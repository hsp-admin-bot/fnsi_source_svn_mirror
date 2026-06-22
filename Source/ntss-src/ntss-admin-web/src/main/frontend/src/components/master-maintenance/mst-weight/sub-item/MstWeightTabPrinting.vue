/**
 * 印字タブ画面
 */
<template>
  <div class="ntss-send-condition-text">
    <div class="center">
      <div class="print-tabs" id="segment" ref="segmentBtnArea">
        <input id="print_seg_0" type="radio" name="print_seg" :checked="selectedSegmentId === 0" @change="onSegmentClick(0)" />
        <label class="print-tab-item" for="print_seg_0">前体重</label>
        <input id="print_seg_1" type="radio" name="print_seg" :checked="selectedSegmentId === 1" @change="onSegmentClick(1)" />
        <label class="print-tab-item" for="print_seg_1">後体重</label>
        <template v-if="!isScaleBed">
          <input id="print_seg_2" type="radio" name="print_seg" :checked="selectedSegmentId === 2" @change="onSegmentClick(2)" />
          <label class="print-tab-item" for="print_seg_2">スケジュールなし</label>
        </template>
        <input id="print_seg_3" type="radio" name="print_seg" :checked="selectedSegmentId === 3" @change="onSegmentClick(3)" />
        <label class="print-tab-item" for="print_seg_3">患者未登録</label>
      </div>
    </div>
    <div class="vertical-div">
      <div class="header-btn-area right" ref="headerBtnArea">
        <v-ons-button
          modifier="outline"
          class="btn3-normal toolbar-btn"
          style="float: left;"
          v-show="true"
          @click="addRow()"
        >追加</v-ons-button>
      </div>
      <div class="setting-items" >
        <table class="ntss-list ntss-list-mst-weight-print " :height="gridHeight">
          <thead>
            <tr>
<!--              mod FNSI-改修内容：体重マスター＞詳細ー＞印字ー＞前体重 タイトルと行を被ってる現象 liang start-->
<!--              <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 3 + 'em' }">表示順</th>-->
<!--              <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 4 + 'em' }">カテゴリ</th>-->
<!--              <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 6 + 'em' }">印字項目</th>-->
<!--              <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 6 + 'em' }">文字サイズ</th>-->
<!--              <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 6 + 'em' }">前表示文字</th>-->
<!--              <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 10 + 'em'}">データ書式</th>-->
<!--              <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 6 + 'em' }">後表示文字</th>-->
                  <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 1 + 'em' , 'z-index': 2}">表示順</th>
                  <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 8 + 'em' , 'z-index': 2}">カテゴリ</th>
                  <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 12.5 + 'em' , 'z-index': 2}">印字項目</th>
                  <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 2 + 'em' , 'z-index': 2}">文字サイズ</th>
                  <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 12 + 'em' , 'z-index': 2}">前表示文字</th>
                  <!-- mod FNSI-データ書式の修正 徐 start -->
                  <!-- <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 17 + 'em', 'z-index': 2 }">データ書式</th> -->
                  <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 20 + 'em', 'z-index': 2 }">データ書式</th>
                  <!-- mod FNSI-データ書式の修正 徐 end -->
                  <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 13 + 'em' , 'z-index': 2}">後表示文字</th>
