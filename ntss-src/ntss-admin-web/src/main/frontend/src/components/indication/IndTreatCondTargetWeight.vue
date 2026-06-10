/** * 治療条件ー目標体重 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row class="action-condition-target-weight"> -->
    <v-ons-row class="action-condition-target-weight" :class="getIsUseFlagWeight ? 'cell-disabled' : ''" >
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">
      目標体重
    </v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <v-ons-row>
        <v-ons-row>
          <!-- mod 8204 周安寧 start -->
          <!-- <custom-radio
            :value="targetWeightValue"
            :name="'treatCondTargetWeightRadio'"
            :radio-value="0"
            @change="changeButton()"
          >DWと同じ
          </custom-radio>
          <custom-radio
            :value="targetWeightValue"
            :name="'treatCondTargetWeightRadio'"
            :radio-value="1"
            @change="changeButton()"
          >指定する
          </custom-radio> -->
          <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
          <!-- <custom-radio
            :value="targetWeightValue"
            :name="'treatCondTargetWeightRadio'"
            :radio-value="0"
            :disabled="getIsUseFlagWeight"
            @change="changeButton()"
          >DWと同じ -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <custom-radio -->
          <!--   :value="targetWeightValue" -->
          <!--   :name="'treatCondTargetWeightRadio'" -->
          <!--   :radio-value="0" -->
          <!--   :disabled="getIsUseFlagWeight" -->
          <!-- >DWと同じ -->
          <custom-radio
            :value="targetWeightValue"
            :name="'treatCondTargetWeightRadio'"
            :radio-value="0"
            :disabled="getIsUseFlagWeight || !getItemAuthorized('Indication', 'default_authority')"
          >DWと同じ
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
          </custom-radio>
          <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
          <!-- <custom-radio
            :value="targetWeightValue"
            :name="'treatCondTargetWeightRadio'"
            :radio-value="1"
            :disabled="getIsUseFlagWeight"
            @change="changeButton()"
          >指定する -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <custom-radio -->
          <!--   :value="targetWeightValue" -->
          <!--   :name="'treatCondTargetWeightRadio'" -->
          <!--   :radio-value="1" -->
          <!--   :disabled="getIsUseFlagWeight" -->
          <!-- >指定する -->
          <custom-radio
            :value="targetWeightValue"
            :name="'treatCondTargetWeightRadio'"
            :radio-value="1"
            :disabled="getIsUseFlagWeight || !getItemAuthorized('Indication', 'default_authority')"
          >指定する
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
          </custom-radio>
          <!-- mod 8204 周安寧 end -->
        </v-ons-row>
        <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
        <!-- <v-ons-row class="action-condition-row"> -->
        <v-ons-row class="action-condition-row" v-if="!this.getWeightMode.isWeightMode">
        <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
          <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
          <!-- <custom-input-number
            :value="displayInputValue"
            :disabled="targetWeightDisabled"
            :digits="5"
            :decimal-digits="2"
            :min-value="0.0"
            :max-value="300.0"
            class="action-condition-input"
            @blur="checkNullInput"
            style="width: 90px"
            @change="changeButton()"
          /> -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <custom-input-number -->
          <!--   :value="displayInputValue" -->
          <!--   :disabled="targetWeightDisabled" -->
          <!--   :digits="5" -->
          <!--   :decimal-digits="2" -->
          <!--   :min-value="0.0" -->
          <!--   :max-value="300.0" -->
          <!--   class="action-condition-input" -->
          <!--   @blur="checkNullInput" -->
          <!--   style="width: 90px" -->
          <!-- /> -->
          <!-- #10196 数値IFのスタイル全不正 linjunfeng start -->
          <!-- <custom-input-number
            :value="displayInputValue"
            :disabled="targetWeightDisabled || !getItemAuthorized('Indication', 'default_authority')"
            :digits="5"
            :decimal-digits="2"
            :min-value="0.0"
            :max-value="300.0"
            class="action-condition-input"
            @blur="checkNullInput"
            style="width: 90px"
          /> -->
          <custom-input-number-pro
            :initVal="displayInputValue.initValue"
            :value="displayInputValue.editValue"
            :disabled="targetWeightDisabled || !getItemAuthorized('Indication', 'default_authority')"
            :step="0.01"
            :min="0"
            :max="300.00"
            :emptyVal="null"
            class="action-condition-input"
            style="width: 90px"
            @blur="checkNullInput"
            @handlerInput="(val) =>{ displayInputValue.editValue = val }"
          />
          <!-- #10196 数値IFのスタイル全不正 linjunfeng start -->
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
          <label>Kg</label>
        </v-ons-row>
        <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
        <v-ons-row class="action-condition-row" v-if="this.getWeightMode.isWeightMode">
          <!-- mod FutreNetWeb+SI課題管理No7332 趙 start-->
          <!-- <v-ons-input-->
          <!-- id="indTreatID"-->
          <!-- class="action-condition-input"-->
          <!-- type="text"-->
          <!-- style="width: 90px"-->
          <!-- :disabled="targetWeightDisabled"-->
          <!-- v-model.number="displayInputValue.editValue"-->
          <!-- @blur="changeMeasureVal(displayInputValue.editValue, $event)"-->
          <!-- @keydown.enter="changeMeasureVal(displayInputValue.editValue, $event)"-->
          <!-- ></v-ons-input>-->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-input -->
          <!--    id="indTreatID" -->
          <!--    :class="classObject" -->
          <!--    type="number" -->
          <!--    :step="numberStep" -->
          <!--    style="width: 90px" -->
          <!--    :disabled="targetWeightDisabled" -->
          <!--    v-model="displayInputValue.editValue" -->
          <!--    @change="changeDisable()" -->
          <!--    @blur="changeMeasureVal(displayInputValue.editValue, $event, false)" -->
          <!--    @keydown.enter="moveFocus($event)" -->
          <!--    @keydown="onKeyDown" -->
          <!--    @input="checkLoop" -->
          <!--    readonly="readonly" -->
          <!--    ></v-ons-input> -->
          <v-ons-input
            id="indTreatID"
            :class="classObject"
            type="number"
            :step="numberStep"
            style="width: 90px"
            :disabled="targetWeightDisabled || !getItemAuthorized('Indication', 'default_authority')"
            v-model="displayInputValue.editValue"
            @change="changeDisable()"
            @blur="changeMeasureVal(displayInputValue.editValue, $event, false)"
            @keydown.enter="moveFocus($event)"
            @keydown="onKeyDown"
            @input="checkLoop"
            readonly="readonly"
          ></v-ons-input>
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!-- mod FutreNetWeb+SI課題管理No7332 趙 end-->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <label>kg <v-ons-button :disabled="targetWeightDisabled" @click="show" style="width: 10px; background: white"> <img height="25px" :src="image_src" /></v-ons-button> </label> -->
          <label>kg <v-ons-button
            :disabled="targetWeightDisabled || !getItemAuthorized('Indication', 'default_authority')"
            @click="show"
            style="width: 10px; background: white">
            <img height="25px" :src="image_src" />
          </v-ons-button> </label>
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
        </v-ons-row>
        <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
      </v-ons-row>
      <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
      <div>
        <!-- mod FutreNetWeb+SI課題管理No7332 趙 start-->
        <!-- <v-ons-popover cancelable :visible.sync="cavisible" :target="popoverTarget" direction="down" class="popoverClass">-->
          <!-- <vue-touch-keyboard :options="options" :layout="layout" :cancel="hide" :accept="accept" :input="input"  />-->
        <!-- </v-ons-popover>-->
        <v-ons-popover
          cancelable
          id="weightPopOver"
          :visible.sync="cavisible"
          :target="popoverTarget"
          direction="down"
          @posthide="tenkeyClose"
          class="popoverClass">
          <vue-touch-keyboard :options="options" :layout="layout" :cancel="hide" :accept="accept" :input="input" :next="next" />
        </v-ons-popover>
        <!-- mod FutreNetWeb+SI課題管理No7332 趙 end-->
      </div>
      <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
    </v-ons-col>
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters } from "vuex";
import {EventBus} from "@/eventBus";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
// add FNSI-体重計モードテンキーの追加 徐 start
import VueTouchKeyboard from "vue-touch-keyboard/dist/vue-touch-keyboard";
import "./../../../public/css/vue-touch-keyboard.css";
// add FNSI-体重計モードテンキーの追加 徐 end
export default {
  mixins: [IndTreatCondBase],
  // add FNSI-体重計モードテンキーの追加 徐 start
  components: {
    "vue-touch-keyboard":VueTouchKeyboard.component
  },
  // add FNSI-体重計モードテンキーの追加 徐 end
  data() {
    return {
      // 初期値がnullか-1だった場合、「DWと同じ」扱いをする
      targetWeightValue: {
        initValue: this.value == -1 || this.value == null ? 0 : 1,
        editValue: this.value == -1 || this.value == null ? 0 : 1
      },
      displayInputValue: {
        initValue: this.value == -1 || this.value == null ? null : this.value,
        editValue: this.value == -1 || this.value == null ? null : this.value
      },
      // add FNSI-体重計モードテンキーの追加 徐 start
      cavisible: false,
      // add FutreNetWeb+SI課題管理No7332 趙 start
      numberStep: 0.01,
      numberMax: 300.00,
      numberMin: 0.00,
      doClearTwice: false,
      // add FutreNetWeb+SI課題管理No7332 趙 end
      layout: null,
      input: null,
      options: {
        useKbEvents: false,
        preventClickEvent: false
      },
      image_src: require("@/../public/img/keyboard/keyboard.png"),
      popoverTarget: null
      // add FNSI-体重計モードテンキーの追加 徐 end
    };
  },

  computed: {
    // add FNSI-DW指定する 徐 start
    ...mapGetters("send-condition/scale", ["getIndDryWeight"]),
    // add FNSI-DW指定する 徐 end
    ...mapGetters("pat-info", ["selectedPat"]),
    // add FNSI-体重計モードテンキーの追加 徐 start
    ...mapGetters("send-condition/weight", ["getWeightMode"]),
    // add FNSI-体重計モードテンキーの追加 徐 end
    // add 8204 周安寧 start
    ...mapGetters("pat-viewer-treat-cond", {getIsUseFlagWeight: "getIsUseFlagWeight"}),
    // add 8204 周安寧 end
    targetWeightDisabled() {
      // add FNSI-体重計モードテンキーの追加 徐 start
      // eslint-disable-next-line vue/no-side-effects-in-computed-properties
      this.cavisible = false;
      // add FNSI-体重計モードテンキーの追加 徐 end
      // mod FNSI-障害票一覧_目標体重除水量制限編集のNo.1対応 韓 start
      //return !this.targetWeightValue.editValue;
      return this.targetWeightValue.editValue == 0
      // mod FNSI-障害票一覧_目標体重除水量制限編集のNo.1対応 韓 end
    },

    inputValue() {
      return this.displayInputValue.editValue !== null
        //mod #9973 fix Missing decimal places issue 20240122 ztc start
        // ? Number(this.displayInputValue.editValue)
        ? this.displayInputValue.editValue
        //mod #9973 fix Missing decimal places issue 20240122 ztc end
        : -1;
    },
    // add FutreNetWeb+SI課題管理No7332 趙 start
    isEdited() {
      return this.displayInputValue.initValue !== this.displayInputValue.editValue;
    },
    classObject() {
      return {
        // 編集時に適用されるclass
        "custom-input-number-edited": this.isEdited,
        "action-condition-input": !this.isEdited,
      };
    }
    // add FutreNetWeb+SI課題管理No7332 趙 end
  },

  watch: {
    targetWeightValue: {
      handler({ editValue }) {
        // add FNSI-DW指定する 徐 start
        // this.displayInputValue.editValue = +editValue
        //   ? this.displayInputValue.initValue || 0
        //   : null;
        //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod start
        // this.displayInputValue.editValue = +editValue
        //   ? this.displayInputValue.initValue ? this.displayInputValue.initValue : this.getIndDryWeight.value
        //   : null;
        this.displayInputValue.editValue = +editValue
          ? this.displayInputValue.editValue ? this.displayInputValue.editValue : this.getIndDryWeight.value
          : null;
        // add FNSI-DW指定する 徐 end
        //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end
      },

      deep: true
    }
  },
  //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add start
  created(){
    // mod 目標体重の初期表示不正 商 start
    //this.displayInputValue.editValue = this.velue;
    //this.targetWeightValue.editValue = this.velue === -1 || this.velue === null ? 0 : 1
    //this.targetWeightValue.initValue = this.value === -1 || this.value === null ? 0 : 1
    if (this.isIndication) {
      // add #10196 数値IFのスタイル全不正 linjunfeng start
      // this.displayInputValue.editValue = this.velue;
      this.displayInputValue.editValue = this.velue == -1 ? null : this.velue;
      // add #10196 数値IFのスタイル全不正 linjunfeng end
      this.targetWeightValue.editValue = this.velue == -1 || this.velue == null ? 0 : 1
      this.targetWeightValue.initValue = this.value == -1 || this.value == null ? 0 : 1
    }
    // mod 目標体重の初期表示不正 商 end
  },
  //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add end
  mounted() {
    this.treatItemCd = "3";
    this.unit = "Kg";
  },

  methods: {
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    //[確認]ボタンの状態の変更をトリガーします
   changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    checkNullInput() {
      if (this.displayInputValue.editValue === null){
        this.targetWeightValue.editValue = 0;
      }
    },
    // mod FutreNetWeb+SI課題管理No7332 趙 start
    // add FNSI-体重計モードテンキーの追加 徐 start
    // changeMeasureVal(oldVal, e) {
    //   // 入力制限
    //   let pattern = "^([0-9][0-9]{0,2}|0)(.[0-9]{1,2})?$";
    //   const re = new RegExp(pattern);
    //   const result = re.exec(e.target.value);
    //   if (result) {
    //     if (result.input > 300) {
    //       e.target.value = 300;
    //     } else {
    //       if (Number(result.input)) {
    //         e.target.value = Number(result.input);
    //       } else {
    //         e.target.value = null;
    //       }
    //     }
    //   } else {
    //     if (this.getWeightMode.isWeightMode) {
    //       if (e.target.value === null || e.target.value === "") {
    //         e.target.value = "";
    //       } else {
    //         let valueSplit = String(e.target.value).split(".");
    //         if (valueSplit.length === 2) {
    //           if (valueSplit[0].length > 3) {
    //             e.target.value = 300;
    //           } else if (valueSplit[1].length > 2) {
    //             e.target.value = null;
    //           } else if (valueSplit[0].length === 0 && valueSplit[1].length === 0) {
    //             e.target.value = null;
    //           }
    //         } else {
    //           e.target.value = null;
    //         }
    //       }
    //     }
    //   }
    //   if (e.target.value !== null && e.target.value !== "") {
    //     if (Number(e.target.value)) {
    //       this.displayInputValue.editValue = Number(e.target.value);
    //     } else {
    //       this.displayInputValue.editValue = null;
    //     }
    //   } else {
    //     this.displayInputValue.editValue = e.target.value;
    //   }
    // },
    changeMeasureVal(oldVal, e, isPostHide) {
      if (this.cavisible && !isPostHide) {
        return;
      }
      // 入力制限
      let pattern = "^([0-9][0-9]{0,2}|0)(.[0-9]{1,2})?$";
      const re = new RegExp(pattern);
      const result = re.exec(e.target.value);
      if (result) {
        if (result.input > this.numberMax) {
          e.target.value = Number(this.numberMax).toFixed(2);
        } else {
          e.target.value = Number(result.input).toFixed(2);
        }
      } else {
        if (this.getWeightMode.isWeightMode) {
          if (e.target.value === null || e.target.value === "") {
            e.target.value = "";
          } else {
            let valueSplit = String(e.target.value).split(".");
            if (valueSplit.length === 2) {
              if (valueSplit[0].length > 3) {
                e.target.value = Number(this.numberMax).toFixed(2);
              } else if (valueSplit[1].length > 2) {
                e.target.value = Number(oldVal).toFixed(2);
              } else if (valueSplit[0].length === 0 && valueSplit[1].length === 0) {
                e.target.value = null;
              }
            } else {
              e.target.value = Number(oldVal).toFixed(2);
            }
          }
        }
      }
    },
    // mod FutreNetWeb+SI課題管理No7332 趙 end
    // add FutreNetWeb+SI課題管理No7332 趙 start
    // 入力欄のフォーカス移動
    moveFocus(event) {
      event.target.blur();
    },
    // テンキー表示時にキー入力無効化
    onKeyDown(event) {
      if (this.cavisible) {
        event.preventDefault();
      }
    },
    next() {
      let reverseVal = 0;
      reverseVal = Number(document.getElementById("indTreatID").value) * (-1);
      document.getElementById("indTreatID").value = reverseVal.toFixed(2);
      this.displayInputValue.editValue = reverseVal.toFixed(2);
      this.moveCursor();
    },
    // 数値範囲内ループチェック
    checkLoop(event) {
      // テキスト入力の場合は除外
      if (event.inputType && event.inputType === "insertText") {
        return;
      }

      // テンキー入力の場合は除外
      if (this.cavisible) {
        return;
      }

      // 数値範囲内かどうかの確認
      if (event.target.value > this.numberMax) {
        event.target.value = this.numberMax;
      } else if (event.target.value < this.numberMin) {
        event.target.value = this.numberMin;
      }
    },
    // テンキー用内部関数 moveCursor: カーソル位置を右端にセットする
    moveCursor() {
      this.input.focus();
      this.input.setSelectionRange(10, 10);
    },
    // テンキー用内部関数 selectAllInput: 入力内容を全選択状態にする
    selectAllInput(inputElement) {
      inputElement.focus();
      inputElement.setSelectionRange(0, inputElement.value.length);
    },
    clearValue() {
      this.input.value = null;
      this.displayInputValue.editValue= null;
    },
    // テンキー用関数 tenkeyClose: 画面テンキーを閉じた際の内部処理
    tenkeyClose() {
      // 入力を番号に戻す
      document.getElementById("indTreatID").setAttribute("type", "number");
      // 異常データの場合の初期化
      this.changeMeasureVal(this.displayInputValue.editValue, {target: document.getElementById("indTreatID")}, true);
      this.input = null;
    },
    // add FutreNetWeb+SI課題管理No7332 趙 end
    accept() {
      // mod FutreNetWeb+SI課題管理No7332 趙 start
      // this.hide();
      if (document.getElementById("indTreatID").value !== "0.00") this.doClearTwice = true;
      this.clearValue();
      this.moveCursor();
      // mod FutreNetWeb+SI課題管理No7332 趙 end
    },
    show() {
      if (this.getWeightMode.isWeightMode) {
        // mod FutreNetWeb+SI課題管理No7332 趙 start
        // this.input = document.getElementById("indTreatID").firstElementChild;
        // this.popoverTarget = document.getElementById("indTreatID");
        let indTreatIDElem = document.getElementById("indTreatID");
        indTreatIDElem.setAttribute("type", "text");
        this.input = indTreatIDElem.firstElementChild;
        this.input.setAttribute("readonly", "readonly");
        this.selectAllInput(this.input);
        this.popoverTarget = this.input;
        // mod FutreNetWeb+SI課題管理No7332 趙 end
        this.cavisible = !this.cavisible;
        let name = ["7 8 9", "4 5 6", "1 2 3", "{zero} . {accept}"];
        let meta = { "zero": { key: "0"}, "accept": { func: "accept", text: "CLR"} }
        let layoutparam = {default: name, _meta: meta};
        this.layout = layoutparam;
      }
    },
    hide() {
      // mod FutreNetWeb+SI課題管理No7332 趙 start
      // document.getElementById("indTreatID").value = null;
      document.getElementById("weightPopOver").hide();
      this.cavisible = false;
      // mod FutreNetWeb+SI課題管理No7332 趙 end
    }
    // add FNSI-体重計モードテンキーの追加 徐 end
  }
};
</script>

<style scoped>
/* add 9664補液及び透析液仕様修正します yangqingzhe start */
.cell-disabled {
  background-color: var(--pat-viewer-ind-cond-info-disabled);
}
 /* add 9664補液及び透析液仕様修正します yangqingzhe end */
