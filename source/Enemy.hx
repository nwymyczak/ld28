package ;

import flixel.FlxSprite;
import flixel.util.FlxVector;
import flixel.util.FlxPoint;
/**
 * ...
 * @author Nick W
 */
class Enemy extends FlxSprite {
	
	
	private static var floaterColor : UInt = 0xffFF3500;
	private static var zombieColor : UInt = 0xffA62300;
	
	private var player : Player;
	private var speed : Float = 100;
	private var updater : Void -> Void;
	
	public function new(x:Float = 0, y:Float = 0, player: Player) {		
		this.player =  player;
		this.maxVelocity = new FlxPoint(10,10);		
		super(x, y);		
		var roll = Std.random(2);
		if (roll == 0) {
			makeIntoFloater();
		}else {
			makeIntoZombie();
		}
		
	}
	
	private function makeIntoFloater() : Void {
		this.makeGraphic(8, 8, floaterColor);
		this.updater = floaterUpdate;
	}
	
	private function makeIntoZombie() : Void {
		this.makeGraphic(8, 8, zombieColor);
		this.updater = zombieUpdate;
	}
	
	private function zombieUpdate() : Void {
		var myVec = new FlxVector(this.x, this.y);
		var dir = new FlxVector(player.halfX, player.halfY);
		dir.substract(myVec);
		dir.normalize();
		
		this.velocity.x = dir.x * speed;
		this.velocity.y = dir.y * speed;
	}
	
	private function floaterUpdate() : Void {
		var myVec = new FlxVector(this.x, this.y);
		var dir = new FlxVector(player.halfX, player.halfY);
		dir.substract(myVec);
		dir.normalize();
		
		this.acceleration.x = dir.x * speed;
		this.acceleration.y = dir.y * speed;
	}
	
	
	override public function update():Void 
	{
		super.update();
		this.updater();		
	}
}