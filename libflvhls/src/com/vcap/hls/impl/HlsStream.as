/*****************************************************************************
 * HlsStream.as: HLS Stream.
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
	import com.vcap.hls.flv.FlvWrapper;
	
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.ByteArray;

	public class HlsStream
	{
		private var mHlsMgr:HlsMgr = null;
		private var mPlayStream:NetStream = null;
		private var mPlayLink:NetConnection = null;	
		private var mVideo:Video = null;
		
		public function HlsStream(mgr:HlsMgr)
		{
			this.mHlsMgr = mgr;
		}
		
		public function start() : void {
			mPlayLink = new NetConnection();
			mPlayLink.client = this;
			mPlayLink.connect(null);
			
			mPlayStream = new NetStream(mPlayLink);	
			mPlayStream.dataReliable = false;
			mPlayStream.bufferTime = 0;
			mPlayStream.client = this;
			mPlayStream.checkPolicyFile = false;
			mPlayStream.bufferTimeMax = 30;
			mPlayStream.bufferTime = 2.0;
			mPlayStream.play(null);
			
			this.mVideo = new Video(mHlsMgr.getVideoWidth(), mHlsMgr.getVideoHeight());
			this.mVideo.attachNetStream( mPlayStream );			
			this.mVideo.x = mHlsMgr.getVideoX();
			this.mVideo.y = mHlsMgr.getVideoY();
			mHlsMgr.getVideoWnd().addChild(mVideo);
			
			var buf:ByteArray = FlvWrapper.getHeader();
			mPlayStream.appendBytes(buf);
			
			if( mHlsMgr.getListener() != null ) {
				mHlsMgr.getListener().onPlayFrame(buf);
			}
		}
		
		public function play(buf:ByteArray) : void {
			mPlayStream.appendBytes(buf);
			
			//callback.
			if( mHlsMgr.getListener() ) {
				mHlsMgr.getListener().onPlayFrame(buf);
			}
		}
		
		public function resume() : void {
			mPlayStream.resume();
		}
		
		public function pause() : void {
			mPlayStream.pause();
		}
		
		public function stop() : void {
			if( mPlayStream != null ) {
				mPlayStream.close();
			}
			if( mVideo != null ) {
				//mHlsMgr.getVideoWnd().removeChild(mVideo);
				mVideo = null;
			}
		}
		
		public function getStream() : NetStream {
			return mPlayStream;
		}
		
		public function getPlayBufLen() : Number {
			return mPlayStream.bufferLength;
		}
		
		public function getPlayTime() : Number {
			return mPlayStream.time/1000;
		}
	}
}