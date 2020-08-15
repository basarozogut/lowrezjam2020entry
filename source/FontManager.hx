package;

import flixel.FlxG;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;

class FontManager
{
	public static var instance:FontManager = new FontManager();

	public function new() {}

	public function getScoreFontBitmap():FlxBitmapFont
	{
		return FlxBitmapFont.fromAngelCode("assets/fonts/goodbye_despair_0.png", "assets/fonts/goodbye_despair.fnt");
	}

	public function setBitmapTextShadow(text:FlxBitmapText)
	{
		text.borderStyle = SHADOW;
		text.borderColor = 0x33000000;
	}

	public function setBitmapTextCentered(text:FlxBitmapText)
	{
		text.alignment = CENTER;
		text.x = FlxG.width / 2 - text.width / 2;
	}
}
