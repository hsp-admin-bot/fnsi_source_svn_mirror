/**
 * 治療状況リスト（大画面） MainContent
 */
<template>
  <table class="multi-column">
    <td>
      <div class="pat-count-region">
        <table class="puncture-area">
          <tr>
            <td class="count-label">穿刺待ち</td>
            <td class="pat-count">{{puncWait}}</td>
            <td class="mei">名</td>
          </tr>
        </table>
      </div>
      <div class="pat-list" :style="patListHeightStyles">
        <table class="pat-list-table">
          <pat-row
            v-for="(dispItem,no) in beforeTreatList"
            :key="'before' + no"
            :dispItem="dispItem"
            :dispIsSmallFont="dispIsSmallFont"
          ></pat-row>
        </table>
      </div>
    </td>
    <td>
      <div class="pat-count-region">
        <table class="return-area">
          <tr>
            <td class="count-label">返血待ち</td>
            <td class="pat-count">{{returnWait}}</td>
            <td class="mei">名</td>
          </tr>
        </table>
      </div>
      <div class="pat-list" :style="patListHeightStyles">
        <table class="pat-list-table">
          <pat-row
            v-for="(dispItem,no) in afterTreatList"
            :key="'after' + no"
            :dispItem="dispItem"
            :dispIsSmallFont="dispIsSmallFont"
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
            v-for="(dispItem,no) in nowTreatList"
            :key="'now' + no"
            :dispItem="dispItem"
            :dispIsSmallFont="dispIsSmallFont"
          ></pat-row>
        </table>
      </div>
    </td>
  </table>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
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
      infoText: ""
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
    dispIsSmallFont() {
      if (this.nowList.length > 0 && this.afterList.length > 0) {
        return true;
      }
      return false;
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
        .call(document.getElementsByClassName("large-display-footer-content"))
        .shift().clientHeight;
      const prh = Array.prototype.slice
        .call(document.getElementsByClassName("pat-count-region"))
        .shift().clientHeight;

      this.patListHeight = wh - cfh - prh - 15;
    }
  },
  props: {},
  watch: {
    windowHeight() {
      this.$nextTick(() => {
        this.calculateContentHeight();
      });
    }
  },
  beforeMount() {},
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
  created() {},
  beforeDestroy() { },
  destroyed() { }
};
</script>

<style scoped>
.component-container {
  display: flex;
  flex-wrap: wrap;
  flex-direction: row;
}
.multi-column {
  display: flex;
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
.puncture-area {
  background-color: #0066ff;
  color: white;
  text-align: center;
  width: 100%;
  table-layout: fixed;
  border-radius: 20px;
  height: 11em;
}
.return-area {
  background-color: #ff66ff;
  color: white;
  text-align: center;
  width: 100%;
  table-layout: fixed;
  border-radius: 20px;
  height: 11em;
}
.count-label {
  font-size: 3.2em;
  vertical-align: top;
}
.pat-count {
  font-size: 8em;
}
.mei {
  font-size: 4em;
  vertical-align: bottom;
}
.info {
  height: 100%;
  font-size: 2em;
  border: solid 2px gray;
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
