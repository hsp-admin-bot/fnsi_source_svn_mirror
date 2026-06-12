/**
 * Rootページ（親コンポーネント）
 */
<template>
  <div ref='layoutRoot' class='route-view-frame-style'>
    <patient-search-sidebar ref='patientSearchSidebar' id='patientSearchSidebarArea' class='sidebar-transition' :style='sidebarWidth' v-show='getStateUserAccountInfo?.patId === null && isDispSidebarBtn'/>
    <!-- 患者検索サイドバー表示ボタン -->
    <!-- mod FNSI-画面部品デザイン じょはく start-->
    <!-- <div id="showPatientSearchSidebarBtn" class='sidebar-transition sidebar-show-button' :style='showSidebarButtonLeft' @click='switchSidebar' v-show='getStateUserAccountInfo?.patId === null && isDispSidebarBtn && !isReMS'></div>-->
    <!--mod  4658 サイドコンテンツエリア表示状態で体重測定に遷移すると、サイドコンテンツ展開用の◀の表示が現在と逆転する 吉 start-->
    <!--<div id="showPatientSearchSidebarBtn" class='sidebar-transition sidebar-show-button' :style='showSidebarButtonLeft' @click='switchSidebar' v-show='getStateUserAccountInfo?.patId === null && isDispSidebarBtn && !isReMS'>-->
    <div ref="sidebarToggleButton" id="showPatientSearchSidebarBtn" class='sidebar-transition sidebar-show-button' :style="[showSidebarButtonLeft,{'background-color': this.colorCode ? this.colorCode : '#404040'}]" @click='switchSidebar' v-if='getStateUserAccountInfo?.patId === null && isDispSidebarBtn && !isReMS'>
      <!--mod  4658 サイドコンテンツエリア表示状態で体重測定に遷移すると、サイドコンテンツ展開用の◀の表示が現在と逆転する 吉 end-->
      <span :class="sidebarToggleArrowClass">{{ sidebarToggleArrowText }}</span>
    </div>
    <!-- mod FNSI-画面部品デザイン じょはく end-->
    <router-view :style='routerViewWidth'/>
    <fab-component v-show='getStateUserAccountInfo?.patId === null'/>
    <loading-screen />
    <ntss-footer-menu ref='footerMenu' id='footer-menu' v-show='isShowFooter' />
    <multi-modal-view />
    <multi-sub-modal-view />
  </div>
</template>

<script>
import { router } from "@/compat/vue/router-facade.js";
import store from "@/stores";
import FabComponent from "@/components/FabComponent";
import PatientSearchSidebar from "@/components/common/PatientSearchSidebar";
import loadingScreen from "@/components/common/LoadingScreen";
import FooterMenu from "@/components/FooterMenuComponent";
import MultiModal from "@/components/modals/MultiModal";
import MultiSubModal from "@/components/modals/MultiSubModal";
import { TITLE } from "@/constants/sysUseConstants";
import { LOCAL_STORAGE_KEY } from "@/constants/localStorageConstants";
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
import { updateFavicons } from "@/functions/SigninFunction";
import { SESSION_STORAGE_KEY } from "@/constants/sessionStorageConstants";
import { getHeaderElements, getViewportHeight, getViewportWidth,
  getScopedWindow} from "@/functions/common/LayoutMeasureHelper";
import axios from "@/compat/http/axios";

const SESSION_TIMEOUT_CHECK_INTERVAL = 15000;

