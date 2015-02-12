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
	import org.flixel.*;
	
	public class PlayState extends FlxState
	{
		private var mAthletes	:FlxGroup;
		private var mLeftTeam	:FlxGroup;
		private var mRightTeam	:FlxGroup;
		private var mRightGoal	:Goal;
		private var mLeftGoal	:Goal;
		private var mGoals		:FlxGroup;
		private var mPuck		:Puck;
		private var mRink		:Rink;
		private var mPreparingMatch :Number;
		private var mMatchRunning :Boolean;
		private var mDebugHud 	:FlxText;
		private var mHud 		:Hud;
		private var mPlayerMark	:FlxSprite;
		private var mMatchTimer	:Number;
		
		private var mScoreRight :int;
		private var mScoreLeft 	:int;
		
		private var mLeftPowerUps	:FlxGroup;
		private var mRightPowerUps	:FlxGroup;		
		
		// Properties to handle speciall effects (e.g. shattering)
		private var mSpecialEffects :SpecialEffects;
		
		private var mShowDebugAI :Boolean;
		private var mAllowHumans :Boolean;
	
		override public function create():void {
			mAthletes 		= new FlxGroup();
			mLeftTeam 		= new FlxGroup();
			mRightTeam 		= new FlxGroup();
			mPuck			= new Puck();
			mRightGoal		= new Goal(Constants.WORLD_WIDTH * 0.915, Constants.WORLD_HEIGHT / 2 - 38, "right");
			mLeftGoal		= new Goal(Constants.WORLD_WIDTH * 0.066, Constants.WORLD_HEIGHT / 2 - 38, "left");
			mGoals			= new FlxGroup(2);
			mRink			= new Rink();
			mPreparingMatch = 0;
			mScoreRight		= 0;
			mScoreLeft		= 0;
			mMatchTimer		= Constants.MATCH_DURATION;
			mLeftPowerUps	= new FlxGroup();
			mRightPowerUps	= new FlxGroup();
			
			// Init some stuff
			initSpecialEffectsAndHud();
			placeAthletes();
			
			add(mRink);
			add(mPuck);
			add(mPlayerMark);
			add(mLeftTeam);
			add(mRightTeam);
			add(mLeftGoal);
			add(mRightGoal);
			
			// Virtual group containing all athletes in the match.
			mAthletes.add(mLeftTeam);
			mAthletes.add(mRightTeam);
			
			// Virtual group to hold both goals
			mGoals.add(mLeftGoal);
			mGoals.add(mRightGoal);
			
			// Addd effects and hud to the scren
			add(mSpecialEffects);
			add(mHud);
			
			initCameras();
			initDebugStuff();
			
			// Start the whole thing up!
			organizeMatchAfterScore(false);
			
			// Let the party begins!
			FlxG.play(Assets.SFX_MAIN_MUSIC, 0.3, true);
			
			// Disable sound by default.
			mHud.toggleSound();
			
			super.create();
		}
		
		private function initDebugStuff():void {
			mShowDebugAI = false;
			mAllowHumans = true;
			mDebugHud = new FlxText(10, FlxG.height - 50, FlxG.width);
			mDebugHud.color = 0xffffff;
			//add(mDebugHud);
		}
		
		private function initCameras():void {
			// There is a real strange bug with Flixel collision system if worldBound.width does not have that "+ 30"....
			FlxG.worldBounds = new FlxRect(0, 0, Constants.WORLD_WIDTH + 30, Constants.WORLD_HEIGHT);
			FlxG.camera.follow(mPuck);
			FlxG.camera.setBounds(0, 0, Constants.WORLD_WIDTH, Constants.WORLD_HEIGHT);
		}
		
		private function initSpecialEffectsAndHud():void {
			mSpecialEffects = new SpecialEffects();
			mHud 			= new Hud(mRightPowerUps, mLeftPowerUps);
			mPlayerMark		= new FlxSprite(0, 0, Assets.PLAYER_MARK);
			
			mPlayerMark.angularVelocity = 50;
		}
		
		// According to this: http://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Ice_hockey_layout.svg/800px-Ice_hockey_layout.svg.png
		private function placeAthletes() :void {
			var i:int;
			var a:Athlete;
			var aRinkCenter :FlxPoint = new FlxPoint(Constants.WORLD_WIDTH / 2, Constants.WORLD_HEIGHT / 2 - 30);
			var aPos :FlxPoint = new FlxPoint();
			
			for (i = 0 ; i < Constants.TEAM_MAX; i++) { 
				switch(i) {
					case 0: aPos.x = Constants.WORLD_WIDTH * 0.07; aPos.y = 0; break; // center
					case 1: aPos.x = Constants.WORLD_WIDTH * 0.15; aPos.y = -Constants.WORLD_HEIGHT * 0.23; break; // right wing
					case 2: aPos.x = Constants.WORLD_WIDTH * 0.15; aPos.y =  Constants.WORLD_HEIGHT * 0.23; break; // left wing
					case 3: aPos.x = Constants.WORLD_WIDTH * 0.30; aPos.y = -Constants.WORLD_HEIGHT * 0.15; break; // right defenseman					
					case 4: aPos.x = Constants.WORLD_WIDTH * 0.30; aPos.y =  Constants.WORLD_HEIGHT * 0.15; break; // left defenseman
					case 5: aPos.x = Constants.WORLD_WIDTH * 0.40; aPos.y = 0; break; // goalie
				}
				
				// Left team
				a = addAthlete(aRinkCenter.x - aPos.x, aRinkCenter.y + aPos.y, 20, mLeftTeam);
				placeAtBottomOfScreen(a);
				
				// Right team
				a = addAthlete(aRinkCenter.x + aPos.x, aRinkCenter.y + aPos.y, 20, mRightTeam);
				placeAtBottomOfScreen(a);
			}
		}
		
		public function addAthlete(thePosX :Number, thePosY :Number, theMass :Number, theTeam :FlxGroup) :Athlete {
			var a :Athlete;
			
			a = new Athlete(thePosX, thePosY, theMass, theTeam);
			Game.instance.boids.push(a.boid);
			theTeam.add(a);
			
			return a;
		}
		
		private function placeAtBottomOfScreen(theAthlete :Athlete):void {
			theAthlete.boid.position.x = Constants.WORLD_WIDTH / 2;
			theAthlete.boid.position.y = Constants.WORLD_HEIGHT - 100;
		}
		
		private function getPlayerControlledAthlete(theTeam :FlxGroup) :Athlete {
			var i :int, aLength :int = theTeam.members.length;
			var aAthlete :Athlete;
			
			for (i = 0; i < aLength; i++) {
				aAthlete = theTeam.members[i];
				
				if (aAthlete != null && aAthlete.isControlledByPlayer()) {
					break;
				}
			}
			
			return aAthlete;
		}
		
		private function pickNextAIControlledAthlete(theTeam :FlxGroup) :Athlete {
			var i :int, aLength :int = theTeam.members.length;
			
			var aAthlete :Athlete;
			var aNext :Athlete;
			var aFirst :Athlete;
			var aPlayerAthlete :Athlete = getPlayerControlledAthlete(theTeam);
			
			for (i = 0; i < aLength; i++) {
				aAthlete = theTeam.members[i];
				
				if (aAthlete != null && aAthlete != aPlayerAthlete) {
					if (aFirst == null) {
						aFirst = aAthlete;
					}
					
					if(aPlayerAthlete == null || aAthlete.id > aPlayerAthlete.id) {
						aNext = aAthlete;
						break;
					}
				}
			}
			
			if (aNext == null) {
				aNext = aFirst;
			}
			
			return aNext;
		}
		
		private function performStickAction() :void {
			var aPlayer :Athlete = getPlayerControlledAthlete(playerTeam);
			
			if(mPuck.owner == aPlayer) {
				mPuck.goFromStickHit(aPlayer, FlxG.mouse, Constants.PUCK_SPEED);
			}
		}
		
		public function selectAnotherAthlete(theTeam :FlxGroup, theNewAthlete :Athlete = null) :void {
			var aPlayerControlled :Athlete = getPlayerControlledAthlete(theTeam);
			var aAIControlled :Athlete = theNewAthlete == null ? pickNextAIControlledAthlete(theTeam) : theNewAthlete;
			
			// Choose another athlete only if the current one is not carrying the puck
			if(aPlayerControlled == null || aPlayerControlled != mPuck.owner) {
				aAIControlled.setControlledByPlayer(true);
				
				if(aPlayerControlled != null) {
					aPlayerControlled.setControlledByPlayer(false);
				}
			}
		}
		
		public function makePlayerControlAthleteCloseToPuck() :void {
			var aAthlete :Athlete = playerTeam.getFirstAlive() as Athlete;
			
			if (aAthlete != null) {
				selectAnotherAthlete(playerTeam, aAthlete.getClosestAthleteFromPuck(playerTeam));
				
			} else {
				selectAnotherAthlete(playerTeam);
			}
		}
		
		private function puckTouchedByAthlete(thePuck :Puck, theAthlete :Athlete) :void {
			if(mPuck.owner != theAthlete) {
				mPuck.setOwner(theAthlete);
			}
		}
		
		private function organizeMatchAfterScore(theSmootlyMovePuck :Boolean = true) :void {
			mMatchRunning = false;
			mPreparingMatch = Constants.MATCH_PREPARE_TIME;
			mPuck.setOwner(null);
			mPuck.visible = false;
			
			if(theSmootlyMovePuck) {
				mPuck.smoothlyMoveTowardsRinkCenter();
			} else {
				mPuck.gotoRinkCenter();
			}
			
			mAthletes.callAll("returnToInitialPosition");
		}
		
		private function startMatch() :void {
			mMatchRunning = true;
			mPuck.gotoRinkCenter();
			
			if (mAllowHumans) {
				makePlayerControlAthleteCloseToPuck();
			}
		}
		
		private function puckTouchedGoal(thePuck :Puck, theGoalSprite :FlxSprite) :void {
			var aDidScore :Boolean = false;
			var aTeamScored :FlxGroup;

			if (theGoalSprite == mRightGoal.goalArea) {
				mScoreLeft++;
				mHud.setScore(mScoreLeft, "left");
				aTeamScored = mLeftTeam;
				aDidScore = true;
				
			} else if(theGoalSprite == mLeftGoal.goalArea) {
				mScoreRight++;
				mHud.setScore(mScoreRight, "right");
				aTeamScored = mRightTeam;
				aDidScore = true;
			}
			
			if (aDidScore) {
				// For now, give power-ups to the left team only.
				if(aTeamScored == mLeftTeam) {
					addRandomPowerUp(aTeamScored);
				}
				
				organizeMatchAfterScore();
				FlxG.flash();
				
				if((FlxG.state as PlayState).hud.isSoundActive()) {
					FlxG.play(Assets.SFX_CHEER);
				}
			}
		}
		
		private function athletesOverlapped(theLeftAthlete :Athlete, theRightAthlete :Athlete) :void {
			if (!theLeftAthlete.visible || !theRightAthlete.visible) {
				return;
			}
			
			if (mPuck.owner != null) {
				if (mPuck.owner == theLeftAthlete) {
					theLeftAthlete.shatter();
					mPuck.setOwner(theRightAthlete);
					
				} else if (mPuck.owner == theRightAthlete) {
					theRightAthlete.shatter();
					mPuck.setOwner(theLeftAthlete);
				}
			}
		}
		
		private function puckColliedWithRinkWall(theRink :FlxObject, thePuck :Puck) :void {
			if (mPuck.owner != null) {
				var aCenter :FlxPoint = new FlxPoint(Constants.WORLD_WIDTH * FlxG.random(), Constants.WORLD_HEIGHT / 2);
				mPuck.goFromStickHit(mPuck.owner, aCenter);
			}
		}
		
		override public function update():void {
			// Hide the player mark. It will be activated by
			// someone if needed.
			mPlayerMark.visible = false;
			
			super.update();
			
			FlxG.collide(mRink, mAthletes);
			FlxG.collide(mRink, mPuck, puckColliedWithRinkWall);
			
			// Make puck and athletes collide/overlap only if the match is running
			if (mMatchRunning) {
				FlxG.collide(mPuck, mGoals, puckTouchedGoal);
				FlxG.overlap(mLeftTeam, mRightTeam, athletesOverlapped);
				
				// Puck can collide with athletes only if it has no owner
				if(mPuck.owner == null) {
					FlxG.collide(mPuck, mAthletes, puckTouchedByAthlete);
				}
			}

			if(mMatchTimer > 0 && mMatchRunning) {
				if (FlxG.mouse.justPressed()) {
					performStickAction();
				}
				
				if (FlxG.keys.justPressed("CONTROL")) {
					mAllowHumans = true;
					makePlayerControlAthleteCloseToPuck();
				}
				
				if (FlxG.keys.justPressed("ENTER") || FlxG.keys.justPressed("SPACE")) {
					// Activate the current powerup
					useCurrentPowerUp();
				}
			}
			
			if (!mMatchRunning) {
				mPreparingMatch -= FlxG.elapsed;
				
				if (mPreparingMatch <= 0) {
					startMatch();
				}
			} else {
				mMatchTimer -= FlxG.elapsed;
				
				if (mMatchTimer <= 0) {
					// That's all, folks!
					FlxG.switchState(new EndState(mScoreLeft, mScoreRight));
				}
			}
			
			applyRinkContraints();
			
			if (FlxG.keys.justPressed("C")) { selectAnotherAthlete(playerTeam); }
			if (FlxG.keys.justPressed("G")) { organizeMatchAfterScore(); }
			if (FlxG.keys.justPressed("R")) { mPuck.gotoRinkCenter(); }
			if (FlxG.keys.justPressed("H")) { toggleAllowHumans(); }
			if (FlxG.keys.justPressed("D")) { mShowDebugAI = !mShowDebugAI; }
			
			mDebugHud.text = "DEBUG:\nHumans allowed (press H to change)?  " + mAllowHumans.toString().toUpperCase() + " \nShow AI (press D to change)?  " + mShowDebugAI.toString().toUpperCase();
		}
		
		private function addRandomPowerUp(theTeam :FlxGroup) :void {
			var aPowerUp :PowerUp = PowerUp.randomlyCreateNew();
			var aPlace :FlxGroup = theTeam == mLeftTeam ? mLeftPowerUps : mRightPowerUps;
			
			aPlace.add(aPowerUp);
			aPowerUp.flicker(0.5);
			
			mHud.refresh();
		}
		
		private function useCurrentPowerUp() :void {
			var aPowerUp :PowerUp = mLeftPowerUps.getFirstAlive() as PowerUp;
			
			if (aPowerUp != null) {
				aPowerUp.kill(); // remove from screen
				executePowerUp(aPowerUp.id);
			}
		}
		
		private function executePowerUp(thePowerUpId :String) :void {
			switch(thePowerUpId) {
				case PowerUp.FEAR_OF_PUCK: 	powerupFearPuck(); 	break;
				case PowerUp.GHOST_HELP: 	powerupGhostHelp(); break;
			}
			
			// Refresh hud to animate any remaining powerup icon still available.
			mHud.refresh();
			FlxG.flash();
		}
		
		private function powerupFearPuck() :void {
			var i 			:uint,
				athletes 	:Array 	= rightTeam.members,
				size 		:uint 	= athletes.length;
			
			FlxG.log("Powerup: Fear Puck");
				
			for (i = 0; i < size; i++) {
				if (athletes[i] != null) {
					athletes[i].fearPuck(Constants.POWERUP_FEAR_OF_PUCK_DURATION);
				}
			}
			
			mPuck.makeFearable(Constants.POWERUP_FEAR_OF_PUCK_DURATION, Constants.TEAM_COLOR_LEFT);
		}
		
		private function powerupGhostHelp() :void {
			var aAthlete :Athlete;
			
			FlxG.log("Powerup: Ghost Help");
			
			for (var i:int = 0; i < 3; i++) {
				aAthlete = addAthlete(Constants.WORLD_WIDTH / 2, Constants.WORLD_HEIGHT - 100 - FlxG.random() * 50, 20, leftTeam);
				aAthlete.setGhost(true, Constants.POWERUP_GHOST_HELP_DURATION);
			}
		}
		
		private function applyRinkContraints() :void {
			for (var i:int = 0; i < Game.instance.boids.length; i++) {
				contraintWithinRink(Game.instance.boids[i]);
			}
			
			contraintWithinRink(mPuck);
		}
		
		private function contraintWithinRink(theElement :Object) :void {
			theElement = theElement is Puck ? theElement : theElement.position;
			
			theElement.x = theElement.x >= mRink.right.x ? mRink.right.x : theElement.x;
			theElement.x = theElement.x <= mRink.left.x + mRink.left.width ? mRink.left.x + mRink.left.width : theElement.x;
			
			theElement.y = theElement.y >= mRink.bottom.y ? mRink.bottom.y : theElement.y;
			theElement.y = theElement.y <= mRink.top.y + mRink.top.height ? mRink.top.y + mRink.top.height : theElement.y;
		}
		
		private function toggleAllowHumans() :void {
			var aPlayerControlled :Athlete = getPlayerControlledAthlete(playerTeam);
			
			mAllowHumans = !mAllowHumans;
			
			if (mAllowHumans == false && aPlayerControlled != null) {
				aPlayerControlled.setControlledByPlayer(false);
			}
		}
		
		public function get rightTeam() :FlxGroup { return mRightTeam; }
		public function get leftTeam() :FlxGroup { return mLeftTeam; }
		public function get rightGoal() :Goal { return mRightGoal; }
		public function get leftGoal() :Goal { return mLeftGoal; }
		public function get athletes() :FlxGroup { return mAthletes; }
		public function get playerTeam() :FlxGroup { return mLeftTeam; }		
		public function get puck() :Puck { return mPuck; }
		public function get rink() :Rink { return mRink; }
		public function get showDebugAI() :Boolean { return mShowDebugAI; }
		public function get specialEffects() :SpecialEffects { return mSpecialEffects; }
		public function get playerMark() :FlxSprite { return mPlayerMark; }
		public function get allowHumans() :Boolean { return mAllowHumans; }
		public function get matchRunning() :Boolean { return mMatchRunning; }
		public function get matchTimer() :Number { return mMatchTimer; }
		public function get rightPowerUps() :FlxGroup { return mRightPowerUps; }
		public function get leftPowerUps() :FlxGroup { return mLeftPowerUps; }
		public function get hud() :Hud { return mHud; }
	}
}