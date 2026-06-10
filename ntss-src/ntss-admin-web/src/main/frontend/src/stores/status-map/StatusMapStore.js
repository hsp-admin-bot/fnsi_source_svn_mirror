/**
 * 治療状況マップ用ストア
 */
//@ts-check

import { sendRequestGetBedLayoutList } from "@/apis/mst-bedLayout";
import {
  sendRequestGetStatusLayout,
  sendRequestGetMntMachineState
} from "@/apis/status-list";
// add #6940 2022/8/18 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou start
import store from "@/stores";
// add #6940 2022/8/18 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou end
import {
  sendRequestGetKur,
  sendRequestGetTreatmentStatusMapMachine,
  sendRequestGetOnscheduleTreatmentStatusList,
  sendRequestGerStatusMapInfo,
  sendRequestGetOrdSchedule,
  sendRequestGetLastestDialysisState,
  sendRequestCheckBeforeMoveOrdMain,
  sendRequestPutAssignScheduleOrdMain,
  sendRequestPutMoveScheduleOrdMain,
  sendRequestPutSwapScheduleOrdMain,
  sendRequestPutUnassigmentScheduleOrdMain,
  sendRequestPostCancelCondition,
  sendRequestPutSendConditionCancel,
  sendRequestGetOrdMainByOrdNo,
  sendRequestGetOrdMainListByOrdNo
} from "@/apis/status-map";
import { sendRequestGetKurSelector } from "@/apis/send-condition";
import statusCommonFunctions from "@/components/status-list/StatusCommonFunction";
import moment from "moment";
import { MACHINE_MODEL } from "@/constants/machineModel";
import { deepCopy } from "@/functions/common/CommonFunctions";
import {
  DIALISYS_STATE,
  MACHINE_ENTRY_STATE
} from "@/constants/statusMapConstants";
import { KEY_NAME_STATUS_MAP } from "@/constants/defaultSettingConstants";
import { ApiHelper } from "@/apis/AxiosHelper";
import { isDisp } from "@/components/status-list/list-map-common/listMapCommonFunction";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 施設コード
    facilityCd: null,
    // NOTE: 何に使っている？真だと何？偽だと何？
    displayNameFlag: true,
    // 治療状況データリスト
    treatmentStatusList: null,
    treatmentScheduleList: null,
    // 全画面モードフラグ
    isDisplayFullMode: false,
    // 画面モードフラグ
    isTreatStateMode: null,
    // 治療状況マップアイコン設定情報
    statusMapInfo: null,
    // 選択中の治療状況データ
    selectedTreatmentSchedule: null,
    // クール詳細一覧(時間が必要な場合の処理用)
    mstKurList: [],
    // 治療状況一覧
    machineStatusList: [],
    // オーダ情報
    ordMainList: [],
    // 検索条件(ログイン中保持する必要があるので、storeに持つ)
    // 検索ヘッダー向けデータ
    findState: {
      // 選択候補
      candidate: {
        // クール一覧
        kurList: [],
        comboKurList: [],
        // ベッドグループリスト
        bedGroupList: [],
        comboBedGroupList: [],
        // 治療状況レイアウトのリスト
        statusLayoutList: [],
        // 治療項目レイアウト（コンボボックス表示用）格納
        comboLayoutItemList: [],
        // ベッドレイアウトのリスト(複数のレイアウトが存在する。)
        bedLayoutList: [],
        // 指示者のリスト
        instructorList: []
      },
      conditionTreatMap: {
        kurCd: "",
        roomBedGroupCd: 0,
        statusLayoutNo: "",
        // 次患者表示
        nextPatValue: 2,
        isClear: true,
        bedLayoutId: "",
        // 予定日
        currentDateTime: new Date(),
        // 指示者
        userId: ""
      },
      filterSignal: false,
    },
    // add FNSI-警報・報知追加 付 start
    alarmData: {},
    // add FNSI-警報・報知追加 付 end
    // デフォルト設定反映判定用フラグ
    initFlg: true,
    //add FNSI redmine5436 fang start
    showFlg: false,
    //add FNSI redmine5436 fang end
    ordMainAndTreatmentStatus: {
      machineStatusList: null,
      ordMainList: [],
      treatmentStatusList: {},
      statusMapInfo: []
    },
    // レイアウトの状態
    layoutState: {
      // レイアウトの位置
      targetTransForm: {
        x: 0,
        y: 0
      },
      // スライダーの倍率
      sliderVal: 0
    },
    // 強制サインアウトフラグ (0:自動サインアウトする、1:自動サインアウトしない)
    forceSignOutFlag: 0,
  },
  mutations: {
//add 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 start
    clearConditionTreatMap(state) {
      state.initFlg = true;
    },
//add 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 end
    /**
     * 全画面モードのセット
     */
    setDisplayFullMode(state, flag) {
      state.isDisplayFullMode = flag;
    },
    /**
     * 画面モードのセット
     */
    setTreatStateMode(state, flag) {
      if (state.isTreatStateMode !== flag) {
        state.isTreatStateMode = flag;
        state.ordMainAndTreatmentStatus.treatmentStatusList = null;
      }
    },
    /**
     * クール詳細リストをセット
     * @param {*} state
     * @param {*} mstKurList
     */
    setMstKurList(state, mstKurList) {
      state.mstKurList = mstKurList.map(dat => {
        return {
          kurName: dat.kurName,
          kurCd: dat.kurCd,
          kurStartTime: dat.kurStartTime,
          kurEndTime: dat.kurEndTime,
          kurStandardStartTime: dat.kurStandardStartTime
        };
      });
    },
    /**
     * クールリストをセット
     */
    setKurList(state, kurList) {
      // mod FNSI-マスタ削除修正 付 start
      // state.findState.candidate.kurList = kurList.map(dat => {
      //   return {
      //     kurName: dat.name,
      //     kurCd: dat.code
      //   };
      // });
      state.findState.candidate.kurList = state.mstKurList.map(dat => {
        return {
          kurName: dat.kurName,
          kurCd: dat.kurCd
        };
      });
      // mod FNSI-マスタ削除修正 付 end
      if (kurList.length > 0) {
        const comboList = deepCopy(state.findState.candidate.kurList);
        state.findState.candidate.comboKurList = comboList;
      } else {
        state.findState.candidate.comboKurList = [];
      }
    },
    /**
     * クールをセット
     */
    setKur(state, kurCd) {
      const selectedKur = state.findState.candidate.comboKurList.find(
        dat => `${dat.kurCd}` === `${kurCd}`
      );
      if (selectedKur) {
        state.findState.conditionTreatMap.kurCd = selectedKur.kurCd;
      } else if (state.findState.candidate.comboKurList.length > 0) {
        state.findState.conditionTreatMap.kurCd =
          state.findState.candidate.comboKurList[0].kurCd;
      } else {
        state.findState.conditionTreatMap.kurCd = "";
      }
    },
    /**
     * ベッドグループリストをセット
     */
    setBedGroupList(state, bedGroupList) {
      const allBed = {
        roomBedGroupName: "すべて",
        roomBedGroupCd: 0
      };
      bedGroupList = bedGroupList.map(dat => {
        dat.bedList = dat.bedList ? JSON.parse(dat.bedList) : [];
        return dat;
      });
      state.findState.candidate.bedGroupList = bedGroupList;
      if (bedGroupList.length > 0) {
        const comboList = bedGroupList.map(dat => {
          return {
            roomBedGroupName: dat.roomBedGroupName,
            roomBedGroupCd: dat.roomBedGroupCd
          };
        });
        comboList.unshift(allBed);
        state.findState.candidate.comboBedGroupList = comboList;
      } else {
        state.findState.candidate.comboBedGroupList = [allBed];
      }
    },
    /**
     * ベッドグループをセット
     */
    setBedGroup(state, roomBedGroupCd) {
      const selectedBedGroup = state.findState.candidate.comboBedGroupList.find(
        dat => `${dat.roomBedGroupCd}` === `${roomBedGroupCd}`
      );
      state.findState.conditionTreatMap.roomBedGroupCd = selectedBedGroup
        ? selectedBedGroup.roomBedGroupCd
        : 0;
    },
    /**
     * ステータスレイアウトリストをセット
     */
    setStatusLayoutList(state, statusLayoutList) {
      state.findState.candidate.statusLayoutList = statusLayoutList.filter(
        dat => dat.useClass === statusCommonFunctions.constant.useClass.map
      );
    },
    /**
     * ステータスレイアウトをセット
     */
    setStatusLayout(state, layoutNo) {
      const selectedLayout = state.findState.candidate.statusLayoutList.find(
        dat => `${dat.layoutNo}` === `${layoutNo}`
      );
      if (selectedLayout) {
        state.findState.conditionTreatMap.statusLayoutNo =
          selectedLayout.layoutNo;
      } else if (state.findState.candidate.statusLayoutList.length > 0) {
        state.findState.conditionTreatMap.statusLayoutNo =
          state.findState.candidate.statusLayoutList[0].layoutNo;
      } else {
        state.findState.conditionTreatMap.statusLayoutNo = "";
      }
    },
    /**
     * ベッドレイアウトリストをセット
     */
    // mod #8118 2022/12/06 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou start
    // setBedLayoutList(state, payload) {
    //   state.findState.candidate.bedLayoutList = payload.bedLayoutList
    //     .filter(dat => dat.isDel !== "1" && dat.isDisp !== "0")
    //     .map(dat => {
    //       dat.bedLayout.obj_list = dat.bedLayout.obj_list.filter(
    //         obj =>
    //           // 装置区分、シリアル番号のある装置のみを対象とする
    //           obj.machine_serial && obj.machine_type_cd
    //       );
    //       return dat;
    //     })
    // },
    setBedLayoutList(state, payload) {
      const isDispMachines = payload.isDispMachines || [];
      state.findState.candidate.bedLayoutList = payload.bedLayoutList
        .filter(dat => dat.isDel !== "1" && dat.isDisp !== "0")
        .map(dat => {
          dat.bedLayout.obj_list = dat.bedLayout.obj_list.filter(
            obj => {
              // 装置区分、シリアル番号のある装置のみを対象とする
              if (!obj.machine_serial || !obj.machine_type_cd) {
                return false;
              }
              if (isDispMachines.length > 0) {
                if (isDispMachines.some(x => x.machineNo == obj.machine_no
                  && x.machineSerial == obj.machine_serial
                  && x.machineTypeCd == obj.machine_type_cd)) {
                  return true;
                }
              }
              return false;
            }
          );
          return dat;
        })
    },
    // mod #8118 2022/12/06 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou start
    /**
     * ベッドレイアウトをセット
     */
    setBedLayout(state, bedLayoutId) {
      const selectedLayout = state.findState.candidate.bedLayoutList.find(
        dat => `${dat.layoutId}` === `${bedLayoutId}`
      );
      if (selectedLayout) {
        state.findState.conditionTreatMap.bedLayoutId = selectedLayout.layoutId;
      } else if (state.findState.candidate.bedLayoutList.length > 0) {
        state.findState.conditionTreatMap.bedLayoutId =
          state.findState.candidate.bedLayoutList[0].layoutId;
      } else {
        state.findState.conditionTreatMap.bedLayoutId = "";
      }
    },
    /**
     * 指示者リストをセット
     */
    setInstructorList(state, instructorList) {
      state.findState.candidate.instructorList = instructorList;
    },
    /**
     * 指示者をセット
     */
    setInstructor(state, userId) {
      state.findState.conditionTreatMap.userId = userId;
    },
    /**
     * 次患者
     */
    setNextPatValue(state, nextPatValue) {
      state.findState.conditionTreatMap.nextPatValue = nextPatValue;
    },


    /**
     * 装置状況データリストをセット
     */
    setMachineState(state, machineState) {
      state.machineStatusList = machineState;
    },
    /**
     * 治療状況データリストをセット
     */
    setTreatmentStatusList(state, treatmentStatues) {
      state.treatmentStatusList = treatmentStatues;
    },
    setTreatmentScheduleList(state, treatmentScheduleList) {
      state.treatmentScheduleList = treatmentScheduleList;
    },
    /**
     * 起点日付時刻をセット(治療状況)
     */
    setCurrentDateTime(state, dateTime) {
      state.findState.conditionTreatMap.currentDateTime = dateTime;
    },
    /**
     * 更新指示
     * @param {*} state state
     * @param {boolean} signal 更新する際にシグナルを立てる
     */
    setFilterSignal(state, signal) {
      state.findState.filterSignal = signal;
    },
    setIsClear(state, isClear) {
      state.findState.conditionTreatMap.isClear = isClear;
    },
    setTreatCondition(state, payload) {
      state.findState.conditionTreatMap = payload.conditionTreatMap;
    },
    /**
     * 治療状況マップアイコン設定情報をセット
     */
    setStatusMapInfo(state, payload) {
      // どの指示の情報か判断がつかないので、ordNoをセット
      state.statusMapInfo = payload;
    },
    selectTreatmentStatus(state, payload) {
      state.selectedTreatmentSchedule = payload;
    },
    clearCondition(state, condition) {
      state.findState.conditionTreatMap.roomBedGroupCd = condition.roomBedGroupCd;
      state.findState.conditionTreatMap.statusLayoutNo = condition.statusLayoutNo;
      state.findState.conditionTreatMap.bedLayoutId = condition.bedLayoutId;
      state.findState.conditionTreatMap.kurCd = condition.kurCd;
      state.findState.conditionTreatMap.nextPatValue = condition.nextPatValue;

      state.findState.conditionTreatMap.isClear = true;
    },
    setFacilityCd(state, facilityCd) {
      state.facilityCd = facilityCd;
    },
    setOrdMainList(state, ordMainList) {
      state.ordMainList = ordMainList;
    },
    // add FNSI-警報・報知追加 付 start
    setAlarmData(state, alarmData) {
      state.alarmData = alarmData;
    },
    // add FNSI-警報・報知追加 付 end
    //add FNSI redmine5436 fang start
    setShowFlg(state, flag) {
      state.showFlg = flag;
    },
    //add FNSI redmine5436 fang end
    setOrdMainAndTreatmentStatus(state, ordMainAndTreatmentStatus) {
      state.ordMainAndTreatmentStatus = ordMainAndTreatmentStatus;
    },
    /**
     * レイアウトの状態を設定
     * @param {*} state
     * @param {Object} layoutState レイアウトの状態
     */
    setLayoutState(state, layoutState) {
      state.layoutState = layoutState;
    },
    setForceSignOutFlag(state, forceSignOutFlag) {
      state.forceSignOutFlag = forceSignOutFlag;
    },
  },
  actions: {
    /**
     * stateを初期化する
     */
    async initState({ dispatch, commit, state }, { facilityCd, defaultCondition, layoutNumbers }) {
      await store.dispatch("loading-screen/setLoadingScreenVisible", true);
      await commit("setFacilityCd", facilityCd);
      // DBから各リストを取得（クール、ベッドグループ、治療状況レイアウト、ベッドレイアウト）
      await dispatch("fetchKur");
      await dispatch("fetchKurBedGroup");
      await dispatch("fetchStatusLayoutList");
      await dispatch("fetchBedLayoutList");
      // // ベッドレイアウトを選択する箇所を指定されていないので、とりあえず一番目のレイアウトを使用
      // await dispatch("setBedLayout", 3);

      // レイアウト
      if (`${state.findState.conditionTreatMap.statusLayoutNo}` === "") {
        const layout = state.findState.candidate.statusLayoutList[0];
        if (layout !== null && layout !== undefined) {
          await dispatch("setStatusLayout", layout.layoutNo);
        }
      }

      // add FNSI-redmine#4278 付 start
    　if (defaultCondition !== undefined || layoutNumbers !== undefined) {
      // add FNSI-redmine#4278 付 end
          // 初回画面表示時のみデフォルト設定を適用
          if (state.initFlg) {
            if (defaultCondition) {
              if (defaultCondition[KEY_NAME_STATUS_MAP.KEY_NAME_BED_LAYOUT_ID] !== null) {
                await dispatch(
                  "setBedLayout",
                  defaultCondition[KEY_NAME_STATUS_MAP.KEY_NAME_BED_LAYOUT_ID]
                );
              }
              if (defaultCondition[KEY_NAME_STATUS_MAP.KEY_NAME_NEXT_PAT_VALUE] !== null) {
                state.findState.conditionTreatMap.nextPatValue = defaultCondition[KEY_NAME_STATUS_MAP.KEY_NAME_NEXT_PAT_VALUE];
              }
              if (defaultCondition[KEY_NAME_STATUS_MAP.KEY_NAME_STATUS_LAYOUT_NO] !== null) {
                await dispatch(
                  "setStatusLayout",
                  defaultCondition[KEY_NAME_STATUS_MAP.KEY_NAME_STATUS_LAYOUT_NO]
                );
              }
              if (defaultCondition[KEY_NAME_STATUS_MAP.KEY_NAME_BED_GROUP_CD] !== null) {
                const roomBedGroupCd = defaultCondition[KEY_NAME_STATUS_MAP.KEY_NAME_BED_GROUP_CD];
                const bedGroupExists = state.findState.candidate.comboBedGroupList.some(
                  rbr => +rbr.roomBedGroupCd === +roomBedGroupCd
                );
                await dispatch("setBedGroup", bedGroupExists ? roomBedGroupCd : 0);
              }
              if (defaultCondition[KEY_NAME_STATUS_MAP.KEY_NAME_KUR_CD] !== null) {
                await dispatch(
                  "setKur",
                  defaultCondition[KEY_NAME_STATUS_MAP.KEY_NAME_KUR_CD]
                );
              }
            }
            // 遷移時にレイアウト番号、ベッドレイアウト番号が指定されていれば適用
            if (layoutNumbers) {
              if (layoutNumbers.LAYOUTNO) {
                await dispatch(
                  "setStatusLayout",
                  Number.parseInt(layoutNumbers.LAYOUTNO)
                );
              }
              if (layoutNumbers.BEDLAYOUTNO) {
                await dispatch(
                  "setBedLayout",
                  Number.parseInt(layoutNumbers.BEDLAYOUTNO)
                );
              }
            }
          state.initFlg = false;
        }
      }

      // 治療状況を再取得
      await dispatch("reFetchTreatmentStatus");
      await store.dispatch("loading-screen/setLoadingScreenVisible", false);
    },
    /**
     * 全画面モードのセット
     */
    setDisplayFullMode({ state, commit }) {
      commit("setDisplayFullMode", !state.isDisplayFullMode);
    },
    /**
     * 画面モードのセット
     */
    async setTreatStateMode({ commit }, flag) {
      await commit("setTreatStateMode", flag);
    },

    /**
     * クール詳細情報一覧の取得
     */
    async fetchKur({ state, commit }) {
      // 一覧取得
      try {
        const response = await sendRequestGetKur(state.facilityCd);
        // 取得したクール一覧情報をセット
        commit("setMstKurList", response.data);
      } catch (err) {
        console.error(err);
      }
    },

    /**
     * クールとベッドの一覧取得
     */
    async fetchKurBedGroup({ state, commit }) {
      // クールとベッドの一覧取得
      try {
        const response = await sendRequestGetKurSelector();
        // 取得したクール一覧情報をセット
        commit("setKurList", response.data.kurSelector);

        // 初期選択設定
        commit("setKur", state.findState.conditionTreatMap.kurCd);

        // 取得したベッドグループ一覧情報をセット
        commit("setBedGroupList", response.data.bedGroupList);
        commit("setBedGroup", state.findState.conditionTreatMap.roomBedGroupCd);
      } catch (err) {
        console.error(err);
      }
    },
    /**
     * クールをセット
     */
    setKur({ state, commit }, kurCd) {
      commit("setKur", kurCd);
    },
    /**
     * ベッドグループをセット
     */
    async setBedGroup({ state, commit }, roomBedGroupCd) {
      await commit("setBedGroup", roomBedGroupCd);
    },
    /**
     * ステータスレイアウトリストを取得
     */
    async fetchStatusLayoutList({ commit, state }) {
      const response = await sendRequestGetStatusLayout();
      if (
        response.status === 200
        // response.status === 200 &&
        // response.data.length > 0 &&
        // response.data[0] !== null
      ) {
        await commit("setStatusLayoutList", response.data);
        const currentLayoutNo = state.findState.conditionTreatMap.statusLayoutNo;
        if (currentLayoutNo !== null && currentLayoutNo !== undefined && `${currentLayoutNo}` !== "") {
          await commit("setStatusLayout", currentLayoutNo);
        } else if (state.findState.candidate.statusLayoutList.length > 0) {
          await commit(
            "setStatusLayout",
            state.findState.candidate.statusLayoutList[0].layoutNo
          );
        }
      }
    },
    /**
     * ステータスレイアウトを設定
     */
    async setStatusLayout({ commit, state }, layoutNo) {
      await commit("setStatusLayout", layoutNo);
    },
    /**
     * 当該施設のベッドレイアウトリストを取得
     */
    async fetchBedLayoutList({ commit, dispatch, state }) {
      const layoutResponse = await sendRequestGetBedLayoutList(
        state.facilityCd
      );
      const machineMasterResponse = await ApiHelper.get(`/machines/mst_machine/${state.facilityCd}`)
        .then(response => response.data)
        .catch(error => {
          throw error;
        });
      let isDispMachines = [];
      if (Array.isArray(machineMasterResponse) && machineMasterResponse.length > 0) {
        isDispMachines = machineMasterResponse.filter(x => x.isDisp == "1");
      }
      // ベッドコードを取得するために、mnt_machine_stateからデータを取得
      const machineStateList = await dispatch("fetchMachineState");
      if (
        layoutResponse.status === 200
        // layoutResponse.status === 200 &&
        // layoutResponse.data.length > 0 &&
        // layoutResponse.data[0] !== null &&
        // machineStateList.length > 0
      ) {
        // bedLayoutを展開
        const bedLayoutList = layoutResponse.data.map(dat => {
          dat.bedLayout = JSON.parse(dat.bedLayout);
          return dat;
        });
        await commit("setBedLayoutList", {
          bedLayoutList: bedLayoutList,
          machineStateList: machineStateList,
          isDispMachines: isDispMachines
        });
        const currentLayoutId = state.findState.conditionTreatMap.bedLayoutId;
        if (currentLayoutId !== null && currentLayoutId !== undefined && `${currentLayoutId}` !== "") {
          await commit("setBedLayout", currentLayoutId);
        } else if (state.findState.candidate.bedLayoutList.length > 0) {
          await commit(
            "setBedLayout",
            state.findState.candidate.bedLayoutList[0].layoutId
          );
        }
      }
    },
    /**
     * 当該施設のベッドレイアウトリストを取得
     */
    async setBedLayout({ state, commit }, layoutId) {
      await commit("setBedLayout", layoutId);
    },
    /**
     * 装置状況を取得
     */
    async fetchMachineState({ state }, autoRefreshFlag) {
      !autoRefreshFlag && store.dispatch("loading-screen/startLoadingScreen");
      const response = await sendRequestGetMntMachineState(state.facilityCd).finally(() => {
        !autoRefreshFlag && store.dispatch("loading-screen/finishLoadingScreen");
      });
      if (
        response.status === 200
        // response.status === 200 &&
        // response.data.length > 0 &&
        // response.data[0] !== null
      ) {
        return response.data;
      } else {
        return null;
      }
    },
    /**
     * 指示者一覧を設定
     */
    async setInstructorList({ commit }, instructorList) {
      await commit("setInstructorList", instructorList);
    },
    /**
     * 指示者を設定
     */
    async setInstructor({ commit }, instructor) {
      await commit("setInstructor", instructor);
    },
    /**
     * 治療状況データを取得
     */
    async fetchTreatmentStatus(
      { commit, dispatch, state },
      { treatDate, layoutNo, autoRefreshFlag, roomBedGroupCd, nextPat, bedLayoutId, kurCd}
    ) {
      let response;
      if (
        treatDate &&
        treatDate !== "" &&
        layoutNo !== null &&
        layoutNo !== undefined &&
        layoutNo !== ""
      ) {

        // 装置状況
        response = await dispatch("fetchMachineState", autoRefreshFlag)
        let machineStatusList;
        if (response !== null) {
          machineStatusList = response;
        }

        // 治療記録
        if (state.isTreatStateMode) {
          response = await sendRequestGetTreatmentStatusMapMachine({
            facilityCd: state.facilityCd,
            treatDate: treatDate,
            layoutNo: layoutNo,
            bedGroupCd: roomBedGroupCd,
            nextPat : nextPat,
            bedLayoutId : bedLayoutId == "" ? -1 : bedLayoutId
          }, autoRefreshFlag);
        } else {
          response = await sendRequestGetOnscheduleTreatmentStatusList({
            facilityCd: state.facilityCd,
            treatDate: treatDate,
            layoutNo: layoutNo,
            bedGroupCd: roomBedGroupCd,
            bedLayoutId : bedLayoutId == "" ? -1 : bedLayoutId,
            kurCd : kurCd
          }, autoRefreshFlag);
        }
        let treatmentStatusList = {}, ordMainList, statusMapInfo;
        if (response.status === 200 && response.data) {
          treatmentStatusList = response.data;
          // アイコン情報は治療状況と同時に取得する必要がある
          if (response.data.dcs) {
            const ordNoArray = response.data.dcs.filter(dat => dat.ordNo).map(dat => dat.ordNo)
            if (ordNoArray?.length > 0) {
              const res = await sendRequestGerStatusMapInfo(ordNoArray, autoRefreshFlag);
              if (res?.status === 200) {
                statusMapInfo = res.data;
              }
            }
          }
          if (response.data.dcs) {
            let ordNoList = [];
            for (const treatmentData of response.data.dcs) {
              if (treatmentData.ordNo || treatmentData.ordNo === 0) {
                ordNoList.push(treatmentData.ordNo);
              }
            }
            if(ordNoList.length > 0)
            {
              ordMainList = await getOrdMainListByOrdNo({
                ordNos: ordNoList,
                autoRefreshFlag
              });
            }
          }
        }
        commit("setOrdMainAndTreatmentStatus", {
          machineStatusList,
          ordMainList,
          treatmentStatusList,
          statusMapInfo
        });
        dispatch(state.isTreatStateMode ? "getTreatmentStatusList" : "getTreatmentScheduleList", state.ordMainAndTreatmentStatus, autoRefreshFlag);
      }

    },
    /**
     * 治療状況マップアイコン設定情報
     */
    // async fetchStatusMapInfo({ commit }, ordNoArray) {
    //   if (ordNoArray.length > 0) {
    //     const response = await sendRequestGerStatusMapInfo(ordNoArray);
    //     // console.log("fetchStatusMapInfo/response is %o", response);
    //     if (response.status === 200 && typeof response.data !== "undefined") {
    //       await commit("setStatusMapInfo", response.data);
    //     }
    //   }
    // },
    /**
     * 日付時刻のセット(治療状況)
     */
    async setCurrentDateTime({ commit }, datetime) {
      await commit("setCurrentDateTime", datetime);
    },
    /**
     * 更新指示
     * @param {*} state state
     * @param {boolean} signal 更新する際にシグナルを立てる
     */
    async setFilterSignal({ commit }, signal) {
      await commit("setFilterSignal", signal);
      await commit("selectTreatmentStatus", null);
    },
    /**
     * 治療状況：抽出条件クリア
     */
    async clearCondition({ commit }, condition) {
      await commit("clearCondition", condition);
      await commit("setBedGroup", condition.roomBedGroupCd);
      await commit("setBedLayout", condition.bedLayoutId);
      await commit("setStatusLayout", condition.statusLayoutNo);
      await commit("setKur", condition.kurCd);
    },
    /**
     * 治療状況：抽出条件セット
     */
    async conditionSet({ commit, dispatch }, condition) {
      // 抽出条件情報をセットする
      await dispatch("setKur", condition.kurCd);
      await dispatch("setBedGroup", condition.roomBedGroupCd);
      await dispatch("setStatusLayout", condition.layoutNo);
      await commit("setNextPatValue", condition.nextPatValue);
      await dispatch("setBedLayout", condition.layoutId);
      await commit("setIsClear", false);
      await dispatch("setCurrentDateTime", condition.currentDateTime);
      await dispatch("setInstructor", condition.userId);
    },

    /**
     * 指定ベッドの空き状態取得
     * @returns true：割り当てなし(空き)/false：割り当てあり
     */
    async checkEmptyBed(context, { treatDate, kurCd, bedCd
      //add FNSI redmine 6588 劉祥霖　start
      // mod/ #12465同患者同日同治療方法同クールの使用制限をしてもメッセージがでない tianqidong start
      ,facilityCd,ordNo,patId,indTreatmentCd
      //add FNSI redmine 6588 劉祥霖　end
    }) {
      let ret = false;
      // 一覧取得
      await sendRequestGetOrdSchedule(
        treatDate
        , kurCd
        , bedCd
        //add FNSI redmine 6588 劉祥霖　start
        ,facilityCd,ordNo,patId
        //add FNSI redmine 6588 劉祥霖　end
        ,indTreatmentCd
        // mod/ #12465同患者同日同治療方法同クールの使用制限をしてもメッセージがでない tianqidong end
      ).then(response => {
        //mod FNSI redmine 6588 劉祥霖　start
        // if (response.data.length == 0) {
        //   ret = true;
        // }
        ret = response.data.msgCd;
        //mod FNSI redmine 6588 劉祥霖　end
      })
        .catch(err => {
          console.error(err);
        });
      return ret;
    },

    /**
     * スケジュールモードでの装置へのアクション
     * （治療情報への割り当ての変更）
     */
    async actionTreatmentSchedule(
      { state, commit, dispatch },
      treatmentSchedule
    ) {
      let isSuccess = false;
      const selectedSchedule = state.selectedTreatmentSchedule;
      if (selectedSchedule?.treatment.ordNo) {
        if (!treatmentSchedule?.treatment?.ordNo) {
          // 最新の治療状況取得
          const rstDialysisState = await getLastestDialysisState({
            treatDate: selectedSchedule.treatment.treatDate,
            kurCd: selectedSchedule.treatment.kurCd,
            bedCd: selectedSchedule.treatment.bedCd,
            ordNo: selectedSchedule.treatment.ordNo
          });
          // 治療状態判定
          if (rstDialysisState === "") {
            // スケジュール変更あり
            return false;
          } else if (rstDialysisState >= DIALISYS_STATE.AFTER_SEND_CONDITION) {
            // 条件送信済み以降

            // 条件送信キャンセル[デバイスエッジへの通知]
            await sendRequestPostCancelCondition({
              ordNo: state.selectedTreatmentSchedule.treatment.ordNo,
              machineNo: state.selectedTreatmentSchedule.bedLayout.machine_no,
              facilityCd: state.facilityCd
            });
            // 条件送信キャンセル[DB関連処理]
            await sendRequestPutSendConditionCancel(
              state.selectedTreatmentSchedule.treatment.bedCd
            );
          }

          // 治療状況判定
          // 治療データを選択中で、空白ベッドを選択した場合ベッドを移動する
          await sendRequestPutMoveScheduleOrdMain({
            facilityCd: state.facilityCd,
            ordNo: state.selectedTreatmentSchedule.treatment.ordNo,
            bedCd: treatmentSchedule.bedLayout.bed_cd,
            userId: state.findState.conditionTreatMap.userId,
            isSendCondition: "0" // 条件再送信はしない
          });
          isSuccess = true;

          await commit("selectTreatmentStatus", null);
          await dispatch("reFetchTreatmentStatus");
        } else if (
          treatmentSchedule.treatment.ordNo ===
          state.selectedTreatmentSchedule.treatment.ordNo
        ) {
          // 二回同じ治療データを選ぶと選択を解除する
          await commit("selectTreatmentStatus", null);
          isSuccess = true;
        } else {
          // 治療データを選択中で、治療データが割り当てられているベッドを選択した場合ベッドを入れ替える
          // 最新の治療状況取得
          const rstDialysisState1 = await getLastestDialysisState({
            treatDate: selectedSchedule.treatment.treatDate,
            kurCd: selectedSchedule.treatment.kurCd,
            bedCd: selectedSchedule.treatment.bedCd,
            ordNo: selectedSchedule.treatment.ordNo
          });
          // 治療状態判定
          if (rstDialysisState1 === "") {
            // スケジュール変更あり
            return false;
            // 治療状態判定
          } else if (rstDialysisState1 >= DIALISYS_STATE.AFTER_SEND_CONDITION) {
            // 条件送信済み以降

            // 条件送信キャンセル[デバイスエッジへの通知]
            await sendRequestPostCancelCondition({
              ordNo: state.selectedTreatmentSchedule.treatment.ordNo,
              machineNo: state.selectedTreatmentSchedule.bedLayout.machine_no,
              facilityCd: state.facilityCd
            });
            // 条件送信キャンセル[DB関連処理]
            await sendRequestPutSendConditionCancel(
              treatmentSchedule.treatment.bedCd
            );
          }

          // 最新の治療状況取得
          const rstDialysisState2 = await getLastestDialysisState({
            treatDate: treatmentSchedule.treatment.treatDate,
            kurCd: treatmentSchedule.treatment.kurCd,
            bedCd: treatmentSchedule.treatment.bedCd,
            ordNo: treatmentSchedule.treatment.ordNo
          });
          // 治療状態判定
          if (rstDialysisState2 === "") {
            // スケジュール変更あり
            return false;
            // 治療状態判定
          } else if (rstDialysisState2 >= DIALISYS_STATE.AFTER_SEND_CONDITION) {
            // 条件送信済み以降

            // 条件送信キャンセル[デバイスエッジへの通知]
            await sendRequestPostCancelCondition({
              ordNo: treatmentSchedule.treatment.ordNo,
              machineNo: treatmentSchedule.bedLayout.machine_no,
              facilityCd: state.facilityCd
            });

            // 条件送信キャンセル[DB関連処理]
            await sendRequestPutSendConditionCancel(
              state.selectedTreatmentSchedule.treatment.bedCd
            );
          }

          // ベッドを入れ替える
          await sendRequestPutSwapScheduleOrdMain({
            ordNo1: treatmentSchedule.treatment.ordNo,
            ordNo2: state.selectedTreatmentSchedule.treatment.ordNo,
            userId: state.findState.conditionTreatMap.userId
          });
          isSuccess = true;

          await commit("selectTreatmentStatus", null);
          await dispatch("reFetchTreatmentStatus");
        }
      } else {
        if (treatmentSchedule.treatment) {
          // 選択されている治療データがなければ、治療データを選択する
          await commit("selectTreatmentStatus", treatmentSchedule);
          isSuccess = true;
        } else {
          await commit("selectTreatmentStatus", null);
          isSuccess = true;
          await dispatch("reFetchTreatmentStatus");
        }
      }

      return isSuccess;
    },
    /**
     * 治療情報をベッドへ割り当て
     */
    async assignScheduleOrdMain(
      { state, dispatch },
      { ordNo, bedCd, currentDate }
    ) {
      const kurCd = state.findState.conditionTreatMap.kurCd;
      const userId = state.findState.conditionTreatMap.userId;
      // 治療情報をベッドへ割り当て
      await sendRequestPutAssignScheduleOrdMain({
        facilityCd: state.facilityCd,
        ordNo: ordNo,
        bedCd: bedCd,
        treatDate: currentDate,
        kurCd: kurCd,
        userId: userId
      });
      // add #6940 2022/8/18 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou start
      await store.dispatch("loading-screen/setLoadingScreenVisible", true);
      // add #6940 2022/8/18 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou end
      // 割り当て後の治療状況を取得
      await dispatch("reFetchTreatmentStatus");
      // add #6940 2022/8/18 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou start
      await store.dispatch("loading-screen/setLoadingScreenVisible", false);
      // add #6940 2022/8/18 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou end
    },
    /**
     * 治療情報のベッドへの割り当てを解除
     */
    async unassigmentScheduleOrdMain({ dispatch, state }, treatData) {
      // 条件送信済み判定
      // mod FNSI-条件送信済み(1)追加 付 start
      // if (treatData.rstDialysisState === "2") {
      if (treatData.rstDialysisState === "2" || treatData.rstDialysisState === "1") {
      // mod FNSI-条件送信済み(1)追加 付 end
        // 条件送信キャンセル[デバイスエッジへの通知]
        await sendRequestPostCancelCondition({
          ordNo: treatData.ordNo,
          machineNo: treatData.machine_no,
          facilityCd: state.facilityCd
        });

        // 条件送信キャンセル[DB関連処理]
        await sendRequestPutSendConditionCancel(
          treatData.bedCd
        );
      }

      // 治療情報のベッドへの割り当てを解除
      await sendRequestPutUnassigmentScheduleOrdMain({
        facilityCd: state.facilityCd,
        ordNo: treatData.ordNo,
        userId: state.findState.conditionTreatMap.userId
      });
      // add #6940 2022/8/18 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou start
      await store.dispatch("loading-screen/setLoadingScreenVisible", true);
      // add #6940 2022/8/18 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou end
      // 割り当て解除後の治療状況を再取得
      await dispatch("reFetchTreatmentStatus");
      // add #6940 2022/8/18 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou start
      await store.dispatch("loading-screen/setLoadingScreenVisible", false);
      // add #6940 2022/8/18 【DBデータ整合性を壊す】治療状況マップのスケジュールにてスケジュール操作で画面更新がされる前に別のスケジュール操作が可能。 dou end
    },
    /* modify by chamaojia 2022-11-26 [6746] 自動リフレッシュ判定フラグパラメータの追加  --start */
    /**
     * 治療状況再取得
     * @param autoRefreshFlag 自動更新にloadingは必要ありません  true:loadingは不要
     */
    async reFetchTreatmentStatus({ dispatch, state }, autoRefreshFlag) {
      await dispatch("fetchTreatmentStatus", {
        facilityCd: state.facilityCd,
        treatDate: moment(
          state.findState.conditionTreatMap.currentDateTime
        ).format("YYYYMMDD"),
        layoutNo: state.findState.conditionTreatMap.statusLayoutNo,
        autoRefreshFlag: autoRefreshFlag,
        roomBedGroupCd:state.findState.conditionTreatMap.roomBedGroupCd,
        nextPat : state.findState.conditionTreatMap.nextPatValue,
        bedLayoutId : state.findState.conditionTreatMap.bedLayoutId,
        kurCd : state.findState.conditionTreatMap.kurCd
      });
    },
    /* modify by chamaojia 2022-11-26 [6746] 自動リフレッシュ判定フラグパラメータの追加  --end */
    /**
     * 治療予定のベッド移動前チェック結果を取得
     * @param {*} params
     */
    async checkBeforeMoveOrdMain(context, params) {
      let ret = null;
      // 情報取得
      await sendRequestCheckBeforeMoveOrdMain(
        params.ordNo
        , params.bedCd
      ).then(response => {
        ret = response.data[0];
      })
        .catch(err => {
          console.error(err);
        });
      return ret;
    },
    //add FNSI redmine5436 fang start
    async setShowFlg({ commit }, flag) {
      await commit("setShowFlg", flag);
    },
    //add FNSI redmine5436 fang end
    /**
     * 治療状況データリストの取得
     */
    getTreatmentStatusList({ commit, getters }, ordMainAndTreatmentStatus, autoRefreshFlag) {
      const {ordMainList, treatmentStatusList, machineStatusList} = ordMainAndTreatmentStatus;
      commit("setTreatmentStatusList", []);
      if (treatmentStatusList) {
        if (
          !getters.getSelectedBedLayout ||
          !getters.getSelectedStatusLayout
        ) {
          commit("setTreatmentStatusList", []);
          return;
        }
        !autoRefreshFlag && store.dispatch("loading-screen/startLoadingScreen");
        const res = getters.getSelectedBedLayout.bedLayout.obj_list
          .map(bedLayout => {
            // 治療状況表示レイアウトと、治療状況データを取得
            const { treatmentDataList, viewItems } = getters.getTreatmentItem(bedLayout);
            // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
            if (!!treatmentDataList && !!viewItems) {
              // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
              // 表示項目内容とレイアウトでの利用者情報をＩＤから名前に変換する
              for (const treatmentData of treatmentDataList) {
                const ordMain = ordMainList?.find(record => record.ordNo === treatmentData.ordNo);
                if (ordMain) {
                  const punctureUserInfo = JSON.parse(ordMain.rstPunctureUserInfo || "{}");
                  const returnUserInfo = JSON.parse(ordMain.rstReturnUserInfo || "{}");
                  const changeUserInfo = JSON.parse(ordMain.rstChargeUserInfo || "{}");
                  for (const viewItem of viewItems) {
                    const {data_class, order_no} = viewItem;
                    const fieldName = "field_" + order_no;
                    const userId = Number(treatmentData[fieldName]);
                    switch (data_class) {
                      case 23: // 担当者1
                        if (changeUserInfo && changeUserInfo.user_id_1 === userId) {
                          treatmentData[fieldName] = changeUserInfo.user_last_name_1 + changeUserInfo.user_first_name_1;
                        }
                        break;
                      case 25: // 担当者2
                        if (changeUserInfo && changeUserInfo.user_id_2 === userId) {
                          treatmentData[fieldName] = changeUserInfo.user_last_name_2 + changeUserInfo.user_first_name_2;
                        }
                        break;
                      case 28: // 穿刺者1
                        if (punctureUserInfo && punctureUserInfo.user_id_1 === userId) {
                          treatmentData[fieldName] = punctureUserInfo.user_last_name_1 + punctureUserInfo.user_first_name_1;
                        }
                        break;
                      case 30: // 穿刺者2
                        if (punctureUserInfo && punctureUserInfo.user_id_2 === userId) {
                          treatmentData[fieldName] = punctureUserInfo.user_last_name_2 + punctureUserInfo.user_first_name_2;
                        }
                        break;
                      case 33: // 返血者1
                        if (returnUserInfo && returnUserInfo.user_id_1 === userId) {
                          treatmentData[fieldName] = returnUserInfo.user_last_name_1 + returnUserInfo.user_first_name_1;
                        }
                        break;
                      case 35: // 返血者2
                        if (returnUserInfo && returnUserInfo.user_id_2 === userId) {
                          treatmentData[fieldName] = returnUserInfo.user_last_name_2 + returnUserInfo.user_first_name_2;
                        }
                        break;
                    }
                  }
                }
              }
              // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
            }
            // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
            // ベッド毎の治療情報を取得
            // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
            // const treatmentData = treatmentDataList.find(treatData =>
            const treatmentData = treatmentDataList?.find(treatData =>
            // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
              compTreatDataAndBedLayoutOfMachine(treatData, bedLayout)
            ) || {};

            // 装置治療状態取得
            let status;
            if (machineStatusList) {
              status = machineStatusList.find(data =>
                data.machineTypeCd === bedLayout.machine_type_cd && data.machineSerial === bedLayout.machine_serial
              );
            }
            if (status) {
              treatmentData.processState = status.processState;
              treatmentData.machineStatus = status.machineStatus;
            }
            // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
            // if (["006", "007", "001", "002", "003"].includes(bedLayout.model) && (treatmentData.machineStatus || treatmentData.machineStatus === 0)) {
            if (!!viewItems && viewItems.length > 0 && treatmentData &&
            ["006", "007", "001", "002", "003"].includes(bedLayout.model) && (treatmentData.machineStatus || treatmentData.machineStatus === 0)) {
            // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
              viewItems.forEach(e => {
                if (["D99", "A99", "R99"].includes(e.key_name)) {
                  treatmentData[`field_${e.order_no}`] = treatmentData.machineStatus;
                }
              });
            }
            return {
              bedLayout,
              treatment: treatmentData || null,
              viewItems: viewItems || null,
              isInBedGroup: getters.isInBedGroup(bedLayout)
            };
          })
          .sort((a, b) => compBedLayoutOrder(a.bedLayout, b.bedLayout));
        commit("setTreatmentStatusList", res);
        !autoRefreshFlag && store.dispatch("loading-screen/finishLoadingScreen");
      } else {
        commit("setTreatmentStatusList", []);
      }

    },
    /**
     * 治療スケジュールリストの取得
     */
    getTreatmentScheduleList({ commit, getters }, ordMainAndTreatmentStatus, autoRefreshFlag) {
      const {ordMainList, treatmentStatusList, statusMapInfo} = ordMainAndTreatmentStatus;
      if (treatmentStatusList) {
        commit("setTreatmentScheduleList", []);
        if (
          !getters.getSelectedBedLayout ||
          !getters.getSelectedStatusLayout
        ) {
          commit("setTreatmentScheduleList", []);
          return;
        }
        // 表示項目内容とレイアウトでの利用者情報をＩＤから名前に変換する
        !autoRefreshFlag && store.dispatch("loading-screen/startLoadingScreen");
        const res = getters.getSelectedBedLayout.bedLayout.obj_list
          .map(bedLayout => {
            // 治療状況表示レイアウトと、治療状況データを取得
            let { treatmentDataList, viewItems } = getters.getTreatmentItem(bedLayout);
            // 表示項目内容とレイアウトでの利用者情報をＩＤから名前に変換する
            // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
            if (!!treatmentDataList && !!viewItems) {
            // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
            for (const treatmentData of treatmentDataList) {
              const ordMain = ordMainList?.find(record => record.ordNo === treatmentData.ordNo);
              if (ordMain) {
                const punctureUserInfo = JSON.parse(ordMain.rstPunctureUserInfo || "{}");
                const returnUserInfo = JSON.parse(ordMain.rstReturnUserInfo || "{}");
                const changeUserInfo = JSON.parse(ordMain.rstChargeUserInfo || "{}");
                for (const viewItem of viewItems) {
                  const { data_class, order_no } = viewItem;
                  const fieldName = "field_" + order_no;
                  const userId = Number(treatmentData[fieldName]);
                  switch (data_class) {
                    case 23: // 担当者1
                      if (changeUserInfo && changeUserInfo.user_id_1 === userId) {
                        treatmentData[fieldName] = changeUserInfo.user_last_name_1 + changeUserInfo.user_first_name_1;
                      }
                      break;
                    case 25: // 担当者2
                      if (changeUserInfo && changeUserInfo.user_id_2 === userId) {
                        treatmentData[fieldName] = changeUserInfo.user_last_name_2 + changeUserInfo.user_first_name_2;
                      }
                      break;
                    case 28: // 穿刺者1
                      if (punctureUserInfo && punctureUserInfo.user_id_1 === userId) {
                        treatmentData[fieldName] = punctureUserInfo.user_last_name_1 + punctureUserInfo.user_first_name_1;
                      }
                      break;
                    case 30: // 穿刺者2
                      if (punctureUserInfo && punctureUserInfo.user_id_2 === userId) {
                        treatmentData[fieldName] = punctureUserInfo.user_last_name_2 + punctureUserInfo.user_first_name_2;
                      }
                      break;
                    case 33: // 返血者1
                      if (returnUserInfo && returnUserInfo.user_id_1 === userId) {
                        treatmentData[fieldName] = returnUserInfo.user_last_name_1 + returnUserInfo.user_first_name_1;
                      }
                      break;
                    case 35: // 返血者2
                      if (returnUserInfo && returnUserInfo.user_id_2 === userId) {
                        treatmentData[fieldName] = returnUserInfo.user_last_name_2 + returnUserInfo.user_first_name_2;
                      }
                      break;
                  }
                }
              }
            }
            // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
            }
            // add #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end

            // ベッド毎の治療情報を取得
            // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
            // const treatmentData = treatmentDataList.find(treatData =>
            const treatmentData = treatmentDataList?.find(treatData =>
            // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
              compTreatDataAndBedLayoutOfMachine(treatData, bedLayout)
            );

            // 治療状況マップアイコン設定情報
            const orderStatusMapInfo = statusMapInfo
              ? statusMapInfo.find(dat => {
                if (treatmentData && treatmentData.ordNo) {
                  return dat.ordNo === treatmentData.ordNo;
                } else {
                  return false;
                }
              })
              : [];
            // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
            // if (viewItems.length > 0 && treatmentData) {
            if (!!viewItems && viewItems.length > 0 && treatmentData) {
            // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
              const keyFilter = {
                "007": ["J", "D99"],
                "006": ["I", "D99"],
                "003": ["D"]
              };

              const model = treatmentData.model;
              if (keyFilter.hasOwnProperty(model)) {
                const allowedKeys = keyFilter[model];
                viewItems = viewItems.filter(e => {
                  const keyName = e.key_name.substring(0, 1);
                  return allowedKeys.includes(keyName) || allowedKeys.includes(e.key_name);
                });
              }
            }

            return {
              //add #11804 治療状況マップ＞スケジュール画面で工程の表示色が白のまま変化しない zrx start
              processState: treatmentData?.processState,
              //add #11801 治療状況マップ＞スケジュール画面で工程の表示色が白のまま変化しない zrx end
              bedLayout: bedLayout,
              treatment: treatmentData || null,
              viewItems: viewItems || null,
              isInBedGroup: getters.isInBedGroup(bedLayout),
              statusMapInfo: orderStatusMapInfo,
              // isSelected:
              //   treatmentData && state.selectedTreatmentSchedule?.treatment ?
              //     treatmentData.ordNo === state.selectedTreatmentSchedule.treatment.ordNo
              //     : false,
              // 装置が割りついている空きベッド、または治療開始(３)より前はクリック可
              isClickable:
                isBedLayoutMachineIsBed(bedLayout)
                && (
                  !treatmentData
                  || (treatmentData
                      && !["3", "4", "5", "6"].includes(
                      treatmentData.rstDialysisState
                    )
                  )
                ),
              isEnableWeight:
                isBedLayoutMachineIsBed(bedLayout)
                && (
                  !treatmentData
                  || (treatmentData
                    && !["3", "4", "5", "6"].includes(
                      treatmentData.rstDialysisState
                    )
                  )
                ),
              isEnableTreatmentRecord:
                isBedLayoutMachineIsBed(bedLayout)
                && (
                  !treatmentData
                  || (treatmentData
                    && !["0"].includes(
                      treatmentData.rstDialysisState
                    )
                  )
                )
            };
          })
          .sort((a, b) => compBedLayoutOrder(a.bedLayout, b.bedLayout));
        commit("setTreatmentScheduleList", res);
        !autoRefreshFlag && store.dispatch("loading-screen/finishLoadingScreen");
      } else {
        commit("setTreatmentScheduleList", []);
      }
    },
    /**
     * レイアウトの状態を設定
     * @param {*} commit
     * @param {*} layoutState レイアウトの状態
     */
    setLayoutState({ commit }, layoutState) {
      commit("setLayoutState", layoutState);
    },
    // -----------------------------------------
    // 強制サインアウトフラグ設定
    // -----------------------------------------
    setForceSignOutFlag({ commit }, forceSignOutFlag) {
      commit("setForceSignOutFlag", forceSignOutFlag);
    },
  },
  getters: {
    isTreatStateMode: state => state.isTreatStateMode,
    isDisplayFullMode: state => state.isDisplayFullMode,
    nextPatGroupListGetter: () => [
      { nextPatGroupName: "表示しない", nextPatValue: 0 },
      { nextPatGroupName: "現クール", nextPatValue: 1 },
      { nextPatGroupName: "次クール", nextPatValue: 2 }
    ],
    displayNameFlag(state) {
      return state.displayNameFlag;
    },
    /**
     * コンボボックス表示要素取得
     */
    comboLayoutItemListGetter: state => {
      if (state.findState.candidate.statusLayoutList.length > 0) {
        return state.findState.candidate.statusLayoutList.map(dat => ({
          layoutName: dat.layoutName,
          layoutNo: dat.layoutNo
        }));
      } else {
        return [];
      }
    },
    comboKurItemListGetter: state => state.findState.candidate.comboKurList,
    /**
     * ベッドグループ一覧
     */
    getBedGroupList: state => state.findState.candidate.bedGroupList,
    comboBedGroupListGetter: state =>
      state.findState.candidate.comboBedGroupList,
    getSelectedBedGroup: state => {
      return state.findState.candidate.bedGroupList.find(
        dat =>
          dat.roomBedGroupCd ===
          state.findState.conditionTreatMap.roomBedGroupCd
      )
    },
    /**
     * クール一覧を取得
     */
    getKurList: state => state.findState.candidate.kurList,
    /**
     * 治療状況レイアウト一覧を取得
     */
    getStatusLayoutList: state => state.findState.candidate.statusLayoutList,
    /**
     * ベッドレイアウト一覧を取得
     */
    getBedLayoutList: state => state.findState.candidate.bedLayoutList,
    /**
     * 指示者一覧を取得
     */
    comboInstructorListGetter: state => state.findState.candidate.instructorList,
    /**
     * 選択されているベッドレイアウトの取得
     */
    getSelectedBedLayout: state => {
      return state.findState.candidate.bedLayoutList.find(
        dat =>
          `${dat.layoutId}` ===
          `${state.findState.conditionTreatMap.bedLayoutId}`
      )
    },
    /**
     * 選択されているステータスレイアウトを取得
     */
    getSelectedStatusLayout: state => {
      return state.findState.candidate.statusLayoutList.find(
        dat =>
          `${dat.layoutNo}` ===
          `${state.findState.conditionTreatMap.statusLayoutNo}`
      )
    },
    /**
     * 選択されている利用者を取得
     */
    getSelectedUser: state =>
      state.findState.conditionTreatMap.userId,
    /**
     * 選択されている予定日を取得
     */
    getConditionTreatMapCurrentDate: state =>
      state.findState.conditionTreatMap.currentDateTime,

    getSelectedTreatmentSchedule: state => state.selectedTreatmentSchedule,

    /**
     * bedLayout.modelに応じた治療状況表示レイアウトと、治療状況データを取得
     */
    getTreatmentItem(state, getters) {
      const { treatmentStatusList } = state.ordMainAndTreatmentStatus;
      return bedLayout => {
        // model別のviewItems、治療情報を取得
        switch (bedLayout.model) {
          case MACHINE_MODEL.DRO: {
            return {
              viewItems: JSON.parse(
                getters.getSelectedStatusLayout.droViewItems
              ),
              treatmentDataList: treatmentStatusList.dro
            };
          }
          case MACHINE_MODEL.DAB: {
            return {
              viewItems: JSON.parse(
                getters.getSelectedStatusLayout.dabViewItems
              ),
              treatmentDataList: treatmentStatusList.dab
            };
          }
          // add FNSI-insert DRY_A and DRY_B machine type 付 start
          case MACHINE_MODEL.DRY_A:
          case MACHINE_MODEL.DRY_B:
          // add FNSI-insert DRY_A and DRY_B machine type 付 end
          case MACHINE_MODEL.DAD: {
            return {
              viewItems: JSON.parse(
                getters.getSelectedStatusLayout.dadViewItems
              ),
              treatmentDataList: treatmentStatusList.dad
            };
          }
          case MACHINE_MODEL.PERSONAL:
          case MACHINE_MODEL.DCS: {
            // クール選択による絞込
            let kurFilteredDCS = null;
            const list = treatmentStatusList.dcs;

            //mod #10594 by zhangruixue 2024-04-08 --start
            // mod #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240618 ztc start
            // kurFilteredDCS = list;
            if (state.isTreatStateMode === true) {
              // 治療状況画面の場合
              kurFilteredDCS = list;
            } else {
              // スケジュール画面の場合
              // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc start
              // if (list !== null && list !== undefined) {
              if (list !== null && list !== undefined && list.length > 0) {
                // const hasDiagnosisItem = JSON.parse(getters.getSelectedStatusLayout.dcsViewItems).some(dcs => dcs?.data_class == 110)
                const hasDiagnosisItem = JSON.parse(getters.getSelectedStatusLayout.dcsViewItems)?.some(dcs => dcs?.data_class == 110)
              // mod #10773 治療状況レイアウトマスタにて透析装置の項目0件だと、治療状況マップのスケジュールで患者が表示しない。 ztc end
                kurFilteredDCS = list.filter(
                    dat =>
                        // state.findState.conditionTreatMap.kurCd === "" ||
                        hasDiagnosisItem || dat.kurCd === state.findState.conditionTreatMap.kurCd
                );
              }
            }
            // mod #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240618 ztc end
            //mod #10594 by zhangruixue 2024-04-08 --end
            return {
              viewItems: JSON.parse(
                getters.getSelectedStatusLayout.dcsViewItems
              ),
              treatmentDataList: kurFilteredDCS
            };
          }
          default: {
            return {
              viewItems: [],
              treatmentDataList: []
            };
          }
        }
      };
    },
    /**
     * bedLayoutがベッドグループにあるベッドかを判定
     */
    isInBedGroup(state, getters) {
      return bedLayout => {
        if (
          (bedLayout.model !== MACHINE_MODEL.PERSONAL &&
            bedLayout.model !== MACHINE_MODEL.DCS) ||
          !getters.getSelectedBedGroup
        ) {
          // ベッド以外の装置は常に表示
          // ベッドグループが選択されていない場合は全装置を表示
          return true;
        } else {
          return getters.getSelectedBedGroup.bedList.indexOf(
            bedLayout.bed_cd
          ) >= 0
            ? true
            : false;
        }
      };
    },

    /**
     * 治療状況：治療データの表示判定
     * @param {*} state
     */
    isDispTreatStatus(state) {
      return (treatData) => {
        let ret = false;

        // ベッドはクールでの表示の絞込を行う
        if (treatData.bedCd !== null && treatData.bedCd !== undefined) {
          ret = isDisp(treatData, state, null);
        } else {
          // 機械室装置
          ret = true;
        }
        return ret;
      };
    },
    /**
     * スケジュール：治療データの表示判定
     */
    isDispTreatScheduleData(state) {
      return treatData => {
        let ret = false;

        if (treatData.bedCd !== null && treatData.bedCd !== undefined) {
          // 透析装置

          //指定されているクールの治療データである
          const isKur =
            treatData.kurCd === state.findState.conditionTreatMap.kurCd;

          if (isKur) {
            // 表示する
            ret = true;
          } else {
            // 表示しない
          }
        } else {
          // 機械室装置
          ret = true;
        }
        return ret;
      };
    },
    conditionFilter: state => state.findState.conditionTreatMap,
    getFilterSignal: state => state.findState.filterSignal,

    /**
     * 治療状況のベッドのみを抽出して患者選択リストを取得する
     */
    getPatTreatmentStatusToPatList(state) {
      // 治療状況
      return StatusMapListToPatList(state.treatmentStatusList);
    },
    /**
     * スケジュールのベッドのみを抽出して患者選択リストを取得する
     */
    getPatTreatmentScheduleToPatList(state) {
      // スケジュール
      return StatusMapListToPatList(state.treatmentScheduleList);
    },
    /**
     * 装置治療状態取得
     */
    getMachineStatus(state) {
      const { machineStatusList } = state.ordMainAndTreatmentStatus;
      return (machineTypeCd, machineSerial) => {
        if (machineStatusList) {
          return machineStatusList.find(data =>
            data.machineTypeCd === machineTypeCd && data.machineSerial === machineSerial
          );
        }
      }
    },
    // add FNSI-警報・報知追加 付 start
    getAlarmData(state) {
      return state.alarmData;
    },
    // add FNSI-警報・報知追加 付 end
    //add FNSI redmine5436 fang start
    getShowFlg(state) {
      return state.showFlg;
    },
    //add FNSI redmine5436 fang end
    /**
     * レイアウトの状態を取得
     * @param {*} state 
     */
    getLayoutState(state) {
      return state.layoutState;
    },
    getForceSignOutFlag: state => state.forceSignOutFlag,
  },
};