export default {
  components: {
    "fab-component": FabComponent,
    "patient-search-sidebar": PatientSearchSidebar,
    "loading-screen": loadingScreen,
    "ntss-footer-menu": FooterMenu,
    "multi-modal-view": MultiModal,
    "multi-sub-modal-view": MultiSubModal
  },
  provide() {
    return {
      getNtssLayoutRootElement: () => this.getLayoutRootElement(),
      getNtssFooterMenuElement: () => this.getFooterMenuElement()
    };
  },
  data() {
    return {
      // サイドバー横幅
      sidebarBasicWidth: 300,
      // サイドバーの表示状態
      showSidebarFlg: false,

      isSidebarHiddenOnPrintStart: false,

      initLoad3: null,
      initLoad8: null,
      initLoad15: null,
      // add 8074 隠しボタンを押してもイベントが出てこないことを傍受していないlogインタフェースが出てこない 付 start
      observer: null,
      // add 8074 隠しボタンを押してもイベントが出てこないことを傍受していないlogインタフェースが出てこない 付 end
      //背景色のカラーコード
      colorCode: "",
      // ヘッダー余白再計算の予約ID
      leftmostHeaderMarginRafId: null

    };
  },
  computed: {
    ...mapGetters("facility-calendar", ["viewMode"]),
    ...mapGetters("account-edit", ["isDispMenu", "getStateUserAccountInfo", "getFontSize","getTheme"]),
    ...mapGetters("account-edit", {isDispSidebarBtn : "getIsDispSidebarBtn"}),
    ...mapGetters("window-size", {
      splittableFrames: "getSplittableFrames"
    }),
    ...mapGetters("user", {
      systemUseSetting: "getSystemUseSetting"
    }),
    ...mapGetters("send-condition/weight", ["getWeightMode"]),
    ...mapGetters("app", ["getKey"]),
    // サイドバーの表示状態に応じて幅を調整
    sidebarWidth() {
      if (this.showSidebarFlg) {
        return { "width": this.sidebarBasicWidth + "px"};
      } else {
        return { "width": this.sidebarBasicWidth + "px", "position": "absolute", "transform": "translateX(-" + this.sidebarBasicWidth + "px)"};
      }
    },
     // ReMSの表示有無を返す
    isReMS() {
      return this.systemUseSetting === "1";
    },
    routerViewWidth() {
      if (this.showSidebarFlg) {
        return { "width": "calc(100% - " + this.sidebarBasicWidth + "px)" };
      } else {
        return { "width": "100%" };
      }
    },
    showSidebarButtonLeft() {
      if (this.showSidebarFlg) {
        return { "left": "calc(" + this.sidebarBasicWidth + "px - 2em)" };
      } else {
        return { "left": "calc(0px - 2em)" };
      }
    },
    // 画面遷移捕捉用
    changeRoutePath() {
      return this.$route.path;
    },
     // test
    isShowFooter() {
      // 体重計モード時にフッター表示しない
      if (this.getWeightMode.isWeightMode) {
        return false;
      }
      return this.isDispMenu === 1;
    },
    sidebarToggleArrowText() {
      return this.showSidebarFlg ? "◀" : "▶";
    },
    sidebarToggleArrowClass() {
      return this.showSidebarFlg ? "arrow-click" : "arrow";
    }
  },
  watch: {
    splittableFrames() {
      this.$nextTick(() => {
        this.addLeftmostHeaderMargin();
      });
    },
    changeRoutePath() {
      this.$nextTick(() => {

        this.addLeftmostHeaderMargin();
        // mod 8074 隠しボタンを押してもイベントが出てこないことを傍受していないlogインタフェースが出てこない 付 start
        //FNSI-修正 ログ対応 xiebzh add start
        // this.initLoad3 = setTimeout(() => {
        //   this.initLoad();
        // }, 2000)

        // this.initLoad8 = setTimeout(() => {
        //   this.clearInit();
        //   this.initLoad();
        // }, 8000)

        // this.initLoad15 = setTimeout(() => {
        //   this.clearInit();
        //   this.initLoad();
        // }, 15000)

        // this.initLoad();
        //FNSI-修正 ログ対応 xiebzh add end
        // mod 8074 隠しボタンを押してもイベントが出てこないことを傍受していないlogインタフェースが出てこない 付 end
      });
    },
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
    showSidebarFlg(val) {
      this.setShowSidebarFlg(val);
    }
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
  },
  methods: {
    getLayoutRootElement() {
      return this.$refs.layoutRoot || this.$el || null;
    },
    getFooterMenuElement() {
      return this.$refs.footerMenu?.$el || this.$refs.footerMenu || null;
    },
    getSidebarToggleButtonElement() {
      return this.$refs.sidebarToggleButton || this.$el?.querySelector?.("#showPatientSearchSidebarBtn") || null;
    },
    getSidebarElement() {
      return this.$refs.patientSearchSidebar?.$el || this.$refs.patientSearchSidebar || null;
    },
    getViewDocument() {
      return this.getLayoutRootElement()?.ownerDocument || document;
    },
    getViewWindow() {
      return this.getViewDocument()?.defaultView || getScopedWindow(this.getLayoutRootElement() || this.$el || this);
    },
    getViewDocumentElement() {
      return this.getViewDocument()?.documentElement || null;
    },
    getViewBodyElement() {
      return this.getViewDocument()?.body || null;
    },
    getViewportSize() {
      return {
        windowHeight: getViewportHeight(),
        windowWidth: getViewportWidth()
      };
    },
    queryLayout(selector, root = this.getLayoutRootElement()) {
      return root?.querySelector?.(selector) || null;
    },
    queryLayoutAll(selector, root = this.getLayoutRootElement()) {
      return Array.from(root?.querySelectorAll?.(selector) || []);
    },
    getConditionSearchAreas() {
      return this.queryLayoutAll('.condition-search-area, .condition-search-icon-area, .condition-items-area');
    },
    getBreadcrumbArea() {
      return this.queryLayout('#BreadCrumbsComponent_breadcrumb_content_area');
    },
    getScopedModalContainers(root = this.getLayoutRootElement()) {
      return getScopedPortalElements(root, '.modal-container, .modal-container-custom');
    },
    getScopedPopoverElements(root = this.getLayoutRootElement()) {
      return getScopedPortalElements(root, 'ons-popover');
    },
    scrollBreadcrumbsToEnd() {
      this.queryLayoutAll('.breadcrumb-content').forEach((element) => {
        element.scrollLeft = 1000;
      });
    },
    // mod #9606 2023/08/30 ログイン時setFacilitySwitchを設定する 朴 start
    ...mapActions("master-maintenance", ["setFacilitySwitch"]),
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
    ...mapActions("account-edit", ["setIsDispSidebarBtn"]),
    ...mapMutations("account-edit", ["setShowSidebarFlg"]),
    // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end
    // mod #9606 2023/08/30 ログイン時setFacilitySwitchを設定する 朴 end
    // add 8074 隠しボタンを押してもイベントが出てこないことを傍受していないlogインタフェースが出てこない 付 start
    handleClick (e) {
      if (["BUTTON", "ONS-BUTTON", "A", "ONS-TOOLBAR-BUTTON"].includes(e.target.tagName)) {
        let subPageName = '';
        this.getScopedModalContainers(e?.target || this.getLayoutRootElement()).forEach(modalElement => {
          modalElement.querySelectorAll("ONS-BUTTON, BUTTON, A, ONS-TOOLBAR-BUTTON").forEach(element => {
            if (element == e.target) {
              modalElement.querySelectorAll('div').forEach(subDiv => {
                if (subDiv.classList.contains('toolbar__title') && subDiv.classList.contains('toolbar__left')) {
                  // #9863 Cannot read properties of null (reading 'innerText') 横展開2 linjunfeng start
                  // subPageName = subDiv.querySelector('span').innerText;
                  subPageName = subDiv.querySelector('span') ? subDiv.querySelector('span').innerText : "";
                  // #9863 Cannot read properties of null (reading 'innerText') 横展開2 linjunfeng end
                }
              });
            }
          });
        });
        const functionName = getPageName(e?.target || this.getLayoutRootElement());
        const pageName = subPageName === '' ? functionName : functionName + "の" + subPageName;
        var btnName = e.target.innerText;
        // add 8074 画像はbuttonタグに包まれボタンはありません 関 start
        if (!btnName && e.target.alt && e.target.alt.includes('icon')) {
          btnName = e.target.alt.substring(0, e.target.alt.lastIndexOf('icon')).replace(/\s/g,"");
        }
        // add 8074 画像はbuttonタグに包まれボタンはありません 関  end
        //FNSI-修正 8164 ljx mod start
        let selectedPatId = store.getters["pat-info/selectedPatId"];
        let param = {'pageName':pageName, 'btnName':btnName,'patId':selectedPatId, 'functionName':functionName};
        //FNSI-修正 8164 ljx mod end
        ApiHelper.put("/logs/event/accesslog", param)
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('RootView.vue', 'btnEvent', error);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        });
        return
      }
      return
    },
    // add 8074 隠しボタンを押してもイベントが出てこないことを傍受していないlogインタフェースが出てこない 付 end
    ...mapActions("window-size", ["setSize"]),
    ...mapActions("account-edit", ["setFontSize","setTheme"]),
    changeFontSizeMid() {
      this.tmpFontSize = this.getFontSize;
      // フォントサイズを中にする
      this.setFontSize(1);
    },
    restoreFontSize() {
      // フォントサイズを元に戻す
      this.setFontSize(this.tmpFontSize);
    },
    changeThemeWhite() {
      this.tmpTheme = this.getTheme;
      // テーマを白にする
      this.setTheme(0);
    },
    restoreTheme() {
      // テーマをを元に戻す
      this.setTheme(this.tmpTheme);
    },
    switchSidebar() {
      if (this.showSidebarFlg) {
        this.showSidebarFlg = false;
      } else {
        this.showSidebarFlg = true;
      }
      // サイドバーの開閉時、画面のリサイズを発火させる (App.vueでwindowsサイズ変更に割り当てられている処理)
      this.$nextTick(() => {
        this.setSize(this.getViewportSize());
        // リサイズ時、パンくずリストを右に寄せる
        this.$nextTick(() => {
          this.scrollBreadcrumbsToEnd();
          EventBus.$emit("switchSidebar");
        });
      });
      let fontSize = this.getFontSize;
      this.setFontSize(null);
      this.setFontSize(fontSize);

      // フッターを閉じる
      EventBus.$emit("closeFooterList");
      // del #9717 施設カレンダーでサイドコンテンツの開閉の際に読み込みが走り表示に時間がかかる linjunfeng start
      // if (
      //   this.$route.name === "facility-calendar" &&
      //   (this.viewMode === 1 || this.viewMode === 2)
      // ) {
      //   EventBus.$emit("updateViewCalendar", this.viewMode);
      // }
      // del #9717 施設カレンダーでサイドコンテンツの開閉の際に読み込みが走り表示に時間がかかる linjunfeng end
    },
    // 画面遷移時に画面幅に応じてサイドバーを閉じる
    sidebarCloseByWidth() {
      if (this.showSidebarFlg) {
        // min-widh が設定されている .content-box が存在しない場合がある為、初期値を設定
        let contentBoxWidth = 200;
        const contentBox = this.getLayoutRootElement()?.querySelector?.('.content-box') || null;
        if (contentBox != null) {
          //.content-box の min-widh を取得
          contentBoxWidth = Number((contentBox.ownerDocument?.defaultView || this.$el?.ownerDocument?.defaultView || window).getComputedStyle(contentBox).minWidth.replace('px',''));
        }
        // サイドバーの横幅 を取得
        const sideBarWidth = this.getSidebarElement()?.offsetWidth || 0;
        if (getViewportWidth() < (contentBoxWidth + sideBarWidth) ) {
          this.switchSidebar();
        }
      }
    },
    // ヘッダーが最左にある場合、サイドバーボタン用のマージンを付与
    addLeftmostHeaderMargin() {
      const scopedWindow = this.getViewDocument()?.defaultView || window;
      if (this.leftmostHeaderMarginRafId) {
        scopedWindow.cancelAnimationFrame?.(this.leftmostHeaderMarginRafId);
      }
      this.leftmostHeaderMarginRafId = scopedWindow.requestAnimationFrame?.(() => {
        this.leftmostHeaderMarginRafId = null;

        const root = this.getLayoutRootElement() || this.getViewBodyElement() || null;
        const sidebarBtn = this.getSidebarToggleButtonElement();
        let btnRightPoint = sidebarBtn ? sidebarBtn.clientWidth / 2 : 0;
        if (this.showSidebarFlg) {
          btnRightPoint += this.sidebarBasicWidth;
        }

        const objList = getHeaderElements(root);
        const removeClassList = Array.from(root?.querySelectorAll?.('.leftmost-header') || []);
        removeClassList.forEach(el => el.classList.remove("leftmost-header"));

        const targets = objList
          .map(obj => ({
            obj,
            marker: obj.getElementsByClassName("mark-leftmost-header")[0],
            left: obj.getBoundingClientRect().left
          }))
          .filter(item => item.marker);

        targets.forEach(({ marker, left }) => {
          if (btnRightPoint > left) {
            marker.classList.add("leftmost-header");
          }
        });
      }) || null;
    },
    forceCloseSideBar() {
      this.showSidebarFlg = false;
      this.$nextTick(() => {
        this.setSize(this.getViewportSize());
        // リサイズ時、パンくずリストを右に寄せる
        this.$nextTick(() => {
          this.scrollBreadcrumbsToEnd();
        });
      });
    },

    printStart() {
      this.changeFontSizeMid();
      this.changeThemeWhite();
      if (this.showSidebarFlg) {
        this.isSidebarHiddenOnPrintStart = true;
        this.switchSidebar();
      }
    },
    printEnd() {
      this.restoreFontSize();
      this.restoreTheme();
      if (this.isSidebarHiddenOnPrintStart) {
        this.switchSidebar();
        this.isSidebarHiddenOnPrintStart = false;
      }
    },

    //FNSI-修正 ログ対応 xiebzh add start
    initLoad() {
       try {
         // ボタンのクリックイベントを追加
         this.queryLayoutAll("ONS-BUTTON, BUTTON").forEach(buttonObj => {
           if (isPC()) {
                // PC側
                buttonObj.onmouseup = function(e) {
                  btnEvent(e);
                  buttonObj.onmouseup = null;
               };
            } else {
                // スマート設備
                buttonObj.ontouchend = function(e) {
                  btnEvent(e);
                  buttonObj.ontouchend = null;
                };
            }
         });

        let searchAreas = this.getConditionSearchAreas();
        searchAreas.forEach(element => {
            //element.removeEventListener("click", popoverHandle, false);
            element.addEventListener("click", popoverHandle, false);
        });
        searchAreas = null;
      } catch (error) {
        //this.clearInit();
        console.log(error);
      }
    },

    getPageNameBySubPage() {
        const linkDivObj = this.getBreadcrumbArea();
        if (linkDivObj) {
            var links = linkDivObj.getElementsByTagName('a');
            if (links) {
               for (var i = 0; i < links.length; i++) {
                  if (i == links.length - 1) {
                    //links = null;
                    return links[i].text;
                  }
               }
            }
        }
        return '';
    },
    //FNSI-修正 ログ対応 xiebzh add end

    // 他のタブでサインアウトしたら追従してサインアウトする
    autoSignOut(e) {
      // localStorageの特定のkeyが変更されたら発火する
      if (e.key === LOCAL_STORAGE_KEY.SIGN_OUT_TRIGGER) {
        store.dispatch("user/clearSignIn");
        store.dispatch("account-edit/clearUserAccountInfo");
        store.dispatch("account-edit/setTheme", 0);
        store.dispatch("bread-crumb/resetKeepHistory");
        router.push({ name: "signin", query: this.getKey ? { key: this.getKey } : {} });
      }
    },

    startSessionTimeoutCheck() {
      if (this.sessionTimeoutCheckProc !== null) {
        return;
      }
      this.checkSessionTimeout();
      this.sessionTimeoutCheckProc = window.setInterval(() => {
        this.checkSessionTimeout();
      }, SESSION_TIMEOUT_CHECK_INTERVAL);
    },

    stopSessionTimeoutCheck() {
      if (this.sessionTimeoutCheckProc !== null) {
        clearInterval(this.sessionTimeoutCheckProc);
        this.sessionTimeoutCheckProc = null;
      }
    },

    async checkSessionTimeout() {
      if (this.sessionTimeoutChecking || store.getters["user/isSignOut"]) {
        return;
      }
      this.sessionTimeoutChecking = true;
      try {
        const response = await axios.get("/ntss-admin-web/api/sign-in/check/sessiontimeout?__background_call__=true");
        if (!response.data) {
          this.handleSessionTimeoutForceSignOut();
        }
      } catch (error) {
        const status = error && error.response ? error.response.status : null;
        if (status === 401 || status === 403) {
          this.handleSessionTimeoutForceSignOut();
        }
      } finally {
        this.sessionTimeoutChecking = false;
      }
    },

    handleSessionTimeoutForceSignOut() {
      if (store.getters["user/isSignOut"]) {
        return;
      }
      this.stopSessionTimeoutCheck();
      store.dispatch("app/setApiResult", {
        status: 401,
        message: "以下のいずれかの理由によりサインアウトしました。<br>" +
          "・設定時間操作がないことによるタイムアウト<br>" +
          "・複数端末同時サインイン制限<br>" +
          "・サインイン連続失敗によるアカウントロック<br>" +
          "・アカウントの権限変更<br>" +
          "・アカウント削除"
      });
      localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT, 0);
      localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_OUT_TRIGGER, new Date());
      store.dispatch("user/signOutForAuthFailed");
    },

    clearInit() {
      const searchAreas = this.getConditionSearchAreas();
       searchAreas.forEach(element => {
         element.removeEventListener("click", popoverHandle, false);
       });

       this.getScopedPopoverElements().forEach(element => {
         element.querySelectorAll('div').forEach(elementDiv => {
           if (elementDiv.classList.contains("popover__content")) {
             elementDiv.divParam = elementDiv;
             elementDiv.removeEventListener("keypress", btnHandle, false);
             elementDiv.querySelectorAll("ONS-BUTTON, BUTTON").forEach(elementBtn => {
                 let btnText = elementBtn.innerText === '' ? elementBtn.textContent : elementBtn.innerText;
                 if (btnText === 'OK' || btnText === '検索') {
                   elementBtn.removeEventListener("click", btnHandle, false);
                 }
             });
           }
         });
       });
      if (this.initLoad3 !== null) {
        clearTimeout(this.initLoad3);
        this.initLoad3 = null;
      }

      if (this.initLoad8 !== null) {
        clearTimeout(this.initLoad8);
        this.initLoad8 = null;
      }

      if (this.initLoad15 !== null) {
        clearTimeout(this.initLoad15);
        this.initLoad15 = null;
      }

    }
  },
  created() {
    this.getViewWindow().addEventListener('storage', this.autoSignOut);
    const viewDocument = this.getViewDocument();
    // 画面タイトル(サインイン後初回設定用)
    if (viewDocument) {
      viewDocument.title = TITLE[this.systemUseSetting != null ? this.systemUseSetting : 0];
    }
    // favicon設定
    updateFavicons(this.systemUseSetting != null ? this.systemUseSetting : 0);
    // 他の画面のヘッダーの mounted() 時に実行する
    EventBus.$on("addLeftmostHeaderMargin", this.addLeftmostHeaderMargin);
    // 画面遷移時に画面幅に応じてサイドバーを閉じる
    EventBus.$on("sidebarCloseByWidth", this.sidebarCloseByWidth);
    EventBus.$on("forceCloseSideBar", this.forceCloseSideBar);
    EventBus.$on("print-start", this.printStart);
    EventBus.$on("print-end", this.printEnd);
    // add 8074 隠しボタンを押してもイベントが出てこないことを傍受していないlogインタフェースが出てこない 付 start
    this.getViewBodyElement()?.addEventListener('click', this.handleClick)
    // const targetNode = document.querySelector('body');
    // const config = { attributes: true, childList: true, subtree: true };
    // const callback = (mutationRecords, observer) => {
    //   mutationRecords.forEach(mutationRecord => {
    //     if(mutationRecord.type === 'childList') {
    //       if (Object.values(mutationRecord.target.classList).indexOf('pika-single') == -1) {
    //         this.clearInit();
    //         this.initLoad();
    //       }
    //     }
    //   })
    // }
    // this.observer = new MutationObserver(callback);
    // this.observer.observe(targetNode, config);
    // add 8074 隠しボタンを押してもイベントが出てこないことを傍受していないlogインタフェースが出てこない 付 end
    // add #9606 2023/08/30 ログイン時setFacilitySwitchを設定する 朴 start
    this.setFacilitySwitch(this.getStateUserAccountInfo.facilityCd);
    // add #9606 2023/08/30 ログイン時setFacilitySwitchを設定する 朴 end
    //背景色のカラーコード取得
    this.colorCode = sessionStorage.getItem(SESSION_STORAGE_KEY.BACKGROUND_COLOR_CODE);
    this.startSessionTimeoutCheck();
  },
  beforeUnmount() {
    // add 8074 隠しボタンを押してもイベントが出てこないことを傍受していないlogインタフェースが出てこない 付 start
    this.observer && this.observer.disconnect();
    if (this.leftmostHeaderMarginRafId) {
      (this.getViewDocument()?.defaultView || window).cancelAnimationFrame?.(this.leftmostHeaderMarginRafId);
      this.leftmostHeaderMarginRafId = null;
    }
    // add 8074 隠しボタンを押してもイベントが出てこないことを傍受していないlogインタフェースが出てこない 付 end
    this.getViewWindow().removeEventListener("storage", this.autoSignOut);
    this.getViewBodyElement()?.removeEventListener('click', this.handleClick);
    EventBus.$off("addLeftmostHeaderMargin", this.addLeftmostHeaderMargin);
    EventBus.$off("sidebarCloseByWidth", this.sidebarCloseByWidth);
    EventBus.$off("forceCloseSideBar", this.forceCloseSideBar);
    EventBus.$off("print-start", this.printStart);
    EventBus.$off("print-end", this.printEnd);
    // ログアウト時にサイドバーが開いていたら閉じておく
    if (this.showSidebarFlg) {
      this.switchSidebar();
    }

    this.stopSessionTimeoutCheck();
    this.clearInit();
  }
};

