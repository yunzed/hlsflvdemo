/*****************************************************************************
 * HlsPlayMgr.as: Hls Play Mgr, which send the .ts content to NetStream.
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
	import com.vcap.hls.ts.TSStreamType;
	
	import flash.events.TimerEvent;
	import flash.utils.getTimer;

	public class HlsPlayMgr
	{
		private var mHlsMgr:HlsMgr = null;
		private var mIndex:int = 0;
		private var mStarted:Boolean = false;
		private var mLastPlayTS:int = 0;
		
		public function HlsPlayMgr(mgr:HlsMgr)
		{
			this.mHlsMgr = mgr;
		}
		
		public function start() : void {
			mStarted = true;
		}
		
		public function stop() : void {
			mStarted = false;
			mIndex = 0;
		}
		
		public function seek(index:int) : void {
			mIndex = index;
			start();
			playNext();
		}
		
		/**
		 * @function playNext
		 * play the next segment, the segment is identified by mIndex.
		 */
		public function playNext() : Boolean {
			if( !mStarted ) {
				HlsLog.error("HlsLoadMgr.loadNext, not started yet.");
				return false;
			}
			
			if( mIndex > mHlsMgr.getPlayListEx().getItemCount()-1 ) {
				//it's the end of playlist:
				HlsLog.error("HlsPlayMgr.playNext, EOF, index=" + mIndex);
				mStarted = false;
				return false;
			}
			var item:HlsItem = mHlsMgr.getPlayListEx().getItem(mIndex);
			if( item == null ) {
				HlsLog.error("HlsPlayMgr.playNext, getItem failed with index=" + mIndex);
				return false;
			}
			
			if( item.failed || item.retry >= 3 ) {
				//fail to load the item, log and play next:
				HlsLog.error("HlsPlayMgr.playNext, item failed to load, url=" + item.url);
				mIndex++;
				return false;
			}
			
			HlsLog.log("HlsPlayMgr.playNext, index=" + mIndex);
			if( playInternal(item) ) {
				mHlsMgr.getLRUMgr().setUsed(mIndex);
				mHlsMgr.getLoadMgr().onPlayItem(item);
				mIndex++;
			} else {
				//need to do something.
				mHlsMgr.getLoadMgr().onPlayItem(item);
			}
			
			return true;
		}
		
		public function getIndex() : int {
			return mIndex;
		}
		
		private function playInternal(item:HlsItem) : Boolean {
			if( item.frames == null ) {
				HlsLog.error("HlsPlayMgr.playInternal, item.frames==null, index=" + item.seq);
				return false;
			}
			
			HlsLog.log("HlsPlayMgr.playInternal, buflen=" + mHlsMgr.getPlayer().getPlayBufLen());
			for( var i:int = 0; i<item.frames.length; i++ ) {
				if( item.frames[i].getType() == TSStreamType.TS_PACKET_AAC ) {
					mHlsMgr.getAACPlayer().play(item.frames[i]);
				} else if( item.frames[i].getType() == TSStreamType.TS_PACKET_H264 ) {
					mHlsMgr.getH264Player().play(item.frames[i]);
				}
			}
			if( mHlsMgr.getListener() ) {
				mHlsMgr.getListener().onPlayItem(item.seq);
			}
			HlsLog.log("HlsPlayMgr.playInternal, frames/buflen=" + item.frames.length + "," + mHlsMgr.getPlayer().getPlayBufLen());
			
			return true;
		}
		
		public function onTimer(event:TimerEvent) : void {
			if( !mStarted ) {
				return;
			}
			
			var playbuflen:int = mHlsMgr.getPlayer().getPlayBufLen();
			var playtime:Number = mHlsMgr.getPlayer().getPlayTime();
			
			if( playbuflen <= 10 && (getTimer()-this.mLastPlayTS > 1000)  ) {
				playNext();
				this.mLastPlayTS = getTimer();
			}
			
			//run ttl to invalid cache.
			mHlsMgr.getLRUMgr().ttl();
			
			//maybe it's end of the playlist:
			var total_time:int = mHlsMgr.getPlayListEx().getTotalTime();
			if( playtime+1 >= total_time && total_time>0 ) {
				mHlsMgr.stop();
			}
		}
		
		public function onLoadItem(item:HlsItem) : void {
			if( mStarted )
				return;
			
			var status:int = mHlsMgr.getNetStat().getStatus();
			var load_num:int = mHlsMgr.getLoadMgr().getLoadNum();
			switch( status ) {
				case HlsNetStat.HLS_NET_PERFECT:
					start();
					break;
				case HlsNetStat.HLS_NET_QUICK:
					if( load_num > 2 )
						start();
					break;
				case HlsNetStat.HLS_NET_MIDDLE:
					if( load_num >= 3 )
						start();
					break;
				case HlsNetStat.HLS_NET_SLOW:
					if( load_num >= 5 )
						start();
					break;
				case HlsNetStat.HLS_NET_FAIL:
					HlsLog.error("HlsPlayMgr.onLoad, failed network.");
					break;
			}
			HlsLog.log("HlsPlayMgr.onLoad, status/load_num=" + status + "," + load_num);
		}
	}
}