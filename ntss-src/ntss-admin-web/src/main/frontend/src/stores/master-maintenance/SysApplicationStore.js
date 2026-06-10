import { ApiHelper } from "@/apis/AxiosHelper";
import { sendRequestFindRecordList } from "@/apis/master-maintenance";
import { FUNC_SCALE_BED } from "@/constants/function-code";

export default {
  namespaced: true,
  state: {
    /** ヘッダ検索条件 */
    condition: {
      recordName: ""
    },
    /** グリッド表示用項目定義 */
    sysApplicationColumn: [
      {
        field: "dummy_disp_no",
        title: " ",
        width: "10px",
        locked: true,
        editable: () => false
      },
      {
        field: "applicationName",
        title: "アプリケーション名",
        width: "20em",
        hidden: false,
        editable: () => false
      },
      {
        field: "version",
        title: "バージョン",
        width: "9em",
        hidden: false,
        editable: () => false
      },
      {
        field: "appdownBtn",
        title: "ダウンロード",
        width: "9em",
        hidden: false,
        editable: () => false,
      }
    ],
    /** アプリケーション情報 */
    applicationInfo: [],
  },
  getters: {
    /** 項目列取得 */
    getSysApplicationColumn(state) {
      return state.sysApplicationColumn;
    },
    /** アプリケーション情報取得 */
    getApplicationInfo(state) {
      return state.applicationInfo;
    },
    /** 検索条件取得 */
    getCondition(state) {
      return state.condition;
    },
  },
  actions: {
    /** 検索条件設定 */
    setCondition({ commit }, condition) {
      commit("setCondition", condition);
    },
    /** アプリケーション情報クリア */
    cleanApplicationInfo({ commit }){
      commit("setApplicationInfo", []);
    },
    /** 項目列設定 */
    setSysApplicationColumn({ commit }, columns) {
      commit("setSysApplicationColumn", columns);
    },
    /** アプリケーション情報取得 */
    async fetchApplicationInfo({ commit, state, rootState }) {
      /* アプリケーションダウンロード情報の取得 */
      const response = await sendRequestFindRecordList("sys_application");
      let appInfo = response.data.localDataSource.data;
      // 表示条件（is_disp=1, is_del=0）で絞り込み
      // #11987 2025.12.25 mod isDispとisDelは文字列型なので文字列で判定するように改善 TDC伊東 start
      // appInfo = appInfo.filter(item => item.isDisp == 1 && item.isDel == 0);
      appInfo = appInfo.filter(item => item.isDisp == "1" && item.isDel == "0");
      // #11987 2025.12.25 mod isDispとisDelは文字列型なので文字列で判定するように改善 TDC伊東 end
      // #11987 2025.12.25 add スケールベッドアプリの行を非表示にする TDC伊東 start
      const useFunction = rootState.facility.useFunction || [];
      // 取得したuseFunctionを使って、スケールベッド機能の有効/無効設定を取得する
      // useFunctionにスケールベッドの設定が含まれていない場合、スケールベッドアプリ行を非表示にする
      if (!useFunction.includes(FUNC_SCALE_BED)) {
        appInfo = appInfo.filter(item => item.applicationName !== "スケールベッドアプリ");
      }
      // #11987 2025.12.25 add スケールベッドアプリの行を非表示にする TDC伊東 end
      // disp_orderでソート
      appInfo.sort((a, b) => a.dispOrder - b.dispOrder);
      // 検索条件：アプリ名での絞り込み
      if (state.condition && state.condition.recordName) {
        const recordName = state.condition.recordName.toLowerCase();
        appInfo = appInfo.filter(item => item.applicationName.toLowerCase().includes(recordName));
      }
      /* システム設定からバージョン情報の取得 */
      const versionRequests = appInfo.map(async item => {
        if (/^\d+$/.test(item.version)) {
          const verInfo = await ApiHelper.get(`/sys_system_define/getSysSystemDefine/${item.version}`);
          const parsedValue = verInfo.data[0] ? JSON.parse(verInfo.data[0].value) : null;
          if (parsedValue && parsedValue.version) {
            item.version = parsedValue.version;
          }
        }
        return item;
      });
      appInfo = await Promise.all(versionRequests);
      commit("setApplicationInfo", appInfo);
    },
  },
  mutations: {
    /** 検索条件設定 */
    setCondition(state, condition) {
      state.condition = condition;
    },
    /** 項目列設定 */
    setSysApplicationColumn(state, data) {
      state.sysApplicationColumn = data;
    },
    /** アプリケーション情報設定 */
    setApplicationInfo(state, data) {
      state.applicationInfo = data;
    },
  }
};
