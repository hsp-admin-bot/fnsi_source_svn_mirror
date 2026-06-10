import store from "@/stores";
import router from "@/router";
import ons from "onsenui";
import moment from "moment";
import { sendPostRequestGetMinSchExtEndDate } from "@/apis/exam-request";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { getDeadlineDate } from "@/functions/common/DateTimeUtils";
import {
  CANCEL,
  SAVED,
  ADD,
  ADD_WARNING,
  FILLCOLOR_DEFAULT,
  FILLCOLOR_HAS_SCHEDULE,
  FILLCOLOR_HAS_NOT_SCHEDULE,
  IntervalValues,
} from "@/constants/examRequestConstants";
import { getAuthorized } from "@/functions/common/CommonFunctions";
import { messageFormat } from "@/functions/common/MessageFormat";
import { confirmIsOk } from "@/functions/common/OnsenFunctions";
import { groupBy, sortableCompare } from "@/functions/SortFunctions";

const INPUT_DATE_FORMAT = "YYYY-MM-DD";
const NO_SEP_DATE_FORMAT = "YYYYMMDD";
const SLASH_DATE_FORMAT = "YYYY/MM/DD";

const getDefaultSchExtEndDateMoment = () => moment().add(12, "months").endOf("month");

/** デフォルトのスケジュール延長最終日を取得 */
export const getDefaultSchExtEndDate = () => getDefaultSchExtEndDateMoment().format(INPUT_DATE_FORMAT);

/** patMainListから患者IDに対応するスケジュール延長最終日を取得する("YYYYMMDD"形式) */
export const getSchExtEndDateWithPatMainList = (patMainList, patId) => {
  const patInfo = patMainList && patMainList.find(aPatInfo => aPatInfo.patId == patId);
  const schExtEndDate = patInfo && patInfo.schExtEndDate
    ? patInfo.schExtEndDate
    : getDefaultSchExtEndDateMoment().format(NO_SEP_DATE_FORMAT);
  return schExtEndDate;
};

/** スケジュール延長最終日を取得 */
export const getMinSchExtEndDateCore = async (facilityCd, patIdList) => {
  const minSchExtEndDate = await sendPostRequestGetMinSchExtEndDate(facilityCd, patIdList);
  // APIレスポンスの minSchExtEndDate.data の型についてのメモ：
  // 患者情報のスケジュール延長最終日を直接取得した場合の型はstringだが、
  // このAPIでは処理対象にスケジュール延長最終日がnullでない患者がいる場合は
  // min処理によってnumberになっている。
  // そうでない場合はstringで空文字列になっている。
  const schExtEndDateMoment = minSchExtEndDate.data
    ? moment("" + minSchExtEndDate.data, NO_SEP_DATE_FORMAT)
    : getDefaultSchExtEndDateMoment();
  const schExtEndDate = schExtEndDateMoment.format(INPUT_DATE_FORMAT);
  return schExtEndDate;
};

/**
 * 日付入力値をスケジュール延長最終日を上限として補正する
 * (但し空値の場合は無期限扱いなので補正しない)
 */
export const modifyInputDateCore = (condition, conditionName, schExtEndDate) => {
  if (condition[conditionName]) {
    const inputDate = moment(condition[conditionName], INPUT_DATE_FORMAT);
    const maxDate = moment(schExtEndDate, INPUT_DATE_FORMAT);
    if (inputDate.isValid() && inputDate.isAfter(maxDate)) {
      condition[conditionName] = schExtEndDate;
    }
  }
};

/** 患者ごとのスケジュール延長最終日と登録対象の日付を比較しスケジュール作成範囲外の患者の存在チェック */
export const checkSchDateCore = (patInfoList, checkDate) => {
  // 1年後の月末日付
  const limitDate = getDefaultSchExtEndDateMoment().format("YYYYMMDD");
  // 患者ごとのスケジュール延長最終日を取得
  const patExtInfoList = {};
  const outsideSchExtPatList = [];
  // 対象患者でループ
  patInfoList.forEach(patInfo => {
    const patId = patInfo.pat_id;
    // スケジュール延長最終日存在しない場合は1年後の月末日付を設定
    const schExtEndDate = patInfo.sch_ext_end_date || limitDate;
    // ストアに保存する情報を作成
    patExtInfoList[patId] = {
      patId,
      schExtEndDate,
      isExistEndDate: !!patInfo.sch_ext_end_date,
    };
    if (checkDate > schExtEndDate) {
      // スケジュール作成範囲外の患者のリストに追加
      outsideSchExtPatList.push(patId);
    }
  });
  return { patExtInfoList, outsideSchExtPatList };
};

/**
 * 患者ごとのスケジュール延長最終日と登録対象の日付を比較しスケジュール作成範囲外の患者の存在チェック
 * （画面に応じたStoreに結果を格納する）
 */
export const checkSchDate = (patInfoList, checkDate) => {
  const storePath = getStorePath();
  if (!storePath) return;

  const { patExtInfoList, outsideSchExtPatList } = checkSchDateCore(patInfoList, checkDate);
  store.dispatch(`${storePath}/setPatExtInfoList`, patExtInfoList);
  store.dispatch(`${storePath}/setOutsideSchExtPatList`, outsideSchExtPatList);
};

/**
 * 指定期間で月ごとの対象曜日の日付リストを作成
 * baseDayCount：第n週の補足値 (第1：0、第2:7、第3:14、第4:21)
 */
export const extractTargetDate = (condition, baseDayCount, patInfoList) => {
  const storePath = getStorePath();
  if (!storePath) return [];

  const { startDate, endDate, selectedDayOfWeek } = condition;
  const startDateMoment = moment(startDate);
  const endDateMoment = moment(endDate || getDefaultSchExtEndDate());
  const rtnDateList = [];

  // 月ごとの対象日付を取得する (月曜：1～日曜：7、月曜始まり)
  for (
    const dateWork = startDateMoment.clone();
    dateWork.isSameOrBefore(endDateMoment, "month");
    dateWork.add(1, "months")
  ) {
    // 月初めの日付を確認し、第1週の指定曜日まで進める
    const firstDayWeek = dateWork.startOf("month").format("E");
    if (firstDayWeek <= selectedDayOfWeek) {
      dateWork.add(selectedDayOfWeek - firstDayWeek, "days");
    } else {
      dateWork.add(7 - (firstDayWeek - selectedDayOfWeek), "days");
    }
    // n週分日付を進める
    dateWork.add(baseDayCount, "days");
    rtnDateList.push(dateWork.format("YYYYMMDD"));
    // 続く処理の為に、月初めの日付に戻す
    dateWork.startOf("month");
  }

  if (rtnDateList.length) {
    // 最初と最後の日付だけ範囲を確認
    if (startDateMoment.isAfter(rtnDateList[0])) {
      rtnDateList.shift();
      if (!rtnDateList.length) {
        return rtnDateList;
      }
    }
    if (endDateMoment.isBefore(rtnDateList[rtnDateList.length - 1])) {
      rtnDateList.pop();
    }
  }

  if (rtnDateList.length && patInfoList) {
    // 指示期間の終了日が設定されている場合は一番未来日、設定されていない場合は一番過去日でスケジュール作成範囲内か判定
    const checkDate = endDate ? rtnDateList[rtnDateList.length - 1] : rtnDateList[0];
    checkSchDate(patInfoList, checkDate);
    if (store.getters[`${storePath}/getOutsideSchExtPatList`].length) {
      // スケジュール作成範囲外となる患者が存在する場合は日付リストを空にする
      rtnDateList.splice(0);
    }
  }

  return rtnDateList;
};
/**
 * 指定期間で月ごとに複数週の対象曜日の日付リストを作成
 * baseDayCountList：第n週の補足値の配列 (第1：0、第2:7、第3:14、第4:21)
 */
