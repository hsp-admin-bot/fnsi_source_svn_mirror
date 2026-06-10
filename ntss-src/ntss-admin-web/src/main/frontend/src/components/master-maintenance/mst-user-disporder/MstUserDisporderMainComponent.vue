/**
 * 利用者表示順マスタメンテナンスデータページ  MainContent
 */
<template>
  <div class='main-content-area master-maintenance-page'>
    <div class='ntss-list' :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <div v-show="isMobileDevice" class="custom-switch-wrapper">
          <label class="fab-font-color">編集</label>
          <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
        </div>
        <div id="grid-header" v-if="isMasterUser" class='header-btn-area right'>
          <v-ons-button
            v-show="isAllowSort"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="sortBtnClick()"
          >
            並び順確認
          </v-ons-button>
        </div>
        <div id="grid-header" v-else class='header-btn-area  right'>

          <v-ons-button
            v-show="isAllowSort"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="sortBtnClick()"
          >
            並び順確認
          </v-ons-button>
        </div>
        <kendo-grid ref="grid" :class="fontSizeSet" style="clear: both;"
            :data-source="masterRecords"
            :editable="true"
            :selectable="true"
            :reorderable="false"
            :height=kendoGridHeight
            :scrollable="true"
            :beforeEdit=editStart
            :cellClose=editEnd
            @save="onSave"
            @databound="onDataBoundKendoGrid">
            <template v-for="(column, index) in columns" >
              <kendo-grid-column
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
            </template>
        </kendo-grid>
      </kendo-grid-toolbar>
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
        :visible.sync="messageDialogInfo.isDialogVisible"
        :message-cd="messageDialogInfo.messageCd"
        :type="messageDialogInfo.type"
        :string-params="messageDialogInfo.stringParams"
      />
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { EventBus } from "@/eventBus.js";
import {deepCopy} from "@/functions/common/CommonFunctions";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import _ from 'lodash';
import { customComparator } from "@/utils/util.js";

