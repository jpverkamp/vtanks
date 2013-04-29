package com.jverkamp.games.vtanks;
import nme.events.KeyboardEvent;
import nme.geom.Point;
import nme.events.Event;
import nme.Lib;

class Tank {
	public static var TANK_WIDTH = 16;
	public static var ANGLE_DELTA = 2 * Math.PI / 360 * 5;
	public static var POWER_DELTA = 1;
	public static var POWER_MAX = 100;
	
	public var world : World;
	
	public var location : Point;
	public var color : Int;
	
	public var angle : Float;
	public var power : Int;
	
	public function new(world : World, location : Point, color : Int) {
		this.world = world;
		this.location = location;
		this.color = color;
		this.angle = 0.5 * Math.PI;
		this.power = 50;
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
	}
	
	public function getTurrent() : Point {
		return new Point(
			location.x + Math.cos(angle) * TANK_WIDTH / 2,
			location.y + TANK_WIDTH / 2 + Math.sin(angle) * TANK_WIDTH / 2
		);
	}
	
	public function onKey(event : KeyboardEvent) {
		if (!world.isCurrent(this)) return;
		
		//  LEFT: 37 <-   97 a   65 A
		//    UP: 38 ^   119 w   87 W  
		// RIGHT: 39 ->  100 d   68 D
		//  DOWN: 40 v   115 s   83 S
		
		// NOTE: for angles, 0 is right and positive is counter clockwise
		
		var mult = (event.shiftKey ? 10 : 1);
		
		if (event.keyCode == 37 || event.keyCode == 97 || event.keyCode == 65) {
			angle += mult * ANGLE_DELTA;
		} else if (event.keyCode == 39 || event.keyCode == 100 || event.keyCode == 68) {
			angle -= mult * ANGLE_DELTA;
		} else if (event.keyCode == 38 || event.keyCode == 119 || event.keyCode == 87) {
			power += mult * POWER_DELTA;
		} else if (event.keyCode == 40 || event.keyCode == 115 || event.keyCode == 83) {
			power -= mult * POWER_DELTA;
		}
		
		while (angle < 0) angle += 2 * Math.PI;
		while (angle >= Math.PI * 2) angle -= 2 * Math.PI;
		
		if (power < 0) power = 0;
		if (power > POWER_MAX) power = POWER_MAX;
	}
}