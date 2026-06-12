import { defineComponent } from "vue";
import CustomInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import { isDecimal } from "@/functions/common/NumberFunctions.js";

const ExtendedCustomInputNumber = defineComponent({
  name: "ExtendedCustomInputNumber",
  extends: CustomInputNumber,
  props: {
    // マウスホイールの刻み幅
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

export default ExtendedCustomInputNumber;
