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

class PlayState extends FlxState
{
	private var _player:Player;
	private var _tilemap:FlxTilemap;
	private var _camTarget:FlxObject;

	private var _actors:FlxGroup;
	private var _collectibles:FlxGroup;

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
		_scoreText = new FlxText(0, 0, 0, "SCORE", 8);
		_scoreText.setFormat("assets/fonts/8_bit_wonder.ttf", 6);
		_scoreText.scrollFactor.set(0, 0);
		_player.score.scoreText = _scoreText;
		_actors = new FlxGroup();
		_collectibles = new FlxGroup();

		var background = new FlxSprite();
		background.loadGraphic(AssetPaths.background_1__png, false, 64, 64);
		background.scrollFactor.set(0, 0);
		add(background);

		loadLevel();
		generateBackgroundTiles();

		add(_tilemap);
		add(_collectibles);
		add(_actors);

		_actors.add(_player);

		_camTarget = new FlxObject(0, 0);
		add(_camTarget);
		// _camTarget.acceleration.x = 2;
		_camTarget.velocity.x = 20;

		FlxG.camera.setScrollBoundsRect(0, 0, cast _tilemap.width, cast _tilemap.height, true);
		FlxG.camera.follow(_camTarget, LOCKON, .3);

		add(_emitter);
		add(_scoreText);

		_emitter.start(false, .02);

		if (FlxG.sound.music == null) // don't restart the music if it's already playing
		{
			FlxG.sound.playMusic(AssetPaths.lowrezjam2020_ingame__ogg, 1, true);
		}

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SPACE)
		{
			FlxG.resetGame();
		}

		var tolerance = 4;
		if ((_player.y > _tilemap.y + _tilemap.height) || (_player.x < FlxG.camera.scroll.x - _player.width - tolerance))
		{
			gameOver();
		}

		super.update(elapsed);

		FlxG.collide(_tilemap, _actors, tilemapCollidedActor);
		FlxG.overlap(_player, _collectibles, overlapped);
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

	function overlapped(spriteA:FlxObject, spriteB:FlxObject):Void
	{
		if ((spriteA is Player) || (spriteB is Coin))
		{
			var coin:Coin = cast spriteB;
			coin.pickedUp();

			var player:Player = cast spriteA;
			player.score.addCollectible(coin);
		}
	}

	private function loadLevel()
	{
		var loader = new FlxOgmo3Loader(AssetPaths.lowrezjam2020__ogmo, AssetPaths.level_1__json);

		_tilemap = new FlxTilemap();
		_tilemap = loader.loadTilemap(AssetPaths.tileset__png, "walls");

		loader.loadEntities(placeEntities, "entities");
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
		FlxG.resetGame();
	}
}
