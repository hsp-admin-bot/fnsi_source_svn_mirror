<template>
  <div class="main-content-area">
    <table id="device-info-list" class="ntss-list">
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
          @click="showModal(device, dataSourceType)"
        >
          <td class="ntss-list-body-td">{{ device.name }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import baseDeviceSetInfoList from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoList.vue";
import { DATA_SOURCE_TYPE_MST } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import { mapGetters,mapActions } from "@/compat/vue/vuex";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import { getLatestHeaderElement, getHeaderHeight, getFooterMenuClientHeight, getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";

class Device {
  constructor(name, type) {
    this.name = name;
    this.type = type;
  }
}

/**
 * @description マスタ装置設定一覧コンポーネント
 */
export default {
  mixins: [baseDeviceSetInfoList],

  data() {
    return {
      // データ取得元はマスタ
      dataSourceType: DATA_SOURCE_TYPE_MST,
      deviceList: [],
      editingFlg: false,
    };
  },
  computed: {
    ...mapGetters("user", ["getAdvancedSettings"]),
    ...mapGetters("master-maintenance", ["getFacilitySwitchAdvancedSettings"]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
    }),
  },

  created() {
    this.setLoadingScreenVisible(true);
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
      new Device("ホスト報知", "hostNotice"),
      // mod FNSI-UFRプログラムの修正 楊 start
      //new Device("UFRプログラム", this.DEVICE_TYPE_UFR),
      new Device("除水プログラム", this.DEVICE_TYPE_UFR),
      // mod FNSI-UFRプログラムの修正 楊 start
      new Device("Na注入プログラム", this.DEVICE_TYPE_NA),
      new Device("透析液濃度プログラム", this.DEVICE_TYPE_DC),
      new Device("血流量・透析液流量プログラム", this.DEVICE_TYPE_QBQD),
      new Device("I-HDF", this.DEVICE_TYPE_IHDF),
    ];

    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // const isBvUfc = this.getAdvancedSettings.func_advcds.some(
    //   setting => setting.func_advcd === ADVANCED_SETTINGS.BV_UFC
    // );
    // const isDAProgram = this.getAdvancedSettings.func_advcds.some(
    //   setting =>
    //     setting.func_advcd === ADVANCED_SETTINGS.DIALYSIS_AMOUNT_PROGRAM
    // );
    const isBvUfc = this.getFacilitySwitchAdvancedSettings.some(
      setting => setting === ADVANCED_SETTINGS.BV_UFC
    );
    const isDAProgram = this.getFacilitySwitchAdvancedSettings.some(
      setting =>
        setting === ADVANCED_SETTINGS.DIALYSIS_AMOUNT_PROGRAM
    );
    // mod マスタ一覧 1･施設切替を可能とする 孔s end

    if (isBvUfc) {
      // 施設設定-拡張設定-BV-UFCが"ON"の場合のみ一覧に表示する
      this.deviceList.push(new Device("BV-UFC", this.DEVICE_TYPE_BVUFC));
    }
    if (isDAProgram) {
      // 施設設定-拡張設定-透析量プログラムが"ON"の場合のみ一覧に表示する
      this.deviceList.push(
        new Device("透析量プログラム", this.DEVICE_TYPE_DIA)
      );
    }
    this.setLoadingScreenVisible(false);
  },
  methods: {
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.editingFlg) {
        const wh = this.windowHeight;
        const hh = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
        // フッターメニューの高さ
        const fmh = getFooterMenuClientHeight(this.$el || null)

        // 追加ボタンや並び替えボタンエリアの高さ
        const mainFonts = getScopedElementsByClassName("main-font", this.$el || this);
        const mainFont = this.$el?.closest?.(".main-font") || mainFonts[1] || mainFonts[0];
        if (mainFont) {
          mainFont.style.height = wh - hh - fmh + "px";
        }
      }
    },
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style
  src="@/components/deviceset-info/base-modules/BeseDeviceSetInfoStyle.css"
  scoped
></style>
