package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	private var _player:Player;
	private var _tilemap:FlxTilemap;

	private var _actors:FlxGroup;

	override public function create()
	{
		super.create();

		loadLevel();

		_player = new Player(16, 16);
		add(_player);

		_actors = new FlxGroup();
		_actors.add(_player);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.collide(_tilemap, _actors);
	}

	private function loadLevel()
	{
		_tilemap = new FlxTilemap();
		var tilemapArray = [
			[1, 1, 1, 1, 1, 1, 1, 1],
			[1, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 1],
			[1, 1, 1, 1, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 1],
			[1, 1, 1, 1, 1, 1, 1, 1]
		];
		_tilemap.loadMapFrom2DArray(tilemapArray, AssetPaths.tileset__png, 8, 8);
		add(_tilemap);
	}
}
