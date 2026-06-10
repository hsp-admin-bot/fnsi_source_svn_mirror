package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.service.report.ReportS3Service;
import jp.co.nikkiso.ntss.api.service.utils.AsposeCellsUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.master.report.MstReportService;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import lombok.extern.slf4j.Slf4j;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


/**
 * 帳票マスタのResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.MASTER_REPORT)
public class MstReportResource {

  @Autowired
  MstReportService mstReportService;
  @Autowired
	LogService logService;
  @Autowired
  ResourceLoader resourceLoader;
  // add 6589 治癒経過表：プレビューでシステムエラー 吉 start
  @Autowired
  private ReportS3Service reportS3Service;
  // add 6589 治癒経過表：プレビューでシステムエラー 吉 end
  /**
   * 帳票マスタのデータ取得.
   *
   * @return マスタデータのResponse
   *
   */
  @GetMapping("")
  public ResponseEntity<?> getAll(@AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer.");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
    null);

    try {

      // 帳票マスタのレスポンス生成
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      //List<MstReport> resReport = mstReportService.selectAll(ntssUser.getFacilityCd());
      // mod #11501 レイアウトデザイナのユーザビリティ改善 limingzhe start
      //List<MstReport> resReport = mstReportService.selectAllForFixedAndNormal(ntssUser.getFacilityCd(), null, "0");
      List<MstReport> resReport = mstReportService.selectAllForFixedAndNormal(ntssUser.getFacilityCd(), null, null);
      // mod #11501 レイアウトデザイナのユーザビリティ改善 limingzhe end
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      // レスポンス作成
      return new ResponseEntity<>(resReport, HttpStatus.OK);

    } catch (Exception e) {

      // マスタが取得できなかった場合
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
    	null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }
  // add マスタ一覧 1･施設切替を可能とする 王 start
  /**
   * 帳票マスタのデータ取得.
   *
   * @return マスタデータのResponse
   *
   */
  //mod 6502 6498 5984 定期・日常が分離されていない 吉 start
