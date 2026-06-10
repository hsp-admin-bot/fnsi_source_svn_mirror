import Vue from "vue";
import VueRouter from "vue-router";
import store from "@/stores";

import ClCertificateDownload from "@/components/cl-download/ClCertificateDownload";
import LoginDownloadCL from "@/components/cl-download/LoginDownloadCL";
//add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
import LoginDownloadReset from "@/components/cl-download/LoginDownloadReset";
//add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
import P12MergePage from "@/components/cl-download/P12MergePage";
Vue.use(VueRouter);

const routes = [
  {
    path: "/",
    name: "clDownloadLogin", //ダウンロードサイトのログインページ
    component: LoginDownloadCL
  },
  {
    path: "/user",
    name: "ClCertificateDownload", //ダウンロードサイト
    component: ClCertificateDownload,
    meta: { adminAuth: false, generalAuth: false, facilityAuth: true }
  } ,
  //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
  {
    path: "/reset",
    name: "LoginDownloadReset", //ダウンロードサイト
    component: LoginDownloadReset,
    meta: { adminAuth: false, generalAuth: false, facilityAuth: true }
  },
  {
    path: "/merge",
    name: "P12MergePage", //P12証明書マージページ
    component: P12MergePage,
    meta: { adminAuth: false, generalAuth: false, facilityAuth: true }
  }
];
  //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
const router = new VueRouter({
  mode: "hash",
  routes
});

function isLoggedIn() {
  const userId = store.getters["user/getUserId"];
  return userId !== null && userId !== "";
}

// ナビゲーションガード
router.beforeEach((to, from, next) => {
  // サインイン未済アクセス対策
  if (
    to.name !== "clManagementLogin" &&
    to.name !== "clDownloadLogin" &&
    !isLoggedIn()
  ) {
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    //if(to.name === "ClCertificateDownload")
    if(to.name === "ClCertificateDownload" || to.name === "LoginDownloadReset" || to.name === "P12MergePage")
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      // サインイン画面へ遷移
      next({ name: "clDownloadLogin" });
    else if(to.name === "clManagementView")
      next({ name: "clManagementLogin" });
    return;
  } else {
    const isAdminUser = store.getters["user/isAdminUser"];
    const isGeneralUser = store.getters["user/isGeneralUser"];
    const isFacilityRole = store.getters["user/isFacilityRole"];
    // ユーザー役割を確認する
    if (to.meta.adminAuth || to.meta.generalAuth) {
      if (to.meta.adminAuth && to.meta.generalAuth) {
        if (isAdminUser || isGeneralUser) {
          next();
        } else {
          // サインイン画面へ遷移
          next({ name: "clManagementLogin" });
        }
      } else if (to.meta.adminAuth) {
        if (isAdminUser) {
          next();
        } else {
          // サインイン画面へ遷移
          next({ name: "clManagementLogin" });
        }
      } else if (to.meta.generalAuth) {
        if (isGeneralUser) {
          next();
        } else {
          // サインイン画面へ遷移
          next({ name: "clManagementLogin" });
        }
      }
    }
    // 施設コードによるログイン
    else if (to.meta.facilityAuth) {
      if (isFacilityRole) {
        next();
      } else {
        // サインイン画面へ遷移
        next({ name: "clDownloadLogin" });
      }
    } else {
      next();
    }
  }
});

export default router;
