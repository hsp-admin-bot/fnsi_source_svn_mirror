<template>
  <div class="main-area">
    <div class="disp-item-area">
      <div class="wrap-block">
        <label class="item-title">テンプレート名</label>
        <v-ons-input class="item-text custom-input-required" @input="setCss($event.target.value)" v-model="inputModel.name" @change="changeButton"/>
      </div>
      <div class="wrap-block">
        <label class="item-title">装置</label>
        <v-ons-select class="selectbox" v-model="inputModel.model" @change="onModelChange()" ref="mySelect">
          <option v-for="(item, index) in modelList" :key="index" :value="item.code">{{ item.name }}</option>
        </v-ons-select>
      </div>
      <div class="wrap-block">
        <label class="item-title">縦軸範囲（左）</label>
        <!-- mod #5589 2023/04/10 数値IFのスタイル全不正 張博 start -->
        <!-- <input
          class="item-numeric input-required required1"
          type="number"
          @input="setNumberCss($event.target.value,'required1')"
          step="0.01"
          v-model="inputModel.verticalRangeLeftMin"
          @change="changeButton"
        /> -->
        <!-- #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng start -->
         <!-- <input
          class="item-numeric input-required required1"
          type="number"
          @input="setNumberCss($event.target.value,'required1')"
          step="0.01"
          v-model="inputModel.verticalRangeLeftMin"
          @mousewheel="()=>{return true}"
        /> -->
        <div class="range-input-wrapper">
          <custom-input-number-pro
            v-if="isShowCustomInputNumberPro"
            :style="'min-width: 7em;'"
            class="item-numeric input-required required1"
            :required="true"
            :value="inputModel.verticalRangeLeftMin"
            :step="0.01"
            @handlerInput="(val) =>{ inputModel.verticalRangeLeftMin = val }"
          />
          <label class="item-title2">～</label>
          <custom-input-number-pro
            v-if="isShowCustomInputNumberPro"
            :style="'min-width: 7em;'"
            class="item-numeric input-required required2"
            :required="true"
            :value="inputModel.verticalRangeLeftMax"
            :step="0.01"
            @handlerInput="(val) =>{ inputModel.verticalRangeLeftMax = val }"
          />
        </div>
      </div>
      <div class="wrap-block">
        <label class="item-title">縦軸範囲（右）</label>
        <!-- mod #5589 2023/04/10 数値IFのスタイル全不正 張博 start -->
        <!-- <input
          class="item-numeric input-required required3"
          type="number"
          @input="setNumberCss($event.target.value,'required3')"
          step="0.01"
          v-model="inputModel.verticalRangeRightMin"
          @change="changeButton"
        /> -->
        <!-- #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng start -->
         <!-- <input
          class="item-numeric input-required required3"
          type="number"
          @input="setNumberCss($event.target.value,'required3')"
          step="0.01"
          v-model="inputModel.verticalRangeRightMin"
          @mousewheel="()=>{return true}"
        /> -->
        <div class="range-input-wrapper">
          <custom-input-number-pro
            v-if="isShowCustomInputNumberPro"
            :style="'min-width: 7em;'"
            class="item-numeric input-required required3"
            :required="true"
            :value="inputModel.verticalRangeRightMin"
            :step="0.01"
            @handlerInput="(val) =>{ inputModel.verticalRangeRightMin = val }"
          />
          <label class="item-title2">～</label>
          <custom-input-number-pro
            v-if="isShowCustomInputNumberPro"
            :style="'min-width: 7em;'"
            class="item-numeric input-required required1"
            :required="true"
            :value="inputModel.verticalRangeRightMax"
            :step="0.01"
            @handlerInput="(val) =>{ inputModel.verticalRangeRightMax = val }"
          />
        </div>
      </div>
      <div class="button-container">
        <v-ons-button class="button-add btn3-normal" :disabled="!isRow" @click="addRow()">フィールド追加</v-ons-button>
      </div>
    </div>
    <div class="disp-item-content-frame print-height-auto" :style="heightStyles">
      <div class="disp-item-content-area">
        <table class="ntss-list graph-list">
          <thead>
            <tr>
              <th
                class="ntss-list-header-th-sticky graph-list-header graph-list-name"
                scope="col"
              ><span style="display:block;width:14em">表示項目</span></th>
              <th
                class="ntss-list-header-th-sticky graph-list-header graph-list-select"
                scope="col"
              >上下限値指定方法</th>
              <th
                class="ntss-list-header-th-sticky graph-list-header graph-list-numeric"
                scope="col"
              >目標値</th>
              <th
                class="ntss-list-header-th-sticky graph-list-header graph-list-numeric"
                scope="col"
              >上限値</th>
              <th
                class="ntss-list-header-th-sticky graph-list-header graph-list-numeric"
                scope="col"
              >下限値</th>
              <th
                class="ntss-list-header-th-sticky graph-list-header graph-list-select"
                scope="col"
              >目標線表示</th>
              <th
                class="ntss-list-header-th-sticky graph-list-header graph-list-numeric"
                scope="col"
              >線色</th>
              <th
                class="ntss-list-header-th-sticky graph-list-header graph-list-select"
                scope="col"
              >使用縦軸</th>
              <th class="ntss-list-header-th-sticky graph-list-header graph-list-del" scope="col"></th>
            </tr>
          </thead>
          <tbody>
          <template v-for="(item,index) in inputModel.seriesInfo" :key="item.id">
            <tr v-if="!item.model_type || item.model_type == inputModel.model">
              <td class="ntss-list-body-td graph-list-name">
                <v-ons-select
                  class="selectbox"
                  v-model="item.moni_cd"
                  @change="onMoniItemChange($event.target.value, index)"
                >
                  <option
                    v-for="(item, index) in filteredMonitorList"
                    :key="index"
                    :value="item.code"
                  >{{ item.name }}</option>
                </v-ons-select>
              </td>
              <td class="ntss-list-body-td graph-list-select">
                <v-ons-select
                  class="selectbox"
                  v-model="item.limit_value_mode"
                  @change="onLimitValueModeChange($event.target.value, index)"
                >
                  <option
                    v-for="(item, index) in limitList"
                    :key="index"
                    :value="item.code"
                  >{{ item.name }}</option>
                </v-ons-select>
              </td>
              <td class="ntss-list-body-td graph-list-numeric">
                <!-- mod #5589 2023/04/10 数値IFのスタイル全不正 張博 start -->
                <!-- <input
                  :class="'input-required listRequired1'+index"
                  :name="'listRequired1'+index"
                  type="number"
                  step="0.01"
                  @input="setListRequiredCss($event)"
                  :value="item.target_value"
                  @change="onTargetValueChange($event.target.value, index )"
                /> -->
                <!-- #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng start -->
                <!-- <input
                  :class="'input-required listRequired1'+index"
                  :name="'listRequired1'+index"
                  type="number"
                  step="0.01"
                  @input="setListRequiredCss($event)"
                  @mousewheel="()=>{return true}"
                  :value="item.target_value"
                  @change="onTargetValueChange($event.target.value, index )"
                /> -->
                <custom-input-number-pro
                  v-if="isShowCustomInputNumberPro"
                  :class="'input-required listRequired1'+index"
                  :required="true"
                  :value="item.target_value"
                  :step="getMonitorItemStep(item.moni_cd)"
                  :min="getTargetRadius(item, 'min')"
                  :max="getTargetRadius(item, 'max')"
                  @handlerInput="(val) =>{ item.target_value = val; }"
                  @input="setListRequiredCss($event)"
                />
                <!-- #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng end -->
                 <!-- mod #5589 2023/04/10 数値IFのスタイル全不正 張博 end -->
              </td>
              <td class="ntss-list-body-td graph-list-numeric">
                <!-- mod #5589 2023/04/10 数値IFのスタイル全不正 張博 start -->
                <!-- <input
                   :class="'input-required listRequired2'+index"
                   :name="'listRequired2'+index"
                  type="number"
                  step="0.01"
                   @input="setListRequiredCss($event)"
                  :value="item.upper_value"
                  @change="onUpperValueChange($event.target.value, index)"
                /> -->
                <!-- <input
                   :class="'input-required listRequired2'+index"
                   :name="'listRequired2'+index"
                  type="number"
                  step="0.01"
                   @input="setListRequiredCss($event)"
                   @mousewheel="()=>{return true}"
                  :value="item.upper_value"
                  @change="onUpperValueChange($event.target.value, index)"
                /> -->
                <!-- #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng start -->
                <custom-input-number-pro
                  v-if="isShowCustomInputNumberPro"
                  :class="'input-required listRequired2'+index"
                  :required="true"
                  :value="item.upper_value"
                  :step="getMonitorItemStep(item.moni_cd)"
                  :min="getMonitorItemRadius(item, 'min')"
                  :max="getMonitorItemRadius(item, 'max', 'upper_value')"
                  @handlerInput="(val) =>{ item.upper_value = val; }"
                  @input="setListRequiredCss($event)"
                />
                <!-- #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng end -->
                <!-- mod #5589 2023/04/10 数値IFのスタイル全不正 張博 end -->
              </td>
              <td class="ntss-list-body-td graph-list-numeric">
                <!-- mod #5589 2023/04/10 数値IFのスタイル全不正 張博 start -->
                <!-- <input
                   :class="'input-required listRequired3'+index"
                   :name="'listRequired3'+index"
                  type="number"
                  step="0.01"
                   @input="setListRequiredCss($event)"
                  :value="item.lower_value"
                  @change="onLowerValueChange($event.target.value, index)"
                /> -->
                <!-- #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng start -->
                <!-- <input
                   :class="'input-required listRequired3'+index"
                   :name="'listRequired3'+index"
                  type="number"
                  step="0.01"
                   @input="setListRequiredCss($event)"
                   @mousewheel="()=>{return true}"
                  :value="item.lower_value"
                  @change="onLowerValueChange($event.target.value, index)"
                /> -->
                <custom-input-number-pro
                  v-if="isShowCustomInputNumberPro"
                  :class="'input-required listRequired2'+index"
                  :required="true"
                  :value="item.lower_value"
                  :step="getMonitorItemStep(item.moni_cd)"
                  :min="getMonitorItemRadius(item, 'min')"
                  :max="getMonitorItemRadius(item, 'max', 'lower_value')"
                  @handlerInput="(val) =>{ item.lower_value = val; }"
                  @input="setListRequiredCss($event)"
                />
                <!-- #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng end -->
                <!-- mod #5589 2023/04/10 数値IFのスタイル全不正 張博 end -->
              </td>
              <td class="ntss-list-body-td graph-list-select">
                <ons-checkbox
                  :checked="getIsShowTargetLine(item)"
                  @change="onIsShowTargetLine($event, index)"
                />
              </td>
              <td class="ntss-list-body-td graph-list-numeric">
                <v-ons-input
                  class
                  type="color"
                  :value="item.line_color"
                  @change="onColorChange($event.target.value, index)"
                />
              </td>
              <td class="ntss-list-body-td graph-list-select">
                <v-ons-select
                  class="selectbox"
                  v-model="item.axis_direction"
                  @change="onAxisDirectionChange($event.target.value, index)"
                >
                  <option
                    v-for="(item, index) in AxisUsedList"
                    :key="index"
                    :value="item.code"
                  >{{ item.name }}</option>
                </v-ons-select>
              </td>
              <td class="ntss-list-body-td graph-list-del">
                <button class="ntss-btn-outset" @click="deleteRow(index)">
                  <v-ons-icon icon="fa-trash"/>
                </button>
              </td>
            </tr>
          </template>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { MACHINE_MODEL, NX_MACHINE_ID } from "@/constants/machineModel";
