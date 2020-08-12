package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;

class Coin extends FlxSprite
{
	private var _pickedUpSound:FlxSound;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		loadGraphic(AssetPaths.coin__png, true, 8);

		_pickedUpSound = FlxG.sound.load(AssetPaths.pickup_coin__wav);

		animation.add("idle", [0, 1, 2, 3], 10);
		animation.play("idle");
	}

	public function pickedUp():Void
	{
		_pickedUpSound.play();
		kill();
	}
}
