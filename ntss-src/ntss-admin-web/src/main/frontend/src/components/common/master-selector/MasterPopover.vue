<template>
  <v-ons-popover
    v-if="popoverVisible"
    :target="resolvedTargetPositionElement"
    :visible="popoverVisible"
    :direction="popoverDisplayDirection"
    :class="[fontSizeSet, 'popover-style', popoverExtraClass]"
    cancelable
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="closePopover(); popoverPosthide()"
  >
    <div>
      <v-ons-row>
        <h2 class="popover-header-style">{{ headerTitle }}</h2>
      </v-ons-row>
      <hr />
      
      <v-ons-row 
        v-for="category in categories" 
        :key="category.key"
        v-show="category.options && category.options.length > 0"
        class="div-style"
      >
        <v-ons-col width="30%">
          <label class="label-style">{{ category.label }}</label>
        </v-ons-col>
        <v-ons-col>
          <v-ons-select
            v-model="category.value"
            :disabled="category.disabled"
            class="select-filter-style"
            @change="filterChange"
          >
            <option
              v-for="option in category.options"
              :key="option.id || option.value"
              :value="option.value"
            >
              {{ option.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      
      <v-ons-row class="div-style">
        <v-ons-col width="30%">
          <label class="label-style">フリーワード</label>
        </v-ons-col>
        <v-ons-col>
          <input
            v-model="inputSearchQuery"
            class="search-style"
            type="search"
            placeholder="検索"
          />
        </v-ons-col>
      </v-ons-row>
      
      <v-ons-row class="div-style master-list-row">
        <v-ons-col width="30%" class="master-list-label-col">
          <label class="label-style">{{ master.label }}</label>
        </v-ons-col>
        <v-ons-col width="70%" class="master-list-col">
          <div
            ref="masterList"
            class="master-list-scroll select-content-style select-has-size select-font-inherit"
            tabindex="0"
            role="listbox"
            @dblclick="saveChanges"
          >
            <table class="master-list-table">
              <tbody>
                <tr
                  v-for="content in popoverFilteredContent"
                  :key="content._uid"
                  role="option"
                  :aria-selected="content._uid === selectedUid"
                  :class="setListClassOne(content)"
                  @click="selectMasterRow(content)"
                  @dblclick.stop="saveChanges"
                >
                  <td class="master-list-cell">{{ content.text }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </v-ons-col>
      </v-ons-row>
      
      <v-ons-row>
        <v-ons-col>
          <v-ons-button
            class="btn2-cancel common-style-cancel-button button-cancel btn2-cancel"
            @click="closePopover"
          >
            キャンセル
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <v-ons-button
            class="btn1-execute common-style-ok-button button-confirm btn3-normal"
            @click="saveChanges"
            :disabled="popoverOkDisabled"
          >
            {{ exeLableName }}
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </v-ons-popover>
</template>

<script>
import PopoverMixin from "@/components/PopoverMixin";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import {
  appendUnregisteredOption,
  isUnregisteredMasterItem,
} from "@/components/common/master-selector/utils/MasterSelectorUtil";
import { EventBus } from "@/compat/vue/event-bus.js";
import { mapGetters } from "vuex";
import { getViewportHeight, getViewportWidth } from "@/functions/common/LayoutMeasureHelper";
import { resolveOnsPopoverTargetElement } from "@/functions/common/OnsenFunctions";
import { FACILITY_PAT_INFO_FAVORITE_PREF_CD } from "@/components/common/master-selector/builder/masterPaginationRegistry";

export default {
  mixins: [PopoverMixin],
  emits: [
    "popover-close",
    "popover-return",
    "master-load-more",
    "master-reset-request",
  ],

  props: {
    fromSendConditionFlg: {
      type: Boolean,
      default: false
    },
    popoverBlankLine: {
      type: Boolean,
      default: false
    },
    popoverVisible: {
      type: Boolean,
      default: false
    },
    popoverSearchQuery: {
      type: String,
      default: ""
    },
    targetPositionElement: {
      type: [Object, HTMLElement],
      default: null
    },
    hasUnregisteredOption: {
      type: Boolean,
      default: true
    },
    exeLableName: {
      type: String,
      default: "OK"
    },
    bizDirection: {
      type: String,
      default: null
    },
    headerTitle: {
      type: String,
      default: ""
    },
    categories: {
      type: Array
    },
    master: {
      type: Object
    },
    favoriteFacilityMedicalInstitutionCds: {
      type: Array,
      default: null
    },
    isSelectionRequired: {
      type: Boolean,
      default: false
    },
    popoverExtraClass: {
      type: String,
      default: "",
    }
  },

  data() {
    return {
      selectedUid: null,
      popoverFilterSelectedItem: {},
      popoverSearchDataset: [],
      inputSearchQuery: this.popoverSearchQuery,
      renderLimit: 2000,
      renderStep: 2000,
      masterScrollEl: null,
      masterScrollHandler: null,
      popoverDirection: "",
      windowHeight: getViewportHeight(),
      windowWidth: getViewportWidth(),
      isChanged: false ,
      initName: null,
      _suppressKeywordWatch: false,
      _keywordRefetchTimer: null,
    };
  },

  computed: {
    ...mapGetters("master-maintenance", {
      masterPhysicalName: "getMasterName"
    }),
    resolvedTargetPositionElement() {
      return resolveOnsPopoverTargetElement(this.targetPositionElement, this);
    },
    resolvedTargetRectElement() {
      return this.resolvedTargetPositionElement;
    },
    popoverDisplayDirection() {
      if (!this.popoverVisible) return null;
      if (this.bizDirection) {
        this.setPopoverDirection(this.bizDirection);
        return this.bizDirection;
      }
      const targetElement = this.resolvedTargetRectElement;
      if (!targetElement?.getBoundingClientRect) return null;
      const elemPosition = targetElement.getBoundingClientRect();
      let direction = "right";
      let defaultHeight =  420;
      if(this.masterPhysicalName == "mst_treatment_set") {
        defaultHeight = 700;
      }
      if (this.windowHeight <= defaultHeight) {
        if (elemPosition.right < this.windowWidth / 2) {
          direction = "right";
        } else {
          direction = "left";
        }
      } else if (this.windowWidth - elemPosition.right < 500) {
        if (elemPosition.top < this.windowHeight / 2) {
          direction = "down";
        } else {
          direction = "up";
        }
      }
      this.setPopoverDirection(direction);
      return direction;
    },

    popoverFilteredContentAll() {
      const Const_popoverSearchDataset = this.popoverSearchDataset ? this.popoverSearchDataset : [];
      const isComposePaged = this.master?.pagination?.mode === "paged";
      const refArr =
        !isComposePaged && this.inputSearchQuery
          ? Const_popoverSearchDataset
          : (this.master && this.master.options) ? this.master.options : [];
       //#10176:ポップアップのフリーワード検索の動作不正 End
      let retArr = [];
      if (!isComposePaged && this.inputSearchQuery) {
        const q = new RegExp(this.inputSearchQuery, "gi");
        retArr = refArr.filter(item => item.text?.search(q) > -1);
      } else {
        retArr = refArr.filter(item => {
          for (const category of this.categories || []) {
            if (category.options && category.options.length > 0) {
              const categoryValue = category.value;
              if (
                categoryValue !== 0 &&
                categoryValue !== "all" &&
                String(categoryValue) !== "0"
              ) {
                if (
                  category.key === "prefecturesCd" &&
                  String(categoryValue) === FACILITY_PAT_INFO_FAVORITE_PREF_CD
                ) {
                  const favoriteCds = this.favoriteFacilityMedicalInstitutionCds;
                  if (favoriteCds && favoriteCds.length > 0) {
                    const itemValue = item.value != null ? String(item.value) : "";
                    if (!favoriteCds.includes(itemValue)) return false;
                  } else {
                    return false;
                  }
                } else {
                  const itemValue =
                    item[category.key + "Value"] !== undefined && item[category.key + "Value"] !== null
                      ? item[category.key + "Value"]
                      : item[category.key];
                  if (category.value != itemValue) return false;
                }
              }
            }
          }
          return true;
        });
        this.setPopoverSearchDataset(retArr);
      }
      retArr = appendUnregisteredOption(
        retArr,
        this.hasUnregisteredOption,
        this.popoverBlankLine);
      return retArr.map((item, index) => ({
        ...item,
        _uid: `${item.value ?? 'null'}_${item.text ?? ''}_${index}`
      }));
    },

    popoverFilteredContent() {
      const all = this.popoverFilteredContentAll || [];
      const limit = Number(this.renderLimit) > 0 ? Number(this.renderLimit) : 0;
      let sliced = all.slice(0, limit);

      const selUid = this.selectedUid;
      if (selUid != null && selUid !== "" && !sliced.some(r => r._uid === selUid)) {
        const hit = all.find(r => r._uid === selUid);
        if (hit) sliced = [hit, ...sliced];
      }

      return sliced;
    },

    isPopoverListRowSelected() {
      return this.selectedUid != null && this.selectedUid !== "";
    },

    popoverOkDisabled() {
      return !this.isPopoverListRowSelected && this.isSelectionRequired;
    },
  },

  watch: {
    popoverVisible(visible) {
      if (visible) {
        this.renderLimit = 2000;
        this.$nextTick(() => {
          this.initializeFilterSelected();
          this.attachMasterScrollListener();
        });
      } else {
        this.detachMasterScrollListener();
      }
    },
    inputSearchQuery(value) {
      this.renderLimit = 2000;
      if (this._suppressKeywordWatch) return;
      if (!this.master?.pagination?.enabled || this.master.pagination.mode !== "paged") {
        return;
      }
      if (this._keywordRefetchTimer != null) {
        clearTimeout(this._keywordRefetchTimer);
      }
      this._keywordRefetchTimer = setTimeout(() => {
        this._keywordRefetchTimer = null;
        this.$emit("master-reset-request", {
          prefecturesCd: this.getPrefectureFilterValue(),
          keyword: value != null ? String(value) : "",
        });
      }, 400);
    },
    inputSearchQuery() {
      this.renderLimit = 2000;
    }
  },

  mounted() {
    EventBus.$off("getInsuranceInfo", this.onGetInsuranceInfo);
    EventBus.$on("getInsuranceInfo", this.onGetInsuranceInfo);
    (this.$el?.ownerDocument?.defaultView || window).addEventListener("resize",this.resizeEventListener);
  },
  methods: {
    resizeEventListener(){
      this.windowHeight = getViewportHeight();
      this.windowWidth = getViewportWidth();
    },
    onGetInsuranceInfo(data) {
      this.initName = data.editValue;
    },
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    selectMasterRow(content) {
      this.selectedUid = content._uid;
    },
    scrollSelectedRowIntoView() {
      this.$nextTick(() => {
        const list = this.$refs.masterList;
        if (!list || typeof list.querySelector !== "function") return;
        const selected = list.querySelector("tr.selected-color");
        if (selected && typeof selected.scrollIntoView === "function") {
          selected.scrollIntoView({ block: "nearest" });
        }
      });
    },
    setListClassOne(content) {
      const cdName = content.text;
      const selectedItem = this.master && this.master.selectedItem;
      const selectedList = Array.isArray(selectedItem)
        ? selectedItem
        : selectedItem
          ? [selectedItem]
          : [];
      const obj = {
        "selected-color": false,
        "dis-selected-color": false,
        "turn-red": false,
      };
      let isSelected = false;
      isSelected = content._uid === this.selectedUid;
      if (selectedList.length === 0) {
        isSelected = this.initName === cdName ? true : isSelected;
      }
      obj["selected-color"] = isSelected;
      obj["dis-selected-color"] = !isSelected;

      if (this.fromSendConditionFlg && content.calibrationCheck != undefined) {
        obj["turn-red"] = !content.calibrationCheck;
      }
      return obj;
    },
    closePopover() {
      this.$emit("popover-close", false);
      this.popoverDirection = "";
      this.detachMasterScrollListener();
    },

    isSameMasterItem(a, b) {
      if (!a || !b) return false;
      if (a.value != b.value) return false;
      if (a.text && b.text) {
        return a.text === b.text;
      }
      return true;
    },
    initializeFilterSelected() {
      if (!(this.master && this.master.selectedItem)) {
        this.selectedUid = null;
        this.isChanged = this.isPatInfoFlg ? true : false;
        return;
      }
      this.selectedUid = null;
      this.$nextTick(() => {
        let matchedItem = this.popoverFilteredContentAll.find(item =>
          this.isSameMasterItem(item, this.master.selectedItem)
        );
        if (!matchedItem && isUnregisteredMasterItem(this.master.selectedItem)) {
          matchedItem = this.popoverFilteredContentAll.find(item =>
            isUnregisteredMasterItem(item)
          );
        }
        this.selectedUid = matchedItem ? matchedItem._uid : null;
        this.scrollSelectedRowIntoView();
      });
      this.isChanged = this.isPatInfoFlg ? true : false;
    },
    clearSearch() {
      this.inputSearchQuery = "";
      this.popoverSearchDataset = [];
    },
    saveChanges() {
      let retVal =
        this.popoverFilteredContentAll.find(
          item => item._uid === this.selectedUid) ?? { text: "", value: null };

      this.master.selectedItem = retVal || null
      this.$emit("popover-return", retVal);
      this.closePopover();
    },
    setPopoverDirection(direction) {
      this.popoverDirection = direction;
    },
    setPopoverSearchDataset(dataset) {
      this.popoverSearchDataset = dataset;
    },
    filterChange() {
      if (this.master?.pagination?.enabled) {
        this._suppressKeywordWatch = true;
        this.clearSearch();
        this.$nextTick(() => {
          this._suppressKeywordWatch = false;
        });
        this.$emit("master-reset-request", {
          prefecturesCd: this.getPrefectureFilterValue(),
          keyword: "",
        });
      } else {
        this.clearSearch();
      }
      this.renderLimit = 2500;
    },

    getPrefectureFilterValue() {
      const category = (this.categories || []).find(item => item.key === "prefecturesCd");
      return category ? category.value : null;
    },

    attachMasterScrollListener() {
      if (this.masterScrollEl && this.masterScrollHandler) return;
      const el = this.$refs.masterList;
      if (!el || typeof el.addEventListener !== "function") return;

      this.masterScrollHandler = () => {
        const nearBottom =
          Math.abs(el.scrollHeight - el.scrollTop - el.clientHeight) < 4;
        if (!nearBottom) return;
        const pagination = this.master?.pagination;
        if (
          pagination &&
          pagination.enabled &&
          pagination.mode === "paged" &&
          pagination.hasMore &&
          !pagination.loading
        ) {
          this.$emit("master-load-more");
          return;
        }
        const allLen = (this.popoverFilteredContentAll || []).length;
        if (this.renderLimit >= allLen) return;
        this.renderLimit = Math.min(this.renderLimit + this.renderStep, allLen);
      };

      el.addEventListener("scroll", this.masterScrollHandler);
      this.masterScrollEl = el;
    },

    detachMasterScrollListener() {
      if (!this.masterScrollEl || !this.masterScrollHandler) return;
      try {
        this.masterScrollEl.removeEventListener("scroll", this.masterScrollHandler);
      } finally {
        this.masterScrollEl = null;
        this.masterScrollHandler = null;
      }
    }
  },
  beforeUnmount() {
    EventBus.$off("getInsuranceInfo", this.onGetInsuranceInfo);
    clearTimeout(this._keywordRefetchTimer);
    (this.$el?.ownerDocument?.defaultView || window).removeEventListener("resize", this.resizeEventListener);
    this.detachMasterScrollListener();
  }
};
</script>

<style scoped>
.popover-style :deep(.popover--top),
.popover-style :deep(.popover--right),
.popover-style :deep(.popover--left),
.popover-style :deep(.popover--bottom) {
  width: initial;
}

.popover-style :deep(.popover__content) {
  width: 500px;
  height: auto;
  padding: 25px;
  border: solid 1px var(--preventive-checked-border-color);
  margin: 3px;
}

.select-filter-style :deep(select),
.select-content-style :deep(select) {
  width: 100%;
  font-size: inherit;
  font-family: inherit;
}

.popover-header-style {
  margin: 0px;
}

.select-filter-style,
.search-style {
  width: 100%;
}

.select-content-style {
  width: 100%;
  height: 100%;
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}

.master-list-row {
  flex-wrap: nowrap !important;
  align-items: flex-start;
}

.master-list-label-col {
  flex: 0 0 30%;
  max-width: 30%;
}

.master-list-col {
  flex: 1 1 0;
  min-width: 0;
  max-width: 70%;
}

.master-list-scroll {
  width: 100%;
  max-width: 100%;
  min-width: 0;
  min-height: 13.5em;
  height: 13.5em;
  max-height: 13.5em;
  overflow: auto;
  border: unset;
  border-width: 2px;
  border-style: inset;
  border-image-repeat: stretch;
  border-color: unset;
  border-radius: 5px;
  box-sizing: border-box;
  outline: none;
}

.master-list-table {
  width: max-content;
  min-width: 100%;
  border-collapse: collapse;
  border-spacing: 0;
}

.master-list-cell {
  padding: 1px 4px;
  white-space: nowrap;
  font: inherit;
  color: inherit;
  vertical-align: middle;
}

.button-cancel {
  float: left;
}

.button-confirm {
  float: right;
}

.popover-footer-style {
  margin-top: 15px;
}

.needle-hidden {
  visibility: hidden;
  height: 0px;
}

.select-has-size {
  font-size: 13.3333px;
}

@media screen and (max-width: 420px) {
  .popover-style :deep(.popover__content) {
    width: auto;
    padding: 10px;
  }
}

@media screen and (max-height: 420px) {
  .popover-style :deep(.popover__content) {
    width: 350px;
    padding: 5px;
  }
}

.master-list-table tr.selected-color .master-list-cell {
  background-color: #0076ff !important;
  color: white !important;
}

.master-list-table tr.dis-selected-color:hover .master-list-cell {
  background-color: #dddddd;
}

.master-list-table tr.turn-red .master-list-cell {
  color: #ff6666 !important;
}

.master-list-table tr.selected-color.turn-red .master-list-cell {
  color: white !important;
}
</style>
