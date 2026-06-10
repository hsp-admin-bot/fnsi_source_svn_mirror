package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.mstSynchro.MstSynchroRequest;
import jp.co.nikkiso.ntss.admin_web.response.mstSynchro.MstDeviceEdgeResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstSynchro.MstFacilityResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstSynchro.SynchroMstMNoticeResponse;
import jp.co.nikkiso.ntss.admin_web.service.mstSynchro.MstSynchroService;
import lombok.extern.slf4j.Slf4j;

import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

/**
 * マスタ同期のResourceクラス.
 */
@Slf4j
@RestController
@RequestMapping(Uri.MST_SYNCHRO)
public class MstSynchroResource {

  /**
   * マスタ同期Service.
   */
  @Autowired
  private MstSynchroService mstSynchroService;

	@Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End


  /**
   * 施設一覧を取得.
   *
   * @return 施設マスタ情報のresponse
   */
  @GetMapping("/mst_facility")
  public ResponseEntity<?> getMstStaffFacility() {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MST_SYNCHRO + "/mst_facility";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      "[REST request] 施設マスタ情報取得");
    // wp アプリケーションログの適正化 Add End

    // ログ出力

//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage( "[REST request] 施設マスタ情報取得");
//    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI,
//    null);
    // レスポンス生成
    MstFacilityResponse response = this.mstSynchroService.getMstFacilityList();

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(response, HttpStatus.OK);
  }
 //8104   心電図スイッチ      ljd Start

  @GetMapping("/sysFunctionAdvanced_facilitycd")
  public   Integer getAllSysFunctionAdvanceds(String facilityCd) {
    String func_advcd = "A12";
    return mstSynchroService.selectAllSysFunctionAdvanceds(func_advcd,facilityCd);
  }
 //8104   心電図スイッチ      ljd Start
  /**
   * 対象施設のデバイスエッジ情報を取得.
   *
   * @param facilityCd
   * @return デバイスエッジマスタ情報のresponse
   */
  @GetMapping("/mst_device_edge/{facilityCd}")
  public ResponseEntity<?> getMstDeviceEdge(@PathVariable String facilityCd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MST_SYNCHRO + "/mst_device_edge";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      "[REST request] デバイスエッジマスタ情報取得");
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage( "[REST request] デバイスエッジマスタ情報取得 ： 施設コード["+facilityCd+"]");
//    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI,
//    null);

    // レスポンス生成
    MstDeviceEdgeResponse response = this.mstSynchroService.getMstDeviceEdgeList(facilityCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * マスタ同期開始.
   * @param request マスタ同期のリクエスト
   * @return
   */
  @PostMapping("/synchro/start")
  public ResponseEntity<?> startMstSynchro(@RequestBody MstSynchroRequest request) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MST_SYNCHRO + "/synchro/start";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      "[REST request] マスタ同期開始");
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("[REST request] マスタ同期開始 ： 施設コード["+request.getFacilityCd()+"]、対象マスタ["+request.getMstTable()+"]、DE番号["+request.getDeviceEdgeNo()+"]");
//    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI,
//    null);

    // マスタ同期開始処理
    HttpStatus status = HttpStatus.OK;
    SynchroMstMNoticeResponse response = this.mstSynchroService.synchroMstMNotice(request.getFacilityCd());
    if (false == response.isSuccess) {
      status = HttpStatus.BAD_REQUEST;
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(response, status);
  }


  /**
   * マスタ同期開始.
   * @param request マスタ同期(隠し画面)からのリクエスト
   * @return
   */
  @PostMapping("/synchro/start_proc")
  public ResponseEntity<?> startMstSynchroProc(@RequestBody MstSynchroRequest request) {
    String mappingUrl = Uri.MST_SYNCHRO + "/synchro/start_proc";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      "[REST request] マスタ同期開始");

    // マスタ同期開始処理
    HttpStatus status = HttpStatus.OK;
    if (false == this.mstSynchroService.startMstSynchro(request.getFacilityCd(), request.getMstTable(), request.getDeviceEdgeNo())) {
      status = HttpStatus.BAD_REQUEST;
    }

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);

    return new ResponseEntity<>(status);
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
