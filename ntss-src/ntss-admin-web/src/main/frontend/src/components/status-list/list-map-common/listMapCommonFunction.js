import dayjs from "@/compat/date/dayjs";
import {DIALISYS_STATE, MACHINE_ENTRY_STATE} from "@/constants/statusMapConstants";

/**
 * 情報表示判定処理
 */
export function isDisp(treatData, state, getters) {
  let ret = false;
  // 条件別次患者表示
  let nextPat;
  // 治療状況リストの場合
  if (null != getters) {
    if (getters.getIsShowMain) {
      nextPat = getters.conditionFilter.nextPatValue;
    } else {
      nextPat = getters.conditionFilter.deviceNextValue;
    }
    // 治療状況マップの場合
  } else {
    nextPat = state.findState.conditionTreatMap.nextPatValue;
  }
  if (nextPat == 0 && treatData.rstDialysisState == DIALISYS_STATE.BEFORE_SEND_CONDITION) {
    return false;
  }
  // 現クール/次クール開始日付時刻を取得
  const currentKurStartDateTime = getCurrentKurStartDateTime(state.mstKurList);

  const nextKurStartDateTime = getNextKurStartDateTime(state.mstKurList);

  const todayStartDateTime = getCurrentDate() + "000000";

  // 現在治療中の治療データである
  let isDialysis = treatData.machineEntry == MACHINE_ENTRY_STATE.NOW_PATIENT;
  // 次患者の治療データである
  const isNextDialysis = !isDialysis && treatData.machineEntry == MACHINE_ENTRY_STATE.NEXT_PATIENT;
  // 次患者である場合
  let checkKurDateTime = "";
  if (isNextDialysis) {
    // チェック対象日時(治療日+クール開始時刻)を作成
    checkKurDateTime = treatData.treatDate + getKurStartTime(state.mstKurList, treatData.kurCd);
  }
  // 表示画面判定
  // 治療状況リストの場合
  if (null != getters && getters.getIsShowMain) {
    // 治療状況画面が表示されている場合
    // 治療状態が後体重測定待ち、版確定待ちの場合
    if (treatData.rstDialysisState == DIALISYS_STATE.AFTER_DRAINAGE
      || treatData.rstDialysisState == DIALISYS_STATE.AFTER_WEIGHT_MEASURING) {
      // 治療中とする
      isDialysis = true;
    }
  } else {
    // 装置一覧画面が表示されている場合
    // 装置エントリー状態判定
    if (treatData.machineEntry == MACHINE_ENTRY_STATE.NON_PATIENT) {
      // 空きベッドの場合治療中とする
      isDialysis = true;
    }
  }
  if (isDialysis) {
    // 治療状況リストの場合
    if (null != getters && getters.getIsShowMain) {
      // 治療状況画面が表示されている場合
      // 版確定後の場合
      if (treatData.rstDialysisState == DIALISYS_STATE.CONFIRMED_WEIGHT_MEASURING) {
        // 治療中以外とする
        return false;
      }
    } else {
      // 装置一覧画面が表示されている場合
      // ベッド番号確認
      if (treatData.bedCd == null) {
        // ベッド番号がない場合は治療中以外とする
        return false;
      }
      // 治療状態が後体重測定待ち、版確定待ち、版確定後の場合
      if (treatData.rstDialysisState == DIALISYS_STATE.AFTER_DRAINAGE
        || treatData.rstDialysisState == DIALISYS_STATE.AFTER_WEIGHT_MEASURING
        || treatData.rstDialysisState == DIALISYS_STATE.CONFIRMED_WEIGHT_MEASURING) {
        // 治療中以外とする
        return false;
      }
    }
    // 治療中のデータは表示する
    ret = true;
  } else {
    switch (nextPat) {
      case 0: {
        // 表示しない
        break;
      }
      case 1: {
        // 現クール
        if (isNextDialysis) {
          // 現クール判定
          if (checkKurDateTime <= currentKurStartDateTime && checkKurDateTime >= todayStartDateTime) {
            ret = true;
          }
        }
        break;
      }
      default: {
        // 次クール
        if (isNextDialysis) {
          // 次クール判定
          if (checkKurDateTime <= nextKurStartDateTime && checkKurDateTime >= todayStartDateTime) {
            ret = true;
          }
        }
        break;
      }
    }
  }
  return ret;
}

/**
 *  現クール開始日付時刻を取得
 */
function getCurrentKurStartDateTime(kurList) {
  let ret = getCurrentDate();
  // 現在クール取得
  const kur = getCurrentKur(kurList);
  if (kur != undefined) {
    ret += kur.kurStartTime;
  }
  return ret;
}

/**
 *  次クール開始日付時刻を取得
 */
function getNextKurStartDateTime(kurList) {
  let ret = "";
  // 現在日付取得
  const now = new Date();
  let checkDate = dayjs(now).format("YYYYMMDD");

  // 現クール開始時刻を取得
  const currentKurStartDateTime = getCurrentKurStartDateTime(kurList);

  // クール情報リスト
  let lop = 0;
  for (; lop < kurList.length; lop++) {
    // 対象クールの開始日付時刻を作成
    let checkDateTime =
      checkDate + getKurStartTime(kurList, kurList[lop].kurCd);

    // 現クール開始時刻と比較
    if (currentKurStartDateTime < checkDateTime) {
      // 現クール開始時刻より大きい
      ret = checkDateTime;
      break;
    }
  }

  // 最後クール判定
  if (lop != 0 && lop == kurList.length) {
    // 翌日判定
    now.setDate(now.getDate() + 1);
    ret =
      dayjs(now).format("YYYYMMDD") +
      getKurStartTime(kurList, kurList[0].kurCd);
  }

  return ret;
}

/**
 * 指定クールの開始時刻を取得
 */
function getKurStartTime(kurList, kurCd) {
  let ret = "000000";
  if (kurCd != null) {
    const kur = kurList.find(dat => dat.kurCd.toString() == kurCd.toString());
    if (kur != undefined) {
      ret = kur.kurStartTime;
    }
  }
  return ret;
}

/**
 * 現在クール
 */
function getCurrentKur(kurList) {
  return kurList.find(
    dat =>
      dat.kurStartTime <= getCurrentTime() && dat.kurEndTime >= getCurrentTime()
  );
}

function getCurrentDate() {
  return dayjs(new Date()).format("YYYYMMDD");
}

function getCurrentTime() {
  return dayjs(new Date()).format("HHmmss");
}