export default {
  components: {
    "message-dialog": messageDialog
  },
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
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
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      facilitylistValue: "",
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: "",
        type: "1",
        stringParams: [""]
      },
      delUserId: -1,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      //自画面の名称
      selfScreenName: "",
      isSortMode: false,
      //変更前の施設
      prevFacilityCd: "",
      lastScrollTop: 0,
      lastScrollLeft: 0,
      iosFlg: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      initMasterRecordList: null,
      hasChanges: false
    };
  },
  computed: {
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
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
      return this.hasChanges;
    },
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
    ...mapGetters("mst-user", {
      getFacilityList: "getFacilityList",
      getMasterRecordList: "getMasterRecordList",
      getIsDispCreateCard: "getIsDispCreateCard"
    }),
    isMasterUser() {
        return this.getStateUserAccountInfo.userType === 1 ? true : false;
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
    },
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    columns:function(val){
      this.$nextTick(function(){
        if (val.length > 1)
        this.setLoadingScreenVisible(false);
      });
    }
  },
  methods: {
    ...mapActions("mst-user", [
      "getUserDataSortList",
      "facilityList",
      "edit",
      "setCondition",
      "updateMstSelecterByFacilityCd",
      "setMasterRecordList"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.editingFlg) {
        const wh = this.windowHeight;
        const hh = Array.prototype.slice
          .call(document.getElementsByClassName("header"))
          .pop().clientHeight;
        const fmh =
          this.isDispMenu === 1
            ? document.getElementById("footer-menu").clientHeight
            : 0;
        this.kendoGridToolbarHeight = wh - hh - fmh - 5;
        this.kendoGridToolbarHeight =
          this.kendoGridToolbarHeight < 340 ? 340 : this.kendoGridToolbarHeight;
        const ghd = document.getElementById("grid-header").clientHeight;
        const gfh = document.getElementById("grid-footer").clientHeight;
        this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + ghd);
      }
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
      if (this.androidFlg) {
        this.editingFlg = true;
      }
    },
    editEnd() {
      this.editingFlg = false;
    },
    sort() {
      const compare = (a, b) =>
        a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
      const tempMasterRecordList = deepCopy(this.getMasterRecordList);
      tempMasterRecordList.data.sort(compare);
      const grid = this.$refs.grid.kendoWidget();
      // 並び順を採番しなおす
      for (let i = 0; i < tempMasterRecordList.data.length; i++) {
        let item = grid.dataSource.data().find(item => {
          return item.userId === tempMasterRecordList.data[i].userId;
        });
        item.set("sortRank", i + 1);
        tempMasterRecordList.data[i].sortRank = i + 1;
        const initMasterRecord = this.initMasterRecordList.data.find(item => {
          return item.userId === tempMasterRecordList.data[i].userId;
        });
        const isEqual = _.isEqualWith(
          initMasterRecord?.sortRank,
          item?.sortRank,
          customComparator
        );
        if (isEqual){
          delete item.dirtyFields["sortRank"];
          if (Object.keys(item.dirtyFields).length === 0) {
            item.set("dirty", false);
            delete item.dirtyFields.dirty;
          }
        }
      }
      const sortedGridData = [...grid.dataSource.data()].sort((a, b) => a.sortRank - b.sortRank);
      grid.dataSource.data(sortedGridData);
      grid.refresh();
      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
      this.hasChanges = grid.dataSource.hasChanges();
      this.setMasterRecordList(deepCopy(tempMasterRecordList));
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
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            column.width = (column.field === "administrator" ||column.field === "sortRank")   ? "8em" : "14em";
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

          this.$nextTick(() => {
            this.calculateGridHeight();
            // 元のスクロール位置に移動
            this.$refs.grid.$el.children[1].scrollTop = this.lastScrollTop;
            this.$refs.grid.$el.children[1].scrollLeft = this.lastScrollLeft;
          });
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstUserDisporderMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
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
          getErrorMessage('MstUserDisporderMainComponent.vue', 'findFacilityList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
    },
    setFacilitylistValue() {
      this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
    },
    sortBtnClick() {
      this.isSortMode = true;
      this.sort();
    },

    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        // グリッドが表示されていない、またはダミーデータの場合は処理終了
        const gridHeader = this.$refs.grid.$el.firstChild;
        if (
          gridHeader.textContent === " " ||
          gridHeader.textContent === "code"
        ) {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");

        // 列が存在しない場合は処理しない
        if (this.$refs.grid.$el.lastChild.lastChild.tBodies != null) {
          const tbodyc = this.$refs.grid.$el.lastChild.lastChild.tBodies[0]
            .children;
          for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
            const currentTrc = tbodyc[rwCount].children;
            // 並び順の色変更
            this.changeSortColor(currentTrc);
          }
        }
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
    async onSave(ev){
      this.editingFlg = false;
      const initMasterRecord = this.initMasterRecordList.data.find(item => {
        return item.userId === ev.model.userId;
      });
      const editField = Object.keys(ev.values)[0];
      const editedValue = ev.values[editField];
      const isEqual = _.isEqualWith(
        initMasterRecord?.[editField],
        editedValue,
        customComparator
      );
      if (isEqual){
        delete ev.model.dirtyFields[editField];
        if (Object.keys(ev.model.dirtyFields).length === 0) {
          ev.model.set("dirty", false);
          delete ev.model.dirtyFields.dirty;
        }
      }
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      ev.sender.refresh();
      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
      this.hasChanges = ev.sender.dataSource.hasChanges();
    },

    /**
     * 保存ボタン押下時イベント処理
     */
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      this.lastScrollTop = this.$refs.grid.$el.children[1].scrollTop;
      this.lastScrollLeft = this.$refs.grid.$el.children[1].scrollLeft;
      /* add スクロールの位置を維持 楊 end */
      await this.sort();

      // 利用者マスタのmst_selecterのみを更新する
      const mstUserSelecters = this.getMasterRecordList.data
        .filter(e => e.userId > 0 || e.isEditedAtThisTime());
      this.updateMstSelecterByFacilityCd({facilityCd: this.facilitylistValue, request: mstUserSelecters})
      .then(response => {
          this.updateResponse = response.data;
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "マスタ更新が完了しました。"
            title: DIALOG_MESSAGES[12000004].title,
            message: messageFormat(DIALOG_MESSAGES[12000004].message),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });

        // データ再取得
        this.findList();
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstUserDisporderMainComponent.vue', 'saveRecord', error);
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
      if (this.selfScreenName === this.$router.currentRoute.name
          && document.getElementsByTagName("ons-alert-dialog").length === 0) {
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
    this.facilitylistValue = this.getFacilitySwitch
    this.findList();
    // mod マスタ一覧 1･施設切替を可能とする 孔 end
    this.setCondition(this.condition);

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$router.currentRoute.name
    EventBus.$on("refresh", this.refresh);

  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("refresh", this.refresh);
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
}
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.k-grid-toolbar {
  padding: 0.1em 0.3em;
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
</style>
