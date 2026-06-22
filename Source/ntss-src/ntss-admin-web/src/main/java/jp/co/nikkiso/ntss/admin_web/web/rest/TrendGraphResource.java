package jp.co.nikkiso.ntss.admin_web.web.rest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.response.trendGraph.TrendGraphMasterResponse;
import jp.co.nikkiso.ntss.admin_web.response.trendGraph.TrendGraphResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.trendGraph.TrendGraphService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;

@RestController
@Slf4j
@RequestMapping(Uri.TREND_GRAPH)
public class TrendGraphResource {

  @Autowired
  TrendGraphService trendGraphService;

  @Autowired
  LogService logService;

  // mod FNSI-改修内容5702修正 xuty start
  //@GetMapping("/collect_master/{model}")
  @GetMapping("/collect_master/{model}/{comFormatCd}")
  // mod FNSI-改修内容5702修正 xuty end
  public ResponseEntity<?> trendGraphMasterData(
      @AuthenticationPrincipal NtssUser ntssUser,
      // mod FNSI-改修内容5702修正 xuty start
      // @PathVariable String model) {
      @PathVariable String model,
      @PathVariable String comFormatCd) {
      // mod FNSI-改修内容5702修正 xuty end
    EventLogMessage eventLogMessage = new EventLogMessage();
    // mod FNSI-改修内容5702修正 xuty start
    // eventLogMessage.setLogMessage("REST request to get trendGraphMasterData : "+ ntssUser.getFacilityCd()+ model);
    eventLogMessage.setLogMessage("REST request to get trendGraphMasterData : "+ ntssUser.getFacilityCd()+ model+ comFormatCd);
    // mod FNSI-改修内容5702修正 xuty end
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    TrendGraphMasterResponse response = new TrendGraphMasterResponse();
    try {

      // add FNSI redmine 5702再修正 劉祥霖 start
      if(comFormatCd.equals("NN")){
        comFormatCd=null;
      }
      // add FNSI redmine 5702再修正 劉祥霖 end

      // レスポンス生成
      // mod FNSI-改修内容5702修正 xuty start
      // response = trendGraphService.findTrendGraphMaster(ntssUser.getFacilityCd(), model);
      response = trendGraphService.findTrendGraphMaster(ntssUser.getFacilityCd(), model, comFormatCd);
      // mod FNSI-改修内容5702修正 xuty end

      response.isSuccess = true;
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get trendGraphMasterData : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      response.errorMessage = e.getMessage();
      response.isSuccess = false;
      return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }
  }

  /**
  * 治療状況リスト：トレンドグラフ情報取得
  * @param facilityCd 施設コード
  * @param machineTypeCd 開始日付
  * @param machineSerial 開始日付
  * @param model 開始日付
  * @param startDate 開始日付 yyyyMMdd
  * @param endDate 開始日付 yyyyMMdd
  * @return
  */
  @GetMapping("/collect_info/{machineTypeCd}/{machineSerial}/{model}/{startDate}/{endDate}")
  public ResponseEntity<?> findTrendGraphdata(
      @AuthenticationPrincipal NtssUser ntssUser,
      @PathVariable String machineTypeCd,
      @PathVariable String machineSerial,
      @PathVariable String model,
      @PathVariable String startDate,
      @PathVariable String endDate) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get TrendGraphdata : "+
    ntssUser.getFacilityCd()+ machineTypeCd+ machineSerial+ model+ startDate+ endDate);
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    TrendGraphResponse response = new TrendGraphResponse();
    try {
      // レスポンス生成
      response = trendGraphService.findTrendGraphdata(ntssUser.getFacilityCd(), machineTypeCd, machineSerial, model,
          startDate, endDate);

      response.isSuccess = true;
      eventLogMessage.setLogMessage("REST request success by get getTrendGraphdata");
      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("REST request error by get getTrendGraphdata : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      response.errorMessage = e.getMessage();
      response.isSuccess = false;
      return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }
  }
}
