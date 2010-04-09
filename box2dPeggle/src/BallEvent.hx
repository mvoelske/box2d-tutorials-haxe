package;

import flash.events.Event;


class BallEvent extends Event
{
  inline static public var BALL_OFF_SCREEN:String = "BallOffScreen";

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
