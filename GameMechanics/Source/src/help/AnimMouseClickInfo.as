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
	 * the mouse cursor.
	 */
	public class AnimMouseClickInfo extends FlxGroup
	{
		private var mText :FlxText;
		private var mAthlete :AnimatedAthlete;
		private var mCursor :FlxSprite;
		private var mPuck :AnimatedPuck;
		private var mMouse :FlxSprite;
		
		private var mPointA :FlxPoint;
		private var mPointB :FlxPoint;
		
		private var mCounter :Number;
		
		public function AnimMouseClickInfo() 
		{
			mText = new FlxText(FlxG.width / 2 - 180, 100, 400);
			mText.size = 18;
			mText.color = 0;
			mText.shadow = 0xffffffff;
			
			mText.text = "CLICK to hit the puck. It will aim at the mouse cursor.";
			
			mAthlete = new AnimatedAthlete(FlxG.width / 2 - 100, FlxG.height / 2 - 10);
			mCursor = new FlxSprite(FlxG.width / 2 + 80, FlxG.height / 2, Assets.CURSOR_SLICK_ARROW);
			
			mCursor.followPath(new FlxPath([
				new FlxPoint(FlxG.width / 2 + 80, FlxG.height / 2 - 50),
				new FlxPoint(FlxG.width / 2 + 80, FlxG.height / 2 + 120),
			]), 20, FlxObject.PATH_YOYO);
			
			mPointA = new FlxPoint(mAthlete.x, mAthlete.y);
			mPointB = new FlxPoint(mCursor.x, mCursor.y);
			
			mPuck = new AnimatedPuck(FlxG.width / 2 - 40, FlxG.height / 2 + 40);
			
			mMouse = new FlxSprite(FlxG.width / 2 + 100, FlxG.height / 2 - 30);
			mMouse.loadGraphic(Assets.MOUSE_WITH_BUTTONS, true, false, 100, 100);
			
			mMouse.addAnimation("idle", [0]);
			mMouse.addAnimation("click", [1]);
			mMouse.play("idle");
			
			mMouse.followPath(new FlxPath([
				new FlxPoint(FlxG.width / 2 + 150, FlxG.height / 2 - 40),
				new FlxPoint(FlxG.width / 2 + 150, FlxG.height / 2 + 130),
			]), 20, FlxObject.PATH_YOYO);
			
			mCounter = 10;
			
			add(mText);
			add(mPuck);
			add(mAthlete);
			add(mCursor);
			add(mMouse);
		}
		
		private function hitPuck() :void {
			mPuck.x = FlxG.width / 2 - 50;
			mPuck.y = FlxG.height / 2 + 35;
			
			mPuck.velocity.x = (mCursor.x - mPuck.x) * 1.5; 
			mPuck.velocity.y = (mCursor.y - mPuck.y) * 1.5; 
		}
		
		override public function update():void 
		{
			mPointB.x = mCursor.x;
			mPointB.y = mCursor.y;
			
			mAthlete.angle = FlxU.getAngle(mPointA, mPointB) - 90;
			
			mCounter += FlxG.elapsed;
			
			if (mCounter >= 3.5) {
				mCounter = -0.2;
				mMouse.play("click", true);
				hitPuck();
			}
			
			if (mCounter > 0) {
				mMouse.play("idle", true);
			}
			
			if (!mPuck.onScreen()) {
				mPuck.x = FlxG.width / 2 - 50;
				mPuck.y = FlxG.height / 2 + 35;
				
				mPuck.velocity.x = 0;
				mPuck.velocity.y = 0;
			}
			
			super.update();
		}
	}
}