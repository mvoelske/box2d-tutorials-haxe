package;

import flash.geom.Point;

class Director 
{
  private var _camera:Camera;
  private var _timeMaster:TimeMaster;

  private var _zoomedIn:Bool;
  private var _minimumTimeToZoomOut:Float;

  public function new(camera:Camera,timeMaster:TimeMaster) {
    _camera = camera;
    _timeMaster = timeMaster;
    _zoomedIn = false;
    _minimumTimeToZoomOut = 0;
  }

  public function zoomIn(zoomInPoint:Point){
    if(!_zoomedIn) {
      _zoomedIn = true;
      _camera.zoomTo(zoomInPoint);
      _timeMaster.slowDown();
      _minimumTimeToZoomOut = Date.now().getTime() + 800;
    }
  }

  public function backToNormal() {
    if(_zoomedIn) {
      if(Date.now().getTime() >= _minimumTimeToZoomOut) {
        _zoomedIn = false;
        _camera.zoomOut();
        _timeMaster.backToNormal();
      }
    }
  }


}
