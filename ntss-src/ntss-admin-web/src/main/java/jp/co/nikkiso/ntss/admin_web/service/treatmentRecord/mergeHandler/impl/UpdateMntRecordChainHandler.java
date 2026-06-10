package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.TreatmentRecordMergeChainHandler;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdTreatConditionDao;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.OrdTreatConditionDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.utils.AppContextUtils;
import jp.co.nikkiso.ntss.core.utils.BeanBuilderUtils;
import org.springframework.beans.BeanUtils;
import org.springframework.util.CollectionUtils;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * 装置状態更新Handler
 *
 * @author Tao.zhou
 * @since 2024-04-08
 */
public class UpdateMntRecordChainHandler extends TreatmentRecordMergeChainHandler {

  private final MniMonitorDao mniMonitorDao;

  private final MntMotionRecordDao mntMotionRecordDao;

  private final OrdTreatConditionDao ordTreatConditionDao;

  private final ComsvOrdTreatConditionDao comsvOrdTreatConditionDao;

  private final boolean delFlag;

  /** バイタル情報マージ有無 */
  private final boolean vitalMergeFlg;
  /** モニタ情報マージ有無 */
  private final boolean monitorMergeFlg;
  /** 装置設定情報マージ有無 */
  private final boolean deviceSetInfoFlag;
  /** 装置記録情報マージ有無 */
  private final boolean deviceSetRecordFlag;

  public UpdateMntRecordChainHandler(Map<String, Boolean> mergeConditionMap) {

    this.delFlag = mergeConditionMap.get("delFlag");

    this.vitalMergeFlg = mergeConditionMap.get("vitalMergeFlg");
    this.monitorMergeFlg = mergeConditionMap.get("monitorMergeFlg");
    this.deviceSetInfoFlag = mergeConditionMap.get("deviceSetInfoFlag");
    this.deviceSetRecordFlag = mergeConditionMap.get("deviceSetRecordFlag");

    this.mniMonitorDao = AppContextUtils.getBean(MniMonitorDao.class);
    this.mntMotionRecordDao = AppContextUtils.getBean(MntMotionRecordDao.class);
    this.ordTreatConditionDao = AppContextUtils.getBean(OrdTreatConditionDao.class);
    this.comsvOrdTreatConditionDao = AppContextUtils.getBean(ComsvOrdTreatConditionDao.class);
  }


