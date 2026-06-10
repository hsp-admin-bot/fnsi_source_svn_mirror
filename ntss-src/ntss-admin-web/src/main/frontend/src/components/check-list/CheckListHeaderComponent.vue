/**
 * チェックリストページ用ヘッダ
 */
<template>
  <v-card>
    <div class="header-item">
      <v-ons-row class="mark-leftmost-header">
        <v-ons-col vertical-align="center">
          <div class="ntss-button-group">
            <input
              type="radio"
              class="identification"
              name="identification"
              value="1"
              id="input-treat"
              @click="changeDisplayName(true);"
              :checked="getIsDisplayTreatingMode"
              :disabled="getIsDataLoading"
            />
            <label for="input-treat" class="label first-of-type">治療中</label>
            <input
              type="radio"
              class="identification"
              name="identification"
              value="2"
              id="input-date"
              @click="changeDisplayName(false);"
              :checked="!getIsDisplayTreatingMode"
              :disabled="getIsDataLoading"
            />
            <label for="input-date" class="label last-of-type">指定日</label>
          </div>
        </v-ons-col>
        <v-ons-col class="condition-search-col">
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <v-ons-col>
          <div class="filter-area"></div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div style="margin:10px;">
        <v-ons-row class="condition-row" v-show="!getIsDisplayTreatingMode">
          <v-ons-col width="40%" vertical-align="center">
            <label>治療日</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <!-- mod FNSI-横展開 日付のチェックの追加対応_チェックリスト機能分 周 start -->
            <!-- <div class="flex-align-center">
              <input
                class="ntss-input-date ntss-control-size"
                id="treatDate"
                name="treatDate"
                type="date"
                model-event="change"
                v-model="localCondition.treatDate"
                v-validate="'required|date_format:yyyy-MM-dd'"
              >
              <common-calendar v-model="localCondition.treatDate" />
            </div> -->
            <div class="flex-align-center">
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
              <!-- <input
                class="ntss-input-date ntss-control-size"
                id="treatDate"
                name="treatDate"
                type="date"
                v-model="localCondition.treatDate"
                data-vv-scope="localCondition"
                v-validate="'required|date_format:yyyy-MM-dd'"
              > -->
              <!--#10715:日付IF修正Start（必須追加+param修正）-->
              <date-input
                class="ntss-input-date ntss-control-size"
                id="treatDate"
                name="treatDate"
                :isRequired="true"
                v-model="localCondition.treatDate"
                @handleClearInput="localCondition.treatDate = null"
                data-vv-scope="localCondition"
              />
              <!--#10715:日付IF修正End（必須追加+param修正）-->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
              <common-calendar v-model="localCondition.treatDate" />
            </div>
            <span class="error-message">{{
              errors.first("localCondition.treatDate")
            }}</span>
            <!-- mod FNSI-横展開 日付のチェックの追加対応_チェックリスト機能分 周 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row v-show="errors.has('treatDate')">
          <td>
            <p
              v-show="errors.has('treatDate')"
              class="error-message"
            >{{ errors.first('treatDate') }}</p>
          </td>
        </v-ons-row>
        <v-ons-row class="condition-row" v-if="getIsDisplayTreatingMode">
          <v-ons-col width="40%" vertical-align="center">
            <label>次患者</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select input-id="nextPat" v-model="localCondition.nextPat">
              <option
                v-for="option in nextPatList"
                :key="option.no"
                :value="option.no"
              >{{ option.name }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row" v-show="!getIsDisplayTreatingMode">
          <v-ons-col width="40%" vertical-align="center">
            <label>クール</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select input-id="kurCd" v-model="localCondition.kurCd">
              <option :value="defaultSelect">すべて</option>
              <option
                v-for="option in getMstKurSelector"
                :key="option.length"
                :value="option.code"
              >{{ option.name }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>ベッドグループ</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select input-id="bedGroupCd" v-model="localCondition.bedGroupCd">
              <option :value="defaultSelect">すべて</option>
              <option
                v-for="(option) in getMstBedGroupList"
                :key="option.length"
                :value="option.roomBedGroupCd"
              >{{ option.roomBedGroupName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>治療日列表示</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-switch input-id="switch" v-model="localCondition.viewTreatDate"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>画面自動更新</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-switch input-id="switch" v-model="localCondition.isAutoReload"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>凡例の表示</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-switch input-id="switch" v-model="localCondition.isShowUsageGuide"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <div class="condition-row" style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <!-- mod FNSI-横展開 画面デザイン_チェックリスト機能分 周 start -->
            <!-- <v-ons-button class="clear" @click="dialogClear">クリア</v-ons-button> -->
            <v-ons-button class="clear btn2-cancel" @click="dialogClear">クリア</v-ons-button>
            <!-- mod FNSI-横展開 画面デザイン_チェックリスト機能分 周 end -->
          </div>
          <div style="float:right;">
            <!-- mod FNSI-横展開 画面デザイン_チェックリスト機能分 周 start -->
            <!-- <v-ons-button class="ok" :disabled="!canSave" @click="dialogOk">OK</v-ons-button> -->
            <v-ons-button class="ok btn3-normal" :disabled="!canSave" @click="dialogOk">OK</v-ons-button>
            <!-- mod FNSI-横展開 画面デザイン_チェックリスト機能分 周 end -->
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { EventBus } from "@/eventBus.js";
import { mapGetters, mapActions } from "vuex";
import { deepCopy } from "@/functions/common/CommonFunctions";
import moment from "moment";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import commonSearchArea from "@/components/common/CommonSearchArea";
import PopoverMixin from "@/components/PopoverMixin";
//add FNSI修正 redmine4255 房 start
import { CHECK_LIST } from "@/constants/defaultSettingConstants";
//add FNSI修正 redmine4255 房 end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
//#5590 2023/04/20 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/20 ×を常に表示するように修正 張博 end

export default {
  mixins: [PopoverMixin],
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 end
  },
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      // 抽出条件
      localCondition: {
        bedGroupCd: -1,
        nextPat: 0,
        treatDate: "",
        kurCd: -1,
        viewTreatDate: false,
        isAutoReload: false,
        isShowUsageGuide: false
      },
      nextPatList: [
        { no: 0, name: "表示しない" },
        { no: 1, name: "現クール" },
        { no: 2, name: "次クール" }
      ],
      isClicking: false,
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("check-list/list", [
      "getCondition",
      "getMstKurSelector",
      "getMstBedGroupList",
      "getIsDisplayTreatingMode",
      "getIsDataLoading"
    ]),
    //add FNSI修正 redmine4255 房 start
    ...mapGetters("account-edit", ["getDefaultSetting"]),
    //add FNSI修正 redmine4255 房 end
    defaultSelect: () => -1,
    treatDate() {
      //#10715:日付IF修正Start
      let res_treatment = this.getCondition.treatDate ? this.getCondition.treatDate.replace(/-/g, "/") : null;
      return res_treatment;
      //#10715:日付IF修正End
    },
    /**
     * データの編集があるかどうか.
     */
    isChanged() {
      return !(
        JSON.stringify(this.localCondition) ===
        JSON.stringify(this.getCondition)
      );
    },
    /**
     * OKボタンがクリックできるかどうか.
     */
    canSave() {
      return this.isChanged && this.$validator.errors.items.length === 0;
    },
    //add FNSI修正 redmine4255 房 start
    // -----------------------------------------
    // デフォルト設定
    // -----------------------------------------
    defaultCondition() {
      // デフォルト設定を store から取得
      const defaultCondition = deepCopy(this.getDefaultSetting[CHECK_LIST.KEY_NAME]);
      if (!(!defaultCondition || Object.keys(defaultCondition).length === 0)) {
        // 初期設定がある場合に値を返す
        return defaultCondition;
      } else {
        return null;
      }
    },
    //add FNSI修正 redmine4255 房 end
  },
  methods: {
    ...mapActions("check-list/list", [
      "fetchKur",
      "fetchKurBedGroup",
      "changeIsDisplayTreatingMode",
      "setCondition",
      "setIsDataLoading"
    ]),
    //FNSI-修正 #5407 xugj add start
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    //FNSI-修正 #5407 xugj add end
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    findKurSelectorByCode(kurCd) {
      return (this.getMstKurSelector || []).find(
        selector => `${selector.code}` === `${kurCd}`
      );
    },
    findNextPatOption(nextPat) {
      return this.nextPatList.find(option => `${option.no}` === `${nextPat}`);
    },
    // 治療中/指定日の表示切替を変更
    changeDisplayName(isDisplayTreatingMode) {
      if (this.getIsDataLoading) {
        return;
      }
      this.changeIsDisplayTreatingMode(isDisplayTreatingMode).then(() => {
        // 治療中/指定日で画面を更新
        EventBus.$emit("dataUpdate");
        this.setConditionList();
      });
    },
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.popoverTarget = event;

      // 検索条件にstoreの情報をセット
      const sCondition = deepCopy(this.getCondition);
      this.localCondition.bedGroupCd = sCondition.bedGroupCd;
      this.localCondition.nextPat = sCondition.nextPat;
      this.localCondition.treatDate = sCondition.treatDate;
      this.localCondition.kurCd = sCondition.kurCd;
      this.localCondition.viewTreatDate = sCondition.viewTreatDate;
      this.localCondition.isAutoReload = sCondition.isAutoReload;
      this.localCondition.isShowUsageGuide = sCondition.isShowUsageGuide;
      // 表示
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検索条件クリアして画面を更新
      this.localCondition.bedGroupCd = -1;
      this.localCondition.nextPat = 0;
      let today = moment(new Date());
      this.localCondition.treatDate = today.format("YYYY-MM-DD");
      this.localCondition.kurCd = -1;
      this.localCondition.viewTreatDate = false;
      this.localCondition.isAutoReload = false;
      this.localCondition.isShowUsageGuide = false;
      // 画面を閉じる
      this.popoverVisible = false;
      this.search();
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      // 画面を閉じる
      this.popoverVisible = false;
      this.search();
    },
    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    search() {
      let chgFlg = false;
      // 治療中(次患者が変更された場合)
      if (this.localCondition.nextPat != this.getCondition.nextPat) {
        chgFlg = true;
      }
      // 指定日(治療日が変更された場合)
      if (this.localCondition.treatDate != this.getCondition.treatDate) {
        chgFlg = true;
      }
      // 抽出条件登録
      this.setCondition(deepCopy(this.localCondition));

      // 検索条件の内容で画面を更新
      EventBus.$emit("filterCheckList", chgFlg);
      this.setConditionList();
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      const condObj = this.getCondition;
      // 治療日
      if (!this.getIsDisplayTreatingMode && condObj.treatDate !== '') {
        condList.push({ name:"治療日", text:this.treatDate });
      }
      // 次患者
      if (this.getIsDisplayTreatingMode) {
        const nextPatOption = this.findNextPatOption(condObj.nextPat);
        condList.push({ name:"次患者", text:nextPatOption ? nextPatOption.name : "" });
      }
      // ベッドグループ
      if (condObj.bedGroupCd !== -1) {
        const bedGroup = this.getMstBedGroupList.find(bg => bg.roomBedGroupCd === condObj.bedGroupCd);
        if(bedGroup) {
          condList.push({ name:"ベッドグループ", text: bedGroup.roomBedGroupName });
        }
        else {
          this.localCondition.bedGroupCd = -1;
          condList.push({ name:"ベッドグループ", text: "すべて" });
          // 抽出条件登録
          this.setCondition(deepCopy(this.localCondition));
        }
      }
      else {
      	condList.push({ name:"ベッドグループ", text: "すべて" });
      }
      // add #11285 機能帳票の印刷情報対応② 高 start
      sessionStorage.setItem('roomBedGroupNameCheckList', JSON.stringify(condList.find(item => item.name === "ベッドグループ").text));
      // add #11285 機能帳票の印刷情報対応② 高 end
      // クール
      if (!this.getIsDisplayTreatingMode && `${condObj.kurCd}` !== "-1") {
        const kur = this.findKurSelectorByCode(condObj.kurCd);
        const text = kur ? kur.name : "";
        condList.push({ name:"クール", text });
      }
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
      const kurItem = condList.find(item => item.name === "クール");
      sessionStorage.setItem('kurGroupNameStatusList', JSON.stringify(kurItem ? kurItem.text : ""));
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
      // 治療日列表示
      if (condObj.viewTreatDate) {
        condList.push({ text:"治療日列表示" });
      }
      // 画面自動更新
      if (condObj.isAutoReload) {
        condList.push({ text:"画面自動更新" });
      }
      // 凡例の表示
      if (condObj.isShowUsageGuide) {
        condList.push({ text:"凡例の表示" });
      }
      this.conditionList = condList;
    }
  },
  // add FNSI-横展開 日付のチェックの追加対応_チェックリスト機能分 周 start
  watch:{
    "localCondition.treatDate": {
      handler() {
        this.$validator.reset("localCondition");
        setTimeout(() => {
          this.$validator.validate("localCondition.treatDate");
        }, 0);
      }
    }
  },
  async created() {
    //FNSI-修正 #5407 xugj add start
    // 共通ローダー:表示開始
    this.setLoadingScreenMessage("処理中・・・");
    this.setLoadingScreenVisible(true);
    //FNSI-修正 #5407 xugj add end
    // 抽出条件初期化
    //mod FNSI修正 redmine4255 房 start
    if (this.getCondition) {
      this.localCondition = deepCopy(this.getCondition);
    } else {
      // 画面遷移パラメータ取得
      const queryParameters = this.getQueryParameters();
      let treatDate = moment(new Date()).format("YYYY-MM-DD");
      if (queryParameters.DATE) {
        treatDate = queryParameters.DATE;
        this.changeDisplayName(false);
      }
      this.setQueryParameters({});

      //mod FNSI修正 redmine5023 房 start
      if (this.defaultCondition) {
        this.localCondition.bedGroupCd = this.defaultCondition.bedGroupCd;
        this.localCondition.nextPat = this.defaultCondition[CHECK_LIST.KEY_NAME_NEXT_PAT_GROUP];
        this.localCondition.viewTreatDate = this.defaultCondition.viewTreatDate;
        this.localCondition.isAutoReload = this.defaultCondition.isAutoReload;
        this.localCondition.isShowUsageGuide = this.defaultCondition.isShowUsageGuide;
        // mod 不具合 #6265 dou start
        // this.localCondition.kurCd = -1;
        this.localCondition.kurCd = this.defaultCondition.kurCd;
        this.localCondition.dispMode = this.defaultCondition.dispMode;
        // mod 不具合 #6265 dou end
        this.localCondition.treatDate = treatDate;
        this.setCondition(deepCopy(this.localCondition));
      } else {
        this.setCondition({
          bedGroupCd: -1,
          nextPat: 0,
          treatDate: treatDate,
          kurCd: -1,
          viewTreatDate: false,
          isAutoReload: false,
          isShowUsageGuide: false
        });
      }
      //mod FNSI修正 redmine5023 房 end
    }
    //mod FNSI修正 redmine4255 房 end
    await Promise.allSettled([
      // クール詳細一覧情報取得
      this.fetchKur(this.getFacilityCd),
      // ベッドグループ情報取得
      this.fetchKurBedGroup(),
    ]);
    this.setConditionList();
    //FNSI-修正 #5407 xugj add start
    this.setLoadingScreenVisible(false);
    //FNSI-修正 #5407 xugj add end
  },
  mounted () {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
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
}

.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  width: 35%; /* ボックスの横幅を指定する */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  margin: 15px 0px;
  white-space: nowrap;
}
.first-of-type {
  border-radius: 10px 0 0 10px;
  margin-left: 5px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
  margin-right: 5px;
}
</style>
