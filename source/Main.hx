package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(64, 64, PlayState));
		// addChild(new FlxGame(64, 64, MenuState));
	}
}
