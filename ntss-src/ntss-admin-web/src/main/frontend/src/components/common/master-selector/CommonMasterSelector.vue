<template>
  <!-- add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
  <master-picker
    :initItem="innerInitItem"
    :editItem="innerEditItem"
    :popoverData="innerPopoverData"
    :bizDirection="directionByBiz"
    :selectedItemClass="selectedItemClass"
    :backgroundColor="backgroundColor"
    :btnClass="btnClass"
    :btnDisabled="btnDisabled"
    :btnVisible="btnVisible"
    :buttonName="buttonName"
    :visible="visible"
    :hasUnregisteredOption="hasUnregisteredOption"
    :isSelectionRequired="isSelectionRequired"
    @create-popover-data="createPopover"
    @popover-close="$emit('popover-close')"
    @popover-return="handlePopoverReturn"
  />
  <!-- add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
</template>

<script>
import MasterPicker from "@/components/common/master-selector/MasterPicker";
import {
  buildMasterPopover,
  buildInitSelectedItem,
} from "@/components/common/master-selector/builder/builderFactory";
import { MASTER } from "@/components/common/master-selector/MasterType";
import {
  appendChangedOptionsIfNeeded,
  removePrefixFromOptions,
  handleMasterLoadError,
} from "@/components/common/master-selector/utils/MasterSelectorUtil";
import { cloneDeep } from "lodash";

export default {
  name: "CommonMasterSelector",
  components: { MasterPicker },

  props: {
    btnDisabled: Boolean,
    btnVisible: {
      type: Boolean,
      default: true,
    },
    masterType: {
      type: String,
      required: true,
    },
    initItem: {
      type: Object,
      default: () => ({}),
    },
    editItem: {
      type: Object,
      default: () => ({}),
    },
    patientId: {
      type: [String, Number],
    },
    facilityCd: {
      type: [String, Number],
    },
    extraParams: {
      type: Object,
      default: () => ({}),
    },
    selectedItemClass: {
      type: [Object, String, Array],
      default: () => ({}),
    },
    btnClass: {
      type: [Object, String, Array],
      default: () => ({}),
    },
    backgroundColor: {
      type: String,
    },
    hasUnregisteredOption: {
      type: Boolean,
      default: true,
    },
    hasChangedOption: {
      type: Boolean,
      default: false,
    },
    changeOptionMode: {
      type: String,
      default: "nameOnly",
      validator: (v) => ["nameOnly", "nameAndUnit"].includes(v),
    },
    
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    btnName: {
      type: String,
    },
    isVisible: {
      type: Boolean,
      default: true,
    },
    isMedicament: {
      type: String,
      default: "0"
    },
    dialysisState: {
      type: Number,
      default: 0
    },
    allowedFields: {
      type: [Object, String, Array],
      default: () => ({}),
    },
    
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    isSelectionRequired: {
      type: Boolean,
      default: false
    },
  },

  data() {
    return {
      innerInitItem: {},
      innerEditItem: {},
      innerPopoverData: {},
      buttonName:'',
      visible:true,
    };
  },

  watch: {
    initItem: {
      immediate: true,
      deep: true,
      handler(val) {
        this.innerInitItem = cloneDeep(val || {});
      },
    },
    editItem: {
      immediate: true,
      deep: true,
      handler(val) {
        this.innerEditItem = cloneDeep(val || {});
      },
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    btnName:{
      immediate: true,
      handler(val) {
        this.buttonName = cloneDeep(val || '選択');
      },
    },
    isVisible:{
      immediate: true,
      handler(val) {
        this.visible = cloneDeep(val);
      },
    },
    
    //add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
  },

  computed: {
    directionByBiz() {
      return MASTER[this.masterType].popoverDirection;
    },
  },

  methods: {
    async initSelector() {
      try {
        const result = await buildInitSelectedItem(
          this.masterType,
          this.createContext()
        );
        if (!result) return;

        const newInitItem = cloneDeep(result.initItem || {});
        const newEditItem = cloneDeep(result.selectedItem || {});
        this.innerInitItem = newInitItem;
        this.innerEditItem = newEditItem;
        this.$emit("update:initItem", newInitItem);
        this.$emit("update:editItem", newEditItem);
      } catch (e) {
        console.error("[CommonMasterSelector] 初期選択生成失敗", e);
        handleMasterLoadError(e, "initSelector");
      }
    },

    async createPopover() {
      if (!this.masterType) return;
      try {
        const popoverData = await buildMasterPopover(
          this.masterType,
          this.createContext()
        );
        if (!popoverData) return;
        appendChangedOptionsIfNeeded(popoverData, this.createContext());

        this.innerPopoverData = cloneDeep(popoverData || {});
        this.$set(this.innerPopoverData, "popoverVisible", true);

        this.$emit("popover-open", {
          masterType: this.masterType,
          popoverData: cloneDeep(this.innerPopoverData),
        });
      } catch (e) {
        console.error("[CommonMasterSelector] Popover生成失敗", e);
        handleMasterLoadError(e, "createPopover");
      }
    },
    async handlePopoverReturn(item) {
      try {
        const resultItem = removePrefixFromOptions(item, this.createContext());
        this.innerEditItem = cloneDeep(resultItem);
        this.$set(
          this.innerPopoverData.master,
          "selectedItem",
          cloneDeep(resultItem)
        );
        this.$emit("popover-return", cloneDeep(resultItem));
      } catch (e) {
        console.error("[CommonMasterSelector] Popover返却失敗", e);
        handleMasterLoadError(e, "handlePopoverReturn");
      }
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    createContext() {
      return {
        vm: this,
        masterType: this.masterType,
        patientId: this.patientId,
        facilityCd: this.facilityCd,
        initItem: this.innerInitItem,
        selectedItem: this.innerEditItem,
        extraParams: this.extraParams,
        hasChangedOption: this.hasChangedOption,
        changeOptionMode: this.changeOptionMode,
        isMedicament: this.isMedicament,
        dialysisState: this.dialysisState,
        allowedFields: this.allowedFields,
      };
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
  },
};
</script>
