/**
 * 体重計マスタページ  MainContent
 */
<template>
  <div class='main-content-area master-maintenance-page'>
    <div v-if="isShowDetailView">
      <mst-weight-component @close="closeDetailView"/>
    </div>
    <div v-show="!isShowDetailView" class='ntss-list' :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <!-- <div class='weight-scale-area'> -->
        <mst-weight-scale-component ref="scale" :is-mobile-device="isMobileDevice" :allow-edit="allowEdit"/>
        <!-- </div> -->
        <div :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord" @click="addRow()">追加</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left; margin-left: 10px;" v-show="!isSortMode && isAllowAddRecord" @click="copyAdd">コピー追加</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 7em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" class="custom-switch" style="float: left; margin-left: 2px;" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="!isSortMode && isAllowSort" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="isSortMode && isAllowSort" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <kendo-grid ref="grid" :class="fontSizeSet" id="under-grid"
            :data-source="masterRecords"
            :editable="true"
            :selectable="true"
            :reorderable="false"
            :height=kendoGridHeight
            :scrollable="true"
            :beforeEdit=editStart
            :edit=addInputAssist
            :cellClose=editEnd
            @save="onSave"
            @databound="onDataBoundKendoGrid">
            <template v-for="(column, index) in columns" >
              <kendo-grid-column v-if="column.field === '$modalType'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :attributes="{ class: 'btn3-kendo-normal' }"
                :command="{ text: '詳細', click: showMasterEditView }">
              </kendo-grid-column>
              <kendo-grid-column v-else
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
      <div id="grid-footer">
        <v-ons-row width="100%" v-show="!isSortMode" >
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel button denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute button registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
    <master-copy-add
      :popoverVisible="masterCopyAddVisible"
      :popoverTarget="masterCopyAddTarget"
      :copySrcData="copySrcData"
      @added-row="addedRow"
      @popover-close="prehideCopyAddPopover"
    />
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import MstWeightScaleComponent from "@/components/master-maintenance/mst-weight/MstWeightScaleListRecordComponent";
import MstWeightComponent from "@/components/master-maintenance/mst-weight/sub-item/MstWeightComponent";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { roomBedGroup } from "@/functions/mst/MstGetters.js";
import $$ from "jquery";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import MasterCopyAddComponent from "@/components/master-maintenance/MasterCopyAddComponent";
// #11987 2026.02.08 add スケールベッド対応 スケールベッド機能の無効・有効取得 TDC渡辺 start
import {sendRequestGetDefaultSettingDispOrder} from "@/apis/User";
//機能コード
import {

    FUNC_SCALE_BED
  } from "@/constants/function-code";
