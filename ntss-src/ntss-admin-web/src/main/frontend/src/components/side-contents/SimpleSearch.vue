<template>
  <div class="simple-search-area">
    <div @click="isConditonVisible = !isConditonVisible">
      <div class="color-header search-header">検索条件</div>
    </div>
    <div v-show="isConditonVisible" class="search-area-border">
      <div style="overflow-x: hidden; overflow-y: auto;">
        <table class="search-area" style="white-space: nowrap;">
          <!-- bug #3854 修正 chen start -->
            <!-- <input style="display:none" type="text"/>
          <input style="display:none" type="password" autocomplete="new-password"/> -->
          <!-- bug #3854 修正 chen end -->
          <tr>
            <td>
              <v-ons-input v-model="freeWord" type="text" @keydown.enter="search(); restFuncNam();" placeholder="フリーワード"/>
            </td>
          </tr>
          <tr>
            <td class="flex-align-center" style="display: block !important;">
              <label class="treatDate-title">治療日</label>
              <!--mod   日付のチェックの追加対応 吉 start-->
<!--              <input v-model="treatDate" class="ntss-input-date" type="date" />-->
<!--              <common-calendar v-model="treatDate" />-->
              <div class="radio_box_dis">
                <div>
                  <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
                  <!-- <div class="date-input">
                    <input v-model="treatDate" class="ntss-input-date treatDate" max="9999-12-31" id="date-input" @keyup="showStartMsg" @blur="getStartDate" type="date" />
                    <v-ons-toolbar-button class="close-btn">
                      <v-ons-icon icon="md-face"></v-ons-icon>
                    </v-ons-toolbar-button>
                  </div> -->
                  <date-input
                    v-model="treatDate"
                    id="date-input"
                    classes="treatDate"
                    @keyup="showStartMsg"
                    @blur="getStartDate"
                    @handleClearInput="treatDate = ''"
                  />
                  <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
                  <!--mod   7778 limingyang start-->
                  <common-calendar
                    v-model="treatDate"
                    :cardDiff="cardDiff"
                    class="calender treatDate-comment"
                  /><br/>
                  <!--mod   7778 limingyang end-->
                  <span class="error-message" v-if="showErrorStartDate">{{
                    this.msgDiaLog
                  }}</span>
                </div>

                <!--mod   日付のチェックの追加対応 吉 end-->
                <!--add 5273  吉 start-->
                <div class="method radio_dis">
                  <div class="checkboxbox">
                  <v-ons-checkbox
                    style="margin-left: 0.2em"
                    input-id="checboxo"
                    value="1"
                    v-model="rstDialysisState"
                  >
                  </v-ons-checkbox>  <span for="checboxo" class="label">予定</span>
                  </div>
                  <div class="checkboxbox">
                  <v-ons-checkbox
                    style="margin-left: 0.2em"
                    input-id="checboxt"
                    value="2"
                    v-model="rstDialysisState"
                  >
                  </v-ons-checkbox >  <span for="checboxt" class="label">実績</span>
                  </div>
                </div>
              </div>

              <!--add 5273  吉 start-->
            </td>
          </tr>
          <tr>
            <td class="week-area">
              <v-ons-row>
                <v-ons-col style="display: flex;">
                  <div v-for="(week, index) in indWeeks" :key="index">
                    <input
                      v-model="treatDayOfWeekList"
                      class="week-checkbox"
                      type="checkbox"
                      :value="week.value"
                      :checked="week.done"
                      :id="'ssWeekCheck-' + index"
                      style="display: none;"
                      @change="changeValue(week, $event.target.checked)"
                    />
                    <label :for="'ssWeekCheck-' + index" onclick="null" style="cursor:pointer;" class="week-button">{{ week.text }}</label>
                  </div>
                </v-ons-col>
              </v-ons-row>
            </td>
          </tr>
          <tr>
            <td>
              <kendo-multiselect
                v-if="mstKur !== null"
                v-model="kurCdList"
                :data-source="mstKur"
                data-text-field="kurName"
                data-value-field="kurCd"
                placeholder="クール"
                @change="calculateTableHeight()"
              />
            </td>
          </tr>
          <tr>
            <td>
              <v-ons-select v-model="bedGroupCd">
                <option :value="0">全ベッド</option>
                <option
                  v-for="mst in mstBedGroup"
                  :key="mst.roomBedGroupCd"
                  :value="mst.roomBedGroupCd"
                >
                  {{ mst.roomBedGroupName }}
                </option>
              </v-ons-select>
            </td>
          </tr>

          <!-- Patient groups -->
          <tr class="pat-groups" v-show="isShowPatGroup">
            <td>
              <!-- mod FutreNetWeb+SI課題管理 No4072 趙 start -->
              <!-- <kendo-multiselect
                v-model="selectedPatGroups"
                :data-source="patGroups"
                data-text-field="patGroupName"
                data-value-field="patGroupCd"
                placeholder="患者グループ"
                @open="getPatGroups"
              /> -->
              <!-- mod 4768 患者グループにID・PW管理リストが表示して選択の邪魔になる 吉 start -->
              <!--<kendo-multiselect
                v-model="selectedPatGroups"
                :data-source="patGroups"
                data-text-field="patGroupName"
                data-value-field="patGroupCd"
                placeholder="患者グループ"
                @open="getPatGroups"
                @change="calculateTableHeight"
              />-->

              <kendo-multiselect
                v-model="selectedPatGroups"
                :data-source="patGroups"
                data-text-field="patGroupName"
                data-value-field="patGroupCd"
                placeholder="患者グループ"
                @open="getPatGroups"
                @change="calculateTableHeight"
                autocomplete="new-password"
              />
              <!-- mod 4768 患者グループにID・PW管理リストが表示して選択の邪魔になる 吉 end -->
              <!-- mod FutreNetWeb+SI課題管理 No4072 趙 end -->
              <div class="method">
                <!-- or -->
                <label class="radio vertical-align-center">
                  <!--mod   吉 start-->
                  <!--<v-ons-radio
                    value="1"
                    modifier="round"
                    v-model="queryPatGroupsMethod"
                    name="conditions"
                  >-->
                  <v-ons-radio
                    value="1"
                    modifier="round"
                    v-model="queryPatGroupsMethod"
                  >
                  <!--mod   吉 end-->
                  </v-ons-radio>
                  <span class="label">含む</span>
                </label>
                <!-- / or -->

                <!-- and -->
                <label class="radio vertical-align-center">
                  <!--mod   吉 start-->
                  <!--<v-ons-radio
                    modifier="round"
                    value="2"
                    v-model="queryPatGroupsMethod"
                    name="conditions"
                  >-->
                    <v-ons-radio
                      modifier="round"
                      value="2"
                      v-model="queryPatGroupsMethod"
                    >
                    <!--mod   吉 end-->
                  </v-ons-radio>                  <span class="label">一致する</span>
                </label>
                <!-- / and -->
              </div>
            </td>
          </tr>
          <!-- / Patient groups -->

          <tr>
            <td>
              <!-- mod FutreNetWeb+SI課題管理No3805対応 趙 start -->
              <!-- <v-ons-select v-model="searchQuery" > -->
              <v-ons-select v-model="searchQueryChange" @change="changeQuery(searchQueryChange)">
              <!-- mod FutreNetWeb+SI課題管理No3805対応 趙 end -->
                <option :value="null" style="display:none;">ｶｽﾀﾑ検索</option>
                <option :value="0"></option>
                <!-- mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start -->
                <!-- mod FutreNetWeb+SI課題管理No3805対応 趙 start -->
                <!-- <option
                  v-for="(el, index) in userQuery"
                  :key="index"
                  :value="el.query"
                > -->
                <option
                  v-for="(el, index) in userQuery"
                  :key="index"
                  :value="el.queryId"
                >
                <!-- mod FutreNetWeb+SI課題管理No3805対応 趙 end -->
                <!-- mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end -->
                  {{ el.queryName }}
                </option>
              </v-ons-select>
            </td>
          </tr>
        </table>
     </div>

      <span class="button-area">
        <!--mod FNSI-改修内容画面デザイン 任 start-->
        <!--<v-ons-button
          class="clear-button common-style-cancel-button"
          @click="initCondtions() "
        >
          初期化
        </v-ons-button>
        <v-ons-button
          class="clear-button common-style-cancel-button"
          @click="clearCondtions()"
        >
          クリア
        </v-ons-button>
        &lt;!&ndash; 検索が実行された時に、検索結果一覧の表示に戻す &ndash;&gt;
        &lt;!&ndash;mod FNSI-改修内容日付のチェックの追加対応。 吉 start&ndash;&gt;
        &lt;!&ndash;<v-ons-button
          class="search-button common-style-ok-button"
          @click="search(); restFuncNam();"
        >&ndash;&gt;
            <v-ons-button
              :disabled="showErrorStartDate"
              class="search-button common-style-ok-button"
              @click="search(); restFuncNam();"
            >-->
        <v-ons-button
          class="clear-button common-style-cancel-button btn2-cancel"
          @click="initCondtions() "
        >
          初期化
        </v-ons-button>
        <v-ons-button
          class="clear-button common-style-cancel-button btn2-cancel"
          @click="clearCondtions()"
        >
          クリア
        </v-ons-button>
        <!-- 検索が実行された時に、検索結果一覧の表示に戻す -->
        <!--mod FNSI-改修内容日付のチェックの追加対応。 吉 start-->
        <!--<v-ons-button
          class="search-button common-style-ok-button"
          @click="search(); restFuncNam();"
        >-->
            <v-ons-button
              :disabled="showErrorStartDate"
              :style="patSearchTypeColor"
              class="search-button common-style-ok-button btn3-normal"
              @click="search(); restFuncNam();"
            >
              <!--mod FNSI-改修内容画面デザイン 任 end-->
          <!--mod FNSI-改修内容日付のチェックの追加対応。 吉 end-->
          検索
        </v-ons-button>
      </span>
    </div>

    <v-ons-modal :visible="isSearching">
      <!-- mod 患者検索フォントサイズ対応 趙 start-->
      <!-- <p class="searching-modal">
        患者検索中...
        <v-ons-icon icon="fa-spinner" spin />
      </p> -->
      <p class="loading-modal">
        患者検索中...
        <v-ons-icon icon="fa-spinner" spin />
      </p>
      <!-- mod 患者検索フォントサイズ対応 趙 end-->
    </v-ons-modal>
  </div>
