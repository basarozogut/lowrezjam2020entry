package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class Player extends FlxSprite
{
	private var _guide:FlxSprite;

	private var _forceStartPosition:FlxPoint;
	private var _forceEndPosition:FlxPoint;
	private var _guideStartPosition:FlxPoint;
	private var _guideEndPosition:FlxPoint;
	private var _dragging:Bool;
	private var _canJump:Bool = false;
	private var _canJumpOnAir:Bool = false;
	private var _jumpCount:Int = 0;
	private var _maxJumpCount:Int = 2;

	private static inline var _throwScale:Float = -3;

	private var _jumpSound:FlxSound = FlxG.sound.load(AssetPaths.jump__wav);
	private var _secondJumpSound:FlxSound = FlxG.sound.load(AssetPaths.second_jump__wav);
	private var _landSound:FlxSound = FlxG.sound.load(AssetPaths.land__wav);

	private var _predictor:MovementPredictor;
	private var _predictedPoints:Array<FlxPoint>;

	private static inline var _maxPredictions:Int = 100;
	private static inline var _predictionTimeSlice:Float = .01;

	public function new(x:Float = 0, y:Float = 0, guide:FlxSprite, predictor:MovementPredictor)
	{
		super(x, y);

		_guide = guide;
		_predictor = predictor;

		loadGraphic(AssetPaths.player__png, true, 8);

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);

		// bounding box
		width = 6;
		height = 7;
		offset.set(1, 1);

		// physics
		acceleration.y = 240;
		drag.x = 10;

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
		_guideStartPosition = new FlxPoint();
		_guideEndPosition = new FlxPoint();

		_predictor.initialize(this);
		_predictedPoints = new Array<FlxPoint>();
		for (i in 0..._maxPredictions)
		{
			_predictedPoints.push(new FlxPoint());
		}
	}

	public function hitTilemap()
	{
		_landSound.play();
	}

	override public function update(elapsed:Float)
	{
		updateFlags();
		updateInput();
		updateAnimations();
		updateGuide();

		super.update(elapsed);
	}

	private function updateFlags()
	{
		if (isTouching(FlxObject.FLOOR))
		{
			_canJump = true;
			_canJumpOnAir = false;
			_jumpCount = 0;
		}
		else
		{
			_canJump = false;
		}
	}

	private function updateInput()
	{
		if (FlxG.mouse.justPressed)
		{
			_forceStartPosition.x = FlxG.mouse.screenX;
			_forceStartPosition.y = FlxG.mouse.screenY;
			_guideStartPosition.set(FlxG.mouse.screenX, FlxG.mouse.screenY);
			_dragging = true;
		}

		_guideEndPosition.set(FlxG.mouse.screenX, FlxG.mouse.screenY);

		if (_dragging && FlxG.mouse.justReleased)
		{
			_forceEndPosition.x = FlxG.mouse.screenX;
			_forceEndPosition.y = FlxG.mouse.screenY;
			_dragging = false;
			throwPlayer();
		}

		if (_dragging)
		{
			var forceEndX = FlxG.mouse.screenX;
			var forceEndY = FlxG.mouse.screenY;
			var forceVector = new FlxVector(forceEndX - _forceStartPosition.x, forceEndY - _forceStartPosition.y);
			forceVector.scale(_throwScale);
			_predictor.PredictMovement(forceVector, x + width / 2 - FlxG.camera.scroll.x, y + height / 2 - FlxG.camera.scroll.y, _predictionTimeSlice,
				_maxPredictions, _predictedPoints);
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
			else if (velocity.x < 0)
			{
				facing = FlxObject.LEFT;
			}
			else
			{
				facing = FlxG.mouse.x > x ? FlxObject.RIGHT : FlxObject.LEFT;
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
					animation.curAnim.frameRate = Math.abs(velocity.x) * .5;
				}
				else
				{
					animation.play(Animation.IDLE);
				}
			}
		}
	}

	private function updateGuide()
	{
		FlxSpriteUtil.fill(_guide, FlxColor.TRANSPARENT);
		if (_dragging && canJump())
		{
			var lineStyle:LineStyle = {
				thickness: 1,
				color: FlxColor.WHITE
			};
			FlxSpriteUtil.drawPolygon(_guide, _predictedPoints, FlxColor.TRANSPARENT, lineStyle);
		}
	}

	private function throwPlayer()
	{
		if (canJump())
		{
			var forceVector = new FlxVector(_forceEndPosition.x - _forceStartPosition.x, _forceEndPosition.y - _forceStartPosition.y);
			forceVector.scale(_throwScale);
			velocity.x = forceVector.x;
			velocity.y = forceVector.y;

			if (_jumpCount == 0)
				_jumpSound.play();
			else
				_secondJumpSound.play();

			_jumpCount++;
			_canJumpOnAir = true;
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
