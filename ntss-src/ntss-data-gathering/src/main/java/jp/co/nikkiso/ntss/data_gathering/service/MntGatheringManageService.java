package jp.co.nikkiso.ntss.data_gathering.service;

import java.util.List;
import jp.co.nikkiso.ntss.data_gathering.entity.MntGatheringManage;


public interface MntGatheringManageService
{
	MntGatheringManage findMaxNo();
	
	List<MntGatheringManage> findById(long gatheringManageNo);
	
	int insert(MntGatheringManage gatheringManage);
	
	int update(MntGatheringManage gatheringManage);
}
