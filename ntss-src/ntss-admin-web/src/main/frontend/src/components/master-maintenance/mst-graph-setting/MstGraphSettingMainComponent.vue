/**
 * P-Ca9分割グラフ管理マスタメンテナンスデータページ  MainContent
 */
<template>
  <div class='main-content-area master-maintenance-page'>
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
        <div v-if="isMasterUser" class='header-btn-area right'>
          <!-- del マスタ一覧 1･施設切替を可能とする 王 start -->
          <!--          <kendo-dropdownlist-->
          <!--            v-model="facilitylistValue"-->
          <!--            :data-source="facilitys"-->
          <!--            :data-text-field="'facilityName'"-->
          <!--            :data-value-field="'facilityCd'"-->
          <!--            :filter="'contains'"-->
          <!--            @open="onOpenFacility"-->
          <!--            @change="onChangeFacility"-->
          <!--            style="width: 13em;">-->
          <!--          </kendo-dropdownlist>-->
          <!-- del マスタ一覧 1･施設切替を可能とする 王 start -->
        </div>
        <div v-else class='header-btn-area left'>
        </div>
        <kendo-grid id="grid" ref="grid" :class="fontSizeSet" style="clear: both;"
          :data-source="masterRecords"
          :editable="true"
          :selectable="true"
          :reorderable="false"
          :height=kendoGridHeight
          :scrollable="true"
          :beforeEdit=editStart
          :cellClose=editEnd
          class="content-style"
          @save="onSave"
          @databound="onDataBoundKendoGrid">
          <template v-for="(column, index) in columns" >
            <kendo-grid-column v-if="column.title === '設定値'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              :encoded="column.encoded"
              :template="column.colorTemplate"
              :editor="editorInput"
              >
            </kendo-grid-column>
            <kendo-grid-column v-else-if="column.field === 'dispOrder'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              width="4em"
              :format="column.format"
              :values="column.values"
              :encoded="column.encoded"
              :editor="editorInput"
              >
            </kendo-grid-column>
            <kendo-grid-column v-else
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              :encoded="column.encoded"
              >
            </kendo-grid-column>
          </template>
        </kendo-grid>
      </kendo-grid-toolbar>
      <!-- 高さ調整 -->
      <div id="grid-footer">
        <v-ons-row v-show="!isSortMode" width="100%">
          <v-ons-col width="50%">
            <v-ons-button
              class="btn2-cancel denial-btn"
              style="width: auto;"
              @click="cancel"
            >
              キャンセル
            </v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="btn1-execute registration-btn"
              style="width: auto;"
              :disabled="!isChanged"
              @click="saveRecord"
            >
              保存
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
      <message-dialog
        v-if="isDialogVisible"
        :visible.sync="isDialogVisible"
        :message-cd="messageCd"
        :string-params="stringParams"
        type="1"
      />
    </div>
  </div>
</template>

