   /** * 治療状況リスト（治療状況リスト画面） MainContent */
<template>
  <div class="conf-body status-list-page">
    <div id="flex-area">
      <div
        id="device-grid-area"
        v-show="RODeviceStatus || DADDeviceStatus || DABDeviceStatus"
      >
        <!-- RO -->
        <div
          id="dro-device-grid"
          class="device-list-grid"
          v-show="RODeviceStatus"
        >
          <kendo-grid-native
            ref="gridDro"
            class="list_dro"
            :class="fontSizeSet"
            :data-items="nativeDataSourceDro"
            :editable="false"
            :reorderable="true"
            :resizable="true"
            :sortable="sortable"
            :sort="sortDro"
            @columnreorder="columnReorderDro"
            :columns="nativeDroColumns"
            @sortchange="sortDroChangeHandler"
            @rowclick="onClickDevice"
            @warn-click="warnClick"
            @info-click="infoClick"
            @blank-click="blankClick"
            @columnresize="columnResizeEventDro"
          >
            <grid-norecords />
          </kendo-grid-native>
        </div>
        <!-- 溶解 -->
        <div
          id="dad-device-grid"
          class="device-list-grid"
          v-show="DADDeviceStatus"
        >
          <kendo-grid-native
            ref="gridDad"
            class="list_dad"
            :class="fontSizeSet"
            :data-items="nativeDataSourceDad"
            :editable="false"
            :reorderable="true"
            :resizable="true"
            :sortable="sortable"
            :sort="sortDad"
            @columnreorder="columnReorderDad"
            :columns="nativeDadColumns"
            @sortchange="sortDadChangeHandler"
            @rowclick="onClickDevice"
            @warn-click="warnClick"
            @info-click="infoClick"
            @blank-click="blankClick"
            @columnresize="columnResizeEventDad"
          >
            <grid-norecords />
          </kendo-grid-native>
        </div>
        <!-- 供給 -->
        <div
          id="dab-device-grid"
          class="device-list-grid"
          v-show="DABDeviceStatus"
        >
          <kendo-grid-native
            ref="gridDab"
            class="list_dab"
            :class="fontSizeSet"
            :data-items="nativeDataSourceDab"
            :editable="false"
            :reorderable="true"
            :resizable="true"
            :sortable="sortable"
            :sort="sortDab"
            @columnreorder="columnReorderDab"
            :columns="nativeDabColumns"
            @sortchange="sortDabChangeHandler"
            @rowclick="onClickDevice"
            @warn-click="warnClick"
            @info-click="infoClick"
            @blank-click="blankClick"
            @columnresize="columnResizeEventDab"
          >
            <grid-norecords />
          </kendo-grid-native>
        </div>
      </div>
      <div id="status-grid-header">
        <div id="batch-check-area">
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-button -->
          <!--   v-if="isShowAllSuccessButton" -->
          <!--   class="common-style-ok-button btn1-execute" -->
          <!--   @click="batchCheck" -->
          <!--   :disabled="batchCheckDisable" -->
          <!--   >一括確定</v-ons-button -->
          <!-- > -->
          <v-ons-button
            v-if="isShowAllSuccessButton"
            class="common-style-ok-button btn1-execute"
            @click="batchCheck"
            :disabled="batchCheckDisable || !getItemAuthorized('StatusListMap', 'default_authority')"
            >一括確定</v-ons-button
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
        </div>
        <table class="dialysis-adjusting-device">
          <tr>
            <td style="text-align: center">
              <v-ons-button
                class="td-button button-font"
                style="width: 6em; margin-right: 0.5em"
                :disabled="sortCancelInActive"
                :style="sortCancelColorStyle"
                @click="sortCancelClick"
                >ソート解除</v-ons-button
              >
            </td>
            <td style="text-align: center">
              <v-ons-button
                id="dro-device"
                class="td-button button-font"
                :class="roBlinkClass"
                :style="roColorStyle"
                @click="deviceClick"
                >RO</v-ons-button
              >
            </td>
            <td style="text-align: center">
              <v-ons-button
                id="dad-device"
                class="td-button button-font"
                :class="dadBlinkClass"
                :style="dadColorStyle"
                @click="deviceClick"
                >溶解</v-ons-button
              >
            </td>
            <td style="text-align: center">
              <v-ons-button
                id="dab-device"
                class="td-button button-font"
                :class="dabBlinkClass"
                style="margin-right: 0.5em"
                :style="dabColorStyle"
                @click="deviceClick"
                >供給</v-ons-button
              >
            </td>
            <td class="alarm-notification-cell">
              <v-ons-button
                class="alarm-notification-list button-font"
                :style="alarmColorStyle"
                :class="alarmBlinkClass"
                @click="moveAlarmNoticeList"
                >警報報知一覧</v-ons-button
              >
            </td>
          </tr>
        </table>
      </div>
      <!-- 透析装置 -->
      <div id="main-list-grid-box" class="status-scale-area">
        <kendo-grid-native
          ref="grid"
          class="list_dcs"
          :class="mainGridClasses"
          :style="{width: gridWidth, height: '100%'}"
          :take="take"
          :skip="skip"
          :scrollable="'virtual'"
          :column-virtualization="true"
          :total="nativeDataSourceDcs.length"
          @pagechange="pageChange"
          :row-height="40"
          :data-items="gridDataItem"
          :edit-field="'inEdit'"
          :reorderable="true"
          :resizable="true"
          :sortable="sortable"
          :sort="sortDcs"
          :columns="nativeDcsColumns"
          @columnreorder="columnReorderDcs"
          @sortchange="sortDcsChangeHandler"
          @clickBedName="onClickBedName"
          @clickPatName="onClickPatName"
          @clickContentChange="onClickContentChange"
          @clickDeleteOrder="onClickDeleteOrder"
          @clickConfirmOrder="onClickConfirmOrder"
          @clickMachineRecordCd="onClickMachineRecordCd"
          @changeStaff="onSaveChanged"
          @changeDateTime="onSaveChanged"
          @rowclick="rowClick"
          @cellclick="cellClick"
          @editStart="editStart"
          @editEnd="editEnd"
          @warn-click="warnClick"
          @info-click="infoClick"
          @blank-click="blankClick"
          :hasUnregisteredOption="false"
          @columnresize="columnResizeEvent"
        >
          <grid-norecords />
        </kendo-grid-native>
      </div>
      <div id="area_usage_guide" v-if="!isNotUsageGuide">
        <div class="usage-guide-div">
          <div
            class="usage-guide-element"
            style="background-color: white; border: silver solid 1px"
          ></div>
          次患者
        </div>
        <div class="usage-guide-div">
          <div
            class="usage-guide-element"
            style="background-color: #42cb92; border: #42cb92 solid 1px"
          ></div>
          前体重測定済
        </div>
        <div class="usage-guide-div">
          <div
            class="usage-guide-element"
            style="background-color: #2ca06f; border: #2ca06f solid 1px"
          ></div>
          治療中
        </div>
        <div class="usage-guide-div">
          <div
            class="usage-guide-element"
            style="background-color: #557769; border: #557769 solid 1px"
          ></div>
          治療終了
        </div>
        <div class="usage-guide-div">
          <div
            class="usage-guide-element"
            style="background-color: #00b0f0; border: #00b0f0 solid 1px"
          ></div>
          洗浄・消毒
        </div>
        <div class="usage-guide-div">
          <div
            class="usage-guide-element"
            style="background-color: #ff6699; border: #ff6699 solid 1px"
          ></div>
          通信エラー
        </div>
        <div class="usage-guide-div">
          <div style="color: #A356A3">患者名</div>
          ：入院患者
        </div>
        <div style="display: flex">
          <div>患者名</div>
          ：外来患者
        </div>
      </div>
    </div>
    <div v-if="buttonConfig == 1">
      <v-ons-alert-dialog
        modifier="rowfooter"
        :visible="diaView"
        :style="(height = '100px')"
      >
        <span slot="title"
          >未実施の投与薬剤が含まれていますがよろしいですか？</span
        >
        <template slot="footer">
          <v-ons-alert-dialog-button @click="diaView = false"
            >キャンセル</v-ons-alert-dialog-button
          >
          <v-ons-alert-dialog-button @click="zisekiConfirm(false)"
            >未実施確定</v-ons-alert-dialog-button
          >
          <v-ons-alert-dialog-button @click="zisekiConfirm(true)"
            >実施済確定</v-ons-alert-dialog-button
          >
        </template>
        <div v-if="buttonConfig == 1">
          <ul class="align-items-left" style="padding: 0; list-style: none">
            <li v-for="(radioItem, index) in recordList" :key="index">
              {{ radioItem.name }}&nbsp;{{ radioItem.amount }}&nbsp;{{
                radioItem.unit
              }}
            </li>
          </ul>
        </div>
        <div>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              <label> キャンセル：治療実績の確定をキャンセルします。 </label>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              <label> 未実施確定：投与薬剤未実施のまま実績確定します。 </label>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              実施済確定：未実施の投与薬剤を実施済にして実績確定します。投与日時は現在日時、実施者はサインイン者で登録します。
            </v-ons-col>
          </v-ons-row>
        </div>
      </v-ons-alert-dialog>
    </div>
    <div v-if="buttonConfig == 2">
      <v-ons-alert-dialog
        modifier="rowfooter"
        :title="''"
        :footer="{
          キャンセル: () => (diaView = false),
          未実施確定: () => zisekiConfirm(false),
          実施済確定: () => zisekiConfirm(true),
          未実施以外確定: () => mijissiigaiConfirm(false),
        }"
        :visible="diaView"
        :style="(height = '100px')"
      >
        <span slot="title"
          >確定する治療実績に、投与薬剤が未実施の治療が含まれていますがよろしいですか？</span
        >
        <template slot="footer">
          <v-ons-alert-dialog-button @click="diaView = false"
            >キャンセル</v-ons-alert-dialog-button
          >
          <v-ons-alert-dialog-button @click="zisekiConfirm(false)"
            >未実施確定</v-ons-alert-dialog-button
          >
          <v-ons-alert-dialog-button @click="zisekiConfirm(true)"
            >実施済確定</v-ons-alert-dialog-button
          >
          <v-ons-alert-dialog-button @click="mijissiigaiConfirm(false)"
            >未実施以外確定</v-ons-alert-dialog-button
          >
        </template>
        <div v-if="buttonConfig == 2">
          <ul class="align-items-left" style="padding: 0; list-style: none">
            <li v-for="(radioItem, index) in recordList" :key="index">
              {{ radioItem.patName }}&nbsp; {{ radioItem.tempKurName }}&nbsp;
              {{ radioItem.bedName }}&nbsp; {{ radioItem.name }}&nbsp;
              {{ radioItem.amount }}&nbsp;
              {{ radioItem.unit }}
            </li>
          </ul>
        </div>
        <div>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              <label> キャンセル：治療実績の確定をキャンセルします。 </label>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              <label> 未実施確定：投与薬剤未実施のまま実績確定します。 </label>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              実施済確定：未実施の投与薬剤を実施済にして実績確定します。投与日時は現在日時、実施者はサインイン者で登録します。
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              未実施以外確定：未実施の投与薬剤を含む治療実績以外を確定します。
            </v-ons-col>
          </v-ons-row>
        </div>
      </v-ons-alert-dialog>
    </div>
  </div>
</template>

<script>
import moment from "moment";
import { mapState, mapActions, mapGetters, mapMutations } from "vuex";
import commonFunctions from "@/components/status-list/StatusCommonFunction";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
import { KEY_NAME_STATUS_LIST } from "@/constants/defaultSettingConstants";
import { EventBus } from "@/eventBus.js";
import { orderBy } from "@progress/kendo-data-query";
// #10338 2024.03.29 del 外部連携をREST API側に構築 TDC片口 start
// import { createJournal } from "@/apis/journal";
// #10338 2024.03.29 del 外部連携をREST API側に構築 TDC片口 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
// mod #10359 編集権限の動作不正 dengshen start
// import { deepCopy } from "@/functions/common/CommonFunctions";
import { deepCopy, getAuthorized, initForceSignOutFlag } from "@/functions/common/CommonFunctions.js";
// mod #10359 編集権限の動作不正 dengshen end
// add FNSI-画面リロードの修正 徐 start
import { NOTIFY_TOPIC_MACHINE_RESULT } from "@/constants/websocketNotifyTopic";
import { STATUS_AUTO_SETTING, STATUS_LIST_FORCE_SIGNOUT } from "@/constants/facilitySetting";
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
// add FNSI-画面リロードの修正 徐 end
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add #10359 編集権限の動作不正 dengshen start
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// add #10359 編集権限の動作不正 dengshen end
import { ALERT_TYPES } from "@/constants/statusMapConstants";
import { 
  TREATMENT_ITEM_CD, 
  DISP_ITEM_DRO,
  DISP_ITEM_DAB,
  DISP_ITEM_DAD,
  ORDER_NUMBER_FIELDS,
  ORDER_TIME_FIELDS,
  ORDER_REVERSE_FIELDS
} from "@/constants/mstTreatmentStatusDispItemConstants";
import { MACHINE_MODEL } from "@/constants/machineModel";
import { multiSortableCompare } from "@/functions/SortFunctions";
import PrintMixin from "@/components/PrintMixin";

const dummyColumnProps = {
  field: "dummyColumn",
  title: "",
  width: "0px",
  hidden: false,
  locked: false,
  reorderable: false,
  orderIndex: 0,
};

