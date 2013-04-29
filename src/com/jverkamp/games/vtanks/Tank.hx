package com.jverkamp.games.vtanks;
import nme.events.KeyboardEvent;
import nme.geom.Point;
import nme.events.Event;
import nme.Lib;

/**
 * Tanks shoot things. Duh.
 */
class Tank {
	// Woo constants!
	// TODO: Is there a better way to do this in FlashDevelop? Like `final` or `readonly`?
	public static var TANK_WIDTH = 16;
	public static var ANGLE_DELTA = 2 * Math.PI / 360 * 5;
	public static var POWER_DELTA = 1;
	public static var POWER_MAX = 100;
	
	// Shift makes it faster, ctrl makes it slower
	// Shift has priority
	public static var SHIFT_MULTIPLIER = 3;
	public static var CTRL_MULTIPLIER = 0.1;
	
	// Actual tank parameters
	public var world : World;
	public var location : Point;
	public var color : Int;
	public var falling : Bool;
	
	// Angle in radians, 0 is right, positive is counterclockwise
	public var angle : Float;
	
	// Power in random arbitrary units, 0 is minimum, 100 is maximum
	public var power : Float;
	
	// Currently pressed keys we care about
	// TODO: Abstract this somehow?
	// TODO: Reset these when a tank gains control or we'll get weird artifacts
	public var left_pressed = false;
	public var right_pressed = false;
	public var up_pressed = false;
	public var down_pressed = false;
	public var shift_pressed = false;
	public var ctrl_pressed = false;
	
	/**
	 * Create a new tank.
	 * @param	world The world the tank is in.
	 * @param	location Where in the world to place the tank.
	 * @param	color The color to draw the tank 0xrrggbb
	 */
	public function new(world : World, location : Point, color : Int) {
		this.world = world;
		this.location = location;
		this.color = color;
		this.angle = 0.5 * Math.PI; // up
		this.power = 50;
		
		// We have to bind to the stage's key listener or we don't get global keys
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}
	
	/**
	 * Get the current point at the end of the turret
	 * Yay trig.
	 * @return The end point
	 */
	public function getTurrent() : Point {
		return new Point(
			location.x + Math.cos(angle) * TANK_WIDTH / 2,
			location.y + TANK_WIDTH / 2 + Math.sin(angle) * TANK_WIDTH / 2
		);
	}
	
	/**
	 * Update the current tank.
	 * 
	 * NOTE: Since we aren't actually using the time, tanks will move slower under slower FPS
	 * TODO: /\ Fix this
	 * 
	 * @param	msSinceLastFrame How long it's been since the last update
	 */
	public function update(msSinceLastFrame : Int) {
		// Falling tanks should fall
		// Find the grand beneath it
		for (i in 0...world.mountains.length - 1) {
			// We have to be between two peaks
			// Get the heights of those and interpolate between them
			if (world.mountains[i].x <= location.x && world.mountains[i + 1].x >= location.x) {
				var multiplier = 1.0 * (location.x - world.mountains[i].x) / (world.mountains[i + 1].x - world.mountains[i].x);
				var yground = multiplier * (world.mountains[i + 1].y - world.mountains[i].y) + world.mountains[i].y;
				if (location.y <= yground) {
					falling = false;
				} else {
					// TODO: Make this better
					location.y -= 1;
				}
			}
		}
		
		// NOTE: for angles, 0 is right and positive is counter clockwise
		
		// Shift makes it faster, ctrl makes it slower
		// Shift has priority
		var mult : Float = 1.0;
		if (shift_pressed)
			mult = SHIFT_MULTIPLIER;
		else if (ctrl_pressed)
			mult = CTRL_MULTIPLIER;
		
		// Update variables, ignore bounds
		if (left_pressed) {
			angle += mult * ANGLE_DELTA;
		} else if (right_pressed) {
			angle -= mult * ANGLE_DELTA;
		} else if (up_pressed) {
			power += mult * POWER_DELTA;
		} else if (down_pressed) {
			power -= mult * POWER_DELTA;
		}
		
		// Modular math on angle to 2Pi radians
		while (angle < 0) angle += 2 * Math.PI;
		while (angle >= Math.PI * 2) angle -= 2 * Math.PI;
		
		// Clamp power to [0, 100]
		if (power < 0) power = 0;
		if (power > POWER_MAX) power = POWER_MAX;
	}
	
	/**
	 * When a key goes down (In a theater? Listening to Alanis Morissette. Good timing.), register that. 
	 * @param	event Key event.
	 */
	public function onKeyDown(event : KeyboardEvent) {
		onKey(true, event);
	}
	
	/**
	 * When a key goes up, register that. 
	 * @param	event Key event.
	 */
	public function onKeyUp(event : KeyboardEvent) {
		onKey(false, event);
	}
	
	/**
	 * Merged keyboard events.
	 * @param	isDownEvent If we want down or up
	 * @param	event Key event
	 */
	public function onKey(isDownEvent : Bool, event : KeyboardEvent) {
		// Only the current tank actually responds to keyboards events
		// TODO: Add a player variable to this
		if (!world.isCurrent(this)) return;
		
		// Shift makes it faster, ctrl makes it slower
		// Shift has priority
		shift_pressed = isDownEvent && event.shiftKey;
		ctrl_pressed = isDownEvent && event.ctrlKey;
		
		// TODO: This is ugly. Make it better
		
		//        Arrow   Lower   Upper
		//  LEFT   37 <-   97 a    65 A
		//    UP   38 ^   119 w    87 W  
		// RIGHT   39 ->  100 d    68 D
		//  DOWN   40 v   115 s    83 S
		
		if (event.keyCode == 37 || event.keyCode == 97 || event.keyCode == 65) {
			left_pressed = isDownEvent;
		} else if (event.keyCode == 39 || event.keyCode == 100 || event.keyCode == 68) {
			right_pressed = isDownEvent;
		} else if (event.keyCode == 38 || event.keyCode == 119 || event.keyCode == 87) {
			up_pressed = isDownEvent;
		} else if (event.keyCode == 40 || event.keyCode == 115 || event.keyCode == 83) {
			down_pressed = isDownEvent;
		}
		
		// On a key down == space, fire the tank's gun
		// NOTE: This doesn't use the main update loop
		// NOTE: ' ' == 32
		if (isDownEvent && event.keyCode == 32) {
			world.fire();
		}
	}
}