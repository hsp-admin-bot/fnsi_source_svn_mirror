<!-- 透析状況確認画面 -->
<template>
  <div class='main-content-area'>
    <!-- コンテンツ枠 -->
    <div class='dialysis-status-area' :style="areaHeightStyle">
      <!-- 血圧、脈拍 -->
      <div class="blood-pressure-area">
        <div class="status-name-label" style="background-color: steelblue;">
          <label>最高血圧</label>
        </div>
        <div class="status-label" style="">
          <label class="value">{{ maxBloodPressure }}</label>
          <label class="unit">mmHg</label>
        </div>
        <div class="status-name-label" style="background-color: steelblue;">
          <label>最低血圧</label>
        </div>
        <div class="status-label" style="">
          <label class="value">{{ minBloodPressure }}</label>
          <label class="unit">mmHg</label>
        </div>
        <div class="status-name-label" style="background-color: darkolivegreen;">
          <label>脈拍</label>
        </div>
        <div class="status-label" style="">
          <label class="value">{{ pulseRate }}</label>
          <label class="unit">回/分</label>
        </div>
      </div>
      <!-- 状態表示 -->
      <div class="treatment-time-area">
        <!-- 治療方法 -->
        <div class="treatment-method">
          <div class="status-name-label" style="background-color: steelblue;">
            <label>治療方法</label>
          </div>
          <label class="value">{{ treatMethodName }}</label>
        </div>
        <!-- 残り時間 -->
        <div style="margin-top: 10px;">
          <div class="time-progress-bar" :style="areaWidthStyle">
            <!-- widthのパーセントで進捗を表示 -->
            <div class="time-progress-bar-rate" :style="timeRatioWidthStyle"></div>
            <!-- 残り時間 -->
            <div class="remain-time">
              <label>残り時間</label><label style="margin-left: 20px;">{{ remainTimeText }}</label>
            </div>
          </div>
        </div>
        <!-- 総除水量 -->
        <div class="status-name-label" style="background-color: steelblue; margin-top: 15px;">
          <label>総除水量</label>
        </div>
        <div class="total-water-removal">
          <!-- 総除水量進捗 -->
          <div>
            <div class="container-mouth">
              <div class="container-mouth-left"></div>
              <div class="container-mouth-right"></div>
            </div>
            <div class="container-body">
              <!-- 1段5%のstepで容器に水が溜まっていく -->
              <div class="water-area">
                <label class="value">{{ waterRemovalRate }}%</label>
                <div class="water-fragment" v-for="key in reteCount" :key="key"></div>
              </div>
            </div>
          </div>
          <!-- 総除水量(L) -->
          <div class="value-label">
            <label class="value">{{ dewateringIntegration }}</label>
            <label class="unit">L</label>
          </div>
        </div>

      </div>
    </div>
    <!-- 下部ボタン枠 -->
    <div class="bottom-buttons">
      <v-ons-button class="button process-button" style="" >病院に連絡</v-ons-button>
      <v-ons-button class="button process-button" style="" @click="next">透析を終える</v-ons-button>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters, mapMutations } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end

// 最高血圧
const maxBloodPressureKey = 90;
// 最低血圧
const minBloodPressureKey = 91;
// 脈拍
const pulseRateKey = 93;
// 残り時間(透析完了)(分)
const remainTimeKey = 4;
// 経過時間(分)
const progressTimeKey = 1;
// 除水目標値
const waterRemovalTargetKey = 32;
// 除水積算値
const dewateringIntegrationKey = 5;

