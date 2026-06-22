package jp.co.nikkiso.ntss.api.service.indHistory;

import jp.co.nikkiso.ntss.api.model.indHistory.IndHistory;
import jp.co.nikkiso.ntss.api.model.indHistory.TreatMethodChangeHelper;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiCommentCreate;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiCopyTreatPlan;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiCreateTreatPlan;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiDeleteIndPlanPatInfo;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiDeviceSetInfo;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiMoveTreatPlan;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiOrdEquip;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiOrdMedi;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiUpdateIndCond;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiUpdateIndSchedule;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiWeekPattern;
import jp.co.nikkiso.ntss.core.entity.OrdMain;

import java.text.ParseException;
import java.util.HashMap;
import java.util.List;

/**
 * 指示履歴登録処理
 */
public interface CreateIndHistoryService {

  boolean isToMongo();

  /**
   * 指示履歴登録処理を実行
   */
  void createHistoryExecute(IndHistory indHistory, String flag);
  void createHistoryExecuteBatch(List<IndHistory> indHistoryList, String flag);

  /**
   * 治療予定・予定中止変更
   */
  void createDeleteHistoryByDeleteIndPlanPatInfo(ValiDeleteIndPlanPatInfo bodyData,List<OrdMain> ordMainList, String dialysisDateFrom,
                                                 String dialysisDateTo) throws ParseException;

  /**
   * 治療予定・予定作成変更
   */
  void createPlanHistory(ValiCreateTreatPlan bodyData, OrdMain ordMain, List<Integer> weeksArray);

  /**
   * 治療予定・治療日変更
   */
  void createMoveHistory(ValiMoveTreatPlan bodyData, OrdMain ordMain, List<Integer> weeksArray);

  /**
   * 治療予定・予定コピー変更
   */
  void createCopyHistory(ValiCopyTreatPlan bodyData, OrdMain ordMain, List<Integer> weeksArray);

  /**
   * 治療条件変更
   */
  void createConditionHistory(ValiUpdateIndCond bodyData, String flag, List<Integer> weeksArray, List<OrdMain> ordMainList);

  /**
   * 投与薬剤変更
   */
  void createMedicineHistory(ValiOrdMedi bodyData, String flag, List<Integer> weeksArray, List<OrdMain> ordMains);

  /**
   * 風袋変更  除水補正変更
   */
  void createIndTareInfoHistory(ValiCreateTreatPlan bodyData, OrdMain ordMain, String indTareInfo, List<Integer> weeksArray, String TareName, String flag);

  /**
   * 医療材料変更
   */
  void createEquipmentHistory(ValiOrdEquip bodyData, String flag, List<Integer> weeksArray,  List<OrdMain> ordMainList);

  /**
   * スケジュール変更
   */
  List<IndHistory> createScheduleHistory(ValiUpdateIndSchedule bodyData, String flag, List<Integer> weeksArray, List<OrdMain> ordMainList, String paramTarget);

  /**
   * 装置設定
   */
  void createDeviceSetInfoHistory(ValiDeviceSetInfo bodyData, String flag, List<Integer> weeksArray, List<OrdMain> ordMainList);

  /**
   * 治療方法
   */
  void createMethodHistory(ValiCreateTreatPlan bodyData, OrdMain ordMain, OrdMain targetOrdMain, List<Integer> weeksArray);

  /**
   * 治療方法Master変更
   */
  void createMstTreatmentModifyHistory(String facilityCd, String patId, String indTreatmentName, Long indUserId, Long updUserId, TreatMethodChangeHelper treatCondSettingDiff);

  /**
   * 治療予定・曜日パターン変更
   */
  void createWeekPatternHistory(ValiWeekPattern bodyData, HashMap<Short, List<Short>> changWeekList, List<Integer> srcDelWeekList);

  /**
   * 指示コメント
   */
  void createCommentHistory(ValiCommentCreate bodyData, String flag, List<Integer> weeksArray, List<String> oldIndContents);
}
