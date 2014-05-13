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

 
 /**
  * This class describes an athlete in the rink. An athlete is able to think
  * using a stack-based FSM (http://gamedevelopment.tutsplus.com/tutorials/finite-state-machines-theory-and-implementation--gamedev-11867).
  * An athlete is also able to move using steering behaviors.
  */
package  
{
	import flash.geom.Vector3D;
	import org.flixel.*;
	
	public class Athlete extends FlxSprite
	{
		private static var mIds	:int = 0;
		
		private var mBoid 				:Boid;		// controls the steering behavior stuff
		private var mMouse 				:Vector3D;	// a cache to store the mouse cursor position
		private var mId					:int;		// a unique identifier for the athelete
		private var mTeam				:FlxGroup;	// a reference to the team the athlete belongs to.
		private var mLabel				:FlxText;	// debug: text above the athlete to show what is going on with the AI.
		private var mInitialPosition	:Vector3D;	// the position in the rink where the athlete should be placed
		
		public function Athlete(thePosX :Number, thePosY :Number, theTotalMass :Number, theTeam :FlxGroup) {
			super(thePosX, thePosY);
			
			mInitialPosition	= new Vector3D(thePosX - 7, thePosY);
			mId 				= mIds++;
			mMouse				= new Vector3D();
			mBoid 				= new Boid(mInitialPosition.x, mInitialPosition.y, theTotalMass);
			mLabel				= new FlxText(0, 0, 100);
			mTeam				= theTeam;
			
			// Init Flixel graphical things
			initGraphicalStuff();
		}
		
		private function initGraphicalStuff() :void {
			loadGraphic(mTeam == (FlxG.state as PlayState).leftTeam ? Assets.ATHLETE_YELLOW : Assets.ATHLETE_RED, true, false, 42, 70, true);
			
			width = 15;
			height = 30;
			offset.x = 10;
			offset.y = 17;
			
			addAnimation("moving", [1, 2], 5);
			play("moving");
		}

		override public function update():void {
			super.update();
			
			// Clear all steering forces
			mBoid.steering.scaleBy(0);
			
			// Wander around
			wanderInTheRink();
	
			// Update all steering stuff
			mBoid.update();
			
			// Update the Flixel sprite with boid info
			x = mBoid.x;
			y = mBoid.y;
			angle = mBoid.rotation;
		}
		
		private function wanderInTheRink() :void {
			var aRinkCenter :Vector3D = new Vector3D(FlxG.width / 2, FlxG.height / 2);
			
			// If the distance from the center is greater than 80,
			// move back to the center, otherwise keep wandering.
			if (Utils.distance(this, aRinkCenter) >= 80) {
				mBoid.steering = mBoid.steering.add(mBoid.seek(aRinkCenter));
			} else {
				mBoid.steering = mBoid.steering.add(mBoid.wander());
			}
		}
		
		public function get boid() :Boid { return mBoid; }
		public function get id() :int { return mId; }
		public function get team() :FlxGroup { return mTeam; }
	}
}