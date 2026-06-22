package jp.co.nikkiso.ntss.data_gathering.service;

import jp.co.nikkiso.ntss.data_gathering.entity.MntMotionRecord;


public interface MntMotionRecordService
{
	MntMotionRecord findMaxNo();
	
	int insert(MntMotionRecord motionRecord);
}
