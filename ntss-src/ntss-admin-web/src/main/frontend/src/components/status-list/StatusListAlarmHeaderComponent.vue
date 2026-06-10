/**
* 治療状況リスト（警報・報知一覧）用ヘッダ
*/
<template>
  <div class="header-item">
    <div style="height: inherit;">
      <v-ons-row class="mark-leftmost-header" style="flex-wrap: nowrap; width: calc(100% - 90px); overflow-x: auto;">
        <v-ons-col vertical-align="center">
          <div class="flex-align-center" style="font-size: 1.5em;">
            <!--mod FNSI-改修内容日付のチェックの追加対応。 江 start-->
            <!-- <input
              class="ntss-input-date"
              type="date"
              name="date"
              style="width:85%; margin-left:10px;"
              v-model="searchDate"
            /> -->
            <!--mod FNSI-改修内容日付のチェックの追加対応。 江 end-->
            <!--#10715:日付IF修正+param修正Start-->
            <date-input
                  :classes="'data-datetime ntss-input-date ntss-control-size w-100'"
                  v-model="searchDate"
                  :isRequired="true"
                  max="9999-12-31"
                  style="margin-left:5px;"
            />
            <!--#10715:日付IF修正＋param修正End-->
            <common-calendar v-model="searchDate" />
          </div>
        </v-ons-col>
        <v-ons-col>
          <div style="display:flex;" id="deviceEdgeFilter">
            <div style="padding:2px;">
              <input
                type="checkbox"
                class="alarm-check"
                id="deviceEdgeEmergency"
                @click="checkedCheckbox($event);"
                v-bind:checked="condition.deviceEdgeEmergency"
              />
              <label for="deviceEdgeEmergency" class="filterLabel">警</label>
            </div>
            <div style="padding:2px;">
              <input
                type="checkbox"
                class="info-check"
                id="deviceEdgeDefect"
                @click="checkedCheckbox($event);"
                v-bind:checked="condition.deviceEdgeDefect"
              />
              <!-- mod FNSI-文字変更 徐 start -->
              <label for="deviceEdgeDefect" class="filterLabel">報</label>
              <!-- mod FNSI-文字変更 徐 end -->
            </div>
          </div>
          <div style="display: flex;">
            <div style="padding:2px;">
              <input
                type="radio"
                class="all"
                id="deviceEdgeAll"
                @click="checkedRadio($event);"
                v-bind:checked="condition.deviceEdgeAll"
              />
              <label for="deviceEdgeAll" class="filterLabel filterLabel2">ALL</label>
            </div>
          </div>
        </v-ons-col>
        <v-ons-col>
          <div style="display:flex; height: 100%; align-items: center; color: var(--ntss-list-body-color);">
            <label style="font-size:38px;">{{this.getFilterListCount}}</label>
            <label style="margin-left: 10px; margin-top: 8px; font-size:20px;">件</label>
          </div>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<!-- スクリプト処理 -->