export default {
  // mod #10359、#10331 編集権限について、対応する。 dengshen start
  // mixins: [NextTransitionMixin, MasterMaintenanceMixin, PatHeaderControlMixin],
  mixins: [NextTransitionMixin, MasterMaintenanceMixin, PatHeaderControlMixin, ComponentGuardMixin, PrintMixin],
  // mod #10359、#10331 編集権限について、対応する。 dengshen end
  props: {
    // NOTE: コンソールエラー対策
    historyKey: null,
  },
  computed: {
    // add #11285 機能帳票の印刷情報対応② 高 start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #11285 機能帳票の印刷情報対応② 高 end
    // add #5746 透析液調製装置を表示していた状態を覚えていない。 dou start
    ...mapGetters("status-list/list", {
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou start
      getStatusList: "getStatusList",
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou end
      // 分割された画面の幅取得
      RODeviceStatus: "getRODeviceStatus",
      DABDeviceStatus: "getDABDeviceStatus",
      DADDeviceStatus: "getDADDeviceStatus",
      // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
      getFirstInit: "getFirstInit",
      dispDab: "getDispDab",
      dispDad: "getDispDad",
      dispDro: "getDispDro",
      // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
      getSysMonitorItem: "getSysMonitorItem",
    }),
    // add #5746 透析液調製装置を表示していた状態を覚えていない。 dou end
    ...mapGetters("status-list/list", [
      "getIsShowMain",
      "treatAllColumn",
      "conditionFilter",
      "getDeviceDataSource",
      "getBedListData",
      "makeUpdateTreatmentStatus",
      "isDispTreatData",
      "getEditingField",
      "getColumnSort",
      "getIsAlarmDisplay",
      // add FNSI-redmine#4252 付 start
      "getColumnResizeData",
      // add FNSI-redmine#4252 付 end
      // add FNSI-redmine#5747 高 start
      "getDroColumnResizeData",
      "getDadColumnResizeData",
      "getDabColumnResizeData",
      // add FNSI-redmine#4252 高 end
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("window-size", {
      // 分割された画面の幅取得
      splittedWidth: "getSplittedWidth",
    }),
    ...mapGetters("account-edit", {
      getStateUserAccountInfo: "getStateUserAccountInfo",
      getUserId: "getUserId",
      getDefaultSetting: "getDefaultSetting",
    }),
    ...mapState("account-edit", ["fontSize", "showSidebarFlg"]),
    // add 機能帳票パラメータ確認 陳 start
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add 機能帳票パラメータ確認 陳 end
    ...mapGetters("window-size", {
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("user-selector-popover", ["mstPersonalUser"]),
    mainGridClasses() {
      const result = [this.fontSizeSet];
      if (this.isIOS || this.isAndroid) {
        result.push("no-scrollbar-area-header");
      }
      return result;
    },
    // -----------------------------------------
    // grid:column情報取得
    // -----------------------------------------
    dcsColumns() {
      // add FNSI-redmine#4252 付 start
      if (this.getColumnResizeData != null && this.getColumnResizeData != []) {
        this.treatAllColumn.dcsTreatSetCol.forEach((e) => {
          this.getColumnResizeData.forEach((col) => {
            if (e.field == col.field) {
              e.width = col.width + "px";
            }
          });
        });
      }
      // add FNSI-redmine#4252 付 end
      return this.treatAllColumn.dcsTreatSetCol;
    },
    //add FNSI redmine 6726 劉祥霖 start
    droColumns() {
      // add FNSI-redmine#5747 高 start
      if (
        this.getDroColumnResizeData != null &&
        this.getDroColumnResizeData != []
      ) {
        this.treatAllColumn.droTreatSetCol.forEach((e) => {
          this.getDroColumnResizeData.forEach((col) => {
            if (e.field == col.field) {
              e.width = col.width + "px";
            }
          });
        });
      }
      return this.treatAllColumn.droTreatSetCol;
    },
    dabColumns() {
      if (
        this.getDabColumnResizeData != null &&
        this.getDabColumnResizeData != []
      ) {
        this.treatAllColumn.dabTreatSetCol.forEach((e) => {
          this.getDabColumnResizeData.forEach((col) => {
            if (e.field == col.field) {
              e.width = col.width + "px";
            }
          });
        });
      }
      return this.treatAllColumn.dabTreatSetCol;
    },
    dadColumns() {
      if (
        this.getDadColumnResizeData != null &&
        this.getDadColumnResizeData != []
      ) {
        this.treatAllColumn.dadTreatSetCol.forEach((e) => {
          this.getDadColumnResizeData.forEach((col) => {
            if (e.field == col.field) {
              e.width = col.width + "px";
            }
          });
        });
      }
      return this.treatAllColumn.dadTreatSetCol;
    },
    // add FNSI-redmine#5747 高 end
    batchCheckDisable() {
      let count = 0;
      let gridDataList = [];
      let filterGridData = this.nativeDataSourceDcs;
      if (filterGridData.length > 0) {
        gridDataList = filterGridData;
      } else {
        return true;
      }
      for (let gridData of gridDataList) {
        if (
          gridData.rstDialysisState == 5 &&
          gridData.ordNo !== null &&
          gridData.patId !== null
        ) {
          count++;
          break;
        }
      }
      if (count > 0) {
        return false;
      } else {
        return true;
      }
    },
    //add FNSI redmine 6726 劉祥霖 end
    // del FNSI-redmine#5747 高 start
    // dabColumns() {
    //   return this.treatAllColumn.dabTreatSetCol;
    // },
    // dadColumns() {
    //   return this.treatAllColumn.dadTreatSetCol;
    // },
    // droColumns() {
    //   return this.treatAllColumn.droTreatSetCol;
    // },
    // del FNSI-redmine#5747 高 end
    // -----------------------------------------
    // grid:dataSource取得
    // -----------------------------------------
    nativeDataSourceDcs() {
      // mod FNSI-ソート順の修正 付 start
      let paramData = {
        fieldNameObj: this.sortDcs,
        /* modify by chamaojia 2024-03-28 [10303、10304] data processing has been completed in the backend --start */
        // datalist: filterBy(this.dcsDataSource, this.gridFilterResult).filter(ele => ele.bedName != null || ele.kurName != null)
        datalist: this.dcsDataSource,
        /* modify by chamaojia 2024-03-28 [10303、10304] data processing has been completed in the backend --end */
        datalistType: MACHINE_MODEL.DCS
      }
      return this.sortNullData(paramData);
      // return orderBy(
      //   filterBy(this.dcsDataSource, this.gridFilterResult),
      //   this.sortDcs
      // );
      // mod FNSI-ソート順の修正 付 end
    },
    nativeDataSourceDro() {
      // mod FNSI-ソート順の修正 付 start
      let paramData = {
        fieldNameObj: this.sortDro,
        datalist: this.droDataSource,
        datalistType: MACHINE_MODEL.DRO
      };
      return this.sortNullData(paramData);
      // return orderBy(this.droDataSource, this.sortDro);
      // mod FNSI-ソート順の修正 付 end
    },
    nativeDataSourceDab() {
      // mod FNSI-ソート順の修正 付 start
      let paramData = {
        fieldNameObj: this.sortDab,
        datalist: this.dabDataSource,
        datalistType: MACHINE_MODEL.DAB
      };
      return this.sortNullData(paramData);
      // return orderBy(this.dabDataSource, this.sortDab);
      // mod FNSI-ソート順の修正 付 end
    },
    nativeDataSourceDad() {
      // mod FNSI-ソート順の修正 付 start
      let paramData = {
        fieldNameObj: this.sortDad,
        datalist: this.dadDataSource,
        datalistType: MACHINE_MODEL.DAD
      };
      return this.sortNullData(paramData);
      // return orderBy(this.dadDataSource, this.sortDad);
      // mod FNSI-ソート順の修正 付 end
    },
    /**
     * 現在の表示グリッドから患者選択リストを取得する
     */
    StatusListToPatList() {
      let ret = [];

      // gridの全行取得
      const view = this.nativeDataSourceDcs;
      view.forEach(function (value, index, array) {
        // 治療実績判定
        const info = array[index];
        if (info.ordNo !== null && info.ordNo !== undefined) {
          let list = {
            pat_id: info.patId,
            pat_last_name: info.patLastName,
            pat_first_name: info.patFirstName,
            ord_no: info.ordNo,
            kur_name: info.kurName,
            bed_name: info.bedName,
            is_same: info.isSame,
            in_out_class: info.inOutClass,
            ...info
          };
          ret.push(list);
        }
      });
      return ret;
    },
    isShowAllSuccessButton() {
      return this.getIsShowMain;
    },
    sortable() {
      return {
        allowUnsort: true,
        mode: "multiple",
      };
    },
    isNotUsageGuide() {
      return this.conditionFilter.notUsageGuide;
    },
    /**
     * 警報・報知カラム fieldマップ ※ソートで使用
     */
    fieldAlarmMap() {
      const map = {
        [MACHINE_MODEL.DCS]: this.treatAllColumn.dcsTreatSetCol.find(item => item.data_class === TREATMENT_ITEM_CD.ALARM_NOTICE)?.field,// 透析装置
        [MACHINE_MODEL.DRO]: this.treatAllColumn.droTreatSetCol.find(item => item.keyName === DISP_ITEM_DRO.ALARM_NOTICE)?.field,   // RO
        [MACHINE_MODEL.DAB]: this.treatAllColumn.dabTreatSetCol.find(item => item.keyName === DISP_ITEM_DAB.ALARM_NOTICE)?.field,   // 供給
        [MACHINE_MODEL.DAD]: this.treatAllColumn.dadTreatSetCol.find(item => item.keyName === DISP_ITEM_DAD.ALARM_NOTICE)?.field    // 溶解
      };
      return map;
    },
    /**
     * 数値化できるものは数値としてソートする fieldの配列 ※ソートで使用
     *  - mst_add_monitorはすべて対象、sys_monitor_itemとmst_treatment_status_disp_itemは特定の項目が対象
     *  - mst_add_monitor: mst_treatment_status_layout.XXX_view_items->"data_class" 10000番台
     *  - sys_monitor_item: mst_treatment_status_layout.XXX_view_items->"data_class" マイナス10000超え番台でdata_typeが 3:時間・時刻 以外
     *  - mst_treatment_status_disp_item: mst_treatment_status_layout.XXX_view_items->"data_class" mst_treatment_status_disp_item.item_cd
     */
    fieldOrderAsNumberMap() {
      // mst_add_monitor
      const mstAddMonitor = this.treatAllColumn.dcsTreatSetCol.filter(item => item.data_class > 10000).map(item => item.field);
      // mst_treatment_status_disp_item
      const mstDispItem = this.treatAllColumn.dcsTreatSetCol.filter(item => ORDER_NUMBER_FIELDS.includes(item.data_class)).map(item => item.field);
      // sys_monitor_itemからdata_typeが 3:時間・時刻 以外のmoni_data_noを抽出
      const moniDataNos = this.getSysMonitorItem.filter(item => item.data_type !== 3).map(item => item.moni_data_no);
      
      const map = {
        //  透析装置 
        [MACHINE_MODEL.DCS]: [
          ...this.treatAllColumn.dcsTreatSetCol.filter(item => item.data_class < -10000 && moniDataNos.includes(item.keyName)).map(item => item.field),
          ...mstAddMonitor,
          ...mstDispItem
        ],
        // RO
        [MACHINE_MODEL.DRO]: this.treatAllColumn.droTreatSetCol.filter(item => item.data_class < -10000 && moniDataNos.includes(item.keyName)).map(item => item.field),
        // 供給
        [MACHINE_MODEL.DAB]: this.treatAllColumn.dabTreatSetCol.filter(item => item.data_class < -10000 && moniDataNos.includes(item.keyName)).map(item => item.field),
        // 溶解
        [MACHINE_MODEL.DAD]: this.treatAllColumn.dadTreatSetCol.filter(item => item.data_class < -10000 && moniDataNos.includes(item.keyName)).map(item => item.field)
      };
      return map;
    },
    /**
     * 時刻形式（hh:mm）にフォーマットしてソートする fieldの配列 ※ソートで使用
     *  - sys_monitor_itemとmst_treatment_status_disp_itemの特定の項目が対象
     */
    fieldOrderAsTimeMap() {
      // mst_treatment_status_disp_item
      const mstDispItem = this.treatAllColumn.dcsTreatSetCol.filter(item => ORDER_TIME_FIELDS.includes(item.data_class)).map(item => item.field);
      // sys_monitor_itemからdata_typeが 3:時間・時刻 のmoni_data_noを抽出
      const moniDataNos = this.getSysMonitorItem.filter(item => item.data_type === 3).map(item => item.moni_data_no);
      const map = {
        //  透析装置
        [MACHINE_MODEL.DCS]: [
          ...this.treatAllColumn.dcsTreatSetCol.filter(item => item.data_class < -10000 && moniDataNos.includes(item.keyName)).map(item => item.field),
          ...mstDispItem
        ],
        // 溶解
        [MACHINE_MODEL.DAD]: this.treatAllColumn.dadTreatSetCol.filter(item => item.data_class < -10000 && moniDataNos.includes(item.keyName)).map(item => item.field)
      };
      return map;
    },
    /** ソート解除ボタンの活性or非活性 */
    sortCancelInActive() {
      // すべての表のソート状態が空なら true
      return !this.sortDcs.length &&
             !this.sortDro.length &&
             !this.sortDab.length &&
             !this.sortDad.length;
    },
    /** ソート解除ボタンのカラースタイル */
    sortCancelColorStyle() {
      return this.sortCancelInActive ? { color: "#bfbfbf", background: "#dfdfdf" } : { color: "#ffffff", background: "#4291B9" };
    }
  },
  data() {
    return {
      gridWidth: this.windowWidth - 1 + 'px',
      // add #7947 2022-09-15 【デグレ】????患者の削除後にしばらくすると復活する dou start
      keys: 0,
      // add #7947 2022-09-15 【デグレ】????患者の削除後にしばらくすると復活する dou end
      scrollPositionTop: 0,
      scrollPositionLeft: 0,
      lastScrollTop: 0,
      lastScrollLeft: 0,
      // 現在の画面名
      selfScreenName: "",
      // del #5746 透析液調製装置を表示していた状態を覚えていない。 dou start
      // RODeviceStatus: false,
      // DABDeviceStatus: false,
      // DADDeviceStatus: false,
      // del #5746 透析液調製装置を表示していた状態を覚えていない。 dou end
      defaultColumns: "",
      doneResponseDataLength: 0,
      countVal: 0,
      mediInfo: [],
      dialogDispList: [],
      updateResponse: {
        isSuccess: false,
        errorMessage: "",
      },

      buttonConfig: 0,

      setConfirm: {
        // ordNo
        ordNo: "",
        // doComplete
        isMedi: false,
        // userId
        userId: "",
      },
      confirmList: [],
      gridFilterResult: [],

      // Android判定フラグ
      isAndroid: false,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      // FNSI-add 画面タイマーの修正 徐 start
      //タイマー
      timerId: [],
      // FNSI-add 画面タイマーの修正 徐 end
      nativeDcsColumns: [dummyColumnProps],
      nativeDroColumns: [dummyColumnProps],
      nativeDabColumns: [dummyColumnProps],
      nativeDadColumns: [dummyColumnProps],
      sortDcs: [],
      sortDro: [],
      sortDab: [],
      sortDad: [],

      isIOS: false,
      // mod FNSI-画面スタイル(ボタン)対応 付 start
      // roColorStyle: { color: "white", background: "#0076ff" },
      // dadColorStyle: { color: "white", background: "#0076ff" },
      // dabColorStyle: { color: "white", background: "#0076ff" },
      // alarmColorStyle: { color: "white", background: "#0076ff" },
      roColorStyle: { color: "white", background: "#4291B9" },
      dadColorStyle: { color: "white", background: "#4291B9" },
      dabColorStyle: { color: "white", background: "#4291B9" },
      alarmColorStyle: { color: "white", background: "#4291B9" },
      // mod FNSI-画面スタイル(ボタン)対応 付 end
      roBlinkClass: "",
      dadBlinkClass: "",
      dabBlinkClass: "",
      alarmBlinkClass: "",
      dataSource: [],
      dcsDataSource: [],
      droDataSource: [],
      dabDataSource: [],
      dadDataSource: [],
      // デフォルト設定
      // del #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
      // dispDab: false,
      // dispDad: false,
      // dispDro: false,
      // del #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
      // add FNSI-実績確定修正 徐 start
      recordList: [],
      diaView: false,
      // add FNSI-実績確定修正 徐 end
      // add FNSI-画面リロードの修正 徐 start
      notifyTopic: NOTIFY_TOPIC_MACHINE_RESULT,
      notifyValue: [],
      refreshInterval: 0,
      // add FNSI-画面リロードの修正 徐 end
      // add FNSI-redmine#4252 付 start
      columnsize: [],
      colChangeSize: [],
      isBool: false,
      // add FNSI-redmine#4252 付 end
      // add FNSI-redmine#5747 高 start
      droColumnsize: [],
      droColChangeSize: [],
      droIsBool: false,
      dadColumnsize: [],
      dadColChangeSize: [],
      dadIsBool: false,
      dabColumnsize: [],
      dabColChangeSize: [],
      dabIsBool: false,
      // add FNSI-redmine#5747 高 end
      blinkAlarm: null,
      blinkColor: null,
      skip: 0,
      take: 30,
      gridDataItem: [],
      // add #11285 機能帳票の印刷情報対応② 高 start
      bedCdListString: "",
      kurGroupName: "",
      // add #11285 機能帳票の印刷情報対応② 高 end
    };
  },
  methods: {
    ...mapActions("multi-modal", ["showSchedule", "showIndicationsDiffModal"]),
    ...mapActions("status-map/ind", {
      setIndOrdNo: "setOrdNo",
    }),
    ...mapActions("status-list/list", [
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou start
      "changeOccurDate",
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou end
      "fetchTreatSettingList",
      "setColItemGroupList",
      "setIsGoAlarmPage",
      "fetchStatusLayoutList",
      "setStatusGridColumn",
      "setTreatSettingList",
      "putCheckAfterWeight",
      "getCheckMediDone",
      "getMstPersonalUser",
      "edit",
      "updateTreatmentStatus",
      "setClientWidth",
      "deleteUnknownPatRecord",
      "setEditingField",
      "setColumnSort",
      "conditionSet",
      "setIsAlarmDisplay",
      // #10338 2024.03.29 del 外部連携をREST API側に構築 TDC片口 start
      // // add FNSI-装置の追加 付 start
      // "getMstMachineByOrdNoRst",
      // // add FNSI-装置の追加 付 end
      // #10338 2024.03.29 del 外部連携をREST API側に構築 TDC片口 end
      // add FNSI-redmine#4252 付 start
      "setColumnResizeData",
      // add FNSI-redmine#4252 付 end
      // add FNSI-redmine#5747 高 start
      "setDroColumnResizeData",
      "setDadColumnResizeData",
      "setDabColumnResizeData",
      // add FNSI-redmine#5747 高 end
      "clearDisplayData",
      "fetchSysMonitorItem",
      "fetchMstTreatmentStatusDispItem"
    ]),
    ...mapActions("trend-graph", ["setMachineInfo"]),
    ...mapActions("schedule-assignment/modal", {
      scheduleAssignmentSetSelectOrdNo: "setSelectOrdNo",
    }),
    ...mapActions("send-condition/scale", {
      sendConditionSetSelectOrdNo: "setSelectOrdNo",
    }),
    ...mapActions("treatment-record/common", {
      setTreatmentRecordOrdNo: "setOrdNo",
      setOrdNoForSideBarRecord: "setOrdNoForSideBarRecord",
      //add FNSI修正 治療記録画面バッグ 房 start
      setOrd: "setOrd",
      //add FNSI修正 治療記録画面バッグ 房 end
    }),
    // #10338 2024.03.29 del 外部連携をREST API側に構築 TDC片口 start
    // // add 装置へ送信 付 start
    // ...mapActions("treatment-record/common", ["sendEndDateUpdateInfo"]),
    // // add 装置へ送信 付 end
    // #10338 2024.03.29 del 外部連携をREST API側に構築 TDC片口 end
    ...mapMutations("pat-info", {
      updateTreatmentPatList: "updateTreatmentPatList",
      setSrcFuncName: "setSrcFuncName",
    }),
    // add FNSI-画面リロードの修正 徐 start
    ...mapActions("websocket", [
      "addWatchTopics",
      "removeWatchTopics",
      "dequeueMessage",
    ]),
    ...mapMutations("status-list/list", {
      // add #5746 透析液調製装置を表示していた状態を覚えていない。 dou start
      setRODeviceStatus: "setRODeviceStatus",
      setDABDeviceStatus: "setDABDeviceStatus",
      setDADDeviceStatus: "setDADDeviceStatus",
      // add #5746 透析液調製装置を表示していた状態を覚えていない。 dou end
      setStatusFlg: "setStatusFlg",
      setCreateColumn: "setCreateColumn",
      setStatusList: "setStatusList",
      // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
      setFirstInit: "setFirstInit",
      setDispDab: "setDispDab",
      setDispDad: "setDispDad",
      setDispDro: "setDispDro",
      // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
    }),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      startLoadingScreen: "startLoadingScreen",
      finishLoadingScreen: "finishLoadingScreen",
      executeWithLoadingScreen: "executeWithLoadingScreen",
    }),
    // add FNSI-画面リロードの修正 徐 end
    // add FNSI-ERRORMESSAGE追加処理 付 start
    ...mapActions("notification-message", [
      "registerNotificationMessage",
      "getNotificationMessage",
    ]),
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    // add FNSI-ERRORMESSAGE追加処理 付 end
    // add FNSI-画面パフォーマンス対応 付 start
    ...mapActions("user-selector-popover", ["getMst"]),
    // add FNSI-画面パフォーマンス対応 付 end
    // add FNSI-redmine#4252 付 start
    ...mapActions("operation-viewer/motion-record-detail", ["setMotionRecord"]),
    ...mapActions("operation-viewer/motion-record", ["setHeaderInfo"]),
    ...mapActions("operation-viewer/machine", ["getMachine"]),
    ...mapGetters("operation-viewer/machine", ["getSelectMachine"]),
    
    /** 画面印刷前の制御 */
    handleBeforePrint() {
      // 共通mixinで横スクロール位置が全体の99%を超えている場合は対象に右端時用クラスを付与
      [
        'dro', // RO
        'dad', // 溶解
        'dab', // 供給
        'dcs'  // 透析装置
      ].forEach(type => {
        this.addScrollClass(
          `.list_${type} .k-grid-content`,
          [`.list_${type} table`]
        );
      });
      
      // 透析装置のレイアウト位置リセット
      // 仮想スクロールで見えてる範囲のみ印刷
      const content = document.querySelector('.list_dcs .k-grid-content');
      const vc = document.querySelector('.list_dcs .k-virtual-content');
      const table = vc?.querySelector('table');
      // スクロール位置保存
      this._savedScrollTop = content.scrollTop;
      // transform対象特定
      const target = [table, vc].find(
        el => el && getComputedStyle(el).transform !== 'none'
      );          
      // 元のtransformも保存
      this._savedTransform = target.style.transform;
      // 仮想スクロール無効化
      target.style.transform = 'none';
    },
    /** 画面印刷後の制御 */
    handleAfterPrint() {
      // 共通mixinで付与した右端時用クラスを削除
      [
        'dro', // RO
        'dad', // 溶解
        'dab', // 供給
        'dcs'  // 透析装置
      ].forEach(type => {
        this.removeScrollClass( [`.list_${type} table`] );
      });
      
      // 透析装置のスクロール位置を元に戻す
      const content = document.querySelector('.list_dcs .k-grid-content');
      const vc = document.querySelector('.list_dcs .k-virtual-content');
      const table = vc?.querySelector('table');
      const target = [table, vc].find(el => el);
      // transformを元に戻す
      target.style.transform = this._savedTransform || '';  
      // スクロール位置復元
      content.scrollTop = this._savedScrollTop || 0;
    },
    
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    pageChange (event) {
      this.skip = event.page.skip;
      this.take = event.page.take;
      this.gridDataItem = this.nativeDataSourceDcs.slice(event.page.skip, event.page.skip + event.page.take);
    },
    // add FNSI-redmine#5747 高 start
    columnResizeEventDro(event) {
      let index = event.index;
      let newWidth = event.newWidth;
      let fieldName = event.columns[index].field;
      this.droColumnsize.push({
        time: Date.now(),
        width: newWidth,
        field: fieldName,
      });
      if (
        this.getDroColumnResizeData != null &&
        this.getDroColumnResizeData != []
      ) {
        this.getDroColumnResizeData.forEach((index) => {
          this.droColumnsize.push(index);
        });
      }
      if (this.droColumnsize != null && this.droColumnsize != []) {
        const groupBy = (array, f) => {
          let groups = {};
          array.forEach((o) => {
            let group = JSON.stringify(f(o));
            groups[group] = groups[group] || [];
            groups[group].push(o);
          });
          return Object.keys(groups).map((group) => {
            return groups[group];
          });
        };
        const sorted = groupBy(this.droColumnsize, (item) => {
          return item.field;
        });
        let data = [];
        if (sorted != null && sorted != []) {
          sorted.forEach((e) => {
            e.sort(function sortNum(a, b) {
              return a["time"] - b["time"];
            });
            data.push(e.reverse()[0]);
          });
        }
        this.droColChangeSize = data;
      }
      this.droIsBool = true;
    },
    columnResizeEventDad(event) {
      let index = event.index;
      let newWidth = event.newWidth;
      let fieldName = event.columns[index].field;
      this.dadColumnsize.push({
        time: Date.now(),
        width: newWidth,
        field: fieldName,
      });
      if (
        this.getDadColumnResizeData != null &&
        this.getDadColumnResizeData != []
      ) {
        this.getDadColumnResizeData.forEach((index) => {
          this.dadColumnsize.push(index);
        });
      }
      if (this.dadColumnsize != null && this.dadColumnsize != []) {
        const groupBy = (array, f) => {
          let groups = {};
          array.forEach((o) => {
            let group = JSON.stringify(f(o));
            groups[group] = groups[group] || [];
            groups[group].push(o);
          });
          return Object.keys(groups).map((group) => {
            return groups[group];
          });
        };
        const sorted = groupBy(this.dadColumnsize, (item) => {
          return item.field;
        });
        let data = [];
        if (sorted != null && sorted != []) {
          sorted.forEach((e) => {
            e.sort(function sortNum(a, b) {
              return a["time"] - b["time"];
            });
            data.push(e.reverse()[0]);
          });
        }
        this.dadColChangeSize = data;
      }
      this.dadIsBool = true;
    },
    columnResizeEventDab(event) {
      let index = event.index;
      let newWidth = event.newWidth;
      let fieldName = event.columns[index].field;
      this.dabColumnsize.push({
        time: Date.now(),
        width: newWidth,
        field: fieldName,
      });
      if (
        this.getDabColumnResizeData != null &&
        this.getDabColumnResizeData != []
      ) {
        this.getDabColumnResizeData.forEach((index) => {
          this.dabColumnsize.push(index);
        });
      }
      if (this.dabColumnsize != null && this.dabColumnsize != []) {
        const groupBy = (array, f) => {
          let groups = {};
          array.forEach((o) => {
            let group = JSON.stringify(f(o));
            groups[group] = groups[group] || [];
            groups[group].push(o);
          });
          return Object.keys(groups).map((group) => {
            return groups[group];
          });
        };
        const sorted = groupBy(this.dabColumnsize, (item) => {
          return item.field;
        });
        let data = [];
        if (sorted != null && sorted != []) {
          sorted.forEach((e) => {
            e.sort(function sortNum(a, b) {
              return a["time"] - b["time"];
            });
            data.push(e.reverse()[0]);
          });
        }
        this.dabColChangeSize = data;
      }
      this.dabIsBool = true;
    },
    // add FNSI-redmine#5747 高 end
    columnResizeEvent(event) {
      this.nativeDcsColumns = event.columns;

      let index = event.index;
      let newWidth = event.newWidth;
      let fieldName = event.columns[index].field;
      this.columnsize.push({
        time: Date.now(),
        width: newWidth,
        field: fieldName,
      });
      if (this.getColumnResizeData != null && this.getColumnResizeData != []) {
        this.getColumnResizeData.forEach((index) => {
          this.columnsize.push(index);
        });
      }
      if (this.columnsize != null && this.columnsize != []) {
        const groupBy = (array, f) => {
          let groups = {};
          array.forEach((o) => {
            let group = JSON.stringify(f(o));
            groups[group] = groups[group] || [];
            groups[group].push(o);
          });
          return Object.keys(groups).map((group) => {
            return groups[group];
          });
        };
        const sorted = groupBy(this.columnsize, (item) => {
          return item.field;
        });
        let data = [];
        if (sorted != null && sorted != []) {
          sorted.forEach((e) => {
            e.sort(function sortNum(a, b) {
              return a["time"] - b["time"];
            });
            data.push(e.reverse()[0]);
          });
        }
        this.colChangeSize = data;
      }
      this.isBool = true;
    },
    // add FNSI-redmine#4252 付 end
    columnReorderDcs(options) {
      let maxLockableIndex = 0;
      options.columns = options.columns.sort(
        (a, b) => a.orderIndex - b.orderIndex
      );
      for (let cnt = 0; cnt < options.columns.length; cnt++) {
        // ダミー列で列固定中止
        if (options.columns[cnt].field === "dummyColumn") {
          maxLockableIndex = cnt;
          break;
        }
      }
      for (let cnt = 0; cnt < maxLockableIndex + 1; cnt++) {
        if (options.columns[cnt].field !== "confirm") {
          options.columns[cnt].locked = true;
          options.columns[cnt].className = "locked-td";
        }
      }
      for (
        let cnt = maxLockableIndex + 1;
        cnt < options.columns.length;
        cnt++
      ) {
        options.columns[cnt].locked = false;
        options.columns[cnt].className = "";
      }
      this.nativeDcsColumns = options.columns;
    },
    columnReorderDro(options) {
      const info = this.changedLockedDeviceColumnsInfo(options.columns);
      this.nativeDroColumns = info.columns;

      this.$nextTick(() => {
        this.columnStyleReset(
          this.$refs.gridDro,
          info.maxLockableIndex + 1
        );
      });
    },
    columnReorderDab(options) {
      const info = this.changedLockedDeviceColumnsInfo(options.columns);
      this.nativeDabColumns = info.columns;

      this.$nextTick(() => {
        this.columnStyleReset(
          this.$refs.gridDab,
          info.maxLockableIndex + 1
        );
      });
    },
    columnReorderDad(options) {
      const info = this.changedLockedDeviceColumnsInfo(options.columns);
      this.nativeDadColumns = info.columns;

      this.$nextTick(() => {
        this.columnStyleReset(
          this.$refs.gridDad,
          info.maxLockableIndex + 1
        );
      });
    },
    // mod FNSI-画面で外部連携APIを呼び出すさい-538 付 start
    // insertCoopJournal(coopCd, patId, ordNo) {
    //   createJournal({
    //     facility_cd: this.getFacilityCd,
    //     coop_cd: coopCd,
    //     coop_cd_index: "",
    //     crud: "C",
    //     direction: "S",
    //     ana_result: "0",
    //     coop_result: "0",
    //     pat_id: patId,
    //     ord_no: ordNo,
    //     user_id: this.getUserId
    //   });
    // },
    // #10338 2024.03.29 del 外部連携をREST API側に構築 TDC片口 start
    // insertCoopJournal(patId, ordNo, opeId, baseDate, pat) {
    //   const params = {
    //     ope_cd: opeId,
    //     crud: "C",
    //     facility_cd: this.getFacilityCd,
    //     hosp_pat_id: patId,
    //     pat_id: pat,
    //     ord_no: ordNo,
    //     base_date: baseDate,
    //     user_id: this.getUserId,
    //   };
    //   createJournal(params);
    // },
    // #10338 2024.03.29 del 外部連携をREST API側に構築 TDC片口 start
    // mod FNSI-画面で外部連携APIを呼び出すさい-538 付 end
    // #10338 2024.03.28 mod 外部連携パラメータを構築 TDC片口 start
    /** @param {array} nativeDataSourceDcs  @param {array} confirmList  */
    buildConfirmParamJournal(nativeDataSourceDcs, confirmList) {
      const createParamRecord = (dcs, opeCd, userId) => {
        return {
          opeCd: opeCd,
          patId: dcs.patId,
          hospPatId: dcs.hospPatId,
          crud: "C",
          userId: userId,
          baseDate: dcs.treatDate,
        };
      };
      for (const confirmParam of confirmList) {
        confirmParam.journal = [];
        const filteredDcs = nativeDataSourceDcs.filter(
          (x) => x.ordNo == confirmParam.ordNo
        );
        if (filteredDcs.length > 0) {
          if (this.buttonConfig == 1) {
            confirmParam.journal.push(
              createParamRecord(filteredDcs[0], "011001", this.getUserId)
            );
            confirmParam.journal.push(
              createParamRecord(filteredDcs[0], "011002", this.getUserId)
            );
            confirmParam.journal.push(
              createParamRecord(filteredDcs[0], "011003", this.getUserId)
            );
            confirmParam.journal.push(
              createParamRecord(filteredDcs[0], "011004", this.getUserId)
            );
          } else if (this.buttonConfig == 2) {
            confirmParam.journal.push(
              createParamRecord(filteredDcs[0], "011005", this.getUserId)
            );
            confirmParam.journal.push(
              createParamRecord(filteredDcs[0], "011006", this.getUserId)
            );
            confirmParam.journal.push(
              createParamRecord(filteredDcs[0], "011007", this.getUserId)
            );
            confirmParam.journal.push(
              createParamRecord(filteredDcs[0], "011008", this.getUserId)
            );
          }
        }
      }
      return confirmList;
    },
    // #10338 2024.03.29 mod 外部連携パラメータを構築 TDC片口 end
    /**
     * 列ロック情報を再設定（装置グリッド）
     */
    changedLockedDeviceColumnsInfo(columns) {
      let maxLockableIndex = 0;
      columns = columns.sort((a, b) => a.orderIndex - b.orderIndex);
      for (let cnt = 0; cnt < columns.length; cnt++) {
        if (columns[cnt].locked && !columns[cnt].reorderable) {
          maxLockableIndex = cnt;
        }
      }
      for (let cnt = 0; cnt < maxLockableIndex + 1; cnt++) {
        columns[cnt].locked = true;
        columns[cnt].className = "locked-td";
      }
      for (let cnt = maxLockableIndex + 1; cnt < columns.length; cnt++) {
        columns[cnt].locked = false;
        columns[cnt].className = "";
      }

      return {
        maxLockableIndex: maxLockableIndex,
        columns: columns,
      };
    },
    /**
     * 非固定列のスタイルを初期化
     */
    columnStyleReset(gridComponent, startIndex) {
      // add 2022/9/15  dou start
      if (gridComponent) {
        // add 2022/9/15  dou end
        const headers = gridComponent.$el.querySelectorAll("th.k-header");
        // add #7190 2022/8/19 【デグレ】治療状況リストを開くまでが遅くなった。 dou start
        if (!!headers && headers.length > 0) {
          // add #7190 2022/8/19 【デグレ】治療状況リストを開くまでが遅くなった。 dou end
          for (let cnt = 0; cnt < startIndex; cnt++) {
            headers[cnt].style.position = "sticky";
            headers[cnt].style.zIndex = "1";
          }
          for (let cnt = startIndex; cnt < headers.length; cnt++) {
            headers[cnt].style = null;
          }
          const rows = gridComponent.$el.querySelectorAll(
            ".k-grid-container .k-grid-table tr.k-master-row"
          );
          for (const row of rows) {
            const tds = row.querySelectorAll("td");
            for (let cnt = startIndex; cnt < tds.length; cnt++) {
              tds[cnt].style = undefined;
            }
          }
          // add #7190 2022/8/19 【デグレ】治療状況リストを開くまでが遅くなった。 dou start
        }
        // add #7190 2022/8/19 【デグレ】治療状況リストを開くまでが遅くなった。 dou end
      }
    },
    /**
     * 治療状況リストグリッドのセルのスタイルを必要に応じて再設定
     */
    columnStyleResetDcs() {
      const gridElement = this.$refs.grid?.$el;
      if (!gridElement) return;
      const headers = Array.from(gridElement.querySelectorAll("th.k-header"));
      if (!headers?.length) return;

      // 列定義内のダミー列の位置から非固定列の先頭位置を求める
      const startIndex = this.nativeDcsColumns.findIndex(({ field }) => field === "dummyColumn") + 1;

      const setFixedStyle = element => setStyle(element, { position: "sticky", zIndex: "1" });
      const setNormalStyle = element => setStyle(element, { position: "", zIndex: "", left: "", right: "", background: "" });

      // ヘッダー行のstyle設定
      // 固定列と非固定列に分けてstyleを設定
      const fixedHeaders = headers.splice(0, startIndex);
      fixedHeaders.forEach(element => setFixedStyle(element));
      headers.forEach(element => {
        if (element.style) {
          setNormalStyle(element);
        }
      });

      // 非ヘッダー行のstyle設定
      Array.from(gridElement.querySelectorAll(
        ".k-grid-container .k-grid-table tr.k-master-row"
      )).forEach(row => {
        // 非固定列のstyleを設定
        // （固定列から非固定列に移動した際に
        // 　kgirdによって設定されるstyleのずれによる問題が起きるため）
        let colCount = 0;
        Array.from(row.querySelectorAll("td")).forEach(element => {
          // 非ヘッダー行のtd要素はスクロールアウトした部分が
          // colSpanが2以上のダミーtd要素に置き換えられるようなので
          // それを考慮して非固定列の処理対象判定を行う
          const colSpan = (typeof element.colSpan === "number") ? element.colSpan : 1;
          if (colSpan === 1 && colCount >= startIndex && element.style) {
            setNormalStyle(element);
          }
          colCount += colSpan;
        });
      });
    },
    /**
     * kendo-girdの列ヘッダセルのソート表示を列名の左に移動する
     */
    modifySortIndicator() {
      // 処理対象のグリッド内のソート表示の矢印部分のspan要素を抽出
      const targetSpanList = [
        this.$refs.grid?.$el,
        this.$refs.gridDro?.$el,
        this.$refs.gridDad?.$el,
        this.$refs.gridDab?.$el,
      ].reduce((list, gridElement) => {
        if (!gridElement?.querySelectorAll) return list;
        const ascSpanList = Array.from(gridElement.querySelectorAll("span.k-i-sort-asc-sm"));
        const descSpanList = Array.from(gridElement.querySelectorAll("span.k-i-sort-desc-sm"));
        list.push(...ascSpanList, ...descSpanList);
        return list;
      }, []);

      // ソート表示を列名の左に移動する
      targetSpanList.forEach(sortSpan => {
        // 処理対象のspan要素の親ノードを取得
        const parentNode = sortSpan.parentNode;
        if (!parentNode) return;
        // 子ノード数が2未満の場合はソート表示がないものとして処理対象外とする
        if (parentNode.childNodes.length < 2) return;

        if (!isTextNode(parentNode.lastChild)) {
          // 子ノード群の末尾が TEXT_NODE でない場合
          // 列名文字列の TEXT_NODE を子ノード群の末尾に追加しなおす
          const textNode = Array.from(parentNode.childNodes).find(node => isTextNode(node));
          parentNode.removeChild(textNode);
          parentNode.appendChild(textNode);
        }

        // ソート表示部分の左端と右端の ELEMENT_NODE を参照する
        const leftElementNode = parentNode.firstChild;
        const rightElementNode = parentNode.lastChild.previousSibling;
        // ソート表示部分のstyle操作対象がspan要素でない場合は想定外の構成のため処理対象外とする
        if (!isSpanNode(leftElementNode) || !isSpanNode(rightElementNode)) return;

        // ソート表示部分の左端の ELEMENT_NODE の margin-left と
        // 右端の ELEMENT_NODE の margin-right を入れ替える
        if (leftElementNode === rightElementNode) {
          // ソート表示部分の左端と右端の ELEMENT_NODE が同じ（＝矢印のみがある）の場合
          setStyle(leftElementNode, { marginLeft: "0", marginRight: "calc(1rem + -1px)" });
        } else {
          // ソート表示部分の左端と右端の ELEMENT_NODE が異なる（＝矢印と番号がある）の場合
          // 矢印のみの状態から矢印と番号がある状態になった場合に対応するため
          // このケースでも矢印部分の marginRight の設定を行う
          setStyle(leftElementNode, { marginLeft: "0", marginRight: "0" });
          setStyle(rightElementNode, { marginRight: "calc(1rem + -1px)" });
        }
      });
    },
    sortDcsChangeHandler(e) {
      this.sortDcs = e.sort;
    },
    sortDroChangeHandler(e) {
      this.sortDro = e.sort;
    },
    sortDabChangeHandler(e) {
      this.sortDab = e.sort;
    },
    sortDadChangeHandler(e) {
      this.sortDad = e.sort;
    },
    fetchTreatDeviceSet(isCreateColumn) {
      const color = { color: "white", background: "gray" };
      // 初期化
      let droTarget = document.getElementById("dro-device");
      let dadTarget = document.getElementById("dad-device");
      let dabTarget = document.getElementById("dab-device");
      let dadDataArray = this.getDeviceDataSource.dad;
      let dabDataArray = this.getDeviceDataSource.dab;
      let droDataArray = this.getDeviceDataSource.dro;

      if (dadTarget != null) dadTarget.disabled = false;
      if (dabTarget != null) dabTarget.disabled = false;
      if (droTarget != null) droTarget.disabled = false;

      if (dadDataArray.length <= 0) {
        this.dadColorStyle = color;
        dadTarget.disabled = true;
        // del #6389 透析液調製装置を隠しても再描画のタイミングで再表示される dou start
        // } else if (this.dispDad) {
        //   this.DADDeviceStatus = true;
        // del #6389 透析液調製装置を隠しても再描画のタイミングで再表示される dou end
      }
      if (dabDataArray.length <= 0) {
        this.dabColorStyle = color;
        dabTarget.disabled = true;
        // del #6389 透析液調製装置を隠しても再描画のタイミングで再表示される dou start
        // } else if (this.dispDab) {
        //   this.DABDeviceStatus = true;
        // del #6389 透析液調製装置を隠しても再描画のタイミングで再表示される dou end
      }
      if (droDataArray.length <= 0) {
        this.roColorStyle = color;
        droTarget.disabled = true;
        // del #6389 透析液調製装置を隠しても再描画のタイミングで再表示される dou start
        // } else if (this.dispDro) {
        //   this.RODeviceStatus = true;
        // del #6389 透析液調製装置を隠しても再描画のタイミングで再表示される dou end
      }
      this.$nextTick(() => {
        this.deviceColorStyle();
      });
      // add #6389 透析液調製装置を隠しても再描画のタイミングで再表示される dou start
      // mod #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
      // if (isCreateColumn) {
      if (isCreateColumn && this.getFirstInit) {
        // mod #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
        if (this.dispDad) {
          this.setDADDeviceStatus(true);
        }
        if (this.dispDab) {
          this.setDABDeviceStatus(true);
        }
        if (this.dispDro) {
          this.setRODeviceStatus(true);
        }
        // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
        this.setFirstInit(false);
        // add #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
      }
      // add #6389 透析液調製装置を隠しても再描画のタイミングで再表示される dou end
      this.droDataSource = droDataArray;
      this.dabDataSource = dabDataArray;
      this.dadDataSource = dadDataArray;
      
      // ソート用field設定
      // sys_monitor_item ソート用field設定
      commonFunctions.setSortFieldSysMonitorItem(this.treatAllColumn.droTreatSetCol, this.droDataSource, this.getSysMonitorItem);
      commonFunctions.setSortFieldSysMonitorItem(this.treatAllColumn.dabTreatSetCol, this.dabDataSource, this.getSysMonitorItem);
      commonFunctions.setSortFieldSysMonitorItem(this.treatAllColumn.dadTreatSetCol, this.dadDataSource, this.getSysMonitorItem);
      
      if (isCreateColumn && this.conditionFilter.isClear) {
        this.sortDro = [];
        this.sortDab = [];
        this.sortDad = [];
      }
    },
    deviceClick(event) {
      // 選択された要素の属性:idをイベントから取得
      const clickId = event.currentTarget.id;
      switch (clickId) {
        case "dro-device":
          if (!this.RODeviceStatus) {
            // mod #5746 透析液調製装置を表示していた状態を覚えていない。 dou start
            // this.RODeviceStatus = true;
            // } else {
            // this.RODeviceStatus = false;
            this.setRODeviceStatus(true);
          } else {
            this.setRODeviceStatus(false);
            // mod #5746 透析液調製装置を表示していた状態を覚えていない。 dou end
          }
          this.deviceColorStyle();
          break;
        case "dad-device":
          if (!this.DADDeviceStatus) {
            // mod #5746 透析液調製装置を表示していた状態を覚えていない。 dou start
            // this.DADDeviceStatus = true;
            // } else {
            // this.DADDeviceStatus = false;
            this.setDADDeviceStatus(true);
          } else {
            this.setDADDeviceStatus(false);
            // mod #5746 透析液調製装置を表示していた状態を覚えていない。 dou end
          }
          this.deviceColorStyle();
          break;
        case "dab-device":
          if (!this.DABDeviceStatus) {
            // mod #5746 透析液調製装置を表示していた状態を覚えていない。 dou start
            // this.DABDeviceStatus = true;
            // } else {
            // this.DABDeviceStatus = false;
            this.setDABDeviceStatus(true);
          } else {
            this.setDABDeviceStatus(false);
            // mod #5746 透析液調製装置を表示していた状態を覚えていない。 dou end
          }
          this.deviceColorStyle();
          break;
      }
    },
    /** ソート解除ボタン押下 */
    sortCancelClick() {
      // すべての表のソート状態を解除
      this.sortDcs = [];
      this.sortDro = [];
      this.sortDab = [];
      this.sortDad = [];
    },    
    deviceColorStyle() {
      const colorAlarmEnabled = { color: "black", background: "#f5a4a4" };
      const colorAlarmInvalid = { color: "black", background: "#ff6666" };
      const colorCautionEnabled = { color: "black", background: "#dede99" };
      const colorCautionInvalid = { color: "black", background: "#ffff66" };
      // mod FNSI-画面スタイル(ボタン)対応 付 start
      // const colorEnabled = { color: "white", background: "#87cefa" };
      // const colorInvalid = { color: "white", background: "#0076ff" };
      const colorEnabled = { color: "#bfbfbf", background: "#dfdfdf" };
      const colorInvalid = { color: "#ffffff", background: "#4291B9" };
      // mod FNSI-画面スタイル(ボタン)対応 付 end

      this.roBlinkClass = "";
      if (this.RODeviceStatus) {
        this.roColorStyle = colorEnabled;
      } else {
        this.roColorStyle = colorInvalid;
      }
      const droData = this.nativeDataSourceDro;
      for (const data of droData) {
        if (data.machineStatus & 0x08) {
          if (this.RODeviceStatus) {
            this.roColorStyle = colorAlarmEnabled;
          } else {
            this.roBlinkClass = "blink-alarm";
            this.roColorStyle = colorAlarmInvalid;
          }
          break;
        } else if (data.machineStatus & 0x20) {
          if (this.RODeviceStatus) {
            this.roColorStyle = colorCautionEnabled;
          } else {
            this.roBlinkClass = "blink-caution";
            this.roColorStyle = colorCautionInvalid;
          }
        }
      }
      this.dadBlinkClass = "";
      if (this.DADDeviceStatus) {
        this.dadColorStyle = colorEnabled;
      } else {
        this.dadColorStyle = colorInvalid;
      }
      const dadData = this.nativeDataSourceDad;
      for (const data of dadData) {
        if (data.machineStatus & 0x08) {
          if (this.DADDeviceStatus) {
            this.dadColorStyle = colorAlarmEnabled;
          } else {
            this.dadBlinkClass = "blink-alarm";
            this.dadColorStyle = colorAlarmInvalid;
          }
          break;
        } else if (data.machineStatus & 0x20) {
          if (this.DADDeviceStatus) {
            this.dadColorStyle = colorCautionEnabled;
          } else {
            this.dadBlinkClass = "blink-caution";
            this.dadColorStyle = colorCautionInvalid;
          }
        }
      }
      this.dabBlinkClass = "";
      if (this.DABDeviceStatus) {
        this.dabColorStyle = colorEnabled;
      } else {
        this.dabColorStyle = colorInvalid;
      }
      const dabData = this.nativeDataSourceDab;
      for (const data of dabData) {
        if (data.machineStatus & 0x08) {
          if (this.DABDeviceStatus) {
            this.dabColorStyle = colorAlarmEnabled;
          } else {
            this.dabBlinkClass = "blink-alarm";
            this.dabColorStyle = colorAlarmInvalid;
          }
          break;
        } else if (data.machineStatus & 0x20) {
          if (this.DABDeviceStatus) {
            this.dabColorStyle = colorCautionEnabled;
          } else {
            this.dabBlinkClass = "blink-caution";
            this.dabColorStyle = colorCautionInvalid;
          }
        }
      }
      //警報注意（ボタンの背景色変更）
      this.alarmBlinkClass = "";
      if (this.getIsAlarmDisplay) {
        this.alarmColorStyle = colorEnabled;
      } else {
        this.alarmColorStyle = colorInvalid;
      }
      // add #7190 2022/8/19 【デグレ】治療状況リストを開くまでが遅くなった。 dou start
      if (!!this.dataSource && !!this.dataSource.dcs) {
        // add #7190 2022/8/19 【デグレ】治療状況リストを開くまでが遅くなった。 dou end
        const allData = this.dataSource.dcs
          .concat(this.dataSource.dro)
          .concat(this.dataSource.dad)
          .concat(this.dataSource.dab);
        for (const data of allData) {
          // add FNSI-警報・報知追加 徐 start
          if (data.machineStatus & 0x08) {
            if (this.getIsAlarmDisplay) {
              this.alarmColorStyle = colorAlarmEnabled;
            } else {
              this.alarmBlinkClass = "blink-alarm";
              this.alarmColorStyle = colorAlarmInvalid;
            }
            break;
          } else if (data.machineStatus & 0x20) {
            if (this.getIsAlarmDisplay) {
              this.alarmColorStyle = colorCautionEnabled;
            } else {
              this.alarmBlinkClass = "blink-caution";
              this.alarmColorStyle = colorCautionInvalid;
            }
          }
          // add FNSI-警報・報知追加 徐 end
        }
        // add #7190 2022/8/19 【デグレ】治療状況リストを開くまでが遅くなった。 dou start
      }
      // add #7190 2022/8/19 【デグレ】治療状況リストを開くまでが遅くなった。 dou end
    },
    setDataSource(data) {
      this.dataSource = data;
    },
    editStart() {
      // ポーリング停止
      this.endPolling();
      if (this.isAndroid) {
        this.editingFlg = true;
      }
    },
    editEnd() {
      // ポーリング再開
      this.startPolling();
      this.editingFlg = false;
    },
    addInputAssist() {
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.isIOS) {
        if (document.getElementsByClassName("k-numerictextbox").length !== 0) {
          let spinnerObj = document
            .getElementsByClassName("k-numerictextbox")[0]
            .getElementsByClassName("k-select")[0];
          // 編集が終了するとオブジェクトが削除されるため、removeEvent処理は不要
          spinnerObj.ontouchend = (event) => event.stopPropagation();
        }
      }
    },
    onClickBedName(e, rowItem) {
      e.preventDefault();
      e.stopPropagation();

      // ordNo
      let selOrdNo = rowItem.ordNo;
      // 治療状況
      const selRstDialysisState = rowItem.rstDialysisState;
      // 患者ID
      const selPatId = rowItem.patId;

      if (
        ["0", "1", "2"].includes(selRstDialysisState) &&
        selPatId !== null &&
        selOrdNo !== null
      ) {
        // 予定(次患者)～条件送信済み患者かつ？？？？患者でない場合

        // 患者選択リストに格納
        this.updateTreatmentPatList(this.StatusListToPatList);
        // 機能コード設定、選択 ord_no を保持
        this.setOrdNoForSideBarRecord(selOrdNo);
        this.setSrcFuncName(this.$router.currentRoute.name);

        // ordNoセット
        this.sendConditionSetSelectOrdNo({
          ordNo: selOrdNo,
          ordNo2: null,
        }).then(() => {
          // 条件送信画面へ遷移
          this.goSpecifiedView("send-condition");
        });
      } else if (selRstDialysisState !== "0" && selOrdNo !== null) {
        // 患者選択リストに格納
        this.updateTreatmentPatList(this.StatusListToPatList);
        // 機能コード設定、選択 ord_no を保持
        this.setOrdNoForSideBarRecord(selOrdNo);
        this.setSrcFuncName(this.$router.currentRoute.name);

        // 治療中以降の患者の場合
        this.setSelectedPatHeader(selPatId).then(() => {
          // ordNoセット
          this.$nextTick(() => {
            //add FNSI修正 治療記録画面バッグ 房 start
            this.setOrd({
              readOnly: false,
            });
            //add FNSI修正 治療記録画面バッグ 房 end
            this.setTreatmentRecordOrdNo(selOrdNo);
            // 治療記録画面へ遷移
            this.$router.push({ name: "treatment-record" });
            //add FNSI修正-7967 遷移すると、患者一覧で使われるbeforeSelectPatIdを状況リスト画面でクリックされる患者で設定する ljx start
            this.$parent.$parent.$parent.$parent.$parent.$parent.$children[0].$children[1].$children[0].$data.beforeSelectPatId =
              selPatId;
            //add FNSI修正-7967 遷移すると、患者一覧で使われるbeforeSelectPatIdを状況リスト画面でクリックされる患者で設定する ljx end
          });
        });
      }
    },
    onClickPatName(e, rowItem) {
      e.preventDefault();
      e.stopPropagation();

      // ordNo
      let selOrdNo = rowItem.ordNo;
      // 患者ID
      const selPatId = rowItem.patId;
      // 治療状況
      const selRstDialysisState = rowItem.rstDialysisState;

      if (selPatId === null && selOrdNo !== null) {
        // add FNSI-外部連携api呼び出対応 陳 start
        window.document.cookie = "flg@@list; path=/";
        // add FNSI-外部連携api呼び出対応 陳 end
        // ？？？患者の場合
        // 名前割り当て画面へ遷移
        // 選択されたord_noの情報をセット
        this.scheduleAssignmentSetSelectOrdNo(selOrdNo).then(() => {
          // スケジュール・名前割り当てモーダル画面表示
          // mod FNSI-？？？？患者割り当てtitle名不正 陳 start
          // mod FNSI-？？？？患者割り当てtitle名不正 付 start
          // this.showSchedule();
          // this.showSchedule({title :"スケジュール割り当て"});
          this.showSchedule({ title: "？？？？患者治療割り当て" });
          // mod FNSI-？？？？患者割り当てtitle名不正 付 end
          // mod FNSI-？？？？患者割り当てtitle名不正 陳 end
        });
        // 治療予定(次患者)の場合
      } else if (
        selRstDialysisState === "0" &&
        selPatId !== null &&
        selOrdNo !== null
      ) {
        // 患者選択リストに格納
        this.updateTreatmentPatList(this.StatusListToPatList);
        // 機能コード設定、選択 ord_no を保持
        this.setOrdNoForSideBarRecord(selOrdNo);
        this.setSrcFuncName(this.$router.currentRoute.name);

        // ordNoセット
        this.sendConditionSetSelectOrdNo({
          ordNo: selOrdNo,
          ordNo2: null,
        }).then(() => {
          // 条件送信画面へ遷移
          this.goSpecifiedView("send-condition");
        });
      } else if (
        selRstDialysisState !== "0" &&
        selPatId !== null &&
        selOrdNo !== null
      ) {
        // 条件送信以降の患者の場合

        // 患者選択リストに格納
        this.updateTreatmentPatList(this.StatusListToPatList);
        // 機能コード設定、選択 ord_no を保持
        this.setOrdNoForSideBarRecord(selOrdNo);
        this.setSrcFuncName(this.$router.currentRoute.name);

        this.setSelectedPatHeader(selPatId).then(() => {
          // ordNoセット
          this.$nextTick(() => {
            //add FNSI修正 治療記録画面バッグ 房 start
            this.setOrd({
              readOnly: false,
            });
            //add FNSI修正 治療記録画面バッグ 房 end
            this.setTreatmentRecordOrdNo(selOrdNo);
            // 治療記録画面へ遷移
            this.$router.push({ name: "treatment-record" });
            //add FNSI修正-7967 遷移すると、患者一覧で使われるbeforeSelectPatIdを状況リスト画面でクリックされる患者で設定する ljx start
            this.$parent.$parent.$parent.$parent.$parent.$parent.$children[0].$children[1].$children[0].$data.beforeSelectPatId =
              selPatId;
            //add FNSI修正-7967 遷移すると、患者一覧で使われるbeforeSelectPatIdを状況リスト画面でクリックされる患者で設定する ljx end
          });
        });
      }
    },
    onClickContentChange(e, rowItem) {
      e.preventDefault();
      this.setIndOrdNo(rowItem.ordNo).then(() => {
        this.showIndicationsDiffModal();
      });
    },
    // mod #9371 治療状況リストにおける警報・報知の動作不良 dou start
    warnClick(e, rowItem) {
      e.preventDefault();
      e.stopPropagation();
      if (!this.getIsAlarmDisplay) {
        this.setIsAlarmDisplay(true);
      }
      EventBus.$emit("deviceColorStyle");
      this.setStatusFlg(1);
      this.setStatusList(rowItem);
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou start
      this.changeOccurDate(
        moment(this.getStatusList.treatDate).format("YYYY-MM-DD")
      );
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou end
      this.setIsGoAlarmPage(true);
    },
    infoClick(e, rowItem) {
      e.preventDefault();
      e.stopPropagation();
      if (!this.getIsAlarmDisplay) {
        this.setIsAlarmDisplay(true);
      }
      EventBus.$emit("deviceColorStyle");
      this.setStatusFlg(2);
      this.setStatusList(rowItem);
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou start
      this.changeOccurDate(
        moment(this.getStatusList.treatDate).format("YYYY-MM-DD")
      );
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou end
      this.setIsGoAlarmPage(true);
    },
    blankClick(e, rowItem) {
      e.preventDefault();
      e.stopPropagation();
      if (!this.getIsAlarmDisplay) {
        this.setIsAlarmDisplay(true);
      }
      EventBus.$emit("deviceColorStyle");
      this.setStatusFlg(3);
      this.setStatusList(rowItem);
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou start
      this.changeOccurDate(
        moment(this.getStatusList.treatDate).format("YYYY-MM-DD")
      );
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou end
      this.setIsGoAlarmPage(true);
    },
    // mod #9371 治療状況リストにおける警報・報知の動作不良 dou end
    // add FNSI-警報・報知追加 徐 end
    onClickDeleteOrder(e, rowItem) {
      e.preventDefault(); // これ以上イベント伝播しない
      // FNSI-7120-治療状況リストから????患者の削除に時間がかかる-徐博-update start
      this.deleteRecord(rowItem, rowItem.ordNo);
      // FNSI-7120-治療状況リストから????患者の削除に時間がかかる-徐博-update end
    },
    onClickConfirmOrder(e, rowItem) {
      this.buttonConfig = 1;
      e.preventDefault(); // これ以上イベント伝播しない
      const currentOrdNo = rowItem.ordNo;
      // add FNSI-実績確定修正 徐 start
      this.dialogDispList = [];
      // add FNSI-実績確定修正 徐 end
      this.dialogDispList.push({
        ordNo: currentOrdNo,
        bedName: rowItem.bedName,
        patName: rowItem.patName,
      });
      this.getMediDone(currentOrdNo);
    },
    async onClickMachineRecordCd(e, rowItem) {
      // 装置情報をstoreに設定
      const condition = {
        facilityCd: this.getFacilityCd,
        machineTypeCd: rowItem.machineTypeCd,
        machineSerial: rowItem.machineSerial,
      };
      await this.getMachine(condition);
      await this.setHeaderInfo(this.getSelectMachine());

      // 装置記録表示設定をstoreに設定
      const today = moment().format("YYYY/MM/DD");
      const motionRecord = {
        motionRecordNo: 0, // 自己診断データの検索にはmotionRecordNoを使わないため、任意の数値を指定(nullだとエラーになる)
        dataType: 4, // 4:自己診断 で固定
        testType: 1, // 1:配管 で固定
        eventRegDate: today, // 当日(YYYY/MM/DD)
      };
      this.setMotionRecord(motionRecord);
      this.goSpecifiedView("operation-viewer-non-split-motion-record-detail");
    },
    rowClick: function (e) {
      this.dcsDataSource.forEach((d) => {
        if (d.inEdit) {
          if (e.dataItem !== d) {
            this.$set(d, "inEdit", undefined);
          }
        }
      });
      this.setEditingField(undefined);
      this.dcsDataSource = this.dcsDataSource;
    },
    cellClick: function (e) {
      if (e.dataItem.inEdit && e.field === this.getEditingField) {
        return;
      }
      this.setEditingField(e.field);

      this.$set(e.dataItem, "inEdit", e.field);
      this.dcsDataSource = this.dcsDataSource;
    },

    async onSaveChanged(e, dataItem, field, newValue) {
      if (e) {
        e.preventDefault(); // これ以上イベント伝播しない
      }
      /** Grid内のデータを変更した際の処理 */
      const param = this.makeUpdateTreatmentStatus({
        srcJson: dataItem,
        key: field,
        newValue: newValue,
      });
      // apiをコールして値を保存
      await this.updateTreatmentStatus(param)
        .then((response) => {
          this.updateResponse = response.data;
          this.isSorted = false;
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage(
            "StatusListMainComponent.vue",
            "onSaveChanged",
            error
          );
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage,
            });
          }
        });
      this.editEnd();
      /* modify by chamaojia 2022-11-26 [6746] loadingが必要  --start */
      this.setGridData(1);
      /* modify by chamaojia 2022-11-26 [6746] loadingが必要  --end */
    },

    // 透析液調製装置一覧グリッド内セルクリック時
    onClickDevice(e) {
      event.preventDefault();
      if (e.dataItem) {
        const rowData = e.dataItem;
        // 選択行登録
        const machineInfo = {
          machineName: rowData.machineName,
          machineSerial: rowData.machineSerial,
          machineTypeCd: rowData.machineTypeCd,
          model: rowData.model,
          // mod FNSI-改修内容5702修正 xuty start
          comFormatCd: rowData.comFormatCd,
          // mod FNSI-改修内容5702修正 xuty end
        };
        this.setMachineInfo(machineInfo).then(() => {
          this.goSpecifiedView("trend-graph");
        });
      }
    },
    batchCheck() {
      this.buttonConfig = 2;
      let ordNoList = [];
      let pushList = [];
      let gridDataList = [];
      let filterGridData = this.nativeDataSourceDcs;
      if (filterGridData.length > 0) {
        gridDataList = filterGridData;
      } else {
        //mod FNSI redmine 6726 劉祥霖 start
        // gridDataList = originGridData;
        this.$ons.notification.alert({
          modifier: "info",
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "一括確定なし",
          // message: `一括確定する実績がない。`
          title: DIALOG_MESSAGES[12000237].title,
          message: messageFormat(DIALOG_MESSAGES[12000237].message),
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        return;
        //mod FNSI redmine 6726 劉祥霖 end
      }
      for (let gridData of gridDataList) {
        if (
          gridData.rstDialysisState == 5 &&
          gridData.ordNo !== null &&
          gridData.patId !== null
        ) {
          let ordNoItem = gridData.ordNo;
          let confItem = {};
          confItem.ordNo = ordNoItem;
          confItem.bedName = gridData.bedName;
          confItem.patName = gridData.patName;
          ordNoList.push(ordNoItem);
          pushList.push(confItem);
        }
      }
      this.dialogDispList = pushList;
      if (ordNoList.length !== 0) {
        this.getMediDone(ordNoList);
      }
    },
    moveAlarmNoticeList() {
      // add #7955 2022/11/26 恐らく画面更新の問題で、画面遷移したときは、警報装置一覧ボタンが無効状態だが、放置すると押せるようになっている。 dou start
      if (this.$router.currentRoute.name == "status-list-alarm") {
        this.$router.push({ name: "status-list" });
        this.setIsAlarmDisplay(false);
        this.deviceColorStyle();
        return;
      }
      // add #7955 2022/11/26 恐らく画面更新の問題で、画面遷移したときは、警報装置一覧ボタンが無効状態だが、放置すると押せるようになっている。 dou end
      if (!this.getIsAlarmDisplay) {
        this.setIsAlarmDisplay(true);
      }
      // add FNSI-警報・報知追加 徐 start
      this.setStatusFlg(0);
      // add FNSI-警報・報知追加 徐 end
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou start
      this.changeOccurDate(moment().format("YYYY-MM-DD"));
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou end
      this.deviceColorStyle();
      this.popoverVisible = false;
      this.setIsGoAlarmPage(true);
    },
    loadData() {
      // 治療状況リストレイアウト情報取得
      Promise.all([
        this.fetchStatusLayoutList(),
        this.fetchSysMonitorItem(),
        this.fetchMstTreatmentStatusDispItem()
      ])
        // mod #8032 2022/10/19 【デグレ】治療状況リストにおいてWebサーバ起動後の最初のサインイン時に何も表示しない dou start
        // .then(response => {
        .then(async ([response, resMonitorItem, resDispItem]) => {
          // mod #8032 2022/10/19 【デグレ】治療状況リストにおいてWebサーバ起動後の最初のサインイン時に何も表示しない dou end
          // 表示項目コンボ用
          let getColItemData = response.data;
          let setDataList = commonFunctions.buildComboBoxItemsTreatmentLayout(
            getColItemData,
            commonFunctions.constant.useClass.list
          );

          // 一覧情報をセットする
          this.setColItemGroupList({
            layoutItemList: setDataList,
            // 治療状況リスト表示項目
            allColItemList: getColItemData,
          });
          this.defaultColumns = setDataList;
          // 治療状況一覧情報を取得しセットする
          // mod #8032 2022/10/19 【デグレ】治療状況リストにおいてWebサーバ起動後の最初のサインイン時に何も表示しない dou start
          // this.$nextTick(() => {
          //   this.setGridData(1);
          // });
          await this.setGridData(1);
          this.refreshVal();
          // mod #8032 2022/10/19 【デグレ】治療状況リストにおいてWebサーバ起動後の最初のサインイン時に何も表示しない dou end        })
        })
        .catch((r) => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage("StatusListMainComponent.vue", "loadData", r);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (r.response.status === 400) {
            // 400エラー
          }
        });
    },
    /* modify by chamaojia 2022-11-26 [6746] 自動更新ロード判定の追加  --start */
    statusUpdate(autoRefreshFlag = false) {
      const grid = document.querySelector(".status-scale-area .k-grid-content");
      this.scrollPositionTop = grid ? grid.scrollTop : 0;
      this.scrollPositionLeft = grid ? grid.scrollLeft : 0;
      if (autoRefreshFlag) {
        this.setGridData(0);
      } else {
        this.setGridData(1);
      }
    },
    /* modify by chamaojia 2022-11-26 [6746] 自動更新ロード判定の追加  --end */
    // #10337 2024.04.12 add 終了を待機可能な画面リロード処理 TDC片口 start
    async statusUpdateAsync() {
      const grid = document.querySelector(".status-scale-area .k-grid-content");
      this.scrollPositionTop = grid ? grid.scrollTop : 0;
      this.scrollPositionLeft = grid ? grid.scrollLeft : 0;
      await this.setGridData(0);
    },
    // #10337 2024.04.12 add 終了を待機可能な画面リロード処理 TDC片口 end
    /**
     * Gridの表示データにフィルターをセットする
     */
    setGridFilter() {
      let conditionFilterValue = this.conditionFilter;
      let bedGroupFilter = this.getBedListData;
      let bedCurrentFilters = [];
      let srcFilters = [];

      // クール
      let kurCurrentFilters = [];
      if (
        // conditionFilterValue.kurGroupIndex !== 0 &&
        conditionFilterValue.kurGroupList.length !== 0 &&
        this.getIsShowMain === true
      ) {
        let kurCds = conditionFilterValue.kurGroupList;
        for (let i = 0; i < kurCds.length; i++) {
          kurCurrentFilters.push({
            field: "kurCd",
            operator: "eq",
            // operator: "contains",
            value: kurCds[i],
          });
        }
        if (kurCurrentFilters.length > 0) {
          srcFilters.push({ logic: "or", filters: kurCurrentFilters });
        } else {
          srcFilters.push({
            logic: "or",
            filters: [
              {
                field: "kurCd",
                operator: "eq",
                value: "",
              },
            ],
          });
        }
      }

      // ベッドグループ
      if (conditionFilterValue.bedGroupCd !== 0) {
        for (let i = 0; i < bedGroupFilter.length; i++) {
          let bedGroupCd = bedGroupFilter[i].roomBedGroupCd;
          let bedNameList = bedGroupFilter[i].bedList;
          let bedNames = JSON.parse(bedNameList);
          if (conditionFilterValue.bedGroupCd === bedGroupCd) {
            if (bedNames != undefined) {
              for (let j = 0; j < bedNames.length; j++) {
                bedCurrentFilters.push({
                  field: "bedCd",
                  operator: "eq",
                  value: bedNames[j],
                });
              }
            }
          }
        }
        if (bedCurrentFilters.length > 0) {
          srcFilters.push({ logic: "or", filters: bedCurrentFilters });
        } else {
          srcFilters.push({
            logic: "or",
            filters: [
              {
                field: "bedCd",
                operator: "eq",
                value: "",
              },
            ],
          });
        }
      }

      // 次患者表示

      // クール・ベッドグループ表示フィルター
      this.gridFilterResult = srcFilters;
    },

    // データ取得
    // mod #7947 2022-09-15 【デグレ】????患者の削除後にしばらくすると復活する dou start
    async setGridData(createColumn) {
      // No.6746 After the Api callback, reset to get the time of calling the Api ztc start
      this.endPolling();
      // No.6746 After the Api callback, reset to get the time of calling the Api ztc end
      // mod #7947 2022-09-15 【デグレ】????患者の削除後にしばらくすると復活する dou end
      let conditionFilterValue = this.conditionFilter;
      let isCreateColumn = createColumn !== 0;

      // add FNSI-実績確定修正 徐 start
      this.setCreateColumn(createColumn);
      // add FNSI-実績確定修正 徐 end

      // 抽出日付（本日）
      let todayDate = moment().format("YYYYMMDD");
      let layoutNo = conditionFilterValue.colItemLayoutNo;
      let layoutInfo = this.defaultColumns;
      if (layoutNo == "") {
        // レイアウトが選択されていない場合
        layoutNo = -1;
        if (layoutInfo.length > 0) {
          layoutNo = layoutInfo[0].colItemLayoutNo;
        }
      }

      //
      if (layoutNo !== undefined && layoutNo !== -1) {
        /* mod #8872 by zhangruixue 2023-06-21 --start */
        let kurCds = conditionFilterValue.kurCd;
        if (!kurCds || kurCds.length == 0) {
          kurCds = "0";
        }
        const info = {
          facilityCd: this.getFacilityCd,
          // isClear: true,
          treatDate: todayDate,
          // treatDate: "20190208",
          layoutNo: layoutNo,
          bedGroupCd: conditionFilterValue.bedGroupCd,
          kurCdS: kurCds,
          /* add by chamaojia 2024-03-28 [10303、10304] add incoming parameters --start */
          isShowMain:  this.getIsShowMain,
          nextPat: this.getIsShowMain ? conditionFilterValue.nextPatValue : conditionFilterValue.deviceNextValue
          /* add by chamaojia 2024-03-28 [10303、10304] add incoming parameters --end */
        };
        /* mod #8872 by zhangruixue 2023-06-21 --end */
        if (createColumn !== 2) {
          this.keys ++;
          let key = this.keys;
          // データ取得
          let response = await this.fetchTreatSettingList(info).catch(
            (error) => {
              //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
              getErrorMessage(
                "StatusListMainComponent.vue",
                "setGridData",
                error
              );
              //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
              if (error.response.status === 400) {
                // this.$ons.notification.alert({
                //   title: "取得失敗",
                //   message: "治療状況リストデータ取得失敗"
                // });
              }
            }
          );
          // 複数回のリクエストは最後のレスポンスのみを取得します
          if (key == this.keys) {
            let colItemCd = layoutNo;
            if (colItemCd === "") {
              colItemCd = -1;
            }
            // grid列作成（治療状況リストDCS、機械室DAB、DAD、DOR）
            if (isCreateColumn) {
              // レイアウト設定が変更されたときのみ
              this.setStatusGridColumn(colItemCd);
            }
            // grid列dataSource作成（治療状況リストDCS、機械室DAB、DAD、DOR）
            let dataSet = response.data;
            // 治療状況一覧情報をセットする
            this.setTreatSettingList({ dataSet: dataSet }).then(() => {
              // グリッドのフィルタ設定
              this.setGridFilter();
              // データソース構築
              this.buildDcsDataSource(isCreateColumn);
              // 機械室の表示
              this.fetchTreatDeviceSet(isCreateColumn);

              this.setDataSource(dataSet);

              this.deviceColorStyle();
            });
          }
          // mod #7947 2022-09-15 【デグレ】????患者の削除後にしばらくすると復活する dou end
        } else {
          // 表示内容の切り替え
          // グリッドのフィルタ設定
          this.setGridFilter();
          // データソース構築
          this.buildDcsDataSource(isCreateColumn);
        }
      } else {
        // grid列作成（治療状況リストDCS、機械室DAB、DAD、DOR）
        this.setStatusGridColumn(-1);

        // grid列dataSource作成（治療状況リストDCS、機械室DAB、DAD、DOR）
        let dataSet = {
          dcs: [],
          dab: [],
          dad: [],
          dro: [],
        };

        // 治療状況一覧情報をセットする
        this.setTreatSettingList({ dataSet: dataSet }).then(() => {
          // グリッドのフィルタ設定
          this.setGridFilter();
          // データソース構築
          this.buildDcsDataSource(isCreateColumn);

          // 機械室の表示
          this.fetchTreatDeviceSet(isCreateColumn);
        });
      }
      // No.6746 After the Api callback, reset to get the time of calling the Api ztc start
      this.startPolling();
      // No.6746 After the Api callback, reset to get the time of calling the Api ztc end
    },
    // #10338 2024.03.29 mod 共通ローダー表示タイミング修正 TDC片口 start
    /**
     * 確認ボタン押下時の更新処理関数
     */
    // getMediDone(no) {
    async getMediDone(no) {
      /**
       * putCheckAfterWeightへの引数は、{ordNo: <値>, mediDone: <boolean>}のオブジェクトを
       * 配列に入れて渡してください。
       * ★実装完了後はこのコメントを削除して下さい。
       */
      let ordNo;
      if (Array.isArray(no)) {
        ordNo = no;
      } else {
        ordNo = parseInt(no, 10);
      }
      const param = ordNo;

      this.confirmList = [];
      this.countVal = 0;

      // // 未投薬チェック
      // this.getCheckMediDone(param).then((response) => {
      this.startLoadingScreen();
      const response = await this.getCheckMediDone(param);
      /* DBリクエストが返ってきてからの処理を記述して下さい */
      let resData = response.data;
      this.mediInfo = resData;
      this.doneResponseDataLength = response.data.length;
      let mediArray = this.dialogDispList;
      let countEff = 0;
      // add FNSI-実績確定修正 徐 start
      this.recordList = [];

      if (mediArray.length > 0) {
        for (let j = 0; j < mediArray.length; j++) {
          let tempList = resData.filter((e) => e.ordNo == mediArray[j].ordNo);
          if (tempList.length > 0) {
            /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
            // let mediInfos = JSON.parse(tempList[0].rstMediInfo);
            let mediInfos =
              tempList[0].rstMediInfo == null
                ? null
                : JSON.parse(tempList[0].rstMediInfo);
            /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
            if (mediInfos != null) {
              let tempMediInfos = mediInfos.filter((el) => el.effect_flg == 0);
              if (tempMediInfos.length > 0) {
                tempMediInfos.forEach((ele) => {
                  const tempMediInfo = {
                    patName: mediArray[j].patName,
                    bedName: mediArray[j].bedName,
                    effect_flg: ele.effect_flg,
                    unit: ele.unit,
                    amount: ele.amount,
                    name: ele.name,
                    tempKurName: tempList[0].rstKurName,
                  };
                  this.recordList.push(tempMediInfo);
                  if (ele.effect_flg == 0) {
                    countEff++;
                  }
                });
              }
            }
          }
        }
      }

      // for (let i = 0; i < resData.length; i++) {
      //   let resOrdNo = resData[i].ordNo;
      //   // for (let j = 0; j < mediArray.length; j++) {
      //   //   if (resOrdNo == mediArray[j].ordNo) {
      //   //     this.mediInfo[i].bedName = mediArray[j].bedName;
      //   //     this.mediInfo[i].patName = mediArray[j].patName;
      //   //   }
      //   // }

      // 1つ目のダイアログを呼ぶ
      if (countEff == 0) {
        this.zisekiConfirm(false);
      } else {
        this.firstDialog();
      }
      // add FNSI-実績確定修正 徐 end
      // });
      this.finishLoadingScreen();
      // #10338 2024.03.29 mod 共通ローダー表示タイミング修正 TDC片口 end
    },
    // add FNSI-実績確定修正 徐 start
    // 1つ目のダイアログ処理
    // firstDialog() {
    //   let mediInfo = this.mediInfo;
    //   if (mediInfo.length > 0) {
    //     let isMediDone = mediInfo[0].isMediDone;
    //     let ordNo = mediInfo[0].ordNo;
    //     let bedName = mediInfo[0].bedName;
    //     let patName = mediInfo[0].patName;
    //     let patId = mediInfo[0].patId;
    //     this.setConfirm.ordNo = ordNo;
    //     this.setConfirm.patId = patId;
    //     let treatCd = mediInfo[0].rstTreatmentCd;

    //     // ポーリング停止
    //     this.endPolling();

    //     // 投薬判定
    //     if (treatCd !== null && !isMediDone) {
    //       this.$ons.notification
    //         .confirm({
    //           title: "未実施の投薬予定があります。",
    //           message:
    //             "ベッド名: " +
    //             bedName +
    //             "</br>患者名: " +
    //             patName +
    //             "</br>の未実施の投薬予定を実施済にします。</br>よろしいですか？",
    //           buttonLabels: ["はい", "いいえ"]
    //         })
    //         .then(answer => {
    //           if (answer === 0) {
    //             // Yes
    //             isMediDone = true;
    //             this.setConfirm.isMedi = isMediDone;
    //           } else {
    //             // No
    //             isMediDone = false;
    //             this.setConfirm.isMedi = isMediDone;
    //           }
    //           // ２つめのダイアログ表示
    //           this.secondDialog();
    //         });
    //     } else {
    //       // ２つめのダイアログ表示
    //       isMediDone = false;
    //       this.setConfirm.isMedi = isMediDone;
    //       this.secondDialog();
    //     }
    //   }
    // },
    firstDialog() {
      let mediInfo = this.mediInfo;
      let isTrue = 0;
      if (mediInfo.length > 0) {
        // ポーリング停止
        this.endPolling();
        for (let i = 0; i < mediInfo.length; i++) {
          let isMediDone = mediInfo[i].isMediDone;
          let treatCd = mediInfo[i].rstTreatmentCd;
          if (treatCd !== null && !isMediDone) {
            isTrue++;
            break;
          }
        }
        if (isTrue > 0) {
          this.diaView = true;
          let alertDialog = document.getElementsByClassName("alert-dialog");
          alertDialog[0].style.width = "auto";
          alertDialog[0].style.maxWidth = "750px";
          let element = document.getElementsByClassName("alert-dialog-content");
          element[0].childNodes[0].style.maxHeight = "240px";
          element[0].childNodes[0].style.overflowY = "auto";
          element[0].childNodes[0].style.overflowX = "hidden";
          if (this.buttonConfig == 1) {
            alertDialog[0].style.width = "28em";
          }
          if (this.buttonConfig == 2) {
            let buttonElem = document.getElementsByClassName(
              "alert-dialog-button"
            );
            buttonElem[3]?.classList?.add("alert-dialog-button--rowfooter");
            buttonElem[3]?.classList?.add(
              "alert-dialog-button--rowfooter--rowfooter"
            );
          }
        }
      }
    },
    zisekiConfirm(val) {
      let mediInfo = this.mediInfo;
      this.diaView = false;
      let accountInfo = this.getStateUserAccountInfo;
      for (let i = 0; i < mediInfo.length; i++) {
        let saveConfData = {};
        let ordNo = mediInfo[i].ordNo;
        let patId = null;
        saveConfData.ordNo = ordNo;
        this.nativeDataSourceDcs.forEach((data) => {
          if (data.ordNo == ordNo) {
            patId = data.patId;
          }
        });
        saveConfData.patId = patId;
        // doComplete
        saveConfData.doCompleteMedi = val;
        // userId
        saveConfData.userId = accountInfo.userId;
        // 保存情報セット
        this.confirmList.push(saveConfData);
      }
      this.endPolling();
      // del #8659 【デグレ】治療状況リストで実績確定を行っても再度リストに表示される dou start
      // ポーリング再開
      // this.startPolling();
      // del #8659 【デグレ】治療状況リストで実績確定を行っても再度リストに表示される dou end
      // #10338 2024.03.26 del 実データと同期しない非表示をやめる TDC片口 start
      // // 非同期データ
      // this.asyncData();
      // #10338 2024.03.26 del 実データと同期しない非表示をやめる TDC片口 end
      // 確定処理へ移動
      this.updateCheckAfterWeight();
    },
    mijissiigaiConfirm(val) {
      this.diaView = false;
      let mediInfo = this.mediInfo;
      let accountInfo = this.getStateUserAccountInfo;
      for (let i = 0; i < mediInfo.length; i++) {
        let saveConfData = {};
        let effcount = 0;
        if (mediInfo[i].rstMediInfo != null) {
          let mediInfoList = JSON.parse(mediInfo[i].rstMediInfo);
          for (let j = 0; j < mediInfoList.length; j++) {
            if (mediInfoList[j].effect_flg == 0) {
              effcount++;
            }
          }
        }
        if (effcount == 0) {
          let ordNo = mediInfo[i].ordNo;
          let patId = null;
          this.nativeDataSourceDcs.forEach((data) => {
            if (data.ordNo == ordNo) {
              patId = data.patId;
            }
          });
          saveConfData.ordNo = ordNo;
          saveConfData.patId = patId;
          // doComplete
          saveConfData.doCompleteMedi = val;
          // userId
          saveConfData.userId = accountInfo.userId;
          // 保存情報セット
          this.confirmList.push(saveConfData);
        }
      }
      this.endPolling();
      // del #8659 【デグレ】治療状況リストで実績確定を行っても再度リストに表示される dou start
      // ポーリング再開
      // this.startPolling();
      // del #8659 【デグレ】治療状況リストで実績確定を行っても再度リストに表示される dou end
      // #10338 2024.03.26 del 実データと同期しない非表示をやめる TDC片口 start
      // // 非同期データ
      // this.asyncData();
      // #10338 2024.03.26 del 実データと同期しない非表示をやめる TDC片口 end
      // 確定処理へ移動
      this.updateCheckAfterWeight();
    },
    // #10338 2024.03.26 del 実データと同期しない非表示をやめる TDC片口 start
    // // 非同期データ
    // asyncData() {
    //   let conList = this.confirmList;
    //   for(let temp = 0; temp < conList.length; temp++) {
    //     for(let e = 0; e < this.dcsDataSource.length; e++) {
    //       if(this.dcsDataSource[e].ordNo === conList[temp].ordNo) {
    //         this.dcsDataSource.splice(e,1);
    //         e--;
    //       }
    //     }
    //   }
    // },
    // #10338 2024.03.26 del 実データと同期しない非表示をやめる TDC片口 end
    // secondDialog() {
    //   let mediInfo = this.mediInfo;
    //   let bedName = mediInfo[0].bedName;
    //   let patName = mediInfo[0].patName;
    //   let treatCd = mediInfo[0].rstTreatmentCd;

    //   // ポーリング停止
    //   this.endPolling();

    //   // 投薬判定
    //   if (treatCd !== null) {
    //     // 治療方法がある場合

    //     this.$ons.notification
    //       .confirm({
    //         title: "治療記録確定",
    //         message:
    //           "ベッド名: " +
    //           bedName +
    //           "</br>患者名: " +
    //           patName +
    //           "</br>の治療記録を確定します。</br>よろしいですか？",
    //         buttonLabels: ["はい", "いいえ"]
    //       })
    //       .then(answer => {
    //         if (answer === 0) {
    //           // Yes
    //           //2回目「いいえ」は保持しない
    //           let accountInfo = this.getStateUserAccountInfo;
    //           let saveConfData = {};
    //           // ordNo
    //           saveConfData.ordNo = this.setConfirm.ordNo;
    //           // doComplete
    //           saveConfData.doComplete = this.setConfirm.isMedi;
    //           // patId
    //           saveConfData.patId = this.setConfirm.patId;
    //           // userId
    //           saveConfData.userId = accountInfo.userId;
    //           // 保存情報セット
    //           this.confirmList.push(saveConfData);
    //           this.countVal++;
    //           this.mediInfo.shift();
    //           this.firstDialog();
    //         } else {
    //           // No
    //           this.mediInfo.shift();
    //           this.countVal++;
    //           this.firstDialog();
    //         }
    //         //
    //         if (this.countVal == this.doneResponseDataLength) {
    //           // ポーリング再開
    //           this.startPolling();
    //           // 確定処理へ移動
    //           this.updateCheckAfterWeight();
    //         }
    //       });
    //   } else {
    //     // 治療方法未定義の場合

    //     this.$ons.notification
    //       .alert({
    //         title: "治療記録確定",
    //         message:
    //           "ベッド名: " +
    //           bedName +
    //           "</br>患者名: " +
    //           patName +
    //           "</br>の治療方法が指定されていないため</br>治療記録を確定できません。"
    //       })
    //       .then(() => {
    //         this.mediInfo.shift();
    //         this.countVal++;
    //         this.firstDialog();

    //         //
    //         if (this.countVal == this.doneResponseDataLength) {
    //           // ポーリング再開
    //           this.startPolling();
    //           // 確定処理へ移動
    //           this.updateCheckAfterWeight();
    //         }
    //       });
    //   }
    // },
    /**
     * 確認ボタン押下時の更新処理関数
     */
    async updateCheckAfterWeight() {
      /**
       * putCheckAfterWeightへの引数は、{ordNo: <値>}のオブジェクトを
       * 配列に入れて渡してください。
       * ★実装完了後はこのコメントを削除して下さい。
       */
      let confirmList = this.confirmList;
      let nativeDataSourceDcs = this.dataSource.dcs;
      if (confirmList.length > 0) {
        // #10338 2024.03.29 mod 外部連携をREST API側に構築 TDC片口 start
        // const param = confirmList;
        // // 装置へ送信失敗計数
        // let warnCount = 0;
        // this.putCheckAfterWeight(param).then(async (response) => {
        // confirmList.forEach((item) => {
        //   // mod FNSI-画面で外部連携APIを呼び出すさい-538 付 start
        //   // this.insertCoopJournal("rst_dial", item.patId, item.ordNo);
        //   // this.insertCoopJournal("karte_ord", item.patId, item.ordNo);
        //   // this.insertCoopJournal("vit_cop", item.patId, item.ordNo);
        //   // this.insertCoopJournal("rep_dial", item.patId, item.ordNo);
        //   let treatDate = null;
        //   let hospPatId = null;
        //   let pat = null;
        //   nativeDataSourceDcs.forEach((sourceDcs) => {
        //     if (sourceDcs.ordNo == item.ordNo) {
        //       treatDate = sourceDcs.treatDate;
        //       hospPatId = sourceDcs.hospPatId;
        //       pat = sourceDcs.patId;
        //     }
        //   });
        //   if (this.buttonConfig == 1) {
        //     this.insertCoopJournal(hospPatId, item.ordNo, "011001", treatDate, pat);
        //     this.insertCoopJournal(hospPatId, item.ordNo, "011002", treatDate, pat);
        //     this.insertCoopJournal(hospPatId, item.ordNo, "011003", treatDate, pat);
        //     this.insertCoopJournal(hospPatId, item.ordNo, "011004", treatDate, pat);
        //   } else if (this.buttonConfig == 2) {
        //     this.insertCoopJournal(hospPatId, item.ordNo, "011005", treatDate, pat);
        //     this.insertCoopJournal(hospPatId, item.ordNo, "011006", treatDate, pat);
        //     this.insertCoopJournal(hospPatId, item.ordNo, "011007", treatDate, pat);
        //     this.insertCoopJournal(hospPatId, item.ordNo, "011008", treatDate, pat);
        //   }
        //   // mod FNSI-画面で外部連携APIを呼び出すさい-538 付 end
        //   // add 装置へ送信 付 start
        //   this.getMstMachineByOrdNoRst(item.ordNo).then((res) => {
        //     const params = {
        //       ordNo: item.ordNo, //オーダー番号
        //       machineNo: res.data[0].machineNo, //装置マスタ.装置番号
        //       deviceEdgeNo: res.data[0].deviceEdgeNo, //デバイスエッジ番号
        //       facilityCd: this.getFacilityCd, //施設コード
        //     };
        //     try {
        //       this.sendEndDateUpdateInfo(params);
        //     } catch (e) {
        //       warnCount++;
        //       //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        //       getErrorMessage(
        //         "StatusListMainComponent.vue",
        //         "updateCheckAfterWeight",
        //         e
        //       );
        //       //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        //     }
        //   });
        // });

        // if (warnCount > 0) {
        //   this.$ons.notification.alert({
        //     modifier: "warn",
        //     // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        //     // title: "送信に失敗しました",
        //     // message: `装置へ送信に失敗しました。`
        //     title: DIALOG_MESSAGES["00200033"].title,
        //     message: messageFormat(DIALOG_MESSAGES["00200033"].message),
        //     // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        //   });
        // }
        // // add 装置へ送信 付 end
        const param = this.buildConfirmParamJournal(
          nativeDataSourceDcs,
          confirmList
        );
        const response = await this.putCheckAfterWeight(param);
        // #10338 2024.03.29 mod 外部連携をREST API側に構築 TDC片口 end
        // add FNSI-ERRORMESSAGE追加処理 付 start
        if (response.status == 400) {
          await this.registerNotificationMessage({
            contentSubject: "更新失敗",
            contentBody: response.data.errorMessage,
            recipients: [this.getUserId],
            additionalInfo: null,
          }).catch((error) => {
            // 新着通知取得
            this.getNotificationMessage();
            //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
            getErrorMessage(
              "StatusListMainComponent.vue",
              "updateCheckAfterWeight",
              error
            );
            //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
            throw error;
          });

          // 新着通知取得
          this.getNotificationMessage();
        }
        // add FNSI-ERRORMESSAGE追加処理 付 end

        // #10338 2024.04.12 mod 画面リロード処理の変更 TDC片口 start
        // this.refresh();
        this.executeWithLoadingScreen(
          async () => await this.statusUpdateAsync()
        );
        // #10338 2024.04.12 mod 画面リロード処理の変更 TDC片口 end
        // });
      }
      // }
    },
    // add FNSI-実績確定修正 徐 end
    async onSave(ev) {
      /** Grid内のデータを変更した際の処理 */
      const param = this.makeUpdateTreatmentStatus(ev);
      // apiをコールして値を保存
      await this.updateTreatmentStatus(param)
        .then((response) => {
          this.updateResponse = response.data;
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "治療状況の情報更新が完了しました。"
            title: DIALOG_MESSAGES[12000238].title,
            message: messageFormat(DIALOG_MESSAGES[12000238].message),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
          this.isSorted = false;
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage("StatusListMainComponent.vue", "onSave", error);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage,
            });
          }
        });
      this.setGridData(0);
      ev.sender.refresh();
    },
    /**
     * 表示項目一覧から指定したdataClassの項目情報を取得する
     */
    searchDispItem(dataClass) {
      const dispItemList = this.refDispItemList;
      const len = dispItemList.length;

      for (let lop = 0; lop < len; lop++) {
        const item = dispItemList[lop];
        if (item.dataClass == dataClass) {
          return item;
        }
      }
    },
    createEditedRecord() {
      // 各装置の現在の設定値を取得
      let jsonDcs = JSON.parse(JSON.stringify(this.getSettingDataDcs));
      // 内部処理用のindexを取り除く
      jsonDcs = this.removeIndexForSettingData(jsonDcs);
      // 文字列化
      const stringDcs = JSON.stringify(jsonDcs);
      // 登録用データ作成
      this.editRecordOnComponent.dcsViewItems = stringDcs;
    },
    /**
     * 表示データを表示順で並べ替える
     */
    sortDispDataByDispOrder(jsonData) {
      let buf = [];
      let buf_temp = [];
      const cnt = jsonData.length;
      for (let lop = 0; lop < cnt; lop++) {
        const data = jsonData[lop];
        if (lop == 0) {
          // ループの1回目は無条件でバッファに入れる
          buf.push(data);
        } else {
          // ループの2回目以降
          let isPushed = false;
          for (let bufLop = 0; bufLop < buf.length; bufLop++) {
            const bufData = buf[bufLop];
            if (data.order_no < bufData.order_no && !isPushed) {
              buf_temp.push(data);
              isPushed = true;
              buf_temp.push(bufData);
            } else {
              buf_temp.push(bufData);
            }
          }
          if (buf_temp.length == buf.length) {
            buf_temp.push(data);
          }

          // 値渡し
          buf = buf_temp.slice();
          // temp初期化
          buf_temp = [];
        }
      }
      return buf;
    },
    // add 画面リロードの修正 徐 start
    async refreshVal() {
      let data = await getMstFacilitySettingValue(
        this.getFacilityCd,
        STATUS_AUTO_SETTING
      );
      if (data.status == 200) {
        if (data.data) {
          this.refreshInterval = data.data * 1000;
        } else {
          this.refreshInterval = 20000;
        }
      } else if (data.status == 400) {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage("StatusListMainComponent.vue", "startPolling", error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        this.refreshInterval = 20000;
      }
      /* 自動更新サインアウトフラグ取得 */
      await initForceSignOutFlag("status-list/list/setForceSignOutFlag", STATUS_LIST_FORCE_SIGNOUT);
      // mod #8032 2022/10/19 【デグレ】治療状況リストにおいてWebサーバ起動後の最初のサインイン時に何も表示しない dou start
      // if (parama != undefined) {
      //   parama();
      // }
      this.startPolling();
      // mod #8032 2022/10/19 【デグレ】治療状況リストにおいてWebサーバ起動後の最初のサインイン時に何も表示しない dou end    },
    },
    startPolling() {
      this.endPolling();
      // #8943対応時のメモ：
      // rev.64623(2023/06/22)時点で、
      // beforeDestroy実行後の this.refreshInterval がゼロの状態で呼ばれる場合が
      // あるようなので、その場合は setInterval を行わないようにしておく
      // （根本的には非同期処理に正しく処理中表示が入っていないために
      // 　非同期処理中に画面遷移などの操作が行われることで発生している問題と思われる）
      // 補足：
      // 画面開始時の this.refreshInterval が設定される前のタイミングでも
      // ゼロの状態で呼ばれるが、何度か endPolling と startPolling を
      // 繰り返しているうちに refreshInterval が初期設定されて
      // 通常の autoRefresh 呼び出しサイクルが始まる
      if (this.refreshInterval === 0) return;
      /* modify by chamaojia 2022-11-26 [6746] タイミングリフレッシュにloadingは必要ありません  --start */
      this.timerId.push(setInterval(this.autoRefresh, this.refreshInterval));
      /* modify by chamaojia 2022-11-26 [6746] タイミングリフレッシュにloadingは必要ありません  --end */
    },
    /* modify by chamaojia 2022-11-26 [6746] 自動リフレッシュ関数の追加  --start */
    autoRefresh() {
      this.statusUpdate(true);
      EventBus.$emit("autoRefresh");
    },
    /* modify by chamaojia 2022-11-26 [6746] 自動リフレッシュ関数の追加  --end */
    // mod FNSI-redmine#3941 付 end
    // add 画面リロードの修正 徐 end
    endPolling() {
      if (!this.timerId || this.timerId.length < 1) return;
      for (let i = 0; i < this.timerId.length; i++) {
        clearInterval(this.timerId[i]);
      }
      this.timerId.splice(0);
    },
    //治療記録削除ダイアログ
    // FNSI-7120-治療状況リストから????患者の削除に時間がかかる-徐博-update start
    async deleteRecord(rowItem, ordNo) {
      // FNSI-7120-治療状況リストから????患者の削除に時間がかかる-徐博-update end
      // ポーリング停止
      this.endPolling();
      let isDispDialog = false;
      await this.$ons.notification.confirm({
        modifier: "warn",
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "治療記録削除警告",
        title: DIALOG_MESSAGES[13000131].title,
        // message:
        //   "表示している治療記録を削除します。削除すると二度と元に戻せません。削除しますか？",
        message: messageFormat(DIALOG_MESSAGES[13000131].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: (answer) => {
          if (answer == 1) {
            isDispDialog = true;
          }
        },
      });
      if (isDispDialog) {
        await this.$ons.notification.confirm({
          modifier: "warn",
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "治療記録削除最終確認",
          title: DIALOG_MESSAGES[13000132].title,
          // message: "表示している治療記録を削除します。本当によろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000132].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: (answer) => {
            if (answer == 0) {
              isDispDialog = false;
            }
          },
        });
        if (isDispDialog) {
          // FNSI-7120-治療状況リストから????患者の削除に時間がかかる-徐博-add start
          this.confirmList.push(rowItem);
          // #10337 2024.04.12 del 実データと同期しない非表示をやめる TDC片口 start
          // // 非同期データ
          // this.asyncData();
          // #10337 2024.04.12 del 実データと同期しない非表示をやめる TDC片口 end
          // FNSI-7120-治療状況リストから????患者の削除に時間がかかる-徐博-add end
          // 削除処理
          // #10337 2024.04.12 add ローディング TDC片口 start
          this.startLoadingScreen();
          // #10337 2024.04.12 add ローディング TDC片口 end
          try {
            const ret = await this.deleteUnknownPatRecord(ordNo);
            // #10337 2024.04.12 add ローディング TDC片口 start
            this.finishLoadingScreen();
            // #10337 2024.04.12 add ローディング TDC片口 end
            if (ret.data.isSuccess) {
              // #10337 2024.04.12 mod ローディング付き再読込処理 TDC片口 start
              // this.statusUpdate();
              await this.executeWithLoadingScreen(
                async () => await this.statusUpdateAsync()
              );
              // #10337 2024.04.12 mod ローディング付き再読込処理 TDC片口 end
            } else {
              await this.$ons.notification.alert({
                modifier: "warn",
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "治療記録削除失敗",
                // message: `治療記録の削除に失敗しました。\n${ret.data.errorMessage}`
                title: DIALOG_MESSAGES[12000239].title,
                message: messageFormat(
                  DIALOG_MESSAGES[12000239].message,
                  ret.data.errorMessage
                ),
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              });
            }
          } catch (e) {
            // #10337 2024.04.12 add ローディング TDC片口 start
            this.finishLoadingScreen();
            // #10337 2024.04.12 add ローディング TDC片口 end
            //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
            getErrorMessage(
              "StatusListMainComponent.vue",
              "deleteRecord",
              "治療記録の削除に失敗しました"
            );
            //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
            await this.$ons.notification.alert({
              modifier: "warn",
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "治療記録削除失敗",
              // message: `治療記録の削除に失敗しました。\n${e}`
              title: DIALOG_MESSAGES[12000239].title,
              message: messageFormat(DIALOG_MESSAGES[12000239].message, e),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        }
      }
      // ポーリング再開
      this.startPolling();
    },
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name) {
        // FNSI-add redmine5168 徐 start
        this.setLoadingScreenVisible(true);
        // FNSI-add redmine5168 徐 end
        // ポーリング停止
        this.endPolling();

        this.statusUpdate();

        // ポーリング再開
        this.startPolling();

        // FNSI-add redmine5168 徐 start
        setTimeout(() => {
          this.setLoadingScreenVisible(false);
        }, 2000);
        // FNSI-add redmine5168 徐 end
      }
    },
    /**
     * ？？？？患者割当後の治療記録画面への遷移
     */
    moveTreatmentRecord(params) {
      this.setSelectedPatHeader(params.patId).then(() => {
        // ordNoセット
        this.$nextTick(() => {
          //add FNSI修正 治療記録画面バッグ 房 start
          this.setOrd({
            readOnly: false,
          });
          //add FNSI修正 治療記録画面バッグ 房 end
          this.setTreatmentRecordOrdNo(params.ordNo);
          // 治療記録画面へ遷移
          this.$router.push({ name: "treatment-record" });
        });
      });
    },
    // Grid表示データの構築
    buildDcsDataSource(isCreateColumn) {
      let dataList = [];

      /* modify by chamaojia 2024-03-28 [10303、10304] data processing has been completed in the backend --start */
      if (this.getDeviceDataSource && this.getDeviceDataSource.dcs) {
        dataList = this.getDeviceDataSource.dcs;
      }

      // null情報除去
      let dSrc = dataList.filter((data) => data !== null);

      // 現患者が治療終了の場合のフラグ 治療状況のみ
      if (this.getIsShowMain) {
        // 現患者を探す
        const nowPatList = dSrc.filter((data) => {
          return data.machineOrdNo === data.ordNo;
        });
        // 現患者のrstDialysisStateが4,5の場合、同じベッドのデータに治療終了フラグを立てる
        nowPatList.forEach((nowPat) => {
          if (
            nowPat.rstDialysisState === "4" ||
            nowPat.rstDialysisState === "5"
          ) {
            for (let i = 0; i < dSrc.length; i++) {
              if (dSrc[i].bedCd === nowPat.bedCd) {
                dSrc[i].endOfTreatment = true;
              }
            }
          }
        });
      }

      if (isCreateColumn) {
        // グリッド再構築
        if (this.conditionFilter.isClear) {
          this.sortDcs = [];

          // 一度ソート条件をリセットした後はisClearをfalseに戻す
          this.conditionFilter.isClear = false;
        } else {
          if (this.sortDcs.length == 0) {
            this.sortDcs = [];
          }
        }
      }

      this.dcsDataSource = dSrc;
      
      // ソート用field設定
      // sys_monitor_item ソート用field設定
      commonFunctions.setSortFieldSysMonitorItem(this.treatAllColumn.dcsTreatSetCol, this.dcsDataSource, this.getSysMonitorItem);
      // mst_treatment_status_disp_itemの個別ソート対応必要な項目のソート用field設定
      commonFunctions.setSortFieldMstDispItem(this.dcsDataSource, this.treatAllColumn, this.mstPersonalUser);

      this.setEditingField(undefined);
    },
    changeView(mode) {
      // ポーリング停止
      this.endPolling();

      this.setGridData(mode);
      // ポーリング再開
      this.startPolling();
    },
    changeView1() {
      this.changeView(1);
    },
    initData(){
      // 画面名称取得
      this.selfScreenName = this.$router.currentRoute.name;

      // スタッフマスタ情報取得
      this.getMstPersonalUser();
      //
      const condition = this.conditionFilter;
      condition.isClear = false;
      this.conditionSet(condition);
      // grid情報取得:初期
      this.loadData();
      // add FNSI-画面リロードの修正 徐 start
      this.$nextTick(() => {
        this.notifyTopic = `${NOTIFY_TOPIC_MACHINE_RESULT}/${this.getFacilityCd}`;
        this.addWatchTopics({
          topic: this.notifyTopic,
          obj: this.notifyValue,
        });
      });
      // add FNSI-画面リロードの修正 徐 end
      // add FNSI-画面パフォーマンス対応 付 start
      this.getMst();
      // add FNSI-画面パフォーマンス対応 付 end

      // 機械室装置ボタン点滅処理
      this.blinkColor = "dark"; // 点滅色の濃さ dark/light
      // ＃9141対応:治療状況リスト：治療状況⇔装置一覧の切り替え時 点滅間隔が早くなる（一定の間隔にする。）Start
      clearTimeout(this.blinkAlarm);
      // ＃9141対応:治療状況リスト：治療状況⇔装置一覧の切り替え時 点滅間隔が早くなる（一定の間隔にする。）Start
      this.blinkProc();
    },
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // add #11285 機能帳票の印刷情報対応② 高 start
        var expressCondCd="";
        if (null != this.getStorSimlpSearchQurey.rstDialysisState && this.getStorSimlpSearchQurey.rstDialysisState.length > 0) {
          if (this.getStorSimlpSearchQurey.rstDialysisState.length == 2) {
            expressCondCd = "予定・実績";
          } else {
            if (this.getStorSimlpSearchQurey.rstDialysisState[0] == 1) {
              expressCondCd = "予定";
            } else {
              expressCondCd = "実績";
            }
          }
        }
        let patGroups = null;
        if(this.getStorSimlpSearchQurey.selectedPatGroupNames) {
          patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames;
        } else {
          patGroups = "すべて";
        }
        // eslint-disable-next-line vue/no-side-effects-in-computed-properties
        this.bedCdListString = JSON.parse(sessionStorage.getItem('roomBedGroupNameStatusList')) || [];
        // eslint-disable-next-line vue/no-side-effects-in-computed-properties
        this.kurGroupName = JSON.parse(sessionStorage.getItem('kurGroupNameStatusList')) || [];
        // add #11285 機能帳票の印刷情報対応② 高 end
        // 機能一致

        // 印刷パラメータを応答
        const param = {
          // add 機能帳票パラメータ確認 陳 start
          // del #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
          // patId: this.selectedPatId,
          // del #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end
          patIds: this.nativeDataSourceDcs.map(({ patId }) => patId),
          ordNos: this.nativeDataSourceDcs.map(({ ordNo }) => ordNo),
          // add 機能帳票パラメータ確認 陳 end
          facilityCd: this.getFacilityCd,
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          functionCd:"01101",
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          date: moment(Date.now()).format("YYYY/MM/DD"),
          fromDate: moment(Date.now()).format("YYYY/MM/DD"),
          toDate: moment(Date.now()).format("YYYY/MM/DD"),
          //add FNSI redmine 5984 劉祥霖 start
          machineNos: this.nativeDataSourceDcs.map(
            ({ machineNo }) => machineNo
          ),
          //add FNSI redmine 5984 劉祥霖 end
          // add #11285 機能帳票の印刷情報対応② 高 start
          treatDate:this.getStorSimlpSearchQurey.treatDate,
          bedCdListString:this.bedCdListString,
          freeWord:this.getStorSimlpSearchQurey.freeWord,
          expressCondCdStr:expressCondCd,
          kurNames:this.kurGroupName.replaceAll("、","・"),
          patGroups:patGroups,
          // add #11285 機能帳票の印刷情報対応② 高 end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add FNSI-ソート順の修正 付 start
    sortNullData(paramData) {
      const isDcs = paramData.datalistType === MACHINE_MODEL.DCS;
      
      // ソートキー変換必要な可変fieldを取得
      const hospPatIdField = this.treatAllColumn.dcsTreatSetCol.find(item => item.data_class === TREATMENT_ITEM_CD.HOSP_PAT_ID)?.field; // 2: 患者ID
      const patientConfirmField = this.treatAllColumn.dcsTreatSetCol.find(item => item.data_class === TREATMENT_ITEM_CD.PATIENT_CONFIRM)?.field; // 50: 患者確認

      let nativeData = [];
      let firstFieldName = null;
      if (
        paramData.fieldNameObj[0] != undefined &&
        paramData.fieldNameObj[0] != null &&
        paramData.fieldNameObj[0] != ""
      ) {
        firstFieldName = paramData.fieldNameObj[0].field;
      }
      if (
        firstFieldName != undefined &&
        firstFieldName != null &&
        firstFieldName != ""
      ) {
        // ソート指定ありの場合

        /** 警報・報知列にmachine_statusのビット値を元に警報or報知or空値を判定する値を設定 */
        const newDataList = this.setAlarmValue(paramData);
        
        /** ソートキー変換用のマップ作成 */
        const SORT_KEY_MAP = new Map();     
        if (isDcs) { // 透析装置
          SORT_KEY_MAP.set("bedName", "bedIndex");    // 固定列
          SORT_KEY_MAP.set("patName", "patNameSort"); // 固定列
          SORT_KEY_MAP.set(hospPatIdField, "hospPatId");
        } else { // RO、溶解、供給
          SORT_KEY_MAP.set("machineName", "machineIndex");  // 固定列
        }
        
        /** ソートキー変換 */        
        const sortFieldNameObj = paramData.fieldNameObj.map(({ field, dir }) => {
          // newDataListの1行目を参照
          const firstRow = newDataList[0] || {};
          const finalField = firstRow.hasOwnProperty(`${field}_sort`)
            ? `${field}_sort` // "_sort" フィールドが存在する場合はそれを使用
            : (SORT_KEY_MAP.get(field) || field); // "_sort" フィールドが存在しない場合はマップで変換後のソートキーを使用
          return { field: finalField, dir };
        });
        
        /** ソート時のoptionルール設定 */
        
        // 昇順/降順を逆順でソートするフィールド ※透析装置
        const reverseFields = isDcs 
          ? this.treatAllColumn.dcsTreatSetCol.filter(item => ORDER_REVERSE_FIELDS.includes(item.data_class)).map(item => item.field)
          : [];
        
        // 空欄位置制御
        const nullOrderRule = sortFieldNameObj.reduce((acc, { field }) => {
          let orderType = "last"; // デフォルトは「常に空欄を後ろへ」
          if (isDcs) {
            if (field === "patNameSort") {
              orderType = "reverse"; // 昇順: 空欄を前へ、降順: 空欄を後ろへ
            } else if (field === patientConfirmField) {
              orderType = "normal";  // 昇順: 空欄を後ろへ、降順: 空欄を前へ
            }
          }
          acc[field] = orderType;
          return acc;
        }, {});
        
        // 数値化できるものは数値でソートするfieldを設定
        const orderAsNumberFields = this.fieldOrderAsNumberMap[paramData.datalistType] || [];
        
        // 時刻形式（hh:mm）にフォーマットしてソートするfieldを設定
        const orderAsTimeFields = this.fieldOrderAsTimeMap[paramData.datalistType] || [];

        // 複合ソート実行(共通関数)
        nativeData = [...newDataList].sort(
          multiSortableCompare(sortFieldNameObj, {
            reverseFields: reverseFields,
            nullOrderRule: nullOrderRule,
            notUseSortKeyMap: true,
            orderAsNumberFields: orderAsNumberFields,
            orderAsTimeFields: orderAsTimeFields,
          })
        );

      } else {
        // ソート指定なしの場合
        nativeData = orderBy(paramData.datalist, paramData.fieldNameObj);
      }
      return nativeData;
    },
    // add FNSI-ソート順の修正 付 end
    /**
     * 警報・報知にmachine_statusのビット値を元に警報or報知or空値を判定する値を設定
     * 警報・報知だけmachine_statusのビット値(Bit0～Bit7)から警報or報知or空値を判定してアイコン表示しているためソートに使用する値が空値になっている
     * 以下の順でソートされるようにする
     * - 昇順：警報⇒報知⇒空欄
     * - 降順：空欄⇒報知⇒警報
     */
    setAlarmValue(paramData) {
      // datalistをコピーして新しい配列に保存
      const newDataList = [...paramData.datalist];

      // 優先度を取得
      const getPriority = (item) => {
        const ret = commonFunctions.judgeWarnInfoBlank(this.getIsShowMain, item);
        if (ret === ALERT_TYPES.WARN) return 1; // 警報 (Bit3が1)
        if (ret === ALERT_TYPES.INFO) return 2; // 報知 (Bit5が1)
        return 3; // 他の値（空欄として扱う）
      };
      // 警報・報知のfield取得
      const fieldAlarm = this.fieldAlarmMap[paramData.datalistType] || "";
      if (fieldAlarm) {
        // 警報・報知の場合、その値をmachine_statusのビット値を元に取得した優先度で書き換える
        newDataList.forEach(item => {
          if (item.hasOwnProperty(fieldAlarm)) {
            item[fieldAlarm] = getPriority(item);
          }
        });
      }
      return newDataList;
    },
    // 機械室装置ボタン点滅処理
    blinkProc() {
      switch (this.blinkColor) {
        case "dark":
          this.setBlinkAlarm(this.blinkColor);
          this.setBlinkCaution(this.blinkColor);
          this.blinkColor = "light";
          this.blinkAlarm = setTimeout(() => {
            this.blinkProc();
          }, 500);
          break;
        case "light":
          this.setBlinkAlarm(this.blinkColor);
          this.setBlinkCaution(this.blinkColor);
          this.blinkColor = "dark";
          this.blinkAlarm = setTimeout(() => {
            this.blinkProc();
          }, 200);
          break;
        default:
          break;
      }
    },
    setBlinkAlarm(blinkColor) {
      const bgColor = blinkColor === "dark" ? "#FF6666" : "#FFDDDD";
      const targetElems = document.getElementsByClassName("blink-alarm");
      for (let elem of targetElems) {
        elem.style.backgroundColor = bgColor;
      }
    },
    setBlinkCaution(blinkColor) {
      const bgColor = blinkColor === "dark" ? "#FFF682" : "#FFFDDD";
      const targetElems = document.getElementsByClassName("blink-caution");
      for (let elem of targetElems) {
        elem.style.backgroundColor = bgColor;
      }
    },
  },
  watch: {
    showSidebarFlg() {
      const clientWidth = document.getElementById("main-list-grid-box").clientWidth;
      this.gridWidth = clientWidth - 1 + 'px';
    },
    windowWidth: {
      handler() {
        this.$nextTick(() => {
          const ele = document.getElementById("main-list-grid-box");
          if (ele) {
            const clientWidth = ele.clientWidth;
            this.gridWidth = clientWidth - 1 + 'px';
          }
        });
      },
      immediate: true
    },
    nativeDataSourceDcs(val) {
      this.gridDataItem = val.slice(this.skip, this.skip + this.take);
    },
    getIsShowMain() {
      this.setGridFilter();
      this.changeView(2);
    },
    splittedWidth(value) {
      // 表示幅設定
      this.setClientWidth(value);
      const clientWidth = document.getElementById("main-list-grid-box").clientWidth;
      this.gridWidth = clientWidth - 1 + 'px';
    },
    dcsColumns(value) {
      this.nativeDcsColumns = value;
    },
    droColumns(value) {
      this.nativeDroColumns = value;
    },
    dabColumns(value) {
      this.nativeDabColumns = value;
    },
    dadColumns(value) {
      this.nativeDadColumns = value;
    },
    // add FNSI-画面リロードの修正 徐 start
    /**
     * WebSocket通知監視
     */
    "notifyValue.length"(newValue) {
      if (newValue > 0) {
        this.dequeueMessage(this.notifyTopic).then((value) => {
          let statusOrdNo = value.split(",");
          if (statusOrdNo[2] == "001") {
            this.nativeDataSourceDro.forEach((e) => {
              if (e.machineSerial != undefined && e.machineSerial != null) {
                if (e.machineSerial == statusOrdNo[3]) {
                  if (e.machineStatus != undefined) {
                    e.machineStatus = statusOrdNo[0];
                  }
                }
              }
            });
          } else if (statusOrdNo[2] == "002") {
            this.nativeDataSourceDab.forEach((e) => {
              if (e.machineSerial != undefined && e.machineSerial != null) {
                if (e.machineSerial == statusOrdNo[3]) {
                  if (e.machineStatus != undefined) {
                    e.machineStatus = statusOrdNo[0];
                  }
                }
              }
            });
          } else if (statusOrdNo[2] == "003") {
            this.nativeDataSourceDad.forEach((e) => {
              if (e.machineSerial != undefined && e.machineSerial != null) {
                if (e.machineSerial == statusOrdNo[3]) {
                  if (e.machineStatus != undefined) {
                    e.machineStatus = statusOrdNo[0];
                  }
                }
              }
            });
          } else {
            this.nativeDataSourceDcs.forEach((e) => {
              if (e.ordNo != undefined && e.ordNo != null) {
                if (e.ordNo == statusOrdNo[1]) {
                  if (e.machineStatus != undefined) {
                    e.machineStatus = statusOrdNo[0];
                  }
                }
              }
            });
          }
        });
      }
      this.deviceColorStyle();
    },
    "$route.path": {
      handler() {
        let href = window.location.href.split("/");
        if (href.slice(-1) == "alarm") {
          this.setIsAlarmDisplay(true);
        } else if (href.slice(-1) == "main") {
          this.setIsAlarmDisplay(false);
          // 透析装置エリアの横幅設定
          const clientWidth = document.getElementById("main-list-grid-box").clientWidth;
          this.gridWidth = clientWidth - 1 + 'px';
          // ボタンのスタイル設定
          this.deviceColorStyle();
        }
      },
    },
    // add FNSI-画面リロードの修正 徐 end
  },
  created() {
    // デフォルト設定読み込み
    const defaultCondition = deepCopy(
      this.getDefaultSetting[KEY_NAME_STATUS_LIST.KEY_NAME]
    );
    // mod #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
    // if (!(!defaultCondition || Object.keys(defaultCondition).length === 0)) {
    if (
      !(!defaultCondition || Object.keys(defaultCondition).length === 0) &&
      this.getFirstInit
    ) {
      // mod #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
      if (defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DRO]) {
        // mod #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
        // this.dispDro = true;
        this.setDispDro(true);
        // mod #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
      }
      if (defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAD]) {
        // mod #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
        // this.dispDad = true;
        this.setDispDad(true);
        // mod #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
      }
      if (defaultCondition[KEY_NAME_STATUS_LIST.KEY_NAME_DISP_DAB]) {
        // mod #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen start
        // this.dispDab = true;
        this.setDispDab(true);
        // mod #8458「透析液調製装置を隠しても再表示される」について、対応する。 dengshen end
      }
    }

    EventBus.$on("startListPolling", this.startPolling);
    EventBus.$on("stopListPolling", this.endPolling);

    // v-bindや{{}}などView要素への変数の依存性注入などがされたあとに実行される処理
    EventBus.$on("filterSignal", this.changeView1);
    // ？？？？患者割り付け後イベントセット
    EventBus.$on("dataUpdate", this.loadData);
    EventBus.$on("initSignal", this.initData);

    // ？？？？患者モーダル非表示時のポーリング再開
    // add FNSI-？？？？患者割り当て 陳 start
    //EventBus.$on("hideScheduleAssignmentModal", this.startPolling);
    EventBus.$on("hideScheduleAssignmentModal", this.refresh);
    // add FNSI-？？？？患者割り当て 陳 end
    EventBus.$on("showScheduleAssignmentModal", this.endPolling);
    // EventBus.$on("startPolling", this.startPolling);
    // EventBus.$on("endPolling", this.endPolling);
    EventBus.$on("refresh", this.refresh);

    // スケジュール割当後の治療記録への遷移
    EventBus.$on("ScheduleAssignment", this.moveTreatmentRecord);

    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);

    EventBus.$on("deviceColorStyle", this.deviceColorStyle);

    // 端末判別
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }

  },
  mounted() {
    // 描画系の処理がすべて完了した後に実行される処理
    const sort = this.getColumnSort;
    this.sortDcs = sort.dcs;
    this.sortDro = sort.dro;
    this.sortDab = sort.dab;
    this.sortDad = sort.dad;
    // del #8032 2022/10/19 【デグレ】治療状況リストにおいてWebサーバ起動後の最初のサインイン時に何も表示しない dou start
    // ポーリング開始
    // mod FNSI-redmine#3941 付 start
    // this.refreshVal(this.startPolling);
    // mod FNSI-redmine#3941 付 end
    // del #8032 2022/10/19 【デグレ】治療状況リストにおいてWebサーバ起動後の最初のサインイン時に何も表示しない dou end
    // 画面遷移パラメータ取得
    const queryParameters = this.getQueryParameters();

    if (queryParameters.ORDNO) {
      // モーダル表示対象にord_noをセット
      this.setIndOrdNo(queryParameters.ORDNO).then(() => {
        // クエリパラメータのord_noをクリア
        queryParameters.ORDNO = null;
        this.setQueryParameters(queryParameters);
        // 指定ord_noのモーダルを出す
        this.showIndicationsDiffModal();
      });
    }
    
    window.addEventListener("beforeprint", this.handleBeforePrint);
    window.addEventListener("afterprint", this.handleAfterPrint);
  },
  updated() {
    // 治療状況リストのkendo-grid-native内で作り直されたセルのDOM要素のstyleを再設定する
    this.columnStyleResetDcs();
    // kendo-girdの列ヘッダセルのソート表示を列名の左に移動する
    this.modifySortIndicator();
  },
  beforeDestroy() {
    // add FNSI-画面リロードの修正 徐 start
    this.removeWatchTopics(this.notifyTopic);
    // add FNSI-画面リロードの修正 徐 end
    // 画面が削除される際に実行される処理
    this.setColumnSort({
      dcs: this.sortDcs,
      dro: this.sortDro,
      dab: this.sortDab,
      dad: this.sortDad,
    });

    EventBus.$off("startListPolling", this.startPolling);
    EventBus.$off("stopListPolling", this.endPolling);

    // ？？？？患者割り付け後イベント削除
    EventBus.$off("dataUpdate", this.loadData);
    EventBus.$off("filterSignal", this.changeView1);
    EventBus.$off("showScheduleAssignmentModal", this.endPolling);
    // add FNSI-画面パフォーマンス対応 付 start
    // EventBus.$off("hideScheduleAssignmentModal", this.startPolling);
    // add FNSI-画面パフォーマンス対応 付 end
    // EventBus.$off("startPolling", this.startPolling);
    // EventBus.$off("endPolling", this.endPolling);
    EventBus.$off("refresh", this.refresh);
    // スケジュール割当後の治療記録への遷移
    EventBus.$off("ScheduleAssignment", this.moveTreatmentRecord);
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add FNSI-画面パフォーマンス対応 付 start
    EventBus.$off("hideScheduleAssignmentModal", this.refresh);
    EventBus.$off("deviceColorStyle", this.deviceColorStyle);
    // add FNSI-画面パフォーマンス対応 付 end
    EventBus.$off("initSignal", this.initData);
    
    window.removeEventListener("beforeprint", this.handleBeforePrint);
    window.removeEventListener("afterprint", this.handleAfterPrint);

    // polling用setIntervalのクリア
    this.endPolling();

    this.setEditingField(undefined);

    // add FNSI-redmine#4252 付 start
    if (!this.isBool) {
      if (this.getColumnResizeData != null && this.getColumnResizeData != []) {
        this.getColumnResizeData.forEach((index) => {
          this.colChangeSize.push(index);
        });
      }
    }
    this.setColumnResizeData(this.colChangeSize);
    this.colChangeSize = [];
    // add FNSI-redmine#4252 付 end
    // add FNSI-redmine#5747 高 start
    if (!this.droIsBool) {
      if (
        this.getDroColumnResizeData != null &&
        this.getDroColumnResizeData != []
      ) {
        this.getDroColumnResizeData.forEach((index) => {
          this.droColChangeSize.push(index);
        });
      }
    }
    this.setDroColumnResizeData(this.droColChangeSize);
    this.droColChangeSize = [];
    if (!this.dadIsBool) {
      if (
        this.getDadColumnResizeData != null &&
        this.getDadColumnResizeData != []
      ) {
        this.getDadColumnResizeData.forEach((index) => {
          this.dadColChangeSize.push(index);
        });
      }
    }
    this.setDadColumnResizeData(this.dadColChangeSize);
    this.dadColChangeSize = [];
    if (!this.dabIsBool) {
      if (
        this.getDabColumnResizeData != null &&
        this.getDabColumnResizeData != []
      ) {
        this.getDabColumnResizeData.forEach((index) => {
          this.dabColChangeSize.push(index);
        });
      }
    }
    this.setDabColumnResizeData(this.dabColChangeSize);
    this.dabColChangeSize = [];
    // add FNSI-redmine#5747 高 end
    this.blinkColor = null;

    // beforeDestroyで変更したStore項目の
    // getters(computed)のキャッシュを更新するために値を参照する
    // （stateに持っている値とgettersのキャッシュで
    // 　別個のオブジェクトを保持している状態を解消する）
    this.getColumnResizeData;
    this.getDroColumnResizeData;
    this.getDadColumnResizeData;
    this.getDabColumnResizeData;
    // beforeDestroyではsetColumnSortによるStore項目の変更も行っているが、
    // stateに持っているgetters対象オブジェクトの
    // 内部のプロパティを置き換えるだけなのでキャッシュを更新する必要はない

    // 画面終了時に不要になるstore内の情報を破棄する
    this.clearDisplayData();

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};