export default {
  data() {
    return {
      // 最高血圧
      maxBloodPressure: 0,
      // 最低血圧
      minBloodPressure: 0,
      // 脈拍
      pulseRate: 0,
      // 治療方法名
      treatMethodName: "",
      // 残り時間
      remainTimeText: "00:00",
      // 経過時間(%)
      treatmentTimeRatio: 0,
      // 除水積算値
      dewateringIntegration: 0,
      // 除水率
      waterRemovalRate: 0,
      // タイマーID
      timerId: 0,
      // 表示領域の高さ
      areaHeight: 700,
      // 表示領域の幅
      areaWidth: 550
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", [ "getStateUserAccountInfo" ]),
    ...mapGetters("pat-info", {
      headerPatId: "selectedPatId"
    }),

    // 除水率を5%区切りで表示する枠の個数
    reteCount() {
      return Math.floor(this.waterRemovalRate / 5);
    },
    // 表示領域の高さをCSS変数を利用して書き換える
    areaHeightStyle() {
      return { "height": `${this.areaHeight}px` };
    },
    // 表示領域の幅をCSS変数を利用して書き換える
    areaWidthStyle() {
      return { "width": `${this.areaWidth}px` };
    },
    // 経過時間(%)
    timeRatioWidthStyle() {
      return { "width": `${this.treatmentTimeRatio}%` };
    }
  },
  methods: {
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("pat-home-dialysis", [
      "getMonitoringData",
    ]),
    ...mapActions("pat-info", [ "selectPat" ]),
    ...mapMutations("pat-info", {
      setPat: "setSelectedPat",
      setIsLoadingPat: "setIsLoadingPat"
    }),

    // 患者情報ヘッダーに表示する患者を設定する
    async setHeaderPatId(patId) {
      this.setIsLoadingPat(true);
      this.setPat(null);
      await this.selectPat(patId).catch(() => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatHomeDialysisStatusComponent.vue', 'setHeaderPatId', '患者選択失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        // TODO: エラー処理検討
        throw new Error("[PatHomeDialysisStatusComponent.vue]setHeaderPatId(): 患者選択失敗");
      });
      this.setIsLoadingPat(false);
    },
    // ウインドウ変更時の高さ、幅を調整
    calculateSize() {
      // ヘッダーの高さ
      const header = document.getElementsByClassName("header");
      let headerHeight = 0;
      if (header.length !== 0) {
        // フッター分 35px
        headerHeight = header[0].offsetHeight + 35;
      }
      // 下部ボタン部の高さ
      const bottomButtons = document.getElementsByClassName("bottom-buttons");
      // 下部ボタン部のmargin：15px
      let bottomButtonsHeight = 15;
      if (bottomButtons.length !== 0) {
        bottomButtonsHeight += bottomButtons[0].offsetHeight;
      }
      // main-content-area の margin：5px
      this.areaHeight = this.windowHeight - headerHeight - bottomButtonsHeight - 5;

      // 血圧、脈拍の幅
      const bloodPressure = document.getElementsByClassName("blood-pressure-area");
      let bloodPressureWidth = 0;
      if (bloodPressure.length !== 0) {
        bloodPressureWidth += bloodPressure[0].offsetWidth;
      }
      // 画面幅に応じてmargin補正
      const clientWidth = document.documentElement.clientWidth;
      if (clientWidth > 550) {
        bloodPressureWidth += 80;
      } else {
        bloodPressureWidth += 60;
      }
      this.areaWidth = clientWidth - bloodPressureWidth;
    },
    // 初回読み込み
    firstLoad() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      ApiHelper.get(`/pat_home_dialysis/monitor/${this.getStateUserAccountInfo.patId}`)
        .then(response => {
          // 治療方法
          if (response.data.ind_treatment_name !== null) {
            this.treatMethodName = response.data.ind_treatment_name;
          } else {
            this.treatMethodName = "---";
          }

          const monitorData = JSON.parse(response.data.monitor_data);
          // monitorDataがnullだった場合は --- を表示して処理を抜ける
          if (monitorData === null) {
            this.updateMonitorData({});
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
            return;
          }

          this.updateMonitorData(monitorData);

          // 状態が 4:排液済 以外の場合はポーリングを開始
          if (response.data.rst_dialysis_state !== "4") {
            this.startPolling();
          }

          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatHomeDialysisStatusComponent.vue', 'firstLoad', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          // 共通ローダー:表示終了
          this.resetLoadingScreenVisibleCount();
          throw error;
        });

    },
    // ポーリング処理
    polling() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      ApiHelper.get(`/pat_home_dialysis/monitor/${this.getStateUserAccountInfo.patId}`)
        .then(response => {
          const monitorData = JSON.parse(response.data.monitor_data);
          // monitorDataがnullだった場合は --- を表示して処理を抜ける
          if (monitorData === null) {
            this.updateMonitorData({});
            return;
          }

          this.updateMonitorData(monitorData);

          // 状態が 4:排液済 の場合は後体重入力画面に遷移する
          if (response.data.rst_dialysis_state === "4") {
            this.next();
          }

          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatHomeDialysisStatusComponent.vue', 'polling', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          // 共通ローダー:表示終了
          this.resetLoadingScreenVisibleCount();
          throw error;
        });

    },
    // 表示データの更新
    updateMonitorData(monitorData) {
      // 最高血圧
      if (monitorData[maxBloodPressureKey] === void 0) {
        this.maxBloodPressure = "---"
      } else {
        this.maxBloodPressure = monitorData[maxBloodPressureKey];
      }

      // 最低血圧
      if (monitorData[minBloodPressureKey] === void 0) {
        this.minBloodPressure = "---"
      } else {
        this.minBloodPressure = monitorData[minBloodPressureKey];
      }

      // 脈拍
      if (monitorData[pulseRateKey] === void 0) {
        this.pulseRate = "---"
      } else {
        this.pulseRate = monitorData[pulseRateKey];
      }

      // 経過時間(分)           ＊＊＊＊    ０：０～２３：５９
      // 残り時間(透析完了)(分)  ＊＊：＊＊  ０：０～２３：５９
      if (monitorData[remainTimeKey] === void 0 || monitorData[progressTimeKey] === void 0) {
        this.remainTimeText = "---"
        this.treatmentTimeRatio = 0;
      } else {
        this.remainTimeText = monitorData[remainTimeKey];

        // 経過時間(%)の計算
        const progressTime = ('000' + monitorData[progressTimeKey]).slice(-4);
        const pTimeH = Number(progressTime.substring(0, 2)) * 60;
        const pTimeM = Number(progressTime.substring(2, 4));
        const rTimeH = Number(this.remainTimeText.substring(0, 2)) * 60;
        const rTimeM = Number(this.remainTimeText.substring(3, 5));
        // %へ変換
        this.treatmentTimeRatio = Math.floor(((pTimeH + pTimeM) / (pTimeH + pTimeM + rTimeH + rTimeM)) * 100);
      }

      // 除水率の計算
      if (!isNaN(monitorData[dewateringIntegrationKey]) && !isNaN(monitorData[waterRemovalTargetKey])) {
        // 除水積算値
        this.dewateringIntegration = Math.round(monitorData[dewateringIntegrationKey]);
        // 除水目標値
        const waterRemovalTarget = monitorData[waterRemovalTargetKey];
        // 除水率
        this.waterRemovalRate = Math.round((monitorData[dewateringIntegrationKey] / waterRemovalTarget) * 100);
      } else {
        this.dewateringIntegration = "---";
        this.waterRemovalRate = 0;
      }
    },
    // ポーリングを開始
    startPolling() {
      this.timerId = setInterval(this.polling, 60000);
    },
    // ポーリングを終了
    endPolling() {
      clearInterval(this.timerId);
    },
    // 後体重入力画面に遷移
    next() {
      this.$router.push({ name: "pat-home-dialysis-weight-after" });
    }
  },
  watch: {
  },
  created() {
    // 戻るボタンの抑制
    history.pushState(null, null, null);
  },
  mounted() {
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("更新中・・・");
    // 画面リサイズ時のイベントを設定
    window.addEventListener("resize", this.calculateSize);
    this.calculateSize();

    // 患者IDがない場合は何もしない
    if (this.getStateUserAccountInfo.patId !== null) {
      // 初期処理
      this.firstLoad();
    }

    // 患者情報ヘッダーの設定
    if (this.headerPatId === null && this.getStateUserAccountInfo.patId !== null) {
      this.setHeaderPatId(this.getStateUserAccountInfo.patId);
    }

  },
  updated() {
  },
  beforeDestroy() {
    // ポーリングクリア
    this.endPolling();
  },
  destroyed() {
    // 画面を閉じたときにイベントを除去
    window.removeEventListener("resize", this.calculateSize);
  }
};
</script>

