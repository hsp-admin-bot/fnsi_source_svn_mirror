package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.master.checklist.MstChecklistService;
import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.custom.MstEquipmentClassForChecklist;
import lombok.extern.slf4j.Slf4j;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@Slf4j
@RequestMapping(Uri.CHECKLIST_SETTING)
public class ChecklistSettingResource {

  @Autowired
  MstChecklistService mstChecklistService;
  @Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  @GetMapping("/get/{facilityCd}")
  public ResponseEntity<?> getWeightScaleByFacilityCd(
      @PathVariable String facilityCd) {
    // 施設のチェックリスト設定情報を取得

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECKLIST_SETTING + "/get";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    List<MstChecklist> settings = mstChecklistService.mstChecklistSelectByFacility(facilityCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(settings, HttpStatus.OK);
  }

  @GetMapping("/get/equip-class/{facilityCd}")
  public ResponseEntity<?> getMstEquipClassByFacilityCd(
      @PathVariable String facilityCd) {
    // 施設のチェックリスト設定情報を取得

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECKLIST_SETTING + "/get/equip-class";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    List<MstEquipmentClassForChecklist> settings = mstChecklistService.getMstEquipClassList(facilityCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(settings, HttpStatus.OK);
  }

  /**
   * チェックリスト設定情報更新
   * @param request
   * @return
   */
  @PutMapping("/update")
  public ResponseEntity<?> mstChecklistUpdate(
      // mod #8344 【デグレ】チェックリストマスタの保存までが長い dou start
      // @RequestBody MstChecklist request) {
      @RequestBody Map<String, Object> request) {
      // mod #8344 【デグレ】チェックリストマスタの保存までが長い dou end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECKLIST_SETTING + "/update";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      int r = mstChecklistService.mstChecklistUpdate(request);
      if (r > 0) {

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(request, HttpStatus.OK);
      } else {

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage(e.getMessage());
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_CHECK_LIST, SERVICE_NAME.FNSI,
//    	null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * チェックリスト設定情報追加
   * @param request
   * @return
   */
  @PostMapping("/insert")
  public ResponseEntity<?> mstChecklistInsert(
      @RequestBody MstChecklist request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CHECKLIST_SETTING + "/insert";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      int r = mstChecklistService.mstChecklistInsert(request);
      if (r > 0) {
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(request, HttpStatus.OK);
      } else {
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage(e.getMessage());
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_CHECK_LIST, SERVICE_NAME.FNSI,
//    	null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_CHECK_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

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
