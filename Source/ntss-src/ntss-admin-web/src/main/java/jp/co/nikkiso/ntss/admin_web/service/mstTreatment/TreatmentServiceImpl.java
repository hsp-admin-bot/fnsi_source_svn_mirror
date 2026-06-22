package jp.co.nikkiso.ntss.admin_web.service.mstTreatment;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.AsyncService;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.IndHistoryMakeService;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistory;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.mstTreatment.utils.TreatMethodChangeHelper;
// del #11004 連携イベント発生部分不正 piao start
// import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordService;
// del #11004 連携イベント発生部分不正 piao end
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.admin_web.strategy.OrdMainTreatmentFactory;
import jp.co.nikkiso.ntss.admin_web.strategy.PatTreatmentPatternFactory;
import jp.co.nikkiso.ntss.admin_web.web.rest.DeviceEdgeOrderResource;
import jp.co.nikkiso.ntss.admin_web.web.rest.OrdMainResource;
import jp.co.nikkiso.ntss.admin_web.web.rest.PatInfoResource;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.IndicationUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PatTreatmentPatternUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.api.service.utils.InvokeResult;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdMaterialSaveDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMainOnly;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.exception.BusinessException;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.NtssUtils;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigInteger;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 治療方法マスタ画面 のService実装クラス.
 */
@Service
public class TreatmentServiceImpl implements TreatmentService {

  //add #9973 by ztc 20231027 mst_treatment変更後にmst _treatment_set start
  private static final String DISUSE_VALUE = "0";
  private static final String EXCLUDED_CTL_NO = "39";
  private static final String IND_COND_INFO_DEFAULT = "{\"1\":{\"value\":\"240\"},\"2\":{\"value\":null},\"3\":{\"value\":\"-1\"},\"4\":{\"value\":\"5\"},\"5\":{\"value\":null},\"6\":{\"value\":null},\"7\":{\"value\":null},\"8\":{\"value\":null},\"9\":{\"value\":null},\"10\":{\"value\":null},\"12\":{\"value\":\"0\"},\"13\":{\"value\":null},\"14\":{\"value\":\"200\"},\"15\":{\"value\":null},\"16\":{\"value\":\"500\"},\"17\":{\"value\":\"0\"},\"18\":{\"value\":\"36\"},\"19\":{\"value\":null},\"20\":{\"value\":\"0.0\"},\"21\":{\"value\":\"1\"},\"22\":{\"value\":\"0\"},\"23\":{\"value\":\"36.0\"},\"24\":{\"value\":\"0.00\"},\"25\":{\"value\":null},\"26\":{\"value\":\"0\"},\"27\":{\"value\":\"0\"},\"28\":{\"value\":\"0\"},\"29\":{\"value\":\"1\"},\"30\":{\"value\":\"1\"},\"31\":{\"value\":\"0\"},\"32\":{\"value\":\"0\"},\"33\":{\"value\":\"10\"},\"34\":{\"value\":\"0\"},\"35\":{\"value\":\"0\"},\"36\":{\"value\":\"0\"},\"37\":{\"value\":\"0\"},\"38\":{\"value\":\"0\"}}";
  //add #9973 by ztc 20231027 mst_treatment変更後にmst _treatment_set end

  // Add 治療方法マスタで治療方法を変更してもイベント作成されない xmj #7325 2022-8-23 start
  @Autowired
  private AsyncService asyncService;
  // Add 治療方法マスタで治療方法を変更してもイベント作成されない xmj #7325 2022-8-23 end
  /**
   * ログ出力Service.
   */
  @Autowired
  LogService logService;
  /**
   * {@link OrdMainDao}インタフェース
   */
  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * {@link PatTreatmentPatternDao}インタフェース.
   */
  @Autowired
  private PatTreatmentPatternDao patTreatmentPatternDao;

  @Autowired
  private MstTreatmentDao mstTreatmentDao;

  @Autowired
  OrdMainResource ordMainResource;

  @Autowired
  PatInfoResource patInfoResource;

  @Autowired
  FacilitySettingService FacilitySettingService;

  // add #10553 ⑫治療方法マスタの治療条件設定変更にう指示変更にて連携イベントを発生させること。 piao start
  @Autowired
  PatPersonalMainDao patPersonalMainDao;

  // del #11004 連携イベント発生部分不正 piao start
  // @Autowired
  // TreatmentRecordService treatmentRecordService;
  // del #11004 連携イベント発生部分不正 piao end
  // add #10553 ⑫治療方法マスタの治療条件設定変更にう指示変更にて連携イベントを発生させること。 piao end

  // add 2023-01-29 bug #8099 修正 chen start
  @Autowired
  JournalService journalService;
  // add 2023-01-29 bug #8099 修正 chen end

  // add #7327 治療方法マスタ操作時の動作がおかしい 王永吉 start
  @Autowired
  IndHistoryMakeService indHistoryMakeService;
  @Autowired
  private TriggerUtil triggerUtil;
  // add #7327 治療方法マスタ操作時の動作がおかしい 王永吉 end
  // add 9664 by kangjie 20231130 start 治療方法コード
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;
  @Autowired
  PatTreatmentPatternUtils patTreatmentPatternUtils;
  @Autowired
  DeviceEdgeOrderResource deviceEdgeOrderResource;
  @Autowired
  private OrdMaterialSaveDao ordMaterialSaveDao;
  @Autowired
  private OrdChecklistDao ordChecklistDao;
  @Autowired
  private PatIndApproveDao patIndApproveDao;

  // sql query column condition
  private final static String IND_COND_INFO_12 = "12";
  // add 9664 by kangjie 20231130 end 治療方法コード

  //  add #7327-治療方法マスタ操作時の動作がおかしい 徐博 start
  @Override
  public int getOrdMainByCd(String indTreatmentCd) {
    return mstTreatmentDao.getOrdMainByCd(indTreatmentCd);
  }
  //  add #7327-治療方法マスタ操作時の動作がおかしい 徐博 end

  /**
   * {@inheritDoc}
   */
  @Override
  public void updateOrdMain(String facilityCd, List<Integer> treatmentCdList, Map<Integer, JSONObject> map,
                            Long userId) throws NotExistException {

    for (int treatmentCd : treatmentCdList) {
      /*mod #8495 by zhangruixue 2023-03-28  GC overhead limit exceeded  start*/
      List<Long> ordNoS = ordMainDao.selectOrdNoByTreatmentCd(facilityCd, treatmentCd, true);
      if(ordNoS.size() > 0) {
        List<List<Long>> splitList = this.splitList(ordNoS, 1000);
        if (splitList.size() > 0) {
          for(List<Long> paramList : splitList){
            List<OrdMain> ordMainList = ordMainDao.selectByTreatmentCd(facilityCd, treatmentCd, true,paramList);
      /*mod #8495 by zhangruixue 2023-03-28  GC overhead limit exceeded  end*/
            if (ordMainList.size() > 0) {
              List<Long> ordNoList = ordMainList.stream().map(item -> item.getOrdNo()).distinct()
                .collect(Collectors.toList());
              MstTreatment selectedTreat = mstTreatmentDao.selectByCd(treatmentCd);
              JSONArray treatCondSetting = null == selectedTreat.getTreatmentConditionSetting() ? new JSONArray()
                : new JSONArray(selectedTreat.getTreatmentConditionSetting());
              JSONObject toAddTreatCond = new JSONObject();
              List<String> toDeleteTreatCondList = new ArrayList<String>();
              for (Integer i = 1; i <= 38; i++) {
                String key = i.toString();
                Boolean isUse = checkTreatCondIsUse(treatCondSetting, key);
                if (isUse) {
                  JSONObject bufJson = new JSONObject();
                  // 設定値
                  bufJson.put("value", TreatmentItemsDef.getDefaultValue(i+""));
                  // 翻訳1
                  bufJson.put("value_name_1", JSONObject.NULL);
                  // 単位
                  bufJson.put("unit", JSONObject.NULL);
                  // 薬剤区分
                  bufJson.put("medicine_type", JSONObject.NULL);
                  // 指示者コード
                  bufJson.put("ind_user_id", userId);
                  // 指示者名_姓
                  bufJson.put("ind_user_last_name", JSONObject.NULL);
                  // 指示者名_名
                  bufJson.put("ind_user_first_name", JSONObject.NULL);
                  // 更新者コード
                  bufJson.put("upd_user_id", userId);
                  // 更新者名_姓
                  bufJson.put("upd_user_last_name", JSONObject.NULL);
                  // 更新者名_名
                  bufJson.put("upd_user_first_name", JSONObject.NULL);
                  // 登録区分
                  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
                  //bufJson.put("input_class", "1");
                  bufJson.put("input_class", 1);
                  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
                  // 編集可否フラグ
                  bufJson.put("is_editable", "1");
                  // 連携オーダ番号
                  bufJson.put("cop_order_no", JSONObject.NULL);

                  toAddTreatCond.put(key, bufJson);
                } else {
                  toDeleteTreatCondList.add(key);
                }
              }
              List<OrdMain> oldOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
              ordMainDao.updateIndCondInfoWithTreatCondSetting(ordNoList, toAddTreatCond.toString(),
                toDeleteTreatCondList, false);
              List<OrdMain> newOrdMains = ordMainDao.selectAllByOrdNoList(ordNoList);
              triggerUtil.updateTriggerOrdMain(oldOrdMains, newOrdMains);
            }
          }
        }
      }
    }
  }

  @Override
  public void updatePatTreatmentPattern(String facilityCd, List<Integer> treatmentCdList,
                                        Map<Integer, JSONObject> map, Long userId) throws NotExistException {
    // TODO Auto-generated method stub
    for (Integer treatmentCd : treatmentCdList) {
      List<PatTreatmentPattern> pTPList = patTreatmentPatternDao.selectByTreatmentCd(facilityCd, treatmentCd);
      if (pTPList.size() > 0) {
        MstTreatment selectedTreat = mstTreatmentDao.selectByCd(treatmentCd);
        JSONArray treatCondSetting = null == selectedTreat.getTreatmentConditionSetting() ? new JSONArray()
          : new JSONArray(selectedTreat.getTreatmentConditionSetting());
        JSONObject toAddTreatCond = new JSONObject();
        List<String> toDeleteTreatCondList = new ArrayList<String>();
        for (Integer i = 1; i <= 38; i++) {
          String key = i.toString();
          Boolean isUse = checkTreatCondIsUse(treatCondSetting, key);
          if (isUse) {
            JSONObject bufJson = new JSONObject();
            // 設定値
            bufJson.put("value", TreatmentItemsDef.getDefaultValue(i+""));
            // 翻訳1
            bufJson.put("value_name_1", JSONObject.NULL);
            // 単位
            bufJson.put("unit", JSONObject.NULL);
            // 薬剤区分
            bufJson.put("medicine_type", JSONObject.NULL);
            // 指示者コード
            bufJson.put("ind_user_id", userId);
            // 指示者名_姓
            bufJson.put("ind_user_last_name", JSONObject.NULL);
            // 指示者名_名
            bufJson.put("ind_user_first_name", JSONObject.NULL);
            // 更新者コード
            bufJson.put("upd_user_id", userId);
            // 更新者名_姓
            bufJson.put("upd_user_last_name", JSONObject.NULL);
            // 更新者名_名
            bufJson.put("upd_user_first_name", JSONObject.NULL);
            // 登録区分
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
            //bufJson.put("input_class", "1");
            bufJson.put("input_class", 1);
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            // 編集可否フラグ
            bufJson.put("is_editable", "1");
            // 連携オーダ番号
            bufJson.put("cop_order_no", JSONObject.NULL);

            toAddTreatCond.put(key, bufJson);
          } else {
            toDeleteTreatCondList.add(key);
          }
        }

        patTreatmentPatternDao.updateIndCondInfoWithTreatCondSetting(treatmentCd, toAddTreatCond.toString(),
          toDeleteTreatCondList);
      }
    }
  }

