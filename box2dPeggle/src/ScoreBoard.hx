package;

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.Lib;

class ScoreBoard extends Sprite
{
  inline static var VSPC = 1;
  inline static var HSPC = 10;

  var _score:TextField;
  var _lives:TextField;
  var _balls:TextField;
  var _slomot:TextField;

  public static function mkLabel(fmt:TextFormat, 
                    text:String=null) : TextField
  {
    var label = new TextField();
    label.embedFonts = true;
    label.defaultTextFormat = fmt;
    label.selectable = false;
    if(text != null) {
      label.text = text;
      label.width = label.textWidth;
      label.height = label.textHeight;
    }
    return label;
  }

  public static function below(l:TextField) {
    return l.y + l.textHeight + VSPC;
  }

  public static function rightOf(l:TextField) {
    return l.x + l.textWidth + HSPC;
  }

  public function new() {
    super();
    var fmt:TextFormat;
    fmt = new TextFormat();
    fmt.font = "vera";
    fmt.size = 32;
    var scoreLabel = mkLabel(fmt, "Score: ");
    var livesLabel = mkLabel(fmt, "Lives: "); 
    var ballsLabel = mkLabel(fmt, "Balls: ");

    fmt.size = 16;
    _slomot = mkLabel(fmt);
    _slomot.visible = false;
    _slomot.width = 300;
    fmt.size = 32;
    fmt.font = "blox2";

    _score = mkLabel(fmt);
    _lives = mkLabel(fmt);
    _balls = mkLabel(fmt);

    scoreLabel.x = 0;
    scoreLabel.y = 0;
    livesLabel.x = 0;
    livesLabel.y = below(scoreLabel);
    ballsLabel.x = 0;
    ballsLabel.y = below(livesLabel);
    _slomot.x = 0;
    _slomot.y = below(ballsLabel);

    _score.x = rightOf(scoreLabel);
    _score.y = scoreLabel.y;
    _lives.x = rightOf(livesLabel);
    _lives.y = livesLabel.y;
    _balls.x = rightOf(ballsLabel);
    _balls.y = ballsLabel.y;

    addChild(scoreLabel);
    addChild(livesLabel);
    addChild(ballsLabel);
    addChild(_score);
    addChild(_lives);
    addChild(_balls);
    addChild(_slomot);
  }

  public function update(score:Int, multiplier:Int, lives:Int, balls:Int,
      slomoTime:Float) {
    _score.text = Std.string(score) + " X" + Std.string(multiplier);
    _score.width = _score.textWidth + 10;
    _lives.text = Std.string(lives);
    _balls.text = Std.string(balls);

    if(slomoTime > 0) {
      _slomot.visible = true;
      _slomot.text = "SLOMO!! " + Std.string(Math.round(slomoTime*10)/10) + "s";
    } else {
      _slomot.visible = false;
    }
  }
}
