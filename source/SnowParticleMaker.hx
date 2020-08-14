package;

import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;

class SnowParticleMaker
{
	public var emitter:FlxEmitter;
	public var whitePixel:FlxParticle;

	public function new()
	{
		// Particles
		var nParticles = 200;
		emitter = new FlxEmitter(0, 0, nParticles);
		emitter.velocity.set(-200, -10, -100, 10);
		emitter.width = FlxG.width;
		emitter.height = FlxG.height;

		for (i in 0...nParticles)
		{
			var whitePixel = new FlxParticle();
			whitePixel.scrollFactor.set(0, 0);
			whitePixel.makeGraphic(1, 1, 0xAAFFFFFF);
			whitePixel.visible = false; // Make sure the particle doesn't show up at (0, 0)
			emitter.add(whitePixel);
		}
	}

	public function start()
	{
		emitter.start(false, .04);
	}
}
