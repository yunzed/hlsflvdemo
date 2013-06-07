/*****************************************************************************
 * TSFrame.as: mpegts frame, maybe one H264 picture or one ADTS frame. 
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
package com.vcap.hls.ts
{
	import flash.utils.ByteArray;

	public class TSFrame
	{
		private var mSeq:int = 0;
		private var mType:int = 0;
		private var mPts:uint = 0;
		private var mDts:uint = 0;
		private var mPayload:ByteArray = new ByteArray();
		
		public function TSFrame()
		{
		}
		
		public function addPayload(buf:ByteArray) : void {
			mPayload.writeBytes(buf, buf.position, buf.bytesAvailable);
		}
		
		public function getPayload() : ByteArray {
			return mPayload;
		}
		
		public function setPts(pts:uint) : void {
			mPts = pts;
		}
		
		public function getPts() : uint {
			return mPts;
		}
		
		public function setDts(dts:uint) : void {
			mDts = dts;
		}
		
		public function getDts() : uint {
			return mDts;
		}
		
		public function setType(type:int) : void {
			mType = type;
		}
		
		public function getType() : int {
			return mType;
		}
		
		public function dump() : void {
			
		}
	}
}