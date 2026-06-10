<template>
  <div class="main-content-area master-maintenance-page">
    <div
      v-kendo-validator="kendoValidatorSetup"
      class="ntss-list"
      :style="ntssListStyles"
    >
      <kendo-grid-toolbar
        class="k-grid-toolbar kendo-grid-toolbar-style"
        :style="heightStyles"
      >
        <div class="header-btn-area right">
          <v-ons-button
            v-show="!isSortMode && isAllowAddRecord"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            style="float:left"
            @click="showMasterModal"
          >
            追加
          </v-ons-button>
          <v-ons-button
            v-show="!isSortMode && isAllowSort"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="toRankEditBtnClick()"
          >
            並び順表示
          </v-ons-button>
          <v-ons-button
            v-show="isSortMode && isAllowSort"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="sortBtnClick()"
          >
            反映
          </v-ons-button>
        </div>
        <!-- ソート後グリッド表示 -->
        <span v-show="isSortChacked">
          <kendo-grid :class="fontSizeSet"
            id="grid-font-size"
            ref="grid"
            :data-source="masterRecords"
            :editable="true"
            :selectable="true"
            :reorderable="false"
            :height="kendoGridHeight"
            :scrollable="true"
            :beforeEdit=editStart
            :cellClose=editEnd
            @save="onSave"
            @databound="onDataBoundKendoGrid">
          >
            <template v-for="(column, index) in columns">
              <!-- 施設選択モーダル列 -->
              <kendo-grid-column
                v-if="column.title === '施設選択'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :attributes="{ class: 'btn3-kendo-normal' }"
                :locked="column.locked"
                :editable="column.editable"
                :minwidth="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '変更', click: showMasterEditModal }"
              />
              <!-- 削除列はeditorを適用 -->
              <kendo-grid-column
                v-else-if="column.field === 'isDel'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="isDelEditor"
              />
              <kendo-grid-column
                v-else
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
              />
            </template>
          </kendo-grid>
        </span>
      </kendo-grid-toolbar>
      <div id="grid-footer">
        <v-ons-row v-show="!isSortMode" width="100%">
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
    </div>

    <message-dialog
      v-if="isDialogVisible"
      :visible.sync="isDialogVisible"
      :message-cd="messageCd"
      :string-params="stringParams"
      type="1"
    />
  </div>
</template>