  /**
   * 治療方法による治療条件設定使用チェック
   *
   * @param treatCondSetting 治療方法設定
   * @param treatKey         治療条件項目番号
   * @return 使用フラグ
   */
  private Boolean checkTreatCondIsUse(JSONArray treatCondSetting, String treatKey) {
    for (int i = 0; i < treatCondSetting.length(); i++) {
      JSONArray items = treatCondSetting.getJSONObject(i).getJSONArray("items");
      for (int j = 0; j < items.length(); j++) {
        if (items.getJSONObject(j).get("ctl_no").equals(treatKey)
          && items.getJSONObject(j).get("is_use").equals("0")) {
          return false;
        }
      }
    }

    return true;
  }

  @Transactional
  @Override
  public InvokeResult<Map<String,List>> updateOrdMainForMstTreatment(String facilityCd, Map treatment, Long userId, NtssUser ntssUser) throws NotExistException {
    Integer treatmentCode = (Integer) treatment.get("code");
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage("治療マスタの治療条件変更に伴い、配布処理を開始します");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    // メッセージ用文字列
    StringBuilder sb = new StringBuilder();

    ArrayList<Map> success = new ArrayList<>();
    ArrayList<OrdMain> error = new ArrayList<>();
    ArrayList<Map> patPatternSuccess = new ArrayList<>();
    ArrayList<PatTreatmentPattern> patPatternError = new ArrayList<>();

    int defaultSelDoctorNumber = Integer.parseInt(treatment.get("selectedDoctorNo").toString());
    // つの治療条件設定の差分を比較する
    String treatmentConditionSetting = String.valueOf(treatment.get("treatmentConditionSetting"));
    String oldTreatmentConditionSetting = String.valueOf(treatment.get("oldTreatmentConditionSetting"));
    TreatMethodChangeHelper treatMethodChangeHelper = new TreatMethodChangeHelper();
    treatMethodChangeHelper.compareConditionSettingDiff(treatmentConditionSetting,oldTreatmentConditionSetting);

    // deviceMode変化
    treatMethodChangeHelper.setNewDeviceMode(String.valueOf(treatment.get("deviceMode")));
    treatMethodChangeHelper.setOldDeviceMode(String.valueOf(treatment.get("oldDeviceMode")));


    List<OrdMain> callNextPatOrdMainList = new ArrayList<>();
    List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
    // 治療条件の設定に変化があった場合やdeviceModelに変化があった場合
    if (treatMethodChangeHelper.isDeviceModelChanged() || treatMethodChangeHelper.isCondChanged()) {
      // 治療条件設定の変化の有無
      // 治療条件の設定に変化があれば、治療法セットマスタを更新する
      String getDisUseCtlNoRst = this.getDisUseCtlNoFrTreatCondSetting(treatment.get("treatmentConditionSetting").toString());

//      mstTreatmentDao.updIndCondInfoByDisUse(facilityCd, treatmentCode, IND_COND_INFO_DEFAULT, getDisUseCtlNoRst);

      this.updateMstTreatmentSetService(facilityCd,treatmentCode,IND_COND_INFO_DEFAULT,getDisUseCtlNoRst,treatMethodChangeHelper);

      // 者治療用パターンの更新
      this.updatePatTreatmentPatternService(facilityCd, treatment, defaultSelDoctorNumber, userId,treatMethodChangeHelper, sb, patPatternSuccess, patPatternError, eventLogMessage);

      // 治療予定ord _main.ind_cond_infoによる更新
      // 治療予定ord _main.ind_deviceset_infoによる更新
      InvokeResult<List<OrdMain>> invokeResult = this.updateOrdMainService(facilityCd, treatment, defaultSelDoctorNumber, userId, treatMethodChangeHelper, sb, success, error, eventLogMessage);
      if(invokeResult.isSuccess()){
        // 次患者更新
        callNextPatOrdMainList = invokeResult.getData();

        // 治療方法マスタの中の装置モードの項目を変更した場合,外部連携イベントを送信する
        ctlNoList = this.sendCreateJournalApi(facilityCd, treatment, invokeResult.getData(), userId);
      }
    }
    eventLogMessage.setLogMessage("配布処理完了しました（成功件数：" + (success.size() + patPatternSuccess.size()) + "、失敗件数：" + (error.size() + patPatternError.size()) + ")");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    Map<String,List> resultData = new HashMap<>();
    resultData.put("success", success);
    resultData.put("error", error);
    resultData.put("patPatternSuccess", patPatternSuccess);
    resultData.put("patPatternError", patPatternError);
    resultData.put("callNextPatOrdMainList", callNextPatOrdMainList); // 次患者更新はController層（トランザクション以外）で呼び出す
    resultData.put("ctlNoList", ctlNoList); // 外部連携データベースを送信するにはコントローラ層（トランザクション外）で呼び出す
    InvokeResult<Map<String,List>> invokeResult = new InvokeResult<>();
    invokeResult.success(resultData);
    return invokeResult;
  }

  /**
  * @Author kangjie
  * @Description
  * @Date 2024/05/27 19:05
  * @Param [facilityCd, treatmentCode, indCondInfoDefault, getDisUseCtlNoRst, treatMethodChangeHelper]
  * @return void
  **/
  private void updateMstTreatmentSetService(String facilityCd, Integer treatmentCode, String indCondInfoDefault,
      String getDisUseCtlNoRst, TreatMethodChangeHelper treatMethodChangeHelper) {
    String newDeviceMode = treatMethodChangeHelper.getNewDeviceMode();
    String oldDeviceMode = treatMethodChangeHelper.getOldDeviceMode();

    // 補液无(0:HD;1:ECUM)
    if (Objects.equals(oldDeviceMode, "0") || Objects.equals(oldDeviceMode, "1")) {
      // 補液无 ->offLine (2:HDF;3:HF;6:AFBF)
      if (Objects.equals(newDeviceMode, "2") || Objects.equals(newDeviceMode, "3")
          || Objects.equals(newDeviceMode, "6")) {
        mstTreatmentDao.updIndCondInfoByDisUseAndOne(facilityCd, treatmentCode, IND_COND_INFO_DEFAULT, getDisUseCtlNoRst);
      }
      // 補液无 ->onLine (7:OHDF;8:OHF;10:IHDF)
      if (Objects.equals(newDeviceMode, "7") || Objects.equals(newDeviceMode, "8")
          || Objects.equals(newDeviceMode, "10")) {
        mstTreatmentDao.updIndCondInfoByDisUseAndTwo(facilityCd, treatmentCode, IND_COND_INFO_DEFAULT, getDisUseCtlNoRst);
      }
    }
    // offLine (2:HDF;3:HF;6:AFBF)
    if (Objects.equals(oldDeviceMode, "2") || Objects.equals(oldDeviceMode, "3")
        || Objects.equals(oldDeviceMode, "6")) {
      // offLine ->補液无(0:HD;1:ECUM)
      if (Objects.equals(newDeviceMode, "0") || Objects.equals(newDeviceMode, "1")) {
        mstTreatmentDao.updIndCondInfoByDisUseAndDel(facilityCd, treatmentCode, IND_COND_INFO_DEFAULT, getDisUseCtlNoRst);
      }
      // offLine -> onLine (7:OHDF;8:OHF;10:IHDF)
      if (Objects.equals(newDeviceMode, "7") || Objects.equals(newDeviceMode, "8")
          || Objects.equals(newDeviceMode, "10")) {
        mstTreatmentDao.updIndCondInfoByDisUseAndFour(facilityCd, treatmentCode, IND_COND_INFO_DEFAULT, getDisUseCtlNoRst);
      }
    }
    // onLine (7:OHDF;8:OHF;10:IHDF)
    if (Objects.equals(oldDeviceMode, "7") || Objects.equals(oldDeviceMode, "8")
        || Objects.equals(oldDeviceMode, "10")) {
      // onLine ->補液无(0:HD;1:ECUM)
      if (Objects.equals(newDeviceMode, "0") || Objects.equals(newDeviceMode, "1")) {
        mstTreatmentDao.updIndCondInfoByDisUseAndDel(facilityCd, treatmentCode, IND_COND_INFO_DEFAULT, getDisUseCtlNoRst);
      }
      // onLine -> offLine (2:HDF;3:HF;6:AFBF)
      if (Objects.equals(newDeviceMode, "2") || Objects.equals(newDeviceMode, "3")
          || Objects.equals(newDeviceMode, "6")) {
        mstTreatmentDao.updIndCondInfoByDisUseAndThree(facilityCd, treatmentCode, IND_COND_INFO_DEFAULT, getDisUseCtlNoRst);
      }
    }
    // 特殊浄化
    if (Objects.equals(newDeviceMode, "9") || Objects.equals(oldDeviceMode, newDeviceMode)
        || Objects.equals(oldDeviceMode, "9")) {
      mstTreatmentDao.updIndCondInfoByDisUse(facilityCd, treatmentCode, IND_COND_INFO_DEFAULT, getDisUseCtlNoRst);
    }
  }

  /**
   * 次患者更新
   * @param facilityCd
   * @param ordMainList
   */
  @Override
  public void callSetNextPatInfo(String facilityCd, List<OrdMain> ordMainList) {
    if (ordMainList == null || ordMainList.isEmpty()) {
      return;
    }
    List<Long> nextPatIdList = ordMainList.stream().map(item -> item.getPatId()).distinct().collect(Collectors.toList());
    List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectByNextPatIdList(facilityCd, nextPatIdList);
    Map<Long, MntMachineState> machineStateMapByNextOrdNo = new HashMap<>();
    for (MntMachineState state : mntMachineStateList) {
      machineStateMapByNextOrdNo.put(state.getNextOrdNo(), state);
    }
    LocalDateTime update = LocalDateTime.now();
    for (OrdMain ord : ordMainList) {
      if (machineStateMapByNextOrdNo.containsKey(ord.getOrdNo())) {
        MntMachineState mntMachineState = machineStateMapByNextOrdNo.get(ord.getOrdNo());
        ordMainResource.callDoCancelSetNextPatInfo(facilityCd, 0l, mntMachineState.getBedCd(), ord, true, update);
      }
    }
  }

