package;

import AssetClasses;
import flash.display.Sprite;

class ShooterSprite extends Sprite
{
  public function new() {
    super();
    var bmp = new BMP_Shooter();

    bmp.x = -45;
    bmp.y = -45;

    addChild(bmp);
  }
}
