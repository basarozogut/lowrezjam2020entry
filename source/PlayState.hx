package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.effects.FlxFlicker;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.utils.AssetManifest;

class PlayState extends FlxState
{
	private var _player:Player;
	private var _tilemap:FlxTilemap;
	private var _backgroundTilemap:FlxTilemap;
	private var _foregroundTilemap:FlxTilemap;
	private var _camTarget:FlxObject;

	// Physical groups
	private var _actors:FlxGroup;
	private var _levelBounds:FlxGroup;
	private var _collectibles:FlxGroup;
	private var _markers:FlxGroup;

	// Logical groups
	private var _enemies:FlxGroup;

	private var _scoreText:FlxBitmapText;

	private var _snowParticleMaker:SnowParticleMaker;

	private var _autoScroll:Bool = false;

	override public function create()
	{
		_snowParticleMaker = new SnowParticleMaker();

		// Gameplay
		_player = new Player(0, 0);
		_scoreText = new FlxBitmapText(FontManager.instance.getScoreFontBitmap());
		FontManager.instance.setBitmapTextShadow(_scoreText);
		_scoreText.scrollFactor.set(0, 0);
		LevelManager.instance.getScore().scoreText = _scoreText;
		_actors = new FlxGroup();
		_levelBounds = new FlxGroup();
		_collectibles = new FlxGroup();
		_markers = new FlxGroup();
		_enemies = new FlxGroup();

		var background = new FlxSprite();
		background.loadGraphic(AssetPaths.background_1__png, false, 64, 64);
		background.scrollFactor.set(0, 0);
		add(background);

		loadLevel();
		var tilemapHeight:Int = cast _tilemap.height;
		var leftBuffer = new FlxTileblock(-15, 0, 16, tilemapHeight);
		_levelBounds.add(leftBuffer);

		add(_backgroundTilemap);
		add(_levelBounds);
		add(_tilemap);
		add(_collectibles);
		add(_markers);
		add(_actors);
		add(_foregroundTilemap);

		_actors.add(_player);

		_camTarget = new FlxObject(0, 0);
		add(_camTarget);
		// _camTarget.acceleration.x = 2;
		_camTarget.velocity.x = 20;

		FlxG.camera.setScrollBoundsRect(0, 0, cast _tilemap.width, cast _tilemap.height, true);
		if (_autoScroll)
		{
			FlxG.camera.follow(_camTarget, PLATFORMER);
		}
		else
		{
			FlxG.camera.follow(_player, PLATFORMER);
		}

		add(_snowParticleMaker.emitter);
		add(_scoreText);

		_snowParticleMaker.start();

		FlxG.sound.playMusic(AssetPaths.lowrezjam2020_ingame__ogg, .5, true);

		FlxG.camera.fade(FlxColor.BLACK, .5, true);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		#if debug
		if (FlxG.keys.justPressed.SPACE)
		{
			resetGame();
		}

		if (FlxG.keys.justPressed.R)
		{
			gameOver();
		}

		if (FlxG.keys.justPressed.N)
		{
			nextLevel();
		}

		if (FlxG.keys.justPressed.P)
		{
			FlxG.switchState(new EndgameState());
		}
		#end

		if (FlxG.keys.justPressed.ESCAPE)
		{
			mainTitle();
		}

		_camTarget.y = _player.y;

		if (_player.x > _tilemap.width)
		{
			nextLevel();
		}

		if (_autoScroll)
		{
			var tolerance = 4;
			if ((_player.x < FlxG.camera.scroll.x - _player.width - tolerance))
			{
				gameOver();
			}

			if (_player.x > _camTarget.x)
			{
				_camTarget.x = _player.x;
			}
		}

		if ((_player.y > _tilemap.y + _tilemap.height))
		{
			gameOver();
		}

		super.update(elapsed);

		FlxG.collide(_tilemap, _actors, tilemapCollidedActor);
		FlxG.collide(_player, _levelBounds);
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

		_autoScroll = loader.getLevelValue("auto_scroll");

		_tilemap = loader.loadTilemap(AssetPaths.tileset__png, "walls");
		_backgroundTilemap = loader.loadTilemap(AssetPaths.tileset__png, "background_tiles");
		_foregroundTilemap = loader.loadTilemap(AssetPaths.tileset__png, "foreground_tiles");

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

	private function gameOver():Void
	{
		if (!_player.alive)
			return;

		var deadPlayer:PlayerDead = new PlayerDead(_player.x, _player.y);
		deadPlayer.acceleration.y = _player.acceleration.y;
		deadPlayer.velocity.y = -deadPlayer.acceleration.y * 0.5;
		deadPlayer.velocity.x = FlxG.random.float(-100, 100);
		add(deadPlayer);
		_player.kill();
		var timer = new FlxTimer(FlxTimer.globalManager);
		FlxG.sound.playMusic(AssetPaths.lowrezjam2020_dead__ogg, .5, false);

		timer.start(2, timer -> FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
		{
			LevelManager.instance.getScore().resetLevelScore();
			FlxG.switchState(new PlayState());
		}));
	}

	private function nextLevel():Void
	{
		LevelManager.instance.getScore().finishLevel();
		FlxG.switchState(new LevelChangeState());
	}

	private function resetGame()
	{
		LevelManager.instance.resetState();
		FlxG.resetGame();
	}

	private function mainTitle()
	{
		LevelManager.instance.resetState();
		FlxG.switchState(new MenuState());
	}
}
