package;

import flash.events.Event;


class PegEvent extends Event
{
  inline static public var PEG_LIT_UP:String = "PegLitUp";

  public function new(type:String, bubbles:Bool=false, cancelable:Bool=false) {
    super(type, bubbles, cancelable);
  }

  public override function clone():Event {
    return new PegEvent(type, bubbles, cancelable);
  }

  public override function toString():String {
    return formatToString("PegEvent", "type", "bubbles", "cancelable",
        "eventPhase");
  }

}
