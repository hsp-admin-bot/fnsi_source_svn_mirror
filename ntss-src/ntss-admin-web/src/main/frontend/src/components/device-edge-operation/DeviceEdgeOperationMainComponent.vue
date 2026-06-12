/**
 * デバイスエッジ稼働監視 MainContent
 */
<template id='de-operation-page-template'>
  <div class="main-content-area">
    <table class="ntss-list">
      <thead>
        <tr>
          <th
            v-for="column in columns"
            :key="column.key"
            :class="sortedClass(column.key)"
            class="ntss-list-header-th-sticky"
            :style="{ width: column.width + '%'}"
            @click="sortBy(column.key)"
          >{{ column.colName }}</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(deviceEdge, deviceEdgeKey) in filterDeviceEdge(sortDeviceEdgeItems)"
          :key="deviceEdge.facilityCd + deviceEdgeKey"
          :class="getClass(deviceEdge) + ' ntss-list-body-tr'"
          @click="moveToManagePage(deviceEdge)"
        >
          <td class="ntss-list-body-td">{{ deviceEdge.departmentCd }}</td>
          <td class="ntss-list-body-td">{{ deviceEdge.facilityName }}</td>
          <td class="ntss-list-body-td">{{ deviceEdge.deviceName }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import { systemSettings } from "@/constants/systemSettings";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { compareKey } from "@/constants/deviceEdgeOperationDefine";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end

export default {
  mixins: [NextTransitionMixin],
  data() {
    return {
      // 列情報
      // key : ソート時のキー
      // colName : 列名
      // width : 列幅(px指定) ※指定しない場合は自動で幅が調整される
      columns: [
        {
          key: "departmentCd",
          colName: "部署符号",
          width: 1
        },
        {
          key: "facilityNameKana",
          colName: "施設名",
          width: 90
        },
        {
          key: "deviceName",
          colName: "DE名",
          width: 10
        }
      ],
      sort: {
        key: "",
        isAsc: true
      },
      timerObj: null,
      selfScreenName: "",
      /**
       * 「未接続発生順にソート」がチェックされている時にソートするキー名
       */
      isAlarmSortKey: "aliveMoniStatusChangeDate"
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("device-edge-operation", ["getDeviceEdges", "getCondition"]),

    // デバイスエッジのリストのソート
    sortDeviceEdgeItems() {
      // ソート時でstate自体の順序を書き換えないため
      let list = this.getDeviceEdges.slice();
      // 未接続発生順にソートフラグをstoreから取得
      const isAlarmSort = this.getCondition.isAlarmSort;
      // 警告リスト
      const alarmList = list.filter(r => {
        return (["F1", "F2"].includes(r.aliveMoniStatus));
      });
      // 未接続リスト
      const warnList = list.filter(r => {
        return (r.aliveMoniStatus === "F0");
      });
      // 正常リスト
      const successList = list.filter(r => {
        return (!["F1", "F2", "F0"].includes(r.aliveMoniStatus));
      });
      if (isAlarmSort) {
        if (this.sort.key) {
          // ソート指定ならばソートキー順に整列
          list = [
            ...alarmList.sort((a, b) => compareKey(a, b, this.sort.key, this.sort.isAsc)),
            ...warnList.sort((a, b) => compareKey(a, b, this.sort.key, this.sort.isAsc)),
            ...successList.sort((a, b) => compareKey(a, b, this.sort.key, this.sort.isAsc))
          ];
        } else {
          // ソート未指定ならばaliveMoniStatusChangeDate順に整列
          list = [
            ...alarmList.sort((a, b) => compareKey(a, b, this.isAlarmSortKey, false)),
            ...warnList.sort((a, b) => compareKey(a, b, this.isAlarmSortKey, false)),
            ...successList.sort((a, b) => compareKey(a, b, this.isAlarmSortKey, false))
          ];
        }
      } else if (this.sort.key) {
        list.sort((a, b) => compareKey(a, b, this.sort.key, this.sort.isAsc));
      }
      return list;
    },
    // -----------------------------------------
    // 日機装ユーザーか否か
    // 日機装ユーザーの場合、trueを返します。
    // -----------------------------------------
    isNkkUser() {
      return 1 === this.getStateUserAccountInfo.userType;
    },
    // -----------------------------------------
    // 管理者ユーザーか否か
    // 管理者ユーザーの場合、trueを返します。
    // -----------------------------------------
    isAdminUser() {
      return 1 === this.getStateUserAccountInfo.administrator;
    }
  },
  methods: {
    ...mapActions("device-edge-operation", ["findDeviceEdges"]),
    ...mapActions("device-edge-manage", ["setDeviceEdgeInfo"]),

    // 昇順/降順のclassを作成
    sortedClass(key) {
      return this.sort.key === key
        ? `sorted-${this.sort.isAsc ? "desc" : "asc"}`
        : "";
    },
    // ソートするキーを設定する
    sortBy(key) {
      if (key === this.sort.key && !this.sort.isAsc) {
        // ソートをクリア
        this.sort.key = "";
        this.sort.isAsc = true;
        return;
      }
      this.sort.isAsc = this.sort.key === key ? !this.sort.isAsc : true;
      this.sort.key = key;
    },
    // 行の背景色を付与する為のクラスを取得する
    getClass(deviceEdge) {
      const aliveMoniStatus = deviceEdge.aliveMoniStatus;
      if (aliveMoniStatus === "F1" || aliveMoniStatus === "F2") {
        return "emergency-row";
      } else if (aliveMoniStatus === "F0") {
        return "com-problem-row";
      }
      return "";
    },
    // 抽出条件のフィルタ
    filterDeviceEdge(deviceEdges) {
      // 選択されている部署符号
      const departmentCd = this.getCondition.departmentCd;
      // 選択されている都道府県
      const prefName = this.getCondition.prefName;
      // 入力されている施設名
      const facilityName = this.getCondition.facilityName;
      // 通信異常、デバイスエッジ異常の表示可否
      const isEmergency = this.getCondition.deviceEdgeEmergency;
      // 手動停止の表示可否
      const isDefect = this.getCondition.deviceEdgeDefect;
      // 全情報の表示可否
      const isAll = this.getCondition.deviceEdgeAll;
      // 抽出条件で絞り込んだ結果を格納する変数
      const filterDeviceEdge = [];
      // 抽出条件が未入力の場合
      if (
        (!departmentCd || departmentCd === "-") &&
        (!prefName || prefName === "-") &&
        !facilityName &&
        isAll
      ) {
        return deviceEdges;
      }
      // -----------------------------------------
      // 抽出条件が入力されている場合
      // -----------------------------------------
      for (let idx = 0; idx < deviceEdges.length; idx++) {
        // 抽出条件対象フラグ
        let isFilter = true;
        if (departmentCd && departmentCd !== "-") {
          if (deviceEdges[idx].departmentCd === departmentCd) {
            isFilter = true;
          } else {
            isFilter = false;
          }
        }
        if (prefName && prefName !== "-" && isFilter) {
          if (deviceEdges[idx].prefName === prefName) {
            isFilter = true;
          } else {
            isFilter = false;
          }
        }
        if (facilityName && isFilter) {
          if (deviceEdges[idx].facilityName.indexOf(facilityName) > -1) {
            isFilter = true;
          } else {
            isFilter = false;
          }
        }
        if (isFilter) {
          if (isAll) {
            filterDeviceEdge.push(deviceEdges[idx]);
          } else if (
            isEmergency &&
            (deviceEdges[idx].aliveMoniStatus === "F1" ||
              deviceEdges[idx].aliveMoniStatus === "F2")
          ) {
            filterDeviceEdge.push(deviceEdges[idx]);
          } else if (isDefect && deviceEdges[idx].aliveMoniStatus === "F0") {
            filterDeviceEdge.push(deviceEdges[idx]);
          }
        }
      }
      return filterDeviceEdge;
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$route.name) {
        this.dataLoad();
      }
    },
    dataLoad() {
      this.findDeviceEdges(this.getStateUserAccountInfo.userId).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('DeviceEdgeOperationMainComponent.vue', 'dataLoad', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        if (error.response.status === 400) {
          // TODO 必要に応じて、適切な業務エラー処理を実装すること。
        }
      });
      // 指定された間隔で一覧の再取得を行う
      clearTimeout(this.timerObj);
      this.timerObj = setTimeout(
        this.dataLoad,
        systemSettings.reloadInterval.deviceEdgeOperation
      );
    },
    // デバイスエッジアップデータ操作画面へ遷移する
    moveToManagePage(deviceEdge) {
      if (this.isNkkUser && this.isAdminUser) {
        this.setDeviceEdgeInfo(deviceEdge);
        this.goSpecifiedView("device-edge-manage");
      }
    }
  },
  created() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    // add 性能改善メモリ不足 shan start
    EventBus.$off("refresh", this.refresh);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("refresh", this.refresh);
    this.dataLoad();
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
    clearTimeout(this.timerObj);
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<style scoped>
</style>
