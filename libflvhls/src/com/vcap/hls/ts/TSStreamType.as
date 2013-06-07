/*****************************************************************************
 * TSStreamType.as: mpegts stream type define (iso13818-1).
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
	public class TSStreamType
	{
		public static const TS_PACKET_H262:int = 0x02;
		public static const TS_PACKET_H222:int = 0x05;
		public static const TS_PACKET_AAC:int = 0x0f;
		public static const TS_PACKET_LATM:int = 0x11;
		public static const TS_PACKET_H264:int = 0x1b;
	}
}