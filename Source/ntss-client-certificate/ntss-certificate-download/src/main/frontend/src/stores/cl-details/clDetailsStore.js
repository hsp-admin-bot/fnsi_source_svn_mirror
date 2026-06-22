import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  namespaced: true,
  strict: process.env.NODE_ENV !== "production",
  state: {
    facilityName: "",

    facility: {

      passwordCl: "",
      maxDownload: "",
      curDownload: "",
      facilityCd: "",
      expiredDate: "",
      time: "",
      facilityName: "",
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      clCertificateId: ""
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end

    },

    certificates: [],

  },
  getters: {
    getFacility({ facility }) {
      return facility;
    },

    getCertificates(state) {
      return state.certificates;
    },

    getFacilityName(state) {
      return state.facilityName
    }
  },
  actions: {
    // ダウンロードページでダウンロードボタンをクリックすると、現在のダウンロード番号に+1が付けられます
    updateCurDownload({ state, dispatch }, facility) {
      return ApiHelper.post("/cl-details/updateCurDownload", facility)
        .then(() => {
          dispatch("selectByFacilityCdWithName", state.facility.facilityCd);
        });
    },

    //証明書と施設名を選択
    async selectByFacilityCdWithName({ commit }, facilityCd) {
      let obj = {
        facilityCd: facilityCd
      };
      ApiHelper.get("/cl-details/selectByFacilityCdWithNameOnly", obj)
        .then(res => {
          commit("setFacility", res.data);
        });
    },

    async selectCertificateByFacilityCd({ commit }, facilityCd) {
      let obj = {
        facilityCd: facilityCd
      };
      ApiHelper.get("/cl-details/selectByFacilityCdWithNameMany", obj)
        .then(res => {
          commit("setCertificates", res.data);
        });
    },
    async selectFacilityName({ commit }, facilityCd) {
      let obj = {
        facilityCd: facilityCd
      };
      ApiHelper.get("/cl-details/getFacilityName", obj)
        .then(res2 => {
          commit("setFacilityName", res2.data);
        });
    }
  },

  mutations: {
    setFacility(state, facility) {
      state.facility = {
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      clCertificateId: facility.clCertificateId,
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      passwordCl: facility.passwordCl,
      maxDownload: facility.maxDownload,
      curDownload: facility.curDownload,
      facilityCd: facility.facilityCd,
      expiredDate: facility.expiredDate,
      facilityName: facility.facilityName
      };
    },

    setCertificates(state, certificate) {
      state.certificates = certificate;
    },

    setFacilityName(state, facilityName) {
      state.facilityName = facilityName;
    }

  }
};
