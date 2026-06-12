/**
 * 治療状況リスト（大画面） MainContent
 */
<template>
  <table>
    <tbody>
      <tr>
        <td class="pat-list-area">
          <div class="pat-list-region">
            <div id="puncture-region-icon" />
            <div class="region-label large-display-label">穿刺</div>
            <div id="return-region-icon" />
            <div class="region-label large-display-label">返血予定</div>
            <div id="returned-region-icon" />
            <div class="region-label large-display-label">返血</div>
          </div>
          <div class="pat-list" :style="patListHeightStyles">
            <table class="pat-list-table">
              <tbody>
                <pat-row
                  v-for="(dispItem, no) in beforeTreatList"
                  :key="'before' + no"
                  :dispItem="dispItem"
                ></pat-row>
                <pat-row
                  v-for="(dispItem, no) in afterTreatList"
                  :key="'after' + no"
                  :dispItem="dispItem"
                ></pat-row>
                <!-- NOTE: 治療中判定が色ではわかりづらければ復活させる
                <tr>
                  <td
                    class="annotation-label"
                    colspan="7"
                    v-if="nowTreatList.length > 0"
                  >-------------------- 以下、治療中 --------------------</td>
                </tr>
                -->
                <pat-row
                  v-for="(dispItem, no) in nowTreatList"
                  :key="'now' + no"
                  :dispItem="dispItem"
                ></pat-row>
              </tbody>
            </table>
          </div>
        </td>

        <td class="info-area">
          <div id="pat-count-area">
            <div class="title large-display-label">穿刺待ち</div>
            <table class="puncture-area">
              <tbody>
                <tr>
                  <td></td>
                  <td colspan="2" class="pat-count">{{puncWait}}</td>
                  <td class="mei">名</td>
                </tr>
              </tbody>
            </table>
            <div class="title large-display-label">返血待ち</div>
            <table class="return-area">
              <tbody>
                <tr>
                  <td></td>
                  <td colspan="2" class="pat-count">{{returnWait}}</td>
                  <td class="mei">名</td>
                </tr>
              </tbody>
            </table>
            <div class="title large-display-label">お知らせ</div>
          </div>
          <div class="info" :style="infoHeightStyles">
            <div v-for="(data, idx) in info" :key="idx">
              <div class="info-title large-display-label">{{ data.title }}</div>
              <div class="info-content large-display-label">{{ data.content }}</div>
            </div>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import { getScopedElementsByClassName, getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import PatRow from "@/components/status-list/large-display/StatusListLargeDispPatRow";

export default {
  components: {
    "pat-row": PatRow
  },
  data() {
    return {
      patListHeight: 0,
      infoHeight: 0,
      intervalObj: undefined,
      infoText: []
    };
  },
  computed: {
    ...mapGetters("status-list/large-display", [
      "beforeTreatList",
      "nowTreatList",
      "afterTreatList",
      "cntPuncWait",
      "cntReturnWait",
      "getInfo"
    ]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    dispPatList() {
      let list = [];
      list.push(this.beforeTreatList);
      list.push(this.afterTreatList);
      list.push(this.nowTreatList);
      // console.log(list);
      return list;
    },
    beforeList() {
      return this.beforeTreatList;
    },
    nowList() {
      return this.nowTreatList;
    },
    afterList() {
      return this.afterTreatList;
    },
    puncWait() {
      return this.cntPuncWait;
    },
    returnWait() {
      return this.cntReturnWait;
    },
    info() {
      return this.getInfo;
    },
    patListHeightStyles() {
      // 高さをCSS変数を利用して書き換え
      return { "max-height": `${this.patListHeight}px` };
    },
    infoHeightStyles() {
      // 高さをCSS変数を利用して書き換え
      return { height: `${this.infoHeight}px` };
    }
  },
  methods: {
    ...mapActions("account-edit", [
      "setIsDispFloatMenu",
      "setIsDispSidebarBtn"
    ]),
    /**
     * 表示する患者一覧データを取得する
     */
    getPatList() {
      let rtnList = [];
      // 透析前
      rtnList.push(this.beforeTreatList);
      // 透析後
      rtnList.push(this.afterTreatList);
      // 透析中
      rtnList.push(this.nowTreatList);

      return rtnList;
    },
    // Windowの高さからメインコンポーネント領域の高さを算出
    calculateContentHeight() {
      const wh = this.windowHeight;
      const cfh = Array.prototype.slice
        .call(getScopedElementsByClassName("large-display-footer-content", this.$el || null))
        .shift().clientHeight;
      const prh = Array.prototype.slice
        .call(getScopedElementsByClassName("pat-list-region", this.$el || null))
        .shift().clientHeight;
      const pch = Number(getScopedElementById("pat-count-area", this.$el || null)?.clientHeight || 0);

      this.patListHeight = wh - cfh - prh - 15;
      if (this.patListHeight < pch + cfh) {
        this.patListHeight = pch + cfh;
      }
      this.infoHeight = wh - cfh - prh - pch;
      if (this.infoHeight < 0) {
        this.infoHeight = 20;
      }
    }
  },

  watch: {
    windowHeight() {
      this.$nextTick(() => {
        this.calculateContentHeight();
      });
    }
  },

  mounted() {
    this.$nextTick(() => {
      this.calculateContentHeight();
    });
  },
  update() {
    this.$nextTick(() => {
      this.calculateContentHeight();
    });
  },

};
</script>

<style scoped>
.component-container {
  display: flex;
  flex-wrap: wrap;
  flex-direction: row;
}
.pat-list-region {
  width: 100%;
  display: flex;
  flex-direction: row;
  margin-top: 0.75em;
}
.region-label {
  font-size: 2.4em;
  margin-top: -1px;
}
#puncture-region-icon {
  background-color: #0066ff;
  border-radius: 5px;
  height: 3.2em;
  width: 3.2em;
}
#return-region-icon {
  background-color: #ffccff;
  border-radius: 5px;
  height: 3.2em;
  width: 3.2em;
  margin-left: 30px;
}
#returned-region-icon {
  background-color: #ff66ff;
  border-radius: 5px;
  height: 3.2em;
  width: 3.2em;
  margin-left: 30px;
}
.pat-list-area {
  margin: 15px 10px 0 10px;
  min-width: 745px;
  vertical-align: top;
}
.pat-list {
  overflow-y: auto;
}
.pat-list-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0px 4px;
}
.pat-list-table tr {
  border-bottom: 2px solid #666;
  border-radius: 3px;
}
.info-area {
  width: 40%;
  margin-top: 15px;
  margin-right: 10px;
  min-width: 370px;
  overflow-x: auto;
  vertical-align: top;
}
.title {
  font-size: 2.4em;
  margin-top: 3%;
}
.puncture-area {
  background-color: #0066ff;
  color: white;
  text-align: center;
  width: 100%;
  table-layout: fixed;
  border-radius: 50px;
  height: 14.4em;
}
.return-area {
  background-color: #ff66ff;
  color: white;
  text-align: center;
  width: 100%;
  table-layout: fixed;
  border-radius: 50px;
  height: 14.4em;
}
.pat-count {
  font-size: 13.6em;
}
.mei {
  font-size: 4em;
  vertical-align: bottom;
}
.info {
  height: 100%;
  font-size: 2em;
  border: solid 2px gray;
  overflow: auto;
  padding-left: 10px;
  padding-top: 5px;
}
.info-title {
  font-weight: bold;
}
.info-content {
  white-space: pre-wrap;
  word-wrap: break-word;
}
.inner-info {
  width: 100%;
  height: 100%;
  background: linear-gradient(315deg, transparent 20px, #fff 20px);
  background-position: bottom right;
  background-repeat: no-repeat;
  position: relative;
}
.inner-info::before {
  content: "";
  display: block;
  background: linear-gradient(315deg, transparent 20px, gray 20px);
  width: 30px;
  height: 30px;
  position: absolute;
  right: 0px;
  bottom: 0px;
}
.main {
  cursor: none;
}
.annotation-label {
  width: 90%;
  text-align: center;
  white-space: nowrap;
  font-size: 2.4em;
}
</style>
