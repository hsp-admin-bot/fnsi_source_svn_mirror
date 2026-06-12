/**
 * 検査依頼一覧(一日)用ストア
 */
import dayjs from "@/compat/date/dayjs";
import { sendRequestPatExamMain } from "@/apis/exam-request";
import { getDeadlineDate } from "@/functions/common/DateTimeUtils";
import { sortSetCdList, toKeyDate } from "@/functions/exam-request/ExamRequestFunctions";
import { SAVED, RegOrderClassTextSet } from "@/constants/examRequestConstants";

/****************************************************************************/
// helper function
/****************************************************************************/
/** 横軸の日付リストと編集状態リストを生成する処理 */
function createDateLists(examDateList) {
  const dateList = {};
  const editDateList = {};
  examDateList.forEach(date => {
    dateList[date] = 0;
    editDateList[date] = 1;
  });
  return { dateList, editDateList };
}
/** 患者IDごとに初期の検査依頼オブジェクトを生成する処理 */
function createInitialListObj(patIdList, dateList, editDateList) {
  return patIdList.map(patId => ({
    patId,
    data: { ...dateList },
    editStatus: { ...editDateList },
    examItemSet: { "1": {}, "2": {}, "0": {} },
  }));
}
/** 検査セットコードの重複を排除し、ユニークなセットコード一覧を取得する処理 */
function getUniqueSetCds(jsonObj, countKey, selectSetCd) {
  if (!selectSetCd[countKey]) selectSetCd[countKey] = {};
  const uniqueSetCds = [];
  jsonObj.forEach(obj => {
    if (!selectSetCd[countKey][obj.set_cd]) {
      selectSetCd[countKey][obj.set_cd] = true;
      uniqueSetCds.push(obj.set_cd);
    }
  });
  return uniqueSetCds;
}
/** 検査セットが未定義の場合に初期化し、既存または新規のセットオブジェクトを返す処理 */
function getOrCreateSet(examItemSet, orderClass, setCd, setName) {
  if (!examItemSet[orderClass][setCd]) {
    examItemSet[orderClass][setCd] = {
      name: setName,
      data: {},
      status: {},
      isLock: {},
    };
  }
  return examItemSet[orderClass][setCd];
}

