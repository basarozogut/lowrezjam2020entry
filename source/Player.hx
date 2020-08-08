package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	private var _forceStartPosition:FlxPoint;
	private var _forceEndPosition:FlxPoint;
	private var _dragging:Bool;

	private var _jumpSound:FlxSound = FlxG.sound.load(AssetPaths.jump__wav);

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		loadGraphic(AssetPaths.player__png, true, 8);

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);

		// physics
		acceleration.y = 240;
		drag.x = 10;
		// elasticity = .9;

		// Animations
		// idle
		var idleFrames = [0, 0, 0, 1, 1, 1];
		var idleLookFrames = [2, 3, 3, 3, 3, 3, 3, 3, 3, 2, 1];
		var idleLoop = [];
		for (i in 0...8)
		{
			idleLoop = idleLoop.concat(idleFrames);
		}
		idleLoop = idleLoop.concat(idleLookFrames);
		for (i in 0...5)
		{
			idleLoop = idleLoop.concat(idleFrames);
		}
		idleLoop = idleLoop.concat(idleLookFrames);
		animation.add(Animation.IDLE, idleLoop, 10);
		// walk
		animation.add(Animation.WALK, [4, 5, 6, 7], 10);
		animation.add(Animation.JUMP, [8], 10);
		animation.add(Animation.FALL, [9], 10);
		animation.add(Animation.STRETCH, [10, 11], 2);

		_forceStartPosition = new FlxPoint();
		_forceEndPosition = new FlxPoint();

		FlxG.watch.add(this, "velocity");
	}

	override public function update(elapsed:Float)
	{
		updateInput();
		updateAnimations();

		super.update(elapsed);
	}

	private function updateInput()
	{
		if (FlxG.mouse.justPressed)
		{
			_forceStartPosition.x = FlxG.mouse.x;
			_forceStartPosition.y = FlxG.mouse.y;
			_dragging = true;
		}

		if (FlxG.mouse.justReleased)
		{
			_forceEndPosition.x = FlxG.mouse.x;
			_forceEndPosition.y = FlxG.mouse.y;
			_dragging = false;
			throwPlayer();
		}

		if (_dragging)
		{
			if (FlxG.mouse.x < x)
			{
				facing = FlxObject.RIGHT;
			}
			else
			{
				facing = FlxObject.LEFT;
			}
		}
		else
		{
			if (velocity.x > 0)
			{
				facing = FlxObject.RIGHT;
			}

			if (velocity.x < 0)
			{
				facing = FlxObject.LEFT;
			}
		}
	}

	private function updateAnimations()
	{
		if (_dragging)
		{
			animation.play(Animation.STRETCH);
		}
		else
		{
			if (velocity.y > 0)
			{
				animation.play(Animation.FALL);
			}
			else if (velocity.y < 0)
			{
				animation.play(Animation.JUMP);
			}
			else
			{
				if (Math.abs(velocity.x) > 0)
				{
					animation.play(Animation.WALK);
				}
				else
				{
					animation.play(Animation.IDLE);
				}
			}
		}
	}

	private function throwPlayer()
	{
		var forceVector = new FlxVector(_forceEndPosition.x - _forceStartPosition.x, _forceEndPosition.y - _forceStartPosition.y);
		// forceVector.truncate(30);
		forceVector.scale(-3);
		velocity.x = forceVector.x;
		velocity.y = forceVector.y;

		_jumpSound.play();
	}
}

enum abstract Animation(String) to String
{
	var IDLE;
	var WALK;
	var JUMP;
	var FALL;
	var STRETCH;
}
