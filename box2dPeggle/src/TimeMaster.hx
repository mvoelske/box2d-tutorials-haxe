package;

import caurina.transitions.Tweener;

class TimeMaster
{
  public var _frameRate:Int;

  public function new() {
    _frameRate = PhysiVals.FRAME_RATE;
  }

  public function getTimeStep():Float {
    return 1.0 / _frameRate;
  }

  public function slowDown() {
    slowDownBy(5);
  }

  public function slowDownBy(factor:Int) {
    if(Tweener.getTweenCount(this) > 0) Tweener.removeTweens(this);
    Tweener.addTween(this, {_frameRate:PhysiVals.FRAME_RATE*factor,
        time:0.5,transition:"linear"});
  }

  public function backToNormal() {
    if(Tweener.getTweenCount(this) > 0) Tweener.removeTweens(this);
    Tweener.addTween(this, {_frameRate:PhysiVals.FRAME_RATE,
        time:0.5});
  }

}
