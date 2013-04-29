package com.jverkamp.games.vtanks;
import nme.geom.Point;

class Tank {
	public static var TANK_WIDTH = 16;
	
	public var location : Point;
	public var color : Int;
	
	public var angle : Float;
	public var power : Int;
	
	public function new(location : Point, color : Int) {
		this.location = location;
		this.color = color;
		this.angle = 0.5 * Math.PI;
		this.power = 50;
	}
	
	public function getTurrent() : Point {
		return new Point(
			location.x + Math.cos(angle) * TANK_WIDTH / 2,
			location.y + TANK_WIDTH / 2 + Math.sin(angle) * TANK_WIDTH / 2
		);
	}
}