//@ts-check

/**
 * 体重計モード専用部分ストア
 */
import { sendRequestFindMstWeightList } from "@/apis/mst-weight-maintenance";
import { sendRequestGetEnableWeightSelect } from "@/apis/send-condition";

export default {
  strict: process.env.NODE_ENV !== "production",
  namespaced: true,
  state: {
    mstWeightSelectorResource: [],
    mstWeightList: [],
    mstWeightIndex: 0,
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao start
    focus:null,
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao end
    selectedWeightNo: null,
    weightMode: {
      isWeightMode: false,
      defaultDispMenu: null
    },
    enableWeightSelect: "0",
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao start
    isHospPatId:null,
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao end
    //add #9558 機能帳票でパラメータが正しく渡されていない 房 start
    selectedPats: [],
    //add #9558 機能帳票でパラメータが正しく渡されていない 房 end
  },
  getters: {
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao start
    getIsHospPatId:state => state.isHospPatId,
    getFocus:state => state.focus,
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao end
    /**
     * 体重計マスタから取得した体重計一覧
     */
    getMstWeightList: state => state.mstWeightList,
    /**
     * 選択中体重計マスタ情報
     */
    getSelectedMstWeight: state => {
      if (state.mstWeightIndex >= 0) {
        return state.mstWeightList[state.mstWeightIndex];
      }
      return null;
    },
    getMstWeightSelectorResource: state => state.mstWeightSelectorResource,
    getMstWeightIndex: state => state.mstWeightIndex,
    getSelectedWeightNo: state => state.selectedWeightNo,
    /**
     * 体重計モードフラグを取得
     */
    getWeightMode: state => state.weightMode,
    getIsEnableWeightSelect: state => state.enableWeightSelect === "1",
    //add #9558 機能帳票でパラメータが正しく渡されていない 房 start
    getSelectedPats: state => state.selectedPats
    //add #9558 機能帳票でパラメータが正しく渡されていない 房 end
  },
  actions: {
    /**
     * 体重計マスタの一覧を取得
     * @param {String} facilityCd 施設コード
     */
    fetchMstWeightList(context, facilityCd) {
      return sendRequestFindMstWeightList({ facilityCd: facilityCd });
    },
    fetchEnableWeightSelect() {
      return sendRequestGetEnableWeightSelect();
    },
    setEnableWeightSelect({ commit }, val) {
      commit("setEnableWeightSelect", val);
    },
    setMstWeightList({ commit }, weightList) {
      commit("setMstWeightList", { weightList: weightList });
    },
    // #11987 2026.02.12 add スケールベッド対応 TDC片口 start
    setMstWeightListByScaleBed({ commit }, weightList) {
      commit("setMstWeightListByScaleBed", { weightList: weightList });
    },
    // #11987 2026.02.12 add スケールベッド対応 TDC片口 end
    setMstWeightSelectIdx({ commit }, idx) {
      commit("setMstWeightSelectIdx", idx);
    },
    // 体重計番号からインデックスを検索し設定
    selectMstWeightByNo({ state, commit }, weightNo) {
      const idx = state.mstWeightList.findIndex(w => {
        return w.weightNo === weightNo;
      });
      commit("setMstWeightSelectIdx", idx);
    },
    selectMstWeightByCd({ state, commit }, weightCd) {
      const idx = state.mstWeightList.findIndex(w => {
        return w.weightCd === weightCd;
      });
      commit("setMstWeightSelectIdx", idx);
    },
    /**
     * 体重計モードフラグ
     * @param {Object} param0
     * @param {Object} weightMode
     * @param {boolean} weightMode.isWeightMode 体重計モードフラグ
     * @param {number} weightMode.defaultDispMenu フッター表示状態
     */
    setWeightMode({ commit }, weightMode) {
      commit("setWeightMode", weightMode);
    },

    setWeightModeOnly({ commit }, isWeightMode) {
      commit("setWeightModeOnly", isWeightMode);
    },
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao start
    setFocus({ commit }, focus) {
      commit("setFocus", focus);
    },
    setIsHospPatId({ commit }, isHospPatId) {
      commit("setIsHospPatId", isHospPatId);
    },
    //add #9558 機能帳票でパラメータが正しく渡されていない 房 start
    setSelectedPats({ commit }, selectedPats) {
      commit("setSelectedPats", selectedPats);
    },
    //add #9558 機能帳票でパラメータが正しく渡されていない 房 end
  },
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao end
  mutations: {
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao start
    setFocus (state,focus){
      state.focus=focus
    },
    setIsHospPatId (state,isHospPatId){
      state.isHospPatId=isHospPatId
    },

    // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao end
    setMstWeightList(state, payload) {
      state.mstWeightList = payload.weightList.filter(
        // #11987 2026.02.01 mod スケールベッド対応 体重種別が体重計のみ表示させる TDC渡辺 start
        //     elm => elm.isDel !== "1" && elm.isDisp === "1"
        elm => elm.isDel !== "1" && elm.isDisp === "1" && elm.weightType == 0
        // #11987 2026.02.01 mod スケールベッド対応 体重種別が体重計のみ表示させる end
      );
      state.mstWeightSelectorResource = [];
      for (const mstWeight of state.mstWeightList) {
        state.mstWeightSelectorResource.push(mstWeight.weightName);
      }
    },
    // #11987 2026.02.12 add スケールベッド対応 TDC片口 start
    setMstWeightListByScaleBed(state, payload) {
      state.mstWeightList = payload.weightList.filter(
        elm => elm.isDel !== "1" && elm.isDisp === "1"
      );
      state.mstWeightSelectorResource = [];
    },
    // #11987 2026.02.12 add スケールベッド対応 TDC片口 end
    setMstWeightSelectIdx(state, idx) {
      state.mstWeightIndex = idx;
      // 選択院内体重計番号を保存
      if (
        state.mstWeightIndex >= 0 &&
        state.mstWeightList[state.mstWeightIndex] !== undefined
      ) {
        state.selectedWeightNo =
          state.mstWeightList[state.mstWeightIndex].weightNo;
      } else {
        state.selectedWeightNo = null;
      }
    },
    setWeightMode(state, weightMode) {
      state.weightMode = weightMode;
    },
    setWeightModeOnly(state, isWeightMode) {
      state.weightMode.isWeightMode = isWeightMode;
    },
    setEnableWeightSelect(state, val) {
      state.enableWeightSelect = String(val);
    },
    //add #9558 機能帳票でパラメータが正しく渡されていない 房 start
    setSelectedPats(state, selectedPats) {
      state.selectedPats = selectedPats;
    }
    //add #9558 機能帳票でパラメータが正しく渡されていない 房 end
  }
};
