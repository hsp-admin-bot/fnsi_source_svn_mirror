package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.net.URISyntaxException;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.patHomeDialysis.DialysisStatusResponse;
import jp.co.nikkiso.ntss.admin_web.response.patHomeDialysis.DialysisWeightResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.patHomeDialysis.PatHomeDialysisService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.PatHhdPattern;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventData;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

/**
 * 在宅透析患者向け用（pat-home-dialysis）系のリソースクラス
 */
@RestController
@RequestMapping(Uri.PAT_HOME_DIALYSIS)
public class PatHomeDialysisResource {

  /**
   * 在宅透析患者向け用サービス.
   */
  @Autowired
  private PatHomeDialysisService patHomeDialysisService;

  @Autowired
	LogService logService;
  /**
   * 装置モニタデータのデータを取得する.
   * @return 装置モニタデータ
   */
  @GetMapping("/monitor/{patId}")
  public ResponseEntity<?> getMonitoringData (
      @PathVariable Long patId,
      @AuthenticationPrincipal NtssUser ntssUser
      ) throws Exception {
    // ord_nain、mni_monitro からデータを取得する
    DialysisStatusResponse dialysisStatusResponse = patHomeDialysisService.createDialysisStatusResponse(patId, ntssUser.getFacilityCd());
    return new ResponseEntity<>(dialysisStatusResponse, HttpStatus.OK);
  }

  /**
   * 在宅患者の治療条件を取得
   * @param facility_cd 施設コード
   * @return 検査結果のResponse
   */
  @GetMapping("/getPatHhdPattern")
  public ResponseEntity<List<PatHhdPattern>> getPatHhdPatternByFacilityCd(
      @RequestParam(value = "facility_cd", required = true) String facility_cd) throws URISyntaxException
  {
    List<PatHhdPattern> listRet = patHomeDialysisService.FindPatHhdPatternByFacilityCd(facility_cd);
    return new ResponseEntity<>(listRet, HttpStatus.OK);
  }


