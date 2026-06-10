import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  namespaced: true,
  strict: process.env.NODE_ENV !== "production",
  state: {
    userSetting: {}, //ユーザー設定
    users: [], //ユーザーのリスト
    selectedIndex: { //テーブルで選択されたユーザー     
      id: "",
      userId: "",
      userName: "",
      userRole: "管理者",
      departmentCd: "",
      userPass: ""
    },
    modalUserCondition: { // モーダルに関するユーザー情報    
      isUpdtFunction: false,
      isShow: false,
      id: "",
      userId: "",
      userName: "",
      userRole: "管理者",
      departmentCd: "",
      userPass: ""
    },
    confirmPassword: "",//モーダルでパスワードを確認するために使用
    sortOptions: null,
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    orderKey: ""
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
  },
  getters: {
    getUserSetting({ userSetting }) {
      return userSetting;
    },

    getUsers({ userSetting, users }) {
      return users.map(user => ({
        id: user.id,
        userName: user.userName,
        userId: user.userId,
        userRole: user.userRole,
        regDate: new Date(user.regDate),
        upDate: new Date(user.upDate),
        isDelete: user.isDelete,
        departmentCd: user.departmentCd,
        isLock: user.numLoginAttempt >= userSetting.lockCount
      }));
    },

    getSelectedIndex({ selectedIndex }) {
      return selectedIndex;
    },

    getModalUserCondition({ modalUserCondition }) {
      return modalUserCondition;
    },

    getConfirmPassword({ confirmPassword }) {
      return confirmPassword;
    },
    
    getSortOptions(state){
      return state.sortOptions;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    getOrderKey(state) {
    return state.orderKey;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
  },
  actions: {
    //すべてのユーザーを取得する
    getUsers({ state,commit }) {
      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
      //ApiHelper.get("/cl-user/getAllUser")
      // .then(res => {
      //   commit("setUsers", res.data);
      // });
      let obj = {
        OrderKey: state.orderKey
      };
      ApiHelper.get("/cl-user/getAllUser", obj)
        .then(res => {
          commit("setUsers", res.data);
        });
      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
    },

    // ユーザーを挿入
    async insertUser({ state, commit, dispatch }) {
      let obj = {
        userId: state.modalUserCondition.userId,
        userName: state.modalUserCondition.userName,
        userRole: state.modalUserCondition.userRole,
        upDate: new Date(),
        regDate: new Date(),
        userPass: state.modalUserCondition.userPass,
        departmentCd: state.modalUserCondition.departmentCd,
        numLoginAttempt: 0
      };
      return ApiHelper.post("/cl-user/insertUser", obj).then(() => {
        dispatch("getUsers");
        commit("clearModalUserState");
      });
    },

    // ユーザーを更新する
    async updateUser({ state, dispatch }) {
      let obj = {
        id: state.selectedIndex.id,
        userName: state.modalUserCondition.userName,
        userRole: state.modalUserCondition.userRole,
        upDate: new Date(),
         //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
        //userPass: state.modalUserCondition.userPass,
        userPass: state.modalUserCondition.userPass.trim(),
         //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
        departmentCd: state.modalUserCondition.departmentCd
      };
      return ApiHelper.post("/cl-user/updateById", obj).then(() => {
        dispatch("getUsers");
      });
    },

    // ユーザーを削除
    async deleteUser({ commit, dispatch }, id) {
      return ApiHelper.post("/cl-user/deleteById", { userId: id }).then(() => {
        dispatch("getUsers");
        commit("clearModalUserState");
      });
    },

    // サインインの更新に失敗しました
    async updateLoginAttempt({state }, userInfo) {
      return ApiHelper.post("/cl-user/updateLoginAttempt", userInfo).then(
        () => {
          let users = state.users;
          users.forEach(element => {
            if(element.userId === userInfo.userId){
              element.numLoginAttempt = 0;
            }
          });
          state.users = users;
        }
      );
    },

    setModalUserVisible({ commit }, isShow) {
      commit("setModalUserVisible", isShow);
    },

    setModalUserFunction({ commit }, isUpdtFunction) {
      commit("setModalUserFunction", isUpdtFunction);
    },

    clearModalUserState({ commit }) {
      commit("clearModalUserState");
    },

    setModalUserState({ commit }) {
      commit("setModalUserState");
    },

    setSelectedIndex({ commit }, selectedIndex) {
      commit("setSelectedIndex", selectedIndex);
    },

    getUserSetting({ commit }) {
      ApiHelper.get("/cl-user/getUserSetting").then(res => {
        commit("setUserSetting", res.data);
      });
    },
    
    setSortOptions({commit}, sortOptions) {
      commit("setSortOptions", sortOptions);
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    setOrderKey({ commit }, orderKey) {
      commit("setOrderKey", orderKey);
    }
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
  },
  mutations: {
    setUserSetting(state, userSetting) {
      state.userSetting = userSetting;
    },

    setUsers(state, users) {
      state.users = users;
    },

    setSelectedIndex(state, selectedIndex) {
      state.selectedIndex = selectedIndex;
    },

    setModalUserVisible(state, isShow) {
      state.modalUserCondition.isShow = isShow;
    },

    setModalUserFunction(state, isUpdtFunction) {
      state.modalUserCondition.isUpdtFunction = isUpdtFunction;
    },

    clearModalUserState(state) {
      state.modalUserCondition = {
        isShow: false,
        isUpdtFunction: false,
        id: "",
        userId: "",
        userName: "",
        userRole: "管理者",
        departmentCd: "",
        userPass: ""
      }

      state.confirmPassword = ""
    },

    setModalUserState(state) {
      state.modalUserCondition = {
        isShow: false,
        isUpdtFunction: true,
        userId: state.selectedIndex.userId,
        userName: state.selectedIndex.userName,
        userRole: state.selectedIndex.userRole,
        departmentCd: state.selectedIndex.departmentCd,
        //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        userPass: "          "
        //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      };
    },

    setUserIdState(state, value) {
      state.modalUserCondition.userId = value;
    },

    setUserNameState(state, value) {
      state.modalUserCondition.userName = value;
    },

    setUserRoleState(state, value) {
      state.modalUserCondition.userRole = value;
    },

    setUserDepartmentState(state, value) {
      state.modalUserCondition.departmentCd = value;
    },

    setUserPasswordState(state, value) {
      state.modalUserCondition.userPass = value;
    },

    setConfirmPassword(state, value) {
      state.confirmPassword = value;
    },
    
    setSortOptions(state, sortOptions) {
      state.sortOptions = sortOptions;
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    setOrderKey(state, value) {
      state.orderKey = value;
    }
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
  }
};
