package jp.co.nikkiso.ntss.web_api.web.rest;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import jp.co.nikkiso.ntss.web_api.service.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.FileCopyUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.request.FacilityCancelRequest;
import jp.co.nikkiso.ntss.web_api.service.FacilityCancelService;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.util.DateUtil;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

/**
 * 施設解約Web API
 */
@RestController
@RequestMapping("facility/cancel")
public class FacilityCancelResource {

  // サービス
  /** 施設解約サービス */
  @Autowired
  private FacilityCancelService facilityCancelService;

  /** ログサービス */
  @Autowired
  private LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 施設解約を登録する。
   *
   * @param req  リクエストパラメータ
   * @return ResponseEntity
   */
  @PostMapping("/register")
  public ResponseEntity<String> register(@RequestBody FacilityCancelRequest req) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/facility/cancel" + "/register";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    String facilityCd = req.getFacilityCd();
    if (StringUtils.isEmpty(facilityCd)) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("施設コードが指定されていません。", HttpStatus.BAD_REQUEST);
    }

    String baseDate = req.getBaseDate();
    if (StringUtils.isEmpty(baseDate)) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("解約基準日が指定されていません。", HttpStatus.BAD_REQUEST);
    }

    String procClass = req.getProcClass();
    if (StringUtils.isEmpty(procClass)) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("処理区分が指定されていません。", HttpStatus.BAD_REQUEST);
    }

    try {
      facilityCancelService.register(facilityCd, baseDate, procClass);

      String okMsg = String.format("施設解約を登録しました。 施設コード:[%s]", facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(okMsg, HttpStatus.OK);

      // 対象施設が存在しない場合（対象テーブルなし）は、現実的にあり得ないため考慮しない。
    } catch (NtssException e) {
      // サービス層以下でNtssExceptionが発生した場合、ログは出力済である。
      // そのためここでは出力しない。
      // 以下同様に、NtssExceptionの場合はエラーログを出力せずにエラー応答を返す。

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    } catch (Exception e) {
      String errMsg = String.format("施設解約の登録で内部エラーが発生しました。 施設コード:[%s]", facilityCd);
      //errorLog(facilityCd, errMsg, e);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 施設解約で削除されるレコードのバックアップを取得する。
   *
   * @param req  リクエストパラメータ
   * @return ResponseEntity
   */
  @PostMapping("/backup")
  public ResponseEntity<String> backup(@RequestBody FacilityCancelRequest req) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/facility/cancel" + "/backup";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    Long expiration = req.getExpiration();

    if (expiration != null && expiration <= 0) {
      String errMsg = String.format("実行時間上限には正の整数を指定してください。 指定された値:[%s]", expiration);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(errMsg, HttpStatus.BAD_REQUEST);
    }

    try {
      facilityCancelService.backup(expiration);

      String okMsg = String.format("削除対象レコードをバックアップしました。");

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(okMsg, HttpStatus.OK);

    } catch (NtssException e) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    } catch (Exception e) {
      String errMsg = String.format("削除対象レコードのバックアップで内部エラーが発生しました。");
      //errorLog(null, errMsg, e);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 施設解約を実行する。
   *
   * @param req リクエストパラメータ
   * @return ResponseEntity
   */
  @PostMapping("/execute")
  public ResponseEntity<String> execute(@RequestBody FacilityCancelRequest req) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/facility/cancel" + "/execute";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    Long expiration = req.getExpiration();

    if (expiration != null && expiration <= 0) {
      String errMsg = String.format("実行時間上限には正の整数を指定してください。 指定された値:[%s]", expiration);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(errMsg, HttpStatus.BAD_REQUEST);
    }

    try {
      facilityCancelService.execute(expiration);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>("施設解約を実行しました。", HttpStatus.OK);
    } catch (NtssException e) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    } catch (Exception e) {
      String errMsg = String.format("施設解約の実行で内部エラーが発生しました。");
     // errorLog(null, errMsg, e);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 施設解約（予約）をキャンセルする。
   *
   * @param req リクエストパラメータ
   * @return ResponseEntity
   */
  @PostMapping("/cancel")
  public ResponseEntity<String> cancel(@RequestBody FacilityCancelRequest req) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/facility/cancel" + "/cancel";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    String facilityCd = req.getFacilityCd();
    if (StringUtils.isEmpty(facilityCd)) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>("施設コードが指定されていません。", HttpStatus.BAD_REQUEST);
    }

    String procClass = req.getProcClass();
    if (StringUtils.isEmpty(procClass)) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>("処理区分が指定されていません。", HttpStatus.BAD_REQUEST);
    }

    try {
      facilityCancelService.updateStatus(facilityCd, procClass);

      String okMsg = String.format("施設解約をキャンセルしました。 施設コード:[%s]", facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(okMsg, HttpStatus.OK);
    } catch (NtssException e) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    } catch (Exception e) {
      String errMsg = String.format("施設解約のキャンセルで内部エラーが発生しました。 施設コード:[%s]", facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 施設解約バックアップファイルをダウンロードする。
   *
   * @param res HTTPレスポンス
   * @param req リクエストパラメータ
   */
  @PostMapping(value="/download")
  public void download(HttpServletResponse res, @RequestBody FacilityCancelRequest req) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/facility/cancel" + "/download";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      if (StringUtils.isEmpty(req.getFacilityCd())) {
        res.setContentType("application/json");
        res.setStatus(HttpStatus.BAD_REQUEST.value());
        res.setCharacterEncoding(StandardCharsets.UTF_8.name());
        PrintWriter out = res.getWriter();
        Map<String, String> resMap = new HashMap<String, String>();
        resMap.put("message", String.format("施設コードが指定されていません。"));
        out.print(ObjectMapperUtil.write(resMap));

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return;
      }

      if (StringUtils.isEmpty(req.getBaseDate())) {
        res.setContentType("application/json");
        res.setStatus(HttpStatus.BAD_REQUEST.value());
        res.setCharacterEncoding(StandardCharsets.UTF_8.name());
        PrintWriter out = res.getWriter();
        Map<String, String> resMap = new HashMap<String, String>();
        resMap.put("message", String.format("解約基準日が指定されていません。"));
        out.print(ObjectMapperUtil.write(resMap));

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return;
      }

      if (StringUtils.isEmpty(req.getProcClass())) {
        res.setContentType("application/json");
        res.setStatus(HttpStatus.BAD_REQUEST.value());
        res.setCharacterEncoding(StandardCharsets.UTF_8.name());
        PrintWriter out = res.getWriter();
        Map<String, String> resMap = new HashMap<String, String>();
        resMap.put("message", String.format("処理区分が指定されていません。"));
        out.print(ObjectMapperUtil.write(resMap));

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return;
      }

      String baseDate = DateUtil.convertDateToStringFormat(req.getBaseDate());

      byte[] downloadByteData = facilityCancelService.getBackupData(req.getFacilityCd(), baseDate, req.getProcClass());
      if (downloadByteData == null) {
        res.setContentType("application/json");
        res.setCharacterEncoding(StandardCharsets.UTF_8.name());
        PrintWriter out = res.getWriter();
        Map<String, String> resMap = new HashMap<String, String>();
        resMap.put("message", "ダウンロード対象が存在しません。");
        out.print(ObjectMapperUtil.write(resMap));

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return;
      }

      ByteArrayResource downloadResource = new ByteArrayResource(downloadByteData);
      res.setContentType("application/octet-stream");
      res.setContentLength(downloadByteData.length);
      res.setHeader("Content-Disposition","attachment; filename=\"download.zip\"");
      FileCopyUtils.copy(downloadResource.getInputStream(), res.getOutputStream());

    } catch(Exception e) {
      res.setContentType("application/json");
      res.setCharacterEncoding(StandardCharsets.UTF_8.name());
      res.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
      try {
        PrintWriter out = res.getWriter();
        Map<String, String> resMap = new HashMap<String, String>();
        resMap.put("message", String.format("施設解約バックアップダウンロードで内部エラーが発生しました。 施設コード:[%s], 解約基準日:[%s]", req.getFacilityCd(), req.getBaseDate()));
        out.print(ObjectMapperUtil.write(resMap));
      } catch(IOException ioe) {

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
        // wp アプリケーションログの適正化 Add End
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return;
    }

    return;
  }

  /**
   * 施設解約バックアップファイルのバイナリデータを取得する
   *
   * @param req リクエストパラメータ
   * @return ResponseEntity
   */
  @PostMapping(value="/getBackupBinary")
  public ResponseEntity<byte[]> getBackupBinary(@RequestBody FacilityCancelRequest req) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/facility/cancel" + "/getBackupBinary";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      if (StringUtils.isEmpty(req.getFacilityCd()) || StringUtils.isEmpty(req.getBaseDate()) || StringUtils.isEmpty(req.getProcClass())) {

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
      }

      String baseDate = DateUtil.convertDateToStringFormat(req.getBaseDate());

      byte[] downloadByteData = facilityCancelService.getBackupData(req.getFacilityCd(), baseDate, req.getProcClass());
      if (downloadByteData == null) {

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(downloadByteData, HttpStatus.OK);


    } catch(Exception e) {
      String errMsg = String.format("施設解約バックアップデータ取得で内部エラーが発生しました。 施設コード:[%s]", req.getFacilityCd());
      //errorLog(null, errMsg, e);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }

  /**
   * 解約施設を完全削除する
   *
   * @param req リクエストパラメータ
   * @return ResponseEntity
   */
  @PostMapping("/completeDelete")
  public ResponseEntity<String> completeDelete(@RequestBody FacilityCancelRequest req) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/facility/cancel" + "/completeDelete";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    String facilityCd = req.getFacilityCd();
    if (StringUtils.isEmpty(facilityCd)) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("施設コードが指定されていません。", HttpStatus.BAD_REQUEST);
    }

    try {
      facilityCancelService.completeDeleteFacility(facilityCd);

      String okMsg = String.format("解約施設を完全削除しました。 施設コード:[%s]", facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(okMsg, HttpStatus.OK);
    } catch (NtssException e) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    } catch (Exception e) {

      String errMsg = String.format("施設解約の完全削除で内部エラーが発生しました。 施設コード:[%s]", facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * ReMS/FNSi解約施設のバックアップファイルを削除する
   *
   * @param req リクエストパラメータ
   * @return ResponseEntity
   */
  @PostMapping("/dataDelete")
  public ResponseEntity<String> dataDelete(@RequestBody FacilityCancelRequest req) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/facility/cancel" + "/dataDelete";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    String facilityCd = req.getFacilityCd();
    if (StringUtils.isEmpty(facilityCd)) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("施設コードが指定されていません。", HttpStatus.BAD_REQUEST);
    }

    try {
      facilityCancelService.dataDeleteFacility(facilityCd);

      String okMsg = String.format("バックアップファイルを削除しました。 施設コード:[%s]", facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(okMsg, HttpStatus.OK);
    } catch (NtssException e) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    } catch (Exception e) {
      String errMsg = String.format("バックアップファイル削除処理で内部エラーが発生しました。 施設コード:[%s]", facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * エラーログを出力する。
   *
   * @param facilityCd 施設コード
   * @param errMsg エラーメッセージ
   * @param t 例外
   */
  private void errorLog(String facilityCd, String errMsg, Throwable t) {
    EventLogMessage msg = new EventLogMessage();
    msg.setFacilityCd(facilityCd);
    msg.setLogMessage(errMsg);
    msg.setSupportMessage(t.toString());

    logService.log(LogLevel.ERROR, msg, null, SERVICE_NAME.REMS, null);
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
