package com.jverkamp.games.vtanks;

import haxe.Timer;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.events.Event;
import nme.text.TextField;
import nme.Lib;

/**
 * Main entry point
 */
class Main extends Sprite {
	var world : World;
	
	var lastTime : Int;
	var startTime : Int;
	var frames : Int;
	var fps : TextField;
	
	/**
	 * Auto generated magic?
	 */
	public function new() {
		super();
		#if iphone
		Lib.current.stage.addEventListener(Event.RESIZE, init);
		#else
		addEventListener(Event.ADDED_TO_STAGE, init);
		#end
	}

	/**
	 * "Real" new method
	 * @param	e
	 */
	private function init(e)  {
		// Create the FPS display
		fps = new TextField();
        fps.width = 400;
		fps.x = 12;
        fps.y = 12;
		fps.textColor = 0xFFFFFF;
        fps.text = "FPS: ";
        nme.Lib.current.addChild(fps);
		
		// Timer for FPS and to correctly esimate velocities
		startTime = nme.Lib.getTimer();
		lastTime = startTime;
		
		// Create the actual important part!
		world = new World(640, 480);
	
		// Update tick, try for 10ms between updates
		var timer = new Timer(10);
        timer.run = runLoop;
	}
	
	/**
	 * Run when the timer is called
	 */
	private function runLoop() {
		// Update fps count
		frames += 1;
		fps.text = "FPS: " + (Math.round(100 * (frames / (0.001 * (Lib.getTimer() - startTime)))) / 100);
		
		// Update any time based things
		var time = nme.Lib.getTimer();
		world.update(time - lastTime);
		lastTime = time;
		
		// Draw everything again!
		// NOTE: If necessary we can make this every other frame easily with `frames % 2 == 0`
		world.draw(Lib.current.graphics);
	}
	
	/**
	 * Entry point into the program
	 */
	static public function main() {
		var stage = Lib.current.stage;
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		stage.align = nme.display.StageAlign.TOP_LEFT;
		
		Lib.current.addChild(new Main());
	}
}
