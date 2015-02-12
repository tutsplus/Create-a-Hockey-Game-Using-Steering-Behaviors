/**
 * Copyright (c) 2015, Fernando Bevilacqua
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
	
	/**
	 * Game hud
	 */
	public class Hud extends FlxGroup
	{
		private var mIconLeft :FlxSprite;
		private var mNameLeft :FlxText;
		private var mMetaLeft :FlxText;
		
		private var mIconRight :FlxSprite;
		private var mNameRight :FlxText;
		private var mMetaRight :FlxText;		
		
		private var mScoreRight 	:FlxText;
		private var mScoreMiddle 	:FlxText;
		private var mScoreLeft 		:FlxText;
		private var mSoundBtn 		:FlxButton;
		private var mSoundActive 	:Boolean;
		
		private var mPowerUpsRight 	:FlxGroup;
		private var mPowerUpsLeft 	:FlxGroup;
		
		private var mTimer 			:FlxText;
		
		private var mGoal :FlxText;
		private var mGetReady :FlxText;
		
		public function Hud(theRightPowerUps :FlxGroup, theLeftPowerUps :FlxGroup) {
			mIconLeft 				= new FlxSprite(2, FlxG.height - 60, Assets.TEAM_ICON_LEFT);
			mNameLeft				= new FlxText(65, FlxG.height - 40, 300, "Angry Eagles");
			mNameLeft.size			= 16;			
			mNameLeft.color			= Constants.TEAM_COLOR_LEFT;
			
			mIconRight 				= new FlxSprite(FlxG.width - 60, FlxG.height - 60, Assets.TEAM_ICON_RIGHT);
			mNameRight				= new FlxText(FlxG.width - 360, FlxG.height - 40, 300, "Iced Dinos");
			mNameRight.size			= 16;			
			mNameRight.color		= Constants.TEAM_COLOR_RIGHT;
			mNameRight.alignment 	= "right";
			
			mScoreRight				= new FlxText(FlxG.width / 2 + 15, FlxG.height - 50, 100, "0");
			mScoreMiddle			= new FlxText(FlxG.width / 2 - 4, FlxG.height - 40, 100, "x");
			mScoreLeft				= new FlxText(FlxG.width / 2 - 110, FlxG.height - 50, 100, "0");
			
			mScoreRight.size 		= 40;
			mScoreRight.alignment 	= "left";
			mScoreRight.color 		= Constants.TEAM_COLOR_RIGHT;
			mScoreMiddle.size 		= 12;
			mScoreLeft.size 		= 40;
			mScoreLeft.alignment 	= "right";
			mScoreLeft.color 		= Constants.TEAM_COLOR_LEFT;
			
			mGoal 					= new FlxText(0, FlxG.height / 2 - 90, FlxG.width, "GOAL!");
			mGoal.alignment 		= "center";
			mGoal.size 				= 120;
			mGoal.shadow 			= 0xffffffff;
			mGoal.visible 			= false;
			
			mGetReady 				= new FlxText(0, FlxG.height / 2 - 20, FlxG.width, "Get ready!");
			mGetReady.alignment 	= "center";
			mGetReady.size 			= 35;
			mGetReady.color 		= 0;
			mGetReady.shadow 		= 0xffffffff;
			mGetReady.velocity.y 	= -5;
			
			mGetReady.flicker(Constants.MATCH_PREPARE_TIME);
			
			mSoundBtn 				= new FlxButton(5, 10, "Sound: On", toggleSound);
			mSoundActive 			= true;
			
			mTimer					= new FlxText(0, 0, FlxG.width, "");
			mTimer.alignment		= "center";
			mTimer.size 			= 32;
			mTimer.color 			= 0xff000000;
			
			mPowerUpsRight			= theRightPowerUps;
			mPowerUpsLeft			= theLeftPowerUps;
			
			add(mIconLeft);
			add(mNameLeft);
			add(mIconRight);
			add(mIconRight);
			add(mNameRight);
			
			add(mScoreRight);
			add(mScoreMiddle);
			add(mScoreLeft);
			add(mGoal);
			add(mGetReady);
			add(mTimer);
			
			add(mPowerUpsLeft);
			add(mPowerUpsRight);
			
			add(mSoundBtn);
			
			// Make hud position relative to the screen and ignore any camera movements.
			for (var i:int = 0; i < members.length; i++) {
				if (members[i] != null) {
					if(!(members[i] is FlxGroup)) {
						members[i].scrollFactor.x = 0;
						members[i].scrollFactor.y = 0;
					}
				}
			}
		}
		
		public function toggleSound():void {
			
			if (mSoundActive) {
				FlxG.pauseSounds();
				mSoundActive = false;
				mSoundBtn.label.text = "Sound: Off";
			} else {
				FlxG.resumeSounds();
				mSoundActive = true;
				mSoundBtn.label.text = "Sound: On";
			}
		}
		
		override public function update():void 
		{
			super.update();
			
			if (mGoal.visible && !mGoal.onScreen()) {
				mGoal.visible = false;
			}
			
			if (!mGetReady.flickering) {
				mGetReady.kill();
			}
			
			var aTime :Number = (FlxG.state as PlayState).matchTimer;
			
			mTimer.text = Utils.numberToStringTime(aTime);
			
			if (aTime <= 30) {
				mTimer.flicker(1);
			}
		}
		
		public function refresh() :void {
			placePowerUpsOnScreen(mPowerUpsLeft, 7);
			placePowerUpsOnScreen(mPowerUpsRight, FlxG.width - 55);
		}
		
		private function placePowerUpsOnScreen(theGroup :FlxGroup, thePosX :Number) :void {
			var i:uint, j:uint = 0;
			var aPowerUp :PowerUp;
			
			for (i = 0; i < theGroup.members.length; i++) {
				aPowerUp = theGroup.members[i];
				
				if (aPowerUp != null && aPowerUp.alive) {
					aPowerUp.x = thePosX;
					aPowerUp.y = FlxG.height - 120 - j++ * (aPowerUp.height + 5);
				}
			}
		}
		
		public function showGoal(theSide :String) :void {
			mGoal.color = theSide == "right" ? Constants.TEAM_COLOR_RIGHT : Constants.TEAM_COLOR_LEFT;
			mGoal.visible = true;
			mGoal.x = FlxG.width - 3;
			mGoal.velocity.x = -250;
		}
		
		public function setScore(theValue :int, theSide :String):void {
			var aText :FlxText = (theSide == "right" ? mScoreRight : mScoreLeft);

			aText.text = theValue.toString();
			aText.flicker(5);
			
			showGoal(theSide);
		}
		
		public function isSoundActive() :Boolean {
			return mSoundActive;
		}
	}
}