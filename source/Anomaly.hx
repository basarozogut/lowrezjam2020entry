package;

import flixel.FlxSprite;

class Anomaly extends FlxSprite
{
	var _speed:Int = 16;

	private var _vertical:Bool;

	public function new(x:Float = 0, y:Float = 0, vertical:Bool, initialDirection:Int)
	{
		super(x + 2, y + 2);

		_vertical = vertical;

		loadGraphic(AssetPaths.anomaly__png, true, 8);

		width = 4;
		height = 4;
		offset.set(2, 2);

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
