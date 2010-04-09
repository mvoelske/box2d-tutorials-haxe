package;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.geom.Point;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.collision.shapes.B2ShapeDef;
import box2D.collision.shapes.B2PolygonDef;


class ArbiStaticActor extends Actor
{

  public function new(parent:DisplayObjectContainer, location:Point,
      arrayOfCoords:Array<Array<Point>>) {
    var myBody:B2Body = createBodyFromCoords(arrayOfCoords, location);
    var mySprite:Sprite = createSpriteFromCoords(arrayOfCoords, location,
        parent);
    super(myBody, mySprite);
  }

  private function createBodyFromCoords(arrayOfCoords:Array<Array<Point>>,
      location:Point) {
    // def shapes
    var allShapeDefs:Array<B2ShapeDef> = [];

    for(listOfPoints in arrayOfCoords) {
      var newShapeDef:B2PolygonDef = new B2PolygonDef();
      newShapeDef.vertexCount = listOfPoints.length;
      for(i in 0 ... listOfPoints.length) {
        var nextPoint:Point = listOfPoints[i];
        newShapeDef.vertices[i].Set(nextPoint.x / PhysiVals.RATIO, 
                                    nextPoint.y / PhysiVals.RATIO);
      }
      newShapeDef.density = 0;
      newShapeDef.friction = 0.2;
      newShapeDef.restitution = 0.3;

      allShapeDefs.push(newShapeDef);
    }

    // def body
    var arbiBodyDef:B2BodyDef = new B2BodyDef();
    arbiBodyDef.position.Set(location.x / PhysiVals.RATIO, 
                             location.y / PhysiVals.RATIO);
    // create body
    var arbiBody = PhysiVals._world.CreateBody(arbiBodyDef);

    // create shapes
    for (newShapeDef in allShapeDefs) {
      arbiBody.CreateShape(newShapeDef);
    }
    arbiBody.SetMassFromShapes();

    return arbiBody;
  }

  private function createSpriteFromCoords(arrayOfCoords:Array<Array<Point>>,
      location:Point, parent:DisplayObjectContainer) : Sprite {
    var newSprite:Sprite = new Sprite();
    newSprite.graphics.lineStyle(2, 0x00BB00);

    for (listOfPoints in arrayOfCoords) {
      var firstPoint:Point = listOfPoints[0];
      newSprite.graphics.moveTo(firstPoint.x, firstPoint.y);
      newSprite.graphics.beginFill(0x00BB00);
      for (newPoint in listOfPoints) {
        newSprite.graphics.lineTo(newPoint.x, newPoint.y);
      }

      newSprite.graphics.lineTo(firstPoint.x, firstPoint.y);
      newSprite.graphics.endFill();
    }
    newSprite.x = location.x;
    newSprite.y = location.y;

    parent.addChild(newSprite);

    return newSprite;
  }

}
