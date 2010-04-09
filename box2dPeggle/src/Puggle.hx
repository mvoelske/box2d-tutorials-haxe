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
    var pegBounds:Rectangle = new Rectangle(114, 226, 418, 255);
    var flipRow:Bool = false;

    trace(pegBounds.top);
    for (pegY in 
        new StepIntIter(Math.floor(pegBounds.top), Math.floor(pegBounds.bottom), 
          vertSpacing)) {
      var startX:Int = Math.floor(pegBounds.left + (flipRow ? 0 : horizSpacing/2));
      flipRow = !flipRow;
      for (pegX in new StepIntIter(startX, Math.floor(pegBounds.right),
            horizSpacing)) {
          var newPeg:PegActor = new PegActor(this, new Point(pegX, pegY),
            PegActor.NORMAL);
          _allActors.push(newPeg);
      }
    }

    trace(_allActors.length);
    trace(PhysiVals._world.m_bodyCount);

    // TODO: turn some pegs into goal pegs
    // TODO: keep track of which these are


    // add the side walls
    var wallShapes:Array<Array<Point>> = [[new Point(0,0), new Point(10,0),
        new Point(10,603), new Point(0,603)]];
    var leftWall:ArbiStaticActor = new ArbiStaticActor(this, new Point(0,0),
        wallShapes);
    _allActors.push(leftWall);

    var rightWall:ArbiStaticActor = new ArbiStaticActor(this, new Point(636,
          0), wallShapes);
    _allActors.push(rightWall);

    
  }


  private function newFrameListener(e:Event) {
    PhysiVals._world.Step(1 / 30.0, 10);

    for (pa in _allActors) {
      pa.updateNow();
    }
  }

  private function makeBall() {
    var ballActor = new BallActor(this, new Point(200, 10), new Point(50, -30));
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
  }


  public static function main() {
    new Puggle();
  }

}


class StepIntIter {
  var min:Int; var max:Int; var step:Int;
  public function new (min:Int, max:Int, step:Int) {
    this.min=min;this.max=max;this.step=step; }
  public function hasNext() { return min + step < max;}
  public function next() { var m = min; min += step; return m;} 
}
