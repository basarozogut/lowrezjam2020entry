package;

class FontManager
{
	public static var instance:FontManager = new FontManager();

	public function new() {}

	public function getScoreFont():String
	{
		return "assets/fonts/goodbyeDespair.ttf";
	}

	public function getScoreFontSize():Int
	{
		return 8;
	}
}
