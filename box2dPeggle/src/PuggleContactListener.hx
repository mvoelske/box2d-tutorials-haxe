package;

import box2D.dynamics.B2ContactListener;
import box2D.collision.B2ContactPoint;
import box2D.common.math.B2Vec2;

import BallActor;
import PegActor;

class PuggleContactListener extends B2ContactListener {

  public function new() {
    super();
  }

  override public function Add(point:B2ContactPoint) {
    //trace("BAM!");

    if((Std.is(point.shape1.GetBody().GetUserData(), BallActor) ||
          Std.is(point.shape2.GetBody().GetUserData(), BallActor))) {

      // ball hits bonus chute sides
      if((Std.is(point.shape1.GetUserData(), String) &&
          cast(point.shape1.GetUserData(), String) ==
          BonusChuteActor.SIDE_TARGET)) {
        cast(point.shape2.GetBody().GetUserData(),
            BallActor).hitBonusTarget(false);
      } else if
         (Std.is(point.shape2.GetUserData(), String) &&
         cast(point.shape2.GetUserData(), String) ==
         BonusChuteActor.SIDE_TARGET)  {
        cast(point.shape1.GetBody().GetUserData(),
            BallActor).hitBonusTarget(false);
        
      }

      // peg hits a ball
      if(Std.is(point.shape1.GetBody().GetUserData(), PegActor)) {
        if(point.shape1.GetBody().IsStatic()) {
          cast(point.shape1.GetBody().GetUserData(),PegActor).hitByBall();
          cast(point.shape1.GetBody().GetUserData(),PegActor).setCollisionInfo(
              point.shape2.GetBody().GetLinearVelocity(),
              point.shape2.GetBody().GetMass(),
              new B2Vec2(point.normal.x*-1, point.normal.y*-1) );
        }
      // ball hits a peg
      } else if(Std.is(point.shape2.GetBody().GetUserData(), PegActor)) {
        if(point.shape2.GetBody().IsStatic()) {
          cast(point.shape2.GetBody().GetUserData(),PegActor).hitByBall();
          cast(point.shape2.GetBody().GetUserData(),PegActor).setCollisionInfo(
              point.shape1.GetBody().GetLinearVelocity(),
              point.shape1.GetBody().GetMass(),
              point.normal );
        }
      }


    } 

    // something hits the center of the bonus chute
    if(Std.is(point.shape1.GetBody().GetUserData(), HitBonusActor) ||
        Std.is(point.shape2.GetBody().GetUserData(), HitBonusActor)) {
      if(Std.is(point.shape1.GetUserData(), String) &&
          cast(point.shape1.GetUserData(),String) ==
          BonusChuteActor.BONUS_TARGET) {
        cast(point.shape2.GetBody().GetUserData(),
            HitBonusActor).hitBonusTarget(true);
      } else if (Std.is(point.shape2.GetUserData(), String) &&
          cast(point.shape2.GetUserData(),String) ==
          BonusChuteActor.BONUS_TARGET) {
        cast(point.shape1.GetBody().GetUserData(),
            HitBonusActor).hitBonusTarget(true);
      }
    }

    super.Add(point);
  }

}
