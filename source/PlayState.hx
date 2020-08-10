package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private var _player:Player;
	private var _guide:FlxSprite;
	private var _tilemap:FlxTilemap;

	private var _actors:FlxGroup;

	override public function create()
	{
		_guide = new FlxSprite(0, 0);
		_guide.makeGraphic(64, 64, FlxColor.TRANSPARENT, true);
		_guide.scrollFactor.set(0, 0);

		var background = new FlxSprite();
		background.loadGraphic(AssetPaths.background_1__png, false, 64, 64);
		background.scrollFactor.set(0, 0);
		add(background);

		loadLevel();
		generateBackgroundTiles();
		add(_tilemap);

		var predictor = new MovementPredictor(0, 0);
		_player = new Player(16, 16, _guide, predictor);
		add(_player);

		_actors = new FlxGroup();
		_actors.add(_player);

		add(_guide);

		FlxG.camera.setScrollBoundsRect(0, 0, cast _tilemap.width, cast _tilemap.height, true);
		FlxG.camera.follow(_player, PLATFORMER, .3);

		bgColor = 0xff55ed8d;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SPACE)
		{
			FlxG.resetGame();
		}

		super.update(elapsed);

		FlxG.collide(_tilemap, _actors, tilemapCollidedActor);
	}

	private function tilemapCollidedActor(a:FlxObject, b:FlxObject)
	{
		if ((b is Player))
		{
			if (b.justTouched(FlxObject.ANY))
			{
				var player:Player = cast b;
				player.hitTilemap();
			}
		}
	}

	private function loadLevel()
	{
		_tilemap = new FlxTilemap();
		_tilemap.loadMapFromGraphic(AssetPaths.level_2__png, true, 1, null, AssetPaths.tileset__png, 8, 8);
	}

	private function generateBackgroundTiles()
	{
		var tileSize = 4;
		var nTilesHorizontal:Int = cast _tilemap.width / tileSize;
		var nTilesVertical:Int = cast 64 / tileSize / 3;
		var map = [];

		for (i in 0...nTilesVertical)
		{
			var row = [];
			for (j in 0...nTilesHorizontal)
			{
				var solid = FlxG.random.bool(20);
				row.push(solid ? 1 : 0);
			}
			map.push(row);
		}

		var bgTilemap = new FlxTilemap();
		bgTilemap.loadMapFrom2DArray(map, AssetPaths.tileset_bg__png, tileSize, tileSize);
		bgTilemap.scrollFactor.set(0.2, 0.2);
		bgTilemap.y = _tilemap.y + _tilemap.height - bgTilemap.height;
		add(bgTilemap);
	}
}
