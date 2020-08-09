package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;

class MovementPredictor extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
	}

	public function initialize(source:Player):Void
	{
		width = source.width;
		height = source.height;
		offset.set(source.offset.x, source.offset.y);
		acceleration.set(source.acceleration.x, source.acceleration.y);
		drag.set(source.drag.x, source.drag.y);
	}

	public function PredictMovement(forceVector:FlxVector, offsetX:Float, offsetY:Float, timeSlice:Float, steps:Int, predictions:Array<FlxPoint>):Void
	{
		x = offsetX;
		y = offsetY;

		velocity.set(forceVector.x, forceVector.y);

		for (i in 0...steps)
		{
			update(timeSlice);
			predictions[i].x = x;
			predictions[i].y = y;
		}
	}
}
