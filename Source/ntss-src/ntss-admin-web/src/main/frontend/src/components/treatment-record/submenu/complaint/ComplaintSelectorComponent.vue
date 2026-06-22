/**
 * 治療記録の子機能 愁訴選択ポップオーバー
 */
<template>
  <v-ons-popover
    cancelable
    :visible="popoverVisible"
    :target="popoverTarget"
    direction="down up"
    :class="[fontSizeSet, 'complaint-popover']"
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="onCancel(); popoverPosthide($event)"
  >
    <div class="filter-area">
      <v-ons-input type="text" class="ntss-input-search" v-model="searchText" @keydown.enter="onSearchEnter" />
      <v-ons-button class="btn3-normal search-button" @click="onSearchClick">検索</v-ons-button>
    </div>
    <div class="list-area">
      <table class="ntss-list">
        <thead>
          <tr>
            <th class="ntss-list-header-th-sticky" style="width: 3em;"><label>頁番号</label></th>
            <th class="ntss-list-header-th-sticky"><label>愁訴</label></th>
          </tr>
        </thead>
        <tbody :class="themeBlack">
          <tr class="ntss-list-body-tr">
            <td class="ntss-list-body-td border-per-page-bottom"></td>
            <td
              class="ntss-list-body-td border-per-page-bottom"
              :class="itemRowClass(-1, hasMatchedName)"
              @click="onItemClick(-1)"
              @dblclick="onItemDblClick(-1)"
            >
              <label>未登録</label>
            </td>
          </tr>
          <template v-for="(item, index) in selectItems" :key="index">
            <tr class="ntss-list-body-tr">
              <td
                v-if="(index % perPage) == 0"
                v-show="isVisiblePage(selectItems, index, hasMatchedName)"
                class="ntss-list-body-td border-per-page-bottom"
                :rowspan="perPage"
              >
                <label>{{ (index / perPage) + 1 }}</label>
              </td>
              <td
                v-show="isVisibleItem(selectItems, index, hasMatchedName)"
                class="ntss-list-body-td"
                :class="itemRowClass(index, hasMatchedName)"
                @click="onItemClick(index)"
                @dblclick="onItemDblClick(index)"
              >
                <label>{{ item.name || '&nbsp;' }}</label>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>
    <div class="button-area flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button denial-btn btn2-cancel" @click="onCancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button registration-btn btn3-normal" :disabled="selectedIndex === null" @click="onOk">OK</v-ons-button>
      </div>
    </div>
  </v-ons-popover>
</template>

<script>
import { mapGetters } from "@/compat/vue/vuex";
import { MstComplaint } from "@/models/treatment-record/complaint/MstComplaint";
import ComplaintComponentMixin from "@/components/treatment-record/submenu/complaint/ComplaintComponentMixin";
import SelectorComponentMixin from "@/components/treatment-record/submenu/complaint/SelectorComponentMixin";
import PopoverMixin from "@/components/PopoverMixin";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { getMstListCompose } from "@/apis/pat-prescription";
import { getMasterConfig } from "@/components/common/master-selector/builder/masterPopoverConfig";
import * as MasterType from "@/components/common/master-selector/MasterType";

export default {
  mixins: [ComplaintComponentMixin, SelectorComponentMixin, PopoverMixin],
  computed: {
    ...mapGetters("account-edit", ["getTheme"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    themeBlack() {
      return this.getTheme === 1 ? "ntss-list-body-tr-black" : "";
    }
  },
  methods: {
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * 初期化処理.
     */
    async init() {
      this.nonSelectValue = new MstComplaint();

      const query = getMasterConfig(MasterType.COMPLAINT_TREATMENT_RECORD, {
        facilityCd: this.facilityCd
      });
      const response = await getMstListCompose(query);
      const items = response?.data?.master?.items ?? [];
      this.selectItems = items
        .filter(e => e.isDisp === "1")
        .map(e => new MstComplaint(e.complaintCd, e.complaintName));
    }
  }
};
</script>

<style scoped>
@media print {
  .list-area{
    height: auto !important;
  }
}
.complaint-popover {
  padding: 4px;
}
.filter-area ons-input,
.filter-area ons-button {
  margin: 4px;
}
.search-button {
  width: 4em;
  font-size: 1.5em;
}
.complaint-popover :deep(.popover__content) {
  padding: 5px;
}
.complaint-popover :deep(.popover__content),
.complaint-popover :deep(.popover--top) {
  width: 400px;
  max-width: 95vw;
}
.list-area {
  overflow: auto;
  height: 300px;
}
.ntss-list {
  position: relative;
}
.button-area {
  margin: 8px 0px;
  height: auto;
}
.ntss-list-body-td {
  padding: 2px;
}
.selected-item-tr {
  background-color: var(--treatment-record-complaint-selected-background-color);
  color: var(--treatment-record-complaint-selected-color);
}
.border-per-page-bottom {
  border-bottom: solid 1px var(--treatment-record-complaint-per-page-border) !important;
}
/* TODO モーダルのブラックテーマ適用時に以下のスタイルを全て削除する */
.ntss-list {
  background-color: #fafafa;
}
.ntss-list-header-th-sticky {
  background-color: #333333;
  border: solid 1px #cccccc;
  border-top: none;
}
.ntss-list-body-tr {
  border: solid 1px #cccccc;
  color: var(--ntss-base-color);
  background-color:var(--ntss-list-item-background-color);
}
.ntss-list-body-td {
  border: solid 1px #cccccc;
}
.ntss-list-body-tr-black {
  background-color: var(--ntss-base-background-color);
  color: #fafafa;
}
.ntss-input-search :deep(.text-input) {
  background-color: var(--treatment-record-input-background-color);
}
</style>
