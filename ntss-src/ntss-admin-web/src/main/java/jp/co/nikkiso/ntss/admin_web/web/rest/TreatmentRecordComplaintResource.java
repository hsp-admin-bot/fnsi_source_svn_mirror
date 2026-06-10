package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordComplaintService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.MntMonitorMsgRecord;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordComplaint;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;

import java.util.List;
import static java.util.Collections.emptyList;

import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 治療記録(愁訴処置)のResourceクラス.
 */
@RestController
@RequestMapping(Uri.TREATMENT_RECORD)
@PreAuthorize("isAuthenticated()")
public class TreatmentRecordComplaintResource {
  /**
   * 治療記録(愁訴処置)Service.
   */
  @Autowired
  private TreatmentRecordComplaintService treatmentRecordComplaintService;
  @Autowired
  OrdMaterialSaveService ordMaterialSaveService;

  /**
   * ログ出力Service.
   */
  @Autowired
  LogService logService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 治療記録（愁訴処置情報）取得.
   * @param ordNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（愁訴処置情報）データのResponse
   */
  @GetMapping("/{ord_no}/complaint")
  public ResponseEntity<?> getTreatmentRecordComplaint(
    @PathVariable("ord_no") Long ordNo,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.TREATMENT_RECORD + "/complaint";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to get treatment record complaint : "+ ordNo);
//    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    // 治療記録（愁訴処置情報）の取得
    TreatmentRecordComplaint response = treatmentRecordComplaintService.getTreatmentRecordComplaint(ordNo);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（愁訴処置情報）更新.
   * @param ordNo オーダ番号
   * @param request 治療記録（愁訴処置情報）データ
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/{ord_no}/complaint")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.RST_EDIT + "') or hasAuthority('" + AdminWebConstant.Authority.RST_PEDIT + "')")
  public ResponseEntity<Void> updateTreatmentRecordComplaint(
    @PathVariable("ord_no") Long ordNo,
    @Valid @RequestBody TreatmentRecordComplaint request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.TREATMENT_RECORD + "/complaint";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to put treatment record complaint : "+ ordNo);
//    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    treatmentRecordComplaintService.updateTreatmentRecordComplaint(ordNo, request);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End
    // add 9845 愁訴処置に入力した薬剤がord_material_saveに登録されない start
    //mod #10196 Ord_Material_Save operation 20240126 ztc start
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new ArrayList<>();
////    ordMaterialSaveService.updateOrdMaterialSave(new OrdMaterialSaveDto(ordNo, false, false, false, true, "2"));
//    MaterialSaveCacheHandler.DiffResultContainer diffMaterialSaveRst = ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//      new OrdMaterialSaveDto(ordNo, false, false, false, true, "2"));
//    diffMaterialSaveRstList.add(diffMaterialSaveRst);
//    if(diffMaterialSaveRstList.size() > 0){
//      ordMaterialSaveService.batchProcessingData(diffMaterialSaveRstList);
//    }
    ordMaterialSaveService.bulkUpdateByOrdNoInTreatment(ordNo);
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
    //mod #10196 Ord_Material_Save operation 20240126 ztc end
    // add 9845 愁訴処置に入力した薬剤がord_material_saveに登録されない end
    return new ResponseEntity(HttpStatus.OK);

  }

  //add FNSI修正401改修 房 start
  // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
  /**
   * 治療記録（愁訴処置情報）更新.
   * @param ordNo オーダ番号
   * @param request 治療記録（愁訴処置情報）データ
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/{ord_no}/{forced_change_flag}/complaint")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.RST_EDIT + "') or hasAuthority('" + AdminWebConstant.Authority.RST_PEDIT + "')")
  public ResponseEntity<String> updateTreatmentRecordComplaint2(
    @PathVariable("ord_no") Long ordNo,
    @PathVariable("forced_change_flag") Boolean forcedChangeFlag,
    @Valid @RequestBody TreatmentRecordComplaint request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    String mappingUrl = Uri.TREATMENT_RECORD + "/complaint";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordNo);

    String msgExist = treatmentRecordComplaintService.updateTreatmentRecordComplaint2(ordNo, request, forcedChangeFlag);

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new ArrayList<>();
//    MaterialSaveCacheHandler.DiffResultContainer diffMaterialSaveRst = ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//      new OrdMaterialSaveDto(ordNo, false, false, false, true, "2"));
//    diffMaterialSaveRstList.add(diffMaterialSaveRst);
//    if(diffMaterialSaveRstList.size() > 0){
//      ordMaterialSaveService.batchProcessingData(diffMaterialSaveRstList);
//    }
    ordMaterialSaveService.bulkUpdateByOrdNoInTreatment(ordNo);
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
    return new ResponseEntity(msgExist ,null, HttpStatus.OK);

  }
  // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end
  /**
   * 治療記録（愁訴処置情報）取得.
   * @param ordNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（愁訴処置情報）データのResponse
   */
  @GetMapping("/{ord_no}/monitor_record")
  public ResponseEntity<?> getMonitorMsgRecord(
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(name = "facilityCd") String facilityCd,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.TREATMENT_RECORD + "/monitor_record";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to get treatment record complaint : "+ ordNo);
//    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    // 治療記録（愁訴処置情報）の取得
    List<MntMonitorMsgRecord> response;
    if(facilityCd!=null&&!facilityCd.isEmpty()){
      response = treatmentRecordComplaintService.getMntMonitorMsgRecord(facilityCd, ordNo);
    }else{
      response = emptyList();
    }


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（愁訴処置情報）取得.
   * @param request 装置動作記録データ
   * @return 治療記録（愁訴処置情報）データのResponse
   */
  @PutMapping("/update/monitor_record")
  public ResponseEntity<Void> updMonitorMsgRecord(@Valid @RequestBody MntMonitorMsgRecord request){

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.TREATMENT_RECORD + "/update/monitor_record";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      treatmentRecordComplaintService.updateMntMonitorMsgRecord(request);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity(HttpStatus.OK);
  }
  //add FNSI修正401改修 房 end

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
