package com.jverkamp.games.vtanks;

import nme.display.Graphics;
import nme.display.Sprite;
import nme.geom.Point;

class World {
	
	var g : Graphics;
	var mountains : Array<Point>;

	public function new(g : Graphics, width : Int, height : Int) {
		this.g = g;
		
		mountains = new Array<Point>();
		mountains.push(new Point(0, height));
		
		var points = 10;
		var offset = width / points;
		
		for (i in 0...points) {
			mountains.push(new Point(
				i * offset - offset / 2 + Std.random(Std.int(offset)), 
				Std.random(height)
			));
		}
		
		mountains.push(new Point(width, height));
		
		draw();
	}
	
	public function draw() {
		g.clear();
		
		g.lineStyle(2, 0xFFFFFF);
		g.moveTo(mountains[0].x, mountains[0].y);
		for (i in 1...mountains.length) {
			g.lineTo(mountains[i].x, mountains[i].y);
		}
	}
}