// 再検査計算予約
<template>
  <modal-base @onClose="showMstExamItemRecManagementModal">
    <div slot="body" class="modal-body-content">
      <div class="date-content">
        <label>対象期間</label>
        <div>
          <date-input
            v-model="startDate"
            @handleClearInput="startDate = '';"
          />
          <common-calendar
            v-model="startDate"
            :disableDatesAfter="maxDate"
            class="calender"
          />
        </div>
        <span>～</span>
        <div>
          <date-input
            v-model="endDate"
            @handleClearInput="endDate = '';"
          />
          <common-calendar
            v-model="endDate"
            :disableDatesBefore="minDate"
            class="calender"
          />
        </div>
      </div>
      <div class="table-content">
        <div class="table-content-left">
          <label>対象患者</label>
          <kendo-grid :key="gridKey" id="leftGrid" ref="leftGrid" :data-source="leftDataSource" height="100%" @change="handleChange">
            <kendo-grid-column
              :selectable="true"
              width="3em"
            ></kendo-grid-column>
            <kendo-grid-column
              :field="'hosp_pat_id'"
              title="患者ID"
              width="12em"
            ></kendo-grid-column>
            <kendo-grid-column
              title="患者名"
              :template="getPatNameTemplate"
              width="12em"
            ></kendo-grid-column>
          </kendo-grid>
        </div>
        <div class="table-content-right">
          <label>対象検査計算項目</label>
          <kendo-grid :key="gridKey" id="rightGrid" ref="rightGrid" :data-source="rightDataSource" height="100%" @change="handleChange">
            <kendo-grid-column
              :selectable="true"
              width="3em"
            ></kendo-grid-column>
            <kendo-grid-column
              :field="'examItemName'"
              title="検査計算項目名"
              width="12em"
            ></kendo-grid-column>
            <kendo-grid-column
              title="既存結果への上書き"
              :template="getTemplate"
              width="12em"
            >
            </kendo-grid-column>
          </kendo-grid>
        </div>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <v-ons-button class="btn2-cancel denial-btn" @click="showMstExamItemRecManagementModal">
        キャンセル
      </v-ons-button>
      <v-ons-button
        class="btn1-execute registration-btn"
        :disabled="saveBtnDisabled"
        @click="handleSave"
      >
        保存
      </v-ons-button>
    </div>
  </modal-base>
</template>

