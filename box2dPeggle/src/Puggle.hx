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

  var _shooter:Shooter;


  var _currentBall:BallActor;

  inline private static var SHOOTER_POINT:Point = new Point(323, 10);
  inline private static var LAUNCH_VELOCITY:Float = 470.0;
  inline private static var GOAL_PEG_NUM:Int = 22;
  inline private static var GRAVITY:Float = 7.8;


  public function new() {/*{{{*/
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

    _shooter = new Shooter();
    _camera.addChild(_shooter);
    _shooter.x = SHOOTER_POINT.x;
    _shooter.y = SHOOTER_POINT.y;
    _aimingLine = new AimingLine(GRAVITY);
    _camera.addChild(_aimingLine);

    setupPhysicsWorld();
    createLevel();
    addEventListener(Event.ENTER_FRAME, newFrameListener);

    Lib.current.stage.addEventListener(MouseEvent.CLICK, launchBall);
    Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, showAimLine);
    
    Lib.current.addChild(this);
  }/*}}}*/

  private function createLevel() {/*{{{*/
    var horizSpacing = 46;
    var vertSpacing = 46;
    var pegBounds:Rectangle = new Rectangle(114, 226, 480, 320);
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
          newPeg.addEventListener(PegEvent.DONE_FADING_OUT, destroyPegNow);
          newPeg.addEventListener(PegEvent.PEG_OFF_SCREEN, handlePegOffScreen);
          newPeg.addEventListener(PegEvent.PEG_HIT_BONUS, handlePegInBonusChute);
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


    var bonusChute:BonusChuteActor = new BonusChuteActor(_camera, 100,
        Lib.current.stage.stageWidth - 100, 580);
    _allActors.push(bonusChute);
  }/*}}}*/

  private function destroyPegNow(e:PegEvent) {/*{{{*/
    safeRemoveActor(e.currentTarget);
    e.currentTarget.removeEventListener(PegEvent.DONE_FADING_OUT,
        destroyPegNow);
  }/*}}}*/

  private function newFrameListener(e:Event) {/*{{{*/
    PhysiVals._world.Step(_timeMaster.getTimeStep(), 10);

    for (pa in _allActors) {
      pa.updateNow();
    }

    checkForZooming();

    reallyRemoveActors();
  }/*}}}*/

  private function checkForZooming() {/*{{{*/
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
  }/*}}}*/

  private function showAimLine(e:MouseEvent) {/*{{{*/
    if(_currentBall == null) {
      if(!hasValidAimPos()) {
        _aimingLine.hide();
        return;
      }
      var launchPoint = _shooter.getLaunchPosition();
      var direction:Point = new Point(mouseX, mouseY).subtract(launchPoint);
      _aimingLine.showLine(launchPoint, direction, LAUNCH_VELOCITY);
    }
  }/*}}}*/

  private function hasValidAimPos():Bool {
    var bounds:Rectangle = _shooter.getBounds(this);
    return !(mouseX > bounds.left && mouseX < bounds.right && mouseY <
      bounds.bottom);
  }

  // actually remove marked actors
  private function reallyRemoveActors() {/*{{{*/
    if(_actorsToRemove.length > 0)
    //trace("removing " + _actorsToRemove.length + " actors.");
    for(removeMe in _actorsToRemove) {
      removeMe.destroy();
      _allActors.remove(removeMe);
    }
    _actorsToRemove= [];
  }/*}}}*/

  // mark actor to remove later, at a safe time
  public function safeRemoveActor(actorToRemove:Actor) {/*{{{*/

    if(!Lambda.has(_actorsToRemove, actorToRemove)) {
      _actorsToRemove.push(actorToRemove);
    }

  }/*}}}*/

  private function launchBall(e:MouseEvent) {/*{{{*/
    if(_currentBall == null && hasValidAimPos()) {
      var launchPoint = _shooter.getLaunchPosition();

      var direction:Point = new Point(mouseX, mouseY).subtract(launchPoint);

      direction.normalize(LAUNCH_VELOCITY);

      var newBall = new BallActor(_camera, launchPoint, direction);
      newBall.addEventListener(BallEvent.BALL_OFF_SCREEN, handleBallOffScreen);
      newBall.addEventListener(BallEvent.BALL_HIT_BONUS, handleBallInBonusChute);
      _allActors.push(newBall);
      _currentBall = newBall;
      _aimingLine.hide();
    }
  }/*}}}*/

  private function handleBallInBonusChute(e:BallEvent) {/*{{{*/
    trace("!B O N U S!");
    handleBallOffScreen(e);
  }/*}}}*/

  private function handlePegInBonusChute(e:PegEvent) {/*{{{*/
    trace("peg bonus: " + cast(e.currentTarget, PegActor)._pegType);
    handlePegOffScreen(e);
  }/*}}}*/

  private function handlePegOffScreen(e:PegEvent) {/*{{{*/
    var pegToRemove = cast(e.currentTarget, PegActor);
    pegToRemove.removeEventListener(PegEvent.PEG_OFF_SCREEN,
        handlePegOffScreen);
    pegToRemove.removeEventListener(PegEvent.PEG_HIT_BONUS,
        handlePegInBonusChute);
    safeRemoveActor(pegToRemove);
  }/*}}}*/

  private function handleBallOffScreen(e:BallEvent) {/*{{{*/
    //trace("Ball is off screen");
    var ballToRemove = cast(e.currentTarget, BallActor);
    ballToRemove.removeEventListener(BallEvent.BALL_OFF_SCREEN,
        handleBallOffScreen);
    ballToRemove.removeEventListener(BallEvent.BALL_HIT_BONUS,
        handleBallInBonusChute);
    safeRemoveActor(ballToRemove);

    _currentBall = null;

    // Remove the pegs that have been lit up at this point
    for(i in 0..._pegsLitUp.length) {
      var pegToRemove = _pegsLitUp[i];
      //pegToRemove.fadeOut(i);
    }
    _pegsLitUp = [];

    showAimLine(null);
  }/*}}}*/

  private function handlePegLitUp(e:PegEvent) {/*{{{*/
    // record the fact that the peg has been lit, remove later
    var pegActor:PegActor = cast(e.currentTarget, PegActor);
    pegActor.removeEventListener(PegEvent.PEG_LIT_UP, handlePegLitUp);
    if(!Lambda.has(_pegsLitUp, pegActor)) {
      _pegsLitUp.push(pegActor);
      if(Lambda.has(_goalPegs, pegActor)) {
        _goalPegs.remove(pegActor);
      }
    }
    
  }/*}}}*/

  private function setupPhysicsWorld() {/*{{{*/
    var worldBounds:B2AABB = new B2AABB();
    worldBounds.lowerBound.Set(-5000 / PhysiVals.RATIO,
        -5000 / PhysiVals.RATIO);
    worldBounds.upperBound.Set(5000 / PhysiVals.RATIO,
        5000 / PhysiVals.RATIO);

    var gravity:B2Vec2 = new B2Vec2(0,GRAVITY);
    var allowSleep:Bool = true;

    PhysiVals._world = new B2World(worldBounds, gravity, allowSleep);
    PhysiVals._world.SetContactListener(new PuggleContactListener());
  }/*}}}*/

  public static function main() {
    new Puggle();
  }

  private static function getDistSquared(p1:Point, p2:Point) : Int {
    var dx = (p2.x-p1.x); var dy = (p2.y - p1.y);
    return Math.round(dx*dx + dy*dy);
  }

}


class StepIter {
  var min:Float; var max:Float; var step:Float;
  public function new (min:Float, max:Float, step:Float) {
    this.min=min;this.max=max;this.step=step; }
  public function hasNext() { return min + step <= max;}
  public function next() { var m = min; min += step; return m;} 
}