export const extractTargetDateJoined = (condition, baseDayCountList, patInfoList) => {
  const rtnDateList = [];
  baseDayCountList.forEach(baseDayCount => {
    rtnDateList.push(...extractTargetDate(condition, baseDayCount, patInfoList));
  });
  rtnDateList.sort();
  return rtnDateList;
};
/** 指定期間で月ごとの対象曜日の日付リストを作成(隔週) */
export const extractTargetDateBiweekly = (condition, patInfoList) => {
  const storePath = getStorePath();
  if (!storePath) return [];

  const { startDate, endDate, selectedDayOfWeek } = condition;
  const startDateMoment = moment(startDate);
  const endDateMoment = moment(endDate || getDefaultSchExtEndDate());
  const rtnDateList = [];

  // 開始日付を取得
  const firstDayWithWeek = startDateMoment.clone();
  const startDayWeek = firstDayWithWeek.format("E");
  if (startDayWeek <= selectedDayOfWeek) {
    firstDayWithWeek.add(selectedDayOfWeek - startDayWeek, "days");
  } else {
    firstDayWithWeek.add(7 - (startDayWeek - selectedDayOfWeek), "days");
  }
  // 隔週(14日毎)の日付を取得
  for (
    const dateWork = firstDayWithWeek.clone();
    dateWork.isSameOrBefore(endDateMoment, "days");
    dateWork.add(14, "days")
  ) {
    rtnDateList.push(dateWork.format("YYYYMMDD"));
  }

  if (rtnDateList.length && patInfoList) {
    // 指示期間の終了日が設定されている場合は一番未来日、設定されていない場合は一番過去日でスケジュール作成範囲内か判定
    const checkDate = endDate ? rtnDateList[rtnDateList.length - 1] : rtnDateList[0];
    checkSchDate(patInfoList, checkDate);
    if (store.getters[`${storePath}/getOutsideSchExtPatList`].length) {
      // スケジュール作成範囲外となる患者が存在する場合は日付リストを空にする
      rtnDateList.splice(0);
    }
  }

  return rtnDateList;
};

// 現在の画面判定用の画面名称
const RouterNames = Object.freeze({
  Exam: {
    List: "exam-request",
    Detail: "exam-request-detail",
  },
  Rad: {
    List: "rad-request",
    Detail: "rad-request-detail",
  },
});
/** 画面名から検査依頼一覧または検査依頼か判定する */
export const isExamRequest = routerName => Object.values(RouterNames.Exam).includes(routerName);
/** 画面名から一般撮影検査依頼一覧または一般撮影検査依頼か判定する */
export const isRadRequest = routerName => Object.values(RouterNames.Rad).includes(routerName);
/** 画面名から検査依頼一覧または一般撮影検査依頼一覧か判定する */
export const isRequestList = routerName => Object.values(RouterNames).map(names => names.List).includes(routerName);
/** 画面名から検査依頼または一般撮影検査依頼か判定する */
export const isRequestDetail = routerName => Object.values(RouterNames).map(names => names.Detail).includes(routerName);

export {
  // ons.notification.confirmでOKを選択した場合はtrueを返す形にするラッパー
  confirmIsOk,
} from "@/functions/common/OnsenFunctions";

/** 現在の画面検査依頼一覧または一般撮影検査依頼一覧で、依頼の編集状態があり、破棄確認でキャンセルされた場合はfalseを返す */
export const confirmAllowDiscardChangesInRequestList = async () => {
  const thisName = router.currentRoute.name;
  // 検査依頼一覧、一般撮影検査依頼一覧のいずれでもない場合は確認不要
  if (!isRequestList(thisName)) return true;
  const isExamRequestList = isExamRequest(thisName);
  const isRadRequestList = isRadRequest(thisName);
  const { getters, dispatch } = store;
  // 検査依頼、一般撮影検査依頼で編集状態がある場合以外は確認不要
  if (!(
    (isExamRequestList && getters["exam-request/list/getIsDataChanged"])
    || (isRadRequestList && getters["rad-request/list/getIsDataChanged"])
  )) return true;
  // 破棄確認を表示して結果を返す
  // title: "内容破棄",
  // message: "編集内容が破棄されます。</br>よろしいですか？",
  const isOK = await confirmIsOk(DIALOG_MESSAGES[13000004]);
  if (isOK) {
    // 破棄確認でOKの場合は編集状態をクリアしておく
    if (isExamRequestList) {
      await dispatch("exam-request/list/clearSearchedExamRequest");
    } else if (isRadRequestList) {
      await dispatch("rad-request/list/clearSearchedRadRequest");
    }
  }
  return isOK;
};

/** 現在の画面検査依頼または一般撮影検査依頼で、依頼の編集状態があり、破棄確認でキャンセルされた場合はfalseを返す */
export const confirmAllowDiscardChangesInRequestDetail = async () => {
  const thisName = router.currentRoute.name;
  // 検査依頼、一般撮影検査依頼のいずれでもない場合は確認不要
  if (!isRequestDetail(thisName)) return true;
  const isExamRequestDetail = isExamRequest(thisName);
  const isRadRequestDetail = isRadRequest(thisName);
  const { getters, dispatch, commit } = store;
  // 検査依頼、一般撮影検査依頼で編集状態がある場合以外は確認不要
  if (!(
    (isExamRequestDetail && getters["exam-request/list/getIsDataChanged"])
    || (isRadRequestDetail && getters["rad-request/list/getIsDataChanged"])
    || getters["pat-info/isPatInfoChaned"]
  )) return true;
  // 破棄確認を表示して結果を返す
  // title: "内容破棄",
  // message: "編集内容が破棄されます。</br>よろしいですか？",
  const isOK = await confirmIsOk(DIALOG_MESSAGES[13000004]);
  if (isOK) {
    // 破棄確認でOKの場合は編集状態をクリアしておく
    if (isExamRequestDetail) {
      await dispatch("exam-request/list/clearSearchedExamRequest");
    } else if (isRadRequestDetail) {
      await dispatch("rad-request/list/clearSearchedRadRequest");
    }
    commit("pat-info/setIsPatInfoChaned", false);
  }
  return isOK;
};

