/**
/**
 * 自己診断判定マスタ詳細モーダル
 */
<template>
  <modal-base @onClose="cancel">
        <template #body>
<div class="custom-ons-list-header">
      <div id="self-measure-result-modal-content">
        <!-- 対象機種・バージョン設定 -->
        <div class="target-machine-setting">
          <div class="color-header machine-setting-header">
            <span>対象機種 範囲バージョン</span>
            <v-ons-icon class="header-icon" icon="fa-plus" @click="addRow"></v-ons-icon>
          </div>
          <div class="machine-setting-area-border">
            <table class="machine-area">
              <tr v-for="(column, index) in targetMachineList" :key="index" class="input-row">
                <td>
                  <!-- 機種選択 -->
                  <!--mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 start-->
                  <!-- <v-ons-select
                    select-id="machine-type-cd"
                    v-model="column.type_cd"
                    @change="changeButton"
                  > -->
                  <v-ons-select
                    select-id="machine-type-cd"
                    v-model="column.type_cd"
                  >
                  <!--mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 end-->
                    <option v-for="(item, index) in comboMachineType" :key="index" :value="item.machineTypeCd">
                      {{ item.machineType }}
                    </option>
                  </v-ons-select>
                </td>
                <td>
                  <!-- バージョン下限 -->
                  <v-ons-input type="text" v-model="column.ver_low" v-on:change="changeVerLowTxt(column)" />
                </td>
                <td>
                  <label>～</label>
                </td>
                <td>
                  <!-- バージョン上限 -->
                  <v-ons-input type="text" v-model="column.ver_up" v-on:change="changeVerUpTxt(column)" />
                </td>
                <td>
                  <!-- 行削除 -->
                  <button class="ntss-btn-outset" @click="delRow(index)">
                    <v-ons-icon icon="fa-trash"/>
                  </button>
                </td>
              </tr>
            </table>
          </div>
        </div>

        <!-- 自己診断項目設定 -->
        <div class="self-measure-result-setting">
          <table class="self-measure-result-list">
            <thead>
              <tr>
                <th
                  v-for="column in columns"
                  :key="column.key"
                  class="self-measure-result-list-header"
                  :style="{
                    'min-width': column.width + 'em',
                    'width': column.colName === '自己診断項目' ? '100%' : null
                  }"
                >{{ column.colName }}</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(item, index) in selfMeasureResultList"
                :key="item.jsonAddress"
                :class="index%2 === 0 ? 'even-row' : 'odd-row'"
              >
                <!-- 自己診断種類 -->
                <td>
                  {{ item.type }}
                </td>
                <!-- 自己診断項目 -->
                <td>
                  {{ item.name }}
                </td>
                <!-- 判定 -->
                <td class="check-box">
                  <!--mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 start-->
                  <!-- <v-ons-checkbox v-model="item.judge" @change="changeButton"> -->
                  <v-ons-checkbox v-model="item.judge">
                  <!--mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 end-->
                  </v-ons-checkbox>
                </td>
                <!-- 不合格下限 -->
                <td v-if="!item.isChkOnly">
                  <!--mod #7849-自己診断判定マスタ詳細に表記が不足している 赵 start-->
                  <!--mod #7849-自己診断判定マスタ詳細に表記が不足している 徐博 start-->
                  <!--<v-ons-input type="number" :step="item.step" :min="item.min" :max="item.max" v-model="item.failure_low" @change="changeButton" :disabled="(item.key == 43 || item.key == 48 || item.key == 45 || item.key == 49)">-->
                  <!-- <v-ons-input
                    type="number"
                    :precision="0.1"
                    :step="item.step"
                    :min="item.min"
                    :max="item.max"
                    v-model="item.failure_low"
                    @blur="item.failure_low = numChange(item.failure_low)"
                    @change="item.failure_low = numChange(item.failure_low), buttonFlag = false"
                    :disabled="(item.key == 43 || item.key == 48 || item.key == 45 || item.key == 49)"
                  > -->
                  <!-- <v-ons-input
                    type="number"
                    :precision="0.1"
                    :step="item.step"
                    :min="item.min"
                    :max="item.max"
                    v-model="item.failure_low"
                    @blur="item.failure_low = numChange(item,3)"
                    @change="item.failure_low = numChange(item,3), buttonFlag = false"
                    :disabled="(item.key == 43 || item.key == 48 || item.key == 45 || item.key == 49)"
                  > -->
                  <!--mod #7849-自己診断判定マスタ詳細に表記が不足している 徐博 end-->
                  <custom-input-number-pro
                    :key="item.key + 'failure_low'"
                    :value="item.failure_low"
                    :min="item.min"
                    :max="item.max"
                    :step="item.step"
                    class="custom-input-number"
                    :disabled="(item.key == 43 || item.key == 48 || item.key == 45 || item.key == 49)"
                    @handlerInput="(val) => { item.failure_low = val }"
                    @blur="handleBlur($event, item, 'failure_low')"
                  />
                </td>
                <!-- 注意点下限 -->
                <td v-if="!item.isChkOnly">
                  <!--mod #7849-自己診断判定マスタ詳細に表記が不足している 徐博 start-->
                  <!--<v-ons-input type="number" :step="item.step" :min="item.min" :max="item.max" v-model="item.caution_low" @change="changeButton" :disabled="(item.key == 43 || item.key == 48 || item.key == 45 || item.key == 49)">-->
                  <!-- <v-ons-input
                    type="number"
                    :step="item.step"
                    :min="item.min"
                    :max="item.max"
                    v-model="item.caution_low"
                    @blur="item.caution_low = numChange(item.caution_low)"
                    @change="item.caution_low = numChange(item.caution_low), buttonFlag = false"
                    :disabled="(item.key == 43 || item.key == 48 || item.key == 45 || item.key == 49)"
                  > -->
                  <!-- mod #5589 2023/03/28 数値IFのスタイル全不正 張博 start -->
                  <!-- <v-ons-input
                    type="number"
                    :step="item.step"
                    :min="item.min"
                    :max="item.max"
                    v-model="item.caution_low"
                    @blur="item.caution_low = numChange(item,4)"
                    @change="item.caution_low = numChange(item,4), buttonFlag = false"
                    :disabled="(item.key == 43 || item.key == 48 || item.key == 45 || item.key == 49)"
                  > -->
                  <!--mod #7849-自己診断判定マスタ詳細に表記が不足している 徐博 end-->
                  <custom-input-number-pro
                    :key="item.key + 'caution_low'"
                    :value="item.caution_low"
                    :min="!isNaN(item.failure_low) ? parseFloat(item.failure_low) : item.min"
                    :max="item.max"
                    :step="item.step"
                    class="custom-input-number"
                    :disabled="(item.key == 43 || item.key == 48 || item.key == 45 || item.key == 49)"
                    @handlerInput="(val) => { item.caution_low = val }"
                  />
                </td>
                <!-- 注意点上限 -->
                <td v-if="!item.isChkOnly">
                  <!--mod #7849-自己診断判定マスタ詳細に表記が不足している 徐博 start-->
                  <!--mod #7849-自己診断判定マスタ詳細に表記が不足している 赵 start-->
                  <!--<v-ons-input type="number" :step="item.step" :min="item.min" :max="item.max" v-model="item.caution_up" @change="changeButton" :disabled="(item.key == 44 || item.key == 53 || item.key == 54)">-->
                  <!-- <v-ons-input
                    type="number"
                    :step="item.step"
                    :min="item.min"
                    :max="item.max"
                    v-model="item.caution_up"
                    @blur="item.caution_up = numChange(item.caution_up)"
                    @change="item.caution_up = numChange(item.caution_up), buttonFlag = false"
                    :disabled="(item.key == 44 || item.key == 53 || item.key == 54)"
                  > -->
                  <!-- mod #5589 2023/03/28 数値IFのスタイル全不正 張博 start -->
                  <!-- <v-ons-input
                    type="number"
                    :step="item.step"
                    :min="item.min"
                    :max="item.max"
                    v-model="item.caution_up"
                    @blur="item.caution_up = numChange(item,5)"
                    @change="item.caution_up = numChange(item,5), buttonFlag = false"
                    :disabled="(item.key == 44 || item.key == 53 || item.key == 54)"
                  > -->
                  <!--mod #7849-自己診断判定マスタ詳細に表記が不足している 徐博 end-->
                  <custom-input-number-pro
                    :key="item.key + 'caution_up'"
                    :value="item.caution_up"
                    :min="item.min"
                    :max="!isNaN(item.failure_up) ? parseFloat(item.failure_up) : item.max"
                    :step="item.step"
                    class="custom-input-number"
                    :disabled="(item.key == 44 || item.key == 53 || item.key == 54)"
                    @handlerInput="(val) => { item.caution_up = val }"
                  />
                </td>
                <!-- 不合格上限 -->
                <td v-if="!item.isChkOnly">
                  <!--mod #7849-自己診断判定マスタ詳細に表記が不足している 赵 start-->
                  <!--mod #7849-自己診断判定マスタ詳細に表記が不足している 徐博 start-->
                  <!--<v-ons-input type="number" :step="item.step" :min="item.min" :max="item.max" v-model="item.failure_up" @change="changeButton" :disabled="(item.key == 44 || item.key == 53 || item.key == 54)">-->
                  <!-- <v-ons-input
                    type="number"
                    :step="item.step"
                    :min="item.min"
                    :max="item.max"
                    v-model="item.failure_up"
                    @blur="item.failure_up = numChange(item.failure_up)"
                    @change="item.failure_up = numChange(item.failure_up), buttonFlag = false"
                    :disabled="(item.key == 44 || item.key == 53 || item.key == 54)"
                  > -->
                  <!-- mod #5589 2023/03/28 数値IFのスタイル全不正 張博 start -->
                  <!-- <v-ons-input
                    type="number"
                    :step="item.step"
                    :min="item.min"
                    :max="item.max"
                    v-model="item.failure_up"
                    @blur="item.failure_up = numChange(item,6)"
                    @change="item.failure_up = numChange(item,6), buttonFlag = false"
                    :disabled="(item.key == 44 || item.key == 53 || item.key == 54)"
                  > -->
                  <custom-input-number-pro
                    :key="item.key + 'failure_up'"
                    :value="item.failure_up"
                    :min="item.min"
                    :max="item.max"
                    :step="item.step"
                    class="custom-input-number"
                    :disabled="(item.key == 44 || item.key == 53 || item.key == 54)"
                    @handlerInput="(val) => { item.failure_up = val }"
                    @blur="handleBlur($event, item, 'failure_up')"
                  />
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    </template>
        <template #footer>
