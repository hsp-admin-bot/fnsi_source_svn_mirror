<template>
  <div>
    <button @click="showModal(DEVICE_TYPE_DFAS)">DFas</button>
    <button @click="showModal(DEVICE_TYPE_BV)">BV</button>
    <button @click="showModal(DEVICE_TYPE_NA)">Na</button>
    <button @click="showModal(DEVICE_TYPE_BVUFC)">BV-UFC</button>
    <button @click="showModal(DEVICE_TYPE_PRI)">プライミング</button>
    <button @click="debug">デバッグ</button>
    <v-ons-modal :visible="isModalVisible">
      <component
        :is="deviceType"
        v-if="sendcondDeviceInfo !== null"
        :data-source-type="dataSourceType"
        :all-device-info.sync="sendcondDeviceInfo"
        @close="closeModal()"
      />
    </v-ons-modal>
  </div>
</template>

<script>
import baseDeviceSetInfoList from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoList.vue";
import { DATA_SOURCE_TYPE_SENDCOND } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import {
  getDeviceSetInfoPat,
  getDeviceSetInfoOrd
} from "@/components/deviceset-info/base-modules/DeviceSetInfoFunctions.js";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end

/**
 * @description 条件送信装置設定一覧コンポーネント
 */
export default {
  mixins: [baseDeviceSetInfoList],

  props: {
    patId: {
      type: Number,
      // TODO: デバッグ用に固定
      default: 1
      // required: true,
    },

    ordNo: {
      type: Number,
      // TODO: デバッグ用に固定
      default: 1
      // required: true,
    }
  },

  data() {
    return {
      // データ取得元は条件送信
      dataSourceType: DATA_SOURCE_TYPE_SENDCOND,
      sendcondDeviceInfo: null
    };
  },

  async created() {
    // 患者情報と指示の装置設定値を取得
    const [devInfoPat, devInfoOrd] = await Promise.all([
      getDeviceSetInfoPat(this.patId),
      getDeviceSetInfoOrd(this.ordNo)
    ]).catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
      getErrorMessage('DeviceSetInfoListSendcond.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
      throw new Error(error);
    });
    if (
      devInfoPat === "" ||
      devInfoPat === null ||
      devInfoOrd === "" ||
      devInfoOrd === null
    ) {
      throw new Error("装置設定がnullです");
    }

    // 2つの装置設定値を1つのオブジェクトに
    this.sendcondDeviceInfo = { ...devInfoPat, ...devInfoOrd };
  },

  methods: {
    debug() {
      console.log("編集された装置設定値");
      // console.log(this.sendcondDeviceInfo);
    }
  }
};
</script>

<style scoped>
</style>
