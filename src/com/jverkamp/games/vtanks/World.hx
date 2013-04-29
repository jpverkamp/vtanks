package com.jverkamp.games.vtanks;

import browser.geom.Matrix;
import nme.display.GradientType;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.geom.Point;
import nme.text.TextField;
import nme.Lib;

/**
 * Holds all of the mountains and tanks in the world
 */
class World {
	var width : Int;
	var height : Int;
	
	var g : Graphics;
	var mountains : Array<Point>;
	var tanks : Array<Tank>;
	var projectiles : Array<Projectile>;
	
	var currentTank : Tank;
	
	var angleDisplay : TextField;
	var powerDisplay : TextField;

	/**
	 * Create a new world of the specified size
	 * @param	width Width in pixels
	 * @param	height Height in pixels
	 */
	public function new(width : Int, height : Int) {
		this.width = width;
		this.height = height;
		
		// World generation
		generateMountains();
		addTanks();
		projectiles = new Array<Projectile>();
		
		// Set up the current tank's angle display in the top left
		angleDisplay = new TextField();
		angleDisplay.width = 100;
		angleDisplay.x = 12;
		angleDisplay.y = 24;
		Lib.current.addChild(angleDisplay);
		
		// Set up the current tank's power display in the top left
		powerDisplay = new TextField();
		powerDisplay.width = 100;
		powerDisplay.x = 12;
		powerDisplay.y = 36;
		Lib.current.addChild(powerDisplay);
	}
	
	/**
	 * Generate some nice jagged mountains
	 * 
	 * Go from left to right roughly at `width / count` intervals (some wiggle induced)
	 * Each peak can be at any random height
	 * 
	 * TODO: Make this a little nicer maybe?
	 * NOTE: Coordinates are y-increasing up, not down.
	 * 
	 * @param	numberOfPeaks How many peaks to generate, points will be this plus 2 for endpoints
	 */
	function generateMountains(numberOfPeaks : Int = 10) {
		// Left endpoint
		mountains = new Array<Point>();
		mountains.push(new Point(0, Std.random(height)));
		
		// Ususual offset between mountains, can also vary by half this either way.
		var offset = width / numberOfPeaks;
		
		// Generate some peaks!
		for (i in 0...numberOfPeaks) {
			// Wiggle room, then any height
			var x : Float = i * offset - offset / 2 + Std.random(Std.int(offset));
			var y : Float = Std.random(height);
			
			//trace("DEBUG: placing a moutain at " + x + ", " + y);
			
			mountains.push(new Point(x, y));
		}
		
		// Right endpoint
		mountains.push(new Point(width, Std.random(height)));
	}
	
	/**
	 * Add tanks / players.
	 * 
	 * TODO: Tanks are not ordered left to right. Should they be?
	 * TODO: Add more graphics for tanks? Probably not.
	 * NOTE: Coordinates are y-increasing up, not down.
	 * 
	 * @param	numberOfTanks The number of tanks to create, should be at least 2.
	 */
	function addTanks(numberOfTanks : Int = 4) {
		tanks = new Array<Tank>();
		
		// Keep trying to generate tanks
		// This will work since we just `continue` if we fail to make a tank
		while (tanks.length < numberOfTanks) {
			// Generate a possible location
			var x : Float = Std.random(width - Tank.TANK_WIDTH) + Tank.TANK_WIDTH / 2;
			var y : Float = -1;
			
			// These scoping rules are strange
			var j = 0;
			for (k in 0...mountains.length - 1) {
				j = k; // wow this is ugly. :)
				
				// We have to be between two peaks
				// Get the heights of those and generate a point between them
				// NOTE: This should theoretically also prevent multiple tanks from spawning on top of each other
				// NOTE: Unless of course you're really unlucky
				if (mountains[j].x <= x - Tank.TANK_WIDTH / 2 && mountains[j + 1].x >= x + Tank.TANK_WIDTH / 2) {
					var minY = Math.min(mountains[j].y, mountains[j + 1].y);
					var maxY = Math.min(mountains[j].y, mountains[j + 1].y);
					y = minY + Std.random(Std.int(maxY - minY));
					break;
				}
			}
			
			// If we're too far up/down bail
			// This also catches cases where y isn't set because we intersected a peak
			// NOTE: This will infinite loop if Tank.TANK_WIDTH doesn't fit in any gaps
			if (y < Tank.TANK_WIDTH || y > height - Tank.TANK_WIDTH) {
				//trace("DEBUG: couldn't place a tank at " + x + "--trying again");
				continue;
			} else {
				//trace(
					//"DEBUG: placing a tank at " + x + ", " + y + "; between " 
					//+ mountains[j].x + ", " + mountains[j].y + " and " 
					//+ mountains[j + 1].x + ", " + mountains[j + 1].y + ". That cool?"
				//);
				//trace("DEBUG: adding new point at " + (x - Tank.TANK_WIDTH / 2) + ", " + y);
				//trace("DEBUG: adding new point at " + (x + Tank.TANK_WIDTH / 2) + ", " + y);
			}
			
			// Add the two new peaks, keep this array sorted so we can add more
			mountains.insert(j + 1, new Point(x - Tank.TANK_WIDTH / 2, y));
			mountains.insert(j + 2, new Point(x + Tank.TANK_WIDTH / 2, y));
			
			// Generate a random color. Constraints:
			// -- RGB color where each of r,g,b is 0, 128, or 255
			// -- Not a dark color (r+g+b > 255)
			// -- Not already used
			var rgb : Int = 0x000000;
			while (true) {
				var r : Int = Std.int(Math.min(255, Std.random(3) * 128));
				var g : Int = Std.int(Math.min(255, Std.random(3) * 128));
				var b : Int = Std.int(Math.min(255, Std.random(3) * 128));
				rgb = (r << 16) | (g << 8) | b;
				
				// Have to be at least a bit bright (r+g+b > 255)
				if (r + g + b < 255)
					continue;

				// Can't match a previous color
				var matching = false;
				for (tank in tanks)
					if (tank.color == rgb)
						matching = true;
				if (matching)
					continue;

				// Actually generated a color (yay!)
				break;
			}
			
			// Remeber the tank
			tanks.push(new Tank(this, new Point(x, y), rgb));
		}
		
		// Set the current tank
		currentTank = tanks[0];
	}
	
