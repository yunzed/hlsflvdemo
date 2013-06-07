/*****************************************************************************
 * HlsSeekInfo.as: manage the seek information.
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
package com.vcap.hls.impl
{
	import flash.utils.getTimer;
	
	public class HlsSeekInfo
	{
		private var mHlsMgr:HlsMgr = null;
		private var mTime:Number = 0;
		private var mSeekTS:int = 0;
		
		public function HlsSeekInfo(mgr:HlsMgr)
		{
			mHlsMgr = mgr;
			mSeekTS = getTimer();
		}
		
		public function seek(time:Number) : void {
			mTime = time;
			mSeekTS = getTimer();
		}
		
		public function getSeek() : int {
			return mTime + getPlayTime()/1000;
		}
		
		public function getPlayTime() : int {
			var now:int = getTimer();
			return (now-mSeekTS);
		}
		
		public function stop() : void {
			mTime = 0;
		}
	}
}