//del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
//import moment from "moment";
//del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  namespaced: true,
  strict: process.env.NODE_ENV !== "production",
  state: {
    downloadServerPath: "",
    isUpdate: false,
    previousMaxDownload: 0,
    previousPassword: "",
    facilityName: "",
    selectedIndex: 0,
    certificate: {
      passwordCl: "",
      //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      // expiredDate: moment(Date.now).format("YYYY-MM-DD"),
      // hour: moment(new Date(2020, 2, 2, 23, 59)).format("HH:mm"),
      // maxDownload: 0,
      // curDownload: 0,
      //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      facilityName: "",
      facilityCd: "",
      latestIssuedUser: "",
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      facilityPassword: ""
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    },
    // モーダルに関する証明書情報
    modalDetailsCondition: {
      isShow: false,
      passwordCl: "",
      //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      // expiredDate: moment(new Date()).format("YYYY-MM-DD"),
      // hour: moment(new Date(2020, 2, 2, 23, 59)).format("HH:mm"),
      // maxDownload: 0,
      //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      curDownload: 0,
      facilityName: "",
      facilityCd: "",
      latestIssuedUser: "",
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      facilityPassword: "",
      isCertificateShow: false,
      latestDownloadTime: "",
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      displayFacilityCd: "",
      displayFacilityName: ""
    },

    facility: {
      passwordCl: "",
      //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      // maxDownload: "",
      // curDownload: "",
      //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      facilityCd: "",
      //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      // expiredDate: "",
      // time: "",
      //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      facilityName: ""
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    Clfacility: {
      facilityName: "",
      facilityCd: "",
      facilityPassword: "",
      passwordCl: "",
      issueDate: ""
     },
    clDownloadList: [],
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    confirmPassword: "",
  },
  getters: {
    getSelectedIndex({ selectedIndex }) {
      return selectedIndex;
    },
    getModalDetailsCondition({ modalDetailsCondition }) {
      return modalDetailsCondition;
    },

    // add 4448修正 解 start
    getDownloadServerPath({ downloadServerPath }) {
      return downloadServerPath;
    },
    // add 4448修正 解 end

    getCertificate({ certificate }) {
      if (certificate.facilityCd != undefined) {
        return {
          passwordCl: certificate.passwordCl,
          //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
          // expiredDate: moment(new Date(certificate.expiredDate)).format(
          //   "YYYY-MM-DD"
          // ),
          // hour: "",
          // maxDownload: certificate.maxDownload,
          // curDownload: certificate.curDownload,
          //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
          isDelete: certificate.isDelete,
          facilityCd: certificate.facilityCd
        };
      } else {
        return {
          passwordCl: "",
          //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
          // expiredDate: moment(new Date()).format("YYYY-MM-DD"),
          // maxDownload: 0,
          // curDownload: 0,
          //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
          isDelete: false,
          facilityCd: undefined
        };
      }
    },
    getIsUpdate({ isUpdate }) {
      return isUpdate;
    },

    getPreviousMaxDownload({ previousMaxDownload }) {
      return previousMaxDownload;
    },

    getPreviousPassword({ previousPassword }) {
      return previousPassword;
    },

    getFacility({ facility }) {
      return facility;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    getClfalicitylist(state) {
      return state.Clfacility;
    },
    getclDownloadList(state) {
      return state.clDownloadList;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    getConfirmPassword({ confirmPassword }) {
      return confirmPassword;
    }
  },
  actions: {
    setModalDetailsVisible({ commit }, isShow) {
      commit("setModalDetailsVisible", isShow)
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    setModalCertificatesVisible({ commit }, isCertificateShow) {
      commit("setModalCertificatesVisible", isCertificateShow);
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    clearModalDetailsVisible({ commit }) {
      commit("clearModalDetailsVisible");
    },
    //mod 6363の対応 xiebzh start
    async setIsUpdateStateFalse({ commit }) {
      await commit("setIsUpdateState", false);
    },
    //mod 6363の対応 xiebzh end

    //新しい証明書を追加する
    //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    async addNewCertificate({ state, dispatch }) {
    //async addNewCertificate({ state, dispatch, commit }) {
    //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      let certificate = {
        passwordCl: state.modalDetailsCondition.passwordCl,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        // maxDownload: state.modalDetailsCondition.maxDownload,
        // curDownload: 0,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
        facilityCd: state.modalDetailsCondition.facilityCd,
        manyFacilityCd: state.modalDetailsCondition.displayFacilityCd,
        manyFacilityName: state.modalDetailsCondition.displayFacilityName,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        // expiredDate: new Date(
        //   state.modalDetailsCondition.expiredDate +
        //     " " +
        //     state.modalDetailsCondition.hour
        // ),
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
        latestIssuedUser: state.modalDetailsCondition.latestIssuedUser
      };
      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
      // return ApiHelper.post("/cl-details/insertCl", certificate).then(() => {
      //   dispatch("clearModalDetailsVisible");
      //   commit("clearModalDetail");
      //   dispatch("cl-facility/getFacilities", null, { root: true });
      // });
      await ApiHelper.post("/cl-details/insertCl", certificate)

      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
      //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start

      let facility = {
        facilityCd: state.modalDetailsCondition.facilityCd,
        facilityName: state.modalDetailsCondition.facilityName,
        facilityPassword: state.modalDetailsCondition.facilityPassword
      };

      await  ApiHelper.post("/cl-facility/insertFacility", facility)
      dispatch("getIssueDate");
      // commit("setClFacility",{certificate, facility});
      //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
    },
    async getIssueDate ({ commit, state}) {
      const obj = {
        facilityCd: state.modalDetailsCondition.facilityCd
      };
      await ApiHelper.get("/cl-details/selectByFacilityCd", obj)
      .then(res => {
        commit('setClFacility', {
          passwordCl: state.modalDetailsCondition.passwordCl,
          facilityCd: state.modalDetailsCondition.facilityCd,
          facilityPassword: state.modalDetailsCondition.facilityPassword,
          facilityName: state.modalDetailsCondition.facilityName,
          issueDate: res.data.issueDate
        });
      });
    },
     //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    //新しい証明書を追加する
    async refeshCertificate({ commit ,dispatch }) {

      dispatch("clearModalDetailsVisible");
      commit("clearModalDetail");
      dispatch("cl-facility/getFacilities", null, { root: true });

    },
     //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
    setModalDetailsCondition({ commit }, modalDetailsCondition) {
      commit("setModalDetailsCondition", modalDetailsCondition);
    },

    setCertificate({ commit }, certificate) {
      commit("setCertificate", certificate);
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    setClfacility({ commit }, Clfacility) {
      commit("setClfacility", Clfacility);
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
    setModalDetailVisible({ commit }, isShow) {
      commit("setModalDetailsVisible", isShow);
    },

    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    setModalCertificateVisible({ commit }, isCertificateShow) {
      commit("setModalCertificatesVisible", isCertificateShow);
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
    // mod CLCertificateAddモーダル表示混乱の修正 start
    // 施設PW変更/アカウント発行のモード判定をAPI応答だけに依存せず、
    // 呼び出し元から渡されたisUpdateを優先する（awaitでAPI完了後に状態を確定）
    async selectCertificateByFacilityCd({ commit, state }, payload) {
      const facilityCd =
        typeof payload === "string" ? payload : payload.facilityCd;
      // ドロップダウン操作から明示的に渡された更新モード（未指定時はAPI結果で判定）
      const explicitIsUpdate =
        typeof payload === "object" ? payload.isUpdate : undefined;

      const res = await ApiHelper.get("/cl-details/selectByFacilityCd", {
        facilityCd: facilityCd
      });

      const isUpdate =
        explicitIsUpdate !== undefined
          ? explicitIsUpdate
          : res.data.passwordCl !== undefined;

      if (isUpdate) {
        let data = {
          isShow: false,
          passwordCl: res.data.passwordCl,
          facilityName: res.data.facilityName,
          facilityCd: res.data.facilityCd,
          isCertificateShow: false
        };
        commit("setCertificate", data);
      } else {
        // アカウント発行時は既存証明書データを使わず新規発行用の状態を設定
        let data = {
          isShow: false,
          passwordCl: "",
          facilityName: state.modalDetailsCondition.facilityName,
          facilityCd: state.modalDetailsCondition.facilityCd,
          isCertificateShow: false
        };
        commit("setCertificate", data);
      }
      commit("setIsUpdateState", isUpdate);
    },
    // mod CLCertificateAddモーダル表示混乱の修正 end
    //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    async updateCertificate({ state, dispatch}) {
    //async updateCertificate({ state, dispatch, commit }) {
    //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      //let certificate = {
        //passwordCl: state.modalDetailsCondition.passwordCl,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        // maxDownload: state.modalDetailsCondition.maxDownload,
        // curDownload: 0,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
        //isDelete: false,
        //facilityCd: state.modalDetailsCondition.facilityCd,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        // expiredDate: new Date(
        //   state.modalDetailsCondition.expiredDate +
        //     " " +
        //     state.modalDetailsCondition.hour
        // ),
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
        //latestIssuedUser: state.modalDetailsCondition.latestIssuedUser
      //};
      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
      //  ApiHelper.post("/cl-details/updateCl", certificate).then(() => {
      //   dispatch("clearModalDetailsVisible");
      //   dispatch("cl-facility/getFacilities", null, { root: true });
      //   commit("clearModalDetail");
      // });
      //await ApiHelper.post("/cl-details/updateCl", certificate)

      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
      //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
      let facility = {
        facilityCd: state.modalDetailsCondition.facilityCd,
        facilityName: state.modalDetailsCondition.facilityName,
        facilityPassword: state.modalDetailsCondition.facilityPassword,
        facilityTimeCreated: new Date(),
        facilityIsDelete: false
      };
      await ApiHelper.post("/cl-facility/updateFacility", facility)

      // commit("setClFacility",state);
      dispatch("getIssueDate");
     //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
    },
    //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    // ダウンロード数のみ更新
    // async updateClNoPassword({ state, dispatch, commit }) {
    //   let obj = {
    //     expiredDate: new Date(
    //       state.modalDetailsCondition.expiredDate +
    //         " " +
    //         state.modalDetailsCondition.hour
    //     ),
    //     maxDownload: state.modalDetailsCondition.maxDownload,
    //     facilityCd: state.modalDetailsCondition.facilityCd,
    //     latestIssuedUser: state.modalDetailsCondition.latestIssuedUser
    //   };
    //   return ApiHelper.post("/cl-details/updateClNoPassword", obj)
    //     .then(() => {
    //       dispatch("clearModalDetailsVisible");
    //       dispatch("cl-facility/getFacilities", null, { root: true });
    //       commit("clearModalDetail");
    //     });
    // },
    //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    async clearModalDetail({ commit }) {
      commit("clearModalDetail");
    },

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
      ApiHelper.get("/cl-details/selectByFacilityCdWithName", obj)
        .then(res => {
          commit("setFacility", res.data);
        });
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    async selectAllCertificatesByFacilityCd({ commit }, facilityCd) {
      let obj = {
        facilityCd: facilityCd
      };
     const response = await ApiHelper.get("/cl-details/selectAllCertificatesByFacilityCd", obj);
      commit("setClDownloadList", response.data);

    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end

    // add 4448修正 解 start
    async selectDownloadServer({ commit }) {
      await ApiHelper.get("/cl-details/getDownloadServer")
        .then((res) => {
          commit("setDownloadServerPath", res.data);
        });
    }
    // add 4448修正 解 end
  },

  mutations: {
    setSelectedIndIndex(state, selectedIndex) {
      state.selectedIndex = selectedIndex;
    },

    setModalDetailsVisible(state, isShow) {
      state.modalDetailsCondition.isShow = isShow;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    setModalCertificatesVisible(state, isCertificateShow) {
      state.modalDetailsCondition.isCertificateShow = isCertificateShow;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    setModalDetailsCondition(state, modalDetailsCondition) {
       state.modalDetailsCondition.facilityCd = modalDetailsCondition.facilityCd;
       state.modalDetailsCondition.facilityName = modalDetailsCondition.facilityName;
       state.modalDetailsCondition.latestIssuedUser = modalDetailsCondition.latestIssuedUser;
       state.modalDetailsCondition.displayFacilityCd = modalDetailsCondition.displayFacilityCd;
       state.modalDetailsCondition.displayFacilityName = modalDetailsCondition.displayFacilityName;
    },

    clearModalDetailsVisible(state) {
      state.modalDetailsCondition = {
        isShow: false,
        //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
        isCertificateShow: false
        //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
      };
    },
    //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    setCertificate(state, data) {
    //setCertificate(state, certificate) {
    //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      let passwordCl = '';
      let facilityPassword = '';
      let codeLength = 10;
      let random = new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
      for (let i = 0; i < codeLength; i++) {
        if (data.passwordCl ===""){
          let indexPW = Math.floor(Math.random() * 9);
          passwordCl += random[indexPW];
        } else {
          passwordCl = data.passwordCl;
        }
        let indexfacilityPW = Math.floor(Math.random() * 9);
        facilityPassword += random[indexfacilityPW];
      }
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      state.modalDetailsCondition.passwordCl = passwordCl;
      state.modalDetailsCondition.facilityPassword = facilityPassword;
      //state.previousPassword = passwordCl;
      //state.modalDetailsCondition.passwordCl = certificate.passwordCl;
      //state.previousPassword = certificate.passwordCl;
      //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      // state.modalDetailsCondition.maxDownload = certificate.maxDownload;
      // state.modalDetailsCondition.curDownload = certificate.curDownload;
      // state.modalDetailsCondition.expiredDate = certificate.expiredDate;
      // state.modalDetailsCondition.hour = certificate.hour;
      // certificate.maxDownload === 0
      //   ? (state.previousMaxDownload = 0)
      //   : (state.previousMaxDownload = certificate.maxDownload);
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    },

    selectCertificateByFacilityCd(state, certificate) {
      state.certificate = {
        passwordCl: certificate.passwordCl,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        // expiredDate: new Date(certificate.expiredDate),
        // maxDownload: certificate.maxDownload,
        // curDownload: certificate.curDownload,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
        facilityName: certificate.facilityName,
        facilityCd: certificate.facilityCd
      };
    },

    clearModalDetail(state) {
      // mod CLCertificateAddモーダル表示混乱の修正 start
      // モーダル閉鎖時に更新モードをリセットし、次回表示時の状態残留を防止
      state.isUpdate = false;
      // mod CLCertificateAddモーダル表示混乱の修正 end
      state.certificate = {
        passwordCl: "",
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        // expiredDate: moment(new Date()).format("YYYY-MM-DD"),
        // hour: moment(new Date(2019, 2, 2, 23, 59)).format("HH:mm"),
        // maxDownload: 0,
        // curDownload: 0,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
        isDelete: false,
        facilityCd: "",
        facilityPassword:""
      };
      state.modalDetailsCondition = {
        isShow: false,
        passwordCl: "",
        facilityPassword:"",
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        // expiredDate: moment(new Date()).format("YYYY-MM-DD"),
        // hour: moment(new Date(2019, 2, 2, 23, 59)).format("HH:mm"),
        // maxDownload: 0,
        // curDownload: 0,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
        facilityName: "",
        facilityCd: "",
        //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        isCertificateShow: false
        //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      };

      state.confirmPassword = "";
    },

    setIsUpdateState(state, isUpdate) {
      state.isUpdate = isUpdate;
    },

    setMaxDownloadState(state, maxDownload) {
      state.modalDetailsCondition.maxDownload = maxDownload;
    },

    setPasswordState(state, password) {
      state.modalDetailsCondition.passwordCl = password;
    },

    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    setfacilityPasswordState(state, facilityPassword) {
      state.modalDetailsCondition.facilityPassword = facilityPassword;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    // setPublicTimeState(state, expiredDate) {
    //   state.modalDetailsCondition.expiredDate = expiredDate;
    // },

    //setHourState(state, hour) {
    //  state.modalDetailsCondition.hour = hour;
    //},
    //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    setFacility(state, facility) {
      state.facility = {
        passwordCl: facility.passwordCl,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        // maxDownload: facility.maxDownload,
        // curDownload: facility.curDownload,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
        facilityCd: facility.facilityCd,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        //expiredDate: facility.expiredDate,
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
        facilityName: facility.facilityName
      };
    },

    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    setClFacility(state, Clfacility) {
      state.Clfacility = Clfacility
    },

    setClDownloadList(state, clDownloadList) {
      state.clDownloadList = clDownloadList;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end

    // add 4448修正 解 start
    setDownloadServerPath(state, downloadServerPath) {
      state.downloadServerPath = downloadServerPath;
    },
    // add 4448修正 解 end

    setConfirmPassword(state, value) {
      state.confirmPassword = value;
    }
  }
};
