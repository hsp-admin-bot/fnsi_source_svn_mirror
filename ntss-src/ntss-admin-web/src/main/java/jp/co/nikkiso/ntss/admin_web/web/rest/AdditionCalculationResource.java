package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;

import jp.co.nikkiso.ntss.api.request.AdditionCalculationRequest;
import jp.co.nikkiso.ntss.api.service.additionInfo.AdditionCalculationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.custom.AdditionInfoOrdMain;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import static java.util.Collections.emptyList;


/**
 * @author KhanhNQ17
 */
@RestController
@RequestMapping(Uri.ADDITION_INFO)
public class AdditionCalculationResource {

  @Autowired
  private LogService logService;

  // mod 11454 時間外加算自動処理が機能していない zkm start
//  @Autowired
//  private WebApiCallCommonUtil webApiCallCommonUtil;
  @Autowired
  private AdditionCalculationService additionCalculationService;
  // mod 11454 時間外加算自動処理が機能していない zkm end

  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * 追加料金計算
   *
   * @param request
   * @return
   */
  @PutMapping("/calculation")
  public ResponseEntity<Void> calculationAddition(@RequestBody AdditionCalculationRequest request) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "calculationAddition実施開始：" + "/calculation/");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    try {
      String facilityCd = request.getFacilityCd();
      // mod 11454 時間外加算自動処理が機能していない zkm start
//      webApiCallCommonUtil.calculationAddition(request);
      additionCalculationService.calculationAddition(request);
      // mod 11454 時間外加算自動処理が機能していない zkm end

      // wangzuo アプリケーションログの適正化 Add Start
      eventLogMessage.setLogMessage(this.getClass().getName() + "calculationAddition実施終了：" + "/calculation/" + facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // wangzuo アプリケーションログの適正化 Mod
      eventLogMessage.setLogMessage(this.getClass().getName() + "calculationAddition実施異常終了：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 加算日/前回加算日の取得
   *
   * @param request
   * @return
   */
  //mod #12462 患者情報共有 zrx start
  @GetMapping("/calculationDateList")
  public ResponseEntity<?> getCalculationDateList(
      @RequestParam(value = "ownFacility", required = true) String ownFacility,
      @RequestParam(name = "facilityCd", required = false)  String facilityCd,
      @RequestParam(name = "ordNo",required = false) Long ordNo,
      @RequestParam(name = "patId",required = true) Long patId,
      @RequestParam(name = "treatDate",required = false) String treatDate,
      @AuthenticationPrincipal NtssUser ntssUser) throws Exception {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "calculationDateList実施開始：" + "/calculationDateList/");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      List<AdditionInfoOrdMain> response;
      // 0（false）1（true）
      if(ownFacility.equals("1")){
        if(facilityCd!=null&&!facilityCd.isEmpty()){
          response = ordMainDao.selectCalculationDateList(ordNo, facilityCd, patId, treatDate);
        }else{
          response = emptyList();
        }
      }else{
        response = ordMainDao.selectCalculationDateListOtherfacilities(ordNo, facilityCd, patId, treatDate);
      }
      //mod #12462 患者情報共有 zrx end
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(this.getClass().getName() + "calculationDateList実施異常終了：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
}