/** 指示者が選択が選択されていなければalertを表示してfalseを返す */
export const validateSelectDoctor = selectDoctor => {
  if (!selectDoctor) {
    // title: "必須項目未入力",
    // message: "{$1}は必須入力項目です。\n必ず値を入力してください。"
    const { title, message } = DIALOG_MESSAGES[22010001];
    ons.notification.alert({
      title,
      message: messageFormat(message, "指示者"),
    });
    return false;
  }
  return true;
};

/** 保存時の確認項目のダイアログを表示してキャンセルされた場合はfalseを返す */
export const confirmCheckResult = async checkResult => {
  if (checkResult.rtnDeadlineOverFlg) {
    // 締切データがある
    // title: "保存確認",
    // message: "検査部門の締め切り時間を過ぎている依頼があります。別途対応をお願いいたします。",
    if (!(await confirmIsOk(DIALOG_MESSAGES[13000032]))) return false;
  }
  if (checkResult.rtnNoTreatDateFlg) {
    // 透析予定がない日がある
    // title: "保存確認",
    // message: "登録内容に透析予定がない日が含まれます。よろしいですか？",
    if (!(await confirmIsOk(DIALOG_MESSAGES[13000033]))) return false;
  }
  return true;
};

/** 保存時のAPI処理待ちとその後の画面表示処理の呼び出しなどを行う（共通ローダー表示処理も含む） */
export const executeUploadTemplete = async (
  apiPromise,
  showCalendarFunc,
  fileName,
  methodName,
  // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
  messageDialogInfo,
  // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
) => {
  const { dispatch } = store;
  await dispatch("loading-screen/executeWithLoadingScreen", apiPromise.then(response => {

    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
    if (200 === response.status && 22020004 === response.data.msgCd) {
      messageDialogInfo.messageCd = 22020004;
      messageDialogInfo.type = "1";
      messageDialogInfo.isDialogVisible = true;
      this.finishLoadingScreen();
      return;
    }
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end

    // 予実リストの更新
    dispatch("indication-result/setResultUpdate", new Date());

    // title: "更新完了",
    // message: "更新が完了しました。"
    ons.notification.alert(DIALOG_MESSAGES["00100002"]);

    // 再表示
    showCalendarFunc();
  }).catch(error => {
    getErrorMessage(fileName, methodName, error);

    if (error?.response?.status === 400) {
      ons.notification.alert({
        // title: "更新失敗",
        title: DIALOG_MESSAGES["00300005"].title,
        message: error?.response?.data?.errorMessage,
      });
    }
  }));
};

// 検査区分
const OrderClass = Object.freeze({
  // 透析前
  Before: "1",
  // 透析後
  After: "2",
  // その他
  Other: "0",
});
// 依頼変更可否フラグ
export const LockFlag = Object.freeze({
  // 変更可（依頼締切前）
  Unlocked: "0",
  // 変更不可（依頼締切後）
  Locked: "1",
});
// レコード編集種別
export const Operation = Object.freeze({
  // 新規追加
  Create: 1,
  // アップデート
  Update: 2,
});
// セット使用区分
export const ExamSetClass = Object.freeze({
  // 両用
  Both: "0",
  // 依頼専用
  Request: "1",
  // 結果専用
  Result: "2",
  // 生理検査
  Ecg: "3",
});
// 血液検査/心電図
const PhyOrdClass = Object.freeze({
  // 心電図
  Ecg: "1",
});
// データ登録区分
const DataGenClass = Object.freeze({
  // クライアント
  Client: "0",
});
// 削除フラグ
export const DeleteFlag = Object.freeze({
  // 削除
  Delete: "1",
});

