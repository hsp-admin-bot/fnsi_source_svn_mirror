/**
 * 利用者マスタメンテナンスStore.
 */
import {
  sendRequestGetMstUserData,
  sendRequestGetMstUserDataSort,
  sendRequestAddNewUser,
  sendRequestUpdateAdministratorFlg,
  sendRequestUpdatePassword,
  sendRequestUpdatePatientSharedFlg,
  // add FNSI-メニューに共有ON／共有OFFを追加する。 江 start
  sendRequestGetPatientSharedFlg,
  // add FNSI-メニューに共有ON／共有OFFを追加する。 江 end
  sendRequestUpdateFailureCnt,
  sendRequestDeleteUser,
  sendRequestGetMstFacility,
  sendRequestGetDeleteTargetEmailAddress,
  sendRequestDeleteEmailAddress,
  sendRequestGetMstJob,
  sendRequestUpdateJobCd,
  sendRequestAddNewPatUser,
  sendRequestUpdateUserPersonalInfo,
  sendRequestUpdateMstSelecterByFacilityCd,
  sendRequestDeleteSecretKey,
  sendRequestCreateMstUserOTP,
  sendRequestUpdateSecretKey,
  sendRequestUpdateIsSetQrCode,
  sendRequestDisableAccessCard,
  sendRequestCheckOtp,
  sendRequestUpdateSigninDate
} from "@/apis/mst-user-maintenance";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import { DISP_CREATE_CARD } from "@/constants/facilitySetting";
import Vue from "vue";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 選択されたマスタ
    selectedMasterName: "",
    // 選択されたマスタ名
    selectedLogicalMasterName: "",
    // マスタレコード
    masterRecordList: [],
    // ヘッダ検索条件
    condition: {
      recordName: ""
    },
    // スキーマ情報
    schema: {},
    // カラム情報
    columns: [],
    // モーダル画面に表示する情報
    userInfoModal: null,
    // 施設リスト
    facilityList: [],
    // 削除対象メールリスト
    deleteTargetEmailAddress: [],
    // 職種一覧
    mstJobList: [],
    // カード作成表示フラグ
    isDispCreateCard: true,
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 start
    // 共有の登録状況
    isRegisteredShared: false,
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 end
    //OTPオブジェクト
    userOTP: {
      secretKey : "",
      Qrcode : ""
    }
  },
  mutations: {
    setMasterName(state, selectedMasterName) {
      state.selectedMasterName = selectedMasterName;
    },
    setLogicalMasterName(state, selectedLogicalMasterName) {
      state.selectedLogicalMasterName = selectedLogicalMasterName;
    },
    setMasterRecordList(state, masterRecordList) {
      state.masterRecordList = masterRecordList;
    },
    setCondition(state, condition) {
      state.condition = condition;
    },
    setSchema(state, schema) {
      state.schema = schema;
    },
    setColumns(state, columns) {
      state.columns = columns;
    },
    // ユーザ情報を設定
    setUserInfoModal(state, userData) {
      state.userInfoModal = userData;
    },
    // 施設情報を設定
    setFacilityList(state, facilityList) {
      state.facilityList = facilityList;
    },
    // 削除対象メールリストを設定
    setDeleteTargetEmailAddress(state, deleteTargetEmailAddress) {
      state.deleteTargetEmailAddress = deleteTargetEmailAddress;
    },
    // 職種一覧
    setMstJobList(state, mstJobList) {
      state.mstJobList = mstJobList;
    },
    // カード作成表示フラグ
    setDispCreateCard(state, isDispCreateCard) {
      state.isDispCreateCard = isDispCreateCard === 0 ? false : true;
    },
    // -----------------------------------------
    // 画面編集内容をstoreに反映
    // -----------------------------------------
    edit(state, editInfo) {
      const editRecord = editInfo.editRecord;
      const isSortMode = editInfo.isSortMode;

      // 該当レコードがあれば内容を更新、なければ追加
      const foundData = state.masterRecordList.data.find(e => {
        return e.userId === editRecord.userId;
      });
      const index = state.masterRecordList.data.indexOf(foundData);

      if (index < 0) {
        // 該当レコードがなければ追加
        // 行番号を最大値＋１で自動採番
        const maxCode = state.masterRecordList.data.reduce(
          (a, b) => (a > +b.userId ? a : +b.userId),
          0
        );
        editRecord.userId = maxCode + 1;
        state.masterRecordList.data.splice(0, 0, editRecord);
      } else {
        if (isSortMode) {
          editRecord.sortInputTime = Date.now();
        }
        Vue.set(state.masterRecordList.data, index, editRecord);
      }
    },
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 start
    setIsRegisteredShared(state, isRegisteredShared) {
      state.isRegisteredShared = isRegisteredShared;
    },
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 end
    setMstUserOTP(state, userOTP) {
      state.userOTP.secretKey = userOTP.secretKey;
      state.userOTP.Qrcode = userOTP.Qrcode;
    }
  },
  actions: {
    // -----------------------------------------
    // 利用者データ一覧を取得
    // -----------------------------------------
    getUserDataList({ commit }, facilityCd) {
      commit("setMasterRecordList", []);
      commit("setSchema", []);
      commit("setColumns", []);

      // 利用者データ一覧取得
      return sendRequestGetMstUserData(facilityCd).then(response => {
        commit("setMasterRecordList", response.data.localDataSource);
        commit("setSchema", response.data.localDataSource.schema);
        commit("setColumns", response.data.columns);

        return Promise.resolve(response);
      });
    },
    // -----------------------------------------
    // 利用者データ一覧(利用者表示順マスタ用）を取得
    // -----------------------------------------
    getUserDataSortList({ commit }, facilityCd) {
      commit("setMasterRecordList", []);
      commit("setSchema", []);
      commit("setColumns", []);

      // 利用者データ一覧取得
      return sendRequestGetMstUserDataSort(facilityCd).then(response => {
        commit("setMasterRecordList", response.data.localDataSource);
        commit("setSchema", response.data.localDataSource.schema);
        commit("setColumns", response.data.columns);

        return Promise.resolve(response);
      });
    },
    // -----------------------------------------
    // 利用者データ一覧を取得
    // -----------------------------------------
    resetUserDataList({ commit }, facilityCd) {
      commit("setMasterRecordList", []);
      // 利用者データ一覧取得
      return sendRequestGetMstUserData(facilityCd).then(response => {
        commit("setMasterRecordList", response.data.localDataSource);
        return Promise.resolve(response);
      });
    },
    // -----------------------------------------
    // 施設データ一覧を取得
    // -----------------------------------------
    facilityList({ commit }) {
      commit("setFacilityList", []);
      return sendRequestGetMstFacility().then(response => {
        commit("setFacilityList", response.data);
      });
    },
    // -----------------------------------------
    // 職種一覧を取得
    // -----------------------------------------
    async mstJobList({ commit }, facilityCd) {
      commit("setMstJobList", []);

      // 職種一覧情報取得
      const response = await sendRequestGetMstJob(facilityCd);
      var dataList = [];

      // 職種：なしを追加
      dataList.push({ jobCd: "", jobName: " " });

      response.data.forEach(function(item, index, array) {
        var job = {};
        job.jobCd = array[index].jobCd;
        job.jobName = array[index].jobName;
        job.defaultMenuFunctions =
          array[index].defaultMenuSettings.default_menu_functions;
        job.initialMenuFunction =
          array[index].defaultMenuSettings.initial_menu_function;
        dataList.push(job);
      });

      // 取得した職種一覧をセット
      commit("setMstJobList", dataList);
    },
    // -----------------------------------------
    // カード作成表示フラグを取得
    // -----------------------------------------
    getDispCreateCard({ commit }, facilityCd) {
      return sendRequestGetMstFacilitySettingValue(
        facilityCd,
        DISP_CREATE_CARD
      ).then(response => {
        commit("setDispCreateCard", response.data);
      });
    },
    // -----------------------------------------
    // 指定施設-MstSelectorを更新
    // -----------------------------------------
    /* eslint-disable no-unused-vars */
    async updateMstSelecterByFacilityCd({ commit }, objArgs) {
      return sendRequestUpdateMstSelecterByFacilityCd(objArgs.facilityCd, objArgs.request);
    },
    // -----------------------------------------
    // データ一覧を更新
    // -----------------------------------------
    setMasterName({ commit }, selectedMasterName) {
      commit("setMasterName", selectedMasterName);
    },
    setLogicalMasterName({ commit }, selectedLogicalMasterName) {
      commit("setLogicalMasterName", selectedLogicalMasterName);
    },
    setMasterRecordList({ commit }, masterRecordList) {
      commit("setMasterRecordList", masterRecordList);
    },
    setCondition({ commit }, condition) {
      commit("setCondition", condition);
    },
    setIsRegisteredShared({ commit }, isRegisteredShared) {
      commit("setIsRegisteredShared", isRegisteredShared);
    },
    // 施設情報を設定
    setFacilityList({ commit }, facilityList) {
      commit("setFacilityList", facilityList);
    },
    edit({ commit }, editInfo) {
      commit("edit", editInfo);
    },
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 start
    async setIsRegisteredSharedFromDb({ commit }, userData) {
      const response = await sendRequestUpdatePatientSharedFlg(
        userData.userId,
        userData.patientShared
      );
      if (response.status === 200) {
        commit("setIsRegisteredShared", userData.patientShared);
        return 0;
      } else {
        return -1;
      }
    },
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 end
    // add FNSI-メニューに共有ON／共有OFFを追加する。 江 start
    async getIsRegisteredSharedFromDb({ commit }, userData) {
      const response = await sendRequestGetPatientSharedFlg(
        userData.userId
      );
      commit("setIsRegisteredShared", response.data[0].patientShared);
    },
    // add FNSI-メニューに共有ON／共有OFFを追加する。 江 end
    async sendRequestAddNewUser({ commit }, userData) {
      const response = await sendRequestAddNewUser(userData);
      if (response.status === 200) {
        userData.loginUrl = response.data.loginUrl;
        userData.dispUserId = response.data.dispUserId;
        userData.userPassword = response.data.userPassword;
        userData.facilityName = response.data.facilityName;
        userData.systemUseSetting = response.data.systemUseSetting;
        commit("setUserInfoModal", userData);
        return 0;
      } else {
        return -1;
      }
    },
    async sendRequestAddNewPatUser({ commit }, userData) {
      const response = await sendRequestAddNewPatUser(userData);
      if (response.status === 200) {
        userData.loginUrl = response.data.loginUrl;
        userData.dispUserId = response.data.dispUserId;
        userData.userPassword = response.data.userPassword;
        userData.facilityName = response.data.facilityName;
        userData.systemUseSetting = response.data.systemUseSetting;
        if (!response.data.patFlg)
        {
          commit("setUserInfoModal", userData);
          return 1;
        }else{
          return 0;
        }
      } else {
        return -1;
      }
    },
    async sendRequestUpdateAdministratorFlg({ commit }, userData) {
      const response = await sendRequestUpdateAdministratorFlg(
        userData.userId,
        userData.administrator
      );
      if (response.status === 200) {
        return 0;
      } else {
        commit("setUserInfoModal", userData.userId);
        return -1;
      }
    },
    /* add 追加患者共有 楊zc start */
    async sendRequestUpdatePatientSharedFlg({ commit }, userData) {
      const response = await sendRequestUpdatePatientSharedFlg(
        userData.userId,
        userData.patientShared
      );
      if (response.status === 200) {
        return 0;
      } else {
        commit("setUserInfoModal", userData.userId);
        return -1;
      }
    },
    /* add 追加患者共有 楊zc end */
    async sendRequestUpdatePassword({ commit }, userData) {
      const response = await sendRequestUpdatePassword(
        userData.facilityCd,
        userData.userId,
        userData.patFlg
      );
      if (response.status === 200) {
        userData.loginUrl = response.data.loginUrl;
        userData.dispUserId = response.data.dispUserId;
        userData.userPassword = response.data.userPassword;
        userData.facilityName = response.data.facilityName;
        userData.systemUseSetting = response.data.systemUseSetting;
        commit("setUserInfoModal", userData);
        return 0;
      } else {
        return -1;
      }
    },
    async sendRequestUpdateFailureCnt({ commit }, userId) {
      const response = await sendRequestUpdateFailureCnt(userId);
      if (response.status === 200) {
        return 0;
      } else {
        commit("setUserInfoModal", userId);
        return -1;
      }
    },
    async sendRequestDeleteUser({ commit }, userId) {
      const response = await sendRequestDeleteUser(userId);
      if (response.status === 200) {
        return 0;
      } else {
        commit("setUserInfoModal", userId);
        return -1;
      }
    },
    async sendRequestUpdateJobCd({ commit }, userData) {
      const response = await sendRequestUpdateJobCd(
        userData.userId,
        userData.jobCd
      );
      if (response.status === 200) {
        return 0;
      } else {
        commit("setUserInfoModal", userData.userId);
        return -1;
      }
    },
    async sendRequestUpdateUserPersonalInfo({ commit }, userData) {
      const response = await sendRequestUpdateUserPersonalInfo(userData);
      if (response.status === 200) {
        return 0;
      } else {
        commit("setUserInfoModal", userData.userId);
        return -1;
      }
    },
    async sendRequestDisableAccessCard({ commit }, userId) {
      const response = await sendRequestDisableAccessCard(userId);
      if (response.status === 200) {
        return 0;
      } else {
        commit("setUserInfoModal", userId);
        return -1;
      }
    },
    //秘密鍵を削除
    async sendRequestDeleteSecretKey({ commit }, userId) {
      const response = await sendRequestDeleteSecretKey(userId);
      if (response.status === 200) {
        return 0;
      } else {
        commit("setUserInfoModal", userId);
        return -1;
      }
    },
    //ユーザーOTPを作成
    async sendRequestCreateMstUserOTP({ commit }, data) {
      const userOTP = {
        secretKey : "",
        Qrcode : ""
      }
      const response = await sendRequestCreateMstUserOTP(data.dispUserId,data.facilityCd);
      if (response.status === 200) {
        userOTP.secretKey = response.data.mtsUserSecretKey;
        userOTP.Qrcode = response.data.mstUserQR64
        commit("setMstUserOTP", userOTP);
      }
    },
    //ユーザー秘密鍵を更新する
    async sendRequestUpdateSecretKey({ commit }, data) {
      const response = await sendRequestUpdateSecretKey(data.userId,data.secretKey);
      if (response.status === 200) {
        return 0;
      } else {
        commit("setUserInfoModal", data.userId);
        return -1;
      }
    },
    // モーダル画面表示用のユーザ情報を設定
    setUserData({ commit }, userData) {
      commit("setUserInfoModal", userData);
    },
    // 削除対象メールアドレスリストの取得
    async checkDeleteTargetEmailAddress({ commit }, userEmailAddress) {
      commit("setDeleteTargetEmailAddress", []);
      const response = await sendRequestGetDeleteTargetEmailAddress(
        userEmailAddress
      );
      if (response.status === 200) {
        commit("setDeleteTargetEmailAddress", response.data);
        return 0;
      } else {
        return -1;
      }
    },
    async sendRequestDeleteEmailAddress({ state }) {
      const response = await sendRequestDeleteEmailAddress(
        state.deleteTargetEmailAddress
      );
      if (response.status === 200) {
        return 0;
      } else {
        return -1;
      }
    },
    async sendRequestUpdateIsSetQrCode({ commit }, user){
      try {
        await sendRequestUpdateIsSetQrCode(
          user.userId,
          user.isSetQrCode
        );
      } catch (error) {
        commit("setUserInfoModal", user.userId);
      }
    },
    async sendRequestCheckOtp({ commit }, checkdata) {
      const response = await sendRequestCheckOtp(
        checkdata.secretKey,
        checkdata.otp
      );
      if (response.data) {
        return 0;
      } else {
        commit("setUserInfoModal", checkdata.userId);
        return -1;
      }
    },
    // サインイン日時更新
    async sendRequestUpdateSigninDate({ commit }, data) {
      const response = await sendRequestUpdateSigninDate(data.userId);
      if (response.status === 200) {
        return 0;
      } else {
        commit("setUserInfoModal", data.userId);
        return -1;
      }
    }
  },
  getters: {
    getFacilityList(state) {
      return state.facilityList;
    },
    getMasterRecordList(state) {
      return state.masterRecordList;
    },
    getFilteredMasterRecordList(state) {
      // データ件数が0件の場合、そのまま返却
      if (
        !state.masterRecordList.data ||
        state.masterRecordList.data.length === 0
      )
        return state.masterRecordList;

      // データ件数が1件以上の場合、条件を適用
      let returnData = state.masterRecordList.data;

      // 条件にマスタ名が設定されている場合は名前で抽出
      if (state.condition.recordName != "") {
        const recordName = state.condition.recordName
        const filterJobCdArr = []
        state.mstJobList.forEach((item) => {
          if (item.jobName.includes(recordName)) {
            filterJobCdArr.push(String(item.jobCd))
          }
        })
        // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf start
        // const columnArr = ['userName', 'jobCd', 'userLastNameKana', 'userFirstNameKana', 'userLastNameAlpha',  'userFirstNameAlpha', 'extensionNo', 'homeNo', 'mobilePhoneNo', 'faxNo', 'zipcd7', 'address', 'inHospitalCd_1', 'inHospitalCd_2', 'secretKey', 'signinDate']
        const columnArr = ['userName', 'jobCd', 'userLastNameKana', 'userFirstNameKana', 'userLastNameAlpha',  'userFirstNameAlpha', 'userEmailAddress1','userEmailAddress2', 'extensionNo', 'homeNo', 'mobilePhoneNo', 'faxNo', 'zipcd7', 'address', 'inHospitalCd_1', 'inHospitalCd_2', 'secretKey', 'signinDate']
        // mod #9804 #9807対応、#9584追加メールアドレス1 メールアドレス2のエラーの再修正  lmf end
        const filterFuc = (item) => {
          let flg = false
          for (const param of columnArr) {
            if (item[param] && param === 'jobCd' && filterJobCdArr.includes(item[param])) {
              flg = true
              break
            } else if (item[param] && item[param].includes(recordName)) {
              flg = true
              break
            } else {
              flg = false
            }
          }
          return flg
        }
        returnData = returnData.filter(
          e => filterFuc(e)
        );
      }

      return {
        schema: state.masterRecordList.schema,
        data: returnData
      };
    },
    getDeleteTargetEmailAddress(state) {
      let resultMessage = "";
      state.deleteTargetEmailAddress.forEach(data => {
        let mail = "";
        if (data.userEmailAddress1 != null) {
          mail = "のメールアドレス1\n";
        } else {
          mail = "のメールアドレス2\n";
        }
        resultMessage += data.facilityName + " " + data.dispUserId + mail;
      });

      return resultMessage;
    },
    getMstJobList(state) {
      return state.mstJobList;
    },
    getIsDispCreateCard(state) {
      return state.isDispCreateCard;
    },
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 start
    getIsRegisteredShared: state => {
      return state.isRegisteredShared;
    },
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 end
    //OTPオブジェクトを取得
    getUserOTP(state) {
      return state.userOTP;
    }
  }
};
