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

class PegActor extends Actor
{

  inline public static var NORMAL:Int = 1;
  inline public static var GOAL:Int = 2;

  inline private static var PEG_DIAMETER:Int = 19;

  private var _beenHit:Bool;
  private var _pegType:Int;


  public function new(parent:DisplayObjectContainer, location:Point, type:Int) {
    _beenHit = false;
    _pegType = type;
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
    }
  }

  public function setType(newType:Int) {
    _pegType = newType;
    setMyMovieFrame();
  }

  private function setMyMovieFrame() {
    if(_pegType == NORMAL) {
      if(_beenHit) {
        cast(_costume, MovieClip).gotoAndStop(2);
      } else {
        cast(_costume, MovieClip).gotoAndStop(1);
      }
    } else {
      if(_beenHit) {
        cast(_costume, MovieClip).gotoAndStop(4);
      } else {
        cast(_costume, MovieClip).gotoAndStop(3);
      }
    }
  }

}
