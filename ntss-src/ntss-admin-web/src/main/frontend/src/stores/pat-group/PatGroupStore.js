// add 10389 患者リストのソートが遅い gjn start
import { ApiHelper } from "@/apis/AxiosHelper";
import {
  deepCopy
} from "@/functions/common/CommonFunctions";
// add 10389 患者リストのソートが遅い gjn end

export default {
  namespaced: true,
  strict: process.env.NODE_ENV !== "production",
  state: {
    selectedPatGroup: {
      patGroupName: "",
      selectedPatList: []
    },
    editedPatGroup: {
      patGroupName: "",
      selectedPatList: []
    },
    isEditedSort: false,
    isEitedPatGroupList: false
  },
  getters: {
    // #11732 患者グループ編集中、重複して登録される start
    // selectedPatGroup({ selectedPatGroup }) {
    //   return selectedPatGroup;
    // },
    // editedPatGroup({ editedPatGroup }) {
    //   return editedPatGroup;
    // },
    selectedPatGroup(state) {
      return state.selectedPatGroup;
    },
    editedPatGroup(state) {
      return state.editedPatGroup;
    },
    // #11732 患者グループ編集中、重複して登録される end
    isEditedSort({ isEditedSort }) {
      return isEditedSort;
    },
    isEitedPatGroupList({ isEitedPatGroupList }) {
      return isEitedPatGroupList;
    }
  },
  actions: {
    setSelectedPatGroup({ commit }, patGroup) {
      commit("setSelectedPatGroup", patGroup);
    },
    setEditedPatGroup({ commit }, patGroup) {
      commit("setEditedPatGroup", patGroup);
    },
    clearState({ commit }) {
      commit("clearState");
    },
    setIsEditedSort({ commit }, isEditedSort) {
      commit("setIsEditedSort", isEditedSort);
    },
    setIsEitedPatGroupList({ commit }, isEitedPatGroupList) {
      commit("setIsEitedPatGroupList", isEitedPatGroupList);
    },

    // add 10389 患者リストのソートが遅い gjn start
    async sortPatListRight({ getters, commit, rootGetters }, sortConditions) {
      const facilityCd = rootGetters["user/getFacilityCd"];
      const treatDate = rootGetters["report-menu/getTreatDate"];
      let isPatGroup = false;
      for (const condition of sortConditions) {
        if (condition.hasOwnProperty("patGroup")) {
          isPatGroup = true;
          break;
        }
      }
      let tmpPatList;
      let patIdList;
      let sortPatListNew;
      if (isPatGroup) {
        sortPatListNew = deepCopy(getters.selectedPatGroup);
        tmpPatList = deepCopy(getters.selectedPatGroup).selectedPatList;
        patIdList = tmpPatList.map(pat => pat.pat_id);
      } else {
        return;
      }
      if (patIdList.length === 0) {
        return;
      }
      const { data: patList } = await ApiHelper.post(
        "/patInfo/getPatByIdList/" + "1",
        {
          patIdList,
          sortConditions,
          treatDate,
          facilityCd,
          tmpPatList
        }
      ).catch(err => {
        throw new Error(err);
      });
      //バックエンドのソート
      tmpPatList = JSON.parse(patList.tmpPatListSort);
      if (isPatGroup) {
        sortPatListNew.selectedPatList = tmpPatList;
        commit("setEditedPatGroup", sortPatListNew);
      }
    }
    // add 10389 患者リストのソートが遅い gjn end
  },
  mutations: {
    setSelectedPatGroup(state, patGroup) {
      state.selectedPatGroup = patGroup;
    },
    setEditedPatGroup(state, patGroup) {
      state.editedPatGroup = patGroup;
    },
    clearState(state) {
      state.selectedPatGroup.patGroupName = "";
      state.selectedPatGroup.selectedPatList = [];
      state.editedPatGroup.patGroupName = "";
      state.editedPatGroup.selectedPatList = [];
    },
    setIsEditedSort(state, isEditedSort) {
      state.isEditedSort = isEditedSort;
    },
    setIsEitedPatGroupList(state, isEitedPatGroupList) {
      state.isEitedPatGroupList = isEitedPatGroupList;
    }
  }
};
