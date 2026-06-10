package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.HashMap;
import java.util.List;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import jp.co.nikkiso.ntss.admin_web.DataGatheringProperties;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.motionRecord.DownloadGatheringRequest;
import jp.co.nikkiso.ntss.admin_web.request.motionRecord.SendDataGatheringRequestRequest;
import jp.co.nikkiso.ntss.admin_web.request.motionRecord.UpdateAllCorrectionsRequest;
import jp.co.nikkiso.ntss.admin_web.request.motionRecord.UpdateCorrectionRequest;
import jp.co.nikkiso.ntss.admin_web.request.motionRecord.UpdateServiceSupportAllRequest;
import jp.co.nikkiso.ntss.admin_web.request.motionRecord.UpdateServiceSupportRequest;
import jp.co.nikkiso.ntss.admin_web.response.GatheringStatusResponse;
import jp.co.nikkiso.ntss.admin_web.response.MotionRecordsResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.DabGraphResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.DissolutionGraphResponse;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.MachineGraphResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.motionRecords.MotionRecordsService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import javax.validation.Valid;
import javax.xml.bind.DatatypeConverter;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.Map;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end


/**
 * 装置動作記録のResourceクラス.
 */
@RestController
@RequestMapping(Uri.MOTION_RECORD)
public class MotionRecordResource {

  /**
   * Logger.
   */
  private final Logger logger = LoggerFactory.getLogger(getClass());

  /**
   * 装置動作記録Service.
   */
  @Autowired
  private MotionRecordsService motionRecordsService;

  /**
   * ログService.
   */
	@Autowired
	LogService logService;

  /**
   * Amazon S3.
   */
  @Autowired
  private AmazonS3 s3;

  /**
   * データ収集Properties.
   */
  @Autowired
  private DataGatheringProperties dataGatheringProperties;

  /**
   * システム設定のDaoインタフェース.
   */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /**
   * 装置動作記録一覧取得.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userTypeCd ユーザ種別
   * @param baseDate 基準日
   * @return 装置動作記録のResponse
   */
  @GetMapping("/{facilityCd}/{machineTypeCd}/{machineSerial}/{userTypeCd}/{baseDate}")
  public ResponseEntity<?> getMotionRecords(@PathVariable String facilityCd,
      @PathVariable String machineTypeCd, @PathVariable String machineSerial, @PathVariable String userTypeCd,
      @PathVariable String baseDate) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get MotionRecords : "+ facilityCd+ machineTypeCd+ machineSerial+ userTypeCd+            baseDate);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,    null);
    // レスポンス生成
    MotionRecordsResponse response = motionRecordsService.createMotionRecordsResponse(facilityCd, machineTypeCd,
        machineSerial, userTypeCd, baseDate);

