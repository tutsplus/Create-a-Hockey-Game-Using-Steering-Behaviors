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
	public class AnimKeyboardMoveFaster extends FlxGroup
	{
		private var mText :FlxText;
		private var mAthlete :AnimatedAthlete;
		private var mKey :FlxSprite;
		
		private var mCounter :Number;
		
		public function AnimKeyboardMoveFaster() 
		{
			mText = new FlxText(FlxG.width / 2 - 180, 100, 400);
			mText.size = 18;
			mText.color = 0;
			mText.shadow = 0xffffffff;
			
			mText.text = "Hold SHIFT to move faster.\n\nShatter opponents carring the puck by bumping into them while moving faster.";
			
			mAthlete = new AnimatedAthlete(FlxG.width / 2 - 80, FlxG.height / 2);
			mKey = new FlxSprite(FlxG.width / 2 + 50, FlxG.height / 2, Assets.KEYBOARD_SHIFT);
			mCounter = 0;
			
			add(mText);
			add(mAthlete);
			add(mKey);
		}
		
		override public function update():void 
		{
			super.update();
			
			mCounter += FlxG.elapsed;
			
			if (mCounter >= 2) {
				mCounter = -1.0;
			}
			
			mKey.scale.x = mCounter < 0 ? 0.8 : 1;
			mKey.scale.y = mCounter < 0 ? 0.8 : 1;
		}
	}
}