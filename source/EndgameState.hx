package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer.FlxTimerManager;
import flixel.util.FlxTimer;
import openfl.Lib;

class EndgameState extends FlxState
{
	var _text:Array<String> = [
		"\n\n\nGAME\nCOMPLETED!",
		"\n\n\nFINAL SCORE\n" + LevelManager.instance.getScore().getAmountText(),
		"\n\nGFX SFX\nMUSIC\nCODING\n\nCHILLWAVES",
		"\n8 BIT WONDER\nFONT by\n\nJoiro Hatagaya",
		"\n\n\nTHANKS FOR\nPLAYING",
		"\n\n\nPRESS ANY KEY\nTO EXIT"
	];
	var _currentTextIndex:Int;
	var _levelCompleteText:FlxText;
	var _waitTimer:FlxTimer;

	override public function create()
	{
		super.create();

		_currentTextIndex = 0;
		_waitTimer = new FlxTimer(FlxTimer.globalManager);

		_levelCompleteText = new FlxText(0, 0, FlxG.width);
		_levelCompleteText.y = 0;
		_levelCompleteText.setFormat(FontManager.instance.getScoreFont(), 6, FlxColor.WHITE, FlxTextAlign.CENTER);
		add(_levelCompleteText);

		FlxG.sound.playMusic(AssetPaths.lowrezjam2020_credits__ogg, .5, true);

		nextText();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY)
		{
			Sys.exit(0);
		}
		super.update(elapsed);
	}

	private function nextText()
	{
		_levelCompleteText.x = -FlxG.width;
		var text = _text[_currentTextIndex];
		_levelCompleteText.text = text;

		_currentTextIndex = (_currentTextIndex + 1) % _text.length;
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