// del #7138 【デグレ】治療状況リスト、マップの表示条件と対象実績表示内容の不正 dou start
// function getCurrentDate() {
//   return moment(new Date()).format("YYYYMMDD");
// }
// function getCurrentTime() {
//   return moment(new Date()).format("HHmmss");
// }
// /**
//  * 現在クール
//  */
// function getCurrentKur(kurList) {
//   return kurList.find(
//     dat =>
//       dat.kurStartTime <= getCurrentTime() &&
//       dat.kurEndTime >= getCurrentTime()
//   );
// }
// /**
//  * 指定クールの開始時刻を取得
//  */
// function getKurStartTime(kurList, kurCd) {
//   let ret = "000000";
//   if (kurCd != null) {
//     const kur = kurList.find(
//       dat => dat.kurCd.toString() === kurCd.toString()
//     );
//     if (kur !== undefined) {
//       ret = kur.kurStartTime;
//     }
//   }
//   return ret;
// }
// /**
//  *  現クール開始日付時刻を取得
//  */
// function getCurrentKurStartDateTime(kurList) {
//   let ret = getCurrentDate();
//   // 現在クール取得
//   const kur = getCurrentKur(kurList);
//   if (kur !== undefined) {
//     ret += kur.kurStartTime;
//   }
//   return ret;
// }
// /**
//  *  次クール開始日付時刻を取得
//  */
// function getNextKurStartDateTime(kurList) {
//   let ret = "";
//   // 現在日付取得
//   const now = new Date();
//   let checkDate = moment(now).format("YYYYMMDD");
//
//   // 現クール開始時刻を取得
//   const currentKurStartDateTime = getCurrentKurStartDateTime(kurList);
//
//   // クール情報リスト
//   let lop = 0;
//   for (; lop < kurList.length; lop++) {
//     // 対象クールの開始日付時刻を作成
//     let checkDateTime = checkDate + getKurStartTime(kurList, kurList[lop].kurCd);
//
//     // 現クール開始時刻と比較
//     if (currentKurStartDateTime < checkDateTime) {
//       // 現クール開始時刻より大きい
//       ret = checkDateTime;
//       break;
//     }
//   }
//
//   // 最後クール判定
//   if (lop !== 0 && lop === kurList.length) {
//     // 翌日判定
//     now.setDate(now.getDate() + 1);
//     ret = moment(now).format("YYYYMMDD") + getKurStartTime(kurList, kurList[0].kurCd);
//   }
//
//   return ret;
// }
// del #7138 【デグレ】治療状況リスト、マップの表示条件と対象実績表示内容の不正 dou end
/**
 * 指定リストを患者選択リストに変換する
 * @param {*} list
 */