<div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="btn2-cancel denial-btn" @click="cancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button :disabled="buttonFlag" class="common-style-select-button registration-btn" @click="registration">確定</v-ons-button>
      </div>
    </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import _ from "@/compat/collections/lodash";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { MACHINE_MODEL } from "@/constants/machineModel";
import { UFRC, BLOOD_LEAKAGE, DIALYSATE_FLOW_RATE, CONCENTRATION } from "@/constants/mstSelfMeasureResultDefine";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end
import { EventBus } from "@/compat/vue/event-bus.js";
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro"
import BigNumber from "@/compat/number/bignumber";
import { toFixed } from "@/functions/common/NumberFunctions";

export default {
  name: "MstSelfMeasureResultMainModal",
  components: {
    "modal-base": ModalBase,
    "custom-input-number-pro":CustomInputNumberPro,
  },
  data() {
    return {
      // 列情報
      // key : キー
      // colName : 列名
      // width : 列幅(em指定) ※指定しない場合は自動で幅が調整される
      columns: [
        {
          key: "type",
          colName: "自己診断種類",
          width: 10
        },
        {
          key: "item",
          colName: "自己診断項目",
          width: 12
        },
        {
          key: "judge",
          colName: "判定",
          width: 3
        },
        {
          key: "failure_low",
          colName: "不合格下限",
          width: 6
        },
        {
          key: "caution_low",
          colName: "注意点下限",
          width: 6
        },
        {
          key: "caution_up",
          colName: "注意点上限",
          width: 6
        },
        {
          key: "failure_up",
          colName: "不合格上限",
          width: 6
        }
      ],
      // 対象機種+バージョンの一覧
      targetMachineList: [],
      // 対象機種+バージョンの一覧(編集前値)
      targetMachineListDefault: [],
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 start
      targetMachineListNew:[],
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 end
      // 型式一覧
      comboMachineType: [],
      // 自己診断情報一覧
      selfMeasureResultList: [],
      // 自己診断情報一覧(編集前値)
      selfMeasureResultListDefault: [],
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 start
      selfMeasureResultListNew:[],
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 end
      // 初期データ
      initMasterRecordList: [],
      buttonFlag: true,
    };
  },
  computed: {
    ...mapGetters("master-maintenance", [
      "getEditRecord",
      "getMasterRecordList"
    ]),
    ...mapGetters("mst-self-measure-result", [
      "getMachineTypeList"
    ])
  },
  watch: {
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 start
    targetMachineList: {
      handler(val) {
        console.log(val);
        this.targetMachineListNew = val;
        if(JSON.stringify(val) !== JSON.stringify(this.targetMachineListDefault)
         || JSON.stringify(this.selfMeasureResultListNew) !== JSON.stringify(this.selfMeasureResultListDefault)){
          this.buttonFlag = false;
        } else {
          this.buttonFlag = true;
        }
      },
      immediate:true,
      deep:true
    },
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 start
    selfMeasureResultList:{
      handler(val) {
        this.selfMeasureResultListNew = val;
        if(JSON.stringify(val) !== JSON.stringify(this.selfMeasureResultListDefault) 
         || JSON.stringify(this.targetMachineListNew) !== JSON.stringify(this.targetMachineListDefault) ){
          this.buttonFlag = false;
        } else{
          this.buttonFlag = true;
        }
      },
      immediate:true,
      deep:true
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 end
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("master-maintenance", [
      "setEditRecord",
      "editRecordBeEmpty",
      "setMasterRecordList"
    ]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),

    /**
     * @description 対象機種追加ボタン押下時の処理
     */
    makeDispData() {
      // 対象機種
      this.targetMachineList = JSON.parse(this.getEditRecord.machineInfo);
      // 対象機種一覧の編集前値を保持
      this.targetMachineListDefault = deepCopy(this.targetMachineList);

      // 自己診断情報
      const arrEditResult = JSON.parse(this.getEditRecord.selfMeasureResult);
      // 配管自己診断結果
      for(let idx = 0; idx < UFRC.length; idx++) {
        const item = UFRC[idx];
        const editItem = arrEditResult.find(result =>
          result.key == item.jsonAddress
        );
        if (editItem) {
          if (editItem.key == 43 || editItem.key == 48 || editItem.key == 45 || editItem.key == 49) {
            editItem.failure_low = "";
            editItem.caution_low = "";
          }
          if (editItem.key + "" === 44 + "" || editItem.key + "" === 53 + "" || editItem.key + "" === 54 + "") {
            editItem.caution_up = "";
            editItem.failure_up = "";
          }
          editItem.type = item.type;
          editItem.name = item.name;
          editItem.judge = editItem.judge === "1";
          editItem.isChkOnly = item.isCheckOnly;
          editItem.step = item.step;
          editItem.min = item.input_min;
          editItem.max = item.input_max;
          this.selfMeasureResultList.push(editItem);
        } else {
          const emptyItem = {
            key: item.jsonAddress,
            type: item.type,
            name: item.name,
            judge: false,
            // mod bug 8080 修正 chen start
            failure_low: (item.jsonAddress == 43 || item.jsonAddress == 48 || item.jsonAddress == 45 || item.jsonAddress == 49) ? "" : item.default_failure_low,
            caution_low: (item.jsonAddress == 43 || item.jsonAddress == 48 || item.jsonAddress == 45 || item.jsonAddress == 49) ? "" : item.default_caution_low,
            caution_up: (item.jsonAddress + "" === 44 + "" || item.jsonAddress + "" === 53 + "" || item.jsonAddress + "" === 54 + "") ? "" : item.default_caution_up,
            failure_up: (item.jsonAddress + "" === 44 + "" || item.jsonAddress + "" === 53 + "" || item.jsonAddress + "" === 54 + "") ? "" : item.default_failure_up,
            // mod bug 8080 修正 chen end
            isChkOnly: item.isCheckOnly,
            step: item.step,
            min: item.input_min,
            max: item.input_max
          };
          this.selfMeasureResultList.push(emptyItem);
        }
      }
      // 漏血自己診断結果
      for(let idx = 0; idx < BLOOD_LEAKAGE.length; idx++) {
        const item = BLOOD_LEAKAGE[idx];
        const editItem = arrEditResult.find(result =>
          result.key == item.jsonAddress
        );
        if (editItem){
          if (editItem.key + "" === 44 + "" || editItem.key + "" === 53 + "" || editItem.key + "" === 54 + "") {
            editItem.caution_up = "";
            editItem.failure_up = "";
          }
          editItem.type = item.type;
          editItem.name = item.name;
          editItem.judge = editItem.judge === "1";
          editItem.isChkOnly = item.isCheckOnly;
          editItem.step = item.step;
          editItem.min = item.input_min;
          editItem.max = item.input_max;
          this.selfMeasureResultList.push(editItem);
        } else {
          const emptyItem = {
            key: item.jsonAddress,
            type: item.type,
            name: item.name,
            judge: false,
            // mod bug 8080 修正 chen start
            failure_low: (item.jsonAddress == 43 || item.jsonAddress == 48 || item.jsonAddress == 45 || item.jsonAddress == 49) ? "" : item.default_failure_low,
            caution_low: (item.jsonAddress == 43 || item.jsonAddress == 48 || item.jsonAddress == 45 || item.jsonAddress == 49) ? "" : item.default_caution_low,
            caution_up: (item.jsonAddress + "" === 44 + "" || item.jsonAddress + "" === 53 + "" || item.jsonAddress + "" === 54 + "") ? "" : item.default_caution_up,
            failure_up: (item.jsonAddress + "" === 44 + "" || item.jsonAddress + "" === 53 + "" || item.jsonAddress + "" === 54 + "") ? "" : item.default_failure_up,
            // mod bug 8080 修正 chen end
            isChkOnly: item.isCheckOnly,
            step: item.step,
            min: item.input_min,
            max: item.input_max
          };
          this.selfMeasureResultList.push(emptyItem);
        }
      }
      // 透析液流量自己診断結果
      for(let idx = 0; idx < DIALYSATE_FLOW_RATE.length; idx++) {
        const item = DIALYSATE_FLOW_RATE[idx];
        const editItem = arrEditResult.find(result =>
          result.key == item.jsonAddress
        );
        if (editItem){
          editItem.type = item.type;
          editItem.name = item.name;
          editItem.judge = editItem.judge === "1";
          editItem.isChkOnly = item.isCheckOnly;
          editItem.step = item.step;
          editItem.min = item.input_min;
          editItem.max = item.input_max;
          this.selfMeasureResultList.push(editItem);
        } else {
          const emptyItem = {
            key: item.jsonAddress,
            type: item.type,
            name: item.name,
            judge: false,
            // mod bug 8080 修正 chen start
            failure_low: (item.jsonAddress == 43 || item.jsonAddress == 48 || item.jsonAddress == 45 || item.jsonAddress == 49) ? "" : item.default_failure_low,
            caution_low: (item.jsonAddress == 43 || item.jsonAddress == 48 || item.jsonAddress == 45 || item.jsonAddress == 49) ? "" : item.default_caution_low,
            caution_up: (item.jsonAddress + "" === 44 + "" || item.jsonAddress + "" === 53 + "" || item.jsonAddress + "" === 54 + "") ? "" : item.default_caution_up,
            failure_up: (item.jsonAddress + "" === 44 + "" || item.jsonAddress + "" === 53 + "" || item.jsonAddress + "" === 54 + "") ? "" : item.default_failure_up,
            // mod bug 8080 修正 chen end
            isChkOnly: item.isCheckOnly,
            step: item.step,
            min: item.input_min,
            max: item.input_max
          };
          this.selfMeasureResultList.push(emptyItem);
        }
      }
      // 濃度自己診断結果
      for(let idx = 0; idx < CONCENTRATION.length; idx++) {
        const item = CONCENTRATION[idx];
        const editItem = arrEditResult.find(result =>
          result.key == item.jsonAddress
        );
        if (editItem){
          editItem.type = item.type;
          editItem.name = item.name;
          editItem.judge = editItem.judge === "1";
          editItem.isChkOnly = item.isCheckOnly;
          editItem.step = item.step;
          editItem.min = item.input_min;
          editItem.max = item.input_max;
          this.selfMeasureResultList.push(editItem);
        } else {
          const emptyItem = {
            key: item.jsonAddress,
            type: item.type,
            name: item.name,
            judge: false,
            // mod bug 8080 修正 chen start
            failure_low: (item.jsonAddress == 43 || item.jsonAddress == 48 || item.jsonAddress == 45 || item.jsonAddress == 49) ? "" : item.default_failure_low,
            caution_low: (item.jsonAddress == 43 || item.jsonAddress == 48 || item.jsonAddress == 45 || item.jsonAddress == 49) ? "" : item.default_caution_low,
            caution_up: (item.jsonAddress + "" === 44 + "" || item.jsonAddress + "" === 53 + "" || item.jsonAddress + "" === 54 + "") ? "" : item.default_caution_up,
            failure_up: (item.jsonAddress + "" === 44 + "" || item.jsonAddress + "" === 53 + "" || item.jsonAddress + "" === 54 + "") ? "" : item.default_failure_up,
            // mod bug 8080 修正 chen end
            isChkOnly: item.isCheckOnly,
            step: item.step,
            min: item.input_min,
            max: item.input_max
          };
          this.selfMeasureResultList.push(emptyItem);
        }
      }

      // 自己診断情報の編集前値を保持
      this.selfMeasureResultListDefault = deepCopy(this.selfMeasureResultList);
    },
    handleBlur(e, item, field){
      // 注意点下限、注意点上限の値補正
      // ** 注意点下限は不合格下限よりも低く設定不可
      // ** 注意点上限は不合格上限よりも高く設定不可
      let inputValue = e.target.value;
      const cautionLow = parseFloat(item.caution_low);
      const cautionUp = parseFloat(item.caution_up);
      if (inputValue > item.max) {
        inputValue = item.max;
      } else if (inputValue < item.min) {
        inputValue = item.min;
      }
      const value = parseFloat(inputValue);
    
      if (isNaN(value)) return;
    
      const updateIfValid = (condition, key, value) => {
        if (condition) item[key] = toFixed(value, BigNumber(item.step).decimalPlaces()); // 小数部桁数を補正
      };
      
      if (field === "failure_low") {
        updateIfValid(value > cautionLow && !isNaN(cautionLow), "caution_low", inputValue);
      } else if (field === "failure_up") {
        updateIfValid(value < cautionUp && !isNaN(cautionUp), "caution_up", inputValue);
      }   
    },
    // mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start

    /**
     * @description 対象機種追加ボタン押下時の処理
     */
    addRow() {
      const newItem = {
        "type_cd": -1,
        "ver_low": "",
        "ver_up": ""
      };
      this.targetMachineList.push(newItem);
    },

    /**
     * @description 対象機種削除ボタン押下時の処理
     */
    delRow(index) {
      this.targetMachineList.splice(index, 1);
    },

    /**
     * @description 保存ボタン押下時処理
     */
    async registration() {
      const valRes = await this.validateData();
      if (valRes.isErr) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "警告",
          title: DIALOG_MESSAGES[12000128].title,
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          message: valRes.errMsg
        })
        return;
      }

      if (this.chkDupVer()) {
        // バージョンチェックで重複有りの場合
        const resOk = await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "確認",
          title: DIALOG_MESSAGES[13000097].title,
          // message: "対象機種の範囲バージョン指定に重複が存在します。<br>このまま登録しますか？"
          message: messageFormat(DIALOG_MESSAGES[13000097].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        });
        if (resOk !== 1) {
          return;
        }
      }

      // 対象機種名の作成
      let newDispMachineName = "";
      this.targetMachineList.forEach(machine => {
        const machineTypInf = this.comboMachineType.find(machineType =>
          machineType.machineTypeCd === machine.type_cd
        );
        if (machine.ver_low === "" && machine.ver_up === "") {
          // バージョンの入力がない場合
          newDispMachineName += machineTypInf.machineType + "\n";
        } else {
          newDispMachineName += machineTypInf.machineType + " " + machine.ver_low + " ～ " + machine.ver_up + "\n";
        }
      });

      // 自己診断情報の作成
      let newSelfMeasureResult = [];
      this.selfMeasureResultList.forEach(result => {
        let editResult = _.omit(result, "type", "name", "isChkOnly", "step", "min", "max");
        // add bug 8080 修正 chen start
        editResult.caution_low = result.caution_low === "NaN" ? "0": result.caution_low;
        editResult.caution_up = result.caution_up === "NaN" ? "0": result.caution_up;
        editResult.failure_low = result.failure_low === "NaN" ? "0": result.failure_low;
        editResult.failure_up = result.failure_up === "NaN" ? "0": result.failure_up;
        // add bug 8080 修正 chen end
        editResult.judge = result.judge ? "1": "0";
        newSelfMeasureResult.push(editResult);
      });

      // 編集中マスタを更新
      this.setEditRecord({
        ...this.getEditRecord,
        dispMachineName: newDispMachineName,
        selfMeasureResult: JSON.stringify(newSelfMeasureResult),
        machineInfo: JSON.stringify(this.targetMachineList)
      });

      const masterRecordList = this.getMasterRecordList;

      // state.editRecordを取得
      const editedRecord = this.getEditRecord;
      // operationがないときは編集とみなす
      if (!editedRecord.operation) {
        editedRecord.operation = 2;
      } else if (editedRecord.operation === 1) {
        // "追加"の場合は、"編集済"フラグを立てる
        editedRecord.edited = true;
      }

      // state.masterRecordListにマージ
      const index = masterRecordList.data.findIndex(
        masterRecord => String(masterRecord.code) === String(editedRecord.code)
      );
      if (index >= 0) {
        editedRecord.code = masterRecordList.data[index].code;
        masterRecordList.data[index] = editedRecord;
      }

      // TODO: 対症療法的なので直したい。
      // 配列の要素を入れ替えただけでは、「stateの変更」とみなしてくれず、一覧が再描画されなかった。
      // state.masterRecordListをwatchする（？）
      if (index >= 0 && !this.validationValueChange(this.initMasterRecordList[index], masterRecordList.data[index])) {
        this.setMasterRecordList(undefined);
      }
      this.setMasterRecordList(masterRecordList);
      this.closeModalWindow();
    },
    /**
     * @description 値が変化したかどうかを判断する。
     * @return boolean もし変化が起こったらtrueに戻ります。そうでなければfalseに戻ります。
     */
    validationValueChange(oldData, newData){
      oldData.machineInfo = JSON.stringify(JSON.parse(oldData.machineInfo))
      newData.machineInfo = JSON.stringify(JSON.parse(newData.machineInfo))
      oldData.selfMeasureResult = JSON.stringify(JSON.parse(oldData.selfMeasureResult))
      newData.selfMeasureResult = JSON.stringify(JSON.parse(newData.selfMeasureResult))
      return oldData.dispMachineName === newData.dispMachineName &&
        oldData.machineInfo === newData.machineInfo &&
        oldData.selfMeasureResult === newData.selfMeasureResult;
    },
    /**
     * @description 入力内容チェック
     * @return チェック結果(isErr: エラー有無、errMsg: 出力するエラーメッセージ)
     */
    validateData() {
      var chkRes = {
        isErr: false,
        errMsg: ""
      };

      // 対象機種が0件の場合はエラー
      if (this.targetMachineList.length === 0){
        chkRes.isErr = true;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // chkRes.errMsg = "対象機種 範囲バージョンが未指定です。<br>1件以上登録してください。";
        chkRes.errMsg = messageFormat(DIALOG_MESSAGES[12000128].message);
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        return chkRes;
      }

      // 対象機種が未選択の場合はエラー
      for (let idx = 0; idx < this.targetMachineList.length; idx++){
        if (this.targetMachineList[idx].type_cd === -1) {
          chkRes.isErr = true;
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // chkRes.errMsg = "対象機種が未選択の行があります。";
          chkRes.errMsg = messageFormat(DIALOG_MESSAGES[12000129].message);
           // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          return chkRes;
        }
      }

      return chkRes;
    },

    /**
     * @description 対象機種・範囲バージョンチェック
     * @return true: バージョン被りあり、false:バージョン被りなし
     */
    chkDupVer() {
      // 対象機種の配列を作成
      const arrMacihneType = [];
      this.targetMachineList.forEach(machineType => {
        if (!arrMacihneType.includes(machineType.type_cd)) {
          arrMacihneType.push(machineType.type_cd);
        }
      });

      // 対象機種毎に入力されたバージョンに被りがないかチェック
      let isDuplicate = false;
      arrMacihneType.forEach(machineTypeCd => {
        if (!isDuplicate) {
          // 編集中のレコード
          let arrMachineInf = this.targetMachineList.filter(machine =>
            machine.type_cd === machineTypeCd
          );

          // その他レコード
          this.getMasterRecordList.data.forEach(masterRecord => {
            // mod #9228 削除したデータは重複チェックする必要ない。 dengshen start
            // if (masterRecord.code !== this.getEditRecord.code) {
            if (masterRecord.code !== this.getEditRecord.code && masterRecord.isDisp != "0") {
            // mod #9228 削除したデータは重複チェックする必要ない。 dengshen end
              // 編集中レコード以外が対象
              const arrMasterMachineInfo = JSON.parse(masterRecord.machineInfo);
              if (arrMasterMachineInfo) {
                // 他レコードの機種情報を追加する
                arrMachineInf = arrMachineInf.concat(arrMasterMachineInfo.filter(machine => machine.type_cd === machineTypeCd));
              }
            }
          });

          let arrVerInf = [];
          for (let idx = 0; idx < arrMachineInf.length; idx++){
            const machineInf = arrMachineInf[idx];

            // 各行でバージョン被りがないか1件ずつチェック
            for (let idx2 = 0; idx2 < arrVerInf.length; idx2++){
              const chkVerLow = arrVerInf[idx2].low;
              const chkVerUp = arrVerInf[idx2].up;
              if (chkVerLow === "" && chkVerUp === "") {
                // 全バージョンがチェック対象となっている場合
                isDuplicate = true;
                break;
              } else if (chkVerLow === "" && chkVerUp !== "") {
                // 最大バージョンのみ指定の場合(『～ verXXX』 の場合)
                if (machineInf.ver_low === "" || machineInf.ver_low <= chkVerUp) {
                  isDuplicate = true;
                  break;
                }
              } else if (chkVerLow !== "" && chkVerUp === "") {
                // 最小バージョンのみ指定の場合(『verXXX ～』 の場合)
                if (machineInf.ver_up === "" || machineInf.ver_up >= chkVerLow) {
                  isDuplicate = true;
                  break;
                }
              } else {
                // 最大・最小バージョンが指定されている場合
                if (machineInf.ver_low === "" && machineInf.ver_up === "") {
                  // チェック対象行の全バージョンが対象となっている場合
                  isDuplicate = true;
                  break;
                } else if (machineInf.ver_low === "" && machineInf.ver_up >= chkVerLow) {
                  // チェック対象行の最大バージョンのみ指定されている場合
                  isDuplicate = true;
                  break;
                } else if (machineInf.ver_up === "" && machineInf.ver_low <= chkVerUp) {
                  // チェック対象行の最小バージョンのみ指定されている場合
                  isDuplicate = true;
                  break;
                } else if (machineInf.ver_low !== "" && machineInf.ver_up !== "") {
                  // チェック対象行の最大・最小バージョンが指定されている場合
                  if (machineInf.ver_up >= chkVerLow && machineInf.ver_low <= chkVerUp ){
                    isDuplicate = true;
                    break;
                  }
                }
              }
            }

            if (isDuplicate) {
              // バージョン被りあり→ここでチェック終了
              break;
            } else {
              // バージョン被りなし→次の行チェック
              arrVerInf.push({"low": machineInf.ver_low, "up": machineInf.ver_up});
            }
          }
        }
      });

      return isDuplicate;
    },

    /**
     * @description キャンセルボタン押下時処理
     */
    cancel() {
      const isChange = (JSON.stringify(this.targetMachineListDefault) !== JSON.stringify(this.targetMachineList))
        || (JSON.stringify(this.selfMeasureResultListDefault) !== JSON.stringify(this.selfMeasureResultList));

      // 編集がある場合はメッセージを表示
      if (isChange) {
        this.$ons.notification.confirm({
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 1) {
              //OK
              this.closeModalWindow();
            }
          }
        });
      } else {
        this.closeModalWindow();
      }
    },

    /**
     * モーダル画面を閉じる処理
     */
    closeModalWindow() {
      EventBus.$emit("onCloseMasterEditModal");
      // state.editRecordを空にする
      this.editRecordBeEmpty();
      this.hideModal();
    },
    /**
     * バージョン入力欄の値入力時処理
     */
    changeVerLowTxt(target) {
      let str = target.ver_low;
      str = str.replace(/[^A-Za-z\d -~]/g, "");
      target.ver_low = str;
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 start
      // this.buttonFlag = false;
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 end
    },
    /**
     * バージョン入力欄の値入力時処理
     */
    changeVerUpTxt(target) {
      let str = target.ver_up;
      str = str.replace(/[^A-Za-z\d -~]/g, "");
      target.ver_up = str;
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 start
      // this.buttonFlag = false;
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 end
    },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 start
    // changeButton() {
    //   this.buttonFlag = false;
    // }
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 end
    
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.initMasterRecordList = deepCopy(this.getMasterRecordList.data);

    // 機種リストのデータを取得
    this.comboMachineType = this.getMachineTypeList.filter(machine =>
      (machine.model === MACHINE_MODEL.PERSONAL || machine.model === MACHINE_MODEL.DCS) && machine.machineTypeCd < 310
    );
    // add #7849-自己診断判定マスタ詳細に表記が不足している 徐博 start
    let arrList = []
    for (const val of this.comboMachineType) {
      arrList.push(val["machineType"])
    }
    for (const arr of this.getMachineTypeList) {
      if(Object.prototype.hasOwnProperty.call(arr, "model") === false) {
        // mod #7849-自己診断判定マスタ詳細に表記が不足している 赵 start
        // if (!arrList.includes(arr["dispMachineName"].split(" ")[0])) {
        // if (!arrList.includes(arr["dispMachineName"].split(" ")[0].replace(/[\r\n]/g, "").replace(/\ +/g, ""))) {
        // // mod #7849-自己診断判定マスタ詳細に表記が不足している 徐博 end
        //   this.comboMachineType.push(
        //     {
        //       machineType: arr["dispMachineName"].split(" ")[0],
        //       machineTypeCd: arr["selfMeasureResultCd"]
        //     }
        //   )
        // }
        if(arr["dispMachineName"] != null){
        if (!arrList.includes(arr["dispMachineName"].split(" ")[0].replace(/[\r\n]/g, "").replace(/ +/g, ""))) {
          this.comboMachineType.push(
            {
              machineType: arr["dispMachineName"].split(" ")[0],
              machineTypeCd: arr["selfMeasureResultCd"]
            }
          )
        }
        }
      }
    }
    // add #7849-自己診断判定マスタ詳細に表記が不足している 赵 end
    // 自己診断情報を編集用データに加工
    this.makeDispData();
  },
  mounted() {
    setTimeout(() => {
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 start
      // this.buttonFlag = true;
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 張玲 2024/01/04 end
      this.setLoadingScreenVisible(false);
    }, 200);
  }
};
</script>

