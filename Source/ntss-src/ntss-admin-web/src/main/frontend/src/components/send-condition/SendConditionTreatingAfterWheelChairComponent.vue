
/**
 * 治療中後体重用車いす測定画面
 */
<template>
  <div class='sub-content-area ntss-send-condition-text'>
    <v-ons-row id='measure-value-row'>
      <div id='measure-value-block vertical-div'>
        <label class="send-condition-title-label">{{MeasuredValueLabel}}</label>
        <div class="horizontal-div">
          <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
          <!-- <v-ons-input class='send-condition-measure-value-simple' type='number' step="0.01"
            v-model.number='editMeasuredValue'
            pattern='^\d{1,3}(\.\d{1,2})?$'
            @blur="changeMeasureVal(measureValue, $event)"
            @keydown.enter='changeMeasureVal(measureValue, $event)'></v-ons-input>
          <label class='send-condition-unit'> kg</label> -->
          <v-ons-input class='send-condition-measure-value-simple'
            id="cewehightID"
            type='text'
            v-model.number='editMeasuredValue'
            @blur="changeMeasureVal(editMeasuredValue, $event)"
            @keydown.enter='changeMeasureVal(editMeasuredValue, $event)'></v-ons-input>
          <label class='send-condition-unit'> kg</label>
          <img :src="image_src" v-show="this.getWeightMode.isWeightMode" @click="show"/>
          <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
        </div>
        <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
        <v-ons-popover cancelable v-model:visible="cavisible" :target="popoverTarget" direction="down" class="popoverClass">
          <vue-touch-keyboard :options="options" :layout="layout" :cancel="hide" :accept="accept" :input="input"  />
        </v-ons-popover>
        <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
      </div>
    </v-ons-row>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import TouchKeyboard from "@/compat/keyboard/TouchKeyboard.vue";
import { publicAssetPath } from "@/compat/assets/public-path";
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
// add FNSI-体重計モードテンキーの追加 徐 start
// add FNSI-体重計モードテンキーの追加 徐 end

export default {

  // add FNSI-体重計モードテンキーの追加 徐 start
  components: {
    "vue-touch-keyboard": TouchKeyboard
  },
  // add FNSI-体重計モードテンキーの追加 徐 end
  data() {
    return {
      measureValue: 0,
      // add FNSI-体重計モードテンキーの追加 徐 start
      cavisible: false,
      layout: null,
      input: null,
      options: {
        useKbEvents: false,
        preventClickEvent: false
      },
      image_src: publicAssetPath("img/keyboard/keyboard.png"),
      popoverTarget: null
      // add FNSI-体重計モードテンキーの追加 徐 end
    };
    
  },
  computed: {
    ...mapGetters("send-condition/scale", [
      "getSelectWheelchair"
    ]),
    // add FNSI-体重計モードテンキーの追加 徐 start
    ...mapGetters("send-condition/weight", ["getWeightMode"]),
    // add FNSI-体重計モードテンキーの追加 徐 end
    MeasuredValueLabel: {
      get() {
        return "後体重測定用 車いす";
      }
    },
    // 測定値
    editMeasuredValue: {
      get() {
        return this.getSelectWheelchair.weight;
      },
      set(val) {
        this.setMeasuring(true);
        this.measureValue = val;
      }
    }
  },
  methods: {
    ...mapActions("send-condition/scale", [
      "calcWeightValue",
      "changeWheelChairWeightValue",
      "setMeasuring"
    ]),
    // 測定値変更時
    changeMeasureVal(oldVal, e) {
      // 入力制限
      // add FNSI-体重計モードテンキーの追加 徐 start
      // const re = new RegExp(e.target.pattern);
      // const result = re.exec(e.target.value);
      // e.target.value = result ? result.input : oldVal;
      let pattern = "^([0-9][0-9]{0,2}|0)(.[0-9]{1,2})?$";
        const re = new RegExp(pattern);
        const result = re.exec(e.target.value);
        if (result) {
          if (result.input > 999.99) {
            e.target.value = 999.99;
          } else {
            e.target.value = Number(result.input);
          }
        } else {
          if (this.getWeightMode.isWeightMode) {
            if (e.target.value === null || e.target.value === "") {
              e.target.value = "";
            } else {
              let valueSplit = String(e.target.value).split(".");
              if (valueSplit.length === 2) {
                if (valueSplit[0].length > 3) {
                  e.target.value = 999.99;
                } else if (valueSplit[1].length > 2) {
                  e.target.value = oldVal;
                } else if (valueSplit[0].length === 0 && valueSplit[1].length === 0) {
                  e.target.value = null;
                }
              }
            }
          } else {
            e.target.value = oldVal;
          }
        }
      // add FNSI-体重計モードテンキーの追加 徐 end
      this.changeWheelChairWeightValue(e.target.value).then(() => {
        // 体重値計算
        this.calcWeightValue();
      });
      // add FNSI-体重計モードテンキーの追加 徐 start
      setTimeout( () => {
          let b = true;
          let str = this.editMeasuredValue.replaceAll(".","");
          if (str.length >= this.editMeasuredValue.length - 1) {
            let regex = /^[0-9]*$/;
            b = regex.test(str);
          } else {
            b = false;
          }

          if ( b === false) {
            const weightInput = getScopedElementById("cewehightID", this.$el || this);
            if (weightInput) {
              weightInput.value = null;
            }
            this.editMeasuredValue = null;
          }
        }, 300);
      // add FNSI-体重計モードテンキーの追加 徐 end
    },
    // add FNSI-体重計モードテンキーの追加 徐 start
    accept() {
      this.hide();
    },
    show() {
      if (this.getWeightMode.isWeightMode) {
        this.input = getScopedElementById("cewehightID", this.$el || this)?.firstElementChild || null;
        this.input?.focus?.();
        this.input?.setSelectionRange?.(0, this.input.value.length);
        this.popoverTarget = getScopedElementById("cewehightID", this.$el || this);
        this.cavisible = !this.cavisible;
        let name = ["7 8 9", "4 5 6", "1 2 3", "{zero} . {accept}"];
        let meta = { "zero": { key: "0"}, "accept": { func: "accept", text: "CLR"} }
        let layoutparam = {default: name, _meta: meta};
        this.layout = layoutparam;
      }
    },
    hide() {
      const weightInput = getScopedElementById("cewehightID", this.$el || this);
      if (weightInput) {
        weightInput.value = null;
      }
      this.changeWheelChairWeightValue(null).then(() => {
        // 体重値計算
        this.calcWeightValue();
      });
    }
    // add FNSI-体重計モードテンキーの追加 徐 end
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};
</script>
<style scoped>
.sub-content-area {
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}

#measure-value-row {
  justify-content: center;
}
#measure-value-block {
  text-align: center;
  justify-content: space-evenly;
  margin-bottom: 5px;
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
 
/* add FNSI-体重計モードテンキーの追加 徐 start */
ons-input :deep(.text-input) {
  text-align: right;
}
.popoverClass :deep(.popover--top) {
  width: auto;
}
/* add FNSI-体重計モードテンキーの追加 徐 end */
</style>
