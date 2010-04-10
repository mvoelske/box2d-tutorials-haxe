package;

import PhysiVals;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import box2D.collision.B2AABB;
import box2D.collision.shapes.B2CircleDef;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;

import Actor;
import BallActor;
import PegActor;
import ArbiStaticActor;
import PuggleContactListener;
import PegEvent;
import BonusChuteActor;

class Puggle extends Sprite {

  var _allActors:Array<Actor>;
  var _actorsToRemove:Array<Actor>;
  var _pegsLitUp:Array<PegActor>;
  var _goalPegs:Array<PegActor>;


  var _director:Director;
  var _camera:Camera;
  var _timeMaster:TimeMaster;
  var _aimingLine:AimingLine;


  var _currentBall:BallActor;

  inline private static var LAUNCH_POINT:Point = new Point(323, 10);
  inline private static var LAUNCH_VELOCITY:Float = 390.0;
  inline private static var GOAL_PEG_NUM:Int = 22;

  public function new() {
    super();

    _camera = new Camera();
    addChild(_camera);

    _allActors = [];
    _actorsToRemove = [];
    _pegsLitUp = [];
    _goalPegs = [];

    _timeMaster = new TimeMaster();
    _currentBall = null;

    _director= new Director(_camera, _timeMaster);

    _aimingLine = new AimingLine(9.8);
    _camera.addChild(_aimingLine);
    _aimingLine.showLine(new Point(250,30), new Point(-3, 2),
        LAUNCH_VELOCITY);

    setupPhysicsWorld();
    createLevel();
    addEventListener(Event.ENTER_FRAME, newFrameListener);

    Lib.current.stage.addEventListener(MouseEvent.CLICK, launchBall);
    
    Lib.current.addChild(this);
  }


  private function createLevel() {/*{{{*/
    var horizSpacing = 36;
    var vertSpacing = 36;
    var pegBounds:Rectangle = new Rectangle(114, 226, 450, 320);
    var flipRow:Bool = false;
    var allPegs:Array<PegActor> = [];


    // Create all of our pegs
    for (pegY in new StepIter(pegBounds.top, pegBounds.bottom, vertSpacing)) {
      var startX = pegBounds.left + (flipRow ? 0 : horizSpacing/2);
      flipRow = !flipRow;
      for (pegX in new StepIter(startX, pegBounds.right, horizSpacing)) {
          var newPeg:PegActor = new PegActor(_camera, new Point(pegX, pegY),
            PegActor.NORMAL);
          newPeg.addEventListener(PegEvent.PEG_LIT_UP, handlePegLitUp);
          _allActors.push(newPeg);
          allPegs.push(newPeg);
      }
    }

    // turn some pegs into goal pegs
    if(allPegs.length < GOAL_PEG_NUM) {
      throw "Dude. I need more pegs!";
    } else {
      for(i in 0...GOAL_PEG_NUM) {
        var randomPegNum = Math.floor(Math.random() * allPegs.length);
        allPegs[randomPegNum].setType(PegActor.GOAL);

        // keep track of which these are
        _goalPegs.push(allPegs[randomPegNum]);
        allPegs.splice(randomPegNum, 1);
      }
    }

    // add the side walls
    var wallShapes:Array<Array<Point>> = [[new Point(0,0), new Point(10,0),
        new Point(10,603), new Point(0,603)]];
    var leftWall:ArbiStaticActor = new ArbiStaticActor(_camera, new Point(-9,0),
        wallShapes);
    _allActors.push(leftWall);

    var rightWall:ArbiStaticActor = new ArbiStaticActor(_camera, new Point(645,
          0), wallShapes);
    _allActors.push(rightWall);

    var leftRampCoords = [[new Point(0,0), new Point(79,27), new Point(79,30),
        new Point(0,3)]];
    var leftRamp1 = new ArbiStaticActor(_camera, new Point(0, 265),
        leftRampCoords);
    _allActors.push(leftRamp1);

    var leftRamp2 = new ArbiStaticActor(_camera, new Point(0, 336),
        leftRampCoords);
    _allActors.push(leftRamp2);

    var leftRamp3 = new ArbiStaticActor(_camera, new Point(0, 415),
        leftRampCoords);
    _allActors.push(leftRamp3);

    var rightRampCoords = [[new Point(0,0), new Point(0,3), new Point(-85,32),
        new Point(-85, 29)]];

    var righRamp1 = new ArbiStaticActor(_camera, new Point(646, 232),
        rightRampCoords);
    _allActors.push(righRamp1);

    var rightRamp2 = new ArbiStaticActor(_camera, new Point(646, 308),
        rightRampCoords);
    _allActors.push(rightRamp2);

    var rightRamp3 = new ArbiStaticActor(_camera, new Point(646, 388),
        rightRampCoords);
    _allActors.push(rightRamp3);


    var bonusChute:BonusChuteActor = new BonusChuteActor(_camera, 200, 450, 580);
    _allActors.push(bonusChute);
  }/*}}}*/

