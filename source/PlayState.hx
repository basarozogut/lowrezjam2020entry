package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private var _player:Player;
	private var _tilemap:FlxTilemap;
	private var _camTarget:FlxObject;

	// Physical groups
	private var _actors:FlxGroup;
	private var _collectibles:FlxGroup;
	private var _markers:FlxGroup;

	// Logical groups
	private var _enemies:FlxGroup;

	private var _scoreText:FlxText;

	private var _emitter:FlxEmitter;
	private var _whitePixel:FlxParticle;

	override public function create()
	{
		// Particles
		var nParticles = 200;
		_emitter = new FlxEmitter(0, 0, nParticles);
		_emitter.velocity.set(-200, -10, -100, 10);
		_emitter.width = FlxG.width;
		_emitter.height = FlxG.height;

		for (i in 0...nParticles)
		{
			_whitePixel = new FlxParticle();
			_whitePixel.scrollFactor.set(0, 0);
			_whitePixel.makeGraphic(1, 1, 0xAAFFFFFF);
			_whitePixel.visible = false; // Make sure the particle doesn't show up at (0, 0)
			_emitter.add(_whitePixel);
		}

		// Gameplay
		_player = new Player(0, 0);
		_scoreText = new FlxText(0, 0, 0, "");
		_scoreText.setFormat("assets/fonts/8_bit_wonder/8_bit_wonder.ttf", 6, FlxColor.WHITE, FlxTextAlign.LEFT, SHADOW, 0x33000000);
		_scoreText.scrollFactor.set(0, 0);
		LevelManager.instance.getScore().scoreText = _scoreText;
		_actors = new FlxGroup();
		_collectibles = new FlxGroup();
		_markers = new FlxGroup();
		_enemies = new FlxGroup();

		var background = new FlxSprite();
		background.loadGraphic(AssetPaths.background_1__png, false, 64, 64);
		background.scrollFactor.set(0, 0);
		add(background);

		loadLevel();
		generateBackgroundTiles();

		add(_tilemap);
		add(_collectibles);
		add(_markers);
		add(_actors);

		_actors.add(_player);

		_camTarget = new FlxObject(0, 0);
		add(_camTarget);
		// _camTarget.acceleration.x = 2;
		_camTarget.velocity.x = 20;

		FlxG.camera.setScrollBoundsRect(0, 0, cast _tilemap.width, cast _tilemap.height, true);
		FlxG.camera.follow(_camTarget, PLATFORMER, .3);

		add(_emitter);
		add(_scoreText);

		_emitter.start(false, .02);

		if (FlxG.sound.music == null) // don't restart the music if it's already playing
		{
			FlxG.sound.playMusic(AssetPaths.lowrezjam2020_ingame__ogg, .5, true);
		}

		FlxG.mouse.visible = false;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		#if debug
		if (FlxG.keys.justPressed.SPACE)
		{
			resetGame();
		}

		if (FlxG.keys.justPressed.N)
		{
			nextLevel();
		}
		#end

		_camTarget.y = _player.y;

		if (_player.x > _tilemap.width)
		{
			nextLevel();
		}

		var tolerance = 4;
		if ((_player.y > _tilemap.y + _tilemap.height) || (_player.x < FlxG.camera.scroll.x - _player.width - tolerance))
		{
			gameOver();
		}

		super.update(elapsed);

		FlxG.collide(_tilemap, _actors, tilemapCollidedActor);
		FlxG.overlap(_actors, _collectibles, overlapped);
		FlxG.overlap(_actors, _enemies, overlapped);
		FlxG.overlap(_actors, _markers, overlapped);
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
		else if ((b is Anomaly))
		{
			var anomaly:Anomaly = cast b;
			if (!anomaly.isVertical())
			{
				if (b.justTouched(FlxObject.RIGHT))
				{
					anomaly.flipDirection(-1);
				}
				else if (b.justTouched(FlxObject.LEFT))
				{
					anomaly.flipDirection(1);
				}
			}
			else
			{
				if (b.justTouched(FlxObject.UP))
				{
					anomaly.flipDirection(1);
				}
				else if (b.justTouched(FlxObject.DOWN))
				{
					anomaly.flipDirection(-1);
				}
			}
		}
	}

	function overlapped(a:FlxObject, b:FlxObject):Void
	{
		if ((a is Player) && (b is Coin))
		{
			var coin:Coin = cast b;
			coin.pickedUp();

			LevelManager.instance.getScore().addCollectible(coin);
		}
		else if ((a is Anomaly) && (b is Marker))
		{
			var anomaly:Anomaly = cast a;
			var marker:Marker = cast b;
			if (marker.getMarkerType() == HAZARD_BOUNCE)
			{
				if (anomaly.isVertical())
				{
					if (marker.y < anomaly.y)
						anomaly.flipDirection(1);
					else
						anomaly.flipDirection(-1);
				}
				else
				{
					if (marker.x < anomaly.x)
						anomaly.flipDirection(1);
					else
						anomaly.flipDirection(-1);
				}
			}
		}
		else if ((a is Player) && (b is Anomaly))
		{
			gameOver();
		}
	}

	private function loadLevel()
	{
		var level = LevelManager.instance.getCurrentLevel();
		var loader = new FlxOgmo3Loader(AssetPaths.lowrezjam2020__ogmo, level);

		_tilemap = new FlxTilemap();
		_tilemap = loader.loadTilemap(AssetPaths.tileset__png, "walls");

		loader.loadEntities(placeEntities, "entities");
		loader.loadEntities(placeEntities, "collectibles");
	}

	function placeEntities(entity:EntityData)
	{
		if (entity.name == "player")
		{
			_player.setPosition(entity.x, entity.y);
		}
		else if (entity.name == "coin")
		{
			var coin = new Coin(entity.x, entity.y);
			_collectibles.add(coin);
		}
		else if (entity.name == "anomaly")
		{
			var anomaly = new Anomaly(entity.x, entity.y, entity.values.vertical, entity.values.initial_direction);
			_actors.add(anomaly);
			_enemies.add(anomaly);
		}
		else if (entity.name == "hazard_bounce_marker")
		{
			var marker = new Marker(entity.x, entity.y, HAZARD_BOUNCE);
			_markers.add(marker);
		}
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

	private function gameOver():Void
	{
		// TODO game over screen
		resetGame();
	}

	private function nextLevel():Void
	{
		LevelManager.instance.nextLevel();
		if (LevelManager.instance.getCurrentLevel() != null)
		{
			FlxG.switchState(new PlayState());
		}
		else
		{
			FlxG.switchState(new EndgameState());
		}
	}

	private function resetGame()
	{
		LevelManager.instance.resetState();
		FlxG.resetGame();
	}
}
