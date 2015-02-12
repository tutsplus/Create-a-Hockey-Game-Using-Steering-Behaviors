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
	 * This class describes a power-up. It contains an icon, a name and a description.
	 */
	public class PowerUp extends FlxSprite
	{
		public static const FEAR_OF_PUCK 	:String = "fear of puck";
		public static const GHOST_HELP 		:String = "ghost help";
		
		public static var available 		:Array = [FEAR_OF_PUCK, GHOST_HELP];
		
		private var mId	:String;
		
		private function init(theId :String) :void {
			var aGraphic :Class;
			
			switch(theId) {
				case FEAR_OF_PUCK: 	aGraphic = Assets.POWERUP_FEAR_OF_PUCK; 	break;
				case GHOST_HELP: 	aGraphic = Assets.POWERUP_GHOST_HELP; 		break;
			}
			
			loadGraphic(aGraphic);
			
			scrollFactor.x = 0;
			scrollFactor.y = 0;
			alpha = 0.8;
		}
		
		public function PowerUp(theId :String) 
		{
			mId = theId;
			init(theId);
		}
		
		/**
		 * Creates a new (random) power-up 
		 * 
		 * @return the newly created powerup
		 */
		public static function randomlyCreateNew() :PowerUp {
			var aId :String = available[int(FlxG.random() * available.length)];
			return new PowerUp(aId);
		}
		
		public function get id():String { return mId; }
	}

}