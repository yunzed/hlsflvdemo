/*****************************************************************************
 * HlsErrorCode.as: error code defines.
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
	public class HlsError
	{
		public static const ERROR_OK:int = 0;		
		public static const ERROR_FAIL:int = 1;
		//playlist relative:
		public static const ERROR_PL_INVALID_FORMAT:int = 100;
		public static const ERROR_PL_DOWNLOAD_FAIL:int = 101;
		public static const ERROR_PL_SECURITY_ERROR:int = 102;
		public static const ERROR_PL_IO_ERROR:int = 103;
		public static const ERROR_PL_NO_ITEM:int = 105;
		
		//mpegts:
		public static const ERROR_TS_DOWNLOAD_FAIL:int = 200;
		public static const ERORR_TS_FORMAT_FAIL:int = 201;
		public static const ERROR_TS_MEDIA_FORMAT_NOT_SUPPORT:int = 202;
	}
}