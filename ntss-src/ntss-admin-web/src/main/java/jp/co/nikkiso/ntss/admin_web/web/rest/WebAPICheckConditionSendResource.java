package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.Map;
import java.util.MissingFormatArgumentException;

import jakarta.validation.Valid;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebAPICheckConditionSend;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;


/**
 * 条件送信結果ＷｅｂＡＰＩ
 *      呼び出し用WebAPI
 *
 */
@RestController
@RequestMapping("/api/WebAPICheckConditionSend")
public class WebAPICheckConditionSendResource {


  @Autowired
  WebAPICheckConditionSend webAPICheckConditionSend ;

  @Autowired
  LogService logService;
  @Autowired
  OrdMainService ordMainService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * WebAPI エンドポイント(条件送信画面系3010の呼び出し)
   * @param bodydata　JSON形式データ
   *    1.オーダー番号                ord_no          Long
   * @return HttpStatusとメッセージ(String)
   *    HttpStatus
   *        200:正常
   *        400:チェック処理でのエラー
   *        500:上記以外のエラー全般(Ｖａｌｉｄａｔｉｏｎの結果で生じたエラーなどもこちらに含まれる)
   *    メッセージ
   *        エラーの詳細
   */
  @PostMapping("/CheckCondition")
  public ResponseEntity<String> postCheck(
      @Valid @RequestBody String bodydata,
      @AuthenticationPrincipal NtssUser ntssUser
  )
  {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/api/WebAPICheckConditionSend" + "/CheckCondition";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      bodydata);
    // wp アプリケーションログの適正化 Add End
    //レスポンス用    HTTPステータス
    HttpStatus status = HttpStatus.OK;
    //戻りメッセージ
     String msg = "" ;
    //レスポンス用    ResponseEntity  メッセージとステータスを詰める
    ResponseEntity<String> retResEnt = new ResponseEntity<String>(status);


//    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("bodydata:" + bodydata.toString());
//    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end

    JSONObject json = new JSONObject(bodydata) ;
    Long ordNo = Long.valueOf(json.getString("ordNo"));
    OrdMain ordMain = ordMainService.selectByOrdNo(ordNo);
    if (ntssUser == null || (ordMain != null && ordMain.getFacilityCd() != null
      && !ordMain.getFacilityCd().equals(ntssUser.getFacilityCd()))) {
      // #11205 mod 20260421 start
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + ordMain.getFacilityCd() + " " + "ordNo=" + ordNo + " " + "patId=" + ordMain.getPatId() + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>("security check error", HttpStatus.FORBIDDEN);
      // #11205 mod 20260421 end
    }


    //メソッド呼び出し
    Map<String,Object> retVal = webAPICheckConditionSend.checkSendCond(ordNo) ;

    if(!(Boolean)retVal.get("ret"))
    {
      status = HttpStatus.INTERNAL_SERVER_ERROR ;
      msg = (String)retVal.get("msg") ;
    }

    retResEnt = new ResponseEntity<String>(msg,status);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return retResEnt ;
  }


  /**
   * ログ出力ラッパー
   * @param loglevel    ログレベル   ※enum LOGLEVEL参照
   * @param logFormat   ログフォーマット（メッセージ）
   * @param args        ログフォーマットの穴埋めパラメーター（可変）
   * @return
   */
  private void ServerMainlogWriterRapper(LogLevel loglevel,String logFormat,Object... args) {

    //メッセージの組み立て
    String logmsg ;
    try {
        logmsg = String.format(logFormat, args) ;
    }
    catch(MissingFormatArgumentException e)
    {
      //引数が合わなかったときなどは、そのまま出力
      logmsg = "log format error!!:" + logFormat ;

      //引数があったら、メッセージの後に連結します
      if(args != null && args.length > 0) {
        for(Object obj:args)
        {
          logmsg += ":" + obj ;
        }
      }
    }

    //ログ出力の本体
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(logmsg);
    logService.log(loglevel, eventLogMessage,"",SERVICE_NAME.FNSI, null);
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
