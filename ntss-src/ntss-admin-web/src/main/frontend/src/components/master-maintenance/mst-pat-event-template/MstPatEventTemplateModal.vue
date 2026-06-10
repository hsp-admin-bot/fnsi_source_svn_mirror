<template>
  <div class="main-area-removeoverflow">
    <div class="disp-item-area wrap-block">
      <label class="item-title-header">名称</label>
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start -->
      <!-- <v-ons-input
        class="pat-event-input custom-input-required"
        @input="setCss($event.target.value)"
        :value="inputModel.name"
        maxlength="20"
        @blur="setTemplateName($event.target.value)"
        @change="changeButton()"
      /> -->
      <v-ons-input
        class="pat-event-input custom-input-required"
        @input="setCss($event.target.value)"
        :value="inputModel.name"
        maxlength="20"
        @blur="setTemplateName($event.target.value)"
      />
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end -->
      <v-ons-button class="btn3-normal button-add" @click="addRow()">フィールド追加</v-ons-button>
      <p>&nbsp;</p>
      <v-ons-button class="btn3-normal button-sort" @click="switchActionMode()">並び替え</v-ons-button>
    </div>
    <table class="disp-item-area">
      <div class="disp-item-content-frame print-height-auto" :style="heightStyles">
        <div class="disp-item-content-area print-height-auto" :style="heightStylesArea">
          <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240116 linjunfeng start  -->
          <!-- <draggable
            :options="{
            animation: 250,
            forceFallback: true,
            disabled: !actionMode,
          }"
            @start="startDragging"
            @end="finishDragging"
          > -->
          <draggable
            v-model="draggableInputParams"
            :options="{
            animation: 250,
            forceFallback: true,
            disabled: !actionMode,
            filter: 'input, select, textarea, .ons-radio, .ons-checkbox',
            preventOnFilter: false,
          }"
            @start="startDragging"
            @end="finishDragging"
            :key="'draggable-' + getInputParams.length"
          >
          <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end  -->
            <div v-for="(json, index) in getInputParams" :key="json._uniqueId || `item-${index}`">
              <table class="card-table" :style="displayStyles(json.format_class)">

                <button
                  v-show="actionMode"
                  class="ntss-btn-outset button-delete"
                  @click="deleteJsonArray(json, index)"
                ><v-ons-icon icon="fa-trash"/></button>
                <div />
                <tr>
                  <td class="item-title">形式名</td>
                  <td>
                    <v-ons-select
                      v-model="json.format_class"
                      @input="onFormatInput(json.format_class,index);
                              onFormatChange($event.target.value,index)"
                    >
                      <option
                        v-for="(item, idx) in getItemFormat"
                        :key="idx"
                        :value="item.formatNo"
                      >{{ item.formatName }}</option>
                    </v-ons-select>
                  </td>
                </tr>
                <!-- mod 楊 start -->
                <!-- <tr v-if="json.format_class < 10"> -->
                <tr v-if="json.format_class !== 10">
                  <td class="item-title">フィールド名</td>
                  <td>
                    <!-- mod #8748 患者イベントテンプレートマスタのフィールド名に文字数制限がある 林峻峰 start -->
                    <!-- <v-ons-input
                      maxlength ="10"
                      :class="'pat-event-input input-required required'+index"
                      :name="'required'+index"
                      :value="json.field_name"
                      @input="setFieldNameCss($event)"
                      @blur="setFieldName($event.target.value, index)"
                      @change="changeButton()"
                    /> -->
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start -->
                    <!-- <v-ons-input
                      maxlength ="100"
                      :class="'pat-event-input input-required required'+index"
                      :name="'required'+index"
                      :value="json.field_name"
                      @input="setFieldNameCss($event)"
                      @blur="setFieldName($event.target.value, index)"
                      @change="changeButton()"
                    /> -->
                    <v-ons-input
                      maxlength ="100"
                      :class="'pat-event-input input-required required'+index"
                      :name="'required'+index"
                      :value="json.field_name"
                      @input="setFieldNameCss($event)"
                      @blur="setFieldName($event.target.value, index)"
                    />
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end -->
                    <!-- mod #8748 患者イベントテンプレートマスタのフィールド名に文字数制限がある 林峻峰 end -->
                  </td>
                </tr>
                <!-- <tr v-if="json.format_class < 10"> -->
                <tr v-if="json.format_class !== 10">
                <!-- mod 楊 end -->
                  <td></td>
                  <td>
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start -->
                    <!-- <ons-checkbox
                      :input-id="'disp-field-' + index"
                      :checked="getIsFieldDisplay(json)"
                      @click="onIsFieldDisplayChange($event, index)"
                      @change="changeButton()"
                    ></ons-checkbox> -->
                    <ons-checkbox
                      :input-id="'disp-field-' + index"
                      :checked="getIsFieldDisplay(json)"
                      @change="onIsFieldDisplayChange($event, index)"
                    ></ons-checkbox>
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end -->
                    <label :for="'disp-field-' + index">フィールド名表示</label>
                  </td>
                </tr>
                <!-- mod 楊 start -->
                <!-- <tr v-if="json.format_class < 9"> -->
                <tr v-if="json.format_class < 9 || json.format_class > 10">
                <!-- mod 楊 end -->
                  <td class="item-title">新規作成時の入力値反映</td>
                  <td>
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start -->
                    <!-- <v-ons-radio
                      :input-id="'copy-rst-0-' + index"
                      value="0"
                      modifier="round"
                      v-model="json.is_rst_copy"
                      @click="onIsRstCopyChange($event, index)"
                      @change="changeButton()"
                    ></v-ons-radio> -->
                    <v-ons-radio
                      :input-id="'copy-rst-0-' + index"
                      value="0"
                      modifier="round"
                      v-model="json.is_rst_copy"
                      @change="onIsRstCopyChange($event, index)"
                    ></v-ons-radio>
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end -->
                    <label :for="'copy-rst-0-' + index">作成する1件目のイベントのみに反映</label>
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start -->
                    <!-- <v-ons-radio
                      :input-id="'copy-rst-1-' + index"
                      value="1"
                      modifier="round"
                      v-model="json.is_rst_copy"
                      @click="onIsRstCopyChange($event, index)"
                      @change="changeButton()"
                    ></v-ons-radio> -->
                    <v-ons-radio
                      :input-id="'copy-rst-1-' + index"
                      value="1"
                      modifier="round"
                      v-model="json.is_rst_copy"
                      @change="onIsRstCopyChange($event, index)"
                    ></v-ons-radio>
                    <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end -->
                    <label :for="'copy-rst-1-' + index">作成するすべてのイベントに反映</label>
                  </td>
                </tr>
                <tr>
                  <td colspan="2">
                    <div v-if="json.format_class == 0" >
                      <component
                        :is="'mst-pat-event-template-text-item'"
                        :props-index="index"
                        keep-alive
                        ref="text"
                      /> 
                    </div>
                    <div v-if="json.format_class == 1">
                      <component
                        :is="'mst-pat-event-template-text-area-item'"
                        :key="index"
                        :props-index="index"
                        keep-alive
                        ref="text"
                      />
                    </div>
                    <div v-else-if="json.format_class == 2">
                      <component
                        :is="'mst-pat-event-template-image-item'"
                        :props-index="index"
                        keep-alive
                        ref="image"
                      />
                    </div>
                    <div v-else-if="json.format_class == 3">
                      <component
                        :is="'mst-pat-event-template-list-item'"
                        :props-index="index"
                        keep-alive
                        ref="list"
                      />
                    </div>
                    <div v-else-if="json.format_class == 4">
                      <component
                        :is="'mst-pat-event-template-radio-item'"
                        :props-index="index"
                        keep-alive
                        ref="radio"
                      />
                    </div>
                    <div v-else-if="json.format_class == 5">
                      <component
                        :is="'mst-pat-event-template-date-item'"
                        :props-index="index"
                        keep-alive
                        ref="date"
                      />
                    </div>
                    <div v-else-if="json.format_class == 6">
                      <component
                        :is="'mst-pat-event-template-check-item'"
                        :props-index="index"
                        keep-alive
                        ref="check"
                      />
                    </div>
                    <div v-else-if="json.format_class == 7">
                      <component
                        :is="'mst-pat-event-template-file-item'"
                        :props-index="index"
                        keep-alive
                        ref="file"
                      />
                    </div>
                    <div v-else-if="json.format_class == 8">
                      <component
                        :is="'mst-pat-event-template-score-calc-item'"
                        :props-index="index"
                        keep-alive
                        ref="calc"
                      />
                    </div>
                    <div v-else-if="json.format_class == 9 "></div>
                    <div v-else-if="json.format_class == 10 ">
                      <component
                        :is="'mst-pat-event-template-bbs-item'"
                        :props-index="index"
                        keep-alive
                        ref="bbs"
                      />
                    </div>
                  </td>
                </tr>
              </table>
            </div>
          </draggable>
        </div>
      </div>
    </table>
  </div>
