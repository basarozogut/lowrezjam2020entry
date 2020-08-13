package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class Player extends FlxSprite
{
	public var allowControls:Bool = true;

	private var _canJump:Bool = false;
	private var _canJumpOnAir:Bool = false;
	private var _jumpCount:Int = 0;
	private var _maxJumpCount:Int = 2;
	private var _walkSpeed:Float = 100;
	private var _maxWalkSpeed:Float = 100;

	private var _jumpSound:FlxSound = FlxG.sound.load(AssetPaths.jump__wav);
	private var _secondJumpSound:FlxSound = FlxG.sound.load(AssetPaths.second_jump__wav);
	private var _landSound:FlxSound = FlxG.sound.load(AssetPaths.land__wav);

	// Controls
	static var actions:FlxActionManager;

	var _up:FlxActionDigital;
	var _down:FlxActionDigital;
	var _left:FlxActionDigital;
	var _right:FlxActionDigital;
	var _shoot:FlxActionDigital;
	var _jump:FlxActionDigital;
	var _stopJump:FlxActionDigital;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		loadGraphic(AssetPaths.player__png, true, 8);

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);

		// bounding box
		width = 6;
		height = 7;
		offset.set(1, 1);

		// physics
		// Walking speed
		maxVelocity.x = _maxWalkSpeed;
		// Gravity
		acceleration.y = 200;
		// Deceleration (sliding to a stop)
		// drag.x = maxVelocity.x * 4;
		drag.x = maxVelocity.x * .25;

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

		configureActions();
	}

	private function configureActions():Void
	{
		_up = new FlxActionDigital().addGamepad(DPAD_UP, PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_UP, PRESSED)
			.addKey(UP, PRESSED)
			.addKey(W, PRESSED);

		_down = new FlxActionDigital().addGamepad(DPAD_DOWN, PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_DOWN, PRESSED)
			.addKey(DOWN, PRESSED)
			.addKey(S, PRESSED);

		_left = new FlxActionDigital().addGamepad(DPAD_LEFT, PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_LEFT, PRESSED)
			.addKey(LEFT, PRESSED)
			.addKey(A, PRESSED);

		_right = new FlxActionDigital().addGamepad(DPAD_RIGHT, PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_RIGHT, PRESSED)
			.addKey(RIGHT, PRESSED)
			.addKey(D, PRESSED);

		_jump = new FlxActionDigital().addGamepad(DPAD_UP, JUST_PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_UP, JUST_PRESSED)
			.addKey(UP, JUST_PRESSED)
			.addKey(W, JUST_PRESSED);
		_stopJump = new FlxActionDigital().addGamepad(DPAD_UP, JUST_PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_UP, JUST_PRESSED)
			.addKey(UP, JUST_PRESSED)
			.addKey(W, JUST_PRESSED);

		_shoot = new FlxActionDigital().addGamepad(X, PRESSED).addKey(X, PRESSED);

		if (actions == null)
			actions = FlxG.inputs.add(new FlxActionManager());
		actions.addActions([_down, _left, _right, _jump, _shoot, _stopJump]);
	}

	public function hitTilemap()
	{
		_landSound.play();
	}

	override public function update(elapsed:Float)
	{
		updateFlags();
		if (allowControls)
		{
			updateInput();
		}
		updateAnimations();

		super.update(elapsed);
	}

	private function updateFlags()
	{
		if (isTouching(FlxObject.FLOOR))
		{
			_canJump = true;
			_canJumpOnAir = true;
			_jumpCount = 0;
		}
		else
		{
			_canJump = false;
		}
	}

	private function updateInput()
	{
		// Smooth slidey walking controls
		acceleration.x = 0;

		if (_left.triggered)
			moveLeft();
		else if (_right.triggered)
			moveRight();

		if (_jump.triggered)
			jump();
		else if (_stopJump.triggered)
			stopJump();
	}

	function moveLeft():Void
	{
		facing = FlxObject.LEFT;
		acceleration.x -= _walkSpeed;
	}

	function moveRight():Void
	{
		facing = FlxObject.RIGHT;
		acceleration.x += _walkSpeed;
	}

	function jump():Void
	{
		if (canJump())
		{
			velocity.y = -acceleration.y * 0.41;

			if (_jumpCount == 0)
				_jumpSound.play();
			else
				_secondJumpSound.play();

			_jumpCount++;
			_canJumpOnAir = true;
		}
	}

	function stopJump()
	{
		// TODO
	}

	private function updateAnimations()
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
				animation.curAnim.frameRate = Math.abs(velocity.x) * .5;
			}
			else
			{
				animation.play(Animation.IDLE);
			}
		}
	}

	private inline function canJump()
	{
		return _canJump || (_canJumpOnAir && _jumpCount < _maxJumpCount);
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