/** 保存用のデータ作成、チェック処理 */
export const checkAndCreateSaveExamData = selectDoctor => {
  const { getters } = store;

  // 検査セットリストの情報を取得
  const examSetNameList = getters["exam-request/list/getAllExamSetList"];
  // 生理検査セットのマスタ情報を取得
  const ecgExamSet = examSetNameList.filter(item => item.examSetClass === ExamSetClass.Ecg);
  // 指示者
  const indUserId = Number(selectDoctor);
  // スケジュール延長最終日取得用の患者情報リスト
  const patMainList = getters["exam-request/list/patMainList"];

  const result = {
    // 透析予定日がない日付が含まれているか
    rtnNoTreatDateFlg: false,
    // 締切日を過ぎた日付の編集が含まれているか
    rtnDeadlineOverFlg: false,
    // 保存APIに渡すデータ
    request: [],
  };

  // 検査依頼の既存データのリストから加工用データのリストを生成
  const saveExamRequestList = getters["exam-request/list/getSaveExamRequestList"];
  const saveExamRequestListClone = JSON.parse(JSON.stringify(saveExamRequestList));

  // 編集データから検査セット行だけを抽出する
  const examRequestListNoShap = getters["exam-request/list/getExamRequestListNoShap"];
  // mod #12462 患者情報共有 Ji start
  const facilityCd = getters["user/getFacilityCd"];

  const kensaObjList = examRequestListNoShap.filter(item => !item.headerflg && item.facilityCd === facilityCd);
  // mod #12462 患者情報共有 Ji end

  // 締切日確認に使用する日付
  const deadlineCondition = getters["exam-request/list/getDeadlineCondition"];
  const deadlineDate = deadlineCondition.deadlineFlg ? moment(getDeadlineDate(deadlineCondition)) : null;

  // 変更されたデータを集計する
  kensaObjList.forEach(kensaObj => {
    // 検査セットが登録されている日付を取得
    const examDateList = Object.keys(kensaObj.examData);
    // 処理対象の検査セットが生理検査セットか判定
    const examSetCd = Number(kensaObj.examSetCd);
    const isEcgExamSet = ecgExamSet.some(item => item.examSetCd === examSetCd);
    // 対象患者のスケジュール延長最終日を取得
    const schExtEndMinDateYyyymmdd = getSchExtEndDateWithPatMainList(patMainList, kensaObj.patId);
    const schExtEndMinDate = moment(schExtEndMinDateYyyymmdd, "YYYYMMDD");

    examDateList.forEach(examDate => {
      const dataType = kensaObj.examData[examDate];
      const isCancelData = dataType === CANCEL;
      const isAddData = dataType === ADD || dataType === ADD_WARNING;
      // 中止と追加のいずれでもない場合は処理しない
      if (!isCancelData && !isAddData) return;
      // スケジュール延長最終日より先の日付の追加は処理しない
      if (isAddData && schExtEndMinDate.isBefore(moment(examDate, "YYYYMMDD"))) return;

      // 処理対象のレコードデータを取得する
      const record = selectOrCreateExamRecord(
        saveExamRequestListClone,
        kensaObj,
        examDate,
        isCancelData,
        isEcgExamSet
      );

      // 依頼変更可否フラグ
      if (deadlineDate) {
        // （中止もしくは追加で）締切確認が有効な場合
        if (deadlineDate.isAfter(moment(examDate, "YYYYMMDD"))) {
          record.isLock = LockFlag.Locked;
          result.rtnDeadlineOverFlg = true;
        }
      }
      // 指示者
      record.indUserId = indUserId;

      if (isCancelData) {
        // 中止操作データの場合

        // 検査依頼セット情報（order_exam_set_info）から中止対象の検査セットを除外
        const orderExamSetInfo = JSON.parse(record.orderExamSetInfo);
        // 中止対象の検査セットに対応するNo
        let targetNo = 0;
        const filteredSetInfo = [];
        orderExamSetInfo.forEach(info => {
          if (info.set_cd !== examSetCd) {
            filteredSetInfo.push(info);
          } else {
            //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
            //targetNo = info.no;
            targetNo = info.set_cd;
            //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
          }
        });
        record.orderExamSetInfo = JSON.stringify(filteredSetInfo);

        // 検査依頼情報（exam_order_info）から中止対象の検査セットの項目を除外
        const examOrderInfo = JSON.parse(record.examOrderInfo);
        //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
        //const filteredOrderInfo = examOrderInfo.filter(info => info.no !== targetNo);
        const filteredOrderInfo = examOrderInfo.filter(info => info.set_cd !== targetNo);
        //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
        record.examOrderInfo = JSON.stringify(filteredOrderInfo);

        // ラベル情報（order_label_info）をorder_exam_set_infoから作り直す
        const orderLabelInfo = [];
        filteredSetInfo.forEach(info => {
          // 検査セットからラベル情報を取得する
          const examSetObj = examSetNameList.find(item => item.examSetCd === info.set_cd);
          const examSetLabelInfo = JSON.parse(examSetObj.labelInfo) || [];
          // ラベル情報に追加
          addLabelInfo(examSetLabelInfo, orderLabelInfo);
        });
        record.orderLabelInfo = JSON.stringify(orderLabelInfo);
      } else if (isAddData) {
        // 追加操作データの場合

        // 警告を表示するフラグ
        if (dataType === ADD_WARNING) {
          result.rtnNoTreatDateFlg = true;
        }

        // 検査セットリストのデータから、該当の検査セットのデータを取得する
        const examSetObj = examSetNameList.find(
          item => item.examSetCd === examSetCd
        );
        // 検査セットから検査依頼、ラベル情報を取得する
        const examSetItemInfo = JSON.parse(examSetObj.examItemInfo);
        const examSetLabelInfo = JSON.parse(examSetObj.labelInfo) || [];

        // 検査依頼セット情報（order_exam_set_info）に対象の検査セットを追加
        const orderExamSetInfo = JSON.parse(record.orderExamSetInfo) || [];
        //del 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
        //const targetNo = Math.max(0, ...orderExamSetInfo.map(info => info.no)) + 1;
        //del 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
        orderExamSetInfo.push({
          //del 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
          //no: targetNo,
          //del 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
          set_cd: examSetCd,
          set_name: kensaObj.examSetName,
        });
        record.orderExamSetInfo = JSON.stringify(orderExamSetInfo);

        // 検査依頼情報（exam_order_info）に対象の検査セットの項目を追加
        const examOrderInfo = JSON.parse(record.examOrderInfo);
        examSetItemInfo.forEach(item => {
          examOrderInfo.push({
            //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
            //no: targetNo,
            set_cd: examSetCd,
            //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
            item_cd: item.exam_item_cd,
            item_name: item.exam_item_name,
          });
        });
        record.examOrderInfo = JSON.stringify(examOrderInfo);

        // ラベル情報（order_label_info）に対象の検査セットの項目を追加
        const orderLabelInfo = JSON.parse(record.orderLabelInfo);
        addLabelInfo(examSetLabelInfo, orderLabelInfo);
        record.orderLabelInfo = JSON.stringify(orderLabelInfo);
      }
    });
  });

  const rtnSaveExamRequestList = result.request;
  // operation要素のあるもののみ抽出
  saveExamRequestListClone.forEach(item => {
    if (item.operation !== undefined) {
      item.regExamDate = item.strExamDate;
      if (!JSON.parse(item.orderExamSetInfo).length) {
        item.isDel = DeleteFlag.Delete;
      }
      rtnSaveExamRequestList.push(item);
    }
  });
  return result;
};

// 既存レコードのデータを取得する、もしくは新規レコードのデータを追加する
export const selectOrCreateExamRecord = (
  saveExamRequestListClone,
  kensaObj,
  examDate,
  isCancelData,
  isEcgExamSet
) => {
  // add #12462 患者情報共有 Ji start
  const { getters } = store;
  const facilityCd = getters["user/getFacilityCd"];
  // add #12462 患者情報共有 Ji end
  const patId = kensaObj.patId;
  const regOrderClass = kensaObj.regOrderClass;
  const examSetCd = Number(kensaObj.examSetCd);
  // 患者ID、検査日、検査区分が一致する既存レコードのデータを取得する
  const recordList = saveExamRequestListClone.filter(item => (
    item.patId === patId
    && item.strExamDate === examDate
    && item.regOrderClass === regOrderClass
  ));

  let record = null;
  if (
    isCancelData
    || regOrderClass === OrderClass.Other
    || isEcgExamSet
  ) {
    // 中止処理、もしくは1セット1レコードとする条件
    // （検査区分がその他、または検査セット区分が生理検査の検査セット）の場合
    // 処理対象の検査セットを持つ既存レコードのデータを検索する
    record = recordList.find(item => {
      const orderExamSetInfo = JSON.parse(item.orderExamSetInfo);
      if (!orderExamSetInfo?.length) return false;
      return orderExamSetInfo.some(info => info.set_cd === examSetCd);
    });
  } else {
    // 心電図検査以外の既存レコードのデータを取得する
    // mod #12462 患者情報共有 Ji start
    record = recordList.find(item => item.phyOrdClass !== PhyOrdClass.Ecg && item.facilityCd == facilityCd);
    // mod #12462 患者情報共有 Ji end
  }

  if (record) {
    // 既存レコードのデータが取得されている場合
    if (record.operation !== Operation.Create) {
      // 新規追加レコードでない場合
      // アップデート対象にする
      record.operation = Operation.Update;
    }
  } else {
    // 既存レコードのデータが取得されていない場合
    // 新規レコードのデータを追加する
    record = {
      patId,
      regExamDate: examDate,
      regOrderClass,
      orderExamSetInfo: "[]",
      examOrderInfo: "[]",
      orderLabelInfo: "[]",
      dataGenClass: DataGenClass.Client,
      isLock: LockFlag.Unlocked,
      indUserId: null,
      strExamDate: examDate,
      operation: Operation.Create,
    };
    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
    if (isEcgExamSet) {
      record.phyOrdClass = PhyOrdClass.Ecg;
    }
    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
    saveExamRequestListClone.push(record);
  }
  return record;
};

