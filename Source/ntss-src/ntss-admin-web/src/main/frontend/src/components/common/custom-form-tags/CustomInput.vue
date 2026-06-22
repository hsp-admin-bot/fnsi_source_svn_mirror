<template>
  <!-- mod FNSI-inputの色 鄭 start -->
  <!-- <v-ons-input
    type="text"
    class="ntss-custom-input"
    v-model="valueInput"
    :class="classObject"
    :disabled="disabled"
    @blur="validate()"
    v-bind="$attrs"
  /> -->
  <!-- mod 患者名入力チェック不正について、対応する。 dengshen start -->
  <!-- <v-ons-input -->
  <!--   type="text" -->
  <!--   class="ntss-custom-input" -->
  <!--   v-model="valueInput" -->
  <!--   :class="classObject" -->
  <!--   :disabled="disabled" -->
  <!--   @blur="delFocusCss($event)" -->
  <!--   v-on="$listeners" -->
  <!--   @focus="addFocusCss($event)" -->
  <!-- /> -->
  <!--#10866：日付(不定型)の部品修正Start -->
  <v-ons-input
    id="custom-input"
    type="text"
    class="ntss-custom-input"
    v-model="valueInput"
    :class="classObject"
    :disabled="disabled"
    @blur="delFocusCss($event)"
    v-bind="$attrs"
    @focus="addFocusCss($event)"
    @input="inputValue($event)"
    @keydown="keydownup($event)"
    @wheel.prevent="wheelChangeValue($event)"
  />
  <!--#10866：日付(不定型)の部品修正End -->
  <!-- mod 患者名入力チェック不正について、対応する。 dengshen end -->
  <!-- mod FNSI-inputの色 鄭 end -->
</template>

<script>
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";
//#10866：日付(不定型)の部品修正Start
// 共通関数
import {
  plusDecimal
} from "@/functions/common/NumberFunctions.js";
//#10866：日付(不定型)の部品修正End
/**
 * @description 共通テキスト入力タグ
 * @summary
 *   ■props
 *     displayString(任意): value属性に与えた値の代わりに表示したい文字列
 *       ※たぶんマスタ選択と一緒に使うときくらいしか使い道ない
 * @example
 *   <custom-input
 *     :value="{ initValue, editValue: マスタのコード }"
 *     :display-string="マスタの名称" />
 */
