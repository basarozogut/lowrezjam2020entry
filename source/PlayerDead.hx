package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.system.FlxSound;

class PlayerDead extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		loadGraphic(AssetPaths.player__png, true, 8);

		// bounding box
		width = 6;
		height = 7;
		offset.set(1, 1);

		animation.add("default", [12, 13], 10);
		animation.play("default");

		angularVelocity = 600;

		var dieSound:FlxSound = FlxG.sound.load(AssetPaths.player_die__wav);
		dieSound.play();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