// 指定したstyle項目を必要に応じて設定する
const setStyle = (element, styles) => {
  Object.entries(styles).forEach(([key, value]) => {
    if (element.style[key] !== value) {
      element.style[key] = value;
    }
  });
};

const NodeType = Object.freeze({
  Element: 1,
  Text: 3,
});
const isTextNode = node => node?.nodeType === NodeType.Text;
const SpanNodeName = "SPAN";
const isSpanNode = node => (
  node?.nodeType === NodeType.Element
  && node?.nodeName === SpanNodeName
);
</script>
<style scoped>
::v-deep .k-grid-header .k-grid-header-sticky,
::v-deep .k-grid-header .k-grid-header-sticky.k-sorted {
  color: #fff !important;
}
/** 機械室装置の行ヘッダ */
.status-list-page >>> .locked-machine-td {
  border-color: var(--master-maintenance-kgrid-border-color);
  color: var(--master-maintenance-kgrid-body-color);
  background-color: var(
    --master-maintenance-kgrid-item-background-color
  ) !important;
}
.status-list-page .k-alt >>> .locked-machine-td {
  border-color: var(--master-maintenance-kgrid-border-color);
  color: var(--master-maintenance-kgrid-body-color);
  background-color: var(
    --master-maintenance-kgrid-item-background-color
  ) !important;
}

