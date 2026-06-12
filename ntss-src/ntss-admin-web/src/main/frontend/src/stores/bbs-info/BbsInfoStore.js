import dayjs from "@/compat/date/dayjs";
import {
  searchBbsList,
  searchPatList,
  selectedBbsInfo
} from "@/functions/BbsInfoFunctions.js";
import { deserializeJsonColumn, customSanitizer } from "@/functions/common/CommonFunctions";
import {ApiHelper} from "@/apis/AxiosHelper";

/**
 * 掲示板登録情報用ストア
 */
export default {
  namespaced: true,
  strict: true,
  state: {
    // 検索条件一覧
    selectedCondition: {
      // カテゴリ機能
      categoryFuncList: [], // 初期値設定:すべて
      // カテゴリ種類
      categoryKindList: [],
      // フリーワード
      freeWord: "", // 初期値設定:未入力
      // 掲載開始日
      noticeStartDate: dayjs().format("YYYY-MM-DD"), // 初期値設定:本日
      // 掲載終了日
      noticeEndDate: dayjs().format("YYYY-MM-DD"), // 初期値設定:本日,
      // 透析日
      dialysisDate: null, // 初期値設定:未入力
      // クール
      kur: null, // 初期値設定:すべて
      // ベッドグループ
      roomBedGroup: { bedGroupCd: null, bedCdList: [] },// 初期値設定:すべて
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      // 表示件数
      limitFrom: 0,
      limitTo: 0,
      userId: "",
      sortColumn: "",
      sortKind: "",
      targetUserId: ""
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
    },

    // 検索条件初期値
    defaultCondition: null,

    /**
     * @description 選択記事
     * @summary テーブルの内容を持つ
     */
    selectedBbs: {
      bbs_ctl_no: null,
      facility_cd: null,
      pat_info: { target: null, detail: [] },
      staff_info: {
        target: [],
        read: []
      },
      func_cd: null,
      kind_no: null,
      fn_seq_id: null, // 内容管理番号(観察記録等)
      content: null,
      file_info: [],
      notice_start_date: null,
      notice_end_date: null,
      reg_staff_id: null,
      reg_staff_name: null,
      upd_staff_id: null,
      upd_staff_name: null,
      transition_router_path: null,
      reg_date: null,
      up_date: null,
      /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start*/
      html_content: null,
      /*add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end*/
      reg_func_class: null
    },

    /**
     * @description 検索結果掲示板一覧※掲示板一覧画面以外ではこちらを使用(未読の絞り込みあり)
     * @type {Array} [{ bbs_ctl_no, facility_cd, pat_info, staff_info, ...}, ...]
     */
    searchedBbsList: [],

    /**
     * @description 検索結果を保持する掲示板一覧※掲示板一覧画面のみで使用(未読等の絞り込みしない)
     */
    searchedKeepBbsList: [],
// add マスタ削除 対応 chen start
    mstBbsKindAll: [],
// add マスタ削除 対応 chen end

    /**
     * @description 掲示板読み込み中フラグ
     * @summary 掲示板詳細ヘッダでの読み込み状態を管理
     * @type {Boolean}
     */
    isLoadingBbs: false,

    userId: null,
    userName: null,

    isOnlyUnread: false,

    // 検索条件設定有無フラグ※初期表示判断用
    isSelectedCondition: false,

    selectCreatedBbs: null,

    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    sortColumn: null,
    sortKind: null,
    isNotRun: false,
    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
    
    isExistBbsInfo: false,

    isInitialDisp: true,

    regFuncClass: null,

    htmlContent: null,
  },

  getters: {
    /**
     * @description 検索条件
     */
    selectedCondition(state) {
      return state.selectedCondition;
    },

    /**
     * @description 検索条件初期値
     */
    getDefaultCondition(state) {
      return state.defaultCondition;
    },

    /**
     * @description 選択した記事
     */
    selectedBbs(state) {
      return state.selectedBbs;
    },

    /**
     * @description 選択した記事番号
     */
    selectedBbsCtlNo: state => {
      if (state.selectedBbs === null) {
        return null;
      }
      return state.selectedBbs.bbs_ctl_no;
    },

    /**
     * @description 掲載されている記事一覧
     */
    searchedBbsList(state) {
      return state.searchedBbsList;
    },

    /**
     * @description 掲載されている記事一覧
     */
    searchedKeepBbsList(state) {
      return state.searchedKeepBbsList;
    },

// add マスタ削除 対応 chen start
    mstBbsKindAll(state) {
      return state.mstBbsKindAll;
    },
// add マスタ削除 対応 chen end

    isLoadingBbs: state => state.isLoadingBbs,

    userId(state) {
      return state.userId;
    },

    userName(state) {
      return state.userName;
    },

    isOnlyUnread: state => state.isOnlyUnread,

    isSelectedCondition: state => state.isSelectedCondition,

    selectCreatedBbs: state => state.selectCreatedBbs,

    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    sortColumn(state) {
      return state.sortColumn;
    },
    sortKind(state) {
      return state.sortKind;
    },
    isNotRun: state => state.isNotRun,
    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end,
    isExistBbsInfo: state => state.isExistBbsInfo,

    isInitialDisp: state => state.isInitialDisp,

    regFuncClass: state => state.regFuncClass,

    htmlContent: state => state.htmlContent,
  },

  mutations: {
    setSelectedCondition(state, selectedCondition) {
      state.selectedCondition = selectedCondition;
    },

    setDefaultCondition(state, defaultCondition) {
      state.defaultCondition = defaultCondition;
    },

    setSelectedBbs(state, record) {
      state.selectedBbs = record;
    },

    setSearchedBbsList(state, recordList) {
      state.searchedBbsList = recordList;
    },

    setSearchedKeepBbsList(state, recordList) {
      state.searchedKeepBbsList = recordList;
    },

// add マスタ削除 対応 chen start
    setMstBbsKindAll(state, mstBbsKindAll) {
      state.mstBbsKindAll = mstBbsKindAll;
    },
// add マスタ削除 対応 chen end

    setIsLoadingBbs: (state, b) => {
      state.isLoadingBbs = b;
    },

    setUserId(state, userId) {
      state.userId = userId;
    },

    setUserName(state, userName) {
      state.userName = userName;
    },

    setIsOnlyUnread: (state, b) => {
      state.isOnlyUnread = b;
    },

    setIsSelectedCondition: (state, b) => {
      state.isSelectedCondition = b;
    },

    setSelectCreatedBbs: (state, selectCreatedBbs) => {
      state.selectCreatedBbs = selectCreatedBbs;
    },

    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    setSortColumn(state, sortColumn) {
      state.sortColumn = sortColumn;
    },
    setSortKind(state, sortKind) {
      state.sortKind = sortKind;
    },

    setIsNotRun: (state, b) => {
      state.isNotRun = b;
    },
    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
    
    setIsExistBbsInfo: (state, isExistBbsInfo) => {
      state.isExistBbsInfo = isExistBbsInfo;
    },

    setIsInitialDisp: (state, isInitialDisp) => {
      state.isInitialDisp = isInitialDisp;
    },

    setRegFuncClass: (state, regFuncClass) => {
      state.regFuncClass = regFuncClass;
    },

    setHTMLContent: (state, htmlContent) => {
      state.htmlContent = htmlContent;
    },
  },

  actions: {
    /**
     * @description 検索条件の設定
     * @param {Object} selectedCondition
     */
    setSelectedCondition({ commit }, selectedCondition) {
      commit("setSelectedCondition", selectedCondition);
    },

    /**
     * @description 検索条件初期値の設定
     * @param {Object} defaultCondition
     */
    setDefaultCondition({ commit }, defaultCondition) {
      commit("setDefaultCondition", defaultCondition);
    },

    /**
     * @description 選択した記事を設定
     * @param {Object} record
     */
    setSelectedBbs({ commit }, record) {
      commit("setSelectedBbs", record);
    },

    /**
     * @description 掲載している掲示板一覧を設定
     * @param {Object} record
     */
    setSearchedBbsList({ commit }, recordList) {
      commit("setSearchedBbsList", recordList);
    },

    setIsLoadingBbs: ({ commit }, isLoadingBbs) => {
      commit("setIsLoadingBbs", isLoadingBbs);
    },

    setUserId({ commit }, userId) {
      commit("setUserId", userId);
    },

    setUserName({ commit }, userName) {
      commit("setUserName", userName);
    },

    setIsOnlyUnread: ({ commit }, isOnlyUnread) => {
      commit("setIsOnlyUnread", isOnlyUnread);
    },

    setIsSelectedCondition: ({ commit }, isSelectedCondition) => {
      commit("setIsSelectedCondition", isSelectedCondition);
    },

    setSelectCreatedBbs: ({ commit }, selectCreatedBbs) => {
      commit("setSelectCreatedBbs", selectCreatedBbs);
    },

    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    setIsNotRun: ({ commit }, isNotRun) => {
      commit("setIsNotRun", isNotRun);
    },
    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end

    /**
     * @description 検索結果を一覧として格納
     */
    async setSearchedList({ getters, commit }, condition) {
      condition.selectedCondition.targetUserId = getters.userId;
      let searchedBbsList = await searchBbsList(
        condition.selectedCondition,
        condition.facilityCd
      );
      // add 障害票一覧_掲示板修正 陳 start
      searchedBbsList.forEach(item=> {
        item.notice_date = item.notice_date.replace('1900/01/01',' ');
        item.notice_date = item.notice_date.replace('9999/12/31',' ');
        item.notice_date = item.notice_date.replace('  ～  ','');
      });
      // add 障害票一覧_掲示板修正 陳 end
      // 操作スタッフ宛の掲示板のみ取得(全スタッフ対象も含む)
      const bbsFilteredByStaff = searchedBbsList.filter(bbs => {
        return (
          bbs.staff_info.target
            .map(el => el)
            .includes(getters.userId) || bbs.staff_info.target.length === 0
        );
      });

      let patCdList = [];
      bbsFilteredByStaff.forEach(
        bbs => (patCdList = [...patCdList, ...bbs.pat_info.detail])
      );
      // 掲示板一覧から患者IDを取得
      const patIdList = patCdList.reduce((acc, curVal) => {
        if (!acc.includes(curVal)) {
          // 重複排除
          acc.push(curVal);
        }
        return acc;
      }, []);

      if (patIdList.length !== 0) {
        const patPersonalInfoList = await searchPatList(patIdList);
        // 画面遷移をした場合でも患者名を常に表示できるよう、storeに設定
        // 掲示板一覧の患者IDに患者名を紐づける
        bbsFilteredByStaff.forEach(bbs => {
          bbs.pat_info.detail = bbs.pat_info.detail.map(bbsPatId =>
            patPersonalInfoList.find(pat => pat.pat_id === bbsPatId)
          );
        });
      }
      // 掲示板詳細画面で参照(スワイプ機能)できるよう、storeに設定
      // delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      // commit("setSearchedKeepBbsList", filteredBbsList);
      // delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      if (condition.selectedCondition.limitFrom == 0 || condition.selectedCondition.sortColumn == "pat_info") {
        commit("setSearchedKeepBbsList", bbsFilteredByStaff);
      } else {
        const keepBbsList = getters.searchedKeepBbsList;
        bbsFilteredByStaff.forEach(e => {
          keepBbsList.push(e);
        });
        commit("setSearchedKeepBbsList", keepBbsList);
      }

// add マスタ削除 対応 chen start
      const mstBbsKindAll = await ApiHelper.get(`/mstInfo/mstBbsKindAll`, {
        facilityCd: condition.facilityCd
      });
      commit("setMstBbsKindAll", mstBbsKindAll.data);
// add マスタ削除 対応 chen end
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
    },

    /**
     * @description 選択した掲示板番号の詳細情報取得
     */
    async setSelectedBbsInfo({ commit }, payload) {
      const bbsCtlNo = payload && typeof payload === "object" ? payload.bbsCtlNo : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      // 選択した掲示板番号の詳細情報をDBから取得
      const responseBbsInfo = await selectedBbsInfo(bbsCtlNo, selectedPatId);
      const deserializeRecordList = responseBbsInfo.data;

      const jsonColumns = ["pat_info", "staff_info", "file_info"];
      // 掲示板情報取得
      const bbsInfo = deserializeJsonColumn(deserializeRecordList, jsonColumns);
      bbsInfo.html_content = customSanitizer(bbsInfo.html_content);
      // 詳細画面で情報を展開するため、取得したDBデータをストアに格納する
      commit("setSelectedBbs", bbsInfo);
      commit("setRegFuncClass", bbsInfo.reg_func_class);
      commit("setHTMLContent",bbsInfo.html_content);
    },

    /**
     * @description 掲示板一覧情報セット
     * @summary サインイン中スタッフ変更時に使用
     */
    setSearchedKeepBbsList({ commit }, bbsInfoList) {
      commit("setSearchedKeepBbsList", bbsInfoList);
    },
// add マスタ削除 対応 chen start
    setMstBbsKindAll({ commit }, mstBbsKindAll) {
      commit("setMstBbsKindAll", mstBbsKindAll);
    },
// add マスタ削除 対応 chen end

    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    setSortColumn({ commit }, sortColumn) {
      commit("setSortColumn", sortColumn);
    },
    setSortKind({ commit }, sortKind) {
      commit("setSortKind", sortKind);
    },
    // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end

    /**
     * @description 選択した掲示板番号の詳細情報取得
     * URLダイレクト/通知からの遷移用。遷移処理(NotificationMessageMixin)では
     * ApiHelper(及びそれをインポートする共通処理)がインポートできないためStoreのActions経由で取得
     */
    async checkExistBbsInfo({ commit }, bbsCtlNo) {
      // 選択した掲示板番号の詳細情報をDBから取得
      const responseBbsInfo = await selectedBbsInfo(bbsCtlNo);
      const deserializeRecordList = responseBbsInfo.data;
      const isExistBbsInfo = 
        Object.prototype.hasOwnProperty.call(deserializeRecordList, "pat_info") &&
        Object.prototype.hasOwnProperty.call(deserializeRecordList, "staff_info") &&
        Object.prototype.hasOwnProperty.call(deserializeRecordList, "file_info");
      commit("setIsExistBbsInfo", isExistBbsInfo);
    },

    setIsInitialDisp({ commit }, initialDisp) {
      commit("setIsInitialDisp", initialDisp);
    },

    setRegFuncClass({ commit }, regFuncClass) {
      commit("setRegFuncClass", regFuncClass);
    },

    setHTMLContent({ commit }, htmlContent) {
      commit("setHTMLContent", htmlContent);
    },
  }
};