//FNSI-修正 ログ対応 xiebzh add start
function collectScopedTargets(...candidates) {
  const result = [];
  candidates.flat(Infinity).forEach((candidate) => {
    if (candidate && !result.includes(candidate)) {
      result.push(candidate);
    }
  });
  return result;
}

function escapeScopedId(id) {
  if (!id) {
    return null;
  }
  try {
    if (typeof CSS !== 'undefined' && typeof CSS.escape === 'function') {
      return CSS.escape(id);
    }
  } catch (_error) {
    return null;
  }
  return null;
}

// パンくずリストによって、画面の日本語名を取得する
function getLayoutScope(root = null) {
    const scopeRoot = root?.$el || root || null;
    const scopeDocument = scopeRoot?.ownerDocument || (typeof document !== 'undefined' ? document : null);
    const scopeBody = scopeDocument?.body || null;
    return scopeRoot?.closest?.('.route-view-frame-style')
      || (scopeRoot?.matches?.('.route-view-frame-style') ? scopeRoot : null)
      || Array.from(scopeBody?.children || []).find((element) => element?.matches?.('.route-view-frame-style'))
      || scopeBody?.querySelector?.('.route-view-frame-style')
      || scopeRoot
      || scopeBody
      || null;
}

function getScopedPortalElements(root = null, selector = '') {
    if (!selector) {
      return [];
    }
    const layoutScope = getLayoutScope(root);
    const scopeBody = layoutScope?.ownerDocument?.body || null;
    const result = [];
    collectScopedTargets(layoutScope).forEach((target) => {
      Array.from(target?.querySelectorAll?.(selector) || []).forEach((element) => {
        if (!result.includes(element)) {
          result.push(element);
        }
      });
    });
    Array.from(scopeBody?.children || []).forEach((element) => {
      if (element?.matches?.(selector) && !result.includes(element)) {
        result.push(element);
      }
    });
    return result;
}


