import { sendRequestGetMstExamItemSortForComsv } from "../../../apis/exam-Record";

export default {
  namespaced: true,
  strict: process.env.NODE_ENV !== "production",
  state: {
    mstExamItemsList: []
  },
  getters: {
    // 検査項目一覧
    mstExamItemsList({ mstExamItemsList }) {
      return mstExamItemsList;
    }
  },
  actions: {
    // 検査項目一覧取得用アクション
    async getMstExamItemsList({ commit, rootGetters }) {
      const facilityCd = rootGetters["user/getFacilityCd"];
      // #9477 2023.11.17 chg 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 start
      // await sendRequestGetMstExamItemSort(facilityCd).then( res => {
      //   if(res) {
      //     commit('setMstExamItemsList',  res.data[0].orderSettings.items);
      //   }
      // });

      await sendRequestGetMstExamItemSortForComsv(facilityCd).then( res => {
        if(res) {
          commit('setMstExamItemsList',  res.data[0].orderSettings.items);
        }
      });
      // #9477 2023.11.17 chg 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 end
    },
    // add マスタ一覧 施設切替を可能とする 王 start
    async getMstExamItemsListByFacilityCd({ commit } ,facilityCd) {
      // #9477 2023.11.17 chg 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 start
      // await sendRequestGetMstExamItemSort(facilityCd).then( res => {
      //   if(res) {
      //     commit('setMstExamItemsList',  res.data[0].orderSettings.items);
      //   }
      // });

      await sendRequestGetMstExamItemSortForComsv(facilityCd).then( res => {
        if(res) {
          commit('setMstExamItemsList',  res.data[0].orderSettings.items);
        }
      });
      // #9477 2023.11.17 chg 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 end
    }
    // add マスタ一覧 施設切替を可能とする 王 end
  },
  mutations: {
    // 検査項目一覧セット用ミューテーション
    setMstExamItemsList(state, mstExamItemsList) {
      state.mstExamItemsList = mstExamItemsList;
    },
  }
};


