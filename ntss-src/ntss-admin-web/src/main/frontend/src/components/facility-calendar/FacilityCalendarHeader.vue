<template>
  <v-card>
    <div class="header-item">
      <div class="mark-leftmost-header">
        <v-ons-row class="content-area" vertical-align="center" style="flex-wrap: nowrap;">
          <v-ons-col class="condition-search-col custom-search">
            <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)' style="height: calc(6.3em - 10px);"/>
          </v-ons-col>
          <v-ons-col class="custom-button">
            <div class="filter-area">
              <v-ons-button class="create-button btn3-normal" @click="createEvent(null)" :disabled = "!getItemAuthorized('FacilityCalendar', 'default_authority')">
                <p class="style-text-button">新規</p>
                <p class="style-text-button">登録</p>
              </v-ons-button>
              <input
                type="radio"
                name="identification"
                value="1"
                id="input-date"
                class="switch-time-range identification"
                v-model="mode"
              />
              <label for="input-date" class="label switch-time-range-label first-of-type" @click="goFacilityCalendar(1)">日</label>
              <input
                type="radio"
                name="identification"
                value="2"
                id="input-week"
                class="switch-time-range identification"
                v-model="mode"
              />
              <label for="input-week" class="label switch-time-range-label middle-of-type" @click="goFacilityCalendar(2)">週</label>
              <input
                type="radio"
                name="identification"
                value="3"
                id="input-month"
                class="switch-time-range identification"
                v-model="mode"
              />
              <label for="input-month" class="label switch-time-range-label last-of-type" @click="goFacilityCalendar(3)">月</label>
            </div>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
    <!-- 検索条件：入力エリア -->
    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'popover-area']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="handlePopoverPosthide"
    >
      <div class="pop-area">
        <div class="pop-main-area">

          <v-ons-row class="condition-row" style="margin-bottom: unset;">
            <v-ons-col width="40%" vertical-align="center">
              <label>集計件数表示</label>
            </v-ons-col>
            <v-ons-col width="60%" vertical-align="center">
              <v-ons-switch input-id="switch" v-model="searchCondition.viewTotal"></v-ons-switch>
            </v-ons-col>
          </v-ons-row>

          <hr>
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center">
              <label>【施設イベント検索】</label>
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>フリーワード</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <input v-model="searchCondition.freeWord" class="input-area ntss-custom-input" type="text" style="width: 95%;" />
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="condition-row" style="flex-wrap: nowrap;">
            <v-ons-col vertical-align="top" class="pop-title">
              <label>掲載日</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <!-- mod 5849 抽出条件にて治療日を入力せず、クールを入力した際に注意文が表示されない start zhao -->
              <!-- <v-ons-row style="flex-wrap: nowrap;"> -->
              <v-ons-row style="white-space: nowrap;">
              <!-- mod 5849 抽出条件にて治療日を入力せず、クールを入力した際に注意文が表示されない start end -->
                <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
                <!-- <input
                  v-model="searchCondition.noticeStartDate"
                  class="input-area ntss-custom-input"
                  type="date"
                />
                <common-calendar
                  v-model="searchCondition.noticeStartDate"
                  class="calender"
                /> -->
                <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
                <!-- <input
                  v-model="searchCondition.noticeStartDate"
                  class="input-area ntss-custom-input start-date"
                  type="date"
                  @keyup="showStartMsg"
                  @blur="getStartDate"
                /> -->
                 <date-input
                  v-model="searchCondition.noticeStartDate"
                  @handleClearInput="searchCondition.noticeStartDate = null"
                  :classes="'input-area ntss-custom-input start-date ntss-input-date'"
                  @keyup="showStartMsg"
                  @blur="getStartDate"
                />
                <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
                <common-calendar
                  v-model="searchCondition.noticeStartDate"
                  class="calender start-date-comment"
                />
                &nbsp;&nbsp;〜&nbsp;&nbsp;
                <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
                <!--add FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
                 <span class="error-message" v-if="showErrorStartDate" style="display: block;">
                   {{this.msgDiaLog}}
                 </span>
                 <!--add FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="condition-row" style="flex-wrap: nowrap;">
            <v-ons-col vertical-align="center" class="pop-title" />
            <v-ons-col vertical-align="center">
              <!-- mod 5849 抽出条件にて治療日を入力せず、クールを入力した際に注意文が表示されない start zhao -->
              <!-- <v-ons-row style="flex-wrap: nowrap;;" vertical-align="center"> -->
              <v-ons-row style="white-space: nowrap;" vertical-align="center">
              <!-- mod 5849 抽出条件にて治療日を入力せず、クールを入力した際に注意文が表示されない end zhao -->
                <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
                 <!-- <input
                  v-model="searchCondition.noticeEndDate"
                  class="input-area ntss-custom-input"
                  type="date"
                />
                <common-calendar
                  v-model="searchCondition.noticeEndDate"
                  class="calender"
                /> -->
                <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
                <!-- <input
                  v-model="searchCondition.noticeEndDate"
                  class="input-area ntss-custom-input end-date"
                  type="date"
                  @keyup="showEndMsg"
                  @blur="getEndDate"
                /> -->
                <date-input
                  v-model="searchCondition.noticeEndDate"
                  @handleClearInput="searchCondition.noticeEndDate = null"
                  :classes="'input-area ntss-custom-input end-date ntss-input-date'"
                  @keyup="showEndMsg"
                  @blur="getEndDate"
                />
                <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
                <common-calendar
                  v-model="searchCondition.noticeEndDate"
                  class="calender end-date-comment"
                />
                <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
                <!--add FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
                <span class="error-message" v-if="showErrorEndDate" style="display: block;">
                  {{this.msgDiaLog}}
               </span>
               <!--add FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="condition-row" style="flex-wrap: nowrap;">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>治療日</label>
            </v-ons-col>
            <v-ons-col vertical-align="center" style="white-space: nowrap;">
              <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
              <!-- <input v-model="searchCondition.dialysisDate" class="input-area ntss-custom-input" type="date" />
              <common-calendar v-model="searchCondition.dialysisDate" class="calender" /> -->
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
              <!-- <input v-model="searchCondition.dialysisDate" class="input-area ntss-custom-input dialysis-date" type="date" @keyup="showDialysisMsg" @blur="getDialysisDate"/> -->
              <date-input v-model="searchCondition.dialysisDate" @handleClearInput="searchCondition.dialysisDate = null" :classes="'input-area ntss-custom-input dialysis-date ntss-input-date'" @keyup="showDialysisMsg" @blur="getDialysisDate"/>
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
              <common-calendar v-model="searchCondition.dialysisDate" class="calender dialysis-date-comment" />
              <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
              <!-- add redmine-5849 「抽出条件にて治療日を入力せず、クールを入力した際に注意文が表示されない」 房 start -->
              <span v-show="isValidTreatmentDate" class="error-message" style="display: block;">治療日をご入力ください。</span>
              <!-- add redmine-5849 「抽出条件にて治療日を入力せず、クールを入力した際に注意文が表示されない」 房 end -->
              <!--add FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
              <span class="error-message" v-if="showErrorDialysisDate" style="display: block;">
                {{this.msgDiaLog}}
              </span>
              <!--add FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>クール</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <v-ons-select v-model="searchCondition.kur">
                <option
                  v-for="(item, kurIndex) in kurOption"
                  :key="kurIndex"
                  :value="item.code"
                >{{ item.name }}</option>
              </v-ons-select>
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>ベッドグループ ・透析室</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <v-ons-select
                v-model="searchCondition.roomBedGroup.bedGroupCd"
                @change="setBedGroupCd(searchCondition.roomBedGroup.bedGroupCd)"
              >
                <option
                  v-for="(item, index) in roomBedGroupOption"
                  :key="index"
                  :value="item.code"
                >{{ item.name }}</option>
              </v-ons-select>
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>

      <div class="condition-row condition-button-area">
        <div class="clear-button">
          <!-- mod 画面部品デザイン定義 修正 chen start -->
          <v-ons-button class="btn2-cancel common-style-cancel-button" @click="dialogClear">クリア</v-ons-button>
          <!-- <v-ons-button class="clear" @click="dialogClear">クリア</v-ons-button> -->
          <!-- mod 画面部品デザイン定義 修正 chen end -->
        </div>
        <div class="ok-button">
          <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
          <!-- <v-ons-button class="ok" @click="sendInfo()">OK</v-ons-button> -->
          <!-- mod 5849抽出条件にて治療日を入力せず、クールを入力した際に注意文が表示されない zhao start -->
          <!-- <v-ons-button class="btn3-normal common-style-ok-button" @click="sendInfo()" :disabled="showErrorEndDate || showErrorStartDate  || showErrorDialysisDate">OK</v-ons-button> -->
          <v-ons-button class="btn3-normal common-style-ok-button" @click="sendInfo()" :disabled="showErrorEndDate || showErrorStartDate  || showErrorDialysisDate || isValidTreatmentDate">OK</v-ons-button>
          <!-- mod 5849抽出条件にて治療日を入力せず、クールを入力した際に注意文が表示されない zhao end -->
          <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<script>
  // ライブラリ
    import dayjs from "@/compat/date/dayjs";
  import { EventBus } from "@/compat/vue/event-bus.js";
    import { ApiHelper } from "@/apis/AxiosHelper";
  import NextTransitionMixin from "@/components/NextTransitionMixin";
  import { deepCopy } from "@/functions/common/CommonFunctions";
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  import commonSearchArea from "@/components/common/CommonSearchArea";
  import { mapGetters, mapActions } from "@/compat/vue/vuex";
  import { ROUTERLINK_FACILITY_CALENDAR, ROUTERLINK_FACILITY_CALENDAR_CREATE } from "@/components/facility-calendar/Definitions";
  import PopoverMixin from "@/components/PopoverMixin";
  import { FACILITY_CALENDAR } from "@/constants/defaultSettingConstants";
  /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 start*/
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
  /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 end*/
  // add 画面印刷プレビューと印刷の実現 黄 start
  import { getCurrentFunctionCd } from "@/router/routing-helper";
  // add 画面印刷プレビューと印刷の実現 黄 end
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
  import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
  import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
  //#5590 2023/04/19 ×を常に表示するように修正 張博 start
  import DateInput from "@/components/common/DateInput.vue";
  import { getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
  //#5590 2023/04/19 ×を常に表示するように修正 張博 end
  // add #11065 【03】編集権限バグ修正 関 start
  import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  // add #11065 【03】編集権限バグ修正 関 end
  const mstKur = "mst_kur";
  const uriKur = `/mstInfo/${mstKur}/mstSelector`;
  const mstRoomBedGroup = "mstRoomBedGroup";
  const uriRoomBedGroup = `/mstInfo/${mstRoomBedGroup}`;
  const uriBbsKind = `/mstInfo/mstBbsKind`;
  // ラジオボタン選択肢
  const ALL_USER = "1";
  const NOT_USER = "2";

  /**
   * @description 患者情報ヘッダ
   */
  export default {
    mixins: [NextTransitionMixin, PopoverMixin],
    components: {
      "common-calendar": commonCalender,
      "common-searcharea": commonSearchArea,
      //#5590 2023/04/19 ×を常に表示するように修正 張博 start
      "date-input":DateInput,
      //#5590 2023/04/19 ×を常に表示するように修正 張博 end
    },
    props: {
      // NOTE: コンソールエラー対策
      historyKey: null
    },

    data() {
      return {
        // 掲示板種別マスタ
        mstBbsKind: null,
        // クールマスタ
        mstKur: null,
        // ベッドグループ ・透析室マスタ
        mstRoomBedGroup: null,
        // 検索条件
        searchCondition: {
          viewTotal: true,
          // フリーワード
          freeWord: "",
          // 掲載開始日
          noticeStartDate: null,
          // 掲載終了日
          noticeEndDate: null,
          // 治療日
          dialysisDate: null,
          // クール
          kur: null,
          // ベッドグループ ・透析室
          roomBedGroup: { bedGroupCd: null, bedCdList: [] }
        },
        selectedCondition: {
          viewTotal: true,
          // フリーワード
          freeWord: "",
          // 掲載開始日
          noticeStartDate: null,
          // 掲載終了日
          noticeEndDate: null,
          // 治療日
          dialysisDate: null,
          // クール
          kur: null,
          // ベッドグループ ・透析室
          roomBedGroup: { bedGroupCd: null, bedCdList: [] }
        },
        // 吹き出し表示フラグ
        popoverVisible: false,
        // 吹き出し位置※左右
        popoverTarget: null,
        // 吹き出し位置※下に表示
        popoverDirection: "down",
        viewAllType: true,
        // 共通検索エリア部品に表示するデータのリスト
        conditionList: [],
        /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 start*/
        msgDiaLog: DIALOG_MESSAGES["99999995"].message,
        showErrorStartDate: false,
        showErrorEndDate: false,
        showErrorDialysisDate:false,
        /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 end*/
        // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
        selectedDate: null,
        // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
        deferViewModeApply: false,
      };
    },

    computed: {
      ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
      // ※検索条件はログイン中保持するため、ストア管理
      ...mapGetters("facility-calendar", [
        "viewMode",
        "getCalendarSearchDate"
      ]),
      ...mapGetters("facility-calendar", {
        storedSelectedCondition: "selectedCondition",
        storedIsSelectedCondition:"isSelectedCondition"
      }),
      ...mapGetters("user", {
        facilityCd: "getFacilityCd",
        dispUserId: "getDispUserId"
      }),
      ...mapGetters("account-edit", {
        defaultSetting: "getDefaultSetting"
      }),
      ...mapGetters("exam-record/list",["getCondition"]),
      ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
      mode: {
        get() {
          return this.viewMode;
        },
        set(value) {
          const parsed = Number.parseInt(value);
          if (this.deferViewModeApply) {
            EventBus.$emit("facilityCalendarQueueViewMode", parsed);
            return;
          }
          this.setViewMode(parsed);
        }
      },

      isFreeWord() {
        const freeWord = this.selectedCondition.freeWord;
        return !(freeWord === null || freeWord === "");
      },

      isNoticeStartDate() {
        const noticeStartDate = this.selectedCondition.noticeStartDate;
        // mod bug修正 chen start
        // return !(noticeStartDate === null || noticeStartDate === "");
        const noticeEndDate = this.selectedCondition.noticeEndDate;
        return !(noticeStartDate === null || noticeStartDate === "") || !(noticeEndDate === null || noticeEndDate === "");
        // mod bug修正 chen end
      },

      isDialysisDate() {
        const dialysisDate = this.selectedCondition.dialysisDate;
        return !(dialysisDate === null || dialysisDate === "");
      },

      isKur() {
        const kur = this.selectedCondition.kur;
        return kur !== null;
      },

      isRoomBedGroup() {
        const roomBedGroup = this.selectedCondition.roomBedGroup.bedGroupCd;
        return roomBedGroup !== null;
      },

      /**
       * @description クールプルダウンリスト
       */
      kurOption() {
        // 選択肢マスタ(クール)から選択肢を表示
        return this.mstKur === null
          ? []
          : this.mstKur.map(item => ({
            code: item.code,
            name: item.name
          }));
      },

      /**
       * @description ベッドグループ ・透析室プルダウンリスト
       */
      roomBedGroupOption() {
        // 選択肢マスタ(ベッドグループ ・透析室)から選択肢を表示
        return this.mstRoomBedGroup === null
          ? []
          : this.mstRoomBedGroup.map(item => ({
            code: item.roomBedGroupCd,
            name: item.roomBedGroupName,
            bedList: item.bedList
          }));
      },

      /**
       * @description フリーワード(検索条件)
       */
      freeWord() {
        return this.selectedCondition.freeWord;
      },

      /**
       * @description クール(検索条件)
       */
      kur() {
        if (this.kurOption.length === 0) {
          // 検索条件が指定されたいない場合、選択肢がない場合
          return null;
        }

        // プルダウン(選択肢)から選択された値を返す
        return this.kurOption.find(item => {
          return item.code === this.selectedCondition.kur;
        }).name;
      },

      /**
       * @description ベッドグループ ・透析室(検索条件)
       */
      roomBedGroup() {
        if (this.roomBedGroupOption.length === 0) {
          // 検索条件が指定されたいない場合、選択肢がない場合
          return null;
        }
        // プルダウン(選択肢)から選択された値を返す
        const bedGroup = this.roomBedGroupOption.find(item => {
          return item.code === this.selectedCondition.roomBedGroup.bedGroupCd;
        });
        return bedGroup.name;
      },

      /**
       * @description 掲載開始日(検索条件)
       */
      noticeStartDate() {
        const startDate = this.selectedCondition.noticeStartDate;
        if (startDate === "" || startDate === null) {
          // 検索条件が指定されていない場合
          return null;
        }

        return dayjs(startDate, "YYYY-MM-DD").format("YYYY/MM/DD");
      },

      /**
       * @description 掲載終了日(検索条件)
       */
      noticeEndDate() {
        const endDate = this.selectedCondition.noticeEndDate;
        if (endDate === "" || endDate === null) {
          // 検索条件が指定されていない場合
          return null;
        }

        return dayjs(endDate, "YYYY-MM-DD").format("YYYY/MM/DD");
      },

      /**
       * @description 治療日(検索条件)
       */
      dialysisDate() {
        const dialysisDate = this.selectedCondition.dialysisDate;
        if (dialysisDate === "" || dialysisDate === null) {
          // 検索条件が指定されていない場合
          return null;
        }

        return dayjs(dialysisDate, "YYYY-MM-DD").format("YYYY/MM/DD");
      },

      NOT_USER() {
        return NOT_USER;
      },
      /* add FNSI-434 改修内容 "掲示板のみに表示施設カレンダのみに表示 趙立強 start*/
      startHour(){
       return new Date().getHours()>9?new Date().getHours():"0"+new Date().getHours();
      },
      startMinutes(){
        return new Date().getMinutes()>9?new Date().getMinutes():"0"+new Date().getMinutes();
      },
      /* add FNSI-434 改修内容 "掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
      // add redmine-5849 「抽出条件にて治療日を入力せず、クールを入力した際に注意文が表示されない」 房 start
      isValidTreatmentDate(){
        if(!this.searchCondition.kur ||
          (this.searchCondition.kur  && this.searchCondition.dialysisDate != null && this.searchCondition.dialysisDate != "")){
          return  false;
        } else {
          return  true;
        }
      }
      // add redmine-5849 「抽出条件にて治療日を入力せず、クールを入力した際に注意文が表示されない」 房 end
    },

    watch: {
      selectedCondition() {
        // 画面をリロードした際、設定した検索条件と表示内容を一致させるため、storeの検索条件を吹き出しに設定
        // storeに影響させないためディープコピーを行う。
        // 検索popoverでストアを変更し、検索ヘッダを更新する用
        this.searchCondition = deepCopy(this.selectedCondition);
      },
      /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 start*/
      'searchCondition.noticeEndDate'() {
        if(this.getHeaderInputByClassName("end-date").validationMessage !== ""){
          this.showErrorEndDate = !(this.getHeaderInputByClassName("end-date").value === "" && this.getHeaderInputByClassName("end-date-comment").value !== "");
        }else{
          this.showErrorEndDate = false;
        }
      },
      'searchCondition.noticeStartDate'() {
        if(this.getHeaderInputByClassName("start-date").validationMessage !== ""){
          this.showErrorStartDate = !(this.getHeaderInputByClassName("start-date").value === "" && this.getHeaderInputByClassName("start-date-comment").value !== "");
        }else{
          this.showErrorStartDate = false;
        }
      },
      'searchCondition.dialysisDate'() {
        if(this.getHeaderInputByClassName("dialysis-date").validationMessage !== ""){
          this.showErrorDialysisDate = !(this.getHeaderInputByClassName("dialysis-date").value === "" && this.getHeaderInputByClassName("dialysis-date-comment").value !== "");
        }else{
          this.showErrorDialysisDate = false;
        }
      }
      /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 end*/
    },

    /**
     * @description 検索条件のプルダウンリスト(選択肢)を取得するため選択肢マスタから各データ取得
     */
    async created() {
      // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
      this.setLoadingScreenMessage("処理中...");
      this.setLoadingScreenVisible(true);
      // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end

      if (!this.storedIsSelectedCondition) {
        // まだ条件が保存されていない場合
        // デフォルト設定を反映してsearchConditionを初期化する
        this.clearCondition();
      } else {
        // 保存された条件でsearchConditionを初期化する
        this.searchCondition = deepCopy(this.storedSelectedCondition);
      }
      this.selectedCondition = deepCopy(this.searchCondition);
      // 表示モード(日/週/月)を設定
      if (!this.mode) {
        let defaultViewMode = null;
        if (typeof this.defaultSetting[FACILITY_CALENDAR.KEY_NAME] !== "undefined" &&
            typeof this.defaultSetting[FACILITY_CALENDAR.KEY_NAME][FACILITY_CALENDAR.KEY_NAME_VIEW_MODE] !== "undefined") {
          defaultViewMode = this.defaultSetting[FACILITY_CALENDAR.KEY_NAME][FACILITY_CALENDAR.KEY_NAME_VIEW_MODE];
        }
        if (defaultViewMode) {
          this.goFacilityCalendar(Number.parseInt(defaultViewMode));
        }
      }

      // 掲示板種別マスタ、観察記録種別情報、クールマスタ、ベッドグループ・透析室マスタ取得
      const [
        responseBbsKind,
        responseKur,
        responseBedGroup
      ] = await Promise.all([
        ApiHelper.get(uriBbsKind, {
          facilityCd: this.facilityCd
        }),
        ApiHelper.get(uriKur, {
          facilityCd: this.facilityCd
        }),
        ApiHelper.get(uriRoomBedGroup, {
          facilityCd: this.facilityCd
        })
      ]).catch(() => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('FacilityCalendarHeader.vue', 'created', 'マスタ取得失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // console.log(`API:"[PatFacilityHeader.vue]created(): マスタ取得失敗");
        // console.log(error);
      });
      this.mstBbsKind = responseBbsKind.data;
      this.mstKur = responseKur.data.orderSettings.items;
      this.mstRoomBedGroup = responseBedGroup.data.map(mst => {
        return { ...mst, bedList: JSON.parse(mst.bedList) };
      });

      // マスタの選択肢に全てを追加
      const allSearchKur = { code: null, name: "すべて" };
      const allSearchRoomBedGroup = {
        roomBedGroupCd: null,
        roomBedGroupName: "すべて",
        bedList: []
      };
      this.mstKur = [allSearchKur, ...this.mstKur];
      this.mstRoomBedGroup = [allSearchRoomBedGroup, ...this.mstRoomBedGroup];
      EventBus.$on("searchConditionFacilityCalendar", this.sendInfo);
      this.setConditionList();
      // 印刷パラメータ要求
      EventBus.$on("requestReportParams", this.requestrReportParams);
      EventBus.$on("goFacilityCalendar", this.goFacilityCalendar);
      EventBus.$on("getSelectedDate", this.getSelectedDate);
      EventBus.$on("createEvent", this.createEvent);
      EventBus.$on("facilityCalendarViewModeApplyDone", this.onViewModeApplyDone);
      this.setLoadingScreenVisible(false);
    },

    beforeUnmount() {
      EventBus.$off("searchConditionFacilityCalendar", this.sendInfo);
      EventBus.$off("requestReportParams", this.requestrReportParams);
      EventBus.$off("goFacilityCalendar", this.goFacilityCalendar);
      EventBus.$off("getSelectedDate", this.getSelectedDate);
      EventBus.$off("createEvent", this.createEvent);
      EventBus.$off("facilityCalendarViewModeApplyDone", this.onViewModeApplyDone);
      this.mstBbsKind = null;
      this.mstKur = null;
      this.mstRoomBedGroup = null;
      this.searchCondition = null;
      this.selectedCondition = null;
      this.popoverVisible = null;
      this.popoverTarget = null;
      this.popoverDirection = null;
      this.viewAllType = null;
      this.conditionList = null;
      this.msgDiaLog = null;
      this.showErrorStartDate = null;
      this.showErrorEndDate = null;
      this.showErrorDialysisDate = null;

      // dataの初期化
      Object.assign(this.$data, this.$options.data());
    },

    mounted() {
      EventBus.$emit("addLeftmostHeaderMargin");
    },

    methods: {
      getHeaderInputByClassName(className) {
        return getScopedElementsByClassName(className, this.popoverTarget || this.$el || null)?.[0] || null;
      },

      // ※検索条件はログイン中保持するため、ストア管理
      //add FutreNetWeb+SI課題管理No4298対応 于 start
      ...mapActions("facility-calendar", [
        "setSelectedCondition",
        "setViewMode",
        "setIsSelectedCondition"
      ]),
      //add FutreNetWeb+SI課題管理No4298対応 于 end
      // ※検索条件はログイン中保持するため、ストア管理
      ...mapActions("bbs-info", [
        "setSelectedBbs",
        "setRegFuncClass",
        "setHTMLContent",
      ]),
      ...mapActions("master-maintenance", [
        "setMasterName",
        "setLogicalMasterName"
      ]),
      // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 start
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
    }),
    // add FNSI5415-カレンダー内のセルの表示に時間がかかる 周 end
      popoverPreShow,
      popoverPostShow,
      popoverPosthide,

      sendInfo() {
        this.selectedCondition = deepCopy(this.searchCondition);
        this.setSelectedCondition(this.selectedCondition);
        this.popoverVisible = false;
        this.setConditionList();
        //add FutreNetWeb+SI課題管理No4298対応 于 start
        this.setIsSelectedCondition(true);
        //add FutreNetWeb+SI課題管理No4298対応 于 end
      },

      // add #11285 機能帳票の印刷情報対応② 高 start
      getbedNames () {
        var bedNames = "";
        // mod #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
        // if (this.selectedCondition.roomBedGroup.bedGroupCd == 0) {
        if (this.selectedCondition.roomBedGroup.bedCdList.length == 0) {
          // bedNames = "複数ベッドグループ";
          bedNames = "すべて";
        // mod #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end

        } else {
          for (var ind = 0; ind < this.roomBedGroupOption.length;ind++) {
            if (this.selectedCondition.roomBedGroup.bedGroupCd == this.roomBedGroupOption[ind].code) {
              bedNames = this.roomBedGroupOption[ind].name;
            }
          }
        }
        return bedNames;
      },
      // add #11285 機能帳票の印刷情報対応② 高 end
      // add 画面印刷プレビューと印刷の実現 黄 start
      requestrReportParams(param) {
        // 機能コード判定
        if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致
          // add #11285 機能帳票の印刷情報対応② 高 start
          var expressCondCd="";
          if (null != this.getStorSimlpSearchQurey.rstDialysisState && this.getStorSimlpSearchQurey.rstDialysisState.length > 0) {
            if (this.getStorSimlpSearchQurey.rstDialysisState.length == 2) {
              expressCondCd = "予定・実績";
            } else {
              if (this.getStorSimlpSearchQurey.rstDialysisState[0] == 1) {
                expressCondCd = "予定";
              } else {
                expressCondCd = "実績";
              }
            }
          }
          let patGroups = null;
          if(this.getStorSimlpSearchQurey.selectedPatGroupNames) {
            patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames;
          } else {
            patGroups = "すべて";
          }
          // add #11285 機能帳票の印刷情報対応② 高 end
          // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
          var selectDate = this.selectedDate;
          var firstDate = new Date(selectDate.getFullYear(), selectDate.getMonth(), 1);
          var lastDate = new Date(selectDate.getFullYear(), selectDate.getMonth()+1, 0);
          // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe end

        // const condition = this.getCondition;
        // 印刷パラメータを応答
        const param = {
          patId: this.selectedPatId,
          // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
          patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
          // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
          // facilityCd: this.getFacilityCd,
          // date: dayjs(Date.now()).format("YYYY/MM/DD"),
          // fromDate: dayjs(this.searchCondition.noticeStartDate).format("YYYY/MM/DD"),
          // toDate: dayjs(this.searchCondition.noticeEndDate).format("YYYY/MM/DD")
          functionCd:"03701",
          facilityCd: this.facilityCd,
          date: dayjs(selectDate).format("YYYY/MM/DD"),
          fromDate: dayjs(firstDate).format("YYYY/MM/DD"),
          toDate: dayjs(lastDate).format("YYYY/MM/DD"),
          // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
          // add #11285 機能帳票の印刷情報対応② 高 start
          freeWord: this.searchCondition.freeWord,
          bedCdListString:this.getbedNames(),
          kurNames:this.kur == null ? "すべて" : this.kur,
          treatDate: this.dialysisDate,
          expressCondCdStr:expressCondCd,
          patGroups:patGroups,
          // add #11285 機能帳票の印刷情報対応② 高 end
        };
        EventBus.$emit("sendReportParams", param);
        }
      },
      // add 画面印刷プレビューと印刷の実現 黄 end

      async showPopover(event) {
        // 必要に応じて日付入力エラー状態をリセットさせる
        await this.clearDateErrorMessage();
        this.popoverTarget = event;
        this.popoverVisible = true;
      },
      async clearDateErrorMessage() {
        if (!this.showErrorStartDate && !this.showErrorEndDate && !this.showErrorDialysisDate) return;

        // 日付入力エラー状態が残っている場合
        // エラーメッセージ表示状態を更新
        this.showStartMsg();
        this.showEndMsg();
        this.showDialysisMsg();
        if (!this.showErrorStartDate && !this.showErrorEndDate && !this.showErrorDialysisDate) return;

        // まだ日付入力エラー状態が残っている場合
        // 日付入力エラー状態からキャンセルやクリアで
        // searchConditionの値をnullにした際には
        // inputのvalueとしては変化が起きないため
        // 入力途中の状態が残ったままになっている状況なので
        // 有効な日付のダミー値を設定して入力状態をリセットさせる
        // 入力状態リセット後のカレンダーの初期表示年月が
        // ここで設定した値に影響を受けるため
        // ダミー値はシステム日付にしておく
        this.searchCondition.noticeStartDate
        = this.searchCondition.noticeEndDate
        = this.searchCondition.dialysisDate = dayjs().format("YYYY-MM-DD");
        // searchConditionの変更がinputに反映されるのを待つ
        await this.$nextTick();

        // 本来の値に戻す
        this.searchCondition.noticeStartDate = this.selectedCondition.noticeStartDate;
        this.searchCondition.noticeEndDate = this.selectedCondition.noticeEndDate;
        this.searchCondition.dialysisDate = this.selectedCondition.dialysisDate;
        // searchConditionの変更がinputに反映されるのを待つ
        await this.$nextTick();

        // この時点でsearchCondition.noticeStartDateなどのwatch処理によって
        // エラーメッセージ表示状態はクリアされた状態になっている
      },

      // -----------------------------------------
      // 抽出条件クリアボタンクリックイベント
      // -----------------------------------------
      dialogClear() {
        // 検索条件クリア
        this.clearCondition();
        // selectedConditionの更新とsetSelectedCondition、setConditionListはsendInfoで行われ、
        // ポップアップは閉じられる
        this.sendInfo();
      },
      clearCondition() {
        // 検索条件クリア
        let defaultViewTotal = true;
        if (typeof this.defaultSetting[FACILITY_CALENDAR.KEY_NAME] !== "undefined" &&
            typeof this.defaultSetting[FACILITY_CALENDAR.KEY_NAME][FACILITY_CALENDAR.KEY_NAME_VIEW_TOTAL] !== "undefined") {
          defaultViewTotal = this.defaultSetting[FACILITY_CALENDAR.KEY_NAME][FACILITY_CALENDAR.KEY_NAME_VIEW_TOTAL];
        }
        this.searchCondition = {
          viewTotal: defaultViewTotal,
          freeWord: "",
          noticeStartDate: null,
          noticeEndDate: null,
          dialysisDate: null,
          kur: null,
          roomBedGroup: { bedGroupCd: null, bedCdList: [] }
        };
      },
      handlePopoverPosthide(event) {
        if (this.popoverVisible) {
          // 背景クリックで閉じられる場合
          // ポップアップ内の入力項目の値を変更前の内容に戻す
          this.searchCondition = deepCopy(this.selectedCondition);
        }
        this.popoverPosthide(event);
      },

      // -----------------------------------------
      // 共通検索エリア部品に表示するデータのリストを作成
      // -----------------------------------------
      setConditionList() {
        let condList = [];
        // 集計件数表示
        if (this.selectedCondition.viewTotal) {
          condList.push({ text:"集計件数表示" });
        }
        // フリーワード
        if (this.isFreeWord) {
          condList.push({ name:"フリーワード", text:this.freeWord });
        }
        // 掲載日
        if (this.isNoticeStartDate) {
          let dataStr = this.noticeStartDate;
          if (this.noticeEndDate !== null) {
            dataStr = dataStr + " ～ " + this.noticeEndDate;
          }
          condList.push({ name:"掲載日", text:dataStr });
        }
        // 治療日
        if (this.isDialysisDate) {
          condList.push({ name:"治療日", text:this.dialysisDate });
        }
        // クール
        if (this.isKur) {
          condList.push({ name:"クール", text:this.kur });
        }
        // ベッドグループ ・透析室
        if (this.isRoomBedGroup) {
          condList.push({ name:"ベッドグループ ・透析室", text:this.roomBedGroup });
        }
        else {
          condList.push({ name:"ベッドグループ ・透析室", text:"すべて" });
        }

        this.conditionList = condList;
      },

      setBedGroupCd(value) {
        const selectedBedGroup = this.mstRoomBedGroup.find(
          mst => mst.roomBedGroupCd === value);
        this.searchCondition.roomBedGroup.bedCdList = selectedBedGroup.bedList ? selectedBedGroup.bedList : [];
      },

      /**
       * @description 掲示板詳細画面へ遷移
       */
      createEvent(date) {
        let noticeDate = null;
        if(date){
          noticeDate = date;
        }else{
          noticeDate = this.getCalendarSearchDate ? this.getCalendarSearchDate : dayjs().format("YYYY-MM-DD");
        }
        // 選択掲示板クリア
        this.setSelectedBbs(
          {
            bbs_ctl_no: null,
            facility_cd: this.facilityCd,
            pat_info: { target: NOT_USER, detail: [] },
            staff_info: {
              target: ALL_USER,
              detail: []
            },
            func_cd: "020",
            kind_no: null,
            fn_seq_id: null, // 内容管理番号(観察記録等)
            content: null,
            file_info: [],
            notice_start_date: noticeDate,
            notice_end_date: noticeDate,
            reg_staff_id: null,
            reg_staff_name: null,
            upd_staff_id: null,
            upd_staff_name: null,
            transition_router_path: null,
            reg_date: null,
            up_date: null,
            notice_fac_cal_start_date: noticeDate,
            notice_fac_cal_end_date: noticeDate,
            notice_fac_cal_start_time: this.startHour + "" +this.startMinutes,
            notice_fac_cal_end_time: this.startHour + "" +this.startMinutes,
            title: null,
            is_disp_bbs: "2",
            is_time_start_flg: "1",
            is_time_end_flg: "1",
            color: null,
            font_color:null,
          });
        // デフォルトコンテンツの初期化
        let defaultContents = "";
        // 掲示板種別マスタ作成済の場合
        if (this.mstBbsKind && this.mstBbsKind.length != 0) {
          // 掲示板種別マスタの取得
          const bbsKind = this.mstBbsKind[0];
          // デフォルトコンテンツの取得
          defaultContents = bbsKind.defaultContents === null ? "" : bbsKind.defaultContents;
        }
        // 初期値の取得
        const htmlContent = "<p style='font-size: 14pt; font-family: メイリオ;'>" + defaultContents + "</p>";
        // 登録元機能の設定
        this.setRegFuncClass(0);
        // HTMLContentの設定
        this.setHTMLContent(htmlContent);
        // 遷移
        this.$router.push({ name: ROUTERLINK_FACILITY_CALENDAR_CREATE });
      },

      async goFacilityCalendar(viewMode) {
        this.$router.push({ name: ROUTERLINK_FACILITY_CALENDAR });
        this.deferViewModeApply = true;
        EventBus.$emit("facilityCalendarQueueViewMode", viewMode);
        this.sendInfo();
      },
      onViewModeApplyDone() {
        this.deferViewModeApply = false;
      },
      // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
      getSelectedDate(date){
        this.selectedDate = new Date(date);
      },
      // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
      // del #9717 施設カレンダーでサイドコンテンツの開閉の際に読み込みが走り表示に時間がかかる linjunfeng start
      // refreshView(viewMode) {
      //   this.setViewMode(viewMode);
      //   this.sendInfo();
      //   if (viewMode !== 3) {
      //     EventBus.$emit("updateDateFollowScreen", viewMode);
      //     EventBus.$emit("updateConfigCurrentDate", viewMode);
      //   }
      // },
      // del #9717 施設カレンダーでサイドコンテンツの開閉の際に読み込みが走り表示に時間がかかる linjunfeng start
      /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 start*/
      showStartMsg(){
      this.showErrorStartDate = this.getHeaderInputByClassName("start-date").validationMessage !== "";
      },
      showEndMsg(){
        this.showErrorEndDate = this.getHeaderInputByClassName("end-date").validationMessage !== "";
      },
      showDialysisMsg(){
        this.showErrorDialysisDate = this.getHeaderInputByClassName("dialysis-date").validationMessage !== "";
      },
      getStartDate(){
        this.showErrorStartDate = this.getHeaderInputByClassName("start-date").validationMessage !== "";
      },
      getEndDate(){
        this.showErrorEndDate = this.getHeaderInputByClassName("end-date").validationMessage !== "";
      },
      getDialysisDate(){
        this.showErrorDialysisDate = this.getHeaderInputByClassName("dialysis-date").validationMessage !== "";
      },
      /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 end*/
      // add #11065 【03】編集権限バグ修正 関 start
      getItemAuthorized(pageCd, itemCd) {
        return getAuthorized(pageCd, itemCd);
      },
      // add #11065 【03】編集権限バグ修正 関 end
    }
  };
