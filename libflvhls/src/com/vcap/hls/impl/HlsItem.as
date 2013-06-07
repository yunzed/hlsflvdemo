/*****************************************************************************
 * HlsItem.as: Hls Item, a HLS segment.
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
	import com.vcap.hls.ts.TSFrame;
	
	import flash.utils.ByteArray;

	public class HlsItem
	{
		public var url:String = null;		//url like http://devimages.apple.com/iphone/samples/bipbop/gear3/fileSequence4.ts
		public var seq:int = 0;				//seq in playlist, 4 for fileSequence4.ts
		public var duration:Number = 0;		//duration in playlist, like 8.00(s)
		public var loading:Boolean = false;	//this item is being loading
		public var loaded:Boolean = false;	//this item is loaded
		public var data:ByteArray = null;	//the data content, usually the content of a .ts file.
		public var retry:int = 0;			//max retry: 3
		public var failed:Boolean = false;	//retry too many times.
		public var frames:Vector.<TSFrame> = null;
	}
}