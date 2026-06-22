package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.impl;

import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler.TreatmentRecordMergeChainHandler;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.utils.AppContextUtils;

import java.sql.Timestamp;
import java.time.Instant;

/**
 * レーセット装置状態管理情報
 *
 * @author Tao.zhou
 */
public class ResetMntStateChainHandler extends TreatmentRecordMergeChainHandler {

  private static final String JSON_OBJECT_EMPTY = "{}";

  /** 装置状態管理のDaoインタフェース. */
  private final MntMachineStateDao mntMachineStateDao;

  private final Long currentBedCd;
  private final Long otherBedCd;

  public ResetMntStateChainHandler(Long currentBedCd, Long otherBedCd) {
    this.currentBedCd = currentBedCd;
    this.otherBedCd = otherBedCd;

    this.mntMachineStateDao = AppContextUtils.getBean(MntMachineStateDao.class);
  }

  private void restMachineState(MntMachineState mntMachineState, Timestamp currentTime) {
    if (mntMachineState != null) {
      mntMachineState.setOrdNo(null);
      mntMachineState.setPatId(null);
      mntMachineState.setWeighBeforeDate(null);
      mntMachineState.setCondSendDate(null);
      mntMachineState.setCondSetDate(null);
      mntMachineState.setStartDate(null);
      mntMachineState.setEndDate(null);
      mntMachineState.setWeighAfterDate(null);
      mntMachineState.setIsPatVerified("0");
      mntMachineState.setAlarmList(JSON_OBJECT_EMPTY);
      mntMachineState.setUpDate(currentTime);
    }
  }

  @Override
  public void execute() {
    Timestamp currentTime = Timestamp.from(Instant.now());

    // find out which bed's record needs to reset?
    boolean updStateForBaseSide;
    boolean updStateForMergeSide;
    if (this.currentBedCd != null && this.otherBedCd != null) {

      // do not change bed means there's no needs to reset.
      if (this.currentBedCd.equals(this.otherBedCd)) {
        updStateForBaseSide = false;
        updStateForMergeSide = false;
      }
      // other bed's record needs to reset.
      else if (this.currentBedCd.equals(getBaseOrdMainData().getRstBedCd())
        && this.otherBedCd.equals(getMergeOrdMainData().getRstBedCd())
      ) {
        updStateForBaseSide = false;
        updStateForMergeSide = true;
      }
      // original base bed's record needs to reset.
      else if (getBaseOrdMainData().getRstBedCd().equals(getMergeOrdMainData().getRstBedCd())
        && this.otherBedCd.equals(getMergeOrdMainData().getRstBedCd())
      ) {
        updStateForBaseSide = true;
        updStateForMergeSide = false;
      }
      // otherwise, I don't know which record needs to reset, so just skip this handle.
      else {
        updStateForBaseSide = false;
        updStateForMergeSide = false;
      }

    } else {
      updStateForBaseSide = false;
      updStateForMergeSide = false;
    }

    //
    Long ordNoToClear;
    if (updStateForBaseSide) {
      ordNoToClear = super.getBaseOrdMainData().getOrdNo();
    } else if (updStateForMergeSide) {
      ordNoToClear = super.getMergeOrdMainData().getOrdNo();
    } else {
      ordNoToClear = null;
    }

    if (ordNoToClear != null) {
      Long paramBedCd = updStateForBaseSide ? this.currentBedCd : this.otherBedCd;

      // 現在画面端に選べたのベッド対応のもうの装置状態情報を取得する
      MntMachineState currMachineState =
        this.mntMachineStateDao
          .selectActiveByBedCd(getBaseOrdMainData().getFacilityCd(), paramBedCd);
      // 現在の治療情報かどうかを判断する
      if (currMachineState != null && ordNoToClear.equals(currMachineState.getOrdNo())) {
        // resetState
        this.restMachineState(currMachineState, currentTime);
        this.mntMachineStateDao.update(currMachineState);
      }
    }

    // 現在、後続の処理があるかどうかを判断し、処理があれば後続の処理を行う。
    if (getSuccessor() != null) {
      getSuccessor().execute();
    }
  }
}
