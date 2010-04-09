package;

import box2D.dynamics.B2ContactListener;
import box2D.collision.B2ContactPoint;

class PuggleContactListener extends B2ContactListener {

  public function new() {
    super();
  }

  override public function Add(point:B2ContactPoint) {
    trace("BAM!");
    super.Add(point);
  }

}