// #11987 2026.02.08 add スケールベッド対応 スケールベッド機能の無効・有効取得 TDC渡辺 end
/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
  components: {
    "mst-weight-scale-component": MstWeightScaleComponent,
    "mst-weight-component": MstWeightComponent,
    "master-copy-add": MasterCopyAddComponent
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
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      isShowDetailView: false,
      //Android端末で編集中であることを示すフラグ
      isAndroid: false,
      isIOS: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      // add FNSI-データ初期種別と測定値送信間隔の制御 徐 start
      deviceClassName:"田中衡機",
      // add FNSI-データ初期種別と測定値送信間隔の制御 徐 end
      //自画面の名称
      selfScreenName: "",
      facilitylistValue: "",
      // コピー追加 吹き出し用 start
      masterCopyAddVisible: false,
      masterCopyAddTarget: null,
      // コピー追加 吹き出し用 end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      // #11987 2025.11.13 add スケールベッド対応 スケールベッド比較文字列 TDC渡辺 start
      weightTypeNameWeight: "体重計",
      weightTypeNameScaleBed: "スケールベッド",
      // #11987 2025.11.13 add スケールベッド対応 スケールベッド比較文字列 TDC渡辺 end
      // #11987 2026.02.08 add スケールベッド対応 スケールベッド機能の無効・有効取得 TDC渡辺 start
      // sys_function.disp_order を取得
      defaultSettingObj: [
        {
          componentName: "defScaleBedSet",
          ref: "scaleBedSettingCard",
          funcCode: FUNC_SCALE_BED,
          dispOrder: null
        },
      ],
      //スケールベット機能フラグ
      //機能が有効な場合 true
      // 無効な場合 false
      ScaleBedFunction: true,
      // #11987 2026.02.08 add スケールベッド対応 スケールベッド機能の無効・有効取得 TDC渡辺 end
    }

    ;
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd"
    }),
    ...mapGetters("mst-weight", {
      getIsGridEditing: "getIsGridEditing",
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start
      getIsChangedMstWeight:"getIsChangedMstWeight"
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
    }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      isRecordModified: "isRecordModified"
    }),
    // #11987 2026.01.07 add スケールベッド対応 デバックモード判定式の追加 TDC渡辺 start
      ...mapGetters("toggle-dev-tool", ["isLockDevTool"])
      ,
    // #11987 2026.01.07 add スケールベッド対応 デバックモード判定式の追加 TDC渡辺 end
    masterRecords() {
      // #11987 2026.02.09 MOD スケールベッド対応 スケールベット機能がOFFの場合、体重計種別がスケールベット物は表示させない。 TDC渡辺 start
      // storeからデータを取得
      //return this.getFilteredMasterRecordList;
      //からデータの場合は空で返す。
      if (!this.getFilteredMasterRecordList || !this.getFilteredMasterRecordList.data) return {};
      // フィルタした配列をdataにセットし、他の情報はそのまま返す
      if (this.ScaleBedFunction === false){
              //体重計のみ表示する。
              return {
                ...this.getFilteredMasterRecordList,
                data: this.getFilteredMasterRecordList.data.filter(row => row.weightType == 0)
              };
            }
            else{
              //すべて表示にする。
              return {
                ...this.getFilteredMasterRecordList,
                data: this.getFilteredMasterRecordList.data
              };
            }
    // #11987 2026.02.09 MOD スケールベッド対応 スケールベット機能がOFFの場合、体重計種別がスケールベット物は表示させない。 TDC渡辺 end
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
      let wsIsChanged = false;
      const refScale = this.$refs.scale;
      if (refScale) {
        wsIsChanged = refScale.isChanged;
      }
      const wIsChanged = this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (this.isRecordModified || !this.kendoValidator?.validate());

      // add FNSI-データ初期種別と測定値送信間隔の制御 徐 start
      this.deviceClassChange();
      // add FNSI-データ初期種別と測定値送信間隔の制御 徐 end
      return (wsIsChanged || wIsChanged);
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start
    isChangedMstWeight(){
      return this.getIsChangedMstWeight
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
    // grid表示データから吹き出しびプルダウンリストデータ生成
    copySrcData() {
      if (!this.masterRecords || this.masterRecords.length === 0 || !this.masterRecords.data) {
        return [];
      }
      return this.masterRecords.data
        .filter(item => item.operation !== 1) // 追加行は除外
        .map(item => ({
          code: item.code,
          name: item.name
        }));
    },
    isMobileDevice() {
      return this.isIOS || this.isAndroid;
    }
  },
  watch: {
    windowHeight() {
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
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
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("master-maintenance", [
      "updateRecordListByFacilityCd",
      "findRecordListByFacilityCd",
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
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
    ...mapActions("mst-weight", {
      setIsGridEditing: "setIsGridEditing",
      requestMst2MntTable: "requestMst2MntTable",
      requestMst2MntTableByFacilityCd: "requestMst2MntTableByFacilityCd",
      // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 start
      requestMstChangedNotify: "requestMstChangedNotify",
      // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 end
    }),
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.getIsGridEditing) {
        const wh = this.windowHeight;
        const hh = Array.prototype.slice
          .call(document.getElementsByClassName("header"))
          .pop().clientHeight;
        const fmh =
          this.isDispMenu === 1
            ? document.getElementById("footer-menu").clientHeight
            : 0;
        this.kendoGridToolbarHeight = wh - hh - fmh - 1;
        this.kendoGridToolbarHeight =
          this.kendoGridToolbarHeight < 240 ? 240 : this.kendoGridToolbarHeight;
        const wsa = this.$refs.scale?.$el;
        let wsah = wsa ? wsa.clientHeight : 100;
        wsah = wsah < 100 ? 100 : wsah;
        const gfh = document.getElementById("grid-footer").clientHeight;
        let tableToolbar = 0
        if (document.getElementsByClassName("header-btn-area") && document.getElementsByClassName("header-btn-area")[0]) {
          tableToolbar = document.getElementsByClassName("header-btn-area")[0].clientHeight
        }
        this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + wsah + tableToolbar);
      }
    },
    async editStart(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      if (this.isAndroid) {
        await this.setIsGridEditing(true);
      }
      // #8745 マウスが止まると中国語のtipsが現れました 林峻峰 start
      this.$nextTick(()=>{
        if (e.sender?.editable?.options?.fields?.field === 'isDisp') {
          const element = document.querySelector('#under-grid .k-grid-content.k-auto-scrollable');
          element.scrollTo({
            left: element.scrollWidth - element.clientWidth,
            behavior: 'smooth'
          });
        }
        if (document.getElementsByClassName('k-input k-textbox') && document.getElementsByClassName('k-input k-textbox')[0]) {
          document.getElementsByClassName('k-input k-textbox')[0].setAttribute('title', '');
        }
      })
      // #8745 マウスが止まると中国語のtipsが現れました 林峻峰 end
    },
    editEnd() {
      this.setIsGridEditing(false);
    },
    addInputAssist() {
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.isIOS) {
        if (document.getElementsByClassName("k-numerictextbox").length !== 0) {
          let spinnerObj = document.getElementsByClassName("k-numerictextbox")[0].getElementsByClassName("k-select")[0];
          // 編集が終了するとオブジェクトが削除されるため、removeEvent処理は不要
          spinnerObj.ontouchend = event => event.stopPropagation();
        }
      }
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして値を取得
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.findRecordList => this.findRecordListByFacilityCd
      // this.findRecordList()
      this.findRecordListByFacilityCd(this.facilitylistValue)
        .then(response => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          if (response.data.columns.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message:
              //   "マスタ定義にカラム情報が登録されていません。<BR>カラム情報を登録してください。",
              title: DIALOG_MESSAGES[12000001].title,
              message: messageFormat(DIALOG_MESSAGES[12000001].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
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
          });
          // 透析室コンボボックス用データ取得
          // mod マスタ一覧 1･施設切替を可能とする 孔 this.facilityCd => this.facilitylistValue
          // roomBedGroup(this.facilityCd).then(response => {
          roomBedGroup(this.facilitylistValue).then(response => {
            let roomBedGroupList = [
              {
                // mod FNSI-透析室コンボボックス用データの制御 徐 start
                // value: null,
                // text: " "
                value: "0",
                text: "なし"
                // mod FNSI-透析室コンボボックス用データの制御 徐 end
              }
            ];
            for (const r of response) {
              if (r.isDel !== "1" && r.groupClass === 2) {
                // 有効な透析室
                roomBedGroupList.push({
                  value: r.roomBedGroupCd,
                  text: r.roomBedGroupName
                });
              }
            }
            toFunction.forEach(column => {
              // デバイスエッジコンボ用データを追加
              if (column.field === "bedGroupCd") {
                column.values = roomBedGroupList;
              }
            });
            this.columns = toFunction;

            // 横スクロールバーを表示するために列幅を指定
            this.columns.forEach(column => {
              // 「削除」のプルダウンが改行しない幅に調整
              // add FNSI-redmine3987 徐 start
              // column.width = column.field === "isDisp" ? "8em" : "14em";
              // mod redmine 4526 小の時に生じる（削除プルダウンのレイアウト不正） 宋qy start
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
              // column.width = column.field === "isDisp" ? "8.3em" : "15em";
              column.width = column.field === "isDisp" ? "9em" : "15em";
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
              // mod redmine 4526 小の時に生じる（削除プルダウンのレイアウト不正） 宋qy end
              // add FNSI-redmine3987 徐 end
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
              width: "10px",
              format: "",
              values: null
            });
            // カラム幅等初期調整
            this.showSortColumn();
            this.$nextTick(() => {
              this.calculateGridHeight();
              this.$refs.grid.$el.lastChild.scrollTop = this.scrollPosition.top;
              this.$refs.grid.$el.lastChild.scrollLeft = this.scrollPosition.left;
            });
            // 初期データ内容を保存
            this.setComparisonRecordModel();
            /* add スクロールの位置を維持 楊 start */
            // this.$nextTick(() => {
            //   document.getElementsByClassName('k-grid-content k-auto-scrollable')[1].scrollTop = this.lastScrollTop;
            //   document.getElementsByClassName('k-grid-content k-auto-scrollable')[1].scrollLeft = this.lastScrollLeft;
            //   setTimeout(() => {
            //     this.lastScrollTop = 0;
            //     this.lastScrollLeft = 0;
            //   }, 1000)});
            });
            /* add スクロールの位置を維持 楊 end */
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWeightRecordComponent.vue', 'findList', '指定されたマスタが見つかりません。');
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
    setFilterCondition(condition) {
      this.condition.recordName = condition.recordName;
      this.condition.includeDeleted = condition.includeDeleted;
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      //イベント発生前のスクロールバーの位置を保持
      const scrollTop = document.getElementsByClassName('k-grid-content k-auto-scrollable')[1].scrollTop;
      const scrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[1].scrollLeft;
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }
      // まずは子コンポーネントの保存処理から
      const childRes = await this.$refs.scale.saveRecord();
      if (childRes.response === -2) {
        // グリッドでエラー
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      } else if (childRes.response < 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        // チェックエラー
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES["00300006"].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message:
            '<div style="text-align:left;">' + childRes.message + "</div>"
        });
        return;
      } else if (childRes.response === 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        // 保存失敗
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "更新失敗",
          title: DIALOG_MESSAGES["00300005"].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: childRes.message
        });
        return;
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        r => !(r.operation === 1 && !r.edited)
      );
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();
      // 体重計番号 重複チェック
      const validateWeightMessage = this.validateWeightSetting();

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message +  messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage;
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validateWeightMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          message +  messageFormat(DIALOG_MESSAGES['00200071'].message) + validateWeightMessage;
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000006].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        return;
      }

      // mod FNSI-データ初期種別と測定値送信間隔の制御 徐 start
      if (this.getMasterRecordList.data !== undefined) {
        for (var i = 0; i < this.getMasterRecordList.data.length; i++) {
          var row = this.getMasterRecordList.data[i];
          if (row.deviceClass !== "1") {
            row.dataSelectType = "";
            row.dataSendInterval = "";
          }
        }
      }
      // mod FNSI-データ初期種別と測定値送信間隔の制御 徐 end

      // apiをコールして値を保存
      // add マスタ一覧 1･施設切替を可能とする 孔s start
      const objArgs = {
        facilityCd: this.facilitylistValue,
        request: this.getUpdateRecordList
      }
      // add マスタ一覧 1･施設切替を可能とする 孔s end
      // mod マスタ一覧 1･施設切替を可能とする 孔s this.updateRecordList => this.updateRecordListByFacilityCd
      // this.updateRecordList(this.getUpdateRecordList)
      this.updateRecordListByFacilityCd(objArgs)
        .then(response => {
          this.updateResponse = response.data;
          // メンテナンステーブルへの反映
          // mod マスタ一覧 1･施設切替を可能とする 孔 this.requestMst2MntTable => this.requestMst2MntTableByFacilityCd
          // this.requestMst2MntTable()
          this.requestMst2MntTableByFacilityCd(this.facilitylistValue)
            .then(() => {
              // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 start
              const updateWeightNos = this.getUpdateRecordList
                .filter(item => item.weightNo) // weightNoが存在するレコードのみ
                .map(item => item.weightNo);
              this.requestMstChangedNotify({
                facilityCd: this.facilitylistValue,
                weightNoList: updateWeightNos ?? []
              })
                .then(() => {
              // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 end
                //共通ローダー：表示終了
                this.setLoadingScreenVisible(false);
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "更新完了",
                  // message: "マスタ更新が完了しました。"
                  title: DIALOG_MESSAGES[12000004].title,
                  message: messageFormat(DIALOG_MESSAGES[12000004].message),
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });

                this.findList();
              })
              .catch(error => {
                this.$refs.grid.$el.lastChild.scrollTop = this.scrollPosition.top;
                this.$refs.grid.$el.lastChild.scrollLeft = this.scrollPosition.left;
                //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
                getErrorMessage('MstWeightRecordComponent.vue', 'saveRecord', error);
                //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
                //共通ローダー：表示終了
                this.setLoadingScreenVisible(false);
                if (error.response.status === 400) {
                  this.$ons.notification.alert({
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                    // title: "更新失敗",
                    title: DIALOG_MESSAGES["00300005"].title,
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    message: error.response.data.errorMessage
                  });
                } else {
                  this.$ons.notification.alert({
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                    // title: "更新失敗",
                    title: DIALOG_MESSAGES["00300005"].title,
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    message: error
                  });
                }
              });
            // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 start
            });
            // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 end
        })
        .catch(error => {
            this.$refs.grid.$el.lastChild.scrollTop = this.scrollPosition.top;
            this.$refs.grid.$el.lastChild.scrollLeft = this.scrollPosition.left;
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWeightRecordComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        });
    },
    validateRequired() {
      let validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      // ストアに保存されているデータについて必須項目の未入力をチェックする
      for (let idx = 0; idx < gridData.data.length; idx++) {
        // スキーマ情報の件数分をチェック
        const keys = Object.keys(gridData.schema.model.fields);
        for (let keyCount = 0; keyCount < keys.length; keyCount++) {
          // バリデーションで必須が定義されている項目を対象
          const validation =
            gridData.schema.model.fields[keys[keyCount]].validation;
          if (typeof validation !== "undefined" && validation.required) {
            if (
              gridData.data[idx][keys[keyCount]] !== null &&
              gridData.data[idx][keys[keyCount]] === ""
            ) {
              // カラム名からタイトルを取得
              const columnInfo = this.columns.find(
                e => e.field == keys[keyCount]
              );
              // 項目名が重複していなければ、メッセージに追加
              validateMessageArr.push(columnInfo.title);
            }
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    validateComboValue() {
      // コンボ項目のfieldを取り出す
      const comboFields = this.columns
        .filter(column => column.values != null)
        .map(column => ({
          field: column.field,
          title: column.title,
          values: column.values
        }));

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data.filter(row => row.isDisp !== "0");
      // コンボの列を対象に、ストアの値がコンボのvaluesに存在することをチェック
      let validateMessageArr = [];
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        for (let comboIdx = 0; comboIdx < comboFields.length; comboIdx++) {
          const columnValue = rows[rowIdx][comboFields[comboIdx].field];
          // valuesにデータ値が存在せず、データ値がNullか空文字でなければエラー
          const index = comboFields[comboIdx].values.findIndex(
            e => e.value == columnValue
          );
          if (index < 0 && (columnValue !== null && columnValue !== "")) {
            validateMessageArr.push(comboFields[comboIdx].title);
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    validateWeightSetting() {
      let validateMessageArr = [];
      let checkWeightNo = [];
      let checkWeightName = [];

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data;
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        let rowNo = rowIdx + 1;
        // 名称取得
        let name = rows[rowIdx]["name"];
        // 体重計番号取得
        let wNo = rows[rowIdx]["weightNo"];
        // 削除対象判定
        let del = rows[rowIdx]["isDisp"] === "1" ? "" : "(削除分)";

        // 体重計番号重複チェック
        let idxNo = 1 + checkWeightNo.indexOf(wNo);
        if (1 <= idxNo) {
          // 重複あり
          let strerr =
            // mod FNSI-体重計番号重複チェックメッセージ編集 徐 start
            // "体重計番号重複あり：<br>" +
            "体重計番号重複あり（削除分含む）：<br>　　　" +
            // mod FNSI-体重計番号重複チェックメッセージ編集 徐 end
            idxNo +
            "行目と" +
            rowNo +
            "行目" +
            del;
          validateMessageArr.push(strerr);
        } else {
          // 重複なし
          checkWeightNo.push(wNo);
        }

        // 体重計名重複チェック
        idxNo = 1 + checkWeightName.indexOf(name);
        if (1 <= idxNo) {
          // 重複あり
          let strerr =
            // mod FNSI-名称重複チェックメッセージ編集 徐 start
            // "名称重複あり：<br>" +
            "名称重複あり（削除分含む）：<br>　　　" +
            // mod FNSI-名称重複チェックメッセージ編集 徐 end
            idxNo +
            "行目と" +
            rowNo +
            "行目" +
            del;
          validateMessageArr.push(strerr);
        } else {
          // 重複なし
          checkWeightName.push(name);
        }
      }

      return this.convertToStr(validateMessageArr);
    },
    convertToStr(messageArr) {
      if (messageArr.length === 0) return "";

      const unique = messageArr.reduce((acc, cur) => {
        if (acc.indexOf(cur) === -1) {
          acc.push(cur);
        }
        return acc;
      }, []);

      const prefix = "</br>&nbsp&nbsp・";
      return prefix + unique.join(prefix);
    },
    sort() {
      const compare = (a, b) =>
        a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
      //グリッドデータの並び替え
      this.getMasterRecordList.data.sort(compare);
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue start
      for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
        this.getMasterRecordList.data[i].sortRank = i + 1;
      }
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue end
    },
    onSave(ev) {
      //イベント発生前のスクロールバーの位置を保持
      const scrollTop = ev.sender.content[0].scrollTop;
      const scrollLeft = ev.sender.content[0].scrollLeft;
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      this.setIsGridEditing(false);
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      ev.sender.refresh();
      if (ev.model.operation === 1) {
        ev.model["edited"] = true;
      }
      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
    },
        onDataBoundKendoGrid(ev) {


    },
    onDataBoundKendoGrid(ev) {
      console.log('9999999999',this.scrollPosition.top);
      
      setTimeout(() => {
        const grid = $$("div.k-grid-content")[1];
        grid.scrollTop = this.scrollPosition.top;
        grid.scrollLeft = this.scrollPosition.left;
      }, 1000);
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    },
    showMasterEditView(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      // const grid = $$("#under-grid div.k-grid-content")[0];
      // this.scrollPosition.top = grid.scrollTop;
      // this.scrollPosition.left = grid.scrollLeft;
      // 次画面を表示
      this.isShowDetailView = true;
      EventBus.$emit("setIsDetailHeaderView", true);

      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
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
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
      });
      // Androidでスクロール位置が戻らない場合があるのでもう一度設定
      setTimeout(() => {
        this.setScrollPosition(this.scrollPosition);
      }, 1000);
    },
    setScrollPosition(position) {
      $$("#under-grid div.k-grid-content")
        .scrollTop(position.top)
        .scrollLeft(position.left);
    },
    toRankEditBtnClick() {
           // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $$("div.k-grid-content")[1];
      
      this.scrollPosition.top = grid.scrollTop;
      this.scrollPosition.left = grid.scrollLeft;
      EventBus.$emit("onCloseMasterEditModal", this.onCloseMasterEditModal);
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
      EventBus.$emit("setSortMode", this.isSortMode);
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
      Object.keys(fields).forEach(k => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          d[k] = "";
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (fields[k].type === "date") {
          d[k] = new Date();
        } else {
          d[k] = null;
        }

        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
      });
      this.scrollPosition.top = this.$refs.grid.$el.lastChild.scrollHeight;
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      this.editBackgroundColor();
    },
    sortBtnClick() {
      this.isSortMode = false;
      this.isSorted = true;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      EventBus.$emit("setSortMode", this.isSortMode);
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
        // #11987 2026.02.08 add スケールベッド対応 スケールベッド機能がONの場合のみ表示する。 TDC渡辺 start
        //スケールベット機能が有効・無効により体重種別を表示・非表示にする。
        const weightTypeIndex = this.columns.findIndex(col => col.field === "weightType");
        if (weightTypeIndex >= 0) {
          if (this.ScaleBedFunction === false){
            //非表示にする。
            this.columns[weightTypeIndex].hidden = true;
          }
          else{
            //表示にする。
             this.columns[weightTypeIndex].hidden = false;
          }
        }
        // #11987 2026.02.08 add スケールベッド対応 スケールベッド機能がONの場合のみ表示する。 TDC渡辺 end
      }

    },
    disableColumns() {
      this.columns.forEach(column => {
        // 並び順列を編集可、並び順列以外を編集不可に。
        column.editable =
          column.field == "sortRank"
            ? this.isAllowSort
              ? () => true
              : () => false
            : () => false;
      });
    },
      copyAdd(e) {
      this.scrollPosition.top = this.$refs.grid.$el.lastChild.scrollHeight;
      // グリッドでエラーが発生している場合は処理を中断
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return;
      }
      this.masterCopyAddTarget = e.target;
      this.masterCopyAddVisible = true;
    },
    editableColumns() {
      this.columns.forEach(column => {
        // 編集可否の設定を初期表示時の状態に戻す
        column.editable =
          column.field == "sortRank"
            ? () => false
            : column.originalEditable
              ? () => true
              : () => false;
      });
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
    editBackgroundColor(masterName = null) {
      this.$nextTick(() => {
        // グリッドが表示されていなかったら処理終了
        const gridHeader = this.$refs.grid.$el.firstChild;
        if (gridHeader.textContent === ' ') {
          return;
        }
        gridHeader?.classList?.add('master-grid-header');

        // グリッドにレコードがなければ処理終了
        if (!this.$refs.grid.$el.lastChild.lastChild.tBodies) {
          return;
        }
        // 固定列、可変列、データソースの取得
        const tbodyc = this.$refs.grid.$el.lastChild.lastChild
          .tBodies[0].children;
        const lockTbodyc = this.$refs.grid.$el.children[1].lastChild
          .tBodies[0].children;
        const gridData = this.$refs.grid.dataSource;
        const dataItem = this.masterPhysicalName === 'mst_exam_item' ? gridData._data : gridData.data
        // 列の行数は固定・可変で同一なため可変列の行数を使用
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;
          const currentLockTrc = lockTbodyc[rwCount].children;
          // 並び順の色変更
          this.changeSortColor(currentLockTrc);
          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc, currentLockTrc);
          // 削除対象を判定
          const deleted = this.isDeleteRow(currentTrc);

          // モーダルからの編集も色を変更する
          if (
            dataItem[rwCount] && this.isEdited(dataItem[rwCount].code)
          ) {
            edited = true;
          }
          // 対応範囲のテーブルのみ、operation = 1 (新規) の行に、k-dirty-cell" を入れる
          if (masterName != null
              && masterName === 'mst_alarm_notification'
              && dataItem[rwCount].operation
              && dataItem[rwCount].operation === 1) {
            edited = true;
          }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
          // add FNSI-8131 劉全航 start
          if(dataItem[rwCount] && dataItem[rwCount].operation && dataItem[rwCount].operation == 1){
            continue;
          }
          // add FNSI-8131 劉全航 end
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 end
          // データ参照エラーコンボの背景色を変更
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // this.changeRefErrorComboColor(currentTrc, deleted);
          this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
        }
      });
    },
    changeSortColor(currentTrc) {
      // 並び順が変更されていれば並び順とダミー項目背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
          this.isEditRow(currentTrc[clCount])
          && clCount === this.getColumnIndex('sortRank')
        ) {
          currentTrc[clCount]?.classList?.add('master-sort-edited');
          const dummyIndex = this.getColumnIndex('dummy');
          if (dummyIndex > -1) {
            currentTrc[dummyIndex]?.classList?.add('master-sort-edited');
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 end
          }
        }
      }
    },
    // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
    changeEditColor(currentTrc, currentLockTrc) {
      let edited = false;
      // 変更されたセルの文字色を変更(固定列と可変列の行数は一致)
      for (let lockClCount = 0; lockClCount < currentLockTrc.length; lockClCount++) {
        // 固定列セル:並び順以外の編集列
        if (
          this.isEditRow(currentLockTrc[lockClCount])
          && lockClCount !== this.getColumnIndex('sortRank')
        ) {
          currentLockTrc[lockClCount]?.classList?.add('master-edited-cell');
          edited = true;
        }
      }

      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        // 可変列セル
        if (
          this.isEditRow(currentTrc[clCount])
        ) {
          currentTrc[clCount]?.classList?.add('master-edited-cell');
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 end
          edited = true;
        }
      }
      return edited;
    },
    isDeleteRow(currentTrc) {
      let deleted = false;
      // 削除カラムで削除が選択されている場合は削除フラグを設定
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
        if (this.isEditRow(currentTrc[clCount])) {
          if (
            currentTrc[clCount].children[0].nextSibling
            && currentTrc[clCount].children[0].nextSibling.data === '削除'
            && this.getColumnIndex('isDisp') === clCount
            // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 end
          ) {
            deleted = true;
          }
        }
      }
      return deleted;
    },
    // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
    changeRowColor(currentTrc, currentLockTrc, edited, deleted) {
      // 並び順より後の項目の背景色を変更
      if (edited || deleted) {
        const addClass = deleted ? 'master-deleted-row' : 'master-edited-row';

        // 固定列（ソート順付）：ソート順後のみ
        for (
          let lockClCount = this.getColumnIndex('sortRank') + 1;
          lockClCount < currentLockTrc.length;
          lockClCount++
        ) {
          currentLockTrc[lockClCount]?.classList?.add(addClass);
        }
        // 可変列：全列対象
        for (
          let clCount = 0;
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 end
          clCount < currentTrc.length;
          clCount++
        ) {
          currentTrc[clCount]?.classList?.add(addClass);
        }
      }
    },
    // mod #9863 編集時背景色表示異常の横展開 蔡 start
    // changeRefErrorComboColor(currentTrc, rowDeleted) {
    // currentLockTrc：左gridのリストを取得する
    changeRefErrorComboColor(currentUnLockTrc, rowDeleted, currentLockTrc) {
    // mod #9863 編集時背景色表示異常の横展開 蔡 end
      // 削除行は処理対象外
      if (rowDeleted) {
        return;
      }
      // add #9863 編集時背景色表示異常の横展開 蔡 start
      let currentTrc = [];
      for (let clCount = 0; clCount < currentLockTrc.length; clCount++) {
        currentTrc.push(currentLockTrc[clCount]);
      }
      for (let clCount = 0; clCount < currentUnLockTrc.length; clCount++) {
        currentTrc.push(currentUnLockTrc[clCount]);
      }
      if (currentTrc.length !== this.columns.length) {
        return;
      }
      // add #9863 編集時背景色表示異常の横展開 蔡 end
      // コンボリストが設定されていてデータが存在するが、画面表示上は空の場合は削除済みレコードを参照として背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        const columnInfo = this.columns[clCount];
        const hasValueColumn = this.hasValueColumn(
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // currentTrc[this.getColumnIndex("code")].textContent,
          currentTrc[this.getColumnIndex('code')].textContent.replaceAll(",", ""),
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
          columnInfo.field,
        );
        if (
          columnInfo.values !== null
          && hasValueColumn
          && currentTrc[clCount].textContent === ''
        ) {
          currentTrc[clCount]?.classList?.add('master-deleted-combo');
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 end
        }
      }
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains("k-dirty-cell");
    },
    // add FNSI-データ初期種別と測定値送信間隔の制御 徐 start
    deviceClassChange() {
      setTimeout(() => {
        var rowxs = document.getElementById("under-grid").childNodes[1].childNodes[0].childNodes[1];
        for (var no = 0; no < rowxs.childNodes.length; no++) {
          var rowx = rowxs.childNodes[no].cells;
          // #11987 2025.11.13 mod スケールベッド対応 体重計種別追加による列の変更 TDC渡辺 start
          // #9863 加算マスタ詳細を開くとtypeエラーが発生する 横展開2 linjunfeng start
          // if (rowx[8].textContent === this.deviceClassName) {
          //   rowx[24].disabled = false;
          //   rowx[25].disabled = false;
          // } else {
          //   rowx[24].disabled = true;
          //   rowx[25].disabled = true;
          //   rowx[24].textContent = "";
          //   rowx[25].textContent = "";
          // }
          //if (rowx[8] && rowx[8].textContent === this.deviceClassName) {
          //  rowx[24].disabled = false;
          //  rowx[25].disabled = false;
          //} else {
          //  if (rowx[24] && rowx[25]) {
          //    rowx[24].disabled = true;
          //    rowx[25].disabled = true;
          //    rowx[24].textContent = "";
          //    rowx[25].textContent = "";
          //  }
          //}
          // #9863 加算マスタ詳細を開くとtypeエラーが発生する 横展開2 linjunfeng end
          //すべての項目を一度表示に設定する。
          if (rowx[no]) {
            rowx[no].disabled = false;
          }
          //スケールベット機能が有効・無効により体重種別を表示・非表示にする。
          if (this.ScaleBedFunction === false) {
            //無効な場合、体重種別を非表示
            if (rowx[6] && rowx[6].style) {
              rowx[6].style.display = 'none';
            }
          } else {
            //有効な場合、体重種別を表示
            if (rowx[6] && rowx[6].style) {
              rowx[6].style.display = '';
            }
          }
          if (rowx[9] && rowx[9].textContent === this.deviceClassName) {
            rowx[25].disabled = false;
            rowx[26].disabled = false;
          } else {
            if (rowx[25] && rowx[26]) {
              rowx[25].disabled = true;
              rowx[26].disabled = true;
              rowx[25].textContent = "";
              rowx[26].textContent = "";
              rowx[25].style.backgroundColor = '#a0a0a0';
              rowx[26].style.backgroundColor = '#a0a0a0';
            }
          }
          //スケールベッドの場合
          if (rowx[6] && rowx[6].textContent === this.weightTypeNameScaleBed) {
            //体重計種別
            rowx[6].disabled = false;
            //詳細不明
            //rowx[7].disabled = true;
            //体重計ポート
            rowx[8].disabled = true;
            rowx[8].textContent = "";
            rowx[8].style.backgroundColor = '#a0a0a0';
            //体重計機種
            rowx[9].disabled = true;
            rowx[9].textContent = "";
            rowx[9].style.backgroundColor = '#a0a0a0';
            //前体重自動送信
            //前体重自動送信待ち時間(秒)
            rowx[11].disabled = true;
            rowx[11].textContent = "";
            rowx[11].style.backgroundColor = '#a0a0a0';
            //前体重自動送信待ち時間(秒)
            rowx[14].disabled = true;
            rowx[14].textContent = "";
            rowx[14].style.backgroundColor = '#a0a0a0';
            //カード有無
            rowx[18].disabled = true;
            rowx[18].textContent = "";
            rowx[18].style.backgroundColor = '#a0a0a0';
            //削除
            //rowx[24].disabled = true;
            //データ初期種別
            rowx[25].disabled = true;
            rowx[25].textContent = "";
            rowx[25].style.backgroundColor = '#a0a0a0';
            //測定値送信間隔
            rowx[26].disabled = true;
            rowx[26].textContent = "";
            rowx[26].style.backgroundColor = '#a0a0a0';
          }
          //体重計の場合
          if (rowx[6] && rowx[6].textContent === this.weightTypeNameWeight) {
            //体重計種別
            rowx[6].disabled = false;
            rowx[6].style.backgroundColor = '';
            //体重計ポート
            rowx[8].disabled = false;
            rowx[8].style.backgroundColor = '';
            //体重計機種
            rowx[9].disabled = false;
            rowx[9].style.backgroundColor = '';
            //前体重自動送信待ち時間(秒)
            rowx[11].disabled = false;
            rowx[11].style.backgroundColor = '';
            //前体重自動送信待ち時間(秒)
            rowx[14].disabled = false;
            rowx[14].style.backgroundColor = '';
            //カード有無
            rowx[18].disabled = false;
            rowx[18].style.backgroundColor = '';
          }
          // #11987 2025.11.13 add スケールベッド対応 体重計種別がスケールベッドの場合非活性化 TDC渡辺 end
        }
      }, 500);
    },
    // add FNSI-データ初期種別と測定値送信間隔の制御 徐 end
    normalization(items) {
      // columnの定義にあわせてデータを正規化する。
      const columnNames = this.columnDefinition.map(column => column.field);

      return Object.keys(items)
        .filter(key => columnNames.includes(key))
        .reduce((acc, key) => {
          acc[key] = items[key];
          return acc;
        }, {});
    },
    closeDetailView() {
      this.isShowDetailView = false;
      this.onCloseMasterEditModal();
      EventBus.$emit("setIsDetailHeaderView", false);
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    },
    loadGridData(){
      // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
      this.findList();
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name
          && document.getElementsByTagName("ons-alert-dialog").length === 0) {
        // #9194 愁訴処置マスタは空行保存ができる仕様だが、愁訴、処置が必須となっておりフォーカスアウトできない。 linjunfeng start
        // if (this.isChanged) {
        if (this.isChanged || !this.kendoValidator.validate()) {
        // #9194 愁訴処置マスタは空行保存ができる仕様だが、愁訴、処置が必須となっておりフォーカスアウトできない。 linjunfeng end
          this.$ons.notification.confirm({
             // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.clearScrollPosition();
                this.$refs.scale.refresh();
                this.loadGridData();
              }
            }
          });
        } else {
          this.clearScrollPosition();
          this.$refs.scale.refresh();
          this.loadGridData();
        }
      }
    },
    /**
     * @description スクロールバーの位置をクリアする
    */
    clearScrollPosition() {
      // this.scrollPosition.top = 0;
      // this.scrollPosition.left = 0;
    },
    /**
     * 行をコピー追加した時の処理
     */
    addedRow(){
      // スクロールバーを一番下にする
      this.lastScrollTop = this.$refs.grid.$el.lastChild.scrollHeight;
    },
  },
  async created() {
    // #11987 2026.02.08 add スケールベッド対応 スケールベッド機能の無効・有効取得 TDC渡辺 start
    // sys_function.disp_order を取得
    let sysFunctionList = await sendRequestGetDefaultSettingDispOrder();
    sysFunctionList = sysFunctionList.data;
    this.defaultSettingObj.forEach(obj => {
      let tmpObj = sysFunctionList.filter(func => {
        return Number(obj.funcCode) === Number(func.functionCd);
      });
      tmpObj = tmpObj.length !== 0 ? tmpObj[0] : [];
      obj.dispOrder = tmpObj.dispOrder ? Number(tmpObj.dispOrder) : null;
    });
    // useFunction配列を取得
    const useFunction = this.$store.state.facility.useFunction || [];
    // スケールベッド機能が有効か判定
    if(useFunction.includes(FUNC_SCALE_BED)){
      // スケールベッド機能が有効
      this.ScaleBedFunction = true;
    }
    else{
      // スケールベッド機能が無効
      this.ScaleBedFunction = false;
     }
    // #11987 2026.02.08 add スケールベッド対応 スケールベッド機能の無効・有効取得 TDC渡辺 end

    this.setLoadingScreenVisible(true);
    // add マスタ一覧 1･施設切替を可能とする 孔s start
    this.facilitylistValue = this.getFacilitySwitch;
    // add マスタ一覧 1･施設切替を可能とする 孔s end
    this.loadGridData();

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.isAndroid = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.isIOS = true;
    }
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
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
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
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
  padding: 0.2em 0.1em 0.1em 0.1em;
}
.k-grid-toolbar {
  padding: 0 0.3em;
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
  padding-left: 0;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}
.kendo-grid-disabled {
  background-color: #FFFFE0;
  color: white;
  /* opacity: 0.5; */
}
input:disabled {
    background-color: #FFFFE0 !important;
    color: #f00707 !important;
    cursor: not-allowed;
    opacity: 0.6;
    pointer-events: none;
}
/*
:disabled {
  background-color: block ;
  color: inherit block;
  cursor: not-allowed;
}

:disabled {
  background-color: block ;
  color: inherit block;
  cursor: not-allowed;
}
  */
</style>
