package com.jverkamp.games.vtanks;
import nme.geom.Point;

class Tank {
	public static var TANK_WIDTH = 16;
	
	public var location : Point;
	public var color : Int;
	
	public function new(location : Point, color : Int) {
		this.location = location;
		this.color = color;
	}
	
}