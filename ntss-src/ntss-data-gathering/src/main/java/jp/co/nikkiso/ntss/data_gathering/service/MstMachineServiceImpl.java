package jp.co.nikkiso.ntss.data_gathering.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.data_gathering.dao.MstMachineDaoDataGathering;
import jp.co.nikkiso.ntss.data_gathering.entity.MstMachine;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

@Service
public class MstMachineServiceImpl implements MstMachineService 
{
	@Autowired
	private MstMachineDaoDataGathering mstMachineDao;
	
	@Autowired
	private LogService logService;
	
	@Override
	public List<MstMachine> findById(String machineTypeCd, String machineSerial, String facilityCd, int deviceEdgeNo)
	{
		List<MstMachine> data;
		try
		{
			data = mstMachineDao.selectById(machineTypeCd, machineSerial, facilityCd, deviceEdgeNo);
		}
		catch (Exception e)
		{
			data = null;
			
			EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
			eventLogMessage.setSqlIdentification("(facility_cd = " + facilityCd + ", deviceEdgeNo = " + deviceEdgeNo + ", machine_type_cd = " + machineTypeCd + 
					", machine_serial = " + machineSerial + ")");
			eventLogMessage.setFacilityCd(facilityCd);
			logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"MstMachineDao/selectById");
		}
		
		return data;
	}
}
