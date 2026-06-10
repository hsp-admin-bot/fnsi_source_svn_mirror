/**
 * 治療記録の子機能 治療条件（シングルニードル）
 */
<template>
  <div class="expandable-content">
    <com-radio name="single-needle" labelName="シングルニードル使用" :radioItems=radioItems.singleNeedle v-model="inputModel.singleNeedle" />
  </div>
</template>

<script>
import CommonRadio from "@/components/treatment-record/submenu/common/CommonRadioComponent";
import { CODES } from "@/constants/TreatmentRecord";
import { SingleNeedle } from "@/models/treatment-record/condition/SingleNeedle";

export default {
  components: {
    "com-radio": CommonRadio
  },
  props: {
    value: {
      type: SingleNeedle
    }
  },
  data() {
    return {
      inputModel: new SingleNeedle(),
      radioItems: {
        singleNeedle: CODES.SINGLE_NEEDLE
      }
    };
  },
  watch: {
    value() {
      this.inputModel = this.value;
    },
    inputModel: {
      handler: function(val) {
        this.$emit("input", val);
      },
      deep: true
    }
  }
};
</script>

<style scoped>
</style>
