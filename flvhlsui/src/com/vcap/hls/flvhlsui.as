package com.vcap.hls
{
	
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.ProgressBar;
	import com.bit101.components.Text;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class flvhlsui extends Sprite
	{
		private var mHlsUrl:String = "http://devimages.apple.com/iphone/samples/bipbop/gear3/prog_index.m3u8";
		private var mTxtUrl:Text = null;
		private var mVideoWnd:Panel = null;
		private var mLabel:Label = null;
		private var mProgressBar:ProgressBar = null;
		
		private var mFlvHls:HlsPlayer = null;
		private var mStarted:Boolean = false;
		private var mPaused:Boolean = false;
		private var mTimer:Timer = null;
		
		public function flvhlsui()
		{
			initUI(0, 0, 480, 340);
			mTimer = new Timer(1000);
			mTimer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		private function initUI(x:int, y:int, w:int, h:int) : void {		
			mTxtUrl = new Text(null, 0, 0, "http://devimages.apple.com/iphone/samples/bipbop/gear3/prog_index.m3u8");
			mTxtUrl.width = w;
			mTxtUrl.height = 20;
			this.addChild(mTxtUrl);
			
			mVideoWnd = new Panel(null, 0, 0);
			mVideoWnd.y = 20;
			mVideoWnd.width = w;
			mVideoWnd.height = h-20;
			mVideoWnd.addEventListener(MouseEvent.CLICK, onVideoClick);
			this.addChild(mVideoWnd);
			
			mLabel = new Label(null, 200, 140, "Click To Play!");
			mLabel.width = 80;
			mLabel.height = 20;
			mLabel.addEventListener(MouseEvent.CLICK, onVideoClick);
			this.addChild(mLabel);
			
			mProgressBar = new ProgressBar(null, 0, h-4);
			mProgressBar.width = w;
			mProgressBar.height = 4;
			mProgressBar.maximum = 100;
			mProgressBar.value = 0;
			mProgressBar.alpha = 0.8;
			mProgressBar.addEventListener(MouseEvent.CLICK, onProgressClick);
			this.addChild(mProgressBar);
		}		
		
		private function startPlay() : void {			
			var url:String = mTxtUrl.text;
			if( url== null || url.length == 0 )
				return;
			
			this.mHlsUrl = url;
			mFlvHls = new HlsPlayer();
			mFlvHls.setVideoWnd(mVideoWnd, 0, 0, 480, 320);
			mFlvHls.play(mHlsUrl);
		}
		
		private function onVideoClick(event:MouseEvent) : void {
			if( !mStarted ) {
				startPlay();
				mStarted = true;
				mLabel.visible = false;
				mTimer.start();
				return;
			}
			mPaused = !mPaused;
			
			if( mPaused ) {
				mFlvHls.pause();
				mLabel.visible = true;
			} else {
				mFlvHls.resume();
				mLabel.visible = false;
			}
		}
		
		private function onProgressClick(event:MouseEvent) : void {
			var x:Number = event.localX;
			var w:Number = mProgressBar.width;
			var total:Number = 0;
			var t:Number = 0;
			
			if( !mStarted ) {
				return;
			}
			
			total = mFlvHls.getTotalTime();
			if( total == 0 )
				return;
			
			t = x/w*total;
			mFlvHls.seek(t);
		}
		
		private function onTimer(event:TimerEvent) : void {
			if( !mStarted )
				return;
			
			var time:Number = mFlvHls.getPlayTime();
			var total:Number = mFlvHls.getTotalTime();
			if( total == 0)
				return;
			
			mProgressBar.value = (time/total)*(mProgressBar.maximum);
		}
	}
}