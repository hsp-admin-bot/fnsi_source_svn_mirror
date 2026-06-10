import {
  requestGetReceivePatient,
  requestGetPublicPatient,
  requestGetDstFacilities,
  updateDstFacilities,
  requestGetSrcFacilities,
  requestGetIsDoctor
} from "@/apis/sharing-patient-information";
import { ApiHelper } from "@/apis/AxiosHelper";
export default {
  namespaced: true,
  strict: true,
  state: {
    isDisclosureTab: true,
    filterBy: null,
    editable: false,
    columns: [],
    publicPatient: [],
    receivePatient: [],
    dstFacilities: [],
    updateDstFacilities: [],
    srcFacilities: [],
    patInfo: null,
    facility: null,
    receivePatientInfos: [],
    newHospPatIdTmp: "",
    newPatNameTmp: "",
    isDoctor: null
  },
  actions: {
    setAcceptanceModal({ commit }, value) {
      commit("setAcceptanceModal", value);
    },
    setIsDisclosureTab({ commit }, isDisclosureTab) {
      commit("setIsDisclosureTab", isDisclosureTab);
    },
    setFilterBy({ commit }, filterBy) {
      commit("setFilterBy", filterBy);
    },
    async setDstFacilities({ commit }, value) {
      try {
        await requestGetDstFacilities(value).then(response => {
          commit("setDstFacilities", response.data);
        });
      } catch (e) {
        throw new Error();
      }
    },
    async updateDstFacilities({ commit }, payload) {
      try {
        const response = await updateDstFacilities(payload).then(response => {
          commit("updateDstFacilities", response.data);
        });
        return response;
      } catch (e) {
        throw new Error();
      }
    },
    setEditable({ commit }, value) {
      commit("setColumns", value.columns);
      commit("setEditable", value);
    },
    setPublicPatient({ commit }, value) {
      return requestGetPublicPatient(value).then(response => {
        commit("setPublicPatient", response.data);
      });
    },
    setReceivePatient({ commit }, value) {
      return requestGetReceivePatient(value).then(response => {
        commit("setReceivePatient", response.data);
      });
    },
    async setSrcFacilities({ commit }, value) {
      await requestGetSrcFacilities(value).then(res => {
        commit("setSrcFacilities", res.data);
      });
    },
    clearSrcFacilities({ commit }) {
      commit("clearSrcFacilities");
    },
    setPatitentInfo({ commit }, value) {
      commit("setPatitentInfo", value);
    },
    setSelectedFacility({ commit }, value) {
      commit("setFacility", value);
    },

    clearDstFacilities({ commit }) {
      commit("setDstFacilities", []);
    },
    async updateReceivePatient({ commit }, param) {
      let response = await ApiHelper.put("/pat_name_identification/sharingPatientInfo/updateSrcFacilities", param)
      commit("setSrcFacilities", response.data)
      commit("clearReceivePatientInfos");
    },

    setReceivePatientInfos({ commit }, value) {
      commit("setReceivePatientInfos", value);
    },

    clearReceivePatientInfos({ commit }) {
      commit("clearReceivePatientInfos");
    },

    setSrcFacilitiesNew({ commit }, value) {
      commit("setSrcFacilitiesNew", value);
    },
    async setGetIsDoctor({ commit }) {
      await requestGetIsDoctor().then(res => {
        commit("setGetIsDoctor", res);
      });
    }
  },
  mutations: {
    setGetIsDoctor(state, doctor) {
      state.isDoctor = doctor;
    },
    setIsDisclosureTab(state, isDisclosureTab) {
      state.isDisclosureTab = isDisclosureTab;
    },
    setFilterBy(state, filterBy) {
      state.filterBy = filterBy;
    },
    setDstFacilities(state, value) {
      state.dstFacilities = value;
    },
    updateDstFacilities(state, value) {
      state.updateDstFacilities = value;
    },
    setPublicPatient(state, patInfo) {
      state.publicPatient = patInfo;
    },
    setReceivePatient(state, patInfo) {
      state.receivePatient = patInfo;
    },
    setEditable(state, value) {
      state.editable = value;
    },
    setColumns(state, columns) {
      state.columns = columns;
    },
    setSrcFacilities(state, srcFacilities) {
      state.srcFacilities = srcFacilities;
    },
    setPatitentInfo(state, value) {
      state.patInfo = value;
    },
    setFacility(state, value) {
      state.facility = value;
      state.newHospPatIdTmp =
        value.new_hosp_pat_id != null ? value.new_hosp_pat_id : "";
      state.newPatNameTmp =
        value.new_pat_name != null ? value.new_pat_name : "";
    },
    setShareInfo(state, value) {
      state.setShareInfo = value;
    },
    setReceivePatientInfos(state, value) {
      let fac = state.srcFacilities.filter(
        facility => facility.facilityCd === value.facilityCd
      )[0];
      if (value.isUpdate && value.receive == "0") {
        fac.receive = "0";
      } else if (value.isUpdate) {
        fac.receive = 9999;
      }
      fac.isOpen = value.isOpen;
      fac.signUp = value.signUp;
      let flag = false;
      for (let i = 0; i < state.receivePatientInfos.length; i++) {
        let facility = state.receivePatientInfos[i];
        if (value.facilityCd === facility.facilityCd) {
          state.receivePatientInfos[i] = value;
          flag = true;
          break;
        }
      }
      if (!flag) {
        state.receivePatientInfos.push(value);
      }
    },
    setSrcFacilitiesNew(state, value) {
      let fac = state.srcFacilities.filter(
        facility => facility.facilityCd === value.facilityCd
      )[0];
      fac.new_hosp_pat_id = value.newHospPatId;
      fac.new_pat_name = value.newName;
    },
    clearReceivePatientInfos(state) {
      state.receivePatientInfos = [];
    },
    setNewPatName(state, value) {
      let fac = state.srcFacilities.filter(
        facility => facility.facilityCd === value.facilityCd
      )[0];
      if (fac) {
        fac.new_pat_name = value.newName;
      }
    },
    setNewHospPatId(state, value) {
      let fac = state.srcFacilities.filter(
        facility => facility.facilityCd === value.facilityCd
      )[0];
      if (fac) {
        fac.new_hosp_pat_id = value.newHospPatId;
      }
    },
    clearSrcFacilities(state) {
      state.srcFacilities = [];
    }
  },
  getters: {
    getIsDoctor(state) {
      return state.isDoctor;
    },
    getPublicPatient(state) {
      return state.publicPatient;
    },
    getReceivePatient(state) {
      return state.receivePatient;
    },
    getIsDisclosureTab: state => {
      return state.isDisclosureTab;
    },
    getFilterBy: state => {
      return state.filterBy;
    },
    getDstFacilities: state => {
      return state.dstFacilities;
    },
    getUpdateDstFacilities: state => {
      return state.updateDstFacilities;
    },
    getEditable: state => {
      return state.editable;
    },
    getColumns(state) {
      return state.columns;
    },
    getSrcFacilities(state) {
      return state.srcFacilities;
    },
    getPatientInfo(state) {
      return state.patInfo;
    },
    getFacility(state) {
      return state.facility;
    },
    getReceivePatientInfos(state) {
      return state.receivePatientInfos;
    },
    getNewHospPatIdTmp(state) {
      return state.newHospPatIdTmp;
    },
    getNewPatNameTmp(state) {
      return state.newPatNameTmp;
    }
  }
};
