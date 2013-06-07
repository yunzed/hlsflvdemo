package com.vcap.hls.impl
{
	public class HlsDisplay
	{
		private var mVideoWnd:Object = null;
		private var mX:int = 0;
		private var mY:int = 0;
		private var mWidth:int = 0;
		private var mHeight:int = 0;
		
		public function HlsDisplay()
		{
		}
		
		public function setVideoWnd(wnd:Object, x:int, y:int, width:int, height:int) : void {
			HlsLog.log("HlsDisplay.setVideoWnd, width/height=" + width + "," + height);
			
			mX = x;
			mY = y;
			mVideoWnd = wnd;
			mWidth=width;
			mHeight=height;
		}
		
		public function getVideoWnd() : Object {
			return mVideoWnd;
		}
		
		public function getVideoX() : int {
			return mX;
		}
		
		public function getVideoY() : int {
			return mY;
		}
		
		public function getVideoWidth() : int {
			return mWidth;
		}
		
		public function getVideoHeight() : int {
			return mHeight;
		}
	}
}