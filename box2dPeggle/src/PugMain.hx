package;

import flash.Lib;
import flash.display.MovieClip;

class PugMain extends MovieClip
{
  var _puggle:Puggle;

  public function new() {
    super();
    newGame(null);
  }

  private function newGame(e:RestartEvent) {
    if(_puggle != null) {
      Lib.current.removeChild(_puggle);
      _puggle.removeEventListener(RestartEvent.NEW_GAME, newGame);
    }
    _puggle = new Puggle();
    Lib.current.addChild(_puggle);
    _puggle.addEventListener(RestartEvent.NEW_GAME, newGame);
  }

  public static function main() {
    new PugMain();
  }
}