//  @GetMapping("/data/{facilityCd}")
//  public ResponseEntity<?> getAllByFacilityCd(@PathVariable(name = "facilityCd", required = true) String facilityCd) {
  @GetMapping("/data/{facilityCd}/{vorcFlag}")
  public ResponseEntity<?> getAllByFacilityCd(@PathVariable(name = "facilityCd", required = true) String facilityCd,
                                              @PathVariable(name = "vorcFlag", required = false) String vorcFlag) {
//mod 6502 6498 5984 定期・日常が分離されていない 吉 end
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer.");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
      null);

    try {

      // 帳票マスタのレスポンス生成
      //mod 6502 6498 5984 定期・日常が分離されていない 吉 start
//      List<MstReport> resReport = mstReportService.selectAll(facilityCd);
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      //List<MstReport> resReport = mstReportService.selectByFlag(facilityCd,vorcFlag);
      List<MstReport> resReport = mstReportService.selectAllForFixedAndNormal(facilityCd, null, "0");
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      //mod 6502 6498 5984 定期・日常が分離されていない 吉 end

      // レスポンス作成
      return new ResponseEntity<>(resReport, HttpStatus.OK);

    } catch (Exception e) {

      // マスタが取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }
  // add マスタ一覧 1･施設切替を可能とする 王 end
  /**
   * 帳票マスタデータ取得.
   *
   * @param reportCd レポートCD
   * @return マスタデータのResponse
   */
  @GetMapping("/{reportCd}")
  public ResponseEntity<?> getByCd(@PathVariable(name = "reportCd", required = true) long reportCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer."+reportCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
    null);
    try {

      // 帳票マスタのレスポンス生成
      MstReport resReport = mstReportService.getMstReport(reportCd);

      // レスポンス作成
      return new ResponseEntity<>(resReport, HttpStatus.OK);

    } catch (Exception e) {

      // マスタが取得できなかった場合
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
    	null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 帳票名更新
   *
   * @param request
   * @return
   */
  @PutMapping("/report_name")
  public ResponseEntity<?> putReportName(@RequestBody MstReport request) {

    try {

      // ログ出力

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to put report name for report layout designer.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
      null);
      // 帳票マスタを登録する
      mstReportService.updateReportName(request);

      return new ResponseEntity<>(HttpStatus.OK);

    } catch (Exception e) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
    	null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 3ファイルのフルパス更新
   *
   * @param request
   * @return
   */
  @PutMapping("/report_path")
  public ResponseEntity<?> putReportPath(@RequestBody MstReport request) {

    try {

      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to put report file path for report layout designer.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
      null);

      // 帳票マスタを登録する
      mstReportService.updateReportPath(request);

      return new ResponseEntity<>(HttpStatus.OK);

    } catch (Exception e) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
    	null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 表示/非表示フラグを更新
   *
   * @param request
   * @return
   */
  @PutMapping("/is_disp")
  public ResponseEntity<?> putIsDisp(@RequestBody MstReport request) {

    try {

      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to put disp flag for report layout designer.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
      null);

      // 帳票マスタを登録する
      mstReportService.updateIsDisp(request);

      return new ResponseEntity<>(HttpStatus.OK);

    } catch (Exception e) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
    	null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 帳票名, 表示非表示フラグ, 削除フラグ更新.
   *
   * @param request 更新データ
   * @return HTTPレスポンス
   */
  @PutMapping("/{facilityCd}/list_data")
  public ResponseEntity<?> putReportNameDispDel(@RequestBody List<MstReport> request,
                                                @PathVariable(name = "facilityCd", required = true) String facilityCd,
                                                @AuthenticationPrincipal NtssUser ntssUser) {

    try {

      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to put report name for report layout designer.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
      null);

      // 帳票名, 表示非表示フラグ, 削除フラグを更新する
      // mod 6589 治癒経過表：プレビューでシステムエラー 吉 start
      mstReportService.updateListData(request, facilityCd, false, ntssUser);
      // del 6589 治癒経過表：プレビューでシステムエラー 吉 start
//      if(null != request && request.size() == 1){
//        MstReport re = request.get(0);
//        boolean flag= reportS3Service.getReportFileIsExist(
//          re.getReportPath().getBucket(),
//          re.getReportPath().getReportZip(),
//          re.getUpDate());
//        if(flag){
//          mstReportService.updateListData(request, ntssUser.getFacilityCd());
//        }else{
//          return new ResponseEntity<>("noExist",HttpStatus.OK);
//        }
//      }
      // del 6589 治癒経過表：プレビューでシステムエラー 吉 end
      // mod 6589 治癒経過表：プレビューでシステムエラー 吉 end
      return new ResponseEntity<>(HttpStatus.OK);

    } catch (Exception e) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
    	null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }
  // MOD #10637 2024/09/05 Thach Start
  // add 6589 帳票ツールの版数を適用するためのインターフェースの抽出　吉 start
  @PutMapping("/edit_report_no")
  public ResponseEntity<?> putReportNoInfo(@RequestBody Map<String, String> request, @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to put set selected history for report layout designer.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,null);

      String result = mstReportService.updateSelectedHst(Long.parseLong(request.get("reportCd")), request.get("selectedHistory"));
      if(!result.equals("")) {
        return new ResponseEntity<>(result, HttpStatus.OK);
      }

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add 6589 帳票ツールの版数を適用するためのインターフェースの抽出　吉 end
  // MOD #10637 2024/09/05 Thach End

  //add 6502  装置帳票：定期・日常が分離されていない  吉 start
  @PutMapping("/check_repeat")
  public ResponseEntity<?> checkRepeat(@RequestBody MstReport request, @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to put report name for report layout designer.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
        null);
      // 帳票名, 表示非表示フラグ, 削除フラグを更新する
      MstReport mstrep = mstReportService.checkRepeat(request, ntssUser.getFacilityCd());
      return new ResponseEntity<>(mstrep,HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //add 6502  装置帳票：定期・日常が分離されていない  吉 end
  /**
   * 表示/非表示フラグを更新
   *
   * @param request
   * @return
   */
  @PutMapping("/{reportCd}/is_del")
  public ResponseEntity<?> putIsDel(@PathVariable(name = "reportCd", required = true) long reportCd, @AuthenticationPrincipal NtssUser ntssUser) {

    try {

      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to put del flag for report layout designer.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
      null);

      // 帳票マスタを登録する
      mstReportService.updateIsDel(reportCd, ntssUser.getFacilityCd());

      return new ResponseEntity<>(HttpStatus.OK);

    } catch (Exception e) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
    	null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
  /**
   * 帳票マスタのデータ取得.
   *
   * @return マスタデータのResponse
   *
   */
  @GetMapping("/{facilityCd}/facilityCd")
  public ResponseEntity<?> getDataByFacilityCd(@PathVariable(name = "facilityCd", required = true) String facilityCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer.");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
      null);

    try {

      // 帳票マスタのレスポンス生成
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      //List<MstReport> resReport = mstReportService.selectAll(facilityCd);
      // mod #11501 レイアウトデザイナのユーザビリティ改善 limingzhe start
      //List<MstReport> resReport = mstReportService.selectAllForFixedAndNormal(facilityCd, null, "0");
      List<MstReport> resReport = mstReportService.selectAllForFixedAndNormal(facilityCd, null, null);
      // mod #11501 レイアウトデザイナのユーザビリティ改善 limingzhe end
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

      // レスポンス作成
      return new ResponseEntity<>(resReport, HttpStatus.OK);

    } catch (Exception e) {

      // マスタが取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  // MOD #10637 2024/09/05 Thach Start

  /**
   * 帳票マスタ登録
   *
   * @param request
   * @return
   */
  @PostMapping("/{facilityCd}/insert")
  public ResponseEntity<?> insertMstReport(@RequestBody MstReport request,
                                             @PathVariable(name = "facilityCd", required = true) String facilityCd,
                                             @AuthenticationPrincipal NtssUser ntssUser) {

    try {

      // ログ出力

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to post data for report layout designer.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
        null);
      // 帳票マスタを登録する
      request.setFacilityCd(facilityCd);
      mstReportService.insert(request, ntssUser);

      return new ResponseEntity<>(request, HttpStatus.OK);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 帳票名, 表示非表示フラグ, 削除フラグ更新.
   *
   * @param request 更新データ
   * @return HTTPレスポンス
   */
  @PutMapping("/{facilityCd}/update")
  public ResponseEntity<?> updateMstReport(@RequestBody List<MstReport> request,
                                             @PathVariable(name = "facilityCd", required = true) String facilityCd,
                                             @AuthenticationPrincipal NtssUser ntssUser) {

    try {

      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to put report name for report layout designer.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
        null);

      // 帳票名, 表示非表示フラグ, 削除フラグを更新する
      mstReportService.updateListData(request, facilityCd, true, ntssUser);

      return new ResponseEntity<>(HttpStatus.OK);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  // MOD #10637 2024/09/05 Thach End

  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy start
  /**
   * 削除しようとする帳票が以下の箇所に配置しているかを確認
   *
   * @param reportList mst_reportレコード
   * @return HTTPレスポンス、メッセージ
   */
  @PutMapping("/{facilityCd}/checkIsCanDelete")
  public ResponseEntity<?> checkIsCanDelete(@RequestBody List<MstReport> reportList,
                                           @PathVariable(name = "facilityCd", required = true) String facilityCd) {
    try {
      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to put report name for report layout designer.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,null);
      String reportInfo = mstReportService.checkIsCanDelete(reportList, facilityCd);
      return new ResponseEntity<>(reportInfo, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy end

  // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
  // add #6435 プレビューがexcelとブラウザで異なる xiaosonglei start
  @PostMapping("/getHtml/{facilityCd}")
  public ResponseEntity<?> getHtml(@RequestBody Map<String, byte[]> param, @PathVariable(name = "facilityCd", required = true) String facilityCd) {
    try {
      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "REST request to post data for report layout designer.");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
        null);
      InputStream byteArrayInputStream = new ByteArrayInputStream(param.get("excelBytes"));
      URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
      String reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream,url);
      return new ResponseEntity<>(reportHtml,HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add #6435 プレビューがexcelとブラウザで異なる xiaosonglei end
}
