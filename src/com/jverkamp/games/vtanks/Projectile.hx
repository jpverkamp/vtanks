package com.jverkamp.games.vtanks;
import nme.geom.Point;

/**
 * Flying bits of firey doom.
 */
class Projectile {
	var world : World;
	var tank : Tank;
	var location : Point;
	var velocity : Point;
	
	/**
	 * Create a projectile.
	 * @param	init The initial point (tip of the gun)
	 * @param	angle The firing angle with 0 to the right and positive going counterclockwise
	 * @param	power A power rating in the range [0, 100]
	 */
	public function new(world : World, tank: Tank, init : Point, angle : Float, power : Int) {
		this.world = world;
		this.tank = tank;
		this.location = init;
		this.velocity = new Point(
			power * Math.cos(angle),
			power * Math.sin(angle),
		);
		// TODO: Check this math
	}
	
	/**
	 * Update this projectile.
	 * 
	 * @param	msSinceLastFrame How long it's been since the last update
	 */
	public function update() {
		
	}
}