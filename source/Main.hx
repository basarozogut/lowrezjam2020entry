package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		LevelManager.instance.addLevel(AssetPaths.level_1__json);
		LevelManager.instance.addLevel(AssetPaths.level_2__json);
		LevelManager.instance.resetState();

		addChild(new FlxGame(64, 64, PlayState));
		// addChild(new FlxGame(64, 64, MenuState));
	}
}
