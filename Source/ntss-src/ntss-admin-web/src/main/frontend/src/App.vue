<template>
  <div id="app" :class="fontSizeSet">
    <!-- FNSI-redming #3831「通知トーストがユーザーフロートメニューに被っている」の不具合修正 江 start -->
    <!-- <notification-message/> -->
    <notification-message id="notified-message"/>
    <!-- FNSI-redming #3831「通知トーストがユーザーフロートメニューに被っている」の不具合修正 江 end -->
    <router-view v-if="showView" />
    <iframe id="consoleFrame" style="display: none;" src="devtools.html"></iframe>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";

import { deleteAllStateDataItem } from "@/stores";
import NotificationMessage from "@/components/common/notification-message/NotificationMessageComponent";

/* add by chamaojia 2022-12-06 [5958] 定数ファイル参照の追加 --start */
import {LOCAL_STORAGE_KEY} from "@/constants/localStorageConstants";
import { persistStorePaths } from "@/constants/persistStorePaths";
import {SESSION_STORAGE_KEY} from "@/constants/sessionStorageConstants";
/* add by chamaojia 2022-12-06 [5958] 定数ファイル参照の追加 --end */
/* add by chamaojia 2023-04-26 [5958] 欠落した参照の補充  --start */
import { deleteSignin } from "@/functions/SigninFunction";
import { ensureStylesheetLink } from "@/compat/assets/head";
import {
  getAlertDialogFooterButtonElements,
  getAppElement,
  getBreadcrumbContentElements,
  getScopedDocument,
  getScopedWindow,
  getShellOverlayElements,
  getViewportHeight,
  getViewportWidth
} from "@/functions/common/LayoutMeasureHelper";
import {
  getOnsAlertDialogElement,
  getOnsAlertDialogFooterElement,
  isOnsAlertDialogElement
} from "@/functions/common/OnsenFunctions";
/* add by chamaojia 2023-04-26 [5958] 欠落した参照の補充  --end */
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import { ApiHelper } from "@/apis/AxiosHelper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end

