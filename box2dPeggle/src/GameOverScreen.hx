package;

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

class GameOverScreen extends Sprite
{
  var _textGameOver : TextField;
  var _textScore : TextField;
  var _textScoreLabel : TextField;

  function adjust(t:TextField, y:Float) {
    t.width = t.textWidth + 5;
    t.height = t.textHeight;
    t.x = width/2 - t.width/2;
    t.y = y;
  }

  public function new(finalScore:Int) {
    super();
    var fmt = new TextFormat();
    fmt.font = "blox2";
    fmt.size = 64;
    _textGameOver = ScoreBoard.mkLabel(fmt, "Game Over");

    fmt.size = 32;
    _textScoreLabel = ScoreBoard.mkLabel(fmt, "Final Score");
    _textScore = ScoreBoard.mkLabel(fmt, Std.string(finalScore));

    var g = graphics;
    g.lineStyle(3.0);
    g.beginFill(0xffffff, .8);
    g.drawRoundRect(0,0,500,250,25);
    g.endFill();

    adjust(_textGameOver, _textGameOver.height * 0.9);
    adjust(_textScoreLabel, ScoreBoard.below(_textGameOver) + 20);
    adjust(_textScore, ScoreBoard.below(_textScoreLabel));
    addChild(_textGameOver);
    addChild(_textScore);
    addChild(_textScoreLabel);
  }

}
