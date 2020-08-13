package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.Lib;

class EndgameState extends FlxState
{
	override public function create()
	{
		super.create();

		var levelCompleteText = new FlxText(0, 0, FlxG.width, "GAME COMPLETED!\n\nA GAME BY\nCHILLWAVES\n\nTHANKS FOR PLAYING");
		levelCompleteText.x = -FlxG.width;
		levelCompleteText.y = 4;
		levelCompleteText.setFormat(FontManager.instance.getScoreFont(), 6, FlxColor.WHITE, FlxTextAlign.CENTER);
		add(levelCompleteText);

		FlxTween.tween(levelCompleteText, {x: 0}, .7, {type: FlxTweenType.ONESHOT, ease: FlxEase.cubeInOut});
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY)
		{
			Sys.exit(0);
		}
		super.update(elapsed);
	}
}
