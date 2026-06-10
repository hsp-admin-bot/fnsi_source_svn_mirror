/**
 * 臨床検査マスタ検索用のストア
 * 検索モーダルで選択された臨床検査マスタの情報は本ストア経由で呼出元に返却する.
 * モーダルにて【キャンセル】ボタンをクリックした場合、選択された臨床検査マスタにはnullが設定される.
 */

export default {
    strict: true,
    namespaced: true,
    state: {
        /**
         * 選択した臨床検査マスタ
         */
        selectedMstExamMatome: null,

        //JLAC10ｺｰﾄﾞ（１７桁）
        searchMstExamMatomeCd: null,
    },
    mutations: {
        /**
         * 選択した臨床検査マスタを設定する.
         * @param {*} state stateオブジェクト
         * @param {*} sysMedicine 選択された臨床検査マスタ
         */
        setSelectedMstExamMatome(state, mstExamMatome) {
        state.selectedMstExamMatome = mstExamMatome;
        },

        setSearchMstExamMatomeCd(state, mstExamMatomeCd) {
        state.searchMstExamMatomeCd = mstExamMatomeCd;
        },
    },
    actions: {
        /**
         * 選択した臨床検査マスタを設定する.
         * @param {*} commit stateオブジェクト
         * @param {*} sysMedicine 選択された臨床検査マスタ
         */
        setSelectedMstExamMatome({ commit }, mstExamMatome) {
        commit("setSelectedMstExamMatome", mstExamMatome);
        },

        setSearchMstExamMatomeCd({ commit }, mstExamMatomeCd) {
        commit("setSearchMstExamMatomeCd", mstExamMatomeCd);
        }
    },
    getters: {
        /**
         * 選択した臨床検査マスタを取得する.
         * @param {*} state stateオブジェクト
         * @returns 選択された臨床検査マスタ(未選択の場合、nullが設定されている.)
         */
        getSelectedMstExamMatome(state) {
        return state.selectedMstExamMatome;
        },

        getSearchMstExamMatomeCd(state) {
            return state.searchMstExamMatomeCd;
        }
    }
};
  