function StatusMapListToPatList(list) {
  let ret = [];

  if (list !== null && list !== undefined) {
    ret = list
      .map(p => {
        // ベッド判定
        if (
          p.isInBedGroup
          && p.treatment !== null
          && p.treatment !== undefined
          && p.treatment.ordNo !== null
        ) {
          return {
            pat_id: p.treatment.patId,
            pat_last_name: p.treatment.patLastName,
            pat_first_name: p.treatment.patFirstName,
            ord_no: p.treatment.ordNo,
            kur_name: p.treatment.kurName,
            bed_name: p.treatment.bedName,
            is_same: p.treatment.isSame,
            in_out_class: p.treatment.inOutClass,
            ...p
          };
        }
      })
      .filter(p => p !== undefined && p.pat_id !== undefined);
    // ベッド名順でソート
    ret.sort(function (a, b) {
      return a.bed_name < b.bed_name ? -1 : a.bed_name > b.bed_name ? 1 : 0;
    });
  }
  return ret;
}

/**
 * ベッドレイアウトの表示順序を比較
 */
function compBedLayoutOrder(a, b) {
  if (
    (a.isFront === true && b.isFront === false) ||
    (a.isBack === false && b.isBack === true)
  ) {
    return 1;
  } else if (
    (a.isFront === false && b.isFront === true) ||
    (a.isBack === true && b.isBack === false)
  ) {
    return -1;
  } else if (a.disp_order_no < b.disp_order_no) {
    return 1;
  } else {
    return -1;
  }
}