.k-grid-content {
  width: 100%;
}
.grid-title {
  margin: 0px;
  padding-left: 10px;
  text-align: left;
  font-size: 1.5em;
  color: var(--treatment-status-font-color);
}
#main-list-grid-box {
  flex-grow: 1;
  height: 100%;
  width: 100%;
  overflow: hidden;
  display: block;
  box-sizing: border-box;
}
#main-list-grid-box >>> .k-grid {
  height: 100% !important;
}
.no-scrollbar-area-header >>> .k-grid-header {
  padding: 0 !important;
}
.device-list-grid {
  display: block;
  margin-bottom: 3px;
}
.conf-body {
  height: 100%;
  width: 100%;
}
#flex-area {
  height: 100%;
  width: 100%;
  display: flex;
  flex-direction: column;
}
#device-grid-area {
  flex-shrink: 0;
  width: 100%;
  max-height: 50%;
  overflow-x: hidden;
  overflow-y: scroll;
  margin-bottom: 3px;
}
#device-grid-area >>> .k-grid {
  height: auto !important;
}
#device-grid-area >>> .k-grid-header {
  padding: 0 !important;
}
#device-grid-area >>> .k-grid-content {
  overflow-y: visible;
}
.button-font {
  font-size: 1em;
  padding: 0;
}
.dialysis-adjusting-device {
  border-collapse: collapse;
}
.alarm-notification-list {
  width: 7em;
  background-color: #999;
  line-height: 1.8em;
  box-shadow: none !important;
}
.page-back-button {
  width: 1.75em;
  height: 1.7em;
  border-radius: 50%;
  -webkit-border-radius: 50%;
  -moz-border-radius: 50%;
  background-color: #999;
  /* outline: none; */
  margin-left: 2em;
  line-height: 1.8em;
}
#status-device {
  display: inherit;
}
.sample {
  width: 100px;
  height: 100px;
  background: red;
}
.device-box {
  height: 100%;
  display: inherit;
  vertical-align: middle;
  text-align: center;
  border: solid 1px #999;
}
.td-button {
  width: 3em;
  display: inline-flex;
  table-layout: fixed;
  box-shadow: none !important;
}

