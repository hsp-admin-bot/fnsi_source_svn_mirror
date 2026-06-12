package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.core.entity.EquipmentLatestNo;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstProcedure;
import jp.co.nikkiso.ntss.core.entity.MstTabooAllergy;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMaterialSave;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.response.ordMain.JournalCreateRequestResponse;
import jp.co.nikkiso.ntss.admin_web.response.ordMain.JournalCreatecallNextPatIdRequestResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.checkList.CheckListService;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistory;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel.SendConditionCancelService;
// del #11004 連携イベント発生部分不正 piao start
// import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordService;
// del #11004 連携イベント発生部分不正 piao end
import jp.co.nikkiso.ntss.admin_web.service.utils.CountVO;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.DeviceEdgeOrderResource;
import jp.co.nikkiso.ntss.admin_web.web.rest.OrdMainResource;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.IndicationUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PatTreatmentPatternUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation.MaterialsSharingPatientInfomationService;
import jp.co.nikkiso.ntss.api.utils.DateTimeFormatUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.DBAppWebAPIDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentClassDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstTabooAllergyDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainMedicineDelete;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainRequest;
import jp.co.nikkiso.ntss.core.dto.OrdMain.UpdateOrdMainMediInfoDTO;
import jp.co.nikkiso.ntss.core.entity.custom.EquipCodeAndType;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.service.PrefixNameService;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import org.apache.commons.lang3.SerializationUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import jakarta.annotation.Resource;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

@Service
public class OrdMainCudServiceImpl implements OrdMainCudService {

  @Autowired
  private MstDialyzerDao mstDialyzerDao;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  MstEquipmentClassDao mstEquipmentClassDao;

  @Autowired
  private MstTreatmentDao mstTreatmentDao;

  @Autowired
  MstMachineDao mstMachineDao;

  @Autowired
  MntMachineStateDao mntMachineStateDao;

  @Autowired
  SendConditionCancelService sendConditionCancelService;

  // del #11004 連携イベント発生部分不正 piao start
  // @Autowired
  // TreatmentRecordService treatmentRecordService;
  // del #11004 連携イベント発生部分不正 piao end

  @Autowired
  DeviceEdgeOrderResource deviceEdgeOrderResource;

  @Autowired
  IndHistoryMakeService indHistoryMakeService;

  @Autowired
  PatTreatmentPatternUtils patTreatmentPatternUtils;

  @Autowired
  CheckListService ordCheckListService;

  @Autowired
  OrdMainResource ordMainResource;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private PatIndApproveDao patIndApproveDao;

  @Autowired
  private AsyncService asyncService;

  @Autowired
  OrdMainService ordMainService;

  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  MaterialsSharingPatientInfomationService materialsSharingPatientInfomationService;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  @Autowired
  private SelectHistoryUtils selectHistoryUtils;

  @Autowired
  PatInfoService patInfoService;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  // mod 2023-01-14 bug #7627 修正 chen start
  @Autowired
  SysCoopJournalDao sysCoopJournalDao;

  @Autowired
  JournalService journalService;
  // mod 2023-01-14 bug #7627 修正 chen end

  @Autowired
  PatPersonalMainDao patPersonalMainDao;

  // add FNSI-FutreNetWeb+SI課題管理No.4750 李 start
  @Resource(name = "crawlExecutorPool")
  private ExecutorService threadExector;
  // add FNSI-FutreNetWeb+SI課題管理No.4750 李 end

  // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.90(外結)対応 韓 start
  @Autowired
  private DBAppWebAPIDao dBAppWebAPIDao;
  // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.90(外結)対応 韓 end

  @Autowired
  private TriggerUtil triggerUtil;

  // add 7959 2023-02-21 17:30 医療材料取得。張  start
//  @Autowired
//  private MstEquipmentDao mstEquipmentDao;
  // add 7959 2023-02-21 17:30 医療材料取得。張  end

  //add #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240913 start
  @Autowired
  PrefixNameService prefixNameService;

  @Autowired
  private MstTabooAllergyDao mstTabooAllergyDao;

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  //add #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240913 end

  // add #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
  // 20:分解薬剤
  private static final String SUPPLIES_CLASS_MEDICINE = "20";
  // NULL
  private static final String NULL_VALUE = null;
  // add #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end

  // mod bug 8157 修正 chen start
  @Transactional
  @Override
  public JournalCreateRequestResponse createOrdMainEquipInfoBatch(List<ApiEntityOrdMain.ValiOrdEquip> bodyDataList){
    ApiEntityOrdMain.ValiOrdEquip firstBodyData = bodyDataList.get(0);
    // 選択された曜日の処理
    String startDate = firstBodyData.getStart_date().replaceAll("-", "");
    String endDate = firstBodyData.getEnd_date().replaceAll("-", "");
    List<Integer> weeksArry = IndicationUtils.getWeekPattern(firstBodyData.getWeeks());
    JSONObject firstBodyDataJson = new JSONObject(firstBodyData.getInd_info());// 編集内容
    // 更新対象治療情報リスト取得
    List<OrdMain> ordMain = new ArrayList<OrdMain>();
    List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
    try {
      ordMain = ordMainDao.selectUpdateTarget(
        Long.parseLong(firstBodyData.getPat_id()),
        firstBodyData.getFacility_cd(),
        startDate,
        endDate,
        weeksArry,
        ordMainResource.getValueList(firstBodyData.getInd_treatment_cd()),
        ordMainResource.getLongList(firstBodyData.getInd_kur_cd()),
        null
      );
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      JournalCreateRequestResponse response = new JournalCreateRequestResponse();
      response.setResponse(new ResponseEntity<>("DBの更新に失敗しました。", (org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR));
      response.setCtlNoList(ctlNoList);
      return response;
    }

    //add #10266 start
    if("2".equals(firstBodyData.getUpdate_flag())){
      ordMain = ordMain.stream().filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
    }
    if(ordMain.size()<=0){
      JournalCreateRequestResponse response = new JournalCreateRequestResponse();
      response.setResponse(ResponseEntity.ok().build());
      response.setCtlNoList(ctlNoList);
      return response;
    }
    //add #10266 end

    //add #10412 次患者更新関連全体見直し対応 朴 start
    List<OrdMain> beforeOrdMainList = ordMain.stream().map(SerializationUtils::clone).collect(Collectors.toList());
    //add #10412 次患者更新関連全体見直し対応 朴 end

    LocalDateTime update = LocalDateTime.now();
    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Store a copy of the data before editing to Mongo, alternative method: getHistory(ord_no) in method updateOrdMainEquipInfo(), And Optimized for batch insertion --start */
    List<Long> ordNoListForMongoLog = ordMain.stream().map(ordMain1 -> ordMain1.getOrdNo()).collect(Collectors.toList());
    selectHistoryUtils.insertMangoDbHistoryBatch(ordNoListForMongoLog);
    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Store a copy of the data before editing to Mongo, alternative method: getHistory(ord_no) in method updateOrdMainEquipInfo(), And Optimized for batch insertion --end */

    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Cache the master data to avoid repeated read from database --start */
    // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
    //List<Integer> editEquipCodeList = new ArrayList<>(); // Record the equip code to be edited
    List<EquipCodeAndType> editEquipCodeList = new ArrayList<EquipCodeAndType>(); // Record the equip code to be edited
    // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
    for (ApiEntityOrdMain.ValiOrdEquip bodyData : bodyDataList) {
      JSONObject editEquipJson = new JSONObject(bodyData.getInd_info());// 編集内容
      if(editEquipJson.get("cd") == null){ // check NullPointerException
        continue;
      }
      // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
      //String classCd = String.valueOf( editEquipJson.get("cd") ); // 医療材料Code
      String code = String.valueOf( editEquipJson.get("cd") ); // 医療材料Code
      String type = String.valueOf( editEquipJson.get("equip_type") ); // 医療材料区分
      EquipCodeAndType equipCodeAndType = new EquipCodeAndType();
      if(!StringUtils.isEmpty(code)){
        equipCodeAndType.setEquipmentCd(Integer.parseInt(code));
        equipCodeAndType.setEquipType(type);
        editEquipCodeList.add(equipCodeAndType);
      }
//      if(!StringUtils.isEmpty(classCd)){
//
//        editEquipCodeList.add(Integer.parseInt(classCd));
//      }
      // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
    }
    MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
    masterCacheHandler.loadEquipmentMap(editEquipCodeList,true);
    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Cache the master data to avoid repeated read from database --end */

    // add FNSI-医療材料最新識別番号の設定 start
    Map<String, Long> equipInfoNoMap = new HashMap<>();
    Set<String> existsEquipKeys = new HashSet<>();
    if (!ordMain.isEmpty()) {
      JSONArray existsEquipArr = new JSONArray(ObjectUtils.isEmpty(ordMain.get(0).getIndEquipInfo()) ? "[]" : ordMain.get(0).getIndEquipInfo());
      for (int i = 0; i < existsEquipArr.length(); i++) {
        JSONObject existsEquip = existsEquipArr.getJSONObject(i);
        String existsKey = String.valueOf(existsEquip.get("cd")) + "_" + (existsEquip.isNull("equip_type") ? "0" : existsEquip.get("equip_type").toString());
        existsEquipKeys.add(existsKey);
      }
    }
    List<String> newEquipKeys = new ArrayList<>();
    for (ApiEntityOrdMain.ValiOrdEquip bodyData : bodyDataList) {
      JSONObject addEquip = new JSONObject(bodyData.getInd_info());
      if (addEquip.isNull("cd")) {
        continue;
      }
      String addEquipKey = String.valueOf(addEquip.get("cd")) + "_" + (addEquip.isNull("equip_type") ? "0" : addEquip.get("equip_type").toString());
      if (!existsEquipKeys.contains(addEquipKey) && !newEquipKeys.contains(addEquipKey)) {
        newEquipKeys.add(addEquipKey);
      }
    }
    if (!newEquipKeys.isEmpty()) {
      ordMainDao.lockMaxIndEquipInfoNo(firstBodyData.getFacility_cd(), firstBodyData.getPat_id());
      Timestamp nowTs = Timestamp.from(java.time.Instant.now());
      ordMainDao.updatePatEquipmentNo(
        new EquipmentLatestNo(firstBodyData.getFacility_cd(), Long.valueOf(firstBodyData.getPat_id()), newEquipKeys.size(), nowTs, nowTs,
          AdminWebConstant.FlagType.FLAG_ON, AdminWebConstant.FlagType.FLAG_OFF)
      );
      long maxEquipNo = ordMainDao.selectIndEquipInfoNo(firstBodyData.getFacility_cd(), firstBodyData.getPat_id());
      long startEquipNo = maxEquipNo - newEquipKeys.size() + 1;
      for (int i = 0; i < newEquipKeys.size(); i++) {
        equipInfoNoMap.put(newEquipKeys.get(i), startEquipNo + i);
      }
    }
    // add FNSI-医療材料最新識別番号の設定 end

    List<Long> ordMainIdList = new ArrayList();
    /* modify by chamaojia 2023-03-13 [6961] forループのデータベース操作を抽出し、一括処理に変更する --start */
    // リストの各治療予定を更新していく
//    List<OrdMaterialSave> ordMaterialSaveList = new ArrayList<>();
//    List<ApiEntityOrdMain.ValiOrdMaterialSave> conditionList = new ArrayList<>();
    //add #10196 Ord_Material_Save code implementation 20240129 ztc start
    // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new ArrayList<>();
    // del 12250 ord_material_saveの処理を2回重複実行している zkm end
    //add #10196 Ord_Material_Save code implementation 20240129 ztc end
    for (OrdMain ord : ordMain) {
      // 实绩_治疗状况  0：条件送信前、1：条件送信済、2：条件送信確認済み、3：治療中、4：排液済、 5：後体重測定済み(実績未確定)、6：後体重確認済み(過去実績)
      String rstDialysisState = ord.getRstDialysisState();
      boolean isUpdatedRstEquipInfo = false;
      JSONObject editEquipJson = null;
      //add #11841 【たくしん会】ord_mainの登録不正 zrx start
      if(Objects.equals("0", ord.getRstDialysisState())) {
        ord = ordMainService.delJSONKey(ord);
      }
      //add #11841 【たくしん会】ord_mainの登録不正 zrx end
      for (ApiEntityOrdMain.ValiOrdEquip bodyData : bodyDataList) {
        /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
        // JSONArray ordEquipArr = new JSONArray(ord.getIndEquipInfo());
        JSONArray ordEquipArr = new JSONArray(ObjectUtils.isEmpty(ord.getIndEquipInfo())? "[]" : ord.getIndEquipInfo());
        /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
        // 治療状況が条件送信前のみunit項目を削除    仅在治疗状态发送条件之前删除单元项
        editEquipJson = new JSONObject(bodyData.getInd_info());// 編集内容
        /* delete by chamaojia 2024-01-26 [10196] No need to set "unit" before sending the message --start */
//        String unit = null;
//        if (AdminWebConstant.OrdMainConst.DialysisState.BEFORE_SEND.equals(rstDialysisState)) {
//          if (! editEquipJson.isNull("unit")) {
//            unit = editEquipJson.getString("unit");
//            editEquipJson.put("unit", JSONObject.NULL);
//          }
//        }
        /* delete by chamaojia 2024-01-26 [10196] No need to set "unit" before sending the message --end */

        // Find the indEquipInfo to edit from the ordEquipArr collection --start
        JSONObject indEquipInfo = null;
        for (int i = 0; i < ordEquipArr.length(); i++) {
          // 医療材料区分 0:医療材料、1:ダイアライザ   医用材料类别  0：医用材料，1：透析器
          JSONObject indEquipInfoDB = ordEquipArr.getJSONObject(i);
          int dbEquipType = indEquipInfoDB.isNull("equip_type") ? 0 : (int) indEquipInfoDB.get("equip_type");
          int editEquipTye =  (int) editEquipJson.get("equip_type");
          String editClassCd = String.valueOf( editEquipJson.get("cd") ); // 医療材料Code
          String dbClassCd = String.valueOf( indEquipInfoDB.get("cd") );
          if ( dbClassCd.equals(editClassCd) && dbEquipType == editEquipTye ) {
            indEquipInfo = indEquipInfoDB;
            break;
          }
        }
        // Find the indEquipInfo to edit from the ordEquipArr collection --end

        /* add by chamaojia 2024-01-26 [10196]  Translation of adding the name of the modifier --start */
        String upd_user_id = editEquipJson.has("upd_user_id") ? editEquipJson.get("upd_user_id").toString() : "";
        if (!"".equals(upd_user_id)) {
          MstPersonalUser updMstPersonalUser = masterCacheHandler.getMstPersonalUser(Long.valueOf(upd_user_id));
          if (updMstPersonalUser != null) {
            editEquipJson.put("upd_user_last_name", updMstPersonalUser.getUserLastName());
            editEquipJson.put("upd_user_first_name", updMstPersonalUser.getUserFirstName());
          }
        }
        /* add by chamaojia 2024-01-26 [10196]  Translation of adding the name of the modifier --end */

        // 更新中ordMainの指示医療材料--start
        int autoInsert = Integer.parseInt(bodyData.getAuto_insert());
        /* modify by chamaojia 2024-01-26 [10196] Modify the logical order of judgment to address omissions --start */
        if(indEquipInfo != null && autoInsert == 0){
          int amount = indEquipInfo.getInt("amount") + editEquipJson.getInt("amount");
          // 数量
          // add 9973 -4 by kangjie 20231027 start
          indEquipInfo.put("amount", amount + "");
          // add 9973 -4 by kangjie 20231027 end
          // 指示者コード
          indEquipInfo.put("ind_user_id", editEquipJson.get("ind_user_id"));
          indEquipInfo.put("ind_user_last_name", editEquipJson.get("ind_user_last_name"));
          indEquipInfo.put("ind_user_first_name", editEquipJson.get("ind_user_first_name"));
          // 更新者コード
          indEquipInfo.put("upd_user_id", editEquipJson.get("upd_user_id"));
          indEquipInfo.put("upd_user_last_name", editEquipJson.get("upd_user_last_name"));
          indEquipInfo.put("upd_user_first_name", editEquipJson.get("upd_user_first_name"));
        }
        // --更新中ordMainの指示医療材料--end

        // modify 11323 by kangjie 20241204 start
        editEquipJson.remove("needle_type");
        // modify 11323 by kangjie 20241204 end

        // --更新中ordMainの实际医療材料--start
        /// 治療状況が未登録以外の場合、実績に変更を反映する
        // mod FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
        String isRstUpdate = bodyData.getIs_rst_update();
        String rstEquipInfo = null;
        // if (OrdMainConst.DialysisState.BEFORE_SEND.equals(rstDialysisState)) {
        if (AdminWebConstant.OrdMainConst.DialysisState.BEFORE_SEND.equals(rstDialysisState)) {
          // mod FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end    IES 475 支持最新改造清单
          if(indEquipInfo == null){
            if (!editEquipJson.has("no") || editEquipJson.isNull("no")) {
              String equipKey = String.valueOf(editEquipJson.get("cd")) + "_" + (editEquipJson.isNull("equip_type") ? "0" : editEquipJson.get("equip_type").toString());
              if (equipInfoNoMap.containsKey(equipKey)) {
                editEquipJson.put("no", equipInfoNoMap.get(equipKey));
              } else {
                editEquipJson.put("no", ordMainService.selectMaxEquipInfoNo(firstBodyData.getFacility_cd(), firstBodyData.getPat_id()));
              }
            }
            ordEquipArr.put(editEquipJson);
          }
          rstEquipInfo = ord.getRstEquipInfo();
        } else { // 反映在实际结果中
          //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240913 start
          JSONObject rstEquipJson = this.getEquipDeployInfo(ord.getPatId(), ord.getFacilityCd(), editEquipJson, masterCacheHandler);
          //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240913 end
          if(indEquipInfo == null){
            if (!editEquipJson.has("no") || editEquipJson.isNull("no")) {
              String equipKey = String.valueOf(editEquipJson.get("cd")) + "_" + (editEquipJson.isNull("equip_type") ? "0" : editEquipJson.get("equip_type").toString());
              if (equipInfoNoMap.containsKey(equipKey)) {
                editEquipJson.put("no", equipInfoNoMap.get(equipKey));
              } else {
                editEquipJson.put("no", ordMainService.selectMaxEquipInfoNo(firstBodyData.getFacility_cd(), firstBodyData.getPat_id()));
              }
            }
            ordEquipArr.put(editEquipJson);
          }
          if ("false".equals(isRstUpdate)) {
            rstEquipInfo = ord.getRstEquipInfo();
          } else {
            JSONArray rstEquipArr = new JSONArray(ord.getRstEquipInfo() == null ? "[]" : ord.getRstEquipInfo());
            rstEquipInfo = this.createRstEquipInfo(ordEquipArr, rstEquipArr, "cd", rstEquipJson).toString();
            isUpdatedRstEquipInfo = true;
          }
        }
        ord.setRstEquipInfo(rstEquipInfo);
        // --更新中ordMainの实际医療材料--end
        ord.setIndEquipInfo(ordEquipArr.toString());
        /* modify by chamaojia 2024-01-26 [10196] Modify the logical order of judgment to address omissions --end */
      }; // end  bodyDataList.forEach

      /* del by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
//      /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Move code block here ( search move7734 )  start */
//      JSONObject indScheduleUserInfoJObj = new JSONObject(ord.getIndScheduleUserInfo());
//      //中止画面からの指示者が元々の指示者と不一致の場合、指示者が変更することにする。
//      String edit_ind_user_id = StrUtils.getStrFromJSONObject(editEquipJson,"ind_user_id");
//      String ind_schedule_ind_user_id = StrUtils.getStrFromJSONObject(indScheduleUserInfoJObj,"ind_user_id");
//      if(!edit_ind_user_id.equals(ind_schedule_ind_user_id)) {
//        //ind_user_id（指示者）の値を変更。
//        indScheduleUserInfoJObj.put("ind_user_id", Long.valueOf(edit_ind_user_id));
//        String edit_ind_user_first_name = StrUtils.getStrFromJSONObject(editEquipJson,"ind_user_first_name");
//        if (!StringUtils.isEmpty(edit_ind_user_first_name)) {
//          indScheduleUserInfoJObj.put("ind_user_first_name", edit_ind_user_first_name);
//        }
//        String edit_ind_user_last_name = StrUtils.getStrFromJSONObject(editEquipJson,"ind_user_last_name");
//        if (!StringUtils.isEmpty(edit_ind_user_last_name)) {
//          indScheduleUserInfoJObj.put("ind_user_last_name", edit_ind_user_last_name);
//        }
//        ord.setIndScheduleUserInfo(indScheduleUserInfoJObj.toString());
//      }
//      /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Move code block here ( search move7734 )  end */
      /* del by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */

      try {
        // update fields: 指示_医療材料、実績_医療材料、最終更新指示者(add FNSI-最終更新指示者のカラム追加と更新処理)
//        updateOrdMainEquipInfo(ord, Long.valueOf(String.valueOf(firstBodyDataJson.get("ind_user_id"))), Long.valueOf(String.valueOf(firstBodyDataJson.get("upd_user_id"))));

        // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 start
        /* modify by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Narrow the range of deleted and inserted data --start */
        // delete the ordMaterialSave of 1:指示、2:実績区分 ---start
        // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 start
        // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//        ApiEntityOrdMain.ValiOrdMaterialSave conditions = new ApiEntityOrdMain.ValiOrdMaterialSave();
//        // 施設コード
//        conditions.setFacility_cd(firstBodyData.getFacility_cd());
//        // 患者ID
//        conditions.setPat_id(firstBodyData.getPat_id());
//        // データ基準日
//        conditions.setBase_date(ord.getTreatDate());
//        // データ基準番号
//        conditions.setSupplies_base_no(ord.getOrdNo().toString());
//        // データ発生元区分List(2：医療材料)
//        conditions.setSupplies_source_class("2");
//        // 物品区分  11：他医療材料
//        List<String> suppliesClass = Arrays.asList("11");
//        conditions.setSupplies_class_list(suppliesClass);
//        // 1:指示、2:実績
//        List<String> indRstClassList = null;
//        if(isUpdatedRstEquipInfo){
//          indRstClassList = Arrays.asList("1","2");
//        }else {
//          indRstClassList = Arrays.asList("1");
//        }
//        conditions.setIndRstClassList(indRstClassList);
        // del 12250 ord_material_saveの処理を2回重複実行している zkm end
//        // 医疗材料コード
//        List<String> suppliesCdList = editEquipCodeList.stream().map(o -> o.toString()).collect(Collectors.toList());
        /* modify by chamaojia 2023-03-30 エンティティークラスコピー処理 --start */
        //del #10196 Ord_Material_Save code implementation 20240129 ztc start
//        ApiEntityOrdMain.ValiOrdMaterialSave ordMaterialSave = new ApiEntityOrdMain.ValiOrdMaterialSave();
//        BeanUtils.copyProperties(conditions, ordMaterialSave);
//        conditionList.add(ordMaterialSave);
                //del #10196 Ord_Material_Save code implementation 20240129 ztc end
        /* modify by chamaojia 2023-03-30 エンティティークラスコピー処理 --end */
        // 条件に基づいてデータを削除する 根据条件删除数据
//        int delCount = ordMaterialSaveDao.deleteByConditions(
//                conditions.getFacility_cd(),
//                conditions.getPat_id(),
//                conditions.getSupplies_base_no(),
//                conditions.getBase_date(),
//                conditions.getSupplies_source_class(),
//                suppliesClass,
//                indRstClassList,
//                suppliesCdList
//        );
        //ordMaterialSaveService.deleteOrdMaterialSaveByConditions(conditions);
        // delete the ordMaterialSave of 1:指示、2:実績区分 ---end
        //mod #10196 Ord_Material_Save code implementation 20240129 ztc start
        // insert the ordMaterialSave of 1:指示 ---start
        // 計算材料保持テーブル投与薬剤情報値の設定
//        JSONArray ordIndEquipArr = new JSONArray(ord.getIndEquipInfo());
        //this.indEquipValueSetting(conditions, ordEquipArr);
//        List<OrdMaterialSave> ordMaterialSaveList1 = this.createEquipOrdMaterialSaveObj("1",conditions, ordIndEquipArr,editEquipCodeList,masterCacheHandler);
//        if (ordMaterialSaveList1 != null && ordMaterialSaveList1.size() > 0) {
//          ordMaterialSaveList.addAll(ordMaterialSaveList1);
//        }

        // insert the ordMaterialSave of 1:指示 ---end

        //mod #10196 Ord_Material_Save code implementation 20240129 ztc end
        // insert the ordMaterialSave of 2:実績 ---end
//        if(!ordMaterialSaveList1.isEmpty()){
//          ordMaterialSaveDao.insertBatch(ordMaterialSaveList1);
//        }
        /* modify by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Narrow the range of deleted and inserted data --end */
        // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 end

        // add FNSI-最終更新指示者のカラム追加と更新処理 楊 start
        // 最終更新指示者のカラム追加と更新処理
//        List<Long> ordMainCdList = new ArrayList();
//        ordMainCdList.add(ord.getOrdNo());
//        ordMainResource.updUpUseId(ordMainCdList, Long.valueOf(String.valueOf(editEquipJson.get("ind_user_id"))), Long.valueOf(String.valueOf(editEquipJson.get("upd_user_id"))));
        ordMainIdList.add(ord.getOrdNo());
        // add FNSI-最終更新指示者のカラム追加と更新処理 楊 end
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        JournalCreateRequestResponse response = new JournalCreateRequestResponse();
        response.setResponse(new ResponseEntity<>("DBの更新に失敗しました。", (org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR));
        response.setCtlNoList(ctlNoList);
        return response;
      }
    } // for (OrdMain ord : ordMain) end

    //mod 9806 ljx start 医療材料
    //updateOrdMainEquipInfoByOrdMainList(ordMain, firstBodyDataJson.getLong("ind_user_id"), firstBodyDataJson.getLong("upd_user_id"));
    updateOrdMainEquipInfoByOrdMainList(ordMain, firstBodyDataJson.getLong("ind_user_id"), firstBodyDataJson.getLong("upd_user_id"),"true".equals(firstBodyData.getIs_rst_update()));
    //mod 9806 ljx end
    // 医疗材料コード
        // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
    //List<String> suppliesCdList = editEquipCodeList.stream().map(o -> o.toString()).collect(Collectors.toList());
    //del #10196 Ord_Material_Save code implementation 20240129 ztc start
//    List<String> suppliesCdList = editEquipCodeList.stream().map(o -> String.valueOf(o.getEquipmentCd())).collect(Collectors.toList());
        // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
//    for (ApiEntityOrdMain.ValiOrdMaterialSave conditions : conditionList) {
//      // 条件に基づいてデータを削除する 根据条件删除数据
//      ordMaterialSaveDao.deleteByConditions(
//        conditions.getFacility_cd(), // 施設コード
//        conditions.getPat_id(), // 患者ID
//        conditions.getSupplies_base_no(), // データ基準番号
//        conditions.getBase_date(), // データ基準日
//        conditions.getSupplies_source_class(), // 0：治療条件、1：投与薬剤、2：医療材料、3：愁訴処置、4：処方
//        conditions.getSupplies_class_list(), // 11：他医療材料
//        conditions.getIndRstClassList(), // 1:指示、2:実績
//        suppliesCdList // 医疗材料コード
//      );
//    }

//    if(!ordMaterialSaveList.isEmpty()){
//      ordMaterialSaveService.insertBatch(ordMaterialSaveList);
//    }
        //del #10196 Ord_Material_Save code implementation 20240129 ztc end
    /* modify by chamaojia 2023-03-13 [6961] forループのデータベース操作を抽出し、一括処理に変更する --end */
    // add FNSI-最終更新指示者のカラム追加と更新処理 楊 start
    /* modify by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Record all ordMainIds, As the parameter of method updpatinandapprove(), Change from single insert to batch insert */
    this.updPatIndApprove(ordMainIdList);
    // add FNSI-最終更新指示者のカラム追加と更新処理 楊 end

    // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 start
    /* modify by chamaojia 2023-03-22 [6961] ループから移動し、一括アクションに変更 --start */
//    ordMain.forEach(item -> {
//      // 患者経過総合ビューア用、最終更新指示者のカラム追加と更新処理
//      ordMainResource.updateOrdChecklistByAction(
//        OrdMainResource.OrdMainActionForChecklist.TREATPLAN_EQUIPMENT_CREATE,
//        Long.parseLong(item.getOrdNo().toString())
//      );
//    });
    List<Long> ordNoList = ordMain.stream().map(o -> o.getOrdNo()).collect(Collectors.toList());
    //mod 9324 医療材料追加コールord_checklist共通方法 gjn start
    //ordMainResource.updateOrdChecklistByActionToList(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_EQUIPMENT_CREATE, ordNoList);
    ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_EQUIPMENT_CREATE, ordNoList);
    //mod 9324 医療材料追加コールord_checklist共通方法 gjn end

    /* modify by chamaojia 2023-03-22 [6961] ループから移動し、一括アクションに変更 --end */
    // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 end

    // 指示履歴登録処理(医療材料)
    /**
     * modify by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization:
     * 1、First determine whether Mongo is necessary to avoid unnecessary object creation
     * 2、Change from single insert to batch insert, createHistoryExecute() modify to createHistoryExecuteBatch()
     */
    // indHistoryMakeService.createEquipmentHistory(bodyData, "1", weeksArry, new ArrayList<OrdMain>());
    if(indHistoryMakeService.isToMongo()){
      String setLogDate = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date());
      List<IndHistory> indHistoryList = new ArrayList<>();
      for (ApiEntityOrdMain.ValiOrdEquip bodyData : bodyDataList) {
        //指示履歴用パラメータ
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        IndHistory indHistory = indHistoryMakeService.createEquipmentHistoryParams(bodyData, "1", weeksArry, new OrdMain());
        IndHistory indHistory = indHistoryMakeService.createEquipmentHistoryParams(bodyData, "1", weeksArry, new ArrayList<>());
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        //指示履歴時刻設定
        indHistory.setLogDate(setLogDate);
        indHistoryList.add(indHistory);
        //指示履歴登録処理
        //indHistoryMakeService.createHistoryExecute(indHistory, "1");
      }
      if(indHistoryList.size() > 0){
        //指示履歴登録処理
        indHistoryMakeService.createHistoryExecuteBatch(indHistoryList, "1");
      }
    }

    //del #10412 次患者更新関連全体見直し対応 朴 start
//    String facilityCd = firstBodyData.getFacility_cd();
//    Long skipCode = Long.parseLong("0");
//    // 次患者更新処理
//    for (OrdMain ord : ordMain) {
//      Long bedCd = Long.parseLong(ord.getIndBedCd().toString());
//      Long targetOrdNo = ord.getOrdNo();
//      // 登録されているベッド(ベッド移動なしのため変更後として処理※変更前は条件送信キャンセルとして処理されるため)
//      /* mod #5482 by zhangruixue 2023-03-02 スケジュール --start */
////      ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, targetOrdNo, true, update);
//      ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, ord, true, update);
//      /* mod #5482 by zhangruixue 2023-03-02 スケジュール --end */
//    }
    //del #10412 次患者更新関連全体見直し対応 朴 end

    // 終了日が未設定の場合患者治療パターンの新規登録 ---start
    List<String> equipInfo = new ArrayList<String>();
    for (ApiEntityOrdMain.ValiOrdEquip bodyData : bodyDataList) {
      if ("false".equals(bodyData.getIs_deadline())) {
        // modify 11323 by kangjie 20241203 start  pat _ treatment _ patternテーブル翻訳upd _ user _ name
        JSONObject indInfoJSONObject = new JSONObject(bodyData.getInd_info());
        String upd_user_id = indInfoJSONObject.has("upd_user_id") ? indInfoJSONObject.get("upd_user_id").toString() : "";
        if (!"".equals(upd_user_id)) {
          MstPersonalUser updMstPersonalUser = masterCacheHandler.getMstPersonalUser(Long.valueOf(upd_user_id));
          if (updMstPersonalUser != null) {
            indInfoJSONObject.put("upd_user_last_name", updMstPersonalUser.getUserLastName());
            indInfoJSONObject.put("upd_user_first_name", updMstPersonalUser.getUserFirstName());
          }
        }
        // modify 11323 by kangjie 20241203 end
        // modify 11323 by kangjie 20241203 start needle _ typeの使用を削除するには
        indInfoJSONObject.remove("needle_type");
        // modify 11323 by kangjie 20241203 end
        // 医療材料をString型のListに格納
//        equipInfo.add(bodyData.getInd_info());
        equipInfo.add(indInfoJSONObject.toString());
      }
    }
    if(!equipInfo.isEmpty()){
      PatTreatmentPatternUtils.PatTreatmentPatternEditData editData = new PatTreatmentPatternUtils.PatTreatmentPatternEditData();
      // 患者治療パターン編集データの格納
      editData.setIndEquipInfo(equipInfo.toString());
      // add 10744 医療材料の穴埋め追加によるpat_treatment_patternへの追加処理が不正 関 start
      editData.setAutoInsert(firstBodyData.getAuto_insert());
      // add 10744 医療材料の穴埋め追加によるpat_treatment_patternへの追加処理が不正 関 end

      // 患者治療パターン項目新規登録処理
      int patPatternCount = patTreatmentPatternUtils.insertPatTreatmentPatternIndItemForIndMediAndEquip(
        Long.parseLong(firstBodyData.getPat_id()),
        firstBodyData.getFacility_cd(),
        ordMainResource.getValueList(firstBodyData.getInd_treatment_cd()),
        ordMainResource.getLongList(firstBodyData.getInd_kur_cd()),
        weeksArry,
        PatTreatmentPatternUtils.IND_ITEM.EQUIP,
        Timestamp.valueOf(update),
        editData
      );
    }
    // 終了日が未設定の場合患者治療パターンの新規登録 ---end

    /* del by chamaojia 2023-08-09 [9303] この判断による連携送信の阻止は不要である  --start */
//    if (firstBodyData.getHosp_pat_id() == null || "".equals(firstBodyData.getHosp_pat_id())) {
//      JournalCreateRequestResponse response = new JournalCreateRequestResponse();
//      response.setResponse(ResponseEntity.ok().build());
//      response.setCtlNoList(ctlNoList);
//      return response;
//    }
    /* del by chamaojia 2023-08-09 [9303] この判断による連携送信の阻止は不要である  --end */

    List<Integer> treatCdList = ordMain.stream().map(OrdMain::getIndTreatmentCd).distinct().collect(Collectors.toList());
    List<MstTreatment> mstTreatList = treatCdList.stream().map(treatCd -> mstTreatmentDao.selectByCd(treatCd)).collect(Collectors.toList());
    for (MstTreatment mstTreat : mstTreatList) {
      List<OrdMain> ordMainList = ordMain.stream()
        .filter(o -> o.getIndTreatmentCd().equals(mstTreat.getTreatmentCd())).collect(Collectors.toList());
      //7771-------------------------------ljg start
      /* Commented by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: To move this update above ( search move7734 above ) */
      //7734 指示者変更の場合 lig stsrt
      //      ordMainList.stream().forEach(item -> {
      //        String indScheduleUserInfo  = item.getIndScheduleUserInfo();
      //        JSONObject indScheduleUserInfoJObj = new JSONObject(indScheduleUserInfo);
      //        JSONObject bodyDataIndinfoObj = new JSONObject(firstBodyData.getInd_info());
      //        //中止画面からの指示者が元々の指示者と不一致の場合、指示者が変更することにする。     如果停止屏幕上的讲师与原来的讲师不匹配，则将更换讲师
      //        if(!bodyDataIndinfoObj.get("ind_user_id").toString().equals((indScheduleUserInfoJObj.get("ind_user_id")).toString())){
      //          if(item.getOrdNo() !=null){
      //            //ind_user_id（指示者）の値を変更。
      //            indScheduleUserInfoJObj.put("ind_user_id",Long.valueOf((bodyDataIndinfoObj.get("ind_user_id")).toString()));
      //            if((bodyDataIndinfoObj.get("ind_user_first_name")).toString()!=null &&
      //              ! "" .equals((bodyDataIndinfoObj.get("ind_user_first_name")).toString())){
      //              indScheduleUserInfoJObj.put("ind_user_last_name",(bodyDataIndinfoObj.get("ind_user_last_name")).toString());
      //            }
      //            if((bodyDataIndinfoObj.get("ind_user_first_name")).toString()!=null &&
      //              ! "" .equals((bodyDataIndinfoObj.get("ind_user_first_name")).toString())
      //            ){
      //              indScheduleUserInfoJObj.put("ind_user_first_name",(bodyDataIndinfoObj.get("ind_user_first_name")).toString());
      //            }
      ////            indScheduleUserInfoJObj.put("ind_user_last_name",(bodyDataIndinfoObj.get("ind_user_last_name")).toString());
      ////            indScheduleUserInfoJObj.put("ind_user_first_name",(bodyDataIndinfoObj.get("ind_user_first_name")).toString());
      //            indScheduleUserInfo = indScheduleUserInfoJObj.toString();
      //            //指示者が変更されたのデータを更新する。
      //            ordMainDao.updateInduser(Long.valueOf(item.getOrdNo()),indScheduleUserInfo);
      //          }
      //        }
      //      });
      //7734 指示者変更の場合 lig end
      if (ordMainList.size()>0) {
        //7771-------------------------------ljg end
        // オペコードを設定する     设置操作码
        String opeCd = "004026";
        // mod 2023-01-14 bug #7627 修正 chen start
        // JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
        // // SysCoopJournal journalCreateRequestPayload = new SysCoopJournal();
        // JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
        // journalCreateRequestPayload.setFacilityCd(firstBodyData.getFacility_cd());
        // journalCreateRequestPayload.setCrud("U");
        // journalCreateRequestPayload.setHospPatId(firstBodyData.getHosp_pat_id());
        // journalCreateRequestPayload.setPatId(Long.valueOf(firstBodyData.getPat_id()));
        // journalCreateRequestPayload.setUserId(Long.valueOf(firstBodyData.getUser_id()));
        // journalCreateRequestPayload.setOpeCd(opeCd);
        // asyncService.sendExternalConnection(ordMainList, journalCreateRequestPayload);
        // List<Long> ctlNoList = new ArrayList<>();
        // del #11004 連携イベント発生部分不正 piao start
        // int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(firstBodyData.getFacility_cd());
        // del #11004 連携イベント発生部分不正 piao end
        for (OrdMain ord : ordMainList) {
            if(ord.getIndKurCd() == null || ord.getIndKurCd().equals(0)){
                opeCd = "004226";
              }else {
                opeCd = "004026";
              }
          // del #11004 連携イベント発生部分不正 piao start
          // if (modify_send_class == 2) {
          //   JournalCreateRequestPayload deljournalCreateRequestPayload = new JournalCreateRequestPayload();
          //   deljournalCreateRequestPayload.setFacilityCd(firstBodyData.getFacility_cd());
          //   deljournalCreateRequestPayload.setCrud("D");
          //   deljournalCreateRequestPayload.setHospPatId(firstBodyData.getHosp_pat_id());
          //   deljournalCreateRequestPayload.setPatId(Long.valueOf(firstBodyData.getPat_id()));
          //   deljournalCreateRequestPayload.setUserId(Long.valueOf(firstBodyData.getUser_id()));
          //   deljournalCreateRequestPayload.setOpeCd(opeCd);
          //   deljournalCreateRequestPayload.setOrdNo(ord.getOrdNo());
          //   deljournalCreateRequestPayload.setBaseDate(ord.getTreatDate());
          //   ctlNoList.add(deljournalCreateRequestPayload);
          //
          // }
          // del #11004 連携イベント発生部分不正 piao end
          JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
          journalCreateRequestPayload.setFacilityCd(firstBodyData.getFacility_cd());
          journalCreateRequestPayload.setCrud("U");
          // del #11004 連携イベント発生部分不正 piao start
          // if (modify_send_class == 2) {
          //   journalCreateRequestPayload.setCrud("C");
          // }
          // del #11004 連携イベント発生部分不正 piao end
          journalCreateRequestPayload.setHospPatId(firstBodyData.getHosp_pat_id());
          journalCreateRequestPayload.setPatId(Long.valueOf(firstBodyData.getPat_id()));
          journalCreateRequestPayload.setUserId(Long.valueOf(firstBodyData.getUser_id()));
          journalCreateRequestPayload.setOpeCd(opeCd);
          journalCreateRequestPayload.setOrdNo(ord.getOrdNo());
          journalCreateRequestPayload.setBaseDate(ord.getTreatDate());
          // journalCreateRequestPayload.setCtlNo(sysCoopJournalDao.selectNextSeqCtlNo());
          // sysCoopJournalDao.insert(journalCreateRequestPayload);
          // ctlNoList.add(journalCreateRequestPayload.getCtlNo());
          ctlNoList.add(journalCreateRequestPayload);
        }
        // mod 2023-01-14 bug #7627 修正 chen end
      }
    }
    JournalCreateRequestResponse response = new JournalCreateRequestResponse();
    response.setResponse(ResponseEntity.ok().build());

    //add #10412 次患者更新関連全体見直し対応 朴 start
    response.setDoCallNextPatOrdMainList(beforeOrdMainList);
    //add #10412 次患者更新関連全体見直し対応 朴 end

    response.setCtlNoList(ctlNoList);
    return response;
  }

