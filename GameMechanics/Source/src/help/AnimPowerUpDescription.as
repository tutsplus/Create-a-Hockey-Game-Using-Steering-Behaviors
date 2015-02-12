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
	 * This class creates described the power-ups in the game.
	 */
	public class AnimPowerUpDescription extends FlxGroup
	{
		private var mText :FlxText;
		private var mTextPowerUpA :FlxText;
		private var mTextPowerUpB :FlxText;
		private var mPowerUpA :FlxSprite;
		private var mPowerUpB :FlxSprite;
		
		public function AnimPowerUpDescription() 
		{
			mText = new FlxText(FlxG.width / 2 - 170, 100, 400);
			mText.size = 18;
			mText.color = 0;
			mText.shadow = 0xffffffff;
			
			mText.text = "Meet the power-ups:";
			
			mPowerUpA = new FlxSprite(FlxG.width / 2 - 200, FlxG.height * 0.4, Assets.POWERUP_FEAR_OF_PUCK);
			mTextPowerUpA = new FlxText(mPowerUpA.x + mPowerUpA.width + 10, mPowerUpA.y - 5, 400);
			mTextPowerUpA.size = 14;
			mTextPowerUpA.color = 0;
			mTextPowerUpA.shadow = 0xffffffff;
			mTextPowerUpA.text = "Fear of Puck\nOpponents will flee the puck while this power-up is active.";
			
			mPowerUpB = new FlxSprite(FlxG.width / 2 - 200, FlxG.height * 0.6, Assets.POWERUP_GHOST_HELP);
			mTextPowerUpB = new FlxText(mPowerUpB.x + mPowerUpB.width + 10, mPowerUpB.y - 5, 400);
			mTextPowerUpB.size = 14;
			mTextPowerUpB.color = 0;
			mTextPowerUpB.shadow = 0xffffffff;
			mTextPowerUpB.text = "Ghost Help\nYour team receives 3 additional athletes for a few seconds.";
			
			add(mText);
			add(mPowerUpA);
			add(mPowerUpB);
			
			add(mTextPowerUpA);
			add(mTextPowerUpB);
		}
	}
}