  //del #10412 次患者更新関連全体見直し対応 朴 start
//  // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
//  @Override
//  @Transactional
//  // mod bug 8099 修正 chen start
//  public JournalCreateRequestResponse updateOrdMainForTreatment(String facilityCd, List<Map<String, Object>> treatmentList, Long userId, NtssUser ntssUser) throws NotExistException, ParseException {
//  // mod bug 8099 修正 chen end
//
//    // add ログ改善対応 劉 start
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setFacilityCd(facilityCd);
//    eventLogMessage.setLogMessage("治療マスタの治療条件変更に伴い、配布処理を開始します");
//    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
//
//    // メッセージ用文字列
//    StringBuilder sb = new StringBuilder();
//    // add ログ改善対応 劉 end
//    // mod bug 8099 修正 chen start
//    List<JournalCreateRequestPayload> ctlNoListAll = new ArrayList<>();
//    String defaultSelDoctor = FacilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.DEFAULT_SEL_DOCTOR);
//    int defaultSelDoctorNumber = 0;
//    try {
//      defaultSelDoctorNumber = Integer.parseInt(defaultSelDoctor);
//    } catch (NumberFormatException e) {
//      eventLogMessage.setLogMessage("デフォルト選択医師設定のデータ取得に失敗しました");
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
//    }
//    // if (defaultSelDoctorNumber == 0) return new JSONObject("{}");
//    if (defaultSelDoctorNumber == 0) {
//      JournalCreateRequestResponse response = new JournalCreateRequestResponse();
//      response.setResponse(new ResponseEntity<>((new JSONObject("{}")).toString(), (org.springframework.http.HttpHeaders) null, HttpStatus.OK));
//      response.setCtlNoList(ctlNoListAll);
//      return response;
//    }
//    // mod bug 8099 修正 chen end
//
//    // TODO Auto-generated method stub
//    ArrayList<Map> success = new ArrayList<>();
//    ArrayList<OrdMain> error = new ArrayList<>();
//    ArrayList<Map> patPatternSuccess = new ArrayList<>();
//    ArrayList<PatTreatmentPattern> patPatternError = new ArrayList<>();
//
//    // add #7327 治療方法マスタ操作時の動作がおかしい 王永吉 start
//    treatmentChangeToMongo(treatmentList, facilityCd, userId);
//    indHistoryMakeService.getOrdAndNewDeviceModes(null);
//    // add #7327 治療方法マスタ操作時の動作がおかしい 王永吉 end
//    for (Map treatment : treatmentList) {
//      //add #9973 by ztc 20231027 mst_treatment変更後にmst _treatment_set start
//      Integer treatmentCode = (Integer) treatment.get("code");
//      String getDisUseCtlNoRst = this.getDisUseCtlNoFrTreatCondSetting(treatment.get("treatmentConditionSetting").toString());
//      mstTreatmentDao.updIndCondInfoByDisUse(facilityCd, treatmentCode, IND_COND_INFO_DEFAULT, getDisUseCtlNoRst);
//      //add #9973 by ztc 20231027 mst_treatment変更後にmst _treatment_set end
//      // mod 8235 周安寧 start
//      //List<OrdMain> ordMainList = ordMainDao.selectByTreatmentCd(facilityCd, (Integer) treatment.get("code"), true);
//      /* mod #8677  治療方法マスタを変更保存するとシステムが停止する。 by zhangruixue 2023-05-25 --start */
////      List<OrdMain> ordMainList = ordMainDao.selectByTreatmentCdUpdateAll(facilityCd, (Integer) treatment.get("code"), true);
//      //mod #9973 by ztc 20231027 mst_treatment変更後にmst _treatment_set start
//      List<OrdMain> ordMainList = ordMainDao.selectByFacilityCdTreatmentCd(facilityCd, treatmentCode, true);
//      //mod #9973 by ztc 20231027 mst_treatment変更後にmst _treatment_set end
//      /* mod #8677  by zhangruixue 2023-05-25 --end */
//      // mod 8235 周安寧 end
//      // mod bug 8099 修正 shi start
//      if (ordMainList.size() > 0) {
//
//        // Boolean isUpdateReplenishLiquid = false;
//        // Integer deviceMode = Integer.parseInt((String) treatment.get("deviceMode"));
//        // Long oldDeviceMode = null;
//        // if (treatment.get("oldDeviceMode") != null) {
//        //   oldDeviceMode = Long.parseLong((String) treatment.get("oldDeviceMode"));
//        //
//        // }
//        // 補液に透析液を同じ値を設定
//        // if (
//        //   deviceMode.equals(AdminWebConstant.Treatment.DeviceMode.HD_AND_REPLACEMENT) ||
//        //     deviceMode.equals(AdminWebConstant.Treatment.DeviceMode.OHDF) ||
//        //     deviceMode.equals(AdminWebConstant.Treatment.DeviceMode.OHF) ||
//        //     deviceMode.equals(AdminWebConstant.Treatment.DeviceMode.I_HDF)
//        // ) {
//        //   isUpdateReplenishLiquid = true;
//        // }
//        Map<Integer, List<OrdMain>> kurMap = new HashMap<>();
//        for (OrdMain ordMain : ordMainList) {
//          if (kurMap.containsKey(ordMain.getIndKurCd())) {
//            kurMap.get(ordMain.getIndKurCd()).add(ordMain);
//          } else {
//            List<OrdMain> patIdList = new ArrayList<>();
//            patIdList.add(ordMain);
//            kurMap.put(ordMain.getIndKurCd(), patIdList);
//          }
//        }
//        String tempWeek = "[\n" +
//                "                {\"text\": \"全\", \"done\": false, \"value\": 0},\n" +
//                "                {\"text\": \"月\", \"done\": false, \"value\": 1},\n" +
//                "                {\"text\": \"火\", \"done\": false, \"value\": 2},\n" +
//                "                {\"text\": \"水\", \"done\": false, \"value\": 3},\n" +
//                "                {\"text\": \"木\", \"done\": false, \"value\": 4},\n" +
//                "                {\"text\": \"金\", \"done\": false, \"value\": 5},\n" +
//                "                {\"text\": \"土\", \"done\": false, \"value\": 6},\n" +
//                "                {\"text\": \"日\", \"done\": false, \"value\": 7}\n" +
//                "              ]";
//        for (Integer kurCd : kurMap.keySet()) {
//          List<OrdMain> ordMainListKur = kurMap.get(kurCd);
//          List<Long> patIdList = ordMainListKur.stream().map(OrdMain::getPatId).distinct().collect(Collectors.toList());
//          Date startDate = null;
//          Date endDate = null;
//          for (OrdMain ordMain : ordMainListKur) {
//            Date treatDate = new SimpleDateFormat("yyyyMMdd").parse(ordMain.getTreatDate());
//            if (startDate == null) {
//              startDate = treatDate;
//            } else {
//              if (startDate.compareTo(treatDate) > 0) {
//                startDate = treatDate;
//              }
//            }
//            if (endDate == null) {
//              endDate = treatDate;
//            } else {
//              if (endDate.compareTo(treatDate) < 0) {
//                endDate = treatDate;
//              }
//            }
//          }
//          String startDateStr = new SimpleDateFormat("yyyy-MM-dd").format(startDate);
//          String endDateStr = new SimpleDateFormat("yyyy-MM-dd").format(endDate);
//          String upDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date());
//          for (Long patId : patIdList) {
//            try {
//              // JSONArray jsonArray = new JSONArray(tempWeek);
//              // for (int i = 0; i < jsonArray.length(); i++) {
//              //   JSONObject jsonObject = (JSONObject) jsonArray.get(i);
//              //   if (ordMainList.get(0).getTreatWeek() == 0 ||
//              //     jsonObject.get("value").equals((int) ordMainList.get(0).getTreatWeek())) {
//              //     jsonObject.put("done", true);
//              //   }
//              // }
//              // tempWeek = jsonArray.toString();
//
//              Integer[] indKurCdArr = {kurCd};
//              Integer[] indTreatmentCdArr = {(Integer) treatment.get("code")};
//
//              ApiEntityOrdMain.ValiCreateTreatPlan bodyData = new ApiEntityOrdMain.ValiCreateTreatPlan();
//
//              // 治療方法名
//              bodyData.setTreatment_name((String) treatment.get("name"));
//              // 治療方法コード
//              bodyData.setTreatment_set_cd(String.valueOf(treatment.get("code")));
//              // 更新日時
//              bodyData.setUp_date(upDate);
//              // 患者ID
//              bodyData.setPat_id(String.valueOf(patId));
//              // 開始日
//              bodyData.setStart_date(startDateStr);
//              // 終了日
//              bodyData.setEnd_date(endDateStr);
//              // 施設コード
//              bodyData.setFacility_cd(facilityCd);
//              // 曜日Jsonデータ
//              bodyData.setWeek_pattern(tempWeek);
//              // 変更対象クール
//              // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  strat
//              // bodyData.setTarget_kur_cd(Arrays.toString(indKurCdArr));
//              bodyData.setInd_kur_cd(Arrays.toString(indKurCdArr));
//              // 変更対象治療方法
//              // bodyData.setTarget_treatment_cd(Arrays.toString(indTreatmentCdArr));
//              bodyData.setInd_treatment_cd(Arrays.toString(indTreatmentCdArr));
//              // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
//              // 指示者コード
////            bodyData.setInd_user_id(BigInteger.valueOf(ordMain.getUpIndUserId()));
//              bodyData.setInd_user_id(BigInteger.valueOf(defaultSelDoctorNumber));
//              // 更新者コード
////            bodyData.setUpd_user_id(BigInteger.valueOf(ordMain.getUpUserId()));
//              bodyData.setUpd_user_id(BigInteger.valueOf(userId));
//              // 治療方法変更フラグ
//              bodyData.setTreat_method_flag(String.valueOf(0));
//              // 終了日格納有無
//              bodyData.setIs_deadline(String.valueOf(true));
//              // add 7760 【デグレ】治療方法マスタを編集すると全透析装置へ次患者情報が再送される zhao start
//              if(treatment.get("nextFlag")!=null){
//                bodyData.setNextFlag(treatment.get("nextFlag").toString());
//              }
//              // add 7760 【デグレ】治療方法マスタを編集すると全透析装置へ次患者情報が再送される zhao end
//
//
//              // List<Long> ordNoList = new ArrayList<Long>();
//              // Long ordNo = ordMain.getOrdNo();
//              // if (ordNo != null) {
//              //   ordNoList.add(ordNo);
//              // }
//
//              //　補液更新
//              // ordMainDao.updateIndCondInfoWithTreatMethodNonReplenishSup(ordNoList, isUpdateReplenishLiquid, oldDeviceMode);
//              // List<Long> updateOrdNos2 = ordMainDao.selectUpdateIndCondInfoWithTreatMethodReplenishSup(ordNoList, isUpdateReplenishLiquid, oldDeviceMode);
//              // List<OrdMain> oldOrdMains2 = ordMainDao.selectAllByOrdNoList(updateOrdNos2);
//              // ordMainDao.updateIndCondInfoWithTreatMethodReplenishSup(ordNoList, isUpdateReplenishLiquid, oldDeviceMode);
//              // List<OrdMain> newOrdMains2 = ordMainDao.selectAllByOrdNoList(updateOrdNos2);
//              // triggerUtil.updateTriggerOrdMain(oldOrdMains2, newOrdMains2);
//
//              //upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --start /
//              ResponseEntity<String> stringResponseEntity = ordMainResource.updatetByTreatSetCdOptimize(bodyData, null, ntssUser);
//              //upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --end /
//              if (stringResponseEntity.getStatusCode() == HttpStatus.OK) {
//
//                // add ログ改善対応 劉 start
//                Map<String, Long> ordMainTemp = new HashMap<>();
//                for (OrdMain ordMain : ordMainListKur) {
//                  sb.setLength(0);
//                  sb.append("配布処理成功 「ord_no : " + ordMain.getOrdNo());
//                  sb.append(", pat_id」 : " + ordMain.getPatId());
//                  sb.append("は 「" + treatment.get("treatmentConditionSetting"));
//                  sb.append("」 のように更新しました");
//
//                  eventLogMessage.setLogMessage(sb.toString());
//                  logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
//                  // add ログ改善対応 劉 start
//
//                  ordMainTemp.put("ordNo", ordMain.getOrdNo());
//                  ordMainTemp.put("patId", ordMain.getPatId());
//                  success.add(ordMainTemp);
//                }
//              } else {
//
//                for (OrdMain ordMain : ordMainListKur) {
//                  // add ログ改善対応 劉 start
//                  eventLogMessage.setLogMessage("配布処理失敗 「ord_no: " + ordMain.getOrdNo() + ", pat_id: " + ordMain.getPatId() + "」");
//                  logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
//                  // add ログ改善対応 劉 end
//
//                  error.add(ordMain);
//                }
//              }
//            } catch (Exception e) {
//
//              for (OrdMain ordMain : ordMainListKur) {
//                // add ログ改善対応 劉 start
//                eventLogMessage.setLogMessage("配布処理失敗　「ord_no: " + ordMain.getOrdNo() + ", pat_id: " + ordMain.getPatId() + "」");
//                logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
//                // add ログ改善対応 劉 end
//
//                error.add(ordMain);
//              }
//              e.printStackTrace();
//            }
//          }
//        }
//      }
//
//      List<PatTreatmentPattern> pTPList = patTreatmentPatternDao.selectByTreatmentCd(facilityCd, (Integer) treatment.get("code"));
//      if (pTPList.size() > 0) {
//        Integer treatmentCd = (Integer) treatment.get("code");
//        MstTreatment selectedTreat = mstTreatmentDao.selectByCd(treatmentCd);
//        JSONArray treatCondSetting = null == selectedTreat.getTreatmentConditionSetting() ? new JSONArray()
//                : new JSONArray(selectedTreat.getTreatmentConditionSetting());
//        JSONObject toAddTreatCond = new JSONObject();
//        List<String> toDeleteTreatCondList = new ArrayList<String>();
//        for (Integer i = 1; i <= 38; i++) {
//          String key = i.toString();
//          Boolean isUse = checkTreatCondIsUse(treatCondSetting, key);
//          if (isUse) {
//            JSONObject bufJson = new JSONObject();
//            // 設定値
//            bufJson.put("value", TreatmentItemsDef.getDefaultValue(i+""));
//            // 翻訳1
//            bufJson.put("value_name_1", JSONObject.NULL);
//            // 単位
//            bufJson.put("unit", JSONObject.NULL);
//            // 薬剤区分
//            bufJson.put("medicine_type", JSONObject.NULL);
//            // 指示者コード
//            bufJson.put("ind_user_id", defaultSelDoctorNumber);
//            // 指示者名_姓
//            bufJson.put("ind_user_last_name", JSONObject.NULL);
//            // 指示者名_名
//            bufJson.put("ind_user_first_name", JSONObject.NULL);
//            // 更新者コード
//            bufJson.put("upd_user_id", userId);
//            // 更新者名_姓
//            bufJson.put("upd_user_last_name", JSONObject.NULL);
//            // 更新者名_名
//            bufJson.put("upd_user_first_name", JSONObject.NULL);
//            // 登録区分
//            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//            //bufJson.put("input_class", "1");
//            bufJson.put("input_class", 1);
//            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
//            // 編集可否フラグ
//            bufJson.put("is_editable", "1");
//            // 連携オーダ番号
//            bufJson.put("cop_order_no", JSONObject.NULL);
//
//            toAddTreatCond.put(key, bufJson);
//          } else {
//            toDeleteTreatCondList.add(key);
//          }
//        }
//        for (PatTreatmentPattern patTP : pTPList) {
//          try {
//            int res = patTreatmentPatternDao.updateIndCondInfo(patTP.getPatId(), patTP.getCtlNo(), toAddTreatCond.toString(), toDeleteTreatCondList);
//            if(res > 0 ){
//
//              sb.setLength(0);
//              sb.append("配布処理成功 「ctl_no : " + patTP.getCtlNo());
//              sb.append(", pat_id」 : " + patTP.getPatId());
//              sb.append("は 「" + treatment.get("treatmentConditionSetting"));
//              sb.append("」 のように更新しました");
//
//              eventLogMessage.setLogMessage(sb.toString());
//              logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
//
//
//              Map<String, Long> patPatternTemp = new HashMap<>();
//              patPatternTemp.put("ctlNo", patTP.getCtlNo());
//              patPatternTemp.put("patId", patTP.getPatId());
//              patPatternSuccess.add(patPatternTemp);
//            }
//          } catch (Exception e) {
//            eventLogMessage.setLogMessage("配布処理失敗　「ctl_no: " + patTP.getCtlNo() + ", pat_id: " + patTP.getPatId() + "」");
//            logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
//            patPatternError.add(patTP);
//            e.printStackTrace();
//          }
//        }
//      }
//      // mod bug 8099 修正 chen start
//      ctlNoListAll.addAll(this.sendCreateJournalApi(facilityCd, treatment, ordMainList, userId));
//      // mod bug 8099 修正 chen end
//    }
//    // mod bug 8099 修正 shi end
//    // add ログ改善対応 劉 start
//    eventLogMessage.setLogMessage("配布処理完了しました（成功件数：" + (success.size() + patPatternSuccess.size()) + "、失敗件数：" + (error.size() + patPatternError.size()) + ")");
//    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
//    // add ログ改善対応 劉 end
//
//    JSONObject data = new JSONObject("{}");
//    data.put("success", success);
//    data.put("error", error);
//    data.put("patPatternSuccess", patPatternSuccess);
//    data.put("patPatternError", patPatternError);
//    // mod bug 8099 修正 chen start
//    JournalCreateRequestResponse response = new JournalCreateRequestResponse();
//    response.setResponse(new ResponseEntity<>(data.toString(), (org.springframework.http.HttpHeaders) null, HttpStatus.OK));
//    response.setCtlNoList(ctlNoListAll);
//    return response;
//    // return data;
//    // mod bug 8099 修正 chen end
//  }
  //del #10412 次患者更新関連全体見直し対応 朴 end

