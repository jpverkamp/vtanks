package com.jverkamp.games.vtanks;
import nme.geom.Point;

/**
 * Flying bits of firey doom.
 */
class Projectile {
	public static var PROJECTILE_WIDTH = 2.0;
	public static var GRAVITY = 9.81;
	public static var POWER_MULTIPLIER = 10.0;
	
	public var world : World;
	public var tank : Tank;
	public var location : Point;
	public var velocity : Point;
	
	/**
	 * Create a projectile.
	 * @param	init The initial point (tip of the gun)
	 * @param	angle The firing angle with 0 to the right and positive going counterclockwise
	 * @param	power A power rating in the range [0, 100]
	 */
	public function new(world : World, tank: Tank, init : Point, angle : Float, power : Float) {
		this.world = world;
		this.tank = tank;
		this.location = init;
		this.velocity = new Point(
			POWER_MULTIPLIER * power * Math.cos(angle),
			POWER_MULTIPLIER * power * Math.sin(angle)
		);
		// TODO: Check this math
	}
	
	/**
	 * Update this projectile.
	 * 
	 * @param	msSinceLastFrame How long it's been since the last update
	 */
	public function update(msSinceLastFrame : Int) {
		this.velocity.y -= GRAVITY;
		this.location.x += msSinceLastFrame / 1000.0 * this.velocity.x;
		this.location.y += msSinceLastFrame / 1000.0 * this.velocity.y;
	}
}