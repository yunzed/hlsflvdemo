/*****************************************************************************
 * HlsPlayListEx.as: top level playlist, this may have muti HlsPlayList.
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
	import com.vcap.hls.HlsError;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	public class HlsPlayListEx
	{
		private var mHlsMgr:HlsMgr = null;
		private var mUrl:String = null;
		private var mBaseUrl:String = null;
		private var mLoader:URLLoader;
		private var mPlayLists:Vector.<HlsPlayList> = new Vector.<HlsPlayList>();
		private var mPlayListLoaded:int = 0;
		private var mTotalTime:Number = 0;
		private var mIndex:int = 0;
		
		public function HlsPlayListEx(mgr:HlsMgr) {
			this.mHlsMgr = mgr;
			this.mLoader = new URLLoader();			
			configureListeners(mLoader);
		}
		
		public function getItemCount() : int {
			if( mPlayLists.length == 0 )
				return 0;
			
			return mPlayLists[mIndex].getItemCount();
		}
		
		public function getTotalTime() : Number {
			if( mPlayLists.length == 0 )
				return 0;
			
			return mPlayLists[mIndex].getTotalTime();
		}
		
		public function getItem(index:int) : HlsItem {
			if( mPlayLists.length == 0 )
				 return null;
			
			return mPlayLists[mIndex].getItem(index);
		}
		
		public function getItemByTime(time:Number) : HlsItem {
			return mPlayLists[mIndex].getItemByTime(time);
		}
		
		public function getTimeByItem(index:int) : Number {
			return mPlayLists[mIndex].getTimeByItem(index);
		}
		
		/**
		 * @function load
		 * 
		 * load the playlist.
		 * @param url playlist url to be loaded.
		 */
		public function load(url:String) : void {
			//maybe it's a playback:
			if( mUrl != null ) {
				if( mUrl == url ) {
					HlsLog.log("HlsPLMgr.load, same url=" + url);
					mHlsMgr.seek(0);
					if( mHlsMgr.getListener() != null ) {
						mHlsMgr.getListener().onLoadPlaylist();
					}
					
					return;
				} else {
					
					mUrl = null;
				}
			}
			
			try {
				this.mUrl = url;
				
				var pos:int = mUrl.lastIndexOf("/");
				if( pos != -1 ) {
					this.mBaseUrl = mUrl.substr(0, pos+1);
				}
				var request:URLRequest = new URLRequest(mUrl);
				mLoader.dataFormat = URLLoaderDataFormat.TEXT;
				mLoader.load(request);
				
			} catch (error:Error) {
				HlsLog.error("Unable to load requested document.");
			}
		}
		
		public function onLoadPL(pl:HlsPlayList) : void {
			mPlayListLoaded++;
			
			if( mPlayListLoaded == mPlayLists.length ) {
				HlsLog.log("HlsAdaptList.onLoaded, all playlist are loaded, len=" + mPlayLists.length);
				
				mHlsMgr.getLoadMgr().loadNext();
			}
		}
		
		public function onLoadItem(item:HlsItem) : void {
			switch( mHlsMgr.getNetStat().getStatus() ) {
				case HlsNetStat.HLS_NET_PERFECT:
					mIndex = findPlayListByBWHigh();
					break;
				case HlsNetStat.HLS_NET_QUICK:
				case HlsNetStat.HLS_NET_MIDDLE:
					mIndex = findPlayListByBWMiddle();
					break;
				case HlsNetStat.HLS_NET_SLOW:
					mIndex = findPlayListByBWMiddle();
					break;
			}
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, onComplete);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
		}
		
		private function onComplete(event:Event):void {
			HlsLog.log("HlsPLMgr.onComplete: " + event);
			var loader:URLLoader = URLLoader(event.target);
			
			var data:String = loader.data;
			if( data.indexOf("#EXT-X-STREAM-INF") != -1 && data.indexOf("#EXTM3U") != -1) {
				//stream with bandwidth.
				HlsLog.log("HlsPLMgr.onComplete, find #EXT-X-STREAM-INF and #EXTM3U");
				parseM3U8(data);
				
				//notify HlsMgr the playlist is ready.
				if( mHlsMgr.getListener() != null ) {
					mHlsMgr.getListener().onLoadPlaylist();
				}
				
			} else {
				var pl:HlsPlayList = new HlsPlayList(mHlsMgr);
				pl.setBaseUrl(mBaseUrl);
				pl.parse(data);
				
				HlsLog.log("HlsPLMgr.onComplete, items=" + pl.getItemCount());
				mPlayLists.push(pl);
				//start the load engine:
				mHlsMgr.getLoadMgr().loadNext();
			}
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void {
			HlsLog.log("HlsPlayList.onSecurityError: " + event);
			
			if( mHlsMgr.getListener() ) {
				mHlsMgr.getListener().onError( HlsError.ERROR_PL_SECURITY_ERROR );
				return;
			} 
		}
		
		private function onIoError(event:IOErrorEvent):void {
			HlsLog.log("HlsPlayList.onIoError: " + event);
			
			if( mHlsMgr.getListener() ) {
				mHlsMgr.getListener().onError( HlsError.ERROR_PL_IO_ERROR );
				return;
			} 
		}
		
		private function parse(data:String) : void {
			var seq:int = 0;
			var pos1:int = 0;
			var pos2:int = 0;
			var line:String = null;
			var line2:String = null;
			var lines:Array = data.split("\n");
			if( lines == null || lines.length == 0 ) {
				return;
			}
			
			for(var i:int = 0; i<lines.length-1; i++ ) {
				line = lines[i];
				
			}
		}
		
		private function parseM3U8(data:String) : void {
			var line:String = null;
			var lines:Array = data.split("\n");
			var segs:Array = null;
			var pos:int = -1;
			var bw:Number = 0;
			var url:String = null;
			
			if( lines == null ) {
				HlsLog.error("HlsAdaptList.parseM3U8, lines==null");
				return;
			}
			for( var i:int = 0; i<lines.length-1; i++ ) {
				line = lines[i];
				if( line.indexOf("#EXT-X-STREAM-INF") == -1 ) {
					continue;
				}
				
				pos = line.indexOf(":");
				if( pos == -1 ) {
					//there must be : after #EXT-X-STREAM-INF;
					continue;
				}
				line = line.substr(pos+1);
				if( line == null || line.length == 0 )
					continue;
				
				segs = line.split(",");
				if( segs == null || segs.length == 0 ) {
					HlsLog.error("HlsAdaptList.parseM3U8, segs==null, line=" + line);
					continue;
				}
				
				for( var j:int = 0; j<segs.length; j++ ) {
					var seg:String = segs[j];
					pos = seg.indexOf("BANDWIDTH");
					if( pos == -1 ) {
						//only handle the item with BANDWIDTH attr.
						continue;
					}
					
					seg = seg.substr(pos);
					pos = seg.indexOf("=");
					if( pos == -1 ) {
						HlsLog.error("HlsAdaptList.parseM3U8, fail to find = after bandwidth, line=" + line);
						continue;
					}
					
					seg = seg.substr(pos+1);
					bw = Number(seg);
					url = lines[i+1];
					url.toLowerCase();
					
					if( url.indexOf("http://") == -1 ) {
						url = mBaseUrl + url;
					}
					var pl:HlsPlayList = new HlsPlayList(mHlsMgr);
					pl.setBandwidth(bw);
					pl.load(url);
					
					mPlayLists.push(pl);
				}
			}
			
			mIndex = findPlayListLeastBW();
		}
		
		private function findPlayListLeastBW() : int {
			var bw:int = 0;
			var index:int = 0;
			
			if( mPlayLists.length == 0 )
				return -1;
			
			if( mPlayLists.length == 1 )
				return 0;
			
			bw = mPlayLists[0].getBandwidth();
			for( var i:int = 0; i<mPlayLists.length; i++ ) {
				if( bw > mPlayLists[i].getBandwidth() ) {
					bw = mPlayLists[i].getBandwidth();
					index = i;
				}
			}
			
			return index;
		}
		
		private function findPlayListByBWHigh() : int {
			var bw:int = 0;
			var index:int = 0;
			
			if( mPlayLists.length == 0 )
				return -1;
			
			if( mPlayLists.length == 1 )
				return 0;
			
			bw = mPlayLists[0].getBandwidth();
			for( var i:int = 0; i<mPlayLists.length; i++ ) {
				if( bw < mPlayLists[i].getBandwidth() ) {
					bw = mPlayLists[i].getBandwidth();
					index = i;
				}
			}
			
			return index;	
		}
		
		private function findPlayListByBWMiddle() : int {
			if( mPlayLists.length<=2 )
				return findPlayListLeastBW();
			
			var low:int = findPlayListLeastBW();
			var high:int = findPlayListByBWHigh();
			
			var bw:int = 0;
			var index:int = 0;
			for( var i:int = 0; i<mPlayLists.length; i++ ) {
				if( mPlayLists[i].getBandwidth() > low && mPlayLists[i].getBandwidth()<high ) {
					index = i;
					break;
				}
			}
			
			return index;	
		}
	}
}