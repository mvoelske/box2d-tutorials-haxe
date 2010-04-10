package;

import flash.display.Sprite;
import flash.events.Event;


class Camera extends Sprite 
{
  public function new() {
    super();
    addEventListener(Event.ENTER_FRAME, moveUp);
  }

  private function moveUp(e:Event) {
    this.y -= 1;
  }
}