.dab1 {
  background-color: #4286f4;
}
.dab2 {
  background-color: #00a36c;
}
.dad {
  background-color: #7ed160;
}
.dro {
  background-color: #00a36c;
}
#status-grid-header {
  flex-shrink: 0;
  overflow-x: hidden;
  display: flex;
  justify-content: space-between;
  margin: 0 5px 3px 5px;
  flex-wrap: wrap;
}
#batch-check-area {
  display: flex;
  align-items: center;
}
.common-style-ok-button {
  font-size: 1.5em;
  width: 90px !important;
}
/** 状態セル */
/** 透析準備 */
.status-list-page >>> .dialysis-state-td-0,
.status-list-page >>> .process-state-td-01,
.status-list-page >>> .process-state-td-07,
.status-list-page >>> .process-state-td-08,
.status-list-page >>> .process-state-td-09,
.status-list-page >>> .process-state-td-20,
.status-list-page >>> .process-state-td-29,
.status-list-page >>> .process-state-td-40,
.status-list-page >>> .process-state-td-45,
.status-list-page >>> .process-state-td-61,
.status-list-page >>> .process-state-td-A0,
.status-list-page >>> .process-state-td-A5,
.status-list-page >>> .process-state-td-A6,
.status-list-page >>> .process-state-td-A7,
.status-list-page >>> .process-state-td-AE,
.status-list-page >>> .process-state-td-B0,
.status-list-page >>> .process-state-td-B8,
.status-list-page >>> .process-state-td-BC {
  background-color: #FFFFFF !important;
  color: black;
}