// ラベル情報の追加処理を行う
export const addLabelInfo = (examSetLabelInfo, orderLabelInfo) => {
  examSetLabelInfo.forEach(item => {
    // 同じspitz_cdのデータがあるか確認
    if (!orderLabelInfo.some(labelInfo => labelInfo.spitz_cd === item.spitz_cd)) {
      // 既存データが無ければ追加
      orderLabelInfo.push({ spitz_cd: item.spitz_cd });
    }
  });
};

/** 保存用のデータ作成、チェック処理 */
export const checkAndCreateSaveRadData = selectDoctor => {
  const { getters } = store;

  // 指示者
  const indUserId = Number(selectDoctor);
  // スケジュール延長最終日取得用の患者情報リスト
  const patMainList = getters["exam-request/list/patMainList"];

  const result = {
    // 透析予定日がない日付が含まれているか
    rtnNoTreatDateFlg: false,
    // 締切日を過ぎた日付の編集が含まれているか
    rtnDeadlineOverFlg: false,
    // 保存APIに渡すデータ
    request: [],
  };

  // 一般撮影検査依頼の既存データのリストから加工用データのリストを生成
  const saveRadRequestList = getters["rad-request/list/getSaveRadRequestList"];
  const saveRadRequestListClone = JSON.parse(JSON.stringify(saveRadRequestList));

  // 編集データから検査セット行だけを抽出する
  const radRequestListNoShap = getters["rad-request/list/getRadRequestListNoShap"];
  const kensaObjList = radRequestListNoShap.filter(item => !item.headerflg);

  // 締切日確認に使用する日付
  const deadlineCondition = getters["rad-request/list/getDeadlineCondition"];
  const deadlineDate = deadlineCondition.deadlineFlg ? moment(getDeadlineDate(deadlineCondition)) : null;

  // 変更されたデータを集計する
  kensaObjList.forEach(kensaObj => {
    // 検査セットが登録されている日付を取得
    const radDateTimeList = Object.keys(kensaObj.radDataDetail);
    const radSetCd = Number(kensaObj.radSetCd);
    // 対象患者のスケジュール延長最終日を取得
    const schExtEndMinDateYyyymmdd = getSchExtEndDateWithPatMainList(patMainList, kensaObj.patId);
    const schExtEndMinDate = moment(schExtEndMinDateYyyymmdd, "YYYYMMDD");

    radDateTimeList.forEach(radDateTime => {
      const [radDate, radTime] = radDateTime.split("_");
      const dataType = kensaObj.radDataDetail[radDateTime];
      const isCancelData = dataType === CANCEL;
      const isAddData = dataType === ADD || dataType === ADD_WARNING;
      // 中止と追加のいずれでもない場合は処理しない
      if (!isCancelData && !isAddData) return;
      // スケジュール延長最終日より先の日付の追加は処理しない
      if (isAddData && schExtEndMinDate.isBefore(moment(radDate, "YYYYMMDD"))) return;

      // 処理対象のレコードデータを取得する
      const record = selectOrCreateRadRecord(
        saveRadRequestListClone,
        kensaObj,
        radDate,
        radTime,
        isCancelData
      );

      // 依頼変更可否フラグ
      if (deadlineDate) {
        // （中止もしくは追加で）締切確認が有効な場合
        if (deadlineDate.isAfter(moment(radDate, "YYYYMMDD"))) {
          record.isLock = LockFlag.Locked;
          result.rtnDeadlineOverFlg = true;
        }
      }
      // 指示者
      record.indUserId = indUserId;

      if (isCancelData) {
        // 中止操作データの場合

        // 放射線検査依頼セット情報（order_rad_set_info）から中止対象の検査セットを除外
        const orderRadSetInfo = JSON.parse(record.orderRadSetInfo);
        // 該当の検査セットを除外
        const filteredSet = orderRadSetInfo.filter(
          info => info.rad_set_cd !== radSetCd
        );
        record.orderRadSetInfo = JSON.stringify(filteredSet);
      } else if (isAddData) {
        // 追加操作データの場合

        // 警告を表示するフラグ
        if (dataType === ADD_WARNING) {
          result.rtnNoTreatDateFlg = true;
        }

        // 放射線検査依頼セット情報（order_rad_set_info）に対象の検査セットを追加
        const orderRadSetInfo = JSON.parse(record.orderRadSetInfo) || [];
        const targetNo = Math.max(0, ...orderRadSetInfo.map(info => info.no)) + 1;
        orderRadSetInfo.push({
          no: targetNo,
          rad_set_cd: radSetCd,
          rad_set_name: kensaObj.radSetName,
        });
        record.orderRadSetInfo = JSON.stringify(orderRadSetInfo);
      }
    });
  });

  const rtnSaveRadRequestList = result.request;
  // operation要素のあるもののみ抽出
  saveRadRequestListClone.forEach(item => {
    if (item.operation !== undefined) {
      item.regRadDate = item.strRadDate;
      if (!JSON.parse(item.orderRadSetInfo).length) {
        item.isDel = DeleteFlag.Delete;
      }
      rtnSaveRadRequestList.push(item);
    }
  });
  return result;
};


// 既存レコードのデータを取得する、もしくは新規レコードのデータを追加する
const selectOrCreateRadRecord = (
  saveRadRequestListClone,
  kensaObj,
  radDate,
  radTime,
  isCancelData
) => {
  const patId = kensaObj.patId;
  const regOrderClass = kensaObj.regOrderClass;

  let record = null;
  if (isCancelData) {
    // 中止処理の場合
    const radSetCd = Number(kensaObj.radSetCd);
    // 患者ID、検査日、検査時刻、検査区分が一致し、
    // 処理対象の検査セットを持つ既存レコードのデータを検索する
    record = saveRadRequestListClone.find(item => {
      if (
        item.patId !== patId
        || item.strRadDate !== radDate
        || item.strRadTime !== radTime
        || item.regOrderClass !== regOrderClass
      ) return false;
      const orderRadSetInfo = JSON.parse(item.orderRadSetInfo);
      if (!orderRadSetInfo?.length) return false;
      return orderRadSetInfo.some(info => info.rad_set_cd === radSetCd);
    });
  }
  // 仕様メモ：
  // 一般撮影検査依頼の場合は常に1セット1レコードとするため
  // 中止処理以外（＝追加処理）では既存レコードを更新することはない

  if (record) {
    // 既存レコードのデータが取得されている場合
    if (record.operation !== Operation.Create) {
      // 新規追加レコードでない場合
      // アップデート対象にする
      record.operation = Operation.Update;
    }
  } else {
    // 既存レコードのデータが取得されていない場合
    // 新規レコードのデータを追加する
    record = {
      patId,
      regRadDate: radDate,
      regOrderClass,
      orderRadSetInfo: "[]",
      dataGenClass: DataGenClass.Client,
      isLock: LockFlag.Unlocked,
      indUserId: null,
      strRadDate: radDate,
      strRadTime: radTime,
      operation: Operation.Create,
    };
    saveRadRequestListClone.push(record);
  }
  return record;
};

