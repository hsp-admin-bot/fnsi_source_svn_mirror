<template>
  <v-card>
    <div class="header-item">
      <div class="mark-leftmost-header">
        <!-- mod FNSI-改修内容4016bug修正 関 start -->
        <!-- <v-ons-row class="content-area" vertical-align="center"> -->
          <v-ons-row class="content-area content-area-t" vertical-align="center">
            <!-- mod FNSI-改修内容4016bug修正 関 end -->
          <v-ons-col class="condition-search-col">
            <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
          </v-ons-col>
          <v-ons-col class="checkbox-area">
            <!-- delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start -->
            <!-- <label class="checkbox-lable"> -->
            <!-- delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end -->
            <!-- add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start -->
            <label class="checkbox-lable" @click="onlyUnreadClick()">
              <!-- add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end -->
              <v-ons-checkbox
                v-model="showOnlyUnread"
                class="input-checkbox"
              /><br />
              未読のみ
            </label>
          </v-ons-col>
          <!-- delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start -->
          <!-- <v-ons-col class="number-area">
            {{ searchedBbsList.length }}件
          </v-ons-col> -->
          <!-- delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end -->
          <!-- add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start -->
          <v-ons-col v-if="searchedBbsList !== null && searchedBbsList.length !== 0" class="number-area">
            {{ searchedBbsList[0].count }}件
          </v-ons-col>
          <v-ons-col v-if="searchedBbsList === null || searchedBbsList.length === 0" class="number-area">
            0件
          </v-ons-col>
          <!-- add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end -->
          <v-ons-col class="create-area">
            <!-- add 権限項目追加 陳 start -->