export default {
  inheritAttrs: false,
  mixins: [baseCustomForm],

  props: {
    displayString: {
      type: String,
      default: null
    },
    disabled: {
      default: false
    //#10866：日付(不定型)の部品修正Start
    },
    wheelChangeUse: {
      default: false
    },
    wheelEmptyInitValue: {
      type: String,
      default: null
    },
    datetype: {
      type: String,
      default: null
    },
    datetypeym: {
      type: String,
      default: null
    },
    //#10866:日付(不定型)の部品修正・検証NG対応 Start
    // foucusIN_SV: {
    //   type:String,
    //   default: null
    // }
    //#10866:日付(不定型)の部品修正・検証NG対応 End
    //#10866：日付(不定型)の部品修正End
  },
  //#10866:日付(不定型)の部品修正・検証NG対応 Start
  data() {
    return {
      wheelChangeOn: false,
      foucusIN_SV: null
    };
  },
  //#10866:日付(不定型)の部品修正・検証NG対応 End
  computed: {
    // 入力欄に表示する値
    valueInput: {
      get() {
        let value;
        if (this.displayString === null) {
          value = this.editValue;
        } else {
          value = this.displayString;
        }
        return value;
      },
      set(value) {
        if (value === "") {
          value = null;
        }
        this.editValue = value;
      }
    },

    classObject() {
      return {
        // 常に適用されるclass
        "custom-input": true,
        // disabled時に適用されるclass
        // ※属性セレクタ[disabled]で指定すると他のスタイルより優先されてしまうので作成
        "custom-input-disabled": this.disabled,
        // 編集時に適用されるclass
        "custom-input-edited": this.isEdited,
        // 必須項目に適用されるclass
        "custom-input-required": this.isRequired,
        // データ不正時に適用されるclass
        "custom-input-invalid": !this.isValid
      };
    }
  },

  // add FNSI-inputの色 鄭 start
  methods:{
    // add 患者名入力チェック不正について、対応する。 dengshen start
    inputValue(event) {
      this.editValue = event.target.value;
    },
    //#10866：日付(不定型)の部品修正Start
    keydownup(event) {
      if (this.datetype == null) return;

      //TAG :datetype指定のみ対応
      let start_txt = ((event.target.value != undefined) && event.target.value != null && event.target.value != '') ? parseInt(event.target.value,10) : 0;
      //↑キー押下
      if (event.key != undefined && event.key === 'ArrowUp') {
          if (this.datetype === 'period-year') {
            if (start_txt < 9999)
              this.editValue = ((start_txt + 1).toString()).padStart(4,"0");
            else
              this.editValue = "0001";
          }
          if (this.datetype === 'period-month') {
            if (start_txt < 12)
              this.editValue = ((start_txt + 1).toString()).padStart(2,"0");
            else
              this.editValue = "01";
          }
          if (this.datetype === 'period-day') {
            let date_str = "31";
            if (this.datetypeym != null && this.datetypeym.length ===8) {
              const yy = this.datetypeym.substr(0, 4) ? this.datetypeym.substr(0, 4) : '0000';
              const mm = this.datetypeym.substr(4, 2) ? this.datetypeym.substr(4, 2) : '00';
              let date_tmp = new Date(yy, parseInt(mm,10), 0);
              date_str = date_tmp.toLocaleDateString().slice(-2);
            }
            if (start_txt < date_str)
              this.editValue = ((start_txt + 1).toString()).padStart(2,"0");
            else
              this.editValue = "01";
          }
      //↓キー押下
      } else if (event.key != undefined && event.key === 'ArrowDown') {
          if (start_txt > 1) {
            if (this.datetype === 'period-month' ||  this.datetype === 'period-day')
              this.editValue = ((start_txt - 1).toString()).padStart(2,"0");
            else
              this.editValue = ((start_txt - 1).toString()).padStart(4,"0");
          } else {
            if (this.datetype === 'period-month')
              this.editValue = "12";
            else if (this.datetype === 'period-day') {
              let date_str = "31";
              if (this.datetypeym != null && this.datetypeym.length ===8) {
                const yy = this.datetypeym.substr(0, 4) ? this.datetypeym.substr(0, 4) : '0000';
                const mm = this.datetypeym.substr(4, 2) ? this.datetypeym.substr(4, 2) : '00';
                let date_tmp = new Date(yy, parseInt(mm,10), 0);
                date_str = date_tmp.toLocaleDateString().slice(-2);
              }
              this.editValue = date_str;
            } else {
              this.editValue = "9999";
            }
          }
      }
      return this.editValue;
    },
    //#10866：日付(不定型)の部品修正End
    // add 患者名入力チェック不正について、対応する。 dengshen end
    addFocusCss(event){
      let element = event.target;
      element?.classList?.add("custom-input-edited");
      //#10866:日付(不定型)の部品修正・検証NG対応 Start
      //フォーカスイン時：不定型フィールド名保持(不定型フィールドは通番含む管理)
      if (this.wheelChangeUse) this.wheelChangeOn = true;
      this.foucusIN_SV = this.datetype;
      //#10866:日付(不定型)の部品修正・検証NG対応 End
    },
    delFocusCss(event){
      if(!this.isEdited){
        let element = event.target;
        element.classList.remove("custom-input-edited");
        //#10866:日付(不定型)の部品修正・検証NG対応 Start
        //フォーカスアウト時：：不定型フィールド名クリア
        if (this.wheelChangeUse) this.wheelChangeOn = false;
        event.preventDefault();
      }
      this.foucusIN_SV = null;
      //#10866:日付(不定型)の部品修正・検証NG対応 End
    },
    // add FNSI-inputの色 鄭 end
    //#10866：日付(不定型)の部品修正Start
    /**
     * @description マウスホイールイベントハンドラ
     * @summary マウスホイールでの入力値の増減を可能にする
     */
    wheelChangeValue(event) {
      // wheelChangeUse を明示した不定型日付入力のみホイール変更を許可する
      if (!this.wheelChangeUse || this.datetype == null) {
        const ownerDocument = event?.target?.ownerDocument || this.$el?.ownerDocument || (typeof document !== "undefined" ? document : null);
        const activeElement = ownerDocument?.activeElement || null;
        const rootEl = this.$el;
        const isFocusedCurrentInput =
          activeElement === event?.target ||
          activeElement === rootEl ||
          (typeof rootEl?.contains === "function" && rootEl.contains(activeElement));
        const eventTargetValue =
          (event?.target && typeof event.target.value !== "undefined")
            ? event.target.value
            : this.editValue;
        if (
          this.wheelEmptyInitValue !== null &&
          isFocusedCurrentInput &&
          (eventTargetValue === "" || eventTargetValue === null || typeof eventTargetValue === "undefined")
        ) {
          this.editValue = this.wheelEmptyInitValue;
        }
        return;
      }
      //#10866:日付(不定型)の部品修正・検証NG対応 Start
      const ownerDocument = event?.target?.ownerDocument || this.$el?.ownerDocument || (typeof document !== "undefined" ? document : null);
      const element = ownerDocument?.activeElement || event?.target;
      if (element?.value === "") {
        //現在不定型フィールド位置の値が空の場合
        if (this.foucusIN_SV != this.datetype) {
          //前回保持不定型フィールド比較：異なる場合ホーイル起動停止
          this.foucusIN_SV = null;
          this.wheelChangeOn = false;
        } else {
          //前回保持不定型フィールド比較：等しい場合ホーイル起動開始
          this.wheelChangeOn = true;
        }
      } else if (this.foucusIN_SV ===  null) this.wheelChangeOn = false;
      if (!this.wheelChangeOn) return;
      //#10866:日付(不定型)の部品修正・検証NG対応 End
      //wheelChangeUse指定のみ対応
      let start_int = ((event.target.value != undefined) && event.target.value != null && event.target.value != '') ? parseInt(event.target.value,10) : 0;
        // マウスホイールの向き
        const isUp = event.deltaY < 0;
        // 変更量
        const stepNum = isUp ? 1 : -1;
        this.stepChangeValue(stepNum, start_int);
    },
    /**
     * @description マウスホイールと上下キーによる値の増減
     * @param stepNum 増減させる値
     */
    stepChangeValue(stepNum, start_int) {
      // 限界値判定
      let plusResult = plusDecimal(start_int, stepNum);

      // 限界値を超えた際の値をループ設定有無で振り分け
      let max_value = 0;
      let min_value = 1;
      if (this.datetype === 'period-year') max_value = 9999;
      if (this.datetype === 'period-month') max_value = 12;
      if (this.datetype === 'period-day') {
        max_value = 31;
        if (this.datetypeym != null && this.datetypeym.length ===8) {
            const yy = this.datetypeym.substr(0, 4) ? this.datetypeym.substr(0, 4) : '0000';
            const mm = this.datetypeym.substr(4, 2) ? this.datetypeym.substr(4, 2) : '00';
            let date_tmp = new Date(yy, parseInt(mm,10), 0);
            max_value = date_tmp.toLocaleDateString().slice(-2);
        }
      }
      if (plusResult > max_value) {
        plusResult = min_value;
      } else if (plusResult < min_value) {
        plusResult = max_value;
      }
      this.udpateValue(plusResult);
    },
    /**
     * @description 編集値の更新と同時に表示値を書き換える
     * @param value 値
     */
    udpateValue(value) {
      let editString="";
      if (value === null) {
        // 空欄
        value = "0";
      } else {
        // 0詰め
        let patsu = 2;
        if (this.datetype === 'period-year') patsu = 4;
        editString = value.toString().padStart(patsu,"0");
      }
      this.editValue = editString;
    },
    //#10866：日付(不定型)の部品修正End
  }
};
</script>

<style scoped>
input {
  color: var(--ntss-list-body-color);
  background-color: var(--ntss-list-background-color);
}

.custom-input-edited {
  border: 2px green solid;
  outline: 0;
}

.custom-input-required {
  color: black;
  background-color: #ffff99;
}

.custom-input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 0.5);
}
</style>
