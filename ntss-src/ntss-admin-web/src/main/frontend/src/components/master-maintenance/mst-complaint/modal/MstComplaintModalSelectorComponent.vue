<template>
  <v-ons-row class="mst-selector">
    <v-ons-col v-if="showLabelName" class="title d-flex align-items-center">
      <label class="theme">
        {{ labelName }}
      </label>
    </v-ons-col>
    <v-ons-col class="text-value d-flex align-items-center">
      <!-- mod #7727 処置薬剤と数量は必須であってはいけない。start -->
      <!-- <v-ons-input
        v-model="value.name"
        class="input-required input_change input-padding"
        type="text"
        readonly
      ></v-ons-input> -->
      <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
      <common-master-selector
        :masterType="MasterType.MEDICATION_TREATMENT_RECORD"
        :initItem="{text:modelValue.initName,value:modelValue.initCd}"
        :editItem="{text:modelValue.name,value:modelValue.cd}"
        :patientId="null"
        :extraParams="{ treatDate: '', rstInfo: { rstName: modelValue.name, rstUnit: modelValue.unit }, medicineType: modelValue.type != null ? modelValue.type : modelValue.medicineType }"
        :facilityCd="getFacilityCd"
        :isMedicament="'0'"
        :hasChangedOption="true"
        :selectedItemClass="'com-basic-sub-input'"
        :backgroundColor="'#f7f7f7'"
        :btnClass="'com-basic-sub-btn'"
        :btnDisabled="isDisabled"
        :isSelectionRequired="true"
        :hasUnregisteredOption="false"
        @popover-return="masterUpdateInput($event);"
      />
       <!--<v-ons-input
        v-model="modelValue.name"
        class="input-padding"
        type="text"
        readonly
        disabled
      ></v-ons-input> -->
      
      <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
      <!-- mod #7727 処置薬剤と数量は必須であってはいけない。end -->
      <!-- <input
        v-model="modelValue.name"
        class="input-required equipment-input-style common-input-style"
        type="text"
        readonly
      /> -->
    </v-ons-col>
    <v-ons-col class="select-button-col d-flex align-items-center">
      <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
      <!--<v-ons-button
        class="button select-btn btn3-normal"
        @click="createPopoverData(modelValue ? modelValue.cd : null)"
        :disabled="isDisabled">選択</v-ons-button>
      <pop-over v-bind="popoverData" @popover-close="closePopover" @popover-return="updateInput" />-->
      <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
    </v-ons-col>
  </v-ons-row>
</template>

<script>
import MasterSelectorMixin from "@/components/common/master-selector/MasterSelectorMixin";
import { Master } from "@/models/common/master-selector-condition/Master";
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";

import { mapGetters } from "@/compat/vue/vuex";

// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
export default {
  mixins: [MasterSelectorMixin],
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
  components: {
    "common-master-selector": commonMasterSelector,
  },
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
  data() {
    return {
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      mstExtraParams:{},
      MasterType,
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    }
  },
  emits: [
    "update:modelValue",
    "changeUnit",
    "changeDecPoint",
    "changePersonalUser"
  ],
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
    // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
    modelValue: {
      type: Object
    },
    isDisabled: {
      type: Boolean,
      default: false
    },
  },
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("user", ["getFacilityCd"]),
  },
  methods: {
    masterUpdateInput(val){
      const medicineKbn = val.kbnValue ?? val.key_type ?? val._sourceTag;
      const data = {
        fnValue:{
          '薬剤分類': val.classCd,
          '薬剤区分': medicineKbn
        },
        isDisp: val.isDisp,
        text: val.text,
        type: medicineKbn,
        value: Number(val.value),
        unit: val.unit,
        decPoint: val.unitDecimalPoint
      }
      this.updateInput(data)
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    updateInput(data) {
      const master = new Master(data.value, data.text);
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      master.type = data.type
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      if (data.needle) {
        master.needle = data.needle;
      }
      this.popoverData.popoverContentSelected = data;
      this.$emit("update:modelValue", master, this.index);
      this.$emit("changeUnit", data.unit, this.index);
      this.$emit("changeDecPoint",data.decPoint, this.index);
      this.$emit("changePersonalUser", data.personalUserInfo, this.index);
    }
  }
};
</script>

<style scoped>
.select-button-col{
  flex: 0 0 4em;
}
.select-btn {
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  min-width: 4em;
  font-size: 1em;
  cursor: pointer;
}
.select-btn:hover {
  color: #212529;
}
/* del #7727 処置薬剤と数量は必須であってはいけない。start */
/* .input-required :deep(input){
  color: black;
  background-color: #ffff99;
}
.input-invalid :deep(input){
  color: black;
  background-color: rgba(255, 0, 0, 1);
} */
/* del #7727 処置薬剤と数量は必須であってはいけない。end */
.input-padding {
  padding: 0 5px 0 0;
}

.input-padding > :deep(.text-input:disabled) {
  opacity: unset !important;
}
/*// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start*/
:deep(.com-basic-sub-btn) {
  margin-left: 5px
}
:deep(.com-basic-sub-input) {
  min-width: 13em;
  width: 100%;
  max-width: 28em;
  background-color: #f7f7f7;
}
/*// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end*/
</style>
