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
	import org.flixel.FlxEmitter;
	import org.flixel.FlxGroup;
	
	/**
	 * Handle all special effects in the game, as shattering pieces.
	 */
	public class SpecialEffects extends FlxGroup
	{
		private var mShatterPieces 			:FlxGroup;
		private var mPiecesEmitters 		:Array;
		private var mCurrentPiecesEmitter 	:int;		
		
		public function SpecialEffects() 
		{
			var i:int = 0;
			var aEmitter :FlxEmitter;
			
			mCurrentPiecesEmitter = 0;
			mPiecesEmitters = new Array();
			
			for (i = 0; i < Constants.EFFECTS_MAX_PIECES_EMITTER; i++) {
				aEmitter = new FlxEmitter(0, 0, Constants.EFFECTS_MAX_PIECES);
				
				aEmitter.setXSpeed(-200, 200);
				aEmitter.setYSpeed(-200, 200);
				aEmitter.setRotation(150, 300);
				aEmitter.makeParticles(Assets.ATHLETE_PIECES, Constants.EFFECTS_MAX_PIECES, 16, true, 0);
				
				mPiecesEmitters.push(aEmitter);
				add(aEmitter);
			}
		}
		
		public function emitShatterPieces(thePosX :Number, thePosY :Number):void {
			if (++mCurrentPiecesEmitter >= Constants.EFFECTS_MAX_PIECES_EMITTER) {
				mCurrentPiecesEmitter = 0;
			}
			
			var aEmitter :FlxEmitter = mPiecesEmitters[mCurrentPiecesEmitter];
			
			aEmitter.x = thePosX;
			aEmitter.y = thePosY;
			aEmitter.start(true, 3);
		}
	}
}