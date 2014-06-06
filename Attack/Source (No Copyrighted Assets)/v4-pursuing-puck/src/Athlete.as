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
		private var mControlledByAI		:Boolean;	// true if the athlete is controlled by the AI alone, or false if the player is in control
		private var mTeam				:FlxGroup;	// a reference to the team the athlete belongs to.
		private var mLabel				:FlxText;	// debug: text above the athlete to show what is going on with the AI.
		private var mInitialPosition	:Vector3D;	// the position in the rink where the athlete should be placed
		private var mBrain				:StackFSM;	// controls the AI stuff
		private var mStandStill			:Boolean;	// make the athlete stand still (it's easier to test the AI).
		
		public function Athlete(thePosX :Number, thePosY :Number, theTotalMass :Number, theTeam :FlxGroup, theStandStill :Boolean = false) {
			super(thePosX, thePosY);
			
			mInitialPosition	= new Vector3D(thePosX - 7, thePosY);
			mId 				= mIds++;
			mControlledByAI 	= true;
			mMouse				= new Vector3D();
			mBoid 				= new Boid(mInitialPosition.x, mInitialPosition.y, theTotalMass);
			mLabel				= new FlxText(0, 0, 100);
			mTeam				= theTeam;
			mBrain				= new StackFSM();
			mStandStill			= theStandStill;
			

			// Tell the brain the current state is 'idle'
			mBrain.pushState(idle);
			mBoid.velocity.scaleBy(0.2);			
			
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
		
		/**
		 * The "pursuePuck" state. During this state the athlete will try to
		 * seek the puck if it is close. If the puck is too far away, the
		 * athlete will give up pursuing and will switch to 'idle'.
		 */
		private function pursuePuck() :void {
			var aPuck :Puck = getPuck();
			
			mBoid.steering = mBoid.steering.add(mBoid.separation(70));
			
			if (Utils.distance(this, aPuck) > 300) {
				// Puck is too far away from our current position, so let's give up
				// pursuing the puck and hope someone will be closer to get the puck
				// for us.
				mBrain.popState();
				mBrain.pushState(idle);
			} else {
				// The puck is close, let's try to grab it.
				if (aPuck.owner == null) {
					// Nobody has the puck, it's our chance to seek and get it!
					mBoid.steering = mBoid.steering.add(mBoid.seek(new Vector3D(aPuck.x, aPuck.y)));
				
				} else {
					// Someone just got the puck. If the new puck owner belongs to my team,
					// we should switch to 'attack', otherwise I should switch to 'stealPuck'
					// and try to get the puck back.
					mBrain.popState();
					mBrain.pushState(doesMyTeamHasThePuck() ? attack : stealPuck);
				}
			}
		}
		
		/**
		 * The 'attack' state. During this state the athlete will try to reach the opponents
		 * goal, passing the puck to another teammate in the event of any opponent tries to
		 * steal it.
		 */
		private function attack() :void {
			// Empty state. For now just pop itself from the brain
			// if the puck has no owner.
			
			if(doesMyTeamHasThePuck() == false) {
				mBrain.popState();
				mBrain.pushState(idle);
			}
		}
		
		/**
		 * The 'stealPuck' state. During this state the athlete will seek the
		 * opponent with the puck, trying to steal it.
		 */
		private function stealPuck() :void {
			// This state is not implemented yet. For now, just pop itself
			// from the brain.
			mBrain.popState();
			mBrain.pushState(idle);
		}
		
		/**
		 * The 'idle' state. The athlete will stand still and stare at the puck
		 * while the puck has no owner. The state ends when someone gets the puck
		 * or the puck passes by (in that case we switch to 'pursuePuck').
		 */
		private function idle() :void {
			var aPuck :Puck = getPuck();
			
			stopAndlookAt(aPuck);
			
			// This is a hack to help test the AI.
			if (mStandStill) return;
			
			// Does the puck has an owner?
			if (getPuckOwner() != null) {
				// Yeah, it has.
				mBrain.popState();
				
				if (doesMyTeamHasThePuck()) {
					// My team just got the puck, it's attack time!
					mBrain.pushState(attack);
				} else {
					// The opponent team got the puck, let's try to steal it.
					mBrain.pushState(stealPuck);
				}
			} else if (Utils.distance(this, aPuck) < 150) {
				// The puck has no owner and it is nearby. Let's pursue it.
				mBrain.popState();
				mBrain.pushState(pursuePuck);
			}
		}
		
		/**
		 * The 'prepareForMatch' state. When this state is active the athlete will
		 * move towards his initial position, arriving there smoothly.
		 */
		private function prepareForMatch() :void {
			mBoid.steering = mBoid.arrive(mInitialPosition, 80);
			
			// Am I at the initial position?
			if (Utils.distance(mBoid.position, mInitialPosition) <= 5) {
				mBrain.popState();
				mBrain.pushState(idle);
			}
		}
		
		/**
		 * Tell the athlete to return to his intial position. It is done by
		 * removing all stacked states and pushin the 'prepareForMatch' state.
		 */
		public function returnToInitialPosition() :void {
			mBrain.stack.splice(0);
			mBrain.pushState(prepareForMatch);
			setControlledByPlayer(false);
		}
		
		/**
		 * Make the athlete stop moving and stare at the informed point.
		 * 
		 * @param	thePoint anything with a "x" and "y" property.
		 */
		private function stopAndlookAt(thePoint :*) :void {
			mBoid.velocity.x = thePoint.x - mBoid.position.x;
			mBoid.velocity.y = thePoint.y - mBoid.position.y;
			
			mBoid.velocity.normalize();
			mBoid.velocity.scaleBy(0.01);
		}
		
		override public function update():void {
			super.update();
			
			// Clear all steering forces
			mBoid.steering.scaleBy(0);
			
			if (flickering) {
				mBoid.velocity.scaleBy(0.1);
			}

			if (mControlledByAI) {
				// The athlete is controlled by the AI. Update the brain (FSM) and
				// stay away from rink walls.
				mBrain.update();
				stayAwayFromRinkWalls();
				
			} else {
				// The athlete is controlled by the player, so just follow
				// the mouse cursor.
				followMouseCursor();
			}
	
			// Update all steering stuff
			mBoid.update();
			
			// Update the Flixel sprite with boid info
			x = mBoid.x;
			y = mBoid.y;
			angle = mBoid.rotation;
		}
		
		private function followMouseCursor() :void {
			mMouse.x = FlxG.mouse.x;
			mMouse.y = FlxG.mouse.y;
			mBoid.steering = mBoid.steering.add(boid.arrive(mMouse, 50));
		}
		
		private function stayAwayFromRinkWalls() :void {
			mBoid.steering = mBoid.steering.add(mBoid.collisionAvoidance((FlxG.state as PlayState).rink.members, 40, 30, 1.5, Rect));
		}
		
		override public function draw():void {
			var aShowDebugAI :Boolean = (FlxG.state as PlayState).showDebugAI;
			var aState :String = "";
			
			_flicker = true; // Remove this line to make athlete flicker when the puck is lost.
			super.draw();
			
			mLabel.x = x - 8;
			mLabel.y = y - 15;
			mLabel.text = mControlledByAI ? "" : "YOU";
			mLabel.color = 0x11ff00;
			mLabel.shadow = 0xff000000;
			
			if (mControlledByAI && aShowDebugAI) {
				if (mBrain.getCurrentState() == idle) { aState = "idle"; mLabel.color = 0xFF00C3; }
				if (mBrain.getCurrentState() == attack) { aState = "attack";  mLabel.color = 0xFF0000; }
				if (mBrain.getCurrentState() == stealPuck) { aState = "stealPuck"; mLabel.color = 0x223824; }
				if (mBrain.getCurrentState() == pursuePuck) { aState = "pursuePuck"; mLabel.color = 0x8587FF; }
				if (mBrain.getCurrentState() == prepareForMatch) { aState = "prepare";  mLabel.color = 0x000000; }
				
				mLabel.text = "AI (" + aState + ")";
				mLabel.shadow = 0;
			}
			
			mLabel.draw();
		}
		
		public function setControlledByPlayer(theStatus :Boolean) :void {
			mControlledByAI = !theStatus;
		}
		
		public function isControlledByPlayer() :Boolean {
			return !mControlledByAI;
		}
		
		public function doesMyTeamHasThePuck() :Boolean {
			return getPuckOwner() != null && getPuckOwner().team == mTeam;
		}
		
		private function getPuckOwner() :Athlete {
			return (FlxG.state as PlayState).puck.owner;
		}

		private function getPuck() :Puck {
			return (FlxG.state as PlayState).puck;
		}
		
		private function getTeamLeader(theTeam :FlxGroup) :Athlete {
			var aLength :int = theTeam.members.length;
			var aPuckOwner :Athlete = getPuckOwner();
			var aLeader :Athlete;
			var aAthlete :Athlete;
			
			if(aPuckOwner != null) {
				for (var i:int = 0; i < aLength; i++) {
					aAthlete = theTeam.members[i];
					
					if (aAthlete != null && aAthlete == aPuckOwner) {
						aLeader = aAthlete;
						break;
					}
				}
			}
			
			return aLeader;
		}
		
		public function getOpponentTeam() :FlxGroup {
			var aPlayState :PlayState = FlxG.state as PlayState;
			return mTeam == aPlayState.leftTeam ? aPlayState.rightTeam : aPlayState.leftTeam;
		}
		
		public function getOpponentGoalPosition() :Vector3D {
			var aPosition :Vector3D;
			var aPlayState :PlayState = FlxG.state as PlayState;
			
			if (mTeam == aPlayState.leftTeam) {
				aPosition = new Vector3D(aPlayState.rightGoal.x, aPlayState.rightGoal.y);
			} else {
				aPosition = new Vector3D(aPlayState.leftGoal.x, aPlayState.leftGoal.y);
			}
			
			return aPosition;
		}
		
		public function get boid() :Boid { return mBoid; }
		public function get id() :int { return mId; }
		public function get team() :FlxGroup { return mTeam; }
		public function get standStill() :Boolean { return mStandStill; }
	}
}