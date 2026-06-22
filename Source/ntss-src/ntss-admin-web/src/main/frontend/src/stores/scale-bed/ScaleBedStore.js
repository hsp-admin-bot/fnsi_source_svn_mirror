import { sendRequestGetKurSelector } from "@/apis/send-condition";

/**
 * @typedef {Object} SearchCondition 社員検索時の条件
 * @property {number} bedGroupCd ベッドグループのコード
 * @property {number[]} kurCd クールコード配列
 * @property {string[]} kurGroupName クール名配列
 * @property {string[]} kurGroupList クール一覧配列
 * @property {boolean} notUsageGuide 凡例非表示フラグ
 */

/**
 * スケールベッド一覧リスト用ストア
 */
const state = {
  /**
   * クール一覧情報
   * @type { { kurGroupName: string, kurCd: number }[] }
   */
  kurGroupList: [],
  /**
   *  @type { kurName: string, kurCd: number}[]
   */
  kurListData: [],
  // ベッドグループ一覧情報
  bedListData: [],
  bedGroupList: [],
  /**
   * フィルタ条件
   * @type {SearchCondition}
   */
  filterParam: {
    // ベッドグループコード
    bedGroupCd: 0,
    // クール
    kurCdList: [],
    // クール名
    kurGroupName: [],
    kurGroupList: [],
    // 凡例非表示
    notUsageGuide: false,
    // 初期化済みフラグ
    isInitialized: false,
  },
  sortSetting: {
    sortColumn: "",
    sortKind: "normal", // normal, asc, desc
  },
  /** @type {Array<{bedCd:number, weightCd: number, weightNo:number}>} */
  targetKeyInfo: [],
  /**
   * 列幅のリスト
   */
  columnResizeData: [],
};

const actions = {

  /**
   * 列幅セット
   */
  setColumnResizeData({ commit }, columnResizeData) {
    commit("setColumnResizeData", columnResizeData);
  },

  /**
   * 検索条件セット
   * @param {Object} param0
   * @param {SearchCondition} condition
   */
  setCondition({ commit }, condition) {
    commit("setCondition", condition);
  },
  /**
   * 検索条件リセット
   * @param {Object} param0
   */
  clearCondition({ commit }) {
    commit("clearCondition");
  },
  /**
   * クールとベッドの一覧取得
   */
  async fetchKurBedGroup({ commit }) {
    // クールとベッドの一覧取得
    try {
      const response = await sendRequestGetKurSelector();
      // 取得したクール一覧情報をセット
      const kurSelector = response.data.kurSelector;
      let setdataList = [];
      kurSelector.forEach((value, index, array) => {
        let groupset = {
          kurGroupName: array[index].name,
          kurCd: array[index].code,
        };
        setdataList.push(groupset);
      });
      // ヘッダー抽出コンボボックス用
      const kurGroupList = setdataList;
      // クール抽出用
      const kurListData = kurSelector.map((dat) => {
        return {
          kurName: dat.name,
          kurCd: dat.code,
        };
      });
      // クール一覧情報をセットする
      commit("setKurList", { kurGroupList, kurListData });

      // コンボボックスにセットする情報を作成
      let comboItemList = [{ bedGroupName: "すべて", bedGroupCd: 0 }];
      response.data.bedGroupList.forEach((value, index, array) => {
        let buf = {
          bedGroupName: array[index].roomBedGroupName,
          bedGroupCd: array[index].roomBedGroupCd,
        };
        comboItemList.push(buf);
      });

      // ベッドグループ一覧情報をセットする
      commit("setBedGroupList", {
        // ヘッダー抽出コンボボックス用
        bedGroupList: comboItemList,
        // ベッドグループ抽出用
        bedListData: response.data.bedGroupList,
      });
    } catch (err) {
      console.error(err);
    }
  },
  setSortSetting({ commit }, sortSetting) {
    commit("setSortSetting", sortSetting);
  },
  setNotifyTargetKeyInfo({ commit }, targetKeyInfo) {
    commit("setNotifyTargetKeyInfo", targetKeyInfo);
  },
  resetNotifyTargetKeyInfo({ commit }) {
    commit("setNotifyTargetKeyInfo", []);
  },
};

