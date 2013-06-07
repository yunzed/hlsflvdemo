/*****************************************************************************
 * H264Player.as: H264 player.
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
	import com.vcap.hls.flv.FlvWrapper;
	import com.vcap.hls.impl.HlsLog;
	import com.vcap.hls.impl.HlsMgr;
	import com.vcap.hls.ts.TSFrame;
	
	import flash.utils.ByteArray;

	public class H264Player
	{
		private var mHlsMgr:HlsMgr = null;
		private var mH264Parser:H264Parser = null;
		private var mLastTS:uint = 0;
		private var mFirstFrame:Boolean = true;
		
		public function H264Player(mgr:HlsMgr)
		{
			mHlsMgr = mgr;
			mH264Parser = new H264Parser();
		}
		
		public function play(frame:TSFrame) : void {
			var payload:ByteArray = frame.getPayload();
			var nalus:Vector.<H264Nalu> = mH264Parser.parse(payload);
			var avcbuf:ByteArray = null;
			var fullbuf:ByteArray = new ByteArray();
			var playbuf:ByteArray = null;
			var rel_stamp:int = 0;
			var key_frame:Boolean = false;
			
			var spsnalu:H264Nalu = null;
			var ppsnalu:H264Nalu = null;
			
			for( var i:int = 0; i<nalus.length; i++ ) {
				if( nalus[i].type == H264Nalu.NALU_SPS ) {
					spsnalu = nalus[i];
					//HlsLog.log("sps: " + spsnalu.payload.length);
					//HlsLog.hex(spsnalu.payload);
				}
				else if( nalus[i].type == H264Nalu.NALU_PPS ) {
					ppsnalu = nalus[i];
					//HlsLog.log("pps: " + ppsnalu.payload.length);
					//HlsLog.hex(ppsnalu.payload);
				}
				else if( nalus[i].type == H264Nalu.NALU_IDR ) {
					key_frame = true;
					//HlsLog.log("slice: " + datanalu.payload.length);
				}
			}			
			//HlsLog.log("HlsH264Player.play, len/pts/dts/rel_stamp/pts_dts_diff=" + payload.length + "," + frame.getPts() + "," + frame.getDts() + "," + rel_stamp + "," + (frame.getPts()-frame.getDts())/90);
			
			if( key_frame ) {				
				if( spsnalu != null && ppsnalu != null ) {
					if( this.mFirstFrame ) 
					{
						avcbuf = FlvWrapper.getAVCConfig(spsnalu, ppsnalu);
						playbuf = FlvWrapper.getVideoTag(avcbuf, 0, true, 0, 0);
						mHlsMgr.getPlayer().play( playbuf );
						
						mFirstFrame = false;
						
						/*
						//callback:
						if( mHlsMgr.getListener() ) {
							mHlsMgr.getListener().onPlayFrame(playbuf);
						}
						*/
						
						HlsLog.log("H264Player.play, output PPS/SPS.");
					}
				} else {
					HlsLog.error("H264Player.play, sps&pps==null, but this is key frame.");
					return;
				}				
				
			} else {
				if( this.mFirstFrame ) {
					//the first play frame must be key frame.
					return;
				}
			}
				
			//calc the rel_stamp:
			if( mLastTS == 0 ) {
				mLastTS = frame.getPts();
				rel_stamp = 0;
			} else {
				rel_stamp = frame.getPts()-mLastTS;
				rel_stamp = rel_stamp/90;
			}
			
			//output the frame now:
			for( i = 0; i<nalus.length; i++ ) {
				fullbuf.writeBytes( nalus[i].payload );
			}
			fullbuf.position = 0;
					
			//HlsLog.hex(datanalu.payload);
			playbuf = FlvWrapper.getVideoTag(fullbuf, 1, key_frame, rel_stamp, (frame.getPts()-frame.getDts())/90);
			mHlsMgr.getPlayer().play( playbuf );
		}
		
		public function stop() : void {
			HlsLog.log("H264Player.stop.");
			mLastTS = 0;
			mFirstFrame = true;
		}
		
		private function isSame(pps1:ByteArray, pps2:ByteArray) : Boolean {
			if( pps1.length != pps2.length )
				return false;
			
			for( var i:int = 0; i<pps1.length; i++ ) {
				if( pps1[i] != pps2[i] )
					return false;
			}
			return true;
		}
	}
}