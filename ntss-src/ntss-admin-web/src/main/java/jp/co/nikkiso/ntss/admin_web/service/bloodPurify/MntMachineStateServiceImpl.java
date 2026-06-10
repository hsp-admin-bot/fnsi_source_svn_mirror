package jp.co.nikkiso.ntss.admin_web.service.bloodPurify;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineStateForMinimumTreatDate;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.List;
import java.util.Objects;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class MntMachineStateServiceImpl implements MntMachineStateService {

  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  PatPersonalMainDao patPersonalMainDao;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

  /**
   * {@inheritDoc}
   */
  @Override
  public List<ComsvMntMachineState> selectByFacilityCd(String facilityCd) {
    return mntMachineStateDao.selectByFacilityCd(facilityCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateUseTime(MntMachineState param) {

    return mntMachineStateDao.updateUseTime(param);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateCondSend(MntMachineState param) {

    return mntMachineStateDao.updateCondSend(param);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateCondSet(MntMachineState param) {

    return mntMachineStateDao.updateCondSet(param);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateDialStart(MntMachineState param) {

    return mntMachineStateDao.updateDialStart(param);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateDialEnd(MntMachineState param) {

    return mntMachineStateDao.updateDialEnd(param);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateUnregisteredPat(MntMachineState param) {

    return mntMachineStateDao.updateUnregisteredPat(param);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MntMachineState selectByKey(String facilityCd, String machineTypeCd, String machineSerial) {
    return mntMachineStateDao.selectByKey(facilityCd, machineTypeCd, machineSerial);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MntMachineState> selectAllByDeviceEdgeNo(String facilityCd, Integer deviceEdgeNo) {
    return mntMachineStateDao.selectAllByDeviceEdgeNo(facilityCd, deviceEdgeNo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public ComsvMntMachineState selectMachineKey(String facilityCd, String machineTypeCd, String machineSerial) {

    ComsvMntMachineState comsv = mntMachineStateDao.selectMachineKey(facilityCd, machineTypeCd, machineSerial);
    Long patId = comsv.getNextPatid();
    if (!(Objects.equals(patId, null))) {
      // pat_personal_main 患者個人情報取得
      PatPersonalMain patPersonal = patPersonalMainDao.selectById(patId);
      // 患者名
      String patLastName = patPersonal.getPat_last_name();
      String patFirstName = patPersonal.getPat_first_name();
      comsv.setNextPatName(patLastName + " " + patFirstName);
    }

    String setInfo = comsv.getTmpDeviceSetInfo();
    comsv.setDeviceSetPatName(null);
    if (!(Objects.equals(setInfo, null))) {
	  // JSON処理
	  ObjectMapper mapper = new ObjectMapper();
	  try {
	    JsonNode jsonNode_array = mapper.readTree(comsv.getTmpDeviceSetInfo());
        // 設定値書込用患者ID取得
        // mod #9973 Resolve null exception for key 20240117 ztc start
//	    String sDevPatId = jsonNode_array.get("dev").get("0").asText();
        String sDevPatId = jsonNode_array.hasNonNull("dev")
                && jsonNode_array.get("dev").hasNonNull("0")
                ? jsonNode_array.get("dev").get("0").asText() : null;
        // mod #9973 Resolve null exception for key 20240117 ztc end
        if (!(Objects.isNull(sDevPatId))) {
	      Long lDevPatId = Long.parseLong(sDevPatId);
	      if (!(Objects.isNull(lDevPatId))) {
	        // pat_personal_main 患者個人情報取得
	        PatPersonalMain patPersonal = patPersonalMainDao.selectById(lDevPatId);
	        // 設定値書込用患者名
	        String patLastName = patPersonal.getPat_last_name();
	        String patFirstName = patPersonal.getPat_first_name();
	        comsv.setDeviceSetPatName(patLastName + " " + patFirstName);
	      }
	    }
	  } catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
	  }
    }

    return comsv;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateAlarmList(String facilityCd, String machineTypeCd, String machineSerial, String alarmList) {

    return mntMachineStateDao.updateAlarmList(facilityCd, machineTypeCd, machineSerial, alarmList);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public ComsvMntMachineStateForMinimumTreatDate selectMinimumTreatDate(String facilityCd, Integer deviceEdgeNo, String startDate, String endDate ) {
    return mntMachineStateDao.selectMinimumTreatDate(facilityCd, deviceEdgeNo, startDate, endDate );
  }

  @Override
  public List<MntMachineState> selectAll() {
    return mntMachineStateDao.selectAll();
  }

  @Override
  public List<MntMachineState> selectMonitorByFacilityCdAndPatIdAndOrdNo(List<MniMonitor> bodyDataList) {
    return mntMachineStateDao.selectMonitorByFacilityCdAndPatIdAndOrdNo(bodyDataList);
  }
  @Override
  public List<MntMachineState> selectByPatId(Long patId) {
    return mntMachineStateDao.selectByPatId(patId);
  }
}
