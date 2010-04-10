
package;

import flash.display.Sprite;
import flash.geom.Point;
import flash.events.Event;
import flash.Lib;

import AssetClasses;

class Shooter extends Sprite
{

  inline static private var BALL_OFFSET:Point = new Point(70,0);

  public function new() {
    super();
    addEventListener(Event.ENTER_FRAME, alignToMouse);
    var bmp = new BMP_Shooter();

    bmp.x = -45;
    bmp.y = -45;

    addChild(bmp);
  }

  public function getLaunchPosition():Point {
    return (localToGlobal(BALL_OFFSET));
  }

  private function alignToMouse(e:Event) {
    var mouseAngle:Float = Math.atan2(Lib.current.stage.mouseY - this.y,
                                      Lib.current.stage.mouseX - this.x) * 
                           180 / Math.PI;
    this.rotation = mouseAngle;
  }

}
