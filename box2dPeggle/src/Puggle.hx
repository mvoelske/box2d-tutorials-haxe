package;

import PhysiVals;
import BallSprite;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;

import box2D.collision.B2AABB;
import box2D.collision.shapes.B2CircleDef;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;

import Actor;
import BallActor;

class Puggle extends Sprite {

  var _ballActor:BallActor;

  public function new() {
    super();

    setupPhysicsWorld();
    makeBall();
    addEventListener(Event.ENTER_FRAME, newFrameListener);

    Lib.current.addChild(this);
  }

  private function newFrameListener(e:Event) {
    PhysiVals._world.Step(1 / 30.0, 10);

    _ballActor.updateNow();
  }

  private function makeBall() {
    _ballActor = new BallActor(this, new Point(200, 10), new Point(50, -30));
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
