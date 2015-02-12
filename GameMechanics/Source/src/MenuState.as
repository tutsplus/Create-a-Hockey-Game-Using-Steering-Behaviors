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
	
	public class MenuState extends FlxState
	{
		private var mBackground :FlxSprite;
		private var mLogo :FlxSprite;
		private var mTextLogo :FlxText;
		private var mTextPlay :FlxText;
		
		override public function create():void 
		{
			mBackground = new FlxSprite(0, 0, Assets.BACKGROUND_MENU);
			mBackground.velocity.x = -20;
			
			mLogo = new FlxSprite(FlxG.width / 2 - 140, FlxG.height / 2 - 180, Assets.LOGO);
			
			mTextLogo = new FlxText(0, mLogo.y + mLogo.height, FlxG.width, "Hockeynamite");
			mTextLogo.alignment = "center";
			mTextLogo.size = 45;
			mTextLogo.color = 0;
			mTextLogo.shadow = 0xffffffff;
			
			
			mTextPlay = new FlxText(FlxG.width / 2 - 100, mTextLogo.y + 90, 200, "Press any key or click to play");
			mTextPlay.alignment = "center";
			mTextPlay.size = 18;
			mTextPlay.color = 0;
			mTextPlay.shadow = 0xffffffff;
			
			add(mBackground);
			add(mLogo);
			add(mTextLogo);
			add(mTextPlay);
			
			FlxG.pauseSounds();
			
			super.create();
		}
		
		override public function update():void 
		{
			if (mBackground.x + mBackground.width < FlxG.width || mBackground.x > 0) {
				mBackground.velocity.x *= -1;
			}
			
			if (FlxG.keys.any() || FlxG.mouse.justPressed()) {
				FlxG.switchState(new HelpState());
			}
			
			super.update();
		}
	}
}