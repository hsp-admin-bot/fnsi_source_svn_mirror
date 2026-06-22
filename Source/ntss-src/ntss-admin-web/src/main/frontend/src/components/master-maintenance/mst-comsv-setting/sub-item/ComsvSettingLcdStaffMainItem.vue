<template>
  <div id="comsv-staff-modal-content">
    <!-- 行追加のボタン -->
    <div class="header-btn-area right">
      <v-ons-button
        modifier="outline"
        class="btn3-normal toolbar-btn"
        style="float: left;"
        ref="btnSelectMstadd"
        @click="addRow()"
      >追加</v-ons-button>
    </div>
    <!-- ダミー -->
    <!-- mod スタッフ追加の複数追加と空欄追加 楊 start -->
    <!-- <div id="dummy-wrapper"></div> -->
    <!-- mod スタッフ追加の複数追加と空欄追加 楊 end -->
    <!-- 一覧 -->
    <div id="staff-list-wrapper" style="height: calc(100% - 2.7em);">
      <table>
        <thead>
          <tr>
            <th align="center" class="th-font-weight" style="width: 4em;">削除</th>
            <th class="th-font-weight" style="padding-left:10px; width: 2em;"></th>
            <th class="th-font-weight" style="padding-left:10px; width: 2em;">No</th>
            <th class="th-font-weight" style="padding-left:10px; width: 4em;">選択</th>
            <th class="th-font-weight" style="padding-left:10px;">スタッフ名</th>
          </tr>
        </thead>
      </table>
      <draggable
        :key="draggableKey"
        v-model="localDataSource"
        animation="250"
        handle=".drag-handle"
        :forceFallback="true"
        @change="sortStaffList"
      >
        <div v-for="(item, index) in localDataSource" :index="index" :key="getStaffRowKey(item, index)">
          <div class="drag-item">
            <div align="center" class="drag-item-button-area">
              <ons-toolbar-button class="close-btn manual-close-btn" @click="deleteRow(item)"><ons-icon icon="fa-times"></ons-icon></ons-toolbar-button>
            </div>
            <div align="center" class="drag-handle">
              <ons-toolbar-button>
                <ons-icon icon="fa-sort"></ons-icon>
              </ons-toolbar-button>
            </div>
            <div class="no-width"><label>{{ item.no }}</label></div>
            <div align="center" class="drag-item-button-area">
              <v-ons-button
                class="btn3-normal select-button"
                :ref="'btnSelectMst' + index"
                @click="selectStaff(index);"
              >選択</v-ons-button>
            </div>
            <div class="drag-item-label">
              {{ item.name }}
            </div>
          </div>
        </div>
      </draggable>
      <pop-over
        v-bind="popoverData"
        :target-position-element="popoverTargetElement"
        @popover-close="closePopover"
        @popover-return="returnPopover"
      />
      <!-- add スタッフ追加の複数追加と空欄追加 楊 start -->
      <pop-over-multiple
        v-bind="popoverDataList"
        :target-position-element="popoverTargetElement"
        @popover-close="closePopover"
        @popover-return="returnPopoverList"
      />
      <!-- add スタッフ追加の複数追加と空欄追加 楊 end -->
    </div>
  </div>
</template>

