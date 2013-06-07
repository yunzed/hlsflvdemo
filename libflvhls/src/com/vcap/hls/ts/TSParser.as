/*****************************************************************************
 * TSParser.as: mpegts parser.
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
	import com.vcap.hls.impl.HlsItem;
	import com.vcap.hls.impl.HlsMgr;
	import com.vcap.hls.impl.HlsLog;
	import com.vcap.hls.HlsError;
	
	import flash.utils.ByteArray;

	public class TSParser
	{
		public static const STATE_WAIT_PAT:int = 1;
		public static const STATE_WAIT_PMT:int = 2;
		public static const STATE_WAIT_PAYLOAD:int = 3;
		
		private var mHlsMgr:HlsMgr = null;
		private var mPmtPid:int = 0;		
		private var mAacPid:int = 0;
		private var mH264Pid:int = 0;
		private var mState:int = 0;
		private var mAacFrame:TSFrame = null;
		private var mH264Frame:TSFrame = null;
		//private var mFrames:Vector.<TSFrame> = new Vector.<TSFrame>();
		
		public function TSParser(mgr:HlsMgr)
		{
			this.mHlsMgr = mgr;
			this.mState = STATE_WAIT_PAT;
		}
		
		/**
		 * @function parse
		 * 
		 * parse the content of a AAC/H264 packet of 188 bytes. 
		 */
		public function parse(item:HlsItem) : void {
			var len:int = item.data.length;
			var buf:ByteArray = new ByteArray();
			var rows:int = len/188;
			var frames:Vector.<TSFrame> = new Vector.<TSFrame>();
			var frame:TSFrame = null;
			var audio_num:int = 0;
			var video_num:int = 0;
			
			item.data.position = 0;
			for( var i:int =0; i<rows; i++ ) {
				item.data.readBytes(buf, 0, 188);
				buf.position = 0;
				var packet:TSPacket = new TSPacket(buf);
				frame = parsePacket(packet);
				if( frame != null ) {
					frames.push(frame);
					
					if( frame.getType() == TSStreamType.TS_PACKET_AAC )
						audio_num++;
					else if( frame.getType() == TSStreamType.TS_PACKET_H264 )
						video_num++;
					else {
						HlsLog.error("TSParser.parse, unsupport stream type=" + frame.getType());
						if( mHlsMgr.getListener() ) {
							mHlsMgr.getListener().onError(HlsError.ERROR_TS_MEDIA_FORMAT_NOT_SUPPORT);
						}
					}
				}
			}
			
			//free the members of item.data
			item.data = null;
			item.frames = frames;
		
			//important, this may make the player lost 1 frame, but it's better than get negative rel_stamp.
			this.mAacFrame = null;
			this.mH264Frame = null;
			HlsLog.log("TSParser.parse, seq/frames/video_num/audio_num=" + item.seq + "," + item.frames.length + "," + video_num + "," + audio_num);
		}
		
		public function parsePacket(packet:TSPacket) : TSFrame {
			var frame:TSFrame = null;
			var payload_len:int = 0;
			
			packet.parse();	
			var pid:int = packet.getPts().pid;
			switch(mState) {
				case STATE_WAIT_PAT:
					if( packet.getPts().pid == TSPID.PID_PAT ) {
						packet.parsePat();
						
						if( this.mPmtPid != packet.getPat().pmt_pid ) {
							this.mPmtPid = packet.getPat().pmt_pid;
							this.mState = STATE_WAIT_PMT;
						}
					}
					break;
				case STATE_WAIT_PMT:
					if( packet.getPts().pid != this.mPmtPid ) {
						break;
					} else {
						packet.parsePmt();
						
						this.mAacPid = packet.getPmt().audio_pid;
						this.mH264Pid = packet.getPmt().video_pid;
						this.mState = STATE_WAIT_PAYLOAD;
					}
					break;
				case STATE_WAIT_PAYLOAD:
					if( pid == TSPID.PID_PAT ) {						
						packet.parsePat();
						
						if( this.mPmtPid != packet.getPat().pmt_pid ) {
							this.mPmtPid = packet.getPat().pmt_pid;
							this.mAacPid = 0;
							this.mH264Pid = 0;
							
							this.mState = STATE_WAIT_PMT;
						}
					} else if( pid == TSPID.PID_SDT ) {
						
					} else if( pid == this.mAacPid || pid == this.mH264Pid ) {
						if( packet.getPts().start ) {
							packet.parsePes();
							if( pid == this.mAacPid) {
								frame = this.mAacFrame;
								this.mAacFrame = new TSFrame();
								this.mAacFrame.setType( TSStreamType.TS_PACKET_AAC);
								//set the pts/dts from pes.
								this.mAacFrame.setPts( packet.getPes().pts );
								this.mAacFrame.setDts( packet.getPes().dts );
							} else if( pid == this.mH264Pid ) {
								frame = this.mH264Frame;								
								this.mH264Frame = new TSFrame();
								this.mH264Frame.setType( TSStreamType.TS_PACKET_H264);
								//set the pts/dts from pes.
								this.mH264Frame.setPts( packet.getPes().pts );
								this.mH264Frame.setDts( packet.getPes().dts );								
							}
						} 
						
						if( packet.getPts().adapt_flag == 0x2 ) {
							//no payload.
							break;
						}
						
						if( pid == this.mAacPid ) {
							if( mAacFrame != null ) {
								mAacFrame.addPayload( packet.getPayload() );
							}
						} else if( pid == this.mH264Pid ) {
							if( mH264Frame != null) {
								mH264Frame.addPayload( packet.getPayload() );
							}
						}
					}
					break;
			}
			
			return frame;
		}
	}
}