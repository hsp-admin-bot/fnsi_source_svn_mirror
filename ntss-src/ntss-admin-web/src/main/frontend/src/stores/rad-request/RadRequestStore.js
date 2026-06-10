/**
 * 一般撮影検査依頼用ストア
 */
import {
  sendRequestPatRadMain,
  sendRequestUpdateRecordList,
  sendRequestGetMstRadSetList,
  sendRequestGetPatInfoList,
} from "@/apis/rad-request";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import {
  RAD_DEADLINE,
  RAD_DEADLINE_DATE_COUNT,
  RAD_DEADLINE_TIME_COUNT,
} from "@/constants/facilitySetting";
import {
  CANCEL,
  SAVED,
  ADD,
  ADD_WARNING,
  INTERVAL_LIST,
} from "@/constants/radRequestConstants";
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
import { toFixed } from "@/functions/common/NumberFunctions";
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
    radDateList: [],
    // 横軸の日時リスト
    radDateTimeList: [],
    // 検査依頼リスト(データ操作用JSON配列)
    editRadRequestList: [],
    // 検査依頼リスト(DB保存データ作成用)
    saveRadRequestList: [],
    // 検査セット一覧
    radSetNameList: null,
    // 検査セット対象日付リスト
    radSetTargetList: [],
    // 保存する患者検査パターンのリスト
    savePatRadPattern: [],
    // 患者、検査セットごとの前回検査日リスト
    lastRadDateList: [],
    // 子画面に表示する患者ID
    selectedPatId: null,
    // 患者毎のスケジュール延長最終日
    patExtInfoList: {},
    // 患者IDの表示フラグ
    isShowHospPatId: false,
    // 前回検査日表示フラグ
    isShowLastRadDate: false,
    // モバイル端末表示フラグ
    isAndroidOrIOS: false,
    // 変更フラグ
    isDataChanged: false,
    // 検査パターンリスト
    patRadPatternList: [],
    // 依頼条件
    conditionList: null,
    selectedCalendar: [],
    // 検査パターンの横軸リスト
    radPatternColumnList: [],
    // 検査パターンの横軸リスト(患者個別用)
    radPatternDetailColumnList: [],
    // 身体情報
    patUniqueList: [],
    // スケジュール延長最終日
    schExtEndDate: null,
    // 治療パターンリスト
    patTreatmentPatternList: [],
    // 放射線検査依頼一覧の患者Id
    checkPatId: null,
    treatBaseDate: [],
    calendarCheckedDate: null,
    // スケジュール作成範囲外患者IDリスト
    outsideSchExtPatList: [],
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
    setDeadlineCondition(state, data) {
      if (data.code === RAD_DEADLINE) {
        state.deadlineCondition.deadlineFlg = data.data;
      } else if (data.code === RAD_DEADLINE_DATE_COUNT) {
        state.deadlineCondition.deadlineDateCount = data.data;
      } else if (data.code === RAD_DEADLINE_TIME_COUNT) {
        state.deadlineCondition.deadlineTimeCount = data.data;
      }
    },
    // 患者毎の透析予約日リスト
    setOrdMainTreatDateList(state, jsonList) {
      state.ordMainTreatDateList = jsonList;
    },
    // 横軸の日付リスト
    setRadDateList(state, radDateList) {
      state.radDateList = radDateList;
    },
    // 横軸の日時リスト
    setRadDateTimeList(state, radDateTimeList) {
      state.radDateTimeList = radDateTimeList;
    },
    // 検査依頼リスト(データ操作用JSON配列)
    setEditRadRequestList(state, editRadRequestList) {
      state.editRadRequestList = editRadRequestList;
    },
    // 検査依頼リスト(DB保存データ作成用)
    setSaveRadRequestList(state, saveRadRequestList) {
      state.saveRadRequestList = saveRadRequestList;
    },
    // 検査セット一覧
    setRadSetNameList(state, data) {
      state.radSetNameList = data;
    },
    // 検査セット対象日付リスト
    setRadSetTargetList(state, data) {
      state.radSetTargetList = data;
    },
    // 保存する患者検査パターンのリスト
    setSavePatRadPattern(state, data) {
      state.savePatRadPattern = data;
    },
    // 患者、検査セットごとの前回検査日リスト
    setLastRadDateList(state, jsonList) {
      state.lastRadDateList = jsonList;
    },
    // 子画面に表示する患者ID
    setSelectedPatId(state, id) {
      state.selectedPatId = id;
    },
    // 患者毎のスケジュール延長最終日
    setPatExtInfoList(state, data) {
      state.patExtInfoList = data;
    },
    // 患者IDの表示フラグ
    setIsShowHospPatId(state, isShowHospPatId) {
      state.isShowHospPatId = isShowHospPatId;
    },
    // 前回検査日表示フラグ
    setIsShowLastRadDate(state, isShowLastRadDate) {
      state.isShowLastRadDate = isShowLastRadDate;
    },
    // モバイル端末表示フラグ
    setAndroidOrIOS(state, isAndroidOrIOS) {
      state.isAndroidOrIOS = isAndroidOrIOS;
    },
    // 変更フラグ
    setIsDataChanged(state, isDataChanged) {
      state.isDataChanged = isDataChanged;
    },
    // 検査パターンリスト
    setPatRadPatternList(state, patRadPatternList) {
      state.patRadPatternList = patRadPatternList;
    },
    // 依頼条件
    setCommonConditionList(state, conditionList) {
      state.conditionList = deepCopy(conditionList);
    },
    setSelectedCalendar(state, selectedCalendar) {
      state.selectedCalendar = deepCopy(selectedCalendar);
    },
    // 検査パターンの横軸リスト
    setRadPatternColumnList(state, radPatternColumnList) {
      const sortComparator = createSortComparator(["radPattern", "radWeek"]);
      radPatternColumnList.sort(sortComparator);
      state.radPatternColumnList = radPatternColumnList;
    },
    // 検査パターンの横軸リスト（患者個別用）
    setRadPatternDetailColumnList(state, radPatternDetailColumnList) {
      const sortComparator = createSortComparator(["radPattern", "radWeek", "radTime"]);
      radPatternDetailColumnList.sort(sortComparator);
      state.radPatternDetailColumnList = radPatternDetailColumnList;
    },
    // スケジュール延長最終日
    setSchExtEndDate(state, data) {
      state.schExtEndDate = data;
    },
    // 治療パターンリスト
    setPatTreatmentPatternList(state, patTreatmentPatternList) {
      state.patTreatmentPatternList = patTreatmentPatternList;
    },
    // 放射線検査依頼一覧の患者Id
    setCheckPatId(state, checkPatId) {
      state.checkPatId = checkPatId;
    },
    setTreatBaseDate(state, treatBaseDate) {
      state.treatBaseDate = treatBaseDate;
    },
    setCalendarCheckedDate(state, calendarCheckedDate) {
      state.calendarCheckedDate = calendarCheckedDate;
    },
    // 身体情報
    setPatUniqueList(state, patUniqueList) {
      state.patUniqueList = patUniqueList;
    },
    setOutsideSchExtPatList(state, outsideSchExtPatList) {
      state.outsideSchExtPatList = outsideSchExtPatList;
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
    getRadDateList(state, getters) {
      const rtnList = getters.getRadDateListNoShap.map(radDate => createDateItem(radDate));

      // ヘッダ列を追加
      if (!state.isAndroidOrIOS || state.isShowLastRadDate) {
        rtnList.unshift({ ...DummyDateItem, dateFormat: "前回検査日" });
      }
      rtnList.unshift(DummyDateItem, DummyDateItem);
      if (state.isShowHospPatId) {
        rtnList.unshift(DummyDateItem);
      }

      state.radPatternColumnList.forEach(item => {
        const patternItem = createPatternItem(item, INTERVAL_LIST, "radPattern", "radWeek");
        if (patternItem) {
          rtnList.push(patternItem);
        }
      });

      return rtnList;
    },
    // 横軸の日付リスト(患者個別用)
    getRadDateListDetail(state, getters) {
      const rtnList = getters.getRadDateTimeListNoShap.map(radDateTime => {
        const [radDate, radTime] = radDateTime.split("_");
        const dateItem = createDateItem(radDate, true, radTime);
        return dateItem;
      });

      // ヘッダ列を追加
      rtnList.unshift(DummyDateItem, DummyDateItem);

      state.radPatternDetailColumnList.forEach(item => {
        const patternItem = createPatternItem(item, INTERVAL_LIST, "radPattern", "radWeek", "radTime");
        if (patternItem) {
          rtnList.push(patternItem);
        }
      });

      return rtnList;
    },
    // 横軸の日付リスト(整形なし)
    getRadDateListNoShap(state, getters) {
      const { showStartDate, showEndDate } = getters.getNormalizedStartToEndDate;
      return state.radDateList.filter(radDate => (
        (!showStartDate || showStartDate <= radDate)
        && (!showEndDate || showEndDate >= radDate)
      ));
    },
    // 横軸の日時リスト(整形なし)
    getRadDateTimeListNoShap(state, getters) {
      const { showStartDate, showEndDate } = getters.getNormalizedStartToEndDate;
      return state.radDateTimeList.filter(radDateTime => {
        const radDate = radDateTime.split("_")[0];
        return (
          (!showStartDate || showStartDate <= radDate)
          && (!showEndDate || showEndDate >= radDate)
        );
      });
    },
    // 横軸の日付リスト(制限なし)
    getRadDateListNoLimit(state) {
      return state.radDateList;
    },
    // 横軸の日付リスト(制限なし)
    getRadDateTimeListNoLimit(state) {
      return state.radDateTimeList;
    },
    // 検査セットリストのセットコードをキーとした並び順の辞書
    getSetOrderMap(state) {
      const setOrderMap = {};
      (state.radSetNameList || []).forEach((setListItem, index) => {
        setOrderMap[setListItem.radSetCd] = index + 1;
      });
      return setOrderMap;
    },
    // 検査依頼リスト(無加工)
    getRadRequestListRaw(state, getters) {
      // 検査依頼リスト(画面表示用)作成
      const showDataObj = [];
      state.editRadRequestList.forEach(obj => {
        const patId = obj.patId;

        // ヘッダ(患者名)
        const headerObj = {
          headerflg: true,
          patId,
          // radItemSet(前、後、その他)毎の数の合計 + 1
          rowspan: 1,
          radData: obj.data,
          editStatus: obj.editStatus,
          lastRadDate: obj.exam_date + "\n" + obj.ctr,
        };
        showDataObj.push(headerObj);

        // 検査セット分
        // 一般撮影検査依頼には検査区分の指定はなく
        // すべて 0 が設定されているが、
        // 念のためすべての区分のデータを処理する形にしておく
        ["1", "2", "0"].forEach(regOrderClass => {
          const itemSet = obj.radItemSet[regOrderClass];
          const setCdList = Object.keys(itemSet);
          if (!setCdList.length) return;
          headerObj.rowspan += setCdList.length;

          // 検査セットリストの並び順に合わせた順で表示用データを追加する
          // （削除済みなどで検査セットリストに存在しないものは
          // 　末尾に検査セットコードの昇順で追加する）
          sortSetCdList(setCdList, getters.getSetOrderMap);
          setCdList.forEach(radSetCd => {
            const setObj = itemSet[radSetCd];
            showDataObj.push({
              headerflg: false,
              patId,
              radSetCd,
              radSetName: setObj.name,
              regOrderClass,
              radData: setObj.data,
              radDataDetail: setObj.dataDetail,
              radTime: setObj.time,
              radDateTime: setObj.dateTime,
              lastRadDate: setObj.lastDate,
              radStatus: setObj.status,
              radStatusDetail: setObj.statusDetail,
              nowIsLock: setObj.isLock,
              // add #12462 患者情報共有 Ji start
              facilityCd: Object.values(setObj.facilityCd)[0]
              // add #12462 患者情報共有 Ji end
            });
          });
        });
      });
      return showDataObj;
    },
    // 検査依頼リスト(画面表示用)
    getRadRequestList(state, getters) {
      return state.showDetailsDisplay
        ? getters.getRadRequestListRaw
        : getters.getRadRequestListRaw.filter(item => item.headerflg);
    },
    // 検査依頼リスト(画面表示用)(整形なし)
    getRadRequestListNoShap(_state, getters) {
      return getters.getRadRequestListRaw;
    },
    // 検査依頼リスト(データ操作用JSON配列)
    getEditRadRequestList(state) {
      return state.editRadRequestList;
    },
    // 検査依頼リスト(DB保存データ作成用)
    getSaveRadRequestList(state) {
      return state.saveRadRequestList;
    },
    // 依頼条件
    getCommonConditionList(state) {
      return state.conditionList;
    },
    getSelectedCalendar(state) {
      return state.selectedCalendar;
    },
    // 検査セット一覧
    getRadSetNameList(state) {
      return state.radSetNameList;
    },
    // 検査セット対象リスト
    getRadSetTargetList(state) {
      return state.radSetTargetList;
    },
    // 保存する患者検査パターンのリスト
    getSavePatRadPattern(state) {
      return state.savePatRadPattern;
    },
    // 患者、検査セットごとの前回検査日リスト
    getLastRadDateList(state) {
      return state.lastRadDateList;
    },
    // 子画面に表示する患者ID
    getSelectedPatId(state) {
      return state.selectedPatId;
    },
    // 子画面表示用リスト
    getRadRequestDetailList(state, getters) {
      return getters.getRadRequestListRaw.filter(item => (
        item.patId === state.selectedPatId
        && !item.headerflg
      ));
    },
    // 患者毎のスケジュール延長最終日
    getPatExtInfoList(state) {
      return state.patExtInfoList;
    },
    // 患者IDフラグを表示する。
    getIsShowHospPatId(state) {
      return state.isShowHospPatId;
    },
    // 前回検査日フラグを表示する。
    getIsShowLastRadDate(state) {
      return state.isShowLastRadDate;
    },
    // 変更フラグ
    getIsDataChanged(state) {
      return state.isDataChanged;
    },
    // 検査パターンリスト
    getPatRadPatternList(state) {
      return state.patRadPatternList;
    },
    // 検査パターンの横軸リスト
    getRadPatternColumnList(state) {
      return state.radPatternColumnList;
    },
    // 検査パターンの横軸リスト（患者個別用）
    getRadPatternDetailColumnList(state) {
      return state.radPatternDetailColumnList;
    },
    // 身体情報
    getPatUniqueList(state) {
      return state.patUniqueList;
    },
    // スケジュール延長最終日
    getSchExtEndDate(state) {
      return state.schExtEndDate;
    },
    // 治療パターンリスト
    getPatTreatmentPatternList(state) {
      return state.patTreatmentPatternList;
    },
    // 子画面に表示する患者ID
    getCheckPatId(state) {
      return state.checkPatId;
    },
    getTreatBaseDate(state) {
      return state.treatBaseDate;
    },
    getCalendarCheckedDate(state) {
      return state.calendarCheckedDate;
    },
    getOutsideSchExtPatList(state) {
      return state.outsideSchExtPatList;
    },
    // モバイル端末表示フラグ
    getIsAndroidOrIOS(state) {
      return state.isAndroidOrIOS;
    },
  },
  actions: {
    // 依頼データ検索前のstateクリア処理
    clearSearchedRadRequest({ commit }) {
      commit("setRadDateList", []);
      commit("setRadDateTimeList", []);
      commit("setSaveRadRequestList", []);
      commit("setOrdMainTreatDateList", []);
      commit("setEditRadRequestList", []);
      commit("setSavePatRadPattern", []);
      commit("setLastRadDateList", []);
      commit("setPatExtInfoList", {});
      commit("setPatRadPatternList", []);
      commit("setPatTreatmentPatternList", []);
      commit("setRadPatternColumnList", []);
      commit("setRadPatternDetailColumnList", []);
      commit("setOutsideSchExtPatList", []);
      commit("setIsDataChanged", false);
    },
    // 初期表示時
    searchRadRequest({ dispatch, commit, state }, reqData) {
      dispatch("clearSearchedRadRequest");
      // 患者リストが空の場合は処理を抜ける
      if (!reqData.patIdList.length) return;

      return sendRequestPatRadMain(reqData).then(response => {
        // add #6479 デグレ：複数回の検査予定の丸の色が、治療予定があるにも関わらず、一定時間治療予定なしの色で表示される 鄭爽 start
        setTimeout(() => {
          // add #6479 デグレ：複数回の検査予定の丸の色が、治療予定があるにも関わらず、一定時間治療予定なしの色で表示される 鄭爽 end
          commit("setRadDateList", response.data.radDateList);
          commit("setRadDateTimeList", response.data.radDateTimeList);
          commit("setSaveRadRequestList", response.data.patRadMains);
          commit("setPatRadPatternList", response.data.patRadPatternList);
          commit("setPatTreatmentPatternList", response.data.patTreatmentPatternList);
          commit("setRadPatternColumnList", response.data.radPatternColumnList);
          commit("setRadPatternDetailColumnList", response.data.radPatternDetailColumnList);
          // add #6479 デグレ：複数回の検査予定の丸の色が、治療予定があるにも関わらず、一定時間治療予定なしの色で表示される 鄭爽 start
        }, 500);
        // add #6479 デグレ：複数回の検査予定の丸の色が、治療予定があるにも関わらず、一定時間治療予定なしの色で表示される 鄭爽 end
        commit("setPatUniqueList", response.data.patUniqueList);

        // 患者毎の透析予約日リストを格納
        const jsonList = response.data.ordMainTreatDateList.map(item => JSON.parse(item));
        commit("setOrdMainTreatDateList", jsonList);

        // 患者、検査セットごとの前回検査日リストを格納
        const lastDateList = response.data.lastRadDateList.map(item => JSON.parse(item));
        commit("setLastRadDateList", lastDateList);

        // 横軸の日付リスト
        const dateList = {};
        // 編集状態の日付リスト
        const editDateList = {};
        response.data.radDateList.forEach(radDate => {
          dateList[radDate] = 0;
          editDateList[radDate] = 1;
        });

        // 横軸の日時リスト
        const dateTimeList = {};
        // 編集状態の日時リスト
        const editDateTimeList = {};
        response.data.radDateTimeList.forEach(radDateTime => {
          dateTimeList[radDateTime] = 0;
          editDateTimeList[radDateTime] = 1;
        });

        // 検査依頼リスト(データ操作用JSON配列)作成
        const ListObj = [];
        reqData.patIdList.forEach(patId => {
          let exam_date = "";
          let ctr = "";
          response.data.patUniqueList.forEach(item => {
            if (item.pat_id !== patId) return;
            const physicalInfoList = JSON.parse(item.physical_info);
            if (!physicalInfoList.length) return;
            const foundInfo = physicalInfoList.find(info => info.exam_date !== "" && info.ctr !== null);
            if (foundInfo) {
              exam_date = moment(foundInfo.exam_date).format("YYYY/MM/DD");
              ctr = toFixed(foundInfo.ctr, 2);
            }
          });

          ListObj.push({
            patId,
            // コピーで日付リストを追加
            data: { ...dateList },
            dataDetail: { ...dateTimeList },
            editStatus: { ...editDateList },
            editStatusDetail: { ...editDateTimeList },
            // 検査セットのリスト
            // 1:透析前 2:透析後 0:その他 の順で表示
            // 一般撮影検査依頼には検査区分の指定はなく
            // すべて 0 が設定されているが、
            // 念のためすべての区分のデータを処理する形にしておく
            radItemSet: {
              "1": {},
              "2": {},
              "0": {},
            },
            exam_date,
            ctr,
          });
        });

        // 締切が有効な場合、締め切り日を取得する
        const deadlineDate = state.deadlineCondition.deadlineFlg
          ? getDeadlineDate(state.deadlineCondition)
          : null;

        // データを集計
        response.data.patRadMains.forEach(data => {
          const jsonObj = JSON.parse(data.orderRadSetInfo);
          const targetObj = ListObj.find(item => item.patId == data.patId);
          const strRadDateTime = `${data.strRadDate}_${data.strRadTime}`;

          // 日付の合計
          targetObj.data[data.strRadDate] += jsonObj.length;
          targetObj.dataDetail[strRadDateTime] += jsonObj.length;

          // 検査セットを追加
          jsonObj.forEach(obj => {
            const targetObjOrderClass = targetObj.radItemSet[data.regOrderClass];
            if (!targetObjOrderClass[obj.rad_set_cd]) {
              targetObjOrderClass[obj.rad_set_cd] = {
                name: obj.rad_set_name,
                data: {},
                dataDetail: {},
                time: {},
                lastDate: "",
                dateTime: [],
                status: {},
                statusDetail: {},
                isLock: {},
                // add #12462 患者情報共有 Ji start
                facilityCd: {},
                // add #12462 患者情報共有 Ji end
              };
            }
            const targetObjSetCd = targetObjOrderClass[obj.rad_set_cd];
            // フラグを入れる
            targetObjSetCd.data[data.strRadDate] = SAVED;
            targetObjSetCd.dataDetail[strRadDateTime] = SAVED;
            targetObjSetCd.time[data.strRadDate] = data.strRadTime;
            // add #12462 患者情報共有 Ji start
            targetObjSetCd.facilityCd[data.strRadDate] = data.facilityCd;
            // add #12462 患者情報共有 Ji end
            targetObjSetCd.dateTime.push(strRadDateTime);
            // 「結果あり」フラグ(同日に有効なフラグがあった場合はそちらを優先する)
            const dateStatus = targetObjSetCd.status[data.strRadDate];
            if (!dateStatus || dateStatus === "0") {
              targetObjSetCd.status[data.strRadDate] = data.radStatus;
            }
            targetObjSetCd.statusDetail[strRadDateTime] = data.radStatus;
            // 締切フラグ(締切は日単位で変動する為、日付毎のデータで持つ)
            if (state.deadlineCondition.deadlineFlg) {
              if (moment(deadlineDate).isAfter(data.strRadDate)) {
                // 締切を過ぎている
                targetObjSetCd.isLock[data.strRadDate] = "1";
              } else {
                // 締切を過ぎていない
                targetObjSetCd.isLock[data.strRadDate] = "0";
              }
            } else {
              // 締切が無効な場合は取得データを入れる
              targetObjSetCd.isLock[data.strRadDate] = data.isLock;
            }

            lastDateList.forEach(item => {
              if (item.radSetCd == obj.rad_set_cd && item.patId == targetObj.patId) {
                targetObjSetCd.lastDate = item.regRadDate;
              }
            });
          });
        });
        // 検査依頼リスト(データ操作用JSON配列)を保持
        commit("setEditRadRequestList", ListObj);
      });
    },
    // 保存
    async updateRecordList({ dispatch, state }, request) {
      const obj = {
        patRadMainList: request.request,
        isRadDetail: request.isRadDetail,
        patRadPatternList: state.savePatRadPattern,
        patExtInfoList: await dispatch("getUpdatePatExtInfoList"),
      };
      return sendRequestUpdateRecordList(obj);
    },
    // 検査セット一覧取得
    searchRadSetNameList({ commit }, facilityCd) {
      commit("setRadSetNameList", []);
      return sendRequestGetMstRadSetList(facilityCd).then(response => {
        commit("setRadSetNameList", response.data);
        return Promise.resolve(response.data);
      });
    },
    // 締切設定を施設設定から取得
    setRadDeadline({ commit }, facilityCd) {
      // 検査締切有無
      sendRequestGetMstFacilitySettingValue(facilityCd, RAD_DEADLINE).then(response => {
        commit("setDeadlineCondition", {
          code: RAD_DEADLINE,
          data: response.data === 1,
        });
      });
      // 検査依頼変更締切り日数
      sendRequestGetMstFacilitySettingValue(facilityCd, RAD_DEADLINE_DATE_COUNT).then(response => {
        commit("setDeadlineCondition", {
          code: RAD_DEADLINE_DATE_COUNT,
          data: response.data,
        });
      });
      // 検査依頼変更締切り時間
      sendRequestGetMstFacilitySettingValue(facilityCd, RAD_DEADLINE_TIME_COUNT).then(response => {
        const chkStr = "^(?:(?:[0-2][0-3])|(?:[0-1][0-9])):[0-5][0-9]$";
        const strResponse = String(response.data);
        const rtnTime = strResponse.match(chkStr) ? strResponse : "00:00";
        commit("setDeadlineCondition", {
          code: RAD_DEADLINE_TIME_COUNT,
          data: rtnTime,
        });
      });
    },
    // 検査セット一覧セット
    setRadSetNameList({ commit }, data) {
      commit("setRadSetNameList", data);
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
    updateRadSetTargetList({ commit }, data) {
      commit("setRadSetTargetList", data);
    },
    // mod #12462 患者情報共有 Ji start
    dayAllClear({ state }, {targetDate, facilityCd}) {
    // mod #12462 患者情報共有 Ji end
      state.editRadRequestList.forEach(pat => {
        // 一般撮影検査依頼には検査区分の指定はなく
        // すべて 0 が設定されているが、
        // 念のためすべての区分のデータを処理する形にしておく
        ["1", "2", "0"].reduce((allItem, regOrderClass) => {
          allItem.push(...Object.values(pat.radItemSet[regOrderClass]));
          return allItem;
        }, []).forEach(item => {
          const itemData = item.data;
          const status = itemData[targetDate];
          if (status == null) return;
          // add #12462 患者情報共有 Ji start
          const facility = item.facilityCd?.[targetDate];
          if (facility && facility !== facilityCd) return;
          // add #12462 患者情報共有 Ji end

          const dataDetail = item.dataDetail;
          const detailKeys = Object.keys(dataDetail);
          // 保存済み、且つ「結果なし」の場合に処理を実施する
          if (status === SAVED) {
            // 詳細データの件数を取得
            let savedCount = 0;
            detailKeys.forEach(detailKey => {
              if (!detailKey.startsWith(targetDate)) return;
              if (dataDetail[detailKey] === SAVED) {
                // 保存済みの場合
                dataDetail[detailKey] = CANCEL;
                savedCount++;
              }
            });
            // 中止
            itemData[targetDate] = CANCEL;
            pat.data[targetDate] -= savedCount;
          } else if (status === ADD || status === ADD_WARNING) {
            // 詳細データから対象日付の追加データ件数を取得し、追加データを詳細データから削除
            let addCount = 0;
            // 詳細データから対象日付の保存済データ件数を取得
            let savedCount = 0;
            detailKeys.forEach(detailKey => {
              if (!detailKey.startsWith(targetDate)) return;
              const detailStatus = dataDetail[detailKey];
              if (
                detailStatus === ADD
                || detailStatus === ADD_WARNING
              ) {
                // 追加の場合
                delete dataDetail[detailKey];
                addCount++;
              } else if (detailStatus === SAVED) {
                // 保存済みの場合
                dataDetail[detailKey] = CANCEL;
                savedCount++;
              }
            });

            // 未保存の依頼があった場合、削除する
            if (savedCount > 0) {
              itemData[targetDate] = CANCEL;
            } else {
              delete itemData[targetDate];
            }
            pat.data[targetDate] -= addCount + savedCount;
          }
        });
      });
      // state.editRadRequestListの要素内の情報を更新したリアクションを起こさせる
      state.editRadRequestList.splice();
    },
    // mod #12462 患者情報共有 Ji start
    // dayAllClearDetail({ state }, targetDateTime) {
    dayAllClearDetail({ state }, {targetDateTime, facilityCd}) {
    // mod #12462 患者情報共有 Ji end
      state.editRadRequestList.forEach(pat => {
        // 一般撮影検査依頼には検査区分の指定はなく
        // すべて 0 が設定されているが、
        // 念のためすべての区分のデータを処理する形にしておく
        ["1", "2", "0"].reduce((allItem, regOrderClass) => {
          allItem.push(...Object.values(pat.radItemSet[regOrderClass]));
          return allItem;
        }, []).forEach(item => {
          // add #12462 患者情報共有 Ji start
          const targetDate = targetDateTime.slice(0, 8)
          const itemFacilityCd = item.facilityCd?.[targetDate]
          if (itemFacilityCd && itemFacilityCd !== facilityCd) return
          // add #12462 患者情報共有 Ji end
          const dataDetail = item.dataDetail;
          const status = dataDetail[targetDateTime];
          if (status == null) return;
          if (status === SAVED) {
            // 中止
            dataDetail[targetDateTime] = CANCEL;
            pat.dataDetail[targetDateTime]--;
          } else if (status === ADD || status === ADD_WARNING) {
            // 保存前の場合は削除
            delete dataDetail[targetDateTime];
            pat.dataDetail[targetDateTime]--;
          }
        });
      });
      // state.editRadRequestListの要素内の情報を更新したリアクションを起こさせる
      state.editRadRequestList.splice();
    },
    // 指定患者、日付の編集状態を更新
    updateEditScheduleStatusStore({ state }, targetDate) {
      // チェックされている患者でループ
      targetDate.radSetTargetList.forEach(targetId => {
        // 該当患者のデータセットを取得
        const targetObj = state.editRadRequestList.find(item => item.patId === targetId);
        if (!targetObj) return;

        // 一般撮影検査依頼には検査区分の指定はなく
        // すべて 0 が設定されているが、
        // 念のためすべての区分のデータを処理する形にしておく
        const allItem = [];
        ["0", "1", "2"].forEach(regOrderClass => {
          allItem.push(...Object.values(targetObj.radItemSet[regOrderClass]));
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

        // 対象日時に対して処理を実施
        targetDate.targetDateTimeList.forEach(setDateTime => {
          // status が SAVED 以外なら取得
          const editStatusDetailList = [];
          allItem.forEach(item => {
            const status = item.dataDetail[setDateTime];
            if (status == null || status === SAVED) return;
            editStatusDetailList.push(status);
          });
          // SAVED 以外の status が存在していた場合は最大値を取得
          const finalStatus = editStatusDetailList.length ? Math.max(...editStatusDetailList) : SAVED;
          targetObj.editStatusDetail[setDateTime] = finalStatus;
        });
      });
      // state.editRadRequestListの要素内の情報を更新したリアクションを起こさせる
      state.editRadRequestList.splice();
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
    // 患者IDフラグを更新する
    setIsShowHospPatId({ commit }, isShowHospPatId) {
      commit("setIsShowHospPatId", isShowHospPatId);
    },
    // 前回検査日フラグを更新する
    setIsShowLastRadDate({ commit }, isShowLastRadDate) {
      commit("setIsShowLastRadDate", isShowLastRadDate);
    },
    // モバイル端末表示フラグを更新する
    setAndroidOrIOS({ commit }, IsAndroidOrIOS) {
      commit("setAndroidOrIOS", IsAndroidOrIOS);
    },
    // 変更フラグ
    setIsDataChanged({ commit }, isDataChanged) {
      commit("setIsDataChanged", isDataChanged);
    },
    // 検査パターンリスト
    setPatRadPatternList({ commit }, patRadPatternList) {
      commit("setPatRadPatternList", patRadPatternList);
    },
    // 依頼条件
    setCommonConditionList({ commit }, conditionList) {
      commit("setCommonConditionList", conditionList);
    },
    setSelectedCalendar({ commit }, selectedCalendar) {
      commit("setSelectedCalendar", selectedCalendar);
    },
    // 検査パターンの横軸リスト
    setRadPatternColumnList({ commit }, radPatternColumnList) {
      commit("setRadPatternColumnList", radPatternColumnList);
    },
    // 検査パターンの横軸リスト(患者個別用)
    setRadPatternDetailColumnList({ commit }, radPatternDetailColumnList) {
      commit("setRadPatternDetailColumnList", radPatternDetailColumnList);
    },
    // 身体情報
    setPatUniqueList({ commit }, patUniqueList) {
      commit("setPatUniqueList", patUniqueList);
    },
    // 保存用検査パターンリスト
    setSavePatRadPattern({ commit }, savePatRadPattern) {
      commit("setSavePatRadPattern", savePatRadPattern);
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
    // 子画面に表示する患者ID
    setCheckedPatId({ commit }, checkPatId) {
      commit("setCheckPatId", checkPatId);
    },
    setTreatBaseDate({ commit }, treatBaseDate) {
      commit("setTreatBaseDate", treatBaseDate);
    },
    setCalendarCheckedDate({ commit }, calendarCheckedDate) {
      commit("setCalendarCheckedDate", calendarCheckedDate);
    },
    setOutsideSchExtPatList({ commit }, outsideSchExtPatList) {
      commit("setOutsideSchExtPatList", outsideSchExtPatList);
    },
  },
};
