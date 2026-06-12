/**
 * 車いすマスタメンテナンスStore.
 */
import {
  sendRequestGetMstPersonalUser,
  sendRequestGetMstPersonalUserName,
  sendRequestGetPatPersonal,
  sendRequestGetMstPersonalUserNameByFacilityCd,
  sendRequestGetPatPersonalByFacilityCd,
  sendRequestGetPatNameByFacilityCd,
  sendRequestGetPatNameByPatId
} from "@/apis/mst-wheel-chair-maintenance";
import { sendRequestGetMstWeightScale } from "@/apis/mst-weight-maintenance";
export default {
  strict: true,
  namespaced: true,
  state: {
    // 利用者マスタ
    personalUser: [],
    // 患者マスタ
    patPersonal: [],
    // 体重測定マスタ
    mstWeightScale: null
  },
  mutations: {
    /**
     * 利用者マスタ情報登録
     * @param {*} state
     * @param {*} personalUser 利用者マスタ情報
     */
    setPersonalUserList(state, personalUser) {
      state.personalUser = personalUser;
    },
    /**
     * 患者マスタ情報登録
     * @param {*} state
     * @param {*} patPersonal 患者マスタ情報
     */
    setPatPersonalList(state, patPersonal) {
      state.patPersonal = patPersonal;
    },
    /**
     * 体重測定マスタ情報登録
     * @param {*} state
     * @param {*} mstWeightScale
     */
    setMstWeightScaleData(state, mstWeightScale) {
      state.mstWeightScale = mstWeightScale;
    }
  },
  actions: {
    /**
     * 利用者マスタ一覧をサーバーから取得してそのままreturnする
     * @param {*} param
     * @param {*} facilityCd
     */
    fetchPersonalUserSimple(context, facilityCd) {
      return sendRequestGetMstPersonalUser(facilityCd);
    },
    /**
     * 利用者マスタ一覧を削除済み込みでサーバーから取得してそのままreturnする
     * @param {*} param
     * @param {*} facilityCd
     */
    fetchPersonalUserWithDeleted() {
      return sendRequestGetMstPersonalUserName();
    },
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    fetchPersonalUserWithDeletedByFacilityCd(context, facilityCd) {
      return sendRequestGetMstPersonalUserNameByFacilityCd(facilityCd);
    },
    // add マスタ一覧 1･施設切替を可能とする 孔 end
    /**
     * 利用者マスタ一覧をサーバーから取得
     * @param {*} param
     * @param {*} facilityCd
     */
    async fetchPersonalUser({ commit }) {
      await sendRequestGetMstPersonalUserName().then(response => {
        const personalUserList = new Array();
        response.data.forEach(data => {
          personalUserList.push({
            value: data.user_id,
            text: data.user_name
          });
        });
        commit("setPersonalUserList", personalUserList);
      });
    },
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    /*async fetchPersonalUserByFacilityCd({ commit }, facilityCd) {
      await sendRequestGetMstPersonalUserNameByFacilityCd(facilityCd).then(response => {
        const personalUserList = new Array();
        response.data.forEach(data => {
          personalUserList.push({
            value: data.user_id,
            text: data.user_name
          });
        });
        commit("setPersonalUserList", personalUserList);
      });
    },*/
    async fetchPersonalUserByFacilityCd({ commit }, facilityCds) {
      const personalUserList = new Array();
      for (const facilityCd of facilityCds) {
        await sendRequestGetMstPersonalUserNameByFacilityCd(facilityCd).then(response => {
          response.data.forEach(data => {
            personalUserList.push({
              value: data.user_id,
              text: data.user_name
            });
          });
        });
      }
      commit("setPersonalUserList", personalUserList);
    },
    // add マスタ一覧 1･施設切替を可能とする 孔 end
    /**
     * 患者マスタ一覧をサーバーから取得してそのままreturnする
     * @param {*} param
     * @param {*} facilityCd
     */
    fetchPatPersonalSimple(context, facilityCd) {
      return sendRequestGetPatPersonal(facilityCd);
    },
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    fetchPatPersonalSimpleByFacilityCd(context, facilityCd) {
      return sendRequestGetPatPersonalByFacilityCd(facilityCd);
    },
    // add マスタ一覧 1･施設切替を可能とする 孔 end
    /**
     * 患者マスタ一覧をサーバーから取得
     * @param {*} param
     * @param {*} facilityCd
     */
    async fetchPatPersonal({ commit }, facilityCd) {
      await sendRequestGetPatPersonal(facilityCd).then(response => {
        const patPersonalList = new Array();
        response.data.forEach(data => {
          patPersonalList.push({
            value: data.pat_id,
            text: data.pat_last_name + data.pat_first_name
          });
        });
        commit("setPatPersonalList", patPersonalList);
      });
    },
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    async fetchPatPersonalByFacilityCd({ commit }, facilityCd) {
      await sendRequestGetPatPersonalByFacilityCd(facilityCd).then(response => {
        const patPersonalList = new Array();
        response.data.forEach(data => {
          patPersonalList.push({
            value: data.pat_id,
            // mod 9485 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。 張玲 start
            // text: data.pat_last_name + data.pat_first_name
            text: (data.pat_last_name ? data.pat_last_name: "")  + (data.pat_first_name ? data.pat_first_name : "")
            // mod 9485 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。 張玲 end
          });
        });
        commit("setPatPersonalList", patPersonalList);
      });
    },
    // add マスタ一覧 1･施設切替を可能とする 孔 end
    /**
     * 体重測定マスタをサーバから取得
     * @param {*} param
     * @param {*} facilityCd
     */
    fetchMstWeightScale(context, facilityCd) {
      return sendRequestGetMstWeightScale({ facilityCd: facilityCd });
    },
    /**
     * 体重測定マスタを保存
     * @param {Object} context
     * @param {Object} mstWeightScaleData
     */
    setMstWeightScale({ commit }, mstWeightScaleData) {
      commit("setMstWeightScaleData", mstWeightScaleData);
    },
    /**
     * 患者個人情報の患者名をサーバから施設コードで取得
     * @param {*} facilityCd
     */
    async fetchPatNameByFacilityCd({ commit }, facilityCd) {
      await sendRequestGetPatNameByFacilityCd(facilityCd).then(response => {
        const patPersonalList = new Array();
        response.data.forEach(data => {
          let name = (data.pat_last_name ? data.pat_last_name: "")  + (data.pat_first_name ? data.pat_first_name : "")
          if(data.is_del === '1') name = "【削除済み】" + name;
          patPersonalList.push({
            value: data.pat_id,
            text: name
          });
        });
        commit("setPatPersonalList", patPersonalList);
      });
    },
    /**
     * 患者個人情報の患者名をサーバから患者IDで取得
     * @param {*} patId
     */
    fetchPatNameByPatId(context, patId) {
      return sendRequestGetPatNameByPatId(patId);
    },
  },
  getters: {
    getPersonalUserList(state) {
      return state.personalUser;
    },
    getPatPersonalList(state) {
      return state.patPersonal;
    },
    getMstWeightScaleData(state) {
      return state.mstWeightScale;
    }
  }
};
