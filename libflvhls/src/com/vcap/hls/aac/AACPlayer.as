/*****************************************************************************
 * AACPlayer: AAC Player for FLV.
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
package com.vcap.hls.aac
{
	import com.vcap.hls.flv.FlvWrapper;
	import com.vcap.hls.impl.HlsLog;
	import com.vcap.hls.impl.HlsMgr;
	import com.vcap.hls.ts.TSFrame;
	
	import flash.utils.ByteArray;

	public class AACPlayer
	{
		private var mHlsMgr:HlsMgr = null;
		private var mAdtsHeadLen:int = 0;
		private var mLastTS:uint = 0;
		
		public function AACPlayer(mgr:HlsMgr)
		{
			this.mHlsMgr = mgr;
		}
		
		public function play(frame:TSFrame) : void {
			var frameLen:int = getAacFrameLength(frame.getPayload(), 0);
			var payload:ByteArray = frame.getPayload();
			var buf:ByteArray = null;
			var rel_stamp:int = 0;
			
			//if(payload.length < 50 )
			//	return;
			if( frame.getPts() > 0xf0000000 )
				return;
			
			payload.position = 0;
			if( mLastTS == 0 ) {
				mLastTS = frame.getPts();
				rel_stamp = 0;
				
				//output AAC config header:
				/*
					5 bits: object type
					if (object type == 31)
					6 bits + 32: object type
					4 bits: frequency index
					if (frequency index == 15)
					24 bits: frequency
					4 bits: channel configuration
					var bits: AOT Specific Config
				 */
				var profile:int = ((payload[2]&0xc0)>>6)+1;
				var sample_rate:int = (payload[2]&0x3c)>>2;
				var channel:int = ((payload[2]&0x1)<<2)|((payload[3]&0xc0)>>6);
				
				var config1:int = (profile<<3)|((sample_rate&0xe)>>1);
				var config2:int = ((sample_rate&0x1)<<7)|(channel<<3);
				
				var aacSeqHeader:ByteArray = new ByteArray();
				aacSeqHeader.writeByte(config1);
				aacSeqHeader.writeByte(config2);
				var header:ByteArray = FlvWrapper.getAudioTag(aacSeqHeader, 0, 2, 0, 0x00);
				mHlsMgr.getPlayer().play(header);
				
				HlsLog.log("AACPlayer.play, mLastTS=" + this.mLastTS);
			} else {
				rel_stamp = (frame.getPts() - this.mLastTS)/90;
				
				if( rel_stamp < -10000 ) {
					HlsLog.error("AACPlayer.play, rel_stamp problem, rel_stamp=" + rel_stamp);
				}
			}
			//HlsLog.log("AACPlayer.play, len/pts/dts/rel_stamp=" + payload.length + "," + frame.getPts() + "," + frame.getDts() + "," + rel_stamp);
			//buf = FlvWrapper.getAudioTag(0xaf, payload, mAdtsHeaderLen, payload.length-mAdtsHeaderLen, frame.getPts()/90, 0x01);
			buf = FlvWrapper.getAudioTag(payload, mAdtsHeadLen, payload.length-mAdtsHeadLen, rel_stamp, 0x01);
			mHlsMgr.getPlayer().play(buf);
		}
		
		public function stop() : void {
			HlsLog.log("AACPlayer.stop");	
			this.mLastTS = 0;
		}
		
		private function getAacFrameLength(bytes:ByteArray, pos:uint):int {
			mAdtsHeadLen = (bytes[pos + 1] & 0x01) ? 7 : 9;
			var h:uint = bytes[pos + 3] & 0x03;
			var m:uint = bytes[pos + 4];
			var l:uint = (bytes[pos + 5] >> 5) & 0x07;
			
			return ((h << 11 | m << 3 | l) - mAdtsHeadLen);
		}
	}
}