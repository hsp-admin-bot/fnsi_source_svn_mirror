<template>
  <v-ons-col style="display: flex">
    
  <!-- add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
    <show-selected-item
      v-if="isVisible"
      :propInitValue="innerInitItem.text"
      :propEditValue="innerEditItem.text"
      :propBackgroundColor="backgroundColor"
      :class="selectedItemClass"
    />

  <!-- add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
    <v-ons-button
      ref="popoverButton"
      v-show="btnVisible"
      :disabled="btnDisabled"
      class="common-style-select-button"
      :class="btnClass"
      @click="onSelectClick"
    >
    <!-- add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
      <!--選択-->
      {{ name }}
      <!-- add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
    </v-ons-button>

    <pop-over
      v-bind="popoverData"
      :target-position-element="getPopoverTargetResolved()"
      :biz-direction="bizDirection"
      :hasUnregisteredOption="hasUnregisteredOption"
      :isSelectionRequired="isSelectionRequired"
      @popover-close="closePopover"
      @popover-return="handlePopoverReturn"
      @master-load-more="$emit('master-load-more')"
      @master-reset-request="$emit('master-reset-request', $event)"
    />
  </v-ons-col>
</template>

<script>
import CustomDivShowSelectedItem from "@/components/common/custom-form-tags/CustomDivShowSelectedItem";
import MasterPopover from "@/components/common/master-selector/MasterPopover";

export default {
  name: "MasterSelector2",
  emits: [
    "create-popover-data",
    "popover-close",
    "popover-return",
    "master-load-more",
    "master-reset-request",
  ],

  components: {
    "show-selected-item": CustomDivShowSelectedItem,
    "pop-over": MasterPopover,
  },

  props: {
    btnDisabled: Boolean,

    bizDirection: {
      type: String,
      default: null,
    },

    initItem: {
      type: Object,
      required: true,
    },

    editItem: {
      type: Object,
      required: true,
    },

    popoverData: {
      type: Object,
      required: true,
    },

    selectedItemClass: {
      type: [Object, String, Array],
      default: () => ({}),
    },

    backgroundColor: {
      type: String
    },

    btnClass: {
      type: [Object, String, Array],
      default: () => ({}),
    },

    btnVisible: {
      type: Boolean,
      default: true
    },

    /** btnVisible=false 時は内蔵ボタンが表示されないため、親の外部ボタン等を POP 基準にする */
    popoverAnchorElement: {
      default: null,
    },

    hasUnregisteredOption: {
      type: Boolean,
      default: true
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    buttonName: {
      type: String
    },
    visible: {
      type: Boolean,
      default: true
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
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      name:'',
      isVisible: true,
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    };
  },

  watch: {
    initItem: {
      // add #10937 20260428 Ji start
      immediate: true,
      // add #10937 20260428 Ji end
      handler(val) {
        this.innerInitItem = { ...val };
      },
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    editItem: {
      immediate: true,
      handler(val) {
        this.innerEditItem = { ...val };
      },
    },
    buttonName: {
      immediate: true,
      handler(val) {
        this.name = val;
      },
    },
    visible: {
      immediate: true,
      handler(val) {
        this.isVisible = val;
      },
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
  },

  methods: {
    getPopoverTargetResolved() {
      const ext = this.popoverAnchorElement;
      if (this.isValidExternalPopoverAnchor(ext)) {
        return ext;
      }
      const btn = this.$refs.popoverButton;
      if (btn != null) {
        return btn;
      }
      return this.$el;
    },

    isValidExternalPopoverAnchor(ext) {
      if (ext == null || ext === false || ext === "") return false;
      if (typeof ext !== "object") return false;
      if (typeof ext.getBoundingClientRect === "function") return true;
      if (
        ext.$el != null &&
        typeof ext.$el.getBoundingClientRect === "function"
      ) {
        return true;
      }
      return false;
    },

    onSelectClick() {
      this.$emit("create-popover-data");
    },

    closePopover() {
      this.popoverData.popoverVisible = false;
      this.$emit("popover-close");
    },

    handlePopoverReturn(item) {
      this.innerEditItem = item;
      this.$emit("popover-return", item);
      this.closePopover();
    },
  },
};
</script>

<style scoped>
.selector-input {
  min-width: 11em;
  width: 100%;
  max-width: 13em;
  background-color: #f7f7f7;
}
</style>
