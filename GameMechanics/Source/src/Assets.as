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
	public class Assets 
	{
		// Art by wutang33, licensed as public domain - http://opengameart.org/content/hockey-players
		[Embed(source="../assets/athlete_yellow_small.png")] public static const ATHLETE_YELLOW :Class;
		[Embed(source="../assets/athlete_yellow.png")] public static const ATHLETE_YELLOW_BIG :Class;
		[Embed(source="../assets/athlete_red_small.png")] public static const ATHLETE_RED :Class;
		[Embed(source="../assets/athlete_pieces.png")] public static const ATHLETE_PIECES :Class;
		
		// Background art by Fernando Bevilacqua, licensed as public domain.
		[Embed(source="../assets/background.png")] public static const BACKGROUND :Class;
		[Embed(source="../assets/background_menu.png")] public static const BACKGROUND_MENU :Class;
		
		// Art by Fernando Bevilacqua, licensed as public domain.
		[Embed(source="../assets/puck.png")] public static const PUCK :Class;
		[Embed(source="../assets/goal.png")] public static const GOAL :Class;
		[Embed(source="../assets/logo.png")] public static const LOGO :Class;
		
		// Art by Lorc, http://game-icons.net/, licensed under CC BY 3.0
		[Embed(source="../assets/team_icon_right.png")] public static const TEAM_ICON_RIGHT :Class;		
		[Embed(source="../assets/team_icon_left.png")] public static const TEAM_ICON_LEFT :Class;
		[Embed(source="../assets/powerup_fear_of_puck.png")]public static const POWERUP_FEAR_OF_PUCK :Class;
		[Embed(source="../assets/powerup_ghost_help.png")]public static const POWERUP_GHOST_HELP :Class;
		
		// Art by qubodup, http://opengameart.org/content/simple-light-graysacle-cursors-16x16, licensed as public domain.
		[Embed(source="../assets/slick_arrow-arrow.png")]public static const CURSOR_SLICK_ARROW:Class;		
		
		// Art by xelu, http://opengameart.org/content/free-keyboard-and-controllers-prompts-pack, licensed as public domain.
		[Embed(source="../assets/keyboard_ctrl.png")]public static const KEYBOARD_CTRL:Class;		
		[Embed(source="../assets/keyboard_shift.png")]public static const KEYBOARD_SHIFT:Class;
		[Embed(source="../assets/keyboard_enter.png")]public static const KEYBOARD_ENTER:Class;
		[Embed(source="../assets/mouse_with_buttons.png")]public static const MOUSE_WITH_BUTTONS:Class;

		// Art by LoneCoder, http://opengameart.org/content/64-crosshairs-pack-split, licensed as public domain
		[Embed(source="../assets/player_mark.png")] public static const PLAYER_MARK :Class;
		[Embed(source="../assets/puck_mark.png")] public static const PUCK_MARK :Class;

		// Sfx by Michel Baradari, http://opengameart.org/content/rumbleexplosion, licensed as CC BY 3.0 
		[Embed(source="../assets/rumble.mp3")]public static const SFX_EXPLOSION :Class;
		
		// Sfx by gr8sfx, http://www.freesfx.co.uk/users/gr8sfx/, licensed as CC BY 3.0 
		[Embed(source="../assets/puck_hit.mp3")]public static const SFX_PUCK_HIT :Class;
		[Embed(source="../assets/cheer.mp3")]public static const SFX_CHEER :Class;
		
		// Music by danosongs, http://www.freesfx.co.uk/users/danosongs/, licensed as CC BY 3.0
		[Embed(source="../assets/snap_sphere.mp3")]public static const SFX_MAIN_MUSIC :Class;
	}
}