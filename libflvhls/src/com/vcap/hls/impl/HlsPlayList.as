/*****************************************************************************
 * HlsPlayList.as: HLS Playlist, which parse.
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

	public class HlsPlayList
	{
		private var mHlsMgr:HlsMgr = null;
		private var mBandwidth:int = 0;
		private var mUrl:String = null;
		private var mBaseUrl:String = null;
		private var mLoader:URLLoader;
		private var mItems:Vector.<HlsItem> = new Vector.<HlsItem>();
		private var mTotalTime:Number = 0;
		
		public function HlsPlayList(mgr:HlsMgr) {
			this.mHlsMgr = mgr;
			this.mLoader = new URLLoader();			
			configureListeners(mLoader);
		}
		
		public function setBaseUrl(url:String) : void {
			mBaseUrl = url;
		}
		
		public function setBandwidth(bw:int) : void {
			mBandwidth = bw;
		}
		
		public function getBandwidth() : int {
			return mBandwidth;
		}
		
		public function getItemCount() : int {
			return mItems.length;
		}
		
		public function getTotalTime() : Number {
			if( mTotalTime != 0 ) 
				return mTotalTime;
				
			for( var i:int =0; i<mItems.length; i++ ) {
				mTotalTime += mItems[i].duration;
			}
			
			return mTotalTime;
		}
		
		public function getItem(index:int) : HlsItem {
			if( index<0 || index>=mItems.length )
				return null;
			
			return mItems[index];
		}
		
		public function getItemByTime(time:Number) : HlsItem {
			var total_time:Number = 0;
			var item:HlsItem = null;
			
			HlsLog.log("HlsPlayList.getItemByTime, time=" + time);
			for( var i:int =0; i<mItems.length; i++ ) {
				total_time += mItems[i].duration;
				if( total_time> time ) {
					item = mItems[i];
					break;
				}
			}
			
			return item;
		}
		
		public function getTimeByItem(index:int) : Number {
			if( index <0 || index>= mItems.length )
				return 0;
			
			var total_time:Number = 0;
			var item:HlsItem = null;
			for( var i:int =0; i<index; i++ ) {
				total_time += mItems[i].duration;
			}
			
			return total_time;
		}
		
		/**
		 * @function load
		 * 
		 * load the url playlist.
		 */
		public function load(url:String) : void {
			//maybe it's a playback:
			if( mUrl != null ) {
				if( mUrl == url ) {
					HlsLog.log("HlsPlayList.load, same url=" + url);
					mHlsMgr.getLoadMgr().seek(0);
					mHlsMgr.getPlayMgr().start();
					if( mHlsMgr.getListener() != null ) {
						mHlsMgr.getListener().onLoadPlaylist();
					}
					
					return;
				} else {
					mItems.splice(0, mItems.length);
					mUrl = null;
				}
			}
			
			try {
				this.mUrl = url;
				this.mItems.splice(0, mItems.length);				
				
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
		
		/**
		 * @function parse
		 * parse the .m3u playlist.
		 * 
		 * @param data the m3u playlist content.
		 */
		public function parse(data:String) : void {
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
				
				if( line.indexOf("#EXTINF") == 0 ) {
					var duration:Number = 0;
					pos1=line.indexOf(":");
					if( pos1 != -1 ) {
						
						pos2 = line.indexOf(",");
						if( pos2 == -1 ) {
							
						} else {
							var str:String = line.substr(pos1+1, pos2-pos1-1);
							duration = Number(str);
						}
					}
					
					
					line2 = lines[i+1];
					if( line2.indexOf("://") != 0 ) {
						line2 = this.mBaseUrl + line2;
					}
					
					var item:HlsItem = new HlsItem();
					item.url = line2;
					item.seq = seq;		
					item.duration = duration;
					mItems.push(item);
					seq++;
					
					i++;
				} else if( line.indexOf("EXT-X-STREAM-INF") == 0 ) {
					
					
				} else if( line.indexOf("#EXT-X-ENDLIST") == 0 ) {
					break;
				}
			}
		}
		
		public function getTime(index:int) : Number {			
			if( index < 0 )
				return 0;
			if( index>= mItems.length-1 ) 
				index = mItems.length;
			
			var time:Number = 0;
			for( var i:int = 0; i<index; i++ ) {
				time += mItems[i].duration;
			}
			
			return time;
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, onComplete);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
		}
		
		private function onComplete(event:Event):void {
			HlsLog.log("HlsPlayList.onComplete: " + event);
			var loader:URLLoader = URLLoader(event.target); 
			parse( loader.data );
			
			HlsLog.log("HlsPlayList.onComplete, items=" + this.mItems.length);
			if( mItems.length == 0 && mHlsMgr.getListener() ) {
				mHlsMgr.getListener().onError( HlsError.ERROR_PL_NO_ITEM );
				return;
			} 
			
			//notify HlsMgr the playlist is ready.
			//mHlsMgr.getLoadMgr().start();
			mHlsMgr.getPlayListEx().onLoadPL(this);
			if( mHlsMgr.getListener() != null ) {
				mHlsMgr.getListener().onLoadPlaylist();
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
	}
}