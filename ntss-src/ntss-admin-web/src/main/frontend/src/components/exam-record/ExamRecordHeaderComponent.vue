/**
 * 検査結果一覧用ヘッダ
 */
<template>
  <v-card>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header'>
        <v-ons-col class='condition-search-col'>
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <v-ons-col>
          <div class="filter-area"></div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'exam-record-header-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="handlePopoverPosthide"
    >
      <div style="margin:10px;">
        <!-- 表示条件切替 -->
        <v-ons-row class="condition-row">
          <div class="ntss-button-group">
            <input
              id="show-result-display"
              type="radio"
              class="identification"
              name="viewDayType"
              value="1"
              @click="changeDayType(1);"
              :checked="isShow"
            />
            <label for="show-result-display" class="label first-of-type">最新結果日</label>
            <input
              id="show-exam-display"
              type="radio"
              class="identification"
              name="viewDayType"
              value="2"
              @click="changeDayType(2);"
              :checked="!isShow"
            />
            <label for="show-exam-display" class="label last-of-type">最新検査日</label>
          </div>
        </v-ons-row>
        <!-- 最新結果表／検査日選択 -->

        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>検査日開始</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center' style="white-space: nowrap;">
            <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
            <!-- <input
              input-id='examDateSt'
              name='examDateSt'
              type='date'
              float
              model-event="change"
              class="ntss-input-date ntss-custom-input"
              v-model='localCondition.examDateSt'
              v-rules="'date_format:yyyy-MM-dd'"/>
              <common-calendar v-model="localCondition.examDateSt" /> -->
              <!--#9621:文字サイズを変更すると文字が見切れる Start-->
            <date-input
              input-id="examDateSt"
              name="examDateSt"
              model-event="change"
              class="ntss-input-date ntss-custom-input"
              style="width:auto"
              v-model="localCondition.examDateSt"
              @handleClearInput="localCondition.examDateSt = ''"
            />
            <!--#9621:文字サイズを変更すると文字が見切れる End-->
            <common-calendar v-model="localCondition.examDateSt" />
            <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>検査日終了</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center' style="white-space: nowrap;">
            <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
            <!-- <input
              input-id='examDateEd'
              name='examDateEd'
              type='date'
              float
              model-event="change"
              class="ntss-input-date ntss-custom-input"
              v-model='localCondition.examDateEd'
              v-rules="'date_format:yyyy-MM-dd'" /> -->
            <!--#9621:文字サイズを変更すると文字が見切れる Start-->
            <date-input
              input-id="examDateEd"
              name="examDateEd"
              model-event="change"
              class="ntss-input-date ntss-custom-input"
              style="width:auto"
              v-model="localCondition.examDateEd"
              @handleClearInput="localCondition.examDateEd = ''"
            />
            <!--#9621:文字サイズを変更すると文字が見切れる End-->
            <common-calendar v-model="localCondition.examDateEd" />
            <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>患者ID列表示</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-switch input-id="switchPatId" v-model="localCondition.viewPatId"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>最終検査日列表示</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-switch input-id="switchExamDate" v-model="localCondition.viewExamDate"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>検査セット</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-select input-id='examSetCd' v-model="localCondition.examSetCd">
              <option :value="defaultSelect"></option>
              <option v-for="(option, index) in getExamSetNameList" :key="index" :value="option.examSetCd">
                {{ option.examSetName }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class='clear btn2-cancel' @click='dialogClear'>クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class='ok btn3-normal' :disabled="!canSave" @click='dialogOk'>OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { EventBus } from "@/compat/vue/event-bus.js";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import commonSearchArea from "@/components/common/CommonSearchArea";
import PopoverMixin from "@/components/PopoverMixin";
import { EXAM_RECORD } from "@/constants/defaultSettingConstants";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { makeDefaultCondition, findExamSet } from "@/functions/exam-record/ExamRecordFunctions";
import dayjs from "@/compat/date/dayjs";
//#5590 2023/04/19 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/19 ×を常に表示するように修正 張博 end

export default {
  mixins: [PopoverMixin],

  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    //#5590 2023/04/19 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/19 ×を常に表示するように修正 張博 end
  },
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      // 抽出条件
      localCondition: {
        examSetCd: -1,
        viewDayType: 1, // NOTE: 1:最新結果日、 2:最新検査日
        examDateSt: "",
        examDateEd: "",
        viewPatId: false,
        viewExamDate: false,
      },
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("exam-record/list", [
      "getComponentInitialized",
      "getCondition",
      "getExamSetNameList",
    ]),
    ...mapGetters("account-edit", [
      "getDefaultSetting",
    ]),
    defaultSelect: () => -1,
    /**
     * OKボタンがクリックできるかどうか.
     */
    canSave() {
      return this.validationErrors.length === 0;
    },
    /** 表示条件の状態 */
    isShow() {
      return this.localCondition.viewDayType === 1 ? true : false;
    },
  },
  methods: {
    ...mapActions("exam-record/list", [
      "setHeaderComponentInitialized",
      "setCondition",
      "examSetNameList",
      "setSortNameList",
      "setExamSetNameList",
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
      "storeReset",
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
    ]),
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    handlePopoverPosthide(event) {
      if (this.popoverVisible) {
        // 背景クリックで閉じられる場合
        this.setStoredCondition();
      }
      this.popoverPosthide(event);
    },
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.popoverTarget = event;

      // 検索条件にstoreの情報をセット
      this.setStoredCondition();
      // 表示
      this.popoverVisible = true;
    },
    setStoredCondition() {
      const condition = this.getCondition;
      this.localCondition.viewDayType = condition.viewDayType;
      this.localCondition.examDateSt = condition.examDateSt;
      this.localCondition.examDateEd = condition.examDateEd;
      this.localCondition.viewPatId = condition.viewPatId;
      this.localCondition.viewExamDate = condition.viewExamDate;
      this.localCondition.examSetCd = condition.examSetCd;
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検索条件クリアして画面を更新
      this.setDefaultCondition();
      this.dialogOk();
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      // 画面を閉じる
      this.popoverVisible = false;
      this.search();
    },
    // -----------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // -----------------------------------------
    search() {
      // 検査日が変更された場合
      const chgFlg = (
        (this.localCondition.examDateSt != this.getCondition.examDateSt)
        || (this.localCondition.examDateEd != this.getCondition.examDateEd)
        || (this.localCondition.viewDayType != this.getCondition.viewDayType));

      // 抽出条件登録
      this.setCondition(this.localCondition);
      this.setConditionList();

      // 検索条件の内容で画面を更新
      EventBus.$emit("filterExamRecord", chgFlg);
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      const condObj = this.localCondition;
      const examSet = findExamSet(condObj.examSetCd, this.getExamSetNameList);
      const makeInfo = (visible, text, name) => ({ visible, listItem: { name, text } });
      const isValidDate = value => value !== "" && value != null;
      const cnvDateFmt = (value) => {
        if (isValidDate(value)) {
          return value.replace(/-/g, "/");
        } else {
          return value;
        }
      };
      this.conditionList = [
        { visible: true, listItem: { text: condObj.viewDayType === 1 ? "最新結果日" : "最新検査日"}},
        makeInfo(isValidDate(condObj.examDateSt), cnvDateFmt(condObj.examDateSt), "検査日開始"),
        makeInfo(isValidDate(condObj.examDateEd), cnvDateFmt(condObj.examDateEd), "検査日終了"),
        makeInfo(condObj.viewPatId, "患者ID列表示"),
        makeInfo(condObj.viewExamDate, "検査日列表示"),
        makeInfo(examSet, examSet && examSet.examSetName, "検査セット"),
      ].reduce((condList, info) => {
        if (info.visible) {
          condList.push(info.listItem);
        }
        return condList;
      }, []);
    },
    // -----------------------------------------
    // 個人設定で登録した初期値をStoreに登録する
    // -----------------------------------------
    setDefaultCondition() {
      const initialDefault = makeDefaultCondition();
      this.localCondition.viewDayType = initialDefault.viewDayType;
      this.localCondition.examDateSt = initialDefault.examDateSt;
      this.localCondition.examDateEd = initialDefault.examDateEd;
      this.localCondition.viewPatId = initialDefault.viewPatId;
      this.localCondition.viewExamDate = initialDefault.viewExamDate;
      this.localCondition.examSetCd = initialDefault.examSetCd;
      // デフォルト設定
      const defaultCondition = this.getDefaultSetting[EXAM_RECORD.KEY_NAME];
      if (defaultCondition) {
        // デフォルト設定が存在する場合は適用
        if (defaultCondition[EXAM_RECORD.KEY_NAME_VIEW_DAY_TYPE] != null) {
          this.localCondition.viewDayType = defaultCondition[EXAM_RECORD.KEY_NAME_VIEW_DAY_TYPE];
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_START_DATE] != null) {
          this.localCondition.examDateSt = calcTargetDate(defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_START_DATE]);
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_END_DATE] != null) {
          this.localCondition.examDateEd = calcTargetDate(defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_END_DATE]);
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_VIEW_PAT_ID] != null) {
          this.localCondition.viewPatId = defaultCondition[EXAM_RECORD.KEY_NAME_VIEW_PAT_ID];
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_VIEW_EXAM_DATE] != null) {
          this.localCondition.viewExamDate = defaultCondition[EXAM_RECORD.KEY_NAME_VIEW_EXAM_DATE];
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_SET_CD] != null) {
          this.localCondition.examSetCd = defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_SET_CD];
        }
      }
    },
    initCondition() {
      // デフォルト設定を反映する
      this.setDefaultCondition();
      // 以前に保存した検索条件が存在する場合は反映する
      if (this.getCondition?.viewDayType != null) {
        this.localCondition.viewDayType = this.getCondition.viewDayType;
      }
      if (this.getCondition?.examDateSt != null) {
        this.localCondition.examDateSt = this.getCondition.examDateSt;
      }
      if (this.getCondition?.examDateEd != null) {
        this.localCondition.examDateEd = this.getCondition.examDateEd;
      }
      if (this.getCondition?.examSetCd != null) {
        this.localCondition.examSetCd = this.getCondition.examSetCd
      }
      if (this.getCondition?.viewPatId != null) {
        this.localCondition.viewPatId = this.getCondition.viewPatId;
      }
      if (this.getCondition?.viewExamDate != null) {
        this.localCondition.viewExamDate = this.getCondition.viewExamDate;
      }

      if (this.$route.params.startDate !== undefined) {
        // 掲示板から検査結果一覧に遷移した場合
        if (this.$route.params.startDate != null) {
          const startDateMoment = dayjs(this.$route.params.startDate);
          this.localCondition.examDateSt = startDateMoment.format("YYYY-MM-DD");
          this.localCondition.examDateEd = (this.$route.params.endDate != null)
            ? dayjs(this.$route.params.endDate).format("YYYY-MM-DD")
            : startDateMoment.add(3, "month").format("YYYY-MM-DD");
        } else if (this.$route.params.endDate === null) {
          const todayMoment = dayjs();
          this.localCondition.examDateEd = todayMoment.format("YYYY-MM-DD");
          this.localCondition.examDateSt = todayMoment.subtract(3, "month").format("YYYY-MM-DD");
        }
      }

      // 検索条件を保存しなおして表示に反映する
      this.setCondition(this.localCondition);
      this.setConditionList();
    },
    startInitialize() {
      this.setHeaderComponentInitialized(false);
    },
    finishInitialize() {
      this.setHeaderComponentInitialized(true);
      if (this.getComponentInitialized) {
        // すでにExamRecordComponentの初期化も完了している場合は検索を実行する
        EventBus.$emit("filterExamRecord", true);
      }
    },
    // 表示条件の切替処理
    changeDayType(dayType) {
      this.localCondition.viewDayType = dayType;
    },
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  created() {
    this.startInitialize();
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
    // 遷移先が検査結果系画面以外：listを初期化
    this.storeReset();
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
  },
  async mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
    this.setLoadingScreenVisible(true);

    // 検査セットデータ生成処理：
    await this.examSetNameList({
      facilityCd: this.getFacilityCd,
      selectedPatId: this.selectedPatId
    });
    // 検査セットソート順データセット処理
    await this.setSortNameList({
      facilityCd: this.getFacilityCd,
      selectedPatId: this.selectedPatId
    });

    // 検索条件の初期設定
    this.initCondition();

    this.setLoadingScreenVisible(false);
    this.finishInitialize();
  }
};
</script>
<style scoped>
input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}

/* ボタングループのスタイル定義 */
.ntss-button-group {
  width: 100%;
  font-size: 1.5em;
  display: flex;
}

.label:hover {
  background-color: #31a9ee; /* マウスオーバー時の背景色を指定する */
}

.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  width: 100%; /* ボックスの横幅を指定する */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  background-color: #87cefa; /* 背景色を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  margin: 15px 0px;
  white-space: nowrap;
}
.first-of-type {
  border-radius: 10px 0 0 10px;
  margin: 2px 0px 2px 5px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
  margin: 2px 5px 2px 0px;
}
ons-popover :deep(.popover) {
  width: 400px;
}

.exam-record-header-popover :deep(.popover) {
  width: 400px;
}
</style>
