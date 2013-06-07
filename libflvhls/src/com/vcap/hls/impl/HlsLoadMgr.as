/*****************************************************************************
 * HlsLoadMgr.as: HLS Load manager, which in charge of the .ts load process.
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
	public class HlsLoadMgr
	{
		private var mHlsMgr:HlsMgr = null;
		private var mIndex:int = 0;
		private var mLoadNum:int = 0;
		private var mFileLoader:HlsItemLoader = null;
		
		public function HlsLoadMgr(mgr:HlsMgr)
		{
			mHlsMgr = mgr;
			mFileLoader = new HlsItemLoader(mHlsMgr);
		}
		
		public function start() : void {
			HlsLog.log("HlsLoadmgr.start.");
		}
		
		public function stop() : void {
			HlsLog.log("HlsLoadmgr.stop.");
			mIndex = 0;
		}
		
		public function seek(index:int) : void {
			HlsLog.log("HlsLoadMgr.seek, index=" + index);
			mIndex = index;
			loadNext();
		}
		
		/**
		 * @function loadNext,
		 * 
		 * load the next segment, using the HlsFileLoader.
		 * the HlsItem is fetch from HlsPlayListEx.
		 */
		public function loadNext() : void {			
			var item:HlsItem = mHlsMgr.getPlayListEx().getItem(mIndex);			
			if( item == null ) {
				HlsLog.log("HlsLoadMgr.loadNext failed with index=" + mIndex);
				mIndex++;
				return;
			}
			if( item.data != null || item.frames != null ) {
				HlsLog.log("HlsLoadMgr.loadNext, item already loaded, url=" + item.url);
				mIndex++;
				return;
			}
			
			HlsLog.log("HlsLoadMgr.loadNext, index/url="+ item.seq + "," + item.url);
			mFileLoader.load(item);			
			mIndex++;
		}
		
		public function isLoaded(index:int) : Boolean {
			var item:HlsItem = mHlsMgr.getPlayListEx().getItem(index);
			if( item == null ) {
				HlsLog.log("HlsLoadMgr.isLoaded failed with index=" + mIndex);
				return true;
			}
			
			if( item.data != null || item.frames != null )
				return true;
			
			return false;
		}
		
		public function getLoadNum() : int {
			return mLoadNum;
		}
		
		public function onLoadItem(item:HlsItem) : void {
			if( item == null )
				return;
			
			mLoadNum++;	
			HlsLog.log("HlsLoadmgr.onLoad, num/seq/url=" + mLoadNum + "," + item.seq + "," + item.url);
			var playbuflen:int = mHlsMgr.getPlayer().getPlayBufLen();
			var playindex:int = mHlsMgr.getPlayMgr().getIndex();
			
			if( playbuflen <= 20 && 
				!mFileLoader.isDownloading() && 
				playindex <= mHlsMgr.getPlayListEx().getItemCount()-1 && 
				( !isLoaded(playindex) || !isLoaded(playindex+1) || !isLoaded(playindex+2) || !isLoaded(playindex+3) )  ) {
					HlsLog.log("HlsLoadMgr.onLoad, loadNext, buflen/index=" + playbuflen + "," + mIndex);
					loadNext();
			}			
			
			if( mHlsMgr.getListener() ) {
				mHlsMgr.getListener().onLoadItem(item.seq);
			}
		}
		
		public function onPlayItem(item:HlsItem) : void {
			var playbuflen:int = mHlsMgr.getPlayer().getPlayBufLen();
			var playindex:int = mHlsMgr.getPlayMgr().getIndex();
			
			if( playbuflen <= 20 && 
				!mFileLoader.isDownloading() && 
				playindex <= mHlsMgr.getPlayListEx().getItemCount()-1 && 
				(!isLoaded(playindex+1) || !isLoaded(playindex+2) || !isLoaded(playindex+3) )  ) {
				HlsLog.log("HlsLoadMgr.onPlay, loadNext, buflen/index=" + playbuflen + "," + mIndex);
				loadNext();
			}
		}
	}
}