<template>
  <modal-base @onClose="closeAlarmModal" class="custom-modal">
    <!-- <div slot="header">
      <component :is="header"></component>
    </div> -->
    <template #body>
      <div class="modal-content d-flex flex-column" :style="{ 'height': '747px' }">
        <!-- Grid -->
        <div id="history-list" class="main-content-area" style="-webkit-overflow-scrolling:touch;">
          <table class="ntss-list">
            <thead>
              <tr>
                <th class="alarm-list-color ntss-list-header-th-sticky" scope="col">&nbsp;</th>
                <th class="ntss-list-header-th-sticky" scope="col">日付</th>
                <th class="ntss-list-header-th-sticky" scope="col">ベッド名</th>
                <th class="ntss-list-header-th-sticky" scope="col">患者名</th>
                <th class="ntss-list-header-th-sticky" scope="col">内容</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(dispItem,no) in customers1()" :key="no" class="ntss-list-body-tr">
                <td class="ntss-list-body-td">
                  <div
                    class="color"
                    :class="{statusListAlarm: dispItem.isRed, statusListNotify: dispItem.isYellow}"
                  >&nbsp;</div>
                </td>
                <td class="ntss-list-body-td">{{dispItem.occurDate}}</td>
                <td class="ntss-list-body-td">{{dispItem.bedName }}</td>
                <td class="ntss-list-body-td">{{dispItem.PatientName}}</td>
                <td class="ntss-list-body-td">{{dispItem.Contents}}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <!-- / Grid -->

      </div>
    </template>

    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <!-- mod FNSI-画面スタイル(ボタン)対応 付 start -->
        <button class="button denial-btn btn2-cancel" @click="closeAlarmModal">キャンセル</button>
        <!-- mod FNSI-画面スタイル(ボタン)対応 付 end -->
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";

import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { dateFormat } from "@/functions/common/DateTimeUtils.js";

