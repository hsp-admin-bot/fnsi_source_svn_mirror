<template>
  <!-- mod FNSI-入力コンポーネントの変更 徐博 start-->
  <!-- mod bug 6150 修正 chen start-->
  <!-- <v-ons-input
    type="number"
    :class="classObject"
    @focus="addFocusCss($event)"
    @input="inputValidValue"
    @blur="formatValue($event)"
    @wheel.prevent="wheelChangeValue"
    @keydown.up.prevent="keyChangeValue"
    @keydown.down.prevent="keyChangeValue"
    v-on="$listeners"
    :step="(1 / Math.pow(10, decimalDigits))"
  />-->
  <!-- mod bug 6150 修正 chen end-->
  <!--mod FNSI-入力コンポーネントの変更 徐博 end-->
  <!-- mod #9857 2023/11/29 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能@mouseup.stop="handleMouseUp($event)"張玲start-->
  <!-- mod #9445 患者経過総合ビューアで除水プログラムのパターン表示が設定と異なる。v-on="$listeners"追加 linjunfeng start -->
  <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start -->
  <!-- <v-ons-input
    type="number"
    :class="classObject"
    @focus="addFocusCss($event)"
    @input="inputValidValue"
    @change="handleChangeValue($event)"
    @blur="formatValue($event)"
    @wheel.prevent="wheelChangeValue"
    @keydown.up.prevent="keyChangeValue"
    @keydown.down.prevent="keyChangeValue"
    :step="(1 / Math.pow(10, decimalDigits))"
    v-on="$listeners"
  />-->
  <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰  -->
  <!-- mod #9445 患者経過総合ビューアで除水プログラムのパターン表示が設定と異なる。v-on="$listeners"追加 linjunfeng end -->
  <v-ons-input
    type="number"
    :class="classObject"
    @mouseup.stop="handleMouseUp($event)"
    @focus="addFocusCss($event)"
    @input="inputValidValue"
    @change="handleChangeValue($event)"
    @blur="formatValue($event)"
    @wheel.prevent="wheelChangeValue"
    @keydown.up.prevent="keyChangeValue"
    @keydown.down.prevent="keyChangeValue"
    @keydown.enter="keyDownValue"
    :step="(1 / Math.pow(10, decimalDigits))"
    v-on="$listeners"
  />
  <!-- mod #9857 2023/11/29 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能
  @mouseup.stop="handleMouseUp($event)" @keydown.enter="keyDownValue" 張玲end-->
</template>

<script>
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";
import BigNumber from "bignumber.js";
// 共通関数
import {
  isDecimal,
  toFixed,
  plusDecimal,
  minusDecimal,
} from "@/functions/common/NumberFunctions.js";

/**
 * @description 共通数値入力タグ
 * @summary
 *   ■機能
 *     ・上下限値設定
 *     ・桁数設定
 *     ・不正値入力制限
 *     ・上下キー、マウスホイールによる値の増減
 *     ・最大値/最小値へ到達後のループON/OFF
 *
 *   ■props
 *     ・maxValue(必須): 入力可能上限値を指定する
 *     ・minValue(必須): 入力可能下限値を指定する
 *     ・digits(必須): マイナス、小数点を除いた最大許容桁数
 *        例: -100.000を許容したいなら6
 *     ・decimalDigits: 小数部の桁数
 *     ・defaultValue: 不正値入力時にリセットされる値
 *     ・loopFlg:最大値や最小値からスクロールさせた時に値をループさせるかさせないか
 *     ・initialValueLock: 初期表示時に入力値の小数部制御を実行するかしないか(初回のみ制御)
 * @example
 *   <custom-input-number
 *     :value="{ initValue, editValue }"
 *     :max-value="100"
 *     :min-value="-10"
 *     :decimal-digits="3"
 *     :digits="6" />
 *
 *   ⇒ -10.000 ～ 100.000 を入力可能
 */