/** 洗浄・消毒 */
.status-list-page >>> .process-state-td-02,
.status-list-page >>> .process-state-td-03,
.status-list-page >>> .process-state-td-04,
.status-list-page >>> .process-state-td-05,
.status-list-page >>> .process-state-td-06,
.status-list-page >>> .process-state-td-23,
.status-list-page >>> .process-state-td-24,
.status-list-page >>> .process-state-td-25,
.status-list-page >>> .process-state-td-26,
.status-list-page >>> .process-state-td-27,
.status-list-page >>> .process-state-td-28,
.status-list-page >>> .process-state-td-46,
.status-list-page >>> .process-state-td-47,
.status-list-page >>> .process-state-td-62,
.status-list-page >>> .process-state-td-63,
.status-list-page >>> .process-state-td-64,
.status-list-page >>> .process-state-td-65,
.status-list-page >>> .process-state-td-A8,
.status-list-page >>> .process-state-td-A9,
.status-list-page >>> .process-state-td-AA,
.status-list-page >>> .process-state-td-AB,
.status-list-page >>> .process-state-td-AC,
.status-list-page >>> .process-state-td-AD,
.status-list-page >>> .process-state-td-B1,
.status-list-page >>> .process-state-td-B2,
.status-list-page >>> .process-state-td-B6,
.status-list-page >>> .process-state-td-B7,
.status-list-page >>> .process-state-td-B9,
.status-list-page >>> .process-state-td-BA,
.status-list-page >>> .process-state-td-BB  {
  background-color: #00B0F0 !important;
  color: black;
}
/** 条件送信済み */
.status-list-page >>> .dialysis-state-td-1,
.status-list-page >>> .dialysis-state-td-2 {
  background-color: #42CB92 !important;
}
/** 治療中 */
.status-list-page >>> .dialysis-state-td-3,
.status-list-page >>> .process-state-td-10,
.status-list-page >>> .process-state-td-11,
.status-list-page >>> .process-state-td-21,
.status-list-page >>> .process-state-td-22,
.status-list-page >>> .process-state-td-41,
.status-list-page >>> .process-state-td-42,
.status-list-page >>> .process-state-td-43,
.status-list-page >>> .process-state-td-44,
.status-list-page >>> .process-state-td-60,
.status-list-page >>> .process-state-td-A1,
.status-list-page >>> .process-state-td-A2,
.status-list-page >>> .process-state-td-A3,
.status-list-page >>> .process-state-td-A4,
.status-list-page >>> .process-state-td-B3,
.status-list-page >>> .process-state-td-B4,
.status-list-page >>> .process-state-td-B5 {
  background-color: #2CA06F !important;
  color: #fff !important;
}

