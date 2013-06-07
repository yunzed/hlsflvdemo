/*****************************************************************************
 * TSPes.as: mpegts PES table.
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
	public class TSPes
	{
		public var stream_id:int  =0;
		public var len:int = 0;
		public var priority:int = 0;
		public var align_ind:int = 0;
		public var copy:int = 0;
		
		public var pts_dts_ind:int = 0;
		public var escr_flag:int = 0;
		public var es_rate_flag:int = 0;
		public var dsm_trick_mode_flag:int = 0;
		public var additional_copy_info_flag:int = 0;
		public var crc_flag:int = 0;
		public var ext_flag:int = 0;
		
		public var left_len:int = 0;
		public var stuff:int = 0;
		public var pts:int = 0;
		public var dts:int = 0;
	}
}