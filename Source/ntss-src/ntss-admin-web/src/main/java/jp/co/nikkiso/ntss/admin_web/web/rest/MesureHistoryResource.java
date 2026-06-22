package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.sql.Timestamp;
import java.util.Arrays;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.measureHistory.MeasureHistoryService;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

@RestController
@RequestMapping(Uri.MESURE_HISTORY)
public class MesureHistoryResource {

  @Autowired
  WebSocketNotifyService sendWsMsg;
  @Autowired
  MeasureHistoryService measureHistoryService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 条件送信履歴取得
   * @param
   * @return
   */
  @GetMapping("order/{facilityCd}/{startDate}/{endDate}")
  public ResponseEntity<?> getOrderWeight(
      @PathVariable(name = "facilityCd", required = true) String facilityCd,
      @PathVariable(name = "startDate", required = true) String startDate,
      @PathVariable(name = "endDate", required = true) String endDate,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
  ) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
          if(!ntssUser.isNkkAdminUser()) {
              if (facilityCd != null && !facilityCd.isEmpty() &&
                  !facilityCd.equals(ntssUser.getFacilityCd())) {
                  String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "startDate=" + startDate + " " + "endDate=" + endDate + " ";
                  InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
                  return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
              }
          }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MESURE_HISTORY + "/order";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      Arrays.asList(startDate, endDate));
    // wp アプリケーションログの適正化 Add End
    // NOTE: ord_weight_scaleをfacilityCdで取得する

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      Arrays.asList(startDate, endDate));
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(measureHistoryService.getOrder(facilityCd,
        toTimestampStart(startDate, Timestamp.valueOf("1970-01-01 00:00:00")),
        toTimestampEnd(endDate, Timestamp.valueOf("9999-01-01 00:00:00"))), HttpStatus.OK);
  }

  /**
   * 条件送信履歴単品取得
   * @param serialNo
   * @return
   */
  @GetMapping("get/{serialNo}")
  public ResponseEntity<?> getOrderWeight(
      @PathVariable Long serialNo,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
  ) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
          if(!ntssUser.isNkkAdminUser()) {
              OrdWeightScale single = measureHistoryService.getSingle(serialNo);
              String facilityCd = single.getFacilityCd();
              if (facilityCd != null && !facilityCd.isEmpty() &&
                  !facilityCd.equals(ntssUser.getFacilityCd())) {
                  String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "serialNo=" + serialNo + " ";
                  InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
                  return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
              }
          }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.MESURE_HISTORY + "/get";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      serialNo);
    // wp アプリケーションログの適正化 Add End
    // NOTE: ord_weight_scaleをfacilityCdで取得する

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      serialNo);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(measureHistoryService.getSingle(serialNo), HttpStatus.OK);
  }
  /**
   * 日付をTimestampへ変換(yyyyMMddからTimestampへ)
   * @param dt  日付文字列(yyyyMMdd)
   * @param def デフォルト
   * @return
   */
  private Timestamp toTimestampStart(String dt, Timestamp def) {
    if (dt != null && dt.length() == 8 && StrUtils.isNumber(dt)) {
      return Timestamp.valueOf(dt.substring(0, 4) + "-" +
          dt.substring(4, 6) + "-" +
          dt.substring(6, 8) + " " +
          "00:00:00");
    } else {
      return def;
    }
  };

  /**
   * 日付をTimestampへ変換(yyyyMMddからTimestampへ)
   * @param dt  日付文字列(yyyyMMdd)
   * @param def デフォルト
   * @return
   */
  private Timestamp toTimestampEnd(String dt, Timestamp def) {
    if (dt != null && dt.length() == 8 && StrUtils.isNumber(dt)) {
      return Timestamp.valueOf(dt.substring(0, 4) + "-" +
          dt.substring(4, 6) + "-" +
          dt.substring(6, 8) + " " +
          "00:00:00");
    } else {
      return def;
    }
  };

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
