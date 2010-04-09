package;

import PhysiVals;
import BallSprite;

import flash.Lib;
import flash.display.Sprite;

import box2D.collision.B2AABB;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;
import box2D.dynamics.B2Body;


class Puggle extends Sprite {

  var _ballSprite:Sprite;
  var _ballBody:B2Body;

  public function new() {
    super();

    setupPhysicsWorld();
    makeBall();

    Lib.current.addChild(this);
  }

  private function makeBall() {
    // Create Sprite
    _ballSprite = new BallSprite();
    addChild(_ballSprite);

    // Create B2Body
  
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
