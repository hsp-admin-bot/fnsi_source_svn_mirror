/**
 * 観察記録一覧用ストア
 */
import {
  sendRequestGetPatEventRecord,
  sendRequestGetPatEventMaster,
  sendRequestGetPatEventRecordByOrdNo,
  sendRequestGetPatEventObserveRecord,
  sendRequestGetPatEventObserveRecordsByCondition
} from "@/apis/pat-event";
import moment from "moment";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 起票日
    eventRegDate: "",
    // 更新結果
    isUpdate: false,
    // 画面更新指示
    reloadSignal: false,
    // オーダNo
    ordNo: 0,
    // 編集対象オーダーNo
    editingOrdNo: 0,
    // 患者イベント
    patEventRecords: [],
    patEventRecord: null,
    patEventRecordForUrlDirect: null,
    // テンプレートマスタ
    mstTemplateRecords: [],
    // カテゴリマスタ
    mstCategoryRecords: [],
    // サブカテゴリマスタ
    mstSubCategoryRecords: [],

    // mod FNSI-観察記録を追加 楊 start
    // 患者経過総合ビューア用日付の設定
    startDate: "",
    endDate: "",
    // mod FNSI-観察記録を追加 楊 end
    //add FNSI redmine4055修正 房 start
    conditionList: null,
    //add FNSI redmine4055修正 房 end
    // add #12462 患者情報共有 20260330 start 
    isOtherFacilitys: false,
    // add #12462 患者情報共有 20260330 end 
  },
  mutations: {
    // mod FNSI-観察記録を追加 楊 start
    /**
     * 患者経過総合ビューア用日付の設定
     * @param {*} date 患者経過総合ビューア用日付
     */
    setStartToEndDate(state, date) {
      state.startDate = date.startDate;
      state.endDate = date.endDate;
    },
    // mod FNSI-観察記録を追加 楊 end
    /**
     * 観察記録種別一覧クリア
     */
    clearPatEventMasterAll(state) {
      state.mstTemplateRecords.splice(0, state.mstTemplateRecords.length);
      state.mstCategoryRecords.splice(0, state.mstCategoryRecords.length);
      state.mstSubCategoryRecords.splice(0, state.mstSubCategoryRecords.length);
    },
    /**
     * カテゴリマスタ
     * @param {*} state
     * @param {*} mstCategoryRecords
     */
    setMstCategoryRecords(state, mstCategoryRecords) {
      state.mstCategoryRecords = [];
      mstCategoryRecords.forEach(e => {
        state.mstCategoryRecords.push(e);
      });
    },
    /**
     * テンプレートマスタ
     * @param {*} state
     * @param {*} mstTemplateRecords
     */
    setMstTemplateRecords(state, mstTemplateRecords) {
      state.mstTemplateRecords = [];
      mstTemplateRecords.forEach(e => {
        state.mstTemplateRecords.push(e);
      });
    },
    /**
     * サブカテゴリマスタ
     * @param {*} state
     * @param {*} mstSubCategoryRecords
     */
    setMstSubCategoryRecords(state, mstSubCategoryRecords) {
      state.mstSubCategoryRecords = [];
      mstSubCategoryRecords.forEach(e => {
        state.mstSubCategoryRecords.push(e);
      });
    },
    /**
     * 観察記録一覧設定
     */
    setObserverRecords(state, patEventRecords) {
      state.patEventRecords = [];
      patEventRecords.forEach(e => {
        state.patEventRecords.push(e);
      });
    },
    setObserverRecord(state, patEventRecord) {
      state.patEventRecord = patEventRecord;
    },
    setObserverRecordForUrlDirect(state, patEventRecordForUrlDirect) {
      state.patEventRecordForUrlDirect = patEventRecordForUrlDirect;
    },
    setEventRegDate(state, baseDate) {
      const eventRegDate = new Date(baseDate);
      eventRegDate.setDate(eventRegDate);
      state.eventRegDate = eventRegDate;
    },
    /**
     * 観察記録一覧クリア
     */
    clearObserveRecords(state) {
      state.patEventRecords.splice(0, state.patEventRecords.length);
    },
    /**
     * 更新結果を反映
     */
    setIsUpdate(state, isUpdate) {
      state.isUpdate = isUpdate;
    },
    /**
     * 更新指示
     * @param {*} state state
     * @param {boolean} signal 更新する際にシグナルを立てる
     */
    setReloadSignal(state, signal) {
      state.reloadSignal = signal;
    },
    /**
     * オーダNoを反映
     */
    setOrdNo(state, ordNo) {
      state.ordNo = ordNo;
    },
    /**
     * 編集オーダNoを反映
     */
    setEditingOrdNo(state, ordNo) {
      state.editingOrdNo = ordNo;
    },
    //add FNSI redmine4055修正 房 start
    setConditionList(state, conditionList){
      state.conditionList = conditionList;
    },
    //add FNSI redmine4055修正 房 end
    // add #12462 患者情報共有 20260330 start
    setIsOtherFacilitys(state, isOtherFacilitys) {
      state.isOtherFacilitys = isOtherFacilitys;
    },
    resetIsOtherFacilitys(state) {
      state.isOtherFacilitys = false;
    },
    // add #12462 患者情報共有 20260330 end
  },
  actions: {
    /**
     * 観察記録種別一覧クリア
     */
    clearObserveKinds({ commit }) {
      commit("clearObserveKinds");
    },

    /**
     * 患者イベント関連マスタクリア
     */
    clearPatEventMasterAll({ commit }){
      commit("clearPatEventMasterAll");
    },
    /**
     * 観察記録一覧クリア
     */
    clearObserveRecords({ commit }) {
      commit("clearObserveRecords");
    },
    /**
     * 更新指示
     * @param {*} state state
     * @param {boolean} signal 更新する際にシグナルを立てる
     */
    setReloadSignal({ commit }, signal) {
      commit("setReloadSignal", signal);
    },
    /**
     * オーダNoを反映
     */
    setOrdNo({ commit }, ordNo) {
      commit("setOrdNo", ordNo);
    },
    /**
     * 編集オーダNoを反映
     */
    setEditingOrdNo({ commit }, ordNo) {
      commit("setEditingOrdNo", ordNo);
    },
    /**
     * 患者イベントマスタ取得
     */
    async fetchPatEventMaster({ commit }) {
      const response = await sendRequestGetPatEventMaster();
      if (response.data.template.length > 0) {
        commit("setMstTemplateRecords", response.data.template);
      }
      if (response.data.category.length > 0) {
        commit("setMstCategoryRecords", response.data.category);
      }
      if (response.data.subCategory.length > 0) {
        commit("setMstSubCategoryRecords", response.data.subCategory);
      }
    },
    /**
     * 初期表示時
     */
    async fetchObserveRecords({ commit }, info) {
      const params = info[0];
      if (params.isClear) {
        // クリア
        commit("clearObserveRecords");
      }
      // 患者未選択の場合はapi呼び出さない
      if (params.patId === null) {
        return;
      }
      const argument = {
        patId: params.patId,
        startDate: params.startDate,
        endDate: params.endDate,
		categoryCd: params.categoryCd,
        subCategoryCd: params.subCategoryCd,
        regStaffCd: params.regStaffCd,
        upStaffCd: params.upStaffCd,
        offset: params.offset,
        // add #12462 患者情報共有 Ji start
        facilityCd: params.facilityCd,
        // add #12462 患者情報共有 Ji end
        // add #12462 患者情報共有 20260330 start
        patShareMode: params.patShareMode,
        otherFacilityCd: params.otherFacilityCd,
        // add #12462 患者情報共有 20260330 end
      };
      const response = await sendRequestGetPatEventObserveRecordsByCondition(argument);
      if (response.data[0] !== null) {
        const ObserveRecords = response.data;
        for (let i = 0; i < ObserveRecords.length; i++) {
          // 日付でソートする用のカラムを追加
          ObserveRecords[i].sortKey = ObserveRecords[i].eventStartDate;
          // 起票に関する日時を設定()
          ObserveRecords[i].viewRecDate = moment(ObserveRecords[i].eventStartDate).format("YYYY/MM/DD");
          ObserveRecords[i].viewRecTime =  moment(ObserveRecords[i].eventStartDate).format("HH:mm:ss");
        }
        if (ObserveRecords.length > 0) {
          commit(
            "setEventRegDate",
            ObserveRecords[ObserveRecords.length - 1].eventStartDate
          );
          commit("setObserverRecords", ObserveRecords);
        }
      }
    },
    /**
     *
     * @param {*} param0
     * @param {*} info
     */
    // add #12462 患者情報共有 20260310 start
    //async findPatEventByCd({ commit }, info) {
    async findPatEventByCd({ commit, rootGetters }, info) {
    // add #12462 患者情報共有 20260310 end
      const params = info[0];
      const response = await sendRequestGetPatEventRecord(params);
      if (response.data[0] !== null) {
        const patEventRecord = response.data;
        if (patEventRecord.length > 0) {
          commit("setObserverRecord", patEventRecord[0]);
          // add #12462 患者情報共有 20260310 start
          const userFacilityCd = rootGetters["user/getFacilityCd"];
          const recordFacilityCd = patEventRecord[0].facilityCd;
          const isOtherFacility = userFacilityCd !== recordFacilityCd;
          commit("setIsOtherFacilitys", isOtherFacility);
          // add #12462 患者情報共有 20260310 end
        }
      }
    },

    /**
     * 観察記録を1件取得
     * @param {*} param0
     * @param {*} info
     */
    async findPatEventByCdForUrlDirect({ commit }, info) {
      const params = info[0];
      const response = await sendRequestGetPatEventObserveRecord(params);
      if (response.data[0] !== null) {
        const patEventRecord = response.data;
        if (patEventRecord.length > 0) {
          commit("setObserverRecordForUrlDirect", patEventRecord[0]);
        }
      }
    },

    /**
     * オーダNoに該当する観察記録を取得初期表示時
     */
    fetchObserveRecordsByOrdNo({ commit }, info) {
      const params = info[0];
      if (params.isClear) {
        // クリア
        commit("clearObserveRecords");
      }
      return sendRequestGetPatEventRecordByOrdNo(
        params
      ).then(response => {
        if (response.data[0] !== null) {
          const ObserveRecords = response.data;
          for (let i = 0; i < ObserveRecords.length; i++) {
            // 日付でソートする用のカラムを追加
            ObserveRecords[i].sortKey = ObserveRecords[i].eventStartDate;
            // 起票に関する日時を設定()
            ObserveRecords[i].viewRecDate = moment(ObserveRecords[i].eventStartDate).format("YYYY/MM/DD");
            ObserveRecords[i].viewRecTime =  moment(ObserveRecords[i].eventStartDate).format("HH:mm:ss");
          }
          if (ObserveRecords.length > 0) {
            commit(
              "setEventRegDate",
              ObserveRecords[ObserveRecords.length - 1].eventStartDate
            );
            commit("setObserverRecords", ObserveRecords);
          }
        }
      });
    },
//    checkIsKindNoSoap({ state }, kindNo) {
//      const sKind = state.observeKinds.find(kind => {
//        return kind.kindNo === kindNo;
//      });
//      return sKind.kindClass === CLASS_SOAP;
//    },
//    checkIsKindNoFdar({ state }, kindNo) {
//      const sKind = state.observeKinds.find(kind => {
//        return kind.kindNo === kindNo;
//      });
//      return sKind.kindClass === CLASS_FDAR;
//    },
//    checkIsKindNoOtherKind({ state }, kindNo) {
//      const sKind = state.observeKinds.find(kind => {
//        return kind.kindNo === kindNo;
//      });
//      return sKind.kindClass !== CLASS_SOAP && sKind.kindClass !== CLASS_FDAR;
//    },
//    async findObserveKind({ state }, kindNo) {
//      for (const kind of state.observeKinds) {
//        if (kind.kindNo === kindNo) {
//          return kind;
//        }
//      }
//      return null;
//    }
    // mod FNSI-観察記録を追加 楊 start
    // 患者経過総合ビューア用日付の設定
    // 表示期間更新
    updateStartToEndDate({commit}, date) {
      commit("setStartToEndDate", date);
    },
    // mod FNSI-観察記録を追加 楊 end
    //add FNSI redmine4055修正 房 start
    setConditionListForSave({commit}, conditionList){
      commit("setConditionList", conditionList);
    },
    //add FNSI redmine4055修正 房 end
    // add #12462 患者情報共有 20260310 start
    resetIsOtherFacilitys({ commit }) {
      commit("resetIsOtherFacilitys");
    },
    // add #12462 患者情報共有 20260310 end
  },
  getters: {
    // mod FNSI-観察記録を追加 楊 start
    // 患者経過総合ビューア用日付
    getStartToEndDate(state) {
      return { "startDate": state.startDate, "endDate": state.endDate };
    },
    // mod FNSI-観察記録を追加 楊 end
    getObserveRecords(state) {
      return state.patEventRecords;
    },
    getObserveRecord(state) {
      return state.patEventRecord;
    },
    getObserveRecordForUrlDirect(state) {
      return state.patEventRecordForUrlDirect;
    },
    getHeaderInfo(state) {
      return state.headerInfo;
    },
    getReloadSignal(state) {
      return state.reloadSignal;
    },
    getOrdNo(state) {
      return state.ordNo;
    },
    getEditingOrdNo(state) {
      return state.editingOrdNo;
    },
    //add FNSI redmine4055修正 房 start
    getConditionList(state) {
      return state.conditionList;
    },
    //add FNSI redmine4055修正 房 end
    // add #12462 患者情報共有 20260310 start
    getIsOtherFacilitys(state) {
      return state.isOtherFacilitys;
    },
    // add #12462 患者情報共有 20260310 end
  }
};