  private function newFrameListener(e:Event) {
    PhysiVals._world.Step(_timeMaster.getTimeStep(), 10);

    for (pa in _allActors) {
      pa.updateNow();
    }

    checkForZooming();

    reallyRemoveActors();
  }

  private function checkForZooming() {
    if(_goalPegs.length == 1 && _currentBall != null) {
      var finalPeg = _goalPegs[0];
      var p1 = finalPeg.getSpriteLoc();
      var p2 = _currentBall.getSpriteLoc();
      if(getDistSquared(p1,p2) < 75*75) {
        _director.zoomIn(p1);
      } else {
        _director.backToNormal();
      }
    } else {
      _director.backToNormal();
    }
  }

  private function getDistSquared(p1:Point, p2:Point) : Int {
    var dx = (p2.x-p1.x); var dy = (p2.y - p1.y);
    return Math.round(dx*dx + dy*dy);
  }

  // actually remove marked actors
  private function reallyRemoveActors() {
    if(_actorsToRemove.length > 0)
    //trace("removing " + _actorsToRemove.length + " actors.");
    for(removeMe in _actorsToRemove) {
      removeMe.destroy();
      _allActors.remove(removeMe);
    }
    _actorsToRemove= [];
  }

  // mark actor to remove later, at a safe time
  public function safeRemoveActor(actorToRemove:Actor) {

    if(!Lambda.has(_actorsToRemove, actorToRemove)) {
      _actorsToRemove.push(actorToRemove);
    }

  }

  private function launchBall(e:MouseEvent) {
    if(_currentBall == null) {
      var direction:Point = new Point(mouseX, mouseY).subtract(LAUNCH_POINT);
      direction.normalize(LAUNCH_VELOCITY);

      var newBall = new BallActor(_camera, LAUNCH_POINT, direction);
      newBall.addEventListener(BallEvent.BALL_OFF_SCREEN, handleBallOffScreen);
      newBall.addEventListener(BallEvent.BALL_HIT_BONUS, handleBallInBonusChute);
      _allActors.push(newBall);
      _currentBall = newBall;
    }
  }

  private function handleBallInBonusChute(e:BallEvent) {
    trace("!B O N U S!");
    handleBallOffScreen(e);
  }

  private function handleBallOffScreen(e:BallEvent) {
    //trace("Ball is off screen");
    var ballToRemove = cast(e.currentTarget, BallActor);
    ballToRemove.removeEventListener(BallEvent.BALL_OFF_SCREEN,
        handleBallOffScreen);
    ballToRemove.removeEventListener(BallEvent.BALL_HIT_BONUS,
        handleBallInBonusChute);
    safeRemoveActor(ballToRemove);

    _currentBall = null;

    // Remove the pegs that have been lit up at this point
    for(pegToRemove in _pegsLitUp) {
      safeRemoveActor(pegToRemove);
    }
    _pegsLitUp = [];
  }

  private function handlePegLitUp(e:PegEvent) {
    // record the fact that the peg has been lit, remove later
    var pegActor:PegActor = cast(e.currentTarget, PegActor);
    pegActor.removeEventListener(PegEvent.PEG_LIT_UP, handlePegLitUp);
    if(!Lambda.has(_pegsLitUp, pegActor)) {
      _pegsLitUp.push(pegActor);
      if(Lambda.has(_goalPegs, pegActor)) {
        _goalPegs.remove(pegActor);
      }
    }
    
  }

  private function setupPhysicsWorld() {
    var worldBounds:B2AABB = new B2AABB();
    worldBounds.lowerBound.Set(-5000 / PhysiVals.RATIO,
        -5000 / PhysiVals.RATIO);
    worldBounds.upperBound.Set(5000 / PhysiVals.RATIO,
        5000 / PhysiVals.RATIO);

    var gravity:B2Vec2 = new B2Vec2(0,9.8);
    var allowSleep:Bool = true;

    PhysiVals._world = new B2World(worldBounds, gravity, allowSleep);
    PhysiVals._world.SetContactListener(new PuggleContactListener());
  }


  public static function main() {
    new Puggle();
  }

}


class StepIter {
  var min:Float; var max:Float; var step:Float;
  public function new (min:Float, max:Float, step:Float) {
    this.min=min;this.max=max;this.step=step; }
  public function hasNext() { return min + step <= max;}
  public function next() { var m = min; min += step; return m;} 
}
