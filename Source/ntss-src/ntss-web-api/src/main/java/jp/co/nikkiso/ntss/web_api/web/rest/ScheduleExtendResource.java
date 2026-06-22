package jp.co.nikkiso.ntss.web_api.web.rest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.web_api.web.rest.util.ScheduleExtendUtil;


@RestController
@RequestMapping("util")
public class ScheduleExtendResource {
  @Autowired(required = false)
  ScheduleExtendUtil scheduleExtendUtil;

  /**
   * スケジュール延長API
   * @param bodydata　JSON形式データ
   *    施設コード   facility_cd
   * @return ResponseEntity(HttpStatusとメッセージ(JSON文字列))
   *    HttpStatus
   *        200:正常終了(警告終了(処理未実施)含む)
   *        400:チェック処理でのエラー
   *        500:上記以外のエラー全般(Validationの結果で生じたエラーなどもこちらに含まれる)
   *    メッセージ(JSON文字列(キー:retMsg))
   *        正常終了時(HttpStatus(200)):空文字
   *        警告終了時(HttpStatus(200)):メッセージ格納
   *        異常終了時(HttpStatus(400、500)):メッセージ格納
   */
  // TODO: スケジューラを使用するためAPIは無効化
  // @PostMapping("/RunScheduleExtend")
  // private ResponseEntity<String> runScheduleExtend(@Valid @RequestBody String bodydata) {
  //   // TODO: エラーチェック、バリデーションチェック、適切なレスポンス返し、ログ出力など
  //   // HTTPステータス格納用
  //   HttpStatus status = HttpStatus.OK;
  //   // メッセージ格納用
  //   JSONObject msgJson = new JSONObject("{}");
  //   String retMsg = null;

  //   JSONObject receiveData = new JSONObject(bodydata);

  //   Boolean res = scheduleExtendUtil.runScheduleExtend(receiveData.getString("facility_cd"));

  //   return new ResponseEntity<String>("メッセージは未実装です。", status);
  // }
}
