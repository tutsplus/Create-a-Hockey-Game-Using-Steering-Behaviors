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
		
		private var mShowDebugAI :Boolean;
		private var mAllowHumans :Boolean;
	
		override public function create():void {
			mAthletes 	= new FlxGroup();
			mLeftTeam 	= new FlxGroup(Constants.TEAM_MAX);
			mRightTeam 	= new FlxGroup(Constants.TEAM_MAX);
			mPuck		= new Puck();
			mRightGoal	= new Goal(FlxG.width * 0.92, FlxG.height / 2 - 16);
			mLeftGoal	= new Goal(FlxG.width * 0.07, FlxG.height / 2 - 16);
			mGoals		= new FlxGroup(2);
			mRink		= new Rink();
			mPreparingMatch = 0;
			
			placeAthletes();
			
			add(new FlxSprite(0, 0, Assets.BACKGROUND));
			add(mRink);
			add(mPuck);
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
			
			// Debug stuff
			mShowDebugAI = true;
			mAllowHumans = false;
			mDebugHud = new FlxText(10, FlxG.height - 50, FlxG.width);
			mDebugHud.color = 0xffffff;
			add(mDebugHud);
			
			// Start the whole thing up!
			startMatch();
			
			super.create();
		}
		
		// According to this: http://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Ice_hockey_layout.svg/800px-Ice_hockey_layout.svg.png
		private function placeAthletes() :void {
			var i:int;
			var a:Athlete;
			var aRinkCenter :FlxPoint = new FlxPoint(FlxG.width / 2, FlxG.height / 2 - 30);
			var aPos :FlxPoint = new FlxPoint();
			
			for (i = 0 ; i < Constants.TEAM_MAX; i++) { 
				switch(i) {
					case 0: aPos.x = FlxG.width * 0.07; aPos.y = 0; break; // center
					case 1: aPos.x = FlxG.width * 0.15; aPos.y = -FlxG.height * 0.23; break; // right wing
					case 2: aPos.x = FlxG.width * 0.15; aPos.y =  FlxG.height * 0.23; break; // left wing
					case 3: aPos.x = FlxG.width * 0.30; aPos.y = -FlxG.height * 0.15; break; // right defenseman					
					case 4: aPos.x = FlxG.width * 0.30; aPos.y =  FlxG.height * 0.15; break; // left defenseman
					case 5: aPos.x = FlxG.width * 0.40; aPos.y = 0; break; // goalie
				}
				
				// Left team
				a = new Athlete(aRinkCenter.x - aPos.x, aRinkCenter.y + aPos.y, 20, mLeftTeam);
				Game.instance.boids.push(a.boid);
				mLeftTeam.add(a);
				
				// Right team
				a = new Athlete(aRinkCenter.x + aPos.x, aRinkCenter.y + aPos.y, 20, mRightTeam);
				Game.instance.boids.push(a.boid);
				mRightTeam.add(a);				
			}
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
					
					if(aAthlete.id > aPlayerAthlete.id) {
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
				mPuck.goFromStickHit(aPlayer, FlxG.mouse);
			}
		}
		
		private function hitPunk() :void {
			var aPlayerControlledAthlete :Athlete = getPlayerControlledAthlete(mLeftTeam);
		}
		
		private function selectAnotherAthlete(theTeam :FlxGroup, theNewAthlete :Athlete = null) :void {
			var aPlayerControlled :Athlete = getPlayerControlledAthlete(theTeam);
			var aAIControlled :Athlete = theNewAthlete == null ? pickNextAIControlledAthlete(theTeam) : theNewAthlete;
			
			aAIControlled.setControlledByPlayer(true);
			aPlayerControlled.setControlledByPlayer(false);
		}
		
		private function puckTouchedByAthlete(thePuck :Puck, theAthlete :Athlete) :void {
			if(mPuck.owner != theAthlete) {
				mPuck.setOwner(theAthlete);
				
				if (theAthlete.team == playerTeam && !theAthlete.isControlledByPlayer() && mAllowHumans) {
					selectAnotherAthlete(playerTeam, theAthlete);
				}
			}
		}
		
		private function organizeMatchAfterScore() :void {
			mMatchRunning = false;
			mPreparingMatch = Constants.MATCH_PREPARE_TIME;
			mPuck.setOwner(null);
			mPuck.kill();
		}
		
		private function startMatch() :void {
			mMatchRunning = true;
			mPuck.gotoRinkCenter();
			
			if(mAllowHumans) {
				selectAnotherAthlete(mLeftTeam);
			}
		}
		
		private function puckTouchedGoal(thePuck :Puck, theGoal :Goal) :void {
			organizeMatchAfterScore();
			mAthletes.callAll("returnToInitialPosition");
		}
		
		private function athletesOverlapped(theLeftAthlete :Athlete, theRightAthlete :Athlete) :void {
			if (theLeftAthlete.flickering || theRightAthlete.flickering) {
				return;
			}
			
			if (mPuck.owner != null) {
				if (mPuck.owner == theLeftAthlete) {
					theLeftAthlete.flicker(2.5);
					mPuck.setOwner(theRightAthlete);
					
				} else if (mPuck.owner == theRightAthlete) {
					theRightAthlete.flicker(2.5);
					mPuck.setOwner(theLeftAthlete);
				}
			}
		}
		
		private function puckColliedWithRinkWall(theRink :FlxObject, thePuck :Puck) :void {
			if (mPuck.owner != null) {
				var aCenter :FlxPoint = new FlxPoint(FlxG.width * FlxG.random(), FlxG.height / 2);
				mPuck.goFromStickHit(mPuck.owner, aCenter);
			}
		}
		
		override public function update():void {
			super.update();
			
			FlxG.collide(mPuck, mGoals, puckTouchedGoal);
			FlxG.overlap(mLeftTeam, mRightTeam, athletesOverlapped);
			FlxG.collide(mRink, mAthletes);
			FlxG.collide(mRink, mPuck, puckColliedWithRinkWall);
			
			if(mPuck.owner == null) {
				FlxG.collide(mPuck, mAthletes, puckTouchedByAthlete);
			}

			if (FlxG.mouse.justPressed()) {
				performStickAction();
			}
			
			if (FlxG.keys.justPressed("C")) {
				mAllowHumans = true;
				selectAnotherAthlete(playerTeam);
			}
			
			if (!mMatchRunning) {
				mPreparingMatch -= FlxG.elapsed;
				
				if (mPreparingMatch <= 0) {
					startMatch();
				}
			}
			
			applyRinkContraints();
			
			if (FlxG.keys.justPressed("G")) { puckTouchedGoal(null, null); }
			if (FlxG.keys.justPressed("R")) { mPuck.gotoRinkCenter(); }
			if (FlxG.keys.justPressed("H")) { toggleAllowHumans(); }
			if (FlxG.keys.justPressed("D")) { mShowDebugAI = !mShowDebugAI; }
			
			mDebugHud.text = "DEBUG:\nHumans allowed (press H to change)?  " + mAllowHumans.toString().toUpperCase() + " \nShow AI (press D to change)?  " + mShowDebugAI.toString().toUpperCase();
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
	}
}