/**
 * 治療データと、ベッドレイアウトの装置を比較
 */
function compTreatDataAndBedLayoutOfMachine(treatData, bedLayout) {
  // ベッドコードが一致するデータを表示
  let ret = false;
  if (isBedLayoutMachineIsBed(bedLayout)) {
    // ベッドの場合
    ret =
      treatData.bedCd !== null &&
      treatData.bedCd !== "-1" &&
      treatData.bedCd == bedLayout.bed_cd;
  } else {
    // 装置の場合
    ret =
      treatData.machineTypeCd !== undefined &&
      treatData.machineTypeCd === bedLayout.machine_type_cd &&
      treatData.machineSerial === bedLayout.machine_serial;
  }
  return ret;
}

/**
 * ベッドレイアウトの装置がベッドである
 */
function isBedLayoutMachineIsBed(bedLayout) {
  //return bedLayout.model !== MACHINE_MODEL.PERSONAL && bedLayout.model !== MACHINE_MODEL.DCS;
  return bedLayout.bed_cd !== null && bedLayout.bed_cd !== -1;
}

/**
 * 指定条件の治療スケジュールがあるかどうかチェックし、あれば治療状況を取得する
 * @returns 空：該当するスケジュールなし/else：治療状況
 */
async function getLastestDialysisState(params) {
  let ret = "";
  // 情報取得
  await sendRequestGetLastestDialysisState(
    params.treatDate
    , params.kurCd
    , params.bedCd
    , params.ordNo
  ).then(response => {
    ret = response.data;
  })
    .catch(err => {
      console.error(err);
    });
  return ret;
}

async function getOrdMainByOrdNo(params) {
  let ret = "";
  // 情報取得
  await sendRequestGetOrdMainByOrdNo(
    params.ordNo
  ).then(response => {
    ret = response.data;
  })
    .catch(err => {
      console.error(err);
    });
  return ret;
}

// add FNSI-7217 バッチ操作インターフェイスを追加します 查 start
async function getOrdMainListByOrdNo(params) {
  let ret = "";
  // 情報取得
  await sendRequestGetOrdMainListByOrdNo(
    params.ordNos.join(","), params.autoRefreshFlag
  ).then(response => {
    ret = response.data;
  })
    .catch(err => {
      console.error(err);
    });
  return ret;
}
// add FNSI-7217 バッチ操作インターフェイスを追加します 查 end
