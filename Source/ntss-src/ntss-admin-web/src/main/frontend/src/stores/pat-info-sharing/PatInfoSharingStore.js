/**
 * 患者情報共有ストア
 */
import {
  sendRequestGetShrFacilityList,
  sendRequestGetShrList,
  sendRequestGetShrDetailsList,
  sendRequestGetCorrespondingFacilities,
  sendRequestAddShrPatInfo,
  sendRequestSaveShrPatInfo,
  sendRequestGetOutPatList,
  sendRequestDeleteShrPatInfo
} from "@/apis/pat-info-sharing";

export default {
  strict: true,
  namespaced: true,
  state: {
    shrFacilityList: [],
    allShrFacilityList: [],
    shrInfoList: [],
    shrFromInfoList: [],
    shrToInfoList: [],
    affiliatedfacilities: {},
    ourPatList: [],
    outHospPatId: "",
    selectedPatId: "",
    condition: null,
    selectedShrInfo: {},
    filterSignal: false,
    isSearching: false,
    unfinishedShareFlg: false
  },
  getters: {
    getShrFacilityList(state) {
      return state.shrFacilityList.map(f => ({
        text: f.facilityName,
        value: f.facilityCd
      }))
    },
    getAllShrFacilityList(state) {
      return state.allShrFacilityList.map(f => ({
        text: f.facilityName,
        value: f.facilityCd
      }))
    },
    getCondition: state => {
      return state.condition;
    },
    getSelectedShrInfo: state => {
      return state.selectedShrInfo;
    },
    getFilterSignal: state => {
      return state.filterSignal;
    },
    getIsSearching: state => {
      return state.isSearching;
    },
    getShrInfoList(state) {
      return state.shrInfoList;
    },
    getShrFromInfoList(state) {
      return state.shrFromInfoList;
    },
    getShrToInfoList(state) {
      return state.shrToInfoList;
    },
    getOurPatList(state) {
      return state.ourPatList;
    },
    getOutHospPatId(state) {
      return state.outHospPatId;
    },
    getSelectedPatId(state) {
      return state.selectedPatId;
    },
    getAffiliatedfacilities(state) {
      return state.affiliatedfacilities;
    },
    getUnfinishedShareFlg(state) {
      return state.unfinishedShareFlg;
    },
  },
  actions: {
    async setShrFacilityList({ commit }) {
      const res = await sendRequestGetShrFacilityList();
      commit("setShrFacilityList", res.data.filterFacility);
      commit("setAllShrFacilityList", res.data.facility);
    },
    setCondition({ commit }, condition) {
      commit("setCondition", condition);
    },
    setSelectedShrInfo({ commit }, selectedShrInfo) {
      commit("setSelectedShrInfo", selectedShrInfo);
    },
    setFilterSignal({ commit }, signal) {
      commit("setFilterSignal", signal);
    },
    setIsSearching({ commit }, signal) {
      commit("setIsSearching", signal);
    },
    setUnfinishedShareFlg({ commit }, flg) {
      commit("setUnfinishedShareFlg", flg);
    },
    setOutHospPatId({ commit }, flg) {
      commit("setOutHospPatId", flg);
    },
    setSelectedPatId({ commit }, flg) {
      commit("setSelectedPatId", flg);
    },
    async fetchShrInfoList({ commit }, info) {
      await commit("clearShrInfoList");
      const param = {
        patBloodTypeAbo: info.bloodType,
        gender: info.gender,
        startBirthDate: info.birthdayFrom,
        endBirthDate: info.birthdayTo,
        fromFacilityCd: info.facilityCdFrom,
        toFacilityCd: info.facilityCdTo,
        shareToFlg: info.isShowShareTo,
        shareFromFlg : info.isShowShareFrom,
        prohibitedFlg: info.isShowShareRefuse,
        pendingFlg: info.isShowShare,
        currentSelectedPatId: info.currentSelectedPatId
      }
      const res = await sendRequestGetShrList(param);
      if (res && res.data && res.data.length > 0) {
        commit("setShrInfoList", res.data);
      }
    },
    async fetchShrDetailsInfoList({ commit }, patId) {
      const res = await sendRequestGetShrDetailsList(patId);
      if (res.data) {
        commit("setShrFromInfoList", res.data.facilityFromList);
        commit("setShrToInfoList", res.data.facilityToList);
      }
    },
    async setAffiliatedfacilities({ commit }) {
      const res = await sendRequestGetCorrespondingFacilities();
      if (res.data) {
        commit("setAffiliatedfacilities", res.data);
      }
    },
    async setOurPatList({ commit }) {
      const res = await sendRequestGetOutPatList();
      if (res.data) {
        commit("setOurPatList", res.data);
      }
    },
    async addShrPatInfo({ }, info) {
      await sendRequestAddShrPatInfo(info);
    },
    async updShrPatInfo({ }, info) {
      await sendRequestSaveShrPatInfo(info);
    },
    async delShrPatInfo({ }, patId) {
      await sendRequestDeleteShrPatInfo(patId);
    },
    clearShrInfoList({ commit }) {
      commit("clearShrInfoList");
    },
    clearShrDetailsInfoList({ commit }) {
      commit("clearShrDetailsInfoList");
    },
  },
  mutations: {
    setShrFacilityList(state, shrFacilityList) {
      state.shrFacilityList = shrFacilityList;
    },
    setAllShrFacilityList(state, allShrFacilityList) {
      state.allShrFacilityList = allShrFacilityList;
    },
    setCondition(state, condition) {
      state.condition = condition;
    },
    setSelectedShrInfo(state, selectedShrInfo) {
      state.selectedShrInfo = selectedShrInfo;
    },
    setFilterSignal(state, signal) {
      state.filterSignal = signal;
    },
    setIsSearching(state, signal) {
      state.isSearching = signal;
    },
    setShrInfoList(state, shrInfoList) {
      state.shrInfoList = shrInfoList;
    },
    setShrFromInfoList(state, shrInfoList) {
      state.shrFromInfoList = shrInfoList;
    },
    setShrToInfoList(state, shrInfoList) {
      state.shrToInfoList = shrInfoList;
    },
    setAffiliatedfacilities(state, affiliatedfacilities) {
      state.affiliatedfacilities = affiliatedfacilities;
    },
    setOurPatList(state, ourPatList) {
      state.ourPatList = ourPatList;
    },
    setOutHospPatId(state, outHospPatId) {
      state.outHospPatId = outHospPatId;
    },
    setSelectedPatId(state, selectedPatId) {
      state.selectedPatId = selectedPatId;
    },
    setUnfinishedShareFlg(state, flg) {
      state.unfinishedShareFlg = flg;
    },
    clearShrInfoList(state) {
      state.shrInfoList.splice(0, state.shrInfoList.length);
    },
    clearShrDetailsInfoList(state) {
      state.shrFromInfoList.splice(0, state.shrFromInfoList.length);
      state.shrToInfoList.splice(0, state.shrToInfoList.length);
    },
  }
};
