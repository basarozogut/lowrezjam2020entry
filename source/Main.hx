package;

import flixel.FlxGame;
import lime.utils.Assets;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		readLevelList();

		addChild(new FlxGame(64, 64, MenuState));
	}

	private function readLevelList()
	{
		var levelManager = LevelManager.instance;

		var levelListText = Assets.getText(AssetPaths.level_list__txt);
		var levelNames = levelListText.split("\r\n");
		for (levelName in levelNames)
		{
			levelManager.addLevel('assets/data/level_$levelName.json');
		}

		levelManager.resetState();
	}
}
