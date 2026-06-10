<template>
  <div id="app" :class="fontSizeSet">
    <!-- FNSI-redming #3831「通知トーストがユーザーフロートメニューに被っている」の不具合修正 江 start -->
    <!-- <notification-message/> -->
    <notification-message id="notified-message"/>
    <!-- FNSI-redming #3831「通知トーストがユーザーフロートメニューに被っている」の不具合修正 江 end -->
    <!--liyanze-z replace  :key="$route.fullPath"--->
    <!--施舍切替互換性がある v-if="showView"-->
    <router-view v-if="showView" />
    <iframe id = "consoleFrame" style="display: none;" src="devtools.html" ></iframe>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";

import { deleteAllStateDataItem } from "@/stores";
import NotificationMessage from "@/components/common/notification-message/NotificationMessageComponent";

/* add by chamaojia 2022-12-06 [5958] 定数ファイル参照の追加 --start */
import {LOCAL_STORAGE_KEY} from "@/constants/localStorageConstants";
import { persistStorePaths } from "@/constants/persistStorePaths";
import {SESSION_STORAGE_KEY} from "@/constants/sessionStorageConstants";
/* add by chamaojia 2022-12-06 [5958] 定数ファイル参照の追加 --end */
/* add by chamaojia 2023-04-26 [5958] 欠落した参照の補充  --start */
import { deleteSignin } from "@/functions/SigninFunction";
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
      showView:true,
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getTheme", "getFontSize"]),
    //liyanze-z 施舍切替互換性がある -- [getRefresh] start
    ...mapGetters("app", ["getUrl","getRefresh"]),
    //liyanze-z 施舍切替互換性がある -- [getRefresh] end
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

    //liyanze-z 施舍切替互換性がある  watch refresh
    getRefresh(val,old) {
      if(val.status == true){
        this.showView = false
        this.$nextTick(() => {
          setTimeout(() => {
            this.showView = true;
            //false
            let newObj = {
                status:false,
                date:val.date
            }
            this.refreshFunction(newObj)
          },20)
        })

      }
    },
    gethisData(newVal,oldVal){
      let params = {
        // srcPageName:oldVal,
        destPageName:newVal
      }
      if(oldVal){
        ApiHelper.put("/logs/event/pageRouterLog", params)
      }
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
    //liyanze-z 施舍切替互換性がある start
    ...mapActions("app", ["refreshFunction"]),
    //liyanze-z 施舍切替互換性がある end
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
    /* modify by yangzhaokai 2022-11-01 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */
    ...mapActions("account-edit", ["clearUserAccountInfo"]),
    ...mapActions("operation-viewer/machine", ["clearFacilityCd"]),
    /* add by chamaojia 2023-04-26 [5958] 欠落した参照の補充  --start */
    ...mapGetters("user", ["isSignIn", "isSignOut"]),
    /* add by chamaojia 2023-04-26 [5958] 欠落した参照の補充  --end */

    // Windowリサイズイベントハンドラ
    handleResizeWindow() {
      // Windowリサイズ時、幅をStoreに格納
      this.setSize({
        windowHeight: document.documentElement.clientHeight,
        windowWidth: document.documentElement.clientWidth
      });

      // Windowリサイズ時、パンくずリストを右に寄せる
      this.$nextTick(() => {
        document.querySelectorAll(".breadcrumb-content").forEach(e => {
          e.scrollLeft = 1000;
        });
      });
    },

    // cssファイル読み込み
    readCss() {
      let ntssCss = document.createElement("link");
      ntssCss.rel = "stylesheet";
      ntssCss.href = "./css/ntss.css";
      document.head.appendChild(ntssCss);
    },

    // 印刷用cssファイル読み込み
    readPrintCss() {
      let ntssCss = document.createElement("link");
      ntssCss.rel = "stylesheet";
      ntssCss.media = "print";
      ntssCss.href = "./css/ntss_print.css";
      document.head.appendChild(ntssCss);
    },

    // themeのcssファイル読み込み
    readThemeCss() {
      const names = ["ntss_variables_w", "ntss_variables_b"];
      let themeCss = document.createElement("link");
      themeCss.rel = "stylesheet";
      themeCss.href = "./css/" + names[this.getTheme] + ".css";
      document.head.appendChild(themeCss);
    },

    // fix 2026/03/26 kendoエディタ用カスタムCSSをグローバルに読み込む lcl start
    // kendoCustomStyle.css をアプリ全体で利用するために head に追加します。
    readKendoCustomCss() {
      let kendoCss = document.createElement("link");
      kendoCss.rel = "stylesheet";
      kendoCss.href = "./css/kendoCustomStyle.css";
      document.head.appendChild(kendoCss);
    },
    // fix 2026/03/26 kendoエディタ用カスタムCSSをグローバルに読み込む lcl end

    // 各input要素にreadonly属性を設定
    setInputReadOnly(elem, flag) {
      const isInput = elem.tagName === "INPUT";
      // #8791 患者イベントの時計アイコンが異常 林峻峰 start
      // const isInputTypeValid = ["date", "time", "number", "datetime-local"].includes(elem.type);
      const isInputTypeValid = ["date", "number", "datetime-local"].includes(elem.type);
      // #8791 患者イベントの時計アイコンが異常 林峻峰 end

      if (!isInput || !isInputTypeValid) return;

      const arrInput = [...document.getElementsByTagName("input")];
      const arrText = [...document.getElementsByTagName("textarea")];

      arrInput.map(item => (item.readOnly = item !== elem ? flag : false));
      arrText.map(item => (item.readOnly = flag));
    },

    handleKeyDown(ev) {
      this.setPressedKey(`${ev.keyCode}${ev.location || ""}`);
    },

    handleKeyUp(ev) {
      this.removePressedKey(`${ev.keyCode}${ev.location || ""}`);
    },

    /* modify by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --start */
    setWatchConsole() {
      const $this = this;
      setInterval(function() {
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
        let consoleStatus = window.consoleStatus;
        if ("on" == consoleStatus ) {
          sessionStorage.setItem("consoleStatus","on");
          $this.devToolsOpenCallback();
        } else {
          sessionStorage.setItem("consoleStatus","off");
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
        const strUrl = window.location.href.split(window.location.pathname);
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
          window.location.href = $this.getUrl;
          // パンくずリストをクリア
          $this.resetKeepHistory();
          // 施設コードをクリア
          $this.clearFacilityCd();
        }
      }
    },
    /* add by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト --end */

    observeAlertDialog() {
      const MutationObserver =
        window.MutationObserver ||
        window.WebKitMutationObserver ||
        window.MozMutationObserver;

      const options = {
        attributes: true,
        attributeFilter: ["style"],
        subtree: true,
        childList: true
      };

      /* 十字キーでボタンのフォーカスを移動する関数 */
      const moveFocus = (currentButton, direction) => {
        // .alert-dialog-footer内のすべてのボタンを取得し、配列に変換
        const buttons = Array.from(document.querySelectorAll('.alert-dialog-footer a'));
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

      /* ons-alert-dialog要素を処理する関数 */
      const handleAlertDialog = (alertDialog) => {
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
        const footer = alertDialog.querySelector(".alert-dialog-footer");
        // フッター内のボタン要素を取得
        const buttonFooter = footer.children;
        // 新しいボタン要素を作成
        const buttonFirst = document.createElement("a");
        buttonFirst.href = "#";
        const buttonSecond = document.createElement("a");
        buttonSecond.href = "#";
        const buttonLast = document.createElement("a");
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
          // attributesの変更をチェックし、対象がons-alert-dialogの場合
          if (mutation.type === 'attributes' && mutation.target.nodeName.toLowerCase() === "ons-alert-dialog") {
            handleAlertDialog(mutation.target);
          }
          // 子ノードの追加をチェック
          else if (mutation.type === 'childList') {
            mutation.addedNodes.forEach(node => {
              // 追加されたノードがons-alert-dialogの場合
              if (node.nodeName.toLowerCase() === "ons-alert-dialog") {
                handleAlertDialog(node);
              }
            });
          }
        });
      };

      this.observer = new MutationObserver(callback);
      this.observer.observe(document.body, options);
    },
    beforePrintSize(){
      //印刷前-kendo-grid表示のために一旦width値を書き換え
      this.setSize({
        windowHeight: document.documentElement.clientHeight,
        windowWidth: document.documentElement.clientWidth -1
      });
    },
    /* add by chamaojia 2022-12-06 リフレッシュイベントsessionStorageへのデータ持続化の追加 --start */
    beforeUnload() {
      if (this.$router.currentRoute.name === "signin") {
        // サインインしている状態でタブ若しくはブラウザが閉じられた場合
        this.$nextTick(() => {
          // サインインしている場合
          // ※サインアウトしないでタブやブラウザを閉じた場合がある.
          if (!this.isSignOut() && this.isSignIn()) {
            const signInCount = localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT) - 1;
            if (signInCount <= 0) {
              localStorage.removeItem(LOCAL_STORAGE_KEY.FACILITY_HASH);
              localStorage.removeItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
            } else {
              localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT, signInCount);
            }
          }
          this.$nextTick(() => {
            // unload イベントは発火しない為、beforeunload の後続処理で実行する
            deleteSignin();
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
      for (const storePath of persistStorePaths) {
        const storeNameArr = storePath.split(".");
        let value = this.$store.state;
        for (let i = 0; i < storeNameArr.length; i++) {
          value = value[storeNameArr[i]]
        }

        sessionStorage.setItem(storePath, JSON.stringify(value))
      }

      sessionStorage.setItem(SESSION_STORAGE_KEY.REFRESH_FLAG, "1")
    },
    /* add by chamaojia 2022-12-06 [5958] リフレッシュイベントsessionStorageへのデータ持続化の追加 --end */
  },
  created() {
    this.lockDevTool();
    // Windowリサイズ検知
    window.addEventListener("resize", this.handleResizeWindow, false);
    window.addEventListener("beforeprint", this.beforePrintSize, false);
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou start
    window.addEventListener("popstate", this.setPopstate, false);
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou end
    document.addEventListener("keydown", this.handleKeyDown);
    document.addEventListener("keyup", this.handleKeyUp);
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
    // 初期Windowサイズ(幅)設定
    this.$nextTick(() => {
      if (
        window.performance.navigation.type ===
        window.performance.navigation.TYPE_RELOAD
      ) {
        // リロード対策：DOM生成やCSSロードより後に高さの調整を遅延させる。
        this.setSize({
          windowHeight: document.documentElement.clientHeight - 100,
          windowWidth: document.documentElement.clientWidth
        });
      }
      setTimeout(() => {
        this.handleResizeWindow();
      }, 200);
    });

    // 入力フォカスアウト対策:onFocus時に編集対象以外の各input要素のreadonly属性をONにする
    window.addEventListener(
      "focus",
      e => {
        this.setInputReadOnly(e.target, true);
      },
      true
    );

    // 入力フォカスアウト対策:onBlur時に各input要素のreadonly属性をOFFにする
    window.addEventListener(
      "blur",
      e => {
        this.setInputReadOnly(e.target, false);
      },
      true
    );
    /* add by chamaojia 2022-12-06 LoginView.vueから移行されたイベントリスナーの追加 --start */
    // window.addEventListener("beforeunload", this.beforeUnload);
    /* add by chamaojia 2022-12-06 LoginView.vueから移行されたイベントリスナーの追加 --end */
    /* fix #10961 by lcl 2026-2-14  --start */
    window.addEventListener("pagehide", this.beforeUnload, false);
    /* fix #10961 by lcl 2026-2-14  --end */

    this.observeAlertDialog();
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
    window.addEventListener('keydown', this.keydownHandler);
    // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
  },
  // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
  beforeDestroy() {
    window.removeEventListener('keydown', this.keydownHandler);
  },
  // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
  destroyed() {
    window.removeEventListener("resize", this.handleResizeWindow, false);
    window.removeEventListener("beforeprint", this.beforePrintSize, false);
    /* fix #10961 by lcl 2026-2-14  --start */
    try {
      window.removeEventListener("pagehide", this.beforeUnload, false);
    } catch (e) {
      // ignore
    }
    /* fix #10961 by lcl 2026-2-14  --end */
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou start
    window.removeEventListener('popstate', this.setPopstate, false);
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou end
    document.removeEventListener("keydown", this.handleKeyDown);
    document.removeEventListener("keyup", this.handleKeyUp);
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
