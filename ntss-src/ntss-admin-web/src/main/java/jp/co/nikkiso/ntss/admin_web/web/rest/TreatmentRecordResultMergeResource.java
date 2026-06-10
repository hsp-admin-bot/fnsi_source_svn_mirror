package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.checkList.CheckListService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordResultMergeService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResultMerge;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import javax.validation.Valid;
import java.sql.Timestamp;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.ExecutorService;

/**
 * 治療記録（実績マージ）画面のResourceクラス.
 */
@RestController
@RequestMapping(AdminWebConstant.Uri.TREATMENT_RECORD)
@PreAuthorize("isAuthenticated()")
public class TreatmentRecordResultMergeResource {

  /**
   * 治療記録（実績マージ）Service.
   */
  @Autowired
  private TreatmentRecordResultMergeService treatmentRecordResultMergeService;

  @Autowired
  CheckListService checkListService;

  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * ログ出力Service.
   */
  @Autowired
  LogService logService;

  //9480 治療記録（実績マージ情報）gjn start
  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;
  @Autowired
  private OrdMainService ordMainService;
  @Resource(name = "crawlExecutorPool")
  private ExecutorService threadExector;
  //9480 治療記録（実績マージ情報）gjn end

  /**
   * 治療記録（実績マージ情報）取得.
   *
   * @param ordNo    オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（実績マージ情報）のResponse
   */
  @GetMapping("/{ord_no}/result-merge")
  public ResponseEntity<?> getResultMergeList(
    @PathVariable("ord_no") Long ordNo,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get result merge list : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（実績マージ情報）の取得
    List<TreatmentRecordResultMerge> response = treatmentRecordResultMergeService.getResultMergeList(ordNo, ntssUser.getFacilityCd());

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（実績マージ情報）更新.
   *
   * @param request  治療記録（実績マージ情報）データ
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/{ord_no}/result-merge")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.RST_EDIT + "') or hasAuthority('" + AdminWebConstant.Authority.RST_PEDIT + "')")
  public ResponseEntity<?> updateResultMerge(
    @PathVariable("ord_no") Long ordNo,
    @Valid @RequestBody TreatmentRecordResultMerge request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to put result merge : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 更新者IDを設定
    request.setUpdStaffId(ntssUser.getUserId());
    request.setBaseFacilityCd(ntssUser.getFacilityCd());
    //9480 治療記録（実績マージ情報）の更新 gjn start
    /**
     * まず、マギーの治療データに修正される前の値を取り出し、（実際の治療開始時間、実際の治療終了時間、
     * 体重情報（前体重、後体重、実除水量、実補液量）、バイタル情報（前血圧、後血圧）
     */
    OrdMain ordMain = ordMainService.selectByOrdNo(ordNo);
    if (!StringUtils.isEmpty(ordMain)) {
      //変更前の実治療開始時間と実治療終了時間
      Timestamp ini_rstStartDate = ordMain.getRstStartDate();
      Timestamp ini_rstEndDate = ordMain.getRstEndDate();
      String rstWeightInfo = ordMain.getRstWeightInfo();
      //変更前に得られた体重情報の前体重と後体重値を取り出しておく
      String ini_weight_before = "";
      String ini_weight_after = "";
      String ini_water_removal_rst = "";
      String ini_add_water_total = "";
      JSONObject jsonObject = new JSONObject(rstWeightInfo);
      if (jsonObject.has("weight_before")) {
        ini_weight_before = String.valueOf(jsonObject.get("weight_before"));
      }
      if (jsonObject.has("weight_after")) {
        ini_weight_after = String.valueOf(jsonObject.get("weight_after"));
      }
      if (jsonObject.has("water_removal_rst")) {
        ini_water_removal_rst = String.valueOf(jsonObject.get("water_removal_rst"));
      }
      if (jsonObject.has("add_water_total")) {
        ini_add_water_total = String.valueOf(jsonObject.get("add_water_total"));
      }
      //変更前バイタル情報の取得（未定）

      //マギー取得後の治療開始時間、治療終了時間、前体重、後体重、実際の除水量、実際の補液量、バイタル情報（前血圧、後血圧、平均血圧）
      Timestamp up_rstStartDate = request.getRstStartDate();
      Timestamp up_rstEndDate = request.getRstEndDate();
      //マージ后の前体重と後体重の値を取得する
      String up_weight_before = "";
      String up_weight_after = "";
      String up_water_removal_rst = "";
      String up_add_water_total = "";
      String up_rstWeightInfo = String.valueOf(request.getRstWeightInfo());
      JSONObject up_weigh = new JSONObject(up_rstWeightInfo);
      if (up_weigh.has("weight_before")) {
        up_weight_before = String.valueOf(up_weigh.get("weight_before"));
      }
      if (up_weigh.has("weight_after")) {
        up_weight_after = String.valueOf(up_weigh.get("weight_after"));
      }
      if (up_weigh.has("water_removal_rst")) {
        up_water_removal_rst = String.valueOf(up_weigh.get("water_removal_rst"));
      }
      if (up_weigh.has("add_water_total")) {
        up_add_water_total = String.valueOf(up_weigh.get("add_water_total"));
      }

      /* #10344 mod 実績情報マージ更新 Start */
      // 治療記録（実績マージ情報）の更新
//      treatmentRecordResultMergeService.updateResultMerge(ordNo, request);
      this.treatmentRecordResultMergeService.treatmentRecordMergeExecution(request);
      /* #10344 mod 実績情報マージ更新 End */

      //以上のパラメータのうち少なくとも1つが異なると判断して再計算する
      //mod 9694 未登録患者に医療材料を追加できない zy start
//      if (!up_rstStartDate.equals(ini_rstStartDate) || !up_rstEndDate.equals(ini_rstEndDate)
//          || !up_weight_before.equals(ini_weight_before) || !up_weight_after.equals(ini_weight_after)
//          || !up_add_water_total.equals(ini_add_water_total) || !up_water_removal_rst.equals(ini_water_removal_rst)) {
      if (!Objects.equals(up_rstStartDate,ini_rstStartDate) ||!Objects.equals(up_rstEndDate,ini_rstEndDate)
        || !!Objects.equals(up_weight_before,ini_weight_before) || !!Objects.equals(up_weight_after,ini_weight_after)
        || !!Objects.equals(up_add_water_total,ini_add_water_total) || !!Objects.equals(up_water_removal_rst,ini_water_removal_rst)) {
      //mod 9694 未登録患者に医療材料を追加できない zy end
        threadExector.execute(new Runnable() {
          @Override
          public void run() {
            // 非同期実行チェック計算
            webApiCallCommonUtil.doAutoCalculation(ordNo);
          }
        });
      }
    }
    //9480 治療記録（実績マージ情報）の更新 gjn end

    // #10344 this logic moved away
    // add 9324 治療記録（実績マージ情報）の更新 ord_checklistの変更 gjn start
//    try {
//      //取得？？？患者的ord_checklist数据
//      List<OrdChecklist> checklistsQuestion = checkListService.getOrdCheckListByOrdNO(request.getMerOrdNo());
//      //取得被merge的患者的ord_main对应的ord_checklist数据
//      List<OrdChecklist> checklistsMargeOld = checkListService.getOrdCheckListByOrdNO(ordNo);
//      //根据？？？患者的checklists，反向生成当时的mst_checklistd的数据,作成JsonNode格式返回
//      Map<String, JsonNode> jsonNodeMap = checkListService.makeMstChecklistByOrdChecklist(checklistsMargeOld);
//      String checklistCd = jsonNodeMap.keySet().size()==1 ? jsonNodeMap.keySet().iterator().next() : null;
//      // marge后的治療情報を取得
//      OrdMainForCheckListSchedule ordMains = ordMainDao.selectByOrdNoChecklist(ordNo);
//      //根据merge后的ord_main数据和反推出来的mst_checklistd的数据，调用共通，生成新的ord_checklist数据
//      List<OrdChecklist> newMakeList = checkListService.getRegisterChecklistRst(ordMains, jsonNodeMap.get(checklistCd), Long.parseLong(checklistCd), true);
//
//      //被marge患者的ord_checklist与新生成的ord_checklist进行marge,checklistsMargeOld作为base
//      checkListService.margeOrdCheckListInsCheckLeft(checklistsMargeOld, newMakeList);
//      //再将？？？患者有被check过的状态marge给checklistsMargeOld后的数据
//      //取最新ord_checklist
//      List<OrdChecklist> checklistsMargeAfter = checkListService.getOrdCheckListByOrdNO(ordNo);
//      checkListService.margeOrdCheckListInsCheckRight(checklistsQuestion, checklistsMargeAfter, request.getDeleteFlag());
//    } catch (Exception e) {
//      e.printStackTrace();
//    }
    // add 9324 治療記録（実績マージ情報）の更新 ord_checklistの変更 gjn end

    // レスポンス生成
    return new ResponseEntity<>(null, HttpStatus.OK);
  }

  //add FNSI修正486改修 房 start
  /**
   * 治療記録（実績マージ一覧情報）取得.
   *
   * @param ordNo    オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（実績マージ情報）のResponse
   */
  @GetMapping("/result-merge-list/{ord_no}/{start_date}/{end_date}/{is_unknown}")
  public ResponseEntity<?> getResultMergeList(
    @PathVariable("ord_no") Long ordNo,
    @PathVariable("start_date") String startDate,
    @PathVariable("end_date") String endDate,
    @PathVariable("is_unknown") String isUnknown,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get result merge list : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（実績マージ情報）の取得　
    List<TreatmentRecordResultMerge> response = treatmentRecordResultMergeService.getResultMergeList(ordNo, ntssUser.getFacilityCd(), startDate, endDate, isUnknown);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  //add FNSI修正486改修 房 end

}
