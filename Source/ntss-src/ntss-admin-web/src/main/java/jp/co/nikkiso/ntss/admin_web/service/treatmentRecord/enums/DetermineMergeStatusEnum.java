package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.enums;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.TreatmentRecordMergeChainHandler;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl.DelFixPatOrdMainChainHandler;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl.DelUnknownPatChainHandler;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl.ResetMntStateChainHandler;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl.UpdateMntRecordChainHandler;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl.UpdateMntStateChainHandler;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl.UpdateOrdChecklistChainHandler;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl.UpdateOrdDataChainHandler;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.apache.commons.lang3.StringUtils;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * 実績マージ処理パターン列挙クラス
 *
 * @author Tao.zhou
 * @since 2024-04-03
 */
public enum DetermineMergeStatusEnum {

  /* ==== BaseData.rds is 3 ==== */
  /** BD 3 <-> MD Unknown_Pat_4 */
  BDD_TO_MUAD(BaseOmStatusEnum.DIALYSIS, MergeOmStatusEnum.AFTER_DIALYSIS_U) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {

      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // Unknown_Pat's record will be forced delete.
      mergeConditionMap.put("delFlag", true);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor( new UpdateMntRecordChainHandler(mergeConditionMap) )
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Delete unknown pat's ordMain record.
        .setSuccessor( new DelUnknownPatChainHandler() );

      return updChain;
    }
  },
  /** BD 3 <-> MD Fixed_Pat_4 */
  BDD_TO_MDAD(BaseOmStatusEnum.DIALYSIS, MergeOmStatusEnum.AFTER_DIALYSIS_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Del fix pat's ord info by delFlag.
        .setSuccessor(new DelFixPatOrdMainChainHandler(mergeConditionMap.get("delFlag")));

      return updChain;
    }
  },
  /** BD 3 <-> MD Unknown_Pat_5 */
  BDD_TO_MUAW(BaseOmStatusEnum.DIALYSIS, MergeOmStatusEnum.AFTER_WEIGHT_U) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // Unknown_Pat's record will be forced delete.
      mergeConditionMap.put("delFlag", true);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Delete unknown pat's ordMain record.
        .setSuccessor(new DelUnknownPatChainHandler());

      return updChain;
    }
  },
  /** BD 3 <-> MD Fixed_Pat_5 */
  BDD_TO_MDAW(BaseOmStatusEnum.DIALYSIS, MergeOmStatusEnum.AFTER_WEIGHT_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Del fix pat's ord info by delFlag.
        .setSuccessor(new DelFixPatOrdMainChainHandler(mergeConditionMap.get("delFlag")));

      return updChain;
    }
  },
  /** BD 3 <-> MD Fixed_Pat_6 */
  BDD_TO_MDPR(BaseOmStatusEnum.DIALYSIS, MergeOmStatusEnum.PAST_RECORD_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);
      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap));

      return updChain;
    }
  },


  /* ==== BaseData.rds is 4 ==== */
  /** BD 4 <-> MD Unknown_Pat_3 */
  BDAD_TO_MUD(BaseOmStatusEnum.AFTER_DIALYSIS, MergeOmStatusEnum.DIALYSIS_U) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // Unknown_Pat's record will be forced delete.
      mergeConditionMap.put("delFlag", true);
      // ベースのrdsを「治療中」に変更
      baseOrdMain.setRstDialysisState(AdminWebConstant.OrdMainConst.DialysisState.DIALYSIS);