  /**
   * ind_equip_info中止処理
   *
   * @param bodyData 必要パラメータの記載されたJson文字列
   * @return
   * @throws URISyntaxException
   */
  @Override
  @Transactional
  public JournalCreateRequestResponse deleteOrdMainEquipInfo(ApiEntityOrdMain.ValiOrdEquip bodyData){
    // 選択された曜日の処理
    String startDate = bodyData.getStart_date().replaceAll("-", "");
    String endDate = bodyData.getEnd_date().replaceAll("-", "");
    List<Integer> weeksArry = IndicationUtils.getWeekPattern((String) bodyData.getWeeks());

    LocalDateTime update = LocalDateTime.now();

    // 更新対象治療情報リスト取得
    List<OrdMain> ordMain = new ArrayList<OrdMain>();
    //add FNSI-9355 ljx start
    List<OrdMain> oldOrdMain = new ArrayList<OrdMain>();
    //add FNSI-9355 ljx end
    List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
    try {
      ordMain = ordMainDao.selectUpdateTarget(
        Long.parseLong(bodyData.getPat_id()),
        bodyData.getFacility_cd(),
        startDate,
        endDate,
        weeksArry,
        ordMainResource.getValueList(bodyData.getInd_treatment_cd()),
        ordMainResource.getLongList(bodyData.getInd_kur_cd()),
        null
      );
      //add FNSI-9355 ljx start
      oldOrdMain = ordMainService.deepCopyList(ordMain);
      //add FNSI-9355 ljx end
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      JournalCreateRequestResponse response = new JournalCreateRequestResponse();
      response.setResponse(new ResponseEntity<>("DBの更新に失敗しました。", (org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR));
      response.setCtlNoList(ctlNoList);
      return response;
    }

    //add #10266 start
    if("2".equals(bodyData.getUpdate_flag())){
      ordMain = ordMain.stream().filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
    }
    if(ordMain.size()<=0){
      JournalCreateRequestResponse response = new JournalCreateRequestResponse();
      response.setResponse(ResponseEntity.ok().build());
      response.setCtlNoList(ctlNoList);
      return response;
    }
    //add #10266 end

    //add #10412 次患者更新関連全体見直し対応 朴 start
    List<OrdMain> beforeOrdMainList = ordMain.stream().map(SerializationUtils::clone).collect(Collectors.toList());
    //add #10412 次患者更新関連全体見直し対応 朴 end

    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Store a copy of the data before editing to Mongo, alternative method: getHistory(ord_no) in method updateOrdMainEquipInfo(), And Optimized for batch insertion --start */
    List<Long> ordNoListForMongoLog = ordMain.stream().map(ordMain1 -> ordMain1.getOrdNo()).collect(Collectors.toList());
    selectHistoryUtils.insertMangoDbHistoryBatch(ordNoListForMongoLog);
    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Store a copy of the data before editing to Mongo, alternative method: getHistory(ord_no) in method updateOrdMainEquipInfo(), And Optimized for batch insertion --end */

    // 編集内容
    JSONObject editEquipJson = new JSONObject(bodyData.getInd_info());

    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Cache the master data to avoid repeated read from database --start */
    // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
    //List<Integer> editEquipCodeList = new ArrayList<>(); // Record the equip code to be edited
    List<EquipCodeAndType> editEquipCodeList = new ArrayList<EquipCodeAndType>();
    // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
    if(editEquipJson.get("cd") != null){ // check NullPointerException
      // 医療材料Code
      // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
//      String classCd = String.valueOf( editEquipJson.get("cd") );
//      if (!StringUtils.isEmpty(classCd)) {
//        editEquipCodeList.add(Integer.parseInt(classCd));
//      }
      String code = String.valueOf(editEquipJson.get("cd") ); // 医療材料Code
      String type = String.valueOf(editEquipJson.get("equip_type") ); // 医療材料区分
      EquipCodeAndType equipCodeAndType = new EquipCodeAndType();
      if(!StringUtils.isEmpty(code)){
        equipCodeAndType.setEquipmentCd(Integer.parseInt(code));
        equipCodeAndType.setEquipType(type);
        editEquipCodeList.add(equipCodeAndType);
      }
      // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
    }
    MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
    if(!editEquipCodeList.isEmpty()){
      masterCacheHandler.loadEquipmentMap(editEquipCodeList,true);
    }
    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Cache the master data to avoid repeated read from database --end */

    List<Long> ordMainIdList = new ArrayList();
    /* modify by chamaojia 2023-03-11 [6961] forループのデータベース操作を抽出し、一括処理に変更する --start */
    // リストの各治療予定を更新していく
    for (OrdMain ord : ordMain) {
      // 实绩_治疗状况  0：条件送信前、1：条件送信済、2：条件送信確認済み、3：治療中、4：排液済、 5：後体重測定済み(実績未確定)、6：後体重確認済み(過去実績)
      String rstDialysisState = ord.getRstDialysisState();
      boolean isUpdatedRstEquipInfo = false;
      //add #11841 【たくしん会】ord_mainの登録不正 zrx start
      if(Objects.equals("0", ord.getRstDialysisState())) {
        ord = ordMainService.delJSONKey(ord);
      }
      //add #11841 【たくしん会】ord_mainの登録不正 zrx end
      // 更新中ordMainの医療材料
      /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
      //JSONArray ordEquipArr = new JSONArray(ord.getIndEquipInfo());
      JSONArray ordEquipArr = new JSONArray(ObjectUtils.isEmpty(ord.getIndEquipInfo())? "[]" : ord.getIndEquipInfo());
      /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
      // 同じ医療材料が存在してるかをチェック
      for (int i = 0; i < ordEquipArr.length(); i++) {
        // 医療材料区分 0:医療材料、1:ダイアライザ
        int equipType = ordEquipArr.getJSONObject(i).isNull("equip_type") ? 0
          : (int) ordEquipArr.getJSONObject(i).get("equip_type");

        if (ordEquipArr.getJSONObject(i).get("cd").equals(editEquipJson.get("cd"))
          && equipType == (int) editEquipJson.get("equip_type")) {
          ordEquipArr.remove(i);
          break;
        }
      }

      // 治療状況が未登録以外の場合、実績に変更を反映する
      String rstEquipInfo = null;
//      if (rstDialysisState == 0) {
      String isRstUpdate = bodyData.getIs_rst_update();
      if (AdminWebConstant.OrdMainConst.DialysisState.BEFORE_SEND.equals(rstDialysisState) || "false".equals(isRstUpdate)) {
        rstEquipInfo = ord.getRstEquipInfo();
      } else {
        JSONArray rstEquipArr = new JSONArray(ord.getRstEquipInfo() == null ? "[]" : ord.getRstEquipInfo());
        // mod FNSI-FutreNetWeb+SI課題管理No.4742 李 start
        // rstEquipInfo = this.createRstInfo(ordEquipArr, rstEquipArr, "cd", editEquipJson).toString();
        //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240913 start
        JSONObject rstEquipJson = this.getEquipDeployInfo(ord.getPatId(), ord.getFacilityCd(), new JSONObject(editEquipJson.toString()),masterCacheHandler);
        //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240913 end
        rstEquipInfo = this.createRstEquipInfo(ordEquipArr, rstEquipArr, "cd", rstEquipJson).toString();
        isUpdatedRstEquipInfo = true;
        // mod FNSI-FutreNetWeb+SI課題管理No.4742 李 end
      }
      ord.setIndEquipInfo(ordEquipArr.toString());
      ord.setRstEquipInfo(rstEquipInfo);

      /* del by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
      /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Move code block here ( search move7734 )  start */
//      JSONObject indScheduleUserInfoJObj = new JSONObject(ord.getIndScheduleUserInfo());
//      //中止画面からの指示者が元々の指示者と不一致の場合、指示者が変更することにする。
//      String edit_ind_user_id = StrUtils.getStrFromJSONObject(editEquipJson,"ind_user_id");
//      String ind_schedule_ind_user_id = StrUtils.getStrFromJSONObject(indScheduleUserInfoJObj,"ind_user_id");
//      if(!edit_ind_user_id.equals(ind_schedule_ind_user_id)) {
//        //ind_user_id（指示者）の値を変更。
//        indScheduleUserInfoJObj.put("ind_user_id", Long.valueOf(edit_ind_user_id));
//        String edit_ind_user_first_name = StrUtils.getStrFromJSONObject(editEquipJson,"ind_user_first_name");
//        if (!StringUtils.isEmpty(edit_ind_user_first_name)) {
//          indScheduleUserInfoJObj.put("ind_user_first_name", edit_ind_user_first_name);
//        }
//        String edit_ind_user_last_name = StrUtils.getStrFromJSONObject(editEquipJson,"ind_user_last_name");
//        if (!StringUtils.isEmpty(edit_ind_user_last_name)) {
//          indScheduleUserInfoJObj.put("ind_user_last_name", edit_ind_user_last_name);
//        }
//        ord.setIndScheduleUserInfo(indScheduleUserInfoJObj.toString());
//      }
      /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Move code block here ( search move7734 )  end */
      /* del by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */

      try {
        // update fields: 指示_医療材料、実績_医療材料、最終更新指示者(add FNSI-最終更新指示者のカラム追加と更新処理)
//        updateOrdMainEquipInfo(ord, Long.valueOf(String.valueOf(editEquipJson.get("ind_user_id"))), Long.valueOf(String.valueOf(editEquipJson.get("upd_user_id"))));

        // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 start
        /* modify by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Narrow the range of deleted and inserted data --start */
        // delete the ordMaterialSave of 1:指示、2:実績区分 ---start
//        ApiEntityOrdMain.ValiOrdMaterialSave conditions = new ApiEntityOrdMain.ValiOrdMaterialSave();
//        // 施設コード
//        conditions.setFacility_cd(bodyData.getFacility_cd());
//        // 患者ID
//        conditions.setPat_id(bodyData.getPat_id());
//        // データ基準日
//        conditions.setBase_date(ord.getTreatDate());
//        // データ基準番号
//        conditions.setSupplies_base_no(ord.getOrdNo().toString());
//        // データ発生元区分List(2：医療材料)
//        conditions.setSupplies_source_class("2");
//        // 物品区分  11：他医療材料
//        List<String> suppliesClass = Arrays.asList("11");
//        conditions.setSupplies_class_list(suppliesClass);
//        // 1:指示、2:実績
//        List<String> indRstClassList = null;
//        if(isUpdatedRstEquipInfo){
//          indRstClassList = Arrays.asList("1","2");
//        }else {
//          indRstClassList = Arrays.asList("1");
//        }
//        conditions.setIndRstClassList(indRstClassList);
//        // 医疗材料コード
//        List<String> suppliesCdList = editEquipCodeList.stream().map(o -> o.toString()).collect(Collectors.toList());

        /* modify by chamaojia 2023-03-30 エンティティークラスコピー処理 --start */
        //del #10196 Ord_Material_Save code implementation 20240129 ztc start
//        ApiEntityOrdMain.ValiOrdMaterialSave ordMaterialSave = new ApiEntityOrdMain.ValiOrdMaterialSave();
//        BeanUtils.copyProperties(conditions, ordMaterialSave);
//        conditionList.add(ordMaterialSave);
        //del #10196 Ord_Material_Save code implementation 20240129 ztc end
        /* modify by chamaojia 2023-03-30 エンティティークラスコピー処理 --end */
        // delete the ordMaterialSave of 1:指示、2:実績区分 ---end

        // insert the ordMaterialSave of 1:指示 ---start


        /* modify by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Narrow the range of deleted and inserted data --end */
        // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 end

        // add FNSI-最終更新指示者のカラム追加と更新処理 楊 start
        // 最終更新指示者のカラム追加と更新処理
//        List<Long> ordMainCdList = new ArrayList();
//        ordMainCdList.add(ord.getOrdNo());
//        ordMainResource.updUpUseId(ordMainCdList, Long.valueOf(String.valueOf(editEquipJson.get("ind_user_id"))), Long.valueOf(String.valueOf(editEquipJson.get("upd_user_id"))));
        ordMainIdList.add(ord.getOrdNo());
        // add FNSI-最終更新指示者のカラム追加と更新処理 楊 end
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (bodyData != null && bodyData.getFacility_cd() != null) {
          eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        JournalCreateRequestResponse response = new JournalCreateRequestResponse();
        response.setResponse(new ResponseEntity<>("DBの更新に失敗しました。", (org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR));
        response.setCtlNoList(ctlNoList);
        return response;
      }
    }

    //mod 9806 ljx start 医療材料
    //updateOrdMainEquipInfoByOrdMainList(ordMain, editEquipJson.getLong("ind_user_id"), editEquipJson.getLong("upd_user_id"));
    updateOrdMainEquipInfoByOrdMainList(ordMain, editEquipJson.getLong("ind_user_id"), editEquipJson.getLong("upd_user_id"),"true".equals(bodyData.getIs_rst_update()));
    //mod 9806 ljx end

    // #10196 Batch del ordMaterialSave Add by Zhou.tao Start
    List<Long> ordNoList = ordMain.stream().map(OrdMain::getOrdNo).collect(Collectors.toList());

    // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//    if (CollectionUtils.isNotEmpty(ordNoList)) {
//      this.ordMaterialSaveDao.deleteBatchByCondition(
//        bodyData.getFacility_cd(),
//        bodyData.getPat_id(),
//        ordNoList,
//        "2",
//        "true".equals(bodyData.getIs_rst_update()) ? List.of("1", "2") : Collections.singletonList("1"),
//        editEquipCodeList
//      );
//    }
    // del 12250 ord_material_saveの処理を2回重複実行している zkm end
    // #10196 Batch del ordMaterialSave Add by Zhou.tao End

    // 医疗材料コード
        // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
    /* modify by chamaojia 2023-03-11 [6961] forループのデータベース操作を抽出し、一括処理に変更する --end */

    // add FNSI-最終更新指示者のカラム追加と更新処理 楊 start
    /* modify by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Record all ordMainIds, As the parameter of method updpatinandapprove(), Change from single insert to batch insert */
    this.updPatIndApprove(ordMainIdList);
    // add FNSI-最終更新指示者のカラム追加と更新処理 楊 end

    // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 start
    /* modify by chamaojia 2023-03-22 [6961] ループから移動し、一括アクションに変更 --start */
    // 医療材料削除の場合
//    ordMain.forEach(item -> {
//      ordMainResource.updateOrdChecklistByAction(
//        OrdMainResource.OrdMainActionForChecklist.TREATPLAN_EQUIPMENT_DELETE,
//        Long.parseLong(item.getOrdNo().toString())
//      );
//    });
    //mod 9324 医療材料削除コールord_checklist共通 gjn start
    //ordMainResource.updateOrdChecklistByActionToList(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_EQUIPMENT_DELETE, ordNoList);
    ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_EQUIPMENT_DELETE, ordNoList);
    //mod 9324 医療材料削除コールord_checklist共通 gjn end

    /* modify by chamaojia 2023-03-22 [6961] ループから移動し、一括アクションに変更 --end */
    // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 end

    //指示履歴を登録
    /**
     * modify by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: First determine whether Mongo is necessary to avoid unnecessary object creation
     */
    if(indHistoryMakeService.isToMongo()){
      //mod FNSI-9355 ljx start
      //indHistoryMakeService.createEquipmentHistory(bodyData, "3", weeksArry, ordMain);
      indHistoryMakeService.createEquipmentHistory(bodyData, "3", weeksArry, oldOrdMain);
      //mod FNSI-9355 ljx end
    }

    // 終了日が未設定の場合、患者治療パターンの項目削除処理
    if ("false".equals(bodyData.getIs_deadline())) {
      PatTreatmentPatternUtils.IND_ITEM ITEM = PatTreatmentPatternUtils.IND_ITEM.EQUIP;
      PatTreatmentPatternUtils.PatTreatmentPatternEditData editData = new PatTreatmentPatternUtils.PatTreatmentPatternEditData();
      List<String> equipInfo = new ArrayList<String>();
      // 医療材料をString型のListに格納
      equipInfo.add(bodyData.getInd_info());
      // 患者治療パターン編集データの格納
      editData.setIndEquipInfo(equipInfo.toString());
      // 患者治療パターン項目削除処理
      int patPatternCount = patTreatmentPatternUtils.deletePatTreatmentPatternIndItemForIndMediAndEquip(
        Long.parseLong(bodyData.getPat_id()),
        bodyData.getFacility_cd(),
        ordMainResource.getValueList(bodyData.getInd_treatment_cd()),
        ordMainResource.getLongList(bodyData.getInd_kur_cd()),
        weeksArry,
        ITEM,
        Timestamp.valueOf(update),
        editData
      );
    }

    //del #10412 次患者更新関連全体見直し対応 朴 start
//    String facilityCd = bodyData.getFacility_cd();
//    Long skipCode = Long.parseLong("0");
//    // 次患者更新処理
//    for (OrdMain ord : ordMain) {
//      Long bedCd = Long.parseLong(ord.getIndBedCd().toString());
//      Long targetOrdNo = ord.getOrdNo();
//      // 登録されているベッド(ベッド移動なしのため変更後として処理※変更前は条件送信キャンセルとして処理されるため)
//      /* mod #5482 by zhangruixue 2023-03-02 スケジュール --start */
////      ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, targetOrdNo, true, update);
//      ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, ord, true, update);
//      /* mod #5482 by zhangruixue 2023-03-02 スケジュール --end */
//    }
    //del #10412 次患者更新関連全体見直し対応 朴 end

    if (bodyData.getHosp_pat_id() == null || "".equals(bodyData.getHosp_pat_id())) {
      JournalCreateRequestResponse response = new JournalCreateRequestResponse();
      response.setResponse(ResponseEntity.ok().build());
      response.setCtlNoList(ctlNoList);
      return response;
    }
    List<Integer> treatCdList = ordMain.stream().map(OrdMain::getIndTreatmentCd).distinct().collect(Collectors.toList());
    List<MstTreatment> mstTreatList = treatCdList.stream().map(treatCd -> mstTreatmentDao.selectByCd(treatCd)).collect(Collectors.toList());
    for (MstTreatment mstTreat : mstTreatList) {
      List<OrdMain> ordMainList = ordMain.stream()
        .filter(o -> o.getIndTreatmentCd().equals(mstTreat.getTreatmentCd())).collect(Collectors.toList());
      //7771-------------------------------ljg start
      /* Commented by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: To move this update above ( search move7734 above ) */
//      //7734 指示者変更の場合 lig stsrt
//      ordMainList.stream()
//        .forEach(item -> {
//          String indScheduleUserInfo  = item.getIndScheduleUserInfo();
//          JSONObject indScheduleUserInfoJObj = new JSONObject(indScheduleUserInfo);
//          JSONObject bodyDataIndinfoObj = new JSONObject(bodyData.getInd_info());
//          //中止画面からの指示者が元々の指示者と不一致の場合、指示者が変更することにする。
//          if(!bodyDataIndinfoObj.get("ind_user_id").toString().equals((indScheduleUserInfoJObj.get("ind_user_id")).toString())){
//            //ind_user_id（指示者）の値を変更。
//            indScheduleUserInfoJObj.put("ind_user_id",Long.valueOf((bodyDataIndinfoObj.get("ind_user_id")).toString()));
//            if((bodyDataIndinfoObj.get("ind_user_first_name")).toString()!=null &&
//              ! "" .equals((bodyDataIndinfoObj.get("ind_user_first_name")).toString())){
//              indScheduleUserInfoJObj.put("ind_user_last_name",(bodyDataIndinfoObj.get("ind_user_last_name")).toString());
//            }
//            if((bodyDataIndinfoObj.get("ind_user_first_name")).toString()!=null &&
//              ! "" .equals((bodyDataIndinfoObj.get("ind_user_first_name")).toString())
//            ){
//              indScheduleUserInfoJObj.put("ind_user_first_name",(bodyDataIndinfoObj.get("ind_user_first_name")).toString());
//            }
////            indScheduleUserInfoJObj.put("ind_user_last_name",(bodyDataIndinfoObj.get("ind_user_last_name")).toString());
////            indScheduleUserInfoJObj.put("ind_user_first_name",(bodyDataIndinfoObj.get("ind_user_first_name")).toString());
//            indScheduleUserInfo = indScheduleUserInfoJObj.toString();
//            //指示者が変更されたのデータを更新する。
//            if(item.getOrdNo() !=null && !"".equals(item.getOrdNo())){
//              ordMainDao.updateInduser(Long.valueOf(item.getOrdNo()),indScheduleUserInfo);
//            }
//          }
//        });
//      //7734 指示者変更の場合 lig end
      if (ordMainList.size()>0) {
        //7771-------------------------------ljg end
        // オペコードを設定する
        String opeCd = "004028";
        // mod 2023-01-14 bug #7627 修正 chen start
        // JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
        // // SysCoopJournal journalCreateRequestPayload = new SysCoopJournal();
        // JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
        // journalCreateRequestPayload.setFacilityCd(bodyData.getFacility_cd());
        // journalCreateRequestPayload.setCrud("U");
        // journalCreateRequestPayload.setHospPatId(bodyData.getHosp_pat_id());
        // journalCreateRequestPayload.setPatId(Long.valueOf(bodyData.getPat_id()));
        // journalCreateRequestPayload.setUserId(Long.valueOf(bodyData.getUser_id()));
        // journalCreateRequestPayload.setOpeCd(opeCd);
        // asyncService.sendExternalConnection(ordMainList, journalCreateRequestPayload);
        // List<Long> ctlNoList = new ArrayList<>();
        // del #11004 連携イベント発生部分不正 piao start
        // int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(bodyData.getFacility_cd());
        // del #11004 連携イベント発生部分不正 piao end
        for (OrdMain ord : ordMainList) {
            if(ord.getIndKurCd() == null || ord.getIndKurCd().equals(0)){
                opeCd = "004228";
              }else {
                opeCd = "004028";
              }
          // del #11004 連携イベント発生部分不正 piao start
          // if (modify_send_class == 2) {
          //   JournalCreateRequestPayload deljournalCreateRequestPayload = new JournalCreateRequestPayload();
          //   deljournalCreateRequestPayload.setFacilityCd(bodyData.getFacility_cd());
          //   deljournalCreateRequestPayload.setCrud("D");
          //   deljournalCreateRequestPayload.setHospPatId(bodyData.getHosp_pat_id());
          //   deljournalCreateRequestPayload.setPatId(Long.valueOf(bodyData.getPat_id()));
          //   deljournalCreateRequestPayload.setUserId(Long.valueOf(bodyData.getUser_id()));
          //   deljournalCreateRequestPayload.setOpeCd(opeCd);
          //   deljournalCreateRequestPayload.setOrdNo(ord.getOrdNo());
          //   deljournalCreateRequestPayload.setBaseDate(ord.getTreatDate());
          //   ctlNoList.add(deljournalCreateRequestPayload);
          // }
          // del #11004 連携イベント発生部分不正 piao end
          JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
          journalCreateRequestPayload.setFacilityCd(bodyData.getFacility_cd());
          journalCreateRequestPayload.setCrud("U");
          // del #11004 連携イベント発生部分不正 piao start
          // if (modify_send_class == 2) {
          //   journalCreateRequestPayload.setCrud("C");
          // }
          // del #11004 連携イベント発生部分不正 piao end
          journalCreateRequestPayload.setHospPatId(bodyData.getHosp_pat_id());
          journalCreateRequestPayload.setPatId(Long.valueOf(bodyData.getPat_id()));
          journalCreateRequestPayload.setUserId(Long.valueOf(bodyData.getUser_id()));
          journalCreateRequestPayload.setOpeCd(opeCd);
          journalCreateRequestPayload.setOrdNo(ord.getOrdNo());
          journalCreateRequestPayload.setBaseDate(ord.getTreatDate());
          // journalCreateRequestPayload.setCtlNo(sysCoopJournalDao.selectNextSeqCtlNo());
          // sysCoopJournalDao.insert(journalCreateRequestPayload);
          // ctlNoList.add(journalCreateRequestPayload.getCtlNo());
          ctlNoList.add(journalCreateRequestPayload);
        }
        // mod 2023-01-14 bug #7627 修正 chen end
      }
    }
    JournalCreateRequestResponse response = new JournalCreateRequestResponse();
    response.setResponse(ResponseEntity.ok().build());

    //add #10412 次患者更新関連全体見直し対応 朴 start
    response.setDoCallNextPatOrdMainList(beforeOrdMainList);
    //add #10412 次患者更新関連全体見直し対応 朴 end

    response.setCtlNoList(ctlNoList);
    return response;
  }

  @Transactional
  @Override
  //mod 7213 2023-03-25 治療途中に追加した薬剤の投与タイミング通知が装置に表示されない 張 start
//public JournalCreateRequestResponse createOrdMainMediInfoBatch(List<ApiEntityOrdMain.ValiOrdMedi> bodyDataList) {
  public JournalCreatecallNextPatIdRequestResponse createOrdMainMediInfoBatch(List<ApiEntityOrdMain.ValiOrdMedi> bodyDataList) {
    //mod #10412 次患者更新関連全体見直し対応 朴 start
    List<OrdMain> nextPatList=new ArrayList<>();
    //mod #10412 次患者更新関連全体見直し対応 朴 end

    ApiEntityOrdMain.ValiOrdMedi firstBodyData = bodyDataList.get(0);
    //add FNSI-redmine 4404 劉祥霖 start
    //システム時間を取得
    SimpleDateFormat ymd = new SimpleDateFormat("yyyyMMdd");
    String sysDate = ymd.format(new Date());
    SimpleDateFormat hm = new SimpleDateFormat("HHmm");
    String sysTimehm = hm.format(new Date());
    int sysTimeh = Integer.parseInt(sysTimehm.substring(0, 2));
    int sysTimem = Integer.parseInt(sysTimehm.substring(2));
    int sysTimeMin = sysTimeh * 60 + sysTimem;
    //add FNSI-redmine 4404 劉祥霖 end
    // 選択された日付+曜日の処理
    String startDate = firstBodyData.getStart_date().replaceAll("-", "");
    String endDate = firstBodyData.getEnd_date().replaceAll("-", "");
    String facilityCd = firstBodyData.getFacility_cd();
    String patId = firstBodyData.getPat_id();
    JSONArray ordDatesJson = new JSONArray(firstBodyData.getInd_dates().toString());
    // 投与間隔によって編集対象となる日付のリスト
    Map<String,String> ordDatesMap = new HashMap<>();
    //List<String> ordDates = new ArrayList<String>();
    for (int i = 0; i < ordDatesJson.length(); i++) {
      //ordDates.add(ordDatesJson.getString(i));
      String date = ordDatesJson.getString(i);
      ordDatesMap.put(date,date);
    }
    List<Integer> weeksArray = IndicationUtils.getWeekPattern(firstBodyData.getWeeks());
    String ind_user_id = null;
    String upd_user_id = null;
    List<OrdMain> ordMain = new ArrayList<>();
    List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
    try {
      // 更新対象ordNo List取得
      ordMain = ordMainDao.selectUpdateTarget(
        Long.parseLong(firstBodyData.getPat_id()),
        firstBodyData.getFacility_cd(),
        startDate,
        endDate,
        weeksArray,
        ordMainResource.getValueList(firstBodyData.getInd_treatment_cd()),
        ordMainResource.getLongList(firstBodyData.getInd_kur_cd()),
        null
      );
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }

    //add #10266 start
    if("2".equals(firstBodyData.getUpdate_flag())){
      ordMain = ordMain.stream().filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
    }
    //add #10266 end

    JSONObject responseData = new JSONObject("{}");
    if(ordMain.isEmpty()){
      JournalCreatecallNextPatIdRequestResponse response = new JournalCreatecallNextPatIdRequestResponse();
      response.setResponse(new ResponseEntity<>(responseData.toString(), (org.springframework.http.HttpHeaders) null, HttpStatus.OK));
      response.setCtlNoList(ctlNoList);
      response.setCallNextPatList(nextPatList);
      return response;
    }

//    //add #10266 start
//    if("2".equals(firstBodyData.getUpdate_flag())){
//      ordMain = ordMain.stream().filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
//    }
//    //add #10266 end

    //add #10412 次患者更新関連全体見直し対応 朴 start
    nextPatList = ordMain.stream().map(SerializationUtils::clone).collect(Collectors.toList());
    //add #10412 次患者更新関連全体見直し対応 朴 end

    // add FNSI-FutreNetWeb+SI課題管理No.5686 李 start
//    Boolean logUpdateFlg = true;
//    Long logOrdNo = null;
//    if (null != ordMain && ordMain.size() > 31) {
//      logOrdNo = ordMain.get(32).getOrdNo();
//    }
    // add FNSI-FutreNetWeb+SI課題管理No.5686 李 end

    // 投与回数用カウンター
//    int count = 0;
    // 投与回数
    // mod FNSI-新規登録処理エラー修正 楊 start
//    Integer countMax = bodyData.getCount_after() == null ? null : Integer.parseInt(bodyData.getCount_after());
//    Integer countMax = StringUtils.isEmpty(firstBodyData.getCount_after()) ? null : Integer.parseInt(firstBodyData.getCount_after());
    // mod FNSI-新規登録処理エラー修正 楊 end

    Map<String, CountVO> countMaxMap = new HashMap<>();// Map<mediCd,CountVO>
    List<Integer> editMedicateCdList = new ArrayList<>(); // Record the Medicate code to be edited
    //add by ShiHongda 2023-02-14 [BUG] --start /
    List<Integer> editMedicateCdListTz = new ArrayList<>();
    List<Integer> editMedicateCdListTc = new ArrayList<>();
    //add by ShiHongda 2023-02-14 [BUG] --end /
    for (ApiEntityOrdMain.ValiOrdMedi bodyData : bodyDataList) {
      JSONObject editMediJson = new JSONObject(bodyData.getInd_info());// 編集内容
      String mediCd = StrUtils.getStrFromJSONObject(editMediJson,"cd"); // code
      //add by ShiHongda 2023-02-14 [BUG] --start /
      String medicine_type = StrUtils.getStrFromJSONObject(editMediJson,"medicine_type"); // medicine_type
      if("1".equals(medicine_type)){
        editMedicateCdListTc.add(Integer.parseInt(mediCd));
      }else if("2".equals(medicine_type)){
        editMedicateCdListTz.add(Integer.parseInt(mediCd));
      }
      //add by ShiHongda 2023-02-14 [BUG] --end /
      editMedicateCdList.add(Integer.parseInt(mediCd));
      if(!StringUtils.isEmpty(bodyData.getCount_after())){
        countMaxMap.put(mediCd,new CountVO(Integer.parseInt(bodyData.getCount_after())));
      }
    }
    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Cache the master data to avoid repeated read from database --start */
    MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
    /* modify by chamaojia 2024-01-22 [10196]  Cache error, different data types need to be separated --start */
    masterCacheHandler.loadMstMedicateMap(editMedicateCdListTc);  // 薬剤
    masterCacheHandler.loadMstMedicineMixMap(editMedicateCdListTz);  // 調製薬剤
    /* modify by chamaojia 2024-01-22 [10196]  Cache error, different data types need to be separated --end */
    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Cache the master data to avoid repeated read from database --end */

    long s = System.currentTimeMillis();
    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Store a copy of the data before editing to Mongo, alternative method: getHistory(ord_no) in method updateOrdMainEquipInfo(), And Optimized for batch insertion --start */
    List<Long> ordNoListForMongoLog = ordMain.stream().filter(o -> ordDatesMap.containsKey(o.getTreatDate())).map(ordMain1 -> ordMain1.getOrdNo()).collect(Collectors.toList());
    selectHistoryUtils.insertMangoDbHistoryBatch(ordNoListForMongoLog);
    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Store a copy of the data before editing to Mongo, alternative method: getHistory(ord_no) in method updateOrdMainEquipInfo(), And Optimized for batch insertion --end */
    PatPersonalMain patPersonalMain = null;

    int editedOrdMainSize = 0;

    // 更新日時の取得
    LocalDateTime update = LocalDateTime.now();

    // シーケンス番号
    // mod FNSI-投薬最新識別番号の設定 李 start
    // long indMediInfoNo = indMediInfoNo == 0 ? ordMainService.selectMaxIndMediInfoNo() : indMediInfoNo;
    // 投薬最新識別番号の設定
    long indMediInfoNoPatId = ordMainService.selectMaxMediInfoNo(facilityCd, patId);
    // mod #8047 2022/10/31 薬剤セットで追加した後に追加した薬剤を選択すると異なる薬剤が表示される dou start
    long indMediInfoNo = indMediInfoNoPatId;
    long updateNo = indMediInfoNoPatId;
    // 投与薬剤をString型のListに格納
    List<String> mediInfo = new ArrayList<>();
    // mod #8047 2022/10/31 薬剤セットで追加した後に追加した薬剤を選択すると異なる薬剤が表示される dou end
    // mod FNSI-投薬最新識別番号の設定 李 end
    Map<String,Long> mediInfoNoMap = new HashMap<>(); // used to record the No of each MediInfo

    /* add by chamaojia 2023-03-21 [6961] 次の一括アクションの準備のための新規コレクション・ストレージ・データ --start */
    // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<OrdMaterialSave> ordMaterialSaveList = new ArrayList<>();
//    List<DeleteByConditionsAllDTO> deleteByConditionsAllDTOList = new ArrayList<>();
    // del 12250 ord_material_saveの処理を2回重複実行している zkm end
    List<UpdateOrdMainMediInfoDTO> mediInfoEntityList = new ArrayList<>();
    /* add by chamaojia 2023-03-21 [6961] 次の一括アクションの準備のための新規コレクション・ストレージ・データ --end */
    //add #10196 Ord_Material_Save operation 20240126 zt start
    // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new ArrayList<>();
    // del 12250 ord_material_saveの処理を2回重複実行している zkm end
    //mod #10196 Ord_Material_Save operation 20240126 zt end
    for (OrdMain ord : ordMain) {
      // 編集対象日付リストに更新中ordMainが存在してるかどうかをチェック
      if(!ordDatesMap.containsKey(ord.getTreatDate())){
        continue;
      }
      editedOrdMainSize ++ ;
      Map<String, Object> namesMap = null;
      boolean isUpdatedRstMediInfo = false;
      long mediInfoNo = indMediInfoNo;
      JSONObject editMediJson = null;
      //add #11841 【たくしん会】ord_mainの登録不正 zrx start
      if(Objects.equals("0", ord.getRstDialysisState())) {
        ord = ordMainService.delJSONKey(ord);
      }
      //add #11841 【たくしん会】ord_mainの登録不正 zrx end
      for (ApiEntityOrdMain.ValiOrdMedi bodyData : bodyDataList) {
        /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
        //JSONArray indMediJsonArr = new JSONArray(ord.getIndMediInfo());
        JSONArray indMediJsonArr = new JSONArray(ObjectUtils.isEmpty(ord.getIndMediInfo())? "[]" : ord.getIndMediInfo());
        /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */

        editMediJson = new JSONObject(bodyData.getInd_info());// 編集するind_medi_info(単位付/名称無し)
        // modify 11323 by kangjie 202041203 start pat _ treatment _ patternテーブル翻訳upd _ user _ name
        upd_user_id = StrUtils.getStrFromJSONObject(editMediJson,"upd_user_id");
        /* add by chamaojia 2024-01-22 [10196]  The updated name needs to be translated --start */
        if (!"".equals(upd_user_id)) {
          MstPersonalUser updMstPersonalUser = masterCacheHandler.getMstPersonalUser(Long.valueOf(upd_user_id));
          if (updMstPersonalUser != null) {
            editMediJson.put("upd_user_last_name", updMstPersonalUser.getUserLastName());
            editMediJson.put("upd_user_first_name", updMstPersonalUser.getUserFirstName());
          }
        }
        /* add by chamaojia 2024-01-22 [10196]  The updated name needs to be translated --end */
        // modify 11323 by kangjie 202041203 end
        // add #8047 2022/10/31 薬剤セットで追加した後に追加した薬剤を選択すると異なる薬剤が表示される dou start
        if ("false".equals(bodyData.getIs_deadline())) {
          // 投与薬剤情報を格納
          editMediJson.put("no", mediInfoNo);
          // add #11298 by kangjie 20241129 start チェックリストでデータが表示しない・フリーズする
          editMediJson.remove("isAmountchg");
          // add #11298 by kangjie 20241129 end
          mediInfo.add(editMediJson.toString());
        }
        // add #8047 2022/10/31 薬剤セットで追加した後に追加した薬剤を選択すると異なる薬剤が表示される dou end
        ind_user_id = StrUtils.getStrFromJSONObject(editMediJson,"ind_user_id");
        String mediCd = StrUtils.getStrFromJSONObject(editMediJson,"cd");
        // 投与回数を満たすと処理を終了
        if(countMaxMap.containsKey(mediCd)){
          CountVO countVO = countMaxMap.get(mediCd);
          //if (countMax != null && count >= countMax) {
          if(countVO != null && countVO.isReachedMax()){
//            mod 8177 投与薬剤編集画面で１回の保存内で同一の薬剤の指示が登録できない 張 start
//            continue;
//            mod 8177 投与薬剤編集画面で１回の保存内で同一の薬剤の指示が登録できない 張 end
          }
          // 投与回数 ++
          countVO.addCount();
        }

        // mod FNSI-redmine 4404 劉祥霖　start
        String medicateTimingCd = StrUtils.getStrFromJSONObject(editMediJson,"timing_cd");
        //投与タイミングを数値に変更します
        MstMedicateTiming mediTiming = null;
        if (medicateTimingCd != null && medicateTimingCd != "null" && medicateTimingCd != "") {
          int mtcd = Integer.parseInt(medicateTimingCd);
          //投与タイミングのデータを取得
          //mediTiming = mstMedicateTimingDao.selectByCd(bodyData.getFacility_cd(), mtcd);
          mediTiming = masterCacheHandler.getMstMedicateTimingByCd(mtcd);
        }
        // mod FNSI-redmine 4404 劉祥霖　end

        // 治療状況
        String rstDialysisState = ord.getRstDialysisState();

        // add FNSI-小数点の修正 楊 start
        // 数量未変更の場合、そのまま設定
        editMediJson.remove("isAmountchg");
        // add FNSI-小数点の修正 楊 end

        // シーケンス番号をリユース
        editMediJson.put("no", mediInfoNo);
        mediInfoNoMap.put(mediCd,mediInfoNo);
        mediInfoNo++;
        // add 2022/11/21 dou start
        updateNo = mediInfoNo;
        // add 2022/11/21 dou end
        /* del by chamaojia 2024-01-22 [10196]  'unit' does not need to be processed here --start */
//        String unit = null;
//
//        // 単位情報は条件送信前のみ未セット / 単位無しの場合はnullデータが来ており、getStringでエラーになる為除外
//        if (AdminWebConstant.OrdMainConst.DialysisState.BEFORE_SEND.equals(rstDialysisState) && ! editMediJson.isNull("unit")) {
//          unit = editMediJson.getString("unit");
//          //del 9582 ljx start
//          //add 5734薬剤・医材マスタの修正による透析情報の反映について 張 start
////          editMediJson.put("unit", unit);
////        } else {
//          //add 5734薬剤・医材マスタの修正による透析情報の反映について 張 end
//          //del 9582 ljx end
//          editMediJson.put("unit", JSONObject.NULL);
//        }
        /* del by chamaojia 2024-01-22 [10196]  'unit' does not need to be processed here --end */

        // 治療未実施以外の場合、変更内容を実績にも反映する
        String rstMediInfo = null;
        // mod FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
        String isRstUpdate = bodyData.getIs_rst_update();
        //if (OrdMainConst.DialysisState.BEFORE_SEND.equals(rstDialysisState)) {
        /* modify by chamaojia 2024-01-22 [10196]  Add missing logic（実績データへの反映をしますか？->Cancel） --start */
        if (AdminWebConstant.OrdMainConst.DialysisState.BEFORE_SEND.equals(rstDialysisState)) {
          indMediJsonArr.put(editMediJson);
          // mod FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
          rstMediInfo = ord.getRstMediInfo();
        } else {
          //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240913 start
          JSONObject rstMediJson = this.getMediDeployInfo(Long.valueOf(bodyData.getPat_id()), bodyData.getFacility_cd(), editMediJson, masterCacheHandler);
          //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240913 end
          indMediJsonArr.put(editMediJson);
          if ("false".equals(isRstUpdate)) {
            rstMediInfo = ord.getRstMediInfo();
          } else {
            JSONArray rstMediInfoArr = new JSONArray(ord.getRstMediInfo() == null ? "[]" : ord.getRstMediInfo());
            // mod FNSI-FutreNetWeb+SI課題管理No.4742 李 start
            // rstMediInfo = this.createRstInfo(indMediJsonArr, rstMediInfoArr, "no", rstMediJson).toString();
            rstMediInfo = this.createRstInfo(indMediJsonArr, rstMediInfoArr, "0","no", rstMediJson, rstDialysisState,masterCacheHandler).toString();
            // mod FNSI-FutreNetWeb+SI課題管理No.4742 李 end
            isUpdatedRstMediInfo = true;
          }
        }
        // 更新中ordMainの指示投与薬剤
        ord.setIndMediInfo(indMediJsonArr.toString());
        /* modify by chamaojia 2024-01-22 [10196]  Add missing logic（実績データへの反映をしますか？->Cancel） --end */
        // 更新中ordMainの实际投与薬剤
        ord.setRstMediInfo(rstMediInfo);

        // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.90(外結)対応 韓 start
        if (ord.getTreatDate().equals(sysDate)){
          //mod FNSI-redmine5640 劉祥霖 start
          String effectFlg = "0";
          String no = editMediJson.get("no").toString();
          if (rstMediInfo != null) {
            JSONArray rstMediInfoStr = new JSONArray(rstMediInfo);
            for (int k = 0; k < rstMediInfoStr.length(); k++) {
              JSONObject rstMed = rstMediInfoStr.getJSONObject(k);
              if (rstMed.get("no").toString().equals(no)) {
                effectFlg = rstMed.get("effect_flg").toString();
              }
            }
          }
          if (isRstUpdate.equals("true") && rstDialysisState.equals("3") && effectFlg.equals("0")) {
            // mod FNSI-redmine 4404 劉祥霖　start
            //日付判定+投与タイミングが選択された判定
            //mod FutreNetWeb+SI課題管理 no.5978 劉全航 start
//            if(date.equals(sysDate)&&!medicateTimingCd.equals(null)){
            if (! medicateTimingCd.equals("null")) {
              //mod FutreNetWeb+SI課題管理 no.5978 劉全航 end
              //データはあるの判定
              if (mediTiming != null) {
                //投与タイミングの時間を取得
                // mod 11455 投与タイミングマスタ>治療開始後通知時間にNULLが設定出来る zkm start
//                int AlertTime = mediTiming.getAlertTime();
                int AlertTime = Objects.isNull(mediTiming.getAlertTime()) ? 0 : mediTiming.getAlertTime();
                // mod 11455 投与タイミングマスタ>治療開始後通知時間にNULLが設定出来る zkm end
                //治療開始時間を取得
                String treatStartTime = ord.getIndTreatStartTime();
                int treatStartTimeH = Integer.parseInt(treatStartTime.substring(0, 2));
                int treatStartTimeM = Integer.parseInt(treatStartTime.substring(2));
                int treatStartTimeMin = treatStartTimeH * 60 + treatStartTimeM;

                //システム時間＞＝治療開始時間+投与タイミングの時間
                if (sysTimeMin >= (treatStartTimeMin + AlertTime)) {
                  if(patPersonalMain == null){
                    patPersonalMain = patPersonalMainDao.selectById(Long.parseLong(patId));
                  }
                  if(namesMap == null){
                    // 通知メッセージ及び付加情報の変換用JSONデータを作成(値は文字列型)
                    // [BEDNAME]：[LASTNAME] [FIRSTNAME]さん に [MEDICINENAME] を投与する時間になりました。
                    // {"FUNC": "006", "ORDNO": "[ORDNO]", "PATID": "[PATID]", "FACILITYCD": "[FACILITYCD]"}
                    namesMap = dBAppWebAPIDao.selectNameDataFromVariousTbl(ord.getOrdNo());
                  }
                  this.registMedicalNotify(editMediJson, patId,facilityCd, ord.getOrdNo(),namesMap,patPersonalMain,masterCacheHandler);
                }
              }
            }
            // mod FNSI-redmine 4404 劉祥霖　end
          }
          //mod FNSI-redmine5640 劉祥霖 end
        }
        // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.90(外結)対応 韓 end
      } // end  bodyDataList.forEach

      //add #10196 Ord_Material_Save operation 20240126 zt start
      if (Objects.isNull(ord.getFacilityCd())) ord.setFacilityCd(facilityCd);
      if (Objects.isNull(ord.getPatId())) ord.setPatId(Long.parseLong(patId));
      //mod #10196 Ord_Material_Save operation 20240126 zt end

      /* del by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
/* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Move code block here ( search move7734 )  start */
//      JSONObject indScheduleUserInfoJObj = new JSONObject(ord.getIndScheduleUserInfo());
//      //中止画面からの指示者が元々の指示者と不一致の場合、指示者が変更することにする。
//      String edit_ind_user_id = StrUtils.getStrFromJSONObject(editMediJson,"ind_user_id");
//      String ind_schedule_ind_user_id = StrUtils.getStrFromJSONObject(indScheduleUserInfoJObj,"ind_user_id");
//      if(!edit_ind_user_id.equals(ind_schedule_ind_user_id)) {
//        //ind_user_id（指示者）の値を変更。
//        indScheduleUserInfoJObj.put("ind_user_id", Long.valueOf(edit_ind_user_id));
//        String edit_ind_user_first_name = StrUtils.getStrFromJSONObject(editMediJson,"ind_user_first_name");
//        if (!StringUtils.isEmpty(edit_ind_user_first_name)) {
//          indScheduleUserInfoJObj.put("ind_user_first_name", edit_ind_user_first_name);
//        }
//        String edit_ind_user_last_name = StrUtils.getStrFromJSONObject(editMediJson,"ind_user_last_name");
//        if (!StringUtils.isEmpty(edit_ind_user_last_name)) {
//          indScheduleUserInfoJObj.put("ind_user_last_name", edit_ind_user_last_name);
//        }
//        ord.setIndScheduleUserInfo(indScheduleUserInfoJObj.toString());
//      }
/* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Move code block here ( search move7734 )  end */
      /* del by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */

//      try {

/* modify by shyw 2022-08-26 [FNSI-6961] for Performance Optimization  --start */
        // mod FNSI-FutreNetWeb+SI課題管理No.5686 李 start
        // ordMainService.updateOrdMainMediInfo(
        // ord.getOrdNo(),
        // mediJsonArr.toString(),
        // rstMediInfo
        // );
        //if (logUpdateFlg && null != logOrdNo && ord.getOrdNo().longValue() == logOrdNo.longValue()) {
        //  logUpdateFlg = false;
        //}
        /**
         * Update the following fields according to ord.getOrdNo():
         *        ord.getIndMediInfo(),
         *        ord.getRstMediInfo(),
         *        ord.getIndScheduleUserInfo(),
         *        upIndUseId,
         *        upUseId
         */
//        updateOrdMainMediInfo(ord,Long.valueOf(ind_user_id),Long.valueOf(upd_user_id));
        /* add by chamaojia 2023-03-21 [6961] 次の一括アクションに備えてデータを整理する --start */
        UpdateOrdMainMediInfoDTO mediInfoEntity = new UpdateOrdMainMediInfoDTO();
        mediInfoEntity.setOrdMain(ord);
        mediInfoEntity.setUpIndUseId(Long.valueOf(ind_user_id));
        mediInfoEntity.setUpUseId(Long.valueOf(upd_user_id));
        mediInfoEntityList.add(mediInfoEntity);
        /* add by chamaojia 2023-03-21 [6961] 次の一括アクションに備えてデータを整理する --end */
        // mod FNSI-FutreNetWeb+SI課題管理No.5686 李 end
/* modify by shyw 2022-08-26 [FNSI-6961] for Performance Optimization  --end */

/* modify by shyw 2022-08-26 [FNSI-6961] for Performance Optimization：Optimize the logic of updating the table ord_material_save  --start */
        // delete the ordMaterialSave of 1:指示、2:実績区分 ---start
//        ApiEntityOrdMain.ValiOrdMaterialSave conditions = new ApiEntityOrdMain.ValiOrdMaterialSave();
        // 施設コード
//        conditions.setFacility_cd(facilityCd);
//        // 患者ID
//        conditions.setPat_id(patId);
//        // データ基準日
//        conditions.setBase_date(ord.getTreatDate());
//        // データ基準番号
//        conditions.setSupplies_base_no(ord.getOrdNo().toString());
//        // データ発生元区分List(1：投与薬剤)
//        conditions.setSupplies_source_class("1");
//        // 物品区分  12：投与薬剤    13：調整薬剤
//        List<String> suppliesClass = Arrays.asList("12","13");
//        conditions.setSupplies_class_list(suppliesClass);
//        // 1:指示、2:実績
//        List<String> indRstClassList = null;
//        if(isUpdatedRstMediInfo){
//          indRstClassList = Arrays.asList("1","2");
//        }else {
//          indRstClassList = Arrays.asList("1");
//        }
//        conditions.setIndRstClassList(indRstClassList);

        // 投与薬剤コード
//        List<String> suppliesCdList = editMedicateCdList.stream().map(o -> o.toString()).collect(Collectors.toList());
//        //add by ShiHongda 2023-02-14 [BUG] --start /
//        List<String> suppliesCdListTc = editMedicateCdListTc.stream().map(o -> o.toString()).collect(Collectors.toList());
//        List<String> medicineMixCdListTj = editMedicateCdListTz.stream().map(o -> o.toString()).collect(Collectors.toList());
//        if(suppliesCdListTc.size()==0){
//          suppliesCdListTc.add("-1");
//        }
//        if(medicineMixCdListTj.size()==0){
//          medicineMixCdListTj.add("-1");
//        }else{
//          suppliesClass = Arrays.asList("12","13","20");
//        }
        /* modify by chamaojia 2023-03-21 [6961] データの整理、次の操作の準備、実行順序の維持 --start */
        // 条件に基づいてデータを削除する 根据条件删除数据
//        int delCount = ordMaterialSaveDao.deleteByConditionsAll(
//                conditions.getFacility_cd(),
//                conditions.getPat_id(),
//                conditions.getSupplies_base_no(),
//                conditions.getBase_date(),
//                conditions.getSupplies_source_class(),
//                suppliesClass,
//                indRstClassList,
//                suppliesCdListTc,
//                medicineMixCdListTj
//        );
//        DeleteByConditionsAllDTO conditionsAllEntity = new DeleteByConditionsAllDTO();
//        conditionsAllEntity.setFacilityCd(conditions.getFacility_cd());
//        conditionsAllEntity.setPatId(conditions.getPat_id());
//        conditionsAllEntity.setSuppliesBaseNo(conditions.getSupplies_base_no());
//        conditionsAllEntity.setBaseDate(conditions.getBase_date());
//        conditionsAllEntity.setSuppliesSourceClass(conditions.getSupplies_source_class());
//        conditionsAllEntity.setSuppliesClass(suppliesClass);
//        conditionsAllEntity.setIndRstClassList(indRstClassList);
//        conditionsAllEntity.setSuppliesCdListTc(suppliesCdListTc);
//        conditionsAllEntity.setMedicineMixCdListTj(medicineMixCdListTj);
//        deleteByConditionsAllDTOList.add(conditionsAllEntity);
        /* modify by chamaojia 2023-03-21 [6961] データの整理、次の操作の準備、実行順序の維持 --end */
        //add by ShiHongda 2023-02-14 [BUG] --end /

        // delete the ordMaterialSave of 1:指示、2:実績区分 ---end

        // insert the ordMaterialSave of 1:指示 ---start
        // 計算材料保持テーブル投与薬剤情報値の設定
//        JSONArray ordIndMediArr = new JSONArray(ord.getIndMediInfo());
        //this.indEquipValueSetting(conditions, mediJsonArr);
        /* modify by chamaojia 2023-03-21 [6961] 一括処理をループ外に移動 --start */
//        List<OrdMaterialSave> ordMaterialSaveList1 = this.createMediOrdMaterialSaveObj("1",conditions, ordIndMediArr,editMedicateCdList,masterCacheHandler);
//        if (ordMaterialSaveList1 != null && ordMaterialSaveList1.size() > 0) {
//          ordMaterialSaveList.addAll(ordMaterialSaveList1);
//        }
        // insert the ordMaterialSave of 1:指示 ---end

        // insert the ordMaterialSave of 2:実績 ---start
//        if(isUpdatedRstMediInfo){
//          JSONArray ordRstEquipArr = new JSONArray(ord.getRstEquipInfo());
//          List<OrdMaterialSave> ordMaterialSaveList2 = this.createMediOrdMaterialSaveObj("2",conditions, ordRstEquipArr,editMedicateCdList,masterCacheHandler);
////          ordMaterialSaveList1.addAll(ordMaterialSaveList2);
//          if (ordMaterialSaveList2 != null && ordMaterialSaveList2.size() > 0) {
//            ordMaterialSaveList.addAll(ordMaterialSaveList2);
//          }
//        }
        // insert the ordMaterialSave of 2:実績 ---end
//        if(!ordMaterialSaveList1.isEmpty()){
//          ordMaterialSaveDao.insertBatch(ordMaterialSaveList1);
//        }
        /* modify by chamaojia 2023-03-21 [6961] 一括処理をループ外に移動 --end */
/* modify by shyw 2022-08-26 [FNSI-6961] for Performance Optimization：Optimize the logic of updating the table ord_material_save  --end */

/* commented out by shyw 2022-08-26 [FNSI-6961] for Performance Optimization: upIndUseId and upUseId have been updated above --start */
        // add FNSI-最終更新指示者のカラム追加と更新処理 楊 start
        // 最終更新指示者のカラム追加と更新処理
        //List<Long> ordMainCdList = new ArrayList();
        //ordMainCdList.add(ord.getOrdNo());
        //this.updUpUseId(ordMainCdList, Long.valueOf(String.valueOf(editMediJson.get("ind_user_id"))), Long.valueOf(String.valueOf(editMediJson.get("upd_user_id"))));
        // add FNSI-最終更新指示者のカラム追加と更新処理 楊 end
/* commented out by shyw 2022-08-26 [FNSI-6961] for Performance Optimization: upIndUseId and upUseId have been updated above --end */
//      } catch (Exception e) {
//        e.printStackTrace();
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage(e.getMessage());
//        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
//      }

    } // for (OrdMain ord : ordMain)  end

    /* add by chamaojia 2023-03-21 [6961] 一括処理と実行順序の維持 --start */
    //mod 9806 ljx start 投与薬剤
    //updateOrdMainMediInfoByList(mediInfoEntityList);

    boolean rst_update_flg = "true".equals(firstBodyData.getIs_rst_update());
    updateOrdMainMediInfoByList(mediInfoEntityList, rst_update_flg);
    //mod 9806 ljx end

    // Mod by zhou.tao #10196 start
//    for (DeleteByConditionsAllDTO entity : deleteByConditionsAllDTOList) {
//      ordMaterialSaveDao.deleteByConditionsAll(
//        entity.getFacilityCd(),
//        entity.getPatId(),
//        entity.getSuppliesBaseNo(),
//        entity.getBaseDate(),
//        entity.getSuppliesSourceClass(),
//        entity.getSuppliesClass(),
//        entity.getIndRstClassList(),
//        entity.getSuppliesCdListTc(),
//        entity.getMedicineMixCdListTj()
//      );
//    }
//
//    if(!ordMaterialSaveList.isEmpty()){
//      ordMaterialSaveService.insertBatch(ordMaterialSaveList);
//    }



    // Mod by zhou.tao #10196 End

    //add #10196 Ord_Material_Save operation 20240126 zt start
    // mod #12250 ord_material_saveの処理を2回重複実行している zkm start
//    ordMaterialSaveService.batchProcessingDataMod(
//      asyncMaterialSaveHandlerTask.updateOrdMaterialSaveByDiff(
//        new OrdMaterialSaveBatchHandleDTO(
//          ordMain.stream().map(OrdMain::getOrdNo).toList(),
//          ordMain,
//          OrdMaterialSaveBatchHandleDTO.getBatchModifiedMode(
//            false, true, false, false,
//            rst_update_flg ? OrdMaterialSaveDto.RST_CLASS : OrdMaterialSaveDto.IND_CLASS,
//            rst_update_flg
//          )
//        )
//      )
//    );
    if (rst_update_flg) {
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(ordMain.stream().map(OrdMain::getOrdNo).toList());
    } else {
      ordMaterialSaveService.bulkUpdateByOrdNoInMedi(ordMain.stream().map(OrdMain::getOrdNo).toList());
    }
    // mod #12250 ord_material_saveの処理を2回重複実行している zkm end
    //add #10196 Ord_Material_Save operation 20240126 zt End

    /* add by chamaojia 2023-03-21 [6961] 一括処理と実行順序の維持 --end */

    if(editedOrdMainSize == 0){
      JournalCreatecallNextPatIdRequestResponse response = new JournalCreatecallNextPatIdRequestResponse();
      response.setResponse(new ResponseEntity<>(responseData.toString(), (org.springframework.http.HttpHeaders) null, HttpStatus.OK));
      response.setCtlNoList(ctlNoList);
      response.setCallNextPatList(nextPatList);
      return response;
    }
    // add #8047 2022/10/31 薬剤セットで追加した後に追加した薬剤を選択すると異なる薬剤が表示される dou start
    if (updateNo > 2) {
      long maxMediInfoNo = updateNo - 1;
      if (maxMediInfoNo > indMediInfoNoPatId) {
        // 投薬最新識別番号の更新
        ordMainDao.updateIndMediInfoNo(facilityCd, patId, maxMediInfoNo);
      }
    }
    // add #8047 2022/10/31 薬剤セットで追加した後に追加した薬剤を選択すると異なる薬剤が表示される dou end
    // del #8047 2022/10/31 薬剤セットで追加した後に追加した薬剤を選択すると異なる薬剤が表示される dou start
//    // 投与薬剤をString型のListに格納
//    List<String> mediInfo = new ArrayList<>();
//    for (ApiEntityOrdMain.ValiOrdMedi bodyData : bodyDataList) {
//      if ("false".equals(bodyData.getIs_deadline())) {
//        // mediInfoNoMap
//        JSONObject editMediJson = new JSONObject(bodyData.getInd_info());
//        // 投与薬剤情報を格納
//        editMediJson.put("no", indMediInfoNo);
//        mediInfo.add(editMediJson.toString());
//      }
//    }
    // del #8047 2022/10/31 薬剤セットで追加した後に追加した薬剤を選択すると異なる薬剤が表示される dou end
    if (!mediInfo.isEmpty()) {
      PatTreatmentPatternUtils.PatTreatmentPatternEditData editData = new PatTreatmentPatternUtils.PatTreatmentPatternEditData();
      // 患者治療パターン編集データの格納
      editData.setIndMediInfo(mediInfo.toString());
      // 患者治療パターン項目新規登録処理
      int patPatternCount = patTreatmentPatternUtils.insertPatTreatmentPatternIndItemForIndMediAndEquip(
        Long.parseLong(patId),
        facilityCd,
        ordMainResource.getValueList(firstBodyData.getInd_treatment_cd()),
        ordMainResource.getLongList(firstBodyData.getInd_kur_cd()),
        weeksArray,
        PatTreatmentPatternUtils.IND_ITEM.MEDI,
        Timestamp.valueOf(update),
        editData
      );
    }

    // 条件送信後の治療予定が更新されたチェック
    //for (OrdMain o : ordMain) {
      // 治療状況
      //Integer dialysisState = Integer.parseInt(o.getRstDialysisState());
      // 条件送信済みの場合、メッセージを表示
      //del 6027 治療中に投与薬剤を追加した時 プロンプトなし 張 start
//      if (dialysisState > 0) {
//        responseData.put("msgCd", 22020003);
//      }
      //del 6027 治療中に投与薬剤を追加した時 プロンプトなし 張 start
    //}

    // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 start
    // 投与薬剤登録の場合
    /* modify by chamaojia 2023-03-21 [6961] ループから移動し、一括アクションに変更 --start */
    List<Long> ordNoToUpdate = new ArrayList<>();
    for (OrdMain item : ordMain) {
      // 編集対象日付リストに更新中ordMainが存在してるかどうかをチェック
      if(!ordDatesMap.containsKey(item.getTreatDate())){
        continue;
      }
//      ordMainResource.updateOrdChecklistByAction(
//        OrdMainResource.OrdMainActionForChecklist.TREATPLAN_MEDICINE_CREATE,
//        Long.parseLong(item.getOrdNo().toString())
//      );
      ordNoToUpdate.add(item.getOrdNo());
    }
    // mod 9324 追加薬剤投与ord_checklist共通インタフェース gjn start
//    ordMainResource.updateOrdChecklistByActionToList(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_MEDICINE_CREATE
//      , ordNoToUpdate);
    ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_MEDICINE_CREATE, ordNoToUpdate);
    // mod 9324 追加薬剤投与ord_checklist共通インタフェース gjn end

    /* modify by chamaojia 2023-03-21 [6961] ループから移動し、一括アクションに変更 --end */
    // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 end

    //指示履歴を登録
    /**
     * modify by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization:
     * 1、First determine whether Mongo is necessary to avoid unnecessary object creation
     * 2、Change from single insert to batch insert, createHistoryExecute() modify to createHistoryExecuteBatch()
     */
    //indHistoryMakeService.createMedicineHistory(bodyData, "1", weeksArray, new OrdMain());
    if(indHistoryMakeService.isToMongo()){
      String setLogDate = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date());
      List<IndHistory> indHistoryList = new ArrayList<>();
      for (ApiEntityOrdMain.ValiOrdMedi bodyData : bodyDataList) {
        //指示履歴用パラメータ
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        IndHistory indHistory = indHistoryMakeService.createMedicineHistoryParams(bodyData, "1", weeksArray, new OrdMain());
        IndHistory indHistory = indHistoryMakeService.createMedicineHistoryParams(bodyData, "1", weeksArray, new ArrayList<>());
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        //指示履歴時刻設定
        indHistory.setLogDate(setLogDate);
        indHistoryList.add(indHistory);
        //指示履歴登録処理
        //indHistoryMakeService.createHistoryExecute(indHistory, "1");
      }
      if(indHistoryList.size() > 0){
        //指示履歴登録処理
        indHistoryMakeService.createHistoryExecuteBatch(indHistoryList, "1");
      }
    }

    //del #10412 次患者更新関連全体見直し対応 朴 start
//    Long skipCode = Long.parseLong("0");
//    // 次患者更新処理
//    for (OrdMain ord : ordMain) {
//      // 編集対象日付リストに更新中ordMainが存在してるかどうかをチェック
//      if(!ordDatesMap.containsKey(ord.getTreatDate())){
//        continue;
//      }
//      Long bedCd = Long.parseLong(ord.getIndBedCd().toString());
//      Long targetOrdNo = ord.getOrdNo();
//      // 登録されているベッド(ベッド移動なしのため変更後として処理※変更前は条件送信キャンセルとして処理されるため)
//      /* mod #5482 by zhangruixue 2023-03-02 スケジュール --start */
////      ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, targetOrdNo, true, update);
//      nextPatList.add(new NextPat(facilityCd, skipCode, bedCd, ord, true, update));
//      /* mod #5482 by zhangruixue 2023-03-02 スケジュール --end */
//    }
    //del #10412 次患者更新関連全体見直し対応 朴 end

//del 8190 投与薬剤編集画面で2剤以上の薬剤追加を行うと連携イベントの登録が行われない start
//    if (firstBodyData.getHosp_pat_id() == null || "".equals(firstBodyData.getHosp_pat_id())) {
//      return new ResponseEntity<>(responseData.toString(), (org.springframework.http.HttpHeaders) null, HttpStatus.OK);
//    }
//del 8190 投与薬剤編集画面で2剤以上の薬剤追加を行うと連携イベントの登録が行われない end

    List<OrdMain> ordMainListFilterByTreatDate = ordMain.stream().filter(o -> ordDatesMap.containsKey(o.getTreatDate())).collect(Collectors.toList());
    List<Integer> treatCdList = ordMainListFilterByTreatDate.stream().map(OrdMain::getIndTreatmentCd).distinct().collect(Collectors.toList());
    List<MstTreatment> mstTreatList = treatCdList.stream().map(treatCd -> mstTreatmentDao.selectByCd(treatCd)).collect(Collectors.toList());
    for (MstTreatment mstTreat : mstTreatList) {
      List<OrdMain> ordMainList = ordMainListFilterByTreatDate.stream()
        .filter(o -> o.getIndTreatmentCd().equals(mstTreat.getTreatmentCd())).collect(Collectors.toList());
      //7771-------------------------------ljg start
      //del 10553 start
//      ordMainList = ordMainList.stream().filter(om->om.getIndKurCd().equals(0)==false && om.getIndKurCd()!=null).collect(Collectors.toList());
      //del 10553 end

/* Commented out by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: To move this update above ( search move7734 above ) -- start */
      //      //7734 指示者変更の場合 lig stsrt
      //      ordMainList.stream().forEach(item -> {
      //        String indScheduleUserInfo  = item.getIndScheduleUserInfo();
      //        JSONObject indScheduleUserInfoJObj = new JSONObject(indScheduleUserInfo);
      //        JSONObject bodyDataIndinfoObj = new JSONObject(firstBodyData.getInd_info());
      //        //中止画面からの指示者が元々の指示者と不一致の場合、指示者が変更することにする。
      //        if(!(bodyDataIndinfoObj.get("ind_user_id")).toString().equals((indScheduleUserInfoJObj.get("ind_user_id")).toString())){
      //          //ind_user_id（指示者）の値を変更。
      //          indScheduleUserInfoJObj.put("ind_user_id",Long.valueOf((bodyDataIndinfoObj.get("ind_user_id")).toString()));
      //          if((bodyDataIndinfoObj.get("ind_user_last_name"))!=null &&
      //            ! "" .equals((bodyDataIndinfoObj.get("ind_user_last_name")).toString())
      //          ){
      //            indScheduleUserInfoJObj.put("ind_user_last_name",(bodyDataIndinfoObj.get("ind_user_last_name")).toString());
      //          }
      //          if((bodyDataIndinfoObj.get("ind_user_first_name"))!=null &&
      //            ! "" .equals((bodyDataIndinfoObj.get("ind_user_first_name")).toString())
      //          ){
      //            indScheduleUserInfoJObj.put("ind_user_first_name",(bodyDataIndinfoObj.get("ind_user_first_name")).toString());
      //          }
      //          indScheduleUserInfo = indScheduleUserInfoJObj.toString();
      //          //指示者が変更されたのデータを更新する。
      //          ordMainDao.updateInduser(Long.valueOf(item.getOrdNo()),indScheduleUserInfo);
      //        }
      //      });
      //      //7734 指示者変更の場合 lig end
/* Commented out by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: To move this update above ( search move7734 above ) -- end */
      if (ordMainList.size()>0) {
        //7771-------------------------------ljg end
        // オペコードを設定する
        String opeCd = "004023";
        // mod 2023-01-14 bug #7627 修正 chen start
        // JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
//         // SysCoopJournal journalCreateRequestPayload = new SysCoopJournal();
//         JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
//         journalCreateRequestPayload.setFacilityCd(firstBodyData.getFacility_cd());
//         journalCreateRequestPayload.setCrud("U");
//         journalCreateRequestPayload.setHospPatId(firstBodyData.getHosp_pat_id());
//         journalCreateRequestPayload.setPatId(Long.valueOf(firstBodyData.getPat_id()));
//         //mod 8190 投与薬剤編集画面で2剤以上の薬剤追加を行うと連携イベントの登録が行われない start
// //        journalCreateRequestPayload.setUserId(Long.valueOf(firstBodyData.getUser_id()));
//         JSONObject indInfoJson = new JSONObject(firstBodyData.getInd_info());
//         journalCreateRequestPayload.setUserId(Long.valueOf(indInfoJson.get("ind_user_id").toString()));
//         //mod 8190 投与薬剤編集画面で2剤以上の薬剤追加を行うと連携イベントの登録が行われない end
//         journalCreateRequestPayload.setOpeCd(opeCd);
        // asyncService.sendExternalConnection(ordMainList, journalCreateRequestPayload);
        // List<Long> ctlNoList = new ArrayList<>();
        // del #11004 連携イベント発生部分不正 piao start
        // int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(firstBodyData.getFacility_cd());
        // del #11004 連携イベント発生部分不正 piao end
        for (OrdMain ord : ordMainList) {
          //add 10553 start
          if(ord.getIndKurCd() == null || ord.getIndKurCd().equals(0)){
            opeCd = "004113";
          }else {
            opeCd = "004023";
          }
          //add 10553 end
          // del #11004 連携イベント発生部分不正 piao start
          // if (modify_send_class == 2) {
          //   JournalCreateRequestPayload deljournalCreateRequestPayload = new JournalCreateRequestPayload();
          //   deljournalCreateRequestPayload.setFacilityCd(firstBodyData.getFacility_cd());
          //   deljournalCreateRequestPayload.setCrud("D");
          //   deljournalCreateRequestPayload.setHospPatId(firstBodyData.getHosp_pat_id());
          //   deljournalCreateRequestPayload.setPatId(Long.valueOf(firstBodyData.getPat_id()));
          //   JSONObject delindInfoJson = new JSONObject(firstBodyData.getInd_info());
          //   deljournalCreateRequestPayload.setUserId(Long.valueOf(delindInfoJson.get("ind_user_id").toString()));
          //   deljournalCreateRequestPayload.setOpeCd(opeCd);
          //   deljournalCreateRequestPayload.setOrdNo(ord.getOrdNo());
          //   deljournalCreateRequestPayload.setBaseDate(ord.getTreatDate());
          //   ctlNoList.add(deljournalCreateRequestPayload);
          // }
          // del #11004 連携イベント発生部分不正 piao end
          JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
          journalCreateRequestPayload.setFacilityCd(firstBodyData.getFacility_cd());
          journalCreateRequestPayload.setCrud("U");
          // del #11004 連携イベント発生部分不正 piao start
          // if (modify_send_class == 2) {
          //   journalCreateRequestPayload.setCrud("C");
          // }
          // del #11004 連携イベント発生部分不正 piao end
          journalCreateRequestPayload.setHospPatId(firstBodyData.getHosp_pat_id());
          journalCreateRequestPayload.setPatId(Long.valueOf(firstBodyData.getPat_id()));
          //mod 8190 投与薬剤編集画面で2剤以上の薬剤追加を行うと連携イベントの登録が行われない start
//        journalCreateRequestPayload.setUserId(Long.valueOf(firstBodyData.getUser_id()));
          JSONObject indInfoJson = new JSONObject(firstBodyData.getInd_info());
          journalCreateRequestPayload.setUserId(Long.valueOf(indInfoJson.get("ind_user_id").toString()));
          //mod 8190 投与薬剤編集画面で2剤以上の薬剤追加を行うと連携イベントの登録が行われない end
          journalCreateRequestPayload.setOpeCd(opeCd);
          journalCreateRequestPayload.setOrdNo(ord.getOrdNo());
          journalCreateRequestPayload.setBaseDate(ord.getTreatDate());
          // journalCreateRequestPayload.setCtlNo(sysCoopJournalDao.selectNextSeqCtlNo());
          // sysCoopJournalDao.insert(journalCreateRequestPayload);
          // ctlNoList.add(journalCreateRequestPayload.getCtlNo());
          ctlNoList.add(journalCreateRequestPayload);
        }
        // mod 2023-01-14 bug #7627 修正 chen end
      }
    }
    JournalCreatecallNextPatIdRequestResponse response = new JournalCreatecallNextPatIdRequestResponse();
    response.setResponse(new ResponseEntity<>(responseData.toString(), (org.springframework.http.HttpHeaders) null, HttpStatus.OK));
    response.setCtlNoList(ctlNoList);
    response.setCallNextPatList(nextPatList);
    return response;
  }