export default {
  mixins: [baseCustomForm],

  props: {
    value: {
      required: true
    },

    maxValue: {
      type: Number,
      required: true
    },

    minValue: {
      type: Number,
      required: true
    },

    digits: {
      type: Number,
      required: true
    },

    decimalDigits: {
      type: Number,
      default: 0
    },

    loopFlg: {
      type: Boolean,
      default: true
    },

    initialValueLock: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      // 入力された文字列
      inputtedString: "",
      // mod 装置設定外結No3対応 趙 start
      valueLock: false,
      focusflg: false,
      // mod 装置設定外結No3対応 趙 end
      // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
      blurFlg: false
      // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end
    };
  },

  computed: {
    classObject() {
      return {
        // 常に適用されるclass
        "custom-input-number": true,
        // 編集時に適用されるclass
        "custom-input-number-edited": this.isEdited,
        // 必須項目に適用されるclass
        "custom-input-number-required": this.isRequired,
        // データ不正時に適用されるclass
        "custom-input-number-invalid": !this.isValid
      };
    },
    // 渡されたデータの初期値
    initValue() {
      return this.value.initValue;
    }
  },

  watch: {
    /**
     * @description editValueの変更検知
     * @summary 使用画面においてeditValueが直接変更される際に必要/この処理でフォーマット処理の動作を確認
     */
    editValue(newValue, oldValue) {
      let editString;
      if (newValue === null) {
        // 空欄
        editString = "";
      } else {
        editString = this.toFixedByDecimalDigits(this.editValue);
      }
      this.inputtedString = editString;
      this.fourceUpdateValue(editString);
    },

    decimalDigits(decimalDigits) {
      let initString;
      if (this.editValue === null) {
        // 空欄
        initString = "";
      } else {
        // 初期表示時DB取得値の小数点以下数値切り捨て制御テスト
        if (
          this.initialValueLock &&
          !this.valueLock &&
          this.getDecimalPointLength(this.editValue) > decimalDigits
        ) {
          initString = BigNumber(this.editValue).toFixed();
          this.valueLock = true;
        } else {
          initString = this.toFixedByDecimalDigits(
            this.editValue,
            decimalDigits
          );
          this.editValue = Number(initString);
          this.valueLock = true;
        }
      }
      this.inputtedString = initString;
      this.fourceUpdateValue(initString);
    }
  },

  /**
   * @description 初期表示時に表示値をセットする
   */
  mounted() {
    let initString;
    if (this.editValue === null) {
      // 空欄
      initString = "";
    } else {
      initString = this.toFixedByDecimalDigits(this.editValue);
    }
    this.inputtedString = initString;
    this.fourceUpdateValue(initString);
  },

  methods: {
    // add FNSI-入力コンポーネントの変更 徐博 start
    addFocusCss(event) {
      let element = event.target;
      element?.classList?.add("custom-input-number-edited");
      // add 装置設定外結No3対応 趙 start
      this.focusflg = true;
      // add 装置設定外結No3対応 趙 end
      // del #9445 患者経過総合ビューアで除水プログラムのパターン表示が設定と異なる。linjunfeng start
      // #6765 装置設定-ホスト報知：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 start
      // this.$emit('focus', event)
      // #6765 装置設定-ホスト報知：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 end
      // del #9445 患者経過総合ビューアで除水プログラムのパターン表示が設定と異なる。linjunfeng end
    },
    // add FNSI-入力コンポーネントの変更 徐博 end

    // mod 7109 修正 chen start
    /**
     * @description 文字列入力処理
     * @summary 入力可能な文字列を入力値として保持する
     */
    inputValidValue(event) {
      // mod 6177 修正 chen start
      if (
        event.data === undefined ||
        event.data === null ||
        this.isNumber(event.data) ||
        ((event.data === "-" || event.data === ".") &&
          this.isNumber(event.target.value))
      ) {
        
        const el = event.target;
        const value = el.value;
        const stepNum = (1 / Math.pow(10, this.decimalDigits));
        
        // spin操作かどうか判定
        if (!event.inputType) {
          // 「空 → spin」の場合
          if (this.inputtedString === "") {
            // ▲か▼かを判別する
            let computedStep = minusDecimal(
              BigNumber(value),
              BigNumber(0)
            );
            if (computedStep < 0) {
              // ▼（decrement）
              el.value = this.minValue;            
            } else {
              // ▲（increment）
              el.value = this.minValue + stepNum;
            }
          }
        }
        
        // mod 6177 修正 chen end
        this.inputtedString = event.target.value;
        // mod 6177 修正 chen start
        // if (event.data !== ".") {
        // // mod 6177 修正 chen end
        //   this.fourceUpdateValue(event.target.value);
        // }
      }
    },
    /**
     * 数値チェック関数
     * 入力値が数値 (符号あり小数 (- のみ許容)) であることをチェックする
     * [引数]   numVal: 入力値
     * [返却値] true:  数値
     *          false: 数値以外
     */
    isNumber(numVal) {
      // チェック条件パターン
      var pattern = /^[-]?([1-9]\d*|0)(\.\d+)?$/;
      // 数値チェック
      return pattern.test(numVal);
    },
    // mod 7109 修正 chen end

    /**
     * @description 入力文字列のフォーマット
     * @summary 不正値の0リセット、限界値判定、小数桁切り捨て、共通タグバリデーション
     */
    // mod FNSI-入力コンポーネントの変更 徐博 start
    formatValue(event) {
      if (!this.isEdited) {
        let element = event.target;
        element.classList.remove("custom-input-number-edited");
      }
      // mod FNSI-入力コンポーネントの変更 徐博 end

      if (this.inputtedString === "") {
        // 空欄はそのまま
        this.udpateValue(null);
        return;
      } else if (!isDecimal(this.inputtedString)) {
        // 不正な文字列は初期値に
        this.udpateValue(this.initValue);
        return;
      }
      // 限界値判定
      let limitedValue = Number(this.inputtedString);
      if (limitedValue > this.maxValue) {
        // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 start
        // limitedValue = this.maxValue;
        limitedValue = this.maxValue;
        // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 end
      } else if (limitedValue < this.minValue) {
        // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 start
        // limitedValue = this.minValue;
        limitedValue = this.minValue;
        // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 end
      }
      // del #9857 2023/11/29 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 張玲 start
      // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 start
      // if (limitedValue == this.maxValue && this.blurFlg) {
      //   limitedValue = this.minValue;
      //   this.blurFlg = false;
      // } else if (limitedValue == this.minValue && this.blurFlg) {
      //   limitedValue = this.maxValue;
      //   this.blurFlg = false;
      // }

      // del #9445 患者経過総合ビューアで除水プログラムのパターン表示が設定と異なる。linjunfeng start
      // #6765 装置設定-ホスト報知：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 start
      // this.$emit('blur', event)
      // #6765 装置設定-ホスト報知：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 end
      // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 end
      // del #9445 患者経過総合ビューアで除水プログラムのパターン表示が設定と異なる。linjunfeng end
      // del #9857 2023/11/29 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 張玲 end
      // 小数指定桁切り捨て
      const truncatedValue = +this.toFixedByDecimalDigits(limitedValue);
      this.udpateValue(truncatedValue);
      this.validate();
      // add 装置設定外結No3対応 趙 start
      this.focusflg = false;
      // add 装置設定外結No3対応 趙 end
    },
    // add #9857 2023/11/29 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 張玲 start
    // mod #10296 装置設定デフォルト＞I-HDFのプログラム設定にて不正な表示になる 20240218 ztc start
    handleMouseUp(event) {
      if (event.target.value === "" && !this.isRequired) {
        this.editValue = null;
      } else if (event.target.value > this.maxValue) {
        this.editValue = this.minValue;
        // this.udpateValue(this.minValue);
      } else if (event.target.value < this.minValue) {
        this.editValue = this.maxValue;
        // this.udpateValue(this.maxValue);
      } else {
        this.editValue = +event.target.value;
        // this.udpateValue(event.target.value);
      }
      this.udpateValue(this.editValue);
    },
    // mod #10296 装置設定デフォルト＞I-HDFのプログラム設定にて不正な表示になる 20240218 ztc end
    // add #9857 2023/11/29 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 張玲 end
    // mod #5589 2023/04/10 数値IFのスタイル全不正 林峻峰 start
    handleChangeValue(event) {
      // del #9857 2023/11/29 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 張玲 start
      // 限界値判定
      // if (event.target.value > this.maxValue) {
      //   // 値は空判定です
      //   event.target.value = event.target.value !== '' ? this.minValue : '';
      //   this.blurFlg = true;
      // } else if (event.target.value < this.minValue) {
      //   // 値は空判定です
      //   event.target.value = event.target.value !== '' ? this.maxValue : '';
      //   this.blurFlg = true;
      // } else {
      //   this.blurFlg = false;
      // }
      // del #9857 2023/11/29 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 張玲 end

      let truncatedValue;
      // 患者経過総合ビューア 身体情報 焦点が離れた時は初期値になりますバグ修正
      // truncatedValue = +this.toFixedByDecimalDigits(event.target.value);
      if (this.isRequired) {
        truncatedValue = +this.toFixedByDecimalDigits(event.target.value);
      } else {
        truncatedValue = this.toFixedByDecimalDigits(event.target.value);
      }
      this.udpateValue(truncatedValue);
      this.validate();
      // del #9445 患者経過総合ビューアで除水プログラムのパターン表示が設定と異なる。linjunfeng start
      // #6765 装置設定-ホスト報知：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 start
      // this.$emit('change', event)
      // #6765 装置設定-ホスト報知：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 end
      // del #9445 患者経過総合ビューアで除水プログラムのパターン表示が設定と異なる。linjunfeng end
    },
    // mod #5589 2023/04/10 数値IFのスタイル全不正 林峻峰 end

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
        const stepNum =
          (1 / Math.pow(10, this.decimalDigits)) * (isUp ? 1 : -1);

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
        // del #9445 患者経過総合ビューアで除水プログラムのパターン表示が設定と異なる。linjunfeng start
        // #6765 装置設定-ホスト報知：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 start
        // this.$emit('wheel', event)
        // #6765 装置設定-ホスト報知：修正時、修正していないが保存ボタンが有効になってしまっている 林峻峰 end
        // del #9445 患者経過総合ビューアで除水プログラムのパターン表示が設定と異なる。linjunfeng end
      }
      // mod 装置設定外結No3対応 趙 end
    },
    // add #9857 2023/12/05 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 張玲 start
    keyDownValue(event) {
      if (event.target.value > this.maxValue) {
        this.editValue = this.maxValue;
      } else if (event.target.value < this.minValue) {
        this.editValue = this.minValue;
      } else {
        // mod #10296 装置設定デフォルト＞I-HDFのプログラム設定にて不正な表示になる 20240218 ztc start
        // this.editValue = event.target.value;
        this.editValue = +event.target.value;
        // mod #10296 装置設定デフォルト＞I-HDFのプログラム設定にて不正な表示になる 20240218 ztc end
      }
      this.udpateValue(this.editValue);
    },
    // add #9857 2023/12/05 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 張玲 end

    /**
     * @description キー押下イベントハンドラ
     * @summary 上下キーでの入力値の増減を可能にする
     */
    keyChangeValue(event) {
      // 上下キー判定
      const isUp = event.key === "ArrowUp";
      // 変更量(小数最下位を1ずつ)
      const stepNum = (1 / Math.pow(10, this.decimalDigits)) * (isUp ? 1 : -1);
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
    },

    /**
     * @description マウスホイールと上下キーによる値の増減
     * @param {Number} stepNum 増減させる値
     */
    stepChangeValue(stepNum) {
      // 限界値判定
      let plusResult = plusDecimal(Number(this.inputtedString), stepNum);
      // 限界値を超えた際の値をループ設定有無で振り分け
      if (plusResult > this.maxValue) {
        plusResult = this.loopFlg ? this.minValue : this.maxValue;
      } else if (plusResult < this.minValue) {
        plusResult = this.loopFlg ? this.maxValue : this.minValue;
      }
      this.udpateValue(plusResult);
    },

    /**
     * @description 編集値の更新と同時に表示値を書き換える
     * @param {Number} value 値
     */
    udpateValue(value) {
      this.editValue = value;
      let editString;
      if (value === null) {
        // 空欄
        editString = "";
      } else {
        // 0詰め
        editString = this.toFixedByDecimalDigits(value);
      }
      this.inputtedString = editString;
      this.fourceUpdateValue(editString);
    },

    /**
     * @description value属性強制更新
     * @summary 入力制限による値の動的な変更は、v-bind:valueでは反映されないため(本当に？見直したい)
     * @param {String} valueString 書き換える値
     */
    fourceUpdateValue(valueString) {
      this.$el.value = valueString;
    },

    /**
     * @description 設定値の小数点桁数算出
     * @param {Number} value 値
     */
    getDecimalPointLength(number) {
      var numbers = String(number).split(".");
      return numbers[1] ? numbers[1].length : 0;
    },

    /**
     * @description 小数を指定桁数に丸める
     * @param {Number} value 値
     * @param {Number} decimalDigits 桁数
     */
    toFixedByDecimalDigits(value, decimalDigits = this.decimalDigits) {
      // 患者経過総合ビューア 身体情報 焦点が離れた時は初期値になりますバグ修正
      if (!this.isRequired) {
        if (value === "" || isNaN(value)) {
          return "";
        }
      }
      return decimalDigits === Infinity ? value : toFixed(value, decimalDigits);
    }
  }
};
</script>

<style scoped>
input {
  color: var(--ntss-list-body-color);
  background-color: var(--ntss-list-background-color);
}

.custom-input-number-edited {
  border: 2px green solid;
  outline: 0;
}

.custom-input-number-required {
  color: black;
  background-color: #ffff99;
}

.custom-input-number-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 0.5) !important;
}
</style>
