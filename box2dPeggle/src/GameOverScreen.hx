package;

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

class GameOverScreen extends Sprite
{
  var _textGameOver : TextField;

  public function new() {
    super();
    var fmt = new TextFormat();
    fmt.font = "blox2";
    fmt.size = 64;
    _textGameOver = new TextField();
    _textGameOver.embedFonts = true;
    _textGameOver.defaultTextFormat = fmt;
    _textGameOver.selectable = false;
    _textGameOver.text = "Game Over";
    _textGameOver.width = _textGameOver.textWidth + 5;
    _textGameOver.height = _textGameOver.textHeight;

    var g = graphics;
    g.lineStyle(3.0);
    g.beginFill(0xffffff, .8);
    g.drawRoundRect(0,0,500,250,25);
    g.endFill();

    _textGameOver.x = width/2 - _textGameOver.width/2;
    _textGameOver.y = _textGameOver.height;
    addChild(_textGameOver);
  }

}