<!--            <v-ons-button-->
<!--              class="create-button"-->
<!--              :disabled="!allowEdit"-->
<!--              @click="confirmGoBbsDetailedInfo()"-->
<!--            >-->
            <!--mod FNSI-改修内容redmine4225 任 start-->
            <!--<v-ons-button
              class="create-button"
              :disabled="!allowEdit"
              @click="confirmGoBbsDetailedInfo()"
            >-->
            <v-ons-button
              class="create-button btn3-normal"
              :disabled="!allowEdit"
              @click="confirmGoBbsDetailedInfo()"
            >
              <!--mod FNSI-改修内容redmine4225 任 end-->
            <!-- add 権限項目追加 陳 end -->
              <p class="style-text-button">新規</p>
              <p class="style-text-button">登録</p>
            </v-ons-button>
          </v-ons-col>
          <v-ons-col class="state-area">
            <!--mod FNSI-改修内容redmine4225 任 start-->
            <!--<v-ons-button class="state-button" @click="confirmAllRead">-->
            <v-ons-button class="state-button btn1-execute" @click="confirmAllRead">
              <!--mod FNSI-改修内容redmine4225 任 end-->
              <p class="style-text-button">全て</p>
              <p class="style-text-button">既読</p>
            </v-ons-button>
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
      @posthide="popoverPosthide"
    >
      <div class="pop-area">
        <div class="pop-main-area">
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>カテゴリ</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <kendo-multiselect
                :data-source="mstBbsKind"
                :data-text-field="'kindName'"
                :data-value-field="'kindNo'"
                :filter="'contains'"
                v-model="searchCondition.categoryKindList"
              />
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>フリーワード</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <input
                v-model="searchCondition.freeWord"
                class="input-area ntss-custom-input"
                type="text"
              />
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="top" class="pop-title">
              <label>掲載日</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
              <!-- <input
                v-model="searchCondition.noticeStartDate"
                class="input-area ntss-input-date ntss-custom-input"
                type="date"
                @input="setNoticeValue($event.target.value)"
              />
              <common-calendar
                v-model="searchCondition.noticeStartDate"
                class="calender"
              /> -->
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
              <!-- <input
                v-model="searchCondition.noticeStartDate"
                class="input-area ntss-input-date ntss-custom-input start-date"
                type="date"
                @input="setNoticeValue($event.target.value)"
                @keyup="showStartMsg"
                @blur="getStartDate"
                max="9999-12-31"
              /> -->
              <date-input
                v-model="searchCondition.noticeStartDate"
                @handleClearInput="searchCondition.noticeStartDate = null"
                :classes="'input-area ntss-input-date ntss-custom-input start-date'"
                style="width:75%"
                @input="setNoticeValue($event)"
                @keyup="showStartMsg"
                @blur="getStartDate"
              />
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
              <common-calendar
                v-model="searchCondition.noticeStartDate"
                class="calender start-date-comment"
              />
              <label>&nbsp;〜</label>
              <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
              <!--add FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
              <span class="error-message" v-if="showErrorStartDate" style="display: block;">{{
                this.msgDiaLog
              }}</span>
              <!--add FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title" />
            <v-ons-col vertical-align="center">
              <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
               <!-- <input
                v-model="searchCondition.noticeEndDate"
                class="input-area ntss-input-date ntss-custom-input"
                type="date"
                @input="setNoticeValue($event.target.value)"
              />
              <common-calendar
                v-model="searchCondition.noticeEndDate"
                class="calender"
              /> -->
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
              <!-- <input
                v-model="searchCondition.noticeEndDate"
                class="input-area ntss-input-date ntss-custom-input end-date"
                type="date"
                @input="setNoticeValue($event.target.value)"
                @keyup="showEndMsg"
                @blur="getEndDate"
                max="9999-12-31"
              /> -->
              <date-input
                v-model="searchCondition.noticeEndDate"
                :classes="'input-area ntss-input-date ntss-custom-input end-date'"
                style="width:75%"
                @handleClearInput="searchCondition.noticeEndDate = null"
                @input="setNoticeValue($event)"
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
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>治療日</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
              <!-- <input
                v-model="searchCondition.dialysisDate"
                class="input-area ntss-input-date ntss-custom-input"
                type="date"
              />
              <common-calendar
                v-model="searchCondition.dialysisDate"
                class="calender"
              /> -->
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
              <!-- <input
                v-model="searchCondition.dialysisDate"
                class="input-area ntss-input-date ntss-custom-input dialysis-date"
                type="date"
                @keyup="showDialysisMsg"
                @blur="getDialysisDate"
                max="9999-12-31"
              /> -->
              <date-input
                v-model="searchCondition.dialysisDate"
                @handleClearInput="searchCondition.dialysisDate = null"
                :classes="'input-area ntss-input-date ntss-custom-input dialysis-date'"
                style="width:75%"
                @keyup="showDialysisMsg"
                @blur="getDialysisDate"
              />
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
              <common-calendar
                v-model="searchCondition.dialysisDate"
                class="calender dialysis-date-comment"
              />
              <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
              <span v-show="isValidTreatmentDate" class="error-message" style="display: block;">治療日をご入力ください。</span>
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
                >
                  {{ item.name }}
                </option>
              </v-ons-select>
            </v-ons-col>
          </v-ons-row>

          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title" style="padding-right: 1em;">
              <label>ベッドグループ・透析室</label>
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
                >
                  {{ item.name }}
                </option>
              </v-ons-select>
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>

      <div class="condition-row condition-button-area">
        <div class="clear-button">
          <!-- mod 画面部品デザイン定義 修正 chen start -->
          <v-ons-button class="btn2-cancel common-style-cancel-button" @click="dialogClear">
          <!-- <v-ons-button class="clear" @click="dialogClear"> -->
          <!-- mod 画面部品デザイン定義 修正 chen end -->
            クリア
          </v-ons-button>
        </div>
        <div class="ok-button">
          <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 start-->
          <!-- <v-ons-button class="ok" @click="dialogOk" :disabled = isValidTreatmentDate>
            OK
          </v-ons-button> -->
          <!--mod FutreNetWeb+SI課題管理No4227対応 趙 start-->
          <!-- <v-ons-button class="btn3-normal common-style-select-button" @click="dialogOk"  :disabled="showErrorEndDate || showErrorStartDate || isValidTreatmentDate || showErrorDialysisDate"> -->
          <v-ons-button class="btn3-normal common-style-ok-button" @click="dialogOk"  :disabled="showErrorEndDate || showErrorStartDate || isValidTreatmentDate || showErrorDialysisDate">
          <!--mod FutreNetWeb+SI課題管理No4227対応 趙 end-->
            OK
          </v-ons-button>
          <!--mod FNSI-改修内容日付のチェックの追加対応。 趙立強 end-->
        </div>
      </div>
    </v-ons-popover>

    <message-dialog
      v-model:visible="isMessage"
      :message-cd="messageDialogInfo.messageCd"
      :title="messageDialogInfo.title"
      :type="messageDialogInfo.type"
      @confirm="confirm"
    />

    <v-ons-modal :visible="isSearching">
      <p class="searching-modal">
        {{ message }}
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal>
  </v-card>
</template>

