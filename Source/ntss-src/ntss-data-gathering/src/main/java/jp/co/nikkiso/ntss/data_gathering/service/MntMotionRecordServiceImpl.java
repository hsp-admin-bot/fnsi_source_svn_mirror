package jp.co.nikkiso.ntss.data_gathering.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.data_gathering.dao.MntMotionRecordDaoDataGathering;
import jp.co.nikkiso.ntss.data_gathering.entity.MntMotionRecord;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;


@Service
public class MntMotionRecordServiceImpl implements MntMotionRecordService
{
	@Autowired
	private MntMotionRecordDaoDataGathering motionRecordDao;
	
	@Autowired
	private LogService logService;
	
	@Override
	public MntMotionRecord findMaxNo()
	{
		MntMotionRecord data;
		try
		{
			data = this.motionRecordDao.selectMaxNo();
		}
		catch (Exception e)
		{
			data = null;
			
			EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
			logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "MntMotionRecordDao/selectMaxNo");
		}
		return data;
	}
	
	@Override
	public int insert(MntMotionRecord motionRecord)
	{
		int ret;
		try
		{
			ret = this.motionRecordDao.insert(motionRecord);
		}
		catch (Exception e)
		{
			ret = -1;
			
			EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
			eventLogMessage.setDeviceEdgeNo(String.valueOf(motionRecord.getDeviceEdgeNo()));
			eventLogMessage.setMachineTypeCd(motionRecord.getMachineTypeCd());
			eventLogMessage.setSqlIdentification("(motion_record_no = " + motionRecord.getMotionRecordNo() +", event_reg_date = " + motionRecord.getEventRegDate() + ", m_notice_status = " + motionRecord.getMNoticeStatus() + 
					", facility_cd = "+ motionRecord.getFacilityCd() + ", device_edge_no = " + motionRecord.getDeviceEdgeNo() + ", machine_type_cd = " + motionRecord.getMachineTypeCd() + ", machine_serial = " + motionRecord.getMachineSerial() + 
					", com_format_cd" + motionRecord.getComFormatCd() + ", data_type = " + motionRecord.getDataType() + ", test_type = " + motionRecord.getTestType() + ", gathering_manage_no = " + motionRecord.getGatheringManageNo() + 
					", email_send_date = "+ motionRecord.getEmailSendDate() + ", email_text = " + motionRecord.getEmailText() + ", machine_record_cd" + ", machine_record_message = " + motionRecord.getMachineRecordMessage() + ", contents = " + motionRecord.getContents() + 
					", machine_record_aux_data = " + motionRecord.getMachineRecordAuxData() + ", email_address = " + motionRecord.getEmailAddress() + ", email_name = " + motionRecord.getEmailName()+ ", remarks = " +  motionRecord.getRemarks() + 
					", is_correction = " + motionRecord.getIsCorrection() + ", user_id = " + motionRecord.getUserId() + ", reg_date = " + motionRecord.getRegDate() + ", up_date = " + motionRecord.getUpDate() +  ")");
			eventLogMessage.setFacilityCd(motionRecord.getFacilityCd());
			eventLogMessage.setUserId(String.valueOf(motionRecord.getUserId()));
			logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "MntMotionRecordDao/insert");
		}
		return ret;
	}
}