<style scoped>
.main-content-area {
  min-width: 200px;
  overflow-x: hidden;
}
.dialysis-status-area {
  display: flex;
  align-items: stretch;
  overflow-x: auto;
}
.status-name-label {
  color: white;
  font-size: 3em;
  width: 8rem;
  text-align: center;
  border-radius: 8px;
  border: 5px solid darkslateblue;
}
.status-label {
  padding-top: 5px;
  padding-bottom: 5px;
  border-radius: 8px;
  border: 2px solid lightblue;
  width: auto;
  display: flex;
  flex-direction: column;
  flex-wrap: wrap;
  justify-content: center;
  text-align: center;
}
.status-label > .value {
  font-size: 6em;
}
.status-label > .unit {
  font-size: 2em;
}
.treatment-time-area {
  margin-left: 40px;
}
.treatment-method {
  display: flex;
  align-items: center;
}
.treatment-method > .value {
  margin-left: 10px;
  font-size: 4em;
}
.time-progress-bar {
  height: 50px;
  position: relative;
  border: 3px solid darkslateblue;
  display: flex;
  align-items: center;
}
.time-progress-bar-rate {
  height: 100%;
  background-color: forestgreen;
}
.remain-time {
  position: absolute;
  width: 100%;
  text-align: center;
  padding: 3px;
  font-size: 3.5em;
  text-shadow: 1px 1px white, -1px -1px white, -1px 1px white, 1px -1px white;
}
.total-water-removal {
  margin-top: 15px;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
}
.container-mouth {
  display: flex;
  justify-content: flex-end;
  width: 320px;
}
.container-mouth-right {
  height: 30px;
  width: 310px;
  border-right: 10px solid;
}
.container-body {
  height: 340px;
  width: 300px;
  border-top: 2px dashed red;
  border-right: 10px solid;
  border-bottom: 10px solid;
  border-left: 10px solid;
  margin: auto;
  border-radius: 0px 0px 20px 20px;
  position: relative;
}
.water-area {
  width: 100%;
  text-align: center;
  position: absolute;
  bottom: 0;
}
.water-area > .value {
  font-size: 5em;
}
.water-fragment {
  height: 13px;
  background-color: lightblue;
  width: 99%;
  border: 2px solid steelblue;
  border-radius: 8px;
}
.total-water-removal > .value-label {
  display: flex;
  align-items: baseline;
}
.total-water-removal > .value-label > .value {
  margin-left: 10px;
  font-size: 8em;
}
.total-water-removal > .value-label > .unit {
  margin-left: 10px;
  font-size: 4em;
}
.bottom-buttons {
  display: flex;
  justify-content: space-between;
  margin-top: 15px;
}
.process-button {
  font-size: 2.5em;
  font-weight: bolder;
  text-shadow: 2px 2px 1px dimgrey;
  width: 12.5rem;
  border-radius: 8px;
  padding-top: 10px;
  padding-bottom: 10px;
}
.container-mouth-left {
  transform: skewX(-150deg);
  border-right: 10px solid;
  height: 30px;
  width: 0px;
  margin-left: -8px;
}