/** 通信エラー */
.status-list-page >>> .process-state-td-99 {
  background-color: #FF6699 !important;
  color: black;
}

/** 治療終了 */
.status-list-page >>> .dialysis-state-td-4,
.status-list-page >>> .dialysis-state-td-5 {
  color: #fff !important;
  background-color: #557769 !important;
}
/** 実績確定 */
.status-list-page >>> .dialysis-state-td-6 {
  color: #fff !important;
  background-color: rgb(0, 26, 0) !important;
}
/** 最新愁訴/処置 */
.status-list-page >>> .comp-treat-td {
  white-space: pre-wrap;
}

.legend {
  margin-left: 10px;
  margin-top: 5px;
  color: var(--ntss-list-body-color);
}
.legend .color {
  width: 20px;
  height: 20px;
  margin-right: 0.2em;
}
.d-flex {
  margin-right: 1em;
}

/* 凡例 */
#area_usage_guide {
  flex-shrink: 0;
  display: flex;
  flex-wrap: wrap;
  color: var(--ntss-list-body-color);
  margin: 2px 5px 2px 5px;
}

.usage-guide-div {
  margin-right: 1em;
  display: flex;
}

.usage-guide-element {
  width: 1em;
  height: 1em;
  margin-top: 0.2em;
}

.status-list-page >>> .change-fontcolor-td-1 {
  color: #FFA500 !important;
}
/* add FNSI-項目表示制御の修正 徐 start */
.status-list-page >>> .un-use {
  background-color: rgb(174, 170, 170) !important;
}
/* add FNSI-項目表示制御の修正 徐 start */

