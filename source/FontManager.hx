package;

class FontManager
{
	public static var instance:FontManager = new FontManager();

	public function new() {}

	public function getScoreFont():String
	{
		return "assets/fonts/8_bit_wonder/8_bit_wonder.ttf";
	}
}
