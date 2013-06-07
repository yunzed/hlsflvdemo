/*****************************************************************************
 * HlsLog.as: log helper.
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
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	public class HlsLog
	{
		public static function	log(msg: String) : void {
			var tmsg:String = getTimer() +"\t" + msg;
			trace(tmsg);
		}
		
		public static function	tlog(msg: String) : void {
			var tmsg:String = getTimer() +"\t" + msg;
			trace(tmsg);
		}
		
		public static function	error(msg: String) : void {
			trace("ERROR**************************************");
			trace("ERROR: " + msg);			
			trace("ERROR**************************************");
		}
		
		public static function hex(buf:ByteArray) : void {
			var rows:int = buf.length/16;
			var left:int = buf.length%16;
			var msg:String = "";
			
			for( var i:int = 0; i<rows; i++ ) {	
				msg = "";
				for( var j:int = 0; j<16; j++ ) {
					msg += buf[i*16+j];
					msg += " ";
				}
				
				trace(msg);
			}
			
			msg = "";
			for( var k:int = 0; k<left; k++ ) {
				msg += buf[rows*16+k];
				msg += " ";
			}
			trace(msg);
		}
	}
}