package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;
import java.util.Map;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
// add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.MstDisease;
// add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 end
import jp.co.nikkiso.ntss.core.entity.MstFacilitySetting;
import jp.co.nikkiso.ntss.core.entity.MstMachineRecordControl;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.master.machineRecord.MasterMachineRecordService;
import lombok.extern.slf4j.Slf4j;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;



/**
 * 装置記録マスタ画面のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.MASTER_MAINTENANCE)
public class MstMachineRecordResource {

  /**
   * 装置記録マスタService
   */
  @Autowired
  private MasterMachineRecordService masterMachineRecordService;

  @Autowired
  LogService logService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 start
  /**
   * 病名マスタを件数取得する
   */
  @GetMapping("/getTotal/{facilityCd}")
  public ResponseEntity<?> getTotal(@PathVariable String facilityCd,
                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
                                    @AuthenticationPrincipal NtssUser ntssUser
                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
  ) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
          if (facilityCd != null && !facilityCd.isEmpty() &&
              !facilityCd.equals(ntssUser.getFacilityCd())) {
              String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
              InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
              return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
          }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
    String Total = masterMachineRecordService.getTotal(facilityCd);
    return new ResponseEntity<>(Total, HttpStatus.OK);
  }

  /**
   * 病名マスタを全件取得する.分頁
   */
  @GetMapping("/getMstDiseaseByLimitAndOffset/{facilityCd}/{offset}")
  public ResponseEntity<?> getMstDiseaseByLimitAndOffset(@PathVariable String facilityCd,
                                                         @PathVariable Integer offset,
                                                         // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
                                                         @AuthenticationPrincipal NtssUser ntssUser
                                                         // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
  ) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
          if (facilityCd != null && !facilityCd.isEmpty() &&
              !facilityCd.equals(ntssUser.getFacilityCd())) {
              String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
              InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
              return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
          }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
    Integer limit = 100;
    List<MstDisease> response = masterMachineRecordService.getMstDiseaseByLimitAndOffset(limit, facilityCd, offset);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 end

  /**
   * マスタデータ更新.
   *
   * @param facilityCd 施設コード
   * @param request    マスタデータ更新のrequest
   * @return
   */
  @PutMapping("/saveMachineRecord/{facilityCd}")
  public ResponseEntity<?> updateMasterData(@PathVariable String facilityCd,
                                            @RequestBody Map<String, List<String>> request,
                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                            @AuthenticationPrincipal NtssUser ntssUser
                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start

    try {
      if(!ntssUser.isNkkAdminUser()) {
        if (request.get("insertRecord") != null && !request.get("insertRecord").isEmpty()) {
          ObjectMapper mapper = new ObjectMapper();
          MstMachineRecordControl mstMachineRecordControl = mapper.readValue(request.get("insertRecord").get(request.get("insertRecord").size() - 1),
            MstMachineRecordControl.class);
          if (mstMachineRecordControl != null && mstMachineRecordControl.getFacilityCd() != null &&
            !mstMachineRecordControl.getFacilityCd().equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstMachineRecordControl.getFacilityCd() + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("セキュリティチェックの例外!");
            logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, LoggingConstant.SERVICE_NAME.FNSI, null);
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
        }
      }
    } catch (JacksonException e) {
      if (!ntssUser.isNkkAdminUser()) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " JsonProcessingException during security check ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("セキュリティチェックの例外!");
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, LoggingConstant.SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MASTER_MAINTENANCE + "/saveMachineRecord";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End


    try {
      masterMachineRecordService.updateMasterData(request);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DETAIL_FACILITIES_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
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