<script>
import Vue from "vue";
import moment from "moment";
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapState, mapActions } from "vuex";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import ModalBase from "@/components/modals/ModalBase";
import DateInput from "@/components/common/DateInput";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import RadioGroup from "./RadioGroup";
import PatNameCell from './PatNameCell';
export default {
  name: "MstExamItemRecBookingModal",
  components: {
    "modal-base": ModalBase,
    "date-input": DateInput,
    "common-calendar": commonCalender,
  },
  watch: {
    startDate() {
      this.getPatListByFacilityCd();
    },
    endDate() {
      this.getPatListByFacilityCd();
    },
    windowWidth () {
      this.gridKey++;
    },
    windowHeight () {
      this.gridKey++;
    },
    fontSize () {
      this.gridKey++;
    }
  },
  data() {
    return {
      startDate: '',
      endDate: '',
      leftDataSource: null,
      rightDataSource: null,
      hasSelectedItem: false,
      gridKey: 0
    };
  },
  computed: {
    ...mapState("user", ["facilityCd"]),
    ...mapState("account-edit", ["userAccountInfo", "fontSize"]),
    ...mapState("window-size", ["windowWidth", "windowHeight"]),
    saveBtnDisabled () {
      return !(this.hasSelectedItem && (!!this.startDate || !!this.endDate));
    },
    maxDate () {
      return this.endDate ? moment(this.endDate).format('YYYYMMDD') : '';
    },
    minDate () {
      return this.startDate ? moment(this.startDate).format('YYYYMMDD') : '';
    },
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal", "showMstExamItemRecManagementModal"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible", "setLoadingScreenMessage"]),
    handleChange () {
      const checkedPatsElements = document.querySelectorAll("#leftGrid .k-state-selected");
      const checkedItemsElements = document.querySelectorAll("#rightGrid .k-state-selected");
      if (checkedPatsElements?.length && checkedItemsElements?.length) {
        this.hasSelectedItem = true;
      } else {
        this.hasSelectedItem = false;
      }
    },
    getPatListByFacilityCd() {
      this.setLoadingScreenVisible(true);
      ApiHelper.post("/exam/getPatListByFacilityCd", {
        facilityCd: this.facilityCd,
        startDate: this.startDate,
        endDate: this.endDate,
      }).then((res) => {
        const data = res.data;
        data.forEach((item) => {
          if (!item.pat_last_name && !item.pat_first_name) {
            item.patName = '？？？？患者'
          } else {
            item.patName = (item.pat_last_name ? (item.pat_last_name + ' ') : '') + item.pat_first_name || '';
          }
        });
        this.leftDataSource = data;
      }).catch(error => {
         getErrorMessage('MstExamItemRecBookingModal.vue', 'getPatListByFacilityCd', error);
         throw error;
      }).finally(() => {
        this.handleChange();
        this.setLoadingScreenVisible(false);
      });
    },
    getMstExamItem () {
      this.setLoadingScreenVisible(true);
      ApiHelper.get(`/exam/examRecord/examItemForRecalc/${this.facilityCd}`).then((res) => {
        const data = res.data;
        data.forEach((item, index) => {
          item.isCover = false;
          item.index = index;
        });
        this.rightDataSource = data;
      }).catch(error => {
         getErrorMessage('MstExamItemRecBookingModal.vue', 'getMstExamItem', error);
         throw error;
      }).finally(() => {
        this.setLoadingScreenVisible(false);
      });
    },
    getTemplate (data) {
      return {
        template: Vue.component(RadioGroup.name, RadioGroup),
        templateArgs: {
          parentComponent: this,
          item: data,
        }
      };
    },
    getPatNameTemplate (data) {
      return {
        template: Vue.component(PatNameCell.name, PatNameCell),
        templateArgs: {
          parentComponent: this,
          item: data,
        }
      };
    },
    handleSave () {
      if (!this.startDate && !this.endDate) {
        this.$ons.notification.alert({
          title: "注意",
          message: "対象期間を入力してください。"
        });
        return;
      }
      this.setLoadingScreenVisible(true);
      const checkedPatsElements = document.querySelectorAll("#leftGrid .k-state-selected");
      const checkedPats = [];
      Array.from(checkedPatsElements).forEach((item) => {
        checkedPats.push(this.leftDataSource[item.rowIndex].pat_id);
      });
      const checkedItemsElements = document.querySelectorAll("#rightGrid .k-state-selected");
      const checkedItems = [];
      Array.from(checkedItemsElements).forEach((item) => {
        checkedItems.push({
          exam_item_cd: this.rightDataSource[item.rowIndex].examItemCd,
          compute_cover: this.rightDataSource[item.rowIndex].isCover
        });
      });
      let content = {
       pat_id: checkedPats,
       to_date: this.endDate,
       from_date: this.startDate,
       item: checkedItems
      }
      let detail = {
        exam_main_cd: "",
        total_cnt: 0,
        done_cnt: 0
      }
      ApiHelper.post(
        `/exam/createMntRecalcQue/`, {
          facilityCd: this.facilityCd,
          status: "0",
          content: JSON.stringify(content),
          detail: JSON.stringify(detail),
          regId: this.userAccountInfo.userId
        }
      ).then(() => {
        this.$refs.leftGrid.kendoWidget()?.clearSelection();
        this.showMstExamItemRecManagementModal();
      }).catch(error => {
         getErrorMessage('MstExamItemRecBookingModal.vue', 'handleSave', error);
         throw error;
      }).finally(() => {
        this.setLoadingScreenVisible(false);
      });
    },
  },
  mounted() {
    this.setLoadingScreenMessage("処理中・・・");
    this.getPatListByFacilityCd();
    this.getMstExamItem();
    // 获取起始日期和结束日期
    const startDate = moment().subtract(90, 'days').format('YYYY-MM-DD');
    const endDate = moment().format('YYYY-MM-DD');
    this.startDate = startDate;
    this.endDate = endDate;
  },
};
</script>

<style lang="css" scoped>
::v-deep .k-widget {
  font-size: 1em;
}
::v-deep .modal-body {
  width: calc(100% - 16px);
  left: 8px;
  height: calc(100% - 76px - 2em);
}
.modal-body-content {
  width: 100%;
  height: 100%;
}
.date-content {
  display: flex;
  flex-direction: row;
  margin-bottom: 10px;
}
.date-content label, .date-content span {
  line-height: 2em;
  margin: 0 8px;
}
.flex-container> ::v-deep .button {
  width: auto;
}
.table-content {
  width: 100%;
  height: calc(100% - 3em);
  display: flex;
  flex-direction: row;
  justify-content: space-between;
}
.table-content-left {
  width: 48%;
  height: 100%;
  display: flex;
  flex-direction: column;
}
.table-content-right {
  width: 48%;
  height: 100%;
  display: flex;
  flex-direction: column;
}
::v-deep .k-grid{
  flex: 1;
}
::v-deep .k-checkbox-label::before{
  background-color: #fff;
  border-radius: 22px !important;
  width: 22px !important;
  height: 22px !important;
  border: 1px solid #c7c7cd !important;
}
::v-deep .k-checkbox:checked+.k-checkbox-label::before {
  background-color: #3B7FA3 !important;
  border: 0 !important;
}
::v-deep .k-checkbox-label::after{
  position: absolute !important;
  content: '' !important;
  top: 7px !important;
  left: 5px !important;
  width: 12px !important;
  height: 6px !important;
  border: 2px solid #fff !important;
  border-radius: 0 !important;
  border-width: 1px !important;
  border-top: none !important;
  border-right: none !important;
  background: transparent !important;
  transform: rotate(-45deg) !important;
}
::v-deep .k-checkbox:focus+.k-checkbox-label::before{
  box-shadow: none !important;
}
::v-deep .k-checkbox-label.k-no-text, .k-radio-label.k-no-text{
  width: 22px !important;
  height: 22px !important;
}
::v-deep .k-grid td{
  border-width: 0 1px 1px 0 !important;
  border-color: var(--master-maintenance-kgrid-border-color);
}

</style>