function queryScopedPortalElements(root = null, selector = '') {
    return getScopedPortalElements(root, selector);
}

function queryScopedElementById(root = null, id = '') {
    if (!id) {
      return null;
    }
    const escapedId = escapeScopedId(id);
    const localScope = root?.closest?.('.popover__content, .modal-container, .modal-container-custom, ons-popover, ons-dialog, ons-alert-dialog') || null;
    const scopeBody = root?.ownerDocument?.body || null;
    const roots = collectScopedTargets(root, localScope, getLayoutScope(root), scopeBody);
    for (const target of roots) {
      if (!target) {
        continue;
      }
      if (typeof target.getElementById === 'function') {
        const byId = target.getElementById(id);
        if (byId) {
          return byId;
        }
      }
      const bySelector = (escapedId && target.querySelector?.(`#${escapedId}`))
        || target.querySelector?.(`[id="${id}"]`)
        || null;
      if (bySelector) {
        return bySelector;
      }
    }
    return null;
}

function getPageName(root = null) {
    const layoutScope = getLayoutScope(root);
    var linkDivObj = layoutScope?.querySelector?.('#BreadCrumbsComponent_breadcrumb_content_area') || null;
    if (linkDivObj) {
        var links = linkDivObj.getElementsByTagName('a');
        if (links) {
           for (var i = 0; i < links.length; i++) {
              if (i == links.length - 1) {
                //links = null;
                return links[i].text;
              }
           }
        }
    }
    return '';
}

