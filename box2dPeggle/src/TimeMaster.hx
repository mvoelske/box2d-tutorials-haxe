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
    // TODO: figure out why tweening doesn't work anymore
    //Tweener.addTween(this, {_frameRate:PhysiVals.FRAME_RATE*factor,
    //    time:0.5,transition:"linear"});
    _frameRate = PhysiVals.FRAME_RATE * factor;
  }

  public function backToNormal() {
    //Tweener.addTween(this, {_frameRate:PhysiVals.FRAME_RATE,
    //    time:0.5});
    _frameRate = PhysiVals.FRAME_RATE;
  }

}
