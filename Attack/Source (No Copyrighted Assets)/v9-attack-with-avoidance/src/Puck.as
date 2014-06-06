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
		
		public function Puck() {
			super(FlxG.width / 2, FlxG.height / 2, Assets.PUCK);
			
			elasticity = 1;
			drag.x = 5;
			drag.y = 5;
			
			mImmuneTime = 0;
			gotoRinkCenter();
		}
		
		public function setOwner(theOwner :Athlete) :void {
			if (mOwner != theOwner && (mImmuneTime <= 0 || theOwner != mOldOwner)) {
				mOldOwner = mOwner;
				mOwner = theOwner;
				velocity.x = 0;
				velocity.y = 0;
				
				if (theOwner == null) {
					mImmuneTime = Constants.PUCK_IMMUNE_TIME;
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
				(FlxG.state as PlayState).puckTouchedGoal(null, null);
			}
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
		}
		
		public function gotoRinkCenter() :void {
			var aRandomY :Number = FlxG.random() * 50 * (FlxG.random() <= 0.5 ? 1 : -1);
			var aRandomX :Number = 0;
			
			reset(FlxG.width / 2 + aRandomX, FlxG.height / 2 - 20 + aRandomY);
			setOwner(null);
		}
		
		public function get owner() :Athlete { return mOwner; }
	}
}