/**
 * 治療記録の子機能 処置薬剤表示ポップオーバー
 */
<template>
  <v-ons-popover
    v-if="popoverVisible"
    cancelable
    :visible="popoverVisible"
    :target="popoverTarget"
    :direction="popoverDisplayDirection"
    :class="[fontSizeSet, 'medicine-popover']"
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="closePopover(); popoverPosthide($event)"
  >
    <div style="max-height: 60vh; overflow: auto;">
      <table class="treatment-record-tool-tip">
        <thead>
          <tr>
            <th class="ntss-list-header-th-sticky" style="width: 45%;">
              <label>処置薬剤</label>
            </th>
            <th class="ntss-list-header-th-sticky" style="width: 15%;">
              <label>数量</label>
            </th>
            <th class="ntss-list-header-th-sticky" style="width: 15%;">
              <label>単位</label>
            </th>
            <th class="ntss-list-header-th-sticky" style="width: 25%;">
              <label>手技</label>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td v-if="!checkExistContraindications" class="ntss-list-body-td-tool-tip">
              <label>{{ popoverTreatment.treatMedicine }} </label>
            </td>
            <td v-if="checkExistContraindications" class="ntss-list-body-td-tool-tip text-color-contraindication">
              <label>{{ popoverTreatment.treatMedicine }} </label>
            </td>
            <td class="ntss-list-body-td-tool-tip">
              <label>{{ popoverTreatment.amount }}</label>
            </td>
            <td class="ntss-list-body-td-tool-tip">
              <label>{{ popoverTreatment.unit }}</label>
            </td>
            <td class="ntss-list-body-td-tool-tip">
              <label>{{ popoverTreatment.procedure }}</label>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </v-ons-popover>
</template>

<script>
import PopoverMixin from "@/components/PopoverMixin";
import { mapGetters } from "vuex";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";

export default {
  mixins: [PopoverMixin], 
  props: {
    popoverVisible: {
      type: Boolean,
      required: true,
      default: false
    },
    popoverTarget: {
      type: HTMLElement
    },
    popoverTreatment: {
      type: Object,
      default: null
    },
    data() {
      return {
        popoverVisible: false
      }
    }
  },
  computed: {
    ...mapGetters("window-size", {
      windowWidth: "getMainWindowWidth",
      windowHeight: "getWindowHeight"
    }),
    /**
     * @description ポップオーバを表示する方向を取得.
     *              クリックされた要素のトップの位置と画面サイズの差が200未満の場合に
     *              クリックされた要素の上部に表示します.
     * 
     * @returns {String} 表示方向
     */
    popoverDisplayDirection() {
      if (!this.popoverVisible) return null;
      const elemPosition = this.popoverTarget.getBoundingClientRect();
      let direction = "down"
      if ((this.windowHeight - elemPosition.top) < 200) {
        direction = "up"
      }
      return direction;
    },

    // check condition change image icon bottle
    checkExistContraindications() {
      const textContraindications = this.popoverTreatment.treatMedicine;
      return (
        textContraindications.includes("【禁忌】") ||
        textContraindications.includes("【禁忌・ｱﾚﾙｷﾞｰ】") ||
        textContraindications.includes("【ｱﾚﾙｷﾞｰ】")
      );
    }
  },
  methods: {
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * @description ポップオーバー非表示
     */
    closePopover() {
      this.$emit("popover-close", false);
    },
  },
};
</script>

<style scoped>
.medicine-popover >>> .popover__content {
  padding: 5px;
}
.medicine-popover >>> .popover__content,
.medicine-popover >>> .popover--top {
  width: 500px;
  max-width: 95vw;
}
.treatment-record-tool-tip {
  border-collapse: collapse;
  margin: 0 auto;
  font-size: 1.5em;
  background-color: var(--ntss-list-background-color);
  width: 100%;
  min-height: 90px;
}
.ntss-list-body-td-tool-tip {
  vertical-align: middle;
  padding: 8px;
}
.text-color-contraindication {
  color: #FF0000;
}
table.treatment-record-tool-tip td,
table.treatment-record-tool-tip th {
  border: solid 1px #cccccc;
}
</style>
