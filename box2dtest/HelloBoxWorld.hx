package;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.Lib;
import flash.events.Event;

import box2D.dynamics.B2World;
import box2D.collision.B2AABB;
import box2D.common.math.B2Vec2;
import box2D.collision.shapes.B2PolygonDef;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2DebugDraw;

class HelloBoxWorld extends MovieClip {
  // ratio pixels / meters
  inline static var RATIO : Int = 40;

  var _world : B2World;

  // Number of frames until next crate
  var _nextCrateIn : Int;

  public function new() {
    super();
    Lib.current.addChild(this);
    // 1. set up world
    setupWorld();
    // 2. create walls + floor
    createWallsAndFloor();

    setupDebugDraw();

    addEventListener(Event.ENTER_FRAME, newFrameEvent);

    _nextCrateIn = 0;
  }

  private function setupDebugDraw() {

    var spriteToDrawOn:Sprite = new Sprite();
    addChild(spriteToDrawOn);

    var artistForHire:B2DebugDraw = new B2DebugDraw();
    artistForHire.m_sprite = spriteToDrawOn;
    artistForHire.m_drawScale = RATIO;
    artistForHire.SetFlags(
        //B2DebugDraw.e_aabbBit | 
        B2DebugDraw.e_shapeBit
        );
    artistForHire.m_lineThickness = 2.0;
    artistForHire.m_fillAlpha = 0.6;
  
    _world.SetDebugDraw(artistForHire);
  }

  private function newFrameEvent(e:Event) {

    _world.Step(1.0 / 30.0, 10);

    // every few frames, until a certain number of crates have been added
    if(_world.m_bodyCount < 80 && _nextCrateIn-- <= 0) {
      // add a random crate to the world
      addARandomCrate();
      _nextCrateIn = 5;
    }
    
    //trace("Falling crate is at " + _fallingCrate.GetPosition().x + "," +
    //    _fallingCrate.GetPosition().y);
  }

  private function setupWorld() {
    // 1. Set up size of universe
    var universeSize:B2AABB = new B2AABB();
    // we want a 6000px by 6000px universe
    universeSize.lowerBound.Set(-3000 / RATIO, -3000 / RATIO);
    universeSize.upperBound.Set( 3000 / RATIO,  3000 / RATIO);

    // 2. define gravity
    var gravity:B2Vec2 = new B2Vec2(0, 3.8);

    // 3. ignore sleeping objects?
    var ignoreSleeping:Bool = true;

    _world = new B2World(universeSize, gravity, ignoreSleeping);

    trace("My world has " + _world.GetBodyCount() + " bodies in it.");
  }


  private function createWallsAndFloor() {
    // 1. create shape (polygon) def
    var bigLongShapeDef:B2PolygonDef = new B2PolygonDef();
    bigLongShapeDef.vertexCount = 4;
    // (no cast needed, haXe handles that)
    bigLongShapeDef.vertices[0].Set(0 / RATIO, 0 / RATIO);
    bigLongShapeDef.vertices[1].Set(550 / RATIO, 0 / RATIO);
    bigLongShapeDef.vertices[2].Set(550 / RATIO, 10 / RATIO);
    bigLongShapeDef.vertices[3].Set(0 / RATIO, 10 / RATIO);
    bigLongShapeDef.friction = 0.5;
    bigLongShapeDef.restitution = 0.3;
    bigLongShapeDef.density = 0.0; // static shape

    // 2. create body def
    var floorBodyDef:B2BodyDef = new B2BodyDef();
    floorBodyDef.position.Set(0 / RATIO, 390 / RATIO);

    // 3. create body
    var floorBody:B2Body = _world.CreateBody(floorBodyDef);

    // 4. create shape
    floorBody.CreateShape(bigLongShapeDef);
    floorBody.SetMassFromShapes();

    var tallSkinnyShapeDef:B2PolygonDef = new B2PolygonDef();
    // half-width, half-height
    tallSkinnyShapeDef.SetAsBox(5 / RATIO, 195 / RATIO);
    tallSkinnyShapeDef.friction = 0.5;
    tallSkinnyShapeDef.restitution = 0.3;
    tallSkinnyShapeDef.density = 0.0; // static shape

    var wallBodyDef:B2BodyDef = new B2BodyDef();
    wallBodyDef.position.Set(5 / RATIO, 195 / RATIO);

    var leftWall:B2Body = _world.CreateBody(wallBodyDef);
    leftWall.CreateShape(tallSkinnyShapeDef);
    leftWall.SetMassFromShapes();

    wallBodyDef.position.Set(545 / RATIO, 195 / RATIO);
    var rightWall = _world.CreateBody(wallBodyDef);
    rightWall.CreateShape(tallSkinnyShapeDef);
    rightWall.SetMassFromShapes();

    trace ("My world now has " + _world.m_bodyCount + " bodies in it.");
  }

  
  private function addARandomCrate() {
    var fallingCrateDef:B2PolygonDef = new B2PolygonDef();
    fallingCrateDef.SetAsBox(randomInt(5,10) / RATIO, randomInt(5,40) / RATIO);
    fallingCrateDef.friction = 0.8;
    fallingCrateDef.restitution = 0.99;
    fallingCrateDef.density = 0.2 + Math.random() * 5;

    var fallingBodyDef:B2BodyDef = new B2BodyDef();
    fallingBodyDef.position.Set(randomInt(15,530) / RATIO, 
        randomInt(-100,-10) / RATIO);
    fallingBodyDef.angle = randomInt(0,360) * Math.PI / 180;

    var fallingCrate = _world.CreateBody(fallingBodyDef);
    fallingCrate.CreateShape(fallingCrateDef);
    fallingCrate.SetMassFromShapes();
  }

  private function randomInt(lowVal:Int, hiVal:Int) : Int {

    if(lowVal <= hiVal) {
      return (lowVal + Math.floor(Math.random() * (hiVal - lowVal + 1)));
    }

    return 4;
  }

  // HaXe main function
  public static function main() {
    new HelloBoxWorld();
  
  }

}
