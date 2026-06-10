/**
 * ユーザ認証ストア
 */
import { sendRequestLogin, sendRequestLogout } from "@/apis/User";

/* ユーザタイプ定義 */
// 管理タイプ
export const USER_TYPE_ADMIN = "管理者";
// 一般タイプ
export const USER_TYPE_GENERAL = "ユーザー";

export const FACILITY_ROLE = "施設";
/* 管理者フラグ定義 */
// 管理者ユーザ

export default {
  strict: true,
  namespaced: true,
  state: {
    userId: null,
    userRole: null,
    userName: null,
    isSuccess: false,
    signInTimestamp: -1,
    signInRestriction: false
  },
  mutations: {
    // 認証成功した利用者氏名を格納
    setUserId(state, userId) {
      state.userId = userId;
    },
    setUserName(state, userName) {
      state.userName = userName;
    },
    // 認証成功可否の状態を格納
    setIsSuccess(state, isSuccess) {
      state.isSuccess = isSuccess;
    },
    // 利用者種別を格納
    setUserRole(state, userRole) {
      state.userRole = userRole;
    },
    // 認証成功した利用者情報を格納
    setUser(state, user) {
      state.userId = user.userId;
      state.userRole = user.userRole;
      state.administrator = user.administrator;
    },
    // サインイン時刻を格納
    setSignInTimestamp(state, timestamp) {
      state.signInTimestamp = timestamp;
    },
    // サインイン後勝ち設定を格納
    setSignInRestriction(state, signInRestriction) {
      state.signInRestriction = signInRestriction;
    }
  },
  actions: {
    // 認証成功した利用者氏名を格納
    setUserId({ commit }, userId) {
      commit("setUserId", userId);
    },
    setUserName({ commit }, userName) {
      commit("setUserName", userName);
    },
    // 認証成功可否の状態を格納
    setIsSuccess({ commit }, isSuccess) {
      commit("setIsSuccess", isSuccess);
    },
    // 利用者種別を格納
    setUserRole({ commit }, userRole) {
      commit("setUserRole", userRole);
    },
    // 認証成功した利用者情報を格納
    setUser({ commit }, user) {
      commit("setUser", user);
    },
    // サインイン後勝ち設定を格納
    setSignInRestriction({ commit }, signInRestriction) {
      commit("setSignInRestriction", signInRestriction);
    },
    // 認証アクション
    // 引数：user -> json(userId, password, facilityCd, signInRestriction)
    signIn({ commit }, user) {
      commit("setUserId", null);
      commit("setIsSuccess", false);
      commit("setUserRole", null);
      commit("setUserName", null);
      commit("setSignInRestriction", null);
      // 認証API呼出し
      return sendRequestLogin(user).then(async response => {
        commit("setIsSuccess", true);
        commit("setUserId", user.userId);
        commit("setUserName", response.data.userName);
        commit("setUserRole", response.data.userRole);
        commit("setSignInRestriction", response.data.signInRestriction);
        // サインイン時刻の設定
        const sTime = new Date().getTime();
        commit("setSignInTimestamp", sTime);
        localStorage.setItem("s-time", sTime);
      });
    },
    signOut({ commit }) {
      return sendRequestLogout().then(() => {
        commit("setUserId", null);
        commit("setUserRole", null);
        commit("setUserName", null);
        commit("setSignInRestriction", null);
        commit("setSignInTimestamp", -1);
      });
    },
    // サインイン時刻をクリアする
    clearSignIn({ commit }) {
      commit("setUserId", null);
      commit("setUserRole", null);
      commit("setUserName", null);
      commit("setSignInRestriction", null);
      commit("setSignInTimestamp", -1);
    }
  },
  getters: {
    // ユーザーID取得
    getUserId(state) {
      return state.userId;
    },
    getUserName(state) {
      return state.userName;
    },
    // 管理タイプかどうか
    isAdminUser(state) {
      return state.userRole === USER_TYPE_ADMIN;
    },
    // 一般タイプかどうか
    isGeneralUser(state) {
      return state.userRole === USER_TYPE_GENERAL;
    },
    isUserRole(state) {
      return (
        state.userRole === USER_TYPE_GENERAL ||
        state.userRole === USER_TYPE_ADMIN
      );
    },
    isFacilityRole(state) {
      return state.userRole === FACILITY_ROLE;
    },
    // ログイン認証成功かどうか
    isSuccess(state) {
      return state.isSuccess;
    },
    // ユーザタイプ取得
    getUserRole(state) {
      return state.userRole;
    },
    // サインイン時刻取得
    getSignInTimestamp(state) {
      return state.signInTimestamp;
    },
    // サインイン後勝ち設定を取得
    getSignInRestriction(state) {
      return state.signInRestriction;
    }
  }
};
