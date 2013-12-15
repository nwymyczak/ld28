package;

import flash.Vector.Vector;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxVector;
import haxe.Int64;


import openfl.Assets;


class PlayState extends FlxState
{
	private var player     	: Player;
	//private var playercolor : UInt = 0xffFF8900;
	private var playerSize  : Int = 16;
	private var explosion : Explosion;
	private var enemies : FlxGroup;
	private var backgroundColor : UInt = 0xff000000;
	private var hud : Hud;
	private var elapsedTime : Float = 0;
	private var UpdateFunction : Void -> Void;
	
	private var walls : FlxGroup;
	
	private var hasExploded : Bool = false;
	
	private var minSpawnDist : Int = 150;
	private var maxSpawnDist : Int = 400;
	
	private var topTimes : Vector<Float>;
	
	private var spawnVect : FlxRect;
	
	private var numOfBackgroundTiles : Int = 6;	//make even (for the world bounds calc to work)
	
	private function CreateBackgroundAndWalls(backgroundImg:Dynamic, wallImg:Dynamic) {
		if (backgroundImg.width != wallImg.width || backgroundImg.height != wallImg.height) {
			throw "Background image and wall image should have the same dimensions";
		}
		walls = new FlxGroup();
		
		var halfTiles = Std.int(numOfBackgroundTiles / 2);
		FlxG.worldBounds.set( -backgroundImg.width * halfTiles, -backgroundImg.height * halfTiles, backgroundImg.width * numOfBackgroundTiles, backgroundImg.height * numOfBackgroundTiles);
		
		var tileWidth = backgroundImg.width;
		var tileHeight = backgroundImg.height;
		
		var playgroundStartX = - tileWidth * halfTiles;
		var playgroundStartY = - tileHeight * halfTiles;
		
		var wallsStartX = playgroundStartX - tileWidth;
		var wallsStartY = playgroundStartY - tileHeight;
		
		//Bounds has to include wall for collisions to work. +2 to include the left/right and top/bottom wwalls
		FlxG.worldBounds.set(wallsStartX, wallsStartY , tileWidth * (numOfBackgroundTiles + 2 ), tileHeight * (numOfBackgroundTiles + 2));
		
		var x = playgroundStartX;
		var y = playgroundStartY;
		
		for (ix in 0 ... numOfBackgroundTiles) {
			for (iy in 0 ... numOfBackgroundTiles) {
				var spr = new FlxSprite(x,y, backgroundImg);
				add(spr);
				y +=  tileHeight;
			}
			y = playgroundStartY;
			x += tileWidth;
		}
		
		x = wallsStartX;
		y = wallsStartY;		
		//Top Walls
		//+2 so the walls can wrap the background tiles
		var bottomY = playgroundStartY + (tileHeight * numOfBackgroundTiles);
		for (ix in 0 ... numOfBackgroundTiles + 2) {
			var top = new FlxSprite(x, y, wallImg);
			top.immovable = true;
			walls.add(top);
			var btm = new FlxSprite(x , bottomY, wallImg);
			btm.immovable = true;
			walls.add(btm);
			x += tileWidth;
		}
		
		x = wallsStartX;
		y = playgroundStartY; //Already did the top most y
		var rightX = playgroundStartX + (tileWidth * numOfBackgroundTiles);
		for (iy in 0 ... numOfBackgroundTiles ) {
			var left = new FlxSprite(x, y, wallImg);
			left.immovable = true;
			walls.add(left);
			
			var right = new FlxSprite(rightX , y, wallImg);
			right.immovable = true;
			walls.add(right);
			y += tileHeight;
		}
		add(walls);
	}
	
	private function CreateNewEnemy(player:Player) {
		var  newX = Randomf(player.halfX - maxSpawnDist, player.halfX + maxSpawnDist);
		var newY = Randomf(player.halfY - maxSpawnDist, player.halfY + maxSpawnDist);
		
		var testPoint = new FlxPoint(newX, newY);
		while (spawnVect.containsFlxPoint(testPoint)) {
			newX = Randomf(player.halfX - maxSpawnDist, player.halfX + maxSpawnDist);
			newY = Randomf(player.halfY - maxSpawnDist, player.halfY + maxSpawnDist);
			testPoint.set(newX, newY);
		}		
		var enemy = new Enemy(newX, newY, player);
		enemies.add(enemy);
	}
	
	private function CreateEnemies(player:Player){
		enemies = new FlxGroup();
		for (i in 0 ... 3) {
			CreateNewEnemy(player);
		}
		add(enemies);
	}
	