<script>
  import dayjs from "@/compat/date/dayjs";
  import { EventBus } from "@/compat/vue/event-bus.js";
  import { mapGetters, mapActions } from "@/compat/vue/vuex";
  import { ApiHelper } from "@/apis/AxiosHelper";
  import { deepCopy } from "@/functions/common/CommonFunctions";
  import { updateBbsList } from "@/functions/BbsInfoFunctions.js";
  // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
  import { PAGE_SIZE } from "@/constants/PageableConstant";
  // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
  import PopoverMixin from "@/components/PopoverMixin";
  import { BBS_INFO } from "@/constants/defaultSettingConstants";
  import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils"
  import commonSearchArea from "@/components/common/CommonSearchArea";
  // 共通カレンダーコンポーネント
  import messageDialog from "@/components/common/message-dialog/MessageDialog";
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 start*/
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
  import {AUTHORITY_CODES} from "@/constants/userAuthority";
  /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 end*/
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
  import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
  import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
  // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
  //#5590 2023/04/19 ×を常に表示するように修正 張博 start
  import DateInput from "@/components/common/DateInput.vue";
  import { getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
  //#5590 2023/04/19 ×を常に表示するように修正 張博 end

  const mstKur = "mst_kur";
  const uriKur = `/mstInfo/${mstKur}/mstSelector`;
  const mstRoomBedGroup = "mstRoomBedGroup";
  const uriRoomBedGroup = `/mstInfo/${mstRoomBedGroup}`;
  const uriBbsKind = `/mstInfo/mstBbsKind`;

  // ラジオボタン選択肢
  const ALL_USER = "1";
  const NOT_USER = "2";

  /**
   * @description 掲示板登録情報ページ用ヘッダー
   */
  export default {
    mixins: [PopoverMixin],

    components: {
      "message-dialog": messageDialog,
      "common-calendar": commonCalender,
      "common-searcharea": commonSearchArea,
      //#5590 2023/04/19 ×を常に表示するように修正 張博 start
      "date-input":DateInput,
      //#5590 2023/04/19 ×を常に表示するように修正 張博 end
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
          // カテゴリ機能
          categoryFuncList: ["020"],
          // カテゴリ種類
          categoryKindList: [],
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
        // メッセージ
        isMessage: false,
        message: null,
        isSearching: false,

        // DB利用者マスタ
        settingBbs: { search_category: null },

        initCategoryKindList: [],

        isNotEdited: true,
        // 共通検索エリア部品に表示するデータのリスト
        conditionList: [],
        /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 start*/
        msgDiaLog: DIALOG_MESSAGES["99999995"].message,
        showErrorStartDate: false,
        showErrorEndDate: false,
        showErrorDialysisDate:false,
        /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 end*/
        // add 権限項目追加 chen start
        // 権限項目
        checkedAuthority: [],
        // add 権限項目追加 chen end
        messageDialogInfo: {
          messageCd: 72000001,
          title: DIALOG_MESSAGES['72000001'].title,
          type: "2"
        }
      };
    },

    computed: {
      // ※検索条件はログイン中保持するため、ストア管理
      ...mapGetters("bbs-info", [
        "selectedCondition",
        "getDefaultCondition",
        "searchedBbsList",
        "isOnlyUnread",
        "userId",
        "userName",
        "selectedBbsCtlNo",
        "isSelectedCondition",
        // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
        "isNotRun",
        "sortColumn",
        "sortKind",



        // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
      ]),
      ...mapGetters("user", {
        facilityCd: "getFacilityCd",
        dispUserId: "getDispUserId"
      }),
      // add 権限項目追加 chen start
      ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
      // add 権限項目追加 chen end
      ...mapGetters("account-edit", {
        defaultSetting: "getDefaultSetting"
      }),

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
       * @description カテゴリ機能(検索条件)
       */
      selectedCategories() {
        // 検索条件(store)から選択肢にヒットした名前(画面表示用)と管理番号(カテゴリ絞り込み用)を返す
        if (!this.mstBbsKind) {
          return [];
        }

        return this.mstBbsKind.filter(kind =>
          this.selectedCondition.categoryKindList.includes(kind.kindNo)
        );
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

      /**
       * @description 新規掲示板登録レコード
       */
      newRecord() {
        return {
          bbs_ctl_no: null,
          facility_cd: this.facilityCd,
          pat_info: { target: NOT_USER, detail: [] },
          staff_info: {
            target: [],
            read: []
          },
          func_cd: "020",
          kind_no: null,
          fn_seq_id: null, // 内容管理番号(観察記録等)
          content: null,
          file_info: [],
          /* mod FNSI-434 改修内容 "掲示板のみに表示施設カレンダのみに表示 趙立強 start*/
          // notice_start_date: dayjs().format(),
          // notice_end_date: dayjs().format(),
          notice_start_date: dayjs().format("YYYY-MM-DD"),
          notice_end_date: dayjs().format("YYYY-MM-DD"),
          /* mod FNSI-434 改修内容 "掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
          reg_staff_id: null,
          reg_staff_name: null,
          upd_staff_id: null,
          upd_staff_name: null,
          transition_router_path: null,
          reg_date: null,
          up_date: null,
          /* mod FNSI-434 改修内容 "掲示板のみに表示施設カレンダのみに表示 趙立強 start*/
          // notice_fac_cal_start_date: dayjs().format(),
          // notice_fac_cal_end_date: dayjs().format(),
          notice_fac_cal_start_date: dayjs().format("YYYY-MM-DD"),
          notice_fac_cal_end_date: dayjs().format("YYYY-MM-DD"),
          notice_fac_cal_start_time: this.startHour + "" +this.startMinutes,
          notice_fac_cal_end_time: this.startHour + "" +this.startMinutes,
          title: null,
          is_disp_bbs: "1",
          is_time_start_flg: "1",
          is_time_end_flg: "1",
          /* mod FNSI-434 改修内容 "掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
          color: null,
          /*FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start*/
          font_color:null,
          /*FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end*/
        };
      },

      hasSelectedCategory() {
        return this.selectedCategories.length > 0;
      },

      isFreeWord() {
        const freeWord = this.selectedCondition.freeWord;
        return !(freeWord === null || freeWord === "");
      },

      isNoticeStartDate() {
        const noticeStartDate = this.selectedCondition.noticeStartDate;
        return !(noticeStartDate === null || noticeStartDate === "");
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

      showOnlyUnread: {
        get() {
          return this.isOnlyUnread;
        },
        set() {
          this.setSelectCreatedBbs(null);
          this.setIsOnlyUnread(!this.isOnlyUnread);
        }
      },

      ALL_USER() {
        return ALL_USER;
      },
      NOT_USER() {
        return NOT_USER;
      },
      isValidTreatmentDate() {
        if(!this.searchCondition.kur ||
          (this.searchCondition.kur  && this.searchCondition.dialysisDate != null && this.searchCondition.dialysisDate != "")){
          return  false;
        } else {
          return  true;
        }
      },
      /* add FNSI-434 改修内容 "掲示板のみに表示施設カレンダのみに表示 趙立強 start*/
      startHour(){
       return new Date().getHours()>9?new Date().getHours():"0"+new Date().getHours();
      },
      startMinutes(){
        return new Date().getMinutes()>9?new Date().getMinutes():"0"+new Date().getMinutes();
      },
      /* add FNSI-434 改修内容 "掲示板のみに表示施設カレンダのみに表示 趙立強 end*/
      // add 権限項目追加 chen start
      allowEdit() {
        return this.checkedAuthority.includes(AUTHORITY_CODES.FCL_EDIT);
      }
      // add 権限項目追加 chen end
    },

    watch: {
      selectedCondition() {
        // 画面をリロードした際、設定した検索条件と表示内容を一致させるため、storeの検索条件を吹き出しに設定
        // storeに影響させないためディープコピーを行う。
        // 検索popoverでストアを変更し、検索ヘッダを更新する用
        this.searchCondition = deepCopy(this.selectedCondition);
        // 検索条件表示を更新
        this.setConditionList();
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

    beforeUnmount() {
      EventBus.$off("isNotEdited", this.onIsNotEdited);
      // mod 画面パフォーマンス対応 chen start
      this.mstBbsKind = null;
      this.mstKur = null;
      this.mstRoomBedGroup = null;
      this.searchCondition = null;
      this.popoverVisible = null;
      this.popoverTarget = null;
      this.popoverDirection = null;
      this.isMessage = null;
      this.message = null;
      this.isSearching = null;
      this.settingBbs = null;
      this.initCategoryKindList = null;
      this.conditionList = null;
      this.msgDiaLog = null;
      this.showErrorStartDate = null;
      this.showErrorEndDate = null;
      this.showErrorDialysisDate = null;
      this.checkedAuthority = null;
      // mod 画面パフォーマンス対応 chen end
    },

    /**
     * @description 検索条件のプルダウンリスト(選択肢)を取得するため選択肢マスタから各データ取得
     */
    async created() {
      if(!this.isSelectedCondition) {
        this.setIsOnlyUnread(true);
        // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
        this.setIsNotRun(true);
        // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
      }
      // add 権限項目追加 chen start
      this.checkedAuthority = this.getStateUserAccountInfo.userSettings.authorized_authorities;
      // add 権限項目追加 chen end
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
        getErrorMessage('BbsHeader.vue', 'created', 'マスタ取得失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // console.log(`API:"[PatBbsHeader.vue]created(): マスタ取得失敗");
        // console.log(error);
      });

      // 選択肢設定
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

      // 検索条件カテゴリ初期値設定
      if (this.getDefaultCondition === null) {
        this.$nextTick(() => {
          this.setUserDefaultSettings();
        });
      } else {
        this.searchCondition = this.selectedCondition;
        this.setConditionList();
      }

      // 掲示板詳細内容の編集有無を取得
      EventBus.$off("isNotEdited", this.onIsNotEdited);
      EventBus.$on("isNotEdited", this.onIsNotEdited);
    },

    mounted() {
      EventBus.$emit("addLeftmostHeaderMargin");
    },

    methods: {
      onIsNotEdited(data) {
        this.isNotEdited = data;
      },
      getHeaderInputByClassName(className) {
        return getScopedElementsByClassName(className, this.popoverTarget || this.$el || null)?.[0] || null;
      },

      // ※検索条件はログイン中保持するため、ストア管理
      ...mapActions("bbs-info", [
        "setSelectedCondition",
        "setDefaultCondition",
        "setSelectedBbs",
        "setIsOnlyUnread",
        "setSearchedList",
        "setSelectedBbsInfo",
        "setIsSelectedCondition",
        "setSelectCreatedBbs",
        // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
        "setIsNotRun",
        // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
        "setRegFuncClass",
        "setHTMLContent",
      ]),
      ...mapGetters("app", ["getQueryParameters"]),
      ...mapActions("app", ["setQueryParameters"]),
      popoverPreShow,
      popoverPostShow,
      popoverPosthide,

      /**
       * @description 吹き出し表示
       */
      showPopover(event) {
        // ストアに保持している検索条件（検索エリアに表示している条件）を吹き出しに表示
        this.searchCondition = deepCopy(this.selectedCondition);
        // 吹き出し表示位置
        this.popoverTarget = event;
        // 吹き出し表示
        this.popoverVisible = true;
      },

      /**
       * @description 検索条件クリア
       */
      dialogClear() {
        // 検索条件カテゴリ初期値設定
        this.searchCondition = deepCopy(this.getDefaultCondition);
      },

      /**
       * @description 吹き出し閉じる
       */
      dialogOk() {
        // 吹き出しを閉じる
        this.popoverVisible = false;

        // 検索条件をstore設定※サインイン時に検索条件を保持するため
        // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
        this.searchCondition.limitFrom = 0;
        this.searchCondition.limitTo = PAGE_SIZE;
        if (this.isOnlyUnread) {
          // 未読のみフラグON
          this.searchCondition.userId = this.userId;
        } else {
          this.searchCondition.userId = null;
        }
        // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
        this.setSelectedCondition(this.searchCondition);
        if (!this.isSelectedCondition) {
          // 検索条件を設定していない場合
          this.setIsSelectedCondition(true);
        }

        // this.message = "掲示一覧検索中...";
        // this.search();
        EventBus.$emit("search");
      },

      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      onlyUnreadClick() {
        // this.message = "掲示一覧検索中...";
        this.searchCondition.limitFrom = 0;
        this.searchCondition.limitTo = PAGE_SIZE;
        if (!this.isOnlyUnread) {
          // 未読のみフラグON
          this.searchCondition.userId = this.userId;
        } else {
          this.searchCondition.userId = null;
        }
        let sortTmp = this.sortKind;
        if (sortTmp != "normal") {
          this.searchCondition.sortColumn = this.sortColumn;
          this.searchCondition.sortKind = sortTmp;
        } else {
          this.searchCondition.sortColumn = null;
          this.searchCondition.sortKind = null;
        }
        this.setSelectedCondition(this.searchCondition);
        if (!this.isSelectedCondition) {
          // 検索条件を設定していない場合
          this.setIsSelectedCondition(true);
        }
        // this.search();
        EventBus.$emit("search");
      },
      // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end

      /**
       * @description 検索実行
       */
      async search() {
        this.isSearching = true;

        const searchCondition = { ...this.searchCondition };
        // "YYYYMMDD"へ変換し検索
        searchCondition.noticeStartDate = this.formattedDate(
          searchCondition.noticeStartDate
        );
        searchCondition.noticeEndDate = this.formattedDate(
          searchCondition.noticeEndDate
        );
        searchCondition.dialysisDate = this.formattedDate(
          searchCondition.dialysisDate
        );

        // 検索結果の掲示板、患者名をstoreに設定
        await this.setSearchedList({
          selectedCondition: searchCondition,
          facilityCd: this.facilityCd
        });

        this.setSelectCreatedBbs(null);
        // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
        this.setIsNotRun(true);
        // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
        this.isSearching = false;
      },

      /**
       * @description 共通検索エリア部品に表示するデータのリストを作成
       */
      setConditionList() {
        let condList = [];
        // カテゴリ
        if (this.hasSelectedCategory) {
          let strCat = "";
          this.selectedCategories.forEach(category => {
            strCat = strCat + category.kindName + "、";
          });
          condList.push({ name:"カテゴリ", text:strCat.slice(0, -1) });
        }
        // フリーワード
        if (this.isFreeWord) {
          condList.push({ name:"フリーワード", text: this.freeWord });
        }
        // 掲載日
        const start = this.noticeStartDate ? this.noticeStartDate : "";
        const end = this.noticeEndDate ? this.noticeEndDate : "";
        if (start || end) {
          condList.push({ name:"掲載日", text: start + "～" + end });
        }
        // 治療日
        if (this.isDialysisDate) {
          condList.push({ name:"治療日", text: this.dialysisDate });
        }
        // クール
        condList.push({ name:"クール", text: this.isKur ? this.kur : "すべて" });
        // ベッドグループ ・透析室
        if (this.isRoomBedGroup) {
          condList.push({ name:"ベッドグループ ・透析室", text: this.roomBedGroup });
        }
        else {
          condList.push({ name:"ベッドグループ ・透析室", text: "すべて" });
        }
        this.conditionList = condList;
      },

      /**
       * @description 検索用に変更
       */
      formattedDate(date) {
        return date === null || date === ""
          ? null
          : dayjs(date).format("YYYYMMDD");
      },

      /**
       * @description メッセージ返答後処理
       */
      confirm(answer) {
        this.isMessage = false;
        if (answer === "OK") {
          // 全件既読
          this.allRead();
        }
      },

      /**
       * @description カテゴリ(種類)
       */
      selectedKindList(funcCd) {
        // マスタから検索条件(store)にヒットした物を返す
        const kindList = this.kindList(funcCd).filter(record =>
          this.selectedCondition.categoryKindList.includes(record.kindNo)
        );

        // 検索条件(カテゴリ種類)として表示
        return kindList.map(record => record.kindName);
      },

      /**
       * @description カテゴリ種別(カテゴリ機能に伴う種類を返す)
       * @param {String} funcCd
       */
      kindList(funcCd) {
        let master = [];
        // カテゴリ機能に一致する種類を取得
        switch (funcCd) {
          case "020":
            // 掲示板
            if (this.mstBbsKind) {
              master = this.mstBbsKind;
            }
            break;
        }

        return master;
      },

      /**
       * @description 掲示板詳細画面へ遷移の確認
       */
      confirmGoBbsDetailedInfo() {
        this.confirmEdit(this.goBbsDetailedInfo);
      },

      /**
       * @description 掲示板詳細画面へ遷移
       */
      goBbsDetailedInfo() {
        // 選択掲示板クリア
        this.setSelectedBbs(this.newRecord);
        // 遷移
        this.$router.push({ name: "bbs-detailed-info" });
      },

      /**
       * @description 一覧を既読状態へ切替
       */
      async allRead() {
        const bbsInfoList = deepCopy(this.searchedBbsList);

        // 未読のみの一覧を取得
        const notReadList = bbsInfoList.filter(bbs => {
          // 自身の状態を取得
          const userBbs = bbs.staff_info.read.find(
            staff => staff === this.userId
          );
          if (!userBbs) {
            // 自身の状態を既読へ
            return (bbs.staff_info.read.push(this.userId));
          }
        });

        this.message = "掲示板情報を保存しています";
        // 更新日時
        const nowDate = dayjs().format();
        // DB更新
        await updateBbsList(notReadList, this.userId, this.userName, nowDate);

        // 編集内容を詳細画面へ反映
        if (this.selectedBbsCtlNo !== null) {
          this.setSelectedBbsInfo(this.selectedBbsCtlNo);
        }

        // 再度検索をかけて再描画
        // this.search();
        EventBus.$emit("search");
      },

      setNoticeValue(value) {
        if (value === "" || value === null) {
          this.searchCondition.noticeEndDate = null;
        }
      },

      setBedGroupCd(value) {
        const selectedBedGroup = this.mstRoomBedGroup.find(
          mst => mst.roomBedGroupCd === value
        );
        this.searchCondition.roomBedGroup.bedCdList = selectedBedGroup.bedList ? selectedBedGroup.bedList : [];
      },

      async setUserDefaultSettings() {
        // ユーザーのデフォルト設定がないときの共通設定
        this.searchCondition.categoryFuncList = ["020"];
        this.searchCondition.categoryKindList = this.initCategoryKindList;
        this.searchCondition.freeWord = "";
        this.searchCondition.noticeStartDate = dayjs().format("YYYY-MM-DD");
        this.searchCondition.noticeEndDate = dayjs().format("YYYY-MM-DD");
        this.searchCondition.dialysisDate = null;
        this.searchCondition.kur = null;
        this.searchCondition.roomBedGroup = { bedGroupCd: null, bedCdList: [] };

        // サインインユーザのデフォルト設定を確認・設定
        const defaultBbsInfo = this.defaultSetting[BBS_INFO.KEY_NAME];
        if (defaultBbsInfo) {
          // カテゴリ
          if (defaultBbsInfo[BBS_INFO.KEY_NAME_CATEGORY_KIND_LIST] !== undefined) {
            const bbsKindNos = this.mstBbsKind.map(kind => kind.kindNo);
            // NOTE: 削除済みは除外して設定
            this.searchCondition.categoryKindList = defaultBbsInfo[BBS_INFO.KEY_NAME_CATEGORY_KIND_LIST].filter(value => bbsKindNos.includes(value));
          }
          // 掲載日・開始日
          if (defaultBbsInfo[BBS_INFO.KEY_NAME_NOTICE_START_DATE] !== undefined &&
            defaultBbsInfo[BBS_INFO.KEY_NAME_NOTICE_START_DATE] !== null &&
            defaultBbsInfo[BBS_INFO.KEY_NAME_NOTICE_START_DATE] !== "") {
            this.searchCondition.noticeStartDate = calcTargetDate(defaultBbsInfo[BBS_INFO.KEY_NAME_NOTICE_START_DATE]);
          }
          // 掲載日・終了日
          if (defaultBbsInfo[BBS_INFO.KEY_NAME_NOTICE_END_DATE] !== undefined &&
            defaultBbsInfo[BBS_INFO.KEY_NAME_NOTICE_END_DATE] !== null &&
            defaultBbsInfo[BBS_INFO.KEY_NAME_NOTICE_END_DATE] !== "") {
            this.searchCondition.noticeEndDate = calcTargetDate(defaultBbsInfo[BBS_INFO.KEY_NAME_NOTICE_END_DATE]);
          }
          // 治療日
          if (defaultBbsInfo[BBS_INFO.KEY_NAME_DIALYSIS_DATE] !== undefined &&
            defaultBbsInfo[BBS_INFO.KEY_NAME_DIALYSIS_DATE] !== null &&
            defaultBbsInfo[BBS_INFO.KEY_NAME_DIALYSIS_DATE] !== "") {
            this.searchCondition.dialysisDate = calcTargetDate(defaultBbsInfo[BBS_INFO.KEY_NAME_DIALYSIS_DATE]);
          }
          // クール
          if (defaultBbsInfo[BBS_INFO.KEY_NAME_KUR] !== undefined &&
            defaultBbsInfo[BBS_INFO.KEY_NAME_KUR] !== "" &&
            this.mstKur.some(kur => +kur.kurCd === +defaultBbsInfo[BBS_INFO.KEY_NAME_KUR])) {
            this.searchCondition.kur = Number(defaultBbsInfo[BBS_INFO.KEY_NAME_KUR]);
          }
          // ベッドグループ・透析室
          if (defaultBbsInfo[BBS_INFO.KEY_NAME_BED_GROUP_CD] !== undefined &&
            defaultBbsInfo[BBS_INFO.KEY_NAME_BED_GROUP_CD] !== "") {
            if(this.mstRoomBedGroup.some(rbr => rbr.roomBedGroupCd === Number(defaultBbsInfo[BBS_INFO.KEY_NAME_BED_GROUP_CD])))
            {
              this.searchCondition.roomBedGroup.bedGroupCd = Number(defaultBbsInfo[BBS_INFO.KEY_NAME_BED_GROUP_CD]);
              this.setBedGroupCd(Number(defaultBbsInfo[BBS_INFO.KEY_NAME_BED_GROUP_CD]));
            }
          }
          // 未読のみ
          if (defaultBbsInfo[BBS_INFO.KEY_NAME_SHOW_ONLY_UNREAD] !== undefined) {
            this.setSelectCreatedBbs(null);
            this.setIsOnlyUnread(defaultBbsInfo[BBS_INFO.KEY_NAME_SHOW_ONLY_UNREAD]);
          }
        }

        // 画面遷移パラメータ取得
        const queryParameters = this.getQueryParameters();

        if (queryParameters.DATE) {
          // 掲載日・終了日
          this.searchCondition.noticeStartDate = queryParameters.DATE;
          this.searchCondition.noticeEndDate = queryParameters.DATE;
        }
        this.setQueryParameters({});

        // 検索条件初期設定をstore設定
        this.setDefaultCondition(this.searchCondition);
        // 検索条件初期設定をstore設定
        this.setSelectedCondition(this.searchCondition);
      },

      confirmEdit(func) {
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
        const htmlContent = "<p><span style='font-family: Meiryo; font-size: 14pt;'>" + defaultContents + "</span></p>";
        // 登録元機能の設定
        this.setRegFuncClass(0);
        // HTMLContentの設定
        this.setHTMLContent(htmlContent);
        // 未編集の場合
        if (this.isNotEdited) {
          func();
        } else {
          this.$ons.notification.confirm({
             // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
             // title: "内容破棄",
             title: DIALOG_MESSAGES[13000004].title,
             // message: "編集内容が破棄されます。</br>よろしいですか？",
             message: messageFormat(DIALOG_MESSAGES[13000004].message),
             // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                func();
              }
            }
          });
        }
      },

      confirmAllRead() {
        const setIsMessageTrue = () => (this.isMessage = true);
        this.confirmEdit(setIsMessageTrue);
      },
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
      }
      /*add FNSI-改修内容日付のチェックの追加対応。 趙立強 end*/
    }
  };
