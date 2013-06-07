/*****************************************************************************
 * FlvWrapper: FLV file format wrapper.
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

package com.vcap.hls.flv
{
	import com.vcap.hls.h264.H264Nalu;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class FlvWrapper
	{
		public static function getHeader():ByteArray {
			var flvBytes:ByteArray = new ByteArray();
			flvBytes.endian = Endian.BIG_ENDIAN;
			
			flvBytes.writeByte(0x46); // 8 bits, 'F'
			flvBytes.writeByte(0x4C); // 8 bits, 'L'
			flvBytes.writeByte(0x56); // 8 bits, 'V'
			flvBytes.writeByte(0x01); // 8 bits, Version 1
			flvBytes.writeByte(0x05); // 5 bits, TypeFlagsReserved, Shall be 0
			// 1 bit, TypeFlagsAudio, 1 = Audio tags are present
			// 1 bit, TypeFlagsReserved, Shall be 0
			// 1 bit, TypeFlagsVideo, 1 = Video tags are present
			flvBytes.writeByte(0x00); // 32 bits, DataOffset, 9 = length
			flvBytes.writeByte(0x00); 
			flvBytes.writeByte(0x00); 
			flvBytes.writeByte(0x09); 
			
			// The following 32 bits are not parts of a FLV header
			flvBytes.writeByte(0x00); // PreviousTagSize0, 32 bits, Always 0
			flvBytes.writeByte(0x00); 
			flvBytes.writeByte(0x00); 
			flvBytes.writeByte(0x00);
			
			flvBytes.position = 0;
			return flvBytes;
		}
		
		public static function getVideoTag(data:ByteArray, packet_type:int, key_frame:Boolean, rel_stamp:int, pts_dts_diff:int) : ByteArray {
			var len:uint = 0;
			var buf:ByteArray = new ByteArray();
			buf.endian = Endian.BIG_ENDIAN;
			
			if( data == null )
				return buf;
			
			len = data.bytesAvailable + 5;
			buf.writeByte(9);
			
			//size
			buf.writeByte(len>>16);
			buf.writeByte(len>>8);
			buf.writeByte(len);
			
			//stamp
			buf.writeByte(rel_stamp>>16);
			buf.writeByte(rel_stamp>>8);
			buf.writeByte(rel_stamp);			
			buf.writeByte(rel_stamp>>24);
			
			//stream id
			buf.writeByte(0);
			buf.writeByte(0);
			buf.writeByte(0);
			
			//VideoTagHeader
			if( key_frame ) {
				buf.writeByte(0x17); 
			} else {
				buf.writeByte(0x27);
			}
			buf.writeByte(packet_type);
			
			//composition time
			if( packet_type == 0 ) {
				buf.writeByte(0);
				buf.writeByte(0);
				buf.writeByte(0);
			} else {
				buf.writeByte(pts_dts_diff>>16);
				buf.writeByte(pts_dts_diff>>8);
				buf.writeByte(pts_dts_diff);
			}
			
			buf.writeBytes(data);
			buf.writeUnsignedInt(buf.length);
			
			buf.position = 0;
			
			return buf;
		}
		
		public static function getAVCConfig(sps:H264Nalu, pps:H264Nalu):ByteArray {
			var buf:ByteArray = new ByteArray();
			var sps2:int = sps.payload[sps.start_code_len+1];
			var sps3:int = sps.payload[sps.start_code_len+2];
			var sps4:int = sps.payload[sps.start_code_len+3];
			
			buf.writeByte(0x01);
			buf.writeByte(sps2);
			buf.writeByte(sps3);
			buf.writeByte(sps4);
			buf.writeByte(0xff);
			
			//sps
			var start_len:int = (sps.payload[2]==0x00)?4:3;
			buf.writeByte(0xe1);
			buf.writeShort(sps.payload.length-start_len);
			buf.writeBytes(sps.payload, start_len, 0);
			
			//pps
			buf.writeByte(0x01);
			start_len = (pps.payload[2]==0x00)?4:3;
			buf.writeShort(pps.payload.length-start_len);
			buf.writeBytes(pps.payload, start_len, 0);
			
			//reset buf position:
			buf.position = 0;
			
			return buf;
		}
		
		public static function getAudioTag(inBytes:ByteArray, pos:uint, len:uint, rel_stamp:uint, aacPacketType:uint = 0x00) :ByteArray {
			var buf:ByteArray = new ByteArray();	
			var size:uint = len+2;	// (tagHeader == 0xaf) ? len + 2 : len + 1;
			
			// tag header
			buf.writeByte(0x08);
			
			// 24 bits, data size
			buf.writeByte((size >> 16) & 0xff);
			buf.writeByte((size >>  8) & 0xff);
			buf.writeByte((size      ) & 0xff);
			
			// 24 bits, timestamp +  8 bits, timestamp extended
			buf.writeByte((rel_stamp >> 16) & 0xff);
			buf.writeByte((rel_stamp >>  8) & 0xff);
			buf.writeByte((rel_stamp      ) & 0xff);
			buf.writeByte((rel_stamp >> 24) & 0xff);
			
			// 24 bits, StreamID, always 0
			buf.writeByte(0x00);
			buf.writeByte(0x00);
			buf.writeByte(0x00);
			
			// audio tag header
			buf.writeByte(0xaf);
			buf.writeByte(aacPacketType);
			
			// audio data
			buf.writeBytes(inBytes, pos, len);
			
			// previous tag size
			buf.writeByte(((size + 11) >> 24) & 0xff);
			buf.writeByte(((size + 11) >> 16) & 0xff);
			buf.writeByte(((size + 11) >>  8) & 0xff);
			buf.writeByte(((size + 11)      ) & 0xff);
			
			return buf;
		}
	}
}