.status-list-page >>> .k-grid-header {
  /* padding: 0 !important; */
  background: var(--ntss-list-header-background-color);
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  /* add #6716 横スクロールするとレイアウトが崩れる xiaosonglei start*/
  padding-right: 1.5rem;
  /* add #6716 横スクロールするとレイアウトが崩れる xiaosonglei end*/
}

.status-list-page >>> .k-header {
  border: solid var(--ntss-list-border-color);
  border-width: 0 1px 1px 0;
}

/* 回診状態_強調表示：オレンジ */
.status-list-page >>> .round-state-td-highlighting-1 {
  color: #FFA500 !important;
}

/* 回診状態_強調表示：赤 */
.status-list-page >>> .round-state-td-highlighting-2 {
  color: #FF3366 !important;
}

/* 印刷用の警報報知アイコン非表示 */
.status-list-page >>> .static-icon {
  display: none;
}
@media print {
  /** スクロールコンテナ */
  #device-grid-area >>> .k-grid-header-wrap,
  #device-grid-area >>> .k-grid-content,
  #main-list-grid-box >>> .k-grid-header-wrap,
  #main-list-grid-box >>> .k-grid-content {
    overflow: hidden !important;
    height: auto !important;
  }
  /** ヘッダのズレ原因を除去 */
  #device-grid-area >>> .k-grid-header,
  #main-list-grid-box >>> .k-grid-header {
    padding-right: 0 !important;
    position: relative;
  }
  /** スクロール要素の幅 */
  #device-grid-area >>> .k-grid,
  #main-list-grid-box >>> .k-grid {
    width: 100vw !important;
    display: block !important;
  }
  #device-grid-area >>> table,
  #main-list-grid-box >>> table {
    display: inline-table;
  }
  /** 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  #device-grid-area >>> table.scroll-rightmost,
  #main-list-grid-box >>> table.scroll-rightmost {
    position: relative !important;
    float: right;
  }
  
  /** 透析装置 凡例 位置調整 */
  #main-list-grid-box >>> .k-grid-content > .k-height-container > div  {
    height: 0 !important;
  }
  #area_usage_guide {
    position: relative;
    top: 3.2rem;
  }
  
  /** 警報報知アイコンを静的画像に差替え */
  .status-list-page >>> .gif-icon {
    display: none;
  }
  .status-list-page >>> .static-icon {
    display: inline-block;
  }
}
/* 横向き印刷 */
@media print and (orientation: landscape) {
  #area_usage_guide {
    top: 2.5rem;
  }
}
</style>