<script>
import { VueDraggable } from "@/compat/drag/VueDraggable";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { createPopoverData } from "@/functions/PopoverFunctions";
import {EventBus} from "@/compat/vue/event-bus.js";
import MasterSelectorMultiple from "@/components/common/master-selector/MasterSelectorMultiple";
import { deepCopy } from "@/functions/common/CommonFunctions";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
export default {
  name: "comsvSettingLcdStaffList",
  mixins: [MasterMaintenanceMixin],
  components: {
    "draggable": VueDraggable,
    "pop-over": MasterSelector,
    /* add スタッフ追加の複数追加と空欄追加 楊 start */
    "pop-over-multiple": MasterSelectorMultiple
    /* add スタッフ追加の複数追加と空欄追加 楊 end */
  },
  data() {
    return {
      lcdStaffList: [],
      localDataSource: [],
      inputModel: {
        comsvCd: "",
        facilityCd: "",
        deviceEdgeNo: "",
        lcdStaffList: ""
      },
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      kendoGridToolbarHeight: 500,
      /* add スタッフ追加の複数追加と空欄追加 楊 start */
      popoverDataList: {},
      /* add スタッフ追加の複数追加と空欄追加 楊 end */
      popoverData: {
        popoverVisible: false,
        popoverDisplayDirection: "left",
        popoverTitleHeader: "",
        popoverFilterLabel: "",
        popoverFilterDataset: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected:{},
        /* add スタッフ追加の複数追加と空欄追加 楊 start */
        popoverBlankLine : true
        /* add スタッフ追加の複数追加と空欄追加 楊 end */
      },
      dispPatName: null,
      mstPersonalUser: [],
      selectedIndex: null,
      // 非表示タブ内で Sortable 初期化されると D&D が効かないため、表示時に再生成する
      draggableKey: 0
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("mst-com-sv-setting", {
      getSelectFacility: "getSelectFacility"
    }),
    ...mapGetters("user-selector-popover", ["mstJob"]),
    // マスタ選択ポップオーバーの表示位置とする対象コンポーネント
    popoverTargetElement() {
      // 初期表示時は未選択なのでnull
      if (this.selectedIndex === null) {
        return null;
      } else if (this.selectedIndex === "add") {
        return this.$refs[`btnSelectMst${this.selectedIndex}`];
      } else {
        return this.$refs[`btnSelectMst${this.selectedIndex}`][0];
      }
    },
    conditions() {
      let ord_schedule = null;
      return {
        ord_schedule,
        facilityCdList: [this.getSelectFacility]
      };
    }
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("user-selector-popover", ["getMst"]),

    getValueByField(field) {
      return this.editRecord[field];
    },

    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },

    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },

    getStaffRowKey(item, index) {
      return `staff-${index}-${item.user_id ?? ""}-${item.no ?? ""}`;
    },

    /**
     * スタッフタブ表示時・一覧読込後に Sortable を再生成する（親の clickStaffTab からも呼ばれる）
     */
    updateWidget() {
      this.$nextTick(() => {
        this.draggableKey += 1;
      });
    },

    selectStaff(index) {
      // 選択ボタンを押した位置を保持
      this.selectedIndex = index;
      // ポップオーバーを表示
      /* mod スタッフ追加の複数追加と空欄追加 楊 start */
      this.showWheelChairPopover(false);
      /* mod スタッフ追加の複数追加と空欄追加 楊 end */
    },
    // 選択ポップアップ
    showWheelChairPopover(isMultiple) {
       this.popoverData = createPopoverData(
        "スタッフ選択",
        null,
        null,
        "スタッフ",
        this.mstPersonalUser,
        "userId",
        "userLastName",
        // 絞り込みデータ
        "jobCd",
        // 名前表示用
        "userFirstName"
      );
      // ポップオーバのフィルタデータを取りまとめる
      const all = { text: "すべて", value: 0 };
      const filterArr = [
        all,
        ...this.mstJob.map(item => ({
          text: item.jobName,
          value: String(item.jobCd)
        }))
      ];

      // ドロップダウン選択肢設定
      this.popoverData.popoverFilter = [
        {
          popoverFilterLabel: "職種",
          popoverFilterDataset: filterArr
        }
      ];
      // ドロップダウン選択肢に紐づけるvalueを設定
      this.popoverData.popoverContentDataset.forEach(
        item => {
          item.fnValue = { 職種: item.fnValue }
        }
      );
      if (this.localDataSource.length > 0) {
        if (this.selectedIndex !== "add") {
          this.popoverData.popoverContentSelected.value = this.localDataSource[this.selectedIndex].user_id;
          if (this.popoverData.popoverContentSelected.value === '') {
            this.popoverData.popoverContentSelected.value = null;
          }
        } else {
          this.popoverData.popoverContentSelected.value = null;
        }
      }
      /* mod スタッフ追加の複数追加と空欄追加 楊 start */
      this.popoverData.popoverBlankLine = true;
      if(isMultiple){
        this.popoverDataList = deepCopy(this.popoverData);
        this.popoverDataList.popoverVisible = true;
      }else{
        this.popoverData.popoverVisible = true;
      }
      /* mod スタッフ追加の複数追加と空欄追加 楊 end */
    },
    closePopover() {
      this.popoverData.popoverVisible = false;
      this.popoverDataList.popoverVisible = false;
    },
    returnPopover(selectData) {
      if (this.selectedIndex === "add") {
        const length = this.localDataSource.length;
        let maxIndex = length === 0 ? 0 : +this.localDataSource[length - 1].no;
        // カレントデータに追加
        this.localDataSource.push({
          no: maxIndex + 1,
          user_id: selectData.value || "",
          /* mod スタッフ追加の複数追加と空欄追加 楊 start */
          // name: selectData.text || "未設定"
             name: selectData.text || ""
          /* mod スタッフ追加の複数追加と空欄追加 楊 end */
        });
      } else {
        this.localDataSource[this.selectedIndex].user_id =
          selectData.value || "";
        this.localDataSource[this.selectedIndex].name =
          /* mod スタッフ追加の複数追加と空欄追加 楊 start */
          // selectData.text || "未設定";
          selectData.text || "";
          /* mod スタッフ追加の複数追加と空欄追加 楊 end */
      }
      const regStaffList = this.localDataSource.map((dat, idx) => ({
        no: idx + 1,
        user_id: dat.user_id
      }));
      let jsonData = "";
      jsonData = {
        staff_list: regStaffList
      };
      // 追加した行を表示するよう、再下部までスクロールする
      this.$nextTick(() => {
        const scrollArea = getScopedElementById("staff-list-wrapper", this.$el || this);
        if (scrollArea) {
          scrollArea.scrollTop = scrollArea.scrollHeight;
        }
      });
      this.updateEditRecord("lcdStaffList", JSON.stringify(jsonData));
    },
    /* add スタッフ追加の複数追加と空欄追加 楊 start */
    returnPopoverList(selectDataList) {
      selectDataList.forEach(selectData =>{
        this.returnPopover(selectData);
      })
    },
    /* add スタッフ追加の複数追加と空欄追加 楊 end */
    async getPersonalUser() {
      // 利用者マスタ
      await ApiHelper.get("/mstInfo/mstPersonalUser", {
        facility_cd: this.getSelectFacility
      })
      .then(response => {
        this.mstPersonalUser = response.data;
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('ComsvSettingLcdStaffMainItem.vue', 'getPersonalUser', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      // JSON展開
      if (!this.inputModel.lcdStaffList) {
        this.inputModel.lcdStaffList = '{"staff_list": []}';
      }
      /* mod スタッフ追加の複数追加と空欄追加 楊 start */
      const tempMstPersonalUser = deepCopy(this.mstPersonalUser);
      tempMstPersonalUser.push({
        userId:"",
        userName:""
      });
      const contact = JSON.parse(this.inputModel.lcdStaffList);
      for (let i = 0; i < contact.staff_list.length; i++) {
        const foundData = tempMstPersonalUser.find(
      /* mod スタッフ追加の複数追加と空欄追加 楊 end */
          dataSrc => dataSrc.userId === contact.staff_list[i].user_id
        );
        if (foundData) {
          this.localDataSource.push({
            user_id: foundData.userId,
            name: foundData.userName
          });
        }
      }
      let idx = 0;
      this.localDataSource.forEach(data => {
        data.no = ++idx;
      });
      this.updateWidget();
    },
    /**
     * 行を追加する
     */
    addRow() {
      /* mod スタッフ追加の複数追加と空欄追加 楊 start */
      // 選択ボタンを押した位置を保持
      this.selectedIndex = "add";
      // ポップオーバーを表示
      this.showWheelChairPopover(true);
      this.popoverTarget = event;
      //this.popoverVisible = true;
      /* mod スタッフ追加の複数追加と空欄追加 楊 end */
    },
    // 項目削除
    deleteRow(row) {
      let item = this.localDataSource;
      if (item !== null) {
        const idx = item.findIndex(d => d.no === row.no);
        item.splice(idx, 1);
      }
      const regStaffList = this.localDataSource.map((dat, idx) => ({
        no: idx + 1,
        user_id: dat.user_id
      }));
      let jsonData = "";
      jsonData = {
        staff_list: regStaffList
      };
      this.updateEditRecord("lcdStaffList", JSON.stringify(jsonData));
    },
    sortStaffList() {
      // 番号の振り直し（配列の差し替えは v-model と Sortable の同期を壊すため行わない）
      this.localDataSource.forEach((data, idx) => {
        data.no = idx + 1;
      });
      this.updateEditRecord(
        "lcdStaffList",
        JSON.stringify({
          staff_list: this.localDataSource.map((staff) => ({
            no: staff.no,
            user_id: staff.user_id
          }))
        })
      );
    }
  },
  mounted() {
    // 描画系の処理がすべて完了した後に実行される処理
    for (const num in this.columnDefinition) {
      if (this.columnDefinition[num].field === "comsvCd") {
        this.inputModel.comsvCd = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      if (this.columnDefinition[num].field === "facilityCd") {
        this.inputModel.facilityCd = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      if (this.columnDefinition[num].field === "deviceEdgeNo") {
        this.inputModel.deviceEdgeNo = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      if (this.columnDefinition[num].field === "lcdStaffList") {
        this.inputModel.lcdStaffList = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
    }
    this.getPersonalUser();
    //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
  },
  created() {
    this.getMst();
  }
};
</script>

<style scoped>
#comsv-staff-modal-content {
  height: 100%;
}
#staff-list-wrapper {
  overflow-y: auto;
}
#group-name-form-wrapper {
  height: 42px;
}
input[type="text"] {
  width: 68px;
  text-align: center;
  font-size: 1em;
}
#dummy-wrapper {
  height: 25px;
}
.toolbar-btn {
  font-size: 1em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.select-button {
  min-width: 4em;
  width: 4em;
  padding: 2px 0px 2px 0px;
}
.no-width {
  width: 2em;
  text-align: right;
  margin-right: 0.5em;
}
.delete-button {
  min-width: 3em;
  width: 3em;
  font-size: 1em;
  padding: 2px 0px 2px 0px;
}
.right {
  text-align: right;
}
.header-btn-area {
  height: 2em;
  padding: 0.5em 0.1em 0.1em 0.1em;
}
/* ドラッグ部品関連 */
#staff-list-wrapper table th {
  background-image: none !important;
}
.drag-item {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  flex-wrap: nowrap;
  width: max-content;
}
.drag-item-button-area {
  width: 5em;
  padding-bottom: 3px;
  min-width: max-content;
}
.drag-handle {
  cursor: grab;
  touch-action: none;
}
.drag-handle:active {
  cursor: grabbing;
}
.th-font-weight {
  font-weight: unset;
}
</style>