<script>
/* eslint-disable */
import { mapGetters, mapActions, mapMutations } from "vuex";
import moment from "moment";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
//#10715:日付IF修正Start
import DateInput from "@/components/common/DateInput.vue";
//#10715:日付IF修正End
// add #9371 治療状況リストにおける警報・報知の動作不良 dou start
import { EventBus } from "@/eventBus";
// add #9371 治療状況リストにおける警報・報知の動作不良 dou end
export default {
  components: {
    //#10715:日付IF修正Start
    "common-calendar": commonCalender,
    "date-input": DateInput,
    //#10715:日付IF修正End
  },
  data() {
    return {
      condition: {
        // del #9371 治療状況リストにおける警報・報知の動作不良 dou start
        // searchOccurDate: "",
        // del #9371 治療状況リストにおける警報・報知の動作不良 dou end
        deviceEdgeEmergency: false,
        deviceEdgeDefect: false,
        deviceEdgeAll: true
      },
      filterListCount: 0
    };
  },
  computed: {
    ...mapGetters("status-list/list", ["gridCount", "getFilterListCount", "getStatusList", "getStatusFlg"
      // add #9371 治療状況リストにおける警報・報知の動作不良 dou start
      , "getOccurDate"]),
    // add #9371 治療状況リストにおける警報・報知の動作不良 dou end
    ...mapGetters("user", ["getFacilityCd"]),
    searchDate: {
      get() {
        // mod #9371 治療状況リストにおける警報・報知の動作不良 dou start
        /* mod #6006 by zhangruixue 2023-05-31 --start */
        // if (this.getStatusFlg ==1 && this.getStatusList && this.getStatusList.treatDate) {
        //   const date = moment(this.getStatusList.treatDate).format("YYYY-MM-DD")
        //   this.changeOccurDate(date);
        //   this.condition.searchOccurDate = date
        //   this.setStatusFlg(0);
        //   return this.condition.searchOccurDate;
        // }
        /* mod #6006 by zhangruixue 2023-05-31 --start */
        // else if (this.condition.searchOccurDate !== "") {
        //   return this.condition.searchOccurDate;
        if (this.getOccurDate) {
          return this.getOccurDate;
          // mod #9371 治療状況リストにおける警報・報知の動作不良 dou end
        } else {
          const today = moment(new Date()).format("YYYY-MM-DD");
          // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
          this.changeOccurDate(today);
          // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
          // del #9371 治療状況リストにおける警報・報知の動作不良 dou start
          // this.condition.searchOccurDate = today;
          // del #9371 治療状況リストにおける警報・報知の動作不良 dou end
          return today;
        }
      },
      set: function(value) {
        this.changeOccurDate(value);
        // del #9371 治療状況リストにおける警報・報知の動作不良 dou start
        // this.condition.searchOccurDate = value;
        // del #9371 治療状況リストにおける警報・報知の動作不良 dou end
        // フィルタリング
        this.dateSearch(value);
        // this.search();
      }
    }
  },
  methods: {
    // add #9371 治療状況リストにおける警報・報知の動作不良 dou start
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    // add #9371 治療状況リストにおける警報・報知の動作不良 dou end
    ...mapActions("status-list/list", [
      "fetchHistoryList",
      "fetchAlarmSettingList",
      "changeOccurDate",
      "setCondition"
    ]),
    ...mapMutations("status-list/list", {
      setStatusList: "setStatusList" ,
      setStatusFlg: "setStatusFlg",
    }),
    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    search() {
      this.fetchHistoryList(this.condition);
    },
    async dateSearch(values) {
      if (values === "") {
        return;
      }
      const info = {
        facilityCd: this.getFacilityCd,
        isClear: true,
        occurDate: moment(values).format("YYYYMMDD")
      };
      await this.fetchAlarmSettingList(info);
      this.search();
    },
    checkedCheckbox(event) {
      // 選択された要素の属性:idをイベントから取得
      const checkId = event.currentTarget.id;
      if (checkId === "deviceEdgeEmergency") {
        this.condition.deviceEdgeEmergency = event.currentTarget.checked;
      } else if (checkId === "deviceEdgeDefect") {
        this.condition.deviceEdgeDefect = event.currentTarget.checked;
      }
      // 全選択のラジオボタンを未選択に設定
      this.condition.deviceEdgeAll = false;
      // チェックボックスが全てOFFになった場合の対応
      if (
        !this.condition.deviceEdgeEmergency &&
        !this.condition.deviceEdgeDefect
      ) {
        // 全選択のラジオボタンをONに設定
        this.condition.deviceEdgeAll = true;
      }
      // storeに条件を登録
      this.setCondition(this.condition);
      // フィルタリング
      this.search();
      //this.findHistoryList(this.condition);
    },
    checkedRadio(event) {
      this.condition.deviceEdgeEmergency = false;
      this.condition.deviceEdgeDefect = false;
      this.condition.deviceEdgeAll = event.currentTarget.checked;
      // storeに条件を登録
      this.setCondition(this.condition);
      // フィルタリング
      this.search();
    },
    // add #9371 治療状況リストにおける警報・報知の動作不良 dou start
    async init() {
      this.setLoadingScreenVisible(true);
      if (this.getStatusFlg == 1) {
        this.condition.deviceEdgeEmergency = true;
        this.condition.deviceEdgeDefect = false;
        this.condition.deviceEdgeAll = false;
      } else if (this.getStatusFlg == 2) {
        this.condition.deviceEdgeEmergency = false;
        this.condition.deviceEdgeDefect = true;
        this.condition.deviceEdgeAll = false;
      } else {
        this.condition.deviceEdgeEmergency = false;
        this.condition.deviceEdgeDefect = false;
        this.condition.deviceEdgeAll = true;
      }
      this.setCondition(this.condition);
      // フィルタリング
      await this.search();
      this.setLoadingScreenVisible(false);
    }
  },
  created() {
    EventBus.$off("initAlarm", this.init);
    EventBus.$on("initAlarm", this.init);
    EventBus.$off("autoFiltering", this.search);
    EventBus.$on("autoFiltering", this.search);
  },
  destroyed() {
    EventBus.$off("initAlarm", this.init);
    EventBus.$off("autoFiltering", this.search);
  },
  // add #9371 治療状況リストにおける警報・報知の動作不良 dou end
  watch:{
    // getFilterListCount: {
    //
    // }
  }
};
</script>

<style scoped>
.checkfilter {
  /* ブロックレベル要素化する */
  display: block;
  /* テキストのセンタリングを指定する */
  text-align: center;
  /* 行の高さを指定する */
  line-height: 20px;
  margin: 5px 0px 0px 0px;
  width: 20px;
  /* フォント色 */
  color: #333333;
}
.alarm-check + label {
  /* 背景色 */
  background: #ff6666;
  /* フォント色 */
  color: #333333;
  /* 枠線 */
  border: solid 1px #cccccc;
}
.alarm-check:checked + label {
  /* 枠線 */
  border: solid 1px #333333;
}
.info-check + label {
  /* 背景色 */
  background: #ffff66;
  /* フォント色 */
  color: #333333;
  /* 枠線 */
  border: solid 1px #cccccc;
}
.info-check:checked + label {
  /* 枠線 */
  border: solid 1px #333333;
}
input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
input[type="checkbox"] {
  display: none; /* チェックボックスを非表示にする */
}
.filterLabel2 {
  width: 4.7em;
}
.day-start-date::-webkit-calendar-picker-indicator {
  display: none;
}
</style>