<script>
import $ from "jquery";
import _ from "underscore";
import moment from "moment";
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { EventBus } from "@/eventBus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import PatGroup from "@/apis/pat-group";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
//FNSI-修正 設定値の大小チェック対応 Huangxl add start
import {
  settingErrorMessage
} from "@/apis/mst-graph-setting-maintenance";
//FNSI-修正 設定値の大小チェック対応 Huangxl add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import { cloneDeep, isEqual } from "lodash";

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

      // DB取得個別ドロップダウンリスト表示項目
      kendoGridDrop:{
        mstExamItemList: null,
        patGroupList: null
      },
      isDialogVisible: false,
      stringParams: null,
      messageCd: null,
      isSortChacked: false,

      delUserId: -1,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      //ソートはしないが共通画面仕様で使うため設定
      isSortMode: false,
      isSorted : false,
      //自画面の名称
      selfScreenName: "",
      // 表示権限ユーザー
      userType: "",
      //変更前の施設
      prevFacilityCd: "",
      lastscrollTop: 0,
      lastscrollLeft: 0,
      iosFlg: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      // 初期値退避用オブジェクト
      originalDataSource: null,
    };
  },
  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", ["getFacilityCd"]),

    heightStyles() {
      const mobileHeader = this.isMobileDevice ? 32 : 0;
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight - mobileHeader}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
    ...mapGetters("mst-graph-setting", {
      getFacilityList: "getFacilityList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getEditRecord: "getEditRecord",
      getMasterRecordList: "getMasterRecordList", // add #10198 検索した状態で保存すると保存が完了しない 宮崎
      getUpdateRecordList: "getUpdateRecordList"
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
      return this.getFilteredMasterRecordList;
    },
    isChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        // add 9462 P-Ca９分割グラフ設定マスタのコンバートが正しくない zhao start
        this.kendoValidator !== undefined &&
        // add 9462 P-Ca９分割グラフ設定マスタのコンバートが正しくない zhao end
        (data.filter(row => row.operation > 0).length ||
          this.isSorted ||
          !this.kendoValidator.validate())
      );
    },

    editRecord(){
      return this.getEditRecord;
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
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
    ...mapActions("multi-modal", [
      "showUserMasterIdReset",
      "showUserMasterAuthFunction"
    ]),
    ...mapActions("mst-graph-setting", [
      "getGraphSettingDataList",
      "edit",
      "setEditRecord",
      "facilityList",
      "setCondition",
      "setUserData",
      "setMasterRecordList",
      "setUserType",
      "getDoctorsAtFacility",
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
          (this.isDispMenu === 1
            ? document.getElementById("footer-menu").clientHeight
            : 0) + 5;
        this.kendoGridToolbarHeight = wh - hh - fmh - 10;
        this.kendoGridToolbarHeight =
          this.kendoGridToolbarHeight < 340 ? 340 : this.kendoGridToolbarHeight;

        const gfh = document.getElementById("grid-footer").clientHeight;
        const hbh = document.querySelector(".header-btn-area").clientHeight;
        this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + hbh);
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

    // マスタ一覧のデータを取得
    async findList() {
      // スクロールの位置を維持
      /* mod スクロールの位置を維持 楊 start */
      // let scrollTop = 0;
      // let scrollLeft = 0;
      // if(this.$refs.grid != null){
      //   scrollTop = this.$refs.grid.$el.children[1].scrollTop;
      //   scrollLeft = this.$refs.grid.$el.children[1].scrollLeft;
      // }
      /* mod スクロールの位置を維持 楊 end */
      // 設定値リストのうちDB参照系をコールして再取得
      await this.setkendoGridDropList();

      // apiをコールして施設設定マスタの値を取得
      this.getGraphSettingDataList(this.facilitylistValue)
        .then(async response => {
          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach(column => {
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
          });
          this.columns = toFunction;
          // 画面表示項目と値格納項目の分離
          // mod #10198 検索した状態で保存すると保存が完了しない 宮崎 start
          this.getMasterRecordList.data.forEach(columnData=> {
            if(columnData.inputType === 4){
              if (columnData.graphSettingNo === "2" || columnData.graphSettingNo === "3") {
                columnData.optionValue = JSON.stringify(this.kendoGridDrop.mstExamItemList);
              }
              if (columnData.graphSettingNo >= "33" && columnData.graphSettingNo <= "42") {
                columnData.optionValue = JSON.stringify(this.kendoGridDrop.patGroupList);
              }
              let jsonData = $.parseJSON(columnData.optionValue);

              let matchData = jsonData.filter(function(item){
                if(item.id == columnData.value) return true;
              });
              if (matchData.length > 0) {
                columnData.dispValue = matchData[0].name;
              } else if (jsonData.length > 0){
                columnData.dispValue = jsonData[0].name;
              }
            } else {
              columnData.dispValue = columnData.value;
            }
          });
          this.setMasterRecordList(this.getMasterRecordList);
          // mod #10198 検索した状態で保存すると保存が完了しない 宮崎 end

          // 初期値退避用オブジェクトに検索結果をディープコピー
          this.originalDataSource = cloneDeep(this.getMasterRecordList.data);

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 設定説明列の幅を拡張するように指定
            column.width = column.field === "description" ? "24em" : "14em";
            column.encoded = column.field === "description" ? false : true;
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && column.dataType === "string" && column.field === "name") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 16 : column.width * 16
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
          });
          // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          this.columns.unshift({
            title: " ",
            field: "dummy",
            hidden: false,
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });
          // 色カラムのテンプレート生成
          // mod 10878 P-Ca9分割グラフ設定マスタで検査マスタ指定が検索で選択できない zhao start
          this.columns.filter(column => column.field === "dispValue")
            .forEach(column => {
              column.colorTemplate = (dataItem) => {
                let value = dataItem[`${column.field}`];
                let inputType = dataItem[`inputType`];
                if (!value) value = "";
                return value.toString().startsWith('#') && inputType == 1 ? `<div style='background-color: ${value}; width: 4em;'>&nbsp;</div>` : this.$sanitize(value);
              }
            });
          // mod 10878 P-Ca9分割グラフ設定マスタで検査マスタ指定が検索で選択できない zhao end
          // カラム幅等初期調整
          // 編集モードによって並び順項目の表示・非表示を切り替える（この画面ではソート順変更の変更はしない）
          // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
          const sortRankIndex = this.columns.findIndex(
            col => col.field === "sortRank"
          );

          if (sortRankIndex >= 0) {
            this.columns[sortRankIndex].hidden = true;
            const dummyIndex = this.columns.findIndex(
              col => col.field === "dummy"
            );
            if (dummyIndex >= 0) {
              this.columns[dummyIndex].hidden = false;
            }
          }

          this.$nextTick(() => {
            this.calculateGridHeight();
            // 元のスクロール位置に移動
            /* mod スクロールの位置を維持 楊 start */
            this.$refs.grid.$el.children[1].scrollTop = this.lastscrollTop;
            this.$refs.grid.$el.children[1].scrollLeft = this.lastscrollLeft;
            setTimeout(() => {
              this.lastScrollTop = 0;
              this.lastScrollLeft = 0;
            }, 1000);
            /* mod スクロールの位置を維持 楊 end */
          });
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstGraphSettingMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response && error.response.status === 400) {
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
          getErrorMessage('MstGraphSettingMainComponent.vue', 'findFacilityList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          alert(error);
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
    },
    setFilterCondition(condition) {
      this.condition.userType = this.getStateUserAccountInfo.userType;
      this.condition.recordName = condition.recordName;
    },
    setFacilitylistValue() {
      this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
    },
    /**
     * グラフ設定項目
     * X,Y軸検査マスタ指定
     */
    async findExamList() {
      const requestParam = {
        facilityCd: this.getFacilityCd
      };
      const [
        mstExamItem
      ] = await Promise.all([
        ApiHelper.get("/mstInfo/mstExamItem", requestParam)
      ]);
      return mstExamItem.data.filter(item=>item.isDel== "0" && item.isDisp=="1");
    },

    async setkendoGridDropList(){
      const mstExamItemResponse = await this.findExamList();
      let examItemList = [{id: "0", name: "未登録"}];
      mstExamItemResponse.forEach(examItem => {
        examItemList.push({
          id: `${examItem.examItemCd}`,
          name: examItem.examItemName
        });
      });
      this.kendoGridDrop.mstExamItemList = examItemList;

      const patGroupListResponse = await PatGroup.list(this.getFacilityCd);
      let patGroupList = [{id: "0", name: "未登録"}];
      patGroupListResponse.data.patGroupInfo.forEach(patGroup => {
        patGroupList.push({
          id: `${patGroup.patGroupCd}`,
          name: patGroup.patGroupName
        });
      });
      this.kendoGridDrop.patGroupList = patGroupList;
    },
    onOpenFacility(e) {
      //変更前の施設を取得
      this.prevFacilityCd = e.sender._old;
    },
    onChangeFacility(e) {
      if(this.prevFacilityCd != e.sender._old) {
        if (this.isChanged){
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
                // 選択した施設を元に施設設定一覧の取得
                this.facilitylistValue = newFacilityCd;
                this.findList();
              } else {
                // 変更前の施設を設定する
                this.facilitylistValue = this.prevFacilityCd;
              }
            }
          });
        } else {
          // 選択した施設を元に施設設定一覧の取得
          this.facilitylistValue = e.sender._old;
          this.findList();
        }
      }
    },

    editBackgroundColor() {
      this.$nextTick(() => {
        const gridHeader = this.$refs.grid.$el.firstChild;
        if (gridHeader.textContent === " ") {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");

        // グリッドにレコードがなければ処理終了
        if (!this.$refs.grid.$el.lastChild.lastChild.tBodies) {
          return;
        }

        const tbodyc = this.$refs.grid.$el.lastChild.lastChild.tBodies[0]
          .children;
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;

          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc);

          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, edited, false);
        }
      });
    },
    changeEditColor(currentTrc) {
      let edited = false;
      // 変更されたセルの文字色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount]) &&
          clCount !== this.getColumnIndex("sortRank")
        ) {
          currentTrc[clCount]?.classList?.add("master-edited-cell");
          edited = true;
        }
      }
      return edited;
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains("k-dirty-cell");
    },
    changeRowColor(currentTrc, edited, deleted) {
      // 並び順より後の項目の背景色を変更
      if (edited || deleted) {
        const addClass = deleted ? "master-deleted-row" : "master-edited-row";

        for (
          let clCount = this.getColumnIndex("sortRank") + 1;
          clCount < currentTrc.length;
          clCount++
        ) {
          currentTrc[clCount]?.classList?.add(addClass);
        }
      }
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },

    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      this.lastscrollTop = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop;
      this.lastscrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft;
      /* add スクロールの位置を維持 楊 end */
      // 必須入力チェック
      if (!this.isFilledRequired()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // masterListの表示値から登録値を再設定(ドロップダウンリストの表示と値を再設定)
      //画面表示項目と値格納項目の再分離
      this.getMasterRecordList.data.forEach(columnData=> {
        if(columnData.inputType === 4 || columnData.inputType === 5 || columnData.inputType === 9){
          //4:ドロップダウンリスト時
          let jsonData = $.parseJSON(columnData.optionValue);

          let matchData = jsonData.filter(function(item){
            if(item.name == columnData.dispValue && columnData.val && columnData.val == item.id) return true;
          });
          if(matchData.length > 0){
            columnData.value = matchData[0].id;
          }

        }else if (columnData.inputType === 3){
          //3:ON/OFF設定時(トグル不可のためドロップダウンリストで代替)
          let jsonData = [{"id":"0", "name":"OFF"},{"id":"1", "name":"ON"}];
          let matchData = jsonData.filter(function(item){
            if(item.name == columnData.dispValue ) return true;
          });
          columnData.value = matchData[0].id;

        }else{
          //2:数値入力 1:テキスト入力時
          columnData.value = columnData.dispValue;
        }
      });
      this.setMasterRecordList(this.getMasterRecordList); // mod #10198 検索した状態で保存すると保存が完了しない 宮崎
      //FNSI-修正 設定値の大小チェック対応 Huangxl add start
      if (!this.settingValidation()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }
      //FNSI-修正 設定値の大小チェック対応 Huangxl add end
      // 登録用項目一覧
      const keys = [
        "graphSettingNo",
        "value"
      ];

      // 編集中のレコードを取得
      const insertRecords = [];
      for (const record of this.getUpdateRecordList) {
         if (record.operation === 2) {
           //更新対象データ
            insertRecords.push(record);
        }
      }

      // 登録日時・更新日時用の現在日時
      const now = moment().format("YYYY-MM-DDTHH:mm:ss.SSSZ");

      const serializedInsertRecords = insertRecords.map(record =>
        JSON.stringify({
          ..._.pick(record, keys),
          facilityCd: this.facilitylistValue,
          regDate: now,
          upDate: now
        })
      );

      //登録更新用レコードの作成
      const editRecord = {
        insertRecord: serializedInsertRecords
      };

      // apiをコールして値を保存
      await ApiHelper.put("/master_maintenance/saveMstGraphSetting", editRecord).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstGraphSettingMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          throw new Error(error);
        }
      );

      this.$ons.notification.alert({
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // title: "更新完了",
        // message: "マスタ更新が完了しました。"
        title: DIALOG_MESSAGES[12000004].title,
        message: messageFormat(DIALOG_MESSAGES[12000004].message),
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      });

      await this.findList();

      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },
    /**
     * @description 必須項目チェック
     * @summary 未入力の必須項目があったらダイアログを表示する
     * @returns {Boolean} true: 未入力なし, false: 未入力あり
     */
    isFilledRequired() {
      if (
        this.getUpdateRecordList.some(
          item => item.dispValue === null || item.dispValue === ""
        )
      ) {
        this.isDialogVisible = true;
        this.messageCd = 20010002;
        this.stringParams = ["設定値"];
        return false;
      }
      return true;
    },

    //FNSI-修正 設定値の大小チェック対応 Huangxl add start
    /**
     * 設定不備の条件
     */
    settingValidation() {
      // mod #10198 検索した状態で保存すると保存が完了しない 宮崎 start
      if (this.getUpdateRecordList != null) {
        let graphSettings = [];
        graphSettings.push({
          limitUpperThresholdX: this.getUpdateRecordList[4].value,
          limitLowerThresholdX: this.getUpdateRecordList[5].value,
          limitUpperThresholdY: this.getUpdateRecordList[8].value,
          limitLowerThresholdY: this.getUpdateRecordList[9].value,
          limitLowerX: this.getUpdateRecordList[6].value,
          limitLowerY: this.getUpdateRecordList[10].value,
          limitUpperX: this.getUpdateRecordList[3].value,
          limitUpperY: this.getUpdateRecordList[7].value,
        });
        // mod #10198 検索した状態で保存すると保存が完了しない 宮崎 end
        let errorStatus = settingErrorMessage(graphSettings);
        if (errorStatus) {
          this.$ons.notification.alert({
            title: "",
            message: errorStatus,
          });
          return false;
        }
        return true;
      }
    },
    //FNSI-修正 設定値の大小チェック対応 Huangxl add end

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
    },

    /**
     * @description 編集時、テキストボックスをDB指定の入力フィールドへ変換
     * @summary inputType 1.テキストボックス 2.数値用テキストボックス 3.ドロップダウンリスト(ON/OFF選択用) 4.ドロップダウンリスト(DB設定項目の選択)
     * @param container grid生成情報
     * @param data DB取得値
     */
    editorInput(container, data) {
      if (data.model.inputType == 4 || data.model.inputType == 5 || data.model.inputType == 9 ) {
      data.model.dispValue = data.model.val ? data.model.val : data.model.value;
      $(`<input class="k-textbox" name="${data.field}"/>`)
        .appendTo(container)
        .kendoDropDownList({
          dataSource: $.parseJSON(data.model.optionValue),
          dataTextField: "name",
          dataValueField: "id",
          change:function(e){
            //mod 10878 P-Ca9分割グラフ設定マスタで検査マスタ指定が検索で選択できない zhao start
            //data.model["val"] = JSON.parse(data.model.optionValue)[e.sender.selectedIndex].id
            //data.model.dispValue = JSON.parse(data.model.optionValue)[e.sender.selectedIndex].name
            data.model["val"] = e.sender._valueBeforeCascade
            data.model.dispValue = e.sender._oldText
            //mod 10878 P-Ca9分割グラフ設定マスタで検査マスタ指定が検索で選択できない zhao end
          },
          filter: "contains",
        })
        .blur(() => {
          const value = data.model["val"] || data.model["value"]
          const optionValue = JSON.parse(data.model.optionValue).find(e => e.id === value)
          if (optionValue && optionValue.name) {
            data.model.dispValue = optionValue.name
          }
        });

      }else if(data.model.inputType == 3){
        $(`<input class="k-textbox" name="${data.field}"/>`)
          .appendTo(container)
          .kendoDropDownList({
            dataSource: [{"id":"0", "name":"OFF"},{"id":"1", "name":"ON"}],
            dataTextField: "name",
            dataValueField: "name"
          });

      }else if(data.model.inputType == 2){
        // mod #5589 2023/04/10 数値IFのスタイル全不正 林峻峰 start
        // var numberScope = $.parseJSON(data.model.optionValue);
        // $(`<input class="k-numerictextbox" name="${data.field}"/>`)
        //   .appendTo(container)
        //   .kendoNumericTextBox({
        //     min: -9999999,
        //     max: 9999999
        //   });
        let strinput= `<input id="myInputNumber" type="number" style="text-align:right" name="${data.field}"/>`;
        let parameterMin = -9999999
        let parameterMax = 9999999
        let parameterStep = 1
        let parameter = {step: parameterStep, format: "n0"}
        parameter.spin = ()=> {
          let value = $('#myInputNumber').data('kendoNumericTextBox').value()
          // 数値範囲内かどうかの確認
          if (value > parameterMax) {
            $('#myInputNumber').data('kendoNumericTextBox').value(parameterMin)
          } else if (value < parameterMin) {
            $('#myInputNumber').data('kendoNumericTextBox').value(parameterMax)
          }
          document.getElementById('grid').onmousewheel = () => {
            return true
          }
        }
        parameter.change = (e)=> {
          let value = e.sender._value
          // 数値範囲内かどうかの確認
          if (value > parameterMax) {
            data.model[data.field] = parameterMax
          } else if (value <  parameterMin) {
            data.model[data.field] = parameterMin
          }
          document.getElementById('grid').onmousewheel = () => {
            return true
          }
        }
        $(strinput).appendTo(container).kendoNumericTextBox(parameter);
        this.$nextTick(() => {
          document.getElementById('grid').onmousewheel = () => {
            return false
          }
          $('#myInputNumber').prev().attr('type','number')
          $('#myInputNumber').data('kendoNumericTextBox').element.on("mousewheel", (event)=>{
            let delta = (event.originalEvent.wheelDelta && (event.originalEvent.wheelDelta > 0 ? 1 : -1)) ||
                        (event.originalEvent.detail && (event.originalEvent.wheelDelta > 0 ? -1 : 1))
            let value = parseFloat($('#myInputNumber').data('kendoNumericTextBox').value())
            if (delta > 0) {
              // 滑ります
              value += parameterStep
            } else {
              // 下がります
              value -= parameterStep
            }
            // 数値範囲内かどうかの確認
            if (value > parameterMax) {
              value = parameterMin
            } else if (value <  parameterMin) {
              value = parameterMax
            }
            $('#myInputNumber').data('kendoNumericTextBox').value(value)
          })
          $('#myInputNumber').data('kendoNumericTextBox').element.on("blur", () => {
            document.getElementById('grid').onmousewheel = () => {
              return true
            }
            //6954 【EOL対応内部】【P-Ca9分割グラフ設定マスタ】报错 start zhao
            if($('#myInputNumber').data('kendoNumericTextBox')){
            $('#myInputNumber').data('kendoNumericTextBox').trigger('change')
            }
            //6954 【EOL対応内部】【P-Ca9分割グラフ設定マスタ】报错 end zhao
          })
        })
        // mod #5589 2023/04/10 数値IFのスタイル全不正 林峻峰 end
      }else if(data.model.inputType == 1){
        if(data.model.dispValue.toString().startsWith('#')) {
          const dummyField = $(`<input type = "color" data-bind="value:dispValue" width: 4em; />`).appendTo(container);
          this.$nextTick(() => {
            dummyField.click();
          });
        }else{
          $(`<textarea name="${data.field}" class="k-valid k-textarea" style="font-size: 1.0em;resize: vertical;width: 100%;height: 100%;max-height: 65vh;"/>`).appendTo(container)
          // $(`<input type="text" class="k-input k-textbox k-valid" name="${data.field}" maxlength="128" data-bind="value:dispValue"/>`).appendTo(container)
        }

      }else if(data.model.inputType == 6){
        $('<textarea data-text-field="Label" class="k-textbox k-valid" data-value-field="Value" data-bind="value:dispValue" style="width: ' + (container.width() - 10) + 'px;height:' + (container.height() - 12) + 'px;margin-top:10px;margin-bottom:10px" />').appendTo(container);

      }else{
        this.editingFlg = false;
        $(`<label>${data.model.value}</label>`).appendTo(container);
      }
    },
    onSave(ev) {
      this.editingFlg = false;
      this.edit({ editRecord: ev.model, isSortMode: false });

      // 初期値と現在値を比較し、差分が無い場合はdirty状態を解除
      this.handleUnchangedState(ev);

      ev.sender.refresh();
      if (ev.model.operation === 1) {
        ev.model.edited = true;
      }
      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
    },
    /**
     * 編集終了時に、初期値とセルの値が同一か判定し、同一の場合はGrid行のdirty状態を解除する
     * @param {Object} e - KendoGridのイベント引数
     */
    handleUnchangedState(e) {
      const { graphSettingNo, inputType } = e.model;
      const originalItem = this.originalDataSource.find((item) => {
        return item.graphSettingNo === graphSettingNo;
      });

      // 編集フィールド取得
      const editField = Object.keys(e.values)[0];
      // 現在値取得
      const editedValue = e.values[editField];
      // 初期値取得(プルダウン項目の場合は非表示のvalueカラムから取得)
      const originalValue = [4, 5, 9].includes(Number(inputType))
        ? originalItem?.['value']
        : originalItem?.[editField];

      // 初期値と現在値を比較
      const isUnchanged = isEqual(originalValue, editedValue);

      if (isUnchanged) {
        // 初期値と現在値に差が無い場合、行のdirty状態を解除
        e.sender.dataSource.cancelChanges(e.model);
        delete e.model.operation;
      }
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    }
  },
  created() {
    this.setUserType(this.getStateUserAccountInfo.userType);
    this.setLoadingScreenVisible(true);
    // add マスタ一覧 1･施設切替を可能とする 王 start
    // this.findFacilityList();
    this.facilitylistValue = this.getFacilitySwitch
    this.findList();
    // add マスタ一覧 1･施設切替を可能とする 王 end
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
    this.selfScreenName = this.$router.currentRoute.name;
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
  beforeDestroy() {
    EventBus.$off("refresh", this.refresh);
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
.content-style >>> .k-grid-content{
  white-space: pre-wrap;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
</style>
