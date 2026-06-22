package jp.co.nikkiso.ntss.web_api.web.rest;

import java.util.ArrayList;
import java.util.List;

import jakarta.validation.Valid;

import jp.co.nikkiso.ntss.web_api.service.LogEventUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.web_api.service.InOutInfoUtilService;
import jp.co.nikkiso.ntss.web_api.service.LogService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;


/**
 * 条件送信結果ＷｅｂＡＰＩ
 *
 *
 */
@RestController
@RequestMapping("util")
public class InOutInfoResource {

  @Autowired
  InOutInfoUtilService inOutInfoUtilService ;

  @Autowired
  LogService logService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 入外区分、在院状態更新API
   * @param bodydata　JSON形式データ
   *    日付  target_dt
   *    患者IDリスト pat_id_list
   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
   *    HttpStatus
   *        200:正常終了
   *        400:チェック処理でのエラー
   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
   *    メッセージ(JSON文字列(キー:retMsg))
   *        正常終了時(HttpStatus(200)):空文字
   *        異常終了時(HttpStatus(400、500)):メッセージ格納
   */
  @PostMapping("/UpdateInOutState")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<String> updateInOutState(
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @Valid @RequestBody String bodydata
  )
  {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/util" + "/UpdateInOutState";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      JSONObject receiveData = new JSONObject(bodydata);
      String targetDt = receiveData.getString("target_dt");
      JSONArray patIds = receiveData.getJSONArray("pat_id_list");

      List<Long> patIdList = new ArrayList<Long>();
// mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
      List<String> patIdStrList = new ArrayList<String>();

      for(int idx = 0; idx < patIds.length(); idx++) {
        patIdList.add(Long.parseLong(patIds.get(idx).toString()));
        patIdStrList.add(patIds.get(idx).toString());
      }

      inOutInfoUtilService.updateInOutStateByDate(targetDt, patIdList);
      inOutInfoUtilService.insertPatMainHistorybyIDList(patIdStrList);
// mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
       null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // ログにエラーメッセージ出力
//      String retMsg = e.getMessage();
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("例外発生：" + retMsg);
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      // 例外発生時、BAD_REQUESTを返す

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
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
