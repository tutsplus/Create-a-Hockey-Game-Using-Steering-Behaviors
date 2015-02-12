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
	import help.*;
	import org.flixel.*;
	
	public class HelpState extends FlxState
	{
		private var mBackground :FlxSprite;
		private var mTextTitle :FlxText;

		private var mTextPlay :FlxText;
		private var mStep :int;
		private var mHelpFigures :FlxGroup;
		
		override public function create():void 
		{
			mBackground = new FlxSprite(0, 0, Assets.BACKGROUND_MENU);
			mBackground.velocity.x = -20;
			
			mTextTitle = new FlxText(0, 40, FlxG.width, "Instructions");
			mTextTitle.alignment = "center";
			mTextTitle.size = 24;
			mTextTitle.color = 0;
			
			mTextPlay = new FlxText(FlxG.width / 2 - 100, FlxG.height - 60, 200, "Press any key or click to continue");
			mTextPlay.alignment = "center";
			mTextPlay.size = 14;
			mTextPlay.color = 0;
			mTextPlay.shadow = 0xffffffff;
			
			mHelpFigures = new FlxGroup();
			mStep = 0;
			
			add(mBackground);
			add(mTextTitle);
			add(mTextPlay);
			add(mHelpFigures);
			
			buildInstructions(mStep);
			
			super.create();
		}
		
		private function buildInstructions(theStep :int) :void {
			mHelpFigures.callAll("kill");

			switch(theStep) {
				case 0:
					mHelpFigures.add(new AnimMouseInfo());
					break;
					
				case 1:
					mHelpFigures.add(new AnimMouseClickInfo());
					break;
					
				case 2:
					mHelpFigures.add(new AnimKeyboardSelect());
					break;
					
				case 3:
					mHelpFigures.add(new AnimKeyboardMoveFaster());
					break;
					
				case 4:
					mHelpFigures.add(new AnimPowerUpInfo());
					break;

				case 5:
					mHelpFigures.add(new AnimPowerUpDescription());
					break;					
			}
		}
		
		override public function update():void 
		{
			if (mBackground.x + mBackground.width < FlxG.width || mBackground.x > 0) {
				mBackground.velocity.x *= -1;
			}
			
			if (FlxG.keys.any() || FlxG.mouse.justPressed()) {
				mStep++;
				
				if(mStep >= 6) {
					FlxG.switchState(new PlayState());
				} else {
					buildInstructions(mStep);
				}
			}
			
			super.update();
		}
	}
}