  @Override
  public void execute() {

    Timestamp updTs = Timestamp.from(Instant.now());

    // 装置設定情報マージ
    if (deviceSetInfoFlag) {
      // 装置設定情報のデータを割り当て患者のデータになるように書き換える
      ordTreatConditionDao.updateOrdNo(
        getBaseOrdMainData().getOrdNo()
        , getMergeOrdMainData().getOrdNo()
        , updTs
      );
    }

    // 更新の目標モニタデータ
    List<MniMonitor> mniMonitorList = mniMonitorDao.selectRecordByConds(
      BeanBuilderUtils.of(MniMonitor::new)
        .with(MniMonitor::setFacilityCd, getBaseOrdMainData().getFacilityCd())
        .with(MniMonitor::setOrdNo, getMergeOrdMainData().getOrdNo())
        .with(MniMonitor::setIsDel, AdminWebConstant.FlagType.FLAG_OFF)
        .build()
    );

    // モニタ情報マージ
    if (monitorMergeFlg) {
      List<MniMonitor> monitorList = mniMonitorList
        .stream()
        .filter(
          mm -> Objects.equals(CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_MONITOR, mm.getDataType())
        ).toList();
      // モニタ情報を更新
      updateMniMonitorRecord(updTs, getBaseOrdMainData().getOrdNo()
        , getBaseOrdMainData().getPatId(), monitorList);
    }

    // バイタル情報マージ
    if (vitalMergeFlg) {
      List<MniMonitor> vitalMonitorList = mniMonitorList
        .stream()
        .filter(
          mm -> List.of(
            CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP
            , CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_TEMPERATURE
            , CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_BEFORE_BP
            , CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_AFTER_BP
          ).contains(mm.getDataType())
        ).toList();
      // モニタ情報を更新
      updateMniMonitorRecord(updTs, getBaseOrdMainData().getOrdNo()
        , getBaseOrdMainData().getPatId(), vitalMonitorList);

      // マージ後、前血圧、後血圧が複数になる場合がある為、複数存在する場合には、データ種別を更新する。
      List<MniMonitor> vitalBpDataList = mniMonitorDao.selectRecordByOrdNoAndDataType(
        getBaseOrdMainData().getFacilityCd()
        , getBaseOrdMainData().getOrdNo()
        , List.of(
          CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP
          , CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_BEFORE_BP
          , CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_AFTER_BP
        )
      );

      if (!CollectionUtils.isEmpty(vitalBpDataList)) {
        // タイムスタンプでソート
        vitalBpDataList.sort(Comparator.comparing(MniMonitor::getOccurDate));
        // 先ず、すべてのデータ種別を透析中血圧に変更
        List<MniMonitor> modVitalBpDataList = vitalBpDataList.stream()
          .map(mm -> {
            // Deep copy every element, so that we can find the modified records at last.
            MniMonitor entity = new MniMonitor();
            BeanUtils.copyProperties(mm, entity);
            return entity;
          })
          .peek(vbp -> vbp.setDataType(CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP))
          .toList();

        // 前血圧 -> 開始時刻より前で開始時刻に最近のレコード
        modVitalBpDataList
          .stream()
          .filter(vbp -> vbp.getOccurDate().before(getBaseOrdMainData().getRstStartDate()))
          .max(Comparator.comparing(MniMonitor::getOccurDate))
          .ifPresent(beforeBp -> beforeBp.setDataType(CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_BEFORE_BP));

        // 後血圧 -> 終了時間後の最後のレコード
        if (getBaseOrdMainData().getRstEndDate() != null) {
          modVitalBpDataList
            .stream()
            .filter(vbp -> vbp.getOccurDate().after(getBaseOrdMainData().getRstEndDate()))
            .max(Comparator.comparing(MniMonitor::getOccurDate))
            .ifPresent(afterBp -> afterBp.setDataType(CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_AFTER_BP));
        }

        // 血圧のデータ更新(only the data which has been modified.)
        List<MniMonitor> modifiedList = new ArrayList<>();
        modVitalBpDataList.forEach(
          vbd -> {
            // I've been overridden MniMonitor entity's method [equals],
            // So we can simply use List.contains to find the records which has been modified.
            if (!vitalBpDataList.contains(vbd))  modifiedList.add(vbd);
          }
        );
        if (!CollectionUtils.isEmpty(modifiedList)) mniMonitorDao.batchUpdateRecordByConds(modifiedList);
      }
    }

    // モニタデータ更新後、Emptyする
    mniMonitorList.clear();

    // 装置記録情報マージ
    if (deviceSetRecordFlag) {
      // 治療記録中の条件による装置記録を検索
      List<MntMotionRecord> mntMotionRecords = mntMotionRecordDao.getMntMotionRecordByTreatConds(
        baseOrdMainData.getFacilityCd(), mergeOrdMainData.getOrdNo(), mergeOrdMainData.getRstBedCd()
      );

      // パラメータの再アセンブリ、batchInsert
      mntMotionRecordDao.batchUpdRecord(
        mntMotionRecords.stream().peek(mmr -> {
          // 割り当て患者のデータになるように書き換える
          mmr.setOrdNo(baseOrdMainData.getOrdNo());
          mmr.setUpDate(updTs);
        }).toList()
      );
    }

    // 現在、後続の処理があるかどうかを判断し、処理があれば後続の処理を行う。
    if (getSuccessor() != null) {
      getSuccessor().execute();
    }
  }

  private void updateMniMonitorRecord(Timestamp updTs, Long baseOrdNo, Long basePatId
    , List<MniMonitor> monitorRecordList) {
    // モニタ情報のデータを割り当て患者のデータになるように書き換える
    mniMonitorDao.batchUpdateRecordByConds(
      monitorRecordList.stream()
        .peek(
          mmUpd -> {
            mmUpd.setOrdNo(baseOrdNo);
            mmUpd.setPatId(basePatId);
            mmUpd.setUpDate(updTs);
            mmUpd.setUpdStaffId(getBaseOrdMainData().getUpUserId());
          }
        ).toList()
    );
  }
}
