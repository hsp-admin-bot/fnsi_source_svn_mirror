import {
  sendRequestGetDetailOfMachine,
  sendRequestGetLayoutDetailOfMachine,
  sendRequestGetLayoutDetailOfMachineHistory,
  sendRequestGetMachineResult,
  sendRequestGetLayoutDetail,
  sendRequestGetUerByListID,
} from "@/apis/daily-check";
import { sendRequestUserAccountInfoAll } from "@/apis/User";
import moment from "moment";
import { Answer } from "@/constants/mainteConstants";
import { deepCopy } from "@/functions/common/CommonFunctions";

export default {
  namespaced: true,
  strict: true,
  state: {
    masterItemList: null,
    resultCheckItem: [],
    layoutDetail: {},
    listDataDetail: [],
    listResultMaster: [],
    listResultMasterHis: [],
    listLayoutByLayoutclass: [],
    dailyDateSearch: moment().format("YYYY-MM-DD"),
    machine: {},
    machineResult: [],
    userAccountInfo: [],
    layoutDate: null,
    layoutParams: null,
    condition: null,
    conditionForReportParams: {
      bedCdListString: "",
      machineTypeName: "",
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
    isOpenBySubView: false,
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
  },
  getters: {
    getMachine(state) {
      return state.machine;
    },
    getMachineResult(state) {
      return state.machineResult;
    },
    getUserAccountInfo(state) {
      return state.userAccountInfo;
    },
    getLayoutParams(state) {
      return state.layoutParams;
    },
    getResultCheckItem(state) {
      return state.resultCheckItem;
    },
    getLayoutDetail(state) {
      return state.layoutDetail;
    },
    getResultMaster(state) {
      return state.listResultMaster;
    },
    getResultMasterHis(state) {
      return state.listResultMasterHis;
    },
    getDailyDateSearch(state) {
      return state.dailyDateSearch;
    },
    getCondition(state) {
      return state.condition;
    },
    getConditionForReportParams(state) {
      return state.conditionForReportParams;
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
    getIsOpenBySubView(state) {
      return state.isOpenBySubView;
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
  },
  actions: {
    setMachine({ commit }, params) {
      commit("setMachine", params);
    },
    async sendRequestGetMachineResult({ commit }, machine) {
      await sendRequestGetMachineResult(machine).then(response => {
        commit("setMachineResult", response.data);
      });
    },
    async setUserAccountInfo({ commit }, facilityCd) {
      await sendRequestUserAccountInfoAll(facilityCd).then(response => {
        commit("setUserAccountInfo", response.data);
      });
    },
    setLayoutParams({ commit }, layoutParams) {
      commit("setLayoutParams", layoutParams);
    },
    async sendRequestGetDetail({ commit }, params) {
      const [layoutDetailRes, resultDetailRes] = await Promise.all([
        sendRequestGetLayoutDetailOfMachine(
          params.machineNo,
          params.date
        ),
        sendRequestGetDetailOfMachine(
          params.machineNo,
          params.date
        ),
      ]);
      const listResult = await createResultList(
        layoutDetailRes.data,
        resultDetailRes.data,
        params.date,
        params.machineNo
      );
      commit("setResultMaster", listResult);
    },

    async sendRequestGetDetailHistory({ commit }, params) {
      const layoutDetailRes = await sendRequestGetLayoutDetailOfMachineHistory(
        params.machineNo,
        params.date,
        params.numOfMonth
      );
      // レイアウトごとの点検項目リストを最新マスタ分と点検結果に存在するものを
      // 合わせたものに置き換える
      const layoutDetailData = layoutDetailRes.data;
      layoutDetailData.forEach(layoutDetail => {
        const allDetails = [];
        if (layoutDetail.detail) {
          allDetails.push(...layoutDetail.detail);
        }
        const latestCount = allDetails.length;
        if (layoutDetail.detailHst) {
          allDetails.push(...layoutDetail.detailHst);
          // #12550対応時のメモ：
          // 点検結果に存在する点検項目のリスト detailHst から
          // 最新マスタに存在しない点検項目を追加する際には
          // 点検日降順で点検結果に出現する順番で列を追加する必要があるが、
          // 最新マスタ分の列にも項目名が同一のものがある場合は
          // 最新マスタ分に存在する列数分は detailHst から追加する列を
          // 減らす必要がある
          // その処理は点検結果の内容を見る必要があるので
          // DailyHistoryModal.vue の convertGridData の段階で行う
        }

        layoutDetail.detail = allDetails;
        layoutDetail.detailLatestCount = latestCount;
      });
      const listResult = await createResultList(
        layoutDetailData,
        // 点検履歴ではここに入れる点検結果情報を使用しないので
        // ダミー値として空配列を入れておく
        [],
        // 点検履歴では createResultList で生成される要素の
        // menteDate の値は使用しないのでダミー値としてnullを入れておく
        // （点検項目入力で保存APIに渡すオブジェクトの点検日の値になる）
        null,
        params.machineNo,
        true
      );
      commit("setResultMasterHis", listResult);
    },
    sendRequestGetLayoutDetail({ commit }, mainteLayoutCd) {
      commit("setLayoutDetail", {});
      sendRequestGetLayoutDetail(mainteLayoutCd).then(response => {
        commit("setLayoutDetail", response.data || {});
      });
    },
    setDailyDateSearch({ commit }, params) {
      commit("setDailyDateSearch", params);
    },
    setCondition({ commit }, params) {
      // 抽出条件セット
      commit("setCondition", params);
    },
    setConditionForReportParams({ commit }, params) {
      // 機能帳票印刷パラメータ生成用抽出条件情報セット
      commit("setConditionForReportParams", params);
    },
  },
  mutations: {
    setResultCheckItem(state, data) {
      state.resultCheckItem = data;
    },
    setLayoutDetail(state, data) {
      state.layoutDetail = data;
    },
    setInspectionMaster(state, data) {
      state.InspectionItemmasterList = data;
    },
    setResultMaster(state, data) {
      state.listResultMaster = data;
    },
    setResultMasterHis(state, data) {
      state.listResultMasterHis = data;
    },
    setCondition(state, params) {
      state.condition = deepCopy(params);
    },
    setConditionForReportParams(state, params) {
      Object.assign(state.conditionForReportParams, {
        bedCdListString: params.bedCdListString || "",
        machineTypeName: params.machineTypeName || "",
      });
    },
    setDailyDateSearch(state, params) {
      state.dailyDateSearch = params;
    },
    setMachine(state, {
      machineName,
      machineType,
      machineSerial,
      bedName,
      machineNo,
    }) {
      state.machine = {
        machineName,
        machineType,
        machineSerial,
        bedName,
        machineNo,
      };
    },
    setMachineResult(state, params) {
      state.machineResult = params;
    },
    setUserAccountInfo(state, userAccountInfo) {
      state.userAccountInfo = userAccountInfo;
    },
    setLayoutParams(state, layoutParams) {
      state.layoutParams = layoutParams;
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
    setIsOpenBySubView(state, data) {
      state.isOpenBySubView = data;
    },
    // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
  },
};

// sendRequestGetDetailOfMachine のレスポンスから点検項目ごとの点検結果情報を生成する
const createResultDetailInfo = async resultDetailData => {
  const resultDetailList = [];
  const userIDList = [];
  // 点検項目ごとの点検結果情報リストを生成する
  resultDetailData.forEach(resultData => {
    if (!resultData.detail) return;

    JSON.parse(resultData.detail).forEach(({
      date,
      judge,
      user_id,
      comment,
      detail_cd,
      cate_cd,
      cate_edi,
      detail_edi,
      sub_cmt,
    }) => {
      // 点検結果が "" の場合は null に読み替える
      if (judge === Answer.NotDate) {
        judge = Answer.NotDateForDb;
      }
      // 過去のデータでは cate_edi が文字列として登録されている場合があるため数値に変換する
      cate_edi = Number(cate_edi);
      resultDetailList.push({
        ...resultData,
        dateUpdate: date ? moment(date).format("YYYY-MM-DD HH:mm") : "",
        answer: judge,
        itemCheckerId: user_id,
        comment,
        menteDetailCd: detail_cd,
        cate_cd,
        cate_edi,
        detail_edi,
        iniText: sub_cmt,
      });
      // 点検者のIDリストに追加する
      if (user_id && !userIDList.includes(user_id)) {
        userIDList.push(user_id);
      }
    });
  });
  // 点検結果の点検者の名前リストを生成する
  const userNameList = [];
  if (userIDList.length) {
    await sendRequestGetUerByListID(userIDList).then(res => {
      userNameList.push(...res.data.map(user => ({
        userId: user.userId,
        fullName: `${user.userLastName} ${user.userFirstName}`,
      })));
    });
  }
  return { resultDetailList, userNameList };
};

// 日時文字列から date と time に分割したオブジェクトを生成する
const createDateAndTime = dateTime => dateTime ? {
  date: dateTime.substring(0, 10),
  time: dateTime.substring(11),
} : { date: "", time: "" };

// 点検項目の点検者情報のダミー値
const dummyUserName = {
  userId: 0,
  fullName: "",
};

// sendRequestGetLayoutDetailOfMachine や
// sendRequestGetLayoutDetailOfMachineHistory のレスポンスから
// 点検項目ごとの情報を生成する
const createDetailItems = (
  layoutDetail,
  machineNo,
  { resultDetailList, userNameList },
  forHistory = false
) => {
  if (!layoutDetail.detail) return [];

  const detailItems = layoutDetail.detail.map(detail => {
    // menteContent3 に文字列として入っている点検項目グループの版数を取得する
    const detailCateEdi = Number(detail.menteContent3);
    const resultDetailItem = resultDetailList.find(item => (
      item.menteDetailCd === detail.menteDetailCd
      && item.menteLayoutCd === layoutDetail.layout.menteLayoutCd
      && item.cate_cd === detail.menteCategoryCd
      && item.detail_edi === detail.editionNo
      && item.cate_edi === detailCateEdi
    ));
    // 点検項目入力の場合は初期展開テキストの値を取得しておく
    const masterIniText = forHistory ? "" : detail.iniText;
    const newItem = {
      menteLayoutCd: layoutDetail.menteLayoutCd,
      machineNo,
    };
    if (resultDetailItem) {
      // sendRequestGetDetailOfMachine のレスポンスに
      // 点検レイアウトコードが一致するものが存在する場合
      // その情報から点検結果に関する項目の値を設定する
      const {
        iniText,
        cate_cd,
        cate_edi,
        detail_edi,
        answer,
        dateUpdate,
        itemCheckerId,
        comment,
      } = resultDetailItem;
      detail.iniText = iniText;
      detail.cateCd = cate_cd;
      detail.cateEdi = cate_edi;
      detail.detailEdi = detail_edi;
      const userName = (
        answer !== Answer.NotDateForDb
        && userNameList.find(user => user.userId === itemCheckerId)
      ) || dummyUserName;
      Object.assign(newItem, {
        ...detail,
        answer,
        dateUpdate,
        ...createDateAndTime(dateUpdate),
        checkerId: itemCheckerId,
        ...userName,
        comment,
      });
    } else {
      // 点検結果に関する項目の値に初期値を設定する
      detail.cateCd = detail.menteCategoryCd;
      detail.cateEdi = detailCateEdi;
      detail.detailEdi = detail.editionNo;
      const dateUpdate = "";
      Object.assign(newItem, {
        ...detail,
        answer: Answer.NotDateForDb,
        dateUpdate,
        ...createDateAndTime(dateUpdate),
        ...dummyUserName,
        checkerId: null,
        comment: "",
        upDate: null,
      });
    }
    if (!forHistory) {
      // 点検項目入力の場合は masterIniText を設定する
      newItem.masterIniText = masterIniText;
    }
    return newItem;
  });
  return detailItems;
};
// sendRequestGetLayoutDetailOfMachine や
// sendRequestGetLayoutDetailOfMachineHistory のレスポンスから
// sendRequestGetDetailOfMachine のレスポンスの情報も使用して
// 点検レイアウトごとの情報を生成する
const createResultList = async (
  layoutDetailData,
  resultDetailData,
  menteDate,
  machineNo,
  forHistory = false
) => {
  // sendRequestGetDetailOfMachine のレスポンスから点検項目ごとの点検結果情報を生成する
  const resultDetailInfo = await createResultDetailInfo(resultDetailData);

  let resultCount = 0;
  const resultList = layoutDetailData.map(layoutDetail => {
    // 点検項目ごとの情報を生成する
    const items = createDetailItems(
      layoutDetail,
      machineNo,
      resultDetailInfo,
      forHistory
    );
    const {
      facilityCd,
      layoutName,
      layoutHeader,
      isDel,
      upDate,
      menteLayoutCd,
      editionNo: mainteLayoutEdition,
    } = layoutDetail.layout;
    // sendRequestGetDetailOfMachine のレスポンスから生成した情報から
    // 点検レイアウトコードが一致するものを検索する
    const resultData = resultDetailData.find(
      item => item.menteLayoutCd === menteLayoutCd
    );

    const newItem = {
      menteDate,
      facilityCd,
      machineNo,
      layoutName,
      layoutHeader,
      items,
    };
    if (forHistory) {
      // 点検履歴用の場合
      // 最新マスタのレイアウトかのフラグも設定する
      newItem.isCurrent = layoutDetail.isCurrent;
      // 点検結果が持つ点検項目の項目名を取得するための情報を設定する
      newItem.detailHst = layoutDetail.detailHst;
      // 最新マスタに対応する点検項目の数を設定する
      newItem.detailLatestCount = layoutDetail.detailLatestCount;
    } else {
      // 点検項目入力用の場合はグループ名表示用の情報も設定する
      newItem.layoutTitle = layoutHeader || null;
      // データ構造上は1装置（1型式）に対して複数のグループが
      // 対象になる可能性があるが、その場合の対応はAPI側で実施されることで
      // ここではグループは1件のみ入っている想定
      newItem.groupHeader = layoutDetail.category?.[0]?.categoryName || null;
      newItem.categoryList = layoutDetail.category;
    }
    if (resultData) {
      // sendRequestGetDetailOfMachine のレスポンスに
      // 点検レイアウトコードが一致するものが存在する場合
      // その情報から点検結果に関する項目の値を設定する
      const {
        menteAns1,
        detail,
        devMenteNo,
        menteLayoutGroupCd,
        mainteLayoutGroupEdition,
        menteLayoutCd: masterMenteLayoutCd,
        mainteLayoutEdition: masterMainteLayoutEdition,
        mainteCategoryCd,
      } = resultData;
      Object.assign(newItem, {
        menteAns1,
        detail,
        devMenteNo,
        menteLayoutGroupCd,
        mainteLayoutGroupEdition,
        menteLayoutCd: masterMenteLayoutCd,
        mainteLayoutEdition: masterMainteLayoutEdition,
        mainteCategoryCd,
      });
      resultCount++;
    } else {
      // 点検結果に関する項目の値に初期値を設定する
      Object.assign(newItem, {
        menteAns1: Answer.NotDateForDb,
        detail: "[]",
        devMenteNo: null,
        isDel,
        upDate,
        menteLayoutCd,
        mainteLayoutEdition,
      });
    }
    return newItem;
  });
  if (!forHistory && resultCount && (resultList.length !== resultCount)) {
    // 点検項目入力用で点検結果レコードが存在するレイアウトと
    // 存在しないレイアウトが混在している場合は
    // 点検結果が存在しないレイアウトを除外するフィルタ処理を行う
    const filteredList = resultList.filter(item => item.devMenteNo != null);
    resultList.splice(0, Infinity, ...filteredList);
  }
  return resultList;
};
