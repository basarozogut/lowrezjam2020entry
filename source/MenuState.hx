package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	var _sun:FlxSprite;

	var _textBlinkTimerMax:Float;
	var _textBlinkTimer:Float;

	var _pressAnyKeyText:FlxBitmapText;
	var _pressedKey:Bool = false;

	override public function create()
	{
		var background = new FlxSprite();
		background.loadGraphic(AssetPaths.intro_background__png, false, 64, 64);
		background.scrollFactor.set(0, 0);
		add(background);

		_sun = new FlxSprite();
		_sun.loadGraphic(AssetPaths.sun__png);
		_sun.x = FlxG.width - _sun.width - 2;
		_sun.y = 2;
		add(_sun);

		FlxTween.tween(_sun, {y: 4}, 1, {
			type: FlxTweenType.PINGPONG,
			ease: FlxEase.cubeInOut,
		});

		var yOffset = 5;

		var logo = new FlxSprite();
		logo.loadGraphic(AssetPaths.intro__png);
		logo.x = FlxG.width / 2 - logo.width / 2;
		logo.y = yOffset;
		add(logo);

		var rows = [
			[1, 0, 0, 0, 0, 0, 0, 1],
			[2, 2, 2, 2, 2, 2, 2, 2],
			[4, 4, 3, 4, 4, 4, 4, 4],
			[4, 4, 4, 4, 3, 3, 4, 4]
		];
		var tilemap = new FlxTilemap();
		tilemap.loadMapFrom2DArray(rows, AssetPaths.tileset__png, 8, 8);
		tilemap.x = 0;
		tilemap.y = FlxG.height - tilemap.height;
		add(tilemap);

		_textBlinkTimerMax = 1;
		_textBlinkTimer = _textBlinkTimerMax;

		_pressAnyKeyText = new FlxBitmapText(FontManager.instance.getScoreFontBitmap());
		_pressAnyKeyText.text = "PRESS\nANY KEY";
		FontManager.instance.setBitmapTextShadow(_pressAnyKeyText);
		FontManager.instance.setBitmapTextCentered(_pressAnyKeyText);
		_pressAnyKeyText.y = FlxG.height - _pressAnyKeyText.height - 2;
		add(_pressAnyKeyText);

		var snowParticleMaker = new SnowParticleMaker();
		add(snowParticleMaker.emitter);
		snowParticleMaker.start();

		bgColor = 0xff55ed8d;

		FlxG.sound.playMusic(AssetPaths.lowrezjam2020_intro__ogg, .4, true);

		FlxG.mouse.visible = false;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			#if desktop
			Sys.exit(0);
			#end
		}
		else if (FlxG.keys.justPressed.ANY && !_pressedKey)
		{
			_pressedKey = true;
			FlxG.sound.playMusic(AssetPaths.lowrezjam2020_start__ogg, .4, false);
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
			{
				FlxG.switchState(new PlayState());
			});
		}

		_textBlinkTimer -= elapsed;
		if (_textBlinkTimer <= 0)
		{
			blinkText();
			_textBlinkTimer += _textBlinkTimerMax;
		}

		super.update(elapsed);
	}

	private function blinkText()
	{
		_pressAnyKeyText.visible = !_pressAnyKeyText.visible;
	}
}
