/**
 * アプリケーション共通のstore
 */
export default {
  strict: true,
  namespaced: true,
  state: {
    path: {
      protocol: "",
      host: "",
      pathname: "",
      key: ""
    },
    apiResult: {
      status: 200,
      message: ""
    },
    queryParameters: {},
    functionCd: "",
    //liyanze-z 施舍切替互換性がある obj
    refreshKeyObj:{
      status:false,
      date:0
    },
  },
  mutations: {
    // store設定
    setState(state, connectInfo) {
      state.path.protocol = connectInfo.protocol;
      state.path.host = connectInfo.host;
      state.path.pathname = connectInfo.pathname;
      state.path.key = connectInfo.key;
    },
    // storeクリア
    clear(state) {
      state.path.protocol = "";
      state.path.host = "";
    },
    // API処理結果クリア
    clearApiResult(state) {
      state.apiResult.status = 200;
      state.apiResult.message = "";
    },
    // API処理結果設定
    setApiResult(state, { status, message }) {
      state.apiResult.status = status;
      state.apiResult.message = message;
    },
    // クエリパラメータ設定
    setQueryParameters(state, queryParameters) {
      state.queryParameters = queryParameters;
    },
    // 機能コード設定
    setFunctionCd(state, functionCd) {
      state.functionCd = functionCd;
    },
    //liyanze-z 施舍切替互換性がある change
    refreshFunction(state, obj) {
      state.refreshKeyObj = obj;
    },
  },
  actions: {
    setState({ commit }, connectInfo) {
      commit("setState", connectInfo);
    },
    clear({ commit }) {
      commit("clear");
    },
    clearApiResult({ commit }) {
      commit("clearApiResult");
    },
    setApiResult({ commit }, { status, message }) {
      commit("setApiResult", { status: status, message: message });
    },
    setQueryParameters({ commit }, queryParameters) {
      commit("setQueryParameters", queryParameters);
    },
    setFunctionCd({ commit }, functionCd) {
      commit("setFunctionCd", functionCd);
    },
    //liyanze-z 施舍切替互換性がある  actions
    refreshFunction({ commit }, obj) {
      commit("refreshFunction", obj);
    },
  },
  getters: {
    getProtocol(state) {
      return state.path.protocol;
    },
    getHost(state) {
      return state.path.host;
    },
    getPathname(state) {
      return state.path.pathname;
    },
    getKey(state) {
      return state.path.key;
    },
    // ログイン画面へ遷移する際、URLにパラメータが含まれている場合に書き変わらない為、
    // window.locationに下記値を渡して遷移するように変更
    getUrl(state) {
      let url = state.path.pathname
        ? `${state.path.protocol}//${state.path.host}/${state.path.pathname}`
        : `${state.path.protocol}//${state.path.host}`;

      if (state.path.key) {
        url += "#/?key=" + state.path.key;
      }

      return url;
    },
    getApiResult(state) {
      return state.apiResult;
    },
    hasApiError(state) {
      return state.apiResult.status !== 200;
    },
    getQueryParameters(state) {
      return state.queryParameters;
    },
    getFunctionCd(state) {
      return state.functionCd;
    },
    //liyanze-z 施舍切替互換性がある  getter
    getRefresh(state){
      return state.refreshKeyObj;
    }
  }
};
