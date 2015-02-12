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
	public class AnimMouseInfo extends FlxGroup
	{
		private var mText :FlxText;
		private var mAthlete :AnimatedAthlete;
		private var mCursor :FlxSprite;
		private var mMouse :FlxSprite;
		
		private var mPointA :FlxPoint;
		private var mPointB :FlxPoint;
		
		public function AnimMouseInfo() 
		{
			mText = new FlxText(FlxG.width / 2 - 180, 100, 400);
			mText.size = 18;
			mText.color = 0;
			mText.shadow = 0xffffffff;
			
			mText.text = "Use the MOUSE cursor to guide/aim your athlete.";
			
			mAthlete = new AnimatedAthlete(FlxG.width / 2 - 100, FlxG.height / 2 - 10);
			mCursor = new FlxSprite(FlxG.width / 2 + 80, FlxG.height / 2, Assets.CURSOR_SLICK_ARROW);
			
			mCursor.followPath(new FlxPath([
				new FlxPoint(FlxG.width / 2 + 80, FlxG.height / 2 - 50),
				new FlxPoint(FlxG.width / 2 + 80, FlxG.height / 2 + 120),
			]), 100, FlxObject.PATH_YOYO);
			
			mMouse = new FlxSprite(FlxG.width / 2 + 100, FlxG.height / 2 - 30);
			mMouse.loadGraphic(Assets.MOUSE_WITH_BUTTONS, false, false, 100, 100);
			mMouse.frame = 0;
			
			mMouse.followPath(new FlxPath([
				new FlxPoint(FlxG.width / 2 + 150, FlxG.height / 2 - 40),
				new FlxPoint(FlxG.width / 2 + 150, FlxG.height / 2 + 130),
			]), 100, FlxObject.PATH_YOYO);
			
			mPointA = new FlxPoint(mAthlete.x, mAthlete.y);
			mPointB = new FlxPoint(mCursor.x, mCursor.y);
			
			add(mText);
			add(mAthlete);
			add(mCursor);
			add(mMouse);
		}
		
		override public function update():void 
		{
			mPointB.x = mCursor.x;
			mPointB.y = mCursor.y;
			
			mAthlete.angle = FlxU.getAngle(mPointA, mPointB) - 90;
			super.update();
		}
	}
}