/* アクションチャート内inputタグ */
.action-condition-input {
  width: 138px;
  /* mod 障害票一覧_NKK.xlsxの3732 対応 韓 start */
  /* margin: 0px 5px 0px 0px; */
  margin: 5px 5px 0px 0px;
  white-space: initial;
  /* mod 障害票一覧_NKK.xlsxの3732 対応 韓 end */
}

.action-condition-column {
  /* mod FNSI-薬剤指示画面等の画面崩れの修正 楊 start */
  /* flex: 0 0 30%; */
  flex: 0 0 9%;
  /* mod FNSI-薬剤指示画面等の画面崩れの修正 楊 end */
  max-width: 30%;
  white-space: normal;
  margin: auto;
}

.action-condition-input-label {
  width: 100px;
  font-size: 15px;
}

.action-condition-data-column {
  margin: auto;
  padding-left: 10px;
  margin-right: 5px;
}

.action-condition-target-weight {
  border: 1px solid var(--ntss-border-color);
  padding: 10px;
}

.action-condition-row {
  align-items: center;
}
/* add FNSI-体重計モードテンキーの追加 徐 start */
ons-input >>> .text-input {
  text-align: right;
}
.popoverClass >>> .popover--top {
  width: auto;
}
/* add FNSI-体重計モードテンキーの追加 徐 end */
/* add FutreNetWeb+SI課題管理No7332 趙 start*/
.custom-input-number-edited {
  border: 2px green solid;
  outline: 0;
  width: 138px;
  margin: 5px 5px 0px 0px;
  white-space: initial;
}
/* add FutreNetWeb+SI課題管理No7332 趙 end*/

.custom-radio {
  margin-right: 15px;
}
</style>