  @Transactional
  @Override
  public JournalCreatecallNextPatIdRequestResponse deleteOrdMainMediInfo(ApiEntityOrdMain.ValiOrdMedi bodyData) {
    //mod #10412 次患者更新関連全体見直し対応 朴 start
    List<OrdMain> nextPatList=new ArrayList<>();
    //mod #10412 次患者更新関連全体見直し対応 朴 end
    // 選択された曜日の処理
    String startDate = bodyData.getStart_date().replaceAll("-", "");
    String endDate = bodyData.getEnd_date().replaceAll("-", "");
    List weeksArry = new ArrayList<Integer>();
    weeksArry.add(0);

    List<OrdMain> ordMain = new ArrayList();
    List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
    try {
      // 更新対象ordNo List取得
      ordMain = ordMainService.findUpdateTarget(
        Long.parseLong(bodyData.getPat_id()),
        bodyData.getFacility_cd(),
        startDate,
        endDate,
        weeksArry,
        ordMainResource.getValueList(bodyData.getInd_treatment_cd()),
        ordMainResource.getLongList(bodyData.getInd_kur_cd())
      );
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }

    //add #10266 start
    if("2".equals(bodyData.getUpdate_flag())){
      ordMain = ordMain.stream().filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
    }
    //add #10266 end

    JSONObject responseData = new JSONObject("{}");
    if(ordMain.isEmpty()){
      JournalCreatecallNextPatIdRequestResponse response = new JournalCreatecallNextPatIdRequestResponse();
      response.setResponse(new ResponseEntity<>(responseData.toString(), (org.springframework.http.HttpHeaders) null, HttpStatus.OK));
      response.setCtlNoList(ctlNoList);
      response.setCallNextPatList(nextPatList);
      return response;
    }

//    //add #10266 start
//    if("2".equals(bodyData.getUpdate_flag())){
//      ordMain = ordMain.stream().filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
//    }
//    //add #10266 end

    //add #10412 次患者更新関連全体見直し対応 朴 start
    nextPatList = ordMain.stream().map(SerializationUtils::clone).collect(Collectors.toList());
    //add #10412 次患者更新関連全体見直し対応 朴 end

    String facilityCd = bodyData.getFacility_cd();
    String patId = bodyData.getPat_id();

    // add FNSI-FutreNetWeb+SI課題管理No.5686 李 start
//    Boolean logUpdateFlg = true;
//    Long logOrdNo = null;
//    if (null != ordMain && ordMain.size() > 31) {
//      logOrdNo = ordMain.get(32).getOrdNo();
//    }
    // add FNSI-FutreNetWeb+SI課題管理No.5686 李 end

    // 投与回数用カウンター
    int count = 0;
    // 投与回数
    Integer countMax = StringUtils.isEmpty(bodyData.getCount_after()) ? null : Integer.parseInt(bodyData.getCount_after());
    // 編集するind_medi_info
    JSONObject editMediJson = new JSONObject(bodyData.getInd_info());
//    mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
    OrdMainRequest ordMainRequest=new OrdMainRequest();
    ordMainRequest.setPatId(Long.parseLong(bodyData.getPat_id()));
    ordMainRequest.setFacilityCd(bodyData.getFacility_cd());
    ordMainRequest.setDialysisDateFrom(startDate);
    ordMainRequest.setDialysisDateTo(endDate);
    List<OrdMainMedicineDelete> ordMainMedicineDelete=ordMainService.getPatIndMmdicine(ordMainRequest);
    OrdMainMedicineDelete ordMainMedicine=ordMainMedicineDelete.stream().filter(item->item.getCd().equals(editMediJson.get("cd").toString())&&item.getMedicineType().equals(editMediJson.get("medicine_type").toString())).findFirst().orElse(null);
    List<String> noList=new ArrayList<String>();
    if (ordMainMedicine!=null) {
      noList= Arrays.asList(ordMainMedicine.getNoList().split(","));
    }
    // 削除する投与薬剤情報
    List<String> deleteMediInfo = new ArrayList<String>();

    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Cache the master data to avoid repeated read from database --start */
    MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Cache the master data to avoid repeated read from database --end */

    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Store a copy of the data before editing to Mongo, alternative method: getHistory(ord_no) in method updateOrdMainEquipInfo(), And Optimized for batch insertion --start */
    List<Long> ordNoListForMongoLog = ordMain.stream().map(ordMain1 -> ordMain1.getOrdNo()).collect(Collectors.toList());
//    selectHistoryUtils.insertMangoDbHistoryBatch(ordNoListForMongoLog);
    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Store a copy of the data before editing to Mongo, alternative method: getHistory(ord_no) in method updateOrdMainEquipInfo(), And Optimized for batch insertion --end */

    /* add by chamaojia 2023-03-21 [6961] 次の一括アクションの準備のための新規コレクション・ストレージ・データ --start */
    // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<OrdMaterialSave> ordMaterialSaveList = new ArrayList<>();
//    List<DeleteByConditionsAllDTO> deleteByConditionsAllDTOList = new ArrayList<>();
    // del 12250 ord_material_saveの処理を2回重複実行している zkm end
    List<UpdateOrdMainMediInfoDTO> mediInfoEntityList = new ArrayList<>();
    /* add by chamaojia 2023-03-21 [6961] 次の一括アクションの準備のための新規コレクション・ストレージ・データ --end */
    //add #10196 Ord_Material_Save operation 20240131 ztc start
    // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new ArrayList<>();
    // del 12250 ord_material_saveの処理を2回重複実行している zkm end
    //mod #10196 Ord_Material_Save operation 20240131 ztc end
    for (OrdMain ord : ordMain){
      boolean hasDeleteMedicineNo = false;
      // 投与回数を満たすと処理を終了
      if (countMax != null && count >= countMax) {
        break;
      }
      String rstDialysisState = ord.getRstDialysisState();
      //add #11841 【たくしん会】ord_mainの登録不正 zrx start
      if(Objects.equals("0", rstDialysisState)) {
        ord = ordMainService.delJSONKey(ord);
      }
      //add #11841 【たくしん会】ord_mainの登録不正 zrx end

      // 更新中ordMainの投与薬剤
      /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
      //JSONArray indMediJsonArr = new JSONArray(ord.getIndMediInfo());
      JSONArray indMediJsonArr = new JSONArray(ObjectUtils.isEmpty(ord.getIndMediInfo())? "[]" : ord.getIndMediInfo());
      /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
      //add by ShiHongda 2023-02-13 [Bug] --start /
      String medicine_type = "";
      //add by ShiHongda 2023-02-13 [Bug] --end /
      List<Integer> deleteds = new ArrayList<Integer>();
      for (int i = 0; i < indMediJsonArr.length(); i++) {
        // 削除対象投与薬剤は更新中ordMainのind_medi_infoに存在してるかをチェック
//        if (indMediJsonArr.getJSONObject(i).get("no").equals(editMediJson.get("no"))) {
          if (noList.contains(indMediJsonArr.getJSONObject(i).get("no").toString())) {
          deleteMediInfo.add(indMediJsonArr.getJSONObject(i).toString());
          //add by ShiHongda 2023-02-13 [Bug] --start /
          medicine_type = indMediJsonArr.getJSONObject(i).get("medicine_type").toString();
          //add by ShiHongda 2023-02-13 [Bug] --end /
//          indMediJsonArr.remove(i);
          deleteds.add(i);
          hasDeleteMedicineNo = true;
//          break;
        }
      }
      for (int i = deleteds.size() - 1; i >= 0; i--) {
        indMediJsonArr.remove(deleteds.get(i));
      }
//      mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
      if (! hasDeleteMedicineNo) {
        // 削除対象の薬剤が見つからない場合：処理をスキップ
        continue;
      }

      // 更新中ordMainの指示投与薬剤
      ord.setIndMediInfo(indMediJsonArr.toString());
      boolean isUpdatedRstMediInfo = false;

      // 治療未実施以外の場合、変更内容を実績にも反映する
      String rstMediInfo = null;
      // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 start
//      if (rstDialysisState == 0) {
      String isRstUpdate = bodyData.getIs_rst_update();
      if (AdminWebConstant.OrdMainConst.DialysisState.BEFORE_SEND.equals(rstDialysisState) || "false".equals(isRstUpdate)) {
        // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 end
        rstMediInfo = ord.getRstMediInfo();
      } else {
        JSONArray rstMediInfoArr = new JSONArray(ord.getRstMediInfo() == null ? "[]" : ord.getRstMediInfo());
        // mod FNSI-FutreNetWeb+SI課題管理No.4742 李 start
        // rstMediInfo = this.createRstInfo(mediJson, rstMediInfoArr, "no", editMediJson).toString();
        rstMediInfo = this.createRstInfo(indMediJsonArr, rstMediInfoArr, "0", "no", editMediJson, rstDialysisState.toString(),masterCacheHandler).toString();
        // mod FNSI-FutreNetWeb+SI課題管理No.4742 李 end
        isUpdatedRstMediInfo = true;
      }
      // 更新中ordMainの实际投与薬剤
      ord.setRstMediInfo(rstMediInfo);
      /* del by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
//      /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Move code block here ( search move7734 )  start */
//      JSONObject indScheduleUserInfoJObj = new JSONObject(ord.getIndScheduleUserInfo());
//      //中止画面からの指示者が元々の指示者と不一致の場合、指示者が変更することにする。
//      String edit_ind_user_id = StrUtils.getStrFromJSONObject(editMediJson,"ind_user_id");
//      String ind_schedule_ind_user_id = StrUtils.getStrFromJSONObject(indScheduleUserInfoJObj,"ind_user_id");
//      if(!edit_ind_user_id.equals(ind_schedule_ind_user_id)) {
//        //ind_user_id（指示者）の値を変更。
//        indScheduleUserInfoJObj.put("ind_user_id", Long.valueOf(edit_ind_user_id));
//        String edit_ind_user_first_name = StrUtils.getStrFromJSONObject(editMediJson,"ind_user_first_name");
//        if (!StringUtils.isEmpty(edit_ind_user_first_name)) {
//          indScheduleUserInfoJObj.put("ind_user_first_name", edit_ind_user_first_name);
//        }
//        String edit_ind_user_last_name = StrUtils.getStrFromJSONObject(editMediJson,"ind_user_last_name");
//        if (!StringUtils.isEmpty(edit_ind_user_last_name)) {
//          indScheduleUserInfoJObj.put("ind_user_last_name", edit_ind_user_last_name);
//        }
//        ord.setIndScheduleUserInfo(indScheduleUserInfoJObj.toString());
//      }
//      /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Move code block here ( search move7734 )  end */
      /* del by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */

      try {
        // mod FNSI-FutreNetWeb+SI課題管理No.5686 李 start
        // ordMainService.updateOrdMainMediInfo(
        // ord.getOrdNo(),
        // mediJson.toString(),
        // rstMediInfo
        // );

/* modify by shyw 2022-08-26 [FNSI-6961] for Performance Optimization  --start */
//        if (logUpdateFlg && null != logOrdNo && ord.getOrdNo().longValue() == logOrdNo.longValue()) {
//          logUpdateFlg = false;
//        }
//        ordMainService.updateOrdMainMediInfo(
//          ord.getOrdNo(),
//          indMediJsonArr.toString(),
//          rstMediInfo,
//          logUpdateFlg
//        );
        /**
         * Update the following fields according to ord.getOrdNo():
         *        ord.getIndMediInfo(),
         *        ord.getRstMediInfo(),
         *        ord.getIndScheduleUserInfo(),
         *        upIndUseId,
         *        upUseId
        */
        String upd_user_id = StrUtils.getStrFromJSONObject(editMediJson,"upd_user_id");
        String ind_user_id = StrUtils.getStrFromJSONObject(editMediJson,"ind_user_id");
        /* modify by chamaojia 2023-03-21 [6961] 次の一括アクションに備えてデータを整理する --start */
//        updateOrdMainMediInfo(ord,Long.valueOf(ind_user_id),Long.valueOf(upd_user_id));
        UpdateOrdMainMediInfoDTO mediInfoEntity = new UpdateOrdMainMediInfoDTO();
        mediInfoEntity.setOrdMain(ord);
        mediInfoEntity.setUpIndUseId(Long.valueOf(ind_user_id));
        mediInfoEntity.setUpUseId(Long.valueOf(upd_user_id));
        mediInfoEntityList.add(mediInfoEntity);
        /* modify by chamaojia 2023-03-21 [6961] 次の一括アクションに備えてデータを整理する --end */
/* modify by shyw 2022-08-26 [FNSI-6961] for Performance Optimization  --end */

        // mod FNSI-FutreNetWeb+SI課題管理No.5686 李 end

        // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 start
/* modify by shyw 2022-08-26 [FNSI-6961] for Performance Optimization：Optimize the logic of updating the table ord_material_save  --end */
//        ApiEntityOrdMain.ValiOrdMaterialSave conditions = new ApiEntityOrdMain.ValiOrdMaterialSave();
//        // 施設コード
//        conditions.setFacility_cd(bodyData.getFacility_cd());
//        // 患者ID
//        conditions.setPat_id(bodyData.getPat_id());
//        // データ基準日
//        conditions.setBase_date(ord.getTreatDate());
//        // データ基準番号
//        conditions.setSupplies_base_no(ord.getOrdNo().toString());
//        // データ発生元区分List(1：投与薬剤)
//        conditions.setSupplies_source_class("1");
//        // 物品区分List
//        List suppliesClassList = new ArrayList();
//        // 12：投与薬剤
//        suppliesClassList.add("12");
//        // 13：調整薬剤
//        suppliesClassList.add("13");
//        conditions.setSupplies_class_list(suppliesClassList);
//        // 条件に基づいてデータを削除する
//        ordMaterialSaveService.deleteOrdMaterialSaveByConditions(conditions);
//
//        // mediJsonに従ってログインします
//        // 指示・実績区分
//        conditions.setInd_rst_class("1");
//        // 確定フラグ
//        conditions.setIs_confirm("0");
//        // 計算材料保持テーブル投与薬剤情報値の設定
//        this.indMediValueSetting(conditions, indMediJsonArr);
        // delete the ordMaterialSave of 1:指示、2:実績区分 ---start
        // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//        ApiEntityOrdMain.ValiOrdMaterialSave conditions = new ApiEntityOrdMain.ValiOrdMaterialSave();
//        // 施設コード
//        conditions.setFacility_cd(facilityCd);
//        // 患者ID
//        conditions.setPat_id(patId);
//        // データ基準日
//        conditions.setBase_date(ord.getTreatDate());
//        // データ基準番号
//        conditions.setSupplies_base_no(ord.getOrdNo().toString());
//        // データ発生元区分List(1：投与薬剤)
//        conditions.setSupplies_source_class("1");
//        // 物品区分  12：投与薬剤    13：調整薬剤
//        List<String> suppliesClass = Arrays.asList("12","13");
//        conditions.setSupplies_class_list(suppliesClass);
//        // 1:指示、2:実績
//        List<String> indRstClassList = null;
//        if(isUpdatedRstMediInfo){
//          indRstClassList = Arrays.asList("1","2");
//        }else {
//          indRstClassList = Arrays.asList("1");
//        }
//        conditions.setIndRstClassList(indRstClassList);
        // del 12250 ord_material_saveの処理を2回重複実行している zkm end
        // 投与薬剤コード
        String mediCd = StrUtils.getStrFromJSONObject(editMediJson,"cd"); // code
        List<String> suppliesCdList = Arrays.asList(mediCd);
        // 条件に基づいてデータを削除する 根据条件删除数据

        //add by ShiHongda 2023-02-13 [Bug] --start /
        int delCount = 0;
        /* modify by chamaojia 2023-03-21 [6961] データの整理、次の操作の準備、実行順序の維持 --start */
        // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//        DeleteByConditionsAllDTO conditionsAllEntity = new DeleteByConditionsAllDTO();
//        conditionsAllEntity.setFacilityCd(conditions.getFacility_cd());
//        conditionsAllEntity.setPatId(conditions.getPat_id());
//        conditionsAllEntity.setSuppliesBaseNo(conditions.getSupplies_base_no());
//        conditionsAllEntity.setBaseDate(conditions.getBase_date());
//        conditionsAllEntity.setSuppliesSourceClass(conditions.getSupplies_source_class());
//        conditionsAllEntity.setIndRstClassList(indRstClassList);
//        conditionsAllEntity.setMedicineType(medicine_type);
//        if("1".equals(medicine_type)){
////          delCount = ordMaterialSaveDao.deleteByConditions(
////            conditions.getFacility_cd(),
////            conditions.getPat_id(),
////            conditions.getSupplies_base_no(),
////            conditions.getBase_date(),
////            conditions.getSupplies_source_class(),
////            suppliesClass,
////            indRstClassList,
////            suppliesCdList
////          );
//          conditionsAllEntity.setSuppliesClass(suppliesClass);
//          conditionsAllEntity.setSuppliesCdListTc(suppliesCdList);
//        }else if("2".equals(medicine_type)){
//          List<String> suppliesCdClass = Arrays.asList("12","13",SUPPLIES_CLASS_MEDICINE);
//          List<String> medicineMixCdList = suppliesCdList;
////          delCount = ordMaterialSaveDao.deleteByTzConditions(
////            conditions.getFacility_cd(),
////            conditions.getPat_id(),
////            conditions.getSupplies_base_no(),
////            conditions.getBase_date(),
////            conditions.getSupplies_source_class(),
////            suppliesCdClass,
////            indRstClassList,
////            medicineMixCdList
////          );
//          conditionsAllEntity.setSuppliesClass(suppliesCdClass);
//          conditionsAllEntity.setMedicineMixCdListTj(medicineMixCdList);
//        }
//        deleteByConditionsAllDTOList.add(conditionsAllEntity);
        // del 12250 ord_material_saveの処理を2回重複実行している zkm end
        /* modify by chamaojia 2023-03-21 [6961] データの整理、次の操作の準備、実行順序の維持 --end */
        //add by ShiHongda 2023-02-13 [Bug] --end /

        // delete the ordMaterialSave of 1:指示、2:実績区分 ---end
        // insert the ordMaterialSave of 1:指示 ---start
        // 計算材料保持テーブル投与薬剤情報値の設定
//        JSONArray ordIndMediArr = new JSONArray(ord.getIndMediInfo());
        //this.indEquipValueSetting(conditions, mediJsonArr);
        /* modify by chamaojia 2023-03-21 [6961] 一括処理をループ外に移動 --start */
//        List<OrdMaterialSave> ordMaterialSaveList1 = this.createMediOrdMaterialSaveObj("1",conditions, ordIndMediArr,Arrays.asList(Integer.parseInt(mediCd)),masterCacheHandler);
//        if (ordMaterialSaveList1 != null && ordMaterialSaveList1.size() > 0) {
//          ordMaterialSaveList.addAll(ordMaterialSaveList1);
//        }
        // insert the ordMaterialSave of 1:指示 ---end

        // insert the ordMaterialSave of 2:実績 ---start
//        if(isUpdatedRstMediInfo){
//          JSONArray ordRstEquipArr = new JSONArray(ord.getRstEquipInfo());
//          List<OrdMaterialSave> ordMaterialSaveList2 = this.createMediOrdMaterialSaveObj("2",conditions, ordRstEquipArr,Arrays.asList(Integer.parseInt(mediCd)),masterCacheHandler);
////          ordMaterialSaveList1.addAll(ordMaterialSaveList2);
//          if (ordMaterialSaveList2 != null && ordMaterialSaveList2.size() > 0) {
//            ordMaterialSaveList.addAll(ordMaterialSaveList2);
//          }
//        }
        // insert the ordMaterialSave of 2:実績 ---end
        //add #10196 Ord_Material_Save code implementation 20240131 ztc start

        // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//        diffMaterialSaveRstList.add(
//          ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//            new OrdMaterialSaveDto(
//              ord.getOrdNo(),
//              false,
//              true,
//              false,
//              false,
//              OrdMaterialSaveDto.IND_CLASS,
//              ord
//            )
//          )
//        );
//        if (isUpdatedRstMediInfo) {
//          diffMaterialSaveRstList.add(
//            ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//              new OrdMaterialSaveDto(
//                ord.getOrdNo(),
//                false,
//                true,
//                false,
//                false,
//                OrdMaterialSaveDto.RST_CLASS,
//                ord
//              )
//            )
//          );
//        }
        // del 12250 ord_material_saveの処理を2回重複実行している zkm end
        //add #10196 Ord_Material_Save code implementation 20240131 ztc end
//        if(!ordMaterialSaveList1.isEmpty()){
//          ordMaterialSaveDao.insertBatch(ordMaterialSaveList1);
//        }
        /* modify by chamaojia 2023-03-21 [6961] 一括処理をループ外に移動 --end */
        /* modify by shyw 2022-08-26 [FNSI-6961] for Performance Optimization：Optimize the logic of updating the table ord_material_save  --end */
        // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 end

/* commented out by shyw 2022-08-26 [FNSI-6961] for Performance Optimization: upIndUseId and upUseId have been updated above --start */
//        // add FNSI-最終更新指示者のカラム追加と更新処理 楊 start
//        // 最終更新指示者のカラム追加と更新処理
//        List<Long> ordMainCdList = new ArrayList();
//        ordMainCdList.add(ord.getOrdNo());
//        this.updUpUseId(ordMainCdList, Long.valueOf(String.valueOf(editMediJson.get("ind_user_id"))), Long.valueOf(String.valueOf(editMediJson.get("upd_user_id"))));
//        // add FNSI-最終更新指示者のカラム追加と更新処理 楊 end
/* commented out by shyw 2022-08-26 [FNSI-6961] for Performance Optimization: upIndUseId and upUseId have been updated above --end */
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      }

      //1回目の処理のみ、指示履歴を登録
      if (count < 1){
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        indHistoryMakeService.createMedicineHistory(bodyData, "3", weeksArry, ord);
        indHistoryMakeService.createMedicineHistory(bodyData, "3", weeksArry, nextPatList);
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
      }
      count++;
    }

    /* add by chamaojia 2023-03-21 [6961] 一括処理と実行順序の維持 --start */
    //mod 9806 ljx start　投与薬剤
    //updateOrdMainMediInfoByList(mediInfoEntityList);
    updateOrdMainMediInfoByList(mediInfoEntityList,"true".equals(bodyData.getIs_rst_update()));
    //mod 9806 ljx end

    // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//    for (DeleteByConditionsAllDTO entity : deleteByConditionsAllDTOList) {
//      if("1".equals(entity.getMedicineType())){
//          ordMaterialSaveDao.deleteByConditions(
//            entity.getFacilityCd(),
//            entity.getPatId(),
//            entity.getSuppliesBaseNo(),
//            entity.getBaseDate(),
//            entity.getSuppliesSourceClass(),
//            entity.getSuppliesClass(),
//            entity.getIndRstClassList(),
//            entity.getSuppliesCdListTc()
//          );
//      }else if("2".equals(entity.getMedicineType())){
//          ordMaterialSaveDao.deleteByTzConditions(
//            entity.getFacilityCd(),
//            entity.getPatId(),
//            entity.getSuppliesBaseNo(),
//            entity.getBaseDate(),
//            entity.getSuppliesSourceClass(),
//            entity.getSuppliesClass(),
//            entity.getIndRstClassList(),
//            entity.getMedicineMixCdListTj()
//          );
//      }
//    }

//    if(!ordMaterialSaveList.isEmpty()){
//      ordMaterialSaveService.insertBatch(ordMaterialSaveList);
//    }
    // del 12250 ord_material_saveの処理を2回重複実行している zkm end
    /* add by chamaojia 2023-03-21 [6961] 一括処理と実行順序の維持 --end */
    //add #10196 Ord_Material_Save code implementation 20240131 ztc start
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    if(diffMaterialSaveRstList.size() > 0){
//      ordMaterialSaveService.batchProcessingData(diffMaterialSaveRstList);
//    }
    if ("true".equals(bodyData.getIs_rst_update())) {
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(ordNoListForMongoLog);
    } else {
      ordMaterialSaveService.bulkUpdateByOrdNoInMedi(ordNoListForMongoLog);
    }
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
    //add #10196 Ord_Material_Save code implementation 20240131 ztc end
    selectHistoryUtils.insertMangoDbHistoryBatch(ordNoListForMongoLog);

    // 条件送信後の治療予定が更新されたチェック
    for (OrdMain o : ordMain) {
      // 治療状況
      Integer dialysisState = Integer.parseInt(o.getRstDialysisState());
      // 条件送信済みの場合、メッセージを表示
      if (dialysisState > 0) {
        responseData.put("msgCd", 22020003);
        break; // add by shyw 2022-08-26 [FNSI-6961] for Performance Optimization: Avoid unnecessary circulation
      }
    }

    /* modify by chamaojia 2023-03-21 [6961] ループから移動し、一括アクションに変更 --start */
    // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 start
    // 投与薬剤登録の場合
//    ordMain.forEach(item -> {
//      ordMainResource.updateOrdChecklistByAction(
//        OrdMainResource.OrdMainActionForChecklist.TREATPLAN_MEDICINE_DELETE,
//        Long.parseLong(item.getOrdNo().toString())
//      );
//    });
    List<Long> ordNoList = ordMain.stream().map(o -> o.getOrdNo()).collect(Collectors.toList());
    //mod 9324 投与と薬剤削除呼び出しord_checklist共通方法 gjn start
//    ordMainResource.updateOrdChecklistByActionToList(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_MEDICINE_DELETE
//      , ordNoList);
    ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_MEDICINE_DELETE, ordNoList);
    //mod 9324 投与と薬剤削除呼び出しord_checklist共通方法 gjn end

    /* modify by chamaojia 2023-03-21 [6961] ループから移動し、一括アクションに変更 --end */
    // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 end


    LocalDateTime update = LocalDateTime.now();

    // 終了日が未設定の場合、患者治療パターンの更新処理
    if ("false".equals(bodyData.getIs_deadline())) {
      if (0 != deleteMediInfo.size()) {
        PatTreatmentPatternUtils.PatTreatmentPatternEditData editData = new PatTreatmentPatternUtils.PatTreatmentPatternEditData();
        // 患者治療パターン編集データの格納
        editData.setIndMediInfo(deleteMediInfo.toString());
        // 曜日を1から7で登録
        List<Integer> weeks = new ArrayList<Integer>();
        for (int i = 1; i <= 7; i++) {
          weeks.add(i);
        }

        // 患者治療パターン項目削除処理
        int patPatternCount = patTreatmentPatternUtils.deletePatTreatmentPatternIndItemForIndMediAndEquip(
          Long.parseLong(bodyData.getPat_id()),
          bodyData.getFacility_cd(),
          ordMainResource.getValueList(bodyData.getInd_treatment_cd()),
          ordMainResource.getLongList(bodyData.getInd_kur_cd()),
          weeks,
          PatTreatmentPatternUtils.IND_ITEM.MEDI,
          Timestamp.valueOf(update),
          editData
        );
      }
    }

    //del #10412 次患者更新関連全体見直し対応 朴 start
//    Long skipCode = Long.parseLong("0");
//    // 次患者更新処理
//    for (OrdMain ord : ordMain) {
//      Long bedCd = Long.parseLong(ord.getIndBedCd().toString());
//      Long targetOrdNo = ord.getOrdNo();
//      // 登録されているベッド(ベッド移動なしのため変更後として処理※変更前は条件送信キャンセルとして処理されるため)
//      /* mod #5482 by zhangruixue 2023-03-02 スケジュール --start */
////      ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, targetOrdNo, true, update);
//      nextPatList.add(new NextPat(facilityCd, skipCode, bedCd, ord, true, update));
//      /* mod #5482 by zhangruixue 2023-03-02 スケジュール --end */
//    }
    //del #10412 次患者更新関連全体見直し対応 朴 end

    if (bodyData.getHosp_pat_id() == null || "".equals(bodyData.getHosp_pat_id())) {
      JournalCreatecallNextPatIdRequestResponse response = new JournalCreatecallNextPatIdRequestResponse();
      response.setResponse(new ResponseEntity<>(responseData.toString(), (org.springframework.http.HttpHeaders) null, HttpStatus.OK));
      response.setCtlNoList(ctlNoList);
      response.setCallNextPatList(nextPatList);
      return response;
    }

    List<Integer> treatCdList = ordMain.stream().map(OrdMain::getIndTreatmentCd).distinct().collect(Collectors.toList());
    List<MstTreatment> mstTreatList = treatCdList.stream().map(treatCd -> mstTreatmentDao.selectByCd(treatCd)).collect(Collectors.toList());
    for (MstTreatment mstTreat : mstTreatList) {
      List<OrdMain> ordMainList = ordMain.stream()
        .filter(o -> o.getIndTreatmentCd().equals(mstTreat.getTreatmentCd())).collect(Collectors.toList());
      //7771-------------------------------ljg start
      //del 10553 start
//      ordMainList = ordMainList.stream().filter(om->om.getIndKurCd().equals(0)==false && om.getIndKurCd()!=null).collect(Collectors.toList());
      //del 10553 end

/* Commented out by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: To move this update above ( search move7734 above ) -- start */
        //      //7734 指示者変更の場合 lig stsrt
        //      ordMainList.stream()
        //        .forEach(item -> {
        //          String indScheduleUserInfo  = item.getIndScheduleUserInfo();
        //          JSONObject indScheduleUserInfoJObj = new JSONObject(indScheduleUserInfo);
        //          JSONObject bodyDataIndinfoObj = new JSONObject(bodyData.getInd_info());
        //          //中止画面からの指示者が元々の指示者と不一致の場合、指示者が変更することにする。
        //          if(!(bodyDataIndinfoObj.get("ind_user_id")).toString().equals((indScheduleUserInfoJObj.get("ind_user_id")).toString())){
        //            //ind_user_id（指示者）の値を変更。
        //            indScheduleUserInfoJObj.put("ind_user_id",Long.valueOf((bodyDataIndinfoObj.get("ind_user_id")).toString()));
        //            if((bodyDataIndinfoObj.get("ind_user_first_name")).toString()!=null &&
        //              ! "" .equals((bodyDataIndinfoObj.get("ind_user_first_name")).toString())){
        //              indScheduleUserInfoJObj.put("ind_user_last_name",(bodyDataIndinfoObj.get("ind_user_last_name")).toString());
        //            }
        //            if((bodyDataIndinfoObj.get("ind_user_first_name")).toString()!=null &&
        //              ! "" .equals((bodyDataIndinfoObj.get("ind_user_first_name")).toString())
        //            ){
        //              indScheduleUserInfoJObj.put("ind_user_first_name",(bodyDataIndinfoObj.get("ind_user_first_name")).toString());
        //            }
        ////            indScheduleUserInfoJObj.put("ind_user_last_name",(bodyDataIndinfoObj.get("ind_user_last_name")).toString());
        ////            indScheduleUserInfoJObj.put("ind_user_first_name",(bodyDataIndinfoObj.get("ind_user_first_name")).toString());
        //            indScheduleUserInfo = indScheduleUserInfoJObj.toString();
        //            //指示者が変更されたのデータを更新する。
        //            ordMainDao.updateInduser(Long.valueOf(item.getOrdNo()),indScheduleUserInfo);
        //          }
        //        });
        //      //7734 指示者変更の場合 lig end
/* Commented out by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: To move this update above ( search move7734 above ) -- start */
      if (ordMainList.size()>0) {
        //7771-------------------------------ljg end
        // オペコードを設定する
        String opeCd = "004025";
        // mod 2023-01-14 bug #7627 修正 chen start
        // JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
        // // SysCoopJournal journalCreateRequestPayload = new SysCoopJournal();
        // JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
        // journalCreateRequestPayload.setFacilityCd(bodyData.getFacility_cd());
        // journalCreateRequestPayload.setCrud("U");
        // journalCreateRequestPayload.setHospPatId(bodyData.getHosp_pat_id());
        // journalCreateRequestPayload.setPatId(Long.valueOf(bodyData.getPat_id()));
        // journalCreateRequestPayload.setUserId(Long.valueOf(bodyData.getUser_id()));
        // journalCreateRequestPayload.setOpeCd(opeCd);
        // asyncService.sendExternalConnection(ordMainList, journalCreateRequestPayload);
        // List<Long> ctlNoList = new ArrayList<>();
        // del #11004 連携イベント発生部分不正 piao start
        // int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(bodyData.getFacility_cd());
        // del #11004 連携イベント発生部分不正 piao end
        for (OrdMain ord : ordMainList) {
          //add 10553 start
          if(ord.getIndKurCd() == null || ord.getIndKurCd().equals(0)){
            opeCd = "004115";
          }else {
            opeCd = "004025";
          }
          //add 10553 end
          // del #11004 連携イベント発生部分不正 piao start
          // if (modify_send_class == 2) {
          //   JournalCreateRequestPayload deljournalCreateRequestPayload = new JournalCreateRequestPayload();
          //   deljournalCreateRequestPayload.setFacilityCd(bodyData.getFacility_cd());
          //   deljournalCreateRequestPayload.setCrud("D");
          //   deljournalCreateRequestPayload.setHospPatId(bodyData.getHosp_pat_id());
          //   deljournalCreateRequestPayload.setPatId(Long.valueOf(bodyData.getPat_id()));
          //   deljournalCreateRequestPayload.setUserId(Long.valueOf(bodyData.getUser_id()));
          //   deljournalCreateRequestPayload.setOpeCd(opeCd);
          //   deljournalCreateRequestPayload.setOrdNo(ord.getOrdNo());
          //   deljournalCreateRequestPayload.setBaseDate(ord.getTreatDate());
          //   ctlNoList.add(deljournalCreateRequestPayload);
          // }
          // del #11004 連携イベント発生部分不正 piao end
          JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
          journalCreateRequestPayload.setFacilityCd(bodyData.getFacility_cd());
          journalCreateRequestPayload.setCrud("U");
          // del #11004 連携イベント発生部分不正 piao start
          // if (modify_send_class == 2) {
          //   journalCreateRequestPayload.setCrud("C");
          // }
          // del #11004 連携イベント発生部分不正 piao end
          journalCreateRequestPayload.setHospPatId(bodyData.getHosp_pat_id());
          journalCreateRequestPayload.setPatId(Long.valueOf(bodyData.getPat_id()));
          journalCreateRequestPayload.setUserId(Long.valueOf(bodyData.getUser_id()));
          journalCreateRequestPayload.setOpeCd(opeCd);
          journalCreateRequestPayload.setOrdNo(ord.getOrdNo());
          journalCreateRequestPayload.setBaseDate(ord.getTreatDate());
          // journalCreateRequestPayload.setCtlNo(sysCoopJournalDao.selectNextSeqCtlNo());
          // sysCoopJournalDao.insert(journalCreateRequestPayload);
          // ctlNoList.add(journalCreateRequestPayload.getCtlNo());
          ctlNoList.add(journalCreateRequestPayload);
        }
        // mod 2023-01-14 bug #7627 修正 chen end
      }
    }
    JournalCreatecallNextPatIdRequestResponse response = new JournalCreatecallNextPatIdRequestResponse();
    response.setResponse(new ResponseEntity<>(responseData.toString(), (org.springframework.http.HttpHeaders) null, HttpStatus.OK));
    response.setCtlNoList(ctlNoList);
    response.setCallNextPatList(nextPatList);
    //mod 7213 2023-03-25 治療途中に追加した薬剤の投与タイミング通知が装置に表示されない 張 end
    return response;
  }

