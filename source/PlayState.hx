package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private var _player:Player;
	private var _tilemap:FlxTilemap;

	private var _actors:FlxGroup;

	override public function create()
	{
		loadLevel();

		_player = new Player(16, 16);
		add(_player);

		_actors = new FlxGroup();
		_actors.add(_player);

		FlxG.camera.setScrollBoundsRect(0, 0, cast(_tilemap.width, Int), cast(_tilemap.height, Int), true);
		FlxG.camera.follow(_player, PLATFORMER, .3);

		bgColor = 0xFF0fb7ff;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.collide(_tilemap, _actors);
	}

	private function loadLevel()
	{
		_tilemap = new FlxTilemap();
		_tilemap.loadMapFromGraphic(AssetPaths.level_1__png, true, 1, null, AssetPaths.tileset__png, 8, 8);
		add(_tilemap);
	}
}
