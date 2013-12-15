package ;
import flixel.FlxSprite;
import flixel.tweens.misc.NumTween;
import flixel.util.FlxPoint;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * ...
 * @author Nick W
 */
class Explosion extends FlxSprite
{
	//private var isExploding : Bool = false;
	//private var explodingDt : Float = 0;
	//private var totalTimeToExplode : Float = 1;
	//private var explodeTween : NumTween;
	
	
	private var timeToExplode : Float;
	private var timeSpentInExplosion : Float;
	private var scalingTween : NumTween;
	
	public function IsExploding() : Bool {
		return timeSpentInExplosion < timeToExplode;
	}
	
	public function new(img:Dynamic) 
	{
		super(0, 0, img);
		this.visible = false;
	}
	
	public function ActivateExplosionAt(point: FlxPoint, timeToExplode :Float, cameraCallback : Void ->Void ) {
		this.x = point.x - this._halfWidth;
		this.y = point.y - this._halfHeight;
		this.scale.x = 0.01;
		this.scale.y = 0.01;
		this.visible = true;
		this.timeToExplode = timeToExplode;
		this.timeSpentInExplosion = 0;
		FlxG.camera.shake(.02, timeToExplode,cameraCallback);
		
		this.scalingTween = FlxTween.num(0.0, 2.5, timeToExplode, { ease: FlxEase.cubeOut } );
		this.scalingTween.active = true;
	}
	
	
	//Set gamestate to explosion (aka pause the game)
			//zoom the camera in slightly to the player, while shaking screen
			//play explosion sound, 
			//set the explosion to active
			//when explosion overlaps an enemy play a sound?
			//wipe enemies clear
			//return to normal gameplay.
			
	public function updateExplosion(dt : Float) {
		timeSpentInExplosion += dt;
		
		if (IsExploding()) {
			this.scale.x += this.scalingTween.value;
			this.scale.y += this.scalingTween.value;
		}
		else {
			this.visible = false;
			this.scalingTween.active = false;
		}
	}
	/*		
	public override function update(dt : Float) {
		
		
		var smallExplosionTime : Float = .4;
		var timeOutBetweenExplosions : Float = .3;
		var largeExplosionTime : Float = .15;
		var totalSmallExplodes = 5;
		
		var smallTotalTime = (smallExplosionTime + timeOutBetweenExplosions) * totalSmallExplodes;
		var totalExplosionTime = largeExplosionTime + smallTotalTime;
		
		if (FlxG.keys.pressed.SPACE) {
			isExploding = true;
			explodeTween = FlxTween.num(0.0, .05, smallTotalTime, { ease: FlxEase.cubeOut } );
			explodeTween.start();
			explosionDt = 0;
			explosions = 0;
			
			enemies.active = false;

			enemies.kill();
			enemies.revive();
			explosion.visible = true;
			var camera = FlxG.camera;
			
			FlxG.camera.shake(.05, .05);
			
		}
		
		if(isExploding){
		explosionDt += FlxG.elapsed;
			
			
			
			if (explosionDt < smallExplosionTime) {
				explosion.scale.x += .2;
				explosion.scale.y += .2;
			}else {
				explosion.visible = false;
			}
			
			
			if (explosions < totalSmallExplodes && explosionDt > (smallExplosionTime + timeOutBetweenExplosions)) {
				explosion.visible = true;
				explosion.setPosition(Math.random() * FlxG.width, Math.random() * FlxG.height);
				explosion.scale.x = .03;
				explosion.scale.y = .03;
				FlxG.log.add("Small");
				FlxG.camera.shake(explodeTween.value, smallExplosionTime);	
				explosions++;
				explosionDt = 0;
			}
			
			if (explosions >= totalSmallExplodes) {
				var playerMidPoint = player.getMidpoint();
				FlxG.camera.shake(explodeTween.value, largeExplosionTime);
				isExploding = false;
			}
		}
		
		
	}
	*/
	
}