</script>

<!-- 個別スタイル定義 -->
<style scoped>
/* mod FNSI-改修内容4224bug修正 関 start */
  /* .checkbox-area,
  .number-area{ */
    /* 一覧の文字色 */
    /* color: var(--ntss-list-body-color);
  } */
  .checkbox-area{
    /* 一覧の文字色 */
    color: var(--ntss-list-body-color);
  }
/* mod FNSI-改修内容4224bug修正 関 end */
/* add FNSI-改修内容4224bug修正 関 start */
  .number-area {
    color: #ffffff;
    font-size: 1.7em;
    text-align: center;
    display: flex;
    align-items: center;
  }
/* add FNSI-改修内容4224bug修正 関 end */
/* mod FNSI-改修内容4016bug修正 関 start */
  /* .condition-search-col {
    height: 6em;
    flex: 0 0 55%;
  } */
   .condition-search-col {
    height: 6em;
    flex: 0 0 45%;
  }
/* mod FNSI-改修内容4016bug修正 関 end */
  .checkbox-area {
    flex: 0 0 10%;
  }
  /* mod FNSI-改修内容4224bug修正 関 start */
  /* .number-area {
    flex: 0 0 5%;
  } */
  .number-area {
    flex: 0 0 10%;
  }
  /* mod FNSI-改修内容4224bug修正 関 start */
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
/* mod FNSI-改修内容4467bug修正 関 start */
  /* .pop-area {
    max-height: 380px;
    overflow-y: auto;
    margin: 10px;
  } */
  .pop-area {
    max-height: 55vh;
    overflow-y: auto;
    margin: 10px;
  }