export default {
  strict: true,
  namespaced: true,
  state: {
    periodType: NaN,               // [期間/一日]切替区分
    condition: null,               // 検索条件
    defaultCondition: null,        // デフォルト検索条件
    isDataChanged: false,          // 変更フラグ
    mstExamSetList: null,          // 検査セット一覧
    orgPatExamMains: [],           // リクエストパラメータ生成用検査依頼リスト
    ordMainTreatDateList: [],      // 患者毎の透析予約日リスト
    editExamRequestList: [],       // レスポンスデータ検査依頼リスト
  },
  mutations: {
    /** [期間/一日]切替区分 */
    setPeriodType(state, value) {
      state.periodType = value;
    },
    /** 検索条件 */ 
    setCondition(state, condition) {
      state.condition = condition;
    },
    /** デフォルト検索条件 */
    setDefaultCondition(state, defaultCondition) {
      state.defaultCondition = defaultCondition;
    },
    /** 変更フラグ */
    setIsDataChanged(state, isDataChanged) {
      state.isDataChanged = isDataChanged;
    },
    // 検査セット一覧
    setMstExamSetList(state, data) {
      state.mstExamSetList = data;
    },
    // リクエストパラメータ生成用検査依頼リスト 
    setOrgPatExamMains(state, orgPatExamMains) {
      state.orgPatExamMains = orgPatExamMains;
    },
    // 患者毎の透析予約日リスト
    setOrdMainTreatDateList(state, jsonList) {
      state.ordMainTreatDateList = jsonList;
    },
    // レスポンスデータ検査依頼リスト
    setEditExamRequestList(state, editExamRequestList) {
      state.editExamRequestList = editExamRequestList;
    },
  },
  getters: {
    /** [期間/一日]切替区分 */
    getPeriodType(state) {
      return state.periodType;
    },
    /** 検索条件 */ 
    getCondition(state) {
      return state.condition;
    },
    /** デフォルト検索条件 */
    getDefaultCondition(state) {
      return state.defaultCondition;
    },
    /** 変更フラグ */
    getIsDataChanged(state) {
      return state.isDataChanged;
    },
    // 患者毎の透析予約日リスト
    getOrdMainTreatDateList(state) {
      return state.ordMainTreatDateList;
    },
    /** リクエストパラメータ生成用 検査依頼リスト 取得 */
    getOrgPatExamMains(state) {
      return state.orgPatExamMains;
    },
    /** 検査セット一覧 */
    getMstExamSetList(state) {
      return state.mstExamSetList;
    },
    /** ヘッダ検査セットリスト 取得
     * 表示条件：
     * (1) 対象日付に検査依頼が存在する {examSetCd, orderClass} の組み合わせは必ず表示
     * (2) それ以外は、結果（examSetClass === "2"）・非表示（isDisp === "0"）を除外し、かつ検査区分（orderClass）が選択されているもののみ表示
     */
    getFilteredExamSetList(state) {
      const { condition, mstExamSetList = [], editExamRequestList } = state;
      /* 検査セット名リストが未取得なら空配列を返す */
      if (!Array.isArray(mstExamSetList)) return [];
      /* 検査区分（orderClass）の選択状態と対象日付を取得 */
      const examTypeList = condition?.examType?.length ? condition.examType : [];
      const targetDate = toKeyDate(condition?.scheduledDate);
      const orderClassOrder = RegOrderClassTextSet.map(item => item.value);
      /* 対象日付に検査依頼が存在するセットを抽出 */
      const usedSetPairs = new Set(); // "examSetCd|orderClass" 形式
      editExamRequestList?.forEach(req => {
        Object.entries(req.examItemSet || {}).forEach(([orderClass, sets]) => {
          Object.entries(sets || {}).forEach(([examSetCd, setObj]) => {
            if (setObj?.data?.[targetDate]) usedSetPairs.add(`${examSetCd}|${orderClass}`);
          });
        });
      });

      const resultList = [];
      /* 検査セットごとに表示対象を判定 */
      mstExamSetList.forEach(set => {
        const orderClassList = JSON.parse(set.orderClass || '[]'); // このセットが対応する検査区分一覧

        orderClassOrder.forEach(orderClass => {
          /** NOTE: 表示条件の内容でresultListに設定していく */
          if (
            (
              usedSetPairs.has(`${set.examSetCd}|${orderClass}`) // 対象日付に検査依頼が存在する組み合わせは必ず表示
              && examTypeList.includes(orderClass)             // 検索条件で選択された検査区分に該当する orderClass かどうか
            ) || (
              orderClassList.includes(orderClass)              // この検査セットがこの検査区分に対応しているか
              && set.examSetClass !== "2"                      // セット使用区分：「結果専用」は除外
              && set.isDisp !== "0"                            // 表示フラグ：非表示は除外
              && examTypeList.includes(orderClass)             // 検索条件で選択された検査区分に該当する orderClass かどうか
            )
          ) {
            const shortText = RegOrderClassTextSet.find(item => item.value === orderClass)?.shortText || "";
            resultList.push({
              examSetCd: set.examSetCd,
              examSetName: `${set.examSetName}${shortText}`,
              regOrderClass: orderClass
            });
          }
        });
      });
      return resultList;
    },
    /** 検査依頼リスト(画面表示用) */
    getSimplifiedExamList(state, getters, rootState, rootGetters) {
      const result = [];
      const { scheduledDate, examType, showScheduledOnly } = state.condition || {};
      const _editExamRequestList = state.editExamRequestList || [];
      const _ordMainTreatDateList = state.ordMainTreatDateList || [];
      const _scheduledDate = toKeyDate(scheduledDate); // NOTE: YYYY-MM-DD形式で設定されている場合があるため、YYYYMMDD形式に変換

      // 検査依頼編集リストを患者単位でループ処理
      _editExamRequestList.forEach(({ patId, examItemSet }) => {
        // scheduledDate に検査が1件でも存在するかを判定するフラグ
        let hasExamOnDate = false;
        // 検査区分ごとに検査セットを確認
        examType.forEach(regOrderClass => {
          const itemSet = examItemSet[regOrderClass];
          if (!itemSet) return; // 該当区分の検査セットが存在しない場合はスキップ
          const setCdList = Object.keys(itemSet);
          if (!setCdList.length) return; // 検査セットが空の場合はスキップ
          // 各検査セットに scheduledDate の検査があるか確認
          for (const examSetCd of setCdList) {
            const setObj = itemSet[examSetCd];
            if (setObj.data?.[_scheduledDate] != null) {
              hasExamOnDate = true;
              break; // 1件でも見つかれば判定終了
            }
          }
        });
        // 「予定ありのみ表示」モードで、検査がない場合
        if (showScheduledOnly && !hasExamOnDate) return;
        // 表示用の検査セット配列を初期化
        const examSets = [];
        // 検査区分ごとに検査セットを抽出・整形
        examType.forEach(regOrderClass => {
          const itemSet = examItemSet[regOrderClass];
          if (!itemSet) return;

          const setCdList = Object.keys(itemSet);
          if (!setCdList.length) return;
          // 検査セットコードの表示順を整える
          sortSetCdList(setCdList, rootGetters['exam-request/list/getSetOrderMap']);
          // 各検査セットを scheduledDate に絞って整形
          setCdList.forEach(examSetCd => {
            const setObj = itemSet[examSetCd];
            const hasExam = setObj.data?.[_scheduledDate] != null;
            if (!hasExam) return;

            examSets.push({
              examSetCd,
              examSetName: setObj.name,
              regOrderClass,
              reqKbn: SAVED,
              examStatus: setObj.status?.[_scheduledDate],
              isLock: setObj.isLock?.[_scheduledDate],
              hasTreatment: _ordMainTreatDateList.some(t => t.pat_id === patId && t.treat_date.includes(_scheduledDate)),
            });
          });
        });
        // 患者単位で検査セットをまとめて結果に追加
        result.push({ patId, examSets });
      });
      return result;
    },
  },
  actions: {
    /** [期間/一日]切替区分を更新する */
    setPeriodType({ commit }, value) {
      commit("setPeriodType", value);
    },
    /** 検索条件を更新する */
    setCondition({ commit }, condition) {
      commit("setCondition", JSON.parse(JSON.stringify(condition)));
    },
    /** デフォルト検索条件を更新する */
    setDefaultCondition({ commit }, defaultCondition) {
      commit("setDefaultCondition", JSON.parse(JSON.stringify(defaultCondition)));
    },
    /** 変更フラグを更新する */
    setIsDataChanged({ commit }, isDataChanged) {
      commit("setIsDataChanged", isDataChanged);
    },
    // 検査セット一覧セット
    setMstExamSetList({ commit }, data) {
      commit("setMstExamSetList", data);
    },
    /** daily store 初期化処理 */
    clearExamRequestDaily({ commit }) {
      commit("setOrgPatExamMains", []);
      commit("setOrdMainTreatDateList", []);
      commit("setEditExamRequestList", []);
      commit("setIsDataChanged", false);
    },
    /** 初期表示処理 */
    searchExamRequestDaily({ dispatch, commit, state, rootState }, reqData) {
      dispatch("clearExamRequestDaily");
      // 患者リストが空の場合は処理を抜ける
      if (!reqData.patIdList.length) return;

      return sendRequestPatExamMain(reqData).then(response => {
        // 検査依頼データ（元データ）を Store に保存
        commit("setOrgPatExamMains", response.data.patExamMains);
        // 透析予約日リスト（JSON文字列）をパースして保存
        const jsonList = response.data.ordMainTreatDateList.map(item => JSON.parse(item));
        commit("setOrdMainTreatDateList", jsonList);
        // 横軸の日付リストと編集状態リストを生成（初期値：data=0, editStatus=1）
        const { dateList, editDateList } = createDateLists(response.data.examDateList);
        // 患者IDごとに初期の検査依頼オブジェクトを作成
        const ListObj = createInitialListObj(reqData.patIdList, dateList, editDateList);
        // 締切条件を取得し、締切日を算出（フラグが有効な場合のみ）
        const dlc = rootState['exam-request'].list.deadlineCondition;
        const deadlineDate = dlc.deadlineFlg ? getDeadlineDate(dlc) : null;
        // 検査セットコードの重複チェック用オブジェクト
        const selectSetCd = {};
        // 検査依頼データを患者単位で処理
        response.data.patExamMains.forEach(data => {
          // 検査セット情報（JSON文字列）をパース
          const jsonObj = JSON.parse(data.orderExamSetInfo);
          // 対象患者のオブジェクトを取得
          const targetObj = ListObj.find(item => item.patId == data.patId);
          // 日付＋区分＋患者IDをキーにユニークなセットコードを抽出
          const countKey = `${data.strExamDate}+${data.regOrderClass}+${data.patId}`;
          const uniqueSetCds = getUniqueSetCds(jsonObj, countKey, selectSetCd);
          // 日付ごとの検査セット数を加算
          targetObj.data[data.strExamDate] += uniqueSetCds.length;
          // 検査セットごとのデータを登録
          jsonObj.forEach(obj => {
            // 検査セットオブジェクトを取得（未定義なら初期化）
            const targetSet = getOrCreateSet(targetObj.examItemSet, data.regOrderClass, obj.set_cd, obj.set_name);
            // 検査データ・状態・ロック状態を登録
            targetSet.data[data.strExamDate] = SAVED;
            targetSet.status[data.strExamDate] = data.examStatus;
            // 締切フラグに応じてロック状態を設定
            targetSet.isLock[data.strExamDate] = dlc.deadlineFlg
              ? (dayjs(deadlineDate).isAfter(data.strExamDate) ? "1" : "0")
              : data.isLock;
          });
        });
        // 編集用の検査依頼リストを Store に保存
        commit("setEditExamRequestList", ListObj);
      });
    },
  },
};