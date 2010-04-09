package;

import flash.display.Sprite;
import AssetClasses;

class BallSprite extends Sprite {

  public function new() {
    super();
    var bmp = new BallBitmap();
    bmp.x = -bmp.width/2; 
    bmp.y = -bmp.height/2;
    addChild(bmp);
  }


}