  /**
   * 患者治療パターンDBの更新
   *
   * @param facilityCd
   * @param treatment
   * @param defaultSelDoctorNumber
   * @param userId
   * @param treatMethodChangeHelper
   * @param sb
   * @param patPatternSuccess
   * @param patPatternError
   * @param eventLogMessage
   */
  private void updatePatTreatmentPatternService(String facilityCd, Map treatment, int defaultSelDoctorNumber, Long userId,
      TreatMethodChangeHelper treatMethodChangeHelper, StringBuilder sb, ArrayList<Map> patPatternSuccess,
      ArrayList<PatTreatmentPattern> patPatternError, EventLogMessage eventLogMessage) {
    // 1、患者治療パターン DB取得
    List<PatTreatmentPattern> pTPList = patTreatmentPatternDao.selectByTreatmentCd(facilityCd, (Integer) treatment.get("code"));
    if (CollectionUtils.isEmpty(pTPList)) {
      return;
    }
    // 2、指示：治療条件情報 add key  取得
    Integer treatmentCd = (Integer) treatment.get("code");
    MstTreatment selectedTreat = mstTreatmentDao.selectByCd(treatmentCd);
    JSONObject isUsedKeyJsonInfo = getIsUsedKeyJsonInTreatmentIndCond(selectedTreat, BigInteger.valueOf(defaultSelDoctorNumber), BigInteger.valueOf(userId));
    String indCondInfoForceUpdate = getIndCondInfoForceUpdateData(selectedTreat, treatMethodChangeHelper);
    Integer deviceMode = selectedTreat.getDeviceMode();
    OrdMainOnly ordMainOnly = new OrdMainOnly();
    // 施设cd
    ordMainOnly.setFacilityCd(facilityCd);
    ordMainOnly.setIndCondInfo(isUsedKeyJsonInfo.toString());

    // sn针处理
    List<String> indCondInfoForNeedleA = new ArrayList<>();
    List<String> indCondInfoForNeedleR = new ArrayList<>();
    getIndCondInfoForNeedleeUpdateData(selectedTreat, indCondInfoForNeedleA, indCondInfoForNeedleR);

    ordMainOnly.setIndCondInfoForNeedleA(indCondInfoForNeedleA);
    ordMainOnly.setIndCondInfoForNeedleR(indCondInfoForNeedleR);
    // 装置设置情报
    String indDeviceSetInfoForceUpdate = getIndDevSetInfo(selectedTreat.getDeviceMode(), treatMethodChangeHelper);
    // device_set_info
    ordMainOnly.setIndDeviceSetInfo(indDeviceSetInfoForceUpdate);
    // deviceMode
    ordMainOnly.setNewDeviceMode(treatMethodChangeHelper.getNewDeviceMode());
    ordMainOnly.setOldDeviceMode(treatMethodChangeHelper.getOldDeviceMode());

    if (!StringUtils.isEmpty(indCondInfoForceUpdate)) {
      ordMainOnly.setIndCondInfoForMerge(indCondInfoForceUpdate);
    }
    // 4、患者治療パターン DB 更新
    try {
      Optional.ofNullable(PatTreatmentPatternFactory.getPatTreatmentStategy(deviceMode))
          .ifPresent(strategy -> {
            strategy.update(ordMainOnly, facilityCd, treatmentCd);
          });
    } catch (Exception e) {
      String stackTraceStr = ExcetionStackTraceToString(e);
      eventLogMessage.setLogMessage("配布処理失敗　「facility_cd: " + facilityCd + ";ind_treatment_cd:" + treatmentCd + "」,error:" + stackTraceStr);
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      throw new BusinessException("配布処理失敗　「facility_cd: " + facilityCd + ";ind_treatment_cd:" + treatmentCd + "」");
    }
  }

