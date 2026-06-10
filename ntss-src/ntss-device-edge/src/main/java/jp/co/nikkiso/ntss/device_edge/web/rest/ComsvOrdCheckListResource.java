package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.io.IOException;
import java.text.ParseException;
import java.util.List;
import java.util.Objects;

import jp.co.nikkiso.ntss.device_edge.response.checkList.ChecklistUpdateResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.response.checkList.ComsvChecklistResponse;
import jp.co.nikkiso.ntss.device_edge.service.ComsvOrdCheckListService;
import jp.co.nikkiso.ntss.device_edge.service.LogService;

@RestController
@RequestMapping("/api/comsv_checklist/ord")

public class ComsvOrdCheckListResource {

  @Autowired
  private LogService logService;

  /**
   * 通信サーバ用チェックリスト情報の取得
   */
  @Autowired
  private ComsvOrdCheckListService comsvOrdCheckListService;

  /**
   * チェックリスト情報を取得する
   * @param send_flg 条件送信フラグ
   * @param ordNo オーダー番号
   * @param listCd  リストコード
   * @param facilityCd 施設コード
   * @return
   */
  @GetMapping({ "/{send_flg}/{ord_no}/{list_cd}/{facility_cd}" })
  public ResponseEntity<?> getComsvMstCheckList(
      @PathVariable("send_flg") Short send_flg,
      @PathVariable("ord_no") Long ord_no,
      @PathVariable("list_cd") Short list_cd,
      @PathVariable(name = "facility_cd", required = false) String facility_cd) throws IOException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API GET CALLED ord_no = " + ord_no + " " + list_cd + " " + facility_cd);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ord_no > 0 && list_cd > 0 && !Objects.equals(facility_cd, "")) {
      List<ComsvChecklistResponse> res;
      if (send_flg == 0) {
        // 条件送信前
        res = comsvOrdCheckListService.getBeforeCheckList(ord_no, list_cd, facility_cd);
      } else {
        // 条件送信後
        res = comsvOrdCheckListService.getAfterCheckList(ord_no, list_cd);
      }
      eventLogMessage.setLogMessage("O K");
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      eventLogMessage.setLogMessage("ERROR");
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * チェックリスト情報を更新する
   * @param send_flg 条件送信フラグ
   * @param ordNo オーダー番号
   * @param listCd  リストコード
   * @param facilityCd 施設コード
   * @return
   * @throws ParseException
   */
  @PostMapping("/update/{send_flg}/{ord_no}/{list_cd}/{facility_cd}")
  public HttpStatus Response(
      @PathVariable("send_flg") Short send_flg,
      @PathVariable("ord_no") Long ord_no,
      @PathVariable("list_cd") Short list_cd,
      @PathVariable(name = "facility_cd", required = false) String facility_cd,
      @RequestBody String body) throws IOException, ParseException {

    if (ord_no <= 0) {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return HttpStatus.BAD_REQUEST;
      return HttpStatus.INTERNAL_SERVER_ERROR;
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("body = [" + body + "]");
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    List<OrdChecklist> res;
    if (send_flg == 0) {
      // 条件送信前チェックリスト情報を取得
      res = comsvOrdCheckListService.getBeforeCheckListByListCd(ord_no, list_cd, facility_cd);
    } else {
      // 条件送信後チェックリスト情報を取得
      res = comsvOrdCheckListService.getAfterCheckListByListCd(ord_no, list_cd);
    }

    // チェックリスト実績更新
    int ret;
    //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 start
    //ret = comsvOrdCheckListService.updateOrdChecklist(facility_cd, body, res);
    ret = comsvOrdCheckListService.updateOrdChecklist(send_flg, facility_cd, body, res);
    //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 end
    eventLogMessage.setLogMessage("updateOrdChecklist = " + ret);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (ret > 0) {
      return HttpStatus.OK;
    } else {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return HttpStatus.BAD_REQUEST;
      return HttpStatus.INTERNAL_SERVER_ERROR;
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  // add FNSI-？？？？患者割り当て 陳 start
  /**
   * チェックリスト情報を更新する
   * @param facility_cd 施設コード
   * @param ord_no オーダー番号
   * @return
   */
  @GetMapping("/createordchecklist/{facility_cd}/{ord_no}")
  public HttpStatus createOrdChecklist(
    @PathVariable("facility_cd") String facility_cd,
    @PathVariable("ord_no") Long ord_no) {

    // 条件送信時のチェックリスト実績作成・更新
    try {

      ChecklistUpdateResponse resChk = comsvOrdCheckListService.createOrdChecklistSendCondition(facility_cd, ord_no);
      if (resChk.isSuccess) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("チェックリスト実績作成");
        eventLogMessage.setSqlIdentification("(facility_cd = " + facility_cd + ",or_no = " + ord_no);
        eventLogMessage.setFacilityCd(facility_cd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,"comsvOrdCheckListService/createOrdChecklistSendCondition");
        return HttpStatus.OK;
      } else {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("チェックリスト実績作成失敗[" + resChk.errorMessage +"]");
        eventLogMessage.setSqlIdentification("(facility_cd = " + facility_cd + ",or_no = " + ord_no);
        eventLogMessage.setFacilityCd(facility_cd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,"comsvOrdCheckListService/createOrdChecklistSendCondition");
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //return HttpStatus.BAD_REQUEST;
        return HttpStatus.INTERNAL_SERVER_ERROR;
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("チェックリスト実績作成エラー[" + e.getMessage() + "]");
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return HttpStatus.BAD_REQUEST;
      return HttpStatus.INTERNAL_SERVER_ERROR;
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }
  // add FNSI-？？？？患者割り当て 陳 end
}