import BigNumber from "@/compat/number/bignumber";
import { ApiHelper } from "@/apis/AxiosHelper.js";
import { deepCopy } from "@/functions/common/CommonFunctions";
import {EventBus} from "@/compat/vue/event-bus.js";
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start

import { getScopedElementsByClassName, resolveRefElement } from "@/functions/common/LayoutMeasureHelper";
import { nextId } from "@/functions/common/id";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// add #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng end

export default {
  name: "MstTrendGraphTemplateModal",
  components: {
    // add #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng start
    "custom-input-number-pro": CustomInputNumberPro
    // add #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng end
  },
  data() {
    return {
      modelList: [
        {
          code: MACHINE_MODEL.DRO,
          name: "ＤＲＯ"
        },
        {
          code: MACHINE_MODEL.DAB,
          name: "ＤＡＢ"
        },
        {
          code: MACHINE_MODEL.DAD,
          name: "ＤＡＤ"
        },
        {
          code: MACHINE_MODEL.DRY_A,
          name: "ＤＲＹ－Ａ"
        },
        {
          code: MACHINE_MODEL.DRY_B,
          name: "ＤＲＹ－Ｂ"
        }
      ],
      limitList: [
        {
          code: "0",
          name: "数値"
        },
        {
          code: "1",
          name: "％"
        }
      ],
      AxisUsedList: [
        {
          code: 0,
          name: "左"
        },
        {
          code: 1,
          name: "右"
        }
      ],
      inputModel: {
        code: 0,
        name: "",
        model: "",
        verticalRangeRightMax: 0,
        verticalRangeRightMin: 0,
        verticalRangeLeftMax: 0,
        verticalRangeLeftMin: 0,
        seriesInfo: [],
        facilityCd: "",
        isDisp: "",
        isDel: ""
      },
      //mod マスタ詳細画面がありません破棄メッセージ
      initName:"",
      initModel:"",
      initVerticalRangeLeftMax:"",
      initVerticalRangeLeftMin:"",
      initVerticalRangeRightMax:"",
      initVerticalRangeRightMin:"",
      initSeriesInfo:{},
      contentsAreaHeight: 200,
      isRow: false,
      monitorItemList: [],
      temporaryItemList: [],
      dataErrList:[],
      // add #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng start
      isShowCustomInputNumberPro: false,
      defaultMinValue: Number("-999999999999999999"),
      defaultMaxValue: Number("999999999999999999"),
      // add #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng end
      elementHeight: 0,
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
    }),
    /**
     * コンテンツの高さをCSS変数を利用して書き換える
     */
    heightStyles() {
      return { height: `${this.contentsAreaHeight}px` };
    },
    /**
     * モニタ項目のフィルタリング
     */
    filteredMonitorList() {
      let filteredList = this.monitorItemList;
      if (this.inputModel.model !== null && this.inputModel.model !== "") {
        filteredList = filteredList.filter(
          item => item.model === this.inputModel.model
        );
      } else {
        return [];
      }
      return filteredList;
    }
  },
  watch: {
    /**
     * ウィンドウサイズが変更された時の処理.
     */
    windowHeight() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    inputModel:{
      handler(){
        if (this.initName!=this.inputModel.name||
        this.initModel!=this.inputModel.model||
        this.initVerticalRangeLeftMin!=this.inputModel.verticalRangeLeftMin||
        this.initVerticalRangeLeftMax!=this.inputModel.verticalRangeLeftMax||
        this.initVerticalRangeRightMin!=this.inputModel.verticalRangeRightMin||
        this.initVerticalRangeRightMax!=this.inputModel.verticalRangeRightMax||
        JSON.stringify(this.inputModel.seriesInfo)!=JSON.stringify(this.initSeriesInfo)
        ) {
          this.changeButton();
        }else{
          EventBus.$emit("mstHolidayRegistered", true);
        }
      },
      deep:true
    },
    /**
     * 画面上部の項目の高さを監視
     */
    elementHeight() {
      this.calculateGridHeight();
    }
  },
  async mounted() {
    // モニタ項目
    const sysMonitorItemRequestParamDab = {
      moniDataType: NX_MACHINE_ID.DAB,
      vitalMonitorClass: null
    };
    const sysMonitorItemRequestParamDad = {
      moniDataType: NX_MACHINE_ID.DAD,
      vitalMonitorClass: null
    };
    const sysMonitorItemRequestParamDro = {
      moniDataType: NX_MACHINE_ID.DRO,
      vitalMonitorClass: null
    };
    const sysMonitorItemRequestParamDryA = {
      moniDataType: NX_MACHINE_ID.DRY_A,
      vitalMonitorClass: null
    };
    const sysMonitorItemRequestParamDryB = {
      moniDataType: NX_MACHINE_ID.DRY_B,
      vitalMonitorClass: null
    };
    const that = this;
    await Promise.all([
      ApiHelper.get(
        "/treatment-record/sys_monitor_item",
        sysMonitorItemRequestParamDab
      ),
      ApiHelper.get(
        "/treatment-record/sys_monitor_item",
        sysMonitorItemRequestParamDad
      ),
      ApiHelper.get(
        "/treatment-record/sys_monitor_item",
        sysMonitorItemRequestParamDro
      ),
      ApiHelper.get(
        "/treatment-record/sys_monitor_item",
        sysMonitorItemRequestParamDryA
      ),
       ApiHelper.get(
        "/treatment-record/sys_monitor_item",
        sysMonitorItemRequestParamDryB
      )
    ]).then(response => {
      /* ================= #9312  Modified Start ================= */
      // モニタ項目：DAB
      const sysMonitorItemDab = response[0].data ? response[0].data
        // .filter(item => item.moni_data_no !== 'A99' && item.moni_data_no !== 'A1') : [];
        .filter(item => item.moni_data_no !== 'A1') : [];
      // モニタ項目：DAD
      const sysMonitorItemDad = response[1].data ? response[1].data
        // .filter(item => item.moni_data_no !== 'D99' && item.moni_data_no !== 'D1') : [];
        .filter(item => item.moni_data_no !== 'D1') : [];
      // モニタ項目：DRO
      const sysMonitorItemDro = response[2].data ? response[2].data
        // .filter(item => item.moni_data_no !== 'R99' && item.moni_data_no !== 'R1') : [];
        .filter(item => item.moni_data_no !== 'R1') : [];
      // モニタ項目：DRY_A
      const sysMonitorItemDryA = response[3].data ? response[3].data.filter(item => item.moni_data_no !== 'I1') : [];
      // モニタ項目：DRY_B
      const sysMonitorItemDryB = response[4].data ? response[4].data.filter(item => item.moni_data_no !== 'J1') : [];
      /* ================= #9312  Modified End ================= */
      // モニタ項目の結合
      const sysMonitorItem = sysMonitorItemDab.concat(
        sysMonitorItemDad,
        sysMonitorItemDro,
        sysMonitorItemDryA,
        sysMonitorItemDryB
      );
      // 表示用モニタ項目作成
      that.monitorItemList = sysMonitorItem
        .filter(s => s.is_disp === "1")
        .map(s => {
          let model = null;
          let code = 0;
          switch (s.moni_data_type) {
            case NX_MACHINE_ID.DAB:
              //DAB
              model = MACHINE_MODEL.DAB;
              code = s.moni_data_no.replace(NX_MACHINE_ID.DAB, "");
              break;
            case NX_MACHINE_ID.DAD:
              //DAD
              model = MACHINE_MODEL.DAD;
              code = s.moni_data_no.replace(NX_MACHINE_ID.DAD, "");
              break;
            case NX_MACHINE_ID.DRO:
              //DRO
              model = MACHINE_MODEL.DRO;
              code = s.moni_data_no.replace(NX_MACHINE_ID.DRO, "");
              break;
            case NX_MACHINE_ID.DRY_A:
              //DRY_A
              model = MACHINE_MODEL.DRY_A;
              code = s.moni_data_no.replace(NX_MACHINE_ID.DRY_A, "");
              break;
            case NX_MACHINE_ID.DRY_B:
              //DRY_B
              model = MACHINE_MODEL.DRY_B;
              code = s.moni_data_no.replace(NX_MACHINE_ID.DRY_B, "");
              break;
            default:
              break;
          }
          const upperLength = parseInt(s.upper).toString(10).length;
          const lowerLength = parseInt(s.lower).toString(10).length;
          let length = 0;
          if (upperLength > lowerLength) {
            length = upperLength;
          } else {
            length = lowerLength;
          }
          return {
            model: model,
            code: parseInt(code, 10),
            name: s.moni_data_name,
            intPoint: length,
            decPoint: s.decimal_figure,
            maxValue: s.upper,
            minValue: s.lower
          };
        });
    });
    this.monitorItemList = that.monitorItemList;
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
      // 装置種別
      if (this.columnDefinition[num].field === "model") {
        this.inputModel.model = this.getValueByField(
          this.columnDefinition[num].field
        );
        if (this.inputModel.model !== null && this.inputModel.model !== "") {
          this.isRow = true;
        }
      }
      // 縦軸範囲（右）最大値
      if (this.columnDefinition[num].field === "verticalRangeRightMax") {
        this.inputModel.verticalRangeRightMax = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // 縦軸範囲（右）最小値
      if (this.columnDefinition[num].field === "verticalRangeRightMin") {
        this.inputModel.verticalRangeRightMin = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // 縦軸範囲（左）最大値
      if (this.columnDefinition[num].field === "verticalRangeLeftMax") {
        this.inputModel.verticalRangeLeftMax = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // 縦軸範囲（左）最小値
      if (this.columnDefinition[num].field === "verticalRangeLeftMin") {
        this.inputModel.verticalRangeLeftMin = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // グラフ系列情報
      if (this.columnDefinition[num].field === "seriesInfo") {
        const contact = this.getValueByField(this.columnDefinition[num].field);
        if (contact === null || !contact ||contact.length === 0) {
          this.inputModel.seriesInfo = [];
        } else {
          let contactList = []
          JSON.parse(contact).forEach(e =>{
            e["id"] = nextId("seriesInfo");
            e["model_type"] = this.inputModel.model;
            contactList.push(e);
          });
          this.inputModel.seriesInfo = contactList;
        }
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
      }
      // 削除フラグ
      if (this.columnDefinition[num].field === "isDel") {
        this.inputModel.isDel = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
    }
    // add #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng start
    this.isShowCustomInputNumberPro = true;
    this.$nextTick(() => {
      //mod マスタ詳細画面がありません破棄メッセージ
      this.calculateGridHeight();
      this.initModel = this.inputModel.model;
      this.initName = this.inputModel.name;
      this.initVerticalRangeLeftMin = this.inputModel.verticalRangeLeftMin;
      this.initVerticalRangeLeftMax = this.inputModel.verticalRangeLeftMax;
      this.initVerticalRangeRightMin = this.inputModel.verticalRangeRightMin;
      this.initVerticalRangeRightMax = this.inputModel.verticalRangeRightMax;
      this.initSeriesInfo = JSON.parse(JSON.stringify(this.inputModel.seriesInfo));
    });
    // add #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 custom-input-number-pro 置き換えます linjunfeng end
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
    this.observeHeightChange();
  },
  created() {
    this.setLoadingScreenVisible(true);
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    getScopedClassElement(className) {
      return getScopedElementsByClassName(className, this.$el || null)[0] || null;
    },
    getScopedModalContainer() {
      return this.$el?.closest?.(".modal-container") || this.getScopedClassElement("modal-container");
    },
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
    /**
     * フィールド追加ボタンクリックイベント
     */
    addRow() {
      let seriesInfoList =  this.inputModel.seriesInfo.filter(e=>e.model_type == this.inputModel.model);
      if (seriesInfoList.length > 4) {
        return;
      }
      const item = {
        id: nextId("seriesInfo"),
        moni_cd: null,
        moni_name: "",
        model_type: this.inputModel.model,
        target_value: 0,
        limit_value_mode: "0",
        upper_value: 0,
        lower_value: 0,
        is_show_target_line: "0",
        line_color: "#ffffff",
        axis_direction: 0
      };
      this.inputModel.seriesInfo.push(item);
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
      this.changeButton();
    },
    /**
     * Gridの高さを調整する
     */
    calculateGridHeight() {
      const modal = this.getScopedModalContainer();
      if (!modal) {
        return;
      }
      const modalHeight = modal.clientHeight;
      const modalHeaderHeight = modal.firstElementChild?.firstElementChild?.clientHeight || 0;
      const modalFooterHeight = modal.lastElementChild?.clientHeight || 0;
      const contentsHeight1 = this.getScopedClassElement("disp-item-area")?.clientHeight || 0;
      // NONE: 画面上部のpadding: 5px * 2
      this.contentsAreaHeight =
        modalHeight -
        modalHeaderHeight -
        modalFooterHeight -
        contentsHeight1 
        -
        10;
    },
    /**
     * 画面上部の高さ
     */
    observeHeightChange() {
      const elements = getScopedElementsByClassName("disp-item-area", this.$el || null);
      if (elements.length > 0) {
        const element = elements[0];
        const resizeObserver = new ResizeObserver(() => {
          this.elementHeight = element.offsetHeight;
        });
        resizeObserver.observe(element);
        // 初期高さを設定
        this.elementHeight = element.offsetHeight;
      }
    },
    /**
     * フィールド削除ボタンクリックイベント
     */
    deleteRow(index) {
      this.inputModel.seriesInfo.splice(index, 1);
      this.changeButton();
    },
    onModelChange() {
      // let seriesInfoList = [];
      // this.inputModel.seriesInfo.forEach(e=>{
      //   if (e.moni_cd) seriesInfoList.push(e)
      // })
      // this.inputModel.seriesInfo = seriesInfoList;
      this.isRow = true;
    },
    setCss(value) {
      const invalidElement = this.getScopedClassElement("custom-input-invalid");
      if (value && invalidElement) invalidElement.classList.remove("custom-input-invalid");
    },
    setNumberCss(value,className) {
      if(value && this.getScopedClassElement(className) && (className =="required1" || className =="required2")) {
        this.getScopedClassElement("required1")?.classList.remove("input-invalid");
        this.getScopedClassElement("required2")?.classList.remove("input-invalid");
      }
      if(value && this.getScopedClassElement(className) && (className =="required3" || className =="required4")) {
        this.getScopedClassElement("required3")?.classList.remove("input-invalid");
        this.getScopedClassElement("required4")?.classList.remove("input-invalid");
      }
    },
    setListRequiredCss(e) {
      e.target.classList.remove("input-invalid")
    },
    /**
     * グリッドの目標値チェック
     */
    // mod 【試験T】【結合テスト】治療状況透析液調製装置グラフレイアウトマスタ 20230629 zhaoqi start
    onTargetValueChange(value, index) {
      const targetValue = this.inputModel.seriesInfo[index].target_value;
      // mod 5706 鞠 目標値の小数点以下が勝手に削除される。 start
      // this.inputModel.seriesInfo[index].target_value = parseInt(value, 10);
      this.inputModel.seriesInfo[index].target_value = Number(new BigNumber(value));
      // mod 5706 鞠 目標値の小数点以下が勝手に削除される。 end
      this.changeButton();
    },
    /**
     * グリッドの上限値チェック
     */
    onUpperValueChange(value, index) {
      const targetValue = this.inputModel.seriesInfo[index].target_value;
      this.inputModel.seriesInfo[index].upper_value = Number(new BigNumber(value));
      this.changeButton();
    },
    /**
     * グリッドの下限値チェック
     */
    onLowerValueChange(value, index) {
      const targetValue = this.inputModel.seriesInfo[index].target_value;
      this.inputModel.seriesInfo[index].lower_value = Number(new BigNumber(value));
      this.changeButton();
    },
    // mod 【試験T】【結合テスト】治療状況透析液調製装置グラフレイアウトマスタ 20230629 zhaoqi end
    /**
     * 表示項目
     */
    onMoniItemChange(value, index) {
      this.inputModel.seriesInfo[index].moni_cd = parseInt(value, 10);
      const filteredList = this.getFilteredList(
        this.inputModel.seriesInfo[index].moni_cd
      );
      if (filteredList) {
        this.inputModel.seriesInfo[index].moni_name = filteredList.name;
        // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
        // this.inputModel.seriesInfo[index].target_value = 0;
        this.inputModel.seriesInfo[index].target_value = Number(0).toFixed(filteredList.decPoint);
        // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end
        this.onLimitValueModeChange(
          this.inputModel.seriesInfo[index].limit_value_mode,
          index
        );
      }
      this.changeButton();
    },
    /**
     * 上下限値指定方法
     */
    onLimitValueModeChange(value, index) {
      if (value === this.limitList[1].code) {
        const targetValue = this.inputModel.seriesInfo[index].target_value;
        // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
        const filteredList = this.getFilteredList(
          this.inputModel.seriesInfo[index].moni_cd
        );
        // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end
        if (Number(targetValue) !== 0) {
          const upperValue = new BigNumber(
            this.inputModel.seriesInfo[index].upper_value
          );
          const lowerValue = new BigNumber(
            this.inputModel.seriesInfo[index].lower_value
          );
          // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
          // this.inputModel.seriesInfo[index].upper_value = Number(
          //   upperValue
          //     .times(100)
          //     .div(targetValue)
          //     .minus(100)
          //     .abs()
          //     .toFixed(2)
          // );
          // this.inputModel.seriesInfo[index].lower_value = Number(
          //   lowerValue
          //     .times(100)
          //     .div(targetValue)
          //     .minus(100)
          //     .abs()
          //     .toFixed(2)
          // );
          if (filteredList) {
            this.inputModel.seriesInfo[index].upper_value = Number(
              upperValue
                .times(100)
                .div(targetValue)
                .minus(100)
                .abs()
            ).toFixed(filteredList.decPoint);
            this.inputModel.seriesInfo[index].lower_value = Number(
              lowerValue
                .times(100)
                .div(targetValue)
                .minus(100)
                .abs()
            ).toFixed(filteredList.decPoint);
          }
        } else {
          // this.inputModel.seriesInfo[index].lower_value = 0;
          // this.inputModel.seriesInfo[index].upper_value = 0;
          this.inputModel.seriesInfo[index].lower_value = filteredList?.decPoint ? Number(targetValue).toFixed(filteredList.decPoint) : 0;
          this.inputModel.seriesInfo[index].upper_value = this.inputModel.seriesInfo[index].lower_value;
        }
        // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end  
      } else {
        const filteredList = this.getFilteredList(
          this.inputModel.seriesInfo[index].moni_cd
        );
        if (filteredList) {
          // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
          // this.inputModel.seriesInfo[index].lower_value = filteredList.minValue;
          this.inputModel.seriesInfo[index].lower_value = this.getMonitorItemComputedValue(filteredList.minValue, filteredList.decPoint).toFixed(filteredList.decPoint);
          // this.inputModel.seriesInfo[index].upper_value = filteredList.maxValue;
          this.inputModel.seriesInfo[index].upper_value = this.getMonitorItemComputedValue(filteredList.maxValue, filteredList.decPoint).toFixed(filteredList.decPoint);
          // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end
        }
      }
      this.inputModel.seriesInfo[index].limit_value_mode = value;
      this.changeButton();
    },
    /**
     * 目標線表示
     */
    onIsShowTargetLine(ev, index) {
      this.inputModel.seriesInfo[index].is_show_target_line = ev.target.checked
        ? "1"
        : "0";
      this.changeButton();
    },
    /**
     * 目標線表示取得処理
     */
    getIsShowTargetLine(json) {
      return json.is_show_target_line === "1";
    },
    /**
     * 使用縦軸処理
     */
    onAxisDirectionChange(value, index) {
      this.inputModel.seriesInfo[index].axis_direction = parseInt(value, 10);
      this.changeButton();
    },
    /**
     * 設定色
     */
    onColorChange(value, index) {
      this.inputModel.seriesInfo[index].line_color = value;
      this.changeButton();
    },
    /**
     * 文字入力
     */
    validateRequired(value) {
      const val = value.toString();
      return val.trim().length > 0;
    },
    /**
     * 数字（正規表現）チェック
     */
    validateNumber(value) {
      const val = value.toString();
      if (!val.match(/^[-]?[0-9]{1,4}(\.[0-9]{1,2})?$/)) {
        return false;
      }
      return true;
    },
    /**
     * 表示項目の抽出処理
     */
    getFilteredList(value) {
      let filteredList = this.monitorItemList;
      if (this.inputModel.model !== null && this.inputModel.model !== "") {
        filteredList = filteredList.filter(
          item => item.model === this.inputModel.model
        );
        filteredList = filteredList.filter(item => item.code === value);
        return filteredList[0];
      }
      return null;
    },
    /**
     * 数字（正規表現）チェック
     */
    validNumJudge({ intPoint, decPoint, value }) {
      let formula = "";
      if (decPoint > 0) {
        formula =
          "^[-]?[0-9]{1," +
          intPoint.toString(10) +
          "}(\\.[0-9]{1," +
          decPoint.toString(10) +
          "})?$";
      } else {
        formula = "^[-]?[0-9]{1," + intPoint.toString(10) + "}?$";
      }
      const regexp = new RegExp(formula);
      if (!regexp.test(value)) {
        return false;
      }
      return true;
    },
    /**
     * 入力データの検証
     */
    validateData() {
      //目標値の未入力判定
      let targetValueValid = true;
      let targetValueOverValid = true;
      let targetValueNumValid = true;
      this.dataErrList = [];
      let idx = 0;
      let value = "";
      let seriesInfoList = [];
      this.temporaryItemList = deepCopy(this.inputModel.seriesInfo);
      this.inputModel.seriesInfo.forEach(e=>{
        if (e.model_type == this.inputModel.model) {
          delete e.model_type;
          delete e.id;
          seriesInfoList.push(e);
        }
      });
      this.inputModel.seriesInfo = seriesInfoList;
      for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
        if (this.inputModel.seriesInfo[idx].moni_cd !== null) {
          value = this.inputModel.seriesInfo[idx].target_value;
          if (!this.validateRequired(value)) {
            targetValueValid = false;
            this.dataErrList.push(idx)
          }
        }
      }
      //目標値の範囲外判定
      if (targetValueValid) {
        for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
          if (
            this.inputModel.seriesInfo[idx].moni_cd !== null &&
            this.inputModel.seriesInfo[idx].limit_value_mode ===
              this.limitList[0].code
          ) {
            value = this.inputModel.seriesInfo[idx].target_value;
            const filteredList = this.getFilteredList(
              this.inputModel.seriesInfo[idx].moni_cd
            );
            if (filteredList) {
              // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
              const max = filteredList.maxValue / Math.pow(10, filteredList.decPoint);
              const min = filteredList.minValue / Math.pow(10, filteredList.decPoint);
              // if (value > filteredList.maxValue) {
              if (value > max) {
              // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end  
                targetValueOverValid = false;
                this.dataErrList.push(idx)
              }
              // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
              // if (value < filteredList.minValue) {
              if (value < min) {
              // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end  
                targetValueOverValid = false;
                this.dataErrList.push(idx)
              }
            }
          }
        }
      }
      //目標値の入力桁数判定
      if (targetValueOverValid) {
        for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
          if (
            this.inputModel.seriesInfo[idx].moni_cd !== null &&
            this.inputModel.seriesInfo[idx].limit_value_mode ===
              this.limitList[0].code
          ) {
            value = this.inputModel.seriesInfo[idx].target_value;
            const filteredList = this.getFilteredList(
              this.inputModel.seriesInfo[idx].moni_cd
            );
            if (filteredList) {
              targetValueNumValid = this.validNumJudge({
                intPoint: filteredList.intPoint,
                decPoint: filteredList.decPoint,
                value: value
              });
              if (!targetValueNumValid) this.dataErrList.push(idx)
            }
          }
        }
      }
      //上限値の未入力判定
      let upperValueValid = true;
      let upperValueOverValid = true;
      let upperValueNumValid = true;
      for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
        if (this.inputModel.seriesInfo[idx].moni_cd !== null) {
          value = this.inputModel.seriesInfo[idx].upper_value;
          if (!this.validateRequired(value)) {
            upperValueValid = false;
            this.dataErrList.push(idx)
          }
        }
      }
      //上限値の範囲外判定
      if (upperValueValid) {
        for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
          if (
            this.inputModel.seriesInfo[idx].moni_cd !== null &&
            this.inputModel.seriesInfo[idx].limit_value_mode ===
              this.limitList[0].code
          ) {
            value = this.inputModel.seriesInfo[idx].upper_value;
            const filteredList = this.getFilteredList(
              this.inputModel.seriesInfo[idx].moni_cd
            );
            if (filteredList) {
              // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
              const max = filteredList.maxValue / Math.pow(10, filteredList.decPoint);
              const min = filteredList.minValue / Math.pow(10, filteredList.decPoint);
              // if (value > filteredList.maxValue) {
              if (value > max) {
              // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end
                upperValueOverValid = false;
                this.dataErrList.push(idx)
              }
              // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
              // if (value < filteredList.minValue) {
              if (value < min) {
              // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end
                upperValueOverValid = false;
                this.dataErrList.push(idx)
              }
            }
          }
        }
      }
      //上限値の入力桁数判定
      if (upperValueOverValid) {
        for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
          if (
            this.inputModel.seriesInfo[idx].moni_cd !== null &&
            this.inputModel.seriesInfo[idx].limit_value_mode ===
              this.limitList[0].code
          ) {
            value = this.inputModel.seriesInfo[idx].upper_value;
            const filteredList = this.getFilteredList(
              this.inputModel.seriesInfo[idx].moni_cd
            );
            if (filteredList) {
              upperValueNumValid = this.validNumJudge({
                intPoint: filteredList.intPoint,
                decPoint: filteredList.decPoint,
                value: value
              });
              if(!upperValueNumValid) this.dataErrList.push(idx)
            }
          }
        }
      }
      //下限値の未入力判定
      let lowerValueValid = true;
      let lowerValueOverValid = true;
      let lowerValueNumValid = true;
      for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
        if (this.inputModel.seriesInfo[idx].moni_cd !== null) {
          value = this.inputModel.seriesInfo[idx].lower_value;
          if (!this.validateRequired(value)) {
            lowerValueValid = false;
            this.dataErrList.push(idx)
          }
        }
      }
      //下限値の範囲外判定
      if (lowerValueValid) {
        for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
          if (
            this.inputModel.seriesInfo[idx].moni_cd !== null &&
            this.inputModel.seriesInfo[idx].limit_value_mode ===
              this.limitList[0].code
          ) {
            value = this.inputModel.seriesInfo[idx].lower_value;
            const filteredList = this.getFilteredList(
              this.inputModel.seriesInfo[idx].moni_cd
            );
            if (filteredList) {
              // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
              const max = filteredList.maxValue / Math.pow(10, filteredList.decPoint);
              const min = filteredList.minValue / Math.pow(10, filteredList.decPoint);
              // if (value > filteredList.maxValue) {
              if (value > max) {
              // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end
                lowerValueOverValid = false;
                this.dataErrList.push(idx)
              }
              // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
              // if (value < filteredList.minValue) {
              if (value < min) {
              // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end
                lowerValueOverValid = false;
                this.dataErrList.push(idx)
              }
            }
          }
        }
      }
      //下限値の入力桁数判定
      if (lowerValueOverValid) {
        for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
          if (
            this.inputModel.seriesInfo[idx].moni_cd !== null &&
            this.inputModel.seriesInfo[idx].limit_value_mode ===
              this.limitList[0].code
          ) {
            value = this.inputModel.seriesInfo[idx].lower_value;
            const filteredList = this.getFilteredList(
              this.inputModel.seriesInfo[idx].moni_cd
            );
            if (filteredList) {
              lowerValueNumValid = this.validNumJudge({
                intPoint: filteredList.intPoint,
                decPoint: filteredList.decPoint,
                value: value
              });
              if(!lowerValueNumValid)this.dataErrList.push(idx)
            }
          }
        }
      }
      //上下限値指定方法
      let limitValueModeValid = true;
      for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
        if (this.inputModel.seriesInfo[idx].moni_cd !== null) {
          value = this.inputModel.seriesInfo[idx].limit_value_mode;
          if (
            value !== this.limitList[0].code &&
            value !== this.limitList[1].code
          ) {
            limitValueModeValid = false;
            this.dataErrList.push(idx)
          }
        }
      }
      //使用縦軸
      let axisDirectionValid = true;
      for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
        if (this.inputModel.seriesInfo[idx].moni_cd !== null) {
          value = this.inputModel.seriesInfo[idx].axis_direction;
          if (value !== 0 && value !== 1) {
            axisDirectionValid = false;
          }
        }
      }
      //明細行有無
      let detailValid = true;
      if (this.inputModel.seriesInfo.length > 0) {
        for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
          if (this.inputModel.seriesInfo[idx].moni_cd === null) {
            detailValid = false;
          }
        }
      } else {
        detailValid = false;
      }
      //明細の上下限値の整合性チェック
      let valueOverValid = true;
      for (idx = 0; idx < this.inputModel.seriesInfo.length; idx++) {
        if (this.inputModel.seriesInfo[idx].moni_cd !== null) {
          const mode = this.inputModel.seriesInfo[idx].limit_value_mode;
          const value = this.inputModel.seriesInfo[idx].target_value;
          let lowValue = parseFloat(
            this.inputModel.seriesInfo[idx].lower_value
          );
          let uppValue = parseFloat(
            this.inputModel.seriesInfo[idx].upper_value
          );
          if (limitValueModeValid && targetValueValid) {
            if (Number(mode) === Number(this.limitList[1].code)) {
              // %
              lowValue = value * (1 - lowValue / 100);
              uppValue = value * (1 + uppValue / 100);
            }
            valueOverValid = !(lowValue >= uppValue);
            if(!valueOverValid) this.dataErrList.push(idx)
          }else{
            this.dataErrList.push(idx)
          }
        }
      }
      //縦軸範囲（右）整合性チェック
      let verticalRangeRightValid = true;
      if (
        this.validateNumber(this.inputModel.verticalRangeRightMin) &&
        this.validateNumber(this.inputModel.verticalRangeRightMax)
      ) {
        if (
          this.inputModel.verticalRangeRightMin >=
          this.inputModel.verticalRangeRightMax
        ) {
          verticalRangeRightValid = false;
        }
      }
      //縦軸範囲（左）整合性チェック
      let verticalRangeLeftValid = true;
      if (
        this.validateNumber(this.inputModel.verticalRangeLeftMin) &&
        this.validateNumber(this.inputModel.verticalRangeLeftMax)
      ) {
        if (
          this.inputModel.verticalRangeLeftMin >=
          this.inputModel.verticalRangeLeftMax
        ) {
          verticalRangeLeftValid = false;
        }
      }
      return {
        nameValid: this.validateRequired(this.inputModel.name),
        nameLengthValid: this.inputModel.name.length <= 50,
        modelValid: this.validateRequired(this.inputModel.model),
        verticalRangeRightMinValid: this.validateRequired(
          this.inputModel.verticalRangeRightMin
        ),
        verticalRangeRightMinValueValid: this.validateNumber(
          this.inputModel.verticalRangeRightMin
        ),
        verticalRangeLeftMinValid: this.validateRequired(
          this.inputModel.verticalRangeLeftMin
        ),
        verticalRangeLeftMinValueValid: this.validateNumber(
          this.inputModel.verticalRangeLeftMin
        ),
        verticalRangeRightMaxValid: this.validateRequired(
          this.inputModel.verticalRangeRightMax
        ),
        verticalRangeRightMaxValueValid: this.validateNumber(
          this.inputModel.verticalRangeRightMax
        ),
        verticalRangeLeftMaxValid: this.validateRequired(
          this.inputModel.verticalRangeLeftMax
        ),
        verticalRangeLeftMaxValueValid: this.validateNumber(
          this.inputModel.verticalRangeLeftMax
        ),
        detailValid: detailValid,
        targetValueValid: targetValueValid,
        targetValueOverValid: targetValueOverValid,
        targetValueNumValid: targetValueNumValid,
        upperValueValid: upperValueValid,
        upperValueOverValid: upperValueOverValid,
        upperValueNumValid: upperValueNumValid,
        lowerValueValid: lowerValueValid,
        lowerValueOverValid: lowerValueOverValid,
        lowerValueNumValid: lowerValueNumValid,
        limitValueModeValid: limitValueModeValid,
        axisDirectionValid: axisDirectionValid,
        verticalRangeRightValid: verticalRangeRightValid,
        verticalRangeLeftValid: verticalRangeLeftValid,
        valueOverValid: valueOverValid
      };
    },
    validateOnRegistration() {
      const validationResult = this.validateData();

      if (Object.values(validationResult).every(v => v === true)) {
        this.updateEditRecord("name", this.inputModel.name);
        this.updateEditRecord("model", this.inputModel.model);
        this.updateEditRecord(
          "verticalRangeRightMin",
          this.inputModel.verticalRangeRightMin
        );
        this.updateEditRecord(
          "verticalRangeRightMax",
          this.inputModel.verticalRangeRightMax
        );
        this.updateEditRecord(
          "verticalRangeLeftMin",
          this.inputModel.verticalRangeLeftMin
        );
        this.updateEditRecord(
          "verticalRangeLeftMax",
          this.inputModel.verticalRangeLeftMax
        );
        // add #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
        this.inputModel.seriesInfo.forEach((item) =>{
          item.lower_value = Number(item.lower_value);
          item.upper_value = Number(item.upper_value);
          item.target_value = Number(item.target_value);
        });
        // add #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end
        this.updateEditRecord(
          "seriesInfo",
          JSON.stringify(this.inputModel.seriesInfo)
        );
        return true;
      }
      if (!validationResult.nameValid) {
        this.getScopedClassElement("custom-input-required")?.classList?.add("custom-input-invalid");
      }
      //add 装置力が入りません，selectボックスが赤になります
      if (!validationResult.modelValid) {
        const selectElement = resolveRefElement(this, "mySelect")?.querySelector('select')
        const selectStyle = {
          backgroundColor: 'rgba(255, 0, 0, 1)',
          color: "black"
        }
        Object.assign(selectElement.style, selectStyle);
      }
      if (!validationResult.verticalRangeRightMinValid || !validationResult.verticalRangeRightMinValueValid) {
        this.getScopedClassElement("required3")?.classList?.add("input-invalid");
      }
      if (!validationResult.verticalRangeRightMaxValid || !validationResult.verticalRangeRightMaxValueValid) {
        this.getScopedClassElement("required4")?.classList?.add("input-invalid");
      }
      if (!validationResult.verticalRangeRightValid) {
        this.getScopedClassElement("required3")?.classList?.add("input-invalid");
        this.getScopedClassElement("required4")?.classList?.add("input-invalid");
      }
      if (!validationResult.verticalRangeLeftValid) {
        this.getScopedClassElement("required1")?.classList?.add("input-invalid");
        this.getScopedClassElement("required2")?.classList?.add("input-invalid");
      }
      if (!validationResult.verticalRangeLeftMinValid || !validationResult.verticalRangeLeftMinValueValid) {
        this.getScopedClassElement("required1")?.classList?.add("input-invalid");
      }
      if (!validationResult.verticalRangeLeftMaxValid || !validationResult.verticalRangeLeftMaxValueValid) {
        this.getScopedClassElement("required2")?.classList?.add("input-invalid");
      }
      if ( !validationResult.verticalRangeLeftMaxValueValid) {
        this.getScopedClassElement("required2")?.classList?.add("input-invalid");
      }

      //明細
      if ( !validationResult.targetValueValid || !validationResult.targetValueOverValid || !validationResult.targetValueNumValid) {
        this.dataErrList.forEach(e=>{
          this.getScopedClassElement("listRequired1"+e)?.classList?.add("input-invalid");
        })
      }
      if ( !validationResult.upperValueValid || !validationResult.upperValueOverValid || !validationResult.upperValueNumValid) {
        this.dataErrList.forEach(e=>{
          this.getScopedClassElement("listRequired2"+e)?.classList?.add("input-invalid");
        })
      }
      if ( !validationResult.lowerValueValid || !validationResult.lowerValueOverValid || !validationResult.lowerValueNumValid) {
        this.dataErrList.forEach(e=>{
          this.getScopedClassElement("listRequired3"+e)?.classList?.add("input-invalid");
        })
      }
      if (!validationResult.valueOverValid) {
        this.dataErrList.forEach(e=>{
          this.getScopedClassElement("listRequired2"+e)?.classList?.add("input-invalid");
          this.getScopedClassElement("listRequired3"+e)?.classList?.add("input-invalid");
        })
      }
      // メッセージ組み立て
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES['00200100'].title;
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.nameValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "テンプレート名を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200100'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.nameLengthValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "テンプレート名が長すぎます。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200101'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.modelValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "装置を選択して下さい。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200102'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.verticalRangeRightMinValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "縦軸範囲（右）下限値を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000137].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.verticalRangeRightMaxValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "縦軸範囲（右）上限値を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000138].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            validationResult.verticalRangeRightMinValid && !validationResult.verticalRangeRightMinValueValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "縦軸範囲（右）下限値の入力値（桁数）が間違っています。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000139].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            validationResult.verticalRangeRightMaxValid && !validationResult.verticalRangeRightMaxValueValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "縦軸範囲（右）上限値の入力値（桁数）が間違っています。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000140].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.verticalRangeRightValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "縦軸範囲（右）の上限値が下限値より小さいです。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000141].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.verticalRangeLeftValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "縦軸範囲（左）の上限値が下限値より小さいです。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000142].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.verticalRangeLeftMinValid
              // ? "縦軸範囲（左）下限値を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000336].message)
              : ""
          }
          ${
            !validationResult.verticalRangeLeftMaxValid
              // ? "縦軸範囲（左）上限値を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000337].message)
              : ""
          }
           ${
            validationResult.verticalRangeLeftMinValid && !validationResult.verticalRangeLeftMinValueValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "縦軸範囲（左）下限値の入力値（桁数）が間違っています。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000143].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            validationResult.verticalRangeLeftMaxValid && !validationResult.verticalRangeLeftMaxValueValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "縦軸範囲（左）上限値の入力値（桁数）が間違っています。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000144].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.detailValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細行の各項目を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000145].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.limitValueModeValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細の上下限値指定方法を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000146].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.targetValueValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細の目標値を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000147].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.targetValueOverValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細の目標値が基準値を超えてます。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000148].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.targetValueNumValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細の目標値で入力値（桁数）が間違っています<br>"
              ? messageFormat(DIALOG_MESSAGES[12000149].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }

          ${
            !validationResult.upperValueValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細の上限値を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000150].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.upperValueOverValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細の上限値が基準値を超えてます。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000151].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.upperValueNumValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細の上限値の入力値（桁数）が間違っています<br>"
              ? messageFormat(DIALOG_MESSAGES[12000152].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.lowerValueValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細の下限値を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000153].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.lowerValueOverValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細の下限値が基準値を超えてます。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000154].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.lowerValueNumValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細の下限値で入力値（桁数）が間違っています<br>"
              ? messageFormat(DIALOG_MESSAGES[12000155].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.valueOverValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細の上限値が下限値より小さいです。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000156].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.axisDirectionValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "明細の使用縦軸を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES[12000157].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      this.inputModel.seriesInfo = this.temporaryItemList;
      return false;
    },
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    // add #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng start
    getMonitorItemRadius(item, state, type) {
      const cd = item.moni_cd;
      const limitValueMode = item.limit_value_mode;
      const radiusObj = this.getFilteredList(cd);
      if (limitValueMode == 0) {
        if (state == 'min') {
          return radiusObj && radiusObj.minValue != null ? this.getMonitorItemComputedValue(radiusObj.minValue, radiusObj.decPoint) : this.defaultMinValue;
        } else {
          return radiusObj && radiusObj.maxValue != null ? this.getMonitorItemComputedValue(radiusObj.maxValue, radiusObj.decPoint) : this.defaultMaxValue;
        }
      }
      if (limitValueMode == 1) {
        if (state == 'min') {
          return 0;
        }
        let value;
        if (type == 'upper_value') {
          value = this.getMonitorItemComputedValue(radiusObj.maxValue, radiusObj.decPoint);
        } else {
          value = this.getMonitorItemComputedValue(radiusObj.minValue, radiusObj.decPoint);
        }
        let num = new BigNumber(value); 
        return num.times(100).div(item.target_value).minus(100).abs().decimalPlaces(radiusObj.decPoint, BigNumber.ROUND_DOWN).toNumber();
      }
    },
    getTargetRadius(item, state) {
      const cd = item.moni_cd;
      const radiusObj = this.getFilteredList(cd);
      if (state == 'min') {
        return radiusObj && radiusObj.minValue != null ? this.getMonitorItemComputedValue(radiusObj.minValue, radiusObj.decPoint) : this.defaultMinValue;
      } else {
        return radiusObj && radiusObj.maxValue != null ? this.getMonitorItemComputedValue(radiusObj.maxValue, radiusObj.decPoint) : this.defaultMaxValue;
      }
    },
    getMonitorItemStep(cd) {
      const radiusObj = this.getFilteredList(cd);
      return radiusObj && radiusObj.decPoint ? Math.pow(10, -radiusObj.decPoint) : 1;
    },
    getMonitorItemComputedValue(value, decPoint) {
      let num = new BigNumber(value);
      let divisor = new BigNumber(10).pow(decPoint);
      let result = num.dividedBy(divisor).decimalPlaces(decPoint, BigNumber.ROUND_DOWN);
      return result.toNumber();
    }
    // #11047 No5 治療状況透析液調製装置グラフレイアウトマスタ＞詳細 目標値 上限値 下限値 マイナス値で保存できない。linjunfeng end
  }
};
</script>

