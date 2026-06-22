/** * 治療条件ーDW */

<template>
  <v-ons-row class="action-condition-target-dw">
    <v-ons-col class="action-condition-column"> DW</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <v-ons-row class="action-condition-row">
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <custom-input-number -->
        <!--   :value="displayInputValue" -->
        <!--   :digits="5" -->
        <!--   :decimal-digits="2" -->
        <!--   :min-value="0.0" -->
        <!--   :max-value="300.0" -->
        <!--   class="action-condition-input" -->
        <!--   style="width: 90px" -->
        <!-- /> -->
        <custom-input-number
          :value="displayInputValue"
          :digits="5"
          :decimal-digits="2"
          :min-value="0.0"
          :max-value="300.0"
          class="action-condition-input"
          style="width: 90px"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <label>Kg</label>
      </v-ons-row>
    </v-ons-col>
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";

export default {
  mixins: [IndTreatCondBase],
  // add #10359 編集権限の動作不正 dengshen start
  methods: {
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
  },
  // add #10359 編集権限の動作不正 dengshen end
  mounted() {
    this.treatItemCd = "39";
    this.unit = "Kg";
  }
};
</script>

<style scoped>
/* アクションチャート内inputタグ */
.action-condition-input {
  width: 138px;
  margin: 0px 5px 0px 0px;
}

.action-condition-target-dw {
  border: 1px solid var(--ntss-border-color);
  padding: 10px;
}

.action-condition-row {
  align-items: center;
}
.action-condition-column {
  flex: 0 0 9%;
  max-width: 30%;
  white-space: normal;
  margin: auto;
}
.action-condition-data-column {
  margin: auto;
  padding-left: 10px;
  margin-right: 5px;
}
</style>