export default {
  name: "app",
  components: {
    "notification-message": NotificationMessage,
  },
  data() {
    return {
      /* delete by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
      //intervalConsoleId: null,
      //elemConsole: null,
      /* delete by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
      /* delete by yangzhaokai 2022-11-01 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
      // countConsoleLog: 0,
      /* delete by yangzhaokai 2022-11-01 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */
      observer: null,
      alertDialogObserverRoot: null,
      alertDialogObserverOptions: null,
      alertDialogObserverPaused: false,
      watchConsoleId: null,
      appResizeTimerId: null,
      showView: true,
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getTheme", "getFontSize"]),
    ...mapGetters("app", ["getUrl", "getRefresh"]),
    /* delete by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
    //...mapGetters("toggle-dev-tool", ["isLockDevTool"]),
    /* modify by yangzhaokai 2022-11-01 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
    //...mapGetters("user", ["getFacilityCd", "getIsDisableDevtool"]),
    /* modify by yangzhaokai 2022-11-01 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */
    /* delete by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return "font-size-set-" + names[this.getFontSize];
    },
    ...mapGetters("bread-crumb", {
      gethisData: "gethisData",
      getKeepHistory:'getKeepHistory'
    })
  },
  watch: {
    getTheme() {
      this.readThemeCss();
    },
    getRefresh(val) {
      if (val?.status === true) {
        this.showView = false;
        this.$nextTick(() => {
          setTimeout(() => {
            this.showView = true;
            this.refreshFunction({
              status: false,
              date: val.date
            });
          }, 20);
        });
      }
    },
    gethisData(newVal, oldVal) {
      const params = {
        destPageName: newVal
      };
      if (oldVal) {
        ApiHelper.put("/logs/event/pageRouterLog", params);
      }
    },
    fontSizeSet() {
      this.syncAppShell();
    },
    /* delete by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
    // isLockDevTool() {
    //   /* modify by yangzhaokai 2022-11-01 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
    //   // this.setWatchConsole(this.isLockDevTool);
    //   this.setWatchConsole();
    //   /* modify by yangzhaokai 2022-11-01 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */
    // }
    /* delete by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */
  },
  methods: {
    ...mapActions("window-size", ["setSize"]),
    ...mapActions("toggle-dev-tool", [
      "lockDevTool",
      "setPressedKey",
      "removePressedKey"
    ]),
    /* add by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
    ...mapGetters("toggle-dev-tool", ["isLockDevTool"]),
    // modify 10718 by kangjie 20240724 start
    // ...mapGetters("user", ["getFacilityCd", "getIsDisableDevtool"]),
    ...mapGetters("user", ["getFacilityCd"]),
    // modify 10718 by kangjie 20240724 end
    /* add by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */
    // mod #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou start
    // ...mapActions("bread-crumb", ["resetKeepHistory"]),
    ...mapActions("bread-crumb", ["resetKeepHistory", "setPopstate"]),
    // mod #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou end
    /* modify by yangzhaokai 2022-11-01 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
    // modify 10718 by kangjie 20240724 start
    // ...mapActions("user", ["signOut", "setIsDisableDevtool"]),
    ...mapActions("user", ["signOut"]),
    // modify 10718 by kangjie 20240724 end
    ...mapActions("app", ["refreshFunction"]),
    getAppScopedDocument() {
      return getScopedDocument(this.$el || this);
    },
    getAppScopedWindow() {
      return getScopedWindow(this.$el || this);
    },
    getAppViewportSize(extraHeight = 0, extraWidth = 0) {
      return {
        windowHeight: getViewportHeight(this.$el || this) + Number(extraHeight || 0),
        windowWidth: getViewportWidth(this.$el || this) + Number(extraWidth || 0)
      };
    },
    /* modify by yangzhaokai 2022-11-01 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */
    ...mapActions("account-edit", ["clearUserAccountInfo"]),
    ...mapActions("operation-viewer/machine", ["clearFacilityCd"]),
    /* add by chamaojia 2023-04-26 [5958] 欠落した参照の補充  --start */
    ...mapGetters("user", ["isSignIn", "isSignOut"]),
    /* add by chamaojia 2023-04-26 [5958] 欠落した参照の補充  --end */
    // Windowリサイズイベントハンドラ
    handleResizeWindow() {
      // Windowリサイズ時、幅をStoreに格納
      this.setSize(this.getAppViewportSize());

      // Windowリサイズ時、パンくずリストを右に寄せる
      this.$nextTick(() => {
        getBreadcrumbContentElements(this.$el || this).forEach(e => {
          e.scrollLeft = 1000;
        });
      });
    },

    syncAppShell() {
      const fontSizeClasses = [
        "font-size-set-small",
        "font-size-set-medium",
        "font-size-set-large",
        "font-size-set-x-large"
      ];
      const scopedDocument = this.$el?.ownerDocument || document;
      const htmlRoot = scopedDocument.documentElement;
      const bodyRoot = scopedDocument.body;
      const preferredShellRoot = getAppElement(this.$el || this);
      const mountRoot = preferredShellRoot?.parentElement?.matches?.("#app[data-v-app]")
        ? preferredShellRoot.parentElement
        : preferredShellRoot;
      const legacyAppRoot = preferredShellRoot && preferredShellRoot !== mountRoot ? preferredShellRoot : null;
      // Keep Vue2-equivalent sizing semantics: apply font-size class to only one app shell root.
      const shellRoots = Array.from(new Set([mountRoot, legacyAppRoot].filter(Boolean)));
      const syncTarget = (target) => {
        if (!target) {
          return;
        }
        target.classList.remove(...fontSizeClasses);
        target.classList.add(this.fontSizeSet);
      };

      shellRoots.forEach((target) => {
        target.classList.remove(...fontSizeClasses);
      });
      syncTarget(preferredShellRoot);

      shellRoots.forEach((target) => {
        target.classList.remove("ntss-app-shell");
        ["overflowY", "width", "height", "minHeight", "display"].forEach((key) => {
          target.style[key] = "";
        });
      });

      [htmlRoot, bodyRoot].filter(Boolean).forEach((target) => {
        target.classList.remove(...fontSizeClasses);
      });
      if (htmlRoot) {
        ["width", "height", "minHeight"].forEach((key) => {
          htmlRoot.style[key] = "";
        });
      }
      if (bodyRoot) {
        ["width", "height", "minHeight", "margin"].forEach((key) => {
          bodyRoot.style[key] = "";
        });
      }

      getShellOverlayElements(this.$el || this).forEach((element) => {
        element.classList.remove(...fontSizeClasses);
        element.classList.add(this.fontSizeSet);
      });
    },

    getLegacyCssCandidates(fileName) {
      const normalized = fileName.replace(/^\/+/, "");
      const baseUrl = import.meta.env.BASE_URL || "/";
      const cleanedBase = baseUrl.endsWith("/") ? baseUrl : `${baseUrl}/`;
      return [
        `${cleanedBase}css/${normalized}`,
        `./css/${normalized}`,
        `/css/${normalized}`,
        `${cleanedBase}${normalized}`
      ].filter((value, index, array) => array.indexOf(value) === index);
    },

    ensureStylesheetLink(id, hrefOrCandidates, media = null) {
      ensureStylesheetLink(id, hrefOrCandidates, media, this.$el || this);
    },

    // cssファイル読み込み
    readCss() {
      this.ensureStylesheetLink("ntss-base-css", this.getLegacyCssCandidates("ntss.css"));
    },

    // 印刷用cssファイル読み込み
    readPrintCss() {
      this.ensureStylesheetLink(
        "ntss-print-css",
        this.getLegacyCssCandidates("ntss_print.css"),
        "print"
      );
    },

    // themeのcssファイル読み込み
    readThemeCss() {
      const names = ["ntss_variables_w", "ntss_variables_b"];
      this.ensureStylesheetLink(
        "ntss-theme-css",
        this.getLegacyCssCandidates(`${names[this.getTheme]}.css`)
      );
    },

    // fix 2026/03/26 kendoエディタ用カスタムCSSをグローバルに読み込む lcl start
    // kendoCustomStyle.css をアプリ全体で利用するために head に追加します。
    readKendoCustomCss() {
      // Vue2 と同じく ntss/theme CSS 読み込み後に kendoCustomStyle.css を読み込む。
      // Vite base / host document の違いだけ compat helper に寄せ、重複 link は作らない。
      this.ensureStylesheetLink(
        "ntss-kendo-custom-css",
        this.getLegacyCssCandidates("kendoCustomStyle.css")
      );
    },
    // fix 2026/03/26 kendoエディタ用カスタムCSSをグローバルに読み込む lcl end

    // 各input要素にreadonly属性を設定
    setInputReadOnly(elem, flag) {
      const targetElement = elem?.nodeType === 1 ? elem : null;
      if (!targetElement) return;

      const isInput = targetElement.tagName === "INPUT";
      // #8791 患者イベントの時計アイコンが異常 林峻峰 start
      // const isInputTypeValid = ["date", "time", "number", "datetime-local"].includes(elem.type);
      const isInputTypeValid = ["date", "number", "datetime-local"].includes(targetElement.type);
      // #8791 患者イベントの時計アイコンが異常 林峻峰 end

      if (!isInput || !isInputTypeValid) return;

      const scopedDocument = targetElement.ownerDocument || this.$el?.ownerDocument || document;
      const arrInput = [...scopedDocument.getElementsByTagName("input")];
      const arrText = [...scopedDocument.getElementsByTagName("textarea")];

      arrInput.map(item => (item.readOnly = item !== targetElement ? flag : false));
      arrText.map(item => (item.readOnly = flag));
    },

    getPhysicalKeyCode(ev) {
      return ev.keyCode ?? ev.which ?? 0;
    },

    handleKeyDown(ev) {
      this.setPressedKey(`${this.getPhysicalKeyCode(ev)}${ev.location || ""}`);
    },

    handleKeyUp(ev) {
      this.removePressedKey(`${this.getPhysicalKeyCode(ev)}${ev.location || ""}`);
    },

    handleWindowFocus(ev) {
      this.setInputReadOnly(ev.target, true);
    },

    handleWindowBlur(ev) {
      this.setInputReadOnly(ev.target, false);
    },

    getNavigationType() {
      const performance = this.getAppScopedWindow()?.performance || globalThis?.performance;
      const navigationEntry = performance?.getEntriesByType?.("navigation")?.[0];
      if (navigationEntry?.type) {
        return navigationEntry.type;
      }

      if (performance?.navigation?.type === performance?.navigation?.TYPE_RELOAD) {
        return "reload";
      }

      return "navigate";
    },

    clearWatchConsole() {
      if (this.watchConsoleId) {
        clearInterval(this.watchConsoleId);
        this.watchConsoleId = null;
      }
    },

    /* modify by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
    setWatchConsole() {
      this.clearWatchConsole();
      const $this = this;
      const ownerWindow = this.getAppScopedWindow() || globalThis;
      const scopedSessionStorage = ownerWindow?.sessionStorage || globalThis?.sessionStorage;
      this.watchConsoleId = ownerWindow.setInterval(function() {
        if(!$this.isLockDevTool()){
          return;
        }
        //del 10718 by kangjie 20240709 start
        // console.log(Object.defineProperties(new Error, {
        //   toString: {value() {(new Error).stack.includes('toString@') && alert('Safari devtools')}},
        //   message: {get() {
        //       openStatus = 1;
        //     }}
        // }));
        // console.clear();
        //del 10718 by kangjie 20240709 end
        //add 10718 by kangjie 20240709 start
        let consoleStatus = ownerWindow.consoleStatus;
        if ("on" == consoleStatus ) {
          scopedSessionStorage?.setItem("consoleStatus","on");
          $this.devToolsOpenCallback();
        } else {
          scopedSessionStorage?.setItem("consoleStatus","off");
        }
        //add 10718 by kangjie 20240709 end
      }, 1000);
      /* delete by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
      // DisableDevtool({
      //   interval: 500,
      //   ondevtoolopen() {
      //     // ユーザーフロートボタン：青状態、デベロッパーツールの起動状態：起動
      //     if ($this.isLockDevTool) {
      //       // 現在表示している画面がサインイン画面ではない場合にダイアログを表示
      //       const strUrl = window.location.href.split(window.location.pathname);
      //
      //       // ログイン画面以外の場合
      //       if ($this.getFacilityCd !== null && (!(strUrl[1] === "#/" || strUrl[1].indexOf("#/?key") === 0))) {
      //         // 起動すると、強制サインアウト
      //         $this.signOut();
      //         $this.clearUserAccountInfo();
      //         // 現在表示している画面がサインイン画面ではない場合にダイアログを表示
      //         const strUrl = window.location.href.split(window.location.pathname);
      //         if (!(strUrl[1] === "#/" || strUrl[1].indexOf("#/?key") === 0)) {
      //           $this.$ons.notification.alert({
      //             title: "サインアウト",
      //             message: "デベロッパーツールが開かれたのでサインアウトしました。</br>デベロッパーツールを閉じて、サインインしてください。"
      //           });
      //         }
      //         // ログイン画面へ遷移
      //         // ※URLにパラメータが含まれている場合に書き変わらない為、
      //         // window.locationで遷移するように変更
      //         window.location.href = $this.getUrl;
      //         // パンくずリストをクリア
      //         $this.resetKeepHistory();
      //         // 施設コードをクリア
      //         $this.clearFacilityCd();
      //       }
      //     }
      //
      //     // 現在表示している画面がサインイン画面ではない場合にダイアログを表示
      //     const strUrl = window.location.href.split(window.location.pathname);
      //     if (!$this.getIsDisableDevtool && (strUrl[1] === "#/" || strUrl[1].indexOf("#/?key") === 0)) {
      //       $this.setIsDisableDevtool(true)
      //     }
      //   },
      //   ondevtoolclose() {
      //     $this.setIsDisableDevtool(false)
      //   }
      // });
      /* delete by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */

      // if (isWatching) {
      //   //#6694 ブラウザのメニューからデベロッパーツールの起動を検知する
      //   const $this = this;
      //   let num = 0;
      //   const devtools = new Date();
      //   devtools.toString = function() {
      //     num++;
      //   //foo.toString = function() {
      //     if (num > 1) {
      //       if ($this.getFacilityCd !== null && $this.countConsoleLog !== 0) {
      //         // storeに保持している利用者情報をクリア
      //         $this.countConsoleLog = 0;
      //         // 起動すると、強制サインアウト
      //         $this.signOut();
      //         $this.clearUserAccountInfo();
      //         // 現在表示している画面がサインイン画面ではない場合にダイアログを表示
      //         const strUrl = window.location.href.split(window.location.pathname);
      //         if (!(strUrl[1] === "#/" || strUrl[1].indexOf("#/?key") === 0)) {
      //           $this.$ons.notification.alert({
      //             title: "サインアウト",
      //             message: "デベロッパーツールが開かれたのでサインアウトしました。</br>デベロッパーツールを閉じて、サインインしてください。"
      //           });
      //         }
      //         // ログイン画面へ遷移
      //         // ※URLにパラメータが含まれている場合に書き変わらない為、
      //         // window.locationで遷移するように変更
      //         window.location.href = $this.getUrl;
      //         // パンくずリストをクリア
      //         $this.resetKeepHistory();
      //         // 施設コードをクリア
      //         $this.clearFacilityCd();
      //       }
      //     }
      //   }
      //   console.log('', devtools);
      //   this.intervalConsoleId = setInterval(() => {
      //      //console.log("%c", this.elemConsole);
      //     this.countConsoleLog++;
      //   }, 1000);
      // } else {
      //   clearInterval(this.intervalConsoleId);
      //   this.countConsoleLog = 0;
      // }
    },
    /* modify by yangzhaokai 2022-11-01 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */

    /* add by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
    devToolsOpenCallback(){
      const $this = this;
      // ユーザーフロートボタン：青状態、デベロッパーツールの起動状態：起動
      if ($this.isLockDevTool) {
        // 現在表示している画面がサインイン画面ではない場合にダイアログを表示
        const ownerLocation = (this.getAppScopedWindow() || globalThis)?.location || {};
        const strUrl = String(ownerLocation.href || "").split(ownerLocation.pathname || "");
        // ログイン画面以外の場合
        if ($this.getFacilityCd !== null && (!(strUrl[1] === "#/" || strUrl[1].indexOf("#/?key") === 0))) {
          // 起動すると、強制サインアウト
          $this.signOut();
          $this.clearUserAccountInfo();
          // 現在表示している画面がサインイン画面ではない場合にダイアログを表示
          // del 10718 by kangjie 20240724 start
          // const strUrl = window.location.href.split(window.location.pathname);
          // if (!(strUrl[1] === "#/" || strUrl[1].indexOf("#/?key") === 0)) {
            // $this.$ons.notification.alert({
            //   title: "サインアウト",
            //   message: "デベロッパーツールが開かれたのでサインアウトしました。</br>デベロッパーツールを閉じて、サインインしてください。"
            // });
          // }
          // del 10718 by kangjie 20240724 end
          // ログイン画面へ遷移
          // ※URLにパラメータが含まれている場合に書き変わらない為、
          // window.locationで遷移するように変更
          (this.getAppScopedWindow() || globalThis).location.href = $this.getUrl;
          // パンくずリストをクリア
          $this.resetKeepHistory();
          // 施設コードをクリア
          $this.clearFacilityCd();
        }
      }
    },
    /* add by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */

    pauseAlertDialogObserverForDailyHistoryGrid() {
      if (!this.observer || this.alertDialogObserverPaused) {
        return;
      }
      try {
        this.observer.disconnect();
        this.alertDialogObserverPaused = true;
        // 点検履歴 Kendo Grid locked 初期化中は body 全体の MutationObserver を止める。
        // locked grid は大量の style/childList mutation を発生させるため、alert-dialog 用監視を巻き込まない。
        console.time?.("[DailyHistoryObserver] paused");
      } catch (error) {
        this.alertDialogObserverPaused = false;
        getErrorMessage('App.vue', 'pauseAlertDialogObserverForDailyHistoryGrid', error);
      }
    },
    resumeAlertDialogObserverForDailyHistoryGrid() {
      if (!this.observer || !this.alertDialogObserverPaused) {
        return;
      }
      const scopedDocument = this.$el?.ownerDocument || document;
      const observeRoot = this.alertDialogObserverRoot || scopedDocument.body || scopedDocument.documentElement;
      const options = this.alertDialogObserverOptions || {
        attributes: true,
        attributeFilter: ["style"],
        subtree: true,
        childList: true
      };
      if (!observeRoot) {
        return;
      }
      try {
        this.observer.observe(observeRoot, options);
        this.alertDialogObserverPaused = false;
        console.timeEnd?.("[DailyHistoryObserver] paused");
      } catch (error) {
        getErrorMessage('App.vue', 'resumeAlertDialogObserverForDailyHistoryGrid', error);
      }
    },
    observeAlertDialog() {
      const MutationObserver =
        (this.getAppScopedWindow() || globalThis).MutationObserver ||
        (this.getAppScopedWindow() || globalThis).WebKitMutationObserver ||
        (this.getAppScopedWindow() || globalThis).MozMutationObserver;

      const options = {
        attributes: true,
        attributeFilter: ["style"],
        subtree: true,
        childList: true
      };

      /* 十字キーでボタンのフォーカスを移動する関数 */
      const moveFocus = (currentButton, direction) => {
        // .alert-dialog-footer内のすべてのボタンを取得し、配列に変換
        const buttons = Array.from(getAlertDialogFooterButtonElements(currentButton?.closest?.('.alert-dialog-footer') || currentButton));
        // 現在のボタンのインデックスを取得
        const currentIndex = buttons.indexOf(currentButton);
        let newIndex;
        // 押されたキーに応じて新しいインデックスを計算
        switch (direction) {
          case 'ArrowLeft':
            if (currentIndex === 0) {
              newIndex = 0; // 0の位置では左に移動しない
            } else {
              newIndex = (currentIndex - 1 + buttons.length) % buttons.length; // 左に移動
            }
            break;
          case 'ArrowRight':
            if (currentIndex === buttons.length - 1) {
              newIndex = buttons.length - 1; // 最後の位置では右に移動しない
            } else {
              newIndex = (currentIndex + 1) % buttons.length; // 右に移動
            }
            break;
        }
        // 新しいインデックスのボタンにフォーカスを移動
        buttons[newIndex].focus();
      };

      /* ボタンにイベントリスナーを追加する関数 */
      const addEvent = (button, position, bottomRadius, buttonFooter) => {
        const footer = buttonFooter[position];
        // aタグが存在する場合は削除
        footer.querySelectorAll("a").forEach(anchor => anchor.remove());
        // ボタンをbuttonFooterの指定位置に追加
        footer.appendChild(button);
        // ボタンにクリックイベントリスナーを追加
        button.addEventListener("click", footer.click);
        button.addEventListener("keypress", footer.click);
        // ボタンにフォーカスが当たったときの処理
        button.addEventListener("focus", function () {
          footer.classList?.add('focus-button');
          switch (bottomRadius) {
            case 0:
              footer.classList?.add('bottom-radius');
              break;
            case 1:
              footer.classList?.add('bottom-left-radius');
              break;
            case 2:
              footer.classList?.add('bottom-right-radius');
              break;
          }
        });
        // ボタンからフォーカスが外れたときの処理
        button.addEventListener("focusout", function () {
          footer.classList.remove('focus-button');
          switch (bottomRadius) {
            case 0:
              footer.classList.remove('bottom-radius');
              break;
            case 1:
              footer.classList.remove('bottom-left-radius');
              break;
            case 2:
              footer.classList.remove('bottom-right-radius');
              break;
          }
        });
        // ボタンにキーダウンイベントリスナーを追加
        button.addEventListener("keydown", function (event) {
          let direction = event.key;
          // タブキーを右矢印キーに変更
          if (event.key === 'Tab' && !event.shiftKey) {
            direction = 'ArrowRight';
          }
          // シフトタブキーを左矢印キーに変更
          else if (event.key === 'Tab' && event.shiftKey) {
            direction = 'ArrowLeft';
          }
          // 左矢印キーまたは右矢印キーの場合にフォーカスを移動
          if (direction === 'ArrowLeft' || direction === 'ArrowRight') {
            event.preventDefault(); // デフォルトのタブ動作を無効化
            moveFocus(button, direction);
          }
        });
      };

      /* v-ons-alert-dialog 要素を処理する関数 */
      const handleAlertDialog = (target) => {
        const alertDialog = getOnsAlertDialogElement(target);
        if (!alertDialog) {
          return;
        }
        // Vuex 共通ダイアログ（GlobalOnsAlertDialog）は v-ons-alert-dialog-button で閉じる。
        // class 付与前に MutationObserver が走ると footer が <a> に差し替わり OK が効かなくなる。
        if (
          alertDialog.classList?.contains("ntss-global-ons-dialog")
          || alertDialog.closest?.("#ons-alert-dialog-global-root")
        ) {
          return;
        }
        // alertDialogのクラスリストをループして、'font-size-set-'を含むクラスを削除
        alertDialog.classList.forEach(item => {
          if (item.includes('font-size-set-')) {
            alertDialog.classList.remove(item);
          }
        });
        // 新しいフォントサイズのクラスを追加
        alertDialog?.classList?.add(this.fontSizeSet);
        // フッターのタイプを取得
        const typeFooter = alertDialog.className.split("-")[1];
        // alert-dialog-footer要素を取得
        const footer = getOnsAlertDialogFooterElement(alertDialog);
        if (!footer) {
          return;
        }
        // フッター内のボタン要素を取得
        const buttonFooter = footer.children;
        // 新しいボタン要素を作成
        const alertOwnerDocument = alertDialog.ownerDocument || document;
        const buttonFirst = alertOwnerDocument.createElement("a");
        buttonFirst.href = "#";
        const buttonSecond = alertOwnerDocument.createElement("a");
        buttonSecond.href = "#";
        const buttonLast = alertOwnerDocument.createElement("a");
        buttonLast.href = "#";

        // ボタンの数に応じてイベントを追加
        switch (buttonFooter.length) {
          case 1:
            addEvent(buttonFirst, 0, 0, buttonFooter);
            break;
          case 2:
            switch (typeFooter) {
              case "4":
              case "5":
                addEvent(buttonFirst, 0, 1, buttonFooter);
                addEvent(buttonSecond, 1, 2, buttonFooter);
                break;
              default:
                addEvent(buttonFirst, 1, 2, buttonFooter);
                addEvent(buttonSecond, 0, 1, buttonFooter);
                break;
            }
            break;
          case 3:
            addEvent(buttonFirst, 0, 1, buttonFooter);
            addEvent(buttonSecond, 1, null, buttonFooter);
            addEvent(buttonLast, 2, 2, buttonFooter);
            break;
        }

        // 最初のボタンにフォーカスを設定
        setTimeout(() => {
          buttonFirst.focus();
        });
      };

      /* MutationObserverのコールバック関数 */
      const callback = mutations => {
        // すべてのmutationをループ
        mutations.forEach(mutation => {
          // attributes の変更をチェックし、対象が v-ons-alert-dialog の場合
          if (mutation.type === 'attributes' && isOnsAlertDialogElement(mutation.target)) {
            handleAlertDialog(mutation.target);
          }
          // 子ノードの追加をチェック
          else if (mutation.type === 'childList') {
            mutation.addedNodes.forEach(node => {
              // 追加されたノードが v-ons-alert-dialog の場合
              if (isOnsAlertDialogElement(node)) {
                handleAlertDialog(node);
              }
            });
          }
        });
      };

      const scopedDocument = this.$el?.ownerDocument || document;
      const observeRoot = scopedDocument.body || scopedDocument.documentElement;
      if (!observeRoot) {
        return;
      }

      this.alertDialogObserverRoot = observeRoot;
      this.alertDialogObserverOptions = options;
      this.alertDialogObserverPaused = false;
      this.observer = new MutationObserver(callback);
      this.observer.observe(observeRoot, options);
    },

    beforePrintSize(){
      //印刷前-kendo-grid表示のために一旦width値を書き換え
      this.setSize(this.getAppViewportSize(0, -1));
    },
    /* add by chamaojia 2022-12-06 リフレッシュイベントsessionStorageへのデータ持続化の追加 --start */
    beforeUnload() {
      if (this.$route.name === "signin") {
        // サインインしている状態でタブ若しくはブラウザが閉じられた場合
        this.$nextTick(() => {
          // サインインしている場合
          // ※サインアウトしないでタブやブラウザを閉じた場合がある.
          if (!this.isSignOut() && this.isSignIn()) {
            const scopedLocalStorage = this.getAppScopedWindow()?.localStorage || globalThis?.localStorage;
            const signInCount = (scopedLocalStorage?.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT) || 0) - 1;
            if (signInCount <= 0) {
              scopedLocalStorage?.removeItem(LOCAL_STORAGE_KEY.FACILITY_HASH);
              scopedLocalStorage?.removeItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
            } else {
              scopedLocalStorage?.setItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT, signInCount);
            }
          }
          this.$nextTick(() => {
            // unload イベントは発火しない為、beforeunload の後続処理で実行する
            deleteSignin(this.$el);
          });
        });
      } else {
        this.setSessionStorage();
      }
      // 9501対応時のメモ：
      // edgeの場合にサインアウト後のリロード時に
      // Storeのstateオブジェクトが残留するメモリリークを起こすようだが
      // メモリリークを起こさせない方法が不明のため、
      // state自体が残留してもその量を抑えることで影響を軽減するために
      // state内の配列を空にしておく
      deleteAllStateDataItem();
    },
    setSessionStorage() {
      const scopedSessionStorage = this.getAppScopedWindow()?.sessionStorage || globalThis?.sessionStorage;
      for (const storePath of persistStorePaths) {
        const storeNameArr = storePath.split(".");
        let value = this.$store.state;
        for (let i = 0; i < storeNameArr.length; i++) {
          value = value[storeNameArr[i]]
        }

        scopedSessionStorage?.setItem(storePath, JSON.stringify(value))
      }

      scopedSessionStorage?.setItem(SESSION_STORAGE_KEY.REFRESH_FLAG, "1")
    },
    /* add by chamaojia 2022-12-06 [5958] リフレッシュイベントsessionStorageへのデータ持続化の追加 --end */
  },
  created() {
    this.lockDevTool();
    // Windowリサイズ検知
    this.getAppScopedWindow().addEventListener("resize", this.handleResizeWindow, false);
    this.getAppScopedWindow().addEventListener("beforeprint", this.beforePrintSize, false);
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou start
    this.getAppScopedWindow().addEventListener("popstate", this.setPopstate, false);
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou end
    this.getAppScopedDocument().addEventListener("keydown", this.handleKeyDown);
    this.getAppScopedDocument().addEventListener("keyup", this.handleKeyUp);
    // cssファイルを読み込む
    this.readCss();
    this.readPrintCss();
    this.readThemeCss();
    this.readKendoCustomCss();

/*    this.elemConsole = new Image();
    const $this = this;
    Object.defineProperty(this.elemConsole, "id", {
      get: function() {
        if ($this.getFacilityCd !== null && $this.countConsoleLog !== 0) {
          $this.countConsoleLog = 0;
          // storeに保持している利用者情報をクリア
          $this.signOut();
          $this.clearUserAccountInfo();
          // 現在表示している画面がサインイン画面ではない場合にダイアログを表示
          const strUrl = window.location.href.split(window.location.pathname);
          if (!(strUrl[1] === "#/" || strUrl[1].indexOf("#/?key") === 0)) {
            $this.$ons.notification.alert({
              title: "サインアウト",
              message: "デベロッパーツールが開かれたのでサインアウトしました。</br>デベロッパーツールを閉じて、サインインしてください。"
            });
          }
          // ログイン画面へ遷移
          // ※URLにパラメータが含まれている場合に書き変わらない為、
          // window.locationで遷移するように変更
          window.location.href = $this.getUrl;
          // パンくずリストをクリア
          $this.resetKeepHistory();
          // 施設コードをクリア
          $this.clearFacilityCd();
        }
        return null;
      }
    });*/
    /* modify by yangzhaokai 2022-11-01 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
    // this.setWatchConsole(this.isLockDevTool);
    this.setWatchConsole();
    /* modify by yangzhaokai 2022-11-01 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */
  },
  mounted() {
    this.syncAppShell();
    // 初期Windowサイズ(幅)設定
    this.$nextTick(() => {
      this.syncAppShell();
      if (this.getNavigationType() === "reload") {
        // リロード対策：DOM生成やCSSロードより後に高さの調整を遅延させる。
        this.setSize(this.getAppViewportSize(-100));
      }
      this.appResizeTimerId = this.getAppScopedWindow().setTimeout(() => {
        this.appResizeTimerId = null;
        this.syncAppShell();
        this.handleResizeWindow();
      }, 200);
    });

    // 入力フォカスアウト対策:onFocus時に編集対象以外の各input要素のreadonly属性をONにする
    this.getAppScopedWindow().addEventListener("focus", this.handleWindowFocus, true);

    // 入力フォカスアウト対策:onBlur時に各input要素のreadonly属性をOFFにする
    this.getAppScopedWindow().addEventListener("blur", this.handleWindowBlur, true);
    /* add by chamaojia 2022-12-06 LoginView.vueから移行されたイベントリスナーの追加 --start */
    /* add by chamaojia 2022-12-06 LoginView.vueから移行されたイベントリスナーの追加 --end */
    /* fix #10961 by lcl 2026-2-14  --start */
    this.getAppScopedWindow().addEventListener("pagehide", this.beforeUnload, false);
    /* fix #10961 by lcl 2026-2-14  --end */

    this.observeAlertDialog();
    const scopedWindowForDailyHistoryObserver = this.getAppScopedWindow() || globalThis;
    this.pauseDailyHistoryAlertObserver = () => this.pauseAlertDialogObserverForDailyHistoryGrid();
    this.resumeDailyHistoryAlertObserver = () => this.resumeAlertDialogObserverForDailyHistoryGrid();
    scopedWindowForDailyHistoryObserver.__ntssPauseAlertDialogObserverForDailyHistoryGrid = this.pauseDailyHistoryAlertObserver;
    scopedWindowForDailyHistoryObserver.__ntssResumeAlertDialogObserverForDailyHistoryGrid = this.resumeDailyHistoryAlertObserver;
    // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
    this.keydownHandler = (e) => {
      // 判断 Ctrl+P 或 Command+P
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'p') {
        const pageName = this.$route?.meta?.title || "";
        const btnName = "Ctrl+P";
        const param = {
          pageName: pageName,
          btnName: btnName
        };
        ApiHelper.put("/logs/event/accesslog", param)
          .catch(err => {
            getErrorMessage('App.vue', 'mounted', err);
          });
      }
    };
    this.getAppScopedWindow().addEventListener('keydown', this.keydownHandler);
    // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
  },
  // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
  beforeDestroy() {
    this.getAppScopedWindow().removeEventListener('keydown', this.keydownHandler);
  },
  beforeUnmount() {
    const scopedWindow = this.getAppScopedWindow();
    if (this.appResizeTimerId) {
      scopedWindow.clearTimeout?.(this.appResizeTimerId);
      this.appResizeTimerId = null;
    }
    scopedWindow.removeEventListener('keydown', this.keydownHandler);
    scopedWindow.removeEventListener("pagehide", this.beforeUnload, false);
  },
  unmounted() {
    this.getAppScopedWindow().removeEventListener("resize", this.handleResizeWindow, false);
    this.getAppScopedWindow().removeEventListener("beforeprint", this.beforePrintSize, false);
    this.getAppScopedWindow().removeEventListener("focus", this.handleWindowFocus, true);
    this.getAppScopedWindow().removeEventListener("blur", this.handleWindowBlur, true);
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou start
    this.getAppScopedWindow().removeEventListener('popstate', this.setPopstate, false);
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou end
    this.getAppScopedDocument().removeEventListener("keydown", this.handleKeyDown);
    this.getAppScopedDocument().removeEventListener("keyup", this.handleKeyUp);
    this.getAppScopedWindow().removeEventListener('keydown', this.keydownHandler);
    this.getAppScopedWindow().removeEventListener("pagehide", this.beforeUnload, false);
    this.clearWatchConsole();
    const scopedWindowForDailyHistoryObserver = this.getAppScopedWindow() || globalThis;
    if (scopedWindowForDailyHistoryObserver.__ntssPauseAlertDialogObserverForDailyHistoryGrid === this.pauseDailyHistoryAlertObserver) {
      delete scopedWindowForDailyHistoryObserver.__ntssPauseAlertDialogObserverForDailyHistoryGrid;
    }
    if (scopedWindowForDailyHistoryObserver.__ntssResumeAlertDialogObserverForDailyHistoryGrid === this.resumeDailyHistoryAlertObserver) {
      delete scopedWindowForDailyHistoryObserver.__ntssResumeAlertDialogObserverForDailyHistoryGrid;
    }
    if (this.observer) {
      this.observer.disconnect();
    }
  }
};
</script>

<style>
/*add タブレット操作時および小窓時にサイドコンテンツを表示するとレイアウトが崩れる #4041 shan start*/
/* body{
  min-width: 720px !important;
} */
/*add タブレット操作時および小窓時にサイドコンテンツを表示するとレイアウトが崩れる #4041 shan end*/
#app {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
}
/*add FNSI-redmine #4457 » 重要通知_文字サイズ特大 徐博 start*/
#app .vue-notification-group{
  width: 30em!important;
}
/*add FNSI-redmine #4457 » 重要通知_文字サイズ特大 徐博 end*/
/* add FNSI-redming #3831「通知トーストがユーザーフロートメニューに被っている」の不具合修正 江 start */
#notified-message{
  z-index: 9999 !important;
  /*mod FNSI-redmine #4482 » トースト_文字サイズ小 徐博 start*/
  /*padding-right: 6.8em;*/
  padding-right: 63.8px;
  /*mod FNSI-redmine #4482 » トースト_文字サイズ小 徐博 end*/
}
/* add FNSI-redming #3831「通知トーストがユーザーフロートメニューに被っている」の不具合修正 江 end */
</style>