</script>

<style scoped>
  .create-button {
    width: auto;
    display: inline-table;
  }
  .style-text-button {
    margin: 0;
    line-height: initial;
    height: 1.2em;
  }
  .leftmost-header {
    margin-left: 2em;
  }
  .switch-time-range {
    display: none;
  }
  .switch-time-range-label {
    display: block; /* ブロックレベル要素化する */
    float: left; /* 要素の左寄せ・回り込を指定する */
    height: 2em; /* ボックスの高さを指定する */
    padding-left: 10px;
    padding-right: 10px;
    color: #ffffff; /* フォントの色を指定する */
    text-align: center; /* テキストのセンタリングを指定する */
    line-height: 2em; /* 行の高さを指定する */
    cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  }
  .first-of-type {
    border-radius: 10px 0 0 10px;
    margin-left: 0.5em;
  }
  .last-of-type {
    border-radius: 0 10px 10px 0;
  }
  .filter-area {
    display: flex;
    margin-top: 2px;
    align-items: center;
    font-size: 1.5em;
  }

  /* 横に広げる */
  .custom-input {
    display: inline-block;
    width: 100%;
    box-sizing: border-box;
    font-size: inherit;
  }
  .horizontal-div {
    display: -webkit-box;
    font-size: 1em;
    margin-bottom: 4px;
    margin-top: 4px;
  }
  .checkbox-area,
  .number-area {
    /* 一覧の文字色 */
    color: var(--ntss-list-body-color);
  }

  .condition-search-col {
    flex: 0 0 55%;
  }

  .checkbox-area {
    flex: 0 0 10%;
  }
  .number-area {
    flex: 0 0 5%;
  }
  .create-area {
    flex: 0 0 10%;
  }
  .state-area {
    flex: 0 0 10%;
  }

  .searching-modal {
    text-align: center;
    font-size: 30px;
  }

  .pop-area {
    margin: 10px;
  }

  .condition-button-area {
    height: 30px;
    margin: 10px;
    text-align: center;
  }

  .clear-button {
    float: left;
  }

  .ok-button {
    float: right;
  }

  .pop-title {
    flex: 0 0 40%;
  }

  .input-checkbox {
    border: solid 1px;
    border-color: gray;
    border-radius: 50%;
  }

  .checkbox-area,
  .number-area,
  .create-area,
  .state-area {
    font-size: 1em;
    text-align: center;
    display: flex;
    align-items: center;
    height: 100%;
    font-size: 1.5em;
  }

  .input-area::-webkit-calendar-picker-indicator {
    display: none;
  }

  .popover-area :deep(.popover-mask) {
    z-index: 100;
  }

  .popover-area :deep(.popover) {
    z-index: 200;
    min-width: 35em;
  }

  @media screen and (max-width: 320px) {
    .custom-search {
      max-width: 35%;
    }
    .custom-button {
      max-width: 20%;
      font-size: 0.8em;
    }
  }
  @media screen and (max-width: 600px) {
    .create-button {
      padding: 5px;
    }
    .custom-button {
      max-width: 36%;
      overflow-x: auto;
    }
    .switch-time-range-label {
      padding-left: 5px;
      padding-right: 5px;
    }
    .first-of-type {
      margin-left: 0.2em;
    }
  }
  @media (min-width: 320px) and (max-width: 720px) {
    .custom-search {
      max-width: 45%;
    }
  }
</style>
