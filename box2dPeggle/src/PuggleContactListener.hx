package;

import box2D.dynamics.B2ContactListener;
import box2D.collision.B2ContactPoint;

import BallActor;
import PegActor;

class PuggleContactListener extends B2ContactListener {

  public function new() {
    super();
  }

  override public function Add(point:B2ContactPoint) {
    trace("BAM!");


    if((Std.is(point.shape1.GetBody().GetUserData(), PegActor) &&
        Std.is(point.shape2.GetBody().GetUserData(), BallActor)) ||
       (Std.is(point.shape1.GetBody().GetUserData(), BallActor) &&
        Std.is(point.shape2.GetBody().GetUserData(), PegActor))) {
      trace("ball hit a peg");
    }

    super.Add(point);
  }

}
