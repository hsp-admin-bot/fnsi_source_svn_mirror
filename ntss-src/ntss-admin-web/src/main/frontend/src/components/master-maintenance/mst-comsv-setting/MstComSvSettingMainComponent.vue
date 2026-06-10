/**
 * 通信サーバーマスタメンテナンスデータページ  MainContent
 */
<template>
  <div class='main-content-area master-maintenance-page'>
    <div class='ntss-list' :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" class='header-btn-area right' :style="isMobileDevice ? { minHeight: '30px' } : {}">
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord" @click="addRow()">追加</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left; margin-left: 10px;" v-show="!isSortMode && isAllowAddRecord" @click="copyAdd">コピー追加</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 2em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <!-- del マスタ一覧 1･施設切替を可能とする 王 start -->
          <!--          <kendo-dropdownlist ref="dropDownList" v-if="isMasterUser"-->
          <!--                    v-model="facilityListValue"-->
          <!--                    :data-source="facilities"-->
          <!--                    :data-text-field="'facilityName'"-->
          <!--                    :data-value-field="'facilityCd'"-->
          <!--                    :filter="'contains'"-->
          <!--                    @open="onOpenFacility"-->
          <!--                    @change="onChangeFacility"-->
          <!--                    style="width: 13em;">-->
          <!--          </kendo-dropdownlist>-->
          <!-- del マスタ一覧 1･施設切替を可能とする 王 end -->
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="!isSortMode && isAllowSort" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="isSortMode && isAllowSort" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <kendo-grid :class="fontSizeSet" ref="grid"
            :data-source="masterRecords"
            :editable="true"
            :selectable="true"
            :reorderable="false"
            :height=kendoGridHeight
            :scrollable="true"
            :beforeEdit=editStart
            :cellClose=editEnd
            :edit=addInputAssist
            @save="onSave"
            @databound="onDataBoundKendoGrid">
            <template v-for="(column, index) in columns" >
              <kendo-grid-column v-if="column.field === '$modalType'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :attributes="{ class: 'btn3-kendo-normal' }"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '詳細', click: showMasterEditModal }">
              </kendo-grid-column>
              <!--//add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start-->
              <kendo-grid-column v-else-if="column.field === 'deviceEdgeNo'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="editorDropDown">
              </kendo-grid-column>
              <!--//add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される end-->
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
            <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord">保存</v-ons-button>
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
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import $ from "jquery"
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import MasterCopyAddComponent from "@/components/master-maintenance/MasterCopyAddComponent";

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
  components: {
    "master-copy-add": MasterCopyAddComponent,
  },
  data() {
    return {
      recordList: [],
      // add 6113 について 修正 chen start
      flg: false,
      machineName: "",
      // add 6113 について 修正 chen end
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
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      isAndroid: false,
      isIOS: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      //自画面の名称
      selfScreenName: "",
      // 選択施設情報
      facilityListValue: "",
      //変更前の施設
      prevFacilityCd: "",
      lastscrollTop: 0,
      lastscrollLeft: 0,
      errorName: [],
      // コピー追加 吹き出し用 start
      masterCopyAddVisible: false,
      masterCopyAddTarget: null,
      // コピー追加 吹き出し用 end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
    };
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
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    ...mapGetters("user", {
      facilityCd: "getFacilityCd"
    }),
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      getFacilitySwitch: "getFacilitySwitch",
      hasValueColumn: "hasValueColumn",
      // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng start
      isRecordModified: "isRecordModified"
      // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng end

    }),
    ...mapGetters("mst-com-sv-setting", {
      getMachineTypeList: "getMachineTypeList",
      getDeviceEdgeList: "getDeviceEdgeList",
      getFacilityList: "getFacilityList",
    }),
    masterRecords() {
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
        data !== undefined && this.kendoValidator !== undefined &&
        (
          // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc start
          // data.filter(row => row.operation > 0).length ||
          // this.isSorted ||
          // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc end
          // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng start
          this.isRecordModified ||
          // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng end
          !this.kendoValidator.validate())
      );
    },
    isMasterUser: {
      get() {
        return this.getStateUserAccountInfo.userType === 1 ? true : false;
      },
      set() {}
    },
    facilities() {
      // storeからデータを取得
      return this.getFacilityList;
    },
    // grid表示データから吹き出しびプルダウンリストデータ生成
    copySrcData() {
      if (!this.masterRecords || this.masterRecords.length === 0) {
        return [];
      }
      return this.masterRecords.data
        .filter(item => item.operation !== 1) // 追加行は除外
        .map(item => {
          // デバイスエッジのリスト から value が一致する要素を探す
          const matchingDevice = this.getDeviceEdgeList.find(device => device.value == item.deviceEdgeNo);
          return {
            code: item.code,
            name: matchingDevice ? matchingDevice.text : ""
          };
        });
    },
    isMobileDevice() {
      return this.isIOS || this.isAndroid;
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
    },
  },
  methods: {
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("master-maintenance", [
      "findRecordListByFacilityCd",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng start
      "setComparisonRecordModel",
      // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng end
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-com-sv-setting", [
      "getComboRecordList",
      "deleteMstMachineList",
      "synchroMstComSvSetting",
      "facilityList",
      "setSelectFacility"
    ]),
    // Windowの高さからGirdコンポーネント領域の高さを算出
    // calculateGridHeight() {
    //   if (!this.editingFlg) {
    //     const wh = this.windowHeight;
    //     const hh = Array.prototype.slice
    //       .call(document.getElementsByClassName("header"))
    //       .pop().clientHeight;
    //     const fmh =
    //       (this.isDispMenu === 1
    //         ? document.getElementById("footer-menu").clientHeight
    //         : 0) + 5;
    //     this.kendoGridToolbarHeight = wh - hh - fmh - 10;
    //     this.kendoGridToolbarHeight =
    //       this.kendoGridToolbarHeight < 340 ? 340 : this.kendoGridToolbarHeight;
    //     const ghd = document.getElementById("grid-header").clientHeight;
    //     const gfh = document.getElementById("grid-footer").clientHeight;
    //     this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + ghd);
    //   }
    // },
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
      if (this.isAndroid) {
        this.editingFlg = true;
      }
    },
    editEnd() {
      this.editingFlg = false;
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
    // グリッドのデータ再表示
    gridDataRefresh() {
      const grid = this.$refs.grid;
      grid.dataSource = [];
      grid.dataSeource = this.masterRecords;
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして型式マスタ、デバイスエッジの値を取得
      this.getComboRecordList(this.facilityListValue).then(() => {
        // apiをコールして値を取得
        this.findRecordListByFacilityCd(this.facilityListValue)
          .then(response => {
            // editableをKendoUI用にfunctionオブジェクトに変換
            const toFunction = response.data.columns;
            toFunction.forEach(column => {
              // 初期表示時の編集可否を退避
              column.originalEditable = column.editable;
              // 編集可否を関数化
              column.editable = column.editable ? () => true : () => false;
              // 列幅初期化
              column["width"] = column.width ? column.width : "0";
              /* del by chamaojia 2023-07-10 装置マスタ初期化エラー  --start */
              // // 型式コンボ用データを追加
              // if (column.field === "machineTypeCd") {
              //   column.values = machineTypeList;
              // }
              // // デバイスエッジコンボ用データを追加
              // if (column.field === "deviceEdgeNo") {
              //   column.values = deviceEdgeList;
              // }
              /* del by chamaojia 2023-07-10 装置マスタ初期化エラー  --end */
            });
            // 型式コンボボックス用データ取得
            const machineTypeList = this.getMachineTypeList;
            // デバイスエッジコンボボックス用データ取得
            const deviceEdgeList = this.getDeviceEdgeList;
            toFunction.forEach(column => {
              // 型式コンボ用データを追加
              if (column.field === "machineTypeCd") {
                column.values = machineTypeList;
              }
              // デバイスエッジコンボ用データを追加
              if (column.field === "deviceEdgeNo") {
                column.values = deviceEdgeList;
              }
            });

            this.columns = toFunction.filter(function(col) {
              return col;
            });

            // 横スクロールバーを表示するために列幅を指定
            this.columns.forEach(column => {
              // 「削除」のプルダウンが改行しない幅に調整
              column.width = "14em";
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
              // if (column.field === "isDisp")column.width = "8em";
              if (column.field === "isDisp")column.width = "9em";
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
              if (column.field === "isDel")column.width = "8em";
                // column.width = (column.field === "isDisp" || column.field === "isDel") ? "8em" : "14em";
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
            /* add スクロールの位置を維持 楊 start */
            document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop = this.lastscrollTop;
            document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft = this.lastscrollLeft;
            setTimeout(() => {
                this.lastScrollTop = 0;
                this.lastScrollLeft = 0;
              }, 1000);
            /* add スクロールの位置を維持 楊 end */
            });
            // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng start
            // 初期データ内容を保存
            this.setComparisonRecordModel();
            // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng end
            // グリッドのデータ再表示
            //this.gridDataRefresh();
          })
          .catch(error => {
            if (error.response.status === 400) {
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
              getErrorMessage('MstComSvSettingMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
              this.$ons.notification.alert({
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "取得失敗",
                // message: "指定されたマスタが見つかりません。"
                title: DIALOG_MESSAGES[12000003].title,
                message: messageFormat(DIALOG_MESSAGES[12000003].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            else{
              getErrorMessage('MstComSvSettingMainComponent.vue', 'findList', error);
            }
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          });
      });
    },
    setFilterCondition(condition) {
      this.condition.recordName = condition.recordName;
      this.condition.includeDeleted = condition.includeDeleted;
    },
    //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
    editorDropDown(container, data) {
      $(`<input class="" name="${data.field}"/>`)
          .appendTo(container)
          .kendoDropDownList({
            dataSource: this.getDeviceEdgeList.filter(e=> e.del === '0' || e.value == data.model.deviceEdgeNo),
            dataTextField: "text",
            dataValueField: "value",
            change: () => {
            }
          });
    },
    //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
    // 指定したデバイスエッジとのマスタ同期
    synchroMstMachineToDeviceEdge(list, idx) {
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 start
      // let title = "通信サーバーマスタ同期";
      let title = messageFormat(DIALOG_MESSAGES['00100009'].title, '通信サーバーマスタ');
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 end
      const infos = list;
      if (infos.length <= idx) {
        return;
      }
      const info = infos[idx];
      // マスタ同期
      this.synchroMstComSvSetting({
        facilityCd:this.facilityListValue,
        deviceEdgeNo: info.value
      })
        .then(() => {
          if (infos.length === idx + 1) {
            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            if (this.errorName.length > 0){
              let name = "";
              this.errorName.forEach(e => {
                name = name + e.text + "</br>";
              });
              name = "デバイスエッジ：</br>" + name + "</br>";
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name)
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            } else {
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message: "マスタ同期が完了しました。"
                message: messageFormat(DIALOG_MESSAGES['00100009'].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
            this.errorName = [];
          } else {
            // 次のデバイスエッジ
            this.synchroMstMachineToDeviceEdge(list, idx + 1);
          }
        })
        .catch(error => {
          if (error.response.status === 400) {
            getErrorMessage('MstComSvSettingMainComponent.vue', 'synchroMstMachineToDeviceEdge', name +'との同期に失敗しました。デバイスエッジの装置と整合性が取れていないので再度「保存」を行ってください。');

            this.errorName.push(info);
            if (infos.length === idx + 1) {
              let name = "";
              this.errorName.forEach(e => {
                name = name + e.text + "</br>";
              });
              name = "デバイスエッジ：</br>" + name + "</br>";
              //共通ローダー：表示終了
              this.setLoadingScreenVisible(false);
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name)
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
              this.errorName = [];
            } else {
              getErrorMessage('MstComSvSettingMainComponent.vue', 'synchroMstMachineToDeviceEdge', error);
              // 次のデバイスエッジ
              this.synchroMstMachineToDeviceEdge(list, idx + 1);
            }
          }
        });
    },
    saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      this.lastscrollTop = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop;
      this.lastscrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft;
      /* add スクロールの位置を維持 楊 end */
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 更新前の情報をバックアップ
      this.backupMasterRecordList = JSON.parse(
        JSON.stringify(this.getMasterRecordList)
      );

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
      // 型式+製造番号、IPアドレス重複チェック
      const validateMachineInfoMessage = this.validateMachineTypeSerialNo();

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message =  messageFormat(DIALOG_MESSAGES[12000005].message) + validateMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message +  messageFormat(DIALOG_MESSAGES[12000006].message) + validateMessage;
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateMachineInfoMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の項目で問題があります。" + validateMachineInfoMessage;
          message +  messageFormat(DIALOG_MESSAGES['00200071'].message) + validateMachineInfoMessage;
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000005].title,
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        this.$nextTick(() => {
          this.calculateGridHeight();
          /* add スクロールの位置を維持 楊 start */
          document.getElementsByClassName(
            "k-grid-content k-auto-scrollable"
          )[0].scrollTop = this.lastscrollTop;
          document.getElementsByClassName(
            "k-grid-content k-auto-scrollable"
          )[0].scrollLeft = this.lastscrollLeft;
          setTimeout(() => {
            this.lastScrollTop = 0;
            this.lastScrollLeft = 0;
          }, 1000);
          /* add スクロールの位置を維持 楊 end */
        });
        return;
      }

      // デバイスエッジ一覧
      //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
      // const deviceEdgeList = this.getDeviceEdgeList;
      const deviceEdgeList = this.getDeviceEdgeList.filter(item => item.del !== '1');
      //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される end

      // mod 7686 修正 chen start
      // upd 8838 装置通信・仮想端末マスタの並び順がNG 修正 20230613 ztc start
      // const updateRecordList = this.getUpdateRecordList.filter(es => es.operation && es.operation > 0);
      // if (updateRecordList.length === 0) {
      //   this.setLoadingScreenVisible(false);
      //   return;
      // }
      // apiをコールして値を保存
      // this.updateRecordListByFacilityCd({facilityCd: this.facilityListValue, request: updateRecordList})
      this.updateRecordListByFacilityCd({facilityCd: this.facilityListValue, request: this.getUpdateRecordList})
      // upd 8838 装置通信・仮想端末マスタの並び順がNG 修正 20230613 ztc end
      // mod 7686 修正 chen end
        .then(response => {
          this.updateResponse = response.data;
          // this.$ons.notification.alert({
          //   title: "更新完了",
          //   message: "マスタ更新が完了しました。"
          // });
          this.isSorted = false;
          this.findList();

          // マスタ同期開始
          this.synchroMstMachineToDeviceEdge(deviceEdgeList, 0);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MstComSvSettingMainComponent.vue', 'updateRecordListByFacilityCd', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          if (error.response.status === 400) {
            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
          // 更新前の情報に戻す
          const backups = this.backupMasterRecordList;
          this.setMasterRecordList(backups);

          // グリッドのデータ再表示
          this.gridDataRefresh();
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
    // デバイスエッジの重複チェック
    validateMachineTypeSerialNo() {
      let validateMessageArr = [];
      let checkDeviceEdgeNo = [];

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data;
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        let rowNo = rowIdx + 1;
        // 装置名取得
        let name = rows[rowIdx]["deviceEdgeNo"];
        // 削除対象判定
        let del = rows[rowIdx]["isDisp"] === "1" ? "" : "(削除分)";
        // 装置名重複チェック
        let idxNo = 1 + checkDeviceEdgeNo.indexOf(name.toString());
        if (1 <= idxNo) {
          let dels =  rows[idxNo -1]["isDisp"]=== "1" ? "" : "(削除分)";
          // 重複あり
          let strerr =
            "デバイスエッジ重複あり：<br>　　　" +
            idxNo +
            "行目" + dels + "と" +
            rowNo +
            "行目" +
            del;
          validateMessageArr.push(strerr);
        } else {
          // 重複なし
          checkDeviceEdgeNo.push(name.toString());
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
      //add 8840 装置通信・仮想端末マスタの並び順が保存できない 修正 20230613 ztc start
      let sortNum = 1;
      for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
        if(this.getMasterRecordList.data[i].isDisp === '1' ) {
          this.getMasterRecordList.data[i].sortRank = sortNum;
          sortNum++;
        }
      }
      //add 8840 装置通信・仮想端末マスタの並び順が保存できない 修正 20230613 ztc end
    },
    onSave(ev) {
      this.editingFlg = false;
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      ev.sender.refresh();
      if (ev.model.operation === 1) {
        ev.model["edited"] = true;
      }
      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    },
    showMasterEditModal(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $("div.k-grid-content")[0];
      this.scrollPosition.top = grid.scrollTop;
      this.scrollPosition.left = grid.scrollLeft;

      // モーダルを表示
      this.showMasterEdit();

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
      $("div.k-grid-content")
        .scrollTop(position.top)
        .scrollLeft(position.left);
    },
    toRankEditBtnClick() {
          // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $("div.k-grid-content")[0];
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
        // 通信SV専用初期値
        if (k === "offlineStartTime") {
          d[k] = null;
        }
      });
      this.lastScrollTop = this.$refs.grid.$el.lastChild.scrollHeight;
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      this.editBackgroundColor();
    },
    sortBtnClick() {
         // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $("div.k-grid-content")[0];
      this.scrollPosition.top = grid.scrollTop;
      this.scrollPosition.left = grid.scrollLeft;
      EventBus.$emit("onCloseMasterEditModal", this.onCloseMasterEditModal);

      const tempData = JSON.parse(
        JSON.stringify(this.getMasterRecordList.data)
      );
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      EventBus.$emit("setSortMode", this.isSortMode);
    },
    sortChange(tempData){
      let flag = false;
      this.getMasterRecordList.data.forEach( item => {
        tempData.forEach( tempItem => {
          if(item.code === tempItem.code && item.sortRank !== tempItem.sortRank)
            flag = true;
        })
      })
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
          column.field == "sortRank"
            ? this.isAllowSort
              ? () => true
              : () => false
            : () => false;
      });
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
        // add #9863 編集時背景色表示異常の横展開 蔡 start
        const lockTbodyc = this.$refs.grid.$el.children[1].lastChild.tBodies[0].children;
        // add #9863 編集時背景色表示異常の横展開 蔡 end  
        // add redmine 5737 デバイスエッジの設定変更後、対象のデバイスエッジの色が変わらない 宋qy start
        const gridData = this.$refs.grid.dataSource;
        // add redmine 5737 デバイスエッジの設定変更後、対象のデバイスエッジの色が変わらない 宋qy end
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;
          // add #9863 編集時背景色表示異常の横展開 蔡 start
          const currentLockTrc = lockTbodyc[rwCount].children;
          // add #9863 編集時背景色表示異常の横展開 蔡 end
          // 並び順の色変更
          this.changeSortColor(currentTrc);
          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc);
          // 削除対象を判定
          const deleted = this.isDeleteRow(currentTrc);

          // モーダルからの編集も色を変更する
          if (
            // mod redmine 5737 デバイスエッジの設定変更後、対象のデバイスエッジの色が変わらない 宋qy start
            this.isEdited(gridData.data[rwCount].code)
            // mod redmine 5737 デバイスエッジの設定変更後、対象のデバイスエッジの色が変わらない 宋qy end
          ) {
            edited = true;
          }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, edited, deleted);
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
    isDeleteRow(currentTrc) {
      let deleted = false;
      // 削除カラムで削除が選択されている場合は削除フラグを設定
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount]) &&
          clCount !== this.getColumnIndex("sortRank")
        ) {
          if (
            currentTrc[clCount].children[0].nextSibling &&
            currentTrc[clCount].children[0].nextSibling.data === "削除" &&
            this.getColumnIndex("isDisp") === clCount
          ) {
            deleted = true;
          }
        }
      }
      return deleted;
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
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // currentTrc[this.getColumnIndex("code")].textContent,
          currentTrc[this.getColumnIndex('code')].textContent.replaceAll(",", ""),
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
          columnInfo.field
        );
        if (
          columnInfo.values !== null &&
          hasValueColumn &&
          currentTrc[clCount].textContent === ""
        ) {
          currentTrc[clCount]?.classList?.add("master-deleted-combo");
        }
      }
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains("k-dirty-cell");
    },
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

    //画面表示
    loadGridData(){
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        // add マスタ一覧 1･施設切替を可能とする 王 start
        // this.facilityListValue = this.getStateUserAccountInfo.facilityCd;
        this.facilityListValue = this.getFacilitySwitch;
        // add マスタ一覧 1･施設切替を可能とする 王 end
        this.setSelectFacility(this.facilityListValue);
        // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          // add マスタ一覧 1･施設切替を可能とする 王 start
          // this.facilityListValue = this.getStateUserAccountInfo.facilityCd;
          this.facilityListValue = this.getFacilitySwitch;
          // add マスタ一覧 1･施設切替を可能とする 王 end
          this.setSelectFacility(this.facilityListValue);
          // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
          this.findList();
        })
        .catch(error => {
          alert(error);
          if (error.response.status === 400) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MstComSvSettingMainComponent.vue', 'loadGridData', '指定されたマスタが見つかりません。');
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          else{
            getErrorMessage('MstComSvSettingMainComponent.vue', 'loadGridData', error);
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        });
    },
    onOpenFacility(e) {
      // 変更前の値を取得
      this.prevFacilityCd = e.sender._old;
    },
    // 施設を選択時の動作
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
                // 選択した施設を元に装置一覧の取得
                this.facilityListValue = newFacilityCd;
                this.setSelectFacility(this.facilityListValue);
                this.findList();
              } else {
                // 変更前の施設を設定する
                this.facilityListValue = this.prevFacilityCd;
              }
            }
          });
        } else {
          // 選択した施設を元に装置一覧の取得
          this.facilityListValue = e.sender._old;
          this.setSelectFacility(this.facilityListValue);
          this.findList();
        }
      }
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
                 // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
                  this.findList();
              }
            }
          });
        } else {
          // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
          this.findList();
        }
      }
    },
    /**
     * 行をコピー追加した時の処理
     */
    addedRow(){
      // スクロールバーを一番下にする
      this.lastScrollTop = this.$refs.grid.$el.lastChild.scrollHeight;
    },
  },
  created() {
    this.setLoadingScreenVisible(true);
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
  },
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
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
  padding: 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}
.kendo-grid-toolbar-style {
  --height: 100%;
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
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
</style>
