package;

import flash.display.MovieClip;
import flash.display.Bitmap;
import AssetClasses;

class PegMovie extends MovieClip {
  public function new() {
    super();
    for (i in 1...4) {
      var bmp:Bitmap = null;
      switch (i) {
        case 1: bmp = new BMP_Peg_Red();
        case 2: bmp = new BMP_Peg_Blue();
        case 3: bmp = new BMP_Peg_Red_Lit();
        case 4: bmp = new BMP_Peg_Blue_Lit();
      }
      bmp.x = -bmp.width/2; 
      bmp.y = -bmp.height/2;
      addChild(bmp);
      nextFrame();
    }
  }
}

//enum PegType {
//  red;
//  blue;
//  red_lit;
//  blue_lit;
//}