//      super.chgBaseRdsCons = 1;  // 状態のみ変更
      baseOrdMain.setRstEndDate(null);  // ベースのrdsを「治療中」に変更の時、治療終了日時「NULL」を設定する

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update MntState record
        .setSuccessor(new UpdateMntStateChainHandler())
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Delete unknown pat's ordMain record.
        .setSuccessor(new DelUnknownPatChainHandler());

      return updChain;
    }
  },
  /** BD 4 <-> MD Fixed_Pat_3 */
  BDAD_TO_MDD(BaseOmStatusEnum.AFTER_DIALYSIS, MergeOmStatusEnum.DIALYSIS_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // ベースのrdsを「治療中」に変更
      baseOrdMain.setRstDialysisState(AdminWebConstant.OrdMainConst.DialysisState.DIALYSIS);
      baseOrdMain.setRstEndDate(null);  // ベースのrdsを「治療中」に変更の時、治療終了日時「NULL」を設定する

      // 削除しない場合はrdsを4に変更＋治療終了日時に現在日時を入れる。
      if (!mergeConditionMap.get("delFlag")) {
        mergrOrdMain.setRstDialysisState(AdminWebConstant.OrdMainConst.DialysisState.AFTER_DIALYSIS);
        mergrOrdMain.setRstEndDate(Timestamp.from(Instant.now()));
      }

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);
      // 状態のみ変更
      updChain.setChgBaseRdsCons(1);
      updChain.setChgMergeRdsCons(1);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update MntState record
        .setSuccessor(new UpdateMntStateChainHandler())
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Del fix pat's ord info by delFlag.
        .setSuccessor(new DelFixPatOrdMainChainHandler(mergeConditionMap.get("delFlag")));

      return updChain;
    }
  },
  /** BD 4 <-> MD Unknown_Pat_4 */
  BDAD_TO_MUAD(BaseOmStatusEnum.AFTER_DIALYSIS, MergeOmStatusEnum.AFTER_DIALYSIS_U) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // Unknown_Pat's record will be forced delete.
      mergeConditionMap.put("delFlag", true);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Delete unknown pat's ordMain record.
        .setSuccessor(new DelUnknownPatChainHandler());

      return updChain;
    }
  },
  /** BD 4 <-> MD Fixed_Pat_4 */
  BDAD_TO_MDAD(BaseOmStatusEnum.AFTER_DIALYSIS, MergeOmStatusEnum.AFTER_DIALYSIS_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Del fix pat's ord info by delFlag.
        .setSuccessor(new DelFixPatOrdMainChainHandler(mergeConditionMap.get("delFlag")));

      return updChain;
    }
  },
  /** BD 4 <-> MD Unknown_Pat_5 */
  BDAD_TO_MUAW(BaseOmStatusEnum.AFTER_DIALYSIS, MergeOmStatusEnum.AFTER_WEIGHT_U) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // Unknown_Pat's record will be forced delete.
      mergeConditionMap.put("delFlag", true);

      baseOrdMain.setRstDialysisState(AdminWebConstant.OrdMainConst.DialysisState.AFTER_WEIGHT);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);
      // 状態を変更するだけでなく、必要なフィールドを設定し、または検査を行う
      updChain.setChgBaseRdsCons(2);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Delete unknown pat's ordMain record.
        .setSuccessor(new DelUnknownPatChainHandler());

      return updChain;
    }
  },
  /** BD 4 <-> MD Fixed_Pat_5 */
  BDAD_TO_MDAW(BaseOmStatusEnum.AFTER_DIALYSIS, MergeOmStatusEnum.AFTER_WEIGHT_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      baseOrdMain.setRstDialysisState(AdminWebConstant.OrdMainConst.DialysisState.AFTER_WEIGHT);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);
      // 状態を変更するだけでなく、必要なフィールドを設定し、または検査を行う
      updChain.setChgBaseRdsCons(2);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Del fix pat's ord info by delFlag.
        .setSuccessor(new DelFixPatOrdMainChainHandler(mergeConditionMap.get("delFlag")));

      return updChain;
    }
  },
  /** BD 4 <-> MD Fixed_Pat_6 */
  BDAD_TO_MDPR(BaseOmStatusEnum.AFTER_DIALYSIS, MergeOmStatusEnum.PAST_RECORD_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap));

      return updChain;
    }
  },


  /* ==== BaseData.rds is 5 ==== */
  /** BD 5 <-> MD Unknown_Pat_3 */
  BDAW_TO_MUD(BaseOmStatusEnum.AFTER_WEIGHT, MergeOmStatusEnum.DIALYSIS_U) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // Unknown_Pat's record will be forced delete.
      mergeConditionMap.put("delFlag", true);

      // ベースのrdsを「治療中」に変更
      baseOrdMain.setRstDialysisState(AdminWebConstant.OrdMainConst.DialysisState.DIALYSIS);
      baseOrdMain.setRstEndDate(null);  // ベースのrdsを「治療中」に変更の時、治療終了日時「NULL」を設定する

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);
      // 状態を変更するだけでなく、必要なフィールドを設定し、または検査を行う
      updChain.setChgBaseRdsCons(2);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update MntState record
        .setSuccessor(new UpdateMntStateChainHandler())
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Delete unknown pat's ordMain record.
        .setSuccessor(new DelUnknownPatChainHandler());

      return updChain;
    }
  },
  /** BD 5 <-> MD Fixed_Pat_3 */
  BDAW_TO_MDD(BaseOmStatusEnum.AFTER_WEIGHT, MergeOmStatusEnum.DIALYSIS_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      // ベースのrdsを「治療中」に変更
      baseOrdMain.setRstDialysisState(AdminWebConstant.OrdMainConst.DialysisState.DIALYSIS);
      baseOrdMain.setRstEndDate(null);  // ベースのrdsを「治療中」に変更の時、治療終了日時「NULL」を設定する

      // 削除しない場合はrdsを4に変更＋治療終了日時に現在日時を入れる。
      if (!mergeConditionMap.get("delFlag")) {
        mergrOrdMain.setRstDialysisState(AdminWebConstant.OrdMainConst.DialysisState.AFTER_DIALYSIS);
        mergrOrdMain.setRstEndDate(Timestamp.from(Instant.now()));
      }

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);
      // 状態を変更するだけでなく、必要なフィールドを設定し、または検査を行う
      updChain.setChgBaseRdsCons(2);
      // 状態のみ変更
      updChain.setChgMergeRdsCons(1);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update MntState record
        .setSuccessor(new UpdateMntStateChainHandler())
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Del fix pat's ord info by delFlag.
        .setSuccessor(new DelFixPatOrdMainChainHandler(mergeConditionMap.get("delFlag")));

      return updChain;
    }
  },
  /** BD 5 <-> MD Unknown_Pat_4 */
  BDAW_TO_MUAD(BaseOmStatusEnum.AFTER_WEIGHT, MergeOmStatusEnum.AFTER_DIALYSIS_U) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // Unknown_Pat's record will be forced delete.
      mergeConditionMap.put("delFlag", true);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Delete unknown pat's ordMain record.
        .setSuccessor(new DelUnknownPatChainHandler());

      return updChain;
    }
  },
  /** BD 5 <-> MD Fixed_Pat_4 */
  BDAW_TO_MDAD(BaseOmStatusEnum.AFTER_WEIGHT, MergeOmStatusEnum.AFTER_DIALYSIS_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Del fix pat's ord info by delFlag.
        .setSuccessor(new DelFixPatOrdMainChainHandler(mergeConditionMap.get("delFlag")));

      return updChain;
    }
  },
  /** BD 5 <-> MD Unknown_Pat_5 */
  BDAW_TO_MUAW(BaseOmStatusEnum.AFTER_WEIGHT, MergeOmStatusEnum.AFTER_WEIGHT_U) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // Unknown_Pat's record will be forced delete.
      mergeConditionMap.put("delFlag", true);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Delete unknown pat's ordMain record.
        .setSuccessor(new DelUnknownPatChainHandler());

      return updChain;
    }
  },
  /** BD 5 <-> MD Fixed_Pat_5 */
  BDAW_TO_MDAW(BaseOmStatusEnum.AFTER_WEIGHT, MergeOmStatusEnum.AFTER_WEIGHT_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Reset merge data's machine state record.
        .setSuccessor( new ResetMntStateChainHandler(orgBaseBedCd, orgMergeBedCd) )
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Del fix pat's ord info by delFlag.
        .setSuccessor(new DelFixPatOrdMainChainHandler(mergeConditionMap.get("delFlag")));

      return updChain;
    }
  },
  /** BD 5 <-> MD Fixed_Pat_6 */
  BDAW_TO_MDPR(BaseOmStatusEnum.AFTER_WEIGHT, MergeOmStatusEnum.PAST_RECORD_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap));

      return updChain;
    }
  },


  /* ==== BaseData.rds is 6 ==== */
  /** BD 6 <-> MD Unknown_Pat_3 */
  BDPR_TO_MUD(BaseOmStatusEnum.PAST_RECORD, MergeOmStatusEnum.DIALYSIS_U) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // Unknown_Pat's record will be forced delete.
      mergeConditionMap.put("delFlag", true);

      // Update ordMain's rds.
      baseOrdMain.setIsConfirm(AdminWebConstant.FlagType.FLAG_OFF);
      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Delete unknown pat's ordMain record.
        .setSuccessor(new DelUnknownPatChainHandler());

      return updChain;
    }
  },
  /** BD 6 <-> MD Fixed_Pat_3 */
  BDPR_TO_MDD(BaseOmStatusEnum.PAST_RECORD, MergeOmStatusEnum.DIALYSIS_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      // Update ordMain's rds.
      baseOrdMain.setIsConfirm(AdminWebConstant.FlagType.FLAG_OFF);
      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap));

      return updChain;
    }
  },
  /** BD 6 <-> MD Unknown_Pat_4 */
  BDPR_TO_MUAD(BaseOmStatusEnum.PAST_RECORD, MergeOmStatusEnum.AFTER_DIALYSIS_U) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // Unknown_Pat's record will be forced delete.
      mergeConditionMap.put("delFlag", true);

      baseOrdMain.setIsConfirm(AdminWebConstant.FlagType.FLAG_OFF);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Delete unknown pat's ordMain record.
        .setSuccessor(new DelUnknownPatChainHandler());

      return updChain;
    }
  },
  /** BD 6 <-> MD Fixed_Pat_4 */
  BDPR_TO_MDAD(BaseOmStatusEnum.PAST_RECORD, MergeOmStatusEnum.AFTER_DIALYSIS_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      baseOrdMain.setIsConfirm(AdminWebConstant.FlagType.FLAG_OFF);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap));

      return updChain;
    }
  },
  /** BD 6 <-> MD Unknown_Pat_5 */
  BDPR_TO_MUAW(BaseOmStatusEnum.PAST_RECORD, MergeOmStatusEnum.AFTER_WEIGHT_U) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);
      // Unknown_Pat's record will be forced delete.
      mergeConditionMap.put("delFlag", true);

      baseOrdMain.setIsConfirm(AdminWebConstant.FlagType.FLAG_OFF);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap))
        // Delete unknown pat's ordMain record.
        .setSuccessor(new DelUnknownPatChainHandler());

      return updChain;
    }
  },
  /** BD 6 <-> MD Fixed_Pat_5 */
  BDPR_TO_MDAW(BaseOmStatusEnum.PAST_RECORD, MergeOmStatusEnum.AFTER_WEIGHT_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      baseOrdMain.setIsConfirm(AdminWebConstant.FlagType.FLAG_OFF);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap));

      return updChain;
    }
  },
  /** BD 6 <-> MD Fixed_Pat_6 */
  BDPR_TO_MDPR(BaseOmStatusEnum.PAST_RECORD, MergeOmStatusEnum.PAST_RECORD_D) {
    @Override
    public TreatmentRecordMergeChainHandler getDetermineStatusHandler(OrdMain baseOrdMain
      , OrdMain mergrOrdMain, Long orgBaseBedCd, Long orgMergeBedCd, Integer assemblyMergeCondition
      , long maxMedicNo, String mergedMediInfo) {
      // dismantling merge conditions
      Map<String, Boolean> mergeConditionMap = super.dismantlingMergeCondition(assemblyMergeCondition);

      baseOrdMain.setIsConfirm(AdminWebConstant.FlagType.FLAG_OFF);

      // Update ordMain's data.
      UpdateOrdDataChainHandler updChain =
        (UpdateOrdDataChainHandler) new UpdateOrdDataChainHandler(maxMedicNo, mergeConditionMap.get("delFlag"), mergedMediInfo)
        .setBaseOrdMainData(baseOrdMain).setMergeOrdMainData(mergrOrdMain);

      updChain
        // Update ordMain's cl.
        .setSuccessor(new UpdateOrdChecklistChainHandler(
          mergeConditionMap.get("delFlag"),
          mergeConditionMap.get("checkListFlag")))
        // Update treatment's mnt records.
        .setSuccessor(new UpdateMntRecordChainHandler(mergeConditionMap));

      return updChain;
    }
  },
  ;

  /** ベース治療状況 */
  private final BaseOmStatusEnum baseOmStatus;
  /** マージ治療状況 */
  private final MergeOmStatusEnum mergeOmStatus;

  private static final int MERGE_CONDITION_LEN = 6;

  /**
   * 実績マージ処理パターン列挙クラスのコンストラクタ
   *
   * @param baseRds ベース治療状況
   * @param mergeRds  マージ治療状況
   */
  DetermineMergeStatusEnum(BaseOmStatusEnum baseRds, MergeOmStatusEnum mergeRds) {
    this.baseOmStatus = baseRds;
    this.mergeOmStatus = mergeRds;
  }

  /** 実績マージ処理パターンのチェーン構造 */
  public abstract TreatmentRecordMergeChainHandler getDetermineStatusHandler(
    OrdMain baseOrdMain
    , OrdMain mergrOrdMain
    , Long orgBaseBedCd
    , Long orgMergeBedCd
    , Integer assemblyMergeCondition
    , long maxMedicNo
    , String mergedMediInfo
  );

  /**
   * パラメータにようり、実際マージ処理パターン取得
   *
   * @param baseRds ベース治療状況
   * @param mergeRds  マージ治療状況
   * @param unknownPat  ？？患者
   * @return  実際マージ処理パターン
   */
  public static Optional<DetermineMergeStatusEnum> getDetermineStatus(String baseRds, String mergeRds, boolean unknownPat) {
    Optional<BaseOmStatusEnum> optionalBaseRds = BaseOmStatusEnum.getBaseOmStatusByCd(baseRds);
    Optional<MergeOmStatusEnum> optionalMergeRds = MergeOmStatusEnum.getMergeOmStatusByCond(mergeRds, unknownPat);

    if (optionalBaseRds.isPresent() && optionalMergeRds.isPresent()) {
      return Arrays.stream(values())
        .filter(
          dms ->
            dms.getBaseOmStatus().equals(optionalBaseRds.get())
              && dms.getMergeOmStatus().equals(optionalMergeRds.get()))
        .findFirst();
    } else {
      return Optional.empty();
    }
  }

  public BaseOmStatusEnum getBaseOmStatus() {
    return baseOmStatus;
  }

  public MergeOmStatusEnum getMergeOmStatus() {
    return mergeOmStatus;
  }

  /**
   * アセンブリパラメータ
   *
   * @param delFlag   患者の実績を削除
   * @param deviceSetInfoFlag 装置設定情報マージ有無
   * @param vitalMergeFlg   バイタル情報マージ有無
   * @param monitorMergeFlg モニタ情報マージ有無
   * @param deviceSetRecordFlag 装置記録情報マージ有無
   * @return  アセンブリ後のパラメータ
   */
  public static Integer assemblyMergeCondition(boolean delFlag, boolean deviceSetInfoFlag
    , boolean vitalMergeFlg, boolean monitorMergeFlg, boolean deviceSetRecordFlag, boolean ordCheclistFlg) {

    return (delFlag ? 1 : 0)
      | (ordCheclistFlg ? 1 << 1 : 0)
      | (deviceSetInfoFlag ? 1 << 2 : 0)
      | (vitalMergeFlg ? 1 << 3 : 0)
      | (monitorMergeFlg ? 1 << 4 : 0)
      | (deviceSetRecordFlag ? 1 << 5 : 0);
  }

  /**
   * 分解パラメータ
   *
   * @param mergeCondition  アセンブリパラメータ
   * @return  分解後のパラメータメープル
   */
  private Map<String, Boolean> dismantlingMergeCondition(Integer mergeCondition) {

    if (mergeCondition == null) mergeCondition = 0;
    //
    String binaryStr = Integer.toBinaryString(mergeCondition);

    if (binaryStr.length() < MERGE_CONDITION_LEN)
      binaryStr = StringUtils.leftPad(binaryStr, MERGE_CONDITION_LEN, "0");

    Map<String, Boolean> mergeConditionMap = new HashMap<>(MERGE_CONDITION_LEN);

    mergeConditionMap.put("delFlag"
      , StringUtils.equals(AdminWebConstant.FlagType.FLAG_ON, String.valueOf(binaryStr.charAt(5))));
    mergeConditionMap.put("checkListFlag"
      , StringUtils.equals(AdminWebConstant.FlagType.FLAG_ON, String.valueOf(binaryStr.charAt(4))));
    mergeConditionMap.put("deviceSetInfoFlag"
      , StringUtils.equals(AdminWebConstant.FlagType.FLAG_ON, String.valueOf(binaryStr.charAt(3))));
    mergeConditionMap.put("vitalMergeFlg"
      , StringUtils.equals(AdminWebConstant.FlagType.FLAG_ON, String.valueOf(binaryStr.charAt(2))));
    mergeConditionMap.put("monitorMergeFlg"
      , StringUtils.equals(AdminWebConstant.FlagType.FLAG_ON, String.valueOf(binaryStr.charAt(1))));
    mergeConditionMap.put("deviceSetRecordFlag"
      , StringUtils.equals(AdminWebConstant.FlagType.FLAG_ON, String.valueOf(binaryStr.charAt(0))));

    return mergeConditionMap;
  }
}