	private function Randomf(min : Float, max : Float) :  Float {
		return min + Math.random() * ((max - min ) + 1);
	}
	
	private function NegOrPos() :Float {
		if (Std.random(2) == 1) {
			return 1;
		}
		return -1;
	}
	
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = backgroundColor;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end	
		
		var	background = Assets.getBitmapData("assets/images/background.png");
		var darkBackground = Assets.getBitmapData("assets/images/backgroundDark.png");
		player = new Player(180, 220, playerSize);
		spawnVect = new FlxRect(player.halfX - minSpawnDist, player.halfY - minSpawnDist, player.width + minSpawnDist * 2, player.width + minSpawnDist * 2);
		
		CreateBackgroundAndWalls(background, darkBackground);
		CreateEnemies(player);	//requires spawnVct and player to be set;
		
		var camera = FlxG.camera;
		camera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 0);
		camera.bgColor = 0xffFFFFFF;		
		FlxG.camera.follow(player, 0, null, 5);
		FlxG.camera.followAdjust(0, 0);
		
		hud = new Hud();
		hud.setAll("scrollFactor", new FlxPoint(0, 0));
		hud.setAll("cameras", [FlxG.camera]);
		
		explosion = new Explosion(Assets.getBitmapData("assets/images/explosion.png"));
		
		UpdateFunction = RestartUpdate;
		
		
		add(player);
		add(hud);
		add(explosion);
		
		hud.ActivateIntroScreen();
		topTimes = new Vector<Float>(5);
		
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	private function KillAll() :Void {
		player.kill();
		enemies.kill();
	}
	private function ReviveAll() : Void {
		player.revive();
		enemies.revive();
	}
	private function KillAndReactiveEnemies() : Void {
		enemies.kill();
		enemies.revive();
		enemies.active = true;
	}
	
	private function ExplosionUpdate() : Void {
		explosion.updateExplosion(FlxG.elapsed);
		if ( ! explosion.IsExploding()) {
			UpdateFunction = PlayingUpdate;
		}
	}
	
	private function PlayingUpdate() : Void {
		
		spawnVect.x = player.x - minSpawnDist;
		spawnVect.y = player.y - minSpawnDist;
		
		elapsedTime += FlxG.elapsed;
		
		var roll = Math.random();
		if (roll > .90) {
			CreateNewEnemy(player);
		}
		
		hud.SetTimerFromElapsedTime(elapsedTime);		
		FlxG.collide(player, walls);
		FlxG.collide(player, enemies, PlayerEnemyCollision);	
		
		if (FlxG.keys.justPressed.SPACE && ! hasExploded) {
			enemies.active = false;
			var playerMid = player.getMidpoint();
			explosion.ActivateExplosionAt(new FlxPoint(playerMid.x, playerMid.y), .5, KillAndReactiveEnemies);
			UpdateFunction = ExplosionUpdate;
			hasExploded = true;
			hud.SetExplosionTo(true);
		}
	}
	
	private function RestartUpdate() : Void {
		
		player.x = 180;
		player.y = 220;
		
		if (FlxG.keys.justPressed.SPACE) {
			KillAndReactiveEnemies();
			UpdateFunction = PlayingUpdate;
			hud.ActivatePlayingScreen();
			ReviveAll();
			elapsedTime = 0;
			player.ResetHealth();
			hud.SetHealthTo(player.ourHealth);
			hasExploded = false;
			hud.SetExplosionTo(false);
		}
	}
	
	
	override public function update():Void
	{
		
		UpdateFunction();
		super.update();

	}
	
	private function PlayerEnemyCollision(_player: FlxObject, _enemy:FlxObject) {
		//shake screen
		//pause game
		//show score and "Restart?" message
		if (! player.isInvuln) {
			FlxG.camera.shake(.01, .05);
			player.DecHealth();
			hud.SetHealthTo(player.ourHealth);
			
			if (player.isDead) {
				
				if (elapsedTime > topTimes[topTimes.length - 1]) {
					topTimes[topTimes.length] = elapsedTime;
					topTimes.sort(timesSort);
					topTimes.length = 5;
				}
				hud.SetTopTimes(topTimes);
				hud.SetScoreFromElapsedTime(elapsedTime);
				hud.ActivateDeathScreen();
				KillAll();
				UpdateFunction = RestartUpdate;	
			}
			
		}
	}
	
	private function timesSort(x:Float, y:Float) : Int {
		if (x > y) {
			return -1; 
		}else if (y > x) {
			return 1;
		}
		return 0;		
	}
	
	
	
	
	
}