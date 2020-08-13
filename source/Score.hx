package;

import flixel.FlxSprite;
import flixel.text.FlxText;

class Score
{
	private var _amount:Int = 0;
	private var _previousScore:Int = 0;

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

	public function addCollectible(collectable:FlxSprite):Void
	{
		if ((collectable is Coin))
		{
			_amount += 1;
		}

		updateScore();
	}

	public function updateScore():Void
	{
		scoreText.text = getAmountText();
	}

	public function resetLevelScore():Void
	{
		_amount = _previousScore;
		updateScore();
	}

	public function finishLevel():Void
	{
		_previousScore = _amount;
		updateScore();
	}

	public function reset():Void
	{
		_amount = 0;
		_previousScore = 0;
		updateScore();
	}

	public function getAmount():Int
	{
		return _amount;
	}

	public function getAmountText():String
	{
		return StringTools.lpad(Std.string(_amount), "0", 4);
	}
}
