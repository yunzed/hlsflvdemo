/*****************************************************************************
 * TSPmt.as: mpegts PMT table.
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

	public class TSPmt
	{
		public var pointer:int = 0;
		public var tid:int = 0;
		public var sect_ind:int = 0;
		public var zero:int = 0;
		public var reserve1:int = 0;
		public var sect_len:int = 0;
		public var tsid:int = 0;
		public var reserve2:int = 0;
		public var ver:int = 0;
		public var next_ind:int = 0;
		public var sect_num:int = 0;
		public var last_sect_num:int = 0;
		
		public var pcr_pid:int = 0;
		public var pinfo_len:int = 0;
		public var pinfo:ByteArray = null;
		
		public var audio_pid:int = 0;
		public var video_pid:int = 0;
		
		public var crc:int = 0;
	}
}