// 端末判別
function isPC() {
   var userAgentInfo = navigator.userAgent;
   var Agents = ["Android", "iPhone",
      "SymbianOS", "Windows Phone",
      "iPad", "iPod"];
   var flag = true;
   for (var v = 0; v < Agents.length; v++) {
      if (userAgentInfo.indexOf(Agents[v]) > 0) {
         flag = false;
         break;
      }
   }
   return flag;
}

function btnEvent(e) {
  const scopeRoot = e?.target || null;
  var subPageName = '';
  //var parentDivParam = e.target.closest("div");
  getScopedPortalElements(scopeRoot, '.modal-container, .modal-container-custom').forEach(modalElement => {
    modalElement.querySelectorAll("ONS-BUTTON, BUTTON, A, ONS-TOOLBAR-BUTTON").forEach(element => {
      if (element == e.target) {
        modalElement.querySelectorAll('div').forEach(subDiv => {
          if (subDiv.classList.contains('toolbar__title') && subDiv.classList.contains('toolbar__left')) {
            subPageName = subDiv.querySelector('span') ? subDiv.querySelector('span').innerText : "";
          }
        });
      }
    });
  });
  var pageName;
  var functionName;
  if (subPageName === '') {
    pageName = getPageName(scopeRoot);
  } else {
    pageName = getPageName(scopeRoot) + "の" + subPageName;
  }
  functionName = getPageName(scopeRoot);
  var btnName = e.target.innerText;
  // add 8074 画像はbuttonタグに包まれボタンはありません 関 start
  if (!btnName && e.target.alt && e.target.alt.includes('icon')) {
    btnName = e.target.alt.substring(0, e.target.alt.lastIndexOf('icon')).replace(/\s/g,"");
  }
  // add 8074 画像はbuttonタグに包まれボタンはありません 関  end
  //FNSI-修正 8164 ljx mod start
  let selectedPatId = store.getters["pat-info/selectedPatId"];
  let param = {'pageName':pageName, 'btnName':btnName,'patId':selectedPatId, 'functionName':functionName};
  //FNSI-修正 8164 ljx mod end
  ApiHelper.put("/logs/event/accesslog", param)
  .catch(error => {
     //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
     getErrorMessage('RootView.vue', 'btnEvent', error);
     //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
  });
}

