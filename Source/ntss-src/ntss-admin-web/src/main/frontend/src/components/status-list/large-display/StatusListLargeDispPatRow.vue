<template>
  <tr class="info-bar large-display-row-content">
    <td class="col-indicator col-left-edge">
      <div
        v-show="dispItem.indicator1"
        class="indicator"
        :class="{ done: dispItem.indicator1 }"
      ></div>
    </td>
    <td class="col-indicator">
      <div
        v-show="dispItem.indicator2 || dispItem.bpMeasureNotDone"
        class="indicator"
        :class="{ done: dispItem.indicator2, 'not-done-bp-measure': dispItem.bpMeasureNotDone }"
      ></div>
    </td>
    <td class="col-time" :style="fontSizeStyles">
      <div
        class="time"
        :class="{ 'treat-before': dispItem.isBefore, 'treat-now': dispItem.isNow, 'treat-after': dispItem.isAfter }"
      >
        {{ dispItem.dispTime }}
        <span
          v-if="dispItem.remainMinutes != null"
          class="remain-minutes"
        >({{ dispItem.remainMinutes }})</span>
      </div>
    </td>
    <td class="col-bed-name" :style="fontSizeStyles">{{ dispItem.bedName }}</td>
    <td class="col-icon">
      <div class="icons-div">
        <div class="box-icon">
          <img
            src="img/status-list/kensa.png"
            class="icon"
            :style="{display: dispItem.examScheDispFlg}"
          />
        </div>
        <div class="box-icon">
          <img
            src="img/status-list/mitei.png"
            class="icon"
            :style="{display: dispItem.mediDoneDispFlg}"
          />
        </div>
        <div class="box-icon">
          <img
            src="img/status-list/nyuin.png"
            class="icon"
            :style="{display: dispItem.isHospitalization}"
          />
        </div>
      </div>
    </td>
    <td class="col-pat-name" :style="fontSizeStyles">{{ dispItem.patName }}</td>
    <td class="col-sama">様</td>
  </tr>
</template>

<script>
export default {
  props: {
    dispItem: {
      type: Object,
      required: true,
    },
    dispIsSmallFont: {
      type: Boolean,
      default: false,
    },
  },
  computed: {
    fontSizeStyles() {
      return { "font-size": this.dispIsSmallFont ? "2.5em" : "3em" };
    },
  },
};
</script>

<style scoped>
.info-bar-table {
  width: 100%;
  table-layout: fixed;
  border-collapse: separate;
  border-spacing: 0px;
  border-radius: 12px;
  border: 1px solid #000;
  background-color: black;
  margin-bottom: 2px;
}

.info-bar {
  width: 90%;
  text-align: center;
  vertical-align: middle;
  white-space: nowrap;
}
.cls-yellow1 {
  border-right: 2px solid var(--status-list-large-display-row-color);
  border-left: 6px solid var(--status-list-large-display-row-color);
}
.cls-yellow2 {
  border-right: 6px solid var(--status-list-large-display-row-color);
  border-left: 2px solid var(--status-list-large-display-row-color);
}
.col-left-edge {
  padding-left: 1em;
  border-top-left-radius: 8px;
  border-bottom-left-radius: 8px;
}
.col-indicator {
  width: 1em;
  padding-right: 5px;
}
.indicator {
  height: 3.2em;
  min-width: 3px;
  background-color: var(--status-list-large-display-row-color);
  border-radius: 3px;
}
.done {
  background-color: yellow;
}
@keyframes blink {
  75% {
    opacity: 0;
  }
}
@-webkit-keyframes blink {
  75% {
    opacity: 0;
  }
}
.not-done-bp-measure {
  background-color: #cc0000;
  animation: blink 1s step-end infinite;
  -webkit-animation: blink 1s step-end infinite;
}
.col-time {
  width: 3.8em;
  color: white;
  font-size: 2.4em;
  padding-left: 5px;
}
.time {
  background-color: blue;
  border-radius: 3px;
  padding-left: 3px;
  padding-right: 3px;
  display: flex;
  justify-content: center;
  align-items: baseline;
}
.remain-minutes {
  font-size: 0.53em;
}
.treat-before {
  background-color: #0066ff;
  color: #ffffff;
}
.treat-now {
  background-color: #ffccff;
  color: #000000;
}
.treat-after {
  background-color: #ff66ff;
  color: #ffffff;
}
.col-bed-name {
  text-align: center;
  font-size: 2.4em;
  color: yellow;
}
.col-icon {
  width: 9.6em;
}
.icons-div {
  justify-content: center;
  align-items: center;
  display: flex;
  flex-wrap: wrap;
  width: 9.6em;
}
.box-icon {
  width: 3.2em;
  height: 3.2em;
  text-align: left;
}
.icon {
  height: 3.2em;
}
.col-pat-name {
  color: white;
  font-size: 2.4em;
  text-align: center;
}
.col-sama {
  font-size: 1.6em;
  width: 1.4em;
  color: white;
  text-align: right;
  padding-right: 0.63em;
  border-top-right-radius: 8px;
  border-bottom-right-radius: 8px;
}
</style>