    return new ResponseEntity<>(response, HttpStatus.OK);

  }

  /**
   * 装置動作記録一覧取得(オーバーロード).
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userTypeCd ユーザ種別
   * @param fromDate 開始日
   * @param toDate 終了日
   * @return 装置動作記録のResponse
   */
  @GetMapping("/{facilityCd}/{machineTypeCd}/{machineSerial}/{userTypeCd}/{fromDate}/{toDate}")
  public ResponseEntity<?> getMotionRecords(@PathVariable String facilityCd,
      @PathVariable String machineTypeCd, @PathVariable String machineSerial, @PathVariable String userTypeCd,
      @PathVariable String fromDate, @PathVariable String toDate) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get MotionRecords : "+ facilityCd+ machineTypeCd+ machineSerial+ userTypeCd+
            fromDate+ toDate);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
    null);
    // レスポンス生成
    MotionRecordsResponse response = motionRecordsService.createMotionRecordsResponse(facilityCd, machineTypeCd,
        machineSerial, userTypeCd, fromDate, toDate);

    return new ResponseEntity<>(response, HttpStatus.OK);

  }

    /**
   * 装置動作記録一覧取得(オーバーロード).
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userTypeCd ユーザ種別
   * @param fromDate 開始日
   * @param toDate 終了日
   * @param offset 開始位置
   * @return 装置動作記録のResponse
   */
  @GetMapping("/{facilityCd}/{machineTypeCd}/{machineSerial}/{userTypeCd}/{fromDate}/{toDate}/{offset}")
  public ResponseEntity<?> getMotionRecords(@PathVariable String facilityCd,
      @PathVariable String machineTypeCd, @PathVariable String machineSerial, @PathVariable String userTypeCd,
      @PathVariable String fromDate, @PathVariable String toDate, @PathVariable Integer offset) {
    Integer limit = 1000;
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get MotionRecords : "+ facilityCd+ machineTypeCd+ machineSerial+ userTypeCd+
            fromDate+ toDate+String.valueOf(offset));
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
    null);
    // レスポンス生成
    MotionRecordsResponse response = motionRecordsService.createMotionRecordsResponse(facilityCd, machineTypeCd,
        machineSerial, userTypeCd, fromDate, toDate, limit, offset);

    return new ResponseEntity<>(response, HttpStatus.OK);

  }

  /**
   * 指定された期間内の装置動作記録を取得.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userTypeCd ユーザ種別
   * @param fromDate 開始日
   * @param toDate 終了日
   * @return 装置動作記録のResponse
   */
  @GetMapping("/period/{facilityCd}/{machineTypeCd}/{machineSerial}/{userTypeCd}/{fromDate}/{toDate}")
  public ResponseEntity<?> getMotionRecordsInPeriod(@PathVariable String facilityCd,
      @PathVariable String machineTypeCd, @PathVariable String machineSerial, @PathVariable String userTypeCd,
      @PathVariable String fromDate, @PathVariable String toDate) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get MotionRecordsInPeriod : "+ facilityCd+ machineTypeCd+ machineSerial+ userTypeCd+
            fromDate+ toDate);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
    null);
    // レスポンス生成
    MotionRecordsResponse response = motionRecordsService.createMotionRecordsResponseWithinPeriod(facilityCd,
        machineTypeCd, machineSerial, userTypeCd, fromDate, toDate);

    return new ResponseEntity<>(response, HttpStatus.OK);

  }

  /**
   * 指定された期間内の装置動作記録を取得.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userTypeCd ユーザ種別
   * @param fromDate 開始日
   * @param toDate 終了日
   * @param offset 開始位置
   * @param dataType データ種別
   * @param freeWord フリーワード
   * @return 装置動作記録のResponse
   */
  @GetMapping("/period/{facilityCd}/{machineTypeCd}/{machineSerial}/{userTypeCd}/{fromDate}/{toDate}/{offset}")
  public ResponseEntity<?> getMotionRecordsInPeriod(@PathVariable String facilityCd,
                                                    @PathVariable String machineTypeCd, @PathVariable String machineSerial, @PathVariable String userTypeCd,
                                                    @PathVariable String fromDate, @PathVariable String toDate, @PathVariable Integer offset,
                                                    @RequestParam(name = "dataType", defaultValue = "") List<Integer> dataType, @RequestParam(name = "freeWord", defaultValue = "") String freeWord) {
    Integer limit = 1000;
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get MotionRecordsInPeriod : "+ facilityCd+ machineTypeCd+ machineSerial+ userTypeCd+
            fromDate+ toDate + String.valueOf(limit) + String.valueOf(offset));
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
    null);
    // レスポンス生成
    MotionRecordsResponse response = motionRecordsService.createMotionRecordsResponseWithinPeriod(facilityCd,
        machineTypeCd, machineSerial, userTypeCd, fromDate, toDate, limit, offset ,dataType, freeWord);

    return new ResponseEntity<>(response, HttpStatus.OK);

  }

   /**
   * 指定された期間内の装置動作記録の総件数を取得.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userTypeCd ユーザ種別
   * @param fromDate 開始日
   * @param toDate 終了日
   * @param dataType データ種別
   * @param freeWord フリーワード
   * @return 装置動作記録のResponse
   */
  @GetMapping("/period/total/{facilityCd}/{machineTypeCd}/{machineSerial}/{userTypeCd}/{fromDate}/{toDate}")
  public ResponseEntity<?> getMotionRecordsTotal(@PathVariable String facilityCd,
      @PathVariable String machineTypeCd, @PathVariable String machineSerial, @PathVariable String userTypeCd,
      @PathVariable String fromDate, @PathVariable String toDate, @RequestParam(name = "dataType", defaultValue = "") List<Integer> dataType,
      @RequestParam(name = "freeWord", defaultValue = "") String freeWord) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get getMotionRecordsTotal : "+ facilityCd+ machineTypeCd+ machineSerial+ userTypeCd+
            fromDate+ toDate);
    eventLogMessage.setInvokeClass(this.getClass().getName());
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
    null);
    // レスポンス生成
    Integer total = motionRecordsService.createMotionRecordsTotal(facilityCd,
        machineTypeCd, machineSerial, userTypeCd, fromDate, toDate, dataType, freeWord);

    return new ResponseEntity<>(total, HttpStatus.OK);
  }

  /**
   * 装置動作記録詳細取得.
   *
   * @param motionRecordNo 装置動作記録番号
   * @param dataType データ種別
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param baseDate 基準日
   * @param offset スキップ行数
   * @return データ種別に応じた装置動作記録詳細のResponse
   */
  @GetMapping("/detail/{motionRecordNo}/{dataType}/{facilityCd}/{machineTypeCd}/{machineSerial}/{baseDate}/{offset}")
  public ResponseEntity<?> getMotionRecordDetail(
      @PathVariable String motionRecordNo,
      @PathVariable String dataType,
      @PathVariable String facilityCd,
      @PathVariable String machineTypeCd,
      @PathVariable String machineSerial,
      @PathVariable String baseDate,
      @PathVariable Integer offset) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get MotionRecordDetail : "+ motionRecordNo+ dataType+ facilityCd+ machineTypeCd+
            machineSerial+ baseDate);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
    null);

    try {
      // レスポンス生成
      ResponseEntity<?> detailResonse = motionRecordsService.createDetailResponse(Long.valueOf(motionRecordNo),
          Integer.valueOf(dataType), facilityCd, machineTypeCd, machineSerial, baseDate, offset);

      return detailResonse;

    } catch (Exception e) {
      eventLogMessage.setLogMessage( "REST request is BAD_REQUEST.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,      null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);

    }

  }

  /**
   * 透析装置自己診断/DAB自己診断のグラフデータ取得.
   * <p>
   * データ種別に応じたグラフデータを一定期間分取得して返す.
   * </p>
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param testType テスト種別
   * @param baseDate 基準日
   * @param weeks 指定期間(週)
   * @return グラフデータのResponse
   */
  @GetMapping("/detail/graphs/{facilityCd}/{machineTypeCd}/{machineSerial}/{testType}/{baseDate}/{weeks}")
  public ResponseEntity<?> getGraphData(@PathVariable String facilityCd,
      @PathVariable String machineTypeCd, @PathVariable String machineSerial,
      @PathVariable String testType, @PathVariable String baseDate, @PathVariable String weeks) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get GraphData : "+ facilityCd+ machineTypeCd+ machineSerial+ testType+ baseDate+
            weeks);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,    null);
    try {
// modify by SunZelin  2023-02-01 [CodeOptimization]  start
//      // 自己診断種別に応じたレスポンス生成
//      switch (Integer.valueOf(testType)) {
//
//      // 透析装置自己診断
//      case TestType.UFRC:
//      case TestType.BLOOD_LEAKAGE:
//      case TestType.DIALYSATE_FLOW_RATE:
//      case TestType.CONCENTRAITION:
//        MachineGraphResponse machineGraphResponse = motionRecordsService.createMachineGraphResponse(facilityCd,
//            machineTypeCd, machineSerial, baseDate, weeks);
//        return new ResponseEntity<>(machineGraphResponse, HttpStatus.OK);
//
//      // DAB自己診断
//      case TestType.PIPING_TEST:
//      case TestType.HEMODILUTION_TEST:
//        DabGraphResponse dabGraphResponse = motionRecordsService.createDabGraphResponse(facilityCd, machineTypeCd,
//            machineSerial, baseDate, weeks);
//        return new ResponseEntity<>(dabGraphResponse, HttpStatus.OK);
//
//      default:
//        // ログ出力
//        eventLogMessage.setLogMessage("REST request is BAD_REQUEST");
//        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
//        null);
//        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
//      }
      return motionRecordsService.getGraphData(facilityCd,machineTypeCd,machineSerial,testType, baseDate ,weeks, eventLogMessage);
// modify by SunZelin  2023-02-01 [CodeOptimization]  end
    } catch (IOException e) {
      // ログ出力
        eventLogMessage.setLogMessage("REST request is BAD_REQUEST");
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 溶解記録のグラフデータ取得.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param baseDate 基準日
   * @param weeks 指定期間(週)
   * @return グラフデータのResponse
   */
  @GetMapping("/detail/graphs/dissolution/{facilityCd}/{machineTypeCd}/{machineSerial}/{baseDate}/{weeks}")
  public ResponseEntity<?> getDissolutionGraphData(@PathVariable String facilityCd,
      @PathVariable String machineTypeCd, @PathVariable String machineSerial,
      @PathVariable String baseDate, @PathVariable String weeks) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get GraphData : "+ facilityCd+ machineTypeCd+ machineSerial+ baseDate+ weeks);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
    null);

    try {
      // レスポンス生成
      DissolutionGraphResponse response = motionRecordsService.createDissolutionGraphResponse(facilityCd, machineTypeCd,
          machineSerial, baseDate, weeks);
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (IOException e) {
      // ログ出力
      eventLogMessage.setLogMessage("REST request is BAD_REQUEST");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 装置動作記録の対処フラグと対処者を更新.
   *
   * @param request リクエスト
   * @return レスポンス
   */
  //mod #12659 securify SQLインジェクション(High) まとめ zrx start
  @PutMapping("/detail/correction")
  public ResponseEntity<?> updateCorrection(@Valid @RequestBody UpdateCorrectionRequest request,
                                            BindingResult validationResult) {
    if (validationResult.hasErrors()) {
      return ResponseEntity.badRequest().build();
    }

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update isCorrection.");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
    null);

    boolean isSuccess = motionRecordsService.updateCorrection(request.getMotionRecordNo(), request.getUserId(),
        request.getIsCorrection());
    if (!isSuccess) {
      return ResponseEntity.badRequest().build();
    }

    return ResponseEntity.ok().build();
  }

  /**
   * 対象データ(緊急発報/予防保守)をすべて対処済に更新.
   *
   * @param request リクエスト
   * @return レスポンス
   */
  @PutMapping("/detail/all_target_corrections/")
  public ResponseEntity<?> updateAllTargetCorrections(@Valid @RequestBody UpdateAllCorrectionsRequest request) {

    boolean isSuccess = motionRecordsService.updateAllTargetCorrectinos(
        request.getFacilityCd(), request.getMachineTypeCd(), request.getMachineSerial(), request.getUserId(),
        Integer.valueOf(request.getDataType()));
    if (!isSuccess) {
      return ResponseEntity.badRequest().build();
    }

    return ResponseEntity.ok().build();
  }

  /**
   * データ収集記録のファイルダウンロード処理.
   *
   * @param request ファイルダウンロードのリクエスト
   * @return ファイルダウンロード用ResponseEntity
   */
  @PostMapping("/detail/gathering/download")
  public ResponseEntity<?> downloadGathering(@Valid @RequestBody DownloadGatheringRequest request) {

    InputStream is = null;
    ByteArrayOutputStream os = null;

    String localStore = null;
    String status = null;

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to download.");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
    null);

    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      localStore = onPremise.get("path");
      status = onPremise.get("status");
    } catch (Exception e) {
      logger.debug(e.getMessage());
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    try {
      String bucket = request.getBucket();
      String filename = request.getFilename();

      // bucket名から"s3://"を取り除く
      // "s3://"を付与している事でS3からS3Objectの取得が出来ない為
      bucket = bucket.replace("s3://", "");

      if (status.equals("on")) {
        String fileLocation = localStore + "/" + bucket + "/" + filename;
        Path path = Paths.get(fileLocation);
        byte[] bytes = Files.readAllBytes(path);
        // 16進数文字列に変換
        String hexString = DatatypeConverter.printHexBinary(bytes);
        return new ResponseEntity<>(hexString, HttpStatus.OK);
      } else {

        // S3オブジェクト取得
        S3Object object = s3.getObject(new GetObjectRequest(bucket, filename));
        if (object == null) {
          return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }

        // レスポンス用データ生成
        is = object.getObjectContent();
        os = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        while (true) {
          int len = is.read(buffer);
          if (len < 0) {
            break;
          }
          os.write(buffer, 0, len);
        }
        byte[] content = os.toByteArray();
        // 16進数文字列に変換
        String hexString = DatatypeConverter.printHexBinary(content);
        return new ResponseEntity<>(hexString, HttpStatus.OK);
      }
    } catch (Exception e) {
      // エラーメッセージをログ出力
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
    	null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);

    } finally {
      if (status.equals("off")) {
        try {
          is.close();
          os.close();
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
          null);
        }
      }
    }
  }

  /**
   * データ収集ステータス取得.
   *
   * @param userId ユーザーID（内部）
   * @param facilityCd 施設コード
   * @return データ収集ステータスのResponse
   */
  @GetMapping("/gathering_status/{userId}/{facilityCd}")
  public ResponseEntity<?> getGetheringStatus(@PathVariable Long userId, @PathVariable String facilityCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get GetheringStatus : "+ userId+ facilityCd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
    null);

    // レスポンス生成
    GatheringStatusResponse response = motionRecordsService.getGatheringStatus(userId, facilityCd);

    return new ResponseEntity<>(response, HttpStatus.OK);

  }

  /**
   * Deviceサーバのデータ収集API呼び出し.
   *
   * @param request データ収集API呼び出しのrequest
   */
  @PostMapping("/request/data_gathering")
  public ResponseEntity<?> sendDataGatheringRequest(@Valid @RequestBody SendDataGatheringRequestRequest request) {

    // ログ出力
	  EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to send data gathering request.");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
	  null);
	  eventLogMessage.setLogMessage( "url["+dataGatheringProperties.getDataGathering().getUrl()+"] header-name["+dataGatheringProperties.getDataGathering().getHeaderName()+"] header-value["+dataGatheringProperties.getDataGathering().getHeaderValue()+"]");
	  logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI,
	  null);

    try {
      RequestEntity<?> requestEntity = RequestEntity.post(new URI(dataGatheringProperties.getDataGathering().getUrl()))
        .header(dataGatheringProperties.getDataGathering().getHeaderName(), dataGatheringProperties.getDataGathering().getHeaderValue())
        .body(request);

      RestTemplate restTemplate = new RestTemplate();
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // API呼び出し
      ResponseEntity<String> result = restTemplate.exchange(requestEntity, String.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.MotionRecordResource");
      map.put("methodName", "sendDataGatheringRequest");
      map.put("method", requestEntity.getMethod());
      map.put("url", requestEntity.getUrl());
      map.put("headers", requestEntity.getHeaders().toSingleValueMap());
      map.put("requestParameter", requestEntity.getBody());
      map.put("status",result.getStatusCode());
      map.put("cost", cost);
      map.put("result",result.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      return result;

    } catch (URISyntaxException e) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);

    }
  }

  /**
   * 装置動作記録のサービス対応区分及び対応者を更新する.
   *
   * @param request リクエスト
   * @param ntssUser 認証情報
   * @return レスポンス
   */
  @PutMapping("/detail/service_support")
  public ResponseEntity<?> updateServiceSupport(
    @Valid @RequestBody UpdateServiceSupportRequest request,
    @AuthenticationPrincipal NtssUser ntssUser
  ) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update serviceSupport.");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI, null);

    boolean result = motionRecordsService.updateServiceSupport(
      request.getMotionRecordNo(),
      request.getServiceSupportType(),
      ntssUser.getUserId());
    if (!result) {
      return ResponseEntity.badRequest().build();
    }

    return ResponseEntity.ok().build();
  }

  /**
   * 対象データ(緊急発報/予防保守)の未対応、1次対応済みをすべてサービス対応済みに更新する.
   *
   * @param request リクエスト
   * @param ntssUser 認証情報
   * @return レスポンス
   */
  @PutMapping("/detail/all_service_support")
  public ResponseEntity<?> updateAllServiceSupport(
    @Valid @RequestBody UpdateServiceSupportAllRequest request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update all serviceSupportType to supported .");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI, null);

    boolean result = motionRecordsService.updateAllServiceSupport(
      request.getFacilityCd(),
      request.getMachineTypeCd(),
      request.getMachineSerial(),
      ntssUser.getUserId(),
      // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start
      Integer.valueOf(request.getDataType())
      // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end
    );
    if (!result) {
      return ResponseEntity.badRequest().build();
    }
    return ResponseEntity.ok().build();
  }

  /**
   * 与えられた装置情報と装置動作記録番号に該当する装置動作記録を取得する.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param motionRecordNo 装置動作記録番号
   * @return 装置情報および装置動作記録番号に該当する装置動作記録
   */
  @GetMapping("/getByMachineAndMotionRecordNo/{facilityCd}/{machineTypeCd}/{machineSerial}/{motionRecordNo}")
  public ResponseEntity<?> getByMachineAndMotionRecordNo(@PathVariable String facilityCd,
      @PathVariable String machineTypeCd, @PathVariable String machineSerial, @PathVariable Long motionRecordNo) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get by machine and motion_record_no.");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_DETAIL, SERVICE_NAME.FNSI, null);

    MntMotionRecord result = motionRecordsService.findByMachineAndMotionRecordNo(facilityCd, machineTypeCd, machineSerial, motionRecordNo);

    return new ResponseEntity<>(result, HttpStatus.OK);
  }
}
