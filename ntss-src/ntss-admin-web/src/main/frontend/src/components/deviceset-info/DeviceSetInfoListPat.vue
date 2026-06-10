<template>
  <div class="main-content-area">
    <table class="ntss-list">
      <thead>
        <tr>
          <th class="ntss-list-header-th-sticky" scope="col">装置設定</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="device in deviceList"
          :key="device.name"
          class="ntss-list-body-tr"
          @click="showDevice(device)"
        >
          <td class="ntss-list-body-td">{{ device.name }}</td>
        </tr>
      </tbody>
    </table>

    <message-dialog
      :visible.sync="isDialogVisble"
      :message-cd="50000006"
      type="1"
    />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import messageDialog from "@/components/common/message-dialog/MessageDialog.vue";
import baseDeviceSetInfoList from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoList.vue";
import { DATA_SOURCE_TYPE_PAT } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
// add #7233 デフォルト帳票について 日本指摘対応 商 start
import moment from "moment";
// add #7233 デフォルト帳票について 日本指摘対応 商 end
// add 画面印刷プレビューと印刷の実現 陳 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
import {EventBus} from "@/eventBus.js";
// add 画面印刷プレビューと印刷の実現 陳 end

class Device {
  constructor(name, type) {
    this.name = name;
    this.type = type;
  }
}

/**
 * @description 患者装置設定一覧コンポーネント
 */
export default {
  components: {
    "message-dialog": messageDialog
  },

  mixins: [baseDeviceSetInfoList],

  data() {
    return {
      // データ取得元は患者情報
      dataSourceType: DATA_SOURCE_TYPE_PAT,
      deviceList: [],
      isDialogVisble: false
    };
  },

  computed: {
    // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
    ...mapGetters("user", ["getFacilityCd"]),
    // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
    // mod 機能帳票パラメータ確認 陳 start
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"])
    // mod 機能帳票パラメータ確認 陳 end
  },

  created() {
    // add 画面印刷プレビューと印刷の実現 陳 start
    // 印刷パラメータ要求
    // add 性能改善メモリ不足 shan start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add 性能改善メモリ不足 shan start
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add 画面印刷プレビューと印刷の実現 陳 end
    this.deviceList = [
      new Device("風袋", "tare"),
      new Device("除水補正", "offwater"),
      new Device("操作範囲", this.DEVICE_TYPE_OPE),
      new Device("ECUM設定", this.DEVICE_TYPE_ECUM),
      new Device("警報点", this.DEVICE_TYPE_WAR),
      new Device("濃度プログラム自動設定警報", this.DEVICE_TYPE_CPRO),
      new Device("血圧計", this.DEVICE_TYPE_BP),
      new Device("BV計", this.DEVICE_TYPE_BV),
      new Device("プライミング", this.DEVICE_TYPE_PRI),
      new Device("D-FAS", this.DEVICE_TYPE_DFAS),
      new Device("静的静脈圧", this.DEVICE_TYPE_IAP),
      new Device("ホスト報知", "hostNotice")
    ];
  },
  // add 画面印刷プレビューと印刷の実現 陳 start
  beforeDestroy() {
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);
    
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  // add 画面印刷プレビューと印刷の実現 陳 end

  methods: {
    // add 画面印刷プレビューと印刷の実現 陳 start
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致

        // 印刷パラメータを応答
        const condition = this.getCondition;

        // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
        var curDate = new Date();
        // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        const param = {
          // add #7233 デフォルト帳票について 日本指摘対応 商 start
          functionCd:"01001",
          date: moment(Date.now()).format("YYYYMMDD"),
          // add #7233 デフォルト帳票について 日本指摘対応 商 end
          patId: this.selectedPatId,
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          facilityCd: this.getFacilityCd,
          fromDate: moment(Date.now()).format("YYYYMMDD"),
          toDate: moment(new Date(curDate.setMonth(curDate.getMonth() + 1))).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: moment(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add 画面印刷プレビューと印刷の実現 陳 end
    /**
     * @description 装置設定表示
     */
    showDevice(device) {
      if (this.selectedPatId === null) {
        // 患者未選択の場合は警告
        this.isDialogVisble = true;
        return;
      }

      this.showModal(device, this.dataSourceType);
    }
  }
};
</script>

<style
  src="@/components/deviceset-info/base-modules/BeseDeviceSetInfoStyle.css"
  scoped
></style>
