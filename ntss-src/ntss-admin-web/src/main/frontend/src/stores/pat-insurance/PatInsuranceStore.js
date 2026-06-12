import { decodeEditableRecord } from '@/functions/PatInfoFunctions';
import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  namespaced: true,
  strict: !import.meta.env.PROD,

  state: {
    insuranceList: [],
    selectedInsuranceJson: {},
    selectedInsuranceIndex: 0,
    mstInsurance: [],
    popOverInsuranceInfo: [],
    reloadRequired: false,
    isCreate: true
  },

  getters: {
    insuranceList: state => {
      return state.insuranceList;
    },
    selectedInsuranceJson(state) {
      return state.selectedInsuranceJson;
    },
    selectedInsuranceIndex(state) {
      return state.selectedInsuranceIndex;
    },
    mstInsurance(state) {
      return state.mstInsurance;
    },
    popOverInsuranceInfo(state) {
      return state.popOverInsuranceInfo;
    },
    reloadRequired(state) {
      return state.reloadRequired;
    },
    isCreate({isCreate}) {
      return isCreate;
    }

  },
  mutations: {
    setInsuranceList: (state, insuranceList) => {
      state.insuranceList = JSON.parse(JSON.stringify(insuranceList));
    },
    setSelectedInsuranceJson(state, selectedInsuranceJson) {
      state.selectedInsuranceJson = selectedInsuranceJson;
    },
    setSelectedInsuranceIndex(state, selectedInsuranceIndex) {
      state.selectedInsuranceIndex = selectedInsuranceIndex;
    },
    setMstInsurance(state, mstInsurance) {
      state.mstInsurance = mstInsurance;
    },
    setPopOverInsuranceInfo(state, popOverInsuranceInfo) {
      state.popOverInsuranceInfo = popOverInsuranceInfo;
    },
    setReloadRequired(state, reloadRequired) {
      state.reloadRequired = reloadRequired;
    },
    setIsCreate(state, isCreate) {
      state.isCreate = isCreate;
    },
  },
  actions: {
    setInsuranceList({ commit }, insuranceList) {
      commit("setInsuranceList", insuranceList);
    },
    async updatePatInsurance({getters}) {
      const list = getters.insuranceList.map((rec, index) => {
        const decodeRecord = decodeEditableRecord(rec);
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start
        const refinedInsuData = {
          ...decodeRecord,
          insu_name: decodeRecord.insu_name.replace("【削除済み】", "")
        };
        refinedInsuData.ctl_no = index;
        return refinedInsuData;
        // decodeRecord.ctl_no = index;
        // return decodeRecord;
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end
      });
      //  mod 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  start
      // await ApiHelper.put(
      //   `/patInfo/bulkUpdatePatInsu`, list

      // // mod FNSI-排他処理 劉 start
      // //).catch(() => {
      //   //throw new Error("患者保険情報を変更失敗");
      // ).catch(error => {
      //   throw error;
      // // mod FNSI-排他処理 劉 end
      // });
      await ApiHelper.put(
        `/patInfo/allUpdatePatInsu`, list

      // mod FNSI-排他処理 劉 start
      //).catch(() => {
        //throw new Error("患者保険情報を変更失敗");
      ).catch(error => {
        throw error;
      // mod FNSI-排他処理 劉 end
      });
      //  mod 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  end
    },
    setSelectedInsuranceJson({ commit }, selectedInsuranceJson) {
      commit("setSelectedInsuranceJson", selectedInsuranceJson);
    },
    setSelectedInsuranceIndex({ commit }, selectedInsuranceIndex) {
      commit("setSelectedInsuranceIndex", selectedInsuranceIndex);
    },
    setMstInsurance({ commit }, mstInsurance) {
      commit("setMstInsurance", mstInsurance);
    },
    setPopOverInsuranceInfo({ commit }, popOverInsuranceInfo) {
      commit("setPopOverInsuranceInfo", popOverInsuranceInfo);
    },
    setReloadRequired({ commit }, reloadRequired) {
      commit("setReloadRequired", reloadRequired);
    },
    setIsCreate({ commit }, isCreate) {
      commit("setIsCreate", isCreate);
    }
  }
};