	/**
	 * Check if a given tank is the current.
	 * @param	tank Tank to check.
	 * @return If it's the current one.
	 */
	public function isCurrent(tank : Tank) : Bool {
		return tank == currentTank;
	}
	
	/**
	 * The current tank fires it's gun.
	 * 
	 * TODO: This should also advance the round
	 */
	public function fire() {
		projectiles.push(new Projectile(this, currentTank, currentTank.getTurrent(), currentTank.angle, currentTank.power));
	}
	
	/**
	 * Update the world. Mostly update things in it.
	 * @param	msSinceLastFrame The time that has passed (in ms) since the last frame.
	 */
	public function update(msSinceLastFrame : Int) {
		// Update each tank
		for (tank in tanks) {
			tank.update(msSinceLastFrame);
			
			// TODO: Check for falling tanks
		}
		
		// Update each current projectile
		var toRemove = new Array<Projectile>();
		for (proj in projectiles) {
			proj.update(msSinceLastFrame);			
			
			// Check for out of bounds, remove projectiles off the screen
			if (proj.location.x < 0 || proj.location.x >= width || proj.location.y < 0 || proj.location.y >= height) {
				toRemove.push(proj);
			}
			
			// Check for collisions
			// TODO: this
		}
		for (proj in toRemove) {
			projectiles.remove(proj);
		}
	}
	
	/**
	 * Draw the world and the things in it.
	 * 
	 * TODO: Delegate more drawing to the subclasses, things can draw themselves...
	 * 
	 * @param	g The Graphics object to use to draw with. (No bounds checking...)
	 */
	public function draw(g : Graphics) {
		g.clear();
		
		// Mountains
		g.beginFill(0xFFFFFF);
		//g.beginGradientFill(GradientType.LINEAR, [0x33ff33, 0xbbffbb], [1, 1], [0, 255]); // TOOD: Rotate this from left/right to down/up.
		g.moveTo(0, height);
		for (i in 0...mountains.length) {
			g.lineTo(mountains[i].x, height - mountains[i].y);
		}
		g.lineTo(width, height);
		g.lineTo(0, height);
		g.endFill();
		
		// Tanks
		//    D (tip)
		//     \
		//   B--C--E
		//  / tank  \
		// A---------F 
		// 
		// ASCII art ftw!
		for (tank in tanks) {
			var tip = tank.getTurrent();
			
			g.lineStyle(2, tank.color);
			/* A */ g.moveTo(tank.location.x - Tank.TANK_WIDTH / 2, height - tank.location.y);
			/* B */ g.lineTo(tank.location.x - Tank.TANK_WIDTH / 2 + Tank.TANK_WIDTH / 4, height - tank.location.y - Tank.TANK_WIDTH / 2);
			/* C */ g.lineTo(tank.location.x, height - tank.location.y - Tank.TANK_WIDTH / 2);
			/* D */ g.lineTo(tip.x, height - tip.y);
			/* C */ g.lineTo(tank.location.x, height - tank.location.y - Tank.TANK_WIDTH / 2);
			/* E */ g.lineTo(tank.location.x + Tank.TANK_WIDTH / 4, height - tank.location.y - Tank.TANK_WIDTH / 2);
			/* F */ g.lineTo(tank.location.x + Tank.TANK_WIDTH / 2, height - tank.location.y);
			/* A */ g.lineTo(tank.location.x - Tank.TANK_WIDTH / 2, height - tank.location.y);
			
			// Update current angle and power for the current tank
			// Also color code it. That will signify current player as well
			if (isCurrent(tank)) {
				var angleInDegrees = (tank.angle - Math.PI / 2) * 360 / (2 * Math.PI);
				if (angleInDegrees > 180) angleInDegrees -= 360;
				
				angleDisplay.textColor = tank.color;
				angleDisplay.text = "Angle: " + (Math.round(-1 * angleInDegrees * 100) / 100);
				
				powerDisplay.textColor = tank.color;
				powerDisplay.text = "Power: " + (Math.round(tank.power * 100) / 100);
			}
		}
		
		// Projectiles
		for (proj in projectiles) {
			g.lineStyle(1, 0xFFFFFF);
			g.beginFill(proj.tank.color);
			g.drawCircle(proj.location.x, height - proj.location.y, Projectile.PROJECTILE_WIDTH);
			g.endFill();
		}
	}
}