  // add 9664 by kangjie 20231130 start 治療方法コード
  /**
   * 治療情報DBの更新
   * @param facilityCd
   * @param treatment
   * @param defaultSelDoctorNumber
   * @param userId
   * @param sb
   * @param success
   * @param error
   * @param eventLogMessage
   * @return List<OrdMain>
   */
  private InvokeResult<List<OrdMain>> updateOrdMainService(String facilityCd, Map treatment, int defaultSelDoctorNumber, Long userId, TreatMethodChangeHelper treatMethodChangeHelper,
      StringBuilder sb, ArrayList<Map> success, ArrayList<OrdMain> error, EventLogMessage eventLogMessage) {
    // 1、ord main の today 以上のデータを取得します。
    Integer treatmentCode = (Integer) treatment.get("code");
    List<OrdMain> ordMainList = ordMainDao.selectByFacilityCdTreatmentCd(facilityCd, treatmentCode, true);
    if (CollectionUtils.isEmpty(ordMainList)) {
      InvokeResult<List<OrdMain>> invokeResult = new InvokeResult<>();
      return invokeResult.fail("NO_DATA", "更新するデータがありません", null);
    }
    // 2、データ変更の実行
    try {
      // get update ordMain resource data
      ApiEntityOrdMain.ValiCreateTreatPlan bodyData = this.getUpdateOrdMainResource(treatment, defaultSelDoctorNumber, userId, facilityCd);
      ResponseEntity<String> responseEntity = null;
      // 1、deviceMode not modify, Only add keys to the treatment
      if (!treatMethodChangeHelper.isDeviceModelChanged()) {
        this.updateByTreatSetCInDeviceModeNotModifyModule(bodyData, ordMainList, treatMethodChangeHelper, eventLogMessage);
      } else {
        // deviceMode modify module
        this.updateByTreatSetCInDeviceModeModifiedModule(bodyData, ordMainList, treatMethodChangeHelper, eventLogMessage);
      }
      // 2、update ordMaterialSave
      List<Long> updateTargetOrdNoList = ordMainList.stream().map(OrdMain::getOrdNo).collect(Collectors.toList());
      updateOrdMaterialSaveToDel(updateTargetOrdNoList, treatmentCode);
      // 3、del ord_checklist
      //del 9324 ord_checklist共通之外的dao方法删除 gjn start
      //ordChecklistDao.delOrdCheckListByOrdNos(updateTargetOrdNoList);
      //del 9324 ord_checklist共通之外的dao方法删除 gjn end

      // 4、update pat_ind_approve
      updatePatIndApproveCheckStatus(updateTargetOrdNoList);
      // ログを残す record log
//    this.updateDataOrdMainRecordLog(responseEntity,ordMainList,treatment,sb,success,error,eventLogMessage);
    } catch (Exception e) {
      // record error log
      this.updateDataOrdMainErrorRecordLog(ordMainList, error, eventLogMessage);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessageNew.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    InvokeResult<List<OrdMain>> invokeResult = new InvokeResult<>();
    return invokeResult.success(ordMainList);
  }

  /**
   * update pat_ind_approve check status
   * @param updateTargetOrdNoList
   */
  private void updatePatIndApproveCheckStatus(List<Long> updateTargetOrdNoList) {
    List<PatIndApprove> patIndApproves = patIndApproveDao.selectBySettingNoAndOrdNoList(updateTargetOrdNoList, "1022", "1");
    if (CollectionUtils.isEmpty(patIndApproves)) return;
    List<Long> ordNos = patIndApproves.stream().map(PatIndApprove::getOrd_no).collect(Collectors.toList());
    patIndApproveDao.updateContentChangeSingleByOrdNoList(ordNos);
  }

  /**
   * record error log
   * @param ordMainList
   * @param error
   * @param eventLogMessage
   */
  private void updateDataOrdMainErrorRecordLog(List<OrdMain> ordMainList,
      ArrayList<OrdMain> error, EventLogMessage eventLogMessage) {
    for (OrdMain ordMain : ordMainList) {
      eventLogMessage.setLogMessage("配布処理失敗　「ord_no: " + ordMain.getOrdNo() + ", pat_id: " + ordMain.getPatId() + "」");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      error.add(ordMain);
    }
  }

  /**
   * ログを残す record log
   * @param responseEntity
   * @param ordMainList
   * @param treatment
   * @param sb
   * @param success
   * @param error
   * @param eventLogMessage
   */
  private void updateDataOrdMainRecordLog(ResponseEntity<String> responseEntity, List<OrdMain> ordMainList, Map treatment, StringBuilder sb, ArrayList<Map> success,
      ArrayList<OrdMain> error, EventLogMessage eventLogMessage) {
    if (responseEntity.getStatusCode() == HttpStatus.OK) {
      Map<String, Long> ordMainTemp = new HashMap<>();
      for (OrdMain ordMain : ordMainList) {
        sb.setLength(0);
        sb.append("配布処理成功 「ord_no : " + ordMain.getOrdNo());
        sb.append(", pat_id」 : " + ordMain.getPatId());
        sb.append("は 「" + treatment.get("treatmentConditionSetting"));
        sb.append("」 のように更新しました");

        eventLogMessage.setLogMessage(sb.toString());
        logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
        ordMainTemp.put("ordNo", ordMain.getOrdNo());
        ordMainTemp.put("patId", ordMain.getPatId());
        success.add(ordMainTemp);
      }
    } else {
      for (OrdMain ordMain : ordMainList) {
        eventLogMessage.setLogMessage("配布処理失敗 「ord_no: " + ordMain.getOrdNo() + ", pat_id: " + ordMain.getPatId() + "」");
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
        error.add(ordMain);
      }
    }
  }

  /**
   * get update ordMain resource data
   * @param treatment
   * @param defaultSelDoctorNumber
   * @param userId
   * @param facilityCd
   * @return
   */
  private ApiEntityOrdMain.ValiCreateTreatPlan getUpdateOrdMainResource(Map treatment, int defaultSelDoctorNumber, Long userId, String facilityCd) {

    // 治療方法 code
    Integer indTreatmentCdArr = (Integer) treatment.get("code");

    ApiEntityOrdMain.ValiCreateTreatPlan bodyData = new ApiEntityOrdMain.ValiCreateTreatPlan();

    // 治療方法名
    bodyData.setTreatment_name((String) treatment.get("name"));
    // 治療方法コード
    bodyData.setTreatment_set_cd(String.valueOf(treatment.get("code")));
    // 更新日時
    String upDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date());
    bodyData.setUp_date(upDate);
    // 開始日
    String startDateStr = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
    bodyData.setStart_date(startDateStr);
    // 施設コード
    bodyData.setFacility_cd(facilityCd);
    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
    // 変更対象治療方法
    // bodyData.setTarget_treatment_cd(String.valueOf(indTreatmentCdArr));
    bodyData.setInd_treatment_cd(String.valueOf(indTreatmentCdArr));
    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
    // 指示者コード
    bodyData.setInd_user_id(BigInteger.valueOf(defaultSelDoctorNumber));
    // 更新者コード
    bodyData.setUpd_user_id(BigInteger.valueOf(userId));
    // 治療方法変更フラグ
    bodyData.setTreat_method_flag(String.valueOf(0));
    // 終了日格納有無
    bodyData.setIs_deadline(String.valueOf(true));
    // add 7760 【デグレ】治療方法マスタを編集すると全透析装置へ次患者情報が再送される zhao start
    if (treatment.get("nextFlag") != null) {
      bodyData.setNextFlag(treatment.get("nextFlag").toString());
    }
    return bodyData;
  }

  /**
   * deviceMode not modify module
   * @param bodyData
   * @param updateTargetOrdMainList
   * @param treatMethodChangeHelper
   * @param eventLogMessage
   * @return
   */
  private void updateByTreatSetCInDeviceModeNotModifyModule(ApiEntityOrdMain.ValiCreateTreatPlan bodyData, List<OrdMain> updateTargetOrdMainList, TreatMethodChangeHelper treatMethodChangeHelper, EventLogMessage eventLogMessage) {
    // 1、get modify data
    MstTreatment selectedTreat = mstTreatmentDao.selectByCd(Integer.parseInt(bodyData.getTreatment_set_cd()));
    // 2、get add key json in ind_cond_info
    JSONObject isUsedKeyJsonInfo = getIsUsedKeyJsonInTreatmentIndCond(selectedTreat, bodyData.getInd_user_id(), bodyData.getUpd_user_id());
    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
    List<Long> updateTargetOrdNoList = updateTargetOrdMainList.stream().map(OrdMain::getOrdNo).distinct().collect(Collectors.toList());
    OrdMainOnly ordMainOnly = new OrdMainOnly();
    // 施设cd
    ordMainOnly.setFacilityCd(bodyData.getFacility_cd());

    // 治療条件 force update key
    String indCondInfoForceUpdate = getIndCondInfoForceUpdateData(selectedTreat, treatMethodChangeHelper);
    //  情報
    ordMainOnly.setIndCondInfo(isUsedKeyJsonInfo.toString());
    ordMainOnly.setIndCondInfoForMerge(indCondInfoForceUpdate);

    // 治疗条件删除key=11
    // sn针处理
    List<String> indCondInfoForNeedleA = new ArrayList<>();
    List<String> indCondInfoForNeedleR = new ArrayList<>();
    getIndCondInfoForNeedleeUpdateData(selectedTreat, indCondInfoForNeedleA, indCondInfoForNeedleR);

    ordMainOnly.setIndCondInfoForNeedleA(indCondInfoForNeedleA);
    ordMainOnly.setIndCondInfoForNeedleR(indCondInfoForNeedleR);

    // deviceMode
    ordMainOnly.setNewDeviceMode(treatMethodChangeHelper.getNewDeviceMode());
    ordMainOnly.setOldDeviceMode(treatMethodChangeHelper.getOldDeviceMode());

    // 追加OrdMain履歴
    selectHistoryUtils.insertMangoDbHistory(3, null, null, updateTargetOrdNoList, new ArrayList<>(), null, null,
        null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
        new ArrayList<>(), null, null);
    // 4、update ordMain
    try {
      Optional.ofNullable(
          OrdMainTreatmentFactory
              .getStrategy(selectedTreat.getDeviceMode())).ifPresent(strategy -> {
        strategy.update(
            Integer.parseInt(bodyData.getTreatment_set_cd()),
            ordMainOnly,
            updateTargetOrdNoList,
            bodyData.getInd_user_id(),
            Long.valueOf(String.valueOf(bodyData.getUpd_user_id())));
      });
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessageNew.setFacilityCd(bodyData.getFacility_cd());
      }
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    // 指示履歴登録処理(患者ごとに)
    createIndHistoryForPatients(bodyData, updateTargetOrdMainList, selectedTreat, treatMethodChangeHelper, eventLogMessage);
  }

  /**
   * delete ord_material_save data
   *
   * @param ordNoList
   * @param treatmentCode
   */
  private void updateOrdMaterialSaveToDel(List<Long> ordNoList, Integer treatmentCode) {
    // 1、get modify data
    MstTreatment selectedTreat = mstTreatmentDao.selectByCd(treatmentCode);
    // 2、get add key json in ind_cond_info
    List<String> suppliesClassList = getDelMaterialSaveParam(selectedTreat);
    // 4、del ord_material_save extra keys
    if (CollectionUtils.isNotEmpty(suppliesClassList)) {
      ordMaterialSaveDao.deleteOrdMaterialSaveByOrdMaterialSaveNo(ordNoList, suppliesClassList);
    }
  }

  private List<String> getDelMaterialSaveParam(MstTreatment selectedTreat) {
    List<String> suppliesClassList = new ArrayList<>();
    JSONArray treatCondSetting = null == selectedTreat.getTreatmentConditionSetting() ? new JSONArray()
        : new JSONArray(selectedTreat.getTreatmentConditionSetting());
    for (Integer i = 1; i <= 38; i++) {
      String key = i.toString();
      Boolean isUse = checkTreatCondIsUse(treatCondSetting, key);
      String suppliesClassByCode = TreatmentKeyAndMaterialSaveSuppliesClassRel.getSuppliesClassByCode(i);
      if (!isUse && Optional.ofNullable(suppliesClassByCode).isPresent()) {
        //删除的key
        suppliesClassList.add(suppliesClassByCode);
      }
    }
    return suppliesClassList;
  }

  enum TreatmentKeyAndMaterialSaveSuppliesClassRel {
    TREATMENT_ITEM_13(13, "00", "血液回路"),
    TREATMENT_ITEM_5(5, "01", "ダイアライザ"),
    TREATMENT_ITEM_6(6, "02", "吸着カラム"),
    TREATMENT_ITEM_7(7, "03", "1次膜"),
    TREATMENT_ITEM_8(8, "04", "2次膜"),
    TREATMENT_ITEM_12(12, "05", "シングルニードル"),
    TREATMENT_ITEM_9(9, "06", "穿刺針(A)"),
    TREATMENT_ITEM_10(10, "07", "穿刺針(V)"),
    TREATMENT_ITEM_15(15, "08", "透析液"),
    TREATMENT_ITEM_19(19, "09", "補液"),
    TREATMENT_ITEM_25(25, "10", "抗凝固剤");
    private int treatmentKey;
    private String suppliesClass;
    private String treatmentName;

    public static TreatmentKeyAndMaterialSaveSuppliesClassRel getTreatmentRelByCode(int key) {
      return Arrays.asList(TreatmentKeyAndMaterialSaveSuppliesClassRel.values())
        .stream().filter(item->
          item.treatmentKey == key
          ).findFirst().orElse(null);
    }

    public static String getSuppliesClassByCode(int key) {
      TreatmentKeyAndMaterialSaveSuppliesClassRel treatmentRelByCode = getTreatmentRelByCode(key);
      if (Optional.ofNullable(treatmentRelByCode).isPresent()) {
        return treatmentRelByCode.suppliesClass;
      }
      return null;
    }

    public int getTreatmentKey() {
      return treatmentKey;
    }

    public String getSuppliesClass() {
      return suppliesClass;
    }

    public String getTreatmentName() {
      return treatmentName;
    }

    TreatmentKeyAndMaterialSaveSuppliesClassRel(int treatmentKey, String suppliesClass, String treatmentName) {
      this.treatmentKey = treatmentKey;
      this.suppliesClass = suppliesClass;
      this.treatmentName = treatmentName;
    }
  }

