// 再検査計算管理
<template>
  <modal-base @onClose="hideModal">
    <div slot="body" class="modal-body-content">
      <div class="tool-bar">
        <v-ons-button
          class="btn3-normal add-btn"
          @click="showMstExamItemRecBookingModal"
          :disabled="addBtnDisabled"
          >予約追加</v-ons-button
        >
      </div>
      <div class="grid-content">
        <kendo-grid ref="grid" :data-source="localDataSource" height="100%">
          <template v-for="(col, index) in columns">
            <kendo-grid-column
              v-if="col.title === '中止'"
              :key="index"
              :title="col.title"
              :width="col.width"
              :command="[{
                text: '中止',
                click: handleDiscontinue,
                className: 'btn3-normal shutdown-btn',
                visible: function(dataItem) {
                  return dataItem.index === 0 && ['未処理', '処理中(処理時間外)'].includes(dataItem.status);
                },
              }]"
            >
            </kendo-grid-column>
            <kendo-grid-column
              v-else
              :key="index"
              :field="col.field"
              :title="col.title"
              :width="col.width"
              :template="col.template"
            >
            </kendo-grid-column>
          </template>
        </kendo-grid>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <v-ons-button
        class="btn2-cancel common-style-cancel-button"
        @click="hideModal"
        :disabled="false"
        >閉じる</v-ons-button
      >
    </div>
  </modal-base>
</template>

<script>
import moment from "moment";
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapState, mapActions } from "vuex";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import ModalBase from "@/components/modals/ModalBase";
export default {
  name: "MstExamItemRecManagementModal",
  components: {
    "modal-base": ModalBase,
  },
  data() {
    return {
      columns: [
        { field: "regDate", title: "予約追加日時", width: '10em' },
        { field: "status", title: "状態", width: '10em' },
        { field: "date", title: "対象期間", width: '15em', template: `<span class="#: fromDate === '' ? 'placeholder' : '' #">#: date # </span>` },
        { field: "patient_count", title: "患者数", width: '5em' },
        {
          field: "item_count",
          title: "検査計算項目数",
          width: '9em',
        },
        { field: "progress", title: "進捗", width: '8em' },
        { field: "", title: "中止", width: '6em' },
      ],
      localDataSource: [],
    };
  },
  computed: {
    ...mapState("user", ["facilityCd"]),
    ...mapState("master-maintenance", ["facilitySwitch"]),
    ...mapState("account-edit", ["userAccountInfo", "fontSize"]),
    ...mapState("window-size", ["windowWidth", "windowHeight"]),
    addBtnDisabled() {
      return ['処理中', '未処理', '処理中(処理時間外)'].includes(this.localDataSource?.[0]?.status);
    },
  },
  methods: {
    ...mapActions("loading-screen", ["setLoadingScreenVisible", "setLoadingScreenMessage"]),
    ...mapActions("multi-modal", [
      "hideModal",
      "showMstExamItemRecBookingModal",
    ]),
    getMntRecalcQueList() {
      this.setLoadingScreenVisible(true);
      const statusContrast = {
        0: "未処理",
        1: "処理中",
        2: "完了",
        3: "中止",
        4: "処理中(処理時間外)",
        8: "エラー",
        9: "中止",
      };
      ApiHelper.get(`/exam/MntRecalcQue/${this.facilityCd}`).then(
        (response) => {
          const data = response.data;
          data.forEach((item, index) => {
            item.index = index;
            item.regDate = moment(item.regDate).format("YYYY/MM/DD HH:mm");
            // item.upDate = moment(item.upDate).format("YYYY/MM/DD HH:mm");
            item.status = statusContrast[item.status];
            const content = JSON.parse(item.content);
            item.toDate = content.to_date?.replaceAll('-', '/');
            item.fromDate = content.from_date?.replaceAll('-', '/');
            item.date = `${item.fromDate}  ～  ${item.toDate}`;
            item.detail = JSON.parse(item.detail);
            item.patient_count = content.pat_id.length;
            item.item_count = content.item.length;
            item.calcPatId = JSON.parse(item.calcPatId);
            item.progress =
              (item.calcPatId?.calc_pat_id?.length || 0) +
              " / " +
              item.patient_count + ' 人';
          });
          this.localDataSource = data;
        }
      ).catch(error => {
         getErrorMessage('MstExamItemRecManagementModal.vue', 'getMntRecalcQueList', error);
         throw error;
      }).finally(() => {
        this.setLoadingScreenVisible(false);
      });
    },
    handleDiscontinue() {
      const dataItem = this.localDataSource[0];
      this.setLoadingScreenVisible(true);
      ApiHelper.post("/exam/updateMntRecalcQue/", {
        status: "9",
        content: dataItem?.content,
        upId: this.userAccountInfo.userId,
        recalcQueCd: dataItem?.recalcQueCd
      }).then(() => {
        this.getMntRecalcQueList();
      }).catch(error => {
         getErrorMessage('MstExamItemRecManagementModal.vue', 'handleDiscontinue', error);
         throw error;
      }).finally(() => {
        this.setLoadingScreenVisible(false);
      });
    },
  },
  mounted() {
    this.setLoadingScreenMessage("処理中・・・");
    this.getMntRecalcQueList();
  },
  watch: {
    windowWidth () {
      this.$refs.grid.kendoWidget().refresh();
    },
    windowHeight () {
      this.$refs.grid.kendoWidget().refresh();
    },
    fontSize () {
      this.$refs.grid.kendoWidget().refresh();
    }
  }
};
</script>

<style lang="css" scoped>
::v-deep .k-widget {
  font-size: 1em;
}
::v-deep .modal-body {
  width: calc(100% - 16px);
  height: calc(100% - 76px - 2em);
  left: 8px;
}
.modal-body-content {
  width: 100%;
  height: 100%;
}
.tool-bar {
  width: 100%;
  display: inline-block;
}
.add-btn {
  float: right;
  width: auto;
}
::v-deep .shutdown-btn {
  font-size: 1em;
}
.grid-content {
  height: calc(100% - 3em);
  width: 100%;
}
::v-deep .placeholder {
  padding-left: 84px;
}
::v-deep .flex-container {
  flex-direction: column;
}
::v-deep .btn2-cancel {
  align-self: flex-end;
}
::v-deep .k-grid td{
  border-width: 0 1px 1px 0 !important;
  border-color: var(--master-maintenance-kgrid-border-color);
}
</style>
