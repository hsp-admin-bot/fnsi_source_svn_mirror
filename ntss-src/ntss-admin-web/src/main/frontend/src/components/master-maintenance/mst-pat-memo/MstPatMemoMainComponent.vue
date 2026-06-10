/**
 * 患者メモマスタページ  MainContent
 */
<template>
  <div :class="['main-content-area', { 'no-scroll': isMobileDevice }, 'master-maintenance-page']">
    <div class='ntss-list' :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <div v-if="isMobileDevice" id="grid-header" class="header-btn-area right" style="height: 30px;">
        <v-ons-row style="width: 7em;">
          <v-ons-col width="45%" vertical-align="center">
            <label class="fab-font-color">編集</label>
          </v-ons-col>
          <v-ons-col width="55%" vertical-align="center">
            <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
          </v-ons-col>
        </v-ons-row>
      </div>
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <kendo-grid ref="grid" :class="fontSizeSet"
            :data-source="masterRecords"
            :editable="true"
            :selectable="true"
            :reorderable="false"
            :height=kendoGridHeight
            :scrollable="true"
            :beforeEdit=onBeforeEdit
            :edit=addInputAssist
            :cellClose=editEnd
            class="content-style"
            @save="onSave"
            @databound="onDataBoundKendoGrid">
            <template v-for="(column, index) in columns" >
              <kendo-grid-column v-if="column.field === 'name'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="nameEditor">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.field === 'content'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="contentEditor">
              </kendo-grid-column>
              <kendo-grid-column v-else
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
            </template>
        </kendo-grid>
      </kendo-grid-toolbar>
      <div id="grid-footer">
        <v-ons-row width="100%" v-show="!isSortMode" >
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel button denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute button registration-btn" style="width: auto;" :disabled="!isChanged" @click="beforeSaveRecord">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    <master-csv
      :popoverVisible="masterCsvVisible"
      :popoverTarget="masterCsvTarget"
      @popover-close="prehideCsvPopover"
    />
    <message-dialog
      v-if="isDialogVisible"
      :visible.sync="isDialogVisible"
      :message-cd="messageCd"
      type="5"
      @confirm="setUpdateAllPatFlg"
    />
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import $ from "jquery";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import { ApiHelper } from "@/apis/AxiosHelper";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
    components: {
    "master-csv": MasterCsvComponent,
    "message-dialog": messageDialog
  },
  data() {
    return {
      recordList: [],
      // 初期状態で1列がないとその後の表示が行われないため初期列を定義
      columns: [
        {
          field: "code",
          title: "code",
          hidden: false,
          locked: false,
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
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      mstSynchroApiParams: {
        mstTable: "mst_m_notice",
        deviceEdgeNo: -1
      },
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      //自画面の名称
      selfScreenName: "",
      masterCsvVisible: false,
      masterCsvTarget: null,

      // 修正済み判定用情報(ローカル用)
      comparisonRecordLocalModel: "",
      updatePatMemoInfo: null,

      // ダイアログ関連
      isDialogVisible: false,
      messageCd: null,
      lockedColumnsWidth: 0,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
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
    heightStyles() {
      const mobileHeader = this.isMobileDevice ? 32 : 0;
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight - mobileHeader}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      isRecordModified: "isRecordModified",
      getFacilitySwitch: "getFacilitySwitch"
    }),
    masterRecords() {
      // storeからデータを取得
      let returnData = this.getFilteredMasterRecordList;

      if(returnData.data !== undefined) {

        // ★削除選択で行が消える現象への対処
        // getFilteredMasterRecordListにて、編集中であろうとis_disp=0のレコードを除外してしまうのが原因
        // Redmineのチケット#689:削除選択で行が消える が修正されればここの処理は不要

        // storeからフィルタ前のデータを取得
        const data = this.getMasterRecordList.data;
        // フィルタ前のgetMasterRecordListから、編集中かつis_disp=0のレコードを抽出する
        const editedDeleteData = data.filter(
          data => this.isEdited(data.code) && data.isDisp === "0"
        );
        // 抽出したレコードをgetFilteredMasterRecordListに追加する
        // 同じ番号のレコードがgetFilteredMasterRecordListに無い場合のみ追加する
        for (let deleteData of editedDeleteData) {
          if (returnData.data.filter(data => data.code === deleteData.code).length <= 0) {
            returnData.data.push(deleteData);
          }
        }

        // ★削除選択で行が消える現象への対処 ここまで

        // 削除済み列が下に固まるのを防ぐためソート
        returnData.data.sort(function(a,b){
          if( a.code < b.code ) return -1;
          if( a.code > b.code ) return 1;
          return 0;
        });
      }
      return returnData;
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
        (this.isRecordModified || !this.kendoValidator.validate())
      );
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
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
  methods: {
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "findRecordListByFacilityCd",
      "findColumnInfo",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      "setComparisonRecordModel"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-synchro", ["startMstSynchro"]),
    /**
     * @description 内容列のkendo editor
     */
    nameEditor(container, data) {
      $(`<input type="text" class="k-input k-textbox k-valid" name="${data.field}"/>`).appendTo(container);
    },
    /**
     * @description 内容列のkendo editor
     */
    contentEditor(container, data) {
      // mod redmine4548 列の変化による操作が困難です 孔 start
      $(
        // `<textarea name="${data.field}" class="k-valid k-textarea" style="font-size: 1.0em;resize: vertical;"/>`
        `<textarea name="${data.field}" class="k-valid k-textarea resize-obs-target" style="font-size: 1.0em;resize: vertical;min-height: calc(0.75rem + 2em);width: 100%;height: 100%;max-height: 65vh;"/>`
      ).appendTo(container);
      // this.$refs.grid.kendoWidget().autoFitColumn(
      //   this.columns.findIndex(c => c.field === data.field)
      // );
      // this.calculateGridWidth();
      // mod redmine4548 列の変化による操作が困難です 孔 end
      const resizeObserver = new ResizeObserver(entries => {
        // テキストエリアのリサイズに応じてkendo-gridをリサイズする
        this.calculateGridWidth();
      });
      resizeObserver.observe(document.querySelector('.resize-obs-target'));
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして値を取得
      // add マスタ一覧 1･施設切替を可能とする 王
      // this.findRecordList()
      this.findRecordListByFacilityCd(this.getFacilitySwitch)
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
            column["width"] = column.width ? column.width : "0";
            // No列表示
            column.hidden = column.field === "code" ? false : column.hidden;
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            column.width = column.field === "isDisp" ? "9em" : (this.columnWidth + "em");
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // ※※※※※※※※
            // ここのコードは非常に混乱で、その他部分に影響するですが、再改造しています 徐博
            // 内容列のテキストエリアがはみ出さないように調整
            // column.width = column.field === "content" ? "21em" : (this.columnWidth + "em");
            if (column.field === "content") {
              column.width = "21em";
            }
            if (column.field === "code") {
              column.width = "5em";
            }
            // add 削除の欄が広い 王 start
            // if (column.field === "isDisp")column.width = "8em";
            // add 削除の欄が広い 王 end
            // ※※※※※※※※
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && column.title === "No") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width * 15
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
          });

          this.lockedColumnsWidth = 5;

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
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
          });
          // null値があるか調べて、あったら空欄に変更する
          let records = this.getMasterRecordList;
          for (let record of records.data) {
            if (record.name === null) {
              record.name = "";
            }
          }
          this.setMasterRecordList(records);
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          this.comparisonRecordLocalModel = JSON.stringify(this.getMasterRecordList.data);
          // 色カラムのテンプレート生成
          this.columns.filter(column => column.dataType === "color")
            .forEach(column => {
              column.colorTemplate = (dataItem) => {
                const value = dataItem[`${column.field}`];
                return `<div style='background-color: ${value}; width: 4em;'>&nbsp;</div>`;
              }
            });
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatMemoMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
        });
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    // ダイアログ表示制御
    beforeSaveRecord() {
      // 変更済みセルの確認
      this.updatePatMemoInfo = this.findChangedValue();
      if (this.updatePatMemoInfo !== null) {
        this.isDialogVisible = true;
        this.messageCd = 60000004;
      } else {
        this.isUpdateAllPat = false;
        this.saveRecord();
      }
    },

    // 患者情報に上書きするフラグの設定
    setUpdateAllPatFlg(answer) {
      this.isDialogVisible = false;
      this.isUpdateAllPat = answer === "No";
      this.saveRecord();
    },

    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      this.setLastScroll();
      /* add スクロールの位置を維持 楊 end */
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        r => !(r.operation === 1 && !r.edited)
      );

      // No昇順にソート
      // sortRankをNoと同じ値に書き換える
      for (let data of records.data) {
        data.sortRank = data.code;
      }

      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES["00300006"].title,
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        return;
      }

      if (this.isUpdateAllPat) {
        // 患者情報の患者メモJSONを上書き
        await ApiHelper.post("/patInfo/updatePatMemo", {
          strSql: this.updatePatMemoInfo
          }).catch(
          error => {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage('MstPatMemoMainComponent.vue', 'saveRecord', error);
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            throw new Error(error);
          }
        );
      }

      // null値があるか調べて、あったら空欄に変更する
      let updateRecords = this.getUpdateRecordList
      for (let record of updateRecords) {
        if (record.name === null) {
          record.name = "";
        }
      }

      // apiをコールして値を保存
      // add マスタ一覧 1･施設切替を可能とする 王
      // this.updateRecordList(updateRecords)
      this.updateRecordListByFacilityCd({facilityCd: this.getFacilitySwitch, request: updateRecords})
        .then(response => {
          this.updateResponse = response.data;

          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "マスタ更新が完了しました。"
            title: DIALOG_MESSAGES[12000004].title,
            message: messageFormat(DIALOG_MESSAGES[12000004].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });

          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatMemoMainComponent.vue', 'setUpdateAllPatFlg', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        })
        // 共通ローダー：表示終了
        .finally(() => this.setLoadingScreenVisible(false));
    },
    findChangedValue() {
      let patMemoInfo = null;

      // 初期データ
      const initData = JSON.parse(this.comparisonRecordLocalModel);
      initData.sort(function(a,b){
        if( a.code < b.code ) return -1;
        if( a.code > b.code ) return 1;
        return 0;
      });

      // 編集中データ
      const gridData = this.getMasterRecordList;
      gridData.data.sort(function(a,b){
        if( a.code < b.code ) return -1;
        if( a.code > b.code ) return 1;
        return 0;
      });

      // 編集済みのセルを抽出してSQLを作成する
      for (let idx = 0; idx < gridData.data.length; idx++) {
        // 編集済みかつ編集中データが未削除
        if (this.isEdited(gridData.data[idx].code) && gridData.data[idx].isDisp === "1") {
          // 0始まりのJSON用index
          const jsonIdx = gridData.data[idx].code - 1;

          // タイトル列の編集SQL作成
          if (initData[idx].name !== gridData.data[idx].name) {
            // 空欄の場合は"null"にする（患者情報画面では空欄にするとnullで入力される）
            const convertedName = gridData.data[idx].name === "" ? "null" : `"${gridData.data[idx].name}"`;
            patMemoInfo = patMemoInfo === null ? "pat_memo_info," : patMemoInfo;
            patMemoInfo = `jsonb_set(${patMemoInfo} '{${jsonIdx}, title}', '${convertedName}'),`;
          }
          // 内容列の編集SQL作成
          if (initData[idx].content !== gridData.data[idx].content) {
            // 空欄の場合は"null"に、そうでない場合は改行を文字列"\n"に変換
            const convertedContent = gridData.data[idx].content === "" ? "null" : `"${gridData.data[idx].content.replace(/\r?\n/g, "\\n")}"`;
            patMemoInfo = patMemoInfo === null ? "pat_memo_info," : patMemoInfo;
            patMemoInfo = `jsonb_set(${patMemoInfo} '{${jsonIdx}, content}', '${convertedContent}'),`;
          }
        }
      }
      return patMemoInfo;
    },
    loadGridData() {
      // delete start #9590
      // this.setCondition(this.condition);
      // delete end #9590
      this.findList();
    },
    /**
     * KendoGridデータバインド時イベントハンドラ.
     * 値変更時にスクロール位置が先頭に戻ってしまう問題の対処
     *
     * @param {*} ev イベント
     */
    onDataBoundKendoGrid(ev) {
      // del redmine4548 列の変化による操作が困難です 孔 start
      // this.autoFitGridColumns();
      // del redmine4548 列の変化による操作が困難です 孔 end
      // スクロール位置が先頭でない場合、その位置を保持する
      const scrollTop = ev.sender.content[0].scrollTop;
      const scrollLeft = ev.sender.content[0].scrollLeft;
      if (scrollTop != 0) {
        this.lastScrollTop = scrollTop;
      }
      if (scrollLeft != 0) {
        this.lastScrollLeft = scrollLeft;
      }

      if (this.lastScrollTop != 0 || this.lastScrollLeft != 0) {
        this.$nextTick(() => {
          ev.sender.content[0].scrollTop = this.lastScrollTop;
          ev.sender.content[0].scrollLeft = this.lastScrollLeft;
          setTimeout(() => {
            this.lastScrollTop = 0;
            this.lastScrollLeft = 0;
          }, 1000)
        });
      }
      /* 固定列・可動列の縦スクロール同期 */
      const lockedContent = this.$el.querySelector('.k-grid-content-locked');
      const scrollableContent = this.$el.querySelector('.k-grid-content');
      let isSyncingScroll = false;
      if (lockedContent && scrollableContent) {
        const syncScroll = (source, target) => {
          if (isSyncingScroll) return;
          isSyncingScroll = true;
          target.scrollTop = source.scrollTop;
          isSyncingScroll = false;
        };
        scrollableContent.addEventListener('scroll', () => syncScroll(scrollableContent, lockedContent));
        lockedContent.addEventListener('scroll', () => syncScroll(lockedContent, scrollableContent));
      }
    },
    // del redmine4548 列の変化による操作が困難です 孔 start
    // autoFitGridColumns() {
    //   for (let i = 0; i < this.$refs.grid.kendoWidget().columns.length; i++) {
    //     if (["name", "content"].includes(this.$refs.grid.kendoWidget().columns[i].field)) {
    //       this.$refs.grid.kendoWidget().autoFitColumn(i);
    //     }
    //   }
    // }
    // del redmine4548 列の変化による操作が困難です 孔 end
    onBeforeEdit(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      this.editStart(e);
    },
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.calculateColumnsWidth();
    this.loadGridData();
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$router.currentRoute.name;
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
    this.$nextTick(() => {
      // del redmine4548 列の変化による操作が困難です 孔 start
      // this.autoFitGridColumns();
      // del redmine4548 列の変化による操作が困難です 孔 end
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
    EventBus.$on("refresh", this.refresh);
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
.csv-btn {
  margin-right: 1em;
}
.k-grid-toolbar {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style >>> .k-tooltip.k-tooltip-validation {
  width: auto;
}
.content-style >>> .k-grid-content{
  white-space: pre-wrap;
}
.kendo-grid-toolbar-style >>> .k-grid-content > .k-selectable {
  box-shadow: 1px 0px 0px 0px white;
  border-right: 1px solid transparent;
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
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked::-webkit-scrollbar {
  display: none;
}
.no-scroll {
  overflow-y: unset !important;
}
</style>
