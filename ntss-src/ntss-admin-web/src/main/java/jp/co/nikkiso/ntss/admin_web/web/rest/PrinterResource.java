package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;

import jp.co.nikkiso.ntss.core.dao.MstPrinterDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.response.creatingReport.PrinterInfo;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.print.PrinterService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.custom.MstPrinter;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * プリンターマスターのResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.PRINTERS)
public class PrinterResource {
  // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
  @Autowired
  MstPrinterDao mstDao;
  // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 end

  @Autowired
  PrinterService service;

  @Autowired
	LogService logService;
  /**
   * プリンターマスタ登録
   * @param clientKey 印刷サーバーアプリ識別子
   * @param ntssUser 認証情報
   * @param request 登録するプリンターマスタ
   * @return
   */
  @PostMapping("/{clientKey}")
  public ResponseEntity<?> postSaveMstPrinter(@PathVariable(name = "clientKey", required = true) String clientKey, @AuthenticationPrincipal NtssUser ntssUser, @RequestBody MstPrinter[] request) {

    try {

      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
			eventLogMessage.setLogMessage("REST request to post data for mst_printer.");
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // 表示用プリンター名の長さが0ならばプリンター名をセットする
      for (MstPrinter s : request) {
        if(s.getDispPrinterName().isEmpty())
        {
          s.setDispPrinterName(s.getPrinterName());
        }
      }

      // プリンターを追加する
      service.insert(ntssUser.getFacilityCd(), clientKey, request);

      return new ResponseEntity<>(HttpStatus.OK);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }

  /**
   * プリンターマスタを読み込む
   * @param ntssUser 認証情報
   * @return プリンターマスタデータのResponse
   */
  @GetMapping("")
  public ResponseEntity<?> getAll(@AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer.");
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    try {

      // プリンターマスタのレスポンス生成
      List<PrinterInfo> res = service.getPrinterInfos(ntssUser.getFacilityCd());

      // レスポンス作成
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (Exception e) {

      // マスタが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
			logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
  /**
   * プリンターマスタを読み込む
   * @param ntssUser 認証情報
   * @param facilityCd 施設コード
   * @return プリンターマスタデータのResponse
   */
  @GetMapping("{facilityCd}")
  public ResponseEntity<?> getAll(
    @AuthenticationPrincipal NtssUser ntssUser,
    @PathVariable(name = "facilityCd", required = true) String facilityCd
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 end

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get data for report layout designer.");
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    try {

      // プリンターマスタのレスポンス生成
      List<PrinterInfo> res = service.getPrinterInfos(facilityCd);

      // レスポンス作成
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (Exception e) {

      // マスタが取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }
  // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end

  // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
  /**
   * プリンターマスタのデータを所得
   * @param facilityCd　施設コード
   * @return
   */
  @GetMapping("/printer-date/{facilityCd}")
  public ResponseEntity<?> getPrinters(@PathVariable String facilityCd,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260421 start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260421 end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260421 end
    try {
      List<jp.co.nikkiso.ntss.core.entity.MstPrinter> printers = mstDao.getPrinters(facilityCd);
      return new ResponseEntity<>(printers, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * クライアント識別子を更新
   * @param request プリンターマスタのデータ
   * @return
   */
  @PutMapping("/clientKey/{clientKey}")
  public ResponseEntity<?> putClientKey(@PathVariable String clientKey,@RequestBody List<String> request) {
    try {
      /* modify by lvzongheng  2023-02-01 [Transaction,CodeOptimization]  start */
//      for (String req: request) {
//        req = req.replace("\"","").replace("{","").replace("}","");
//        String[] printerArr = req.split(";");
//        String strPrinterCd = "";
//        String strClientKey = "";
//        String strType = "";
//        if("printerCd".equals(printerArr[0].split(":")[0].trim())){
//          strPrinterCd = printerArr[0].split(":")[1];
//        }else{
//          return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//        }
//        if("clientKey".equals(printerArr[1].split(":")[0].trim())){
//          // add FNSI-4749 不要プリンターの削除機能対応 夏 start
//          if(printerArr[1].split(":").length > 1) {
//            // add FNSI-4749 不要プリンターの削除機能対応 夏 end
//            strClientKey = printerArr[1].split(":")[1];
//            // add FNSI-4749 不要プリンターの削除機能対応 夏 start
//          }else{
//            strClientKey = "";
//          }
//          // add FNSI-4749 不要プリンターの削除機能対応 夏 end
//        }else{
//          return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//        }
//        if("type".equals(printerArr[2].split(":")[0].trim())){
//          strType = printerArr[2].split(":")[1];
//        }else{
//          return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//        }
//        // add FNSI-4749 不要プリンターの削除機能対応 夏 start
//        if(strClientKey.isEmpty()){
//          mstDao.updateIsDelOnByPrinterCd(strPrinterCd, strClientKey);
//        }else {
//          // add FNSI-4749 不要プリンターの削除機能対応 夏 end
//          if (clientKey.equals(strClientKey) && !"ADD".equals(strType)) {
//            // mod FNSI-4749 不要プリンターの削除機能対応 夏 start
////            mstDao.updateIsDelOnByPrinterCd(strPrinterCd);
//            mstDao.updateIsDelOnByPrinterCd(strPrinterCd, strClientKey);
//            // mod FNSI-4749 不要プリンターの削除機能対応 夏 start
//          } else {
//            mstDao.updateclientKey(strPrinterCd, strClientKey);
//          }
//          // add FNSI-4749 不要プリンターの削除機能対応 夏 start
//        }
//        // add FNSI-4749 不要プリンターの削除機能対応 夏 end
//      }
      return service.putClientKey(clientKey,request);
      /* modify by lvzongheng  2023-02-01 [Transaction,CodeOptimization]  end */
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * プリンターマスタ削除
   * @param clientKey 印刷サーバーアプリ識別子
   * @param ntssUser 認証情報
   * @param request 登録するプリンターマスタ
   * @return
   */
  @PostMapping("/printDel/{clientKey}")
  public ResponseEntity<?> postDeleteMstPrinter(@PathVariable(name = "clientKey", required = true) String clientKey,
                                                @AuthenticationPrincipal NtssUser ntssUser,
                                                @RequestBody MstPrinter[] request) {
    try {
      // プリンターを削除する
      service.delete(ntssUser.getFacilityCd(), clientKey, request);
      return new ResponseEntity<>(HttpStatus.OK);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }
  // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 end

}
