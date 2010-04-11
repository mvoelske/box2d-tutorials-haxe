package;

import flash.events.Event;


class BallEvent extends Event
{
  inline static public var BALL_OFF_SCREEN:String = "BallOffScreen";
  inline static public var BALL_HIT_BONUS:String = "BallHitBonus";
  inline static public var BALL_HIT_BONUS_SIDE:String = "BallHitBonusSide";

  public function new(type:String, bubbles:Bool=false, cancelable:Bool=false) {
    super(type, bubbles, cancelable);
  }

  public override function clone():Event {
    return new BallEvent(type, bubbles, cancelable);
  }

  public override function toString():String {
    return formatToString("BallEvent", "type", "bubbles", "cancelable",
        "eventPhase");
  }

}
