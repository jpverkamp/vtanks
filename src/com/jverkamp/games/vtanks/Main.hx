package com.jverkamp.games.vtanks;

import nme.display.Graphics;
import nme.display.Sprite;
import nme.events.Event;
import nme.text.TextField;
import nme.Lib;

class Main extends Sprite {
	var world : World;
	
	var startTime : Int;
	var frames : Int;
	var fps : TextField;
	
	public function new() {
		super();
		#if iphone
		Lib.current.stage.addEventListener(Event.RESIZE, init);
		#else
		addEventListener(Event.ADDED_TO_STAGE, init);
		#end
	}

	private function init(e)  {
		fps = new TextField();
        fps.width = 400;
        fps.y = 10;
		fps.textColor = 0xFFFFFF;
        fps.text = "FPS: ";
        nme.Lib.current.addChild(fps);
		
		startTime = nme.Lib.getTimer();
		
		world = new World(Lib.current.graphics, 640, 480);
	
		var timer = new haxe.Timer(10);
        timer.run = runLoop;
	}
	
	private function runLoop() {
		frames += 1;
		fps.text = "FPS: " + (frames / (0.001 * (Lib.getTimer() - startTime)));
		
		world.draw();
	}
	
	static public function main() {
		var stage = Lib.current.stage;
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		stage.align = nme.display.StageAlign.TOP_LEFT;
		
		Lib.current.addChild(new Main());
	}
	
}
