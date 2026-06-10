/**
 * マスタ選択共通コンポーネント
 */
<template>
  <v-ons-row>
    <v-ons-col class="text-value">
      <!-- mod #10359 編集権限の動作不正 start -->
      <!-- <v-ons-input type="text" v-model="nameValue" class="text" :style="contentInputText"></v-ons-input> -->
      <v-ons-input
        type="text"
        v-model="nameValue"
        :disabled="
          !getItemAuthorized('PatEvent', 'default_authority')
        "
        class="text"
        :style="contentInputText"
      ></v-ons-input>
      <!-- mod #10359 編集権限の動作不正 end -->
      <label class="text-view ntss-pat-event-label" :style="contentText">{{nameValue}}</label>
    </v-ons-col>
    <v-ons-col class="select-button" :style="contentInputText">
      <!-- mod #10359 編集権限の動作不正 start -->
      <!-- <v-ons-button class="button btn3-normal" @click="handleShowPopover">選択</v-ons-button> -->
      <v-ons-button
        class="button btn3-normal"
        :disabled="
          !getItemAuthorized('PatEvent', 'default_authority')
        "
        @click="handleShowPopover"
        >選択</v-ons-button
      >
      <!-- mod #10359 編集権限の動作不正 end -->
      <pop-over v-bind="popoverData" @popover-close="closePopover" @popover-return="updateInput" />
    </v-ons-col>
  </v-ons-row>
</template>

<script>
import { mapGetters } from "vuex";
import MasterSelectorMixin from "@/components/common/master-selector/MasterSelectorMixin";
import { Master } from "@/models/common/master-selector-condition/Master";
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end

export default {
  mixins: [MasterSelectorMixin],
  props: {
    index: {
      type: Number,
      default: undefined
    },
    name: {
      type: String
    },
    labelName: {
      type: String
    },
    showLabelName: {
      type: Boolean,
      default: true
    },
    showClassFilter: {
      type: Boolean,
      default: true
    },
    value: {
      type: Object
    }
  },
  computed: {
    ...mapGetters("pat-event/detail", ["getViewMode"]),
    nameValue: {
      get() {
        return this.value ? this.value.name : "";
      },
      set(value) {
        const master = new Master(null, value);
        if (value.needle) {
          master.needle = value.needle;
        }
        this.$emit("input", master, this.index);
      }
    },
    contentInputText() {
      if (this.getViewMode) {
        return { display: "none" };
      } else {
        return { display: "inline-block" };
      }
    },
    contentText() {
      if (this.getViewMode) {
        return { display: "inline-block" };
      } else {
        return { display: "none" };
      }
    }
  },
  methods: {
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
    updateInput(data) {
      const master = new Master(data.value, data.text);
      if (data.needle) {
        master.needle = data.needle;
      }

      this.popoverData.popoverContentSelected = data;
      this.$emit("input", master, this.index);
      this.$emit("changeUnit", data.unit, this.index);
      this.$emit("changePersonalUser", data.personalUserInfo, this.index);
    },
    handleShowPopover() {
      this.popoverData.popoverContentDataset.length === 0
        // #11389 患者イベントの編集での不正　V1.1A linjunfeng start
        // ? this.createPopoverData()
        ? this.createPopoverData(this.value.cd)
        // #11389 患者イベントの編集での不正　V1.1A linjunfeng end
        : this.showPopover();
    }
  }
};
</script>

<style scoped>
.text-value {
  min-width: 10em;
  max-width: 36em;
}
.select-button {
  min-width: 5em;
  max-width: 5em;
  margin-left: 0.2em;
  border-radius: 5px;
  margin-bottom: 2px;
}
.select-btn {
  padding: 0.2em 1em 0em 1em;
  min-width: 5em;
  font-size: 100%;
}
.text-view {
  font-size: 1.2em;
}
.text >>> .text-input {
/*mod FNSI-改修内容5348 。fan start*/
height: 2.0em;
/*mod FNSI-改修内容5348 。fan end*/
}
</style>
