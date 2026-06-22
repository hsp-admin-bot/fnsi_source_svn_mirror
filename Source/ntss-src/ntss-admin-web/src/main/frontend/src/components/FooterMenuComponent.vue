/**
 * フッターメニュー部品
 */
<template>
  <v-ons-bottom-toolbar class='ntss-footer' style="overflow: visible;">
    <div class='footer-base-area' style='height: inherit; justify-content: space-around;'>
      <div style='width: min-content;' v-for='(item, idx) in menuItemList' :key='idx'>
        <!-- 通常メニュー -->
        <div
          v-if="item.router_name"
          @click="changeView(item)"
          :name="item.router_name"
          class="toolbar-button"
          style="padding-top: 0;"
          :style="menuStyles(item)"
        >
          <img :src="displayIcon(item)" class="ntss-footer-icon" />
        </div>
        <!-- 外部リンクメニュー --> 
        <footer-url
          v-else-if="item.urlCd"
          :img="item.urlInfo.function_icon"
          :link="item.urlInfo.text"
          @click="closeFooterList"
        />
        <div v-else 
          :ref="`menuGroupContainer${item.menuGroupCd}`"
          class="menu-group-container">
          <!-- メニューグループ -->
          <div
            :ref="`menuGroup${item.menuGroupCd}`"
            class="menu-group"
            :class="{ 'menu-group-hidden': !isSelectMenuGroup(item.menuGroupCd) }"
          >
            <!-- 動的メニュー -->
            <div v-for="groupMenuItem in item.groupMenuItemList" :key="groupMenuItem.function_cd">
              <div
                :ref="`menuGroupItem${item.menuGroupCd}-${groupMenuItem.function_cd}`"
                v-if="groupMenuItem.router_name"
                @click="changeView(groupMenuItem)"
                :name="groupMenuItem.router_name"
                class="toolbar-button menu-group-item"
                style="padding-top: 0;"
                :style="menuStyles(groupMenuItem)"
              >
                <img :src="displayIcon(groupMenuItem)" class="ntss-footer-icon" />
              </div>
              <footer-url
                v-else-if="groupMenuItem.urlCd"
                :img="groupMenuItem.urlInfo.function_icon"
                :link="groupMenuItem.urlInfo.text"
                class="menu-group-item"
                @click="closeFooterList"
              />
              <!-- メニュー0件のダミー -->
              <div
                v-else
                class="toolbar-button menu-group-item menu-group-dummy"
                style="padding-top: 0;"
              >
              </div>
            </div>
          </div>
          <!-- 静的メニュー -->
          <div
            :ref="`menuGroupItem${item.menuGroupCd}`"
            class="toolbar-button"
            :class="{ 'menu-group-selected': isSelectMenuGroup(item.menuGroupCd), 'active-menu': isActiveMenuGroup(item.groupMenuItemList) }"
            style="padding-top: 0;"
            @click="toggleGroupMenu(item)"
          >
            <img :src="item.iconInfo.function_icon" class="ntss-footer-icon" />
          </div>
        </div>
      </div>
      <div id='dummyBtnArea' style='width: 62px;' :style="displayStyles">
        <div class='toolbar-button' style='padding-top: 0;'>
          <div class="ntss-footer-icon"></div>
        </div>
      </div>
      <div id='listOpenBtnArea' style='width: 62px; right: 0px;' :style="displayStyles" @click="listOpen()">
        <img id="listOpenBtn" :src="listOpenButton" class="ntss-footer-icon" />
      </div>
    </div>
  </v-ons-bottom-toolbar>
</template>

<script>
// 機能コードに関する定数ファイル
import { FUNC_OPERATION_VIEWER, FUNC_DEVICE_EDGE_OPERATION } from "@/constants/function-code";
import FooterUrlComponent from "@/components/FooterUrlComponent";
import { EventBus } from "@/compat/vue/event-bus.js";
import { getRouterItem } from "@/router/routing-helper";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { getFooterMenuElement, getVisibleFooterMenuHeight, getScopedWindow, getScopedUserAgent } from "@/functions/common/LayoutMeasureHelper";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
// add #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat'
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages'
// add #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
import RoutingDefs from "@/router/json/routing-defs.json";

const ACTIVE_ROUTER_COLOR = "#2ca06f";

