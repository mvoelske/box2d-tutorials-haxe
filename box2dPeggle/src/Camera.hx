package;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;

import caurina.transitions.Tweener;

class Camera extends Sprite 
{

  inline private static var ZOOM_IN_AMT:Float = 5.3;


  public function new() {
    super();
  }


  public function zoomTo(whatPoint:Point) {
    var newx = (Lib.current.stage.stageWidth  / 2) - (whatPoint.x * ZOOM_IN_AMT);
    var newy = (Lib.current.stage.stageHeight / 2) - (whatPoint.y * ZOOM_IN_AMT);

    if(Tweener.getTweenCount(this) > 0) Tweener.removeTweens(this);
    Tweener.addTween(this, {x:newx, y:newy, scaleX:ZOOM_IN_AMT,
        scaleY:ZOOM_IN_AMT, transition:"linear", time:0.3});

  }

  public function zoomOut() {
    if(Tweener.getTweenCount(this) > 0) Tweener.removeTweens(this);
    Tweener.addTween(this, {x:0.0, y:0.0, scaleX:1.0, scaleY:1.0, 
        transition:"linear", time:1.0});
  }

}