</template>

<script>
  import _ from "underscore";
  import moment from "moment";
  import {mapActions, mapGetters, mapMutations} from "vuex";
  import {ApiHelper} from "@/apis/AxiosHelper";
  import PatGroup from "@/apis/pat-group";
  import {FUNC_PAT_GROUP} from "@/constants/function-code";
  import {PATIENT_SEARCH} from "@/constants/defaultSettingConstants";
  import {deepCopy} from "@/functions/common/CommonFunctions";
  // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
  import DateInput from "@/components/common/DateInput.vue";
  // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
  // mod FNSI-改修内容 ｶｽﾀﾑ検索を選択した後、「検索」ボタンをクリックすると、ページにエラーが表示されます dou start
  import {SearchQuery} from "./SearchDefinitions.js";
  // 共通関数
  import {formatDatetime} from "@/functions/common/CommonFunctions.js";
  // 共通カレンダーコンポーネント
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
  /*add FNSI-改修内容日付のチェックの追加対応。 吉 start*/
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
  /*add FNSI-改修内容日付のチェックの追加対応。 吉 end*/
  // add FNSI-No.341 患者リストのソート項目不足 吉 start
  import {EventBus} from "@/eventBus.js";
  // mod FNSI-改修内容 ｶｽﾀﾑ検索を選択した後、「検索」ボタンをクリックすると、ページにエラーが表示されます dou end
  // add FNSI-No.341 患者リストのソート項目不足  吉 end
  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
  import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
  import { confirmAllowDiscardChangesInRequestList } from "@/functions/exam-request/ExamRequestFunctions";
  import { confirmAllowDiscardChangesInMultiPatList } from "@/components/multi-pat-list/Functions";
  import { getKurCds } from "@/functions/modals/default-setting/defaultSettingUtils";

/**
 * @description 簡易検索
 */
