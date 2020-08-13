package;

import flixel.FlxSprite;

class Anomaly extends FlxSprite
{
	var _speed:Int = 16;

	private var _vertical:Bool;

	public function new(x:Float = 0, y:Float = 0, vertical:Bool, initialDirection:Int)
	{
		super(x + 1, y + 1);

		_vertical = vertical;

		loadGraphic(AssetPaths.anomaly__png, true, 8);

		width = 6;
		height = 6;
		offset.set(1, 1);

		animation.add("idle", [0, 1, 2, 3, 4], 10);
		animation.play("idle");

		if (!_vertical)
			velocity.x = _speed * initialDirection;
		else
			velocity.y = _speed * initialDirection;
	}

	public function flipDirection(direction:Int)
	{
		if (!_vertical)
			velocity.x = _speed * direction;
		else
			velocity.y = _speed * direction;
	}

	public function isVertical()
	{
		return _vertical;
	}
}
