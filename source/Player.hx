package ;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxVector;
/**
 * ...
 * @author Nick W
 */
class Player extends FlxSprite {
	
	public var halfX(get, null) : Float;
	public var halfY(get, null) : Float;
	public function get_halfX():Float {
		return this.x +_halfWidth;
	}
	public function get_halfY():Float {
		return this.y +_halfHeight;
	}
	
	private var speed : Float = 1000;
	private var friction : Float = 10.5;
	
	public var colors : Array<UInt>;
	public var ourHealth : Int = 5;	
	
	private var invlunStartingTime : Float = .3;
	
	private var invulnTime : Float = .04;
	
	public var isDead(get, null) : Bool;
	public function get_isDead(): Bool {
		return ourHealth <= 0;
	}
	
	public var isInvuln(get, null) : Bool;
	public function get_isInvuln() : Bool {
		return invulnTime >= 0;
	}
	
	public function IncHealth() : Void {
		
		this.ourHealth ++;
		if (! get_isDead()) {
			this.color = this.colors[ourHealth - 1];
		}
	}
	public function DecHealth() : Void {
		if(! get_isInvuln()){
			this.ourHealth --;
			invulnTime = invlunStartingTime;
		}
		
		if (! get_isDead()) {
			this.color = this.colors[ourHealth - 1];
		}
	}
	
	public function ResetHealth() : Void {
		this.ourHealth = colors.length;
		this.color = this.colors[ourHealth - 1];
	}
	
	
	public function new(x:Float, y:Float, size : Int) {
		//this.immovable = true;
		super(x, y);
		this.colors = [0xffA65900, 0xffBF7D30, 0xffFF8900, 0xffFFA640, 0xffFFBE73];
		this.makeGraphic(size, size, 0xffffffff);
		ResetHealth();
		this.maxVelocity.x = 300;
		this.maxVelocity.y = 300;
	}
	override public function update():Void 
	{
		this.velocity.x = 0;
		this.velocity.y = 0;

		this.invulnTime -= FlxG.elapsed;
		
		if ((FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A))
		{
			//this.acceleration.x = -speed;
			this.velocity.x = -300;
		}else if ((FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D ))
		{
			//this.acceleration.x = speed;
			this.velocity.x = 300;
		}else {
			//this.acceleration.x = 0;
		}
		
		if ((FlxG.keys.pressed.UP || FlxG.keys.pressed.W))
		{
			//this.acceleration.y = -speed;
			this.velocity.y = -300;
		}else if ((FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S ))
		{
			//this.acceleration.y = speed;
			this.velocity.y = 300;
		}else {
			//this.acceleration.y = 0;
		}
		super.update();
		
	}
}