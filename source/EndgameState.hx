package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class EndgameState extends FlxState
{
	var _text:Array<String> = [
		"\n\n\nGAME\nCOMPLETED!",
		"\n\n\nFINAL SCORE\n" + LevelManager.instance.getScore().getAmountText(),
		"\n\nA GAME BY\n\nCHILLWAVES",
		"\nGFX\nMUSIC\nCODING\n\nCHILLWAVES",
		"\nSFX MADE\nWITH SFXR\n\nBY\nTOMAS PETTERSSON",
		"\n'GOODBYE DESPAIR'\nFONT BY\n\nUkiyoMoji Fonts",
		"\n\n\nTHANKS FOR\nPLAYING!",
		"\n\n\nPRESS ANY KEY\nTO EXIT"
	];
	var _currentTextIndex:Int;
	var _levelCompleteText:FlxText;
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

		_levelCompleteText = new FlxText(0, 0, FlxG.width);
		_levelCompleteText.y = 0;
		_levelCompleteText.setFormat(FontManager.instance.getScoreFont(), FontManager.instance.getScoreFontSize(), FlxColor.WHITE, FlxTextAlign.CENTER,
			SHADOW, 0xFF000000);
		add(_levelCompleteText);

		FlxG.sound.playMusic(AssetPaths.lowrezjam2020_credits__ogg, .5, true);
		nextText();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY && _canQuit)
		{
			Sys.exit(0);
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
		_levelCompleteText.x = -FlxG.width;
		var text = _text[_currentTextIndex];
		_levelCompleteText.text = text;

		_currentTextIndex++;
		if (_currentTextIndex >= _text.length)
		{
			_currentTextIndex = 0;
			_canQuit = true;
		}

		FlxTween.tween(_levelCompleteText, {x: 0}, 1, {
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
