package;

import PhysiVals;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
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

class Puggle extends Sprite {

  var _allActors:Array<Actor>;

  public function new() {
    super();

    _allActors = [];

    setupPhysicsWorld();
    makeBall();
    createLevel();
    addEventListener(Event.ENTER_FRAME, newFrameListener);

    Lib.current.addChild(this);
  }


  private function createLevel() {
    var horizSpacing = 36;
    var vertSpacing = 36;
    var pegBounds:Rectangle = new Rectangle(114, 226, 450, 320);
    var flipRow:Bool = false;

    for (pegY in new StepIter(pegBounds.top, pegBounds.bottom, vertSpacing)) {
      var startX = pegBounds.left + (flipRow ? 0 : horizSpacing/2);
      flipRow = !flipRow;
      for (pegX in new StepIter(startX, pegBounds.right, horizSpacing)) {
          var newPeg:PegActor = new PegActor(this, new Point(pegX, pegY),
            PegActor.NORMAL);
          _allActors.push(newPeg);
      }
    }

    // TODO: turn some pegs into goal pegs
    // TODO: keep track of which these are

    // add the side walls
    var wallShapes:Array<Array<Point>> = [[new Point(0,0), new Point(10,0),
        new Point(10,603), new Point(0,603)]];
    var leftWall:ArbiStaticActor = new ArbiStaticActor(this, new Point(-9,0),
        wallShapes);
    _allActors.push(leftWall);

    var rightWall:ArbiStaticActor = new ArbiStaticActor(this, new Point(645,
          0), wallShapes);
    _allActors.push(rightWall);

    var leftRampCoords = [[new Point(0,0), new Point(79,27), new Point(79,30),
        new Point(0,3)]];
    var leftRamp1 = new ArbiStaticActor(this, new Point(0, 265),
        leftRampCoords);
    _allActors.push(leftRamp1);

    var leftRamp2 = new ArbiStaticActor(this, new Point(0, 336),
        leftRampCoords);
    _allActors.push(leftRamp2);

    var leftRamp3 = new ArbiStaticActor(this, new Point(0, 415),
        leftRampCoords);
    _allActors.push(leftRamp3);

    var rightRampCoords = [[new Point(0,0), new Point(0,3), new Point(-85,32),
        new Point(-85, 29)]];

    var righRamp1 = new ArbiStaticActor(this, new Point(646, 232),
        rightRampCoords);
    _allActors.push(righRamp1);

    var rightRamp2 = new ArbiStaticActor(this, new Point(646, 308),
        rightRampCoords);
    _allActors.push(rightRamp2);

    var rightRamp3 = new ArbiStaticActor(this, new Point(646, 388),
        rightRampCoords);
    _allActors.push(rightRamp3);
  }


  private function newFrameListener(e:Event) {
    PhysiVals._world.Step(1 / 30.0, 10);

    for (pa in _allActors) {
      pa.updateNow();
    }
  }

  private function makeBall() {
    var ballActor = new BallActor(this, new Point(500*Math.random(), 10), new
        Point(200*(Math.random()-0.5), -30));
    _allActors.push(ballActor);
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
