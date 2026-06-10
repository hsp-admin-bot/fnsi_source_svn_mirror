<template>
  <v-ons-popover
    v-if="popoverVisible"
    :target="targetPositionElement"
    :visible="popoverVisible"
    :direction="popoverDisplayDirection"
    :class="[fontSizeSet, 'popover-style']"
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
      
      <v-ons-row class="div-style">
        <v-ons-col width="30%">
          <label class="label-style">{{ master.label }}</label>
        </v-ons-col>
        <v-ons-col>
          <v-ons-select
            v-model="selectedUid"
            class="select-content-style select-has-size select-font-inherit"
            size="10"
            @dblclick="saveChanges"
          >
            <option
              v-for="content in popoverFilteredContent"
              :key="content._uid"
              :value="content._uid"
              :class="setListClassOne(content)"
            >
              {{ content.text }}
            </option>
          </v-ons-select>
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
            :disabled="!selectedUid && isSelectionRequired"
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
import { appendUnregisteredOption } from "@/components/common/master-selector/utils/MasterSelectorUtil";
import { EventBus } from "@/eventBus.js";

export default {
  mixins: [PopoverMixin],

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
      default() {
        return this.$parent;
      }
    },
    hasUnregisteredOption: {
      type: Boolean
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
    isSelectionRequired: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      selectedUid: null,
      popoverFilterSelectedItem: {},
      popoverSearchDataset: [],
      inputSearchQuery: this.popoverSearchQuery,
      popoverDirection: "",
      windowHeight: window.innerHeight,
      windowWidth: window.innerWidth,
      isChanged: false ,
      initName: null
    };
  },

  computed: {
    popoverDisplayDirection() {
      if (!this.popoverVisible) return null;
      if (this.bizDirection) {
        this.setPopoverDirection(this.bizDirection);
        return this.bizDirection;
      }
      const elemPosition = this.targetPositionElement.$el
        ? this.targetPositionElement.$el.getBoundingClientRect()
        : this.targetPositionElement.getBoundingClientRect();
      let direction = "right";
      let defaultHeight =  420;
      if(this.masterPhysicalName == "mst_treatment_set" ) {
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

    popoverFilteredContent() {
      const Const_popoverSearchDataset = this.popoverSearchDataset ? this.popoverSearchDataset : [];
      const refArr = this.inputSearchQuery
        ? Const_popoverSearchDataset
        : this.master.options;
       //#10176:ポップアップのフリーワード検索の動作不正 End
      let retArr = [];
      if (this.inputSearchQuery) {
        const q = new RegExp(this.inputSearchQuery, "gi");
        retArr = refArr.filter(item => item.text?.search(q) > -1);
      } else {
        retArr = refArr.filter(item => {
          for (const category of this.categories || []) {
            if (category.options && category.options.length > 0 && category.value) {
              if (category.value !== 0 && category.value !== "all") {
                const itemValue =
                  item[category.key + "Value"] !== undefined && item[category.key + "Value"] !== null
                    ? item[category.key + "Value"]
                    : item[category.key];
                if (category.value != itemValue) return false;
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
        this.popoverBlankLine
      );
      return retArr.map((item, index) => ({
        ...item,
        _uid: `${item.value ?? 'null'}_${item.text ?? ''}_${index}`
      }));
    },
  },

  watch: {
    popoverVisible(visible) {
      if (visible) {
        this.$nextTick(() => {
          this.initializeFilterSelected();
        });
      }
    }
  },

  mounted() {
    EventBus.$on("getInsuranceInfo", data => {
      this.initName = data.editValue
    })
    window.addEventListener("resize",this.resizeEventListener);
  },
  methods: {
    resizeEventListener(){
      this.windowHeight = window.innerHeight;
      this.windowWidth = window.innerWidth;
    },
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    setListClassOne(content) {
      const cdName = content.text;
      const selectedList = this.master.selectedItem ? this.master.selectedItem : [];
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
        return;
      }
      this.$nextTick(() => {
        const matchedItem = this.popoverFilteredContent.find(item =>
          this.isSameMasterItem(item, this.master.selectedItem)
        );
        this.selectedUid = matchedItem ? matchedItem._uid : null;
      });
      this.isChanged = this.isPatInfoFlg ? true : false;
    },
    clearSearch() {
      this.inputSearchQuery = "";
      this.popoverSearchDataset = [];
    },
    saveChanges() {
      let retVal =
        this.popoverFilteredContent.find(
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
      this.clearSearch();
    }
  },
  beforeDestroy() {
    EventBus.$off('getInsuranceInfo');
    window.removeEventListener("resize", this.resizeEventListener);
  }
};
</script>

<style scoped>
.popover-style >>> .popover--top,
.popover-style >>> .popover--right,
.popover-style >>> .popover--left,
.popover-style >>> .popover--bottom {
  width: initial;
}

.popover-style >>> .popover__content {
  width: 500px;
  height: auto;
  padding: 25px;
  border: solid 1px var(--preventive-checked-border-color);
  margin: 3px;
}

.select-filter-style >>> select,
.select-content-style >>> select {
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
  .popover-style >>> .popover__content {
    width: auto;
    padding: 10px;
  }
}

@media screen and (max-height: 420px) {
  .popover-style >>> .popover__content {
    width: 350px;
    padding: 5px;
  }
}

.selected-color {
  background-color: #0076ff !important;
  color: white;
  /*min-width: 100%;*/
  width: max-content;
}

.dis-selected-color:hover {
  background-color: #dddddd;
}

.turn-red {
  color: #FF6666 !important;
}
</style>