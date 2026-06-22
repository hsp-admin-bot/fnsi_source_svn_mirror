<template>
  <div>
    <v-ons-row class="condition-row custom-condition-row">
      <v-ons-col><label style="margin: 0 5px; flex: 0 0 20%;">グループ名</label></v-ons-col>
      <v-ons-col style="flex: 0 0 80%;">
        <v-ons-input
          class="select-item input-required"
          @change="limitNameLength($event)"
          :value="editRecord.groupName"
          @input="setCss($event.target.value)"
          @blur="setLayoutGroupName($event.target.value)"
          style="width: 20%"
        />
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="condition-row frame">
      <v-ons-col class="item-title" style="flex: 0 0 20%;">
        グループ情報
        <v-ons-button class="item-button btn3-normal" @click="addRecordLayout($event)" style="width: 60px">追加</v-ons-button>
      </v-ons-col>
      <v-ons-col class="item-title" style="flex: 0 0 80%;">
        <div class="disp-item-content-area print-height-auto" style="overflow: auto" :style="heightStyles">
          <table class="ntss-list sticky_table" style="position: relative;table-layout: fixed;">
            <thead display="block">
            <tr>
              <th class="ntss-list-header-th-sticky">レイアウト名</th>
              <th class="ntss-list-header-th-sticky">装置型式</th>
            </tr>
            </thead>
            <tr v-for="(item, idx) in listLayoutGroupDisplay" :key="`${item.menteLayoutCd}-${idx}`">
              <td class="ntss-list-body-td ntss-list-body-td-background">{{ item.layoutName }}</td>
              <td class="ntss-list-body-td ntss-list-body-td-background">{{ item.machineNameString }}</td>
            </tr>
          </table>
        </div>
      </v-ons-col>
    </v-ons-row>
    <v-ons-popover
      cancelable
      v-model:visible="popoverInfo.popoverVisible"
      :target="popoverInfo.popoverTarget"
      :direction="popoverInfo.popoverDirection"
      :class="[fontSizeSet, 'popover-style']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <h2 class="selector-title">{{ popoverInfo.titleLabel }}</h2>
      <div class="mult-selector">
        <div
          v-for="(selectedInfo, index) in listLayoutGroup"
          :key="index"
          @click="selectMachineInfo(selectedInfo)"
          :class="setListClass(selectedInfo)"
          class="select-label-style"
          :id="selectedInfo.menteLayoutCd"
        >
          {{ selectedInfo.layoutName }} / {{ selectedInfo.machineNameString }}
        </div>
      </div>
      <div class='condition-row' style="height:30px;margin-bottom:5px;">
        <div style="float:left;">
          <v-ons-button  @click="clear" class='btn2-cancel clear' >クリア</v-ons-button>
        </div>
        <div style="float:right;">
          <v-ons-button  @click="savePopover" class='btn1-execute ok' >OK</v-ons-button>
        </div>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import PopoverMixin from "@/components/PopoverMixin";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import {EventBus} from "@/compat/vue/event-bus.js";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start

