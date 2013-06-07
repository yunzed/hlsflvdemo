/*****************************************************************************
 * HlsPlayer.as: HLS Player interface.
 *****************************************************************************
 * Copyright (C) 2013-2013 libflvhls project
 *
 * Authors: Yunze Deng <yunzed@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02111, USA.
 *
 *****************************************************************************/

package com.vcap.hls
{
	import com.vcap.hls.impl.HlsMgr;

	public class HlsPlayer
	{
		public static const BANDWIDTH_UNKNOWN:int = 0;
		public static const BANDWIDTH_LOW:int = 1;
		public static const BANDWIDTH_MEDIUM:int = 2;
		public static const BANDWIDTH_HIGH:int = 3;
		
		private var mHlsMgr:HlsMgr = null;
		
		public function HlsPlayer()
		{
			mHlsMgr = new HlsMgr();
		}
		
		public function setVideoWnd(wnd:Object, x:int = 0, y:int = 0, width:int=640, height:int=480) : void {
			mHlsMgr.setVideoWnd(wnd, x, y, width, height);
		}
		
		public function setListener(listener:IHlsListener) : void {
			mHlsMgr.setListener(listener);
		}
		
		public function setBandWidth(bw:int) : void {
			
		}
		
		public function play(url:String) : int {
			return mHlsMgr.play(url);
		}
		
		public function pause() : void {
			mHlsMgr.pause();
		}
		
		public function resume() : void {
			mHlsMgr.resume();
		}
		
		public function stop() : void {
			mHlsMgr.stop();
		}
		
		public function seek(time:Number) : int {
			return mHlsMgr.seek(time);
		}
		
		public function getPlayTime() : Number {
			return mHlsMgr.getPlayTime();	
		}
		
		public function getCurIndex() : int {
			return mHlsMgr.getCurIndex();
		}
		
		public function getTotalTime() : int {
			return mHlsMgr.getTotalTime();
		}
	}
}