package jp.co.nikkiso.ntss.monitoring.web.rest;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.entity.MstMoniItem;
import jp.co.nikkiso.ntss.monitoring.service.MstMoniItemService;

import jp.co.nikkiso.ntss.monitoring.service.logger.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
/**
 * モニタ項目のResourceクラス
 */
@CrossOrigin(origins = "*") // 別ドメインからのテスト用にアクセスすることを許可
@RestController
@RequestMapping("/api/moni_item")
public class MoniItemResource {
  
  private final Logger logger = LoggerFactory.getLogger(getClass());
  
  @Autowired
  private LogService logService;
  
  @Autowired
  private MstMoniItemService mstMoniItemService;
  
  /**
   * モニターアイテム取得
   * @param facility_cd 施設コード
   * @param model 機種
   * @param moni_no モニタ項目番号
   * @return
   */
  @GetMapping({"/{facilityCd}", "/{facilityCd}/{model}", "/{facilityCd}/{model}/{moniNo}"})
  public ResponseEntity<List<MstMoniItem>> getMstMonitem(
      @PathVariable("facilityCd") String facilityCd,
      @PathVariable(name = "model", required = false) String model,
      @PathVariable(name = "moniNo", required = false) String moniNo) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("REST request to get MoniItem : %s %s %s", facilityCd, model, moniNo));
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
    List<MstMoniItem> res = new ArrayList<>();

    res = mstMoniItemService.Select(facilityCd, model, moniNo);

    return new ResponseEntity<>(res, HttpStatus.OK);
  }


}