/** 一覧画面のセル緑色表示情報用のキー生成関数：日付 */
export const makeRequestHeaderKey = (patId, setDate) => `rh_${patId}_${setDate}`;
/** 一覧画面のセル緑色表示情報用のキー生成関数：検査セット・検査区分・日付 */
export const makeRequestSetKey = (patId, setCd, regOrderClass, setDate) => `rs_${patId}_${setCd}_${regOrderClass}_${setDate}`;
/** 一覧画面のセル緑色表示情報用のキー生成関数：パターン種別・曜日 */
export const makePatternHeaderKey = (patId, pattern, week) => `ph_${patId}_${pattern}_${week}`;
/** 一覧画面のセル緑色表示情報用のキー生成関数：検査セット・検査区分・パターン種別・曜日 */
export const makePatternSetKey = (patId, setCd, regOrderClass, pattern, week) => `ps_${patId}_${setCd}_${regOrderClass}_${pattern}_${week}`;

/**
 * ObjectのArrayのsortで使用するコンパレーター関数を生成する
 * （降順には未対応）
 */
export const createSortComparator = sortKeys => ((a, b) => {
  const keys = [...sortKeys];
  while (keys.length) {
    const key = keys.shift();
    if (a[key] > b[key]) {
      return 1;
    } else if (a[key] < b[key]) {
      return -1;
    }
  }
  return 0;
});

/** 検査パターンと患者ID、曜日が一致する治療パターンがあるか判定する */
export const hasTreatmentPatternOnWeek = (requestPattern, selectedPatId = null) => {
  const storePath = getStorePath();
  if (!storePath) return false;
  const weekName = selectValueByExamOrRad("examWeek", "radWeek");
  // mod #12462 患者情報共有 Ji start
  // const patId = selectedPatId || (requestPattern.patId ? Number(requestPattern.patId) : null);
  let matchPatId = selectedPatId;

  if (!matchPatId) {
    if (requestPattern.matchPatId) {
      matchPatId = Number(requestPattern.matchPatId);
    } else if (requestPattern.ownPatId) {
      matchPatId = Number(requestPattern.ownPatId);
    } else if (requestPattern.patId) {
      matchPatId = Number(requestPattern.patId);
    }
  }
  const requestWeek = requestPattern[weekName] ? Number(requestPattern[weekName]) : null;
  // if (!patId || !requestWeek) return false;
  if (!matchPatId || !requestWeek) return false;

  const treatmentPatternList = store.getters[`${storePath}/getPatTreatmentPatternList`];
  return treatmentPatternList.some(treatmentPattern => (
    (
      treatmentPattern.ownPatId
        ? matchPatId === Number(treatmentPattern.ownPatId)
        : matchPatId === Number(treatmentPattern.patId)
    ) &&
    requestWeek === treatmentPattern.treatWeek
  ));
  // mod #12462 患者情報共有 Ji end
};

/** router.currentRoute.nameから検査依頼用もしくは一般撮影検査依頼用の値を返す */
export const selectValueByExamOrRad = (examValue, radValue, defaultValue = null) => {
  const currentName = router.currentRoute.name;
  if (isExamRequest(currentName)) return examValue;
  if (isRadRequest(currentName)) return radValue;
  return defaultValue;
};
/** router.currentRoute.nameから検査依頼用もしくは一般撮影検査依頼用のストアパスを返す */
export const getStorePath = () => {
  const routeName = router.currentRoute.name;
  const examRequestPath =
    routeName === 'exam-request-detail'                          // NOTE: 検査依頼詳細の場合、listのStore参照
      ? 'exam-request/list'
      : store.getters['exam-request/daily/getPeriodType'] === 1  // NOTE: 検査依頼一覧の場合、表示区分に応じたStore参照
        ? 'exam-request/list'
        : 'exam-request/daily';
  return selectValueByExamOrRad(examRequestPath, "rad-request/list");
};

/** 検査日または無期限パターンに対する治療予定があるか判定する */
export const hasScheduleTreatment = (dateItem, selectedPatId) => {
  switch (dateItem.columnType) {
    case ColumnType.Date: {
      // 検査日付データの場合
      const dateYyyymmdd = moment(dateItem.date).format("YYYYMMDD");
      return hasScheduleOnTargetDate(selectedPatId, dateYyyymmdd);
    }
    case ColumnType.Pattern: {
      // 無期限パターンデータの場合
      return hasTreatmentPatternOnWeek(dateItem.setData, selectedPatId);
    }
  }
  return false;
};

/** 指定の患者と日付で透析予定があるか確認 */
export const hasScheduleOnTargetDate = (patId, dateYyyymmdd) => {
  const storePath = getStorePath();
  if (!storePath) return false;

  const ordMainTreatDateList = store.getters[`${storePath}/getOrdMainTreatDateList`];
  const treatDateList = ordMainTreatDateList.find(item => item.pat_id === patId)?.treat_date;
  if (!treatDateList) return false;

  return treatDateList.includes(dateYyyymmdd);
};

