/*****************************************************************************
 * TSPacket.as: mpegts packet, usually 188 bytes.
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
	import com.vcap.hls.impl.HlsLog;
	
	import flash.utils.ByteArray;

	public class TSPacket
	{
		private var mBuffer:ByteArray = null;
		private var mPts:TSPts = new TSPts();
		private var mPat:TSPat = null;
		private var mPmt:TSPmt = null;
		private var mPes:TSPes = null;
		
		public function TSPacket(buf:ByteArray)
		{
			this.mBuffer = buf;
		}
		
		public function parse() : void {
			parsePts();
		}
		
		public function getPts() : TSPts {
			return mPts;
		}
		
		public function getPat() : TSPat {
			return mPat;
		}
		
		public function getPmt() : TSPmt {
			return mPmt;
		}
		
		public function getPes() : TSPes {
			return mPes;
		}
		
		public function getPayload() : ByteArray {
			return mBuffer;
		}
		
		public function parsePts() : void {
			var val:int = mBuffer.readByte();			
			if( val != 0x47 ) {
				return;
			}
			
			val = mBuffer.readShort();
			mPts.error = (val&0x8000)>>15;
			mPts.start = (val&0x4000)>>14;
			mPts.priority = (val&0x2000)>>13;
			mPts.pid = (val&0x3fff);
			
			val = mBuffer.readByte();
			mPts.scramb = (val&0xcf)>>6;
			mPts.adapt_flag = (val&0x3f)>>4;
			mPts.seq = (val&0x0f);
			
			if( mPts.adapt_flag == 0x02 || mPts.adapt_flag == 0x03 ) {
				val = mBuffer.readByte()&0x00ff;
				if( val > 0 ) {
					mPts.adapt = new ByteArray();
					mBuffer.readBytes(mPts.adapt, 0, val);
				}
			}
		}
		
		public function parsePat() : void {
			var val:int = 0;
			
			mPat = new TSPat();
			if( mPts.start ) {
				mPat.pointer = mBuffer.readByte();
			}
			
			mPat.tid = mBuffer.readByte();
			
			//section len
			val = mBuffer.readShort();
			mPat.sect_ind = (val&0x8000)>>15;
			mPat.sect_len = (val&0x3ff);
			mPat.tsid = mBuffer.readShort();
			
			//version
			val = mBuffer.readByte();
			mPat.ver = (val&0x3f)>>1;
			mPat.next_ind = (val&0x1);
			
			mPat.sect_num = mBuffer.readByte();
			mPat.last_sect_num = mBuffer.readByte();
			
			//
			mPat.pmt_num = mBuffer.readShort();
			mPat.pmt_pid = mBuffer.readShort()&0x1fff;
			mPat.crc = mBuffer.readInt();
		}
		
		public function parsePmt() : void {
			var val:int = 0;
			
			mPmt = new TSPmt();
			if( mPts.start ) {
				mPmt.pointer = mBuffer.readByte();
			}
			
			mPmt.tid = mBuffer.readByte();
			
			//section len
			val = mBuffer.readShort();
			mPmt.sect_ind = (val&0x8000)>>15;
			mPmt.sect_len = (val&0x3ff);
			mPmt.tsid = mBuffer.readShort();
			
			//version
			val = mBuffer.readByte();
			mPmt.ver = (val&0x3f)>>1;
			mPmt.next_ind = (val&0x1);
			
			mPmt.sect_num = mBuffer.readByte();
			mPmt.last_sect_num = mBuffer.readByte();
			
			//
			val = mBuffer.readShort();
			mPmt.pcr_pid = val&0x1fff;
			
			val = mBuffer.readShort();
			mPmt.pinfo_len = val&0x3ff;
			
			if( mPmt.pinfo_len != 0 ) {
				mPmt.pinfo = new ByteArray();
				mBuffer.readBytes(mPmt.pinfo, 0, mPmt.pinfo_len);
			}
			
			//stream type->pid:
			var pos1:int = mBuffer.position;
			var pos2:int = 0;
			var type:int = 0;
			var pid:int = 0;
			while(1) {
				pos2 = mBuffer.position;
				if( pos2-pos1 >= mPmt.sect_len-13 )
					break;
				
				type = mBuffer.readByte();
				pid = mBuffer.readShort()&0x1fff;
				val = mBuffer.readShort()&0x3ff;
				
				if( val != 0 )
					mBuffer.position += val;
				
				switch(type) {
					case TSStreamType.TS_PACKET_AAC:
						mPmt.audio_pid = pid;
						break;
					case TSStreamType.TS_PACKET_H264:
						mPmt.video_pid = pid;
						break;
				}
			}
			
			mPmt.crc = mBuffer.readInt();
		}
		
		public function parsePes() : void {
			var val:int = 0;
			
			if( mBuffer.readByte() != 0x00 || mBuffer.readByte() != 0x00 || mBuffer.readByte() != 0x01 ) {
			//	return;
				HlsLog.error("TSPacket.parsePES, invalid start code.");
			}
			
			mPes = new TSPes();
			mPes.stream_id = mBuffer.readByte();
			mPes.len = mBuffer.readShort()+4;
			
			val = mBuffer.readShort();
			mPes.priority = (val&0x0800)>>11;
			mPes.align_ind = (val&0x0400)>>10;
			mPes.copy = (val&0x0200)>>8;
			
			mPes.pts_dts_ind = (val&0xc0)>>6;
			mPes.escr_flag = (val&0x20)>>5;
			mPes.es_rate_flag = (val&0x10)>>4;
			mPes.dsm_trick_mode_flag = (val&0x8)>>3;
			mPes.additional_copy_info_flag = (val&0x4)>>2;
			mPes.crc_flag = (val&0x2)>>1;
			mPes.ext_flag = (val&0x1);
			
			mPes.left_len = mBuffer.readByte();
			
			var pos1:int = mBuffer.position;
			var pos2:int = 0;
			if( mPes.left_len > 0 ) {
				if( mPes.pts_dts_ind == 0x3 ) {
					val = mBuffer.readByte();
					mPes.pts = ((val&0x0e)>>1)<<30;
					
					val = mBuffer.readUnsignedShort();
					mPes.pts += ((val&0xfffe)>>1)<<15;
					
					//val = readShort();
					val = mBuffer.readUnsignedShort();
					mPes.pts += (val&0xfffe)>>1;
					
					//dts
					val = mBuffer.readByte();
					mPes.dts = ((val&0x0e)>>1)<<30;
					
					val = mBuffer.readShort();
					mPes.dts += ((val&0xfffe)>>1)<<15;
					
					val = mBuffer.readShort();
					mPes.dts += (val&0xfffe)>>1;
				} else if( mPes.pts_dts_ind == 0x02 ) {
					val = mBuffer.readByte();
					mPes.pts = ((val&0x0e)>>1)<<30;
					
					val = mBuffer.readShort();
					mPes.pts += ((val&0xfffe)>>1)<<15;
					
					val = mBuffer.readShort();
					mPes.pts += (val&0xfffe)>>1;
					
					mPes.dts = mPes.pts;
				}
				
				if( mPes.escr_flag ) {
					mBuffer.position += 6;
				}
				
				if( mPes.es_rate_flag ) {
					mBuffer.position += 3;
				}
				
				if( mPes.dsm_trick_mode_flag ) {
					mBuffer.position += 1;
				}
				
				if( mPes.additional_copy_info_flag ) {
					mBuffer.position += 1;
				}
				
				if( mPes.crc_flag ) {
					mBuffer.position += 2;
				}
				
				pos2 = mBuffer.position;
				if( pos2-pos1 < mPes.left_len ) {
					mBuffer.position += (mPes.left_len-(pos2-pos1));
				}
				
				//HlsLog.log("TSPacket.parsePes, pid/pts/dts=" + mPts.pid + "," + mPes.pts + "," + mPes.dts);
			}
		}
		
		public function parseAudio() : void {
			
		}
		
		private function readByte() : int {
			return mBuffer.readByte();
		}
		
		private function readShort() : int {
			var b1:int = mBuffer.readByte();
			var b2:int = mBuffer.readByte();
			
			return (b1<<8|b2);
		}
	}
}