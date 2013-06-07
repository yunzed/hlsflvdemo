/*****************************************************************************
 * H264Nalu: H264 Nalu object, start_code+payload.
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
package com.vcap.hls.h264
{
	import flash.utils.ByteArray;

	public class H264Nalu
	{
		public static const NALU_SEI:int = 6;
		public static const NALU_SPS:int = 7;
		public static const NALU_PPS:int = 8;
		public static const NALU_AUD:int = 9;
		public static const NALU_IDR:int = 5;
		public static const NALU_SLICE:int = 1;
		
		public var type:int = 0;
		public var payload:ByteArray = new ByteArray();
		public var start_code_len:int = 0;
	}
}