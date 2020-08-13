package;

class LevelManager
{
	public static var instance:LevelManager = new LevelManager();

	private var _levelList:Array<String>;
	private var _currentLevelIndex = -1;
	private var _score:Score;

	public function new()
	{
		_levelList = new Array<String>();
		resetState();
	}

	public function addLevel(level:String)
	{
		_levelList.push(level);
	}

	public function nextLevel():Void
	{
		_currentLevelIndex++;
	}

	public function getCurrentLevel():String
	{
		if (_currentLevelIndex >= _levelList.length)
		{
			return null;
		}

		return _levelList[_currentLevelIndex];
	}

	public function resetState():Void
	{
		_currentLevelIndex = 0;
		_score = new Score();
	}

	public function getScore()
	{
		return _score;
	}
}
