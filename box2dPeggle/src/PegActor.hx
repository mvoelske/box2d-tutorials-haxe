package;
import Actor;
import PhysiVals;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.events.EventDispatcher;
import flash.geom.Point;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.collision.shapes.B2CircleDef;
import box2D.common.math.B2Vec2;

import AssetClasses;
import PegEvent;

import caurina.transitions.Tweener;

class PegActor extends HitBonusActor
{

  inline public static var NORMAL:Int = 1;
  inline public static var GOAL:Int = 2;
  inline public static var BONUS:Int = 3;

  inline private static var PEG_DIAMETER:Int = 19;

  private var _beenHit:Bool;
  public var _pegType(default,null):Int;
  private var _turnNormalWhenSafe:Bool;
  private var _turnedNormal:Bool;

  private var _ballForceToApply:B2Vec2;

  public function new(parent:DisplayObjectContainer, location:Point, type:Int) {
    _beenHit = false;
    _pegType = type;
    _turnNormalWhenSafe = false;
    _turnedNormal = false;
    var pegMovie:MovieClip = new PegMovie();
    pegMovie.scaleX = PEG_DIAMETER / pegMovie.width;
    pegMovie.scaleY = PEG_DIAMETER / pegMovie.height;
    parent.addChild(pegMovie);

    // Create shape def
    var pegShapeDef:B2CircleDef = new B2CircleDef();
    pegShapeDef.radius = ((PEG_DIAMETER / 2) / PhysiVals.RATIO);
    pegShapeDef.density = 0;
    pegShapeDef.friction = 0;
    pegShapeDef.restitution = 0.45;

    // create body def
    var pegBodyDef = new B2BodyDef();
    pegBodyDef.position.Set(location.x / PhysiVals.RATIO, location.y /
        PhysiVals.RATIO);

    // create body
    var pegBody = PhysiVals._world.CreateBody(pegBodyDef);

    // create shape
    pegBody.CreateShape(pegShapeDef);
    pegBody.SetMassFromShapes();

    super(pegBody, pegMovie);

    setMyMovieFrame();
  }

  public function hitByBall() {
    if(!_beenHit) {
      _beenHit = true;
      dispatchEvent(new PegEvent(PegEvent.PEG_LIT_UP));
      setMyMovieFrame();
      _turnNormalWhenSafe = true;
    }
  }

  override function hitBonusTarget(center:Bool) {
    if(center) {
      dispatchEvent(new PegEvent(PegEvent.PEG_HIT_BONUS));
    }
  }

  override function childSpecificUpdating() {
    if(_turnNormalWhenSafe && !_turnedNormal) {
      turnNormal();
      _turnedNormal = true;
    }
    if (_costume.y > _costume.stage.stageHeight) {
      dispatchEvent(new PegEvent(PegEvent.PEG_OFF_SCREEN));
    }
    super.childSpecificUpdating();
  }

  public function setCollisionInfo(ballVel:B2Vec2, ballMass:Float,
      collisionNormal:B2Vec2) {
    _ballForceToApply = collisionNormal.Copy();
    _ballForceToApply.Multiply(ballVel.Length());
    _ballForceToApply.Multiply(ballMass);

    var dotProduct:Float = (ballVel.x * collisionNormal.x) + (ballVel.y *
        collisionNormal.y);

    dotProduct /= ballVel.Length();
    dotProduct /= collisionNormal.Length();

    // scale the force with cos(theta), where
    // cos(theta) = (v1 * v2) / (|v1|*|v2|)
    _ballForceToApply.Multiply(dotProduct);
  }

  private function turnNormal() {
    // Iterate through all shapes in our body
    var shape = _body.GetShapeList();
    while(shape != null) {
      shape.m_density = 1.0;
      shape = shape.GetNext();
    }
    _body.SetMassFromShapes();
    _body.WakeUp();
    _body.ApplyImpulse(_ballForceToApply, _body.GetWorldCenter());
  }


  public function fadeOut(pegNumber:Int) {
    //Tweener.addTween(_costume,
    //    {time:0.3, alpha:0, delay:0.08 * pegNumber,
    //     onComplete:sendFadeOutDone}
    //);
  }

  private function sendFadeOutDone() {
    dispatchEvent(new PegEvent(PegEvent.DONE_FADING_OUT));
  }
  
  public function setType(newType:Int) {
    _pegType = newType;
    setMyMovieFrame();
  }

  private function setMyMovieFrame() {
    var  toFrame:Int = 1;
    switch(_pegType) {
      case NORMAL: toFrame=1;
      case GOAL: toFrame=3;
      case BONUS: toFrame=5;
    }
    if(_beenHit) {
      toFrame+=1;
    }
    cast(_costume, MovieClip).gotoAndStop(toFrame);
  }

}
