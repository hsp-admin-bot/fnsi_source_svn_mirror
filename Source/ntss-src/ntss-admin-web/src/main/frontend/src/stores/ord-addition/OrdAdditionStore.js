/**
 * 加算Store.
 */
import {
  sendRequestGetByTreatInfo,
  sendRequestPutOrdAdditionList,
  sendRequestGetMstAddition,
  sendRequestGetAdditionDateList,
  sendRequestGetShortNameList,
  sendRequestGetPatAddInfo
} from "@/apis/ord-addition";
import dayjs from "@/compat/date/dayjs";

export default {
  strict: true,
  namespaced: true,
  state: {
    ordAdditionList: [],
    mstAdditionList: [],
    mode: "",
    shortNameList: [],
    patAdditionList: []
  },
  mutations: {
    setOrdAdditionList(state, payload) {
      state.ordAdditionList = payload;
    },
    setMstAdditionList(state, payload) {
      state.mstAdditionList = payload;
    },
    setMode(state, payload) {
      state.mode = payload;
    },
    setShortNameList(state, payload) {
      state.shortNameList = payload;
    },
    setPatAdditionList(state, payload) {
      state.patAdditionList = payload;
    }
  },
  getters: {
    getOrdAdditionList(state) {
      return state.ordAdditionList;
    },
    mstAdditionList(state) {
      return state.mstAdditionList;
    },
    selectedMstAdditionList({ mstAdditionList }) {
      return mstAdditionList.filter(addition => addition.is_enable);
    },
    unselectedMstAdditionList({ mstAdditionList }) {
      return mstAdditionList.filter(addition => !addition.is_enable);
    },
    getShortNameList(state) {
      return state.shortNameList;
    },
    getPatAdditionList(state) {
      return state.patAdditionList;
    }
  },
  actions: {
    async sendRequestGetByPatInfo({ commit }, payload){
      const response = await sendRequestGetPatAddInfo({
        facilityCd: payload.facilityCd,
        patId: payload.patId
      });
      commit("setPatAdditionList", response.data);
    },

    // オーダーの加算リスト取得
    sendRequestGetOrdAdditionList({ state, commit }, payload) {
      commit("setOrdAdditionList", []);

      let params = {
        facilityCd: payload.facilityCd,
        patId: payload.patId,
        ordNo: payload.ordNo,
        ownFacility: payload.ownFacility
      };
      let response = null;
      switch (state.mode) {
        case "TREATMENT-RECORD":
          response = sendRequestGetByTreatInfo(params);
          break;
        case "PATIENT-INFO":
          response = sendRequestGetPatAddInfo(params);
          break;

        default:
          break;
      }

      commit("setOrdAdditionList", response.data);
      return response.data;
    },

    // 保存
    async updateRecordList({ commit }, payload) {
      let list = [];
      if (payload.updateList.length > 0) {
        payload.updateList.forEach(item => {
          let temp = {
            cd: item.additionCd, // 加算コード
            name: item.orditem_name ? item.orditem_name : item.additionName,
            is_enable: "1",
            start_date: item.start_date ? dayjs(item.start_date).format("YYYYMMDD") : ""
          };
          list.push(temp);
        });
      }
      const response = await sendRequestPutOrdAdditionList({
        facilityCd: payload.facilityCd,
        patId: payload.patId,
        ordNo: payload.ordNo,
        additionInfo: list
      });

      const patAddList = await sendRequestGetPatAddInfo({
        facilityCd: payload.facilityCd,
        patId: payload.patId
      });
      commit("setPatAdditionList", patAddList.data);

      return response;
    },

    // 略称リスト取得
    async sendRequestGetShortNameList({ commit }, payload) {
      commit("setShortNameList", []);

      let params = {
        facilityCd: payload.facilityCd,
        patId: payload.patId,
        ordNo: payload.ordNo
      };

      const response = await sendRequestGetShortNameList(params);
      commit("setShortNameList", response.data);
      return response.data;
    },

    // 加算マスター取得
    async sendRequestGetMstAddition({ state, commit }, payload) {
      commit("setOrdAdditionList", []);
      commit("setMstAdditionList", []);

      let params = {
        facilityCd: payload.facilityCd,
        patId: payload.patId,
        ordNo: payload.ordNo,
        ownFacility: payload.ownFacility
      };

      let ordAdditionList = [];
      switch (state.mode) {
        case "TREATMENT-RECORD":
          // 指定患者・指定オーダー番号の加算情報をとる
          await sendRequestGetByTreatInfo(params).then(response => {
            ordAdditionList = response.data;
          });
          break;
        case "PATIENT-INFO":
          // 指定患者の加算情報を全てとる
          await sendRequestGetPatAddInfo(params).then(response => {
            ordAdditionList = response.data;
          });
          break;
        default:
          break;
      }

      let mstAdditionList = [];
      const facilityCd = payload.facilityCd;
      await sendRequestGetMstAddition(facilityCd).then(response => {
        mstAdditionList = response.data;
      });

      // 前回加算日の取得処理
      let calculationDateList = null;
      if(state.mode === "TREATMENT-RECORD") {
        const params = {
          "ordNo": payload.ordNo,
          "patId": payload.patId,
          "treatDate": payload.treatDate,
          "facilityCd": payload.facilityCd,
          "ownFacility": payload.ownFacility
        };
        calculationDateList = await sendRequestGetAdditionDateList(params)
          .catch(error => {
            throw error;
          });
        calculationDateList = calculationDateList.data ? calculationDateList.data : null;
      }

      // 加算マスタの内容にJSONの内容を追加する
      let pushedOrdAdditionList = [];
      if (mstAdditionList.length > 0) {
        for (let i = 0; i < mstAdditionList.length; i++) {
          let mstItem = mstAdditionList[i];
          mstItem.sort_order_mst = i;
          mstItem.is_enable = false;
          // 治療チェック
          for (let j = 0; j < ordAdditionList.length; j++) {
            let ordItem = ordAdditionList[j];
            if (ordItem.cd == mstItem.additionCd) {
              mstItem.sort_order_ord = j;
              mstItem.orditem_name = ordItem.name;
              mstItem.is_enable = true;
              mstItem.start_date = ordItem.start_date ? dayjs(ordItem.start_date).format("YYYY-MM-DD") : "";
              pushedOrdAdditionList.push(ordItem.cd);
            }
          }
        }
      }
      // 先ほどのループで追加していないJSONの内容をmstAdditionListに入れる
      for (let i = 0; i < ordAdditionList.length; i++) {
        let ordItem = ordAdditionList[i];
        if (pushedOrdAdditionList.indexOf(ordItem.cd) === -1) {
          let mstItem = {};
          mstItem.additionCd = ordItem.cd;
          mstItem.sort_order_mst = 99999;
          mstItem.sort_order_ord = i;
          mstItem.orditem_name = ordItem.name;
          mstItem.is_enable = true;
          mstItem.start_date = "";
          mstAdditionList.push(mstItem);
        }
      }
      
      // 前回加算日データを mstAdditionList に追加する
      if (calculationDateList !== null && calculationDateList.length > 0) {
        calculationDateList.forEach(day => {
          const addition = mstAdditionList.find(add => {
            return add.additionCd == day.cd;
          });
          if (typeof addition === "object") {
            addition.last_date = day.last_date;
          }
        });
      }

      commit("setOrdAdditionList", ordAdditionList);
      commit("setMstAdditionList", mstAdditionList);
    }
  }
};
