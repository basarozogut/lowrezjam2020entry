package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class EndgameState extends FlxState
{
	var _text:Array<String> = [
		"GAME\nCOMPLETED!", "FINAL SCORE\n" + LevelManager.instance.getScore().getAmountText(), "A GAME BY\n\nCHILLWAVES", "MADE FOR\n\nLOWREZJAM\n2020",
		"GFX\nMUSIC\nCODING\nLEVEL DESIGN\n\nCHILLWAVES", "SFX MADE\nWITH SFXR\n\nBY\nTOMAS\nPETTERSSON",
		"TITLE FONT\n\"8 BIT WONDER\"\nBY\n\nJoiro\nHatagaya", "\"GOODBYE\nDESPAIR\"\nFONT BY\n\nUkiyoMoji\nFonts", "GAME ENGINE\n\nHAXEFLIXEL",
		"THANKS FOR\nPLAYING!", "PRESS\nANY KEY"
	];
	var _currentTextIndex:Int;
	var _levelCompleteText:FlxBitmapText;
	var _waitTimer:FlxTimer;
	var _canQuit:Bool;

	var _coins:Array<Coin>;

	override public function create()
	{
		super.create();

		_canQuit = false;
		_currentTextIndex = 0;
		_waitTimer = new FlxTimer(FlxTimer.globalManager);

		var nCoins = 10;
		_coins = new Array<Coin>();
		for (i in 0...nCoins)
		{
			var coin = new Coin();
			coin.x = FlxG.width * i / nCoins;
			coin.y = FlxG.random.float(-FlxG.height, -coin.height);
			coin.velocity.y = 5 + FlxG.random.float(35);
			_coins.push(coin);
			add(coin);
		}

		_levelCompleteText = new FlxBitmapText(FontManager.instance.getScoreFontBitmap());
		_levelCompleteText.y = 0;
		FontManager.instance.setBitmapTextShadow(_levelCompleteText);
		add(_levelCompleteText);

		FlxG.sound.playMusic(AssetPaths.lowrezjam2020_credits__ogg, .5, true);

		bgColor = 0xff000000;

		nextText();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY && _canQuit)
		{
			LevelManager.instance.resetState();
			FlxG.switchState(new MenuState());
		}

		for (coin in _coins)
		{
			if (coin.y > FlxG.height)
			{
				coin.y = -coin.height;
			}
		}

		super.update(elapsed);
	}

	private function nextText()
	{
		var text = _text[_currentTextIndex];
		_levelCompleteText.text = text;
		FontManager.instance.setBitmapTextCentered(_levelCompleteText);
		_levelCompleteText.x = -FlxG.width;
		_levelCompleteText.y = FlxG.height / 2 - _levelCompleteText.height / 2;

		_currentTextIndex++;
		if (_currentTextIndex > 1)
		{
			_canQuit = true;
		}
		if (_currentTextIndex >= _text.length)
		{
			_currentTextIndex = 0;
		}

		FlxTween.tween(_levelCompleteText, {x: FlxG.width / 2 - _levelCompleteText.width / 2}, 1, {
			type: FlxTweenType.ONESHOT,
			ease: FlxEase.cubeInOut,
			onComplete: tween -> _waitTimer.start(2, (timer) -> hideText())
		});
	}

	private function hideText()
	{
		FlxTween.tween(_levelCompleteText, {x: FlxG.width}, 1, {
			type: FlxTweenType.ONESHOT,
			ease: FlxEase.cubeInOut,
			onComplete: tween -> nextText()
		});
	}

	private function newlineCount(str:String)
	{
		var count = 0;
		for (i in 0...str.length)
		{
			var c = str.charAt(i);
			if (c == "\n")
				count++;
		}

		return count;
	}
}
