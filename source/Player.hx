package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	private var _forceStartPosition:FlxPoint;
	private var _forceEndPosition:FlxPoint;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		makeGraphic(8, 8, FlxColor.WHITE);

		// physics
		acceleration.y = 240;
		drag.x = 50;
		elasticity = .7;

		_forceStartPosition = new FlxPoint();
		_forceEndPosition = new FlxPoint();
	}

	override public function update(elapsed:Float)
	{
		updateInput();

		super.update(elapsed);
	}

	private function updateInput()
	{
		if (FlxG.mouse.justPressed)
		{
			_forceStartPosition.x = FlxG.mouse.x;
			_forceStartPosition.y = FlxG.mouse.y;
		}

		if (FlxG.mouse.justReleased)
		{
			_forceEndPosition.x = FlxG.mouse.x;
			_forceEndPosition.y = FlxG.mouse.y;
			throwPlayer();
		}
	}

	private function throwPlayer()
	{
		var forceVector = new FlxVector(_forceEndPosition.x - _forceStartPosition.x, _forceEndPosition.y - _forceStartPosition.y);
		// forceVector.truncate(30);
		forceVector.scale(-3);
		velocity.x = forceVector.x;
		velocity.y = forceVector.y;
	}
}
