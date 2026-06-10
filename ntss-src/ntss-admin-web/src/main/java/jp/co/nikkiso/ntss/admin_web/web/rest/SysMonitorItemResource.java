package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.request.sysMonitorItem.SysMonitorItemRequest;
import jp.co.nikkiso.ntss.admin_web.service.SysMonitorItemService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.entity.SysMonitorItem;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.List;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@Slf4j
@RequestMapping(Uri.TREATMENT_RECORD)
public class SysMonitorItemResource {

  /**
   * {@link SysMonitorItemService}のサービスインタフェース
   */
  @Autowired
  private SysMonitorItemService sysMonitorItemService;

  @Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
  /**
   * 指定された条件に該当するモニタ項目を取得する.
   *
   * @param sysMonitorItemRequest リクエスト情報(検索条件)
   * @return 該当するモニタ項目のリスト
   */
  @GetMapping("/sys_monitor_item")
  public ResponseEntity<?> getSysMonitorItem(SysMonitorItemRequest sysMonitorItemRequest) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.TREATMENT_RECORD + "/sys_monitor_item";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    List<SysMonitorItem> sysMonitorItemList = Collections.emptyList();
    try {
      if ("all".equals(sysMonitorItemRequest.getMoniDataType())) {
        // 全てのモニタ項目取得
        sysMonitorItemList = sysMonitorItemService.getMonitorItemAll();
      } else if (sysMonitorItemRequest.getVitalMonitorClass() == null) {
        // 与えられたモニタデータ区分モニタ項目取得.
        sysMonitorItemList = sysMonitorItemService.getMonitorItemByMoniDataType(sysMonitorItemRequest.getMoniDataType());
      } else {
        sysMonitorItemList = sysMonitorItemService.getMonitorItemByMoniDataTypeAndClass(
            sysMonitorItemRequest.getMoniDataType(),
            sysMonitorItemRequest.getVitalMonitorClass());
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(sysMonitorItemList, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("REST request error by get sysMonitorItem : "+ e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.REMS, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /* ===== 2024-07-04 ADD #9312 Start ===== */

  /**
   * In order to obtain configurations more flexibly,
   * I hope to bind fixed configurations in the background to adapt to the different needs of each page.
   *
   * @param kind
   * @return
   */
  @GetMapping("/particularSMItems/{kind}")
  public ResponseEntity<?> getParticularSysMonitorItems(@PathVariable(name = "kind") String kind) {
    String mappingUrl = Uri.TREATMENT_RECORD + "/particularSMItems";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), ""
      , AFTER_LOG_FLG_INFO, mappingUrl, null, null);

    List<SysMonitorItem> sysMonitorItemList = Collections.emptyList();

    // May be use enum is better.
    if (StringUtils.equals("treatment-graph", kind)) {
      // 治療記録モニタグラフマスタ
      sysMonitorItemList = this.sysMonitorItemService.getTreatmentGraphItems();
    }

    return new ResponseEntity<>(sysMonitorItemList, HttpStatus.OK);
  }
  /* ===== 2024-07-04 ADD #9312 End ===== */

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
