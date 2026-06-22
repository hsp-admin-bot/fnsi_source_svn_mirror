import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  namespaced: true,
  strict: process.env.NODE_ENV !== "production",
  state: {
    isUpdate: false,
    facilities: [],
    selectedIndex: {
      facilityName: "",
      facilityPwd: "",
      facilityCd: ""
    },
    modalFacilityCondition: {
      isUpdtFunction: false,
      isShow: false,
      facilityCd: "",
      facilityName: "",
      facilityPwd: null
    },
    facilitySetting: {
      passwordMin: null,
      lockCount: null
    },

    confirmPassword: "",
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    orderKey: ""
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
  },
  getters: {
    getFacilities({ facilities }) {
      return facilities.map(facility => ({
        facilityCd: facility.facilityCd,
        facilityName: facility.facilityName,
        issuedNumber:
          facility.maxDownload === 0
            ? ""
            : (facility.curDownload === null ? 0 : facility.curDownload) +
              " / " +
              facility.maxDownload,
        prefecturesCd: facility.prefecturesCd,
        expiredDate:
          facility.expiredDate !== null ? new Date(facility.expiredDate) : "",
        attemptFail: facility.attemptFail,
        isLocked: facility.attemptFail === 5 ? true : false,
        latestIssuedUser: facility.latestIssuedUser,
        facilityCount: facility.facilityCount
      }));
    },

    getSelectedIndex({ selectedIndex }) {
      return selectedIndex;
    },

    getModalFacilityCondition(state) {
      return state.modalFacilityCondition;
    },

    getIsUpdate(state) {
      return state.isUpdate;
    },

    getFacilitySetting(state) {
      return state.facilitySetting;
    },

    getConfirmPassword(state) {
      return state.confirmPassword;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    getOrderKey(state) {
      return state.orderKey;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
  },
  actions: {
    async getFacilityByCd({ state, dispatch, commit }) {
      let obj = {
        facilityCd: state.selectedIndex.facilityCd
      };
      await ApiHelper.get("/cl-facility/getFacilitiesByCd", obj).then(res => {
        if (res.data !== "") {
          commit("setIsUpdateState", true);
        } else {
          commit("setIsUpdateState", false);
        }
        dispatch("setSelectedIndex", res.data);
      });
    },

    async setIsUpdateStateFalse({ commit }) {
      await commit("setIsUpdateState", false);
    },

    async updateFacility({ state, commit }) {
      let obj = {
        facilityCd: state.modalFacilityCondition.facilityCd,
        facilityName: state.modalFacilityCondition.facilityName,
        facilityPassword: state.modalFacilityCondition.facilityPwd,
        facilityAddress: state.modalFacilityCondition.facilityAddress,
        facilityTimeCreated: new Date(),
        facilityIsDelete: false
      };
      return ApiHelper.post("/cl-facility/updateFacility", obj).then(() => {
        commit("clearModalFacilityState");
      });
    },

    async insertFacility({ state, commit }) {
      let facility = {
        facilityCd: state.modalFacilityCondition.facilityCd,
        facilityName: state.modalFacilityCondition.facilityName,
        facilityPassword: state.modalFacilityCondition.facilityPwd
      };

      return ApiHelper.post("/cl-facility/insertFacility", facility)
        .then(() => {
          commit("clearModalFacilityState");
        });
    },

    async updateFacilityAttemptFail({ dispatch }, obj) {
      return ApiHelper.post("cl-facility/updateAttempFail", obj).then(() => {
        dispatch("getFacilities");
      });
    },

    async getFacilities({ state, commit }) {
      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
      //const res = await ApiHelper.get("/cl-facility/getAllFacilities");
      let obj = {
        OrderKey: state.orderKey
      };
      const res = await ApiHelper.get("/cl-facility/getAllFacilities", obj);

      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
      commit("setFacilities", res.data);
    },
    setFacilitySetting({ commit }) {
      ApiHelper.get("/cl-facility/getFacilitySetting")
        .then(res => {
          commit("setFacilitySetting", res.data);
        });
    },

    setModalFacilityVisible({ commit }, isShow) {
      commit("setModalFacilityVisible", isShow);
    },

    setModalFacilityFunction({ commit }, isUpdtFunction) {
      commit("setModalFacilityFunction", isUpdtFunction);
    },

    clearModalFacilityState({ commit }) {
      commit("clearModalFacilityState");
    },

    setModalFacilityState({ commit }) {
      commit("setModalFacilityState");
    },

    setSelectedIndex({ commit }, selectedIndex) {
      commit("setSelectedIndex", selectedIndex);
    },

    setModalConditionPassword({ commit }, password) {
      commit("setModalConditionPassword", password);
    },

    clearModalState({ commit }) {
      commit("clearModalState");
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    setOrderKey({ commit }, orderKey) {
      commit("setOrderKey", orderKey);
    }
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
  },
  mutations: {
    setFacilities(state, facilities) {
      state.facilities = facilities;
    },
    setSelectedIndex(state, selectedIndex) {
      state.selectedIndex = selectedIndex;
    },

    setModalFacilityVisible(state, isShow) {
      state.modalFacilityCondition.isShow = isShow;
    },

    setModalFacilityFunction(state, isUpdtFunction) {
      state.modalFacilityCondition.isUpdtFunction = isUpdtFunction;
    },

    clearModalFacilityState(state) {
      state.modalFacilityCondition = {
        isShow: false,
        facilityId: "",
        facilityName: "",
        facilityPwd: "",
        facilityAddress: ""
      };
    },

    setModalFacilityState(state) {
      state.modalFacilityCondition = {
        isShow: false,
        facilityCd: state.selectedIndex.facilityCd,
        facilityName: state.selectedIndex.facilityName,
        facilityPwd: ""
      };
    },

    setModalConditionPassword(state, password) {
      state.modalFacilityCondition.facilityPwd = password;
    },

    clearModalState(state) {
      state.selectedIndex = {
        facilityName: "",
        facilityPwd: "",
        facilityCd: ""
      };
      state.modalFacilityCondition = {
        isUpdtFunction: false,
        isShow: false,
        facilityCd: "",
        facilityName: "",
        facilityPwd: ""
      };
      state.confirmPassword = "";
    },

    setIsUpdateState(state, isUpdate) {
      state.isUpdate = isUpdate;
    },

    setFacilitySetting(state, value) {
      state.facilitySetting = value;
    },

    setConfirmPassword(state, value) {
      state.confirmPassword = value;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    setOrderKey(state, value) {
      state.orderKey = value;
    }
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
  }
};
