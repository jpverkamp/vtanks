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
	public var width : Int;
	public var height : Int;
	
	public var g : Graphics;
	public var mountains : Array<Point>;
	public var tanks : Array<Tank>;
	public var projectiles : Array<Projectile>;
	
	public var currentTank : Int;
	public var winner : Tank;
	
	public var angleDisplay : TextField;
	public var powerDisplay : TextField;
	
	public var waiting : Bool;

	/**
	 * Create a new world of the specified size
	 * @param	width Width in pixels
	 * @param	height Height in pixels
	 */
	public function new(width : Int, height : Int) {
		this.width = width;
		this.height = height;
		this.waiting = true;
		
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
		currentTank = 0;
	}
	
	/**
	 * Check if a given tank is the current.
	 * @param	tank Tank to check.
	 * @return If it's the current one.
	 */
	public function isCurrent(tank : Tank) : Bool {
		return tank == tanks[currentTank];
	}
	
	/**
	 * The current tank fires it's gun. 
	 * 
	 * TODO: This should also advance the round
	 */
	public function fire() {
		if (winner == null && projectiles.length == 0) {
			waiting = false;
			projectiles.push(new Projectile(this, tanks[currentTank] , tanks[currentTank].getTurrent(), tanks[currentTank].angle, tanks[currentTank].power));
		}
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
		var projsToRemove = new Array<Projectile>();
		var tanksToRemove = new Array<Tank>();
		
		for (proj in projectiles) {
			proj.update(msSinceLastFrame);			
			
			// Check for out of bounds, remove projectiles off the screen
			if (proj.location.x < 0 || proj.location.x >= width || proj.location.y < 0 || proj.location.y >= height) {
				projsToRemove.push(proj);
			}
			
			// Check for collisions
			if (proj.explodingFrame < 0) {
				var impactY : Float = -1;
				for (j in 0...mountains.length - 1) {
					// We have to be between two peaks
					// Get the heights of those and interpolate between them
					if (mountains[j].x <= proj.location.x && mountains[j + 1].x >= proj.location.x) {
						//trace("projectile at " + proj.location + " hitting between " + mountains[j] + " and " + mountains[j + 1]);
						
						var multiplier = 1.0 * (proj.location.x - mountains[j].x) / (mountains[j + 1].x - mountains[j].x);
						var yground = multiplier * (mountains[j + 1].y - mountains[j].y) + mountains[j].y;
						
						//trace("ground point is at " + yground);
						
						if (proj.location.y < yground) {
							impactY = yground;
							break;
						}
					}
				}
				
				// We hit something!
				if (impactY >= 0) {
					proj.explodingFrame = 1;
					proj.velocity = new Point(0, 0);
					//proj.location.y = impactY;
				}
			}
			
			// If it's too far gone, boom
			else if (proj.explodingFrame > Projectile.MAX_EXPLOSION_WIDTH) {
				projsToRemove.push(proj);
				
				// Redraw the landscape
				
				// Remove any peaks in the collision range
				var insertAt = -1;
				var i = 0;
				while (i < mountains.length) {
					// This where it goes, remember it
					if (insertAt < 0 && mountains[i].x > proj.location.x) {
						insertAt = i;
					}
					
					// Peak matched, remove
					if (proj.location.x - Projectile.MAX_EXPLOSION_WIDTH < mountains[i].x && proj.location.x + Projectile.MAX_EXPLOSION_WIDTH > mountains[i].x) {
						//trace("DEBUG: removing peak " + i + ", " + mountains[i]);
						mountains.remove(mountains[i]);
					} 
					
					// No peak, advance
					else {
						i++;
					}
				}
				
				// Add new peaks for the explosion
				//trace("DEBUG: new peak at " + insertAt + ", " + new Point(proj.location.x - Projectile.MAX_EXPLOSION_WIDTH, proj.location.y));
				//trace("DEBUG: new peak at " + (insertAt + 1) + ", " + new Point(proj.location.x - Projectile.MAX_EXPLOSION_WIDTH / 2, proj.location.y - Projectile.MAX_EXPLOSION_WIDTH / 2));
				//trace("DEBUG: new peak at " + (insertAt + 2) + ", " + new Point(proj.location.x + Projectile.MAX_EXPLOSION_WIDTH / 2, proj.location.y - Projectile.MAX_EXPLOSION_WIDTH / 2));
				//trace("DEBUG: new peak at " + (insertAt + 3) + ", " + new Point(proj.location.x + Projectile.MAX_EXPLOSION_WIDTH, proj.location.y));
				mountains.insert(insertAt, new Point(proj.location.x - Projectile.MAX_EXPLOSION_WIDTH, proj.location.y));
				mountains.insert(insertAt + 1, new Point(proj.location.x - Projectile.MAX_EXPLOSION_WIDTH / 2, proj.location.y - Projectile.MAX_EXPLOSION_WIDTH / 2));
				mountains.insert(insertAt + 2, new Point(proj.location.x + Projectile.MAX_EXPLOSION_WIDTH / 2, proj.location.y - Projectile.MAX_EXPLOSION_WIDTH / 2));
				mountains.insert(insertAt + 3, new Point(proj.location.x + Projectile.MAX_EXPLOSION_WIDTH, proj.location.y));
				
				// Check for any tanks in that range.
				for (tank in tanks) {
					if (proj.location.x - Projectile.MAX_EXPLOSION_WIDTH < tank.location.x && proj.location.x + Projectile.MAX_EXPLOSION_WIDTH > tank.location.x) {
						tank.falling = true;
					}
				}
			}
			
			// Check if we can remove any tanks
			else {
				var offset : Point;
				var distance : Float;
				
				for (tank in tanks) {
					offset = tank.location.subtract(proj.location);
					distance = Math.sqrt(offset.x * offset.x + offset.y * offset.y);
					
					if (distance - Tank.TANK_WIDTH < proj.explodingFrame) {
						tanksToRemove.push(tank);
					}
				}
			}
		}
		
		// Remove things (whee!)
		for (proj in projsToRemove) projectiles.remove(proj);
		for (tank in tanksToRemove) tanks.remove(tank);
		
		// Check if we can advance the player counter
		// There has to be no projectiles and no falling tanks
		// TODO: Known bug, if the next tank in line is removed, strange things happen
		if (!waiting && projectiles.length == 0 && !Lambda.exists(tanks, function(t) { return t.falling; } )) {
			currentTank += 1;
			if (currentTank >= tanks.length) {
				currentTank = 0;
			}
			waiting = true;
			
			// Check for a winner
			if (tanks.length == 1) {
				winner = tanks[0];
			} else if (tanks.length == 0) {
				winner = new Tank(this, new Point(0, 0), 0x000000);
			}
			
			trace("DEBUG: Current tank advanced to " + currentTank);
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
		
		// Display for winnders!
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
			//g.lineStyle(1, 0xFFFFFF);
			//g.beginFill(proj.tank.color);
			g.beginGradientFill(GradientType.RADIAL, [0xFFFFFF, proj.tank.color], [1, 1], [0, 255]);
			if (proj.explodingFrame < 0) {
				g.drawCircle(proj.location.x, height - proj.location.y, Projectile.PROJECTILE_WIDTH);
			} else {
				g.drawCircle(proj.location.x, height - proj.location.y, Projectile.PROJECTILE_WIDTH + proj.explodingFrame);
			}
			g.endFill();
		}
		
		// We have a winner!
		if (winner != null) {
			var winMessage = new TextField();
			winMessage.backgroundColor = 0x000000;
			winMessage.x = Lib.current.width / 2;
			winMessage.y = Lib.current.height / 2;
			Lib.current.addChild(winMessage);
			
			angleDisplay.text = "";
			powerDisplay.text = "";
			
			if (winner.color == 0x000000) {
				winMessage.textColor = 0xFF0000;
				winMessage.text = "FAIL! You all lose.\nGame over";
			} else {
				winMessage.textColor = winner.color;
				winMessage.text = "Yay! You win!\nGame over";
			}
		}
	}
}