var popoverHandle = function (event) {
    popoverClick(event?.currentTarget || event?.target || null);
}

function btnHandle(e) {
    if (e?.type === 'keypress') {
      if(e.keyCode == 13) {
        if (e.target.tagName === 'INPUT' && e.target.type === 'text') {
          var parentDivParam = e.target.closest('div');
          for (var i = 0; i < 20 && parentDivParam; i++) {
            if (parentDivParam.classList.contains('condition-search-area') || parentDivParam.classList.contains('condition-search-icon-area')) {
              break;
            } else {
              parentDivParam = parentDivParam.closest('div');
            }
          }
          if (parentDivParam) {
            btnClick(parentDivParam);
          }
        }
      }
    } else if (e?.target?.divParam) {
      btnClick(e.target.divParam);
    }
}

function btnClick(obj) {
    if (!obj) {
      return;
    }
    // マスタ一覧が555で検索しました。
    var conditionMessage = '';
    var elements = obj.getElementsByTagName('*');
    var elementIdx;
    for (elementIdx in elements) {
      var item = elements[elementIdx];
      if (item && item.style && item.style.display === 'none' && item.tagName != 'SELECT') {
        continue;
      }

      switch (item.tagName) {
        case 'SPAN':
          if (item.classList.contains("k-input")) {
            conditionMessage += item.innerText + '、';
          }
          break;
        case 'ONS-INPUT':
          if (item && item.value != '') {
            conditionMessage += item.value + '、';
          }
          break;
        case 'SELECT':
          var selectValue = '';
          for (var sIdx = 0; sIdx < item.options.length; sIdx++) {
            if(item.options[sIdx].selected) {
              selectValue += " " + item.options[sIdx].text
            }
          }
          if (selectValue != '')
            conditionMessage += selectValue + '、';
          break;
        case 'LABEL':
          var forValue = item.getAttribute("for");
          if (forValue) {
            var checkValue = queryScopedElementById(obj, forValue);
            if (checkValue && checkValue.checked) {
                conditionMessage += item.innerText + '、';
            }
          }
          break;
        case 'ONS-RADIO':
          var rObj = item.getElementsByTagName('input')[0];
          var parentObj = item.parentNode;
          var lObj = parentObj.getElementsByTagName('label')[0];
          if (rObj && rObj.checked && lObj) {
            conditionMessage += lObj.innerText + '、';
          }

          break;

        case 'INPUT':
          if (item.type === 'checkbox' && item.checked) {
            var rowObj = item.closest('ONS-ROW');
            if (rowObj) {
              var colRow = rowObj.querySelector('.ons-col');
              var labelObj = colRow.getElementsByTagName('label')[0];
              if (labelObj) {
                conditionMessage += labelObj.innerText + '、';
              }
            }
            break;
          }

          if (item.type != 'text' && item.type != 'date') {
            break;
          }

          if (item.parentNode.tagName != 'ONS-INPUT') {
            if (item.value != '')
              conditionMessage += item.value + '、';
          }

          break;
        default:
          break;
      }

    }

    if (conditionMessage != '') {
      if (conditionMessage.charAt(conditionMessage.length - 1) === "、") {
        conditionMessage = conditionMessage.substr(0,conditionMessage.length-1);
      }

      var msg = getPageName(obj) + "が[" + conditionMessage + "]で検索しました。";
      let paramObj = {'message': msg, 'functionName': getPageName(obj)};
      ApiHelper.put("/logs/event/conditionlog", paramObj)
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('RootView.vue', 'btnClick', error);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        });
    }

}

function popoverClick(root = null) {
  getScopedPortalElements(root, "ons-popover").forEach(element => {
        element.querySelectorAll('div').forEach(elementDiv => {
          if (elementDiv.classList.contains("popover__content") && elementDiv.classList.contains("popover--top__content")) {
            elementDiv.divParam = elementDiv;
            //elementDiv.removeEventListener("keypress", btnHandle, false);
            elementDiv.addEventListener("keypress", btnHandle, false);
            elementDiv.querySelectorAll("ONS-BUTTON, BUTTON").forEach(elementBtn => {
                let btnText = elementBtn.innerText === '' ? elementBtn.textContent : elementBtn.innerText;
                if (btnText.trim() === 'OK' || btnText.trim() === '検索') {
                  elementBtn.divParam = elementDiv;
                    //element.removeEventListener("click", btnHandle, false);
                  elementBtn.addEventListener("click", btnHandle, false);
                }
            });
          }
        });
      });
}


//FNSI-修正 ログ対応 xiebzh add end
</script>