  @Transactional
  @Override
  public JournalCreateRequestResponse updateIndComment(ApiEntityOrdMain.ValiCommentCreate bodyData, Long userId) {
    StringBuilder sb = new StringBuilder();
    sb.append("患者ID: " + bodyData.getPat_id()).append(System.getProperty("line.separator"))
      .append("施設コード: " + bodyData.getFacility_cd()).append(System.getProperty("line.separator"))
      .append("開始日: " + bodyData.getStart_date()).append(System.getProperty("line.separator"))
      .append("終了日: " + bodyData.getEnd_date()).append(System.getProperty("line.separator"))
      .append("クール: " + bodyData.getInd_kur_cd()).append(System.getProperty("line.separator"))
      .append("治療方法: " + bodyData.getInd_treatment_cd()).append(System.getProperty("line.separator"))
      .append("コメント番号: " + bodyData.getNum_comment()).append(System.getProperty("line.separator"))
      .append("変更前指示コメント: " + bodyData.getInit_comment()).append(System.getProperty("line.separator"))
      .append("指示コメント: " + bodyData.getComment()).append(System.getProperty("line.separator"))
      .append("指示者ID: " + bodyData.getInd_user_id()).append(System.getProperty("line.separator"))
      .append("更新者ID: " + bodyData.getUpd_user_id());
    EventLogMessage message = new EventLogMessage();
    message.setLogMessage(sb.toString());
    logService.log(LogLevel.DEBUG, message, "", SERVICE_NAME.FNSI, null);

    // 現在の日時取得
    Timestamp up_date = Timestamp.valueOf(LocalDateTime.now());

    // 患者ID
    Long patId = null;
    if (bodyData.getPat_id() != null) {
      patId = Long.parseLong(bodyData.getPat_id());
    }
    // 開始日
    int startDate = Integer.parseInt(bodyData.getStart_date().replaceAll("-", ""));
    // 終了日
    int endDate = Integer.parseInt(bodyData.getEnd_date().replaceAll("-", ""));
    // 編集可能曜日
    List<Integer> weeksArray = IndicationUtils.getWeekPattern((String) bodyData.getWeeks());
    // 指示コメント番号
    int commentNum = 0;
    if (bodyData.getNum_comment() != null) {
      commentNum = Integer.parseInt(bodyData.getNum_comment());
    }

    //Jsonデータの組み立て
    JSONObject indCommentInfo = new JSONObject();
    List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
    /* add by chamaojia 2024-01-26 [10196]  Add variable definition --start */
    Long indUserId = bodyData.getInd_user_id() != null ? Long.parseLong(bodyData.getInd_user_id()) : null;
    Long updUserId = bodyData.getUpd_user_id() != null ? Long.parseLong(bodyData.getUpd_user_id()) : null;
    /* add by chamaojia 2024-01-26 [10196]  Add variable definition --end */
    try {
      // 指示コメント番号
      indCommentInfo.put("no", commentNum);
      // 指示コメント内容
      if (StringUtils.isEmpty(bodyData.getComment())) {
        indCommentInfo.put("content", JSONObject.NULL);
      } else {
        indCommentInfo.put("content", bodyData.getComment());
      }
      // 指示者名_姓
      indCommentInfo.put("ind_user_last_name",
        StringUtils.isEmpty(bodyData.getInd_user_last_name()) ? "" : bodyData.getInd_user_last_name());
      // 指示者名_名
      indCommentInfo.put("ind_user_first_name",
        StringUtils.isEmpty(bodyData.getInd_user_first_name()) ? "" : bodyData.getInd_user_first_name());
      // 指示者コード
      /* modify by chamaojia 2024-01-26 [10196]  User Information Query Table Translation --start */
      indCommentInfo.put("ind_user_id", indUserId == null ? JSONObject.NULL : indUserId);
//      // 更新者名_姓
//      indCommentInfo.put("upd_user_last_name",
//        StringUtils.isEmpty(bodyData.getUpd_user_last_name()) ? "" : bodyData.getUpd_user_last_name());
//      // 更新者名_名
//      indCommentInfo.put("upd_user_first_name",
//        StringUtils.isEmpty(bodyData.getUpd_user_first_name()) ? "" : bodyData.getUpd_user_first_name());
      // 更新者コード
      indCommentInfo.put("upd_user_id", updUserId != null ? updUserId : JSONObject.NULL);
      MasterCacheHandler masterCacheHandler = MasterCacheHandler.get();
      MstPersonalUser updUserInfo = updUserId != null ? masterCacheHandler.getMstPersonalUser(updUserId) : null;
      if (updUserInfo != null) {
        // 更新者名_姓
        indCommentInfo.put("upd_user_last_name", updUserInfo.getUserLastName());
        // 更新者名_名
        indCommentInfo.put("upd_user_first_name", updUserInfo.getUserFirstName());
      } else {
        indCommentInfo.put("upd_user_last_name", JSONObject.NULL);
        indCommentInfo.put("upd_user_first_name", JSONObject.NULL);
      }
      /* modify by chamaojia 2024-01-26 [10196]  User Information Query Table Translation --end */
      /* modify by chamaojia 2024-01-26 [10196]  Default value setting modification --start */
      // 登録区分
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //indCommentInfo.put("input_class", StringUtils.isEmpty(bodyData.getInput_class()) ? "" : Integer.parseInt(bodyData.getInput_class()));
      indCommentInfo.put("input_class", StringUtils.isEmpty(bodyData.getInput_class()) ? 1 : bodyData.getInput_class());
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      // mod FNSI-FutreNetWeb+SI課題管理No.5500 李 start
      // 編集可否フラグ
      // indCommentInfo.put("is_editable", StringUtils.isEmpty(bodyData.getIs_editable()) ? "" : bodyData.getIs_editable());
      indCommentInfo.put("is_editable", "1");
      // mod FNSI-FutreNetWeb+SI課題管理No.5500 李 end
      // 連携オーダー番号
      indCommentInfo.put("cop_order_no", JSONObject.NULL);
      /* modify by chamaojia 2024-01-26 [10196]  Default value setting modification --end */
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
      }
      eventLogMessage.setLogMessage("Jsonデータの作成に失敗しました");
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      JournalCreateRequestResponse response = new JournalCreateRequestResponse();
      response.setResponse(new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST));
      response.setCtlNoList(ctlNoList);
      return response;
    }
    List<OrdMain> ordMain = new ArrayList();
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
    String isRstUpdate = bodyData.getIs_rst_update();
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
    // オーダー番号リスト
    List<Long> ordNoList = new ArrayList();
    //mod FNSI-redmine6539 fang start
    if (bodyData.getIs_deadline() != null && ! "false".equals(bodyData.getIs_deadline())) {
      if (bodyData.getOrd_no() != null) {
        Long ordNo = Long.parseLong(bodyData.getOrd_no());
        ordNoList.add(ordNo);
      }
      /**
      else {
        for (int i = 0; i < ordMain.size(); i++) {
          ordNoList.add(ordMain.get(i).getOrdNo());
        }
      }
    } else {
      for (int i = 0; i < ordMain.size(); i++) {
        ordNoList.add(ordMain.get(i).getOrdNo());
      }
       */
    }
    if(!ordNoList.isEmpty()){
      // 更新対象ordNo List取得
      ordMain = ordMainService.selectByOrdNoList(ordNoList);
    }else {
      //mod 10416 治療記録＞回診記録の指示コメント展開バグ zhao end
      // 更新対象ordNo List取得
//      ordMain = ordMainService.findUpdateTarget(
//        patId,
//        bodyData.getFacility_cd(),
//        String.valueOf(startDate),
//        String.valueOf(endDate),
//        weeksArray,
//        //mod 指示コメント修正 房 start
//        // this.getValueList(bodyData.getInd_treatment_cd()),
//        // this.getLongList(bodyData.getInd_kur_cd())
//        // del FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 start
//        // new ArrayList<Integer>(),
//        // new ArrayList<Long>()
//        // del FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 end
//        //mod 指示コメント修正 房 end
//        // add FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 start
//        "1".equals(bodyData.getGenDifferentiation()) ? ordMainResource.getValueList(bodyData.getInd_treatment_cd()) : new ArrayList<Integer>(),
//        "1".equals(bodyData.getGenDifferentiation()) ? ordMainResource.getLongList(bodyData.getInd_kur_cd()) : new ArrayList<Long>()
//        // add FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 end
//      );
      if(bodyData.getOrd_no() == null){
        // 更新対象ordNo List取得
        ordMain = ordMainService.findUpdateTarget(
          patId,
          bodyData.getFacility_cd(),
          String.valueOf(startDate),
          String.valueOf(endDate),
          weeksArray,
          //mod 指示コメント修正 房 start
          // this.getValueList(bodyData.getInd_treatment_cd()),
          // this.getLongList(bodyData.getInd_kur_cd())
          // del FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 start
          // new ArrayList<Integer>(),
          // new ArrayList<Long>()
          // del FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 end
          //mod 指示コメント修正 房 end
          // add FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 start
          "1".equals(bodyData.getGenDifferentiation()) ? ordMainResource.getValueList(bodyData.getInd_treatment_cd()) : new ArrayList<Integer>(),
          "1".equals(bodyData.getGenDifferentiation()) ? ordMainResource.getLongList(bodyData.getInd_kur_cd()) : new ArrayList<Long>()
          // add FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 end
        );

        //add #10266 start
        if("2".equals(bodyData.getUpdate_flag())){
            ordMain = ordMain.stream().filter(ord -> "0".equals(ord.getRstDialysisState())).collect(Collectors.toList());
        }
        //add #10266 end

      }else{
        // 更新対象ordNo List取得
        ordMain = ordMainService.findUpdateTarget(
          patId,
          bodyData.getFacility_cd(),
          String.valueOf(startDate),
          String.valueOf(endDate),
          weeksArray,
          //mod 指示コメント修正 房 start
          // this.getValueList(bodyData.getInd_treatment_cd()),
          // this.getLongList(bodyData.getInd_kur_cd())
          // del FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 start
          // new ArrayList<Integer>(),
          // new ArrayList<Long>()
          // del FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 end
          //mod 指示コメント修正 房 end
          // add FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 start
          "1".equals(bodyData.getGenDifferentiation()) ? ordMainResource.getValueList(bodyData.getInd_treatment_cd()) : new ArrayList<Integer>(),
          "1".equals(bodyData.getGenDifferentiation()) ? ordMainResource.getLongList(bodyData.getInd_kur_cd()) : new ArrayList<Long>(),
          "0"
          // add FNSI-患者経過総合ビューア_修正内容1.xlsx 対応 李 end
        );
        List<Long> ordNoListToDay = new ArrayList();
        ordNoListToDay.add(Long.parseLong(bodyData.getOrd_no()));
        ordMain.addAll(ordMainService.selectByOrdNoList(ordNoListToDay));
      }
      //mod 10416 治療記録＞回診記録の指示コメント展開バグ zhao end
    }

    if(ordMain.isEmpty()){
      JournalCreateRequestResponse response = new JournalCreateRequestResponse();
      response.setResponse(ResponseEntity.ok().build());
      response.setCtlNoList(ctlNoList);
      return response;
    }

    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Store a copy of the data before editing to Mongo, alternative method: getHistory(ord_no) in method updateOrdMainEquipInfo(), And Optimized for batch insertion --start */
    List<Long> ordNoListForMongoLog = ordMain.stream().map(ordMain1 -> ordMain1.getOrdNo()).collect(Collectors.toList());
    selectHistoryUtils.insertMangoDbHistoryBatch(ordNoListForMongoLog);
    /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Store a copy of the data before editing to Mongo, alternative method: getHistory(ord_no) in method updateOrdMainEquipInfo(), And Optimized for batch insertion --end */

    //mod FNSI-redmine6539 fang end
    try {
      // add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
      Set<String> oldIndContents = new HashSet<>();
      // add 11555 指示履歴への記録の残り方が仕様と異なる zkm end
      for (OrdMain ord : ordMain) {
        // 指示コメント新規登録処理、指示コメント編集処理
        if (bodyData.getComment_flag().equals("1") || bodyData.getComment_flag().equals("2")) {
          boolean hasPutCommentNo = false;
          /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
          //JSONArray indCommentJsonArr = new JSONArray(ord.getIndIndCommentInfo());
          JSONArray indCommentJsonArr = new JSONArray(ObjectUtils.isEmpty(ord.getIndIndCommentInfo())? "[]" : ord.getIndIndCommentInfo());
          /* mod by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
          for (int i = 0; i < indCommentJsonArr.length(); i++) {
            JSONObject indCommentJson = indCommentJsonArr.getJSONObject(i);
            int commentNo = indCommentJson.getInt("no");
            if (commentNum == commentNo) {
              indCommentJsonArr.put(i,indCommentInfo);
              hasPutCommentNo = true;
              // add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
              oldIndContents.add(Objects.isNull(indCommentJson.get("content")) ? "" : indCommentJson.get("content").toString());
              // add 11555 指示履歴への記録の残り方が仕様と異なる zkm end
              break;
            }
          }
          // mod #10266 子指示ボタンをクリックして指示された治療計画から指示されていない治療計画に変更し、エラーをクリックして、現在の指示ボタンを誤って保存する 20240508 ztc start
          //if(!hasPutCommentNo){
          if(!hasPutCommentNo && bodyData.getComment_flag().equals("1")){
            indCommentJsonArr.put(indCommentInfo);
          }
          // mod #10266 子指示ボタンをクリックして指示された治療計画から指示されていない治療計画に変更し、エラーをクリックして、現在の指示ボタンを誤って保存する 20240508 ztc end
          //mod FNSI-redmine8338 ljx start
          //回診記録から指示コメントへ転記する時がある。その場合、実績のみに登録する
          //回診記録画面でind_rst_flagを"rst"で設定する、他の画面には8338修正済みの時点ではまだ存在しない。
          //ord.setIndIndCommentInfo(indCommentJsonArr.toString());
          //mod 10416 治療記録＞回診記録の指示コメント展開バグ zhao start
          if(bodyData.getOrd_no() == null){
            if(bodyData.getInd_rst_flag() == null || !"rst".equals(bodyData.getInd_rst_flag())){
              ord.setIndIndCommentInfo(indCommentJsonArr.toString());
            }
          }else{
            ord.setIndIndCommentInfo(indCommentJsonArr.toString());
          }
          //mod 10416 治療記録＞回診記録の指示コメント展開バグ zhao end
          //mod FNSI-redmine8338 ljx end

          if (AdminWebConstant.OrdMainConst.DialysisState.BEFORE_SEND.equals(ord.getRstDialysisState()) || "false".equals(isRstUpdate)) {
          } else {
            /* modify by chamaojia 2024-01-26 [10196]  Delete user content in JSON item --start */
            JSONObject indCommentInfoToRst = new JSONObject(indCommentInfo.toString());
            indCommentInfoToRst.remove("ind_user_id");
            indCommentInfoToRst.remove("ind_user_last_name");
            indCommentInfoToRst.remove("ind_user_first_name");
            indCommentInfoToRst.remove("upd_user_id");
            indCommentInfoToRst.remove("upd_user_last_name");
            indCommentInfoToRst.remove("upd_user_first_name");
            hasPutCommentNo = false;
            /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
//            JSONArray rstCommentJsonArr = new JSONArray(ord.getRstIndCommentInfo());
            JSONArray rstCommentJsonArr = new JSONArray(ObjectUtils.isEmpty(ord.getRstIndCommentInfo()) ? "[]" : ord.getRstIndCommentInfo());
            /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
            for (int i = 0; i < rstCommentJsonArr.length(); i++) {
              JSONObject rstCommentJson = rstCommentJsonArr.getJSONObject(i);
              int commentNo = rstCommentJson.getInt("no");
              if (commentNum == commentNo) {
                rstCommentJsonArr.put(i,indCommentInfoToRst);
                hasPutCommentNo = true;
                break;
              }
            }
            if(!hasPutCommentNo){
              rstCommentJsonArr.put(indCommentInfoToRst);
            }
            ord.setRstIndCommentInfo(rstCommentJsonArr.toString());
            /* modify by chamaojia 2024-01-26 [10196]  Delete user content in JSON item --end */
          }
          // 指示コメント編集処理
        } else if (bodyData.getComment_flag().equals("3")) {
          if(!ObjectUtils.isEmpty(ord.getIndIndCommentInfo())) { // add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える
            JSONArray indCommentJsonArr = new JSONArray(ord.getIndIndCommentInfo());
            for (int i = 0; i < indCommentJsonArr.length(); i++) {
              JSONObject indCommentJson = indCommentJsonArr.getJSONObject(i);
              int commentNo = indCommentJson.getInt("no");
              if (commentNum == commentNo) {
                indCommentJsonArr.remove(i);
                // add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
                oldIndContents.add(Objects.isNull(indCommentJson.get("content")) ? "" : indCommentJson.get("content").toString());
                // add 11555 指示履歴への記録の残り方が仕様と異なる zkm end
                break;
              }
            }
            ord.setIndIndCommentInfo(indCommentJsonArr.toString());
          }

          if (AdminWebConstant.OrdMainConst.DialysisState.BEFORE_SEND.equals(ord.getRstDialysisState()) || "false".equals(isRstUpdate)) {
          } else {
            if(!ObjectUtils.isEmpty(ord.getRstIndCommentInfo())) { // add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える
              JSONArray rstCommentJsonArr = new JSONArray(ord.getRstIndCommentInfo());
              for (int i = 0; i < rstCommentJsonArr.length(); i++) {
                JSONObject rstCommentJson = rstCommentJsonArr.getJSONObject(i);
                int commentNo = rstCommentJson.getInt("no");
                if (commentNum == commentNo) {
                  rstCommentJsonArr.remove(i);
                  break;
                }
              }
              ord.setRstIndCommentInfo(rstCommentJsonArr.toString());
            }
          }
        }

        /* del by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
        /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Move code block here ( search move7734 )  start */
//        JSONObject indScheduleUserInfoJObj = new JSONObject(ord.getIndScheduleUserInfo());
//        //中止画面からの指示者が元々の指示者と不一致の場合、指示者が変更することにする。
//        String edit_ind_user_id = String.valueOf(userId);
//        String ind_schedule_ind_user_id = StrUtils.getStrFromJSONObject(indScheduleUserInfoJObj,"ind_user_id");
//        if(!edit_ind_user_id.equals(ind_schedule_ind_user_id)) {
//          //ind_user_id（指示者）の値を変更。
//          indScheduleUserInfoJObj.put("ind_user_id", Long.valueOf(edit_ind_user_id));
//          String edit_ind_user_first_name = StrUtils.getStrFromJSONObject(indCommentInfo,"ind_user_first_name");
//          if (!StringUtils.isEmpty(edit_ind_user_first_name)) {
//            indScheduleUserInfoJObj.put("ind_user_first_name", edit_ind_user_first_name);
//          }
//          String edit_ind_user_last_name = StrUtils.getStrFromJSONObject(indCommentInfo,"ind_user_last_name");
//          if (!StringUtils.isEmpty(edit_ind_user_last_name)) {
//            indScheduleUserInfoJObj.put("ind_user_last_name", edit_ind_user_last_name);
//          }
//          ord.setIndScheduleUserInfo(indScheduleUserInfoJObj.toString());
//        }
        /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Move code block here ( search move7734 )  end */
        /* del by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */
        //mod 8277 周安寧 start
        //updateOrdMainCommentInfo(ord,userId,userId);
        /* del by chamaojia 2023-03-27 [6961] 循環外バッチ処理へ移動 --start */
//        updateOrdMainCommentInfo(ord);
        /* del by chamaojia 2023-03-27 [6961] 循環外バッチ処理へ移動 --end */
        //mod 8277 周安寧 end
      }
      /* add by chamaojia 2023-03-27 [6961] 新規一括処理コール --start */
      //mod 9806 ljx start 指示コメント
      //updateOrdMainCommentInfoByList(ordMain);
      /* modify by chamaojia 2024-01-26 [10196] Add Method Reference --start */
      updateOrdMainCommentInfoByList(ordMain, "true".equals(bodyData.getIs_rst_update())
              , indUserId, updUserId, (bodyData.getInd_rst_flag() == null || !"rst".equals(bodyData.getInd_rst_flag())) ? true : false);
      /* modify by chamaojia 2024-01-26 [10196] Add Method Reference --end */
      //mod 9806 ljx end
      /* add by chamaojia 2023-03-27 [6961] 新規一括処理コール --end */

      //指示履歴を登録
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      indHistoryMakeService.createCommentHistory(bodyData, bodyData.getComment_flag(), weeksArray);
      indHistoryMakeService.createCommentHistory(bodyData, bodyData.getComment_flag(), weeksArray, oldIndContents.stream().toList());
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
      // 終了日が無期限の場合患者治療パターンを更新する
      if ("false".equals(bodyData.getIs_deadline())) {
        PatTreatmentPatternUtils.PatTreatmentPatternEditData editData = new PatTreatmentPatternUtils.PatTreatmentPatternEditData();
        // 患者治療パターン用指示コメントデータの作成
        List<String> indComInfo = new ArrayList<String>();
        // String型のListに指示コメント情報を格納
        indComInfo.add(indCommentInfo.toString());
        // 患者治療パターン編集情報に指示コメント編集データを格納
        editData.setIndIndCommentInfo(indComInfo.toString());
        if (bodyData.getComment_flag().equals("1")) {
          // 患者治療パターン項目新規登録処理
          int patPatternCount = patTreatmentPatternUtils.insertPatTreatmentPatternIndItemForIndMediAndEquip(
            Long.parseLong(bodyData.getPat_id()),
            bodyData.getFacility_cd(),
            //mod 指示コメント修正 房 start
//                this.getValueList(bodyData.getInd_treatment_cd()),
//                this.getLongList(bodyData.getInd_kur_cd()),
            new ArrayList<Integer>(),
            new ArrayList<Long>(),
            //mod 指示コメント修正 房 end
            weeksArray,
            PatTreatmentPatternUtils.IND_ITEM.IND_COMMENT,
            up_date,
            editData
          );
        } else if (bodyData.getComment_flag().equals("2")) {
          // 患者治療パターン項目更新処理
          int patPatternCount = patTreatmentPatternUtils.updatePatTreatmentPatternIndItem(
            Long.parseLong(bodyData.getPat_id()),
            bodyData.getFacility_cd(),
            ordMainResource.getValueList(bodyData.getInd_treatment_cd()),
            ordMainResource.getLongList(bodyData.getInd_kur_cd()),
            weeksArray,
            Arrays.asList(PatTreatmentPatternUtils.IND_ITEM.IND_COMMENT),
            up_date,
            editData,
            // modify 9664 by kangjie 20240425 start
            ordMain,new ArrayList<MstTreatment>()
            // modify 9664 by kangjie 20240425 end
            // add 10150_9664 by kangjie 20240628 start
            ,null
            // add 10150_9664 by kangjie 20240628 end
            );
        } else {
          // 患者治療パターン項目削除処理
          int patPatternCount = patTreatmentPatternUtils.deletePatTreatmentPatternIndItemForIndMediAndEquip(
            Long.parseLong(bodyData.getPat_id()),
            bodyData.getFacility_cd(),
            ordMainResource.getValueList(bodyData.getInd_treatment_cd()),
            ordMainResource.getLongList(bodyData.getInd_kur_cd()),
            weeksArray,
            PatTreatmentPatternUtils.IND_ITEM.IND_COMMENT,
            up_date,
            editData
          );
        }
      }

      //del #10412 次患者更新関連全体見直し対応 朴 start
      // 指示コメント関連の指示変更は次患者情報１or２への影響がないため、次患者更新処理は不要である
