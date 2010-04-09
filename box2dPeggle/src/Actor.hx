package;

import PhysiVals;

import flash.display.DisplayObject;
import flash.events.EventDispatcher;

import box2D.dynamics.B2Body;

class Actor extends EventDispatcher {

  private var _body(default,null):B2Body;
  private var _costume(default,null):DisplayObject;

  public function new(myBody:B2Body, myCostume:DisplayObject) {
    super();

    _body = myBody;
    _body.SetUserData(this);
    _costume = myCostume;

    updateMyLook();
  }

  public function updateNow() {
    if (!_body.IsStatic()) {
      updateMyLook();
    }
    childSpecificUpdating();
  }

  function childSpecificUpdating() {
    // does nothing
    // overridden by subclasses
  }

  function cleanUpBeforeRemoving() {
    // does nothing
    // overridden by subclasses
  }

  // remove the actor from the world
  public function destroy() {
    // remove evt listeners, misc cleanup
    cleanUpBeforeRemoving();

    // remove costume sprite from display
    _costume.parent.removeChild(_costume);
    
    // destroy the body
    PhysiVals._world.DestroyBody(_body);

  }

  private function updateMyLook() {
    _costume.x = _body.GetPosition().x * PhysiVals.RATIO;
    _costume.y = _body.GetPosition().y * PhysiVals.RATIO;
    _costume.rotation = _body.GetAngle() * 180 / Math.PI;
  }


}
