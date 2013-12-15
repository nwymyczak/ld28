package ;

import flash.Vector.Vector;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.FlxG;
/**
 * ...
 * @author Nick W
 */
class Hud extends FlxGroup
{
	private var timer : FlxText;
	
	private var title : FlxText;
	private var helpMessage  : FlxText;
	private var startMessage  : FlxText;
	
	private var lastScore     : FlxText;
	private var topTimes 	  : FlxText;
	
	private var instructions  : FlxText;
	
	private var health 		  : FlxText;
	private var healthSprites : Vector<FlxSprite>;
	
	private var explosion 	  : FlxText;
	
	//Last Time Was : 01:10:11
	//Press any key to start.
	
	
	private function FormatElapsedTime(elapsedTime : Float ) : String {
		//70.92 == elapsed time (in seconds)
		//min:sec:ms
		//70.92 ==> 1:10:92
		
		//70.92 => 70
		var totalSeconds = Std.int(elapsedTime);
		//(70.92 - 70) == .92 ==> int(.92 * 100) ==> 92
		var ms = Std.int((elapsedTime - totalSeconds)* 100);
		//70 % 60 == 10 
		var sec = totalSeconds % 60;
		//int(70/60) == 1
		var min = Std.int(totalSeconds / 60);
		return Std.string(min) + ":" + Std.string(sec) + ":" + Std.string(ms);
	}
	public function SetTimerFromElapsedTime(elapsedTime:Float) : Void {
		timer.text = FormatElapsedTime(elapsedTime);
	}
	
	public function SetTopTimes(times : Vector<Float>) : Void {
		var text = "Top times  \n";
		for (i in 0 ... times.length) {
			text += "\t" + Std.string(i + 1) + ": "+ FormatElapsedTime(times[i]) + "\n";
		}
		topTimes.text = text;
	}
	
	public function SetHealthTo(health : Int) : Void {
		if (health > 0 && health <= healthSprites.length) {
			var healthInd = health - 1;
			var i = 0;
			while (i <= healthInd) {
				healthSprites[i].visible = true;
				i++;
			}
			while (i < healthSprites.length) {
				healthSprites[i].visible = false;
				i++;
			}
		}
		if (health <= 0) {
			for (i in 0 ... healthSprites.length) {
				healthSprites[i].visible = false;
			}
		}
	}
	
	public function SetScoreFromElapsedTime(elapsedTime: Float) : Void {
		lastScore.text = "Current Time : " + FormatElapsedTime(elapsedTime);
	}	
	public function SetExplosionTo(hasExploded : Bool) : Void {
		if (hasExploded) {
			explosion.color = (0xAAAAAA);
		}else {
			explosion.color = (0xFFFFFF);
		}
	}
	private function IntroVisible(visible: Bool) : Void {
		if (visible) {
			title.visible = true;
			startMessage.visible = true;
			helpMessage.visible = true;
			startMessage.x = 125;
			startMessage.y = 350;
			
		}else {
			title.visible = false;
			startMessage.visible = false;
			helpMessage.visible = false;
		}
	}
	private function PlayingVisible(visible: Bool) : Void {
		if (visible) {
			health.visible = true;
			explosion.visible = true;
			timer.visible = true;
		}else {
			explosion.visible = false;
			health.visible = false;
			timer.visible = false;
			SetHealthTo(-1);
		}
	}
	private function RestartVisible(visible: Bool) : Void {
		if (visible) {
			startMessage.visible = true;
			lastScore.visible = true;
			topTimes.visible = true;	
			startMessage.x = FlxG.width / 2 - 75;
			startMessage.y = FlxG.height / 2 - 20;
		}else {
			startMessage.visible = false;
			lastScore.visible = false;
			topTimes.visible = false;
		}
	}
	
	public function ActivateIntroScreen() :Void {
		PlayingVisible(false);
		RestartVisible(false);
		IntroVisible(true);
	}
	
	public function ActivatePlayingScreen() : Void {
		IntroVisible(false);
		RestartVisible(false);
		PlayingVisible(true);
	}
	
	public function ActivateDeathScreen() : Void {
		IntroVisible(false);
		PlayingVisible(false);
		RestartVisible(true);
	}
	
	
	public function new()
	{
		super();
		
		var textSize = 16;
		var textWidth = 300;
		
		var helpText = "Move with the WASD or Arrows Keys.\n" +
					   "Press space to cause an explosion.\n" +
					   "Avoid the nasty red squares.";
		
		title = new FlxText(30, 100, 1080, "You only have one Explosion!", 32);
		
		helpMessage = new FlxText(125,275,textWidth + 250, helpText, textSize); 
		
		add(title);
		add(helpMessage);
		
		
		
		var healthStartingX = 15;
		var healthStartingY = 35;
		
		health = new FlxText(15, 10, textWidth, "Health", textSize);		
		var colors: Array<UInt> = [0xffA65900, 0xffBF7D30, 0xffFF8900, 0xffFFA640, 0xffFFBE73];
		healthSprites = new Vector<FlxSprite>(colors.length);
		
		for (i in 0 ... colors.length) {
			var spr = new FlxSprite(healthStartingX + i * 16, healthStartingY);
			spr.makeGraphic(16, 16, colors[i]);
			healthSprites[i] = spr;
			add(spr);
		}
		
		explosion = new FlxText(100, 10, textWidth, "Explosion", textSize);
		
		
		timer = new FlxText(FlxG.width / 2, 13 , 120, "", textSize);
		
		lastScore = new FlxText((FlxG.width / 2) - 75, (FlxG.height / 2) - 40, textWidth, "",textSize);
		startMessage = new FlxText((FlxG.width / 2) - 75, FlxG.height / 2 - 20, textWidth, "Press space to start",textSize);
		topTimes = new FlxText((FlxG.width / 2) - 75, (FlxG.height / 2) + 5, textWidth, "",textSize);
		
		
		
		add(explosion);
		add(health);
		add(timer);
		add(startMessage);
		add(lastScore);
		add(topTimes);
		
		ActivateIntroScreen();	
	}
}