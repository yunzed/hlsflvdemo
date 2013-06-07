/*****************************************************************************
 * HlsNetStat.as: Hls Net Status management.
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
	public class HlsNetStat
	{
		public static const HLS_NET_PERFECT:int = 120;
		public static const HLS_NET_QUICK:int = 100;
		public static const HLS_NET_MIDDLE:int = 60;
		public static const HLS_NET_SLOW:int = 50;
		public static const HLS_NET_FAIL:int = 20;
		public static const HLS_NET_UNKNOWN:int = 20;
		
		private var mSpeed:Number = 0;
		private var mLastSpeed:Number = 0;
		private var mCount:int = 0;
		private var mRatio:Number = 0;
		private var mBW:Number = 0;
		
		public function HlsNetStat()
		{
		}
		
		/**
		 * @function addSample
		 * 
		 * This function will be called when a .ts segment is loaded.
		 * @param len the .ts segment length.
		 * @param time time to load the .ts segment.
		 * @param duration duration of the .ts segment.
		 */
		public function addSample(len:int, time:Number, duration:int) : void {
			var total:int = (mSpeed*mCount + len/time);
			
			mCount++;
			mSpeed = total/mCount;
			mRatio = duration/time;
			mBW = len/time;
		}
		
		public function getSpeed():Number {
			return mSpeed;
		}
		
		public function getStatus() : int {
			if( mRatio>100 )
				return HLS_NET_PERFECT;
			else if( mRatio > 30 )
				return HLS_NET_QUICK;
			else if( mRatio >=10 )
				return HLS_NET_MIDDLE;
			else if( mRatio >= 1 )
				return HLS_NET_SLOW;
			else if( mRatio == 0 )
				return HLS_NET_UNKNOWN;
			
			return HLS_NET_FAIL;
		}
	}
}