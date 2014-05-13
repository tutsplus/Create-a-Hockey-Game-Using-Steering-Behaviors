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
			mShowDebugAI = false;
			mDebugHud = new FlxText(10, FlxG.height - 70, FlxG.width);
			mDebugHud.color = 0xffffff;
			add(mDebugHud);
			
			// Start the whole thing up!
			resetGame();
			
			super.create();
		}
		
		private function placeAthletes() :void {
			var a:Athlete;
			
			a = new Athlete(FlxG.width / 2 - 70, FlxG.height / 2, 20, mLeftTeam);
			
			Game.instance.boids.push(a.boid);
			mLeftTeam.add(a);
		}
		
		private function getPlayerControlledAthlete(theTeam :FlxGroup) :Athlete {
			var i :int, aLength :int = theTeam.members.length;
			var aAthlete :Athlete;
			
			for (i = 0; i < aLength; i++) {
				aAthlete = theTeam.members[i];
				
				if (aAthlete != null) {
					break;
				}
			}
			
			return aAthlete;
		}
		
		
		private function performStickAction() :void {
			var aPlayer :Athlete = getPlayerControlledAthlete(playerTeam);
			
			if(mPuck.owner == aPlayer) {
				mPuck.goFromStickHit(aPlayer, FlxG.mouse);
			}
		}
		
		private function puckTouchedByAthlete(thePuck :Puck, theAthlete :Athlete) :void {
			if(mPuck.owner != theAthlete) {
				mPuck.setOwner(theAthlete);
			}
		}
		
		private function resetGame() :void {
			mPuck.gotoRinkCenter();
			
			var aPlayer :Athlete = getPlayerControlledAthlete(mLeftTeam);
			
			aPlayer.boid.position.x = FlxG.width / 2 - 70;
			aPlayer.boid.position.y = FlxG.height / 2;
		}
		
		private function puckColliedWithRinkWall(theRink :FlxObject, thePuck :Puck) :void {
			if (mPuck.owner != null) {
				var aCenter :FlxPoint = new FlxPoint(FlxG.width * FlxG.random(), FlxG.height / 2);
				mPuck.goFromStickHit(mPuck.owner, aCenter);
			}
		}
		
		override public function update():void {
			super.update();
			
			FlxG.collide(mRink, mAthletes);
			FlxG.collide(mRink, mPuck, puckColliedWithRinkWall);
			
			if(mPuck.owner == null) {
				FlxG.collide(mPuck, mAthletes, puckTouchedByAthlete);
			}

			if (FlxG.mouse.justPressed()) {
				performStickAction();
			}
			
			applyRinkContraints();
			
			if (FlxG.keys.justPressed("R")) { resetGame(); }
			
			mDebugHud.text = "INSTRUCTIONS:\nGet the puck at the center of the rink.\nWith the puck, click anywhere to hit the puck.\nPress R to reset and start again.";
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