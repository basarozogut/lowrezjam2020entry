package;

import flixel.FlxG;
import flixel.FlxSprite;
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
		var background = new FlxSprite();
		background.loadGraphic(AssetPaths.background_1__png, false, 64, 64);
		background.scrollFactor.set(0, 0);
		add(background);

		loadLevel();

		_player = new Player(16, 16);
		add(_player);

		_actors = new FlxGroup();
		_actors.add(_player);

		FlxG.camera.setScrollBoundsRect(0, 0, cast(_tilemap.width, Int), cast(_tilemap.height, Int), true);
		FlxG.camera.follow(_player, PLATFORMER, .3);

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
		_tilemap.loadMapFromGraphic(AssetPaths.level_2__png, true, 1, null, AssetPaths.tileset__png, 8, 8);
		add(_tilemap);
	}
}
