/**
 * 検査依頼用ストア
 */
import {
  sendRequestPatExamMain,
  sendRequestUpdateRecordList,
  sendRequestGetMstExamSetList,
  sendRequestGetPatInfoList,
} from "@/apis/exam-request";
import { sendRequestGetPatMain } from "@/apis/pat-viewer";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import {
  EXAM_DEADLINE,
  EXAM_DEADLINE_DATE_COUNT,
  EXAM_DEADLINE_TIME_COUNT,
} from "@/constants/facilitySetting";
import {
  CANCEL,
  SAVED,
  ADD,
  ADD_WARNING,
  INTERVAL_LIST,
} from "@/constants/examRequestConstants";
import {
  getMinSchExtEndDateCore,
  modifyInputDateCore,
  createSortComparator,
  DummyDateItem,
  createDateItem,
  createPatternItem,
  sortSetCdList,
} from "@/functions/exam-request/ExamRequestFunctions";
import { getDeadlineDate } from "@/functions/common/DateTimeUtils";
import moment from "moment";
import { deepCopy } from "@/functions/common/CommonFunctions";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 詳細表示フラグ
    showDetailsDisplay: true,
    // 表示期間
    showStartDate: "",
    showEndDate: "",
    isStoredShowDate: false,
    // 締切設定
    deadlineCondition: {
      deadlineFlg: false,
      deadlineDateCount: 0,
      deadlineTimeCount: ""
    },
    // 患者毎の透析予約日リスト
    ordMainTreatDateList: [],
    // 横軸の日付リスト
    examDateList: [],
    // 検査依頼リスト(データ操作用JSON配列)
    editExamRequestList: [],
    // 検査依頼リスト(DB保存データ作成用)
    saveExamRequestList: [],
    // 検査セット一覧
    examSetNameList: null,
    // 検査セット対象日付リスト
    examSetTargetList: [],
    // 保存する患者検査パターンのリスト
    savePatExamPattern: [],
    // 子画面に表示する患者ID
    selectedPatId: null,
    // 患者IDの表示フラグ
    isShowHospPatId: false,
    // 血糖検査の表示フラグ
    isShowBloodGlucoseExam: false,
    // 変更フラグ
    isDataChanged: false,
    // 患者毎のスケジュール延長最終日
    patExtInfoList: {},
    patMainList: [],
    // 検査パターンリスト
    patExamPatternList: [],
    // 検査パターンの横軸リスト
    examPatternColumnList: [],
    // スケジュール延長最終日
    schExtEndDate: null,
    // 治療パターンリスト
    patTreatmentPatternList: [],
    // 検査依頼一覧の患者ID
    checkPatId: null,
    treatBaseDate: [],
    calendarCheckedDate: null,
    // 依頼条件
    conditionList: null,
    selectedCalendar: [],
    // スケジュール作成範囲外患者IDリスト
    outsideSchExtPatList: [],
    // 施設に紐づく検査セットマスタ情報（削除済み含む）
    allExamSetList: [],
  },
  mutations: {
    // 詳細表示フラグ
    setShowDetailsDisplay(state, flg) {
      state.showDetailsDisplay = flg;
    },
    // 表示期間
    setStartToEndDate(state, data) {
      state.showStartDate = data.showStartDate;
      state.showEndDate = data.showEndDate;
      state.isStoredShowDate = true;
    },
    // 締切設定
    setDeadlineCondition(state, date) {
      if (date.code === EXAM_DEADLINE) {
        state.deadlineCondition.deadlineFlg = date.data;
      } else if (date.code === EXAM_DEADLINE_DATE_COUNT) {
        state.deadlineCondition.deadlineDateCount = date.data;
      } else if (date.code === EXAM_DEADLINE_TIME_COUNT) {
        state.deadlineCondition.deadlineTimeCount = date.data;
      }
    },
    // 患者毎の透析予約日リスト
    setOrdMainTreatDateList(state, jsonList) {
      state.ordMainTreatDateList = jsonList;
    },
    // 横軸の日付リスト
    setExamDateList(state, examDateList) {
      state.examDateList = examDateList;
    },
    // 検査依頼リスト(データ操作用JSON配列)
    setEditExamRequestList(state, editExamRequestList) {
      state.editExamRequestList = editExamRequestList;
    },
    // 検査依頼リスト(DB保存データ作成用)
    setSaveExamRequestList(state, saveExamRequestList) {
      state.saveExamRequestList = saveExamRequestList;
    },
    // 検査セット一覧
    setExamSetNameList(state, data) {
      state.examSetNameList = data;
    },
    // 検査セット対象日付リスト
    setExamSetTargetList(state, data) {
      state.examSetTargetList = data;
    },
    // 保存する患者検査パターンのリスト
    setSavePatExamPattern(state, data) {
      state.savePatExamPattern = data;
    },
    // 子画面に表示する患者ID
    setSelectedPatId(state, id) {
      state.selectedPatId = id;
    },
     // 患者IDの表示フラグ
    setIsShowHospPatId(state, isShowHospPatId) {
      state.isShowHospPatId = isShowHospPatId;
    },
    // 血糖検査の表示フラグ
    setIsShowBloodGlucoseExam(state, flag) {
      state.isShowBloodGlucoseExam = flag;
    },
    // 変更フラグ
    setIsDataChanged(state, isDataChanged) {
      state.isDataChanged = isDataChanged;
    },
    // 患者毎のスケジュール延長最終日
    setPatExtInfoList(state, data) {
      state.patExtInfoList = data;
    },
    setPatMainList(state, list) {
      state.patMainList = list;
    },
    // 検査パターンリスト
    setPatExamPatternList(state, patExamPatternList) {
      state.patExamPatternList = patExamPatternList;
    },
    // 検査パターンの横軸リスト
    setExamPatternColumnList(state, examPatternColumnList) {
      const sortComparator = createSortComparator(["examPattern", "examWeek"]);
      examPatternColumnList.sort(sortComparator);
      state.examPatternColumnList = examPatternColumnList;
    },
    // スケジュール延長最終日
    setSchExtEndDate(state, data) {
      state.schExtEndDate = data;
    },
    // 治療パターンリスト
    setPatTreatmentPatternList(state, patTreatmentPatternList) {
      state.patTreatmentPatternList = patTreatmentPatternList;
    },
    // 検査依頼一覧の患者ID
    setCheckPatId(state, checkPatId) {
      state.checkPatId = checkPatId;
    },
    setTreatBaseDate(state, treatBaseDate) {
      state.treatBaseDate = treatBaseDate;
    },
    setCalendarCheckedDate(state, calendarCheckedDate) {
      state.calendarCheckedDate = calendarCheckedDate;
    },
    // 依頼条件
    setCommonConditionList(state, conditionList) {
      state.conditionList = deepCopy(conditionList);
    },
    setSelectedCalendar(state, selectedCalendar) {
      state.selectedCalendar = deepCopy(selectedCalendar);
    },
    setOutsideSchExtPatList(state, outsideSchExtPatList) {
      state.outsideSchExtPatList = outsideSchExtPatList;
    },
    // 施設に紐づく検査セットマスタ情報（削除済み含む）
    setAllExamSetList(state, allExamSetList) {
      state.allExamSetList = allExamSetList;
    },
  },
  getters: {
    // 締切設定
    getDeadlineCondition(state) {
      return state.deadlineCondition;
    },
    // 表示期間
    getStartToEndDate(state) {
      const { showStartDate, showEndDate } = state;
      return { showStartDate, showEndDate };
    },
    isStoredShowDate(state) {
      return state.isStoredShowDate;
    },
    // 表示期間（未来日～過去日の大小逆転を解決済みの状態）
    getNormalizedStartToEndDate(state) {
      let { showStartDate, showEndDate } = state;
      if (showStartDate && showEndDate && showStartDate > showEndDate) {
        // 日付の大小が逆転している場合は入れ替える
        [showStartDate, showEndDate] = [showEndDate, showStartDate];
      }
      return { showStartDate, showEndDate };
    },
    // 患者毎の透析予約日リスト
    getOrdMainTreatDateList(state) {
      return state.ordMainTreatDateList;
    },
    // 横軸の日付リスト
    getExamDateList(state, getters) {
      const rtnList = getters.getExamDateListNoShap.map(examDate => createDateItem(examDate));

      // ヘッダ列を追加
      rtnList.unshift(DummyDateItem, DummyDateItem);
      if (state.isShowHospPatId) {
        rtnList.unshift(DummyDateItem);
      }
      if (state.isShowBloodGlucoseExam) {
        rtnList.unshift(DummyDateItem);
      }

      state.examPatternColumnList.forEach(item => {
        const patternItem = createPatternItem(item, INTERVAL_LIST, "examPattern", "examWeek");
        if (patternItem) {
          rtnList.push(patternItem);
        }
      });

      return rtnList;
    },
    getExamDateListDetail(state, getters) {
      const rtnList = getters.getExamDateListNoShap.map(examDate => createDateItem(examDate, true));

      // ヘッダ列を追加
      rtnList.unshift(DummyDateItem, DummyDateItem);

      state.examPatternColumnList.forEach(item => {
        const patternItem = createPatternItem(item, INTERVAL_LIST, "examPattern", "examWeek");
        if (patternItem) {
          rtnList.push(patternItem);
        }
      });

      return rtnList;
    },
    // 横軸の日付リスト(整形なし)
    getExamDateListNoShap(state, getters) {
      const { showStartDate, showEndDate } = getters.getNormalizedStartToEndDate;
      return state.examDateList.filter(examDate => (
        (!showStartDate || showStartDate <= examDate)
        && (!showEndDate || showEndDate >= examDate)
      ));
    },
    // 横軸の日付リスト(制限なし)
    getExamDateListNoLimit(state) {
      return state.examDateList;
    },
    // 検査セットリストのセットコードをキーとした並び順の辞書
    getSetOrderMap(state) {
      const setOrderMap = {};
      (state.examSetNameList || []).forEach((setListItem, index) => {
        setOrderMap[setListItem.examSetCd] = index + 1;
      });
      return setOrderMap;
    },
    // 検査依頼リスト(無加工)
    getExamRequestListRaw(state, getters) {
      // 検査依頼リスト(画面表示用)作成
      const showDataObj = [];
      state.editExamRequestList.forEach(obj => {
        const patId = obj.patId;

        // ヘッダ(患者名)
        const headerObj = {
          headerflg: true,
          patId,
          // examItemSet(前、後、その他)毎の数の合計 + 1
          rowspan: 1,
          examData: obj.data,
          editStatus: obj.editStatus,
        };
        showDataObj.push(headerObj);

        // 検査セット分(前、後、その他)
        ["1", "2", "0"].forEach(regOrderClass => {
          const itemSet = obj.examItemSet[regOrderClass] || {};
          const setCdList = Object.keys(itemSet);
          if (!setCdList.length) return;
          headerObj.rowspan += setCdList.length;

          sortSetCdList(setCdList, getters.getSetOrderMap);
          setCdList.forEach(examSetCd => {
            const setObj = itemSet[examSetCd];
            showDataObj.push({
              headerflg: false,
              patId,
              examSetCd,
              examSetName: setObj.name,
              regOrderClass,
              examData: setObj.data,
              examStatus: setObj.status,
              nowIsLock: setObj.isLock,
              // add #12462 患者情報共有 Ji start
              facilityCd: Object.values(setObj.facilityCd || {})[0],
              ownPatId: Object.values(setObj.ownPatId || {})[0],
              setInfo: setObj.setInfo
              // add #12462 患者情報共有 Ji end
            });
          });
        });
      });
      return showDataObj;
    },
    // 検査依頼リスト(画面表示用)
    getExamRequestList(state, getters) {
      return state.showDetailsDisplay
        ? getters.getExamRequestListRaw
        : getters.getExamRequestListRaw.filter(item => item.headerflg);
    },
    // 検査依頼リスト(画面表示用)(整形なし)
    getExamRequestListNoShap(_state, getters) {
      return getters.getExamRequestListRaw;
    },
    // 検査依頼リスト(データ操作用JSON配列)
    getEditExamRequestList(state) {
      return state.editExamRequestList;
    },
    // 検査依頼リスト(DB保存データ作成用)
    getSaveExamRequestList(state) {
      return state.saveExamRequestList;
    },
    // 検査セット一覧
    getExamSetNameList(state) {
      return state.examSetNameList;
    },
    // 検査セット対象リスト
    getExamSetTargetList(state) {
      return state.examSetTargetList;
    },
    // 保存する患者検査パターンのリスト
    getSavePatExamPattern(state) {
      return state.savePatExamPattern;
    },
    // 子画面に表示する患者ID
    getSelectedPatId(state) {
      return state.selectedPatId;
    },
    // 子画面表示用リスト
    getExamRequestDetailList(state, getters) {
      return getters.getExamRequestListRaw.filter(item => (
        item.patId === state.selectedPatId
        && !item.headerflg
      ));
    },
    // 患者IDフラグを表示する。
    getIsShowHospPatId(state) {
      return state.isShowHospPatId;
    },
    // 血糖検査フラグを表示する。
    getIsShowBloodGlucoseExam(state) {
      return state.isShowBloodGlucoseExam;
    },
    // 変更フラグ
    getIsDataChanged(state) {
      return state.isDataChanged;
    },
    // 患者毎のスケジュール延長最終日
    getPatExtInfoList(state) {
      return state.patExtInfoList;
    },
    patMainList(state) {
      return state.patMainList;
    },
    // 検査パターンリスト
    getPatExamPatternList(state) {
      return state.patExamPatternList;
    },
    // 検査パターンの横軸リスト
    getExamPatternColumnList(state) {
      return state.examPatternColumnList;
    },
    // スケジュール延長最終日
    getSchExtEndDate(state) {
      return state.schExtEndDate;
    },
    // 治療パターンリスト
    getPatTreatmentPatternList(state) {
      return state.patTreatmentPatternList;
    },
    // 検査依頼一覧の患者ID
    getCheckPatId(state) {
      return state.checkPatId;
    },
    getTreatBaseDate(state) {
      return state.treatBaseDate;
    },
    getCalendarCheckedDate(state) {
      return state.calendarCheckedDate;
    },
    // 依頼条件
    getCommonConditionList(state) {
      return state.conditionList;
    },
    getSelectedCalendar(state) {
      return state.selectedCalendar;
    },
    getOutsideSchExtPatList(state) {
      return state.outsideSchExtPatList;
    },
    // 施設に紐づく検査セットマスタ情報（削除済み含む）
    getAllExamSetList(state) {
      return state.allExamSetList;
    },
  },
  actions: {
    // 依頼データ検索前のstateクリア処理
    clearSearchedExamRequest({ commit }) {
      commit("setExamDateList", []);
      commit("setSaveExamRequestList", []);
      commit("setOrdMainTreatDateList", []);
      commit("setEditExamRequestList", []);
      commit("setSavePatExamPattern", []);
      commit("setPatExtInfoList", {});
      commit("setPatExamPatternList", []);
      commit("setPatTreatmentPatternList", []);
      commit("setExamPatternColumnList", []);
      commit("setOutsideSchExtPatList", []);
      commit("setIsDataChanged", false);
    },
    // 初期表示時
    searchExamRequest({ dispatch, commit, state }, reqData) {
      dispatch("clearSearchedExamRequest");
      // 患者リストが空の場合は処理を抜ける
      if (!reqData.patIdList.length) return;

      return sendRequestPatExamMain(reqData).then(response => {
        commit("setExamDateList", response.data.examDateList);
        commit("setSaveExamRequestList", response.data.patExamMains);
        // mod FNSI6479-一定時間治療予定なしの色で表示される 周 0318 start
        //commit("setPatExamPatternList", response.data.patExamPatternList);
        commit("setPatExamPatternList", response.data.patExamPatternList.reverse());
        // mod FNSI6479-一定時間治療予定なしの色で表示される 周 0318 end
        commit("setPatTreatmentPatternList", response.data.patTreatmentPatternList);
        commit("setExamPatternColumnList", response.data.examPatternColumnList);

        // 患者毎の透析予約日リストを格納
        const jsonList = response.data.ordMainTreatDateList.map(item => JSON.parse(item));
        commit("setOrdMainTreatDateList", jsonList);

        // 横軸の日付リスト
        const dateList = {};
        // 編集状態の日付リスト
        const editDateList = {};
        response.data.examDateList.forEach(examDate => {
          dateList[examDate] = 0;
          editDateList[examDate] = 1;
        });

        // 検査依頼リスト(データ操作用JSON配列)作成
        const ListObj = [];
        reqData.patIdList.forEach(patId => {
          ListObj.push({
            patId,
            // コピーで日付リストを追加
            data: { ...dateList },
            editStatus: { ...editDateList },
            // 検査セットのリスト
            // 1:透析前 2:透析後 0:その他 の順で表示
            examItemSet: {
              "1": {},
              "2": {},
              "0": {},
            },
          });
        });

        // 締切が有効な場合、締め切り日を取得する
        const deadlineDate = state.deadlineCondition.deadlineFlg
          ? getDeadlineDate(state.deadlineCondition)
          : null;

        // データを集計
        const selectSetCd = [];
        response.data.patExamMains.forEach(data => {
          // mod #12462 患者情報共有 Ji start
          // const jsonObj = JSON.parse(data.orderExamSetInfo);
          const jsonObj = JSON.parse(data.orderExamSetInfo || "[]");
          const setInfo = JSON.parse(data.examOrderInfo || "[]");
          jsonObj.forEach(set => {
            set.items = setInfo.filter(item => item && item.set_cd === set.set_cd);
          });
          // mod #12462 患者情報共有 Ji end
          const targetObj = ListObj.find(item => item.patId == data.patId);

          // 日付の合計
          let unSelectNum = 0;
          const countKey = `${data.strExamDate}+${data.regOrderClass}+${data.patId}`;
          jsonObj.forEach(obj => {
            if (!selectSetCd[countKey]) {
              selectSetCd[countKey] = [];
            }
            if (!selectSetCd[countKey][obj.set_cd]) {
              selectSetCd[countKey][obj.set_cd] = true;
              unSelectNum += 1;
            }
          });
          targetObj.data[data.strExamDate] += unSelectNum;

          // 検査セットを追加
          jsonObj.forEach(obj => {
            const targetObjOrderClass = targetObj.examItemSet[data.regOrderClass];
            if (!targetObjOrderClass[obj.set_cd]) {
              targetObjOrderClass[obj.set_cd] = {
                name: obj.set_name,
                data: {},
                status: {},
                isLock: {},
                // add #12462 患者情報共有 Ji start
                facilityCd: {},
                ownPatId: {},
                setInfo:[]
                // add #12462 患者情報共有 Ji end
              };
            }
            const targetObjSetCd = targetObjOrderClass[obj.set_cd];
            // フラグを入れる
            targetObjSetCd.data[data.strExamDate] = SAVED;
            targetObjSetCd.status[data.strExamDate] = data.examStatus;
            // add #12462 患者情報共有 Ji start
            targetObjSetCd.facilityCd[data.strExamDate] = data.facilityCd;
            targetObjSetCd.ownPatId[data.strExamDate] = data.ownPatId;
            targetObjSetCd.setInfo = setInfo.filter(
              item => item && item.set_cd === obj.set_cd
            );
            // add #12462 患者情報共有 Ji end
            // 締切フラグ
            if (state.deadlineCondition.deadlineFlg) {
              if (moment(deadlineDate).isAfter(data.strExamDate)) {
                // 締切を過ぎている
                targetObjSetCd.isLock[data.strExamDate] = "1";
              } else {
                // 締切を過ぎていない
                targetObjSetCd.isLock[data.strExamDate] = "0";
              }
            } else {
              // 締切が無効な場合は取得データを入れる
              targetObjSetCd.isLock[data.strExamDate] = data.isLock;
            }
          });
        });
        // 検査依頼リスト(データ操作用JSON配列)を保持
        commit("setEditExamRequestList", ListObj);
      });
    },
    // 保存
    async updateRecordList({ dispatch, state }, request) {
      const obj = {
        patExamMainList: request,
        patExamPatternList: state.savePatExamPattern,
        patExtInfoList: await dispatch("getUpdatePatExtInfoList"),
      };
      return sendRequestUpdateRecordList(obj);
    },
    // 保存
    async updateRecordListJournal({ dispatch, state }, request) {
      const obj = {
        patExamMainList: request.request,
        patExamPatternList: state.savePatExamPattern,
        patExtInfoList: await dispatch("getUpdatePatExtInfoList"),
        requestJournalList: request.requestJournal,
      };
      return sendRequestUpdateRecordList(obj);
    },
    // 検査セット一覧取得
    searchExamSetNameList({ commit }, facilityCd) {
      commit("setExamSetNameList", []);
      return sendRequestGetMstExamSetList(facilityCd).then(response => {
        commit("setExamSetNameList", response.data);
        return Promise.resolve(response.data);
      });
    },
    // 締切設定を施設設定から取得
    setExamDeadline({ commit }, facilityCd) {
      // 検査締切有無
      sendRequestGetMstFacilitySettingValue(facilityCd, EXAM_DEADLINE).then(response => {
        commit("setDeadlineCondition", {
          code: EXAM_DEADLINE,
          data: response.data === 1,
        });
      });
      // 検査依頼変更締切り日数
      sendRequestGetMstFacilitySettingValue(facilityCd, EXAM_DEADLINE_DATE_COUNT).then(response => {
        commit("setDeadlineCondition", {
          code: EXAM_DEADLINE_DATE_COUNT,
          data: response.data,
        });
      });
      // 検査依頼変更締切り時間
      sendRequestGetMstFacilitySettingValue(facilityCd, EXAM_DEADLINE_TIME_COUNT).then(response => {
        const chkStr = "^(?:(?:[0-2][0-3])|(?:[0-1][0-9])):[0-5][0-9]$";
        const strResponse = String(response.data);
        const rtnTime = strResponse.match(chkStr) ? strResponse : "00:00";
        commit("setDeadlineCondition", {
          code: EXAM_DEADLINE_TIME_COUNT,
          data: rtnTime,
        });
      });
    },
    // 検査セット一覧セット
    setExamSetNameList({ commit }, data) {
      commit("setExamSetNameList", data);
    },
    // 検査セット対象リスト
    setShowDetailsDisplay({ commit }, flg) {
      commit("setShowDetailsDisplay", flg);
    },
    // 子画面に表示する患者ID
    setSelectedPatId({ commit }, id) {
      commit("setSelectedPatId", id);
    },
    // 患者毎のスケジュール延長最終日
    setPatExtInfoList({ commit }, data) {
      commit("setPatExtInfoList", data);
    },
    // 表示期間更新
    updateStartToEndDate({ commit }, data) {
      commit("setStartToEndDate", data);
    },
    // 検査セットリスト更新
    updateExamSetTargetList({ commit }, data) {
      commit("setExamSetTargetList", data);
    },
    // mod #12462 患者情報共有 Ji start
    // dayAllClear({ state }, targetDate) {
    dayAllClear({ state }, { targetDate, facilityCd }) {
    // mod #12462 患者情報共有 Ji end
      state.editExamRequestList.forEach(pat => {
        // 透析前、透析後、その他の順に処理する
        ["1", "2", "0"].reduce((allItem, regOrderClass) => {
          allItem.push(...Object.values(pat.examItemSet[regOrderClass]));
          return allItem;
        }, []).forEach(item => {
          // mod #12462 患者情報共有 Ji start
          const itemFacilityCd = item.facilityCd?.[targetDate]
          if (itemFacilityCd && itemFacilityCd !== facilityCd) return
          // mod #12462 患者情報共有 Ji end
          const itemData = item.data;
          const status = itemData[targetDate];
          if (status == null) return;

          if (status === SAVED) {
            // 保存済みの場合は中止
            itemData[targetDate] = CANCEL;
            pat.data[targetDate]--;
          } else if (status === ADD || status === ADD_WARNING) {
            // 保存前の場合は削除
            delete itemData[targetDate];
            pat.data[targetDate]--;
          }
        });
      });
      // state.editExamRequestListの要素内の情報を更新したリアクションを起こさせる
      state.editExamRequestList.splice();
    },
    // 指定患者、日付の編集状態を更新
    updateEditScheduleStatusStore({ state }, targetDate) {
      // チェックされている患者でループ
      targetDate.examSetTargetList.forEach(targetId => {
        // 該当患者のデータセットを取得
        const targetObj = state.editExamRequestList.find(item => item.patId == targetId);
        if (!targetObj) return;
        // すべての検査タイミング(その他、前、後)のデータをまとめて処理する
        const allItem = [];
        ["0", "1", "2"].forEach(regOrderClass => {
          allItem.push(...Object.values(targetObj.examItemSet[regOrderClass]));
        });
        // 対象日付に対して処理を実施
        targetDate.targetDateList.forEach(setDate => {
          // status が SAVED 以外なら取得
          const editStatusList = [];
          allItem.forEach(item => {
            const status = item.data[setDate];
            if (status == null || status === SAVED) return;
            editStatusList.push(status);
          });
          // SAVED 以外の status が存在していた場合は最大値を取得
          const finalStatus = editStatusList.length ? Math.max(...editStatusList) : SAVED;
          targetObj.editStatus[setDate] = finalStatus;
        });
      });
      // state.editExamRequestListの要素内の情報を更新したリアクションを起こさせる
      state.editExamRequestList.splice();
    },
    // 患者IDフラグを更新する
    setIsShowHospPatId({ commit }, isShowHospPatId) {
      commit("setIsShowHospPatId", isShowHospPatId);
    },
    // 血糖検査フラグを更新する
    setIsShowBloodGlucoseExam({ commit }, flag) {
      commit("setIsShowBloodGlucoseExam", flag);
    },
    // 変更フラグ
    setIsDataChanged({ commit }, isDataChanged) {
      commit("setIsDataChanged", isDataChanged);
    },
    // 患者情報の取得
    getPatInfoList({}, patIdList) {
      return sendRequestGetPatInfoList(patIdList).then(response => {
        return Promise.resolve(response.data);
      });
    },
    // スケジュール延長最終日の更新用オブジェクトの作成
    getUpdatePatExtInfoList({ state }) {
      const rtnUpdatePatExtInfoList = [];
      Object.keys(state.patExtInfoList).forEach(key => {
        // スケジュール延長最終日が存在しない患者のみ抽出
        if (!state.patExtInfoList[key].isExistEndDate) {
          rtnUpdatePatExtInfoList.push(state.patExtInfoList[key]);
        }
      })
      return rtnUpdatePatExtInfoList;
    },
    async getPatMainList({ commit }, patIdList) {
      const response = await sendRequestGetPatMain(patIdList);
      const data = response && response.data;
      if (data) {
        const list = data.map(item => ({
          patId: item.pat_id,
          isBloodGlucoseExam: !!+item.is_blood_suger_exam,
          schExtEndDate: item.sch_ext_end_date,
        }));
        commit("setPatMainList", list);
      }
      return data;
    },
    // 検査パターンリスト
    setPatExamPatternList({ commit }, patExamPatternList) {
      commit("setPatExamPatternList", patExamPatternList);
    },
    // 検査パターンの横軸リスト
    setExamPatternColumnList({ commit }, examPatternColumnList) {
      commit("setExamPatternColumnList", examPatternColumnList);
    },
    // 保存用検査パターンリスト
    setSavePatExamPattern({ commit }, savePatExamPattern) {
      commit("setSavePatExamPattern", savePatExamPattern);
    },
    // スケジュール延長最終日を取得
    async getMinSchExtEndDate({ commit }, { facilityCd, patIdList }) {
      const schExtEndDate = await getMinSchExtEndDateCore(facilityCd, patIdList);
      commit("setSchExtEndDate", schExtEndDate);
    },
    // 日付入力値をスケジュール延長最終日を上限として補正する
    modifyInputDate({ getters }, { condition, conditionName }) {
      modifyInputDateCore(condition, conditionName, getters.getSchExtEndDate);
    },
    // 検査依頼一覧の患者ID
    setCheckedPatId({commit},checkPatId) {
      commit("setCheckPatId", checkPatId);
    },
    setTreatBaseDate({ commit }, treatBaseDate) {
      commit("setTreatBaseDate", treatBaseDate);
    },
    setCalendarCheckedDate({ commit }, calendarCheckedDate) {
      commit("setCalendarCheckedDate", calendarCheckedDate);
    },
    // 依頼条件
    setCommonConditionList({ commit }, conditionList) {
      commit("setCommonConditionList", conditionList);
    },
    setSelectedCalendar({ commit }, selectedCalendar) {
      commit("setSelectedCalendar", selectedCalendar);
    },
    setOutsideSchExtPatList({ commit }, outsideSchExtPatList) {
      commit("setOutsideSchExtPatList", outsideSchExtPatList);
    },
    setAllExamSetList({ commit }, allExamSetList) {
      commit("setAllExamSetList", allExamSetList);
    },
  },
};
