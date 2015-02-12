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
		
		private var mRespawnCounter		:Number;	// counts the time the athlete should wait until respawn.
		private var mFearCounter		:Number;	// counts the time the athlete should evade from puck (when fear powerup is active).
		private var mGhost				:Boolean;	// tells if the athlete is a ghost (a powerup that adds new athletes to help steal the puck).
		private var mGhostCounter		:Number;	// counts the time a ghost will remain active
		
		public function Athlete(thePosX :Number, thePosY :Number, theTotalMass :Number, theTeam :FlxGroup) {
			super(thePosX, thePosY);
			
			mInitialPosition	= new Vector3D(thePosX - 7, thePosY);
			mId 				= mIds++;
			mControlledByAI 	= true;
			mMouse				= new Vector3D();
			mBoid 				= new Boid(mInitialPosition.x, mInitialPosition.y, theTotalMass);
			mLabel				= new FlxText(0, 0, 100);
			mTeam				= theTeam;
			mBrain				= new StackFSM();
			mRespawnCounter		= 0;
			mFearCounter		= 0;		// powerup "Fear the puck"
			mGhost				= false;	// powerup "Ghost help"
			mGhostCounter		= 0;
			
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
			
			mBoid.steering = mBoid.steering.add(mBoid.separation(140));
			
			if (Utils.distance(this, aPuck) > 400) {
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
		
		private function passPuck() :void {
			var aTeammate :Athlete = getClosestAthleteFromPuck(mTeam, true);
			var aOpponent :Athlete = getClosestAthleteFromPuck(getOpponentTeam());
			var aTowardsTeammate :Vector3D;
			
			if(aTeammate != null) {
				aTowardsTeammate = mBoid.velocity.add(mBoid.position);
				getPuck().goFromStickHit(this, aTowardsTeammate);
				
				mBrain.popState();
			}
		}
		
		/**
		 * Checks if there are nearby opponents trying to steal the puck.
		 */
		private function anyOpponentsTryingToStealPuck() :Boolean {
			var aAhead :Vector3D;
			aAhead = mBoid.velocity.add(mBoid.position);
			aAhead.normalize();
			aAhead.scaleBy(30);
			
			var aCount :int = countAthletesWithinRadius(getOpponentTeam(), aAhead, 60);
			return aCount > 0;
		}
		
		/**
		 * Checks if someone is ahead of me by comparing our distances to the opponents goal.
		 * 
		 * @param	theBoid the athlete to be tested
		 * @return	true is theBoid is ahead of me or false otherwise.
		 */
		private function isAheadOfMe(theBoid :Boid) :Boolean {
			var aTargetDistance :Number = Utils.distance(getOpponentGoalPosition(), theBoid);
			var aMyDistance :Number = Utils.distance(getOpponentGoalPosition(), mBoid.position);
			
			return aTargetDistance <= aMyDistance;
		}
		
		/**
		 * The 'attack' state. During this state the athlete will try to reach the opponents
		 * goal, passing the puck to another teammate in the event of any opponent tries to
		 * steal it.
		 */
		private function attack() :void {
			var aPuckOwner :Athlete = getPuckOwner();
			
			// Does the puck has an owner?
			if (aPuckOwner != null) {
				// Yeah, it has. Let's find out if the owner belongs to the opponents team.
				if (doesMyTeamHasThePuck()) {
					if (amIThePuckOwner()) {
						// My team has the puck and I am the one who has it! Let's move
						// towards the opponent's goal, avoding any opponents along the way.
						// If any opponent tries to steal the puck, we pass it to a teammate.
						mBoid.steering = mBoid.steering.add(mBoid.seek(getOpponentGoalPosition()));
						mBoid.steering = mBoid.steering.add(mBoid.collisionAvoidance(getOpponentTeam().members, 40, 150, 3, Circle));
						
						if (anyOpponentsTryingToStealPuck()) {
							mBrain.pushState(passPuck);
						}						
					} else {
						// My team has the puck, but a teammate has it. Is he ahead of me?
						if (isAheadOfMe(aPuckOwner.boid)) {
							// Yeah, he is ahead of me. Let's just follow him to give some support
							// during the attack.
							mBoid.steering = mBoid.steering.add(mBoid.followLeader(aPuckOwner.boid));
							mBoid.steering = mBoid.steering.add(mBoid.separation(40, 2.0));
						} else {
							// Nope, the teammate with the puck is behind me. In that case
							// let's hold our current position with some separation from the
							// other, so we prevent crowding.
							mBoid.steering = mBoid.steering.add(mBoid.separation(60, 2.0));
						}
					}
				} else {
					// The opponent has the puck! Stop the attack
					// and try to steal it.
					mBrain.popState();
					mBrain.pushState(stealPuck);
				}
			} else {
				// Puck has no owner, so there is no point to keep
				// attacking. It's time to re-organize and start pursuing the puck.
				mBrain.popState();
				mBrain.pushState(pursuePuck);
			}
		}
		
		/**
		 * Checks if this athelete instance has the puck.
		 */
		private function amIThePuckOwner() :Boolean {
			var aPuckOwner :Athlete = getPuckOwner();
			return aPuckOwner == this;
		}
		
		/**
		 * A method that makes the athlete evade from puck.
		 */
		private function evadeFromPuck() :void {
			mBoid.steering = mBoid.steering.add(mBoid.evade(getPuck().boid));
		}
		
		/**
		 * The 'stealPuck' state. During this state the athlete will seek the
		 * opponent with the puck, trying to steal it.
		 */
		private function stealPuck() :void {
			// Does the puck has any owner?
			if (getPuckOwner() != null) {
				// Yeah, it has, but who has it?
				if (doesMyTeamHasThePuck()) {
					// My team has the puck, so it's time to stop trying to steal
					// the puck and start attacking.
					mBrain.popState();
					mBrain.pushState(attack);
				} else {
					// An opponent has the puck.
					var aOpponentLeader :Athlete = getPuckOwner();
										
					// Is the opponent with the puck close to me?
					if (Utils.distance(aOpponentLeader, this) < 200) {
						// Yeah, he is close! Let's pursue him while mantaining a certain
						// separation from the others to avoid that everybody will ocuppy the same
						// position in the pursuit.
						mBoid.steering = mBoid.steering.add(mBoid.pursuit(aOpponentLeader.boid));
						mBoid.steering = mBoid.steering.add(mBoid.separation(100));
						
					} else {
						// No, he is too far away. Let's switch to 'defend' and hope
						// someone closer to the puck can steal it for us.
						mBrain.popState();
						mBrain.pushState(defend);
					}
				}
			} else {
				// The puck has no owner, it is probably running freely in the rink.
				// There is no point to keep trying to steal it, so let's finish the 'stealPuck' state
				// and switch to 'pursuePuck'.
				mBrain.popState();
				mBrain.pushState(pursuePuck);
			}
		}
		
		/**
		 * The 'patrol' state. During this state the athlete will wander around his
		 * initial position in order to create a more realistic defense pattern. Eventually
		 * the athlete will wander too far from his initial position, so we switch
		 * to 'defend' that will bring the athlete back to its initial position.
		 */
		private function patrol() :void {
			mBoid.steering = mBoid.steering.add(mBoid.wander());
			
			// Am I too far away from my initial position?
			if (Utils.distance(mInitialPosition, this) > 120) {
				// Yeah, I am. It's time to stop patrolling and go back to
				// my initial position.
				mBrain.popState();
				mBrain.pushState(defend);
			}
		}
		
		/**
		 * The 'defend' state. During this state the athlete will try to return to
		 * his initial position. When we get there, we start wandering around to
		 * patrol the area. If the opponent with the puck passes by, we try to steal
		 * the puck from him.
		 */
		private function defend() :void {
			var aPuckOwner :Athlete = getPuckOwner();
			
			// Move towards the initial position, arriving there smoothly.
			mBoid.steering = mBoid.steering.add(mBoid.arrive(mInitialPosition, 50));
			
			// Am I close to my initial position and the puck has no owner?
			if (Utils.distance(mInitialPosition, this) <= 10 && aPuckOwner != null) {
				// Yeah, so it's time to patrol the area.
				mBrain.popState();
				mBrain.pushState(patrol);
			}
			
			// Does the puck has an owner?
			if (aPuckOwner != null) {
				// Yeah, it has. Who has it?
				if (doesMyTeamHasThePuck()) {
					// My team has the puck, time to stop defending and start attacking!
					mBrain.popState();
					mBrain.pushState(attack);
					
				} else if (Utils.distance(aPuckOwner, this) < 200) {
					// An opponent has the puck and he is close to us!
					// Let's try to steal the puck from him.
					mBrain.popState();
					mBrain.pushState(stealPuck);
				}
			} else {
				// No, the puck has no owner, it is running in the rink.
				// There is no point to keep defending the goal, because nobody has the puck.
				// Let's switch to 'pursuePuck' and try to get the puck to our team.
				mBrain.popState();
				mBrain.pushState(pursuePuck);
			}
		}
		
		/**
		 * The 'idle' state. The athlete will stand still and stare at the puck
		 * while the puck has no owner. The state ends when someone gets the puck
		 * or the puck passes by (in that case we switch to 'pursuePuck').
		 */
		private function idle() :void {
			var aPuck :Puck = getPuck();
			
			stopAndlookAt(aPuck);
			
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
			} else if (isMatchRunning() && Utils.distance(this, aPuck) < 200) {
				// The puck has no owner and it is nearby. Let's pursue it.
				mBrain.popState();
				mBrain.pushState(pursuePuck);
			}
		}
		
		private function isMatchRunning():Boolean {
			return (FlxG.state as PlayState).matchRunning;
		}
		
		/**
		 * The 'prepareForMatch' state. When this state is active the athlete will
		 * move towards his initial position, arriving there smoothly.
		 */
		private function prepareForMatch() :void {
			mBoid.steering = mBoid.arrive(mInitialPosition, 20);
			
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
		 * Adjusts everything to make the athlete follow the player
		 * input, e.g. follow the mouse cursor.
		 */
		private function updateAccordingPlayerInput():void {
			followMouseCursor();
			hightlightWithCrosshair();
			
			// If the player is holding SHIFT, it means we should
			// move faster
			if (FlxG.keys.SHIFT) {
				mBoid.velocity.scaleBy(Constants.ATHLETE_SPEED_BOOST);
			}
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
			
			if (!visible) {
				// If the athlete is not visible, it has been shattered.
				// No need to make any update but controlling the respawn time.
				controlRespawn();
				return;
			}
			
			// Clear all steering forces
			mBoid.steering.scaleBy(0);
			
			// Update powerup counters and stuff
			updatePowerups();
			
			if (mControlledByAI) {
				// The athlete is controlled by the AI. Update the brain (FSM) and
				// stay away from rink walls.
				mBrain.update();
				stayAwayFromRinkWalls();
				
			} else {
				// The athlete is controlled by the player, so just follow
				// the mouse cursor.
				updateAccordingPlayerInput();
			}
			
			// If the athlete is an AI-controlled opponent, slow it down
			// to make the game easier to play.
			if (amIAnAiControlledOpponent()) {
				mBoid.velocity.scaleBy(0.99);

				// Check if "fear powerup" is active. If that's true, evade from puck.
				if(shouldIEvadeFromPuck()) {
					evadeFromPuck();
				}
			}
			
			// Update all steering stuff
			mBoid.update();
			
			// Update the Flixel sprite with boid info
			x = mBoid.x;
			y = mBoid.y;
			angle = mBoid.rotation;
		}
		
		private function updatePowerups():void {
			if(mFearCounter > 0) {
				mFearCounter -= FlxG.elapsed;
			}
			
			// If the athlete is a ghost, it has a counter that controls
			// when it must be removed.
			if (amIAGhost()) {
				mGhostCounter -= FlxG.elapsed;
				
				if (mGhostCounter <= 2) {
					// Make athlete flicker when he is about to be removed.
					flicker(0.5);
				}
				
				if (mGhostCounter <= 0) {
					// Time to leave this world! (again)
					kill();
				}
			}
		}
		
		/**
		 * Make the athlete fear the puck, evading from it.
		 * 
		 * @param	theDuration How many seconds the athlete should fear the puck.
		 */
		public function fearPuck(theDuration: Number = 2) :void {
			mFearCounter = theDuration;
		}
		
		private function shouldIEvadeFromPuck() :Boolean {
			return mFearCounter > 0 && mBrain.getCurrentState() != idle && mBrain.getCurrentState() != prepareForMatch;
		}
		
		private function amIAnAiControlledOpponent():Boolean {
			return mControlledByAI && mTeam == (FlxG.state as PlayState).rightTeam;
		}
		
		private function hightlightWithCrosshair():void {
			var aPlayerMark :FlxSprite = (FlxG.state as PlayState).playerMark;
			
			aPlayerMark.visible = true;
			aPlayerMark.x = mBoid.position.x - aPlayerMark.width / 2 + width / 2;
			aPlayerMark.y = mBoid.position.y - aPlayerMark.height / 2 + height / 2;
		}
		
		private function controlRespawn():void {
			mRespawnCounter += FlxG.elapsed;

			if (mRespawnCounter >= Constants.ATHLETE_RESPAWN_TIME) {
				mBoid.position.x = Constants.WORLD_WIDTH / 2 + (150 - FlxG.random() * 300);
				mBoid.position.y = Constants.WORLD_HEIGHT - 50;
				
				visible = true;
				flicker(2);
			}
		}
		
		public function shatter():void {
			visible = false;
			mRespawnCounter = 0;
			
			mBoid.position.x = -30;
			mBoid.position.y = -30;
			
			if (amIAGhost()) {
				// If this athlete is a ghost (created by a powerup), there is
				// no respawn after shattering.
				kill();
			}
			
			// Emit shattering particles all over the place!
			(FlxG.state as PlayState).specialEffects.emitShatterPieces(x, y);
			FlxG.shake(0.005, 0.2);
			
			if((FlxG.state as PlayState).hud.isSoundActive()) {
				FlxG.play(Assets.SFX_EXPLOSION);
			}
		}
		
		override public function kill():void {
			var aIndex :int = Game.instance.boids.indexOf(this);

			// Remove athlete from the boids and the teams list
			if (aIndex > 0) {
				Game.instance.boids.splice(aIndex, 1);
				mTeam.remove(this);
			}
			
			// The athlete is the puck owner, tell the puck it has no
			// owner from now on, because this athlete will be removed
			if (getPuckOwner() == this) {
				getPuck().setOwner(null);
			}
			
			super.kill();
		}
		
		private function followMouseCursor() :void {
			mMouse.x = FlxG.mouse.x;
			mMouse.y = FlxG.mouse.y;
			mBoid.steering = mBoid.steering.add(boid.seek(mMouse));
		}
		
		private function stayAwayFromRinkWalls() :void {
			mBoid.steering = mBoid.steering.add(mBoid.collisionAvoidance((FlxG.state as PlayState).rink.members, 40, 30, 1.5, Rect));
		}
		
		override public function draw():void {
			var aShowDebugAI :Boolean = (FlxG.state as PlayState).showDebugAI;
			var aState :String = "";
			
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
				if (mBrain.getCurrentState() == defend) { aState = "defend";  mLabel.color = 0x009191; }
				if (mBrain.getCurrentState() == prepareForMatch) { aState = "prepare";  mLabel.color = 0x000000; }
				if (mBrain.getCurrentState() == patrol) { aState = "patrol";  mLabel.color = 0x2488C1; }
				if (mBrain.getCurrentState() == passPuck) { aState = "passPuck"; mLabel.color = 0xFAC5C5; }
				
				mLabel.text = "AI (" + aState + ")";
				mLabel.shadow = 0;
			}
			
			mLabel.draw();
		}
		
		public function setControlledByPlayer(theStatus :Boolean) :void {
			if(!mGhost) {
				mControlledByAI = !theStatus;
			}
		}
		
		public function setGhost(theStatus :Boolean, theDuration :Number) :void {
			mGhost = theStatus;
			mGhostCounter = theDuration;
			alpha = 0.8;
		}
		
		public function amIAGhost() :Boolean {
			return mGhost;
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
		
		public function getClosestAthleteFromPuck(theTeam :FlxGroup, theIgnoreMyself :Boolean = false) :Athlete {
			var aPuck :Puck = getPuck();
			var aDistance :Number = Number.MAX_VALUE;
			var aClosest :Athlete;
			var aAthlete :Athlete;			
			var aLength :int = theTeam.members.length;
			
			for (var i:int = 0; i < aLength; i++) {
				aAthlete = theTeam.members[i];
				
				if (aAthlete != null && aAthlete.visible && Utils.distance(aAthlete, aPuck) < aDistance && (theIgnoreMyself == false || aAthlete != this)) {
					aClosest = aAthlete;
					aDistance = Utils.distance(aAthlete, aPuck);
				}
			}
			
			return aClosest;
		}
		
		public function countAthletesWithinRadius(theTeam :FlxGroup, theCenter :*, theRadius :Number) :int {
			var aDistance :Number = Number.MAX_VALUE;
			var aAthlete :Athlete;			
			var aLength :int = theTeam.members.length;
			var aCount :int = 0;

			for (var i:int = 0; i < aLength; i++) {
				aAthlete = theTeam.members[i];
				
				if (aAthlete != null && Utils.distance(aAthlete, theCenter) <= theRadius) {
					aCount++;
				}
			}
			
			return aCount;
		}
		
		public function getOpponentTeam() :FlxGroup {
			var aPlayState :PlayState = FlxG.state as PlayState;
			return mTeam == aPlayState.leftTeam ? aPlayState.rightTeam : aPlayState.leftTeam;
		}
		
		public function getOpponentGoalPosition() :Vector3D {
			var aPosition :Vector3D;
			var aPlayState :PlayState = FlxG.state as PlayState;
			
			if (mTeam == aPlayState.leftTeam) {
				aPosition = new Vector3D(aPlayState.rightGoal.sprite.x, aPlayState.rightGoal.sprite.y);
			} else {
				aPosition = new Vector3D(aPlayState.leftGoal.sprite.x, aPlayState.leftGoal.sprite.y);
			}
			
			return aPosition;
		}
		
		public function get boid() :Boid { return mBoid; }
		public function get id() :int { return mId; }
		public function get team() :FlxGroup { return mTeam; }
	}
}