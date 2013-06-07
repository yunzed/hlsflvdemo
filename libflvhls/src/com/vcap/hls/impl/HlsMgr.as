/*****************************************************************************
 * HlsMgr.as: center manager of HlsPlayer.
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
	import com.vcap.hls.IHlsListener;
	import com.vcap.hls.aac.AACPlayer;
	import com.vcap.hls.h264.H264Player;
	import com.vcap.hls.ts.TSParser;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class HlsMgr
	{
		private var mPlayListEx:HlsPlayListEx = null;
		private var mTSParser:TSParser = null;
		private var mPlayer:HlsStream = null;
		private var mAACPlayer:AACPlayer = null;
		private var mH264Player:H264Player = null;
		private var mDisplay:HlsDisplay = null;
		private var mBandwidth:int = 0;
		
		private var mListener:IHlsListener = null;
		private var mSeekInfo:HlsSeekInfo = null;
		private var mStatus:HlsStatus = null;
		private var mPlayMgr:HlsPlayMgr = null;
		private var mLoadMgr:HlsLoadMgr = null;
		private var mLRUMgr:HlsLRUMgr = null;
		private var mNetStat:HlsNetStat = null;
		
		private var mTimer:Timer = null;
			
		public function HlsMgr()
		{
			mPlayListEx = new HlsPlayListEx(this);
			mTSParser = new TSParser(this);
			mPlayer = new HlsStream(this);	
			mAACPlayer = new AACPlayer(this);
			mH264Player = new H264Player(this);
			mDisplay = new HlsDisplay();
			mSeekInfo = new HlsSeekInfo(this);
			mStatus = new HlsStatus();
			mPlayMgr = new HlsPlayMgr(this);
			mLoadMgr = new HlsLoadMgr(this);
			mLRUMgr = new HlsLRUMgr(this);
			mNetStat = new HlsNetStat();
			
			mTimer = new Timer(1000, 0);
			mTimer.addEventListener(TimerEvent.TIMER, onTimer);
			mTimer.start();
		}
		
		public function play(url:String) : int {
			HlsLog.log("HlsMgr.play, url=" + url);
			
			if( !HlsUtil.isValidUrl(url) ) {
				HlsLog.error("HlsMgr.play, invalid url=" + url);
				return HlsError.ERROR_PL_INVALID_FORMAT;
			}

			mStatus.setStatus( HlsStatus.HLS_STATUS_LOADING_PL );
			stop();
			start();
			mPlayListEx.load(url);
			
			return HlsError.ERROR_OK;
		}
		
		public function start() : void {
			HlsLog.log("HlsMgr.start");
			mPlayer.start();
			mPlayMgr.start();
			mLoadMgr.start();
		}
		
		public function pause() : void {
			mStatus.setStatus( HlsStatus.HLS_STATUS_PAUSED );
			mPlayer.pause();
		}
		
		public function resume() : void {
			mStatus.setStatus( HlsStatus.HLS_STATUS_PLAYING );
			mPlayer.resume();
		}
		
		public function stop() : void {
			HlsLog.log("HlsMgr.stop");
			mStatus.setStatus( HlsStatus.HLS_STATUS_STOPPED );
			mPlayer.stop();
			mPlayMgr.stop();
			mLoadMgr.stop();
			mSeekInfo.stop();
			mAACPlayer.stop();
			mH264Player.stop();
		}
		
		public function seek(time:Number) : int {
			HlsLog.log("HlsMgr.seek, index=" + time);
			
			var index:int = 0;
			var item:HlsItem = mPlayListEx.getItemByTime(time);
			var seek_time:Number = 0;
			
			if( item == null ) {
				HlsLog.error("HlsMgr.seek, getItemByTime failed.");
				return HlsError.ERROR_FAIL;
			}
			index = item.seq;
			seek_time = mPlayListEx.getTimeByItem(index);
			
			if( index < 0 )
				index = 0;
			if( index>=mPlayListEx.getItemCount()-1 )
				index=mPlayListEx.getItemCount()-1;
			
			mStatus.setStatus( HlsStatus.HLS_STATUS_SEEKING );
			mH264Player.stop();
			mAACPlayer.stop();
			mPlayer.stop();
			mPlayer.start();
			
			HlsLog.log("HlsMgr.seek, bufplay=" + mPlayer.getPlayBufLen());
			mLoadMgr.seek(index);
			mPlayMgr.seek(index);	
			mSeekInfo.seek(seek_time);
			
			return HlsError.ERROR_OK;
		}
		
		public function getPlayTime() : Number {
			var seek:int = mSeekInfo.getSeek();
			if( seek == 0 )
				return mPlayer.getPlayTime();
			else {
				return mSeekInfo.getSeek();
			}
		}
		
		public function getCurIndex() : int {
			var time:Number = getPlayTime();
			var item:HlsItem = mPlayListEx.getItemByTime(time);
			if( item == null ) {
				HlsLog.log("HlsMgr.getCurIndex, item==null, time=" + time);
				return -1;
			}
			
			return item.seq + mSeekInfo.getSeek();
		}
		
		public function getTotalTime() : int {
			return mPlayListEx.getTotalTime();
		}
		
		public function getPlayListEx() : HlsPlayListEx {
			return mPlayListEx;
		}
		
		/*
		public function getFileLoader() : HlsItemLoader {
			return mFileLoader;
		}
		*/
		
		public function getTSParser() : TSParser {
			return mTSParser;
		}
		
		public function getAACPlayer() : AACPlayer {
			return mAACPlayer;
		}
		
		public function getH264Player() : H264Player {
			return mH264Player;
		}

		public function getPlayer() : HlsStream {
			return mPlayer;
		}
		
		public function setVideoWnd(wnd:Object, x:int, y:int, width:int, height:int) : void {
			HlsLog.log("HlsMgr.setVideoWnd, width/height=" + width + "," + height);
			
			mDisplay.setVideoWnd(wnd, x, y, width, height);
		}
		
		public function getVideoWnd() : Object {
			return mDisplay.getVideoWnd();
		}
		
		public function getVideoX() : int {
			return mDisplay.getVideoX();
		}
		
		public function getVideoY() : int {
			return mDisplay.getVideoY();
		}
		
		public function getVideoWidth() : int {
			return mDisplay.getVideoWidth();
		}
		
		public function getVideoHeight() : int {
			return mDisplay.getVideoHeight();
		}
		
		public function setBandwidth(bw:int) : void {
			this.mBandwidth = bw;
		}
		
		public function getBandwidth() : int {
			return mBandwidth;
		}
		
		public function setListener(listener:IHlsListener) : void {
			if( listener ) {
				HlsLog.error("HlsMgr.setListener, listener==null.");
			}
			mListener = listener;
		}
		
		public function getListener() : IHlsListener {
			return mListener;
		}
		
		public function getStatus() : HlsStatus {
			return mStatus;
		}
		
		public function getPlayMgr() : HlsPlayMgr {
			return mPlayMgr;
		}
		
		public function getLoadMgr() : HlsLoadMgr {
			return mLoadMgr;
		}
		
		public function getSeekInfo() : HlsSeekInfo {
			return mSeekInfo;
		}
		
		public function getLRUMgr() : HlsLRUMgr {
			return mLRUMgr;
		}
		
		public function getNetStat() : HlsNetStat {
			return mNetStat;
		}
		
		private function onTimer(event:TimerEvent) : void {
			mPlayMgr.onTimer(event);			
			mLRUMgr.ttl();
		}
	}
}