//      String facilityCd = bodyData.getFacility_cd();
//      Long skipCode = Long.parseLong("0");
//      LocalDateTime update = LocalDateTime.now();
//      // 次患者更新処理
//      for (OrdMain ord : ordMain) {
//        Long bedCd = Long.parseLong(ord.getIndBedCd().toString());
//        Long targetOrdNo = ord.getOrdNo();
//        // 登録されているベッド(ベッド移動なしのため変更後として処理※変更前は条件送信キャンセルとして処理されるため)
//        //mod FNSI-修正 redmine4683 房 start
//        int dialysisState = 0;
//        if (ord.getRstDialysisState() != null) {
//          dialysisState = Integer.parseInt(ord.getRstDialysisState());
//        }
//        if (dialysisState == 1) {
//          /* mod #5482 by zhangruixue 2023-03-02 スケジュール --start */
////          ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, targetOrdNo, true, update);
//          ordMainResource.callDoCancelSetNextPatInfo(facilityCd, skipCode, bedCd, ord, true, update);
//          /* mod #5482 by zhangruixue 2023-03-02 スケジュール --end */
//        }
//        //mod FNSI-修正 redmine4683 房 end
//      }
      //del #10412 次患者更新関連全体見直し対応 朴 end

    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessage.setFacilityCd(bodyData.getFacility_cd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      JournalCreateRequestResponse response = new JournalCreateRequestResponse();
      response.setResponse(new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST));
      response.setCtlNoList(ctlNoList);
      return response;
    }
    if (bodyData.getHosp_pat_id() == null || "".equals(bodyData.getHosp_pat_id())) {
      JournalCreateRequestResponse response = new JournalCreateRequestResponse();
      response.setResponse(ResponseEntity.ok().build());
      response.setCtlNoList(ctlNoList);
      return response;
    }
    if ("1".equals(bodyData.getGenDifferentiation())) {
      List<Integer> treatCdList = ordMain.stream().map(OrdMain::getIndTreatmentCd).distinct().collect(Collectors.toList());
      List<MstTreatment> mstTreatList = treatCdList.stream().map(treatCd -> mstTreatmentDao.selectByCd(treatCd)).collect(Collectors.toList());
      for (MstTreatment mstTreat : mstTreatList) {
        List<OrdMain> ordMainList = ordMain.stream()
          .filter(o -> o.getIndTreatmentCd().equals(mstTreat.getTreatmentCd())).collect(Collectors.toList());
        //7771-------------------------------ljg start
/* Commented out by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: To move this update above ( search move7734 above ) -- start */
//        //7734 指示者変更の場合 lig stsrt
//        ordMainList.stream()
//          .forEach(item -> {
//            String indScheduleUserInfo  = item.getIndScheduleUserInfo();
//            JSONObject indScheduleUserInfoJObj = new JSONObject(indScheduleUserInfo);
//            //中止画面からの指示者が元々の指示者と不一致の場合、指示者が変更することにする。
//            if(!bodyDataIndUserid.equals((indScheduleUserInfoJObj.get("ind_user_id")).toString())){
//              //ind_user_id（指示者）の値を変更。
//              indScheduleUserInfoJObj.put("ind_user_id",Long.valueOf((bodyDataIndUserid)));
//              if(bodyDataIndUserlastname!=null &&
//                ! "" .equals(bodyDataIndUserlastname)){
//                indScheduleUserInfoJObj.put("ind_user_last_name",(bodyDataIndUserlastname));
//              }
//              if(bodyDataIndUserfristname!=null &&
//                ! "" .equals(bodyDataIndUserfristname)
//              ){
//                indScheduleUserInfoJObj.put("ind_user_first_name",(bodyDataIndUserfristname));
//              }
////              indScheduleUserInfoJObj.put("ind_user_last_name",(bodyDataIndUserlastname));
////              indScheduleUserInfoJObj.put("ind_user_first_name",(bodyDataIndUserfristname));
//              indScheduleUserInfo = indScheduleUserInfoJObj.toString();
//              //指示者が変更されたのデータを更新する。
//              if(item.getOrdNo() !=null && !item.getOrdNo().equals("")){
//                ordMainDao.updateInduser(Long.valueOf(item.getOrdNo()),indScheduleUserInfo);
//              }
//            }
//          });
//        //7734 指示者変更の場合 lig end
/* Commented out by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: To move this update above ( search move7734 above ) -- end */
        if (ordMainList.size()>0) {
          //7771-------------------------------ljg end
          // オペコードを設定する
          //String opeCd = "004024"; (160)
          String opeCd = "004029";
          // mod 2023-01-14 bug #7627 修正 chen start
          // JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
          // // SysCoopJournal journalCreateRequestPayload = new SysCoopJournal();
          // JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
          // journalCreateRequestPayload.setFacilityCd(bodyData.getFacility_cd());
          // journalCreateRequestPayload.setCrud("U");
          // journalCreateRequestPayload.setHospPatId(bodyData.getHosp_pat_id());
          // journalCreateRequestPayload.setPatId(Long.valueOf(bodyData.getPat_id()));
          // journalCreateRequestPayload.setUserId(Long.valueOf(bodyData.getUser_id()));
          // journalCreateRequestPayload.setOpeCd(opeCd);
          // asyncService.sendExternalConnection(ordMainList, journalCreateRequestPayload);
          // List<Long> ctlNoList = new ArrayList<>();
          for (OrdMain ord : ordMainList) {
              if(ord.getIndKurCd() == null || ord.getIndKurCd().equals(0)){
                  opeCd = "004229";
                }else {
                  opeCd = "004029";
                }
            // mod 10553 指示コメント編集連携送信 関  start
            // del #11004 連携イベント発生部分不正 piao start
            // JournalCreateRequestPayload delJournalCreateRequestPayload = new JournalCreateRequestPayload();
            // del #11004 連携イベント発生部分不正 piao end
            JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
            // del #11004 連携イベント発生部分不正 piao start
            // int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(bodyData.getFacility_cd());
            // if (modify_send_class == 2) {
            //   delJournalCreateRequestPayload.setFacilityCd(bodyData.getFacility_cd());
            //   delJournalCreateRequestPayload.setCrud("D");
            //   delJournalCreateRequestPayload.setHospPatId(bodyData.getHosp_pat_id());
            //   delJournalCreateRequestPayload.setPatId(Long.valueOf(bodyData.getPat_id()));
            //   delJournalCreateRequestPayload.setUserId(Long.valueOf(bodyData.getUser_id()));
            //   delJournalCreateRequestPayload.setOpeCd(opeCd);
            //   delJournalCreateRequestPayload.setOrdNo(ord.getOrdNo());
            //   delJournalCreateRequestPayload.setBaseDate(ord.getTreatDate());
            //   ctlNoList.add(delJournalCreateRequestPayload);
            // }
            // del #11004 連携イベント発生部分不正 piao end
            journalCreateRequestPayload.setFacilityCd(bodyData.getFacility_cd());
            // mod #10553 連携イベント発生部分不正 piao start
            journalCreateRequestPayload.setCrud("U");
            // if (modify_send_class == 2) {
            //   journalCreateRequestPayload.setCrud("C");
            // }else {
            //   journalCreateRequestPayload.setCrud("U");
            // }
            // mod #10553 連携イベント発生部分不正 piao end
            journalCreateRequestPayload.setHospPatId(bodyData.getHosp_pat_id());
            journalCreateRequestPayload.setPatId(Long.valueOf(bodyData.getPat_id()));
            journalCreateRequestPayload.setUserId(Long.valueOf(bodyData.getUser_id()));
            journalCreateRequestPayload.setOpeCd(opeCd);
            journalCreateRequestPayload.setOrdNo(ord.getOrdNo());
            journalCreateRequestPayload.setBaseDate(ord.getTreatDate());
            // journalCreateRequestPayload.setCtlNo(sysCoopJournalDao.selectNextSeqCtlNo());
            // sysCoopJournalDao.insert(journalCreateRequestPayload);
            // ctlNoList.add(journalCreateRequestPayload.getCtlNo());
            ctlNoList.add(journalCreateRequestPayload);
            // mod 10553 指示コメント編集連携送信 関  end
          }
          // mod 2023-01-14 bug #7627 修正 chen end
        }
      }
    }
    JournalCreateRequestResponse response = new JournalCreateRequestResponse();
    response.setResponse(ResponseEntity.ok().build());
    response.setCtlNoList(ctlNoList);
    return response;
  }
  // mod bug 8157 修正 chen end

  // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.90(外結)対応 韓 start

  /**
   * 通知メッセージの登録処理
   * 有効な投与タイミングメッセージを通知メッセージテーブルにを登録
   */
  private void registMedicalNotify(JSONObject editMediJson,String patId, String facilityCd,Long ordNo,Map<String, Object> namesMap,PatPersonalMain patPersonalMain, MasterCacheHandler masterCacheHandler) throws RuntimeException {
    MstMedicateTiming mediTiming = editMediJson.isNull("timing_cd") ?
      new MstMedicateTiming() : masterCacheHandler.getMstMedicateTimingByCd((int) editMediJson.get("timing_cd"));
    // 通知フラグ('1'：通知する)
    String isAlert = mediTiming.getIsAlert();
    //add FNSI-redmine5640 劉祥霖 start
    String dialysisProgressCd = mediTiming.getDialysisProgressCd();
    //add FNSI-redmine5640 劉祥霖 end
    if (isAlert != null && isAlert.equals("1")
      //add FNSI-redmine5640 劉祥霖 start
      && dialysisProgressCd != null && dialysisProgressCd.equals("002")) {
      //add FNSI-redmine5640 劉祥霖 end
      JSONObject replaceData = new JSONObject();
      if (namesMap.size() > 0) {
        // 指示：ベッド名
        String indBedName = namesMap.containsKey("bed_name") ? (namesMap.get("bed_name") != null ? namesMap.get("bed_name").toString() : "") : "";
        replaceData.put("BEDNAME", indBedName);
      }
      replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
      replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
      replaceData.put("ORDNO", String.valueOf(ordNo));
      //mod FNSI redmine 6706 劉祥霖　start
      replaceData.put("PATID", patId);
//    replaceData.put("PATID",  bodyData.getPat_id());
      //mod FNSI redmine 6706 劉祥霖　end
      replaceData.put("FACILITYCD", facilityCd);

      Integer cd = editMediJson.has("cd") ? editMediJson.getInt("cd") : null;
      Integer medicineType = editMediJson.has("medicine_type") ? editMediJson.getInt("medicine_type") : null;
      //取得したコードを元に薬剤情報から名称を取得(DBから)
      if (cd != null && medicineType != null) {
        Map<String, Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
          facilityCd,
          medicineType,
          cd
        );
        String medicineName = mediMap.containsKey("name") ? mediMap.get("name").toString() : "";
        replaceData.put("MEDICINENAME", medicineName);
      }

      // add FNSI-FutreNetWeb+SI課題管理No.4750 李 start
      threadExector.execute(new Runnable() {
        @Override
        public void run() {
          try {
            webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.MEDICINE_TYMING, facilityCd, replaceData);
          } catch (URISyntaxException e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (!StringUtils.isEmpty(facilityCd)) {
              eventLogMessage.setFacilityCd(facilityCd);
            }
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          }
        }
      });
      // add FNSI-FutreNetWeb+SI課題管理No.4750 李 end
    }
    return;
  }
