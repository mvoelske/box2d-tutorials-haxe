package;

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


class Puggle extends Sprite {

  inline private static var SHOOTER_POINT:Point = new Point(323, 10);
  inline private static var LAUNCH_VELOCITY:Float = 470.0;
  inline private static var GOAL_PEG_NUM:Int = 22;
  inline private static var BONUS_PEG_NUM:Int = 13;

  inline private static var GRAVITY:Float = 7.8;

  inline private static var TIME_BETWEEN_INCREMENTS:Float = 100;

  inline private static var SLOMO_TIME_BONUS = 5.5;
  inline private static var SLOMO_FACTOR = 5;

  var _allActors:Array<Actor>;
  var _actorsToRemove:Array<Actor>;
  var _pegsLitUp:Array<PegActor>;
  var _goalPegs:Array<PegActor>;

  var _caughtPegs:Array<PegActor>;
  var _allPegs:Array<PegActor>;

  var _caughtBall:Bool;

  var _camera:Camera;
  var _timeMaster:TimeMaster;
  var _aimingLine:AimingLine;

  var _shooter:Shooter;

  var _scoreBoard:ScoreBoard;

  var _currentBall:BallActor;

  var _ballsLeft:Int;
  var _livesLeft:Int;
  var _score:Int;
  var _scoreMultiplier:Int;
  var _nextIncrement:Float;

  var _running:Bool;

  var _slomoSecs:Float;


