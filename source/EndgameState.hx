package;

import flixel.FlxState;
import flixel.text.FlxText;

class EndgameState extends FlxState
{
	override public function create()
	{
		super.create();

		var endText = new FlxText(0, 0, "THE END");
		add(endText);
	}
}
