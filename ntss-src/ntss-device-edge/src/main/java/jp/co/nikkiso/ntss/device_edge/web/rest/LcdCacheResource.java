package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.io.IOException;
import java.util.List;
import java.util.Objects;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvLcdCash;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq32;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq38;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq41;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq42;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq44;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq45;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq51;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq52;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq53;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.response.checkList.ComsvChecklistResponse;
import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.DailyReportResponse;
import jp.co.nikkiso.ntss.device_edge.response.lcdReq.LcdReqExamResponse;
import jp.co.nikkiso.ntss.device_edge.service.ComsvOrdCheckListService;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.lcdReq.LcdReqService;

@RestController
@RequestMapping("/api/lcdcash")
public class LcdCacheResource {

  @Autowired
  private LogService logService;

  /**
   * 仮想端末キャッシュデータの取得
   */
  @Autowired
  private LcdReqService lcdReqService;
  @Autowired
  private ComsvOrdCheckListService comsvOrdCheckListService;

  @GetMapping("/{facility_cd}/{device_edge_no}/{send_flg}/{ord_no}/{pat_id}")
  public ResponseEntity<?> getLcdReq(
	  @PathVariable(name = "facility_cd", required = false) String facility_cd,
	  @PathVariable("device_edge_no") Integer device_edge_no,
	  @PathVariable("send_flg") Short send_flg,
    @PathVariable("ord_no") Long ord_no,
    @PathVariable("pat_id") Long pat_id) throws IOException {

		EventLogMessage eventLogMessage = new EventLogMessage();
		eventLogMessage.setDeviceEdgeNo(device_edge_no.toString());
		eventLogMessage.setPatId(pat_id.toString());
		eventLogMessage.setLogMessage("API GET CALLED ID = " + facility_cd + "," + device_edge_no + "," + send_flg + "," + ord_no + "," + pat_id);
		eventLogMessage.setFacilityCd(facility_cd);
		logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ord_no > 0) {
      ComsvLcdCash cash = new ComsvLcdCash();
      ObjectMapper mapper = new ObjectMapper();

      if ( send_flg != 0 ) {
	    /**
	     * 仮想端末情報(酸素吸入)の取得
	     */
	    List<LcdReq32> res32 = lcdReqService.lcdReq32SelectByNo(ord_no);
	    String json32 = mapper.writeValueAsString(res32);
	    cash.setLcdCashReq32(json32);

	    /**
	     * 仮想端末情報(体重トレンド)の取得
	     */
	    List<LcdReq38> res38 = lcdReqService.lcdReq38SelectWeightAll(pat_id);
	    String json38 = mapper.writeValueAsString(res38);
	    cash.setLcdCashReq38(json38);

	    /**
	     * 仮想端末情報(透析日報)の取得
	     */
	    DailyReportResponse res40 = lcdReqService.lcdReq40selectByNo(ord_no, device_edge_no);
	    String json40 = mapper.writeValueAsString(res40);
	    cash.setLcdCashReq40(json40);

	    /**
	     * 仮想端末情報(投与薬剤)の取得
	     */
	    List<LcdReq41> res41 = lcdReqService.lcdReq41selectByNo(ord_no);
	    String json41 = mapper.writeValueAsString(res41);
	    cash.setLcdCashReq41(json41);

	    /**
	     * 仮想端末情報(抗凝固剤)の取得
	     */
	    LcdReq42 res42 = lcdReqService.lcdReq42selectByNo(ord_no);
	    String json42 = mapper.writeValueAsString(res42);
	    cash.setLcdCashReq42(json42);

	    /**
	     * 仮想端末情報（禁忌）の取得
	     */
	    List<LcdReq44> res44 = lcdReqService.lcdReq44SelectById(pat_id);
	    String json44 = mapper.writeValueAsString(res44);
	    cash.setLcdCashReq44(json44);

	    /**
	     * 仮想端末情報(メモ)の取得
	     */
	    List<LcdReq45> res45 = lcdReqService.lcdReq45SelectById(pat_id);
	    String json45 = mapper.writeValueAsString(res45);
	    cash.setLcdCashReq45(json45);

	    /**
	     * 仮想端末情報(検査グラフ)の取得
	     */
	    List<LcdReqExamResponse> res46 = lcdReqService.lcdReqExamResult(pat_id);
	    String json46 = mapper.writeValueAsString(res46);
	    cash.setLcdCashReq46(json46);

	    /**
	     * 仮想端末情報(穿刺／回収／担当)の取得
	     */
	    LcdReq51 res51 = lcdReqService.lcdReq51SelectByNo(ord_no);
	    String json51 = mapper.writeValueAsString(res51);
	    cash.setLcdCashReq51(json51);

	    /**
	     * 仮想端末情報(指示／特記)の取得
	     */
	    List<LcdReq52> res52 = lcdReqService.lcdReq52SelectByNo(ord_no);
	    String json52 = mapper.writeValueAsString(res52);
	    cash.setLcdCashReq52(json52);

	    /**
	     * 仮想端末情報(CTRトレンド)の取得
	     */
	    List<LcdReq53> res53 = lcdReqService.lcdReq53SelectWeightAll(pat_id);
	    String json53 = mapper.writeValueAsString(res53);
	    cash.setLcdCashReq53(json53);
      }

      /**
	   * 仮想端末情報(チェックリスト)の取得
	   */
	  if (!Objects.equals(facility_cd, "1")) {
	    short i;
	    List<ComsvChecklistResponse> res;
	    for (i = 1; i <= 8; i++) {
	      if (send_flg == 0) {
	        // 条件送信前
	        res = comsvOrdCheckListService.getBeforeCheckList(ord_no, i, facility_cd);
	      }
	      else {
	        // 条件送信後
	        res = comsvOrdCheckListService.getAfterCheckList(ord_no, i);
	      }
		  String json54 = mapper.writeValueAsString(res);
	      if (i == 1) {
	        cash.setLcdCashReq54No1(json54);
	      }
	      else if (i == 2) {
		    cash.setLcdCashReq54No2(json54);
		  }
	      else if (i == 3) {
		    cash.setLcdCashReq54No3(json54);
		  }
	      else if (i == 4) {
		    cash.setLcdCashReq54No4(json54);
		  }
	      else if (i == 5) {
		    cash.setLcdCashReq54No5(json54);
		  }
	      else if (i == 6) {
		    cash.setLcdCashReq54No6(json54);
		  }
	      else if (i == 7) {
		    cash.setLcdCashReq54No7(json54);
		  }
	      else if (i == 8) {
		    cash.setLcdCashReq54No8(json54);
		  }
	    }
			eventLogMessage.setLogMessage("O K");
			eventLogMessage.setFacilityCd(facility_cd);
			logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
	    return new ResponseEntity<>(cash, HttpStatus.OK);
	  }
    }
			eventLogMessage.setLogMessage("ERROR");
			eventLogMessage.setFacilityCd(facility_cd);
			logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
  }

}
