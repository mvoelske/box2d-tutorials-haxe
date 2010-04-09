package;

import PhysiVals;
import BallSprite;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;

import box2D.collision.B2AABB;
import box2D.collision.shapes.B2CircleDef;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;


class Puggle extends Sprite {

  var _ballSprite:Sprite;
  var _ballBody:B2Body;

  public function new() {
    super();

    setupPhysicsWorld();
    makeBall();
    addEventListener(Event.ENTER_FRAME, newFrameListener);

    Lib.current.addChild(this);
  }

  private function newFrameListener(e:Event) {
    PhysiVals._world.Step(1 / 30.0, 10);

    _ballSprite.x = _ballBody.GetPosition().x * PhysiVals.RATIO;
    _ballSprite.y = _ballBody.GetPosition().y * PhysiVals.RATIO;

    _ballSprite.rotation = _ballBody.GetAngle() * 180 / Math.PI;
  }

  private function makeBall() {
    // Create Sprite
    _ballSprite = new BallSprite();
    addChild(_ballSprite);

    // Create B2Body
    var ballShapeDef:B2CircleDef = new B2CircleDef();
    ballShapeDef.radius = 15 / PhysiVals.RATIO;
    ballShapeDef.density = 1.0;

    var ballBodyDef : B2BodyDef = new B2BodyDef();
    ballBodyDef.position.Set(200 / PhysiVals.RATIO, 10 / PhysiVals.RATIO);
  
    _ballBody = PhysiVals._world.CreateBody(ballBodyDef);
    _ballBody.CreateShape(ballShapeDef);
    _ballBody.SetMassFromShapes();
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
