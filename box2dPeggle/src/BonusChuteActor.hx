package;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.geom.Point;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.collision.shapes.B2PolygonDef;
import box2D.common.math.B2Vec2;

class BonusChuteActor extends Actor
{

  inline public static var BONUS_TARGET:String = "BonusTarget";
  inline static var TRAVEL_SPEED = 2;
  private var _bounds:Array<Int>;
  private var _yPos:Int;
  private var _direction:Int;

  public function new(parent:DisplayObjectContainer, leftBounds:Int,
      rightBounds:Int, yPos:Int) {

    _bounds = [leftBounds, rightBounds];
    _yPos = yPos;
    _direction = 1;


    var chuteGraphic:Sprite = new BonusChuteSprite();
    parent.addChild(chuteGraphic);

    var leftRampShapeDef:B2PolygonDef = new B2PolygonDef();
    leftRampShapeDef.vertexCount = 3;

    leftRampShapeDef.vertices[0].Set( -83.5 / PhysiVals.RATIO, 12 /
        PhysiVals.RATIO);
    leftRampShapeDef.vertices[1].Set( -63.5 / PhysiVals.RATIO, -4 /
        PhysiVals.RATIO);
    leftRampShapeDef.vertices[2].Set( -63.5 / PhysiVals.RATIO, 12 /
        PhysiVals.RATIO);

    leftRampShapeDef.friction = 0.1;
    leftRampShapeDef.restitution = 0.6;
    leftRampShapeDef.density = 1;

    var rightRampShapeDef:B2PolygonDef = new B2PolygonDef();
    rightRampShapeDef.vertexCount = 3;
    rightRampShapeDef.vertices[0].Set( 83 / PhysiVals.RATIO, 12 /
        PhysiVals.RATIO);
    rightRampShapeDef.vertices[1].Set( 63 / PhysiVals.RATIO, 12 /
        PhysiVals.RATIO);
    rightRampShapeDef.vertices[2].Set( 63 / PhysiVals.RATIO, -4 /
        PhysiVals.RATIO);

    rightRampShapeDef.friction = 0.1;
    rightRampShapeDef.restitution = 0.6;
    rightRampShapeDef.density = 1;


    var centerHoleShapeDef = new B2PolygonDef();
    centerHoleShapeDef.vertexCount = 4;
    centerHoleShapeDef.vertices[0].Set( -64.5 / PhysiVals.RATIO, 0 / PhysiVals.RATIO);
    centerHoleShapeDef.vertices[1].Set( 64.0 / PhysiVals.RATIO, 0 / PhysiVals.RATIO);
    centerHoleShapeDef.vertices[2].Set( 64.0 / PhysiVals.RATIO, 12 / PhysiVals.RATIO);
    centerHoleShapeDef.vertices[3].Set( -64.5 / PhysiVals.RATIO, 12 / PhysiVals.RATIO);
    centerHoleShapeDef.friction = 0.1;
    centerHoleShapeDef.restitution = 0.6;
    centerHoleShapeDef.density = 1;
    centerHoleShapeDef.isSensor = true;
    centerHoleShapeDef.userData = BonusChuteActor.BONUS_TARGET;

    var chuteBodyDef = new B2BodyDef();

    chuteBodyDef.position.Set(((leftBounds + rightBounds) / 2) /
        PhysiVals.RATIO, yPos / PhysiVals.RATIO);
    chuteBodyDef.fixedRotation = true;

    var chuteBody = PhysiVals._world.CreateBody(chuteBodyDef);

    chuteBody.CreateShape(leftRampShapeDef);
    chuteBody.CreateShape(rightRampShapeDef);
    chuteBody.CreateShape(centerHoleShapeDef);
    chuteBody.SetMassFromShapes();

    super(chuteBody, chuteGraphic);
  }


  override function childSpecificUpdating() {

    var idealLocation = new B2Vec2(_costume.x + _costume.mouseX, _yPos);

    if(idealLocation.x < _bounds[0]) idealLocation.x = _bounds[0];
    else if(idealLocation.x > _bounds[1]) idealLocation.x = _bounds[1];

    var directionToTravel = new B2Vec2(idealLocation.x - _costume.x,
        idealLocation.y - _costume.y);

    //distance in meters
    directionToTravel.Multiply(1 / PhysiVals.RATIO);

    // multiply by frame rate to get m/s
    directionToTravel.Multiply(PhysiVals.FRAME_RATE);

    _body.SetLinearVelocity(directionToTravel);

    super.childSpecificUpdating();
  }

}