</template>

<script>
import vuedraggable from "vuedraggable";
import { mapGetters, mapActions } from "vuex";
import { deepCopy } from "@/functions/common/CommonFunctions";
import MstPatEventTemplateTextItem from "@/components/master-maintenance/mst-pat-event-template/sub-item/MstPatEventTemplateText";
import MstPatEventTemplateTextAreaItem from "@/components/master-maintenance/mst-pat-event-template/sub-item/MstPatEventTemplateTextArea";
import MstPatEventTemplateDateItem from "@/components/master-maintenance/mst-pat-event-template/sub-item/MstPatEventTemplateDate";
import MstPatEventTemplateListItem from "@/components/master-maintenance/mst-pat-event-template/sub-item/MstPatEventTemplateList";
import MstPatEventTemplateScoreCalcItem from "@/components/master-maintenance/mst-pat-event-template/sub-item/MstPatEventTemplateScoreCalc";
import MstPatEventTemplateImageItem from "@/components/master-maintenance/mst-pat-event-template/sub-item/MstPatEventTemplateImage";
import MstPatEventTemplateRadioItem from "@/components/master-maintenance/mst-pat-event-template/sub-item/MstPatEventTemplateRadio";
import MstPatEventTemplateCheckItem from "@/components/master-maintenance/mst-pat-event-template/sub-item/MstPatEventTemplateCheck";
import MstPatEventTemplateFileItem from "@/components/master-maintenance/mst-pat-event-template/sub-item/MstPatEventTemplateFile";
import MstPatEventTemplateBbsItem from "@/components/master-maintenance/mst-pat-event-template/sub-item/MstPatEventTemplateBbs";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import {EventBus} from "@/eventBus";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import Vue from 'vue';
import CustomInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
// 共通関数
import { isDecimal } from "@/functions/common/NumberFunctions.js";
export default {
  name: "MstPatEventTemplateModal",
  components: {
    "mst-pat-event-template-text-item": MstPatEventTemplateTextItem,
    "mst-pat-event-template-text-area-item": MstPatEventTemplateTextAreaItem,
    "mst-pat-event-template-date-item": MstPatEventTemplateDateItem,
    "mst-pat-event-template-list-item": MstPatEventTemplateListItem,
    "mst-pat-event-template-score-calc-item": MstPatEventTemplateScoreCalcItem,
    "mst-pat-event-template-image-item": MstPatEventTemplateImageItem,
    "mst-pat-event-template-radio-item": MstPatEventTemplateRadioItem,
    "mst-pat-event-template-check-item": MstPatEventTemplateCheckItem,
    "mst-pat-event-template-file-item": MstPatEventTemplateFileItem,
    "mst-pat-event-template-bbs-item": MstPatEventTemplateBbsItem,
    draggable: vuedraggable
  },
  data() {
    return {
      /* mod 楊 start */
      itemFormat: [
        {
          formatNo: 0,
          // formatName: "テキスト"
          formatName: "テキストボックス"
        },
        {
          formatNo: 1,
          formatName: "テキストエリア"
        },
        {
          formatNo: 2,
          formatName: "画像"
        },
        {
          formatNo: 3,
          // formatName: "リスト"
          formatName: "リストボックス"
        },
        {
          formatNo: 4,
          formatName: "ラジオボタン"
        },
        {
          formatNo: 6,
          // formatName: "チェック"
          formatName: "チェックボックス"
        },
        {
          formatNo: 5,
          formatName: "日付"
        },
        {
          formatNo: 7,
          formatName: "添付ファイル"
        },
        {
          formatNo: 8,
          formatName: "スコア計算"
          // TODO: それぞれ実績入力が対応したらコメントアウトを戻す
        },
        {
          formatNo: 9,
          formatName: "治療実績リンク"
        },
        {
          formatNo: 10,
          formatName: "掲示板リンク"
        }
        /* mod 楊 end */
      ],
      initName:"",
      initGetInputParams:"",
      inputModel: {
        code: 0,
        name: "",
        inputParams: [],
        facilityCd: "",
        isDisp: "",
        isDel: ""
      },
      saveInputModel: {
        code: 0,
        name: "",
        inputParams: [],
        facilityCd: "",
        isDisp: "",
        isDel: ""
      },
      dispIsDisp: false,
      dispIsDel: false,
      actionMode: false,
      contentsAreaHeight: 200,
      //カテゴリをドラッグしているかのフラグ
      isDraggingCategory: false,
      selectedPreDoctor: "1",
      dataErrList: [],
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start
      inputModelDefault: [],
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end
    };
  },

  computed: {
    ...mapGetters("user", {
      facilityCd: "getFacilityCd",
      advancedSettings: "getAdvancedSettings"
    }),
    ...mapGetters("master-maintenance", {
      getFacilitySwitchAdvancedSettings: "getFacilitySwitchAdvancedSettings",
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("mst-pat-event-template", {
      getInputParams: "getInputParams",
      getListScore: "getListScore"
    }),
    //add 4756 下部が余白になる 鞠 start
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize"
    }),
    //add 4756 下部が余白になる 鞠 end
    getItemFormat() {
      const isScoreCalc = this.getIsScoreCalc;
      // 施設設定-拡張設定-スコア計算が"ON"の場合のみ表示する
      let newList = this.itemFormat;
      if (!isScoreCalc) {
        newList = newList.filter(v => v.formatNo !== 8);
      }
      return newList;
    },
    getIsScoreCalc() {
      // mod マスタ一覧 1･施設切替を可能とする 孔s start
      // return this.advancedSettings.func_advcds.some(
      //   setting => setting.func_advcd === ADVANCED_SETTINGS.PATEVENT_SCORE_CALC
      // );
      return this.getFacilitySwitchAdvancedSettings.some(
        setting => setting === ADVANCED_SETTINGS.PATEVENT_SCORE_CALC
      );
      // mod マスタ一覧 1･施設切替を可能とする 孔s end
    },
    /**
     * コンテンツの高さをCSS変数を利用して書き換える
     */
    heightStyles() {
      return { height: `${this.contentsAreaHeight}px` };
    },
    heightStylesArea() {
      return { height: `${this.contentsAreaHeight-2}px` };
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start
    draggableInputParams: {
      get() {
        return this.getInputParams;
      },
      set(value) {
        // vue-draggableによって更新された配列をストアに直接反映
        // データの完全性を確保するために、ディープコピーしたデータを直接使用する
        const clonedValue = JSON.parse(JSON.stringify(value));
        this.setInputParams(JSON.stringify(clonedValue));
        this.inputModel.inputParams = clonedValue;
        this.updateEditRecord("inputParams", JSON.stringify(clonedValue));
      }
    }
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end
  },
  watch: {
    /**
     * ウィンドウサイズが変更された時の処理.
     */
    //[確認]ボタンの状態の変更をトリガーします
    inputModel:{
      handler(newVal){
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start
        // if (this.inputModel.name!==this.initName) {
        //   this.changeButton();
        // }else{
        //   EventBus.$emit("mstHolidayRegistered", true);
        // }
        if (this.compareObjects(this.inputModelDefault, newVal)) {
          EventBus.$emit("mstHolidayRegistered", true);
        }else{
          this.changeButton();
        }
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end
      },
      deep:true,
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start
    getInputParams:{
      handler(newVal){
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start
        // if (JSON.stringify(newVal)!==JSON.stringify(this.initGetInputParams)) {
        //     this.changeButton();
        // }else{
        //   EventBus.$emit("mstHolidayRegistered", true);
        // }
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end
        this.inputModel.inputParams = deepCopy(newVal);
      },
      deep:true
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end
    windowHeight() {
      this.calculateGridHeight();
    },
    //add 4576 下部が余白になる 鞠 start
    getFontSize() {
      this.calculateGridHeight();
    }
    //add 4576 下部が余白になる 鞠 end
  },
  mounted() {
    for (const num in this.columnDefinition) {
      // テンプレートコード
      if (this.columnDefinition[num].field === "code") {
        this.inputModel.code = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // テンプレート名
      if (this.columnDefinition[num].field === "name") {
        this.inputModel.name = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // 項目情報
      if (this.columnDefinition[num].field === "inputParams") {
        this.setInitInputParams(
          this.getValueByField(this.columnDefinition[num].field)
        );
        this.setInputParams(
          this.getValueByField(this.columnDefinition[num].field)
        );
        this.inputModel.inputParams = this.getInputParams;
      }
      // 施設コード
      if (this.columnDefinition[num].field === "facilityCd") {
        this.inputModel.facilityCd = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // 表示フラグ
      if (this.columnDefinition[num].field === "isDisp") {
        this.inputModel.isDisp = this.getValueByField(
          this.columnDefinition[num].field
        );
        if (this.inputModel.isDisp === "1") {
          this.dispIsDisp = true;
        } else if (this.inputModel.isDisp === "0") {
          this.dispIsDisp = false;
        } else {
          // "0"でも"1"でもないなら"0"をセットする
          this.inputModel.isDisp = "0";
          this.dispIsDisp = false;
          this.updateEditRecord("isDisp", "0");
        }
      }
      // 削除フラグ
      if (this.columnDefinition[num].field === "isDel") {
        this.inputModel.isDel = this.getValueByField(
          this.columnDefinition[num].field
        );
        if (this.inputModel.isDel === "1") {
          this.dispIsDel = true;
        } else if (this.inputModel.isDel === "0") {
          this.dispIsDel = false;
        } else {
          // "0"でも"1"でもないなら"0"をセットする
          this.inputModel.isDel = "0";
          this.dispIsDel = false;
          this.updateEditRecord("isDel", "0");
        }
      }
    }
    this.$nextTick(() => {
      this.calculateGridHeight();
      // 既存のデータにユニークIDを追加する
      this.initializeUniqueIds();
    });
    //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
  },
  async created() {
    // add 6850 テキストエリアのデフォルト表示に直前に開いたテンプレートの内容が表示される。 関 start
    for (const num in this.columnDefinition) {
      // テンプレートコード
      if (this.columnDefinition[num].field === "code") {
        this.inputModel.code = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // テンプレート名
      if (this.columnDefinition[num].field === "name") {
        this.inputModel.name = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // 項目情報
      if (this.columnDefinition[num].field === "inputParams") {
        this.setInitInputParams(
          this.getValueByField(this.columnDefinition[num].field)
        );
        this.setInputParams(
          this.getValueByField(this.columnDefinition[num].field)
        );
        this.inputModel.inputParams = this.getInputParams;
      }
      // 施設コード
      if (this.columnDefinition[num].field === "facilityCd") {
        this.inputModel.facilityCd = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // 表示フラグ
      if (this.columnDefinition[num].field === "isDisp") {
        this.inputModel.isDisp = this.getValueByField(
          this.columnDefinition[num].field
        );
        if (this.inputModel.isDisp === "1") {
          this.dispIsDisp = true;
        } else if (this.inputModel.isDisp === "0") {
          this.dispIsDisp = false;
        } else {
          // "0"でも"1"でもないなら"0"をセットする
          this.inputModel.isDisp = "0";
          this.dispIsDisp = false;
          this.updateEditRecord("isDisp", "0");
        }
      }
      // 削除フラグ
      if (this.columnDefinition[num].field === "isDel") {
        this.inputModel.isDel = this.getValueByField(
          this.columnDefinition[num].field
        );
        if (this.inputModel.isDel === "1") {
          this.dispIsDel = true;
        } else if (this.inputModel.isDel === "0") {
          this.dispIsDel = false;
        } else {
          // "0"でも"1"でもないなら"0"をセットする
          this.inputModel.isDel = "0";
          this.dispIsDel = false;
          this.updateEditRecord("isDel", "0");
        }
      }
    }
    this.initName = this.inputModel.name;
    this.initGetInputParams = JSON.parse(JSON.stringify(this.getInputParams));
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start
    this.inputModelDefault = deepCopy(this.inputModel)
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end
    // add 6850 テキストエリアのデフォルト表示に直前に開いたテンプレートの内容が表示される。 関  end
    await this.fetchSysDataSet();
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("mst-pat-event-template", [
      "setInitInputParams",
      "setInputParams",
      "setInputParamsDelete",
      "setInputParamsInsert",
      "setInputParamsParentUpdate",
      "fetchSysDataSet"
    ]),
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start
    compareObjects(obj1, obj2) {

      // 基本型(文字列、数字など)の場合は、そのまま等価比較をします。
      if (!this.isObject(obj1)) {
        return obj1 == obj2;
      }
      // 1つ目のオブジェクトの属性名を全て取得します
      const keys = Object.keys(obj1);
      // 属性を横断して深さを比較します
      for (let key of keys) {
        if (key === "inputParams" || key === 'values') {
          if (obj1[key] && obj2[key] && obj1[key].length !== obj2[key].length) {
            return false;
          }
        }
        if (obj2[key] === undefined) {
          return false;
        }
        if (!this.compareObjects(obj1[key], obj2[key])) {
          return false;
        }
      }
      return true;
    },

    isObject(value) {
      return value && typeof value === 'object';
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end
    getValueByField(field) {
      return this.editRecord[field];
    },

    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },

    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },

    displayStyles(formatClass) {
      if (formatClass === 8 && !this.getIsScoreCalc) {
        return { display: "none" };
      }
      return { display: "table" };
    },

    setCss(value) {
      if(value && document.getElementsByClassName("custom-input-invalid")[0])
      document.getElementsByClassName("custom-input-invalid")[0].classList.remove("custom-input-invalid");
    },
    /**
     * データ項目のユニークIDを初期化するために
     */
    initializeUniqueIds() {
      const inputParams = this.getInputParams;
      let hasUpdate = false;
      inputParams.forEach((item, index) => {
        if (!item._uniqueId) {
          item._uniqueId = `existing_${index}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
          hasUpdate = true;
        }
      });
      if (hasUpdate) {
        this.setInputParams(JSON.stringify(inputParams));
        this.inputModel.inputParams = inputParams;
        this.updateEditRecord("inputParams", JSON.stringify(inputParams));
      }
    },
    setFieldNameCss (e){
      if(e.target.value && document.getElementsByClassName(e.target.name)[0])
      document.getElementsByClassName(e.target.name)[0].classList.remove("input-invalid");
    },
    /**
     * フィールド追加ボタンクリックイベント
     */
    addRow() {
      //[確認]ボタンの状態の変更をトリガーします
      this.changeButton();
      const item = {
        format_class: 0,
        field_name: "",
        is_field_display: "1",
        is_rst_copy: "0",
        item_json: {},
        _uniqueId: `item_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
      };
      this.setInputParamsInsert(item);
      const inputParams = this.getInputParams;
      this.updateEditRecord("inputParams", JSON.stringify(inputParams));
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    },
    /**
     * 並び替えモード切り替え
     */
    switchActionMode() {
      this.actionMode = !this.actionMode;
    },
    /**
     * リスト名(対象フィールド:リストボックス、ラジオボタン、チェックボックス)への入力データの並び替え
     */
    sortListNameInputData() {
      let tempInputModel = deepCopy(this.saveInputModel);
      tempInputModel.inputParams = [];
      this.inputModel.inputParams.forEach(inputModelData => {
        let existsFlg = false;
        this.saveInputModel.inputParams.forEach(saveInputModelData => {
          if(saveInputModelData && inputModelData._uniqueId === saveInputModelData._uniqueId){
            tempInputModel.inputParams.push(saveInputModelData);
            existsFlg = true;
          }
        })
        if(!existsFlg){
          tempInputModel.inputParams.push(null);
        }
      })
      this.saveInputModel.inputParams = tempInputModel.inputParams;
    },
    /**
     * ドラッグを始めた際の処理
     */
    startDragging() {
      //項目を非表示にする
      this.isDraggingCategory = true;
      
      // ドラッグ開始時に保存されていないフィールド名入力をすべて保存する
      // これにより、ドラッグ時のすべてのデータが最新の状態であり、フィールド名の異常な変化を回避することができます
      const fieldNameInputs = document.querySelectorAll('input[name^="required"]');
      fieldNameInputs.forEach((input) => {
        if (document.activeElement === input) {
          // 現在の入力ボックスが編集されている場合は、まずblurイベントをトリガしてデータを保存します
          input.blur();
        }
      });
    },
    /**
     * ドラッグを終えた際の処理
     */
    finishDragging() {
      //項目を表示する
      this.isDraggingCategory = false;
      
      // ドラッグアンドドロップが終了したら、データが同期されていることを確認してください。
      this.$nextTick(() => {
        this.inputModel.inputParams = deepCopy(this.getInputParams);
        this.updateEditRecord("inputParams", JSON.stringify(this.inputModel.inputParams));
      });
      this.sortListNameInputData();
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end
    /**
     * テンプレート名の入力イベント
     */
    setTemplateName(value) {
      this.inputModel.name = value;
      this.updateEditRecord("name", this.inputModel.name);
    },
    /**
     *
     */
    setFieldName(value, index) {
      /* mod 楊 start*/
      const oldInputParams = this.getInputParams[index].field_name;
      this.inputModel.inputParams = this.getInputParams;
      this.inputModel.inputParams[index].field_name = value;
      if([3,4,6].includes(this.inputModel.inputParams[index].format_class)) {
        for (let [num, param] of this.inputModel.inputParams.entries()) {
          if(param.format_class === 8 && oldInputParams!=="") {
            this.inputModel.inputParams[num].item_json.calc = this.inputModel.inputParams[num].item_json.calc.replace(oldInputParams,value)
          }
        }
      }
      /* mod 楊 end*/
      this.setInputParams(JSON.stringify(this.inputModel.inputParams));
      this.updateEditRecord(
        "inputParams",
        JSON.stringify(this.getInputParams)
      );
    },
    /**
     * フィールド名表示表示有無クリックイベント
     */
    onIsFieldDisplayChange(ev, index) {
      this.inputModel.inputParams = this.getInputParams;
      if (ev.target.checked) {
        this.inputModel.inputParams[index].is_field_display = "1";
      } else {
        this.inputModel.inputParams[index].is_field_display = "0";
      }
      this.setInputParams(JSON.stringify(this.inputModel.inputParams));
      this.updateEditRecord(
        "inputParams",
        JSON.stringify(this.inputModel.inputParams)
      );
    },
    /**
     * 実績展開クリックイベント
     */
    onIsRstCopyChange(ev, index) {
      this.inputModel.inputParams = this.getInputParams;
      if (ev.target.value === "1") {
        this.inputModel.inputParams[index].is_rst_copy = "1";
      } else {
        this.inputModel.inputParams[index].is_rst_copy = "0";
      }
      this.setInputParams(JSON.stringify(this.inputModel.inputParams));
      this.updateEditRecord(
        "inputParams",
        JSON.stringify(this.inputModel.inputParams)
      );
    },
    /**
     * 形式コンボボックス選択イベント
     */
    onFormatChange(value, index) {
      //[確認]ボタンの状態の変更をトリガーします
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng start
      // this.changeButton();
      // #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者イベントテンプレートマスタ 20240105 linjunfeng end
      if([3,4,6].includes(this.inputModel.inputParams[index].format_class)){
        this.saveInputModel.inputParams[index] = this.inputModel.inputParams[index];
      }
      this.inputModel.inputParams = this.getInputParams;
      this.inputModel.inputParams[index].format_class = Number(value);
      switch (value) {
        case '2':
          this.inputModel.inputParams[index].item_json = { values: [] };
          break;
        case '3':
        case '4':
        case '6':
          if(this.saveInputModel.inputParams[index]){
            this.inputModel.inputParams[index].item_json = this.saveInputModel.inputParams[index].item_json;
          } else {
            this.inputModel.inputParams[index].item_json = { values: [] };
          }
          break;
        case '10':
          // 掲示板
          // フィールド名生成
          this.inputModel.inputParams[index].item_json = {};
          break;
        default:
          this.inputModel.inputParams[index].item_json = {};
          break;
      }
      this.setInputParams(JSON.stringify(this.inputModel.inputParams));
      this.updateEditRecord(
        "inputParams",
        JSON.stringify(this.inputModel.inputParams)
      );
    },
    onFormatInput(previousValue, index) {
      // 形式名の変更前の値が掲示板リンクの場合はフィールド名を空値にする
      if (previousValue == 10) {
        this.getInputParams[index].field_name = "";
      }
    },
    /**
     * Gridの高さを調整する
     */
    calculateGridHeight() {
      const modal = document.getElementsByClassName("modal-container")[0];
      const modalHeight = modal.clientHeight;
      const modalHeaderHeight = modal.firstElementChild.clientHeight;
      const modalFooterHeight = modal.lastElementChild.clientHeight;
      const contentsHeight1 = document.getElementsByClassName(
        "disp-item-area"
      )[0].clientHeight;
      this.contentsAreaHeight =
        modalHeight -
        modalHeaderHeight -
        modalFooterHeight -
        contentsHeight1 -
        62.6;
    },

    /**
     * JSON配列カラムの項目削除処理
     */
    deleteJsonArray(json, index) {
      this.setInputParamsDelete(index);
      this.inputModel.inputParams = this.getInputParams;
      this.updateEditRecord(
        "inputParams",
        JSON.stringify(this.inputModel.inputParams)
      );
      this.sortListNameInputData();
    },
    /**
     *  JSONのフィールド名表示有無取得処理
     */
    getIsFieldDisplay(json) {
      if (json.is_field_display === "1") {
        return true;
      }
      return false;
    },
    /**
     *  JSONの実績展開取得処理
     */
    getIsRstCopy(json) {
      if (json.is_rst_copy === "1") {
        return 1;
      }
      return 0;
    },
    /**
     *
     */
    validateData() {
      const onRegistrationList = [];
      // テキストチェック
      const textItem = this.$refs.text;
      if (textItem !== undefined) {
        for (const item of textItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // テキストエリアチェック
      const textAreaItem = this.$refs.textArea;
      if (textAreaItem !== undefined) {
        for (const item of textAreaItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // 画像チェック
      const imageItem = this.$refs.image;
      if (imageItem !== undefined) {
        for (const item of imageItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // リストチェック
      const listItem = this.$refs.list;
      if (listItem !== undefined) {
        for (const item of listItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // ラジオボタンチェック
      const radioItem = this.$refs.radio;
      if (radioItem !== undefined) {
        for (const item of radioItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // 日付チェック
      const dateItem = this.$refs.date;
      if (dateItem !== undefined) {
        for (const item of dateItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // チェックチェック
      const checkItem = this.$refs.check;
      if (checkItem !== undefined) {
        for (const item of checkItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // ファイルチェック
      const fileItem = this.$refs.file;
      if (fileItem !== undefined) {
        for (const item of fileItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // 計算チェック
      const calcItem = this.$refs.calc;
      if (calcItem !== undefined) {
        for (const item of calcItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      // 掲示板リンク
      const bbsItem = this.$refs.bbs;
      if (bbsItem !== undefined) {
        for (const item of bbsItem) {
          onRegistrationList.push(item.validateOnRegistration);
        }
      }
      for (const onRegistration of onRegistrationList) {
        if (onRegistration) {
          const validationResult = onRegistration();
          if (!validationResult) return;
        }
      }
      // 治療実績リンク
      const treatments = this.getInputParams.filter(item => {
        return item.format_class === 9;
      });
      if (treatments.length > 1) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "治療実績リンクのチェックエラー",
          // message: "２つ以上の項目が存在します。<br>"
          title: DIALOG_MESSAGES['00200073'].title,
          message: messageFormat(DIALOG_MESSAGES['00200073'].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      this.dataErrList = [];
      let treatmentFieldNameValid = true;
      let num = 0;
      for (const treatmentItem of this.getInputParams) {
        if (treatmentItem.format_class === 9) {
          const fieldName = treatmentItem.field_name;
          treatmentFieldNameValid = fieldName !== null && fieldName !== "";
          if(!treatmentFieldNameValid) this.dataErrList.push(num)
        }
        num++;
      }
      if (!treatmentFieldNameValid) {
        this.dataErrList.forEach(element => {
          document.getElementsByClassName("required"+element)[0]?.classList?.add("input-invalid");
        });
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "治療実績リンクのチェックエラー",
          // message: "フィールド名を入力する必要があります。<br>"
          title: DIALOG_MESSAGES['00200074'].title,
          message: messageFormat(DIALOG_MESSAGES['00200074'].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 掲示板リンク
      const bbss = this.getInputParams.filter(item => {
        return item.format_class === 10;
      });
      if (bbss.length > 1) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "掲示板リンクのチェックエラー",
          // message: "２つ以上の項目が存在します。<br>"
          title: DIALOG_MESSAGES['00200156'].title,
          message: messageFormat(DIALOG_MESSAGES['00200156'].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      let bbsFieldNameValid = true;
      for (const bbsItem of this.getInputParams) {
        if (bbsItem.format_class === 10) {
          const fieldName = bbsItem.field_name;
          bbsFieldNameValid = fieldName !== null && fieldName !== "";
        }
      }
      if (!bbsFieldNameValid) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "掲示板リンクのチェックエラー",
          // message: "フィールド名を入力する必要があります。<br>"
          title: DIALOG_MESSAGES['00200129'].title,
          message: messageFormat(DIALOG_MESSAGES['00200129'].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      const name = this.inputModel.name;
      const nameLength = name ? name.length : 0;
      // 重複の存在チェック
      let fieldNameValid = true;
      const fieldNameList = this.getInputParams.map(
        record => record.field_name
      );
      // 施設コードリストをSetオブジェクトに(重複排除)
      const set = new Set(fieldNameList);
      if (fieldNameList.length !== set.size) {
        fieldNameValid = false;
      } else {
        fieldNameValid = true;
      }
      return {
        nameValid: name !== null && name !== "",
        nameLengthValid: nameLength <= 256,
        fieldNameValid: fieldNameValid
      };
    },
      //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    /**
     *
     */
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (validationResult === undefined) {
        return false;
      }
      if (Object.values(validationResult).every(v => v === true)) {
        // 直接使用現在正しくソートされたデータに依存し、DOMインデックスを使用しない。
        const currentData = deepCopy(this.getInputParams);
        this.inputModel.inputParams = currentData;
        this.setInputParams(JSON.stringify(currentData));
        this.updateEditRecord(
          "inputParams",
          JSON.stringify(currentData)
        );
        return true;
      }
      if(!validationResult.nameValid) {
        document.getElementsByClassName("custom-input-required")[0]?.classList?.add("custom-input-invalid");
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES['00200075'].title;
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.nameValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "名称を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200075'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.nameLengthValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "名称が長すぎます。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200076'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.fieldNameValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "フィールド名で重複があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200077'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.fieldNameValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "フィールド名で重複があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200077'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    }
  }
};
const ExtendedCustomInputNumber = Vue.extend({
  extends: CustomInputNumber,
  props: {
    //マウスホイールの刻み幅
    wheelStep: {
      type: Number,
      default: 0
    }
  },
  methods: {
    /**
     * @description マウスホイールイベントハンドラ
     * @summary マウスホイールでの入力値の増減を可能にする
     */
    wheelChangeValue(event) {
      // disabledでマウスホイールを拾わない
      if (this.$el.disabled) {
        return;
      }
      // mod 装置設定外結No3対応 趙 start
      if (this.focusflg) {
        // マウスホイールの向き
        const isUp = event.deltaY < 0;
        // 変更量(小数最下位を1ずつ)
        const stepNum = this.wheelStep * (isUp ? 1 : -1);

        // 空欄 ▼（decrement）: 最小値、▲（increment）: 最小値＋step
        if (this.inputtedString === "") {
          const updVal = isUp ? (this.minValue + stepNum) : this.minValue;
          this.udpateValue(updVal);
          return;
        }
        // 不正値は最小値に
        if (!isDecimal(this.inputtedString)) {
          this.udpateValue(this.minValue);
          return;
        }
        this.stepChangeValue(stepNum);
      }
    }
  }
});
Vue.component('extended-custom-input-number', ExtendedCustomInputNumber);
</script>

<style scoped>
@media print{
  .disp-item-content-frame{
    height: auto !important;
  }
  .print-height-auto{
    height: 100% !important;
  }
}
.disp-item-name-area {
  vertical-align: middle;
  padding-left: 5px;
}

.pat-event-input {
  width: 50%;
}

.disp-item-content-area {
  overflow-y: scroll;
  height: 85%;
}

.disp-item-area {
  width: 100%;
  border-collapse: collapse;
  margin-top: 5px;
}

.disp-item-area tr {
  height: 2em;
}

.disp-item-area tr th {
  text-align: left;
}

.disp-item-area tr th:first-child,
.disp-item-area tr th:nth-child(2) {
  width: 30%;
}

.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2),
.disp-item-area tr td:nth-child(3) {
  text-align: left;
}

.disp-item-content-frame {
  width: 100%;
  border: 1px solid;
  box-sizing: border-box;
  position: relative;
}

.card-table {
  width: 100%;
  border: 1px solid;
  box-sizing: border-box;
  position: relative;
}

.item-title {
  position: relative;
  padding-left: 5px;
  width: 12em;
}

.item-title-header {
  position: relative;
  padding-left: 10px;
  width: 12em;
}

.item-radio {
  position: relative;
  padding-left: 10px;
}

/* 削除ボタン */
.button-delete {
  position: absolute;
  top: 0;
  right: 0;
  height: 100%;
}

/* 追加ボタン */
.button-add {
  bottom: 2px;
  max-width: 10em;
  margin-left: auto;
  font-size: 100%;
}
.custom-input-required {
  color: black;
  background-color: transparent;
  height: fit-content;
}
.custom-input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.input-required >>> input{
  color: black;
  background-color: #ffff99;
}
.input-invalid >>> input{
  color: black;
  background-color: rgba(255, 0, 0, 1);
}

/* 並び替えボタン */
.button-sort {
  bottom: 2px;
  max-width: 8em;
  font-size: 100%;
}

.pat-event-input >>> .text-input {
  width: 99.9%;
}

.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}
.deleted-item {
  background-color: rgba(255, 0, 0, 0.5);
}

.item-dropdownlist {
  position: relative;
  top: 5px;
}

/* ドロップしている要素 */
.ghost {
  opacity: 0.5;
}
/* ドラッグしている要素*/
.drag {
  display: none;
}

.category-handle,
.column-handle {
  cursor: move;
  float: right;
}

/* カテゴリをドラック時、カテゴリの欄を小さくする*/
.layout-category-dragging {
  height: 150px;
}

/* カテゴリをドラック時、項目を見えなくする*/
.layout-column-dragging {
  display: none;
}

/* add 楊 start*/
.main-area-removeoverflow {
  border: 5px;
  height: 100%;
  padding: 5px;
}
/* add 楊 end*/
</style>