// add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.90(外結)対応 韓 end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240913 start
  /**
   * 投与薬剤情報の展開情報の追加
   *
   * @summary 条件送信後に展開する情報を更新する情報に追加する
   */
  private JSONObject getMediDeployInfo(Long patId, String facilityCd, JSONObject editData, MasterCacheHandler masterCacheHandler) {
    /* modify by chamaojia 2024-01-22 [10196]  'Unit' supplementary translation and null value handling --start */
    Integer medicineMixCd = editData.getInt("cd");
    // 対象が調整薬剤の場合はそちらへ上書き
    if (! editData.isNull("medicine_type") && editData.getInt("medicine_type") == 2) {
      // 調製薬剤マスタ取得
      //MstMedicineMix medicineMix = mstMedicineMixDao.selectByCd(facilityCd, editData.getInt("cd"));
      MstMedicineMix medicineMix = masterCacheHandler.getMstMedicineMixByCd(medicineMixCd);
      // 薬剤分類マスタ取得
      MstMedicineClass mstMedicineClass = medicineMix.getClassCd() == null ? new MstMedicineClass() : masterCacheHandler.getMstMedicineClassByCd(medicineMix.getClassCd());
      // 手技マスタ取得
      MstProcedure procedure = editData.isNull("procedure_cd") ? new MstProcedure() : masterCacheHandler.getMstProcedureByCd((int) editData.get("procedure_cd"));
      // 投与タイミングマスタ取得
      MstMedicateTiming mediTiming = editData.isNull("timing_cd") ? new MstMedicateTiming() : masterCacheHandler.getMstMedicateTimingByCd((int) editData.get("timing_cd"));
      // TODO:ここでセットすると画面表示した値と不一致になる場合があるため、編集時には要確認
      // mod FNSI-【1006】障害票一覧_患者経過総合ビューアNo52対応 韓 start
//      editData.put("class_name", mstMedicineClass.getClassName());
//      editData.put("class_cd", medicineMix.getClassCd());
//      editData.put("class_type", mstMedicineClass.getClassType());
//      editData.put("name", medicineMix.getMedicineMixName());
//      editData.put("short_name", medicineMix.getMedicineMixShortName());
//      //editData.put("unit", medicine.getUnit());
//      editData.put("timing_name", mediTiming.getMedicateTimingName());
//      editData.put("procedure_name", procedure.getPricedureName());
      if (! Objects.isNull(mstMedicineClass)) {
        editData.put("class_name", changeToJSONObjectNull(mstMedicineClass.getClassName()));
        editData.put("class_type", changeToJSONObjectNull(mstMedicineClass.getClassType()));
      } else {
        editData.put("class_name", JSONObject.NULL);
        editData.put("class_type", JSONObject.NULL);
      }
      if (! Objects.isNull(medicineMix)) {

        MstTabooAllergy mstTabooAllergy = new MstTabooAllergy();
        mstTabooAllergy.setFacilityCd(facilityCd);
        List<MstTabooAllergy> tabooAllergyList = null;
        PatMain patMain = patMainDao.selectById(patId);
        String patTabooAllergyInfo = "";
        String prefixName = "";
        if (patMain != null) {
          patTabooAllergyInfo = patMain.getTaboo_allergy_info();
          if (!ObjectUtils.isEmpty(patTabooAllergyInfo) && !"[]".equals(patTabooAllergyInfo)) {
            tabooAllergyList = mstTabooAllergyDao.selectAll(SelectOptions.get(), mstTabooAllergy);
          }
          prefixName = prefixNameService.getMedicineMixPrefixOfName(patTabooAllergyInfo, tabooAllergyList, medicineMix);
        }

        editData.put("class_cd", changeToJSONObjectNull(medicineMix.getClassCd()));
        editData.put("name", changeToJSONObjectNull(prefixName + medicineMix.getMedicineMixName()));
        editData.put("short_name", changeToJSONObjectNull(medicineMix.getMedicineMixShortName()));
        editData.put("unit", changeToJSONObjectNull(medicineMix.getUnit()));
      } else {
        editData.put("class_cd", JSONObject.NULL);
        editData.put("name", JSONObject.NULL);
        editData.put("short_name", JSONObject.NULL);
        editData.put("unit", JSONObject.NULL);
      }
      if (! Objects.isNull(mediTiming)) {
        editData.put("timing_name", changeToJSONObjectNull(mediTiming.getMedicateTimingName()));
      } else {
        editData.put("timing_name", JSONObject.NULL);
      }
      if (! Objects.isNull(procedure)) {
        editData.put("procedure_name", changeToJSONObjectNull(procedure.getPricedureName()));
      } else {
        editData.put("procedure_name", JSONObject.NULL);
      }
      // mod FNSI-【1006】障害票一覧_患者経過総合ビューアNo52対応 韓 end
//      // TODO: 指示者・更新者の格納は一旦保留
//      editData.put("ind_user_last_name", "");
//      editData.put("ind_user_first_name", "");
//      editData.put("upd_user_last_name", "");
//      editData.put("upd_user_first_name", "");
      return editData;
    } else {
      // 薬剤マスタ取得
      //MstMedicine medicine = mstMedicineDao.selectByCd(facilityCd, editData.getInt("cd"));
      MstMedicine medicine = masterCacheHandler.getMstMedicineByCd(editData.getInt("cd"));
      // 薬剤分類マスタ取得
      MstMedicineClass mstMedicineClass = medicine.getClassCd() == null ? new MstMedicineClass() : masterCacheHandler.getMstMedicineClassByCd(medicine.getClassCd());
      // 手技マスタ取得
      MstProcedure procedure = editData.isNull("procedure_cd") ? new MstProcedure() : masterCacheHandler.getMstProcedureByCd(editData.getInt("procedure_cd"));
      // 投与タイミングマスタ取得
      MstMedicateTiming mediTiming = editData.isNull("timing_cd") ? new MstMedicateTiming() : masterCacheHandler.getMstMedicateTimingByCd(editData.getInt("timing_cd"));
      // TODO:ここでセットすると画面表示した値と不一致になる場合があるため、編集時には要確認
      // mod FNSI-【1006】障害票一覧_患者経過総合ビューアNo52対応 韓 start
//      editData.put("class_name", mstMedicineClass.getClassName());
//      editData.put("class_cd", medicine.getClassCd());
//      editData.put("class_type", mstMedicineClass.getClassType());
//      editData.put("name", medicine.getMedicineName());
//      editData.put("short_name", medicine.getMedicineShortName());
//      //editData.put("unit", medicine.getUnit());
//      editData.put("timing_name", mediTiming.getMedicateTimingName());
//      editData.put("procedure_name", procedure.getPricedureName());
      if (! Objects.isNull(mstMedicineClass)) {
        editData.put("class_name", changeToJSONObjectNull(mstMedicineClass.getClassName()));
        editData.put("class_type", changeToJSONObjectNull(mstMedicineClass.getClassType()));
      } else {
        editData.put("class_name", JSONObject.NULL);
        editData.put("class_type", JSONObject.NULL);
      }
      if (! Objects.isNull(medicine)) {
        MstTabooAllergy mstTabooAllergy = new MstTabooAllergy();
        mstTabooAllergy.setFacilityCd(facilityCd);
        List<MstTabooAllergy> tabooAllergyList = null;
        PatMain patMain = patMainDao.selectById(patId);
        String patTabooAllergyInfo = "";
        String prefixName = "";
        if (patMain != null) {
          patTabooAllergyInfo = patMain.getTaboo_allergy_info();
          if (!ObjectUtils.isEmpty(patTabooAllergyInfo) && !"[]".equals(patTabooAllergyInfo)) {
            tabooAllergyList = mstTabooAllergyDao.selectAll(SelectOptions.get(), mstTabooAllergy);
          }
          prefixName = prefixNameService.getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, "1", medicine.getMedicineCd(), medicine.getUseEndDate(),
            medicine.getIsDisp(), medicine.getIsDel());
        }

        editData.put("class_cd", changeToJSONObjectNull(medicine.getClassCd()));
        editData.put("name", changeToJSONObjectNull(prefixName + medicine.getMedicineName()));
        editData.put("short_name", changeToJSONObjectNull(medicine.getMedicineShortName()));
        editData.put("unit", changeToJSONObjectNull(medicine.getUnit()));
      } else {
        editData.put("class_cd", JSONObject.NULL);
        editData.put("name", JSONObject.NULL);
        editData.put("short_name", JSONObject.NULL);
        editData.put("unit", JSONObject.NULL);
      }
      if (! Objects.isNull(mediTiming)) {
        editData.put("timing_name", changeToJSONObjectNull(mediTiming.getMedicateTimingName()));
      } else {
        editData.put("timing_name", JSONObject.NULL);
      }
      if (! Objects.isNull(procedure)) {
        editData.put("procedure_name", changeToJSONObjectNull(procedure.getPricedureName()));
      } else {
        editData.put("procedure_name", JSONObject.NULL);
      }
      // mod FNSI-【1006】障害票一覧_患者経過総合ビューアNo52対応 韓 end
//      // TODO: 指示者・更新者の格納は一旦保留
//      editData.put("ind_user_last_name", "");
//      editData.put("ind_user_first_name", "");
//      editData.put("upd_user_last_name", "");
//      editData.put("upd_user_first_name", "");
      return editData;
    }
    /* modify by chamaojia 2024-01-22 [10196]  'Unit' supplementary translation and null value handling --end */
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240913 end

  /* add by chamaojia 2024-02-06 [10196] Convert empty parameters to JSONObject.NULL --start */
  /**
   * Convert empty parameters to JSONObject.NULL
   * @param object
   * @return
   */
  public Object changeToJSONObjectNull(Object object) {
    return object != null ? object : JSONObject.NULL;
  }
  /* add by chamaojia 2024-02-06 [10196] Convert empty parameters to JSONObject.NULL --end */

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240913 start
  /* modify by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Replace the dao with masterCacheHandler to avoid repeated database access  */
  private JSONObject getEquipDeployInfo(Long patId, String facilityCd, JSONObject editData,MasterCacheHandler masterCacheHandler) {
    MstTabooAllergy mstTabooAllergy = new MstTabooAllergy();
    mstTabooAllergy.setFacilityCd(facilityCd);
    List<MstTabooAllergy> tabooAllergyList = null;
    PatMain patMain = patMainDao.selectById(patId);
    String patTabooAllergyInfo = "";
    String prefixName = "";
    // 医療材料区分 0:医療材料、1:ダイアライザ で処理を分ける     医疗材料类别  0：医疗材料，1：透析器单独处理
    if (editData.getInt("equip_type") == 0) {
      // 医療材料マスタ取得
      //MstEquipment equipment = mstEquipDao.selectByEquipmentCd(editData.getInt("cd"));
      MstEquipment equipment = masterCacheHandler.getEquipmentByCd(editData.getInt("cd"));
      // 医療材料分類マスタ取得
      //mod FNSI-7140 劉全航 start
      //MstEquipmentClass mstEquipmentClass = mstEquipmentClassDao.selectByCd(equipment.getClassCd());
      MstEquipmentClass mstEquipmentClass = masterCacheHandler.getEquipmentClassByCd(equipment.getClassCd());
      //mod FNSI-7140 劉全航 end
      editData.put("class_cd", equipment.getClassCd());
      //mod FNSI-7140 劉全航 start
//      editData.put("class_name", mstEquipmentClass.getClassName());
//      editData.put("class_type", mstEquipmentClass.getClassType());
      editData.put("class_name", mstEquipmentClass != null ? mstEquipmentClass.getClassName() : null);
      editData.put("class_type", mstEquipmentClass != null ? mstEquipmentClass.getClassType() : null);
      //mod FNSI-7140 劉全航 end
      if (patMain != null) {
        patTabooAllergyInfo = patMain.getTaboo_allergy_info();
        if (!ObjectUtils.isEmpty(patTabooAllergyInfo) && !"[]".equals(patTabooAllergyInfo)) {
          tabooAllergyList = mstTabooAllergyDao.selectAll(SelectOptions.get(), mstTabooAllergy);
        }
        prefixName = prefixNameService.getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, "3", equipment.getEquipmentCd(), equipment.getUseEndDate(),
          equipment.getIsDisp(), equipment.getIsDel());
      }
      editData.put("name", prefixName + equipment.getEquipmentName());
      editData.put("short_name", equipment.getEquipmentShortName());
      editData.put("unit", equipment.getUnit());
      // TODO: 指示者・更新者については一旦保留
    } else if (editData.getInt("equip_type") == 1) {
      // ダイアライザマスタ取得
      // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
      //MstDialyzer dialyzer = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), editData.getInt("cd"));
      MstDialyzer dialyzer = masterCacheHandler.getDialyzerCd(editData.getInt("cd"));
      // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
      if (patMain != null) {
        patTabooAllergyInfo = patMain.getTaboo_allergy_info();
        if (!ObjectUtils.isEmpty(patTabooAllergyInfo) && !"[]".equals(patTabooAllergyInfo)) {
          tabooAllergyList = mstTabooAllergyDao.selectAll(SelectOptions.get(), mstTabooAllergy);
        }
        prefixName = prefixNameService.getPrefixOfName(patTabooAllergyInfo, tabooAllergyList, "4", dialyzer.getDialyzerCd(), dialyzer.getUseEndDate(),
          dialyzer.getIsDisp(), dialyzer.getIsDel());
      }
      editData.put("name", prefixName + dialyzer.getModelNumber());
      // add #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
      editData.put("short_name", dialyzer.getModelNumber());
      editData.put("unit", "本");
      editData.put("class_cd", JSONObject.NULL);
      editData.put("class_name", JSONObject.NULL);
      editData.put("class_type", JSONObject.NULL);
      // add #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
    }
    return editData;
  }
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240913 end

  /**
   * 実績情報の作成
   * 投与薬剤実績情報を作成
   * 実績情報を作成する前に条件送信後展開情報を指示に格納する
   * <p>
   * マスタ参照した最新化入力済データ editDataの情報を指示データにセットし
   * 実績データから旧データの削除／新データのセットを実施する
   *
   * @param indJsonArr 指示データ(入力データセット済) NewNo
   * @param rstJsonArr 実績データ(マスタ参照値) OldNo
   * @param editNo     修正前のNo情報(編集かつコードが違う場合のみセット／それ以外は0）
   * @param keyName    キー対象名
   * @param editData   画面入力データ（IDマスタ参照最新化済）
   */
  // mod FNSI-FutreNetWeb+SI課題管理No.4742 李 start
  // private JSONArray createRstInfo(JSONArray indJsonArr, JSONArray rstJsonArr, String editNo, String keyName, JSONObject editData) {
  private JSONArray createRstInfo(JSONArray indJsonArr, JSONArray rstJsonArr, String editNo, String keyName, JSONObject editData,
                                  String rstDialysisState,MasterCacheHandler masterCacheHandler) {
    // mod FNSI-FutreNetWeb+SI課題管理No.4742 李 end
    String no = editData.get(keyName).toString();
    // 指示変更データを取得
    JSONObject editInfo = null;
    for (int i = 0; i < indJsonArr.length(); i++) {
      if (indJsonArr.getJSONObject(i).get(keyName).toString().equals(no)) {
        indJsonArr.put(i, editData);
        editInfo = indJsonArr.getJSONObject(i);
      }
    }
    boolean isExit = false;
    for (int i = 0; i < rstJsonArr.length(); i++) {
      if (rstJsonArr.getJSONObject(i).get(keyName).toString().equals(no)) {
        isExit = true;
        if (editInfo == null) {
          rstJsonArr.remove(i);
        } else {
          rstJsonArr.put(i, editInfo);
        }
      }
    }
    if (! isExit && editInfo != null) {
      rstJsonArr.put(editInfo);
    }

    // 編集時かつ編集前後でNoが違う場合のみ:旧Noを保持
    if (! editNo.equals("0")) {
      for (int i = 0; i < rstJsonArr.length(); i++) {
        if (rstJsonArr.getJSONObject(i).get(keyName).toString().equals(editNo)) {
          // 対象データを削除
          rstJsonArr.remove(i);
        }
      }
    }

    // add FNSI-障害票一覧_患者経過総合ビューアNo.86 李 start
    JSONArray mediInfoJson = new JSONArray();
    for (int i = 0; i < rstJsonArr.length(); i++) {
      JSONObject obj = rstJsonArr.getJSONObject(i);
      JSONObject bufJson = new JSONObject();
      // 識別番号
      bufJson.put("no", obj.has("no") ? obj.get("no") : JSONObject.NULL);
      // 薬剤分類コード
      bufJson.put("class_cd", obj.has("class_cd") ? obj.get("class_cd") : JSONObject.NULL);
      // 薬剤分類名
      bufJson.put("class_name", obj.has("class_name") ? obj.get("class_name") : JSONObject.NULL);
      // 分類区分
      bufJson.put("class_type", obj.has("class_type") ? obj.get("class_type") : JSONObject.NULL);
      // 薬剤区分
      bufJson.put("medicine_type", obj.has("medicine_type") ? obj.get("medicine_type") : JSONObject.NULL);
      // 薬剤(調整薬剤)コード
      bufJson.put("cd", obj.has("cd") ? obj.get("cd") : JSONObject.NULL);
      // 薬剤名
      bufJson.put("name", obj.has("name") ? obj.get("name") : JSONObject.NULL);
      // 省略薬剤名
      bufJson.put("short_name", obj.has("short_name") ? obj.get("short_name") : JSONObject.NULL);
      // 単位
      bufJson.put("unit", obj.has("unit") ? obj.get("unit") : JSONObject.NULL);
      // 数量
      bufJson.put("amount", obj.has("amount") ? obj.get("amount") : JSONObject.NULL);
      // 初回投与日
      bufJson.put("init_date", obj.has("init_date") ? obj.get("init_date") : JSONObject.NULL);
      // 投与間隔
      bufJson.put("date_interval", obj.has("date_interval") ? obj.get("date_interval") : JSONObject.NULL);
      // 投与タイミングコード
      bufJson.put("timing_cd", obj.has("timing_cd") ? obj.get("timing_cd") : JSONObject.NULL);
      // 投与タイミング名
      bufJson.put("timing_name", obj.has("timing_name") ? obj.get("timing_name") : JSONObject.NULL);
      // 手技コード
      bufJson.put("procedure_cd", obj.has("procedure_cd") ? obj.get("procedure_cd") : JSONObject.NULL);
      // 手技名
      bufJson.put("procedure_name", obj.has("procedure_name") ? obj.get("procedure_name") : JSONObject.NULL);
      // コメント
      bufJson.put("comment", obj.has("comment") ? obj.get("comment") : JSONObject.NULL);
      /* del by chamaojia 2024-01-22 [10196]  The data does not require this content (実績：投与薬剤情報) --start */
//      // 指示者コード
//      bufJson.put("ind_user_id", obj.has("ind_user_id") ? obj.get("ind_user_id") : JSONObject.NULL);
//      // 指示者名_姓
//      bufJson.put("ind_user_last_name", obj.has("ind_user_last_name") ? obj.get("ind_user_last_name") : JSONObject.NULL);
//      // 指示者名_名
//      bufJson.put("ind_user_first_name", obj.has("ind_user_first_name") ? obj.get("ind_user_first_name") : JSONObject.NULL);
//      // 更新者コード
//      bufJson.put("upd_user_id", obj.has("upd_user_id") ? obj.get("upd_user_id") : JSONObject.NULL);
//      // 更新者名_姓
//      bufJson.put("upd_user_last_name", obj.has("upd_user_last_name") ? obj.get("upd_user_last_name") : JSONObject.NULL);
//      // 更新者名_名
//      bufJson.put("upd_user_first_name", obj.has("upd_user_first_name") ? obj.get("upd_user_first_name") : JSONObject.NULL);
      /* del by chamaojia 2024-01-22 [10196]  The data does not require this content (実績：投与薬剤情報) --end */
      // 登録区分
      bufJson.put("input_class", obj.has("input_class") ? obj.get("input_class") : JSONObject.NULL);
      // 編集可否フラグ
      bufJson.put("is_editable", obj.has("is_editable") ? obj.get("is_editable") : JSONObject.NULL);
      // 連携オーダ番号
      bufJson.put("cop_order_no", obj.has("cop_order_no") ? obj.get("cop_order_no") : JSONObject.NULL);
      // 投与実施フラグ
      bufJson.put("effect_flg", obj.has("effect_flg") ? obj.get("effect_flg") : 0);
      // 投与実施日時
      bufJson.put("effect_date", obj.has("effect_date") ? obj.get("effect_date") : JSONObject.NULL);
      // 投与実施者コード
      bufJson.put("effect_user_id", obj.has("effect_user_id") ? obj.get("effect_user_id") : JSONObject.NULL);
      // 投与実施者名_姓
      bufJson.put("effect_user_last_name", obj.has("effect_user_last_name") ? obj.get("effect_user_last_name") : JSONObject.NULL);
      // 投与実施者名_名
      bufJson.put("effect_user_first_name", obj.has("effect_user_first_name") ? obj.get("effect_user_first_name") : JSONObject.NULL);

      // add FNSI-FutreNetWeb+SI課題管理No.4742 李 start
      if (obj.has("no") && editData.get("no") != null) {
        if ("3".equals(rstDialysisState) && obj.get("no").toString().equals(editData.get("no").toString()) && obj.has("cd")) {
          //List<Integer> params = new ArrayList<>(Arrays.asList(Integer.parseInt(obj.get("cd").toString())));
          //List<MstMedicine> mstMedicines = mstMedicineDao.selectAllByCdList(SelectOptions.get(), params);
          String mediCd = obj.get("cd").toString();
          MstMedicine mstMedicine = masterCacheHandler.getMstMedicineByCd(Integer.parseInt(mediCd));
          //List<MstMedicine> mstMedicineList = mstMedicines.stream().filter(el ->
          //  el.getMedicineCd().toString().equals(obj.get("cd").toString())).collect(Collectors.toList()
          //);

          //if (mstMedicineList != null && mstMedicineList.size() > 0) {
          if (mstMedicine != null) {
            if ("1".equals(mstMedicine.getIsMedicated())) {
              // 投与実施フラグ
              bufJson.put("effect_flg", 1);
              /* modify by chamaojia 2024-01-31 [10196] Save data type modification --start */
              // 投与実施日時 ※ISO8601形式
//              bufJson.put("effect_date", new Timestamp(System.currentTimeMillis()));
              //
              bufJson.put("effect_date", DateTimeFormatUtil.formatDateString(LocalDateTime.now()));
              /* modify by chamaojia 2024-01-31 [10196] Save data type modification --end */

              //List<FacilitySettingInfo> facilitySettingInfos = mstFacilitySettingDao.selectFacilitySetting(facilityCd, "3020");
              FacilitySettingInfo facilitySettingInfo = masterCacheHandler.getFacilitySettingInfo(mstMedicine.getFacilityCd(),"3020");
              if (facilitySettingInfo != null && facilitySettingInfo.getValue() != null) {
                MstPersonalUser persionalUser = mstPersonalUserDao.selectById(Long.parseLong(facilitySettingInfo.getValue()));
                if (persionalUser != null) {
                  // 投与実施者コード
                  bufJson.put("effect_user_id", Long.parseLong(facilitySettingInfo.getValue()));
                  // 投与実施者名_姓
                  bufJson.put("effect_user_last_name", persionalUser.getUserLastName());
                  // 投与実施者名_名
                  bufJson.put("effect_user_first_name", persionalUser.getUserFirstName());
                }
              }
            }
          }
        }
      }
      // add FNSI-FutreNetWeb+SI課題管理No.4742 李 end

      mediInfoJson.put(bufJson);
    }
    // add FNSI-障害票一覧_患者経過総合ビューアNo.86 李 end

    return mediInfoJson;

  }

  /**
   * 実績情報の作成
   * 医療材料の実績情報を作成
   * 実績情報を作成する前に条件送信後展開情報を指示に格納する
   * <p>
   * マスタ参照した最新化入力済データ editDataの情報を指示データにセットし
   * 実績データから旧データの削除／新データのセットを実施する
   *
   * @param indJsonArr 指示データ(入力データセット済) NewNo
   * @param rstJsonArr 実績データ(マスタ参照値) OldNo
   * @param keyName    キー対象名
   * @param editData   画面入力データ（IDマスタ参照最新化済）
   */
  private JSONArray createRstEquipInfo(JSONArray indJsonArr, JSONArray rstJsonArr, String keyName, JSONObject editData) {
    return this.createRstEquipInfo(indJsonArr, rstJsonArr, "0", "9", keyName, editData);
  }


  /**
   * 実績情報の作成
   * 医療材料実績情報を作成
   * 実績情報を作成する前に条件送信後展開情報を指示に格納する
   * <p>
   * マスタ参照した最新化入力済データ editDataの情報を指示データにセットし
   * 実績データから旧データの削除／新データのセットを実施する
   *
   * @param indJsonArr 指示データ(入力データセット済) NewNo
   * @param rstJsonArr 実績データ(マスタ参照値) OldNo
   * @param editNo     修正前のcd情報(編集かつコードが違う場合のみセット／それ以外は0をセット）
   * @param equipType  修正前のequipType（編集かつコードやequipTypeが違う場合のみセット／それ以外は9をセット)
   * @param keyName    キー対象名
   * @param editData   画面入力データ（IDマスタ参照最新化済）
   */
  private JSONArray createRstEquipInfo(JSONArray indJsonArr, JSONArray rstJsonArr, String editNo, String equipType, String keyName, JSONObject editData) {
    String no = editData.get(keyName).toString();
    String type = editData.get("equip_type").toString();
    // 指示変更データを取得
    JSONObject editInfo = null;
    for (int i = 0; i < indJsonArr.length(); i++) {
      //更新データと一致する登録サイドをチェック
      if (indJsonArr.getJSONObject(i).get(keyName).toString().equals(no) && indJsonArr.getJSONObject(i).get("equip_type").toString().equals(type)) {
        /* delete by chamaojia 2024-07-12 [10266] delete incorrect assignments --start */
//        indJsonArr.put(i, editData);
        /* delete by chamaojia 2024-07-12 [10266] delete incorrect assignments --end */
        /* modify by chamaojia 2024-01-26 [10196]  Delete user content in JSON item --start */
        editInfo = new JSONObject(indJsonArr.getJSONObject(i).toString());
        editInfo.remove("ind_user_id");
        editInfo.remove("ind_user_last_name");
        editInfo.remove("ind_user_first_name");
        editInfo.remove("upd_user_id");
        editInfo.remove("upd_user_last_name");
        editInfo.remove("upd_user_first_name");
        /* modify by chamaojia 2024-01-26 [10196]  Delete user content in JSON item --end */
      }
    }
    boolean isExit = false;
    for (int i = 0; i < rstJsonArr.length(); i++) {
      if (rstJsonArr.getJSONObject(i).get(keyName).toString().equals(no) && rstJsonArr.getJSONObject(i).get("equip_type").toString().equals(type)) {
        isExit = true;
        if (editInfo == null) {
          rstJsonArr.remove(i);
        } else {
          rstJsonArr.put(i, editInfo);
        }
      }
    }
    if (! isExit && editInfo != null) {
      rstJsonArr.put(editInfo);
    }

    // 編集時かつ編集前後でNoが違う場合のみ:旧Noを保持
    if (! editNo.equals("0") && ! equipType.equals("9")) {
      boolean isDel = true;
      for (int i = 0; i < indJsonArr.length(); i++) {
        if (indJsonArr.getJSONObject(i).get(keyName).toString().equals(editNo) && indJsonArr.getJSONObject(i).get("equip_type").toString().equals(equipType)) {
          isDel = false;
        }
      }
      // 更新対象データが更新後も指示データに残る場合には実績データを削除しない（更新する）
      if (isDel) {
        for (int i = 0; i < rstJsonArr.length(); i++) {
          if (rstJsonArr.getJSONObject(i).get(keyName).toString().equals(editNo) && rstJsonArr.getJSONObject(i).get("equip_type").toString().equals(equipType)) {
            // 対象データを削除
            rstJsonArr.remove(i);
          }
        }
      }
    }
    return rstJsonArr;

  }

  private int updateOrdMainEquipInfo(
    OrdMain ord,
    Long upIndUseId,
    Long upUseId) {
    // add FNSI-改修内容追加OrdMain履歴 付 start
    // getHistory(ord_no); // 优化：移动到外面，并改为批量插入mongo
    // mangoDb-updateOrdMainEquipInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord.getOrdNo() + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End
    // add 6227 張 start
//    copyOrdmainToOrdMainRestore(ord_no);
    // add 6227 張 end
//    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ord.getOrdNo());
// add 7959 2023-02-21 17:30 医療材料取得。張  start
    //マスタ取得用パラメータに施設コードを設定
//    MstEquipment mstEquipment = new MstEquipment();
//    mstEquipment.setFacilityCd(ord.getFacilityCd());
//    MstDialyzer mstDialyzer = new MstDialyzer();
//    mstDialyzer.setFacilityCd(ord.getFacilityCd());
//    //マスタ取得処理
//    SelectOptions selectOptions = SelectOptions.get();
//    List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectAll(selectOptions,mstEquipment);
//    List<MstDialyzer> MstDialyzerList = mstDialyzerDao.selectAll(selectOptions,mstDialyzer);
//    JSONArray ordEquipArr = new JSONArray(ord.getIndEquipInfo());
//    if(ordEquipArr.length()>0){
//      for (int i = 0; i <ordEquipArr.length() ; i++) {
//        // 医療材料区分 0:医療材料、1:ダイアライザ
//        int equipType = ordEquipArr.getJSONObject(i).isNull("equip_type") ? 0
//          : (int) ordEquipArr.getJSONObject(i).get("equip_type");
//        int equipCd = Integer.parseInt(ordEquipArr.getJSONObject(i).get("cd").toString());
//        Integer class_cd = null;
//        if(equipType == 0){
//          MstEquipment mstEquipmentdata = mstEquipmentList.stream().filter(item -> item.getEquipmentCd().equals(equipCd)).findFirst().orElse(null);
//          if(mstEquipmentdata != null){
//            class_cd = mstEquipmentdata.getClassCd();
//          }
//        }else{
//          MstDialyzer mstDialyzerdata = MstDialyzerList.stream().filter(item -> item.getDialyzerCd().equals(equipCd)).findFirst().orElse(null);
//          if(mstDialyzerdata != null){
//            class_cd = null;
//          }
//        }
//            ordEquipArr.getJSONObject(i).put("class_cd", class_cd);
//      }
//      ord.setIndEquipInfo(ordEquipArr.toString());
//    }
    // add 7959 2023-02-21 17:30 医療材料取得。張  end
    /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
    int updateCount = ordMainDao.updateOrdMainEquipInfoAndUserId(
      ord.getOrdNo(),
      ord.getIndEquipInfo(),
      ord.getRstEquipInfo(),
//      ord.getIndScheduleUserInfo(),
      upIndUseId,
      upUseId,
      //mod 9806 ljx start 医療材料
      //現状：ここの処理を利用する箇所がないので、一旦falseを設定、SQLファイルに追加された処理が実行しないようにする。
      false);
    //mod 9806 ljx end
    /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */
    triggerUtil.updateOrdMainTriggerForOrdScheduleInsert(Collections.singletonList(ord));
    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック wangzuo End
    PatIndApprove patIndApprove = new PatIndApprove();
    patIndApprove.setOrd_no(ord.getOrdNo());
    try {
      updateContentChangeSingleWithNotification(ord.getOrdNo(), patIndApprove);
    } catch (Exception e) {
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return updateCount;
  }

  /* add by chamaojia 2023-03-11 [6961] データを一括処理できる新しい方法 --start */
  private int updateOrdMainEquipInfoByOrdMainList(
    List<OrdMain> ordMainList,
    Long upIndUseId,
    Long upUseId,
    //mod 9806 ljx start 医療材料
    //パラメータ追加：rst_update_flg、実績データへの反映要否、true：反映、false:反映しない。
    //追加されたパラメータによって、is_confirmを更新するかの判断をする。
    Boolean rst_update_flg) {
    //mod 9806 ljx end
    // add FNSI-改修内容追加OrdMain履歴 付 start
    // getHistory(ord_no); // 优化：移动到外面，并改为批量插入mongo
    // mangoDb-updateOrdMainEquipInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
    // DB更新ログ出力ロジック wangzuo Start
    List<Long> ordNoList = ordMainList.stream().map(o -> o.getOrdNo()).collect(Collectors.toList());
    String tableName = "ord_main";
    // SQL検索条件
    String inStr = getInStr("ord_no in ", ordNoList);
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(inStr + "\n");
//    wheres.append(" ord_no = " + ord.getOrdNo() + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End
    // add 6227 張 start
//    copyOrdmainToOrdMainRestore(ord_no);
    // add 6227 張 end
//    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ord.getOrdNo());
// add 7959 2023-02-21 17:30 医療材料取得。張  start
    //マスタ取得用パラメータに施設コードを設定
//    String facilityCd = ordMainList.get(0).getFacilityCd();
//    MstEquipment mstEquipment = new MstEquipment();
//    mstEquipment.setFacilityCd(facilityCd);
//    MstDialyzer mstDialyzer = new MstDialyzer();
//    mstDialyzer.setFacilityCd(facilityCd);
//    //マスタ取得処理
//    SelectOptions selectOptions = SelectOptions.get();
//    List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectAll(selectOptions,mstEquipment);
//    List<MstDialyzer> MstDialyzerList = mstDialyzerDao.selectAll(selectOptions,mstDialyzer);

    int updateCount = 0;
    // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new LinkedList<>();
    // del 12250 ord_material_saveの処理を2回重複実行している zkm end
    for (OrdMain ord : ordMainList) {
//      JSONArray ordEquipArr = new JSONArray(ord.getIndEquipInfo());
//      if(ordEquipArr.length()>0){
//        for (int i = 0; i <ordEquipArr.length() ; i++) {
//          // 医療材料区分 0:医療材料、1:ダイアライザ
//          int equipType = ordEquipArr.getJSONObject(i).isNull("equip_type") ? 0
//            : (int) ordEquipArr.getJSONObject(i).get("equip_type");
//          int equipCd = Integer.parseInt(ordEquipArr.getJSONObject(i).get("cd").toString());
//          Integer class_cd = null;
//          if(equipType == 0){
//            MstEquipment mstEquipmentdata = mstEquipmentList.stream().filter(item -> item.getEquipmentCd().equals(equipCd)).findFirst().orElse(null);
//            if(mstEquipmentdata != null){
//              class_cd = mstEquipmentdata.getClassCd();
//            }
//          }else{
//            MstDialyzer mstDialyzerdata = MstDialyzerList.stream().filter(item -> item.getDialyzerCd().equals(equipCd)).findFirst().orElse(null);
//            if(mstDialyzerdata != null){
//              class_cd = null;
//            }
//          }
//          ordEquipArr.getJSONObject(i).put("class_cd", class_cd);
//        }
//        ord.setIndEquipInfo(ordEquipArr.toString());
//      }
      // add 7959 2023-02-21 17:30 医療材料取得。張  end
      /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
      updateCount = updateCount +
        ordMainDao.updateOrdMainEquipInfoAndUserId(
        ord.getOrdNo(),
        ord.getIndEquipInfo(),
        ord.getRstEquipInfo(),
//        ord.getIndScheduleUserInfo(),
        upIndUseId,
        upUseId,
          //mod 9806 ljx start 医療材料
          rst_update_flg);
      //mod 9806 ljx end
      /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */

      // #10196 Add by Zhou.tao Start
//       計算材料保持
//      diffMaterialSaveRstList.add(
//        ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//          new OrdMaterialSaveDto(
//            ord.getOrdNo(),
//            false,
//            false,
//            true,
//            false,
//            OrdMaterialSaveDto.IND_CLASS,
//            ord
//          )
//        )
//      );
//      if (rst_update_flg)
//        diffMaterialSaveRstList.add(
//          ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//            new OrdMaterialSaveDto(
//              ord.getOrdNo(),
//              false,
//              false,
//              true,
//              false,
//              OrdMaterialSaveDto.RST_CLASS,
//              ord
//            )
//          )
//        );
    }

//    if (!diffMaterialSaveRstList.isEmpty()) ordMaterialSaveService.batchProcessingData(diffMaterialSaveRstList);

    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    ordMaterialSaveService.batchProcessingDataMod(
//      asyncMaterialSaveHandlerTask.updateOrdMaterialSaveByDiff(
//        new OrdMaterialSaveBatchHandleDTO(
//          ordNoList,
//          ordMainList
//          , OrdMaterialSaveBatchHandleDTO.getBatchModifiedMode(
//          false, false, true, false,
//          rst_update_flg ? OrdMaterialSaveDto.RST_CLASS : OrdMaterialSaveDto.IND_CLASS,
//          rst_update_flg
//        )
//        )
//      )
//    );
    if (rst_update_flg) {
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(ordNoList);
    } else {
      ordMaterialSaveService.bulkUpdateByOrdNoInEquip(ordNoList);
    }
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end

    triggerUtil.insertListTriggerOrdMain(ordMainList);
    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック wangzuo End
//    for (OrdMain ord : ordMainList) {
//      PatIndApprove patIndApprove = new PatIndApprove();
//      patIndApprove.setOrd_no(ord.getOrdNo());
//      try {
//        updateContentChangeSingleWithNotification(ord.getOrdNo(), patIndApprove);
//      } catch (Exception e) {
//        e.printStackTrace();
//      }
//    }
    if (updateCount > 0) {
      tableName = "pat_ind_approve";
      // logCommon設定
      DataUpdateLogCommonNew patIndApprovelogCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean patIndApproveSetResult = patIndApprovelogCommon.setInfo();

      int patUpdateCount = 0;
      try {
        patUpdateCount = updateContentChangeSingleWithNotification(ordNoList);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }

      if (patIndApproveSetResult && patUpdateCount > 0) {
        patIndApprovelogCommon.setAfterResults();
//        patIndApprovelogCommon.updateLog();
        asyncService.updateLog(patIndApprovelogCommon);
      }

    }
    return updateCount;
  }
  /* add by chamaojia 2023-03-11 [6961] データを一括処理できる新しい方法 --end */

  private int updateOrdMainMediInfo(
    OrdMain ord,
    Long upIndUseId,
    Long upUseId) {
    Long ord_no = ord.getOrdNo();
    // add FNSI-改修内容追加OrdMain履歴 付 start
    // getHistory(ord_no);  // 优化：移动到外面，并改为批量插入mongo
    // mangoDb-updateOrdMainMediInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
    // add 6227 張 start
//    copyOrdmainToOrdMainRestore(ord_no);
    // add 6227 張 end

//    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ord.getOrdNo());
    /* modify by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
    int updateCount = ordMainDao.updateOrdMainMedInfoAndUserId(
            ord.getOrdNo(),
            ord.getIndMediInfo(),
            ord.getRstMediInfo(),
//            ord.getIndScheduleUserInfo(),
            upIndUseId,
            upUseId,
            //mod 9806 ljx start 医療材料
            //現状：ここの処理を利用する箇所がないので、一旦falseを設定、SQLファイルに追加された処理が実行しないようにする。
            false);
            //mod 9806 ljx end
    /* modify by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */
    triggerUtil.updateOrdMainTriggerForOrdScheduleInsert(Collections.singletonList(ord));
    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック wangzuo End

    if (0 != updateCount) {
      PatIndApprove patIndApprove = new PatIndApprove();
      patIndApprove.setOrd_no(ord_no);
      try {
        updateContentChangeSingleWithNotification(ord_no, patIndApprove);
      } catch (Exception e) {
      }
    }
    return updateCount;
  }

  /* add by chamaojia 2023-03-21 [6961] 上のupdateOrdMainMediInfoメソッドを一括オペレーションに拡張 --start */
  private int updateOrdMainMediInfoByList(
    //mod 9806 start ljx 投与薬剤
    //パラメータ追加：rst_update_flg、実績データへの反映要否、true：反映、false:反映しない。
    //追加されたパラメータによって、is_confirmを更新するかの判断をする。
    //List<UpdateOrdMainMediInfoDTO> dataList) {
    List<UpdateOrdMainMediInfoDTO> dataList,Boolean rst_update_flg) {
    //mod 9806 end ljx
    List<Long> ordNoList = dataList.stream().map(o -> o.getOrdMain().getOrdNo()).collect(Collectors.toList());
    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_main";
    // SQL検索条件
    String inStr = getInStr("ord_no in ", ordNoList);
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(inStr + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = 0;
    for (UpdateOrdMainMediInfoDTO infoEntity : dataList) {
      /* modify by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
      updateCount = updateCount + ordMainDao.updateOrdMainMedInfoAndUserId(
        infoEntity.getOrdMain().getOrdNo(),
        infoEntity.getOrdMain().getIndMediInfo(),
        infoEntity.getOrdMain().getRstMediInfo(),
//        infoEntity.getOrdMain().getIndScheduleUserInfo(),
        infoEntity.getUpIndUseId(),
        infoEntity.getUpUseId(),
        //mod 9806 start ljx 投与薬剤
        rst_update_flg);
      //mod 9806 end ljx
      /* modify by chamaojia 2024-01-22 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */
    }

    List<OrdMain> ordMainList = dataList.stream().map(o -> o.getOrdMain()).collect(Collectors.toList());
    triggerUtil.insertListTriggerOrdMain(ordMainList);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック wangzuo End

    if (0 != updateCount) {
      /* modify by chamaojia 2023-03-27 ログ補完 --start */
      tableName = "pat_ind_approve";
      // logCommon設定
      DataUpdateLogCommonNew patIndApprovelogCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean patIndApproveSetResult = patIndApprovelogCommon.setInfo();

      int patUpdateCount = 0;
      try {
        patUpdateCount = updateContentChangeSingleWithNotification(ordNoList);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }

      if (patIndApproveSetResult && patUpdateCount > 0) {
        patIndApprovelogCommon.setAfterResults();
//        patIndApprovelogCommon.updateLog();
        asyncService.updateLog(patIndApprovelogCommon);
      }
      /* modify by chamaojia 2023-03-27 ログ補完 --end */
    }
    return updateCount;
  }
  /* add by chamaojia 2023-03-21 [6961] 上のupdateOrdMainMediInfoメソッドを一括オペレーションに拡張 --end */

  //mod 8277 周安寧 start
//  private int updateOrdMainCommentInfo(
//    OrdMain ord,
//    Long upIndUseId,
//    Long upUseId) {
  private int updateOrdMainCommentInfo(
      OrdMain ord) {
    //mod 8277 周安寧 end
    Long ord_no = ord.getOrdNo();
    //mod 8277 周安寧 start
//    int updateCount = ordMainDao.updateOrdMainCommentInfoAndUserId(
//      ord.getOrdNo(),
//      ord.getIndIndCommentInfo(),
//      ord.getRstIndCommentInfo(),
//      ord.getIndScheduleUserInfo(),
//      upIndUseId,
//      upUseId);

//    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ord.getOrdNo());
    /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
    int updateCount = ordMainDao.updateOrdMainCommentInfoAndUserId(
            ord.getOrdNo(),
            ord.getIndIndCommentInfo(),
            ord.getRstIndCommentInfo(),
//            ord.getIndScheduleUserInfo(),
            null, null, false,
            //mod 9806 ljx start 指示コメント
            //現状：ここの処理を利用する箇所がないので、一旦falseを設定、SQLファイルに追加された処理が実行しないようにする。
            false);
    //mod 9806 ljx end
    /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */

    triggerUtil.updateOrdMainTriggerForOrdScheduleInsert(Collections.singletonList(ord));
    //mod 8277 周安寧 end
    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック wangzuo End

    if (0 != updateCount) {
      PatIndApprove patIndApprove = new PatIndApprove();
      patIndApprove.setOrd_no(ord_no);
      try {
        updateContentChangeSingleWithNotification(ord_no, patIndApprove);
      } catch (Exception e) {
      }
    }
    return updateCount;
  }

  /* add by chamaojia 2023-03-27 [6961] 新しいバッチ処理方法、上のupdateOrdMainCommentInfo方法の拡張 --start */
  private int updateOrdMainCommentInfoByList(
    //mod 9806 ljx start 指示コメント
    //パラメータ追加：rst_update_flg、実績データへの反映要否、true：反映、false:反映しない。
    //追加されたパラメータによって、is_confirmを更新するかの判断をする。
    //List<OrdMain> ordMainList) {
    // isIndFlag 'ind' update identifier
    List<OrdMain> ordMainList,Boolean rst_update_flg, Long upIndUserId, Long upUserId, Boolean isIndFlag) {
    //mod 9806 ljx end
    List<Long> ordNoList = ordMainList.stream().map(o -> o.getOrdNo()).collect(Collectors.toList());
    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_main";
    // SQL検索条件
    String inStr = getInStr("ord_no in ", ordNoList);
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(inStr + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = 0;
    for (OrdMain ord : ordMainList) {
      /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --start */
      updateCount = updateCount + ordMainDao.updateOrdMainCommentInfoAndUserId(
        ord.getOrdNo(),
        ord.getIndIndCommentInfo(),
        ord.getRstIndCommentInfo(),
//        ord.getIndScheduleUserInfo(),
        upIndUserId,
        upUserId,
        isIndFlag,
        //mod 9806 ljx start 指示コメント
        rst_update_flg);
      //mod 9806 ljx end
      /* modify by chamaojia 2024-01-23 [10196]  No need to modify the content of 'indScheduleUserInfo' --end */
    }
    triggerUtil.insertListTriggerOrdMain(ordMainList);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.setAfterResults();
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
    }
    // DB更新ログ出力ロジック wangzuo End

    if (0 != updateCount) {
      tableName = "pat_ind_approve";
      // logCommon設定
      DataUpdateLogCommonNew patIndApprovelogCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean patIndApproveSetResult = patIndApprovelogCommon.setInfo();

      int patUpdateCount = 0;
      try {
        patUpdateCount = updateContentChangeSingleWithNotification(ordNoList);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }

      if (patIndApproveSetResult && patUpdateCount > 0) {
        patIndApprovelogCommon.setAfterResults();
//        patIndApprovelogCommon.updateLog();
        asyncService.updateLog(patIndApprovelogCommon);
      }
    }
    return updateCount;
  }
  /* add by chamaojia 2023-03-27 [6961] 新しいバッチ処理方法、上のupdateOrdMainCommentInfo方法の拡張 --end */

  private int updateContentChangeSingleWithNotification(Long ordNo, PatIndApprove patIndApprove) throws Exception {
    // 指示変更ありフラグの追加処理     指令变更标志的附加处理
    Integer patUpdateCount = patIndApproveDao.updateContentChangeSingle(ordNo, patIndApprove);
    // 更新できた場合、通知発火     更新成功触发通知
    if (patUpdateCount > 0) {
      registerUpdateContentChangeNotification(ordNo);
    }
    return patUpdateCount;
  }

  /* add by chamaojia 2023-03-11 [6961] データを一括処理できる新しい方法 --start */
  private int updateContentChangeSingleWithNotification(List<Long> ordNoList) throws Exception {
    Integer rtnUpdateCount = 0;
    List<OrdMain> ordMainList = ordMainDao.selectByOrdNoList(ordNoList);
    Map<Long, OrdMain> ordMainMap = ordMainList.stream()
      .collect(Collectors.toMap(o -> o.getOrdNo(), o -> o));
    for (Long ordNo : ordNoList) {
      // 指示変更ありフラグの追加処理     指令变更标志的附加处理
      Integer patUpdateCount = patIndApproveDao.updateContentChangeSingle(ordNo, new PatIndApprove());
      // 更新できた場合、通知発火     更新成功触发通知
      if (patUpdateCount > 0) {
        rtnUpdateCount += patUpdateCount;
        registerUpdateContentChangeNotificationByOrdMain(ordMainMap.get(ordNo));
      }
    }
    return rtnUpdateCount;
  }
  /* add by chamaojia 2023-03-11 [6961] データを一括処理できる新しい方法 --end */

  /**
   * 治療中指示変更通知発火処理    治疗中指令变更通知触发流程
   * @param ordNo オーダー番号
   * @return アップデート件数
   * @throws Exception
   */
  private void registerUpdateContentChangeNotification(Long ordNo) throws Exception {
    OrdMain ord = ordMainDao.selectByOrdNo(ordNo);
    // 条件送信後から後体重測定前までの間のみ処理する      仅在条件传输后和后称重前处理
    int dialysisState = Integer.parseInt(ord.getRstDialysisState());
    if (dialysisState >= 1 && dialysisState <= 4) {
      Long patId = ord.getPatId();
      String facilityCd = ord.getFacilityCd();
      String bedName = ord.getIndBedName() != null ? ord.getIndBedName() : "未登録";

      Map<String, String> patInfo = patInfoService.selectById(patId , facilityCd);
      ObjectMapper mapper = new ObjectMapper();
      PatPersonalMain patPersonalMain = mapper.readValue(patInfo.get("pat_personal_main"), PatPersonalMain.class);
      JSONObject replaceData = new JSONObject();
      replaceData.put("PATID", patId.toString());
      replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
      replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
      replaceData.put("BEDNAME", bedName);
      replaceData.put("FACILITYCD", facilityCd);
      replaceData.put("ORDNO", ordNo.toString());
      webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.INDICATION_CHANGE_IN_TREATMENT, facilityCd, replaceData);
    }
  }

  /* add by chamaojia 2023-03-11 [6961] データを一括処理できる新しい方法 --start */
  /**
   * 治療中指示変更通知発火処理    治疗中指令变更通知触发流程
   * @param ordNo オーダー番号
   * @return アップデート件数
   * @throws Exception
   */
  private void registerUpdateContentChangeNotificationByOrdMain(OrdMain ord) throws Exception {
    // 条件送信後から後体重測定前までの間のみ処理する      仅在条件传输后和后称重前处理
    int dialysisState = Integer.parseInt(ord.getRstDialysisState());
    if (dialysisState >= 1 && dialysisState <= 4) {
      Long patId = ord.getPatId();
      String facilityCd = ord.getFacilityCd();
      String bedName = ord.getIndBedName() != null ? ord.getIndBedName() : "未登録";

      Map<String, String> patInfo = patInfoService.selectById(patId , facilityCd);
      ObjectMapper mapper = new ObjectMapper();
      PatPersonalMain patPersonalMain = mapper.readValue(patInfo.get("pat_personal_main"), PatPersonalMain.class);
      JSONObject replaceData = new JSONObject();
      replaceData.put("PATID", patId.toString());
      replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
      replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
      replaceData.put("BEDNAME", bedName);
      replaceData.put("FACILITYCD", facilityCd);
      replaceData.put("ORDNO", ord.getOrdNo().toString());
      webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.INDICATION_CHANGE_IN_TREATMENT, facilityCd, replaceData);
    }
  }
  /* add by chamaojia 2023-03-11 [6961] データを一括処理できる新しい方法 --end */

  public void updPatIndApprove(List<Long> ordMainCdList) {
      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_ind_approve";
      // SQL検索条件
      String inStr = getInStr("ord_no in ", ordMainCdList);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(inStr + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int patUpdateCount = patIndApproveDao.updateContentChangeList(ordMainCdList, new PatIndApprove());
      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && patUpdateCount > 0) {
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
        logCommon.setAfterResults();
//         logCommon.updateLog();
        asyncService.updateLog(logCommon);
        /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
      }
      // DB更新ログ出力ロジック wangzuo End
  }

  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }

    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   *
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

  /**
   * 検索条件 IN情報
   *
   * @param fieldInfo カラム情報
   * @param inList    IN値リスト
   * @return inStr
   */
  private <T> String getInStr(String fieldInfo, List<T> inList) {
    StringBuffer inStr = new StringBuffer("");
    inStr.append(fieldInfo);
    inStr.append(" ( ");
    for (T obj : inList) {
      inStr.append(obj);
      inStr.append(" ,");
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(" ) ");
    return String.valueOf(inStr);
  }

  /**
   * 投与薬剤情報
   *
   * @param conditions 条件
   * @param setMedi    投与薬剤情報
   */
  private List<OrdMaterialSave> createMediOrdMaterialSaveObj(String indRstClass, ApiEntityOrdMain.ValiOrdMaterialSave conditions,
                                                             JSONArray setMedi, List<Integer> editMediCodeList,
                                                             MasterCacheHandler masterCacheHandler) {
    List<OrdMaterialSave> ordMaterialSaveList = new ArrayList<>();
    if (null == setMedi || setMedi.length() == 0) {
      return ordMaterialSaveList;
    }
    // 投与薬剤情報取得值的设定
    // 同じ種類の計算材料を取得します(type,cd,amount)
    Map<String, Map<String, Double>> typeCdAmountMap = ordMainResource.sameKindCalculation(setMedi);
    Iterator<Map.Entry<String, Map<String, Double>>> typeCdAmountentries = typeCdAmountMap.entrySet().iterator();

    //MstMedicine mstMedicineI = new MstMedicine();
    //mstMedicineI.setFacilityCd(conditions.getFacility_cd());
    //mstMedicineI.setIsDel("0");
    //SelectOptions selectOptions = SelectOptions.get();
    //List<MstMedicine> mstMedicines = mstMedicineDao.selectAll(selectOptions, mstMedicineI);

    while (typeCdAmountentries.hasNext()) {
      Map.Entry<String, Map<String, Double>> typeCdAmountenEntry = typeCdAmountentries.next();
      // 通常薬剤の場合
      if ("1".equals(typeCdAmountenEntry.getKey())) {
        // 同じ種類の計算材料を取得します(cd,amount)
        Map<String, Double> cdAmountMap = typeCdAmountenEntry.getValue();
        Iterator<Map.Entry<String, Double>> cdAmountentries = cdAmountMap.entrySet().iterator();
        while (cdAmountentries.hasNext()) {
          Map.Entry<String, Double> cdAmountenEntry = cdAmountentries.next();
          String medicineCd = cdAmountenEntry.getKey();
          Integer medicineCdInt =  Integer.parseInt(medicineCd);
          /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Only processe records that been edited on the page */
          if(!editMediCodeList.contains(medicineCdInt)){
            continue;
          }
          // データ発生元区分(1：投与薬剤)
          conditions.setSupplies_source_class("1");
          // 物品区分(12：投与薬剤)
          conditions.setSupplies_class("12");
          // 物品コード
          conditions.setSupplies_cd(medicineCd);
          // 調製薬剤コード
          conditions.setMedicine_mix_cd(null);
          // 分類コード
          //List<MstMedicine> medicines = mstMedicines.stream().filter(a -> a.getMedicineCd().equals(cdAmountenEntry.getKey())).collect(Collectors.toList());
          MstMedicine mstMedicine = masterCacheHandler.getMstMedicineByCd(medicineCdInt);
          //if (mstMedicine != null && medicines.size() != 0) {
          //  mstMedicine = medicines.get(0);
          //}
          // MstMedicine mstMedicine = this.mstMedicineSelectByCd(Integer.parseInt(cdAmountenEntry.getKey()));
          conditions.setClass_cd(mstMedicine == null || (mstMedicine != null && mstMedicine.getClassCd() == null)
            ? null : mstMedicine.getClassCd().toString());
          // 指示・実績値
          // add 8315 ljx start
          // 小数点桁数を正しく保持する
          int decimalPoint = 0;
          if(mstMedicine != null){
            if(mstMedicine.getUnitDecimalPoint()!=null){
              decimalPoint=mstMedicine.getUnitDecimalPoint();
            }
          }
          // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen start
          // StringBuilder sb = new StringBuilder("#");
          StringBuilder sb = new StringBuilder("0");
          // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen end
          if(decimalPoint > 0) {
            sb.append(".");
            for(int i = 0; i < decimalPoint; i++) {
              sb.append(0);
            }
          }
          DecimalFormat df = new DecimalFormat(sb.toString());
          conditions.setInd_rst_value(df.format(cdAmountenEntry.getValue()));
          // add 8315 ljx end
          conditions.setInd_rst_class(indRstClass);
          // レセ値
          ordMainResource.receiptValueSet(conditions, mstMedicine, cdAmountenEntry.getValue().toString());
          // 登録や修正データを設定する
          //int result = ordMaterialSaveService.ordMaterialSave(conditions, "1");
          // ログインに失敗したとき
          //if (result == - 1) {
          //  return false;
          //}

          ordMaterialSaveList.add(convertToOrdMaterialSave(conditions));
          // エンティティクリア
          this.clearConditions(conditions);
        }
        // 調製薬剤の場合
      } else {
        // 同じ種類の計算材料を取得します(cd,amount)
        Map<String, Double> cdAmountMap = typeCdAmountenEntry.getValue();
        Iterator<Map.Entry<String, Double>> cdAmountentries = cdAmountMap.entrySet().iterator();
        while (cdAmountentries.hasNext()) {
          Map.Entry<String, Double> cdAmountenEntry = cdAmountentries.next();
          String medicineCd = cdAmountenEntry.getKey();
          Integer medicineCdInt =  Integer.parseInt(medicineCd);
          /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Only processe records that been edited on the page */
          if(!editMediCodeList.contains(medicineCdInt)){
            continue;
          }
          // 調製薬剤自身の場合
          // データ発生元区分(1：投与薬剤)
          conditions.setSupplies_source_class("1");
          // 物品区分(13：調製薬剤)
          conditions.setSupplies_class("13");
          // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
          // 物品コード
          // conditions.setSupplies_cd(medicineCd);
          conditions.setSupplies_cd(NULL_VALUE);
          // 調製薬剤コード
          // conditions.setMedicine_mix_cd(null);
          conditions.setMedicine_mix_cd(medicineCd);
          // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
          // 分類コード
          //Integer medicineMixCd = Integer.parseInt(cdAmountenEntry.getKey());
          //MstMedicineMix medicineMix = this.mstMedicineMixSelectByMedicineMixCd(medicineMixCd);
          MstMedicineMix medicineMix = masterCacheHandler.getMstMedicineMixByCd(medicineCdInt);
          conditions.setClass_cd(medicineMix == null || (medicineMix != null && medicineMix.getClassCd() == null)
            ? null : medicineMix.getClassCd().toString());
          // 指示・実績値
          // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
          // conditions.setInd_rst_value(cdAmountenEntry.getValue().toString());
          conditions.setInd_rst_value(setMixDecimal(cdAmountenEntry, medicineMix));
          // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
          conditions.setInd_rst_class(indRstClass);
          // レセ値
          //mod 8489  配布リスト（ベッド）の出力項目が正しくない 調整薬剤の数量が「0」となる。  zhou start
          //conditions.setReceipt_value(null);
          conditions.setReceipt_value(setMixDecimal(cdAmountenEntry, medicineMix));
          //mod 8489  配布リスト（ベッド）の出力項目が正しくない 調整薬剤の数量が「0」となる。 zhou end
          // 登録や修正データを設定する
          //int result = ordMaterialSaveService.ordMaterialSave(conditions, "1");
          // ログインに失敗したとき
          //if (result == - 1) {
          //  return false;
          //}
          ordMaterialSaveList.add(convertToOrdMaterialSave(conditions));
          // エンティティクリア
          this.clearConditions(conditions);

          // 調製薬剤下通常薬剤の場合
          // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
          // if (null != medicineMix) {
          if (null != medicineMix && medicineMix.getMixInfo() != null && !medicineMix.getMixInfo().equals("[]")) {
            // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
            JSONArray mixInfo = new JSONArray(medicineMix.getMixInfo());
            //add 396  調製薬剤 の数量固定 張 start
            Map<String, Boolean> cdSolventMap = ordMainResource.sameKindSolvent(mixInfo);
            //add 396  調製薬剤 の数量固定  張 end
            Map<String, Map<String, Double>> mstMedicine = ordMainResource.sameKindCalculation(mixInfo);
            Map<String, Double> mstMedicineAmountMap = mstMedicine.get("0");
            Iterator<Map.Entry<String, Double>> mstMediEntry = mstMedicineAmountMap.entrySet().iterator();
            while (mstMediEntry.hasNext()) {
              Map.Entry<String, Double> mstMediMap = mstMediEntry.next();
              String mediCd = mstMediMap.getKey();
              // データ発生元区分(1：投与薬剤)
              conditions.setSupplies_source_class("1");
              // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
              // 物品区分(20:分解薬剤)
              // conditions.setSupplies_class("12");
              conditions.setSupplies_class(SUPPLIES_CLASS_MEDICINE);
              // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
              // 物品コード
              conditions.setSupplies_cd(mediCd);
              // 調製薬剤コード
              conditions.setMedicine_mix_cd(medicineMix.getMedicineMixCd().toString());
              // 分類コード
              MstMedicine mstMixMedicine = null;
              if (! "null".equals(mediCd)) {
                //List<MstMedicine> medicines = mstMedicines.stream().filter(a -> a.getMedicineCd().equals(mstMediMap.getKey())).collect(Collectors.toList());
                //if (medicines != null && medicines.size() != 0) {
                //  mstMixMedicine = medicines.get(0);
                //}
                // mstMixMedicine = this.mstMedicineSelectByCd(Integer.parseInt(mstMediMap.getKey()));
                mstMixMedicine = masterCacheHandler.getMstMedicineByCd(Integer.parseInt(mediCd));
              }
              conditions.setClass_cd(mstMixMedicine == null || (mstMixMedicine != null && mstMixMedicine.getClassCd() == null)
                ? null : mstMixMedicine.getClassCd().toString());
              //mod 396  調製薬剤 の数量固定 張 start
              // 指示・実績値
//                conditions.setInd_rst_value(Double.toString(mstMediMap.getValue() * cdAmountenEntry.getValue()));
              // レセ値
//                this.receiptValueSet(conditions, mstMixMedicine, Double.toString(mstMediMap.getValue() * cdAmountenEntry.getValue()));
              // mod 8315 ljx start
              // 小数点桁数を正しく保持する
              int decimalPoint = 0;
              if(mstMixMedicine != null){
                if(mstMixMedicine.getUnitDecimalPoint()!=null){
                  decimalPoint=mstMixMedicine.getUnitDecimalPoint();
                }
              }
              // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen start
              // StringBuilder sb = new StringBuilder("#");
              StringBuilder sb = new StringBuilder("0");
              // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen end
              if(decimalPoint > 0) {
                sb.append(".");
                for(int i = 0; i < decimalPoint; i++) {
                  sb.append(0);
                }
              }

              DecimalFormat df = new DecimalFormat(sb.toString());
              String indRstValue = "";
              if (cdSolventMap.get(mediCd)) {
                // 指示・実績値
                indRstValue = df.format(mstMediMap.getValue());
                //conditions.setInd_rst_value(Double.toString(mstMediMap.getValue()));
                conditions.setInd_rst_value(indRstValue);
                // レセ値
                ordMainResource.receiptValueSet(conditions, mstMixMedicine, Double.toString(mstMediMap.getValue()));
              } else {
                // 指示・実績値
                indRstValue = df.format(mstMediMap.getValue() * cdAmountenEntry.getValue());
                conditions.setInd_rst_value(indRstValue);
                //conditions.setInd_rst_value(Double.toString(mstMediMap.getValue() * cdAmountenEntry.getValue()));
                // レセ値
                ordMainResource.receiptValueSet(conditions, mstMixMedicine, Double.toString(mstMediMap.getValue() * cdAmountenEntry.getValue()));
              }
              // mod 8315 ljx end
              conditions.setInd_rst_class(indRstClass);
              //mod 396  調製薬剤 の数量固定 張 end
              // 登録や修正データを設定する
              //result = ordMaterialSaveService.ordMaterialSave(conditions, "1");
              // ログインに失敗したとき
              //if (result == - 1) {
              //  return false;
              //}
              ordMaterialSaveList.add(convertToOrdMaterialSave(conditions));
              // エンティティクリア
              this.clearConditions(conditions);
            }
          }
        }
      }
    }
    return ordMaterialSaveList;
  }
  // add #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
  private String setMixDecimal(Map.Entry<String, Double> cdAmountenEntry, MstMedicineMix medicineMix) {
    // 小数点桁数を正しく保持する
    int decimalPoint = 0;
    if (null != medicineMix) {
      if (null != medicineMix.getUnitDecimalPoint()) {
        decimalPoint = medicineMix.getUnitDecimalPoint();
      }
    }
    // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen start
    // StringBuilder sb = new StringBuilder("#");
    StringBuilder sb = new StringBuilder("0");
    // mod 内部指摘#5825対応する。「指示・実績値」の値の保存不正を修正する。 dengshen end
    if (decimalPoint > 0) {
      sb.append(".");
      for (int i = 0; i < decimalPoint; i++) {
        sb.append(0);
      }
    }
    DecimalFormat df = new DecimalFormat(sb.toString());
    return df.format(cdAmountenEntry.getValue());
  }
  // add #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
  private OrdMaterialSave convertToOrdMaterialSave(ApiEntityOrdMain.ValiOrdMaterialSave conditions){
    OrdMaterialSave oms = new OrdMaterialSave();
    // 施設コード
    oms.setFacilityCd(conditions.getFacility_cd());
    // 患者ID
    oms.setPatId(Long.parseLong(conditions.getPat_id()));
    // データ基準日
    oms.setSuppliesBaseDate(conditions.getBase_date());
    // データ基準番号
    oms.setSuppliesBaseNo(Long.parseLong(conditions.getSupplies_base_no()));
    // データ発生元区分
    oms.setSuppliesSourceClass(String.valueOf(conditions.getSupplies_source_class()));
    // 物品区分
    oms.setSuppliesClass(conditions.getSupplies_class());
    // 物品コード
    oms.setSuppliesCd(conditions.getSupplies_cd());
    // 調整薬剤コード
    // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou start
    // oms.setMedicineMixCd(null);
    oms.setMedicineMixCd(conditions.getMedicine_mix_cd());
    // mod #8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 dou end
    // 分類コード
    oms.setClassCd(conditions.getClass_cd());
    // 指示・実績区分
    oms.setIndRstClass(conditions.getInd_rst_class());
    // 指示・実績値
    oms.setIndRstValue(conditions.getInd_rst_value());
    // レセ値
    oms.setReceiptValue(conditions.getReceipt_value());
    // 確定フラグ
    oms.setIsConfirm("0");
    //add FNSI-redmine 6824 ljx　start
    oms.setUpDate(new Timestamp(System.currentTimeMillis()));
    oms.setRegDate(new Timestamp(System.currentTimeMillis()));
    //add FNSI-redmine 6824 ljx　start
    return oms;
  }

   /**
   * 医療材料情報
   * @param conditions
   * @param setEquip
   * @param editEquipCodeList
   * @return
   */
        // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start//  private List<OrdMaterialSave> createEquipOrdMaterialSaveObj(String indRstClass, ApiEntityOrdMain.ValiOrdMaterialSave conditions,
//                                                              JSONArray setEquip, List<Integer> editEquipCodeList,
//                                                              MasterCacheHandler masterCacheHandler) {
   private List<OrdMaterialSave> createEquipOrdMaterialSaveObj(String indRstClass, ApiEntityOrdMain.ValiOrdMaterialSave conditions,
                                                               JSONArray setEquip, List<EquipCodeAndType> editEquipCodeList,
                                                               MasterCacheHandler masterCacheHandler) {
        // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
     List<OrdMaterialSave> ordMaterialSaveList = new ArrayList<>();
    if (null == setEquip || setEquip.length() == 0) {
      return ordMaterialSaveList;
    }
    // 医療材料情報取得值的设定
    // 同じ種類の計算材料を取得します(type,cd,amount)
    Map<String, Map<String, Double>> typeCdAmountMap = ordMainResource.sameKindCalculation(setEquip);
    Map<String, Double> mstEquipAmountMap = typeCdAmountMap.get("0");
    Iterator<Map.Entry<String, Double>> mstEquipEntry = mstEquipAmountMap.entrySet().iterator();
    while (mstEquipEntry.hasNext()) {
      Map.Entry<String, Double> mstEquipMap = mstEquipEntry.next();

      //add FNSI-redmine 3858 劉祥霖　start
        // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
      //String changeCd = mstEquipMap.getKey();
      String changeCd ="";
      Integer equipCd = null;
      String equipType = "";
      if (mstEquipMap.getKey().contains("-")){
        changeCd = mstEquipMap.getKey().split("-")[0];
        equipCd = Integer.parseInt(mstEquipMap.getKey().split("-")[0]);
        equipType = mstEquipMap.getKey().split("-")[1];
      }else {
        changeCd = mstEquipMap.getKey();
        equipCd = Integer.parseInt(mstEquipMap.getKey());
      }
      /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Only processe records that been edited on the page --start */
      //Integer equipCd = Integer.parseInt(mstEquipMap.getKey());
        // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
      // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
//      if(!editEquipCodeList.contains(equipCd)){
//        continue;
//      }
      boolean flag = false;
      for(EquipCodeAndType equipCodeAndType : editEquipCodeList){
        if (String.valueOf(equipCodeAndType.getEquipmentCd()).equals(equipCd.toString())
        && String.valueOf(equipCodeAndType.getEquipType()).equals(equipType)){
          flag = true;
          break;
        }
      }
      if (!flag){ continue; }
      // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
      /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: Only processe records that been edited on the page --start */

      String changeFlag = "11";
      for (int i = 0; i < setEquip.length(); i++) {
        JSONObject obj = setEquip.getJSONObject(i);
        String cd = obj.get("cd").toString();
        String equip_type = obj.get("equip_type").toString();
        if (cd.equals(changeCd)) {
          if (equip_type.equals("1")) {
            changeFlag = "01";
          }
          break;
        }
      }
      //add FNSI-redmine 3858 劉祥霖　end

      // 分類コード
      // 医療材料マスタ取得
      //MstEquipment mstEquipment = mstEquipDao.selectByEquipmentCd(Integer.parseInt(equipCd));
      // ADD 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou START
      String classCd = "-1" ;
      if (!"01".equals(changeFlag)) {
        // ADD 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou END
        MstEquipment mstEquipment = masterCacheHandler.getEquipmentByCd(equipCd);
//        String classCd = mstEquipment == null || (mstEquipment != null && mstEquipment.getClassCd() == null)
//          ? null : mstEquipment.getClassCd().toString();
        classCd = mstEquipment == null || (mstEquipment != null && mstEquipment.getClassCd() == null)
          ? null : mstEquipment.getClassCd().toString();
        //FNSI-add #6824 ljx  start
        if (!"-1".equals(classCd)) {
          MstEquipmentClass mstEquipmentClass = masterCacheHandler.getEquipmentClassByCd(mstEquipment.getClassCd());
          if (mstEquipmentClass != null && !"01".equals(changeFlag)) {
            int classType = mstEquipmentClass.getClassType().intValue();
            switch (classType) {
              case 1:
                changeFlag = "00";
                break;
              case 0:
              case 2:
              case 3:
                changeFlag = "11";
                break;
              case 4:
                changeFlag = "02";
                break;
              case 5:
                changeFlag = "03";
                break;
              case 6:
                changeFlag = "04";
                break;
              default:
                changeFlag = "11";
                break;
            }
          }
        }
        // add 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
      }
        // add 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
      //FNSI-add #6824 ljx  end
      // Map<String,String> conditionsMap = new HashMap<>();
      OrdMaterialSave oms = new OrdMaterialSave();
      // 施設コード
      oms.setFacilityCd(conditions.getFacility_cd());
      // 患者ID
      oms.setPatId(Long.parseLong(conditions.getPat_id()));
      // データ基準日
      oms.setSuppliesBaseDate(conditions.getBase_date());
      // データ基準番号
      oms.setSuppliesBaseNo(Long.parseLong(conditions.getSupplies_base_no()));
      // データ発生元区分
      oms.setSuppliesSourceClass(String.valueOf(conditions.getSupplies_source_class()));
      // 物品区分
      //mod FNSI-redmine 3858 劉祥霖　start
      oms.setSuppliesClass(changeFlag);
      //mod FNSI-redmine 3858 劉祥霖　end
      // 物品コード
      oms.setSuppliesCd(equipCd.toString());
      // 調整薬剤コード
      oms.setMedicineMixCd(null);
      // 分類コード
      oms.setClassCd(classCd);
      // 指示・実績区分
      oms.setIndRstClass(indRstClass);
      // 指示・実績値
      oms.setIndRstValue((Math.round(mstEquipMap.getValue()))+"");
      // レセ値
      //mod FNSI-redmine 6824 ljx　start
      //mod 8496 2023-03-29 【IES起票】【ord_material_save】医材に関するレせ値がない 張 start
//      oms.setReceiptValue(conditions.getReceipt_value());
      oms.setReceiptValue((Math.round(mstEquipMap.getValue()))+"");
      //mod 8496 2023-03-29 【IES起票】【ord_material_save】医材に関するレせ値がない 張 end
      //mod FNSI-redmine 6824 ljx　start
      // 確定フラグ
      oms.setIsConfirm("0");
      //add FNSI-redmine 6824 ljx　start
      oms.setRegDate(new Timestamp(System.currentTimeMillis()));
      oms.setUpDate(new Timestamp(System.currentTimeMillis()));
      //add FNSI-redmine 6824 ljx　end
      ordMaterialSaveList.add(oms);
    }
    return ordMaterialSaveList;
  }

  private void clearConditions(ApiEntityOrdMain.ValiOrdMaterialSave conditions) {
    // データ発生元区分
    conditions.setSupplies_source_class(null);
    // 物品区分
    conditions.setSupplies_class(null);
    // 物品コード
    conditions.setSupplies_cd(null);
    // 調整薬剤コード
    conditions.setMedicine_mix_cd(null);
    // 分類コード
    conditions.setClass_cd(null);
    // 指示・実績値
    conditions.setInd_rst_value(null);
    // レセ値
    conditions.setReceipt_value(null);
  }

}
