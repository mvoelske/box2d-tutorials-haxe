package;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;


class Camera extends Sprite 
{

  inline private static var ZOOM_IN_AMT:Float = 3.3;


  public function new() {
    super();
  }


  public function zoomTo(whatPoint:Point) {
    this.scaleX = ZOOM_IN_AMT;
    this.scaleY = ZOOM_IN_AMT;

    this.x = (Lib.current.stage.stageWidth  / 2) - (whatPoint.x * ZOOM_IN_AMT);
    this.y = (Lib.current.stage.stageHeight / 2) - (whatPoint.y * ZOOM_IN_AMT);
  }

  public function zoomOut() {
    this.scaleX = 1;
    this.scaleY = 1;
    this.x = 0;
    this.y = 0;
  }

}

