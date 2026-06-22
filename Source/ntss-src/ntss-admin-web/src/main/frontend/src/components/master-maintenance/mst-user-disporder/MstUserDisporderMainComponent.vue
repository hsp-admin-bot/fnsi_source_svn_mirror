/**
 * 利用者表示順マスタメンテナンスデータページ  MainContent
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style mst-user-disporder-direct-jq-toolbar" :style="heightStyles">
        <div v-show="isMobileDevice" class="custom-switch-wrapper">
          <label class="fab-font-color">編集</label>
          <v-ons-switch modifier="outline" v-model="allowEdit" />
        </div>
        <div id="grid-header" v-if="isMasterUser" class="header-btn-area right">
          <!-- del マスタ一覧 1･施設切替を可能とする 孔 start -->
          <!--<kendo-dropdownlist
                    v-model="facilitylistValue"
                    :data-source="facilitys"
                    :data-text-field="'facilityName'"
                    :data-value-field="'facilityCd'"
                    :filter="'contains'"
                    @open="onOpenFacility"
                    @change="onChangeFacility"
                    style="width: 13em;">
          </kendo-dropdownlist>-->
          <!-- del マスタ一覧 1･施設切替を可能とする 孔 end -->
          <v-ons-button
            v-show="isAllowSort"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="sortBtnClick()"
          >
            並び順確認
          </v-ons-button>
        </div>
        <div id="grid-header" v-else class="header-btn-area right">
          <v-ons-button
            v-show="isAllowSort"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="sortBtnClick()"
          >
            並び順確認
          </v-ons-button>
        </div>

        <div
          v-show="columns.length > 1"
          id="grid-font-size"
          ref="gridRoot"
          :class="[
            fontSizeSet,
            'ntss-kendo-grid-legacy',
            'mst-user-disporder-direct-jq-grid'
          ]"
        ></div>
      </div>
      <!-- 高さ調整 -->
      <div id="grid-footer">
        <v-ons-row width="100%">
          <v-ons-col width="50%">
            <v-ons-button
              class="btn2-cancel button denial-btn"
              style="width: auto;"
              @click="cancel"
            >
              キャンセル
            </v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="btn1-execute button registration-btn"
              style="width: auto;"
              :disabled="!isChanged"
              @click="saveRecord"
            >
              保存
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
      <div v-if="messageDialogInfo.isDialogVisible">
        <message-dialog
          v-model:visible="messageDialogInfo.isDialogVisible"
          :message-cd="messageDialogInfo.messageCd"
          :type="messageDialogInfo.type"
          :string-params="messageDialogInfo.stringParams"
        />
      </div>
    </div>
  </div>
</template>

<script>
import { markRaw } from "@/compat/vue/runtime";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import $ from "jquery";
import kendo from "@progress/kendo-ui";
import {
  bindGridEditorEnterToCloseCell,
  bindGridEditorNumericWheelSpinAssist
} from "@/compat/kendo/grid-edit";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { EventBus } from "@/compat/vue/event-bus.js";
import { deepCopy } from "@/functions/common/CommonFunctions";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import {
  getFooterMenuElement,
  getGridFooterElement,
  getLatestHeaderElement,
  getScopedAlertDialogs,
  getViewportHeight
} from "@/functions/common/LayoutMeasureHelper";

function installComponentJQuery() {
  if (typeof window !== "undefined") {
    window.$ = window.$ || $;
    window.jQuery = window.jQuery || $;
  }
  if (typeof globalThis !== "undefined") {
    globalThis.$ = globalThis.$ || $;
    globalThis.jQuery = globalThis.jQuery || $;
  }
}

function toPlainRecord(record) {
  if (!record) {
    return record;
  }
  if (typeof record.toJSON === "function") {
    return record.toJSON();
  }
  return { ...record };
}

export default {
  name: "MstUserDisporderMainComponent",
  components: {
    "message-dialog": messageDialog
  },
  data() {
    return {
      // 初期状態で1列がないとその後の表示が行われないため初期列を定義
      columns: [
        {
          field: "code",
          title: "code",
          hidden: false,
          editable: () => true,
          values: null
        }
      ],
      condition: {
        recordName: ""
      },
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      facilitylistValue: "",
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: "",
        type: "1",
        stringParams: [""]
      },
      updateResponse: null,
      delUserId: -1,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      //自画面の名称
      selfScreenName: "",
      isSortMode: false,
      isSorted: false,
      //変更前の施設
      prevFacilityCd: "",
      lastScrollTop: 0,
      lastScrollLeft: 0,
      iosFlg: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      directGridDataSource: null,
      directGridWidget: null,
      directGridMounted: false,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridColumnSignature: "",
      directGridSortEditedUserIds: markRaw(new Set()),
      directGridEditOriginalValues: markRaw(new Map()),
      originalDataSource: null,
      hasChanges: false
    };
  },
  computed: {
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch" }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", {
      getSystemUseSetting: "getSystemUseSetting"
    }),
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isChanged() {
      const data = this.getMasterRecordList?.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (data.filter(row => row.operation > 0).length ||
          this.isSorted ||
          this.hasChanges ||
          !this.validateDirectGridContract())
      );
    },
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return `font-size-set-${names[this.getFontSize] || names[0]}`;
    },
    ...mapGetters("mst-user", {
      getFacilityList: "getFacilityList",
      getMasterRecordList: "getMasterRecordList",
      getIsDispCreateCard: "getIsDispCreateCard"
    }),
    isMasterUser() {
      return this.getStateUserAccountInfo?.userType === 1 ? true : false;
    },
    facilitys() {
      // storeからデータを取得
      return this.getFacilityList;
    },
    masterRecords() {
      // storeからデータを取得
      return this.getMasterRecordList;
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
      this.scheduleDirectGridPostLayoutRefresh();
    },
    isDispMenu() {
      this.calculateGridHeight();
      this.scheduleDirectGridPostLayoutRefresh();
    },
    getFontSize() {
      this.calculateGridHeight();
      this.scheduleDirectGridPostLayoutRefresh();
    },
    columns(val) {
      this.$nextTick(() => {
        if (val.length > 1) {
          this.setLoadingScreenVisible(false);
          this.initDirectGridIfReady();
        }
      });
    }
  },
  methods: {
    ...mapActions("mst-user", [
      "getUserDataSortList",
      "facilityList",
      "edit",
      "setCondition",
      "setMasterRecordList",
      "updateMstSelecterByFacilityCd"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),
    getComponentOwnerDocument() {
      return this.$el?.ownerDocument || (typeof document !== "undefined" ? document : null);
    },
    getComponentOwnerWindow() {
      return this.getComponentOwnerDocument()?.defaultView || (typeof window !== "undefined" ? window : null);
    },
    getGridRootEl() {
      return this.$refs.gridRoot || null;
    },
    getDirectGridWidget() {
      return this.directGridWidget || ($(this.getGridRootEl()).data("kendoGrid") || null);
    },
    getDirectGridScrollContent() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content") || null;
    },
    getDirectGridLockedScrollContent() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getDirectGridHeaderEl() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-header") || null;
    },
    getDirectGridBodyRows() {
      return Array.from(this.getGridRootEl()?.querySelectorAll?.(".k-grid-content tbody tr") || []);
    },
    getDirectGridLockedBodyRows() {
      return Array.from(this.getGridRootEl()?.querySelectorAll?.(".k-grid-content-locked tbody tr") || []);
    },
    getDirectGridScrollPosition() {
      const content = this.getDirectGridScrollContent();
      return {
        top: content?.scrollTop || 0,
        left: content?.scrollLeft || 0
      };
    },
    setDirectGridScrollPosition(position = {}) {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (content) {
        if (typeof position.top === "number") {
          content.scrollTop = position.top;
        }
        if (typeof position.left === "number") {
          content.scrollLeft = position.left;
        }
        content.dispatchEvent?.(new Event("scroll", { bubbles: true }));
      }
      if (lockedContent && typeof position.top === "number") {
        lockedContent.scrollTop = position.top;
      }
    },
    syncDirectGridLockedScrollPosition() {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!content || !lockedContent) {
        return;
      }
      lockedContent.scrollTop = content.scrollTop;
    },
    bindDirectGridScrollSync() {
      const content = this.getDirectGridScrollContent();
      if (!content || content.__mstUserDisporderScrollSyncBound) {
        return;
      }
      content.__mstUserDisporderScrollSyncBound = true;
      content.addEventListener("scroll", () => this.syncDirectGridLockedScrollPosition(), { passive: true });
    },
    validateDirectGridContract() {
      const grid = this.getDirectGridWidget();
      const validator = grid?.editable?.validatable || this.kendoValidator || null;
      if (validator && typeof validator.validate === "function") {
        return validator.validate();
      }
      return true;
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.editingFlg) {
        const ownerDocument = this.getComponentOwnerDocument();
        const wh = getViewportHeight(ownerDocument) || this.windowHeight || 0;
        const hh = getLatestHeaderElement(ownerDocument)?.clientHeight || 0;
        const fmh = this.isDispMenu === 1 ? (getFooterMenuElement(ownerDocument)?.clientHeight || 0) : 0;
        this.kendoGridToolbarHeight = wh - hh - fmh - 5;
        this.kendoGridToolbarHeight =
          this.kendoGridToolbarHeight < 340 ? 340 : this.kendoGridToolbarHeight;
        const ghd = this.$el?.querySelector?.("#grid-header")?.clientHeight || 0;
        const gfh = getGridFooterElement(this.$el)?.clientHeight || 0;
        this.kendoGridHeight = Math.max(160, this.kendoGridToolbarHeight - (gfh + ghd));
        this.resizeDirectGrid();
      }
    },
    resizeDirectGrid() {
      const grid = this.getDirectGridWidget();
      if (!grid) {
        return;
      }
      try {
        grid.setOptions({ height: this.kendoGridHeight });
        grid.resize(true);
      } catch (_error) {
        // direct jq では resize 失敗時に追加 rebuild しない。
      }
      this.applyDirectGridLegacyStyleContract();
    },
    scheduleDirectGridPostLayoutRefresh() {
      const ownerWindow = this.getComponentOwnerWindow() || globalThis;
      if (!ownerWindow?.requestAnimationFrame) {
        this.applyDirectGridLegacyStyleContract();
        return;
      }
      if (this.directGridLayoutRafId != null) {
        ownerWindow.cancelAnimationFrame?.(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = ownerWindow.requestAnimationFrame(() => {
        this.applyDirectGridLegacyStyleContract();
        this.directGridLayoutRafId = ownerWindow.requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.applyDirectGridLegacyStyleContract();
        });
      });
    },
    editStart(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      this.captureDirectGridEditOriginalValue(e);
      if (this.androidFlg) {
        this.editingFlg = true;
      }
    },
    editEnd() {
      this.editingFlg = false;
    },
    syncDirectGridDataToStore() {
      const grid = this.getDirectGridWidget();
      const data = grid?.dataSource?.data?.();
      if (!data || !this.getMasterRecordList?.data) {
        return;
      }
      const byUserId = new Map(data.map(item => {
        const record = toPlainRecord(item);
        return [record?.userId, record];
      }));
      const nextData = this.getMasterRecordList.data.map(row => {
        const record = byUserId.get(row.userId);
        return record ? { ...row, ...record } : row;
      });
      this.setMasterRecordList({
        ...this.getMasterRecordList,
        data: nextData
      });
    },
    sort() {
      const source = this.getMasterRecordList?.data;
      if (!Array.isArray(source) || source.length === 0) {
        return;
      }
      const compare = (a, b) =>
        (Number(a.sortRank) - Number(b.sortRank)) ||
        ((Number(a.sortInputTime) || 0) - (Number(b.sortInputTime) || 0));
      const sortedData = source.map(item => ({ ...item })).sort(compare);
      // 並び順を採番しなおす
      for (let i = 0; i < sortedData.length; i++) {
        sortedData[i].sortRank = i + 1;
      }
      this.setMasterRecordList({
        ...this.getMasterRecordList,
        data: sortedData
      });
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして利用者マスタの値を取得
      this.getUserDataSortList(this.facilitylistValue)
        .then(response => {
          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach(column => {
            // 編集可否を関数化
            column.originalEditable = column.editable;
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            column.width = (column.field === "administrator" || column.field === "sortRank") ? "8em" : "14em";
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && column.dataType === "string" && column.field === "name") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width * 15
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
          });

          // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          this.columns.unshift({
            title: " ",
            field: "dummy",
            hidden: false,
            editable: () => false,
            width: "1px",
            format: "",
            values: null
          });

          // カラム幅等初期調整
          // 編集・並び順設定モードによって並び順項目の表示・非表示を切り替える
          // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
          const sortRankIndex = this.columns.findIndex(
            col => col.field === "sortRank"
          );
          if (sortRankIndex >= 0) {
            this.columns[sortRankIndex].hidden = false;
            const dummyIndex = this.columns.findIndex(
              col => col.field === "dummy"
            );
            if (dummyIndex >= 0) {
              this.columns[dummyIndex].hidden = true;
            }
          }
          
          //画面の入力値の初期値の取得
          this.initMasterRecordList = deepCopy(response.data.localDataSource);
          this.hasChanges = false;

          this.directGridSortEditedUserIds.clear();
          this.directGridEditOriginalValues.clear();
          this.originalDataSource = deepCopy(this.getMasterRecordList?.data || []);
          this.isSorted = false;
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.initDirectGridIfReady();
            // 元のスクロール位置に移動
            /* mod スクロールの位置を維持 楊 start */
            this.setDirectGridScrollPosition({ top: this.lastScrollTop, left: this.lastScrollLeft });
            /* mod スクロールの位置を維持 楊 end */
            this.scheduleDirectGridPostLayoutRefresh();
          });
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage("MstUserDisporderMainComponent.vue", "findList", "指定されたマスタが見つかりません。");
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
    },
    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        this.setFacilitylistValue();
        // 選択した施設を元に利用者一覧の取得
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          this.setFacilitylistValue();
          // 選択した施設を元に利用者一覧の取得
          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage("MstUserDisporderMainComponent.vue", "findFacilityList", "指定されたマスタが見つかりません。");
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
    },
    setFacilitylistValue() {
      this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
    },
    onOpenFacility(e) {
      // 変更前の値を取得
      this.prevFacilityCd = e.sender._old;
    },
    onChangeFacility(e) {
      if (this.prevFacilityCd != e.sender._old) {
        if (this.isChanged) {
          // 編集時は未保存確認メッセージを出力する
          const newFacilityCd = e.sender._old;
          e.preventDefault();
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                // 選択した施設を元に装置一覧の取得
                this.isSorted = false;
                this.facilitylistValue = newFacilityCd;
                this.findList();
              } else {
                // 変更前の施設を設定する
                this.facilitylistValue = this.prevFacilityCd;
              }
            }
          });
        } else {
          // 選択した施設を元に利用者一覧の取得
          this.isSorted = false;
          this.facilitylistValue = e.sender._old;
          this.findList();
        }
      }
    },
    sortBtnClick() {
      const scroll = this.getDirectGridScrollPosition();
      this.syncDirectGridDataToStore();
      this.isSortMode = true;
      this.sort();
      this.updateIsSortedFromSnapshot();
      //EventBus.$emit("setSortMode", this.isSortMode);
      this.$nextTick(() => {
        this.refreshDirectGridDataFromMasterRecords();
        this.setDirectGridScrollPosition(scroll);
        this.syncSortHighlightFromData();
      });
    },
    sortChange(tempData) {
      let flag = false;
      this.getMasterRecordList.data.forEach(item => {
        tempData.forEach(tempItem => {
          if (item.userId === tempItem.userId && item.sortRank !== tempItem.sortRank) {
            flag = true;
          }
        });
      });
      return flag;
    },
    showSortColumn() {
      // 編集・並び順設定モードによって並び順項目の表示・非表示を切り替える
      // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
      const sortRankIndex = this.columns.findIndex(
        col => col.field === "sortRank"
      );
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(
          this.isAllowSort && this.isSortMode
        );
        const dummyIndex = this.columns.findIndex(col => col.field === "dummy");
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
    },
    disableColumns() {
      this.columns.forEach(column => {
        // 並び順列を編集可、並び順列以外を編集不可に。
        column.editable =
          column.field === "sortRank"
            ? this.isAllowSort
              ? () => true
              : () => false
            : () => false;
      });
      this.refreshDirectGridColumns();
    },
    editableColumns() {
      this.columns.forEach(column => {
        // 編集可否の設定を初期表示時の状態に戻す
        column.editable =
          column.field === "sortRank"
            ? () => false
            : column.originalEditable
              ? () => true
              : () => false;
      });
      this.refreshDirectGridColumns();
    },

    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    getDirectGridVisibleColumnByCell(rowEl, cellIndex) {
      const isLocked = !!rowEl?.closest?.(".k-grid-content-locked");
      return (this.columns || [])
        .filter(column => !column.hidden && !!column.locked === isLocked)
        [cellIndex] || null;
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        this.syncSortHighlightFromData();
      });
    },
    changeSortColor(currentTrc) {
      // 並び順が変更されていれば並び順とダミー項目背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        currentTrc[clCount]?.classList?.remove("master-sort-edited");
        if (
          this.isEditRow(currentTrc[clCount]) &&
          clCount === this.getColumnIndex("sortRank")
        ) {
          currentTrc[clCount]?.classList?.add("master-sort-edited");
          const dummyIndex = this.getColumnIndex("dummy");
          if (dummyIndex > -1) {
            currentTrc[dummyIndex]?.classList?.add("master-sort-edited");
          }
        }
      }
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains("k-dirty-cell");
    },
    getDirectGridEditKey(uid, fieldName) {
      return uid && fieldName ? `${uid}:${fieldName}` : "";
    },
    getDirectGridEventContainerElement(ev) {
      const container = ev?.container;
      if (!container) {
        return null;
      }
      if (container.jquery) {
        return container[0] || null;
      }
      if (container.nodeType === 1) {
        return container;
      }
      return null;
    },
    getDirectGridFieldByEditEvent(ev) {
      if (ev?.field) {
        return ev.field;
      }
      const activeField = ev?.sender?.editable?.options?.fields?.field;
      if (activeField) {
        return activeField;
      }
      const container = this.getDirectGridEventContainerElement(ev);
      const cell = container?.matches?.("td") ? container : container?.closest?.("td");
      const row = cell?.closest?.("tr");
      if (!cell || !row) {
        return "";
      }
      return this.getDirectGridVisibleColumnByCell(row, cell.cellIndex)?.field || "";
    },
    readDirectGridEditorValue(container) {
      const input = container?.querySelector?.("input");
      if (!input) {
        return undefined;
      }
      const value = input.value;
      const numeric = Number(value);
      return value !== "" && !Number.isNaN(numeric) ? numeric : value;
    },
    resolveDirectGridSaveValues(ev) {
      const values = { ...(ev?.values || {}) };
      const field = this.getDirectGridFieldByEditEvent(ev);
      if (field && !Object.prototype.hasOwnProperty.call(values, field)) {
        const container = this.getDirectGridEventContainerElement(ev) || ev?.container?.[0] || ev?.container;
        const editorValue = this.readDirectGridEditorValue(container);
        if (editorValue !== undefined) {
          values[field] = editorValue;
        }
      }
      if (Object.keys(values).length === 0 && ev?.model) {
        const fallbackField = field || "sortRank";
        const modelValue = toPlainRecord(ev.model)?.[fallbackField];
        if (
          modelValue !== undefined &&
          this.isDirectGridFieldChanged(ev, fallbackField, modelValue)
        ) {
          values[fallbackField] = modelValue;
        }
      }
      return values;
    },
    applyDirectGridScrollFromWheel(wheelEvent, fromElement = null) {
      if (!wheelEvent || typeof wheelEvent.deltaY !== "number") {
        return;
      }
      let dy = wheelEvent.deltaY;
      if (wheelEvent.deltaMode === 1) {
        dy *= 16;
      } else if (wheelEvent.deltaMode === 2) {
        dy *= wheelEvent.target?.ownerDocument?.defaultView?.innerHeight ?? 640;
      }
      const content = fromElement?.closest?.(".k-grid")?.querySelector?.(".k-grid-content")
        || this.getDirectGridScrollContent();
      if (!(content instanceof HTMLElement)) {
        return;
      }
      const maxTop = Math.max(0, (content.scrollHeight || 0) - (content.clientHeight || 0));
      const nextTop = Math.min(maxTop, Math.max(0, (content.scrollTop || 0) + dy));
      this.setDirectGridScrollPosition({
        top: nextTop,
        left: content.scrollLeft || 0
      });
    },
    syncDirectGridSortRankPendingState(ev, cell, field) {
      if (!this.isSortMode || field !== "sortRank") {
        return;
      }
      const value = this.readDirectGridEditorValue(cell);
      if (value === undefined) {
        return;
      }
      const record = {
        ...(toPlainRecord(ev?.model) || {}),
        sortRank: value
      };
      const originalItem = this.findOriginalUserDisporderRecord(record);
      const storeRecord = this.getMasterRecordList?.data?.find(
        (item) => String(item.userId) === String(record.userId)
      );
      const differsFromSnapshot = originalItem
        && !this.isUserDisporderRowUnchangedBySnapshot(record, originalItem);

      if (differsFromSnapshot && record.userId != null) {
        this.directGridSortEditedUserIds.add(record.userId);
        if (storeRecord) {
          storeRecord.sortRank = value;
          storeRecord.sortInputTime = Date.now();
        }
      } else if (record.userId != null) {
        this.directGridSortEditedUserIds.delete(record.userId);
        if (storeRecord && originalItem) {
          storeRecord.sortRank = originalItem.sortRank;
          delete storeRecord.sortInputTime;
        }
      }
      this.updateIsSortedFromSnapshot();
      this.applyDirectGridCurrentRowVisualContract(record, ev?.model?.uid);
    },
    bindDirectGridSortRankEditorAssist(ev, cell, field) {
      const onEditorValueChange = () => {
        this.syncDirectGridSortRankPendingState(ev, cell, field);
      };
      const input = cell.querySelector?.("input");
      if (input) {
        input.addEventListener("input", onEditorValueChange, { passive: true });
        input.addEventListener("change", onEditorValueChange, { passive: true });
      }
      cell.addEventListener("click", (event) => {
        if (event.target?.closest?.(
          ".k-spinner-increase, .k-spinner-decrease, .k-link-increase, .k-link-decrease, .k-spin-button"
        )) {
          setTimeout(onEditorValueChange, 0);
        }
      }, true);
      bindGridEditorNumericWheelSpinAssist({
        cell,
        gridRoot: this.getGridRootEl(),
        onEditorValueChange
      });
    },
    onDirectGridEdit(ev) {
      bindGridEditorEnterToCloseCell(ev?.sender || this.getDirectGridWidget(), ev?.container);
      const field = this.getDirectGridFieldByEditEvent(ev);
      const cell = this.getDirectGridEventContainerElement(ev) || ev?.container?.[0] || ev?.container;
      if (!field || !cell) {
        return;
      }
      if (field === "sortRank") {
        this.bindDirectGridSortRankEditorAssist(ev, cell, field);
      }
    },
    normalizeDirectGridCompareValue(value) {
      if (value === null || value === undefined) {
        return "";
      }
      if (typeof value === "number") {
        return Number.isFinite(value) ? String(value) : "";
      }
      const stringValue = String(value).trim();
      if (stringValue === "") {
        return "";
      }
      const numberValue = Number(stringValue);
      return Number.isFinite(numberValue) ? String(numberValue) : stringValue;
    },
    captureDirectGridEditOriginalValue(ev) {
      const uid = ev?.model?.uid;
      const fieldName = this.getDirectGridFieldByEditEvent(ev);
      const key = this.getDirectGridEditKey(uid, fieldName);
      if (!key) {
        return;
      }
      const record = toPlainRecord(ev.model) || {};
      this.directGridEditOriginalValues.set(key, record[fieldName]);
    },
    getDirectGridOriginalValue(ev, fieldName) {
      const key = this.getDirectGridEditKey(ev?.model?.uid, fieldName);
      if (key && this.directGridEditOriginalValues.has(key)) {
        return this.directGridEditOriginalValues.get(key);
      }
      return toPlainRecord(ev?.model)?.[fieldName];
    },
    clearDirectGridOriginalValue(ev, fieldName) {
      const key = this.getDirectGridEditKey(ev?.model?.uid, fieldName);
      if (key) {
        this.directGridEditOriginalValues.delete(key);
      }
    },
    isDirectGridFieldChanged(ev, fieldName, nextValue) {
      const originalValue = this.getDirectGridOriginalValue(ev, fieldName);
      return this.normalizeDirectGridCompareValue(originalValue) !== this.normalizeDirectGridCompareValue(nextValue);
    },
    findOriginalUserDisporderRecord(record) {
      if (!record || !Array.isArray(this.originalDataSource)) {
        return null;
      }
      return this.originalDataSource.find(
        (item) => String(item.userId) === String(record.userId)
      ) || null;
    },
    isUserDisporderRowUnchangedBySnapshot(record, originalItem) {
      if (!record || !originalItem) {
        return false;
      }
      return (
        this.normalizeDirectGridCompareValue(record.sortRank) ===
        this.normalizeDirectGridCompareValue(originalItem.sortRank)
      );
    },
    clearDirectGridRowDirtyState(ev) {
      const rows = this.getDirectGridRowsByRecord(ev?.model, ev?.model?.uid);
      rows.forEach((row) => {
        Array.from(row.children || []).forEach((cell) => {
          cell.classList.remove("k-dirty-cell");
          cell.querySelectorAll?.(".k-dirty")?.forEach?.((element) => element.remove());
        });
      });
    },
    clearDirectGridRowActiveState(record, preferredUid = null) {
      const grid = this.getDirectGridWidget();
      const uid = preferredUid || record?.uid;
      try {
        grid?.clearSelection?.();
      } catch (_error) {
        // noop
      }
      const rowClasses = ["k-selected", "k-state-selected", "k-grid-edit-row"];
      const cellClasses = [
        "k-state-selected",
        "k-selected",
        "k-edit-cell",
        "k-focus",
        "k-focused"
      ];
      const clearRow = (row) => {
        if (!row) {
          return;
        }
        rowClasses.forEach((className) => row.classList.remove(className));
        Array.from(row.children || []).forEach((cell) => {
          cellClasses.forEach((className) => cell.classList.remove(className));
        });
      };
      this.getDirectGridRowsByRecord(record, uid).forEach(clearRow);
      if (uid) {
        const root = this.getGridRootEl();
        root?.querySelectorAll?.(`tbody tr[data-uid="${uid}"]`)?.forEach?.(clearRow);
      }
    },
    revertUserDisporderRowToOriginal(record, originalItem, ev) {
      const applySnapshot = (target) => {
        if (!target || !originalItem) {
          return;
        }
        target.sortRank = originalItem.sortRank;
        delete target.sortInputTime;
        delete target.operation;
        delete target.edited;
        if (target.dirtyFields && typeof target.dirtyFields === "object") {
          Object.keys(target.dirtyFields).forEach((field) => {
            delete target.dirtyFields[field];
          });
        }
        target.dirty = false;
      };
      applySnapshot(record);
      applySnapshot(ev?.model);
      const storeRecord = this.getMasterRecordList?.data?.find(
        (item) => String(item.userId) === String(record.userId)
      );
      applySnapshot(storeRecord);
      const gridItem = this.getDirectGridWidget()
        ?.dataSource?.data?.()
        ?.find((item) => String(item.userId) === String(record.userId));
      applySnapshot(gridItem);
      if (record.userId != null) {
        this.directGridSortEditedUserIds.delete(record.userId);
      }
      this.clearDirectGridRowDirtyState(ev);
      this.clearDirectGridRowActiveState(record, ev?.model?.uid);
    },
    updateIsSortedFromSnapshot() {
      if (!Array.isArray(this.originalDataSource) || this.originalDataSource.length === 0) {
        this.isSorted = false;
        this.refreshDirectGridHasChanges();
        return;
      }
      this.isSorted = this.sortChange(deepCopy(this.originalDataSource));
      this.refreshDirectGridHasChanges();
    },
    refreshDirectGridHasChanges() {
      const gridHasChanges = !!this.getDirectGridWidget()?.dataSource?.hasChanges?.();
      this.hasChanges = gridHasChanges || this.isSorted || this.directGridSortEditedUserIds.size > 0;
    },
    getDirectGridChangedFields(ev) {
      const values = ev?.values || {};
      return Object.keys(values).filter(fieldName => this.isDirectGridFieldChanged(ev, fieldName, values[fieldName]));
    },
    async onDirectGridSave(ev) {
      this.editingFlg = false;
      const values = this.resolveDirectGridSaveValues(ev);
      const baseRecord = toPlainRecord(ev?.model) || {};
      const record = {
        ...baseRecord,
        ...values
      };
      Object.keys(values).forEach(fieldName => this.clearDirectGridOriginalValue(ev, fieldName));

      const originalItem = this.findOriginalUserDisporderRecord(record);
      if (originalItem && this.isUserDisporderRowUnchangedBySnapshot(record, originalItem)) {
        this.revertUserDisporderRowToOriginal(record, originalItem, ev);
        this.$nextTick(() => {
          this.applyDirectGridCurrentRowVisualContract(record, ev?.model?.uid);
          this.syncSortHighlightFromData();
          this.updateIsSortedFromSnapshot();
          requestAnimationFrame(() => {
            if (!this.shouldHighlightSortRow(record)) {
              this.clearDirectGridRowActiveState(record, ev?.model?.uid);
            }
          });
        });
        return;
      }

      let changedFields = Object.keys(values).filter(
        (fieldName) => this.isDirectGridFieldChanged(ev, fieldName, values[fieldName])
      );
      const differsFromSnapshot = originalItem
        && !this.isUserDisporderRowUnchangedBySnapshot(record, originalItem);
      if (changedFields.length === 0 && differsFromSnapshot) {
        changedFields = Object.keys(values).length > 0 ? Object.keys(values) : ["sortRank"];
      }
      if (changedFields.length === 0) {
        this.$nextTick(() => {
          this.applyDirectGridCurrentRowVisualContract(baseRecord, ev?.model?.uid);
          this.syncSortHighlightFromData();
          this.updateIsSortedFromSnapshot();
        });
        return;
      }

      if (changedFields.includes("sortRank") && record.userId != null) {
        this.directGridSortEditedUserIds.add(record.userId);
      }
      if (this.isSortMode && changedFields.includes("sortRank")) {
        record.sortInputTime = Date.now();
      }
      this.edit({ editRecord: record, isSortMode: this.isSortMode });
      if (record.operation === 1) {
        record.edited = true;
      }
      this.updateIsSortedFromSnapshot();
      this.$nextTick(() => {
        this.applyDirectGridCurrentRowVisualContract(record, ev?.model?.uid);
        this.syncSortHighlightFromData();
      });
    },

    /**
     * 保存ボタン押下時イベント処理
     */
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      const scroll = this.getDirectGridScrollPosition();
      this.lastScrollTop = scroll.top;
      this.lastScrollLeft = scroll.left;
      /* add スクロールの位置を維持 楊 end */
      this.syncDirectGridDataToStore();
      await this.sort();

      // 利用者マスタのmst_selecterのみを更新する
      const mstUserSelecters = this.getMasterRecordList.data
        .filter(e => e.userId > 0 || (typeof e.isEditedAtThisTime === "function" && e.isEditedAtThisTime()));
      this.updateMstSelecterByFacilityCd({ facilityCd: this.facilitylistValue, request: mstUserSelecters })
        .then(response => {
          this.updateResponse = response.data;
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "マスタ更新が完了しました。"
            title: DIALOG_MESSAGES[12000004].title,
            message: messageFormat(DIALOG_MESSAGES[12000004].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });

          // データ再取得
          this.isSorted = false;
          this.directGridSortEditedUserIds.clear();
          this.directGridEditOriginalValues.clear();
          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage("MstUserDisporderMainComponent.vue", "saveRecord", error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification
              .alert({
                title: "更新に失敗しました。",
                message: error.response.data.errorMessage
              })
              .then(() => this.findList());
          }
        })
        // 共通ローダー：表示終了
        .finally(() => this.setLoadingScreenVisible(false));
    },

    buildDirectGridColumns() {
      return this.columns.map(column => ({
        ...column,
        editable: column.editable,
        hidden: !!column.hidden,
        values: column.values || undefined,
        sortable: false
      }));
    },
    getDirectGridColumnSignature() {
      return JSON.stringify(this.columns.map(column => ({
        field: column.field,
        title: column.title,
        hidden: !!column.hidden,
        width: column.width,
        locked: !!column.locked
      })));
    },
    createDirectGridDataSource(source = this.masterRecords) {
      const option = {
        data: source?.data || [],
        schema: source?.schema || this.getMasterRecordList?.schema || undefined
      };
      this.directGridDataSource = markRaw(new kendo.data.DataSource(option));
      return this.directGridDataSource;
    },
    initDirectGridIfReady(options = {}) {
      const root = this.getGridRootEl();
      if (!this.directGridMounted || !root || this.columns.length <= 1) {
        return;
      }
      installComponentJQuery();
      const signature = this.getDirectGridColumnSignature();
      if (this.directGridWidget) {
        if (signature !== this.directGridColumnSignature) {
          this.refreshDirectGridColumns();
        } else {
          this.refreshDirectGridDataFromMasterRecords();
        }
        return;
      }
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        columns: this.buildDirectGridColumns(),
        editable: true,
        selectable: true,
        reorderable: false,
        sortable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        beforeEdit: this.editStart,
        edit: this.onDirectGridEdit,
        cellClose: this.editEnd,
        save: this.onDirectGridSave,
        dataBound: this.onDirectGridDataBound
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.directGridColumnSignature = signature;
      this.applyDirectGridLegacyStyleContract();
      this.bindDirectGridScrollSync();
      this.scheduleDirectGridPostLayoutRefresh();
    },
    destroyDirectGrid() {
      const grid = this.getDirectGridWidget();
      if (grid) {
        try {
          grid.destroy();
        } catch (_error) {
          // 破棄時の追加補正は行わない。
        }
      }
      const root = this.getGridRootEl();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
      this.directGridDataSource = null;
      this.directGridColumnSignature = "";
    },
    refreshDirectGridColumns() {
      const grid = this.getDirectGridWidget();
      if (!grid) {
        return;
      }
      const scroll = this.getDirectGridScrollPosition();
      try {
        grid.setOptions({
          columns: this.buildDirectGridColumns(),
          height: this.kendoGridHeight
        });
        this.directGridColumnSignature = this.getDirectGridColumnSignature();
      } catch (_error) {
        return;
      }
      this.refreshDirectGridDataFromMasterRecords();
      this.setDirectGridScrollPosition(scroll);
      this.applyDirectGridLegacyStyleContract();
    },
    refreshDirectGridDataFromMasterRecords() {
      const grid = this.getDirectGridWidget();
      if (!grid) {
        return;
      }
      const scroll = this.getDirectGridScrollPosition();
      const dataSource = this.createDirectGridDataSource(this.masterRecords);
      grid.setDataSource(dataSource);
      this.setDirectGridScrollPosition(scroll);
      this.applyDirectGridLegacyStyleContract();
    },
    onDirectGridDataBound() {
      this.applyDirectGridLegacyStyleContract();
      this.bindDirectGridScrollSync();
      this.syncSortHighlightFromData();
      this.scheduleDirectGridPostLayoutRefresh();
    },
    resolveDirectGridFontPixel() {
      const root = this.getGridRootEl();
      const ownerWindow = this.getComponentOwnerWindow() || window;
      const fontSize = ownerWindow.getComputedStyle?.(root || this.$el)?.fontSize;
      const value = Number.parseFloat(fontSize || "");
      return Number.isFinite(value) && value > 0 ? value : 16;
    },
    parseDirectGridColumnWidthPx(width) {
      if (width === null || width === undefined || width === "") {
        return 0;
      }
      if (typeof width === "number") {
        return Number.isFinite(width) ? width : 0;
      }
      const value = String(width).trim().toLowerCase();
      const numeric = Number.parseFloat(value);
      if (!Number.isFinite(numeric)) {
        return 0;
      }
      if (value.endsWith("em")) {
        return numeric * this.resolveDirectGridFontPixel();
      }
      if (value.endsWith("px") || /^[0-9.]+$/.test(value)) {
        return numeric;
      }
      return 0;
    },
    getDirectGridVisibleLockedWidthPx() {
      return this.columns.reduce((total, column) => {
        if (!column?.locked || column.hidden) {
          return total;
        }
        return total + this.parseDirectGridColumnWidthPx(column.width);
      }, 0);
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRootEl();
      const width = this.getDirectGridVisibleLockedWidthPx();
      if (!root || !width) {
        return;
      }
      const widthPx = `${Math.ceil(width)}px`;
      [
        ".k-grid-header-locked",
        ".k-grid-content-locked",
        ".k-grid-footer-locked",
        ".k-grid-content-locked table",
        ".k-grid-header-locked table"
      ].forEach(selector => {
        root.querySelectorAll(selector).forEach(element => {
          element.style.width = widthPx;
          element.style.minWidth = widthPx;
        });
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!content || !lockedContent) {
        return;
      }
      const ownerWindow = content.ownerDocument?.defaultView || window;
      const styleHeight = Number.parseFloat(ownerWindow.getComputedStyle?.(content)?.height || "");
      const offsetHeight = content.offsetHeight || styleHeight || 0;
      const clientHeight = content.clientHeight || 0;
      const horizontalScrollbarHeight = Math.max(0, Math.ceil(offsetHeight - clientHeight));
      const targetHeight = clientHeight || (Number.isFinite(styleHeight) ? styleHeight - horizontalScrollbarHeight : 0);
      if (!Number.isFinite(targetHeight) || targetHeight <= 0) {
        return;
      }
      const heightPx = `${Math.floor(targetHeight)}px`;
      lockedContent.style.height = heightPx;
      lockedContent.style.maxHeight = heightPx;
      this.syncDirectGridLockedScrollPosition();
    },
    applyDirectGridLegacyShellClasses() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block", "mst-user-disporder-direct-jq-grid");
    },
    applyDirectGridLegacyContentClasses() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      root.querySelectorAll("tbody tr").forEach((tr, index) => {
        tr.classList.add("k-master-row");
        if (index % 2 === 1) {
          tr.classList.add("k-alt");
        } else {
          tr.classList.remove("k-alt");
        }
      });
      root.querySelectorAll("td").forEach(td => td.classList.add("k-td", "k-table-td"));
    },
    applyDirectGridLegacyStyleContract() {
      this.applyDirectGridLegacyShellClasses();
      this.applyDirectGridLegacyContentClasses();
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
    },
    getDirectGridRowsByRecord(record, preferredUid = null) {
      const root = this.getGridRootEl();
      if (!root || !record) {
        return [];
      }
      const rows = [];
      if (preferredUid) {
        rows.push(...root.querySelectorAll(`tbody tr[data-uid="${preferredUid}"]`));
      }
      const grid = this.getDirectGridWidget();
      root.querySelectorAll("tbody tr").forEach(row => {
        if (rows.includes(row)) {
          return;
        }
        const dataItem = grid?.dataItem?.(row);
        if (dataItem && String(dataItem.userId) === String(record.userId)) {
          rows.push(row);
        }
      });
      return rows;
    },
    applyDirectGridCurrentRowVisualContract(record, preferredUid = null) {
      const rows = this.getDirectGridRowsByRecord(record, preferredUid);
      const shouldHighlight = this.shouldHighlightSortRow(record);
      rows.forEach(row => {
        // Vue2 の本画面は並び順編集時に行全体を編集色へ変えず、
        // sortRank / dummy セルだけを master-sort-edited にする。
        row.classList.remove("master-edited-row", "master-deleted-row", "master-sort-edited");
        Array.from(row.children || []).forEach(cell => {
          cell.classList.remove("master-sort-edited");
          if (!shouldHighlight) {
            cell.classList.remove("k-dirty-cell");
            cell.querySelectorAll?.(".k-dirty")?.forEach?.(element => element.remove());
          }
        });
        this.highlightSortCellsForRow(row, record);
      });
      if (!shouldHighlight) {
        this.clearDirectGridRowActiveState(record, preferredUid);
      }
    },
    clearSortHighlightClasses() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      root.querySelectorAll(".master-sort-edited, .master-edited-row, .master-deleted-row").forEach(element => {
        element.classList.remove("master-sort-edited", "master-edited-row", "master-deleted-row");
      });
    },
    shouldHighlightSortRow(item) {
      return !!(item && this.directGridSortEditedUserIds?.has?.(item.userId));
    },
    highlightSortCellsForRow(rowEl, item) {
      if (!rowEl || !this.shouldHighlightSortRow(item)) {
        return;
      }
      let marked = false;
      rowEl.querySelectorAll("td").forEach(cell => {
        const field = cell.getAttribute("data-field");
        if (field === "sortRank" || field === "dummy") {
          cell.classList.add("master-sort-edited");
          marked = true;
        }
      });
      if (marked) {
        return;
      }
      const sortIdx = this.getColumnIndex("sortRank");
      const dummyIdx = this.getColumnIndex("dummy");
      Array.from(rowEl.children).forEach((cell, columnIndex) => {
        const column = this.getDirectGridVisibleColumnByCell(rowEl, columnIndex);
        const field = column?.field;
        if (field === "sortRank" || field === "dummy" || columnIndex === sortIdx || columnIndex === dummyIdx) {
          cell.classList.add("master-sort-edited");
        }
      });
    },
    syncSortHighlightFromData() {
      const gridHeader = this.getDirectGridHeaderEl();
      if (
        !gridHeader ||
        gridHeader.textContent === " " ||
        gridHeader.textContent === "code"
      ) {
        return;
      }
      gridHeader.classList.add("master-grid-header");
      this.clearSortHighlightClasses();

      const grid = this.getDirectGridWidget();
      const data = grid?.dataSource?.view?.() || grid?.dataSource?.data?.() || this.getMasterRecordList?.data || [];
      const lockedRows = this.getDirectGridLockedBodyRows();
      const bodyRows = this.getDirectGridBodyRows();
      const rowCount = Math.max(lockedRows.length, bodyRows.length, data.length);

      for (let index = 0; index < rowCount; index++) {
        const item = data[index];
        this.highlightSortCellsForRow(lockedRows[index], item);
        this.highlightSortCellsForRow(bodyRows[index], item);
      }
    },

    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$route.name
          && getScopedAlertDialogs(this.$el || this).length === 0) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.findList();
              }
            }
          });
        } else {
          this.findList();
        }
      }
    }
  },
  created() {
    this.setLoadingScreenVisible(true);
    // mod マスタ一覧 1･施設切替を可能とする 孔 start
    // this.findFacilityList();
    this.facilitylistValue = this.getFacilitySwitch;
    this.findList();
    // mod マスタ一覧 1･施設切替を可能とする 孔 end
    this.setCondition(this.condition);

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = (globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$route.name;
    EventBus.$on("refresh", this.refresh);
  },
  mounted() {
    this.directGridMounted = true;
    this.$nextTick(() => {
      this.calculateGridHeight();
      this.initDirectGridIfReady();
    });
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
    const ownerWindow = this.getComponentOwnerWindow() || globalThis;
    [
      this.directGridLayoutRafId,
      this.directGridFilterRefreshRafId,
      this.directGridScrollSyncRafId
    ].forEach(id => {
      if (id != null) {
        ownerWindow.cancelAnimationFrame?.(id);
      }
    });
    this.directGridSortEditedUserIds?.clear?.();
    this.directGridEditOriginalValues?.clear?.();
    this.destroyDirectGrid();
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
#grid-footer {
  margin: 0;
  padding: 5px 5px 5px 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
  padding: 0.1em 0.3em;
}
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.custom-switch-wrapper {
  display: flex;
  float: left;
  align-items: center;
  min-width: 7em;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.mst-user-disporder-direct-jq-grid {
  clear: both;
}
.kendo-grid-toolbar-style :deep(.k-grid-header-locked > table),
.kendo-grid-toolbar-style :deep(.k-grid-content-locked > table) {
  margin-bottom: 0;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  overflow: hidden;
}
.kendo-grid-toolbar-style :deep(.master-grid-header) {
  font-weight: normal;
}

/* Vue2 kendo-grid wrapper rendered toolbar/header style contract.
   Keep this screen local: inherit the project font chain and use header currentColor
   for the separator, instead of adding a new global compat/theme rule. */
.mst-user-disporder-direct-jq-toolbar :deep(.toolbar-btn),
.mst-user-disporder-direct-jq-toolbar :deep(.toolbar-btn *) {
  font-family: inherit;
}
.mst-user-disporder-direct-jq-grid :deep(.k-grid-header th),
.mst-user-disporder-direct-jq-grid :deep(.k-grid-header .k-table-th),
.mst-user-disporder-direct-jq-grid :deep(.k-grid-header-locked th),
.mst-user-disporder-direct-jq-grid :deep(.k-grid-header-locked .k-table-th) {
  border-right-color: currentColor;
}
.mst-user-disporder-direct-jq-grid :deep(.k-grid-header th),
.mst-user-disporder-direct-jq-grid :deep(.k-grid-header .k-table-th),
.mst-user-disporder-direct-jq-grid :deep(.k-grid-header .k-link),
.mst-user-disporder-direct-jq-grid :deep(.k-grid-header-locked th),
.mst-user-disporder-direct-jq-grid :deep(.k-grid-header-locked .k-table-th),
.mst-user-disporder-direct-jq-grid :deep(.k-grid-header-locked .k-link) {
  cursor: default;
}


/* Vue2 Kendo locked layout contract.
   Kendo 2026 renders locked content inside flex containers; keep the locked area
   at the width Kendo/column definitions already calculated, as Kendo 2019 did. */
:deep(.k-grid-lockedcolumns .k-grid-header-locked),
:deep(.k-grid-lockedcolumns .k-grid-content-locked),
:deep(.k-grid-lockedcolumns .k-grid-footer-locked) {
  flex: 0 0 auto;
  flex-shrink: 0;
}
</style>
