/**
 * Copyright (c) 2014, Fernando Bevilacqua
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * 
 *   Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 *   Redistributions in binary form must reproduce the above copyright notice, this
 *   list of conditions and the following disclaimer in the documentation and/or
 *   other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package  
{
	import flash.geom.Vector3D;
	import org.flixel.*;
	
	public class Puck extends FlxSprite
	{
		private var mOwner :Athlete;		// the athlete currently carring the puck.
		private var mOldOwner :Athlete; 	// last athlete to own the puck.
		private var mImmuneTime :Number; 	// used to "immunize" the puck against the current athlete: if he releases the puck, he cannot get the puck for the next mImmuneTime seconds.
		private var mMark :FlxSprite;
		private var mBoid :Boid;
		private var mRinkCenter :FlxPoint;	// where the puck understands as the rink center
		
		private var mFearCounter :Number;	// used when the "Fear the puck" power-up is active
		private var mFearMark :FlxSprite;	// used when the "Fear the puck" power-up is active

		
		public function Puck() {
			super(FlxG.width / 2, FlxG.height / 2, Assets.PUCK);
			
			elasticity = 1;
			drag.x = 5;
			drag.y = 5;
			
			mMark = new FlxSprite(0, 0, Assets.PUCK_MARK);
			mMark.angularVelocity = 80;
			mMark.color = 0xFF26FF;	
			
			mRinkCenter = new FlxPoint(Constants.WORLD_WIDTH / 2 - 3, Constants.WORLD_HEIGHT / 2 - 3);
			
			mBoid = new Boid(0, 0, 10);
			
			initPowerUpStuff();
			
			mImmuneTime = 0;
			gotoRinkCenter();
		}
		
		private function initPowerUpStuff() :void {
			mFearCounter = 0;
			mFearMark = new FlxSprite(0, 0, Assets.POWERUP_FEAR_OF_PUCK);
		}
		
		public function makeFearable(theDuration :Number, theColor :uint) :void {
			mFearCounter 		= theDuration;
			
			mFearMark.color 	= theColor;
			mFearMark.scale.x 	= 1.3;
			mFearMark.scale.y 	= 1.3;
			mFearMark.alpha 	= 0.2;
		}
		
		private function isMatchRunning() :Boolean {
			return (FlxG.state as PlayState).matchRunning;
		}
		
		public function setOwner(theOwner :Athlete) :void {
			if (isMatchRunning() && mOwner != theOwner && (mImmuneTime <= 0 || theOwner != mOldOwner)) {
				mOldOwner = mOwner;
				mOwner = theOwner;
				velocity.x = 0;
				velocity.y = 0;
				
				if (theOwner == null) {
					mImmuneTime = Constants.PUCK_IMMUNE_TIME;
					
				} else {
					var aPlaystate :PlayState = FlxG.state as PlayState;

					// If the athlete belongs to the player's team, let's immediately mark him
					// as player-controlled.
					
					if (theOwner.team == aPlaystate.playerTeam && aPlaystate.allowHumans) {
						aPlaystate.selectAnotherAthlete(aPlaystate.playerTeam, theOwner);
					}
				}
			}
		}
		
		private function placeAheadOfOwner() :void {
			var ahead :Vector3D = mOwner.boid.velocity.clone();
			
			ahead.normalize();
			ahead.scaleBy(30);
			
			x = mOwner.boid.position.x + mOwner.width / 2 + ahead.x;
			y = mOwner.boid.position.y + mOwner.height / 2 + ahead.y;
		}
		
		private function updatePowerUpStuff() :void {
			if (mFearCounter > 0) {
				// "Fear the Puck" power-up is active. We must count its duration
				mFearCounter -= FlxG.elapsed;
				
				// Place the fear mark under the puck
				mFearMark.x = x - mFearMark.width / 2 + width / 2;
				mFearMark.y = y - mFearMark.height / 2 + height / 2;
			}
		}
		
		override public function update():void {
			if (mOwner != null) {
				placeAheadOfOwner();
			}
			
			if (mImmuneTime > 0) {
				mImmuneTime -= FlxG.elapsed;
			}
			
			super.update();			
			
			if (!onScreen()) {
				gotoRinkCenter();
			}
			
			mMark.postUpdate();
			updatePowerUpStuff();
			
			// Update steering behavior stuff based on
			// Flixel properties.
			mBoid.position.x = x;
			mBoid.position.y = y;
			mBoid.velocity.x = velocity.x;
			mBoid.velocity.y = velocity.y;
			
			// If the match is not running but the puck is moving, it must go
			// to the rink center and stop there.
			if (!isMatchRunning()) {
				if (amIMoving() && Utils.distance(this, mRinkCenter) <= 30) {
					stopAtRinkCenter();
				}
			}
		}
		
		private function amIMoving() :Boolean {
			return Math.abs(velocity.x) >= 0.0001 || Math.abs(velocity.y) >= 0.0001;
		}
		
		override public function draw():void 
		{
			if (mFearCounter > 0) {
				mFearMark.draw();
			}
			
			mMark.x = x - mMark.width / 2 + width / 2;
			mMark.y = y - mMark.height / 2 + height / 2;
			
			mMark.draw();
			
			super.draw();
		}
		
		/**
		 * Make the puck travel from one place to another.
		 * 
		 * @param	theAthlete the entity representing where the journey begins.
		 * @param	theDestination the place where the puck should go. The puck will travel following the vector that goes from theAthlete to theDestination. The param theDestination must have a "x" and a "y" property.
		 * @param	theSpeed how fast the puck should move.
		 */
		public function goFromStickHit(theAthlete :Athlete, theDestination :*, theSpeed :Number = 160) :void {
			// If the puck was hit by someone who doesn't own the puck, we ignore the hit.
			// Or if the match is not running
			if (theAthlete != mOwner) return;
			
			// Place the puck ahead of the owner to prevent unexpected trajectories (e.g. puck colliding the athlete that just hit it)
			placeAheadOfOwner();
			
			// Mark the puck as free (no owner)
			setOwner(null);
			
			// Calculate the vector the puck should follow.
			velocity.x = theDestination.x - x;
			velocity.y = theDestination.y - y;
			
			Utils.normalize(velocity);

			velocity.x *= theSpeed;
			velocity.y *= theSpeed;
			
			if ((FlxG.state as PlayState).hud.isSoundActive()) {
				FlxG.play(Assets.SFX_PUCK_HIT);	
			}
		}
		
		public function gotoRinkCenter() :void {
			stopAtRinkCenter();
			setOwner(null);
			visible = true;
		}
		
		public function stopAtRinkCenter() :void {
			velocity.x = 0;
			velocity.y = 0;
			x = mRinkCenter.x;
			y = mRinkCenter.y;
		}
		
		public function smoothlyMoveTowardsRinkCenter() :void {
			velocity.x = mRinkCenter.x - x;
			velocity.y = mRinkCenter.y - y;
			
			velocity.x *= 0.3;
			velocity.y *= 0.3;
		}
		
		public function get owner() :Athlete { return mOwner; }
		public function get boid() :Boid { return mBoid; }
	}
}