/* 横幅550px を下回ったらスタイル変更 */
@media screen and (max-width: 550px) {
  .status-name-label {
    font-size: 1.5em;
    width: 5rem;
    border: 3px solid darkslateblue;
  }
  .status-label > .value {
    font-size: 3em;
  }
  .status-label > .unit {
    font-size: 1em;
  }
  .treatment-time-area {
    margin-left: 20px;
  }
  .treatment-method > .value {
    font-size: 2em;
  }
  .remain-time {
    font-size: 1.5em;
  }
  .container-mouth {
    width: 200px;
  }
  .container-mouth-right {
    width: 200px;
  }
  .container-body {
    height: 200px;
    width: 180px;
  }
  .water-area > .value {
    font-size: 3em;
  }
  .water-fragment {
    height: 6px;
  }
  .total-water-removal > .value-label > .value {
    font-size: 5em;
  }
  .process-button {
    font-size: 2em;
    font-weight: unset;
    width: 10rem;
  }
}

/* 横幅1366px を上回ったらスタイル変更 */
@media screen and (min-width: 1366px) {
  .status-name-label {
    font-size: 5em;
    width: 15rem;
  }
  .status-label > .value {
    font-size: 10em;
  }
  .status-label > .unit {
    font-size: 3em;
  }
  .treatment-method > .value {
    margin-left: 15px;
    font-size: 7em;
  }
  .time-progress-bar {
    height: 70px;
  }
  .remain-time {
    font-size: 5em;
  }
  .water-area > .value {
    font-size: 7em;
  }
  .total-water-removal {
    margin-top: 50px;
  }
  .total-water-removal > .value-label > .value {
    margin-left: 15px;
    font-size: 12em;
  }
  .bottom-buttons {
    height: 90px;
  }
  .process-button {
    font-size: 5em;
    line-height: unset;
    width: 22rem;
  }
}
</style>
