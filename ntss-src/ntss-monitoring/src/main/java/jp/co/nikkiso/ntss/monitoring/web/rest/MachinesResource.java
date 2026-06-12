package jp.co.nikkiso.ntss.monitoring.web.rest;

import java.net.URISyntaxException;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.MstMachineWithState;
import jp.co.nikkiso.ntss.monitoring.service.MntMachineStateService;
import jp.co.nikkiso.ntss.monitoring.service.MstMachineService;

import jp.co.nikkiso.ntss.monitoring.service.logger.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.monitoring.service.logger.LogEventUtils;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
/**
 * 装置系画面のResourceクラス.
 * <p>
 * 装置系画面から呼び出されるDB処理
 * <p>
 */
@CrossOrigin(origins = "*") // 別ドメインからのテスト用にアクセスすることを許可
@RestController
@RequestMapping("/api/machines")
public class MachinesResource {

  /**
   * Logger.
   */
  private final Logger logger = LoggerFactory.getLogger(getClass());

  /**
   * 装置一覧Service.
   */
  @Autowired
  private MstMachineService machinesService;
  /**
   * 装置状態Service.
   */
  @Autowired
  private MntMachineStateService mntMachineService;

  @Autowired
  private LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 装置一覧を取得（状態付き）
   * @param facilityCd　施設コード
   * @param machineTypeCd　型式コード　（省略時はすべて）
   * @param machineSerial　製造番号　（省略時はすべて）
   * @return　装置一覧
   * @throws URISyntaxException
   */
  @GetMapping({"/{facilityCd}", "/{facilityCd}/{machineTypeCd}", "/{facilityCd}/{machineTypeCd}/{machineSerial}"})
  public ResponseEntity<?> getMachines(
      @PathVariable String facilityCd,
      @PathVariable(name = "machineTypeCd", required = false) String machineTypeCd,
      @PathVariable(name = "machineSerial", required = false) String machineSerial) throws URISyntaxException {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("REST request to get Machines :  %s %s %s", facilityCd, machineTypeCd, machineSerial));
    eventLogMessage.setMachineTypeCd(machineTypeCd);
    eventLogMessage.setFacilityCd(facilityCd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
    List<MstMachineWithState> mstMachines = machinesService.findByFacilitywithState(facilityCd, machineTypeCd, machineSerial);

    return new ResponseEntity<>(mstMachines, HttpStatus.OK);

  }

  @PostMapping("/alarm_list/update")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<String> writeAlarmList(
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @RequestBody MntMachineState param) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/api/machines" + "/alarm_list/update";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      // エスケープ文字の置換
      if(param.getAlarmList() != null) {
        param.setAlarmList((param.getAlarmList().replace("\\\"", "\"")));
      }

      int result = mntMachineService.updateAlarmList(
          param.getFacilityCd(),
          param.getMachineTypeCd(),
          param.getMachineSerial(), param.getAlarmList());
      if(result == 1) {
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>("", HttpStatus.OK);
      } else {
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>("", HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(String.format("Error post sysSystemDefine : %s", ex.getMessage()));
      eventLogMessage.setFacilityCd(param.getFacilityCd());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(ex.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
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
