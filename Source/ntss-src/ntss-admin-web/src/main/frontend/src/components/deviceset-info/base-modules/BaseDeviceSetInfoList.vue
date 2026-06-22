<script>
import {
  DEVICE_TYPE_OPE,
  DEVICE_TYPE_WAR,
  DEVICE_TYPE_BP,
  DEVICE_TYPE_BV,
  DEVICE_TYPE_PRI,
  DEVICE_TYPE_UFR,
  DEVICE_TYPE_NA,
  DEVICE_TYPE_DC,
  DEVICE_TYPE_ECUM,
  DEVICE_TYPE_CPRO,
  DEVICE_TYPE_IHDF,
  DEVICE_TYPE_BVUFC,
  DEVICE_TYPE_DIA,
  DEVICE_TYPE_QBQD,
  DEVICE_TYPE_DFAS,
  DEVICE_TYPE_IAP
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import tare from "@/components/deviceset-info/tare-info/TareInfoEditor.vue";
import offwater from "@/components/deviceset-info/off-water-info/OffWaterInfoEditor.vue";
// add FNSI7658-装置設定>プライミングにて動脈充填の流量を変更すると血流量の見直しの注意喚起メッセージが表示される 周 start
import ope from "@/components/deviceset-info/ope/OpeEditor.vue";
import war from "@/components/deviceset-info/warning-point/WarningPointEditor.vue";
import bp from "@/components/deviceset-info/blood-pressure/BloodPressureEditor.vue";
import bv from "@/components/deviceset-info/bv/BVEditor.vue";
import pri from "@/components/deviceset-info/priming/PrimingEditor.vue";
import ufr from "@/components/deviceset-info/ufr-program/UfrProgramEditor.vue";
import na from "@/components/deviceset-info/na-program/NaProgramEditor.vue";
import dc from "@/components/deviceset-info/dc-program/DcProgramEditor.vue";
import ecum from "@/components/deviceset-info/ecum/EcumEditor.vue";
import cpro from "@/components/deviceset-info/cpro/CproEditor.vue";
import ihdf from "@/components/deviceset-info/i-hdf/IHdfMain.vue";
import bvufc from "@/components/deviceset-info/bv-ufc/BvUfcEditor.vue";
import dia from "@/components/deviceset-info/diaysis-program/DiaysisProgramEditor.vue";
import qbqd from "@/components/deviceset-info/qbqd/QbqdEditor.vue";
import dfas from "@/components/deviceset-info/d-fas/DFasEditor.vue";
import iap from "@/components/deviceset-info/iap/IapEditor.vue";
// add FNSI7658-装置設定>プライミングにて動脈充填の流量を変更すると血流量の見直しの注意喚起メッセージが表示される 周 end
import hostNotice from "@/components/deviceset-info/host-notification/HostNoticeEditor.vue";
import baseTareOffwater from "@/components/deviceset-info/base-modules/TareAndOffWaterInfoEditBase.vue";
import { mapActions } from "@/compat/vue/vuex";

/**
 * @description 装置設定一覧ベースコンポーネント
 */
export default {
  components: {
    // mod FNSI7658-装置設定>プライミングにて動脈充填の流量を変更すると血流量の見直しの注意喚起メッセージが表示される 周 start
    // [DEVICE_TYPE_OPE]: () =>
    //   import(
    //     "@/components/deviceset-info/ope/OpeEditor.vue"),
    // [DEVICE_TYPE_WAR]: () =>
    //   import(
    //     "@/components/deviceset-info/warning-point/WarningPointEditor.vue"
    //   ),
    // [DEVICE_TYPE_BP]: () =>
    //   import(
    //     "@/components/deviceset-info/blood-pressure/BloodPressureEditor.vue"
    //   ),
    // [DEVICE_TYPE_BV]: () =>
    //   import("@/components/deviceset-info/bv/BVEditor.vue"),
    // [DEVICE_TYPE_PRI]: () =>
    //   import("@/components/deviceset-info/priming/PrimingEditor.vue"),
    // [DEVICE_TYPE_UFR]: () =>
    //   import("@/components/deviceset-info/ufr-program/UfrProgramEditor.vue"),
    // [DEVICE_TYPE_NA]: () =>
    //   import("@/components/deviceset-info/na-program/NaProgramEditor.vue"),
    // [DEVICE_TYPE_DC]: () =>
    //   import("@/components/deviceset-info/dc-program/DcProgramEditor.vue"),
    // [DEVICE_TYPE_ECUM]: () =>
    //   import("@/components/deviceset-info/ecum/EcumEditor.vue"),
    // [DEVICE_TYPE_CPRO]: () =>
    //   import("@/components/deviceset-info/cpro/CproEditor.vue"),
    // [DEVICE_TYPE_IHDF]: () =>
    //   import("@/components/deviceset-info/i-hdf/IHdfMain.vue"),
    // [DEVICE_TYPE_BVUFC]: () =>
    //   import("@/components/deviceset-info/bv-ufc/BvUfcEditor.vue"),
    // [DEVICE_TYPE_DIA]: () =>
    //   import(
    //     "@/components/deviceset-info/diaysis-program/DiaysisProgramEditor.vue"
    //   ),
    // [DEVICE_TYPE_QBQD]: () =>
    //   import("@/components/deviceset-info/qbqd/QbqdEditor.vue"),
    // [DEVICE_TYPE_DFAS]: () =>
    //   import("@/components/deviceset-info/d-fas/DFasEditor.vue"),
    // [DEVICE_TYPE_IAP]: () =>
    //   import("@/components/deviceset-info/iap/IapEditor.vue"),
    ope,
    war,
    bp,
    bv,
    pri,
    ufr,
    na,
    dc,
    ecum,
    cpro,
    ihdf,
    bvufc,
    dia,
    qbqd,
    dfas,
    iap,
    // mod FNSI7658-装置設定>プライミングにて動脈充填の流量を変更すると血流量の見直しの注意喚起メッセージが表示される 周 end
    tare,
    offwater,
    // ""で囲われた箇所は省略可能だが、可読性の為に記載
    "host-notice": hostNotice,
    baseTareOffwater
  },

  data() {
    return {
      // 装置設定値取得元 ※各装置設定一覧画面で定義すること
      dataSourceType: null,
      deviceType: null,
      DEVICE_TYPE_OPE,
      DEVICE_TYPE_WAR,
      DEVICE_TYPE_BP,
      DEVICE_TYPE_BV,
      DEVICE_TYPE_PRI,
      DEVICE_TYPE_UFR,
      DEVICE_TYPE_NA,
      DEVICE_TYPE_DC,
      DEVICE_TYPE_ECUM,
      DEVICE_TYPE_CPRO,
      DEVICE_TYPE_IHDF,
      DEVICE_TYPE_BVUFC,
      DEVICE_TYPE_DIA,
      DEVICE_TYPE_QBQD,
      DEVICE_TYPE_DFAS,
      DEVICE_TYPE_IAP
    };
  },
  methods: {
    ...mapActions("device-set-info-modal", ["setDeviceSetInfo"]),
    ...mapActions("multi-modal", ["showDeviceSetInfoModal"]),
    ...mapActions("multi-sub-modal", ["showDeviceSetInfoSubModal"]),

    /**
     * @description 装置設定モーダル表示
     * @param {Object} 装置種類
     * @param {Number} 装置設定値取得元
     */
    showModal(device, deviceSourceType) {
      // component要素のis属性にコンポーネント名をバインドすることで対応するコンポーネントを表示する
      this.deviceType = device.type;
      this.setDeviceSetInfo({ deviceType: device.type, deviceSourceType });
      this.showDeviceSetInfoModal(device.name);
    },

    /**
     * @description 装置設定サブモーダル表示
     * @param {Object} 装置種類
     * @param {Number} 装置設定値取得元
     */
    showSubModal(device, deviceSourceType) {
      // component要素のis属性にコンポーネント名をバインドすることで対応するコンポーネントを表示する
      this.deviceType = device.type;
      this.setDeviceSetInfo({ deviceType: device.type, deviceSourceType });
      this.showDeviceSetInfoSubModal(device.name);
    }
  }
};
</script>

<style scoped></style>
