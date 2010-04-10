package;

class TimeMaster
{
  private var _frameRate:Int;

  public function new() {
    _frameRate = PhysiVals.FRAME_RATE;
  }

  public function getTimeStep():Float {
    return 1.0 / _frameRate;
  }

  public function slowDown() {
    _frameRate = PhysiVals.FRAME_RATE * 5;
  }

  public function backToNormal() {
    _frameRate = PhysiVals.FRAME_RATE;
  }

}
