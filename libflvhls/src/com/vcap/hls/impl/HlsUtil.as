/*****************************************************************************
 * HlsUtil.as: util functions.
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
	public class HlsUtil
	{
		public static function isValidUrl(url:String) :Boolean {
			url = url.toLowerCase();
			if( url.indexOf("http://") != 0 && url.indexOf("https://") != 0 && url.indexOf("hls://") != 0) {
				return false;
			}
			
			if( url.lastIndexOf(".m3u8") != url.length-5 && url.lastIndexOf(".m3u") != url.length-4 ) {
				return false;
			}
			
			return true;
		}
	}
}