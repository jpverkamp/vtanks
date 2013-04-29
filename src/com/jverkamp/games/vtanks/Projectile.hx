package com.jverkamp.games.vtanks;
import nme.geom.Point;

class Projectile {
	var location : Point;
	var velocity : Point;
	
	public function new(init : Point, angle : Float, power : Int) {
		location = init;
		velocity = new Point(
			power * Math.cos(angle),
			power * Math.sin(angle),
		);
	}
}