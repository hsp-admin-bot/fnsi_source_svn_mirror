/**
 * 穿刺返血大画面共通部
 */
<template>
  <div class="large-display-main-content-area">
    <!-- メイン領域 -->
    <div class="large-display-main-content" :style="mainHeightStyles">
      <div v-if="isStandardViewMode">
        <!-- 通常表示 -->
        <standard-component />
      </div>
      <div v-else>
        <!-- 複数列カラム表示 -->
        <multi-column-component />
      </div>
    </div>
    <!-- フッター -->
    <div class="large-display-footer-content flex-container">
      <div class="flex-btn-area" style="overflow-x: hidden;" id="chip-area">
        <div v-for="(option,index) in navigationList"
            :key="option.length"
            :class="option.class"
            :value="index">
          {{ option.bedName }}
        </div>
      </div>
      <div class="flex-btn-area" id="btn-area">
        <div id="hide-counter" style="
          padding: 7px 13px 3px 13px;
          margin: 2px 3px;
          border-radius: 20px;
          border: 2px solid white;
          white-space: nowrap;
          color: white;
          background: rgba(180,58,58,1);
          display:none;
          width: 55px;">
          ＋{{ hideChipsCount }}件
        </div>
        <div class="display-close" @click="changeViewMode">
          <img class="img-icon none-event" src="img/status-list/change-mode.png" />
        </div>
        <div class="display-close" @click="moveStatusList">
          <img class="img-icon none-event" src="img/status-list/close-screen.png" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import dayjs from "@/compat/date/dayjs";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import StatusListStandardComponent from "@/components/status-list/large-display/StatusListLargeDispStandardMainComponent";