<!--              mod FNSI-改修内容：体重マスター＞詳細ー＞印字ー＞前体重 タイトルと行を被ってる現象 liang end-->
              <th class="ntss-list-header-th-sticky" :style="{ 'min-width': 3 + 'em', 'z-index': 2 }"/>
            </tr>
          </thead>
          <tbody>
          <tr v-for="(dispData, idx) in dispDataList" :key="idx" style="height: 1.1rem;">
            <td class="ntss-list-body-td">
              <custom-input-number
                class="scale-input number-input"
                :value="dispData.disp_order"
                :digits="3"
                :min-value="1"
                :max-value="999"
                @focus="editStart"
                @blur="onChangeSort(); editEnd() "
                @change="saveEditRecord"
              />
            </td>
            <td class="ntss-list-body-td">
              <custom-select
                class="scale-input"
                :value="dispData.item_source"
                :options="itemSourceList"
                @change="onItemSourceChange(dispData),saveEditRecord()"
              />
            </td>
            <td class="ntss-list-body-td">
              <custom-select
                v-if="dispData.item_source.editValue === itemSourceValue.preset"
                class="scale-input"
                :value="dispData.item_cd"
                :options="presetPrintItemList"
                @change="onPrintItemCdChange(dispData),saveEditRecord()"
              />
              <custom-select
                v-else-if="dispData.item_source.editValue === itemSourceValue.exam"
                class="scale-input"
                :value="dispData.item_cd"
                :options="examItemList"
                @change="onExamItemIdChange(dispData),saveEditRecord()"
              />
              <custom-select
                v-else-if="dispData.item_source.editValue === itemSourceValue.check"
                class="scale-input"
                :value="dispData.item_cd"
                :options="checkItemList"
                @change="onCheckItemIdChange(dispData),saveEditRecord()"
              />
              <!-- FNSI-add redmine4656 徐 start -->
              <div v-show="dispData.item_source.editValue === itemSourceValue.exam" style="vertical-align: -webkit-baseline-middle">
                <v-ons-radio
                  v-model="dispData.exam_class.editValue"
                  :name="'radio-group' + idx"
                  :value="'1'"
                  modifier="round"
                  @change="saveEditRecord()"
                  :input-id="'radio-enable-' + idx"
                />
                <label :for="'radio-enable-' + idx" class="item-label">透析前</label>
                <v-ons-radio
                  v-model="dispData.exam_class.editValue"
                  :name="'radio-group' + idx"
                  :value="'2'"
                  modifier="round"
                  @change="saveEditRecord()"
                  :input-id="'radio-enable-' + idx"
                />
                <label :for="'radio-enable-' + idx" class="item-label">透析後</label>
                <v-ons-radio
                  v-model="dispData.exam_class.editValue"
                  :name="'radio-group' + idx"
                  :value="'0'"
                  modifier="round"
                  @change="saveEditRecord()"
                  :input-id="'radio-enable-' + idx"
                />
                <label :for="'radio-enable-' + idx" class="item-label">その他</label>
              </div>
              <!-- FNSI-add redmine4656 徐 end -->
            </td>
            <td class="ntss-list-body-td">
              <custom-select
                class="scale-input number-input"
                style="width:auto"
                :value="dispData.font_size"
                :options="fontSizeList"
                @change="saveEditRecord"
              />
            </td>
            <template v-if="isBlankRow(dispData) || isSheetCut(dispData) || isBarCode(dispData)">
              <!-- 設定変更不可 -->
              <td class="ntss-list-body-td" colspan="3" />
            </template>
            <template v-else-if="isFreeText(dispData) || isLineText(dispData)">
              <!-- フリーテキスト -->
              <td class="ntss-list-body-td" colspan="3">
                <custom-input
                  class="scale-input"
                  :value="dispData.before_word"
                  @focus="editStart"
                  @blur="editEnd"
                  @change="saveEditRecord"
                />
              </td>
            </template>
            <template v-else>
              <td class="ntss-list-body-td">
                <custom-input
                  class="scale-input"
                  :value="dispData.before_word"
                  @focus="editStart"
                  @blur="editEnd"
                  @change="saveEditRecord"
                />
              </td>
              <td
                class="ntss-list-body-td horizontal-div"
                v-if="dispData.data_type.editValue === 0"
              >
                <div class="vertical-div">
                  <label>整数桁</label>
                  <custom-input-number
                    class="scale-input number-input"
                    :value="dispData.integerPoint"
                    :digits="2"
                    :min-value="1"
                    :max-value="10"
                    @focus="editStart"
                    @blur="editEnd"
                    @change="onNumberFormatChange(dispData); saveEditRecord();"
                  />
                </div>
                <div class="vertical-div">
                  <label>小数桁</label>
                  <custom-input-number
                    class="scale-input number-input"
                    :value="dispData.decimalPoint"
                    :digits="2"
                    :min-value="1"
                    :max-value="10"
                    @focus="editStart"
                    @blur="editEnd"
                    @change="onNumberFormatChange(dispData); saveEditRecord();"
                  />
                </div>
              </td>
              <td class="ntss-list-body-td" v-else-if="dispData.data_type.editValue === 1">
                <label>日付書式</label>
                <custom-input
                  class="scale-input"
                  :value="dispData.data_format"
                  @focus="editStart"
                  @blur="editEnd"
                  @change="saveEditRecord"
                />
              </td>
              <td class="ntss-list-body-td" v-else-if="dispData.data_type.editValue === 2">
                <label>{{dispData.data_format.editValue}}</label>
              </td>
              <!-- mod FNSI-データ書式の修正 徐 start -->
              <!-- <td
                class="ntss-list-body-td horizontal-div"
                v-else-if="dispData.data_type.editValue === 3"
              > -->
              <td
                class="ntss-list-body-td"
                v-else-if="dispData.data_type.editValue === 3"
              >
              <!-- mod FNSI-データ書式の修正 徐 end -->
                <!-- del FNSI-データ書式の修正 徐 start -->
                <!-- <div class="vertical-div"> -->
                <!-- del FNSI-データ書式の修正 徐 end -->
                  <label>日付書式</label>
                  <custom-input
                    class="scale-input"
                    :value="dispData.data_format"
                    @focus="editStart"
                    @blur="editEnd"
                    @change="saveEditRecord"
                  />
                <!-- del FNSI-データ書式の修正 徐 start -->
                <!-- </div> -->
                <!-- del FNSI-データ書式の修正 徐 end -->
                <!-- mod FNSI-データ書式の修正 徐 start -->
                <!-- <custom-select
                  class="scale-input"
                  :value="dispData.date_position"
                  :options="datePositionList"
                  @change="saveEditRecord()"
                /> -->
                <custom-select
                  class="scale-input"
                  style="vertical-align: top"
                  :value="dispData.date_position"
                  :options="datePositionList"
                  @change="saveEditRecord"
                />
                <!-- mod FNSI-データ書式の修正 徐 end -->
              </td>
              <td class="ntss-list-body-td" v-else></td>
              <td class="ntss-list-body-td">
                <custom-input
                  class="scale-input"
                  :value="dispData.after_word"
                  @focus="editStart"
                  @blur="editEnd"
                  @change="saveEditRecord"
                />
              </td>
            </template>
            <td class="ntss-list-body-td">
              <button class="ntss-btn-outset delete-button" @click="deleteRow(dispData)">
                <v-ons-icon icon="fa-trash"/>
              </button>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import customSelect from "@/components/common/custom-form-tags/CustomSelect";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { getHeaderHeight, getFooterMenuClientHeight, getLatestHeaderElement, getScopedElementById, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import cloneDeep from "@/compat/collections/lodash/cloneDeep";

// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {

  components: {
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "custom-select": customSelect
  },
  data() {
    return {
      editRecordOnComponent: {},
      editSettings: { before: [], after: [], no_schedule: [], no_pat: [] },
      gridHeight: 100,
      tableTop: 100,
      //mod マスタ詳細画面がありません破棄メッセージ 张博 start
      olddispDataList:[],
      giveUpFlg:false,
      //mod マスタ詳細画面がありません破棄メッセージ 张博 end
      //Android端末で編集中であることを示すフラグ
      androidFlg: false,
      editRecordClone: {}
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn"
    }),
    ...mapGetters("mst-weight/print", {
      getColumns: "getColumns",
      getCurrentData: "getCurrentData",
      getSelectedIndex: "getSelectedIndex",
      getCategoryIndex: "getCategoryIndex",
      getPresetPrintItemList: "getPresetPrintItemList",
      getPresetPrintItem: "getPresetPrintItem",
      getExamItemList: "getExamItemList"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("mst-weight", {
      getIsGridEditing: "getIsGridEditing"
    }),
    itemSourceValue() {
      return {
        preset: 0,
        exam: 1,
        check: 2
      };
    },
    itemSourceList() {
      return [
        { value: 0, displayValue: "プリセット" },
        { value: 1, displayValue: "検査結果" },
        { value: 2, displayValue: "チェック項目" }
      ];
    },
    fontSizeList() {
      return [
        { value: 0, displayValue: "小" },
        { value: 1, displayValue: "中" },
        { value: 2, displayValue: "大" }
      ];
    },
    datePositionList() {
      return [
        { value: 0, displayValue: "前" },
        { value: 1, displayValue: "後" }
      ];
    },
    dispDataList() {
      switch (this.getSelectedIndex) {
        case this.getCategoryIndex.before:
          return this.editSettings.before;
        case this.getCategoryIndex.after:
          return this.editSettings.after;
        case this.getCategoryIndex.no_schedule:
          return this.editSettings.no_schedule;
        case this.getCategoryIndex.no_pat:
          return this.editSettings.no_pat;
        default:
          return [];
      }
    },
    // 選択中のモード
    selectedSegmentId: {
      get() {
        return this.getSelectedIndex;
      },
      set() {}
    },
    presetPrintItemList() {
      const list = this.getPresetPrintItemList(this.getSelectedIndex);
      let retList = [];
      for (const iterator of list) {
        retList.push({
          value: iterator.cd,
          displayValue: iterator.item_name
        });
      }
      return retList;
    },
    examItemList() {
      // 検査マスタを返す
      const exam = this.getExamItemList;
      if (!Array.isArray(exam)) {
        return [];
      }
      const list = exam.filter(c => c.category[this.getSelectedIndex]);
      let retList = [];
      for (const iterator of list) {
        retList.push({
          value: iterator.cd,
          displayValue: iterator.item_name
        });
      }
      return retList;
    },
    checkItemList() {
      const check = JSON.parse(this.editRecord.checkContent);
      if (!Array.isArray(check)) {
        return [];
      }
      const list = check.filter(c => c.is_print[this.getSelectedIndex]);
      let retList = [];
      for (const iterator of list) {
        retList.push({
          value: iterator.ctl_no,
          displayValue: iterator.name
        });
      }
      return retList;
    },
    isScaleBed() {
      return this.editRecordClone?.weightType === "1";
    }
  },
  methods: {
    ...mapActions("master-maintenance", [
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty"
    ]),
    ...mapActions("mst-weight/print", [
      "fetchExamItemListByFacilityCd",
      "clearData",
      "setSettingData",
      "changeCurrentData",
      "setCurrentRowData",
      "setCurrentData",
      "setCurrentNewRowData",
      "fetchExamItemList",
      "setExamItemList"
    ]),
    ...mapActions("mst-weight", {
      setIsGridEditing: "setIsGridEditing"
    }),
    async editStart() {
      if (this.androidFlg) {
        await this.setIsGridEditing(true);
      }
    },
    editEnd() {
      this.setIsGridEditing(false);
    },
    isPresetItemIsTarget(src, targetId) {
      if (src.item_source.editValue === this.itemSourceValue.preset) {
        if (src.item_cd.editValue === targetId) {
          return true;
        }
      }
      return false;
    },
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    passFather(){
      return this.giveUpFlg;
    },
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    isBlankRow(src) {
      // 空行
      return this.isPresetItemIsTarget(src, 0);
    },
    isFreeText(src) {
      // フリーテキスト
      return this.isPresetItemIsTarget(src, 28);
    },
    isLineText(src) {
      // 罫線
      return this.isPresetItemIsTarget(src, 29);
    },
    isSheetCut(src) {
      // 用紙カット
      return this.isPresetItemIsTarget(src, 34);
    },
    isBarCode(src) {
      // バーコード
      return (
        this.isPresetItemIsTarget(src, 30) || this.isPresetItemIsTarget(src, 31)
      );
    },
    onItemSourceChange(src) {
      // カテゴリ変更時はいろいろリセットする
      src.item_cd.editValue = -1;
      src.font_size.editValue = 1;
      src.data_type.editValue = 2;
      src.data_format.editValue = "";
      src.before_word.editValue = "";
      src.after_word.editValue = "";
      src.calculate.editValue = "";
      src.date_position.editValue = 0;
      src.integerPoint.editValue = null;
      src.decimalPoint.editValue = null;
    },
    onPrintItemCdChange(src) {
      // 印字項目変更時
      if (src.item_cd < 0) {
        return;
      }
      const target = this.getPresetPrintItem(src.item_cd.editValue);
      src.data_type.editValue = target.data_type;
      src.data_format.editValue = target.default_format;
      src.before_word.editValue = target.default_before_word;
      src.after_word.editValue = target.default_after_word;
      src.calculate.editValue = "";
      src.date_position.editValue = 0;
      src.integerPoint.editValue = null;
      src.decimalPoint.editValue = null;
      if (target.data_type === 0) {
        const fmt = target.default_format.split(".");
        src.integerPoint.editValue = Number(fmt[0]);
        src.decimalPoint.editValue = Number(fmt[1]);
      }
    },
    onExamItemIdChange(src) {
      if (src.item_cd < 0) {
        return;
      }
      // 検査結果選択
      const exam = this.getExamItemList;
      const target = exam.find(c => c.cd === src.item_cd.editValue);
      src.data_type.editValue = target.data_type;
      src.data_format.editValue = target.default_format;
      // FNSI-add redmine4656 徐 start
      src.exam_class.editValue = "1";
      // FNSI-add redmine4656 徐 end
      src.before_word.editValue = target.default_before_word;
      src.after_word.editValue = target.default_after_word;
      src.calculate.editValue = null;
      src.date_position.editValue = target.date_position;
      src.integerPoint.editValue = null;
      src.decimalPoint.editValue = null;

    },
    onCheckItemIdChange(src) {
      if (src.item_cd < 0) {
        return;
      }
      // チェック設定から印字項目変更時
      const check = JSON.parse(this.editRecord.checkContent);
      const target = check.find(c => c.ctl_no === src.item_cd.editValue);
      src.data_type.editValue = target.print_datatype;
      src.data_format.editValue = target.print_default_format;
      src.before_word.editValue = target.before_word;
      src.after_word.editValue = target.after_word;
      src.calculate.editValue = target.calculate;
      src.date_position.editValue = 0;
      src.integerPoint.editValue = null;
      src.decimalPoint.editValue = null;
      if (target.print_datatype === 0) {
        const fmt = target.print_default_format.split(".");
        src.integerPoint.editValue = Number(fmt[0]);
        src.decimalPoint.editValue = Number(fmt[1]);
      }
    },
    onNumberFormatChange(src) {
      src.data_format.editValue = `${src.integerPoint.editValue}.${src.decimalPoint.editValue}`;
    },
    // 項目削除
    deleteRow(row) {
      let item = this.dispDataList;
      if (item !== null) {
        const idx = item.findIndex(
          d => d.ctl_no.editValue === row.ctl_no.editValue
        );
        item.splice(idx, 1);
      }
      this.saveEditRecord();
    },
    onChangeSort() {
      switch (this.getSelectedIndex) {
        case this.getCategoryIndex.before:
          this.editSettings.before = this.sortDispDataByDispOrder(
            this.editSettings.before
          );
          break;
        case this.getCategoryIndex.after:
          this.editSettings.after = this.sortDispDataByDispOrder(
            this.editSettings.after
          );
          break;
        case this.getCategoryIndex.no_schedule:
          this.editSettings.no_schedule = this.sortDispDataByDispOrder(
            this.editSettings.no_schedule
          );
          break;
        case this.getCategoryIndex.no_pat:
          this.editSettings.no_pat = this.sortDispDataByDispOrder(
            this.editSettings.no_pat
          );
          break;
      }
      this.saveEditRecord();
    },
    // 項目追加
    addRow() {
      let item = this.dispDataList;
      if (item !== null) {
        const newId = this.getMaxID(item);
        const newDispNo = this.getMaxDispNo(item);
        item.push({
          ctl_no: { initValue: null, editValue: newId },
          disp_order: { initValue: null, editValue: newDispNo },
          item_source: { initValue: null, editValue: 0 },
          item_cd: { initValue: null, editValue: 0 },
          font_size: { initValue: null, editValue: 1 },
          data_type: { initValue: null, editValue: 2 },
          data_format: { initValue: null, editValue: "" },
          before_word: { initValue: null, editValue: "" },
          after_word: { initValue: null, editValue: "" },
          calculate: { initValue: null, editValue: "" },
          date_position: { initValue: null, editValue: 0 },
          integerPoint: { initValue: null, editValue: null },
          decimalPoint: { initValue: null, editValue: null },
          // FNSI-add redmine4656 徐 start
          exam_class: { initValue: null, editValue: null },
          // FNSI-add redmine4656 徐 end
        });
      }
      this.saveEditRecord();
    },
    // idの最大値取得
    getMaxID(list) {
      let rID = 0;
      for (let i = 0; i < list.length; i++) {
        if (rID < list[i].ctl_no.editValue) {
          rID = list[i].ctl_no.editValue;
        }
      }
      return rID + 1;
    },
    // disp_orderの最大値取得
    getMaxDispNo(list) {
      let rNo = 0;
      for (let i = 0; i < list.length; i++) {
        if (rNo < list[i].disp_order.editValue) {
          rNo = list[i].disp_order.editValue;
        }
      }
      return rNo + 1;
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.getIsGridEditing) {
        const wh = this.windowHeight;
        const hh = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
        const th = Array.prototype.slice
          .call(queryScopedSelectorAll(".tab_item", this.$el || this))
          .shift().offsetHeight;
        const segmentBtnAreaEl = this.$refs.segmentBtnArea;
        const segmentBtnAreaHeight = segmentBtnAreaEl ? segmentBtnAreaEl.offsetHeight : 0;
        const headerBtnAreaEl = this.$refs.headerBtnArea;
        const headerBtnAreaHeight = headerBtnAreaEl ? headerBtnAreaEl.offsetHeight : 0;
        const gfh = getScopedElementById("detail-footer", this.$el || this).offsetHeight;
        const fmh =
          this.isDispMenu === 1
            ? getFooterMenuClientHeight(this.$el || null)
            : 0;

        // ntssListの高さ設定(ウィンドウ高さ－ヘッダー高さ－タブ高さ－セグメントボタンエリア高さ－追加ボタンエリア高さ－メニューバー高さ－確定/キャンセルボタンエリア高さ)
        this.gridHeight = wh - hh - th - segmentBtnAreaHeight - headerBtnAreaHeight - gfh - fmh;

        // ntssListのheader行高とbody行高を取得(ただし、body行高が行毎に可変の場合は対応できない。あくまで目安高。)
        const firstTh = this.$el.querySelector('.ntss-list-mst-weight-print thead tr');
        const thHeight = firstTh ? firstTh.offsetHeight : 0;
        const firstTd = this.$el.querySelector('.ntss-list-mst-weight-print tbody tr');
        const tdHeight = firstTd ? firstTd.offsetHeight : 0;
        // ntssList最低5行分の高さ＝header高さ＋5行分の高さ＋横スクロールの高さ目安17px
        const gridMinHeight = thHeight + (tdHeight * 5) + 17;

        // ntssListの高さが最低5行分より小さいか(ウィンドウ高が極端に小さいや文字サイズ特大の場合等に起こりえる)
        if (this.gridHeight < gridMinHeight) {
          // 最低5行分の高さをntssListの高さに設定
          this.gridHeight = gridMinHeight;
        }
      }
    },
    /**
     * タブ切り替え時、表示内容を切り替える
     */
    onSegmentClick(selectedId) {
      const currentId = this.selectedSegmentId;
      //入力項目のチェック
      if (!this.validateOnRegistration()) {
        this.setSegmentClickBackColor(currentId);
        this.changeCurrentData(currentId);
        return;
      }
      // 選択中のタブがクリックされた場合は処理しない
      if (selectedId != currentId) {
        // 表示データの切り替え
        this.setSegmentClickBackColor(selectedId);
        this.changeCurrentData(selectedId);
      }
    },
    /**
     * タブ切り替え時、アクティブボタンの設定
     */
    setSegmentClickBackColor(index) {
      const el = this.$el?.querySelector?.(`#print_seg_${index}`);
      if (el) {
        el.checked = true;
      }
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
            if (
              data.disp_order.editValue < bufData.disp_order.editValue &&
              !isPushed
            ) {
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
    // 初期データを編集用にコピー
    initDispEditSettingData(jsonData) {
      for (const key in jsonData) {
        if (Object.prototype.hasOwnProperty.call(jsonData, key)) {
          for (const row of jsonData[key]) {
            let integerPoint = 0;
            let decimalPoint = 0;
            if (row.data_type === 0) {
              const fmt = row.data_format.split(".");
              integerPoint = Number(fmt[0]);
              decimalPoint = Number(fmt[1]);
            }
            this.editSettings[key].push({
              ctl_no: { initValue: row.ctl_no, editValue: row.ctl_no },
              disp_order: {
                initValue: row.disp_order,
                editValue: row.disp_order
              },
              item_source: {
                initValue: row.item_source,
                editValue: row.item_source
              },
              item_cd: { initValue: row.item_cd, editValue: row.item_cd },
              font_size: { initValue: row.font_size, editValue: row.font_size },
              data_type: { initValue: row.data_type, editValue: row.data_type },
              data_format: {
                initValue: row.data_format,
                editValue: row.data_format
              },
              before_word: {
                initValue: row.before_word,
                editValue: row.before_word
              },
              after_word: {
                initValue: row.after_word,
                editValue: row.after_word
              },
              calculate: { initValue: row.calculate, editValue: row.calculate },
              date_position: {
                initValue: row.date_position,
                editValue: row.date_position
              },
              integerPoint: {
                initValue: integerPoint,
                editValue: integerPoint
              },
              decimalPoint: { initValue: decimalPoint, editValue: decimalPoint },
              // FNSI-add redmine4656 徐 start
              exam_class: {
                initValue: row.exam_class ? row.exam_class : "1",
                editValue: row.exam_class ? row.exam_class : "1"
              },
              // FNSI-add redmine4656 徐 end
            });
          }
        }
      }
    },
    /* ストアに登録する */
    setDispSettingData(editRecord) {
      let jsonData = {};
      jsonData = JSON.parse(editRecord.printSetting);

      // JSONオブジェクトを表示順でソート
      jsonData.before = this.sortDispDataByDispOrder(jsonData.before);
      jsonData.after = this.sortDispDataByDispOrder(jsonData.after);
      jsonData.no_schedule = this.sortDispDataByDispOrder(jsonData.no_schedule);
      jsonData.no_pat = this.sortDispDataByDispOrder(jsonData.no_pat);

      this.setSettingData(jsonData);
      this.initDispEditSettingData(jsonData);
    },
    saveEditRecord() {
      let jsonRecord = { before: [], after: [], no_schedule: [], no_pat: [] };
      for (const key in this.editSettings) {
        if (Object.prototype.hasOwnProperty.call(this.editSettings, key)) {
          for (const row of this.editSettings[key]) {
            const item = {
              ctl_no: row.ctl_no.editValue,
              disp_order: row.disp_order.editValue,
              item_source: row.item_source.editValue,
              item_cd: row.item_cd.editValue,
              font_size: row.font_size.editValue,
              data_type: row.data_type.editValue,
              // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
              // data_format: row.data_format.editValue,
              // before_word: row.before_word.editValue,
              data_format: row.data_format.editValue === null ? "" : row.data_format.editValue,
              before_word: row.before_word.editValue === null ? "" : row.before_word.editValue,
              // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
              // FNSI-add nullを""に修正する 徐 start
              // after_word: row.after_word.editValue,
              after_word: row.after_word.editValue === null ? "" : row.after_word.editValue,
              // FNSI-add nullを""に修正する 徐 end
              calculate: row.calculate.editValue,
              date_position: row.date_position.editValue,
              exam_class: row.exam_class.editValue || '1'
            };
            jsonRecord[key].push(item);
          }
        }
      }
      this.updateEditRecord("printSetting", JSON.stringify(jsonRecord));
    },
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },
    updateWidget() {
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    },
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        this.saveEditRecord();
        return true;
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES["00200107"].title;
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.unselectedPrintItem
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "印刷項目が未選択です。<br>"
              ? messageFormat(DIALOG_MESSAGES["00200107"].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    },
    /**
     * 入力データの検証チェック
     */
    validateData() {
      let unselectedPrintItem = true;
      for (let idx = 0; idx < 3; idx++) {
        let dispDataList = [];
        switch (idx) {
          case this.getCategoryIndex.before:
            dispDataList = this.editSettings.before;
            break;
          case this.getCategoryIndex.after:
            dispDataList = this.editSettings.after;
            break;
          case this.getCategoryIndex.no_schedule:
            dispDataList = this.editSettings.no_schedule;
            break;
          case this.getCategoryIndex.no_pat:
            dispDataList = this.editSettings.no_pat;
            break;
          default:
            dispDataList = [];
        }
        for (const item of dispDataList) {
          if (
            item.item_source.editValue === 1 ||
            item.item_source.editValue === 2
          ) {
            if (
              item.item_cd.editValue < 0 ||
              item.item_cd.editValue === undefined
            ) {
              unselectedPrintItem = false;
            }
          }
        }
      }
      return {
        unselectedPrintItem: unselectedPrintItem
      };
    }
  },
  watch: {
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    dispDataList:{
      handler(newdispData){
        if (JSON.stringify(newdispData) !== this.olddispDataList) {
                 this.giveUpFlg =true
        }else{
                 this.giveUpFlg =false
        }
      },
      deep:true
    },
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    windowHeight() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    }
  },
  created() {
    // 親画面から設定JSONデータ取得
    this.editRecordOnComponent = JSON.parse(this.editRecord.printSetting);
    this.setDispSettingData(this.editRecord);
    // 端末判別
    if (((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").match(/Android/)) {
      this.androidFlg = true;
    }
    // 検査マスタ取得
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // this.fetchExamItemList().then(res => {
    //   this.setExamItemList(res.data);
    // });
    this.fetchExamItemListByFacilityCd(this.getFacilitySwitch).then(res => {
      this.setExamItemList(res.data);
    });
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
  },
  mounted() {
    // 起動時は前体重測定のデータを表示する
    this.changeCurrentData(0);
    // Gridの高さを調整する
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    this.olddispDataList=JSON.stringify(this.dispDataList)
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    this.editRecordClone = cloneDeep(this.editRecord);
  },
  unmounted() {
    this.clearData();
  }
};
</script>
<style scoped>
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}
/* [印字タブ] メニューボタングループ*/
.center {
  text-align: center;
}
.segment-button {
  width: 100%;
  padding: 5px 0 0 0;
}
.print-button {
  width: 160px;
  margin: 10px;
  border-radius: 10px 10px 10px 10px;
}
/* [印字タブ] メニューボタン：クリックしたとき色変える*/
.buttonGroup input[type="radio"]:checked + label {
  background-color: #277bfa;
}
/* [印字タブ] 設定項目 */
.setting-items {
  overflow: auto;
}

/* [印字タブ] グリッド */
.row-style {
  min-width: 1000px;
  font-size: 1.5em;
  text-align: center;
}
/* [印字タブ] 削除ボタン */
.delete-button {
  display: block;
  margin: auto;
}
/* [印字タブ] 入力要素 */
.input-item {
  margin: 0px 5px 0px 5px;
}
/* [印字タブ] 印刷プレビューボタン */
.btn-area {
  display: flex;
  justify-content: space-between;
  left: 8px;
  bottom: 3px;
  flex-basis: 80%;
}
/* mod FNSI-改修内容：体重マスター＞詳細ー＞印字ー＞前体重 数据展示问题 liang start-->*/
/*.ntss-list-mst-weight-print {*/
/*  overflow: auto;*/
/*  display: block;*/
/*  font-size: 1em;*/
/*  position: relative;*/
/*  background-color: inherit;*/
/*}*/

.ntss-list-mst-weight-print {
  overflow: auto;
  display: block;
  font-size: 1em;
  position: relative;
  background-color: inherit;
}
/*mod FNSI-改修内容：体重マスター＞詳細ー＞印字ー＞前体重 数据展示问题 liang end--> */
.right {
  text-align: right;
}
.header-btn-area {
  height: 2em;
  padding: 0.3em 0 calc(0.1em + 2px); /* 他タブとボタンの位置合わせ(gridがborder-top:noneの影響で位置がずれる) */
}
.toolbar-btn {
  font-size: 1em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}

.number-input {
  width: 3em;
  margin-right: 2px;
}

.scale-input {
  font-size: 1em;
  text-align: left;
}
.horizontal-div {
  display: flex;
  flex-direction: row;
}
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}

/* [印字タブ] サブタブ全体 */
.print-tabs {
  margin-top: 10px;
  width: 100%;
  overflow: hidden;
}

/* [印字タブ] サブタブ各タブ */
.print-tab-item {
  width: calc(100% / 4);
  height: 30px;
  border-bottom: 3px solid #5ab4bd;
  background-color: #d9d9d9;
  line-height: 30px;
  text-align: center;
  color: #565656;
  display: block;
  float: left;
  font-weight: bold;
  transition: all 0.2s ease;
  cursor: pointer;
}

.print-tab-item:hover {
  opacity: 0.75;
}

input[name="print_seg"] {
  display: none;
}

.print-tabs input:checked + .print-tab-item {
  background-color: #2a8bc4;
  color: #fff;
}
</style>
