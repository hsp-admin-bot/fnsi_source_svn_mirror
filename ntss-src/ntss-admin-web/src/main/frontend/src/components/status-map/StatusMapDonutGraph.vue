/**
 * ドーナツグラフ(治療状況マップ)
 */
<template>
  <div class="donut-main">
    <!-- del #6712「治療状況マップの詳細画面にゴミが表示される」について、対応する。 dengshen start -->
    <!-- <ons-progress-circular class="graph" :value="percent"></ons-progress-circular>-->
    <!-- del #6712「治療状況マップの詳細画面にゴミが表示される」について、対応する。 dengshen end -->
<!--    <div class="percent">{{ percent }}%</div>-->
    <div class="percent">{{ percent }}</div>
  </div>
</template>

<script>

export default {
  /** 表示項目 */
  SHOW_DATA_CLASS: [
    58  /** 進捗率 */
  ],
  computed: {
    /**
     * 率(%)
     */
    persent() {
      if (this.percent) {
        return this.percent;
      } else {
        return 0;
      }
    }
  },
  props: ["percent"],





};
</script>

<style scoped>
ons-progress-circular.graph {
  position: absolute;
  /* add FNSI-389進捗率位置修正 付 start */
  left: 80%;
  top: 0%;
  width: 100%;
  height: 100%;
  /* add FNSI-389進捗率位置修正 付 end */
}
.percent {
  position: absolute;
  top: 50%;
  /* add FNSI-389進捗率位置修正 付 start */
  /* left: 53%; */
  left: 130%;
  /* add FNSI-389進捗率位置修正 付 end */
  transform: translateY(-50%) translateX(-50%);
  -webkit-transform: translateY(-50%) translateX(-50%);
  margin: auto;
}
* :deep(.progress-circular__background) {
  stroke-width: 10%;
}

* :deep(.progress-circular__secondary) {
  stroke-width: 10%;
}

* :deep(.progress-circular__primary) {
  stroke-width: 10%;
}
</style>
