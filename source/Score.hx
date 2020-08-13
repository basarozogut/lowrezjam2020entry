package;

import flixel.FlxSprite;
import flixel.text.FlxText;

class Score
{
	private var _amount:Int = 0;

	@:isVar public var scoreText(get, set):FlxText;

	function get_scoreText()
	{
		return scoreText;
	}

	function set_scoreText(val:FlxText)
	{
		this.scoreText = val;
		updateScore();
		return this.scoreText;
	}

	public function new()
	{
		_amount = 0;
	}

	public function getAmount():Int
	{
		return _amount;
	}

	public function addCollectible(collectable:FlxSprite)
	{
		if ((collectable is Coin))
		{
			_amount += 1;
		}

		updateScore();
	}

	private function updateScore():Void
	{
		scoreText.text = StringTools.lpad(Std.string(_amount), "0", 4);
	}

	public function reset()
	{
		_amount = 0;
		updateScore();
	}
}
