package;
import flash.display.MovieClip;
import flash.Lib;

class HelloBoxWorld extends MovieClip {

  public function new() {
    super();
    Lib.current.addChild(this);
  }

  public static function main() {
  
  }

}