export default {
  components: {
    "footer-url": FooterUrlComponent
  },
  data() {
    return {
      colCount: 0,
      rowWidth: 0,
      colWidth: 0,
      StandardFooterHeight: 50,
      footerHeight: 0,
      scrollbar: "",
      orikaeshiSizeList: [0, 0, 0, 0],
      orikaeshiFlg: false,
      // iOS対応用データ
      iosCurrentWidth: 0,
      iosScreenWidth: 0,
      iosScreenHeight: 0,
      activeRouterName: "",
      listOpenButton: `${import.meta.env.BASE_URL}img/list-open-button/up_arrow.png`,
      listCloseButton: `${import.meta.env.BASE_URL}img/list-open-button/down_arrow.png`,
      msgFlg: false,
      // 現在開いているメニューグループを保持
      selectMenuGroupCd: null,
      footerToolbarFrameId: 0,
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getIsNkkAdmin", "getUseFunctions","getAuthorizedFunctions"]),
    ...mapGetters("user", ["getUserType", "getFacilityCd", "isGeneralUser"]),
    ...mapGetters("bread-crumb", { keepHistories: "getKeepHistory" }),
    ...mapGetters("url-link-register", { urlRegisterList : "getUrlRegisterList" }),
    ...mapGetters("mst-menu-group", { menuGroupList : "getMenuGroupList" }),
    ...mapGetters("pat-info", ["selectedPat"]),
    // メニューリスト
    menuItemList() {
      //mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない ljx start
      const dispMenu = this.getUseFunctions.filter(x => this.getAuthorizedFunctions.indexOf(x) !== -1)
      //const menuItemList = this.getUseFunctions.reduce((acc, useFunction) => {
      //mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない ljx end
      const menuItemList = dispMenu.reduce((acc, useFunction) => {  
        let item;
        if (/^(url-)/i.test(useFunction)) {
          // 外部リンクメニュー
          item = this.urlRegisterList.find(
            url => +url.urlCd === +useFunction.split("-")[1]
          );
        } else if (/^(group-)/i.test(useFunction)) {
          // メニューグループ
          const foundItem = this.menuGroupList.find(group => +group.menuGroupCd === +useFunction.split("-")[1]);                
          if (foundItem) {
            
            item = JSON.parse(JSON.stringify(foundItem)); // this.menuGroupListを変更しないようdeepコピー
            
            // 利用者マスタの許可機能のみをメニューグループに表示
            // ** 施設マスタの許可機能更新時に利用者マスタの許可機能も更新して最新のアカウント情報をストアに保存しているため、施設マスタの使用許可機能のフィルタは必要ない **
            item.menuList = item.menuList.filter(groupFuncCd => 
              this.getAuthorizedFunctions.some(authFuncCd => authFuncCd === groupFuncCd)
            );

            // メニューグループに登録されている通常メニュー、外部リンクの項目をセット
            item.groupMenuItemList = item.menuList
              .map(menuItem => {
                let menuObj;
                if (/^url-/i.test(menuItem)) {
                  // 外部リンクメニュー
                  const urlCd = menuItem.split("-")[1];
                  menuObj = this.urlRegisterList.find(url => +url.urlCd === +urlCd) || null;
                } else {
                  // 通常メニュー
                  menuObj = getRouterItem(menuItem, this.getUserType);
                }
                if (menuObj) {
                  menuObj.function_cd = menuItem;
                }
                return menuObj;
              })
              .filter(Boolean); // null を除外
              
            // メニュー0件時はダミー要素を追加
            if (item.groupMenuItemList.length === 0) {
              item.groupMenuItemList.push({ function_cd: "dummy" });
            }
          }
        } else {
          // 通常メニュー
          item = getRouterItem(useFunction, this.getUserType);
        }
        
        if (item) {
          acc.push(item);
        }

        return acc;
      }, []);
      // フッターが既に表示されている場合は表示の更新
      if (this.getFooterMenuEl() !== null) {
        this.setSizeInfo(menuItemList.length + 1);
        this.handleResize();
      }
      // 003:デバイスエッジ稼働監視は日機装ユーザー(user_type: 1)かつ管理者のみ表示
      return menuItemList.filter(menuItem => {
        return menuItem.function_cd !== FUNC_DEVICE_EDGE_OPERATION || this.getIsNkkAdmin;
      });
    },
    displayStyles() {
      // 表示/非表示切替
      if (this.orikaeshiFlg) {
        return {};
      } else {
        return { display: "none" };
      }
    }
  },
  watch: {
    // ルーティングの監視
    keepHistories() {
      this.getActiveRouter();
    },
  },
  methods: {
    ...mapActions("operation-viewer/machine", ["setFacilityCd"]),
    ...mapActions("url-link-register", ["getUrlRegisterList"]),
    ...mapActions("mst-menu-group", ["getMenuGroupList"]),
    
    /**
     * メニューグループ内のメニュースタイル設定
     * @param {*} item メニューグループ項目
     */
    setMenuGroupStyle(item) {
      // 高さ
      const menuGroupItem = this.$refs[`menuGroupItem${item.menuGroupCd}`];
      const menuHeight = menuGroupItem[0].getBoundingClientRect().height;
      const height = item.groupMenuItemList.length * menuHeight;
      // 最大高さ（メニュー10個分）
      const maxHeight = menuHeight * 10;
      
      const menuGroup = this.$refs[`menuGroup${item.menuGroupCd}`];
      menuGroup[0].style.height = this.isSelectMenuGroup(item.menuGroupCd) ? `${height}px` : "0px";
      menuGroup[0].style.maxHeight = `${maxHeight}px`;
      menuGroup[0].style.overflowY = height > maxHeight ? "scroll" : "hidden";
      menuGroup[0].style.boxShadow = this.isSelectMenuGroup(item.menuGroupCd) ? "0 0 0 2px #eeeeee" : "";
      // 左マージンの計算（縦スクロールバーの分のずれ防止）
      const marginLeft = menuGroup[0].offsetWidth - menuGroup[0].clientWidth;
      menuGroup[0].style.marginLeft = `${marginLeft > 0 ? (marginLeft / 2) : 0}px`;
    },
    /**
     * 選択中のメニューグループか判定
     * @param {*} menuGroupCd 
     */
    isSelectMenuGroup(menuGroupCd) {
      return this.selectMenuGroupCd === menuGroupCd;
    },
    /**
     * アクティブなメニューグループか判定
     * @param {*} groupMenuItemList 
     */
    isActiveMenuGroup(groupMenuItemList) {
      return groupMenuItemList.some(item => item.router_name === this.activeRouterName);
    },
    /**
     * クリックしたメニューグループの開閉
     * @param {*} item 
     */
    toggleGroupMenu(item) {
      // クリックしたメニューグループが開いていたら閉じる、それ以外なら開く
      this.selectMenuGroupCd = this.selectMenuGroupCd === item.menuGroupCd ? null : item.menuGroupCd;
      // メニューグループエリア スタイル設定
      this.setMenuGroupStyle(item);
    },
    getFooterMenuEl() {
      const root = this.$el || null;
      if (root?.matches?.('[data-ntss-layout-role="footer-menu"], #footer-menu, .ntss-footer')) {
        return root;
      }
      return getFooterMenuElement(root);
    },
    getFooterBaseEl() {
      return this.getFooterMenuEl()?.firstElementChild || null;
    },
    getFooterFirstRowCollapsedHeight() {
      const footerBase = this.getFooterBaseEl();
      if (!footerBase) {
        return 0;
      }
      const scopedWindow = footerBase.ownerDocument?.defaultView || window;
      const candidates = Array.from(footerBase.children || []).filter((child) => {
        const style = scopedWindow?.getComputedStyle?.(child);
        if (style && (style.display === "none" || style.visibility === "hidden")) {
          return false;
        }
        const rect = child.getBoundingClientRect?.();
        return !!rect && rect.height > 0 && rect.width > 0;
      });
      if (candidates.length === 0) {
        return Number(this.StandardFooterHeight || 0);
      }
      const rects = candidates.map((child) => child.getBoundingClientRect());
      const minTop = Math.min(...rects.map((rect) => rect.top));
      const firstRow = rects.filter((rect) => Math.abs(rect.top - minTop) <= 2);
      const rowHeight = firstRow.length > 0
        ? Math.max(...firstRow.map((rect) => rect.bottom - minTop))
        : 0;
      const listRect = this.getListOpenBtnAreaEl()?.getBoundingClientRect?.();
      const listHeight = listRect ? listRect.height : 0;
      return Math.ceil(Math.max(rowHeight, listHeight, Number(this.StandardFooterHeight || 0), 0));
    },
    setFooterToolbarHeight() {
      const footerMenu = this.getFooterMenuEl();
      if (!footerMenu) {
        return;
      }
      footerMenu.style.height = "";
      footerMenu.style.minHeight = "";
      footerMenu.style.maxHeight = "";
      delete footerMenu.dataset.ntssFooterResolvedHeight;
    },
    syncFooterToolbarHeight() {
      const scopedWindow = getScopedWindow(this.$el) || window;
      const cancelFrame = scopedWindow.cancelAnimationFrame?.bind(scopedWindow) || scopedWindow.clearTimeout?.bind(scopedWindow) || clearTimeout;
      const scheduleFrame = scopedWindow.requestAnimationFrame?.bind(scopedWindow) || ((callback) => scopedWindow.setTimeout(callback, 0));
      cancelFrame(this.footerToolbarFrameId);
      this.footerToolbarFrameId = scheduleFrame(() => {
        const footerBase = this.getFooterBaseEl();
        if (!footerBase) {
          return;
        }
        this.setFooterToolbarHeight();
      });
    },
    getListOpenBtnAreaEl() {
      return this.$el?.querySelector?.('#listOpenBtnArea') || null;
    },
    getDummyBtnAreaEl() {
      return this.$el?.querySelector?.('#dummyBtnArea') || null;
    },
    getListOpenBtnEl() {
      return this.$el?.querySelector?.('#listOpenBtn') || null;
    },
    getFooterHeight() {
      return getVisibleFooterMenuHeight(this.$el || null);
    },
    emitFooterLayoutChanged() {
      this.syncFooterToolbarHeight();
      this.$nextTick(() => {
        (getScopedWindow(this.$el) || window).requestAnimationFrame?.(() => {
          EventBus.$emit("footerLayoutChanged", {
            height: this.getFooterHeight(),
            isExpanded: this.getFooterBaseEl()?.style?.height !== "inherit"
          });
        });
      });
    },
    changeView(menuItem) {
      if (this.msgFlg) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // mod bug #6506 修正 chen start
          // title: "確認"
          title: DIALOG_MESSAGES[13000003].title,
          buttonLabels: ["キャンセル", "OK"],
          // title: "動作確認",
          // mod bug #6506 修正 chen end
          // message: "現在集計処理中です。</br>集計がキャンセルされますがよろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000003].message),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 1) {
              /* modify by chamaojia 2023-08-21 [9272] 共通の方法を提案し、プロンプトボックスをポップアップしない場合と一致している  --start */
              // if (
              //   this.isGeneralUser &&
              //   menuItem.function_cd === FUNC_OPERATION_VIEWER
              // ) {
              //   // 顧客かつ稼働ビューアを初期表示メニューに設定しているユーザーの場合
              //   this.setFacilityCd(this.getFacilityCd);
              // }
              //
              // // 画面幅に応じてサイドバーを閉じる
              // EventBus.$emit("sidebarCloseByWidth");
              // // 画面遷移
              // this.$router.push({ name: menuItem.router_name, params: { footer: null } });
              //
              // // ユーザーメニューを閉じる
              // EventBus.$emit("closeUserMenu");
              // // フッターのリストを閉じる
              // this.closeFooterList();
              this.changeViewDetail(menuItem)
              /* modify by chamaojia 2023-08-21 [9272] 共通の方法を提案し、プロンプトボックスをポップアップしない場合と一致している  --end */
            }
          }
        });
      } else {
        /* modify by chamaojia 2023-08-21 [9272] 公開方法を提案し、詳細ページをジャンプする必要がある機能を追加する  --start */
        // if (
        //   this.isGeneralUser &&
        //   menuItem.function_cd === FUNC_OPERATION_VIEWER
        // ) {
        //   // 顧客かつ稼働ビューアを初期表示メニューに設定しているユーザーの場合
        //   this.setFacilityCd(this.getFacilityCd);
        // }
        //
        // // 画面幅に応じてサイドバーを閉じる
        // EventBus.$emit("sidebarCloseByWidth");
        // // 画面遷移
        // this.$router.push({ name: menuItem.router_name, params: { footer: null } });
        //
        // if (
        //   this.selectedPat !== null &&
        //   menuItem.function_cd === FUNC_EXAM_RECORD
        // ) {
        //   // 患者選択中かつ検査結果画面への遷移
        //   this.$router.push({ name: "exam-record-detail", params: { footer: null } });
        // }
        //
        // // ユーザーメニューを閉じる
        // EventBus.$emit("closeUserMenu");
        // // フッターのリストを閉じる
        // this.closeFooterList();
        this.changeViewDetail(menuItem)
        /* modify by chamaojia 2023-08-21 [9272] 公開方法を提案し、詳細ページをジャンプする必要がある機能を追加する  --end */
      }
    },
    /* add by chamaojia 2023-08-21 [9272] メニューをクリックしてページをジャンプして共通メソッドを追加する  --start */
    changeViewDetail(menuItem) {
      if (
          this.isGeneralUser &&
          menuItem.function_cd === FUNC_OPERATION_VIEWER
      ) {
        // 顧客かつ稼働ビューアを初期表示メニューに設定しているユーザーの場合
        this.setFacilityCd(this.getFacilityCd);
      }

      // 画面幅に応じてサイドバーを閉じる
      EventBus.$emit("sidebarCloseByWidth");
      // 画面遷移
      //mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yqz start
      // this.$router.push({ name: menuItem.router_name, params: { footer: null } });
      this.$router.push({ name: menuItem.router_name, params: { function_cd:menuItem.function_cd, footer: null } });
      //mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない yqz end
      // 患者が選択し、詳細ページが存在すると判断した場合は、詳細ページにジャンプ
      // del #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng start
      // if (
      //     this.selectedPat !== null && existsDetailPageRouter.has(menuItem.function_cd)
      // ) {
      //   // 患者選択中かつ検査結果画面への遷移
      //   this.$router.push({ name: existsDetailPageRouter.get(menuItem.function_cd), params: { footer: null } });
      // }
      // del #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng end

      // ユーザーメニューを閉じる
      EventBus.$emit("closeUserMenu");
      // フッターのリストを閉じる
      this.closeFooterList();
    },
    /* add by chamaojia 2023-08-21 [9272] メニューをクリックしてページをジャンプして共通メソッドを追加する  --end */
    // アイコンの表示数等の情報をセット
    setSizeInfo(count) {
      const footerObj = Array.from(this.getFooterBaseEl()?.children || []);
      // カラム数(処理ボタン数)取得
      if (count >= 0) {
        this.colCount = count;
      } else {
        this.colCount = Math.max(footerObj.length - 1, 0);
      }

      if (this.colCount === 0 || footerObj.length === 0) {
        this.colWidth = 0;
        this.orikaeshiSizeList = [0, 0, 0, 0];
        return;
      }

      // アイコン幅を取得
      const firstMenuArea = footerObj[0] || null;
      const firstButton = firstMenuArea?.firstElementChild || null;
      const firstIcon = firstButton?.firstElementChild || null;

      // リロード時に画像サイズが0になってしまう対策（Vue2 同等）
      if ((firstIcon?.offsetWidth || 0) === 0) {
        this.colWidth = (firstMenuArea?.offsetWidth || 0) + 40;
      } else {
        this.colWidth = firstMenuArea?.offsetWidth || 0;
      }
      if (this.colWidth <= 0) {
        this.colWidth = 62;
      }
      const listOpenBtnArea = this.getListOpenBtnAreaEl();
      const dummyBtnArea = this.getDummyBtnAreaEl();
      if (listOpenBtnArea) {
        listOpenBtnArea.style.width = this.colWidth + "px";
      }
      if (dummyBtnArea) {
        dummyBtnArea.style.width = this.colWidth + "px";
      }

      // 2行目発生画面サイズ
      const size1 = (this.colCount - 1) * this.colWidth;
      // 3行目発生画面サイズ
      const size2 = Math.ceil(this.colCount / 2) * this.colWidth;
      // 4行目発生画面サイズ
      const size3 = Math.ceil(this.colCount / 3) * this.colWidth;
      // スクロールバー表示画面サイズ
      const size4 = Math.ceil(this.colCount / 4) * this.colWidth;
      this.orikaeshiSizeList = [size1, size2, size3, size4];
    },
    // iOS環境でのresizeイベント発生時に実行する処理
    handleResizeForiOS() {
      // iOS/PWA環境では、縦⇔横変更時に幅が正常に取得できない為、画面表示時に値を取得しておき、縦⇔横変更時に幅を入れ替える。
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      const orientation = ownerWindow.orientation;
      if (this.iosCurrentWidth === 0) {
        // 画面表示時の処理
        this.iosScreenWidth = ownerWindow.screen.width;
        this.iosScreenHeight = ownerWindow.screen.height;
        // 現在の向きを判定
        if (orientation === 0){
          // 縦画面の時
          this.iosCurrentWidth = this.iosScreenWidth;
        } else {
          // 横画面の時
          this.iosCurrentWidth = this.iosScreenHeight;
        }
      } else if (orientation === 0 && this.iosCurrentWidth === this.iosScreenHeight) {
        // 縦画面になった時の処理
        this.iosCurrentWidth = this.iosScreenWidth;
      } else if ((orientation === 90 || orientation === -90) && this.iosCurrentWidth === this.iosScreenWidth) {
        // 横画面になった時の処理
        this.iosCurrentWidth = this.iosScreenHeight;
      }
      this.handleResize();
    },
    // resizeイベント発生時に実行する処理
    handleResize() {
      const footerObj = this.getFooterBaseEl();
      if (!footerObj) {
        return;
      }
      if (this.iosCurrentWidth !== 0){
        // handleResizeForiOSから発火された場合の処理
        this.rowWidth = this.iosCurrentWidth;
      } else {
        // 表示領域のサイズを取得
        this.rowWidth = footerObj.offsetWidth;
      }
      // 表示幅に応じてスタイルを変更
      if (this.orikaeshiSizeList[3] > this.rowWidth) {
        this.orikaeshiFlg = true;
        // スクロールバー表示するとメニューグループが展開出来なくなるのでスクロールバーは非表示としてメニューバーの高さを調節
        this.scrollbar = "";
        const colCount = Math.floor(this.rowWidth / this.colWidth);
        const rowCount = Math.floor(this.colCount / colCount) + (this.colCount % colCount > 0 ? 1 : 0);
        this.footerHeight = this.StandardFooterHeight * rowCount;
      } else if (this.orikaeshiSizeList[2] > this.rowWidth) {
        this.orikaeshiFlg = true;
        this.scrollbar = "";
        // 4行分に高さを調整
        this.footerHeight = this.StandardFooterHeight * 4;
      } else if (this.orikaeshiSizeList[1] > this.rowWidth) {
        this.orikaeshiFlg = true;
        this.scrollbar = "";
        // 3行分に高さを調整
        this.footerHeight = this.StandardFooterHeight * 3;
      } else if (this.orikaeshiSizeList[0] > this.rowWidth) {
        this.orikaeshiFlg = true;
        this.scrollbar = "";
        // 2行分に高さを調整
        this.footerHeight = this.StandardFooterHeight * 2;
      } else {
        this.orikaeshiFlg = false;
        // 既にリストを開いていた場合、閉じる
        if (footerObj.style.height != "inherit") {
          this.closeFooterList();
        }
        this.emitFooterLayoutChanged();
        // 折り返しがない場合は処理を抜ける
        return;
      }

      // 既に開いた状態の場合は設定を適用
      if (footerObj.style.height != "inherit") {
        this.openFooterList();
      }
      this.emitFooterLayoutChanged();
    },
    // フッターのリスト開閉ボタン
    listOpen() {
      const footerObj = this.getFooterBaseEl();
      if (!footerObj) {
        return;
      }
      // ボタン表示を変更
      const btnAreaObj = this.getListOpenBtnAreaEl();
      if (footerObj.style.height != "inherit") {
        this.closeFooterList();
        btnAreaObj?.classList?.add("list-open-button-area");
        btnAreaObj?.classList?.remove("list-close-button-area");
      } else {
        this.openFooterList();
        // ボタン表示を変更
        let btnObj = this.getListOpenBtnEl();
        if (btnObj) {
          btnObj.src = this.listCloseButton;
        }
        btnAreaObj?.classList?.add("list-close-button-area");
        btnAreaObj?.classList?.remove("list-open-button-area");
      }
      this.emitFooterLayoutChanged();
    },
    // フッターリストを開く
    openFooterList() {
      let footerObj = this.getFooterBaseEl();
      if (!footerObj) {
        return;
      }
      footerObj.style.height = this.footerHeight + "px";
      footerObj.style.overflowY = this.scrollbar;
      footerObj.style.justifyContent = "flex-start";
      // 横位置の調整
      const rightMargin = this.rowWidth % this.colWidth;
      const listOpenBtnArea = this.getListOpenBtnAreaEl();
      if (listOpenBtnArea) {
        listOpenBtnArea.style.right = rightMargin + "px";
      }
      // メニューグループ強制折畳
      this.closeMenuGroup();
      this.emitFooterLayoutChanged();
    },
    /**
     *フッターリストを閉じる
     */
    closeFooterList() {
      let footerObj = this.getFooterBaseEl();
      if (!footerObj) {
        return;
      }
      footerObj.style.height = "inherit";
      footerObj.style.overflowY = "";
      footerObj.style.justifyContent = "space-around";
      const listOpenBtnArea = this.getListOpenBtnAreaEl();
      if (listOpenBtnArea) {
        listOpenBtnArea.style.right = "0px";
      }
      let btnObj = this.getListOpenBtnEl();
      const btnAreaObj = this.getListOpenBtnAreaEl();
      if (btnObj) {
        btnObj.src = this.listOpenButton;
      }
      btnAreaObj?.classList?.add("list-open-button-area");
      btnAreaObj?.classList?.remove("list-close-button-area");
      // メニューグループ強制折畳
      this.closeMenuGroup();
      this.emitFooterLayoutChanged();
    },
    // 現在のルーターを取得する
    getActiveRouter() {
      if (this.keepHistories.length > 0){
        if (this.keepHistories.length > 1 &&
            this.keepHistories[0].routerName === "pat-info-create" &&
            this.keepHistories[1].routerName === "pat-info") {
          this.activeRouterName = this.keepHistories[1].routerName;
          return;
        }
        if (this.keepHistories[0].routerName === "exam-record-detail") {
            this.activeRouterName = "exam-record";
            return;
        }
        const params = this.$route?.params || {};
        if (this.keepHistories.length > 1 && params.type && params.type === "check") {
          this.activeRouterName = this.keepHistories[1].routerName;
          return;
        }
        this.activeRouterName = this.getActiveRouterName(this.keepHistories[0].routerName);
      } else {
        this.activeRouterName = "";
      }
    },
    getActiveRouterName(routerName) {
      const routingItems = RoutingDefs.routing_defs.routing_items;
      const direct = routingItems.find(item => item.router_name === routerName);
      if (direct) {
        return direct.router_name;
      }
      for (const item of routingItems) {
        if (
          item.routes &&
          Array.isArray(item.routes) &&
          item.routes.includes(routerName)
        ) {
          return item.router_name;
        }
      }
      return routerName;
    },
    isActiveMenuItem(item) {
      if (!item || !this.activeRouterName) {
        return false;
      }
      return this.activeRouterName === item.router_name;
    },
    // アイコンの切り替え
    displayIcon(item) {
      if (this.isActiveMenuItem(item)){
        return item.active_icon;
      } else {
        return item.function_icon
      }
    },
    /**
     * メニューのアクティブ色 制御
     * @param {*} item 
     */
    menuStyles(item) {
      if (this.isActiveMenuItem(item)) {
        return {
          backgroundColor: ACTIVE_ROUTER_COLOR,
        };
      } else {
        return { backgroundColor: "" };
      }
    },
    /**
     * 外部リンクメニューマスタ、メニューグループマスタを取得
     */
    async getUrlAndGroupList() {
      // APIリストのURLレジスタを呼び出す
      try {
        await Promise.all([
          this.getUrlRegisterList(this.getFacilityCd),
          this.getMenuGroupList(this.getFacilityCd),
        ]);       
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('FooterMenuComponent.vue', 'getUrlAndGroupList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end

        // エラーを処理する
        this.internalServerError(error);
      }
    },
    internalServerError(error) {
      // console.log(error);
      // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
      // this.$ons.notification.alert("システムエラーが発生しました。", {
      //   title: "エラー"
      // });
      this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200002'].message), {
        title: DIALOG_MESSAGES['00200002'].title
      });
      // mod #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
    },
    /**
     * メニューグループを閉じる
     */
    closeMenuGroup() {
      // メニューグループも強制折畳
      this.selectMenuGroupCd = null;
    },
    onSetFooterMsgFlg(data) {
      this.msgFlg = data;
    },
  },
  created() {
    // add 性能改善メモリ不足 shan start
    EventBus.$off("closeFooterList", this.closeFooterList);
    EventBus.$off("refreshUrlList", this.getUrlAndGroupList);
    EventBus.$off("setFooterMsgFlg", this.onSetFooterMsgFlg);
    EventBus.$on("closeFooterList", this.closeFooterList);
    EventBus.$on("refreshUrlList", this.getUrlAndGroupList);
    EventBus.$on("setFooterMsgFlg", this.onSetFooterMsgFlg);
    this.getUrlAndGroupList();
    // add 性能改善メモリ不足 shan end
  },
  mounted() {
    this.getActiveRouter();
    this.setSizeInfo(-1);
    // 端末を判別し、画面リサイズ時のイベントを設定
    const ua = getScopedUserAgent(this.$el);
    if (ua.match(/iPhone|iPad/)) {
      (getScopedWindow(this.$el) || window).addEventListener("orientationchange", this.handleResizeForiOS);
      this.handleResizeForiOS();
    } else {
      (getScopedWindow(this.$el) || window).addEventListener("resize", this.handleResize);
      this.handleResize();
    }
    this.closeFooterList();
    this.emitFooterLayoutChanged();
  },
  beforeUnmount() {
    // 画面を閉じたときにイベントを除去
    (getScopedWindow(this.$el) || window).removeEventListener("resize", this.handleResize);
    (getScopedWindow(this.$el) || window).removeEventListener("orientationchange", this.handleResizeForiOS);
    const scopedWindow = getScopedWindow(this.$el) || window;
    const cancelFrame = scopedWindow.cancelAnimationFrame?.bind(scopedWindow) || scopedWindow.clearTimeout?.bind(scopedWindow) || clearTimeout;
    cancelFrame(this.footerToolbarFrameId);
    // add 性能改善メモリ不足 shan start
    EventBus.$off("setFooterMsgFlg", this.onSetFooterMsgFlg);
    EventBus.$off("closeFooterList", this.closeFooterList);
    EventBus.$off("refreshUrlList", this.getUrlAndGroupList);
    // add 性能改善メモリ不足 shan end
  },
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.footer-base-area {
  -webkit-transition: height 0.2s ease-out 0s;
  transition: height 0.2s ease-out 0s;
  background-image: -webkit-linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
}
.footer-base-area {
  width: 100%;
  background-color: inherit;
  bottom: 0px;
  position: fixed;
  display: flex;
  flex-flow: row wrap;
  align-content: flex-start;
  -webkit-align-content: flex-start;
}
#listOpenBtnArea {
  height: 43px;
  background-color: inherit;
  bottom: 0px;
  position: fixed;
  background-image: -webkit-linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
}
.list-close-button-area {
  background-color: transparent !important;
  background-image: none !important;
}
.list-open-button-area {
  background-color: inherit !important;
  background-image: -webkit-linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%) !important;
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%) !important;
}
.button-background {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  margin-left: 10px;
  background-color: #0076ff;
  overflow: hidden;
}
#listOpenBtnArea .button-background {
  background-image: -webkit-linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  box-shadow: 0 2px 2px 0 rgba(255, 255, 255, 0.2) inset,
    0 2px 20px 0 rgba(255, 255, 255, 0.5) inset, 0 -2px 2px 0 rgba(0, 0, 0, 0.1);
}
.menu-group-container {
  position: relative; /* メニューグループボタンを基準にメニューを配置 */
  display: inline-block;
}
.menu-group {
  position: absolute;
  bottom: 100%; /* メニューグループボタンの上に配置 */
  left: 50%;
  transform: translateX(-50%);
  background-color: var(--ntss-footer-background-color);
  background-image: -webkit-linear-gradient(
        rgba(255, 255, 255, 0.3) 0%,    
        transparent 50%,    
        transparent 50%,    
        rgba(0, 0, 0, 0.1) 100%  );
  padding: 0px;
  white-space: nowrap;
  background-clip: padding-box;
  overflow-y: hidden;
  transition: height 0.2s ease-out;
}
.menu-group-hidden {
  height: 0px !important;
  box-shadow: unset !important;
}
.menu-group-item {
  box-shadow: 0 0 0 1px #eeeeee;
  border-radius: unset;
  margin: 0 !important;
}
.menu-group-dummy {
  height: 40px;
  width: 40px;
}
.menu-group-selected {
  position: relative;
  z-index: 1;
  box-shadow: 0 0 0 2px #eeeeee;
  border-radius: unset;
}
.active-menu {
  background-color: #2ca06f;
}
.toolbar-button {
  margin: 1px;
}
</style>
