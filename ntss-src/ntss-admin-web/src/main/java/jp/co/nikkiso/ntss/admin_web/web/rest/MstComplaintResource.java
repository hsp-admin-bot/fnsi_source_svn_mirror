package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.ComplaintService;
import jp.co.nikkiso.ntss.core.entity.MstCompTreatment;
import jp.co.nikkiso.ntss.core.entity.MstComplaint;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import javax.validation.Valid;
import java.util.List;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * マスタ編集（愁訴処置マスタ)のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(AdminWebConstant.Uri.COMPLAINT)
public class MstComplaintResource {

  @Autowired
  private ComplaintService complaintService;

	@Autowired
	LogService logService;
  /**
   * 愁訴マスタ取得.
   * @param ntssUser NTSS認証ユーザ
   * @return 愁訴マスタデータのResponse
   */
  @GetMapping("/mst-complaint")
  public ResponseEntity<?> getAllMstComplaints(
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get MstComplaint list : "+ ntssUser.getFacilityCd());
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
    null);

    // 対象施設の愁訴マスタを全て取得
    List<MstComplaint> response = complaintService.getAllMstComplaints(ntssUser.getFacilityCd());

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 愁訴マスタ更新.
   * @param request 愁訴マスタ
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/mst-complaint")
  public ResponseEntity<?> updateMstComplaints(
    @Valid @RequestBody List<MstComplaint> request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to update MstComplaint list : "+ ntssUser.getFacilityCd());
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
    null);

    // 対象施設の処置マスタを更新
    complaintService.updateMstComplaints(ntssUser.getFacilityCd(), request);

    return new ResponseEntity<>(null, HttpStatus.OK);
  }

  /**
   * 処置マスタ取得.
   * @param ntssUser NTSS認証ユーザ
   * @return 処置マスタデータのResponse
   */
  @GetMapping("/mst-comp-treatment")
  public ResponseEntity<?> getAllMstCompTreatments(
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get MstCompTreatment list : "+ ntssUser.getFacilityCd());
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,  null);

    // 対象施設の処置マスタを全て取得
    List<MstCompTreatment> response = complaintService.getAllMstCompTreatments(ntssUser.getFacilityCd());

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 処置マスタ更新.
   * @param request 処置マスタ
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/mst-comp-treatment")
  public ResponseEntity<?> updateMstCompTreatments(
    @Valid @RequestBody List<MstCompTreatment> request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update MstCompTreatment list : "+ ntssUser.getFacilityCd());
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
    null);

    // 対象施設の処置マスタを更新
    complaintService.updateMstCompTreatments(ntssUser.getFacilityCd(), request);

    return new ResponseEntity<>(null, HttpStatus.OK);
  }

  // add マスタ一覧 1･施設切替を可能とする 王 start
  /**
   * 愁訴マスタ取得.
   * @param
   * @return 愁訴マスタデータのResponse
   */
  @GetMapping("/mst-complaint/data/{facilityCd}")
  public ResponseEntity<?> getMstComplaintsByFacilityCd(
    @PathVariable(name = "facilityCd", required = true) String facilityCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get MstComplaint list : "+ facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
      null);

    // 対象施設の愁訴マスタを全て取得
    List<MstComplaint> response = complaintService.getAllMstComplaints(facilityCd);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 処置マスタ取得.
   * @param
   * @return 処置マスタデータのResponse
   */
  @GetMapping("/mst-comp-treatment/data/{facilityCd}")
  public ResponseEntity<?> getMstCompTreatmentsByFacilityCd(
    @PathVariable(name = "facilityCd", required = true) String facilityCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get MstCompTreatment list : "+ facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,  null);

    // 対象施設の処置マスタを全て取得
    List<MstCompTreatment> response = complaintService.getAllMstCompTreatments(facilityCd);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 処置マスタ更新.
   * @param request 処置マスタ
   * @param
   * @return
   */
  @PutMapping("/mst-comp-treatment/update/{facilityCd}")
  public ResponseEntity<?> updateMstCompTreatmentsByFacilityCd(
    @Valid @RequestBody List<MstCompTreatment> request,
    @PathVariable(name = "facilityCd", required = true) String facilityCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update MstCompTreatment list : "+ facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
      null);

    // 対象施設の処置マスタを更新
    complaintService.updateMstCompTreatments(facilityCd, request);

    return new ResponseEntity<>(null, HttpStatus.OK);
  }

  /**
   * 愁訴マスタ更新.
   * @param request 愁訴マスタ
   * @param
   * @return
   */
  @PutMapping("/mst-complaint/update/{facilityCd}")
  public ResponseEntity<?> updateMstComplaintsByFacilityCd(
    @Valid @RequestBody List<MstComplaint> request,
    @PathVariable(name = "facilityCd", required = true) String facilityCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to update MstComplaint list : "+ facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
      null);

    // 対象施設の処置マスタを更新
    complaintService.updateMstComplaints(facilityCd, request);

    return new ResponseEntity<>(null, HttpStatus.OK);
  }
  // add マスタ一覧 1･施設切替を可能とする 王 end
}
