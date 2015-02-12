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

package help 
{
	import org.flixel.*;
	
	/**
	 * This class creates an animation to show how to play the game using
	 * the keyboard keys.
	 */
	public class AnimKeyboardSelect extends FlxGroup
	{
		private var mText :FlxText;
		private var mAthleteA :AnimatedAthlete;
		private var mAthleteB :AnimatedAthlete;
		private var mCtrl :FlxSprite;
		
		private var mCounter :Number;
		private var mSelectionMark :FlxSprite;
		private var mSelected :FlxSprite;
		
		public function AnimKeyboardSelect() 
		{
			mText = new FlxText(FlxG.width / 2 - 160, 100, 350);
			mText.size = 18;
			mText.color = 0;
			mText.shadow = 0xffffffff;
			
			mText.text = "Use CTRL to select an athlete close to the puck.";
			
			mAthleteA = new AnimatedAthlete(FlxG.width / 2 - 80, FlxG.height / 2 - 40);
			mAthleteB = new AnimatedAthlete(FlxG.width / 2 - 30, FlxG.height / 2 + 40);
			
			mCtrl = new FlxSprite(FlxG.width / 2 + 50, FlxG.height / 2 - 30, Assets.KEYBOARD_CTRL);
			mSelectionMark = new FlxSprite(mAthleteA.x, mAthleteA.y, Assets.PLAYER_MARK);
			mSelectionMark.angularVelocity = 50;
			mSelectionMark.scale.x = 1.5;
			mSelectionMark.scale.y = 1.5;
			
			mCounter = 0;
			mSelected = mAthleteA;
			
			add(mText);
			add(mSelectionMark);
			add(mAthleteA);
			add(mAthleteB);
			add(mCtrl);
		}
		
		override public function update():void 
		{
			super.update();
			
			mCounter += FlxG.elapsed;
			
			if (mCounter >= 2) {
				mSelected = mSelected == mAthleteA ? mAthleteB : mAthleteA;
				mCounter = -0.2;
			}
			
			mCtrl.scale.x = mCounter < 0 ? 0.8 : 1;
			mCtrl.scale.y = mCounter < 0 ? 0.8 : 1;
			
			mSelectionMark.x = mSelected.x;
			mSelectionMark.y = mSelected.y + 15;
		}
	}
}