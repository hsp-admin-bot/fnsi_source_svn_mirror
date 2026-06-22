// #10833 2024.08.23 add 体重計アプリへの印刷指示をスレッドにて実施する TDC米沢 start
package jp.co.nikkiso.ntss.admin_web.service.weight;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.admin_web.service.weight.state.MntWeightStateService;
import jp.co.nikkiso.ntss.admin_web.web.rest.WeightStateResource;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

/**
 * 体重計アプリへの印刷指示処理用スレッド
 * @author TDC米沢
 */
public class WeightScalePrintThread extends Thread {
  /**
   * 施設コード
   */
  String facilityCd;
  /**
   * 体重計番号
   */
  Integer weightNo;
  /**
   * 測定記録番号
   */
  Long weightScaleNo;

  /**
   * WebSocket通知依頼サービス
   */
  @Autowired
  WebSocketNotifyService sendWsMsg;

  /**
   * 測定記録サービス
   */
  @Autowired
  MntWeightStateService mntWeightStateService;


  // #10833 2024.08.26 add ログを記録するためのメソッドを追加 TDC米沢 start
  /**
   * ログ記録サービス
   */
  @Autowired
  LogEventUtils logEventUtils;

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
  // #10833 2024.08.26 add ログを記録するためのメソッドを追加 TDC米沢 end

  /**
   * コンストラクタ
   * @param strFacilityCd 施設コード
   * @param intWeightNo 体重計番号
   * @param lngWeightScaleNo 測定記録番号
   */
  public WeightScalePrintThread(String strFacilityCd, Integer intWeightNo, Long lngWeightScaleNo) {
    this.facilityCd = strFacilityCd;
    this.weightNo = intWeightNo;
    this.weightScaleNo = lngWeightScaleNo;
  }

  /**
   * 体重計アプリへの印刷指示
   */
  public void run() {
    // #10833 2024.08.26 mod try catch処理を追加して通知結果による更新処理をリファクタリング、ログ記録を追加 TDC米沢 start
    // // 体重計アプリへの印刷指示作成(WebSocket通知用電文作成)
    // String topic = PayloadBuilder.BuildWeightTopic(AdminWebConstant.WebSocketTopic.WeightState.PRINT, this.facilityCd, this.weightNo);
    // String payload = this.weightScaleNo.toString();
    //
    // // 体重計アプリに印刷指示を通知(WebSocket通知を依頼)
    // if (sendWsMsg.sendMsg(WebSocketNotifyService.SendTarget.weightApp, this.facilityCd, this.weightNo, topic, payload)) {
    //   // 測定記録の状態を指示中にする
    //   mntWeightStateService.updatePrintStatus(this.weightScaleNo, WeightStateResource.printStatus.ORDER, "");
    // } else {
    //   // 測定記録の状態を印刷失敗にする
    //   mntWeightStateService.updatePrintStatus(this.weightScaleNo, WeightStateResource.printStatus.NG, "指示通知失敗");
    // }

    boolean res = false;
    String errMessage = "";
    try {
      // 処理開始ログ記録
      logEventUtils.resourceLogOutput(
        getClassName(),
        getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_SEND_CONDITION,
        BEFORE_LOG_FLG_INFO,
        "",
        null,
        "weight_no:" + this.weightNo.toString()
          + " / weight_scale_no:" + this.weightScaleNo.toString()
      );

      // 体重計アプリへの印刷指示作成(WebSocket通知用電文作成)
      String topic = PayloadBuilder.BuildWeightTopic(
        AdminWebConstant.WebSocketTopic.WeightState.PRINT,
        this.facilityCd,
        this.weightNo
      );
      String payload = this.weightScaleNo.toString();

      // 体重計アプリに印刷指示を通知(WebSocket通知を依頼)
      res = sendWsMsg.sendMsg(
        WebSocketNotifyService.SendTarget.weightApp,
        this.facilityCd,
        this.weightNo,
        topic,
        payload
      );

      // 通知結果により測定記録の状態を更新する
      mntWeightStateService.updatePrintStatus(
        this.weightScaleNo,
        res ? WeightStateResource.printStatus.ORDER : WeightStateResource.printStatus.NG,
        res ? "" : "指示通知失敗"
      );
    } catch(Exception ex) {
      // エラー内容取得
      errMessage = ex.getMessage();
    } finally {
      // 処理終了ログ記録
      logEventUtils.resourceLogOutput(
        getClassName(),
        getMethodName(),
        LoggingConstant.FUNCTION_CODE.FUNC_SEND_CONDITION,
        res ? AFTER_LOG_FLG_INFO : AFTER_LOG_FLG_ERROR,
        "",
        null,
        "印刷指示通知結果:" + (res ? "成功" : "失敗")
          + " / weight_no:" + this.weightNo.toString()
          + " / weight_scale_no:" + this.weightScaleNo.toString()
          +  (errMessage.isEmpty() ? "" : " / error_message:" + errMessage)
      );
    }
    // #10833 2024.08.26 mod try catch処理を追加して通知結果による更新処理をリファクタリング、ログ記録を追加 TDC米沢 end
  }
}
// #10833 2024.08.23 add 体重計アプリへの印刷指示をスレッドにて実施する TDC米沢 end
