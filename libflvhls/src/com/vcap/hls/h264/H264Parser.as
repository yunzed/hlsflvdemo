/*****************************************************************************
 * H264Parser.as: H264 Parser, which splite H264 stream into nalus.
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
	import com.vcap.hls.impl.HlsLog;
	
	import flash.utils.ByteArray;

	public class H264Parser
	{
		public function H264Parser()
		{
		}
		
		public function parse(buf:ByteArray) : Vector.<H264Nalu> {
			var nalus:Vector.<H264Nalu> = new Vector.<H264Nalu>();
			var pos1:int = 0;
			var pos2:int = 0;
			var start:int = 0;
			
			buf.position = 0;			
			while( buf.bytesAvailable>4 ) {
				pos1 = findStartCode(buf, start);
				if( pos1 == -1 ) {
					break;
				} else {
					pos2 = findStartCode(buf, pos1+4);
					if( pos2 == -1 ) {
						if( buf.bytesAvailable>4 ) {
							var nalu_last:H264Nalu = new H264Nalu();
							buf.readBytes(nalu_last.payload, 0, buf.bytesAvailable);
							parseNalu(nalu_last);
							
							if( nalu_last.type != H264Nalu.NALU_AUD ) {
								nalus.push(nalu_last);					
							}
						}
						break;
					} else {
						var nalu:H264Nalu = new H264Nalu();
						buf.readBytes(nalu.payload, 0, pos2-pos1);
						parseNalu(nalu);
						
						//if( nalu.type != H264Nalu.NALU_AUD ) {
							nalus.push(nalu);					
						//}
						start = pos2;
					}
				}				
				
			}
			
			return nalus;
		}
		
		private function parseNalu(nalu:H264Nalu) : void {
			if( nalu.payload[0] != 0 || nalu.payload[1] != 0 ||
				(nalu.payload[2] != 0x00 && nalu.payload[2] != 0x01) ||
				(nalu.payload[2] == 0x00 && nalu.payload[3] != 0x01 ) ){
				HlsLog.error("H264Parser.parseNalu, not start with 0x0000, start code=" + nalu.payload[0] + "," + nalu.payload[1] + "," +nalu.payload[2] + "," +nalu.payload[3]);
				return;
			}

			var start_code_len:int = (nalu.payload[2]==0x00)?4:3;
			var prefix_buf:ByteArray = new ByteArray();
			prefix_buf.writeUnsignedInt(nalu.payload.length-start_code_len);
			prefix_buf.writeBytes(nalu.payload, start_code_len, 0);
			
			nalu.payload = prefix_buf;
			nalu.payload.position = 0;
			nalu.type = nalu.payload[4]&0x1f;
		}
		
		private function findStartCode(buf:ByteArray, start:int) : int {
			var state:int = 0;
			
			for( var i:int = start; i<buf.length; i++ ) {
				if( buf[i] != 0x00 && buf[i] != 0x01 ) {
					state = 0;
					continue;
				}
				switch(state) {
					case 0:
						if( buf[i] == 0 ) {
							state = 1;
						} else {
							state = 0;
						}
						break;
					case 1:
						if( buf[i] == 0 ) {
							state = 2;
						} else {
							state = 0;
						}
						break;
					case 2:
						if( buf[i] == 0 ) {
							state = 3;
						} else {
							state = 31;
							return i-2;
						}
						break;
					case 3:
						if( buf[i] == 1 ) {
							state = 41;
							return i-3;
						}
						break;
				}
			}
			
			return -1;
		}
	}
}