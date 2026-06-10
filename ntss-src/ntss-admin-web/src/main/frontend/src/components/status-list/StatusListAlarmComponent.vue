/**
* 治療状況リスト（警報・報知一覧）  MainContent
*/
<template>
  <div id="history-list" class="main-content-area" style="-webkit-overflow-scrolling:touch;">
    <table class="ntss-list">
      <thead>
      <th class="alarm-list-color ntss-list-header-th-sticky" scope="col">&nbsp;</th>
      <th class="ntss-list-header-th-sticky" scope="col">日付</th>
      <th class="ntss-list-header-th-sticky" scope="col">ベッド名</th>
      <th class="ntss-list-header-th-sticky" scope="col">患者名</th>
      <th class="ntss-list-header-th-sticky" scope="col">内容</th>
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
</template>

<script>
import Kendo from "@progress/kendo-ui";
import { mapActions, mapGetters, mapMutations } from "vuex";
import moment from "moment";
// add FNSI-警報・報知追加 徐 start
import { dateFormat } from "@/functions/common/DateTimeUtils.js";
// add FNSI-警報・報知追加 徐 end
// #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
import { EventBus } from "@/eventBus.js";
// #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end

export default {
  props: {},
  // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
  watch: {
    getOccurDate (val) {
      this.gainOccurDate = val
    }
  },
  // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
  computed: {
    ...mapGetters("status-list/list", [
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
      "getOccurDate",
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
      "alarmListSettings",
      "dateFilterDataSource",
      "getCondition",
      "gridCount",
      // add FNSI-警報・報知追加 徐 start
      "getStatusFlg",
      "getStatusList"
      // add FNSI-警報・報知追加 徐 end
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    customers() {
      return new Kendo.data.DataSource({
        data: this.alarmListSettings
      });
    },
    customers1: function() {
      return this.getHistoryList;
    }
  },
  data: function() {
    return {
      gainOccurDate: null
    };
  },
  // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
  async created () {
    EventBus.$off("refresh", this.refresh);
    EventBus.$on("refresh", this.refresh);
    EventBus.$off("autoRefresh", this.autoRefresh);
    EventBus.$on("autoRefresh", this.autoRefresh);
  },
  // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
  methods: {
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
    refresh () {
      this.loadData('refresh')
    },
    // 自動更新処理
    autoRefresh () {
      this.loadData('refresh', true);
    },
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
    ...mapActions("status-list/list", [
      "fetchAlarmSettingList",
      "setGridCount",
      "setIsAlarmDisplay"
    ]),
    ...mapMutations("status-list/list", {
      setFilterListCount :"setFilterListCount",
      setStatusList: "setStatusList" ,
    }),
    loadData(type, autoRefreshFlag) {
      // 一覧情報取得
      let changeOccurDate = "";

      if (changeOccurDate == "") {
        // 日付指定がない時は今日？
        // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
        let todayDate = (type == 'refresh' && (this.gainOccurDate != null) ? moment(this.gainOccurDate).format("YYYYMMDD") : (this.getOccurDate != null) ? moment(this.getOccurDate).format("YYYYMMDD") : moment(new Date()).format("YYYYMMDD"));
        // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
        changeOccurDate = todayDate;
      } else {
        changeOccurDate = moment(changeOccurDate).format("YYYYMMDD");
      }
      const info = {
        facilityCd: this.getFacilityCd,
        isClear: true,
        occurDate: changeOccurDate,
        autoRefreshFlag
      };
      this.fetchAlarmSettingList(info).then(() => {
        // NOTE: 呼び出し元は何も返却しないため、不要な分岐を削除
        const eventName = autoRefreshFlag ? "autoFiltering" : "initAlarm";
        EventBus.$emit(eventName);
      });
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

      // add FNSI-改修内容不具合対応 陳 start

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
        // add FNSI-改修内容不具合対応 陳 end
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
      // add FNSI-警報・報知追加 徐 start
      // if (this.getStatusFlg == 1) {
      //   filterList = filterList.filter(e=> e.PatientName == this.getStatusList.patName &&
      //                     e.bedName == this.getStatusList.bedName &&
      //                     dateFormat.queueDate(e.occurDate) == dateFormat.queueDate(new Date()));
      //   this.setFilterListCount(filterList.length);
      //   return filterList;
      // } else
      /* mod #6006 by zhangruixue 2023-05-31 --start */
      // mod #9371 治療状況リストにおける警報・報知の動作不良 dou start
      // if (this.getStatusFlg == 2 || this.getStatusFlg == 1) {
      if (this.getStatusFlg > 0) {
        // mod #9371 治療状況リストにおける警報・報知の動作不良 dou end
        filterList = filterList.filter(e=> e.machineTypeCd == this.getStatusList.machineTypeCd &&
          e.machineSerial == this.getStatusList.machineSerial &&
          dateFormat.queueDate(e.occurDate) == dateFormat.queueDate(this.getOccurDate ? this.getOccurDate : new Date()));
        this.setFilterListCount(filterList.length);
        return filterList;
      }
      /* mod #6006 by zhangruixue 2023-05-31 --end */
      // add FNSI-警報・報知追加 徐 end
      this.setFilterListCount(filterList.length);
      return filterList;
    },
    // 表示一覧データの共通部分作成
    setCommonValue(list) {
      let buf = list;
      buf.isRed = false;
      buf.isYellow = false;
      return buf;
    },

    // add FNSI-改修内容不具合対応 陳 start
    // 警報注意一覧のデータカウントの確認
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
    }
    // add FNSI-改修内容不具合対応 陳 end
  },
  mounted() {
    // grid情報取得:初期
    this.loadData();
  },
  destroyed() {
    this.setIsAlarmDisplay(false);
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("autoRefresh", this.autoRefresh);
    // add #9211 by zhangruixue 2023-08-02 --start
    this.getCondition.deviceEdgeEmergency = false;
    this.getCondition.deviceEdgeDefect = false;
    this.getCondition.deviceEdgeAll = true;
    // add #9211 by zhangruixue 2023-08-02 --end
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
  }
};
</script>

<style scoped>
.history-list {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 100;
  overflow-y: auto;
  margin: 5px;
  margin-top: 0;
  height: inherit;
}
.alarm-list-color {
  width: 20px;
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