  public function new() {/*{{{*/
    super();

    _ballsLeft = 1;
    _livesLeft = 3;
    _score = 0;
    _scoreMultiplier = 1;
    _nextIncrement = 0;

    _camera = new Camera();
    addChild(_camera);
    _scoreBoard = new ScoreBoard();
    addChild(_scoreBoard);

    _allActors = [];
    _actorsToRemove = [];
    _pegsLitUp = [];
    _goalPegs = [];
    _caughtPegs = [];
    _allPegs = [];
    _caughtBall = false;
    _running = true;
    _slomoSecs = 0.0;

    _timeMaster = new TimeMaster();
    _currentBall = null;


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
    var tmpPegs:Array<PegActor> = [];
    var sh = Lib.current.stage.stageHeight;
    var sw = Lib.current.stage.stageWidth;
    var horizSpacing = 46;
    var vertSpacing = 46;
    var pegBounds:Rectangle = new Rectangle(114, 226, 480, 320);
    var flipRow:Bool = false;

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
          _allPegs.push(newPeg);
          tmpPegs.push(newPeg);
      }
    }

    // turn some pegs into goal pegs
    if(tmpPegs.length < GOAL_PEG_NUM) {
      throw "Dude. I need more pegs!";
    } else {
      for(i in 0...GOAL_PEG_NUM) {
        var randomPegNum = Math.floor(Math.random() * tmpPegs.length);
        tmpPegs[randomPegNum].setType(PegActor.GOAL);

        // keep track of which these are
        _goalPegs.push(tmpPegs[randomPegNum]);
        tmpPegs.splice(randomPegNum, 1);
      }
    }

    // turn some pegs into bonus pegs  
    if(tmpPegs.length < BONUS_PEG_NUM) {
      throw "Dude. I need more pegs!";
    } else {
      for(i in 0...BONUS_PEG_NUM) {
        var randomPegNum = Math.floor(Math.random() * tmpPegs.length);
        tmpPegs[randomPegNum].setType(PegActor.BONUS);

        // keep track of which these are
        _goalPegs.push(tmpPegs[randomPegNum]);
        tmpPegs.splice(randomPegNum, 1);
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
        Lib.current.stage.stageWidth - 100, 580, _timeMaster);
    _allActors.push(bonusChute);
  }/*}}}*/

  private function destroyPegNow(e:PegEvent) {/*{{{*/
    safeRemoveActor(e.currentTarget);
    e.currentTarget.removeEventListener(PegEvent.DONE_FADING_OUT,
        destroyPegNow);
  }/*}}}*/

  private function newFrameListener(e:Event) {/*{{{*/
    _scoreBoard.update(_score, _livesLeft, _ballsLeft, _slomoSecs);
    if(_running) {
      PhysiVals._world.Step(_timeMaster.getTimeStep(), 10);

      for (pa in _allActors) {
        pa.updateNow();
      }

      if(_slomoSecs > 0) {
        _slomoSecs -= 1.0 / PhysiVals.FRAME_RATE;
      } else {
        _slomoSecs = 0;
        _timeMaster.backToNormal();
      }

      checkForZooming();

      reallyRemoveActors();
    }
  }/*}}}*/

  private function checkForZooming() {/*{{{*/
    // TODO: change so that it zooms in on the last ball lost
    //if(_goalPegs.length == 1 && _currentBall != null) {
    //  var finalPeg = _goalPegs[0];
    //  var p1 = finalPeg.getSpriteLoc();
    //  var p2 = _currentBall.getSpriteLoc();
    //  if(getDistSquared(p1,p2) < 75*75) {
    //  } else {
    //  }
    //} else {
    //}
    if(_currentBall!=null &&
        _currentBall.getSpriteLoc().y > Lib.current.stage.stageHeight - 20) {
      _camera.zoomTo(_currentBall.getSpriteLoc());
    } else {
      _camera.zoomOut();
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

  private function hasValidAimPos():Bool {/*{{{*/
    var bounds:Rectangle = _shooter.getBounds(this);
    return !(mouseX > bounds.left && mouseX < bounds.right && mouseY <
      bounds.bottom);
  }/*}}}*/

  // actually remove marked actors
  private function reallyRemoveActors() {/*{{{*/
    if(_actorsToRemove.length > 0)
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
    if(_currentBall == null && hasValidAimPos() && _ballsLeft > 0) {
      _caughtBall = false;
      _caughtPegs = [];
      var launchPoint = _shooter.getLaunchPosition();

      var direction:Point = new Point(mouseX, mouseY).subtract(launchPoint);

      direction.normalize(LAUNCH_VELOCITY);

      var newBall = new BallActor(_camera, launchPoint, direction);
      newBall.addEventListener(BallEvent.BALL_OFF_SCREEN, handleBallOffScreen);
      newBall.addEventListener(BallEvent.BALL_HIT_BONUS, handleBallInBonusChute);
      newBall.addEventListener(BallEvent.BALL_HIT_BONUS_SIDE,
          incrementMultiplier);
      _allActors.push(newBall);
      _currentBall = newBall;
      _aimingLine.hide();
      _scoreMultiplier = 1;
      _ballsLeft -= 1;
    }
  }/*}}}*/

  private function handleBallInBonusChute(e:BallEvent) {/*{{{*/
    _caughtBall = true;
    getScore(scoreCaughtBall);
    _ballsLeft += 1;
    handleBallOffScreen(e);
  }/*}}}*/

  private function handleBallOffScreen(e:BallEvent) {/*{{{*/
    var ballToRemove = cast(e.currentTarget, BallActor);
    ballToRemove.removeEventListener(BallEvent.BALL_OFF_SCREEN,
        handleBallOffScreen);
    ballToRemove.removeEventListener(BallEvent.BALL_HIT_BONUS,
        handleBallInBonusChute);
    ballToRemove.removeEventListener(BallEvent.BALL_HIT_BONUS_SIDE,
        incrementMultiplier);
    safeRemoveActor(ballToRemove);

    if(!_caughtBall) {
      getScore(scoreLostBall);
    }

    _currentBall = null;
    _scoreMultiplier = 1;

    // Remove the pegs that have been lit up at this point
    for(i in 0..._pegsLitUp.length) {
      var pegToRemove = _pegsLitUp[i];
      //pegToRemove.fadeOut(i);
    }
    _pegsLitUp = [];

    if(_ballsLeft < 1) {
      gameOver();
    }

    showAimLine(null);

  }/*}}}*/

  private function handlePegInBonusChute(e:PegEvent) {/*{{{*/
    var peg = cast(e.currentTarget, PegActor);
    switch(peg._pegType) {
      case PegActor.NORMAL: getScore(scoreCaughtBlue);
      case PegActor.GOAL:   getScore(scoreCaughtRed);
                            loseLife();
      case PegActor.BONUS:  getScore(scoreCaughtBonus);
                            if(_slomoSecs <= 0) {
                              _timeMaster.slowDownBy(SLOMO_FACTOR);
                            }
                            _slomoSecs += SLOMO_TIME_BONUS;
    }
    _caughtPegs.push(peg);
    handlePegOffScreen(e);
  }/*}}}*/

  private function handlePegOffScreen(e:PegEvent) {/*{{{*/
    var pegToRemove = cast(e.currentTarget, PegActor);
    if(!Lambda.has(_caughtPegs, pegToRemove)) {
      // peg really fell off screen
      switch(pegToRemove._pegType) {
        case PegActor.NORMAL: getScore(scoreLostBlue);
        case PegActor.GOAL:    getScore(scoreLostRed);
        case PegActor.BONUS:  getScore(scoreLostBonus);
      }
    }
    _allPegs.remove(pegToRemove);
    if(_allPegs.length == 0) {
      getScore(scoreClearAll);
    }
    pegToRemove.removeEventListener(PegEvent.PEG_OFF_SCREEN,
        handlePegOffScreen);
    pegToRemove.removeEventListener(PegEvent.PEG_HIT_BONUS,
        handlePegInBonusChute);
    safeRemoveActor(pegToRemove);
  }/*}}}*/

  private function incrementMultiplier(e:BallEvent) {/*{{{*/
    if(Date.now().getTime() >= _nextIncrement) {
      _scoreMultiplier++;
      _nextIncrement = Date.now().getTime() + TIME_BETWEEN_INCREMENTS;
    }
  }/*}}}*/

  private function handlePegLitUp(e:PegEvent) {/*{{{*/
    // record the fact that the peg has been lit, remove later
    var pegActor:PegActor = cast(e.currentTarget, PegActor);
    pegActor.removeEventListener(PegEvent.PEG_LIT_UP, handlePegLitUp);
    getScore(scoreHitPeg);
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

  private function loseLife() {/*{{{*/
    _livesLeft -= 1;
    if(_livesLeft < 1) {
      gameOver();
    }
  }/*}}}*/

  private function getScore(e:ScoreType) {/*{{{*/
    var inc = scoreFor(e);
    _score += (inc > 0 ? inc * _scoreMultiplier : inc);
  }/*}}}*/

  private function gameOver() {
    _ballsLeft = 0;
    _running = false;
    Lib.current.stage.removeEventListener(MouseEvent.CLICK, launchBall);
    var gameOverScreen = new GameOverScreen();
    var mc = flash.Lib.current;
    gameOverScreen.x = mc.stage.stageWidth/2 - gameOverScreen.width/2;
    gameOverScreen.y = mc.stage.stageHeight/2 - gameOverScreen.height/2;
    mc.addChild(gameOverScreen);

    //TODO: display score etc
  }

  public static function main() {
    new Puggle();
  }

  private static function getDistSquared(p1:Point, p2:Point) : Int {
    var dx = (p2.x-p1.x); var dy = (p2.y - p1.y);
    return Math.round(dx*dx + dy*dy);
  }

  private static function randomInt(lowVal:Float, hiVal:Float) : Int {
    if(lowVal <= hiVal) {
      return (Math.floor(lowVal) + Math.floor(Math.random() * (hiVal - lowVal
              + 1)));
    }
    return 4;
  }

  private static function scoreFor(e:ScoreType) : Int {
    switch(e) {
      case scoreHitPeg:      return 3;
      case scoreCaughtBall:  return  10;
      case scoreLostBall:    return -10;
      case scoreCaughtRed:   return -50;
      case scoreCaughtBlue:  return 50;
      case scoreCaughtBonus: return 25;
      case scoreLostRed:     return 1;
      case scoreLostBlue:    return -5;
      case scoreLostBonus:   return -50;
      case scoreClearAll:    return 1000;
    }
  }

}


class StepIter {
  var min:Float; var max:Float; var step:Float;
  public function new (min:Float, max:Float, step:Float) {
    this.min=min;this.max=max;this.step=step; }
  public function hasNext() { return min + step <= max;}
  public function next() { var m = min; min += step; return m;} 
}

enum ScoreType {
  scoreHitPeg;
  scoreCaughtBall;
  scoreLostBall;
  scoreCaughtRed;
  scoreCaughtBlue;
  scoreCaughtBonus;
  scoreLostRed;
  scoreLostBlue;
  scoreLostBonus;
  scoreClearAll;
}
