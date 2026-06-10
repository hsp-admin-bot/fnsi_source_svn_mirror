/**
 * 送信先グループマスタ画面用Store
 */
import { PersonalUser } from "@/stores/master-maintenance/mst-destination-group/PersonalUser";
import { sendRequestGetNameAndHasEmailAddress, sendRequestGetNameAndHasEmailAddressByFacilityCd } from "@/apis/personal-user";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 検索条件
    condition: {
      staffName: "",
      onlySendEmail: false
    },
    // 施設に属する全利用者
    allStaffs: []
  },
  getters: {
    condition: state => {
      return state.condition;
    },
    staffsByCondition: state => {
      const _staffName = state.condition.staffName;
      const _onlySendEmail = state.condition.onlySendEmail;

      return state.allStaffs
        .filter(staff => staff.fullName.indexOf(_staffName) > -1)
        .filter(staff => {
          return _onlySendEmail ? staff.isSendEmailAddress : true;
        });
    }
  },
  mutations: {
    saveStaffs(state, payload) {
      state.allStaffs = payload.map(
        staff =>
          new PersonalUser(
            staff.userId,
            staff.lastName,
            staff.firstName,
            staff.hasEmailAddress1,
            staff.hasEmailAddress2
          )
      );
    },
    conditionStaffName(state, payload) {
      state.condition.staffName = payload;
    },
    conditionOnlySendEmail(state, payload) {
      state.condition.onlySendEmail = payload;
    },
    saveStaff(state, payload) {
      const index = state.allStaffs.findIndex(
        _staff => _staff.userId === payload.userId
      );
      state.allStaffs[index] = payload;
    }
  },
  actions: {
    async fetchAllStaffs(context) {
      const response = await sendRequestGetNameAndHasEmailAddress();
      context.commit("saveStaffs", response.data.personalUsers);
    },
    async fetchAllStaffsByFacilityCd(context, facilityCd) {
      const response = await sendRequestGetNameAndHasEmailAddressByFacilityCd(facilityCd);
      context.commit("saveStaffs", response.data.personalUsers);
    },
    setConditionStaffName(context, payload) {
      context.commit("conditionStaffName", payload);
    },
    setConditionOnlySendEmail(context, payload) {
      context.commit("conditionOnlySendEmail", payload);
    },
    conditionsClear(context) {
      context.commit("conditionStaffName", "");
      context.commit("conditionOnlySendEmail", false);
    },
    saveStaff(context, payload) {
      context.commit("saveStaff", payload);
    }
  }
};
