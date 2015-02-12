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
	
	public class Goal extends FlxGroup
	{
		public var goalArea :FlxSprite;
		public var backArea :FlxSprite;
		public var sprite :FlxSprite;
		
		public function Goal(theX :Number, theY :Number, theSide :String) {
			sprite = new FlxSprite(theX, theY, Assets.GOAL);
			
			if (theSide == "left") {
				sprite.scale.x *= -1;
			}
			
			sprite.moves = false;
			sprite.immovable = true;
			
			goalArea = new FlxSprite(theX + (theSide == "left" ? sprite.width : -3), theY);
			goalArea.makeGraphic(3, sprite.height, 0xffff0000);
			goalArea.visible = false;
			goalArea.moves = false;
			goalArea.immovable = true;
			
			backArea = new FlxSprite(theX + (theSide == "right" ? goalArea.width : 0), theY);
			backArea.makeGraphic(sprite.width, sprite.height, 0xff00ff00);
			backArea.visible = false;
			backArea.moves = false;
			backArea.immovable = true;
			
			add(sprite);
			add(goalArea);
			add(backArea);
		}
	}
}