package;

import flixel.FlxObject;

class Marker extends FlxObject
{
	private var _markerType:MarkerType;

	public function new(x:Float = 0, y:Float = 0, markerType:MarkerType)
	{
		super(x, y);

		width = 8;
		height = 8;

		_markerType = markerType;
	}

	public function getMarkerType():MarkerType
	{
		return _markerType;
	}
}

enum MarkerType
{
	HAZARD_BOUNCE;
}