  /**
   *
   * @param teat
   * @param indUserId 指示者ID
   * @param updUserId 更新者ID
   * @return
   */
  private JSONObject getIsUsedKeyJsonInTreatmentIndCond(MstTreatment teat, BigInteger indUserId, BigInteger updUserId) {
    JSONObject jsonObject = new JSONObject();
    JSONArray treatCondSetting = null == teat.getTreatmentConditionSetting() ? new JSONArray()
        : new JSONArray(teat.getTreatmentConditionSetting());
    for (Integer i = 1; i <= 38; i++) {
      String key = i.toString();
      Boolean isUse = checkTreatCondIsUse(treatCondSetting, key);
      if (isUse) {
        JSONObject bufJson = new JSONObject();
        // 設定値
        bufJson.put("value",
            TreatmentItemsDef.getDefaultValue(i + "") == null ? JSONObject.NULL : TreatmentItemsDef.getDefaultValue(i + ""));
        // 翻訳1
        bufJson.put("value_name_1", JSONObject.NULL);
        // 単位
        bufJson.put("unit", JSONObject.NULL);
        // 薬剤区分
        bufJson.put("medicine_type", JSONObject.NULL);
        // 指示者コード
        MstPersonalUser user = MasterCacheHandler.get().getMstPersonalUser(indUserId.longValue());
        bufJson.put("ind_user_id", indUserId);
        // 指示者名_姓
        bufJson.put("ind_user_last_name", user.getUserLastName());
        // 指示者名_名
        bufJson.put("ind_user_first_name", user.getUserFirstName());
        // 更新者コード
        MstPersonalUser updPerson = MasterCacheHandler.get().getMstPersonalUser(updUserId.longValue());
        bufJson.put("upd_user_id", Long.parseLong(String.valueOf(updUserId)));
        // 更新者名_姓
        bufJson.put("upd_user_last_name", updPerson.getUserLastName());
        // 更新者名_名
        bufJson.put("upd_user_first_name", updPerson.getUserFirstName());
        // 登録区分
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //bufJson.put("input_class", "1");
        bufJson.put("input_class", 1);
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 編集可否フラグ
        bufJson.put("is_editable", "1");
        // 連携オーダ番号
        bufJson.put("cop_order_no", JSONObject.NULL);

        jsonObject.put(key, bufJson);
      }
    }
    return jsonObject;
  }

