import { createRouter, createWebHashHistory } from "vue-router";
import store from "@/stores";

import LoginCL from "@/components/cl-login/LoginCL";
import ManageSite from "@/components/cl-manage-view/ManageSite";
import CLCertificateDetails from "@/components/cl-show/CLCertificateDetails";
const routes = [
  {
    path: "/",
    name: "clManagementLogin", //管理サイトのログインページ（デフォルトページ）
    component: LoginCL
  },
  {
    path: "/management",
    name: "clManagementView", //管理サイト
    component: ManageSite,
    meta: { adminAuth: true, generalAuth: true, facilityAuth: false }
  },
  {
    path: "/CertificateDetails",
    name: "CLCertificateDetails", //管理サイト
    component: CLCertificateDetails,
    meta: { adminAuth: true, generalAuth: true, facilityAuth: false }
  }
];

const router = createRouter({
  history: createWebHashHistory(),
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
    if(to.name === "ClCertificateDownload")
      // サインイン画面へ遷移
      next({ name: "clDownloadLogin" });
    else if(to.name === "clManagementView" || to.name === "CLCertificateDetails")
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
