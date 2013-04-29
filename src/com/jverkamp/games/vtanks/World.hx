package com.jverkamp.games.vtanks;

import nme.display.Graphics;
import nme.display.Sprite;
import nme.geom.Point;
import nme.text.TextField;
import nme.Lib;

class World {
	var width : Int;
	var height : Int;
	
	var g : Graphics;
	var mountains : Array<Point>;
	var tanks : Array<Tank>;
	
	var currentTank : Tank;
	
	var angleDisplay : TextField;
	var powerDisplay : TextField;

	public function new(width : Int, height : Int) {
		this.width = width;
		this.height = height;
		
		generateMountains();
		addTanks();
		
		angleDisplay = new TextField();
		angleDisplay.width = 100;
		angleDisplay.x = 12;
		angleDisplay.y = 24;
		Lib.current.addChild(angleDisplay);
		
		powerDisplay = new TextField();
		powerDisplay.width = 100;
		powerDisplay.x = 12;
		powerDisplay.y = 36;
		Lib.current.addChild(powerDisplay);
	}
	
	function generateMountains(numberOfPeaks : Int = 10) {
		mountains = new Array<Point>();
		mountains.push(new Point(0, 0));
		
		var points = 10;
		var offset = width / numberOfPeaks;
		
		for (i in 0...numberOfPeaks) {
			var x : Float = i * offset - offset / 2 + Std.random(Std.int(offset));
			var y : Float = Std.random(height);
			
			//trace("DEBUG: placing a moutain at " + x + ", " + y);
			
			mountains.push(new Point(x, y));
		}
		
		mountains.push(new Point(width, 0));
	}
	
	function addTanks(numberOfTanks : Int = 4) {
		tanks = new Array<Tank>();
		
		while (tanks.length < numberOfTanks) {
			var x : Float = Std.random(width - Tank.TANK_WIDTH) + Tank.TANK_WIDTH / 2;
			var y : Float = -1;
			
			var j = 0;
			for (k in 0...mountains.length - 1) {
				j = k; // wow this is ugly. :)
				if (mountains[j].x <= x - Tank.TANK_WIDTH / 2 && mountains[j + 1].x >= x + Tank.TANK_WIDTH / 2) {
					var minY = Math.min(mountains[j].y, mountains[j + 1].y);
					var maxY = Math.min(mountains[j].y, mountains[j + 1].y);
					y = minY + Std.random(Std.int(maxY - minY));
					break;
				}
			}
			
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
			
			mountains.insert(j + 1, new Point(x - Tank.TANK_WIDTH / 2, y));
			mountains.insert(j + 2, new Point(x + Tank.TANK_WIDTH / 2, y));
			
			var rgb : Int = 0x000000;
			while (true) {
				var r : Int = Std.int(Math.min(255, Std.random(3) * 128));
				var g : Int = Std.int(Math.min(255, Std.random(3) * 128));
				var b : Int = Std.int(Math.min(255, Std.random(3) * 128));
				rgb = (r << 16) | (g << 8) | b;
				
				// Have to be at least a bit bright
				if (r + g + b < 255)
					continue;

				// Can't match a previous color
				var matching = false;
				for (tank in tanks)
					if (tank.color == rgb)
						matching = true;
				if (matching)
					continue;

				break;
			}
			tanks.push(new Tank(this, new Point(x, y), rgb));
		}
		
		currentTank = tanks[0];
	}
	
	public function isCurrent(tank : Tank) : Bool {
		return tank == currentTank;
	}
	
	public function update(ms : Int) {
		for (tank in tanks) {
			tank.update(ms);
		}
	}
	
	public function draw(g : Graphics) {
		g.clear();
		
		// Mountains
		g.lineStyle(2, 0xFFFFFF);
		g.moveTo(mountains[0].x, height - mountains[0].y);
		for (i in 1...mountains.length) {
			g.lineTo(mountains[i].x, height - mountains[i].y);
		}
		
		// Tanks
		for (tank in tanks) {
			var tip = tank.getTurrent();
			
			g.lineStyle(2, tank.color);
			
			/*
			 *    D (tip)
			 *     \
			 *   B--C--E
			 *  / tank  \
			 * A---------F 
			 */
			
			/* A */ g.moveTo(tank.location.x - Tank.TANK_WIDTH / 2, height - tank.location.y);
			/* B */ g.lineTo(tank.location.x - Tank.TANK_WIDTH / 2 + Tank.TANK_WIDTH / 4, height - tank.location.y - Tank.TANK_WIDTH / 2);
			/* C */ g.lineTo(tank.location.x, height - tank.location.y - Tank.TANK_WIDTH / 2);
			/* D */ g.lineTo(tip.x, height - tip.y);
			/* C */ g.lineTo(tank.location.x, height - tank.location.y - Tank.TANK_WIDTH / 2);
			/* E */ g.lineTo(tank.location.x + Tank.TANK_WIDTH / 4, height - tank.location.y - Tank.TANK_WIDTH / 2);
			/* F */ g.lineTo(tank.location.x + Tank.TANK_WIDTH / 2, height - tank.location.y);
			/* A */ g.lineTo(tank.location.x - Tank.TANK_WIDTH / 2, height - tank.location.y);
			
			// Update current angle and power
			if (isCurrent(tank)) {
				var angleInDegrees = (tank.angle - Math.PI / 2) * 360 / (2 * Math.PI);
				if (angleInDegrees > 180) angleInDegrees -= 360;
				
				angleDisplay.textColor = tank.color;
				angleDisplay.text = "Angle: " + (Math.round(-1 * angleInDegrees * 100) / 100);
				
				powerDisplay.textColor = tank.color;
				powerDisplay.text = "Power: " + (Math.round(tank.power * 100) / 100);
			}
		}
	}
}