/** 検査依頼の日付列の表示用データを生成 */
export const getExamCellImgAttributesByDate = (celObj, setDate) => {
  const imgAttrs = {
    src: "",
    class: "",
    style: "",
  };
  const isLockFlg = celObj.examStatus[setDate] === "1" || celObj.nowIsLock[setDate] === "1";
  const hasSchedle = FILLCOLOR_HAS_SCHEDULE + "!important";
  const hasNotSchedle = FILLCOLOR_HAS_NOT_SCHEDULE + "!important";
  // add #12462 患者情報共有 Ji start
  const patId = celObj.ownPatId ? celObj.ownPatId : celObj.patId
  // add #12462 患者情報共有 Ji end
  switch (celObj.examData[setDate]) {
    case CANCEL:
      // 予定有無を判別して画像を変える
      // mod #12462 患者情報共有 Ji start
      // if (hasScheduleOnTargetDate(celObj.patId, setDate)) {
      if (hasScheduleOnTargetDate(patId, setDate)) {
      // mod #12462 患者情報共有 Ji end
        Object.assign(imgAttrs, {
          src: "img/exam-request/32-32_0.png",
          class: "symbol-request-cancel td-img",
        });
      } else {
        Object.assign(imgAttrs, {
          src: "img/exam-request/32-32_4.png",
          class: "symbol-request-cancel td-img",
        });
      }
      break;
    case SAVED:
      // 予定有無を判別して画像を変える
      // mod #12462 患者情報共有 Ji start
      // if (hasScheduleOnTargetDate(celObj.patId, setDate)) {
      if (hasScheduleOnTargetDate(patId, setDate)) {
      // mod #12462 患者情報共有 Ji end
        Object.assign(imgAttrs, {
          src: "img/exam-request/32-32_2.png",
          class: "symbol-request-saved td-img",
          style: `background-color: ${isLockFlg ? hasSchedle : FILLCOLOR_DEFAULT}`,
        });
      } else {
        Object.assign(imgAttrs, {
          src: "img/exam-request/32-32_3.png",
          class: "symbol-request-saved td-img",
          style: `background-color: ${isLockFlg ? hasNotSchedle : FILLCOLOR_DEFAULT}`,
        });
      }
      break;
    case ADD:
      Object.assign(imgAttrs, {
        src: "img/exam-request/32-32_2.png",
        class: "symbol-request-unsaved td-img",
        style: `background-color: ${isLockFlg ? hasSchedle : FILLCOLOR_DEFAULT}`,
      });
      break;
    case ADD_WARNING:
      Object.assign(imgAttrs, {
        src: "img/exam-request/32-32_3.png",
        class: "symbol-request-noplan td-img",
        style: `background-color: ${isLockFlg ? hasNotSchedle : FILLCOLOR_DEFAULT}`,
      });
      break;
  }
  return imgAttrs;
};

/**
 * getExamDateList,getExamDateListDetail,getRadDateList,getRadDateListDetailで設定する
 * 検査日付/検査日時データか無期限パターンデータかの判定用区分
 */
export const ColumnType = Object.freeze({
  // ダミーデータ
  Dummy: 0,
  // 検査日付/検査日時データ
  Date: 1,
  // 無期限パターンデータ
  Pattern: 2,
});
/** getExamDateList,getExamDateListDetail,getRadDateList,getRadDateListDetailで使用するダミーデータ */
export const DummyDateItem = Object.freeze({
  date: "",
  dateFormat: "",
  columnType: ColumnType.Dummy,
  setData: {},
});

/**
 * getExamDateList,getExamDateListDetail,getRadDateList,getRadDateListDetailで使用する
 * 検査日付/検査日時データを生成する
 */
export const createDateItem = (yyyymmdd, isDetail = false, hh_mm = "") => {
  const dateMoment = moment(yyyymmdd);
  const dateString = dateMoment.format(isDetail ? "YYYY/M/D(ddd)" : "M/D(ddd)");
  const timeString = (hh_mm && hh_mm !== "00:00") ? ` ${hh_mm}` : "";
  return {
    date: dateMoment.toDate(),
    dateFormat: `${dateString}${timeString}`,
    columnType: ColumnType.Date,
    setData: DummyDateItem.setData,
  };
};

/**
 * getExamDateList,getExamDateListDetail,getRadDateList,getRadDateListDetailで使用する
 * 無期限パターンデータを生成する
 */
export const createPatternItem = (patternInfo, intervalList, patternName, weekName, timeName = null) => {
  // radPatternDetailColumnList の要素のみAPIの実装上の問題により
  // radPattern と radWeek がStringになっているため
  // intervalListとの一致判定と曜日名称の添え字にはNumberに変換して使用する
  const patternId = Number(patternInfo[patternName]);
  const intervalItem = intervalList.find(item => item.value === patternId);
  if (!intervalItem || !patternInfo[weekName]) return null;

  const setData = {
    [patternName]: patternInfo[patternName],
    [weekName]: patternInfo[weekName],
  };
  if (timeName) {
    setData[timeName] = patternInfo[timeName];
  }
  const weekId = Number(patternInfo[weekName]);
  const weekString = ["", "月", "火", "水", "木", "金", "土", "日"][weekId];
  const timeString = (timeName && patternInfo[timeName] !== "00:00") ? ` ${patternInfo[timeName]}` : "";
  return {
    date: DummyDateItem.date,
    dateFormat: `${intervalItem.name}(${weekString})${timeString}`,
    columnType: ColumnType.Pattern,
    setData,
  };
};

/** 検査セットコード配列を表示順辞書を使用してソートする */
export const sortSetCdList = (setCdList, setOrderMap) => {
  setCdList.sort((setCdA, setCdB) => {
    if (setOrderMap[setCdA] && setOrderMap[setCdB]) {
      return setOrderMap[setCdA] - setOrderMap[setCdB];
    } else if (setOrderMap[setCdA]) {
      return -1;
    } else if (setOrderMap[setCdB]) {
      return 1;
    }
    return Number(setCdA) - Number(setCdB);
  });
  return setCdList;
};

/** 保存済みの表示期間をv-model用の情報に反映する */
export const setShowDateToCondition = (condition, startToEndDate) => {
  [
    condition.startDate,
    condition.endDate
  ] = [
    startToEndDate.showStartDate,
    startToEndDate.showEndDate
  ].map(normalizeDateForInput);
};
/** nullもしくは日付文字列などを日付入力欄のvalueやv-model用の文字列にする */
export const normalizeDateForInput = value => !value ? "" : formatToInputDate(value);

/** momentコンストラクタの引数を受け取ってYYYYMMDDの文字列で返す */
export const formatToYyyymmdd = (...args) => moment(...args).format("YYYYMMDD");
/** momentコンストラクタの引数を受け取ってYYYY-MM-DDの文字列で返す */
export const formatToInputDate = (...args) => moment(...args).format(INPUT_DATE_FORMAT);

// 権限がなければメッセージを表示する関数
const checkAuthorized = (authorized, functionName) => {
  if (!authorized) {
    // title: "権限エラー",
    // message: "{functionName}を操作する権限がありません。管理者に確認してください。"
    const { title, message } = DIALOG_MESSAGES[12000315];
    ons.notification.alert({
      title,
      message: messageFormat(message, functionName),
    });
  }
  return authorized;
};
/** 検査依頼の編集権限があるか判定する */
export const getExamAuthorized = () => getAuthorized("ExamRequest", "default_authority");
/** 検査依頼の編集権限があるか判定する（権限がなければメッセージを表示する） */
export const checkExamAuthorized = () => checkAuthorized(getExamAuthorized(), "検査依頼");
/** 一般撮影検査依頼の編集権限があるか判定する */
export const getRadAuthorized = () => getAuthorized("RadRequest", "default_authority");
/** 一般撮影検査依頼の編集権限があるか判定する（権限がなければメッセージを表示する） */
export const checkRadAuthorized = () => checkAuthorized(getRadAuthorized(), "一般撮影検査依頼");