// mutations
const mutations = {
  /** 検索条件セット */
  setCondition(state, condition) {
    state.filterParam = condition;
  },
  /** 抽出条件クリア */
  clearCondition(state) {
    state.filterParam.bedGroupCd = 0;
    state.filterParam.kurCdList = [];
    state.filterParam.kurGroupList = [];
    state.filterParam.kurGroupName = [];
    state.filterParam.notUsageGuide = false;
  },
  /**
   * クール設定
   * @param {Object} state ステート
   * @param {{
   * kurGroupList: { kurGroupName: string, kurCd: number }[],
   * kurListData: { kurName: string, kurCd: number}[]
   * }} kurList クール一覧情報
   */
  setKurList(state, kurList) {
    // ヘッダー抽出コンボボックス用
    state.kurGroupList = kurList.kurGroupList;
    // クール抽出用
    state.kurListData = kurList.kurListData;
  },
  /**
   * ベッドグループ一覧情報をセットする
   */
  setBedGroupList(state, payload) {
    state.bedGroupList = payload.bedGroupList;
    state.bedListData = payload.bedListData;
  },
  /** ソート設定セット */
  setSortSetting(state, sortSetting) {
    state.sortSetting = sortSetting;
  },
  setNotifyTargetKeyInfo(state, targetKeyInfo) {
    state.targetKeyInfo = targetKeyInfo;
  },
  setColumnResizeData(state, columnData) {
    state.columnResizeData = columnData;
  }
};

// getters
const getters = {
  /** フィルタ条件取得
   * @param {Object} state
   * @returns {SearchCondition}
   */
  getFilterParam: (state) => {
    return state.filterParam;
  },
  /**
   *
   * @param {Object} state
   * @returns {{ kurGroupName: string, kurCd: number }[]}
   */
  getKurGroupList: (state) => {
    return state.kurGroupList;
  },
  /**
   *
   * @param {Object} state
   * @returns {{ kurName: string, kurCd: number }[]}
   */
  getKurListData: (state) => {
    return state.kurListData;
  },
  getBedGroupList: (state) => {
    return state.bedGroupList;
  },
  getMstBedGroupList: (state) => {
    return state.bedListData;
  },
  getFilteredBedGroup: (state) => {
    const bedGroup = state.bedGroupList.find(
      (bed) => bed.bedGroupCd === state.filterParam.bedGroupCd
    );
    return bedGroup;
  },
  getFilteredKurList: (state) => {
    const kurList = state.kurListData.filter((kur) =>
      state.filterParam.kurCdList.includes(kur.kurCd)
    );
    return kurList ?? [];
  },
  getSortSetting: (state) => {
    return state.sortSetting;
  },
  getNotifyTargetKeyInfo: (state) => {
    /** @type {Array<{weightCd: number, weightNo: number, bedCdList: number[]}>} */
    const ret = [];
    for (const weightCd of state.targetKeyInfo.map((item) => item.weightCd)) {
      if (ret.some((item) => item.weightCd === weightCd)) {
        // すでに登録済み
        continue;
      }
      // 新規登録
      const bedCdList = state.targetKeyInfo
        .filter((item) => item.weightCd === weightCd)
        .map((item) => item.bedCd);
      const weightNo = state.targetKeyInfo.find(
        (item) => item.weightCd === weightCd
      )?.weightNo;
      ret.push({
        weightCd: weightCd,
        weightNo: weightNo,
        bedCdList: bedCdList,
      });
    }
    return ret;
  },
  getNotifyTargetKeyInfoRaw: (state) => {
    return state.targetKeyInfo;
  },
  getColumnResizeData(state) {
    return state.columnResizeData;
  },
};

export default {
  namespaced: true,
  state,
  actions,
  mutations,
  getters,
};
