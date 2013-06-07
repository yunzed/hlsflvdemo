/*****************************************************************************
 * HlsStatus.as: Hls Status, not used yet, but maybe later.
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
	public class HlsStatus
	{
		public static const HLS_STATUS_INIT:int = 0;
		public static const HLS_STATUS_LOADING_PL:int = 1;
		public static const HLS_STATUS_PLAYING:int = 2;
		public static const HLS_STATUS_PAUSED:int = 3;
		public static const HLS_STATUS_SEEKING:int = 4;
		public static const HLS_STATUS_CACHING:int = 5;
		public static const HLS_STATUS_STOPPED:int = 6;
		public static const HLS_STATUS_FATAL:int = 7;
		
		private var mStatus:int = HLS_STATUS_INIT;
		
		public function HlsStatus()
		{
		}
		
		public function setStatus(status:int) : void {
			mStatus = status;
		}
		
		public function getStatus() : int {
			return mStatus;
		}
	}
}