export default {
  // 共通タグコンポーネント読み込み
  components: {
    "common-calendar": commonCalender,
    // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
    DateInput
    // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
  },

  props: {
    userQuery: {
      type: Array,
      default() {
        return [];
      }
    }
  },

  data() {
    return {
      // add 7778 limingyang start
      cardDiff:true,
      // add 7778 limingyang end
      freeWord: "",
      treatDate: moment().format("YYYY-MM-DD"),
      treatDayOfWeekList: [],
      kurCdList: [],
      bedGroupCd: 0,
      mstKur: null,
      mstBedGroup: null,
      isSearching: false,
      isConditonVisible: true,
      multiselectValue: "",
      indWeeks: [
        {
          text: "全",
          done: false,
          value: 0
        },
        {
          text: "月",
          done: false,
          value: 1
        },
        {
          text: "火",
          done: false,
          value: 2
        },
        {
          text: "水",
          done: false,
          value: 3
        },
        {
          text: "木",
          done: false,
          value: 4
        },
        {
          text: "金",
          done: false,
          value: 5
        },
        {
          text: "土",
          done: false,
          value: 6
        },
        {
          text: "日",
          done: false,
          value: 7
        }
      ],
      searchQuery: null,
      // add FutreNetWeb+SI課題管理No3805対応 趙 start
      searchQueryChange: null,
      // add FutreNetWeb+SI課題管理No3805対応 趙 end
      patGroups: [],
      selectedPatGroups: [],
      queryPatGroupsMethod: '2',
      /*add FNSI-改修内容日付のチェックの追加対応。 吉 start*/
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorStartDate: false,
      dateUmpt:"",
      /*add FNSI-改修内容日付のチェックの追加対応。 吉 end*/

      rstDialysisState:[],
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    /*mod  吉 start*/
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    /*mod  吉 end*/
    ...mapGetters("pat-info", ["selectedPatId", "patSearchType"]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getDefaultSetting: "getDefaultSetting"
    }),
    //治療患者リスト取得用
    ...mapGetters("pat-info", [
      "srcFuncName"
    ]),
    ...mapGetters("facility", ["useFunction"]),

    /**
     * @description 検索条件オブジェクト
     * @returns {Object} { ord_schedule, facilityCdList }
     */
    conditions() {
      let ord_schedule = null;
      if (
        !_.isEmpty(this.formattedTreatDate) ||
        !_.isEmpty(this.kurCdList) ||
        !_.isEmpty(this.bedGroupCd) ||
        !_.isEmpty(this.treatDayOfWeekList)||
        !_.isEmpty(this.rstDialysisState)
      ) {
        ord_schedule = {
          treatDate: this.formattedTreatDate,
          kurCdList: this.kurCdList,
          bedGroupCd: this.bedGroupCd === 0 ? null : this.bedGroupCd,
          treatDayOfWeekList: this.treatDayOfWeekList,
          rstDialysisState : this.rstDialysisState,
        };
      }
      //add   吉 start
      var patGroups;
      if(null != this.getStorSimlpSearchQurey.selectedPatGroups){
        patGroups = this.getStorSimlpSearchQurey.selectedPatGroups;
      }else{
        patGroups = this.selectedPatGroups;
      }
      //add   吉 end
      return {
        ord_schedule,
        facilityCdList: [this.facilityCd],
        patGroupSearch: {
          patGroupCd: patGroups,
          searchType: +this.queryPatGroupsMethod
        }
      };
    },

    formattedTreatDate() {
      return formatDatetime(this.treatDate, "YYYYMMDD");
    },

    isShowPatGroup() {
      return this.useFunction.includes(FUNC_PAT_GROUP);
    },

    // 検索ボタンから検索が実施された場合にボタンの色を変更
    patSearchTypeColor() {
      let rtn = {};
      // patSearchType が簡易検索(1)の場合、且つ画面遷移後でない場合
      if (this.patSearchType === 1 && this.srcFuncName === "") {
        rtn = {"background-image": "linear-gradient(#2ca06f, #2ca06f) !important"};
      }
      return rtn;
    }
  },

  watch: {
    isConditonVisible() {
      setTimeout(() => {
        if (document.getElementsByClassName("pat-list-area") && document.getElementsByClassName("pat-list-area")[0]) {
          const wh = this.windowHeight;
          const tableTop = document.getElementsByClassName("pat-list-area")[0].getBoundingClientRect().top;
          const fmh =
            (this.isDispMenu === 1
              ? document.getElementById("footer-menu").clientHeight
              : 0);
          document.getElementsByClassName("pat-list-area")[0].style.height = (wh - tableTop - fmh - 10) + "px";
        }else if(document.getElementsByClassName("pat-list-grid-area") && document.getElementsByClassName("pat-list-grid-area")[0]){
          // 機能別患者リストの高さ調整のイベントを発火
          EventBus.$emit("calculatePatListGridHeight");
        }
      }, 100);
    },
    // 機能名称の有無で表示するリストの切替を実施
    srcFuncName() {
      if (this.srcFuncName !== "" ) {
        // 検索条件を閉じる
        this.isConditonVisible = false;
      } else {
        this.isConditonVisible = true;
      }
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 吉 start*/
    treatDate() {
      // del 6577 患者検索のクリアを押下するとソート条件がクリアされる 周安寧　start
      //EventBus.$emit("setDreatDate", this.treatDate);
      // del 6577 患者検索のクリアを押下するとソート条件がクリアされる 周安寧　end
      // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
      this.setPatSearchedTreatDate(this.treatDate);
      // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
      setTimeout(() => {
        if(document.getElementsByClassName("treatDate")[0].validationMessage !== ""){
          this.showErrorStartDate = !(document.getElementsByClassName("treatDate")[0].value === "" && document.getElementsByClassName("treatDate-comment")[0].value !== "");
        }else{
          this.showErrorStartDate = false;
        }
      }, 100);
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 吉 end*/
    // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
    rstDialysisState(newValue) {
      if (newValue.length > 1) {
        this.rstDialysisState = [newValue[newValue.length - 1]];
      }
    }
    // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
  },

  async created() {
    // クール、ベッドグループ、患者グループマスタ取得
    await this.loadMasterData();
    // del 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 start
    //add   吉 start
    // const param = this.getStorSimlpSearchQurey;
    // if(null != param && null != param.queryPatGroupsMethod){
    //   this.$nextTick(() => {
    //     this.freeWord = param.freeWord;
    //     this.treatDate=param.treatDate;
    //     this.treatDayOfWeekList=param.treatDayOfWeekList;
    //     this.kurCdList=param.kurCdList;
    //     this.bedCdListString=param.bedCdListString;
    //     this.selectedPatGroups=param.selectedPatGroups;
    //     this.queryPatGroupsMethod=param.queryPatGroupsMethod;
    //     // add 5273 吉 start
    //     if(null == param.rstDialysisState){
    //       this.rstDialysisState = [];
    //     }else{
    //       this.rstDialysisState = param.rstDialysisState;
    //     }

    //     // add 5273 吉 end
    //     if(null != param.searchQuery && param.searchQuery != 0){
    //       this.searchQuery =param.searchQuery;
    //       // add FutreNetWeb+SI課題管理No3805対応 趙 start
    //       this.searchQueryChange = param.searchQueryChange;
    //       // add FutreNetWeb+SI課題管理No3805対応 趙 end
    //     }else{
    //       this.searchQuery = null;
    //       // add FutreNetWeb+SI課題管理No3805対応 趙 start
    //       this.searchQueryChange = null;
    //       // add FutreNetWeb+SI課題管理No3805対応 趙 end
    //     }
    //   })
    // }
    // //add   吉 end
    // // add FutreNetWeb+SI課題管理No4299対応 趙 start
    // else{
    //   const defaultCondition = deepCopy(this.getDefaultSetting[PATIENT_SEARCH.KEY_NAME]);
    //   if (defaultCondition) {
    //     if (defaultCondition[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS] != null) {
    //       this.$nextTick(() => {
    //       this.selectedPatGroups = defaultCondition[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS];
    //       })
    //     }
    //   }
    // }
    // add FutreNetWeb+SI課題管理No4299対応 趙 end
    // del 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 end
    // 初期設定の適用
    // mod 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 start
    //this.setDefaultCondition();
    setTimeout(() => {
      this.setDefaultCondition();
      // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
      let detailedCondtion = null;
      if (this.searchQuery) {
         detailedCondtion = new SearchQuery(this.searchQuery).createCondition([
          this.facilityCd
        ]);
      }else{
        detailedCondtion = this.simpleConditions();
        detailedCondtion.ord_main.simpleSearchTreatDate = this.treatDate;
        detailedCondtion.ord_main.simpleSearchRstDialysisState = this.rstDialysisState;
        detailedCondtion.ord_schedule.simpleSearchTreatDayOfWeekList = this.treatDayOfWeekList;
        detailedCondtion.ord_schedule.simpleSearchKurCdList = this.kurCdList;
        detailedCondtion.ord_schedule.simpleSearchBedGroupCd = this.bedGroupCd;
      }
      this.setSearchedDetailedCondtion(detailedCondtion);
      // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
      // add #11055 画面の最新状態を元に帳票出力するようにする 高 start
      EventBus.$on('invokeSearch', this.search);
      if (this.$route.path.includes('report-menu')) {
        this.search();
      }
      // add #11055 画面の最新状態を元に帳票出力するようにする 高 end
    });
    // mod 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 end
    // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
    this.setPatSearchedTreatDate(this.treatDate);
    // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
  },
  // add #11055 画面の最新状態を元に帳票出力するようにする 高 start
  beforeDestroy() {
    EventBus.$off("invokeSearch");
  },
  // add #11055 画面の最新状態を元に帳票出力するようにする 高 end
  methods: {
    // add  吉 start
    ...mapMutations("periodic-inspection", [
      "setStorSimlpSearchQurey",
    ]),
    // add   吉 end
    ...mapActions("pat-info", ["clearSearchedPatList", "setSearchedPatList"]),
    ...mapActions("treatment-record/common", ["setOrdNoForSideBarRecord"]),
    // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    // mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
    // ...mapMutations("pat-info", ["setSrcFuncName", "setPatSearchType"]),
    ...mapMutations("pat-info", ["setSrcFuncName", "setPatSearchType","setPatSearchedTreatDate","setSearchedDetailedCondtion"]),
    // mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
    // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    ...mapMutations("report-menu", ["setSelectedTreatDate"]),
    /**
     * @description 検索実行
     */
    async search(needConfirm = true) {
      /*add  吉 start*/
      var setStorSearchQurey= {
        freeWord:"",
        treatDate:"",
        treatDayOfWeekList:[],
        kurCdList:[],
        bedGroupCd: 0,
        selectedPatGroups:[],
        queryPatGroupsMethod:"",
        searchQuery:null,
        // add FutreNetWeb+SI課題管理No3805対応 趙 start
        searchQueryChange:null,
        // add FutreNetWeb+SI課題管理No3805対応 趙 end
        // add 5273 吉 start
        rstDialysisState:[],
        // add 5273 吉 end
        // 帳票の検索条件対応
        // mod #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
        // selectedBedGName: "複数ベッドグループ",
        // selectedKurName: "複数クール",
        selectedBedGName: "すべて",
        selectedKurName: "すべて",
        // mod #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
        // add #11009 カテゴリ「印刷情報」の優先対応 高 start
        selectKurNameNewReport: "すべて",
        // add #11009 カテゴリ「印刷情報」の優先対応 高 end
        // add 11010 スケジュール表出力時の処理が不足している 吉 start
        kurList: [],
        bedCdList: [],
        // add 11010 スケジュール表出力時の処理が不足している 吉 end
        // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
        selectedPatGroupNames: null,
        kurNames: []
        // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
      };
      /*add  吉 end*/
      /*add 検索条件ログ対応 吉 start*/
      var msg="患者検索が[";
      if(null != this.freeWord && ""!=this.freeWord){
        msg+=this.freeWord+'、';
        setStorSearchQurey.freeWord=this.freeWord;
      }
      if(null != this.treatDate && "" != this.treatDate){
        setStorSearchQurey.treatDate=this.treatDate;
        msg+=this.treatDate+'、';
      }
      var week="";
      if(null != this.treatDayOfWeekList && this.treatDayOfWeekList.length>0){
        setStorSearchQurey.treatDayOfWeekList=this.treatDayOfWeekList;
        for(var i=0;i<this.indWeeks.length;i++){
          for(var k=0;k<this.treatDayOfWeekList.length;k++){
            if(this.indWeeks[i].value == this.treatDayOfWeekList[k]){
              week+=this.indWeeks[i].text+'、'
            }
          }
        }
        week=week.substring(0,week.lastIndexOf('、'))
        msg+=week+'、';
      }
      var kurList="";
      // add 11010 スケジュール表出力時の処理が不足している 吉 start
      var kurArr = [];
      // add 11010 スケジュール表出力時の処理が不足している 吉 end
      if(null != this.kurCdList && this.kurCdList.length>0){
        setStorSearchQurey.kurCdList = this.kurCdList;
        for(i=0;i<this.mstKur.length;i++){
          for(k=0;k<this.kurCdList.length;k++){
            if(this.mstKur[i].kurCd == this.kurCdList[k]){
              kurList+=this.mstKur[i].kurName+'、'
              // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
              setStorSearchQurey.kurNames.push(this.mstKur[i].kurName);
              // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
              // add 11010 スケジュール表出力時の処理が不足している 吉 start
              kurArr.push(this.mstKur[i].kurCd)
              // add 11010 スケジュール表出力時の処理が不足している 吉 end
            }
          }
        }
        // 帳票の検索条件対応 ( 未選択、複数件選択：複数クール、1件選択の場合はクール名を表示する )
        if (kurList.split("、").length == 2) {
          setStorSearchQurey.selectedKurName = kurList.split("、")[0];
        }
        kurList=kurList.substring(0,kurList.lastIndexOf('、'))
        msg+=kurList+'、';
        // add #11009 カテゴリ「印刷情報」の優先対応 高 start
        if (kurList != "") {
          setStorSearchQurey.selectKurNameNewReport = kurList.replace("、","・");
          // add 11010 スケジュール表出力時の処理が不足している 吉 start
          setStorSearchQurey.kurList = kurArr;
          // add 11010 スケジュール表出力時の処理が不足している 吉 end
        }
        // add #11009 カテゴリ「印刷情報」の優先対応 高 end
      }
      var bedList = "";
      setStorSearchQurey.bedGroupCd = this.bedGroupCd;
      for(i=0;i<this.mstBedGroup.length;i++){
        if(this.mstBedGroup[i].roomBedGroupCd == this.bedGroupCd){
          bedList+=this.mstBedGroup[i].roomBedGroupName;
          // 帳票の検索条件対応 (ベッドグループ名を表示)
          setStorSearchQurey.selectedBedGName = this.mstBedGroup[i].roomBedGroupName;
          // add 11010 スケジュール表出力時の処理が不足している 吉 start
          setStorSearchQurey.bedCdList = this.mstBedGroup[i].bedList
          // add 11010 スケジュール表出力時の処理が不足している 吉 end
        }
      }
      msg += bedList === "" ? "全ベッド" : bedList;
      msg += "、";

      var selectedPatGroupsStr="";
      if(null != this.selectedPatGroups && this.selectedPatGroups.length>0){
        // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
        let tempGroupNames = [];
        this.selectedPatGroups.forEach(el => {
          tempGroupNames.push(this.patGroups[this.patGroups.findIndex(obj => obj.patGroupCd == el)].patGroupName);
        })
        setStorSearchQurey.selectedPatGroupNames = tempGroupNames.join("・");
        // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
        setStorSearchQurey.selectedPatGroups=this.selectedPatGroups;
        for(i=0;i<this.patGroups.length;i++){
          for(k=0;k<this.patGroups.length;k++){
            if(this.patGroups[i].patGroupCd == this.selectedPatGroups[k]){
              selectedPatGroupsStr+=this.patGroups[i].patGroupName+'、'
            }
          }
        }
        selectedPatGroupsStr=selectedPatGroupsStr.substring(0,selectedPatGroupsStr.lastIndexOf('、'))
        msg+=selectedPatGroupsStr+'、';
      }
      var queryPatGroupsMethodStr=this.queryPatGroupsMethod == "1" ? '含む' : '一致する';
      setStorSearchQurey.queryPatGroupsMethod = this.queryPatGroupsMethod;
      msg+=queryPatGroupsMethodStr+'、';
      // add 5273 吉 start
      if(null != this.rstDialysisState && this.rstDialysisState.length >0){
        if(this.rstDialysisState.length== 2){
          var rstDialysisStateStr ='[予定,実績]';
          msg+=rstDialysisStateStr+'、';
        }else{
          if(this.rstDialysisState[0] == 1){
            rstDialysisStateStr ='[予定]';
            msg+=rstDialysisStateStr+'、';
          }else{
            rstDialysisStateStr ='[実績]';
            msg+=rstDialysisStateStr+'、';
          }
        }
      }
      setStorSearchQurey.rstDialysisState=this.rstDialysisState;
      // add 5273 吉 end
      var searchQueryStr="";
      if(null != this.searchQuery){
        setStorSearchQurey.searchQuery=this.searchQuery;
        for(i=0;i<this.userQuery.length;i++){
          if(this.userQuery[i].query == this.searchQuery){
            searchQueryStr+=this.userQuery[i].queryName
          }
        }
        msg+=searchQueryStr+'、';
      }
      if(msg != "患者検索が["){
        msg = msg.substring(0,msg.lastIndexOf("、"))
        msg +="]で検索しました。";
        let paramObj = {'message': msg, 'functionName': '患者検索'};
        ApiHelper.put("/logs/event/conditionlog", paramObj)
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('SimpleSearch.vue', 'search', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          });
      }
      /*add 検索条件ログ対応 吉 end*/
      if (needConfirm) {
        const confirm =
          await confirmAllowDiscardChangesInRequestList() &&
          await confirmAllowDiscardChangesInMultiPatList();
        // 検査依頼、一般撮影検査依頼、データリスト＞患者情報1 破棄確認キャンセルの場合はreturn
        if (!confirm) return;
      }

      this.setSelectedTreatDate(this.formattedTreatDate);
      this.isSearching = true;

      let searchedPatList = [];
      // add 9580 サイドコンテンツの患者詳細検索にて全患者検索で患者一覧をクリアしていない zhou start
      let searchFlag = false ;
      // add 9580 サイドコンテンツの患者詳細検索にて全患者検索で患者一覧をクリアしていない zhou end
      // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
      // if (this.searchQuery !== null && this.searchQuery !== 0) {
      if (this.searchQuery) {
        // add 9580 サイドコンテンツの患者詳細検索にて全患者検索で患者一覧をクリアしていない zhou start
        searchFlag = true ;
        // add 9580 サイドコンテンツの患者詳細検索にて全患者検索で患者一覧をクリアしていない zhou end
        // クエリが指定されていたら詳細検索実行
        const uriDetailed = "/patInfo/getDetailedSearchResult";
        this.searchQuery.simpleSearchTreatDate = null;
        this.searchQuery.simpleSearchRstDialysisState = null;
        this.searchQuery.simpleSearchTreatDayOfWeekList = null;
        this.searchQuery.simpleSearchKurCdList = null;
        this.searchQuery.simpleSearchBedGroupCd = null;
        this.searchQuery.simpleSearchPatGroupSearch = null;
        if (this.conditions.ord_schedule !== null && this.searchQuery) {
          this.searchQuery.simpleSearchTreatDate = this.conditions.ord_schedule.treatDate;
          this.searchQuery.simpleSearchRstDialysisState = this.conditions.ord_schedule.rstDialysisState;
          this.searchQuery.simpleSearchTreatDayOfWeekList = this.conditions.ord_schedule.treatDayOfWeekList;
          this.searchQuery.simpleSearchKurCdList = this.conditions.ord_schedule.kurCdList;
          this.searchQuery.simpleSearchBedGroupCd = this.conditions.ord_schedule.bedGroupCd;
        }
        if(null != this.selectedPatGroups){
            this.conditions.patGroupSearch.patGroupCd=this.selectedPatGroups;
          }
        if(this.conditions.patGroupSearch != null && this.searchQuery){
           this.searchQuery.simpleSearchPatGroupSearch = this.conditions.patGroupSearch;
          }
        // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
        // mod FNSI-改修内容 ｶｽﾀﾑ検索を選択した後、「検索」ボタンをクリックすると、ページにエラーが表示されます dou start
        // const detailedCondtion = this.searchQuery.createCondition([
        const detailedCondtion = new SearchQuery(this.searchQuery).createCondition([
        // mod FNSI-改修内容 ｶｽﾀﾑ検索を選択した後、「検索」ボタンをクリックすると、ページにエラーが表示されます dou end
          this.facilityCd
        ]);
        const resDetailed = await ApiHelper.post(
          uriDetailed,
          detailedCondtion
        ).catch(() => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('SimpleSearch.vue', 'search', "[SearchPatSimple.vue]searchPat(): クエリ検索失敗");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          this.isSearching = false;
          throw new Error("[SearchPatSimple.vue]searchPat(): クエリ検索失敗");
        });
        searchedPatList = resDetailed.data;
        // add FutreNetWeb+SI課題管理No3805対応 趙 start
        setStorSearchQurey.searchQueryChange = this.searchQueryChange;
        // add FutreNetWeb+SI課題管理No3805対応 趙 end
        /*add  吉 start*/
        this.setStorSimlpSearchQurey(setStorSearchQurey);
        /*add  吉 end*/
      }
      // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
      // if (this.conditions.ord_schedule !== null || this.searchQuery === null || this.searchQuery === 0) {
      if (!this.searchQuery) {
        // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
        // add 9580 サイドコンテンツの患者詳細検索にて全患者検索で患者一覧をクリアしていない zhou start
        if ((searchFlag && searchedPatList && searchedPatList.length > 0) || !searchFlag) {
          // add 9580 サイドコンテンツの患者詳細検索にて全患者検索で患者一覧をクリアしていない zhou end
          // 簡易条件指定あり、またはクエリ指定なしの場合は簡易検索API実行
          const uriSimple = "/patInfo/getSimpleSearchResult";
          // クエリ検索結果があるなら患者IDのみ取り出す
          const searchedPatIdList = searchedPatList.map(pat => pat.pat_id);
          //add   吉 start
          // if(null == this.conditions.patGroupSearch.patGroupCd || "" == this.conditions.patGroupSearch.patGroupCd){
          //   this.conditions.patGroupSearch.patGroupCd=[];
          // }
          if(null != this.selectedPatGroups){
            this.conditions.patGroupSearch.patGroupCd=this.selectedPatGroups;
          }
          //add   吉 end
          const resSimple = await ApiHelper.post(uriSimple, {
            ...this.conditions,
            patIdList: searchedPatIdList
          }).catch(() => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('SimpleSearch.vue', 'search', "[SearchPatSimple.vue]searchPat(): 簡易検索失敗");
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            this.isSearching = false;
            throw new Error("[SearchPatSimple.vue]searchPat(): 簡易検索失敗");
          });
          searchedPatList = resSimple.data;
          // add FutreNetWeb+SI課題管理No3805対応 趙 start
          setStorSearchQurey.searchQueryChange = this.searchQueryChange;
          // add FutreNetWeb+SI課題管理No3805対応 趙 end
          /*add  吉 start*/
          this.setStorSimlpSearchQurey(setStorSearchQurey);
          /*add  吉 end*/
          // add 9580 サイドコンテンツの患者詳細検索にて全患者検索で患者一覧をクリアしていない zhou start
        }
        // add 9580 サイドコンテンツの患者詳細検索にて全患者検索で患者一覧をクリアしていない zhou end
      }

      // 必要なカラムのみ取り出す
      const patPersonalInfoList = searchedPatList.map(pat => {
        return {
          pat_id: pat.pat_id,
          hosp_pat_id: pat.hosp_pat_id,
          pat_sex: pat.pat_sex,
          pat_last_name: pat.pat_last_name,
          pat_first_name: pat.pat_first_name,
          pat_first_name_kana: pat.pat_first_name_kana,
          pat_last_name_kana: pat.pat_last_name_kana,
          is_same: pat.is_same,
          read_only: pat.readOnly
          // add FNSI-NO423入院患者名の配布 江 start
          ,in_out_class: pat.in_out_class
          // add FNSI-NO423入院患者名の配布 江 end
        };
      });

      // フリーワードでフィルタ
      const filteredPatList = patPersonalInfoList.filter(pat => {
        const patName = `${pat.pat_last_name}${pat.pat_first_name}`;
        // mod 7816 患者検索の検索がエラーになり患者検索中のまま画面が戻らない 関 start
        // const regexp = new RegExp(`.*${this.freeWord}.*`);
        // return regexp.test(patName) || regexp.test(pat.hosp_pat_id);
        const regexp = this.freeWord;
        return (patName != null && patName.includes(regexp)) || (pat.hosp_pat_id != null && pat.hosp_pat_id.includes(regexp));
        // mod 7816 患者検索の検索がエラーになり患者検索中のまま画面が戻らない 関 end
      });

      // 患者リストに追加
      this.setSearchedPatList(filteredPatList);

      this.isSearching = false;
      // add FutreNetWeb+SI課題管理 No4072 趙 start
      this.calculateTableHeight();
      // add FutreNetWeb+SI課題管理 No4072 趙 end
      // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
      let detailedCondtion = null;
      if (this.searchQuery) {
         detailedCondtion = new SearchQuery(this.searchQuery).createCondition([
          this.facilityCd
        ]);
      }else if (this.conditions.ord_schedule != null) {
        detailedCondtion = this.simpleConditions();
        detailedCondtion.ord_main.simpleSearchTreatDate = this.conditions.ord_schedule.treatDate;
        detailedCondtion.ord_main.simpleSearchRstDialysisState = this.conditions.ord_schedule.rstDialysisState;
        detailedCondtion.ord_schedule.simpleSearchTreatDayOfWeekList = this.conditions.ord_schedule.treatDayOfWeekList;
        detailedCondtion.ord_schedule.simpleSearchKurCdList = this.conditions.ord_schedule.kurCdList;
        detailedCondtion.ord_schedule.simpleSearchBedGroupCd = this.conditions.ord_schedule.bedGroupCd;
      }
      this.setSearchedDetailedCondtion(detailedCondtion);
      // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
      //add 5368 患者の入外状態の色変更が正しく行われない 吉 start
      this.$emit("handleClickChange")
      //add 5368 患者の入外状態の色変更が正しく行われない 吉 end
    },
    // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    simpleConditions() {
      return {
        ord_schedule: {
          simpleSearchTreatDate: null,
          simpleSearchTreatDayOfWeekList: null,
          simpleSearchKurCdList: null,
          simpleSearchBedGroupCd: null
        },
        ord_main: {
          simpleSearchRstDialysisState: null
        }
      };
    },
    // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    /**
     * @description 初期化ボタン処理
     */
    async initCondtions() {
      const confirm =
        await confirmAllowDiscardChangesInRequestList() &&
        await confirmAllowDiscardChangesInMultiPatList();
      // 検査依頼、一般撮影検査依頼、データリスト＞患者情報1 破棄確認キャンセルの場合はreturn
      if (!confirm) return;
      
      // クール、ベッドグループ、患者グループマスタ取得
      await this.loadMasterData();

      // 患者リストクリア
      this.clearSearchedPatList();
      // 各条件初期化
      this.freeWord = "";
      this.treatDate = moment().format("YYYY-MM-DD");
      this.rstDialysisState = []; // 予定／実績チェックボックスOFF
      this.treatDayOfWeekList = [];
      this.kurCdList = [];
      this.bedGroupCd = 0; // ベッドグループ
      this.searchQuery = null;
      // add FutreNetWeb+SI課題管理No3805対応 趙 start
      this.searchQueryChange = null;
      // add FutreNetWeb+SI課題管理No3805対応 趙 end
      // add FutreNetWeb+SI課題管理No4299対応 趙 start
      this.selectedPatGroups = [];
      // デフォルト設定
      const defaultCondition = deepCopy(this.getDefaultSetting[PATIENT_SEARCH.KEY_NAME]);
      if (defaultCondition) {
        // ベッドグループ
        if (defaultCondition[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST] != null) {
          this.bedGroupCd = defaultCondition[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST];
          // ベッドグループがマスタから削除されている場合は初期値にする
          if (!this.mstBedGroup.some(item => item.roomBedGroupCd === this.bedGroupCd)) {
            this.bedGroupCd = 0;
          }
        }
        // 患者グループ
        if (defaultCondition[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS] != null) {
          this.selectedPatGroups = defaultCondition[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS];
          // 患者グループがマスタから削除されている場合は配列内のから対象コードを削除
          const validPatGroupCds = this.patGroups.map(item => item.patGroupCd);
          this.selectedPatGroups = this.selectedPatGroups.filter(value => validPatGroupCds.includes(value));
        }
        // 患者グループ 含む／一致する
        if (defaultCondition[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD] != null) {
          this.queryPatGroupsMethod = defaultCondition[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD];
        }
      }
      // add FutreNetWeb+SI課題管理No4299対応 趙 end
      this.indWeeks.forEach(item => {
        item.done = false;
      });

      // クールは現在時刻のクールを設定
      if (this.mstKur !== null) {
        // mstKurから現在時刻が範囲内のクールコードの配列を取得
        this.kurCdList = getKurCds(this.mstKur);
      }

      // 初期化後に検索実施
      this.search(false);
      this.restFuncNam();
      // add FutreNetWeb+SI課題管理 No4072 趙 start
      this.calculateTableHeight();
      // add FutreNetWeb+SI課題管理 No4072 趙 end
    },
    /**
     * @description クリアボタン処理
     */
    async clearCondtions() {
      // クール、ベッドグループ、患者グループマスタ取得
      await this.loadMasterData();
      
      // 各条件初期化
      // add クリアボタンでクールがクリアされたが、画面上でクリアされない。 吉 start
      this.bedGroupCd = 0;
      // add クリアボタンでクールがクリアされたが、画面上でクリアされない。  吉 end
      this.freeWord = "";
      /*mod FNSI-改修内容日付のチェックの追加対応。 吉 start*/
      // this.treatDate = "";
      this.treatDate = moment().format("YYYY-MM-DD");
      this.$nextTick(() => {
        this.treatDate = "";
      });
      // add 5273 吉 start
      this.rstDialysisState=[];
      // add 5273 吉 end
      /*mod FNSI-改修内容日付のチェックの追加対応。 吉 start*/
      this.treatDayOfWeekList = [];
      this.kurCdList = [];
      this.searchQuery = null;
      // add FutreNetWeb+SI課題管理No3805対応 趙 start
      this.searchQueryChange = null;
      // add FutreNetWeb+SI課題管理No3805対応 趙 end
      this.selectedPatGroups = [];
      this.indWeeks.forEach(item => {
        item.done = false;
      });
      // add FutreNetWeb+SI課題管理 No4072 趙 start
      this.calculateTableHeight();
      // add FutreNetWeb+SI課題管理 No4072 趙 end
    },

    changeValue(week, value) {
      week.done = value;

      let isDoneAll = true;

      // [全]が押されたら動作
      if (week.value === 0) {
        // 全ての曜日を格納するために空にする
        if (week.done) {
          this.treatDayOfWeekList = [];
        }
        // 全ての曜日を[全]と同じBoolean値へ
        this.indWeeks.forEach(item => {
          if (item.value !== 0) {
            item.done = week.done;
          }
          // 全ての曜日を格納
          if (week.done) {
            this.treatDayOfWeekList.push(item.value);
          } else if (
            !week.done &&
            this.treatDayOfWeekList.includes(item.value)
          ) {
            // 全ての曜日を配列から削除
            this.treatDayOfWeekList = _.without(
              this.treatDayOfWeekList,
              item.value
            );
          }
        });
      } else {
        // [全]以外が押されたら動作
        // 曜日が1つでもfalseの場合[全]をfalseへ
        this.indWeeks.forEach(item => {
          if (item.value !== 0 && !item.done) {
            isDoneAll = false;
          }
        });
        // 「全」にBooleanを設定
        this.indWeeks[0].done = isDoneAll;

        if (this.indWeeks[0].done) {
          // 配列から「全」を追加
          this.treatDayOfWeekList.push(this.indWeeks[0].value);
        } else {
          // 配列から「全」を削除
          this.treatDayOfWeekList = _.without(
            this.treatDayOfWeekList,
            this.indWeeks[0].value
          );
        }
      }
    },

    async getPatGroups() {
      const { data } = await PatGroup.list(this.facilityCd);
      this.patGroups = data.patGroupInfo;
    },

    // 検索が実行された時に、検索結果一覧の表示に戻す
    restFuncNam() {
      this.setSrcFuncName("");
      // 画面遷移後のリストで選択されている ord_no の初期化
      this.setOrdNoForSideBarRecord(null);
      // 検索タイプを(1：簡易)に設定
      this.setPatSearchType(1);
    },

    // add FutreNetWeb+SI課題管理No3805対応 趙 start
    changeQuery(value) {
      // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
      // this.searchQuery = value.query;
      this.searchQuery = value != 0 ? this.userQuery.filter(item => item.queryId ==value)[0].query : null;
      // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    },
    // add FutreNetWeb+SI課題管理No3805対応 趙 end

    // -----------------------------------------
    // 個人設定で登録した初期値をStoreに登録する
    // -----------------------------------------
    setDefaultCondition() {
      // 初期値を入れる
      this.kurCdList = [];
      this.bedGroupCd = 0;
      this.selectedPatGroups = [];
      this.queryPatGroupsMethod = '2';
      // add 5273 吉 start
      this.rstDialysisState=[];
      // add 5273 吉 end
      // デフォルト設定
      // add 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 start
      const param = this.getStorSimlpSearchQurey;
      if(null != param && null != param.queryPatGroupsMethod){
          this.freeWord = param.freeWord;
          this.treatDate=param.treatDate;
          this.treatDayOfWeekList=param.treatDayOfWeekList;
          this.kurCdList=param.kurCdList;
          this.bedGroupCd=param.bedGroupCd;
          this.selectedPatGroups=param.selectedPatGroups;
          this.queryPatGroupsMethod=param.queryPatGroupsMethod;
          if(null == param.rstDialysisState){
            this.rstDialysisState = [];
          }else{
            this.rstDialysisState = param.rstDialysisState;
          }
          if(null != param.searchQuery && param.searchQuery != 0){
            this.searchQuery =param.searchQuery;
            this.searchQueryChange = param.searchQueryChange;
          }else{
            this.searchQuery = null;
            this.searchQueryChange = null;
          }
    }
    else{
      const defaultCondition = deepCopy(this.getDefaultSetting[PATIENT_SEARCH.KEY_NAME]);
      if (defaultCondition) {
         // デフォルト設定が存在する場合は適用
          if (defaultCondition[PATIENT_SEARCH.KEY_NAME_KUR_CD_LIST] != null) {
            this.kurCdList = defaultCondition[PATIENT_SEARCH.KEY_NAME_KUR_CD_LIST];
          }
          if (defaultCondition[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST] != null) {
            this.bedGroupCd = defaultCondition[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST];
            // ベッドグループがマスタから削除されている場合は初期値にする
            if (!this.mstBedGroup.some(item => item.roomBedGroupCd === this.bedGroupCd)) {
              this.bedGroupCd = 0;
            }
          }
          if (defaultCondition[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS] != null) {
            this.selectedPatGroups = defaultCondition[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS];
            // 患者グループがマスタから削除されている場合は配列内のから対象コードを削除
            const validPatGroupCds = this.patGroups.map(item => item.patGroupCd);
            this.selectedPatGroups = this.selectedPatGroups.filter(value => validPatGroupCds.includes(value));
          }
          if (defaultCondition[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD] != null) {
            this.queryPatGroupsMethod = defaultCondition[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD];
          }
      }
     }
     // add 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 end
     // del 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 start
      // if (defaultCondition) {
      //   // デフォルト設定が存在する場合は適用
      //   if (defaultCondition[PATIENT_SEARCH.KEY_NAME_KUR_CD_LIST] != null) {
      //     this.kurCdList = defaultCondition[PATIENT_SEARCH.KEY_NAME_KUR_CD_LIST];
      //   }
      //   if (defaultCondition[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST] != null) {
      //     this.bedCdListString = defaultCondition[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST];
      //   }
      //   // del FutreNetWeb+SI課題管理No4299対応 趙 start
      //   // if (defaultCondition[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS] != null) {
      //   //     this.selectedPatGroups = defaultCondition[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS];
      //   // }
      //   // del FutreNetWeb+SI課題管理No4299対応 趙 end
      //   if (defaultCondition[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD] != null) {
      //     this.queryPatGroupsMethod = defaultCondition[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD];
      //   }
      // del 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 end
        // サインイン時の検索条件(印刷用)の保存
        let setStorSearchQurey= {
          freeWord:"", // フリーワード：デフォルト設定に存在しない為、初回は必ず空欄
          treatDate:"",
          treatDayOfWeekList:[], // 曜日設定：デフォルト設定に存在しない為、初回は必ず「[]」
          kurCdList:[],
          bedGroupCd: 0,
          selectedPatGroups:[],
          queryPatGroupsMethod:"",
          searchQuery:null, // カスタム検索：デフォルト設定に存在しない為、初回は必ずnull
          searchQueryChange:null, // カスタム検索：デフォルト設定に存在しない為、初回は必ずnull
          rstDialysisState:[], // 予定、実績：デフォルト設定に存在しない為、初回は必ず「[]」
          // mod #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
          // selectedBedGName: "複数ベッドグループ",
          // selectedKurName: "複数クール",
          selectedBedGName: "すべて",
          selectedKurName: "すべて",
          // mod #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
          // add #11009 カテゴリ「印刷情報」の優先対応 高 start
          selectKurNameNewReport: "すべて",
          // add #11009 カテゴリ「印刷情報」の優先対応 高 end
          // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
          selectedPatGroupNames: null,
          kurNames: []
          // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
        };
        // 検査日
        if (null != this.treatDate && "" != this.treatDate) {
          setStorSearchQurey.treatDate=this.treatDate;
        }
        // クール名
        let kurList="";
        if (null != this.kurCdList && this.kurCdList.length>0) {
          for (let i=0; i<this.mstKur.length; i++) {
            for (let k=0; k<this.kurCdList.length; k++) {
              if (this.mstKur[i].kurCd == this.kurCdList[k]) {
                kurList+=this.mstKur[i].kurName+'、'
                // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
                setStorSearchQurey.kurNames.push(this.mstKur[i].kurName);
                // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
              }
            }
          }
          // 帳票の検索条件対応 ( 未選択、複数件選択：複数クール、1件選択の場合はクール名を表示する )
          if (kurList.split("、").length == 2) {
            setStorSearchQurey.selectedKurName = kurList.split("、")[0];
          }
          // add #11009 カテゴリ「印刷情報」の優先対応 高 start
          if (kurList != "") {
            setStorSearchQurey.selectKurNameNewReport = kurList.replace("、","・");
          }
          // add #11009 カテゴリ「印刷情報」の優先対応 高 end
        }
        // ベッドグループ
        setStorSearchQurey.bedGroupCd = this.bedGroupCd;
        for(let ii=0;ii<this.mstBedGroup.length;ii++){
          if(this.mstBedGroup[ii].roomBedGroupCd == this.bedGroupCd){
            // 帳票の検索条件対応 (ベッドグループ名を表示)
            setStorSearchQurey.selectedBedGName = this.mstBedGroup?.[ii]?.roomBedGroupName;
          }
        }
        // 患者グループ
        if (null != this.selectedPatGroups && this.selectedPatGroups.length>0) {
          setStorSearchQurey.selectedPatGroups=this.selectedPatGroups;
          // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
          let tempGroupNames = [];
          this.selectedPatGroups.forEach(el => {
            tempGroupNames.push(this.patGroups[this.patGroups.findIndex(obj => obj.patGroupCd == el)].patGroupName);
          })
          setStorSearchQurey.selectedPatGroupNames = tempGroupNames.join("・");
          // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
        }
        setStorSearchQurey.queryPatGroupsMethod = this.queryPatGroupsMethod;
        this.setStorSimlpSearchQurey(setStorSearchQurey);
      // del 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 start
      // }
      // del 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 end
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 吉 start*/
    setDateFunc(){
      return false;
    },
    showStartMsg(){
      this.showErrorStartDate = document.getElementsByClassName("treatDate")[0].validationMessage !== "";
    },
    getStartDate(){
      this.showErrorStartDate = document.getElementsByClassName("treatDate")[0].validationMessage !== "";
    },
    /*add FNSI-改修内容日付のチェックの追加対応。 吉 end*/
    // add FutreNetWeb+SI課題管理 No4072 趙 start
    calculateTableHeight(ev) {
      // 患者检索：检索结果不正 linjunfeng start
      if (ev) {
        this.selectedPatGroups = ev.sender._old
      }
      // 患者检索：检索结果不正 linjunfeng end
      EventBus.$emit("calculateTableHeight");
      setTimeout(() => {
        if(document.getElementsByClassName("pat-list-grid-area") && document.getElementsByClassName("pat-list-grid-area")[0]){
          // 機能別患者リストの高さ調整のイベントを発火
          EventBus.$emit("calculatePatListGridHeight");
        }
      }, 100);
    },
    // add FutreNetWeb+SI課題管理 No4072 趙 end
    /**
     * マスタ取得処理
     */
    async loadMasterData() {
      try {
        const [responseKur, responseBedGroup, patGroups] = await Promise.all([
          ApiHelper.get("/mstInfo/mstKur", {
            facility_cd: this.facilityCd,
            is_del: "0"
          }),
          ApiHelper.get("/mstInfo/mstRoomBedGroup", {
            facilityCd: this.facilityCd
          }),
          PatGroup.list(this.facilityCd)
        ]);
    
        this.mstKur = responseKur.data;
        this.mstBedGroup = responseBedGroup.data;
        this.patGroups = patGroups.data.patGroupInfo;
    
      } catch (error) {
        getErrorMessage("SimpleSearch.vue", "loadMasterData", "[SearchPatSimple.vue]loadMasterData(): マスタ取得失敗");
        throw new Error("[SearchPatSimple.vue]loadMasterData(): マスタ取得失敗");
      }
    }
  }
};
</script>

