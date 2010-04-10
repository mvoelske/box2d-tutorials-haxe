package;

import flash.display.Sprite;
import flash.geom.Point;

class AimingLine extends Sprite
{

  private var _gravityInMeters:Float;

  public function new(gravityInMeters:Float) {
    super();
    _gravityInMeters = gravityInMeters;
  }

  public function showLine(startPoint:Point, direction:Point,
      velocityInPixels:Float) {
    // travel vector in px
    var velocityVector = direction.clone();
    
    // set length in px/sec
    velocityVector.normalize(velocityInPixels);

    var gravityInPixels = _gravityInMeters * PhysiVals.RATIO;
    
    var stepPoint = startPoint.clone();

    this.graphics.clear();
    graphics.lineStyle(12, 0x00FF00, .4);
    graphics.moveTo(stepPoint.x, stepPoint.y);

    // steps per second
    var granularity:Int = 20;

    for(i in 0...granularity) {
      velocityVector.y += gravityInPixels / granularity;
      stepPoint.x += velocityVector.x / granularity;
      stepPoint.y += velocityVector.y / granularity;

      graphics.lineTo(stepPoint.x, stepPoint.y);
    }

  }

}
