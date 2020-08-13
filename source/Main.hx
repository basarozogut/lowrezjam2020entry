package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		LevelManager.instance.addLevel(AssetPaths.level_start__json);
		LevelManager.instance.addLevel(AssetPaths.level_chase__json);
		LevelManager.instance.addLevel(AssetPaths.level_the_tower__json);
		LevelManager.instance.addLevel(AssetPaths.level_mess__json);
		LevelManager.instance.resetState();

		addChild(new FlxGame(64, 64, MenuState));
	}
}
