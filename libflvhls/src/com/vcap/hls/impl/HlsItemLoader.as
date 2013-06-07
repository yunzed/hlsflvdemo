/*****************************************************************************
 * HlsFileLoader.as: Hls File Loader, which load the .ts segments.
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
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.getTimer;

	public class HlsItemLoader
	{		
		private var mHlsMgr:HlsMgr = null;
		private var mItem:HlsItem = null;
		private var mLoader:URLLoader;
		private var mDownloading:Boolean = false;
		private var mStartTime:int = 0;
		private var mEndTime:int = 0;
		
		public function HlsItemLoader(mgr:HlsMgr) {
			this.mHlsMgr = mgr;
			this.mLoader = new URLLoader();			
			configureListeners(mLoader);
		}
		
		/**
		 * @function load
		 * load a segment whose url is in the item parameter.
		 * 
		 * @param item a HlsItem object which reprsentive a segment.
		 */
		public function load(item:HlsItem) : Boolean {
			try {
				if( item == null || item.url == null ) {
					return false;
				}
				HlsLog.log("HlsFileLoader.load, url=" + item.url);
				
				if( item.data != null || item.frames != null ) {
					HlsLog.error("HlsFileLoader.load, already loaded, why load again?");
					return false;
				}
				this.mItem = item;
				this.mItem.loading = true;
				this.mDownloading = true;
				this.mStartTime = getTimer();
				
				var request:URLRequest = new URLRequest(mItem.url);
				mLoader.dataFormat = URLLoaderDataFormat.BINARY;
				mLoader.load(request);
			} catch (error:Error) {
				HlsLog.error("HlsFileLoader.load, exception=" + error.message);
				return false;
			}
			
			return true;
		}
		
		/**
		 * @function isDownloading
		 * 
		 * Flag if the downloading is going on, this is to void download multiple segments at the same time.
		 */
		public function isDownloading() : Boolean {
			return mDownloading;
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, onComplete);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
		}
		
		private function onComplete(event:Event):void {			
			var loader:URLLoader = URLLoader(event.target);
			this.mItem.loaded = true;
			this.mItem.data = loader.data;
			this.mDownloading = false;
			this.mEndTime = getTimer();
			
			//do speed test:
			var time:Number = (mEndTime-mStartTime)/1000;
			mHlsMgr.getNetStat().addSample(mItem.data.length/1000, time, mItem.duration);
			
			//parse the packets:
			HlsLog.log("HlsFileLoader.onComplete, length/time/url=" + mItem.data.length/1000 + "," + time + "," + mItem.url );
			mHlsMgr.getTSParser().parse(mItem);
			
			//update load mgr and play mgr:
			mHlsMgr.getLoadMgr().onLoadItem(mItem);
			mHlsMgr.getPlayMgr().onLoadItem(mItem);
			mHlsMgr.getPlayListEx().onLoadItem(mItem);
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void {
			HlsLog.log("HlsFileLoader.onSecurityError: " + event);
			mItem.loading = false;
			if( mItem.retry >= 3 ) {
				mItem.failed = true;
			} else {
				this.mItem.retry++;
			}
			this.mDownloading = false;
		}
		
		private function onIoError(event:IOErrorEvent):void {
			HlsLog.log("HlsFileLoader.onIoError: " + event);
			mItem.loading = false;
			if( mItem.retry >= 3 ) {
				mItem.failed = true;
			} else {
				this.mItem.retry++;
			}
			this.mDownloading = false;
		}
	}
}