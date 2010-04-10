package;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;

import caurina.transitions.Tweener;

class Camera extends Sprite 
{

  inline private static var ZOOM_IN_AMT:Float = 3.3;


  public function new() {
    super();
  }


  public function zoomTo(whatPoint:Point) {
    var newx = (Lib.current.stage.stageWidth  / 2) - (whatPoint.x * ZOOM_IN_AMT);
    var newy = (Lib.current.stage.stageHeight / 2) - (whatPoint.y * ZOOM_IN_AMT);

    Tweener.addTween(this, {x:newx, y:newy, scaleX:ZOOM_IN_AMT,
        scaleY:ZOOM_IN_AMT, transition:"linear", time:1.0});

  }

  public function zoomOut() {
    Tweener.addTween(this, {x:0, y:0, scaleX:1, scaleY:1, transition:"linear",
        time:1.0});
  }

}