<style scoped>
input,
button,
select {
  font-size: 1em;
}

.search-header {
  text-align: left;
  margin-bottom: 1.5px;
}

.search-area {
  width: 100%;
}

.search-area tr th {
  text-align: left;
}

.search-area tr {
  width: 35%;
}

input[type="text"] {
  display: inline-block;
  box-sizing: border-box;
  width: 100%;
  padding-left:5px;
}

label {
  user-select: none;
}

.clear-button,
.search-button {
  font-size: 1em;
  width: 90px;
}

.select {
  width: 100%;
}

.radio-area {
  text-align: right;
}

.button-area {
  display: flex;
  justify-content: space-between;
  margin: 2px 2px 2px 2px;
}

.week-area {
  width: 74%;
  font-size: 12.5px;
}
/*mod FNSI-画面部品デザイン じょはく start*/
.week-checkbox:checked + label {
  background-color: #9acd32;
  color: #050505;
}
/*mod FNSI-画面部品デザイン じょはく end*/
.week-button {
  padding: 5px 10px;
  float: left;
  border: solid;
  border-color: #c0c0c0;
  border-width: 0.85px;
}
.pat-groups .method {
  height: 2em;
  display: flex;
  justify-content: flex-end;
  align-items: flex-end;
}

.pat-groups .method {
  text-align: right;
}

.pat-groups .method label:first-child {
  margin-right: 1em;
}

.treatDate-title {
  padding-right: 10px;
  display: flex;
  align-items: center;
}

.search-area-border {
  border: 1px solid #dddddd;
  border-top-style: hidden;
  margin: 1px 0px 1px 0px;
}
/* add 患者検索フォントサイズ対応 趙 start */
.loading-modal {
    text-align: center;
    font-size: 30px;
}
/* add 患者検索フォントサイズ対応 趙 end */

::v-deep .k-input{
  width: 200px !important;
}
.radio_dis{
  display: flex;
  flex-wrap: wrap;
  justify-content: space-around;
}
.radio_box_dis{
  display: flex;
  align-items: center;
  justify-content: space-between;
}
  .checkboxbox{
    display: inline-block;
  }
/* #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start */
.date-input{
  position: relative;
  display: inline-block;
}
.date-input .close-btn{
  position: absolute;
  right: 3px;
  padding: 4px 0;
}
/* #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end */
.treatDate-comment{
  width: 25px;
}
</style>
