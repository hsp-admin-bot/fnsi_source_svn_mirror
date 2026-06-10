
<template>
  <div>
    <pat-header-component
      v-if="isPatHeaderView && !isMeasureHistoryHeaderView"
      :isWeightScale="true"
      :isCannotSwipe="true"
      class="weight-mode-header-content"
    />
    <wheel-chair-header-component
      v-else-if="!isPatHeaderView && !isMeasureHistoryHeaderView"
      class="test2"
    />
    <measure-history-header-component
      v-else-if="isMeasureHistoryHeaderView"
    />
    <pat-header-component
      v-else
      :isWeightScale="true"
      :isCannotSwipe="true"
      class="weight-mode-header-content"
    />
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import patHeader from "@/components/header-contents/PatHeader";
import wheelChairHeader from "@/components/master-maintenance/mst-wheel-chair/MstWheelChairHeaderComponent";
import measureHistoryHeader from "@/components/measure-history/MeasureHistoryHeaderComponent";
import { EventBus } from "@/eventBus.js";
import moment from "moment";

export default {
  components: {
    "pat-header-component": patHeader,
    "wheel-chair-header-component": wheelChairHeader,
    "measure-history-header-component": measureHistoryHeader
  },
  computed: {
    ...mapGetters("send-condition/weight", ["getWeightMode"]),
    isPatHeaderView() {
      // 体重計モード画面
      const isWheelChairPage = this.$route.fullPath.startsWith(
        "/weight/wheelchair"
      );
      return !isWheelChairPage;
    },
    // 体重計測定記録画面
    isMeasureHistoryHeaderView() {
      return this.$route.fullPath.startsWith("/weight-mode/measure-history");
    },
  },
  methods: {
    ...mapActions("multi-modal", ["showPatSearch"]),
    ...mapActions("account-edit", ["setDispMenuBar"]),
    ...mapActions("send-condition/scale", [
      "setSelectOrdNo",
      "setInputPatId",
      "setPatId",
      "setMeasuredValue"
    ]),
    ...mapActions("send-condition/schedule", [
      "fetchScheduleByHospPatId",
      "findPatId",
      "setScheduleList",
      "setFilteringHospPatId",
      "findMeasuredValue"
    ]),
    ...mapActions("send-condition/weight", ["setWeightMode"]),
    ...mapActions("send-condition/scale/audio", ["initAudio"]),
    /**
     * 患者スケジュール検索して画面遷移、複数スケジュールの場合は選択モーダル表示
     * @param {Object} payload
     * @param {String} payload.hospPatId 院内患者ID
     */
    searchHospPatIdSchedule(payload) {
      // 条件セット
      const today = moment(new Date(), "YYYYMMDD").format("YYYYMMDD");
      let param = {
        hospPatId: payload.hospPatId,
        treatDate: today,
        isPast: false
      };
      // 入力された院内患者IDに該当するスケジュールを取得
      this.fetchScheduleByHospPatId(param).then(async response => {
        if (!response || !response.data) {
          // 応答データなし
          return;
        }
        const scheduleCount = response.data.length;
        if (scheduleCount === 0) {
          // スケジュールがない場合
          // 患者が存在するかどうかチェック
          this.findPatId({
            hospPatId: param.hospPatId
          }).then(res => {
            if (res.data !== null && res.data !== "") {
              // 患者ID登録
              this.setInputPatId(param.hospPatId);
              // add FNSI-次回同じ患者を検索する場合測定値保存する 徐 start
              this.findMeasuredValue({
                patId: res.data
              }).then( abs => {
                this.setMeasuredValue(abs.data);
              });
              // add FNSI-次回同じ患者を検索する場合測定値保存する 徐 end
              this.setPatId(res.data).then(() => {
                // スケジュール無し患者
                this.setSelectOrdNo({
                  ordNo: null,
                  ordNo2: null
                }).then(() => {
                  // 選択した患者で条件送信画面画面へ遷移
                  EventBus.$emit("loadSendConditionView");
                });
              });
            }
          });
        } else if (scheduleCount === 1) {
          // スケジュールが1つの場合
          this.setInputPatId(param.hospPatId);
          // 患者情報ヘッダ用に患者情報登録
          this.setPatId(response.data[0].patId).then(() => {
            this.setSelectOrdNo({
              ordNo: response.data[0].ordNo,
              ordNo2: null
            }).then(() => {
              // 選択した患者で条件送信画面画面へ遷移
              EventBus.$emit("loadSendConditionView");
            });
          });
        } else {
          // スケジュールが複数ある場合
          // 取得したスケジュールをセット
          this.setInputPatId(param.hospPatId);
          await Promise.all([
            this.setScheduleList(response.data),
            this.setFilteringHospPatId(param.hospPatId)
          ]);
          // 患者検索モーダル表示
          this.showPatSearch();
        }
      });
    }
  },
  mounted() {
    this.initAudio();
  },
  created() {
    EventBus.$on("searchHospPatIdSchedule", this.searchHospPatIdSchedule);
  },
  beforeDestroy() {
    EventBus.$off("searchHospPatIdSchedule");

    // 体重計画面から抜ける際、体重計モードだったらモードを解除する（）
    if (this.getWeightMode.isWeightMode) {
      if (this.getWeightMode.defaultDispMenu === 1) {
        // フッター表示
        this.setDispMenuBar(1);
      }

      this.setWeightMode({
        isWeightMode: false,
        defaultDispMenu: null
      });
    }

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  watch: {}
};
</script>