import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { getModalBodyElement, queryScopedSelector, queryScopedSelectorAll } from '@/functions/common/LayoutMeasureHelper';
import { messageFormat } from "@/functions/common/MessageFormat";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  mixins: [PopoverMixin],
  name: "MstInspectionLayoutGroupComponent",
  data() {
    return {
      listLayoutGroup: [],
      popoverInfo: {
        popoverVisible: false,
        popoverTarget: null,
        popoverDirection: null,
        titleLabel: null,
        selectedList: []
      },
      listLayoutGroupDisplay: [],
      listLayoutGroupTmp: [],
      listHeight: 710,
      listGroupName:"",
      listItemDefaultSelected:""
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      editRecord: "getEditRecord",
      getFacilitySwitch: "getFacilitySwitch"
    }),
    ...mapGetters("mst-layout", ["getLayoutGroupList"]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
    }),
    listItemSelected() {
      const selectedList = this.listLayoutGroup.filter(x => x.selected == true).map(x => {
        return x.menteLayoutCd;
      });
      return selectedList;
    },
    heightStyles() {
      // リストの高さをCSS変数を利用して書き換え
      return { "height": `${this.listHeight}px` };
    },
  },
  watch: {
    listLayoutGroupDisplay: {
      handler(newValue) {
        // レイアウトリストが変更され場合は確定ボタンを活性化する
        if (JSON.stringify(this.listItemDefaultSelected) !== JSON.stringify(newValue)) {
          EventBus.$emit("mstHolidayRegistered", false);
        }else{
          EventBus.$emit("mstHolidayRegistered", true);
        }
      }
    },
    /**
     * ウィンドウの高さが変更された時
     */
    windowHeight() {
      this.calculateListHeight();
    },
    getFontSize() {
      this.calculateListHeight();
    },
  },
  async mounted() {
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 500);
    this.listGroupName=this.editRecord.groupName;
  },
  methods: {
    getCurrentModalBody() {
      return getModalBodyElement(this.$el) || null;
    },
    getInspectionLayoutElement(selector) {
      return this.getCurrentModalBody()?.querySelector?.(selector) || this.$el?.querySelector?.(selector) || queryScopedSelector(selector, this.$el);
    },
    ...mapActions("mst-layout", ["senRequestGetListLayoutByLayoutClassAndFacilityCd"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    isDisableCheckbox(item) {
      let result = false;
      let existType = [];
      this.listLayoutGroup.filter(rec => {
        return rec.selected === true;
      }).forEach(it => {
        const machineType = it.typeInfo && JSON.parse(it.typeInfo);
        const typeCds = machineType.map(i => {
          return i.machineTypeCd;
        })
        existType = existType.concat(typeCds);
      })
      const currentMachine = item.typeInfo && JSON.parse(item.typeInfo);
      if (!currentMachine) return result;
      currentMachine.forEach(m => {
        if (!item.selected && existType.indexOf(m.machineTypeCd) > -1) {
          result = true;
        }
      })
      return result;
    },
    async initData() {
      await this.senRequestGetListLayoutByLayoutClassAndFacilityCd(this.getFacilitySwitch);
      const selectedList = this.editRecord.layoutList ? JSON.parse(this.editRecord.layoutList) : "";
      Array.from(this.getLayoutGroupList).forEach(item => {
        let selected = false;
        let listMachine = [];
        let machineArr = [];
        if (item.typeInfo) {
          listMachine = JSON.parse(item.typeInfo);
          machineArr = listMachine.map(machine => {
            return machine.machineType;
          });
        }
        if (selectedList.indexOf(item.menteLayoutCd) > -1) {
          selected = true;
        }
        this.listLayoutGroup.push({
          ...item,
          nachinList: listMachine,
          selected: selected,
          machineNameString: machineArr.join()
        });
      });
      this.listLayoutGroupDisplay = [...this.listLayoutGroup].filter(item => {
        return item.selected === true;
      })
     this.listItemDefaultSelected = JSON.parse(JSON.stringify(this.listLayoutGroupDisplay));
    },
    addRecordLayout(event) {
      this.listLayoutGroupTmp = JSON.parse(JSON.stringify(this.listLayoutGroup));
      this.popoverInfo.popoverTarget = event;
      this.popoverInfo.popoverDirection = "right";
      this.popoverInfo.titleLabel = "レイアウト選択";
      this.popoverInfo.popoverVisible = true;
    },
    selectMachineInfo(selectedInfo) {
      const selected = selectedInfo.selected;
      selectedInfo.selected = !selected;
    },
    setListClass(selectedInfo) {
      const obj = {
        "selected-color": false,
        "dis-selected-color": false
      };
      let isSelected = false;
      isSelected = this.listItemSelected.indexOf(selectedInfo.menteLayoutCd) > -1 ? true:false;
      obj["selected-color"] = isSelected;
      obj["dis-selected-color"] = !isSelected;
      obj["disabled"] = this.isDisableCheckbox(selectedInfo);
      return obj;
    },
    setLayoutGroupName(value) {
      this.editRecord.groupName = value;
    },
    setCss(value) {
      const invalidInput = this.getInspectionLayoutElement('.input-invalid');
      if (value && invalidInput) {
        invalidInput.classList.remove('input-invalid');
      }
    },
    validateData() {
      this.editRecord.layoutList = JSON.stringify(this.listItemSelected);
      const groupName = this.editRecord.groupName;
      let layoutList = false;
      if (this.listItemSelected.length > 0) {
        layoutList = true;
      }
      return {
        nameValid: groupName !== null && groupName !== "",
        layoutListValid: layoutList,
      };
    },
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      if (!validationResult.nameValid) {
        this.getInspectionLayoutElement('.input-required')?.classList?.add('input-invalid');
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES['00200064'].title;
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
        !validationResult.nameValid
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // ? "グループ名を入力する必要があります。<br>"
          ? messageFormat(DIALOG_MESSAGES['00200064'].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          : ""
      }
          ${
        !validationResult.layoutListValid
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // ? "レイアウトを選択する必要があります。<br>"
          ? messageFormat(DIALOG_MESSAGES['00200065'].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          : ""
      }
        `;

      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    },
    savePopover() {
      this.popoverInfo.popoverVisible = false;
      this.listLayoutGroupDisplay = [...this.listLayoutGroup].filter(item => {
        return item.selected === true;
      })
    },
    clear() {
      this.listLayoutGroup = JSON.parse(JSON.stringify(this.listLayoutGroupTmp));
      this.popoverInfo.popoverVisible = false;
    },
    limitNameLength(event) {
      event.target.value = String(event.target.value)
      event.target.value = event.target.value.length > 265? event.target.value.substr(0,265): event.target.value;
      if (event.target.value!==this.listGroupName) {
        EventBus.$emit("mstHolidayRegistered", false);
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }

    },
    calculateListHeight() {
      // 画面の高さ
      const bodyHeight = this.getCurrentModalBody()?.clientHeight || 0;

      // ヘッダーの高さ
      const itemHeads = queryScopedSelectorAll('.item-head', this.getCurrentModalBody() || this.$el);
      const headHeight = (itemHeads[0]?.clientHeight || 0) + (itemHeads[1]?.clientHeight || 0)
      // リストの高さを設定
      this.listHeight = bodyHeight - headHeight;
    },
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.initData();
  }
};
</script>

<style scoped>
@media print {
  .print-height-auto{
    height: auto !important;
  }
}
.list-header-th-center {
  text-align: center;
  background-color: rgb(175, 173, 173);
  height: 20px;
  color: black;
  border: solid 1px var(--ntss-list-border-color);
}
#popover {
  margin: 5px 10px 5px 10px;
  position: relative;
  height: 250px;
}
.table {
  height: 200px;
  text-align: center;
}
.confirm {
  margin-top: 15px;
  width: 100%;
  height: 40px;
}
.ntss-list {
  position: unset;
}
.input-required :deep(input) {
  color: black;
  background-color: #ffff99;
}
.input-invalid :deep(input) {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}

.popover-style :deep(.popover__content) {
  width: fit-content;
  height: 100%;
  padding: 25px;
}

.selector-title {
  margin: 0;
}

.mult-selector {
  overflow-y: auto;
  max-height: 300px;
  min-height: 300px;
  border: solid 1px #bbbbbb;
}

.dis-selected-color{
  white-space: nowrap;
}

.selected-color {
  background-color: #0076ff !important;
  color: white;
  width: max-content;
  min-width: 100%;
}

.dis-selected-color:hover {
  background-color: #dddddd;
}
.disabled {
  opacity: 0.5;
  pointer-events: none;
}

.custom-condition-row .select-item {
  font-size: unset;
}

.frame{
  border-top: 1px solid black;
  border-right: 1px solid black;
  border-left: 1px solid black;
}
</style>