  /**
   * deviceMode modify module
   * @param bodyData
   * @param updateTargetOrdMainList
   * @param treatMethodChangeHelper
   * @param eventLogMessage
   * @return
   * @throws JSONException
   */
  private void updateByTreatSetCInDeviceModeModifiedModule(ApiEntityOrdMain.ValiCreateTreatPlan bodyData, List<OrdMain> updateTargetOrdMainList, TreatMethodChangeHelper treatMethodChangeHelper, EventLogMessage eventLogMessage)
      throws Exception {
    // 更新対象オーダー番号リストの取得
    List<Long> ordNoList = updateTargetOrdMainList.stream().map(OrdMain::getOrdNo).distinct().collect(Collectors.toList());
    ordNoList = null == ordNoList ? new ArrayList<>() : ordNoList;

    // Get Treatment:治療の条件設定
    MstTreatment selectedTreat = mstTreatmentDao.selectByCd(Integer.parseInt(bodyData.getTreatment_set_cd()));
    // ordMain  ind_cond_info &rst_cond_info-> 削除キー:未使用isUsed=0、追加キー:使用済みisUsed=1
    JSONObject isUsedKeyJsonInfo = getIsUsedKeyJsonInTreatmentIndCond(selectedTreat, bodyData.getInd_user_id(), bodyData.getUpd_user_id());

    OrdMainOnly ordMainOnly = new OrdMainOnly();

    // 施设cd
    ordMainOnly.setFacilityCd(bodyData.getFacility_cd());

    //  治療条件情報
    String indCondInfoForceUpdate = getIndCondInfoForceUpdateData(selectedTreat, treatMethodChangeHelper);
    // ind_cond_info
    ordMainOnly.setIndCondInfo(isUsedKeyJsonInfo.toString());
    ordMainOnly.setIndCondInfoForMerge(indCondInfoForceUpdate);

    // 治疗条件删除
    List<String> indCondInfoForNeedleA = new ArrayList<>();
    List<String> indCondInfoForNeedleR = new ArrayList<>();
    // sn针处理
    getIndCondInfoForNeedleeUpdateData(selectedTreat, indCondInfoForNeedleA, indCondInfoForNeedleR);

    ordMainOnly.setIndCondInfoForNeedleA(indCondInfoForNeedleA);
    ordMainOnly.setIndCondInfoForNeedleR(indCondInfoForNeedleR);

    //  装置設定情報
    String indDeviceSetInfoForceUpdate = getIndDevSetInfo(selectedTreat.getDeviceMode(), treatMethodChangeHelper);
    // device_set_info
    ordMainOnly.setIndDeviceSetInfo(indDeviceSetInfoForceUpdate);
    // deviceMode
    ordMainOnly.setNewDeviceMode(treatMethodChangeHelper.getNewDeviceMode());
    ordMainOnly.setOldDeviceMode(treatMethodChangeHelper.getOldDeviceMode());

    // 追加OrdMain履歴
    selectHistoryUtils.insertMangoDbHistory(3, null, null, ordNoList, new ArrayList<>(), null, null,
        null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
        new ArrayList<>(), null, null);
    // update ordMain
    try {
      List<Long> finalOrdNoList = ordNoList;
      Optional.ofNullable(OrdMainTreatmentFactory.getStrategy(selectedTreat.getDeviceMode()))
          .ifPresent(strategy -> {
            strategy.update(
                Integer.parseInt(bodyData.getTreatment_set_cd()),
                ordMainOnly,
                finalOrdNoList,
                bodyData.getInd_user_id(),
                Long.valueOf(String.valueOf(bodyData.getUpd_user_id()))
            );
          });
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      if (bodyData != null && bodyData.getFacility_cd() != null) {
        eventLogMessageNew.setFacilityCd(bodyData.getFacility_cd());
      }
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    // 指示履歴登録処理(患者ごとに)
    createIndHistoryForPatients(bodyData, updateTargetOrdMainList, selectedTreat, treatMethodChangeHelper, eventLogMessage);
  }

  /**
   * 指示履歴登録処理（患者ごとに）
   * 共通メソッド：治療方法マスタ変更時の指示履歴とジャーナル作成を行う
   *
   * @param bodyData 治療方法変更データ
   * @param updateTargetOrdMainList 更新対象のOrdMainリスト
   * @param selectedTreat 選択された治療方法マスタ
   * @param treatMethodChangeHelper 治療方法変更ヘルパー
   * @param eventLogMessage イベントログメッセージ
   */
  private void createIndHistoryForPatients(ApiEntityOrdMain.ValiCreateTreatPlan bodyData,
                       List<OrdMain> updateTargetOrdMainList,
                       MstTreatment selectedTreat,
                       TreatMethodChangeHelper treatMethodChangeHelper,
                       EventLogMessage eventLogMessage) {
    // 指示履歴登録処理(患者ごとに)
    List<Long> patIdList = updateTargetOrdMainList.stream()
        .map(ordMain -> ordMain.getPatId())
        .distinct()
        .collect(Collectors.toList());

    // 患者単位でMongoDB登録とjournal登録を実行
    for (Long patId : patIdList) {
      try {
        String today = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date());
        IndHistory indHistory = new IndHistory();
        indHistory.setLogDate(today);
        indHistory.setFacilityCd(bodyData.getFacility_cd());
        indHistory.setPatId(String.valueOf(patId));

        // 現在のユーザー情報を取得
        try {
          indHistory.setCreatedUserId(Long.valueOf(bodyData.getInd_user_id().toString()));
        } catch (Exception userEx) {
          // ユーザー情報が取得できない場合はデフォルト値を設定
          indHistory.setCreatedUserId(Long.parseLong("-1"));
        }

        // 患者ごとのTreatMethodChangeHelperを作成
        TreatMethodChangeHelper patientSpecificHelper = new TreatMethodChangeHelper();

        // 新規・変更のリストをコピー（深いコピー）
        for (TreatMethodChangeHelper.ItemAndValue itemAndValue : treatMethodChangeHelper.getToAddCtlNoList()) {
          patientSpecificHelper.addChangeForAdd(itemAndValue.getItem(), itemAndValue.getValue());
        }
        for (TreatMethodChangeHelper.ItemAndValue itemAndValue : treatMethodChangeHelper.getToUpdCtlNoList()) {
          patientSpecificHelper.addChangeForUpd(itemAndValue.getItem(), itemAndValue.getValue());
        }

        // 中止のリストは患者ごとに元の値を取得して設定
        if (treatMethodChangeHelper.hasChangeToDel()) {
          // この患者のord_mainデータを取得
          Optional<OrdMain> patientOrdMain = updateTargetOrdMainList.stream()
              .filter(om -> om.getPatId().equals(patId))
              .findFirst();

          if (patientOrdMain.isPresent() && patientOrdMain.get().getIndCondInfo() != null) {
            JSONObject indCondInfo = new JSONObject(patientOrdMain.get().getIndCondInfo());

            // 中止される各項目の元の値を取得してhelperに設定
            for (TreatMethodChangeHelper.ItemAndValue itemAndValue : treatMethodChangeHelper.getToDelCtlNoList()) {
              String itemNumber = itemAndValue.getItem();
              String oldValue = null;

              // ind_cond_infoから元の値を取得
              if (indCondInfo.has(itemNumber)) {
                JSONObject itemData = indCondInfo.getJSONObject(itemNumber);
                if (itemData.has("value") && !itemData.isNull("value")) {
                  oldValue = itemData.getString("value");
                  // gettingValue メソッドを使って表示用の値に変換
                  oldValue = indHistoryMakeService.gettingValue(itemNumber, itemData, bodyData.getFacility_cd());
                }
              }

              // 元の値付きで追加
              patientSpecificHelper.addChangeForDel(itemNumber, oldValue);
            }
          } else {
            // ord_mainデータがない、またはind_cond_infoがnullの場合は、元の値なしで追加
            for (TreatMethodChangeHelper.ItemAndValue itemAndValue : treatMethodChangeHelper.getToDelCtlNoList()) {
              patientSpecificHelper.addChangeForDel(itemAndValue.getItem(), null);
            }
          }
        }

        // deviceModeの変更情報もコピー
        patientSpecificHelper.setOldDeviceMode(treatMethodChangeHelper.getOldDeviceMode());
        patientSpecificHelper.setNewDeviceMode(treatMethodChangeHelper.getNewDeviceMode());
        // deviceSetChangeContentListをコピー（深いコピー）
        for (String changeContent : treatMethodChangeHelper.getDeviceSetChangeContentList()) {
          patientSpecificHelper.getDeviceSetChangeContentList().add(changeContent);
        }

        // 1. MongoDB登録
        indHistoryMakeService.createMstTreatmentModifyHistory(
            bodyData.getFacility_cd(),
            String.valueOf(patId),
            selectedTreat.getTreatmentName(),
            Long.valueOf(bodyData.getInd_user_id().toString()),
            Long.valueOf(bodyData.getUpd_user_id().toString()),
            patientSpecificHelper,
            today
        );

        // 2. MongoDB登録完了後、journal登録を実行
        indHistoryMakeService.callCreateJournal(indHistory);
      } catch (Exception e) {
        String stackTraceStr = ExcetionStackTraceToString(e);
        eventLogMessage.setLogMessage("指示履歴・journal登録処理失敗　「facility_cd: " + bodyData.getFacility_cd() + ";pat_id:" + patId + "」,error:" + stackTraceStr);
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        if (bodyData != null && bodyData.getFacility_cd() != null) {
          eventLogMessageNew.setFacilityCd(bodyData.getFacility_cd());
        }
        eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    }
  }

  private String getIndCondInfoForceUpdateData(MstTreatment selectedTreat, TreatMethodChangeHelper treatMethodChangeHelper) {

    Integer deviceMode = selectedTreat.getDeviceMode();
    if (AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(deviceMode) ||
      AdminWebConstant.Treatment.DeviceMode.AFBF.equals(deviceMode)) {
      JSONObject indCondInfoJSON = new JSONObject();
      JSONObject json_12 = new JSONObject();
      json_12.put("value", TreatmentItemsDef.getDefaultValue(IND_COND_INFO_12));
      indCondInfoJSON.put(IND_COND_INFO_12, json_12);

      treatMethodChangeHelper.addChangeForUpd(IND_COND_INFO_12, "0");
      return indCondInfoJSON.toString();
    }
    return null;
  }

  private void getIndCondInfoForNeedleeUpdateData(MstTreatment selectedTreat, List<String> indCondInfoForNeedleA, List<String> indCondInfoForNeedleR) {
    Integer deviceMode = selectedTreat.getDeviceMode();
    if (AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(deviceMode) ||
      AdminWebConstant.Treatment.DeviceMode.AFBF.equals(deviceMode)) {
      indCondInfoForNeedleA.add("9");
      indCondInfoForNeedleA.add("10");
      indCondInfoForNeedleA.add("12");

      indCondInfoForNeedleR.add("11");
    } else {
      indCondInfoForNeedleA.add("9");
      indCondInfoForNeedleA.add("10");
      indCondInfoForNeedleA.add("11");
      indCondInfoForNeedleA.add("12");

      indCondInfoForNeedleR.add("9");
      indCondInfoForNeedleR.add("10");
      indCondInfoForNeedleR.add("11");
      indCondInfoForNeedleR.add("12");
    }
  }

  private String getIndDevSetInfo(Integer targetDeviceMode, TreatMethodChangeHelper treatMethodChangeHelper) {
    JSONObject jsonIndDeviceSetInfo = new JSONObject();

    // 除水プログラム、HD/ECUMのECUMがある場合は切替をHDに強制変更。
    if (AdminWebConstant.Treatment.DeviceMode.HDF.equals(targetDeviceMode) ||
      AdminWebConstant.Treatment.DeviceMode.HF.equals(targetDeviceMode) ||
      AdminWebConstant.Treatment.DeviceMode.OHDF.equals(targetDeviceMode) ||
      AdminWebConstant.Treatment.DeviceMode.OHF.equals(targetDeviceMode) ||
      AdminWebConstant.Treatment.DeviceMode.AFBF.equals(targetDeviceMode)) {
      for (int i = 291; i <= 300; i++) {
        JSONObject usr = new JSONObject();
        usr.put(String.valueOf(i), "0");
        if (i == 300) {
          JSONObject usrA = new JSONObject();
          usrA.put("A", usr);
          JSONObject usrDev = new JSONObject();
          usrDev.put("dev", usrA);
          jsonIndDeviceSetInfo.put("ufr", usrDev);
        }
      }
      treatMethodChangeHelper.addDeviceSetChangeContent("除水プログラム", "治療モード１", "0");
      treatMethodChangeHelper.addDeviceSetChangeContent("除水プログラム", "治療モード2", "0");
      treatMethodChangeHelper.addDeviceSetChangeContent("除水プログラム", "治療モード3", "0");
      treatMethodChangeHelper.addDeviceSetChangeContent("除水プログラム", "治療モード4", "0");
      treatMethodChangeHelper.addDeviceSetChangeContent("除水プログラム", "治療モード5", "0");
      treatMethodChangeHelper.addDeviceSetChangeContent("除水プログラム", "治療モード6", "0");
      treatMethodChangeHelper.addDeviceSetChangeContent("除水プログラム", "治療モード7", "0");
      treatMethodChangeHelper.addDeviceSetChangeContent("除水プログラム", "治療モード8", "0");
      treatMethodChangeHelper.addDeviceSetChangeContent("除水プログラム", "治療モード9", "0");
      treatMethodChangeHelper.addDeviceSetChangeContent("除水プログラム", "治療モード10", "0");
    }

    // 除水プログラム、ONの場合は強制的にOFFに変更する。
    if (AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(targetDeviceMode)) {
      JSONObject usr = new JSONObject();
      usr.put("290", "0");
      JSONObject usrA = new JSONObject();
      usrA.put("A", usr);
      JSONObject usrDev = new JSONObject();
      usrDev.put("dev", usrA);
      jsonIndDeviceSetInfo.put("ufr", usrDev);
      treatMethodChangeHelper.addDeviceSetChangeContent("除水プログラム", "除水プログラム電源ＳＷ", "0");
    }

    // Na注入プログラム、ONの場合は強制的にOFFに変更する。
    if (AdminWebConstant.Treatment.DeviceMode.PURIFICATION.equals(targetDeviceMode)) {
      JSONObject na = new JSONObject();
      na.put("315", "0");
      JSONObject devA = new JSONObject();
      devA.put("A", na);
      JSONObject naDev = new JSONObject();
      naDev.put("dev", devA);
      jsonIndDeviceSetInfo.put("na", naDev);
      treatMethodChangeHelper.addDeviceSetChangeContent("Ｎａ注入プログラム", "Ｎａ注入プログラム電源ＳＷ", "0");
    }

    // 透析液濃度プログラム、ONの場合は強制的にOFFに変更する。
    if (AdminWebConstant.Treatment.DeviceMode.AFBF.equals(targetDeviceMode)) {
      JSONObject dc = new JSONObject();
      dc.put("340", "0");
      JSONObject dcA = new JSONObject();
      dcA.put("A", dc);
      JSONObject dcDev = new JSONObject();
      dcDev.put("dev", dcA);
      jsonIndDeviceSetInfo.put("dc", dcDev);
      treatMethodChangeHelper.addDeviceSetChangeContent("透析液濃度プログラム", "濃度プログラム電源ＳＷ", "0");
    }

    if (AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(targetDeviceMode)) {
      // 血流量・透析液流量プログラム、ONの場合は強制的にOFFに変更する。
      JSONObject qbqd = new JSONObject();
      qbqd.put("431", "0");
      qbqd.put("430", "0");
      JSONObject qbqdA = new JSONObject();
      qbqdA.put("A", qbqd);
      JSONObject qbqdDev = new JSONObject();
      qbqdDev.put("dev", qbqdA);
      jsonIndDeviceSetInfo.put("qbqd", qbqdDev);
      treatMethodChangeHelper.addDeviceSetChangeContent("血流量・透析液流量プログラム", "QBプログラム電源", "0");

      // BV-UFC、ONの場合は強制的にOFFに変更する。
      JSONObject bvufc = new JSONObject();
      bvufc.put("196", "0");
      JSONObject bvufcA = new JSONObject();
      bvufcA.put("A", bvufc);
      JSONObject bvufcDev = new JSONObject();
      bvufcDev.put("dev", bvufcA);
      jsonIndDeviceSetInfo.put("bvufc", bvufcDev);
      treatMethodChangeHelper.addDeviceSetChangeContent("BV-UFC", "BV-UFC使用選択", "0");
    }

    // 透析量プログラム  ONの場合は強制的にOFFに変更する。
    if (AdminWebConstant.Treatment.DeviceMode.HDF.equals(targetDeviceMode) || AdminWebConstant.Treatment.DeviceMode.HF.equals(targetDeviceMode)
        || AdminWebConstant.Treatment.DeviceMode.OHDF.equals(targetDeviceMode) || AdminWebConstant.Treatment.DeviceMode.OHF.equals(targetDeviceMode)
        || AdminWebConstant.Treatment.DeviceMode.AFBF.equals(targetDeviceMode) || AdminWebConstant.Treatment.DeviceMode.I_HDF.equals(targetDeviceMode)) {
      JSONObject dia = new JSONObject();
      dia.put("282", "0");
      JSONObject diaA = new JSONObject();
      diaA.put("A", dia);
      JSONObject diaDev = new JSONObject();
      diaDev.put("dev", diaA);
      jsonIndDeviceSetInfo.put("dia", diaDev);
      treatMethodChangeHelper.addDeviceSetChangeContent("透析量プログラム", "透析量プログラム使用選択", "0");
    }

    return jsonIndDeviceSetInfo.toString();
  }
  // add 9664 by kangjie 20231130 end 治療方法コード
  // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end

  //add #9973 by ztc 20231027 mst_treatment変更後にmst _treatment_set start
  public String getDisUseCtlNoFrTreatCondSetting(String treatCondSetting) {
    if (("").equals(treatCondSetting) || ("null").equals(treatCondSetting)) {
      return "{}";
    }
    StringBuilder disUseCtlNoRst = new StringBuilder("{");
    JSONArray tcsJsonArray = new JSONArray(treatCondSetting);
    boolean firstFlag = true;
    for (int i = 0; i < tcsJsonArray.length(); i++) {
      JSONObject category = tcsJsonArray.getJSONObject(i);
      JSONArray tcsItems = category.getJSONArray("items");
      for (int j = 0; j < tcsItems.length(); j++) {
        JSONObject tcsItem = tcsItems.getJSONObject(j);
        String isUse = tcsItem.getString("is_use");
        String ctlNo = tcsItem.getString("ctl_no");
        if (DISUSE_VALUE.equals(isUse) && !EXCLUDED_CTL_NO.equals(ctlNo)) {
          if (!firstFlag) {
            disUseCtlNoRst.append(",");
          } else {
            firstFlag = false;
          }
          disUseCtlNoRst.append(ctlNo);
        }
      }
    }
    disUseCtlNoRst.append("}");
    return disUseCtlNoRst.toString();
  }
  //add #9973 by ztc 20231027 mst_treatment変更後にmst _treatment_set start

  /**
   * 治療方法マスタの中の装置モードの項目を変更した場合,外部連携イベントを送信する
   * @param facilityCd 施設コード
   * @param treatment 治療方法data
   * @param ordMainList 治療情報List
   * @param userId ユーザID
   * NO-7325 cuifc
   * */
  // mod bug 8099 修正 chen start
  private List<JournalCreateRequestPayload> sendCreateJournalApi(String facilityCd, Map treatment, List<OrdMain> ordMainList, Long userId) {
    List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
    if (ordMainList == null || ordMainList.size() == 0) {
      return ctlNoList;
    }
    // mod bug 8099 修正 chen end
    //upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --start /
    if (treatment.containsKey("isSendJournalApiFlag") && ("1").equals(treatment.get("isSendJournalApiFlag").toString())) {
      //upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --end /
      // add FNSI-7325 劉全航 start
      ordMainList = ordMainList.stream().filter(o -> o.getIndKurCd() != 0).collect(Collectors.toList());
      // add FNSI-7325 劉全航 end

      // mod #10553 ⑫治療方法マスタの治療条件設定変更にう指示変更にて連携イベントを発生させること。 piao start
      List<Long> patIdList = new ArrayList<>();
      patIdList.addAll(ordMainList.stream().map(o -> o.getPatId()).collect(Collectors.toList()));
      List<PatPersonalMain> patPersonalMainList = patPersonalMainDao.selectPatPersonalMainForHospPatIdListByPatIdList(facilityCd, patIdList);
      Map<Long, String> patPersonalMainListMap = patPersonalMainList.stream().collect(Collectors.toMap(PatPersonalMain::getPat_id, PatPersonalMain::getHosp_pat_id));

      // del #11004 連携イベント発生部分不正 piao start
      // int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(facilityCd);
      // del #11004 連携イベント発生部分不正 piao end
      // mod 2023-01-29 bug #8099 修正 chen start
      String opeCd = "900006";
      for (OrdMain ordMain : ordMainList) {
        String hospPatId = patPersonalMainListMap.get(ordMain.getPatId());
        // del #11004 連携イベント発生部分不正 piao start
        // if (modify_send_class == 2) {
        //   JournalCreateRequestPayload deljournalCreateRequestPayload = new JournalCreateRequestPayload();
        //   deljournalCreateRequestPayload.setFacilityCd(facilityCd);
        //   deljournalCreateRequestPayload.setCrud("D");
        //   deljournalCreateRequestPayload.setHospPatId(hospPatId);
        //   deljournalCreateRequestPayload.setPatId(ordMain.getPatId());
        //   deljournalCreateRequestPayload.setUserId(userId);
        //   deljournalCreateRequestPayload.setOpeCd(opeCd);
        //   deljournalCreateRequestPayload.setOrdNo(ordMain.getOrdNo());
        //   deljournalCreateRequestPayload.setBaseDate(ordMain.getTreatDate());
        //   ctlNoList.add(deljournalCreateRequestPayload);
        // }
        // del #11004 連携イベント発生部分不正 piao end
        JournalCreateRequestPayload JCRequestPayload = new JournalCreateRequestPayload();
        JCRequestPayload.setOpeCd(opeCd);
        JCRequestPayload.setCrud("U");
        // del #11004 連携イベント発生部分不正 piao start
        // if (modify_send_class == 2) {
        //   JCRequestPayload.setCrud("C");
        // }
        // del #11004 連携イベント発生部分不正 piao end
        JCRequestPayload.setFacilityCd(facilityCd);
        JCRequestPayload.setPatId(ordMain.getPatId());
        JCRequestPayload.setHospPatId(hospPatId);
        JCRequestPayload.setOrdNo(ordMain.getOrdNo());
        JCRequestPayload.setBaseDate(ordMain.getTreatDate());
        JCRequestPayload.setUserId(userId);
        // try {
        //   ResponseEntity<?> responseEntity = patInfoResource.create(JCRequestPayload, null);
        //
        //   EventLogMessage eventLogMessage = new EventLogMessage();
        //   eventLogMessage.setFacilityCd(facilityCd);
        //   eventLogMessage.setLogMessage("外部連携イベントを送信-StatusCode:" + responseEntity.getStatusCode());
        //   logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
        // } catch (Exception e) {
        //   e.printStackTrace();
        // }
        ctlNoList.add(JCRequestPayload);
      }
      // mod #10553 ⑫治療方法マスタの治療条件設定変更にう指示変更にて連携イベントを発生させること。 piao end
      // mod bug 8099 修正 chen start
      // journalService.callCreateJournalForCtrNo(ctlNoList);
      // mod 2023-01-29 bug #8099 修正 chen end
    }
    // Add 治療方法マスタで治療方法を変更してもイベント作成されない xmj #7325 2022-8-23 start
//  else if (1 != isSendJournalApiFlag) {
//    for (OrdMain ordMain: ordMainList) {
//    JournalCreateRequestPayload journalCreateRequestPayload = new JournalCreateRequestPayload();
//    journalCreateRequestPayload.setFacilityCd(facilityCd);
//    journalCreateRequestPayload.setCrud("U");
//    journalCreateRequestPayload.setPatId(ordMain.getPatId());
//    journalCreateRequestPayload.setOrdNo(ordMain.getOrdNo());
//    journalCreateRequestPayload.setUserId(Long.valueOf(userId));
//    journalCreateRequestPayload.setOpeCd("004003");
//    asyncService.sendExternalConnection(ordMainList, journalCreateRequestPayload);
//    }
//  }
    // Add 治療方法マスタで治療方法を変更してもイベント作成されない xmj #7325 2022-8-23 end
    return ctlNoList;
    // mod bug 8099 修正 chen end
  }
  // add #7327 治療方法マスタ操作時の動作がおかしい 王永吉 start

  private void treatmentChangeToMongo(List<Map<String, Object>> treatmentList, String facilityCd, Long userId) {

    for (Map treatment : treatmentList) {
      /*mod #8495 by zhangruixue 2023-03-27  GC overhead limit exceeded start*/
 /*get ordNo */
      List<Long> ordNoList = ordMainDao.selectOrdNoByTreatmentCd(facilityCd, (Integer) treatment.get("code"), true);
      // add 9664 by kangjie 20231212 start
      Integer defaultSelDoctorNumber = Integer.valueOf(treatment.get("selectedDoctorNo").toString());
      // add 9664 by kangjie 20231212 end

      if (ordNoList.size() > 0) {
        List<List<Long>> splitList = this.splitList(ordNoList, 1000);
        if (splitList.size() > 0) {
          for (List<Long> paramList : splitList) {
            List<OrdMain> ordMainList = ordMainDao.selectByTreatmentCd(facilityCd, (Integer) treatment.get("code"), true, paramList);
            /*mod #8495 by zhangruixue 2023-03-27  GC overhead limit exceeded  end*/
            if (ordMainList.size() > 0) {

              for (OrdMain ordMain : ordMainList) {
                try {
                  if ("1".equals(ordMain.getIsDel())){ continue; }

                  String tempWeek = "[\n" +
                    "                {\"text\": \"全\", \"done\": false, \"value\": 0},\n" +
                    "                {\"text\": \"月\", \"done\": false, \"value\": 1},\n" +
                    "                {\"text\": \"火\", \"done\": false, \"value\": 2},\n" +
                    "                {\"text\": \"水\", \"done\": false, \"value\": 3},\n" +
                    "                {\"text\": \"木\", \"done\": false, \"value\": 4},\n" +
                    "                {\"text\": \"金\", \"done\": false, \"value\": 5},\n" +
                    "                {\"text\": \"土\", \"done\": false, \"value\": 6},\n" +
                    "                {\"text\": \"日\", \"done\": false, \"value\": 7}\n" +
                    "              ]";
                  JSONArray jsonArray = new JSONArray(tempWeek);
                  for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject jsonObject = (JSONObject) jsonArray.get(i);
                    if (ordMain.getTreatWeek() == 0 ||
                      jsonObject.get("value").equals((int) ordMain.getTreatWeek())) {
                      jsonObject.put("done", true);
                    }
                  }
                  tempWeek = jsonArray.toString();
                  Date treatDate = new SimpleDateFormat("yyyyMMdd").parse(ordMain.getTreatDate());
                  String treatDateStr = new SimpleDateFormat("yyyy-MM-dd").format(treatDate);
                  String upDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date());

                  Integer[] indKurCdArr = {ordMain.getIndKurCd()};
                  Integer[] indTreatmentCdArr = {ordMain.getIndTreatmentCd()};
                  ApiEntityOrdMain.ValiCreateTreatPlan bodyData = new ApiEntityOrdMain.ValiCreateTreatPlan();
                  // 治療方法名
                  bodyData.setTreatment_name((String) treatment.get("name"));
                  // 治療方法コード
                  bodyData.setTreatment_set_cd(String.valueOf(treatment.get("code")));
                  // 治療方法コード
                  bodyData.setInd_treatment_cd(String.valueOf(treatment.get("code")));
                  // 更新日時
                  bodyData.setUp_date(upDate);
                  // 患者ID
                  bodyData.setPat_id(String.valueOf(ordMain.getPatId()));
                  // 開始日
                  bodyData.setStart_date(treatDateStr);
                  // 終了日
                  bodyData.setEnd_date(treatDateStr);
                  // 施設コード
                  bodyData.setFacility_cd(ordMain.getFacilityCd());
                  // 曜日Jsonデータ
                  bodyData.setWeek_pattern(tempWeek);
                  // 変更対象クール
                  // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  strat
                  // bodyData.setTarget_kur_cd(Arrays.toString(indKurCdArr));
                  bodyData.setInd_kur_cd(Arrays.toString(indKurCdArr));
                  // 変更対象治療方法
                  // bodyData.setTarget_treatment_cd(String.valueOf(ordMain.getIndTreatmentCd()));
                  bodyData.setInd_treatment_cd(String.valueOf(ordMain.getIndTreatmentCd()));
                  // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
                  // 指示者コード
                  bodyData.setInd_user_id(BigInteger.valueOf(defaultSelDoctorNumber));
                  // 更新者コード
                  bodyData.setUpd_user_id(BigInteger.valueOf(userId));
                  // 治療方法変更フラグ
                  bodyData.setTreat_method_flag(String.valueOf(0));
                  // 終了日格納有無
                  bodyData.setIs_deadline(String.valueOf(true));

                  OrdMain ordMainThis = new OrdMain();
                  ordMainThis.setPatId(Long.parseLong(bodyData.getPat_id()));
                  ordMainThis.setFacilityCd(bodyData.getFacility_cd());
                  ordMainThis.setIndTreatmentCd(Integer.parseInt(treatment.get("code").toString()));

                  indHistoryMakeService.createMethodHistory(bodyData, ordMainThis, ordMain, IndicationUtils.getWeekPattern(bodyData.getWeek_pattern()));

                } catch (Exception e) {}
              }
            }
          }
        }
      }
    }
  }
  // add #7327 治療方法マスタ操作時の動作がおかしい 王永吉 end

  /* add by gaojuncheng  2023-01-31 [CodeOptimization]  start */
  @Override
  @Transactional
  public void updatetByTreatSetCdSup(Map<String, Long> request) {
    Boolean isUpdateReplenishLiquid = false;
    Integer deviceMode = Math.toIntExact(request.get("deviceMode"));
    Long oldDeviceMode = request.get("oldDeviceMode");
    // 補液に透析液を同じ値を設定
    if (
      deviceMode.equals(AdminWebConstant.Treatment.DeviceMode.HD_AND_REPLACEMENT) ||
        deviceMode.equals(AdminWebConstant.Treatment.DeviceMode.OHDF) ||
        deviceMode.equals(AdminWebConstant.Treatment.DeviceMode.OHF) ||
        deviceMode.equals(AdminWebConstant.Treatment.DeviceMode.I_HDF)
    ) {
      isUpdateReplenishLiquid = true;
    }

    List<Long> ordNoList = new ArrayList<Long>();
    Long ordNo = request.get("ordNo");
    if (ordNo != null) {
      ordNoList.add(ordNo);
    }

    //　補液更新
    ordMainDao.updateIndCondInfoWithTreatMethodNonReplenishSup(ordNoList, isUpdateReplenishLiquid, oldDeviceMode);
    List<Long> updateOrdNos2 = ordMainDao.selectUpdateIndCondInfoWithTreatMethodReplenishSup(ordNoList, isUpdateReplenishLiquid, oldDeviceMode);
    List<OrdMain> oldOrdMains2 = ordMainDao.selectAllByOrdNoList(updateOrdNos2);
    ordMainDao.updateIndCondInfoWithTreatMethodReplenishSup(ordNoList, isUpdateReplenishLiquid, oldDeviceMode);
    List<OrdMain> newOrdMains2 = ordMainDao.selectAllByOrdNoList(updateOrdNos2);
    triggerUtil.updateTriggerOrdMain(oldOrdMains2, newOrdMains2);
  }

  @Override
  @Transactional
  public void updateTreatmentRecord(String facilityCd, List<Integer> treatmentCdList, Map<Integer, JSONObject> CondList, NtssUser ntssUser) {
    updateOrdMain(facilityCd, treatmentCdList, CondList, ntssUser.getUserId());
    updatePatTreatmentPattern(facilityCd, treatmentCdList, CondList, ntssUser.getUserId());
  }

  // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --start /
  @Override
  @Transactional
  public List<Integer> getOrdMainByCds(List<Integer> indTreatmentCdList) {
    return mstTreatmentDao.getOrdMainByCds(indTreatmentCdList);
  }
  // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --start /

  /* add by gaojuncheng  2023-01-31 [CodeOptimization]  end */

  /*mod #8495 by zhangruixue 2023-03-27  GC overhead limit exceeded start*/
  /**
   * list  Split
   * @param list
   * @param size
   * @param <T>
   * @return
   */
  public static <T> List<List<T>> splitList(List<T> list, int size) {
    if (list == null || list.isEmpty() || size <= 0) {
      return Collections.emptyList();
    }
    int total = list.size();
    int count = (total + size - 1) / size;
    List<List<T>> result = new ArrayList<>(count);
    for (int i = 0; i < count; i++) {
      int start = i * size;
      int end = Math.min(start + size, total);
      result.add(list.subList(start, end));
    }
    return result;
  }
  /*mod #8495 by zhangruixue 2023-03-27  GC overhead limit exceeded end*/

  @Override
  public MstTreatment selectByCd(Integer treatmentCd) {
    return mstTreatmentDao.selectByCd(treatmentCd);
  }
}