import StatusListMultiColumnComponent from "@/components/status-list/large-display/StatusListLargeDispMultiColumnMainComponent";
import { ApiHelper } from "@/apis/AxiosHelper";
import { STATUS_LARGE_AUTO_SETTING, STATUS_LARGE_FORCE_SIGNOUT } from "@/constants/facilitySetting";
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import { initForceSignOutFlag } from "@/functions/common/CommonFunctions.js";
import { EventBus } from "@/compat/vue/event-bus.js";
import { getFooterMenuElement, getScopedElementsByClassName, getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";

export default {
  mixins: [NextTransitionMixin],
  components: {
    "standard-component": StatusListStandardComponent,
    "multi-column-component": StatusListMultiColumnComponent
  },
  data() {
    return {
      isStandardViewMode: true,
      intervalObj: 0,
      contentHeight: 0,
      // フッタ表示用リスト
      navigationList: [],
      mstBed: [],
      hideChipsCount: 0,
      refreshInterval: 0
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("status-list/large-display", [
      "beforeTreatList",
      "nowTreatList",
      "afterTreatList",
      "getIsDispCharge1NotSet",
      "getIsDispCharge2NotSet"
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    mainHeightStyles() {
      // main-content部の高さをCSS変数を利用して書き換え
      return { height: `${this.contentHeight}px` };
    }
  },
  methods: {
    ...mapActions("status-list/large-display", [
      "setDispData",
      "fetchEntryList",
      "setIsDispCharge1NotSet",
      "setIsDispCharge2NotSet"
    ]),
    ...mapActions("account-edit", [
      "setIsDispFloatMenu",
      "setIsDispSidebarBtn"
    ]),
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    /**
     * 入退室対象患者一覧をDBから取得する(取得データはストアへ格納)
     */
    loadData(autoRefreshFlag) {
      let todayDate = dayjs().format("YYYYMMDD");
      const param = {
        treatDate: todayDate,
        autoRefreshFlag
      };
      this.fetchEntryList(param).then(response => {
        // console.log(response);
        if (response.status == 200) {
          this.setDispData(response.data);

          this.navigationList = [];
          this.makeNavigationList(this.beforeTreatList);
          this.makeNavigationList(this.nowTreatList);
          this.makeNavigationList(this.afterTreatList);
        }
      });
    },

    // ナビゲーションバーに異常ベッド表示するリストをつくる
    makeNavigationList(itemList) {
      for (const item of itemList) {
        // ベッドの表示順を取得
        let bedDispOrder = 99999;
        for (let i = 0; i < this.mstBed.length; i++) {
          if (this.mstBed[i].bedCd === item.bedCd) {
            bedDispOrder = i;
            break;
          }
        }

        if (this.getIsDispCharge2NotSet && !item.isCharge2Done) {
          // 担当者1未入力情報を navigationList に追加する
          this.navigationList.push({
            isBloodMeasure: false,
            chargeNo: 2,
            bedDispOrder: bedDispOrder,
            class: "bed-alert no-charge2",
            bedName: item.bedName
          });
        }
        if (this.getIsDispCharge1NotSet && !item.isCharge1Done) {
          // 担当者1未入力情報を navigationList に追加する
          this.navigationList.push({
            isBloodMeasure: false,
            chargeNo: 1,
            bedDispOrder: bedDispOrder,
            class: "bed-alert no-charge1",
            bedName: item.bedName
          });
        }
        if (item.bpMeasureNotDone) {
          // 血圧測定未実施情報を navigationList に追加する
          this.navigationList.push({
            isBloodMeasure: true,
            bedDispOrder: bedDispOrder,
            class: "bed-alert no-blood-measure",
            bedName: item.bedName
          });
        }

        // ソート
        // 順序1: 血圧測定未実施情報を先に表示
        // 順序2: ベッドマスタ表示順
        // 順序3: 担当者１→担当者２
        this.navigationList.sort((a, b) => {
          if (a.isBloodMeasure !== b.isBloodMeasure) {
            if (a.isBloodMeasure) return -1;
            if (b.isBloodMeasure) return 1;
          }
          if (a.bedDispOrder !== b.bedDispOrder) {
            if (a.bedDispOrder < b.bedDispOrder) return -1;
            if (a.bedDispOrder > b.bedDispOrder) return 1;
          }
          if (a.chargeNo && b.chargeNo && a.chargeNo !== b.chargeNo) {
            if (a.chargeNo < b.chargeNo) return -1;
            if (a.chargeNo > b.chargeNo) return 1;
          }
          return 0;
        });
      }
    },

    // ベッドマスタ取得
    async getMstBed() {
      const res = await ApiHelper.get("/mstInfo/mstBed", {
        facility_cd: this.getFacilityCd,
        is_disp: 1,
        is_del: 0
      });
      return res.data;
    },

    // Windowの高さからメインコンポーネント領域の高さを算出
    calculateContentHeight() {
      const wh = this.windowHeight;
      const cfh = Array.prototype.slice
        .call(getScopedElementsByClassName("large-display-footer-content", this.$el || null))
        .shift().clientHeight;

      this.contentHeight = wh - cfh;
    },
    // Windowの幅からナビゲーションバーのチップ領域の幅を算出し、非表示の場合件数表示
    calculateContentWidth() {
      // 非表示カウンターの制御
      let hideCounter = getScopedElementById("hide-counter", this.$el || null);
      hideCounter.style.display = "none";

      // 非表示チップ件数の初期化
      this.hideChipsCount = 0;

      // 計算用変数
      const iconsWidth = 96;                                                                     // 右下のアイコンの横幅(48px*2)
      const hideCounterWidth = 91;                                                               // 非表示カウンターの横幅
      const chipAreaWidth = this.windowWidth - iconsWidth;                                       // チップが表示できる領域
      const chipElemWidth = Number(getScopedElementById("chip-area", this.$el || null)?.getBoundingClientRect?.().width || 0);  // チップ親要素の領域

      // チップ親要素の領域がチップが表示できる領域以上のとき、非表示件数表示を行う
      if (chipElemWidth >= chipAreaWidth) {
        let displayChipsWidthTotal = 0;     // 表示中チップの合計横幅
        let displayChipsCount = 0;          // 表示中チップ数の合計

        // 表示中チップ数の合計を求める
        const chips = getScopedElementsByClassName("bed-alert", this.$el || null);
        for (let i = 0; i < chips.length; i++) {
          if (displayChipsWidthTotal + chips[i].getBoundingClientRect().width < chipAreaWidth - hideCounterWidth) {
            displayChipsWidthTotal += chips[i].getBoundingClientRect().width;
            displayChipsCount++;
          }
        }
        this.hideChipsCount = chips.length - displayChipsCount;

        hideCounter.style.display = "block";
      }
    },
    /**
     * 入退室患者情報一覧の定期取得を開始する
     */
    startPolling() {
      this.intervalObj = setInterval(() => {
        this.loadData(true);
      }, this.refreshInterval);
    },
    /**
     * 入退室患者情報一覧の定期取得を停止する
     */
    endPolling() {
      // console.log("[LargeDisp] polling end.");
      clearInterval(this.intervalObj);
    },
    changeViewMode() {
      this.isStandardViewMode = !this.isStandardViewMode;
    },
    moveStatusList() {
      // 治療状況リストへ遷移
      this.goSpecifiedView("status-list");
    },
    /**
     * 施設設定マスタから更新間隔を取得し、ポーリング開始する
     */
    async refreshVal() {
      let data = await getMstFacilitySettingValue(this.getFacilityCd, STATUS_LARGE_AUTO_SETTING);
      if (data.status == 200) {
        if (data.data) {
          this.refreshInterval = data.data * 1000;
        } else {
          this.refreshInterval = 10000;
        }
      } else if (data.status == 400) {
        getErrorMessage("StatusListLargeDispMainComponent.vue", "startPolling", { response: data });
        this.refreshInterval = 10000;
      }
      /* 自動更新サインアウトフラグ取得 */
      await initForceSignOutFlag("status-list/large-display/setForceSignOutFlag", STATUS_LARGE_FORCE_SIGNOUT);
      // ポーリング開始
      this.startPolling();
    },
    updateFooterVisibility(isVisible) {
      const footerMenu = getFooterMenuElement(this.$el || null);
      if (footerMenu) {
        footerMenu.style.display = isVisible ? "block" : "none";
        EventBus.$emit("footerLayoutChanged", {
          height: isVisible ? footerMenu.clientHeight : 0,
          isExpanded: false
        });
      }
    },
  },
  watch: {
    windowHeight() {
      this.$nextTick(() => {
        this.calculateContentHeight();
      });
    },
    windowWidth() {
      this.$nextTick(() => {
        this.calculateContentWidth();
      });
    }
  },
  beforeMount() {
    this.loadData();
  },
  async created() {
    this.setIsDispCharge1NotSet(this.getFacilityCd);
    this.setIsDispCharge2NotSet(this.getFacilityCd);

    // URLダイレクト対応
    // 画面遷移パラメータ取得
    const queryParameters = this.getQueryParameters();

    // モード2(2段組み)指定時
    if (queryParameters.MODE === "2") {
      this.isStandardViewMode = false;
    }
    // クエリパラメータをクリアする
    this.setQueryParameters({});

    this.mstBed = await this.getMstBed();
  },
  mounted() {
    this.updateFooterVisibility(false);
    // フロートメニューを非表示
    this.setIsDispFloatMenu(false);
    // サイドメニュー、サイドメニュー開閉ボタンを非表示
    this.setIsDispSidebarBtn(false);
    this.$nextTick(() => {
      this.calculateContentHeight();
    });

    getScopedElementsByClassName("content-container", this.$el || null)[0].style.width =
      "100%";
    const contentBox = getScopedElementsByClassName("content-box", this.$el || null)[0];
    if (contentBox) contentBox.style.width = "100%";
    // 更新間隔を取得し、ポーリング開始
    this.refreshVal();
  },
  update() {
    this.$nextTick(() => {
      this.calculateContentHeight();
    });
  },
  beforeUnmount() {
    // polling用setIntervalのクリア
    this.endPolling();
    
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  unmounted() {
    this.updateFooterVisibility(true);
    // フロートメニューを表示
    this.setIsDispFloatMenu(true);
    // サイドメニュー、サイドメニュー開閉ボタンを表示
    this.setIsDispSidebarBtn(true);
  }
};
</script>
<style scoped>
.large-display-main-content-area {
  display: flex;
  flex-direction: column;
}
.large-display-main-content {
  overflow-x: auto;
}
.flex-container {
  display: flex;
  justify-content: space-between;
  flex-direction: row;
  align-items: center;
  height: 100%;
}
.flex-btn-area {
  display: flex;
  margin: 0 0 0 auto;
}
/* 最下部エリア*/
.large-display-footer-content {
  height: auto;
  z-index: 2;
}
img.img-icon {
  display: block;
  cursor: pointer;
  height: 3em;
  margin-left: 3px;
}
.bed-alert {
  padding: 5px;
  margin: 2px 3px;
  border-radius: 5px;
  border: 2px solid white;
  white-space: nowrap;
}
.bed-alert.no-charge1 {
  background: skyblue;
}
.bed-alert.no-charge2 {
  background: lightgreen;
}
.bed-alert.no-blood-measure {
  background: orange;
}

@media print {
  .large-display-main-content {
    zoom: 0.5;
    height: auto;
  }
}
</style>