export default {
  mixins: [MasterMaintenanceMixin],
  components: {
    "modal-base": ModalBase
  },
  computed: {
    ...mapGetters("status-list/list", [
      "alarmListSettings",
      "dateFilterDataSource",
      "getCondition",
      "gridCount",
      "getStatusFlg",
      "getStatusList"
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    customers1: function() {
      return this.getHistoryList;
    },
    ...mapGetters("status-map/map", ["getAlarmData"]),
  },
  data: function() {
    return {};
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("bread-crumb", ["resetTitle"]),
    ...mapActions("multi-modal", ["showAralmDetail"]),
    ...mapMutations("status-list/list", {
      setFilterListCount :"setFilterListCount"
    }),
    ...mapActions("status-list/list", [
      "fetchAlarmSettingList"
    ]),
    closeAlarmModal() {
      // モーダルを非表示に
      this.hideModal();
    },
    getHistoryList() {
      // 緊急発報の表示可否
      const isEmergency = this.getCondition.deviceEdgeEmergency;
      // 予防保守の表示可否
      const isDefect = this.getCondition.deviceEdgeDefect;
      // 通信不要の表示可否
      const isAll = this.getCondition.deviceEdgeAll;
      // 抽出条件で絞り込んだ結果を格納する変数
      let filterList = [];
      let alarmList = this.alarmListSettings;
      let buf;

      // グリッドのカウント数
      let count = this.gridCount;

      // 警報注意一覧のデータカウントの確認
      let filterCount = this.filterDataConfirm(alarmList,isEmergency,isDefect,isAll);

      // 初期化の場合、グリッドのカウント数がフィルタ数と合わない
      if (count !== filterCount) {

        for (let lop1 = 0; lop1 < alarmList.length; lop1++) {

          buf = this.setCommonValue(alarmList[lop1]);
          if (buf.historyType == 3) {
            buf.isRed = true;
            buf.isYellow = false;
          } else {
            buf.isRed = false;
            buf.isYellow = true;
          }
          filterList.push(buf);
        }
      } else {
        for (let lop = 0; lop < alarmList.length; lop++) {
          if (isAll) {
            buf = this.setCommonValue(alarmList[lop]);
            if (buf.historyType == 3) {
              buf.isRed = true;
              buf.isYellow = false;
            } else {
              buf.isRed = false;
              buf.isYellow = true;
            }
            filterList.push(buf);
          } else if (isEmergency && alarmList[lop].historyType == 3) {
            buf = this.setCommonValue(alarmList[lop]);
            buf.isRed = true;
            buf.isYellow = false;
            filterList.push(buf);
          } else if (isDefect && alarmList[lop].historyType == 1) {
            buf = this.setCommonValue(alarmList[lop]);
            buf.isRed = false;
            buf.isYellow = true;
            filterList.push(buf);
          }
        }
      }
      // if (this.getAlarmData.mode == 1) {
      //   filterList = filterList.filter(e=> e.PatientName == this.getAlarmData.patName &&
      //                   e.bedName == this.getAlarmData.bedName &&
      //                   dateFormat.queueDate(e.occurDate) == dateFormat.queueDate(new Date()));
      // } else
      if (this.getAlarmData.mode == 2 || this.getAlarmData.mode == 1) {
        filterList = filterList.filter(e=> e.machineTypeCd == this.getAlarmData.machineTypeCd &&
                        e.machineSerial == this.getAlarmData.machineSerial &&
                        dateFormat.queueDate(e.occurDate) == dateFormat.queueDate(new Date()));
      }
      return filterList;
    },
    // 表示一覧データの共通部分作成
    setCommonValue(list) {
      let buf = list;
      buf.isRed = false;
      buf.isYellow = false;
      return buf;
    },
    filterDataConfirm(list,isEmergency,isDefect,isAll){

      let count = 0;
      for (let lop = 0; lop < list.length; lop++) {
        if (isAll) {

          count++;
        } else if (isEmergency && list[lop].historyType == 3) {

          count++;
        } else if (isDefect && list[lop].historyType == 1) {

          count++;
        }
      }

      return count;
    },
    loadData(autoRefreshFlag) {
      // 一覧情報取得
      let changeOccurDate = "";

      if (changeOccurDate == "") {
        // 日付指定がない時は今日？
        let todayDate = dayjs(new Date()).format("YYYYMMDD");
        changeOccurDate = todayDate;
      } else {
        changeOccurDate = dayjs(changeOccurDate).format("YYYYMMDD");
      }
      const info = {
        facilityCd: this.getFacilityCd,
        isClear: true,
        occurDate: changeOccurDate,
        autoRefreshFlag
      };
      this.fetchAlarmSettingList(info).then(result => {
        if (result === false) {
          // alert('取得失敗');
        }
      });
    },
  },
  created() {
    EventBus.$off("alarmSettingLoad", this.loadData);
    EventBus.$on("alarmSettingLoad", this.loadData);
  },
  watch : {
    getAlarmData(){

    }
  },
  mounted() {
    // grid情報取得:初期
    this.loadData();
  },
  beforeUnmount() {
    // add #9211 by zhangruixue 2023-08-02 --start
    this.getCondition.deviceEdgeEmergency = false;
    this.getCondition.deviceEdgeDefect = false;
    this.getCondition.deviceEdgeAll = true;
    // add #9211 by zhangruixue 2023-08-02 --start
    EventBus.$off("alarmSettingLoad", this.loadData);
  }
};
</script>

<style scoped>
.modal-content {
  font-size: 1.25em;
}

.loading-modal {
  font-size: 2.4em;
}
.grid {
  max-height: 100%;
  overflow-y: hidden;
  overflow-x: auto;
  margin-left: 3px;
  margin-right: 3px;
}
.grid .col-header,
.grid .cat-header,
.grid .sub-cat-header {
  padding: 0.1em 0.2em;
  color: var(--ntss-header-color);
  background-color: var(--ntss-header-background-color);
  word-break: break-all;
  border-left: 1px solid var(--ntss-border-color);
  border-bottom: 1px solid var(--ntss-border-color);
}
.grid .th-sticky {
  top: 0;
  position: -webkit-sticky;
  position: sticky;
}
.grid .cat-header {
  min-width: 1.5em;
  width: 1.5em;
  padding-top: 0.3em;
  padding-bottom: 0.3em;
}
.grid .cat-header span {
  writing-mode: vertical-rl;
  align-items: center;
  word-break: keep-all;
}
.grid .sub-cat-header {
  min-width: 8.5em;
  width: 8.5em;
  padding-top: 0.3em;
  padding-bottom: 0.3em;
}
.grid .sub-category-item {
  border-bottom: 1px solid var(--ntss-border-color);
  border-left: 1px solid var(--ntss-border-color);
  background-color: #fafafa;
  /*color: var(--ntss-base-color);*/
  color: #050505;
  padding: 5px;
}
.grid .item-value {
  min-width: 12em;
}
.grid .instructor {
  min-width: 8em;
}
.grid .updater {
  border-right: 1px solid var(--ntss-border-color);
  min-width: 8em;
}
.grid .content-change > .sub-category-item {
  background-color: orange;
}
.right {
  text-align: right;
}
.icon {
  display: flex;
  align-items: center;
  height: calc(1.5em + 10px);
  padding: 5px;
  background-color: #0076ff;
  border-radius: 4px;
  line-height: 20px;
}
.icon :deep(img) {
  width: 1.5em;
}
.statusListAlarm {
  background-color: var(--emergency-background-color);
  width: 100%;
  height: 100%;
  border-radius: 0px;
}
.statusListNotify {
  background-color: var(--preventive-background-color);
  width: 100%;
  height: 100%;
  border-radius: 0px;
}
</style>