/* mod FNSI-改修内容4467bug修正 関 end */
  .condition-button-area {
    height: 30px;
    margin: 10px;
    text-align: center;
    background-image: none;
  }

  .clear-button {
    float: left;
  }

  .ok-button {
    float: right;
  }

  .condition-notice {
    word-break: break-all;
    -webkit-box-orient: vertical;
    -webkit-line-clamp: 1;
    overflow: hidden;
    text-align: center;
    line-height: 22px;
    display: inline-block;
    padding-top: 6px;
    padding-bottom: 1px;
    padding-left: 4px;
    padding-right: 4px;
  }

  .pop-title {
    flex: 0 0 40%;
  }

  .pop-category-kind {
    padding-left: 20px;
  }

  .input-checkbox {
    border: solid 1px;
    border-color: gray;
    border-radius: 50%;
  }
/* mod FNSI-改修内容4224bug修正 関 start */
  /* .checkbox-area,
  .number-area,
  .create-area,
  .state-area {
    text-align: center;
    display: flex;
    align-items: center;
    font-size: 1.5em;
  } */
  .checkbox-area,
  .create-area,
  .state-area {
    text-align: center;
    display: flex;
    align-items: center;
    font-size: 1.5em;
  }
/* mod FNSI-改修内容4224bug修正 関 end */
  .create-button,
  .state-button {
    width: auto;
    font-size: 1em;
    display: inline-table;
    background-image: -webkit-linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
    background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
    /*del FNSI-改修内容redmine4225 任 start*/
    /*box-shadow: 0 2px 2px 0 rgba(255,255,255,.2) inset,0 2px 20px 0 rgba(255,255,255,.5) inset,0 -2px 2px 0 rgba(0,0,0,.1);*/
    /*del FNSI-改修内容redmine4225 任 end*/
  }

  .input-area {
    width: 75%;
  }

  .input-area.ntss-input-date {
    padding-right: 2px;
  }

  .input-area::-webkit-calendar-picker-indicator {
    display: none;
  }

  .popover-area :deep(.popover-mask) {
    z-index: 100;
  }

  .popover-area :deep(.popover) {
    z-index: 200;
    min-width: 430px;
  }
  /* #9760 掲示版の新規登録と全て既読のスイッチがはみ出ている 張博 start */
  .style-text-button {
    margin: 0;
    line-height: initial;
    height: 1.2em;
  }
  /* #9760 掲示版の新規登録と全て既読のスイッチがはみ出ている 張博 end */

  @media screen and (max-width: 420px) {
    .condition-search-col {
      flex: 0 0 40%;
    }
    /* mod FNSI-改修内容5009bug修正 関 start */
    /* .checkbox-area {
      height: 70px;
    } */
    .checkbox-area {
      height: 50px;
    }
    /* mod FNSI-改修内容5009bug修正 関 end */
    .create-area,
    .state-area {
      padding: 1px;
    }

    .style-text-button {
      margin: 0;
      line-height: 14px;
      font-size: 10px;
    }

    .number-area,
    .checkbox-lable {
      font-size: 10px;
    }
    /* add FNSI-改修内容4224bug修正 関 start */
    .number-area {
    flex: 0 0 5%;
  }
    /* add FNSI-改修内容4224bug修正 関 end */
  }

  .error-message {
    font-size: 0.8em;
  }
/* add FNSI-改修内容4016bug修正 関 start */
.content-area-t{
    flex-wrap:nowrap;
}
.checkbox-lable{
  min-width: 50px;
}
:deep(.k-legacy-multiselect input.k-input) {
  width: 49px !important;
}
/* add FNSI-改修内容4016bug修正 関 end */
</style>