  /**
  * 前体重入力時：治療情報データ作成用在宅患者治療パターンファイル取得
  *
  * @param facilityCd 取得対象の施設コード
  * @param patId 取得対象の患者ID
  * @return 検査項目マスタデータのResponse
  *
  */
  @PostMapping("/getPatHhdPatternList")
  public ResponseEntity<?> getPatHhdPatternList(
    @RequestBody Map<String, Object > req,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : use patHhdPatternData");
    logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      List<PatHhdPattern> response = patHomeDialysisService.getPatHhdPatternData(
          ntssUser.getFacilityCd(),
          Long.parseLong(req.get("patId").toString())
          );
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // 対象データが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
  * 前体重入力時：治療情報データ存在チェック
  *
  * @param facilityCd 取得対象の施設コード
  * @param patId 取得対象の患者ID
  * @return 検査項目マスタデータのResponse
  *
  */
  @PostMapping("/getOrdMainWeightBefore")
  public ResponseEntity<?> getOrdMainWeightBefore(
    @RequestBody Map<String, Object > req,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : use getOrdMainWeightBefore");
    logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      DialysisWeightResponse response = patHomeDialysisService.getDialysisWeightBefore(
          Long.parseLong(req.get("patId").toString()),
          ntssUser.getFacilityCd()
          );
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // 対象データが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);

      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * rst_dialisys_state=1~5のデータが存在する場合にマスタの編集をできなくする。
   * @param req
   * @param ntssUser
   * @return
   */
  @PostMapping("/getOrdMainStatue")
  public ResponseEntity<?> getOrdMainStatue(
    @RequestBody Map<String, Object > req,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : use getOrdMainBefore");
    logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      DialysisWeightResponse response = patHomeDialysisService.getStatue(
          ntssUser.getFacilityCd(),
          ((String) req.get("state")).split(",")
          );
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // 対象データが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);

      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
  * 後体重入力時：治療情報データ存在チェック
  *
  * @param facilityCd 取得対象の施設コード
  * @param patId 取得対象の患者ID
  * @return 検査項目マスタデータのResponse
  *
  */
  @PostMapping("/getOrdMainWeightAfter")
  public ResponseEntity<?> getOrdMainWeightAfter(
    @RequestBody Map<String, Object > req,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : use getOrdMainWeightAfter");
    logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      DialysisWeightResponse response = patHomeDialysisService.getDialysisWeightAfter(
          Long.parseLong(req.get("patId").toString()),
          ntssUser.getFacilityCd()
          );
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // 対象データが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }



  /**
   * 治療情報データのうち体重情報のみ取得
   * @return 治療情報:体重データ
   */
  @GetMapping("/getOrdMainWeight/{ordNo}")
  public ResponseEntity<?> getOrdMainWeight (
      @PathVariable Long ordNo,
      @AuthenticationPrincipal NtssUser ntssUser
      ) throws Exception {
    // ord_nain内の体重情報及びstatusを取得
    DialysisWeightResponse dialysisWeightResponse = patHomeDialysisService.getDialysisStateByOrdNo(ordNo);
    return new ResponseEntity<>(dialysisWeightResponse, HttpStatus.OK);
  }

  /**
  * 前体重入力時：治療情報データ作成用在宅患者治療パターンファイル取得
  *
  * @param facilityCd 取得対象の施設コード
  * @param patId 取得対象の患者ID
  * @return 検査項目マスタデータのResponse
  *
  */
  @PostMapping("/saveWeightBefore")
  public ResponseEntity<?> saveWeightBefore(
    @RequestBody Map<String, Object > req,
    @AuthenticationPrincipal NtssUser ntssUser) {
      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to Update weightBefore : ord_main");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      boolean response = patHomeDialysisService.updateWeightBefore(
          Long.parseLong(req.get("ordNo").toString()),
          req.get("weightBefore").toString()
          );
      if(response){
        return new ResponseEntity<>(HttpStatus.OK);
      }else{
        // 対象データが更新できなかった場合
        eventLogMessage.setLogMessage("weightBefore Update error");
        logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }
    } catch (Exception e) {
      // 対象データが更新できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }


  /**
  * 後体重入力時：治療情報データ作成用在宅患者治療パターンファイル取得
  *
  * @param facilityCd 取得対象の施設コード
  * @param patId 取得対象の患者ID
  * @return 検査項目マスタデータのResponse
  *
  */
  @PostMapping("/saveWeightAfter")
  public ResponseEntity<?> saveWeightAfter(
    @RequestBody Map<String, Object > req,
    @AuthenticationPrincipal NtssUser ntssUser) {
      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to Update weightAfter : ord_main");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      boolean response = patHomeDialysisService.updateWeightAfter(
          Long.parseLong(req.get("ordNo").toString()),
          req.get("weightAfter").toString()
          );
      if(response){
        return new ResponseEntity<>(HttpStatus.OK);
      }else{
        // 対象データが更新できなかった場合
        eventLogMessage.setLogMessage("weightAfter Update error");
        logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
            HttpStatus.INTERNAL_SERVER_ERROR);
      }
    } catch (Exception e) {
      // 対象データが更新できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 在宅患者治療パターン 保存処理.
   *
   * @param request    マスタデータ更新のrequest
   * @return
   */
  @PutMapping("/insert")
  public ResponseEntity<?> savePatHhdPattern(
      @RequestBody Map<String, String> request
      ) throws Exception {
    try {
      int response = patHomeDialysisService.insert(request);
      if (response > 0) {
        patHomeDialysisService.registerPushNotification(Long.parseLong(request.get("patId")));
      }
      // 戻り値用
      return new ResponseEntity<>(
          response,
          HttpStatus.OK);
    } catch (Exception e) {
      // 更新処理ができなかった場合
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 在宅患者の治療条件を取得（患者指定）
   * @param pat_id 患者ID
   * @return 検査結果のResponse
   */
  @GetMapping("/getPatHhdPatternByPatId")
  public ResponseEntity<List<PatHhdPattern>> getPatHhdPatternByPatId(
      @RequestParam(value = "pat_id", required = true) Long pat_id) throws URISyntaxException
  {
    List<PatHhdPattern> listRet = patHomeDialysisService.FindPatHhdPatternByPatId(pat_id);
    return new ResponseEntity<>(listRet, HttpStatus.OK);
  }

  /**
   * 患者イベント取得.
   *
   * @param patId 取得対象の患者ID
   * @param startEventdate 取得対象の開始イベント日付(YYYY/MM/DD)
   * @param endEventdate 取得対象の終了イベント日付(YYYY/MM/DD)
   * @return 患者イベントデータのResponse
   *
   */
   @GetMapping("/getEventByPatIdNewest")
   public ResponseEntity<?> getRadSetList(
       @RequestParam("patId") Long patId,
       @RequestParam("startEventdate") String startEventdate,
       @RequestParam("endEventdate") String endEventdate
       ) {
     try {
       // レスポンス生成
       List<PatEventData> response = patHomeDialysisService.findEventByPatIdNewest(patId,startEventdate,endEventdate);
       return new ResponseEntity<>(response, HttpStatus.OK);
     } catch (Exception e) {
       // 取得できなかった場合
       EventLogMessage eventLogMessage = new EventLogMessage();
       eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
       logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_PAT_HOME_DIALYSIS,SERVICE_NAME.FNSI, null);
       return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
           HttpStatus.INTERNAL_SERVER_ERROR);
     }
   }

}
