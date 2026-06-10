/**
 * 患者の処方Store.
 */
import {
  // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start
  sendRequestGetFacilityNameByCd,
  // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou end
  // add FNSI5516処方薬剤選択画面の表示が遅い 周 start
  sendRequestGetDrugsByOffsetAndLimit,
  // add FNSI5516処方薬剤選択画面の表示が遅い 周 end
  sendRequestGetDrugs,
  sendRequestGetTakeMedicine,
  sendRequestSavePrescription,
  sendRequestGetPatInsurance,
  sendRequestGetOrderPrescription,
  sendRequestGetOrderPrescriptionDetail,
  sendRequestGetDoctorsAtFacility,
  sendRequestDeleteOrderPrescription,
  sendRequestGetInsuInfoByCd
} from "@/apis/pat-prescription";
import BigNumber from "bignumber.js";
import { isEqual } from 'lodash';
import { MEDICINE_TYPE } from "@/constants/patPrescriptionConstants";

const initialSearchCondition = {
  startDate: "",
  endDate: "",
  checkHos: "",
  checkIss: "",
};

export default {
  strict: true,
  namespaced: true,
  ordPrescriptionNo: null,
  state: {
    // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou start
    routeFlag: true,
    otherFacilityFlag: false,
    appointedDate: "",
    facilityName: "",
    // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou end
    drugList: [],
    viewMode: false,
    isEdit: false,
    originalEditRecord: [],
    isInputModalChanged: false,
    //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 start
    isDoctorChanged: false,
    //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 end
    editRecord: [],
    indexRow: -1,
    listTakeMedicine: [],
    listPatInsurance: [],
    listOrderPres: [],
    ordPrescriptionNo: 0,
    // add FutreNetWeb+SI課題管理No5520 趙 start
    startDate: null,
    endDate: null,
    // add FutreNetWeb+SI課題管理No5520 趙 end
    ordPrescriptionPatId: 0,
    prescriptionDetail: [],
    inputModal: {
      startDate: "",
      endDate: "",
      checkHos: "1",
      issued: false,
      isChild: false,
      isDoubt: false,
      isInformation: false,
      isElderly: false,
      isElderly7: false,
      isAnesthesia: false,
      doctor: "",
      patInsurance: "",
      remarksFree: "",
      isRefill: false,
      refillNum: NaN,
    },
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
    treatBaseDate: []
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
    ,infoFromCalendar:{
      checkedDate: null,
      checkedInOroutFlg: null,
      inOroutFlg: null
    },
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
    //add FutreNetWeb+SI課題管理-NO.4295 劉全航 start
    searchCondition: { ...initialSearchCondition },
    //add FutreNetWeb+SI課題管理-NO.4295 劉全航 end
  },
  mutations: {
    // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou start
    setRouteFlag(state, routeFlag) {
      state.routeFlag = routeFlag;
    },
    setOtherFacilityFlag(state, otherFacilityFlag) {
      state.otherFacilityFlag = otherFacilityFlag;
    },
    setAppointedDate(state, appointedDate) {
      state.appointedDate = appointedDate;
    },
    setFacilityName(state, facilityName) {
      state.facilityName = facilityName;
    },
    // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou end
    setIsInputModalChanged(state, condition) {
      return state.isInputModalChanged = condition;
    },
    //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 start
    setIsDoctorChanged(state, isDoctorChanged){
      state.isDoctorChanged = isDoctorChanged;
    },
    //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 end
    setOriginalEditRecord(state, originalEditRecord) {
      state.originalEditRecord = originalEditRecord;
    },
    setDrugList(state, drugList) {
      state.drugList = drugList;
    },
    setViewMode(state, viewMode) {
      state.viewMode = viewMode;
    },
    setIsEdit(state, isEdit) {
      state.isEdit = isEdit;
    },
    setEditRecord(state, editRecord) {
      state.editRecord = editRecord;
    },
    setIndexRow(state, indexRow) {
      state.indexRow = indexRow;
    },
    setListTakeMedicine(state, listTakeMedicine) {
      state.listTakeMedicine = listTakeMedicine;
    },
    setListPatInsurance(state, listPatInsurance) {
      state.listPatInsurance = listPatInsurance;
    },
    setListOrderPres(state, listOrderPres) {
      state.listOrderPres = listOrderPres;
    },
    setInputModal(state, inputModal) {
      state.inputModal = inputModal;
    },
    setOrdPrescriptionNo(state, ordPrescriptionNo) {
      state.ordPrescriptionNo = ordPrescriptionNo;
    },
    // add FutreNetWeb+SI課題管理No5520 趙 start
    setStartDate(state, startDate) {
      state.startDate = startDate;
    },
    setEndDate(state, endDate) {
      state.endDate = endDate;
    },
    // add FutreNetWeb+SI課題管理No5520 趙 end
    setOrdPrescriptionPatId(state, ordPrescriptionPatId) {
      state.ordPrescriptionPatId = ordPrescriptionPatId;
    },
    setPrescriptionDetail(state, prescriptionDetail) {
      state.prescriptionDetail = prescriptionDetail;
    },
    // add FNSI5516処方薬剤選択画面の表示が遅い 周 start
    addDrugList(state, data) {
      if(undefined !== state.drugList && null !== state.drugList && state.drugList.length > 0) {
        for(const elem of data) {
          const foundData = state.drugList.find(
            //    mod 10225 処方薬剤選択に一般名処方が表示しない。 関  start
            dataSrc => dataSrc.medicineCd === elem.medicineCd && dataSrc.genericCd === elem.genericCd
            //    mod 10225 処方薬剤選択に一般名処方が表示しない。 関  end
          );
          if (!foundData) {
            state.drugList.push(elem);
          }
        }
      } else {
        state.drugList = data;
      }
    },
    // add FNSI5516処方薬剤選択画面の表示が遅い 周 end
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
    setTreatBaseDate(state, treatBaseDate) {
      state.treatBaseDate = treatBaseDate;
    }
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
    ,setInfoFromCalendar(state, infoFromCalendar) {
      state.infoFromCalendar = infoFromCalendar;
    }
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
    //add FutreNetWeb+SI課題管理-NO.4295 劉全航 start
    ,setSearchCondition(state, condition) {
      state.searchCondition = condition;
    }
    //add FutreNetWeb+SI課題管理-NO.4295 劉全航 end
  },
  actions: {
    async setDrugList({ commit }, searchObj) {
      const res = await sendRequestGetDrugs(searchObj.classCd, searchObj.medicineName, searchObj.genericName, searchObj.facilityCd, searchObj.patId);
      commit("setDrugList", res.data);
    },
    // ビューモードを設定する。
    setViewMode({ commit }, value) {
      commit("setViewMode", value);
    },
    // add FNSI5516処方薬剤選択画面の表示が遅い 周 start
    async addDrugListFrom({ commit }, searchObj) {
      const res = await sendRequestGetDrugsByOffsetAndLimit(searchObj.classCd, searchObj.medicineName, searchObj.genericName,
          searchObj.facilityCd, searchObj.patId, searchObj.offset, 100);
      if(undefined !== res.data && null !== res.data && res.data.length > 0) {
        commit("addDrugList", res.data);
      }
    },
    // add FNSI5516処方薬剤選択画面の表示が遅い 周 end
    // 編集モードかどうかチェック
    setIsEdit({ commit }, value) {
      commit("setIsEdit", value);
    },
    // 処方箋詳細を格納
    setEditRecord({ commit }, value) {
      commit("setEditRecord", value);
    },
    // 初期表示データを比べる
    setOriginalEditRecord({ commit }, value) {
      commit("setOriginalEditRecord", value);
    },
    // 初期表示データと入力モデルを比較
    setIsInputModalChanged({ commit }, value) {
      commit("setIsInputModalChanged", value);
    },
    //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 start
    setIsDoctorChanged({ commit }, value){
      commit("setIsDoctorChanged", value);
    },
    //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 end
    // 入力モデルを設定する
    setInputModal({ commit }, value) {
      commit("setInputModal", value);
    },
    // 現在選択した薬剤行の位置
    setIndexRow({ commit }, value) {
      commit("setIndexRow", value);
    },
    // 薬剤を選択後にデータをセット
    setChildEditRecord({ commit, state }, data) {
      let dataList = state.editRecord;
      // 処方薬剤選択で
      // - 一般名処方で反映→後発不可を強制OFF
      // - 薬剤名で反映→後発不可を強制ON
      // NOTE: [患者希望]は利用者の選択した状態となる（※強制的な変更は行わない）
      dataList[data.index].buttonItems[0].itemValue = (data.type === MEDICINE_TYPE.MEDICINE);

      dataList[data.index].buttonItems[2].itemValueCd = data.cd;
      dataList[data.index].buttonItems[2].itemValue = data.name;
      dataList[data.index].buttonItems[2].itemValueType = data.type;
      dataList[data.index].buttonItems[6].dataList = data.dataList;
      dataList[data.index].buttonItems[6].itemValue = "";
      dataList[data.index].buttonItems[5].unitDecimalPoint = data.unitDecimalPoint;
      if (data.hasOwnProperty("unitDecimalPoint")) {
        let returnVal = 0;
        let decPoint = data.unitDecimalPoint;
        let num = dataList[data.index].buttonItems[5].itemValue;
        let decStep = BigNumber(10).exponentiatedBy(BigNumber(decPoint)).valueOf();
        let setStep = BigNumber(10).exponentiatedBy(BigNumber(decPoint).negated()).valueOf();
        if (decPoint !== null) {
          num = BigNumber(num).multipliedBy(BigNumber(decStep)).valueOf();
          num = num >= 0 ? Math.floor(num) : Math.ceil(num);
          returnVal = BigNumber(num).multipliedBy(BigNumber(setStep)).valueOf();
          dataList[data.index].buttonItems[5].itemValue = BigNumber(returnVal).toFixed(decPoint);
        }
      }
      commit("setEditRecord", dataList);
    },

    // 用法・用語マスタを取得
    async setTakeMedicine({ commit }, facilityCd) {
      commit("setListTakeMedicine", []);
      const response = await sendRequestGetTakeMedicine(facilityCd)
      commit("setListTakeMedicine", response.data);
    },

    // 処方箋を保存
    async sendRequestSavePrescription({ commit }, data) {
      const response = await sendRequestSavePrescription(data.ordPrescription, data.ordPersonalPrescription,data.isRegisterInsurance);
      if (response.status == 200) {
        commit("setViewMode", false);
      }
      return response;
    },

    // 保険一覧を取得
    async sendRequestGetPatInsurance({ commit }, data) {
      this.ordPrescriptionNo = data.ordPrescriptionNo;
      const response = await sendRequestGetPatInsurance(data.patId, data.facilityCd, data.ordPrescriptionNo);
      commit("setListPatInsurance", response);
    },

    /**
     * 処方箋表示順番を取得
     * @param {*} data : 以下全てパラメータを含む
     * @param {*} patID : 患者ID
     * @param {*} facilityCd : 施設CD
     * @param {*} prescriptionType : 処方種別
     * @param {*} issueDateFrom : 交付日開始
     * @param {*} issueDateTo : 交付日終了
     * @param {*} issueState : 交付状況
     */
    async sendRequestGetOrderPrescription({ commit }, data) {
      const response = await sendRequestGetOrderPrescription(data);
      commit("setListOrderPres", response);
    },

    /**
     * 指定された処方箋詳細を取得する。
     * @param {*} ordPrescriptionNo
     */
    async sendRequestGetOrderPrescriptionDetail({ commit }, ordPrescriptionNo) {
      const response = await sendRequestGetOrderPrescriptionDetail(ordPrescriptionNo);
      let data = {
        startDate: response.data.ordPrescription.issueDate,
        endDate: response.data.ordPrescription.expirationDate,
        checkHos: response.data.ordPrescription.prescriptionType,
        issued: response.data.ordPrescription.issueState == "1" ? true : false,
        isChild: response.data.ordPersonalPrescription.isChild == "1" ? true : false,
        isDoubt: response.data.ordPersonalPrescription.isDoubt == "1" ? true : false,
        isInformation: response.data.ordPersonalPrescription.isInformation == "1" ? true : false,
        isElderly: response.data.ordPersonalPrescription.isElderly == "1" ? true : false,
        isElderly7: response.data.ordPersonalPrescription.isElderly7 == "1" ? true : false,
        isAnesthesia: response.data.ordPersonalPrescription.isAnesthesia == "1" ? true : false,
        doctor: response.data.ordPersonalPrescription.insuDrId,
        patInsurance: (response.data.ordPersonalPrescription.insuranceCd ?? "0") + "&" + (response.data.ordPersonalPrescription.insuranceName ?? ""),
        remarksFree: response.data.ordPersonalPrescription.remarksFree,
        isRefill: response.data.ordPersonalPrescription.isRefill == "1" ? true : false,
        refillNum: response.data.ordPersonalPrescription.refillNum,
        // add #12462 患者情報共有 Ji start
        facilityCd: response.data.ordPersonalPrescription.facilityCd,
        // add #12462 患者情報共有 Ji end
      }
      commit("setOrdPrescriptionNo", response.data.ordPrescription.ordPrescriptionNo);
      // add FutreNetWeb+SI課題管理No5520 趙 start
      commit("setStartDate", response.data.ordPrescription.issueDate);
      commit("setEndDate", response.data.ordPrescription.expirationDate);
      // add FutreNetWeb+SI課題管理No5520 趙 end
      commit("setPrescriptionDetail", JSON.parse(response.data.ordPrescription.prescriptionDetail))
      commit("setInputModal", data);
      commit("setIsEdit", true);
    },

    /* add by chamaojia 2022-11-18 [6876] レシピ詳細のリセット方法の追加  --start */
    resetOrderPrescriptionDetail({ commit }) {
      commit("setOrdPrescriptionNo", 0);
      commit("setStartDate", null);
      commit("setEndDate", null);
      commit("setPrescriptionDetail", [])
      commit("setInputModal", {
        startDate: "",
        endDate: "",
        checkHos: "1",
        issued: false,
        isChild: false,
        isDoubt: false,
        isInformation: false,
        isElderly: false,
        isElderly7: false,
        isAnesthesia: false,
        doctor: "",
        patInsurance: "",
        remarksFree: "",
        isRefill: false,
        refillNum: NaN,
      });
      commit("setIsEdit", false);
    },
    /* add by chamaojia 2022-11-18 [6876] レシピ詳細のリセット方法の追加  --end */

    /**
     * 指定された処方オーダー番号に対する処方情報を検索し、stateにセットする
     * @param {*} ordPrescriptionNo
     */
    async findOrderPrescription({ commit }, ordPrescriptionNo) {
      const response = await sendRequestGetOrderPrescriptionDetail(ordPrescriptionNo);
      if (response.data.ordPrescription !== null) {
        commit("setOrdPrescriptionNo", response.data.ordPrescription.ordPrescriptionNo);
        commit("setOrdPrescriptionPatId", response.data.ordPrescription.patId)
      } else {
        commit("setOrdPrescriptionNo", 0);
        commit("setOrdPrescriptionPatId", 0);
      }
    },

    /**
     * 指定された処方を削除する。
     * @param {*} ordPrescriptionNo
     */
    sendRequestDeleteOrderPrescription(context, ordPrescriptionNo) {
      return sendRequestDeleteOrderPrescription(ordPrescriptionNo);
    },

    /**
     * 指定された施設の医師リストを取得する。
     * @param {*} context
     * @param {*} facilityCd
     * @param {*} ordPrescriptionNo
     */
    getDoctorsAtFacility(context, facilityCd, ordPrescriptionNo) {
      return sendRequestGetDoctorsAtFacility(facilityCd, !ordPrescriptionNo ? this.ordPrescriptionNo : ordPrescriptionNo);
    },

    /**
     * 指定された保険コードから保険情報を取得する。
     * @param {*} insuranceCd
     */
    sendRequestGetInsuInfoByCd(context, insuranceCd) {
      let response = sendRequestGetInsuInfoByCd(insuranceCd);
      return response
    },

    // add FNSI-改修内容  イベント一覧の日付直下に、施設名を表示する dou start
    /**
     * 施設名取得
     * @param {*} facilityCd
     */
    sendRequestGetFacilityNameByCd(context, facilityCd) {
      let response = sendRequestGetFacilityNameByCd(facilityCd);
      return response
    },
    // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou end

    /**
     * 処方番号を設定する。
     * @param {*} value
     */
    setOrdPrescriptionNo({ commit }, value) {
      commit("setOrdPrescriptionNo", value);
    },
    // add FutreNetWeb+SI課題管理No5520 趙 start
    setStartDate({ commit }, value) {
      commit("setStartDate", value);
    },
    setEndDate({ commit }, value) {
      commit("setEndDate", value);
    },
    // add FutreNetWeb+SI課題管理No5520 趙 end

    /**
     * ストアをクリア
     * @param {*} value
     */
    clearStateEdit({ commit }) {
      commit("setEditRecord", []);
      commit("setOriginalEditRecord", []);
      commit("setIsInputModalChanged", false);
      //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 start
      commit("setIsDoctorChanged", false);
      //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 end
    },

    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
    setTreatBaseDate({ commit }, treatBaseDate) {
      commit("setTreatBaseDate", treatBaseDate);
    }
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
    ,setInfoFromCalendar({ commit }, infoFromCalendar) {
      commit("setInfoFromCalendar", infoFromCalendar);
    }
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
    //add FutreNetWeb+SI課題管理-NO.4295 劉全航 start
    ,setSearchCondition({commit}, condition) {
      commit("setSearchCondition", condition);
    },
    //add FutreNetWeb+SI課題管理-NO.4295 劉全航 end
    // 処方エリアのデータ設定
    setPrescriptionDetail({ commit }, value) {
      commit("setPrescriptionDetail", value);
    },
  },
  getters: {
    // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou start
    getRouteFlag(state) {
      return state.routeFlag
    },
    getOtherFacilityFlag(state) {
      return state.otherFacilityFlag
    },
    getAppointedDate(state) {
      return state.appointedDate
    },
    getFacilityName(state) {
      return state.facilityName
    },
    // add FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou end
    getIsChanged(state) {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc start
      const newData = JSON.parse(JSON.stringify(state.editRecord));
      //state.editRecord.forEach(element => {
      newData.forEach(element => {
        element.buttonItems.forEach(item => {
          delete item.showSelectFlag
        })
      });
      //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 start
      // return (!isEqual(state.originalEditRecord, state.editRecord)) || state.isInputModalChanged;
      // #6876 患者を切り替えると内容破棄確認モーダルが表示される 訾浩 start
      //if (state.originalEditRecord.length === 0 || state.editRecord.length === 0) {
      if (state.originalEditRecord.length === 0 && newData.length === 0) {
        return state.isInputModalChanged || state.isDoctorChanged;
      } else {
        
        const normalize = list =>
          list?.[0]?.dataButtonNo === 1 ? list.slice(1) : list;
          
        // 編集時、Rp1は固定のため、Rp1の要素を除外して比較
        return (
          !isEqual(
            normalize(state.originalEditRecord),
            normalize(newData)
          ) ||
          state.isInputModalChanged ||
          state.isDoctorChanged
        );
        
      }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc end
      // #6876 患者を切り替えると内容破棄確認モーダルが表示される 訾浩 end
      //FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 end
    },
    // #9924対応時のメモ：
    // 既存の処理は行の追加・移動・種別変更などが考慮されていないため
    // indexとiを使った変更判定で実行時エラーが発生することがある
    // 対応を青田さんに確認したところ
    // 変更表示は他の画面でもいくつか問題が起きているので
    // このチケットでは一旦明細行の既存の変更表示処理を無効化して
    // 実行時エラーを起こさないようにしておくことになった
    // 詳細はチケットの説明欄も参照してください
    // /* #8575 処方の各種入力ボックスが、キーボード入力＋検索つきプルダウンでなくなっている。 訾浩 start */
    // getIschangedFlag(state) {
    //   return isEqual(state.originalEditRecord, state.editRecord);
    // },
    // getoriginalEditRecordselect (state) {
    //   return state.originalEditRecord
    // },
    // /* #8575 処方の各種入力ボックスが、キーボード入力＋検索つきプルダウンでなくなっている。 訾浩 end */

    getDrugList(state) {
      return state.drugList;
    },
    getViewMode(state) {
      return state.viewMode;
    },
    getIsEdit(state) {
      return state.isEdit;
    },
    getEditRecord(state) {
      return state.editRecord;
    },
    getOriginalEditRecord(state) {
      return state.originalEditRecord;
    },
    getIndexRow(state) {
      return state.indexRow;
    },
    getListTakeMedicine(state) {
      return state.listTakeMedicine
    },
    getListPatInsurance(state) {
      return state.listPatInsurance
    },
    getListOrderPres(state) {
      return state.listOrderPres
    },
    getInputModal(state) {
      return state.inputModal
    },
    getOrdPrescriptionNo(state) {
      return state.ordPrescriptionNo
    },
    // add FutreNetWeb+SI課題管理No5520 趙 start
    getStartDate(state) {
      return state.startDate
    },
    getEndDate(state) {
      return state.endDate
    },
    // add FutreNetWeb+SI課題管理No5520 趙 end
    getOrdPrescriptionPatId(state) {
      return state.ordPrescriptionPatId
    },
    getPrescriptionDetail(state) {
      return state.prescriptionDetail
    },
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
    getTreatBaseDate(state) {
      return state.treatBaseDate;
    }
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
    ,getInfoFromCalendar(state) {
      return state.infoFromCalendar;
    }
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
    //add FutreNetWeb+SI課題管理-NO.4295 劉全航 start
    ,getSearchCondition(state) {
      return state.searchCondition;
    },
    //add FutreNetWeb+SI課題管理-NO.4295 劉全航 end
    isInitialSearchCondition(state) {
      return isEqual(state.searchCondition, initialSearchCondition);
    },
  }
};
