/*****************************************************************************
 * HlsLRUMgr.as: manage when to release the cache.
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
	import flash.utils.Dictionary;

	public class HlsLRUMgr
	{
		private var mHlsMgr:HlsMgr = null;
		private var mItemMap:Dictionary = new Dictionary();
		
		public function HlsLRUMgr(mgr:HlsMgr)
		{
			mHlsMgr = mgr;
		}
		
		public function setUsed(index:int) : void {
			if( mItemMap.hasOwnProperty(index) ) {
				mItemMap[index] = mItemMap[index] + 100;
			} else {
				mItemMap[index] = 100;
			}
			
			setWillUse(index+1);
			setWillUse(index+2);
			setWillUse(index+3);
		}
		
		/**
		 * @function ttl
		 * 
		 * ttl, will decrease ttl for each loaded segment.
		 * when a segment ttl==0, release the loaded buffer.
		 */
		public function ttl() : void {
			var key:String;
			var value:int = 0;
			
			for( key in mItemMap ) {
				value = mItemMap[key];
				if( value == 0 ) {
					//ttl comes to 0, time to release the cache.
					HlsLog.log("HlsLRUMgr.ttl, time to release seq=" + key);
					//[TBD] release the HlsItem object memory.
					free(int(key));
				} else {
					mItemMap[key]=value-1;
				}
			}
			
			//dump();
		}
		
		public function free(index:int) : void {
			HlsLog.log("HlsLRUMgr.free, index=" + index);
			var item:HlsItem = mHlsMgr.getPlayListEx().getItem(index);
			if( item == null )
				return;
			
			item.frames = null;
			delete mItemMap[index];
		}
		
		private function setWillUse(index:int) : void {
			if( index > mHlsMgr.getPlayListEx().getItemCount()-1 )
				return;
			
			if( mItemMap.hasOwnProperty(index) ) {
				mItemMap[index] = mItemMap[index] + 100;
			} else {
				mItemMap[index] = 100;
			}
		}
		
		private function dump() : void {
			HlsLog.log("");
			for(var key:* in mItemMap ) {
				var  value:int = mItemMap[key];
				
				HlsLog.log("HlsLRUMgr.dump, key/value=" + key + "," + value);
			
			}
			HlsLog.log("");
		}
	}
}