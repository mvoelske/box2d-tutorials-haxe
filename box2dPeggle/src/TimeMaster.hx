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
    Tweener.addTween(this, {_frameRate:PhysiVals.FRAME_RATE*5,
        time:0.5,transition:"linear"});
  }

  public function backToNormal() {
    Tweener.addTween(this, {_frameRate:PhysiVals.FRAME_RATE,
        time:0.5,transition:"linear"});
  }

}
