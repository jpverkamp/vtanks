package com.jverkamp.games.vtanks;

import nme.display.Graphics;
import nme.display.Sprite;
import nme.geom.Point;

class World {
	var width : Int;
	var height : Int;
	
	var g : Graphics;
	var mountains : Array<Point>;
	var tanks : Array<Tank>;

	public function new(g : Graphics, width : Int, height : Int) {
		this.g = g;
		this.width = width;
		this.height = height;
		
		generateMountains();
		addTanks();
		
		draw();
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
			
			if (y < 0) {
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
			
			var r : Int = Std.random(8) * 16 + 128;
			var g : Int = Std.random(8) * 16 + 128;
			var b : Int = Std.random(8) * 16 + 128;
			var rgb : Int = (r << 16) | (g << 8) | b;
			
			tanks.push(new Tank(new Point(x, y), rgb));
		}
	}
	
	public function draw() {
		g.clear();
		
		// Mountains
		g.lineStyle(2, 0xFFFFFF);
		g.moveTo(mountains[0].x, height - mountains[0].y);
		for (i in 1...mountains.length) {
			g.lineTo(mountains[i].x, height - mountains[i].y);
		}
		
		// Tanks
		for (tank in tanks) {
			g.lineStyle(2, tank.color);
			g.moveTo(tank.location.x - Tank.TANK_WIDTH / 2, height - tank.location.y);
			g.lineTo(tank.location.x - Tank.TANK_WIDTH / 2 + Tank.TANK_WIDTH / 4, height - tank.location.y - Tank.TANK_WIDTH / 2);
			g.lineTo(tank.location.x + Tank.TANK_WIDTH / 4, height - tank.location.y - Tank.TANK_WIDTH / 2);
			g.lineTo(tank.location.x + Tank.TANK_WIDTH / 2, height - tank.location.y);
			g.lineTo(tank.location.x - Tank.TANK_WIDTH / 2, height - tank.location.y);
		}
	}
}