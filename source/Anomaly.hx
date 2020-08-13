package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;

class Anomaly extends FlxSprite
{
	var _speed:Int = 16;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		loadGraphic(AssetPaths.anomaly__png, true, 8);

		animation.add("idle", [0, 1, 2, 3, 4], 10);
		animation.play("idle");

		velocity.x = -_speed;
	}

	public function flipDirection(?direction:Int)
	{
		velocity.x = _speed * direction;
	}
}