<style scoped>
#self-measure-result-modal-content {
  padding-left: 20px;
}
.target-machine-setting {
  margin-top: 10px;
  margin-bottom: 20px;
  margin-right: 20px;
}
.machine-setting-header {
  background-color: var(--ntss-list-header-background-color);
  text-align: left;
  margin-bottom: 1.5px;
}
.header-icon {
  float: right;
  margin-right: 4px;
}
.machine-setting-area-border {
  border: solid 1px var(--ntss-list-border-color);
  border-top-style: hidden;
  margin: 1px 0px 1px 0px;
  overflow-x: auto;
}
table.machine-area {
  width: 45em;
  border-collapse: separate;
  border-spacing: 10px 10px;
}
table.machine-area tr.input-row {
  margin: 2px 0;
}
.input-item-name {
  padding-inline-start: 0.5em;
  font-size: 1.0em;
  color: #ffffff;
  background-color: var(--ntss-list-header-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}
.input-item-icon {
  float: right;
}
.input-item-version {
  width: 5em;
}
.check-box {
  width: 1rem;
  white-space: normal;
  text-align: center;
}
.self-measure-result-setting {
  overflow-x: auto;
}
table.self-measure-result-list {
  width: calc(100% - 20px);
  border: solid 1px var(--ntss-list-border-color);
}
table.self-measure-result-list thead {
  color: white;
  background-color: var(--ntss-list-header-background-color);
}
table.self-measure-result-list thead tr th.self-measure-result-list-header {
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
}
table.self-measure-result-list tbody tr.even-row {
  background-color: var(--ntss-list-item-background-color);
}
table.self-measure-result-list tbody tr.odd-row {
  background-color: var(--ntss-list-content-2nd-background-color);
}
</style>