<script>
import $ from "jquery";
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  components: {
    "message-dialog": messageDialog
  },
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
  data() {
    return {
      recordList: [],
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
        recordName: "",
        includeDeleted: false
      },
      updateResponse: {
        isSuccess: false,
        errorMessage: ""
      },
      isSortMode: false,
      isSorted: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      isDialogVisible: false,
      stringParams: null,
      messageCd: null,
      isSortChacked: false,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      // 自画面の名称
      selfScreenName: "",
      lockedColumnsWidth: 0,
      lastScrollTop: 0,
      lastScrollLeft: 0
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      getFacilitySwitch: "getFacilitySwitch",
      isRecordModified: "isRecordModified"
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),

    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
    masterRecords() {
      if (this.getMasterRecordList.length !== 0) {
        // フィルター処理
        this.filterRecords(this.getFilteredMasterRecordList.data);
        if (!this.isSortChacked) {
          // storeからデータ取得後施設コードでソート
          this.sortRecords(this.getFilteredMasterRecordList.data);

          // 表示順を更新するため、storeに設定
          this.setMasterRecordList(this.getFilteredMasterRecordList);
          // ソート後グリッドを表示
          this.showDisplay();
        }
      }

      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (data.filter(row => row.operation > 0).length ||
          this.isRecordModified ||
          !this.kendoValidator.validate())
      );
    }
  },
  watch: {
    windowHeight() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    windowWidth() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    isDispMenu() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    getFontSize() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    columns:function(val){
      this.$nextTick(function(){
        if (val.length > 1)
        this.setLoadingScreenVisible(false);
      });
    }
  },

  created() {
    this.setLoadingScreenVisible(true);
    this.calculateColumnsWidth();
    this.loadGridData();

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.androidFlg = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
  },
  // add 性能改善メモリ不足 shan end
  mounted() {
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
  },

  updated() {
    // オブジェクトの描画前に実行すると発生するエラーを抑制
    if (this.$refs.grid.$el.firstChild.classList != null) {
      // Storeの更新等で画面が再描画された場合に背景色を変更
      this.editBackgroundColor();
    }
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
  },

  methods: {
    ...mapActions("multi-modal", [
      "showMasterEdit",
      "showMstFavoriteFacilityModal"
    ]),
    ...mapActions("master-maintenance", [
      "findRecordListByFacilityCdWithSql",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordListByFacilityCd",
      "setComparisonRecordModel",
      "setEditRecord",
      "editRecordBeEmpty"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),

    /**
     * @description 削除列のkendo editor
     */
    isDelEditor(container, data) {
      if (data.model.operation === 1) {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 新規レコードはlabelにして編集させない
        $(`<label></label>`).appendTo(container);
      } else {
        // 既存レコードは編集可
        $(`<input class="k-textbox" name="${data.field}" />`)
          .appendTo(container)
          .kendoDropDownList({
            dataSource: [
              { text: "", value: "0" },
              { text: "削除", value: "1" }
            ],
            dataTextField: "text",
            dataValueField: "value"
          });
      }
    },
    // グリッドのデータ再表示
    gridDataRefresh() {
      const grid = this.$refs.grid;
      // grid.dataSource = [];
      grid.dataSource = this.masterRecords;
    },

    // マスタ一覧のデータを取得
    async findList() {
      // apiをコールして値を取得
      // add マスタ一覧 1･施設切替を可能とする 王 facilityCd -> getFacilitySwitch
      // this.findRecordListByFacilityCdWithSql(this.facilityCd)
      this.findRecordListByFacilityCdWithSql(this.getFacilitySwitch)
        .then(response => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          if (response.data.columns.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message:
              //   "マスタ定義にカラム情報が登録されていません。<BR>カラム情報を登録してください。",
              title: DIALOG_MESSAGES[12000001].title,
              message: messageFormat(DIALOG_MESSAGES[12000001].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              callback: () => {
                this.cancel();
              }
            });
          }
          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach(column => {
            // 初期表示時の編集可否を退避
            column.originalEditable = column.editable;
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column.width = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            column.width = column.field === "isDisp" ? "9em" : (this.columnWidth + "em");
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            if (column.title === "施設選択") {
              column.width = "6em";
            }
            //よく使う施設マスタで施設を追加した時に高さが異なる修正 #7292 xmj start
            if (column.title === "施設名") {
              column.width = "20em";
            }
            //よく使う施設マスタで施設を追加した時に高さが異なる修正 #7292 xmj end
          });

          // del redmine 4531 よく使う施設マスタで並び順変更をすると施設名が見えなくなる 宋qy start
          // if (this.androidFlg || this.iosFlg) {
          //   this.lockedColumnsWidth = 15;
          // } else {
          //   this.lockedColumnsWidth = 20;
          // }
          // del redmine 4531 よく使う施設マスタで並び順変更をすると施設名が見えなくなる 宋qy end

          // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          this.columns.unshift({
            title: " ",
            field: "dummy",
            hidden: false,
            locked: true,
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            /* add スクロールの位置を維持 楊 start */
            this.$refs.grid.$el.children[1].scrollTop = this.lastScrollTop;
            this.$refs.grid.$el.children[1].scrollLeft = this.lastScrollLeft;
            /* add スクロールの位置を維持 楊 end */
          });
        })
        .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage('MstFavoriteFacilityMainComponent.vue', 'findList', error);
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        });
    },

    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      this.lastScrollTop = this.$refs.grid.$el.children[1].scrollTop;
      this.lastScrollLeft = this.$refs.grid.$el.children[1].scrollLeft;
      /* add スクロールの位置を維持 楊 end */
      // 必須チェック
      if (!this.isFilledRequired()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      const updRecLst =
        this.getUpdateRecordList
          .filter(updRec => {
            // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 start
            // 施設コード/医療機関コード の場合
            if (!(updRec.operation === 1 && !(updRec.favoriteFacilityCd || updRec.medicalInstitutionCd))) return true;
            // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 end
          })
          .map(updRec => {
            return {
              code: updRec.code,
              favoriteFacilityCd: updRec.favoriteFacilityCd,
              // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 start
              medicalInstitutionCd: updRec.medicalInstitutionCd,
              // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 end
              sortRank: updRec.sortRank,
              sortInputTime: updRec.sortInputTime,
              isDisp: updRec.isDisp,
              operation: updRec.operation
            }
          });

      // add マスタ一覧 1･施設切替を可能とする 王 facilityCd -> getFacilitySwitch
      // this.updateRecordListByFacilityCd({facilityCd: this.facilityCd, request: updRecLst})
      this.updateRecordListByFacilityCd({facilityCd: this.getFacilitySwitch, request: updRecLst})
        .then(response => {
          this.updateResponse = response.data;
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "マスタ更新が完了しました。"
            title: DIALOG_MESSAGES[12000004].title,
            message: messageFormat(DIALOG_MESSAGES[12000004].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });

          this.isSorted = false;
          this.findList();
          // 画面表示フラグ
          this.isSortChacked = false;

          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstFavoriteFacilityMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        });
    },

    /**
     * @description 必須項目チェック
     * @summary 未入力の必須項目があったらダイアログを表示する
     * @returns {Boolean} true: 未入力なし, false: 未入力あり
     */
    isFilledRequired() {
      if (
        this.getUpdateRecordList.some(
          item => (item.favoriteFacilityCd === null || item.favoriteFacilityCd === "") && item.operation !== 1
          // 医療機関コード の場合
          // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 start
          && (item.medicalInstitutionCd === null || item.medicalInstitutionCd === "")
          && item.operation !== 1
          // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 end
        )
      ) {
        this.isDialogVisible = true;
        this.messageCd = 30000004;
        this.stringParams = ["施設を選択してください。"];
        return false;
      }
      return true;
    },
    showMasterEditModal(e) {
      this.showMasterModal();

      /**
       * 「設定」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      let code = selectedRowItem.code;

      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
        code = this.getMasterRecordList.data[0].code;
      }

      // プロパティを正規化する。
      const normalizedItem = this.normalization(selectedRowItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);
    },
    showMasterModal() {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $("div.k-grid-content")[0];
      this.scrollPosition.top = grid.scrollTop;
      this.scrollPosition.left = grid.scrollLeft;

      // モーダルを表示
      this.showMstFavoriteFacilityModal();
    },
    onCloseMasterEditModal(facilities) {
      // #9863 facilities.forEach is not a function 横展開2 linjunfeng start
      // if (facilities && facilities.length > 0) {
        if (facilities && typeof facilities === "object" &&  facilities.length > 0) {
        facilities.forEach(facility => this.addRow(facility));
      }
      // #9863 facilities.forEach is not a function 横展開2 linjunfeng end
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
      });
      // Androidでスクロール位置が戻らない場合があるのでもう一度設定
      setTimeout(() => {
        this.setScrollPosition(this.scrollPosition);
      }, 1000);
    },
    addRow(record) {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      // 空レコードをストアに登録
      const newRecord = {};
      const fields = this.getMasterRecordList.schema.model.fields;

      // 初期値を設定
      Object.keys(fields).forEach(colName => {
        newRecord[colName] = record ? record[colName] : null;
        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (colName === "sortRank") {
          newRecord[colName] = this.getMaxSortRank() + 1;
        }
      });
      newRecord.edited = true;
      this.lastScrollTop = this.$refs.grid.$el.lastChild.scrollHeight;
      // 画面編集内容をstoreに反映 ※新規レコード追加
      this.edit({ editRecord: newRecord, isSortMode: this.isSortMode });
      // 色変え？
      this.editBackgroundColor();
    },
    /**
     * @description 表示順設定
     * @param {Array}
     */
    sortRecords(records) {
      records.sort((a, b) => {
        // 施設コードでソート
        return a.sortRank - b.sortRank;
      });
    },

    /**
     * @description 画面表示関数
     */
    showDisplay() {
      // 画面表示フラグ
      this.isSortChacked = true;
    },

    loadGridData(){
      // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
      this.findList();
    },

    /**
     * @description フィルター処理
     * @param {Array}
     */
    filterRecords(records) {
      // フィルター処理
      const data = records.filter(item => {
        return (!item.isFavDel || item.isFavDel === "0") && (!item.isSysDel || item.isSysDel === "0");
      });
      // フィルター処理済データの格納
      this.getFilteredMasterRecordList.data = data;
    }
  }
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
  padding: 5px;
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
.k-grid-toolbar span {
  margin: 0;
}

.kendo-grid-toolbar-style >>> .k-grid-header-locked > table {
  border-right-width: 0px;
}
.kendo-grid-toolbar-style >>> .k-grid-header-locked {
  border-right: 1px solid var(--ntss-list-border-color) !important;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  z-index: 1;
  box-shadow: 1px 0px 0px 0px var(--ntss-border-color) !important;
  padding-bottom: 16px;
}
</style>
