
package;

import flash.events.Event;


class RestartEvent extends Event
{
  inline static public var NEW_GAME:String = "NewGame";

  public function new(type:String, bubbles:Bool=false, cancelable:Bool=false) {
    super(type, bubbles, cancelable);
  }


  public override function toString():String {
    return formatToString("BallEvent", "type", "bubbles", "cancelable",
        "eventPhase");
  }

}
