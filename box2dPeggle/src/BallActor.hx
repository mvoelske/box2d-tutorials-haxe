package;

import Actor;
import PhysiVals;
import BallSprite;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.geom.Point;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.collision.shapes.B2CircleDef;
import box2D.common.math.B2Vec2;

class BallActor extends Actor 
{
  inline static private var BALL_DIAMETER:Int = 12;

  public function new(parent:DisplayObjectContainer, location:Point, initVel:Point) {
    // create costume
    var ballSprite:Sprite = new BallSprite();
    ballSprite.scaleX = BALL_DIAMETER / ballSprite.width;
    ballSprite.scaleY = BALL_DIAMETER / ballSprite.height;
    parent.addChild(ballSprite);

    // create shape def
    var ballShapeDef:B2CircleDef = new B2CircleDef();
    ballShapeDef.radius  = BALL_DIAMETER / 2 / PhysiVals.RATIO;
    ballShapeDef.density = 1.5;
    ballShapeDef.friction = 0.0;
    ballShapeDef.restitution = 0.45;

    // create body def (with location)
    var ballBodyDef:B2BodyDef = new B2BodyDef();
    ballBodyDef.position.Set(location.x / PhysiVals.RATIO, location.y /
        PhysiVals.RATIO);
    // TODO: one more thing...

    // create body
    var ballBody:B2Body = PhysiVals._world.CreateBody(ballBodyDef); 

    // create shape
    ballBody.CreateShape(ballShapeDef);
    ballBody.SetMassFromShapes();

    // set velocity to match parameter
    var velocityVector:B2Vec2 = new B2Vec2(initVel.x / PhysiVals.RATIO,
        initVel.y / PhysiVals.RATIO);
    ballBody.SetLinearVelocity(velocityVector);

    super(ballBody,ballSprite);
  }
  
  override function childSpecificUpdating() {
    if (_costume.y > _costume.stage.stageHeight) {
      //trace ("Exit Ball!");
      // TODO: remove ball, give player a new one
    }
    super.childSpecificUpdating();
  }

}
