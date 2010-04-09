package;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.collision.shapes.B2PolygonDef;
import box2D.common.math.B2Vec2;

class BonusChuteActor extends Actor
{

  inline public static var BONUS_TARGET:String = "BonusTarget";

  public function new(parent:DisplayObjectContainer, leftBounds:Int,
      rightBounds:Int, yPos:Int) {
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
    leftRampShapeDef.density = 0;

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
    rightRampShapeDef.density = 0;


    // TODO: sensor fails to fire sometimes. turn on debugdraw and look at this
    var centerHoleShapeDef = new B2PolygonDef();
    centerHoleShapeDef.vertexCount = 4;
    centerHoleShapeDef.vertices[0].Set( -64.5 / PhysiVals.RATIO, 0 / PhysiVals.RATIO);
    centerHoleShapeDef.vertices[1].Set( 64.0 / PhysiVals.RATIO, 0 / PhysiVals.RATIO);
    centerHoleShapeDef.vertices[2].Set( 64.0 / PhysiVals.RATIO, 12 / PhysiVals.RATIO);
    centerHoleShapeDef.vertices[3].Set( -64.5 / PhysiVals.RATIO, 12 / PhysiVals.RATIO);
    centerHoleShapeDef.friction = 0.1;
    centerHoleShapeDef.restitution = 0.6;
    centerHoleShapeDef.density = 0;
    centerHoleShapeDef.isSensor = true;
    centerHoleShapeDef.userData = BonusChuteActor.BONUS_TARGET;

    var chuteBodyDef = new B2BodyDef();

    chuteBodyDef.position.Set(((leftBounds + rightBounds) / 2) /
        PhysiVals.RATIO, yPos / PhysiVals.RATIO);

    var chuteBody = PhysiVals._world.CreateBody(chuteBodyDef);

    chuteBody.CreateShape(leftRampShapeDef);
    chuteBody.CreateShape(rightRampShapeDef);
    chuteBody.CreateShape(centerHoleShapeDef);
    chuteBody.SetMassFromShapes();

    super(chuteBody, chuteGraphic);
  }

}