/** 検査間隔の各種判定結果を持つオブジェクトを返す */
export const checkIntervalState = interval => {
  const isDateOnce = interval === IntervalValues.SelectDateOnce;
  const isMultiDays = interval === IntervalValues.MultiDaysOfYear;
  return {
    /** 指定日1回分 */
    isDateOnce,
    /** 年間複数日 */
    isMultiDays,
    /** 曜日指定と指示期間終了日が有効（指定日1回分と年間複数日のいずれでもない） */
    isWeekRepeat: !isDateOnce && !isMultiDays,
  };
};

/** 簡易モードの場合はヘッダのみに絞る */
const filterHeaderIfNeeded = list => {
  const storePath = getStorePath();
  if (!storePath) return false;
  const [moduleName, submoduleName] = storePath.split("/");
  
  const showDetailsDisplay = store.state[moduleName][submoduleName].showDetailsDisplay;
  return !showDetailsDisplay
    ? list.filter(item => item.headerflg)
    : list;
};

/** 患者ID / 患者名 / 血糖検査 でソート */
const sortByPatientFields = (list, sortKey, isAsc) => {
  // リストをpat_idでグループ化
  const sortedGroups = groupBy(list, item => item.patId);

  sortedGroups.sort((groupA, groupB) => {
    const a = groupA.find(i => i.headerflg) || groupA[0];
    const b = groupB.find(i => i.headerflg) || groupB[0];

    // 共通関数でソート
    return sortableCompare(a, b, sortKey, isAsc, {
      reverseFields: ["is_blood_suger_exam"]  // reverseFields: 指定の項目は逆順扱い
    });
  });
  return sortedGroups.flat();
}

/** 日付列のソート */
const sortByDate = (list, sortKey, isAsc) => {
  // リストをpat_idでグループ化
  const sortedGroups = groupBy(list, item => item.patId);
  
  const dataName = selectValueByExamOrRad("examData", "radData");
  
  sortedGroups.sort((groupA, groupB) => {
    const headerA = groupA.find(i => i.headerflg);
    const headerB = groupB.find(i => i.headerflg);
    const valueA = headerA[dataName][sortKey];
    const valueB = headerB[dataName][sortKey];

    // 検査件数で比較（多い方を前に）
    if (valueA !== valueB) return isAsc ? valueB - valueA : valueA - valueB;

    // 検査件数が同じ場合、examData[sortKey] === CANCEL（×）の件数で比較（多い方を前に）
    const countZero = (group) =>
      group.filter(i => i[dataName]?.[sortKey] === CANCEL).length;

    return isAsc
      ? countZero(groupB) - countZero(groupA)
      : countZero(groupA) - countZero(groupB);
  });
  return sortedGroups.flat();
}

/** 検査パターン列のソート */
const sortByPattern = (
  list,
  key1,
  key2,
  isAsc,
  getPatRowCellNumber,
  getPatternFiltered,
) => {
  
  const patternName = selectValueByExamOrRad("examPattern", "radPattern");
  const weekName = selectValueByExamOrRad("examWeek", "radWeek");
  const cellObjSetCdName = selectValueByExamOrRad("examSetCd", "radSetCd");
  const filteredSetCdName = selectValueByExamOrRad("orderExamSetCd", "orderRadSetCd");
    
  const setData = {
    [patternName]: Number(key1),
    [weekName]: Number(key2)
  };
  // リストをpat_idでグループ化
  const sortedGroups = groupBy(list, item => item.patId);

  sortedGroups.sort((groupA, groupB) => {
    const headerA = groupA.find(i => i.headerflg);
    const headerB = groupB.find(i => i.headerflg);

    // 該当する検査パターンのセル数で比較（多い方を前に）
    const patternCount = i =>
      i?.headerflg ? getPatRowCellNumber(i, setData) ?? 0 : 0;

    const valueA = patternCount(headerA);
    const valueB = patternCount(headerB);

    if (valueA !== valueB) {
      return isAsc ? valueB - valueA : valueA - valueB;
    }

    // パターン数が同じ場合：status = CANCEL の件数で比較（多い方を前に）
    const countCancel = group =>
      group.reduce((count, i) => {
        const filtered = getPatternFiltered(i, setData, true)
          .filter(p =>
            Number(p[filteredSetCdName]) === Number(i[cellObjSetCdName]) &&
            String(p.regOrderClass) === String(i.regOrderClass) &&
            p.status === CANCEL
          );
        return count + filtered.length;
      }, 0);

    return isAsc
      ? countCancel(groupB) - countCancel(groupA)
      : countCancel(groupA) - countCancel(groupB);
  });
  return sortedGroups.flat();
}

/** ソート条件に従ってソート実施 */
/** - ソート後、簡易モードの場合はヘッダのみ抽出してリスト返却 */
export const sortList = (list, sort, getPatRowCellNumber, getPatternFiltered) => {
  const sortKey = sort.key;
  const isAsc = sort.isAsc;
  
  // ソート条件なしは元のリストを返す
  if (!sortKey) return filterHeaderIfNeeded(list);

  // key1: examPattern、key2: examWeek
  const [key1, key2] = sortKey.split(":");
  
  // 患者ID / 患者名 / 血糖検査のソート
  if (["hosp_pat_id", "pat_name", "is_blood_suger_exam"].includes(sortKey)) {
    return filterHeaderIfNeeded(
      sortByPatientFields(list, sortKey, isAsc)
    );
  }

  // 日付のソート
  if (key2 === undefined) {
    return filterHeaderIfNeeded(
      sortByDate(list, sortKey, isAsc)
    );
  }

  // 検査パターンのソート
  return filterHeaderIfNeeded(
    sortByPattern(
      list,
      key1,
      key2,
      isAsc,
      getPatRowCellNumber,
      getPatternFiltered
    )
  );  
}

/** moment(input) -> 無効なら今日 -> format(fmt) */
function formatOrToday(input, fmt) {
  const d = moment(input);
  const base = d.isValid() ? d : moment();
  return base.format(fmt);
}
/** 
 * NOTE: 検査予定日（日付項目）の形式について
 * (a) [YYYY-MM-DD]形式
 *  カレンダーの日付選択用のフォーマットで主にコンポーネント内部で使用する形式
 * (b) [YYYY/MM/DD]形式
 *  ・ヘッダの「検査予定日」表示形式
 *  ・検査依頼情報取得用（リクエストパラメータ）の形式
 * (c) [YYYYMMDD]形式
 *  検査依頼情報のキー項目で、データ加工・検査依頼保存時（登録・中止）に使用する形式
 */
export const toCalDate   = (input) => formatOrToday(input, INPUT_DATE_FORMAT);
export const toSlashDate = (input) => formatOrToday(input, SLASH_DATE_FORMAT);
export const toKeyDate   = (input) => formatOrToday(input, NO_SEP_DATE_FORMAT);
