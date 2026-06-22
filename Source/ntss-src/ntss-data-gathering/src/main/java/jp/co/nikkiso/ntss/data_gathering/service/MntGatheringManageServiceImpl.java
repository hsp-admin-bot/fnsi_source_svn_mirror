package jp.co.nikkiso.ntss.data_gathering.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.data_gathering.dao.MntGatheringManageDaoDataGathering;
import jp.co.nikkiso.ntss.data_gathering.entity.MntGatheringManage;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;


@Service
public class MntGatheringManageServiceImpl implements MntGatheringManageService
{
	@Autowired
	private MntGatheringManageDaoDataGathering gatheringManageDao;
	
	@Autowired
	private LogService logService;
	
	@Override
	public MntGatheringManage findMaxNo()
	{
		MntGatheringManage data;
		try
		{
			data = gatheringManageDao.selectMaxNo();
		}
		catch (Exception e)
		{
			data = null;
			EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
			logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"MntGatheringManageDao/selectMaxNo");
		}
		return data;
	}
	
	@Override
	public List<MntGatheringManage> findById(long gatheringManageNo)
	{
		List<MntGatheringManage> data;
		try
		{
			data = gatheringManageDao.selectById(gatheringManageNo);
		}
		catch (Exception e)
		{
			data = null;
			
			EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
			eventLogMessage.setSqlIdentification("(gathering_manage_no = " + gatheringManageNo + ")");
			logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"MntGatheringManageDao/selectById");
		}
		return data;
	}
	
	@Override
	public int insert(MntGatheringManage gatheringManage)
	{
		int ret;
		try
		{
			ret = gatheringManageDao.insert(gatheringManage);
		}
		catch (Exception e)
		{
			ret = -1;
			
			EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
			eventLogMessage.setSqlIdentification("(facility_cd = " + gatheringManage.getFacilityCd() + ", gathering_manage_no = " + gatheringManage.getGatheringManageNo() + 
					", gathering_status = " + gatheringManage.getGatheringStatus() + ", gathering_info = " + gatheringManage.getGatheringInfo() + 
					", ope_info = " + gatheringManage.getOpeInfo() + ", parent_manage_no = " + gatheringManage.getParentManageNo() + "userId = " + gatheringManage.getUserId() + 
					", reg_date = " + gatheringManage.getRegDate() + ", up_date = "+ gatheringManage.getUpDate() + ")");
			eventLogMessage.setFacilityCd(gatheringManage.getFacilityCd());
			eventLogMessage.setUserId(String.valueOf(gatheringManage.getUserId()));
			logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"MntGatheringManageDao/insert");
		}
		return ret;
	}
	
	@Override
	public int update(MntGatheringManage gatheringManage)
	{
		int ret;
		try
		{
			ret = gatheringManageDao.update(gatheringManage);
		}
		catch (Exception e)
		{
			ret = -1;
			
			EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
			eventLogMessage.setSqlIdentification("(gathering_manage_no = " + gatheringManage.getGatheringManageNo() +", gathering_status = " + gatheringManage.getGatheringStatus() + ", gathering_info = " + gatheringManage.getGatheringInfo() + 
					", up_date = "+ gatheringManage.getUpDate() + ")");
			eventLogMessage.setFacilityCd(gatheringManage.getFacilityCd());
			eventLogMessage.setUserId(String.valueOf(gatheringManage.getUserId()));
			logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"MntGatheringManageDao/insert");
		}
		return ret;
	}
}
