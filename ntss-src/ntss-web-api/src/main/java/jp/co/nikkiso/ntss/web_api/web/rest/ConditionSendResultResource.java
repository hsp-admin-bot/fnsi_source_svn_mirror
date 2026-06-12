package jp.co.nikkiso.ntss.web_api.web.rest;

import java.util.HashMap;

import jakarta.validation.Valid;


import jp.co.nikkiso.ntss.api.service.utils.ConditionSendResultUtil;
import jp.co.nikkiso.ntss.api.service.utils.ConditionSendResultUtil.PARAMKEY;
import jp.co.nikkiso.ntss.web_api.service.LogEventUtils;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.web_api.service.LogService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;


/**
 * 条件送信結果ＷｅｂＡＰＩ
 *
 *
 */
@RestController
@RequestMapping("util")
public class ConditionSendResultResource {


  @Autowired
  ConditionSendResultUtil conditionSendResultUtil ;

  @Autowired
  LogService logService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * WebAPI エンドポイント  条件送信結果3011
   * @param bodydata　JSON形式データ
   *    施設コード   facility_cd
   *    型式コード   machine_type_cd
   *    製造番号    machine_serial
   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
   *    HttpStatus
   *        200:正常終了
   *        400:チェック処理でのエラー
   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
   *    メッセージ(JSON文字列(キー:retMsg))
   *        正常終了時(HttpStatus(200)):空文字
   *        異常終了時(HttpStatus(400、500)):メッセージ格納
   */
  @PostMapping("/SendCondResult")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<String> sendCondResult(
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @Valid @RequestBody String bodydata
  )
  {


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "util" + "/SendCondResult";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    //レスポンス用    HTTPステータス
    HttpStatus status = HttpStatus.OK;
    //レスポンス用    ResponseEntity  メッセージとステータスを詰める
    ResponseEntity<String> retResEnt = new ResponseEntity<String>(status);
    //レスポンス用    JSON組み立て用
    JSONObject msgJson = null;
    String retMsg = "", retLogMsg = "";

    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("tmp ver");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    //戻り値初期化
    HashMap<PARAMKEY,Object> retVal = new HashMap<>();
    try {
      msgJson = new JSONObject("{}")  ;

      // add 11454 時間外加算自動処理が機能していない(ntss-web-api/src/main/java/jp/co/nikkiso/ntss/web_api/web/rest/util/ConditionSendResultUtil.javaからコピーする) zkm start
      boolean ret;
      //クラス名の取得(ログ用)
      final String className = new Object(){}.getClass().getEnclosingClass().getName();
      //メソッド名の取得(ログ用)
      final String methodName = new Object(){}.getClass().getEnclosingMethod().getName();

      //bodyデータから引数を取得
      //JSONObject宣言
      //受信パラメータ受付用(送信body情報のJSON文字列格納)
      JSONObject receiveData = null;
      //各データブロックの取得(受信データのボディからの取得処理)
      HashMap<PARAMKEY,Object> retValData = new HashMap<>() ;
      ret = conditionSendResultUtil.getDataFromBodyData(bodydata,retValData) ;

      eventLogMessage.setLogMessage("01：パラメータ取得有無：" + ret);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      if(ret) {
        //受信データ
        receiveData = (JSONObject)retValData.get(PARAMKEY.RECEIVE_DATA) ;
      }
      else
      {
        //データブロックの取得時にエラー発生
        status = (HttpStatus)retValData.get(PARAMKEY.STATUS);
        retMsg = (String)retValData.get(PARAMKEY.MSG);
        retLogMsg = (String)retValData.get(PARAMKEY.ERRMSG);

        retVal.put(PARAMKEY.STATUS, status) ;
        retVal.put(PARAMKEY.RET_MSG, retMsg) ;
        retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
        conditionSendResultUtil.exitMethod(className,methodName,retLogMsg);
      }

      //値の取得
      //呼び出し時に渡される以下の値をbodyデータ(Json)から取得する
      //・施設コード
      //・型式コード
      //・製造番号

      //    施設コード   facility_cd
      String facilityCd = (String)conditionSendResultUtil.getDataFromJSON(receiveData, PARAMKEY.FACILITY_CD.get()) ;
      //    型式コード   machine_type_cd
      String machineTypeCd = (String)conditionSendResultUtil.getDataFromJSON(receiveData, PARAMKEY.MACHINE_TYPE_CD.get()) ;
      //    製造番号    machine_serial
      String machineSerial = (String)conditionSendResultUtil.getDataFromJSON(receiveData, PARAMKEY.MACHINE_SERIAL.get()) ;

      if(null == facilityCd || null == machineTypeCd || null == machineSerial)
      {
        //必要パラメータが渡されていないので終了
        String fmt = "渡されたパラメータが不正です。"+ PARAMKEY.FACILITY_CD.get()+"(%s) " + PARAMKEY.MACHINE_TYPE_CD.get()+"(%s) "+ PARAMKEY.MACHINE_SERIAL.get()+"(%s) " ;
        retLogMsg = String.format(fmt, facilityCd,machineTypeCd,machineSerial);
        retMsg = "装置が特定できません。";
        // エラーステータス設定
        retVal.put(PARAMKEY.STATUS, HttpStatus.BAD_REQUEST) ;
        // エラーメッセージ設定
        retVal.put(PARAMKEY.RET_MSG, retMsg) ;
        retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
        // ロールバック用の例外を投げる
        conditionSendResultUtil.exitMethod(className,methodName,retLogMsg);
      }
      // add 11454 時間外加算自動処理が機能していない(ntss-web-api/src/main/java/jp/co/nikkiso/ntss/web_api/web/rest/util/ConditionSendResultUtil.javaからコピーする) zkm start

      //------------------------------------
      //main処理 3011
      // 条件送信の結果処理を行う
      //* @param bodydata        ＷｅｂＡＰＩ呼び出し時の受信データ(Ｊｓｏｎ)
      //        施設コード   facility_cd
      //        型式コード   machine_type_cd
      //        製造番号    machine_serial
      //* @param retVal  <PARAMKEY:value>    パラメータ授受用
      //*       PARAMKEY.STATUS     Httpステータス
      //*       PARAMKEY.RET_MSG    メッセージ
      // mod 11454 時間外加算自動処理が機能していない zkm start
//      conditionSendResultUtil.mainProcessSendCondResult(bodydata,retVal) ;
      conditionSendResultUtil.mainProcessSendCondResult(facilityCd, machineTypeCd, machineSerial, retVal);
      // mod 11454 時間外加算自動処理が機能していない zkm end
    }
    catch(Exception e)
    {
      //JSON関連のエラー
      status = HttpStatus.INTERNAL_SERVER_ERROR ;
      retMsg = "指示展開データエラー" ;
      retLogMsg = e.getMessage() ;
      //一旦戻り値retValに格納("戻り値の組み立て処理"共通化のため)
      retVal.put(PARAMKEY.STATUS, status) ;
      retVal.put(PARAMKEY.RET_MSG, retMsg) ;
      retVal.put(PARAMKEY.RET_LOG_MSG, retLogMsg) ;
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

    }

    //戻り値の組み立て
    try {
      //Httpステータスの取り出し
      status = (HttpStatus)retVal.get(PARAMKEY.STATUS) ;
      //メッセージの取り出し
      retMsg = (String)retVal.get(PARAMKEY.RET_MSG) ;
      retLogMsg = (String)retVal.get(PARAMKEY.RET_LOG_MSG) ;
      //返却用Ｊｓｏｎオブジェクトにセット
      msgJson.put(PARAMKEY.RET_MSG.get(), retMsg) ;

    }
    catch(JSONException e)
    {//JSON操作での例外キャッチなので、戻り値のJSONの操作はできないから、ステータスだけ変更
      status = HttpStatus.INTERNAL_SERVER_ERROR ;
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
    }
    //返却値の生成
    retResEnt = new ResponseEntity<String>(msgJson.toString(),status);

    //ログの出力
    if(HttpStatus.OK != status)
    {//エラーログ
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage = new EventLogMessage();
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      eventLogMessage.setLogMessage("例外発生：" + retLogMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }

    return retResEnt ;
  }
//  /**
//   * WebAPI エンドポイント  条件送信結果3011(ord_mainの実績反映のみ)
//   * @param bodydata　JSON形式データ
//   *    オーダー番号 ordNo
//   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
//   *    HttpStatus
//   *        200:正常終了
//   *        400:チェック処理でのエラー
//   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
//   *    メッセージ(JSON文字列(キー:retMsg))
//   *        正常終了時(HttpStatus(200)):空文字
//   *        異常終了時(HttpStatus(400、500)):メッセージ格納
//   */
//  @PostMapping("/SendCondResultOnly")
//  private ResponseEntity<String> sendCondResultOnly(
//      @Valid @RequestBody String bodydata
//  )
//  {
//
//    // wp アプリケーションログの適正化 Add Start
//    String mappingUrl = "util" + "/SendCondResultOnly";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
//      null);
//    // wp アプリケーションログの適正化 Add End
//
//      //レスポンス用    HTTPステータス
//      HttpStatus status = HttpStatus.OK;
//      //レスポンス用    ResponseEntity  メッセージとステータスを詰める
//      ResponseEntity<String> retResEnt = new ResponseEntity<String>(status);
//      //レスポンス用    JSON組み立て用
//      JSONObject msgJson = null;
//      String retMsg = "", retLogMsg = "";
//
//      //戻り値初期化
//      HashMap<ConditionSendResultUtil.PARAMKEY,Object> retVal = new HashMap<>();
//      try {
//        msgJson = new JSONObject("{}")  ;
//
//        //------------------------------------
//        //main処理 3011
//        // 条件送信の結果処理を行う(ord_mainのみの処理)
//        //* @param bodydata        ＷｅｂＡＰＩ呼び出し時の受信データ(Ｊｓｏｎ)
//        //        オーダー番号   ordNo
//        //* @param retVal  <PARAMKEY:value>    パラメータ授受用
//        //*       PARAMKEY.STATUS     Httpステータス
//        //*       PARAMKEY.RET_MSG    メッセージ
//        conditionSendResultUtil.makeSendResult(bodydata, retVal);
//      }
//      catch(Exception e)
//      {
//        //JSON関連のエラー
//        status = HttpStatus.INTERNAL_SERVER_ERROR ;
//        retMsg = "指示展開データエラー" ;
//        retLogMsg = e.getMessage() ;
//        //一旦戻り値retValに格納("戻り値の組み立て処理"共通化のため)
//        retVal.put(ConditionSendResultUtil.PARAMKEY.STATUS, status) ;
//        retVal.put(ConditionSendResultUtil.PARAMKEY.RET_MSG, retMsg) ;
//        retVal.put(ConditionSendResultUtil.PARAMKEY.RET_LOG_MSG, retLogMsg) ;
//        // wp アプリケーションログの適正化 Add Start
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
//        // wp アプリケーションログの適正化 Add End
//      }
//
//      //戻り値の組み立て
//      try {
//        //Httpステータスの取り出し
//        status = (HttpStatus)retVal.get(ConditionSendResultUtil.PARAMKEY.STATUS) ;
//        //メッセージの取り出し
//        retMsg = (String)retVal.get(ConditionSendResultUtil.PARAMKEY.RET_MSG) ;
//        retLogMsg = (String)retVal.get(ConditionSendResultUtil.PARAMKEY.RET_LOG_MSG) ;
//        //返却用Ｊｓｏｎオブジェクトにセット
//        msgJson.put(ConditionSendResultUtil.PARAMKEY.RET_MSG.get(), retMsg) ;
//      }
//      catch(JSONException e)
//      {//JSON操作での例外キャッチなので、戻り値のJSONの操作はできないから、ステータスだけ変更
//        status = HttpStatus.INTERNAL_SERVER_ERROR ;
//        // wp アプリケーションログの適正化 Add Start
//        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
//        // wp アプリケーションログの適正化 Add End
//      }
//    //返却値の生成
//    retResEnt = new ResponseEntity<String>(msgJson.toString(),status);
//
//    //ログの出力
//    if(HttpStatus.OK != status)
//    {//エラーログ
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("例外発生：" + retLogMsg);
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
//    }
//
//    return retResEnt ;
//  }


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
