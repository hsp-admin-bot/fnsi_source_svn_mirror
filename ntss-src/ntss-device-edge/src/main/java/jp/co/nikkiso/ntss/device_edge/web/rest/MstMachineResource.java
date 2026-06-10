package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.util.Arrays;
import java.util.List;
import java.util.Objects;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.trigger.MstMachineTrigger;
import jp.co.nikkiso.ntss.device_edge.service.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.constant.Constant.Uri;
import jp.co.nikkiso.ntss.device_edge.response.mstMachine.MachineOptionDTO;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.MstMachineService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@RestController
@RequestMapping(Uri.MACHINES)

public class MstMachineResource {

  @Autowired
  private LogService logService;


  @Autowired
  private MstMachineService mstMachineService;

  @Autowired
  private MstMachineDao mstMachineDao;

  @Autowired
  private MstMachineTrigger mstMachineTrigger; // add by shiyw for Trigger 20230306

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 装置マスタ設定の取得
   */
  @GetMapping({ "/{facility_cd}/{device_edge_no}" })
  public ResponseEntity<?> getMachineMst(
      @PathVariable(name = "facility_cd", required = false) String facility_cd,
      @PathVariable("device_edge_no") Integer device_edge_no) {


    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setDeviceEdgeNo(String.valueOf(device_edge_no) );
    eventLogMessage.setLogMessage("API GET CALLED facility_cd = " + facility_cd + " device_edge_no = " + device_edge_no);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (!Objects.equals(facility_cd, "") && device_edge_no > 0) {
      List<String> res = mstMachineService.findByDeviceEdge(facility_cd, device_edge_no);

      StringBuilder buf = new StringBuilder();
      for (String str : res) {
        buf.append(str);
      }

      eventLogMessage.setLogMessage("O K");
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(buf.toString(), HttpStatus.OK);
    } else {
      eventLogMessage.setLogMessage("ERROR");
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 装置オプション更新
   * @param facility_cd 施設コード
   * @param device_edge_no デバイスエッジ番号
   * @param machine_no 装置番号
   * @param option_value 装置オプション情報
   */
  @PutMapping({ "/update_option/{facility_cd}/{device_edge_no}/{machine_no}/{option_value}" })
  public ResponseEntity<?> updateMachineOption(
      @PathVariable("facility_cd") String facility_cd,
      @PathVariable("device_edge_no") int device_edge_no,
      @PathVariable("machine_no") Long machine_no,
      @PathVariable("option_value") String option_value) {


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MACHINES + "/update_option";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd,
      Arrays.asList(device_edge_no, machine_no,option_value));
    // wp アプリケーションログの適正化 Add End

	  EventLogMessage eventLogMessage = new EventLogMessage();
	  eventLogMessage.setDeviceEdgeNo(String.valueOf(device_edge_no));
	  eventLogMessage.setLogMessage("API PUT CALLED facility_cd = " + facility_cd + " device_edge_no = " + device_edge_no + " machine_no = "
            + machine_no + " option_value = " + option_value);
    eventLogMessage.setFacilityCd(facility_cd);
	  //logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    if (!Objects.equals(facility_cd, "") && device_edge_no > 0) {
      MstMachine param = new MstMachine();
      param.setFacilityCd(facility_cd);
      param.setDeviceEdgeNo(device_edge_no);
      param.setMachineNo(machine_no);

      // 送信データ文字数チェック
      if (option_value.length() != 20) {
        eventLogMessage.setLogMessage("ERROR: The number of characters of [option_value] is not 20 characters");
        eventLogMessage.setFacilityCd(facility_cd);
	      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
      }
      // JSON文字列作成
      MachineOptionDTO dto = new MachineOptionDTO();
      dto.setOptionByHexString(option_value);
      String json = "";
      ObjectMapper mapper = new ObjectMapper();
      try {
        json = mapper.writeValueAsString(dto);
      } catch (JsonProcessingException e) {

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, facility_cd, e.getMessage());
        // wp アプリケーションログの適正化 Add End
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
        if (facility_cd != null) {
          eventLogMessage.setFacilityCd(facility_cd);
        }
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      param.setMachineOption(json);

      int result = mstMachineService.updateMachineOption(param);
      List<MstMachine> mstMachineList = mstMachineDao.selectByFacilityAndDeviceEdgeNoAndMachineNo(param.getFacilityCd(),param.getDeviceEdgeNo(),param.getMachineNo());
      for (MstMachine machine: mstMachineList){
        mstMachineTrigger.triggerMachineStateInsert(machine);// modify by shiyw for Trigger 20230306
      }
      return new ResponseEntity<>(result, HttpStatus.OK);
    } else {
      eventLogMessage.setLogMessage("ERROR: facility_cd is empty or device_edge_no less than 0");
      eventLogMessage.setFacilityCd(facility_cd);
	    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }
}
