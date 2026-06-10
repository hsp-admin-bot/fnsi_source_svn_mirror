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
      :target-position-element="$refs.popoverButton"
      :biz-direction="bizDirection"
      :hasUnregisteredOption="hasUnregisteredOption"
      :isSelectionRequired="isSelectionRequired"
      @popover-close="closePopover"
      @popover-return="handlePopoverReturn"
    />
  </v-ons-col>
</template>

<script>
import CustomDivShowSelectedItem from "@/components/common/custom-form-tags/CustomDivShowSelectedItem";
import MasterPopover from "@/components/common/master-selector/MasterPopover";

export default {
  name: "MasterSelector2",

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

    hasUnregisteredOption: {
      type: Boolean
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
