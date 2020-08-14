package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class LevelChangeState extends FlxState
{
	var _textBlinkTimerMax:Float;
	var _textBlinkTimer:Float;

	var _allowKeyPressTimer:Float;

	var _pressAnyKeyText:FlxText;

	override public function create()
	{
		super.create();

		_textBlinkTimerMax = 1;
		_textBlinkTimer = _textBlinkTimerMax;

		_allowKeyPressTimer = 2;

		var background = new FlxSprite();
		background.loadGraphic(AssetPaths.background_1__png, false, 64, 64);
		background.scrollFactor.set(0, 0);
		add(background);

		var levelCompleteText = new FlxText(0, 0, FlxG.width, "LEVEL COMPLETED!");
		levelCompleteText.setFormat(FontManager.instance.getScoreFont(), FontManager.instance.getScoreFontSize(), FlxColor.WHITE, FlxTextAlign.CENTER, SHADOW,
			0x33000000);

		_pressAnyKeyText = new FlxText(0, 0, FlxG.width, "PRESS ANY KEY");
		_pressAnyKeyText.setFormat(FontManager.instance.getScoreFont(), FontManager.instance.getScoreFontSize(), FlxColor.WHITE, FlxTextAlign.CENTER, SHADOW,
			0x33000000);
		_pressAnyKeyText.y = FlxG.height - _pressAnyKeyText.height;
		_pressAnyKeyText.visible = false;

		var scoreText = new FlxText(0, 16, FlxG.width);
		scoreText.setFormat(FontManager.instance.getScoreFont(), FontManager.instance.getScoreFontSize(), FlxColor.WHITE, FlxTextAlign.CENTER, SHADOW,
			0x33000000);
		LevelManager.instance.getScore().scoreText = scoreText;
		LevelManager.instance.getScore().updateScore();

		var player = new Player(0, 0);
		player.allowControls = false;
		player.x = FlxG.width / 2 - player.width / 2;
		player.y = FlxG.height / 2 - player.height / 2;
		player.acceleration.y = 0;
		add(player);

		var tileRow = [2, 2, 2, 2, 2, 2, 2, 2];
		var tileRow2 = [4, 4, 4, 4, 4, 4, 4, 4];
		var tilemap = new FlxTilemap();
		tilemap.loadMapFrom2DArray([tileRow, tileRow2, tileRow2, tileRow2], AssetPaths.tileset__png, 8, 8);
		tilemap.x = 0;
		tilemap.y = player.y + player.height;
		add(tilemap);

		add(levelCompleteText);
		add(_pressAnyKeyText);
		add(scoreText);

		FlxG.sound.playMusic(AssetPaths.lowrezjam2020_level_change__ogg, .5, false);
	}

	override public function update(elapsed:Float)
	{
		#if debug
		if (FlxG.keys.justPressed.ANY)
		{
			nextLevel();
		}
		#else
		if (FlxG.keys.justPressed.ANY && _allowKeyPressTimer <= 0)
		{
			nextLevel();
		}
		#end

		if (_allowKeyPressTimer > 0)
		{
			_allowKeyPressTimer -= elapsed;
		}
		else
		{
			_textBlinkTimer -= elapsed;
			if (_textBlinkTimer <= 0)
			{
				blinkText();
				_textBlinkTimer += _textBlinkTimerMax;
			}
		}

		super.update(elapsed);
	}

	private function blinkText()
	{
		_pressAnyKeyText.visible = !_pressAnyKeyText.visible;
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
}