<style scoped>
@media print{
  .disp-item-content-frame{
    height: auto !important;
  }
}
.disp-item-name-area {
  vertical-align: middle;
  padding-left: 5px;
}

.disp-item-content-area {
  overflow: auto;
  height: 100%;
}

.custom-input-required {
  color: black;
  background-color: #ffff99;
}
.custom-input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.input-required {
  color: black;
  background-color: #ffff99;
}
.input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.disp-item-area {
  width: 100%;
  border-collapse: collapse;
}

.disp-item-area tr {
  height: 30px;
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
/* ラベル */
.item-title {
  flex: 0 0 8em;
  margin-right: 1em;
}
/* ラベル */
.item-title2 {
  margin: 0 0.5em;
}
/* 入力テキスト */
.item-text {
  width: 28em;
}
/* 入力数字 */
.item-numeric {
  width: 10%;
  min-width: 60px;
}
/* 追加ボタン */
.button-container {
  display: flex;
  justify-content: flex-end;
}
.button-add {
  width: 180px;
  margin: 10px 5px 5px 5px;
  font-size: 1em;
}

/* 横並び */
.wrap-block {
  display: flex;
  flex-wrap: nowrap;
  align-items: center;
  margin-bottom: 3px;
}
/* 縦軸範囲の入力欄(外枠) */
.range-input-wrapper {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
}

.graph-list {
  position: relative;
  background-color: inherit;
}

table.graph-list {
  border-collapse: collapse;
}

table.graph-list th,
table.graph-list td {
  border: solid 1px var(--ntss-list-border-color);
}

table.graph-list {
  width: 100%;
  overflow-y: auto
}

table.graph-list thead {
  color: white;
  background-color: var(--ntss-list-header-background-color);
}

table.graph-list thead tr {
  height: 30px;
}

table.graph-list thead tr th.graph-list-header {
  z-index: 1;
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
  position: -webkit-sticky;
  position: sticky;
  top: 0;
}

table.graph-list .graph-list-del {
  width: 3.3%;
  text-align: center;
}

table.graph-list .graph-list-name {
  width: 18%;
}

table.graph-list .graph-list-select {
  width: 8%;
}

table.graph-list .graph-list-numeric {
  width: 12%;
}

table.graph-list tbody tr {
  height: 1.2rem;
}
</style>
