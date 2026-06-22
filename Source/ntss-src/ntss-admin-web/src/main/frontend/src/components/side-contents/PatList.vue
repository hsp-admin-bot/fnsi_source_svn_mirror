<template>
  <!-- mod 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start -->
  <!-- <div class="pat-list-area"> -->
  <div class="pat-list-area" ref="mianScroll" v-if="srcFuncName === '' || srcFuncName === 'indication'">
    <!-- mod 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end -->
    <table class="pat-area" v-if="srcFuncName === ''">
      <tbody>
      <tr @click="showPopover">
        <th class="color-header">患者ID</th>
        <th class="color-header">
          患者名
          <span class="searched-cnt">{{ searchedCountText }}</span>
        </th>
      </tr>
      <tr
        v-for="patRecord in searchedPatList"
        :key="patRecord.pat_id"
        :class="{'selected-pat' : patRecord.pat_id === selectedPatId}"
      >
        <td>
          <a
            class="pat-id-area"
            href=""
            @click.prevent.stop="setSelectedPat(patRecord.pat_id, null, patRecord.hosp_pat_id,patRecord)"
            >{{ patRecord.hosp_pat_id }}</a
          >
        </td>
        <td>
          <!-- mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou start  -->
          <a
            :class="patRecord.in_out_class === 1 ? 'in_class pat-name-area' : 'pat-name-area'"
            href=""
            @click.prevent.stop="setSelectedPat(patRecord.pat_id, null, patRecord.hosp_pat_id,patRecord)"
          >
            {{ `${patRecord.pat_last_name == null ? "" : patRecord.pat_last_name} ${patRecord.pat_first_name == null ? "" : patRecord.pat_first_name}` }}
            <img class='same-icon' v-show="patRecord.is_same === '1'" :src="image_src_same" />
          </a>
          <!-- mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou end  -->
        </td>
      </tr>
    
      </tbody></table>

    <!-- 各機能からの患者リストを表示している場合に表示する -->
    <!-- 指示受け・指示承認の場合 -->
    <table class="pat-area" v-else>
      <tbody>
      <tr>
        <th v-if="!isIndicationUnitScreen" class="color-header" style="width: 25%;">クール</th>
        <th v-if="!isIndicationUnitScreen" class="color-header" style="width: 25%;">ベッド</th>
        <th v-if="isIndicationUnitScreen" class="color-header">患者ID</th>
        <th class="color-header">
          患者名
          <span class="searched-cnt">{{ searchedCountText }}</span>
        </th>
      </tr>
      <tr
        v-for="patRecord in treatmentPatList"
        :key="patRecord.ord_no"
        :class="{'selected-pat' : patRecord.pat_id == selectedPatId && patRecord.ord_no == getOrdNoForSideBarRecord}"
      >
        <td v-if="!isIndicationUnitScreen" style="text-align: unset;">
          <a
            href=""
            @click.prevent.stop="setSelectedPat(patRecord.pat_id, patRecord.ord_no, patRecord.hosp_pat_id)"
            >{{ patRecord.kur_name }}</a
          >
        </td>
        <td v-if="!isIndicationUnitScreen">
          <a
            href=""
            @click.prevent.stop="setSelectedPat(patRecord.pat_id, patRecord.ord_no, patRecord.hosp_pat_id)"
            >{{ patRecord.bed_name }}</a
          >
        </td>
        <td v-if="isIndicationUnitScreen">
          <a
            class="pat-id-area"
            href=""
            @click.prevent.stop="setSelectedPat(patRecord.pat_id, patRecord.ord_no, patRecord.hosp_pat_id)"
            >{{ patRecord.hosp_pat_id }}</a
          >
        </td>
        <td>
          <a
            :class="patRecord.in_out_class === 1 ? 'in_class pat-name-area' : 'pat-name-area'"
            href=""
            @click.prevent.stop="setSelectedPat(patRecord.pat_id, patRecord.ord_no, patRecord.hosp_pat_id)"
            >{{ patRecord.pat_id ? `${patRecord.pat_last_name == null ? "" : patRecord.pat_last_name}
             ${patRecord.pat_first_name == null ? "" : patRecord.pat_first_name}` : "？？？？患者"}}
            <img class='same-icon' v-show="patRecord.is_same === '1'" :src="image_src_same" />
          </a>
          <!-- mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou end  -->
        <!--mod FNSI-入外区分が入院の場合、患者名は紫色にする dou end -->
        </td>
      </tr>
    
      </tbody></table>

    <v-ons-popover
      cancelable
      :class="[fontSizeSet, 'sort-popover']"
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :cover-target="false"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="sort-condition">
        <div class="pat-list-sort-title">
          第1ソート条件
          <div class="pat-list-sort-condition">
            <v-ons-select v-model="sortConditions[0].key">
              <!-- mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start -->
              <!-- <option
                v-for="option in sortOptions"
                :key="option.key"
                :value="option.key"
              >
                {{ option.displayValue }}
              </option> -->
              <option
                v-for="option in treatmentDateExist"
                :key="option.key"
                :value="option.key"
              >
                {{ option.displayValue }}
              </option>
              <!-- mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end -->
            </v-ons-select>
            <v-ons-select v-model="sortConditions[0].isAsc">
              <option
                v-for="option in sortOrder"
                :key="option.displayValue"
                :value="option.isAsc"
              >
                {{ option.displayValue }}
              </option>
            </v-ons-select>
          </div>
        </div>
        <div class="pat-list-sort-title">
          第2ソート条件
          <div class="pat-list-sort-condition">
            <v-ons-select
              v-model="sortConditions[1].key"
              :disabled="!sortConditions[0].key"
            >
            <!-- mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start -->
            <!-- <option
                v-for="option in sortOptions"
                :key="option.key"
                :value="option.key"
              >
                {{ option.displayValue }}
              </option> -->
              <option
                v-for="option in treatmentDateExist"
                :key="option.key"
                :value="option.key"
              >
                {{ option.displayValue }}
              </option>
              <!-- mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end -->
            </v-ons-select>
            <v-ons-select
              v-model="sortConditions[1].isAsc"
              :disabled="!sortConditions[0].key"
            >
              <option
                v-for="option in sortOrder"
                :key="option.displayValue"
                :value="option.isAsc"
              >
                {{ option.displayValue }}
              </option>
            </v-ons-select>
          </div>
        </div>
        <div class="pat-list-sort-title">
          第3ソート条件
          <div class="pat-list-sort-condition">
            <v-ons-select
              v-model="sortConditions[2].key"
              :disabled="!sortConditions[0].key || !sortConditions[1].key"
            >
            <!-- mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start -->
              <!-- <option
                v-for="option in sortOptions"
                :key="option.key"
                :value="option.key"
              >
                {{ option.displayValue }}
              </option> -->
              <option
                v-for="option in treatmentDateExist"
                :key="option.key"
                :value="option.key"
              >
                {{ option.displayValue }}
              </option>
              <!-- mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end -->
            </v-ons-select>
            <v-ons-select
              v-model="sortConditions[2].isAsc"
              :disabled="!sortConditions[0].key || !sortConditions[1].key"
            >
              <option
                v-for="option in sortOrder"
                :key="option.displayValue"
                :value="option.isAsc"
              >
                {{ option.displayValue }}
              </option>
            </v-ons-select>
          </div>
        </div>
      </div>
      <div class="button-area">
        <v-ons-button
          class="clear-button btn2-cancel common-style-cancel-button"
          @click="popoverVisible = false"
        >
          キャンセル
        </v-ons-button>
        <v-ons-button
          class="search-button btn3-normal common-style-ok-button"
          @click="sort"
        >
          OK
        </v-ons-button>
      </div>
    </v-ons-popover>
    <!--add 患者検索のソートの処理状態を追加 吉 start-->
    <v-ons-modal v-show="islodingFlag">
      <!-- mod 患者検索フォントサイズ対応 趙 start -->
      <!-- <p class="searching-modal">
        患者ソート中...
        <v-ons-icon icon="fa-spinner" spin />
      </p> -->
      <p class="loading-modal">
        患者ソート中...
        <v-ons-icon icon="fa-spinner" spin />
      </p>
      <!-- mod 患者検索フォントサイズ対応 趙 end -->
    </v-ons-modal>
     <!-- add 患者検索のソートの処理状態を追加 吉 end-->
  </div>
  <!-- 上記以外の場合 -->
  <div v-else class="pat-list-grid-area" :style="{'height': kendoGridHeight + 'px'}">
    <div
      id="kendo"
      ref="grid"
      class="grid-area"
    ></div>
  </div>
</template>

<script>
  // ライブラリ
  import {EventBus} from "@/compat/vue/event-bus.js";
  import $$ from "@/compat/jquery";
  import kendo from "@progress/kendo-ui";
  import { markRaw } from "@/compat/vue/runtime";
  import {mapActions, mapGetters, mapMutations} from "@/compat/vue/vuex";
  import nameDuplicationImg from "@/assets/name_duplication.png";
  import PopoverMixin from "@/components/PopoverMixin";
  // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 start
  // import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
  // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 end
  import {PATIENT_SEARCH,SORT_OPTIONS} from "@/constants/defaultSettingConstants.js";
  import {deepCopy} from "@/functions/common/CommonFunctions";
  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
  import {popoverPosthide, popoverPostShow, popoverPreShow} from "@/functions/common/CommonPopoverFunctions";
  // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
  import { messageFormat } from '@/functions/common/MessageFormat';
  // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
  import dayjs from "@/compat/date/dayjs";
  import { ApiHelper } from "@/apis/AxiosHelper";
  import { sortableCompare, addPatNameSortToList } from "@/functions/SortFunctions";

import { getLatestHeaderElement, getHeaderHeight, getFooterMenuClientHeight, getScopedElementsByClassName, queryScopedSelector } from "@/functions/common/LayoutMeasureHelper";

  // ソートキー変換用のマップ
  const SORT_KEY_MAP = {
    kur_name:"kurName", // クール ※共通ソートで別キーにするため、専用のキー名に変換
    bed_name:"bedName", // ベッド ※共通ソートで別キーにするため、専用のキー名に変換
    dialysisState:"rstDialysisState", // 治療状況 ※治療状況は文字列のためrstDialysisStateでソートする
    viewTreatDate: "treatDateForSort", // 治療日 ※viewTreatDateは"YYYY/MM/DD" 形式のためtreatDateでソートする
    startTime: "startTimeForSort", // 開始時刻 ※startTimeは"hh:mm" 形式のためstartTimeForSortでソートする
    endScheduleTime: "endScheduleTimeForSort", // 終了予定 ※endScheduleTimeは"hh:mm" 形式のためendScheduleTimeForSortでソートする
    endTime: "endTimeForSort", // 終了時刻 ※endTimeは"hh:mm" 形式のためendTimeForSortでソートする
    roundState: "roundStateForSort", // 回診 ※roundStateは文字列のためroundStateForSortでソートする
  };


  function createPatListDataSource(options = {}) {
    return markRaw(new kendo.data.DataSource(options));
  }

  export default {
  // mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 start
  // mixins: [PopoverMixin, UserAuthorityMixin],
  mixins: [PopoverMixin],
  // mod 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 end

  data() {
    return {
      popoverTarget: null,
      popoverVisible: false,
      // FNSI-修正、#6129、「beforeSelectPatId」を親対象に遷移、xugj del start
      /*add FNSI-改修内容redmain6647 任 start*/
      //beforeSelectPatId: "",
      /*add FNSI-改修内容redmain6647 任 end*/
      // FNSI-修正、#6129、「beforeSelectPatId」を親対象に遷移、xugj del end
      //add  吉 start
      islodingFlag:false,
      //add  吉 end
      sortConditions: [
        { key: null, isAsc: 1 },
        { key: null, isAsc: 1 },
        { key: null, isAsc: 1 }
      ],
      // mod FNSI-No.341 患者リストのソート項目不足 吉 start
      // sortOptions: [
      //   { key: null, displayValue: "" },
      //   { key: "hosp_pat_id", displayValue: "患者ID" },
      //   { key: "pat_name", displayValue: "患者名(漢字)" },
      //   { key: "pat_name_kana", displayValue: "患者名(フリガナ)" },
      //   { key: "pat_name_alpha", displayValue: "患者名(英語)" },
      //   { key: "in_out_class", displayValue: "入外区分" },
      //   { key: "in_out_current_state", displayValue: "在院状態" },
      //   { key: "pat_birthday_age", displayValue: "生年月日" },
      //   { key: "pat_birthday", displayValue: "年齢" },
      //   { key: "pat_sex", displayValue: "性別" },
      //   { key: "pat_blood_type_abo", displayValue: "血液型" },
      //   { key: "dialysis_start_date", displayValue: "透析歴" },
      //   { key: "pat_kur", displayValue: "クール" },
      //   { key: "pat_bed_name", displayValue: "ベッド名" }
      // ],
      sortOptions: SORT_OPTIONS,
      // mod FNSI-No.341 患者リストのソート項目不足  吉 end
      // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
      sortOptionsNoneTreat: [
        { key: null, displayValue: "　" },
        { key: "hosp_pat_id", displayValue: "患者ID" },
        // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
        // { key: "pat_name", displayValue: "患者名(漢字)" },
        // { key: "pat_name_kana", displayValue: "患者名(フリガナ)" },
        // { key: "pat_name_alpha", displayValue: "患者名(英語)" },
        { key: "pat_name", displayValue: "患者名" },
        // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
        { key: "in_out_class", displayValue: "入外区分" },
        { key: "in_out_current_state", displayValue: "在院状態" },
        { key: "pat_sex", displayValue: "性別" },
        { key: "pat_birthday_age", displayValue: "生年月日" },
        { key: "pat_birthday", displayValue: "年齢" },
        { key: "pat_blood_type_abo", displayValue: "血液型" },
        { key: "taboo_allergy_info", displayValue: "禁忌" },
        { key: "is_infect", displayValue: "感染症" },
        { key: "is_implant", displayValue: "インプラント" },
        { key: "is_diabetes", displayValue: "糖尿病" },
        { key: "is_blood_suger_exam", displayValue: "血糖検査" },
        { key: "dial_diff_com_info", displayValue: "主たる透析困難理由" },
        { key: "severity_cd", displayValue: "重症度" },
        { key: "transport_cd", displayValue: "搬送区分" },
        { key: "is_wheel_chair", displayValue: "車いす利用" },
        { key: "dialysis_start_date", displayValue: "透析歴" },
        { key: "is_dia_under_dis", displayValue: "透析導入原疾患" },
        { key: "is_main_disease", displayValue: "主病" },
        { key: "main_course_cd", displayValue: "診療科" },
        { key: "dialysis_course_cd", displayValue: "透析実施科" },
        { key: "ward_cd", displayValue: "病棟" },
      ],
      // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
      sortOrder: [
        { isAsc: 1, displayValue: "昇順" },
        { isAsc: 0, displayValue: "降順" }
      ],
      //同姓同名アイコン
      image_src_same: nameDuplicationImg,
      // getDataList: []
      // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 start
      // trueFlag: false,
      // authorityCd072and073: false
      // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 end
      treatDate: dayjs().format("YYYY-MM-DD"),
      listDataSource: createPatListDataSource({ data: [] }),
      currentSort: null,
      kendoGridHeight: 400,
      directGridWidget: null,
      directGridColumnSignature: "",
      directGridLayoutRafId: null,
    };
  },

  computed: {
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 start
    // ...mapGetters("exam-request/list", [
    //   "getExamRequestListNoShap",
    //   "getSavePatExamPattern",
    // ]),
    // ...mapGetters("rad-request/list", [
    //   "getRadRequestListNoShap",
    //   "getSavePatRadPattern"
    // ]),
    // isChanged() {
    //   let rtn = false;
    //   //	add 編集可能な権限があるかどうかを判断する 炜 start
    //   if(!this.authorityCd072and073) {
    //     return rtn;
    //   }
    //   //	add 編集可能な権限があるかどうかを判断する 炜 end
    //   // 編集データから検査セット行だけを抽出する
    //   const kensaObjList = this.getExamRequestListNoShap.filter(function(item){
    //     if (!item.headerflg) return true;
    //   });
    //   // 変更されたデータを確認する
    //   rtn = kensaObjList.some(function(kensaObj) {
    //     // 検査セットが登録されている日付を取得
    //     const examDataKeys = Object.keys(kensaObj.examData);
    //     return examDataKeys.some(function(key) {
    //       if (kensaObj.examData[key] !== 1 ) {
    //         return true;
    //       }
    //     });
    //   });
    //   if (this.getSavePatExamPattern.length > 0) rtn = true;
    //   return rtn;
    // },
    // isChangedhas() {
    //   // 	mod 編集可能な権限があるかどうかを判断する 張岩 start
    //   if(this.hasAuthority()){
    //     return false
    //   }
    //   let rtn = false;
    //   //	mod 編集可能な権限があるかどうかを判断する 張岩 end
    //   // 編集データから検査セット行だけを抽出する
    //   const kensaObjList = this.getRadRequestListNoShap.filter(function(item){
    //     if (!item.headerflg) return true;
    //   });
    //   // 変更されたデータを確認する
    //   rtn = kensaObjList.some(function(kensaObj) {
    //     // 検査セットが登録されている日付を取得
    //     const radDataTimeKeys = Object.keys(kensaObj.radDataDetail);
    //     return radDataTimeKeys.some(function(key) {
    //       if (kensaObj.radDataDetail[key] !== 1 ) {
    //         return true;
    //       }
    //     });
    //   });
    //   if (this.getSavePatRadPattern.length > 0) rtn = true;
    //   return rtn;
    // },
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 end
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId", "srcFuncName", "treatmentPatList", "isPatInfoVisible", "isPatInfoChaned","getPatSearchedTreatDate", "getSortPatInfo","getPatListGridColumn", "getIsOtherFacility", "getOtherFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getOrdNoForSideBarRecord", "getOrdNo"]),
    ...mapGetters("indication", ["isTreatmentUnit"]),
    ...mapGetters("account-edit", ["getDefaultSetting", "isDispMenu" ,"getFontSize", "getPatientShareMode","getPatientShareFacilityCdMode"]),
    ...mapGetters("window-size", { windowHeight: "getWindowHeight", windowWidth: "getWindowWidth"}), // add #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎
    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start
    ...mapGetters("schedule-list",["getIsPatientEnabled"]),
    ...mapGetters("pat-viewer-modal",["getBaseDate"]),
    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end
    isIndicationUnitScreen() {
      return this.srcFuncName === 'indication' && !this.isTreatmentUnit;
    },
    // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
    treatmentDateExist() {
      if (!this.getPatSearchedTreatDate) {
        for (let i = this.sortConditions.length -1; i >= 0; i--) {
          if(!this.sortOptionsNoneTreat.find(e => e.key === this.sortConditions[i].key)) {
            this.sortConditions.splice(i,1);
            this.sortConditions.push({ key: null, isAsc: 1 });
          }
        }
      }
      if (this.getPatSearchedTreatDate != null && this.getPatSearchedTreatDate != "") {
        return this.sortOptions;
      } else {
        return this.sortOptionsNoneTreat;
      }
    },
    // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
    /**
     * 患者検索数
     */
    searchedCountText() {
      const searchedCount = this.srcFuncName === "" ? this.searchedPatList.length : this.treatmentPatList.length;
      return `計${searchedCount}名`;
    },
    selectedFontSize: {
      get() {
        return this.getFontSize;
      }
    },
    // 機能名と患者リストをまとめたwatch用変数
    funcNameAndTreatmentPatListForWatch(){
      return [this.srcFuncName,this.treatmentPatList];
    }
  },

  watch: {
    sortConditions: {
      deep: true,
      handler(sortConditions) {
        if (!sortConditions[0].key) {
          this.sortConditions[1].key = null;
          this.sortConditions[2].key = null;
          return;
        }
        if (!sortConditions[1].key) {
          this.sortConditions[2].key = null;
          return;
        }
      }
    },
    // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
    getSortPatInfo() {
      if (this.getSortPatInfo.length > 0) {
        this.sortConditions = this.getSortPatInfo;
      }
    },
    // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
    windowHeight() {
      if(this.srcFuncName !== 'indication' && this.srcFuncName !== ''){
        this.calculateGridHeight();
      }
    },
    windowWidth() {
      if(this.srcFuncName !== 'indication' && this.srcFuncName !== ''){
        this.calculateGridHeight();
      }
    },
    isDispMenu() {
      if(this.srcFuncName !== 'indication' && this.srcFuncName !== ''){
        this.calculateGridHeight();
      }
    },
    getFontSize() {
      if(this.srcFuncName !== 'indication' && this.srcFuncName !== ''){
        // スクロール位置保持
        // ※画面全体のリサイズによりスクロール位置が0に戻されるため個別に保持する
        const gridContent = this.getGridContentElement();
        const currentScrollTop = gridContent?.scrollTop || 0;
        const currentScrollLeft = gridContent?.scrollLeft || 0;

        // 画面全体の項目リサイズを待ってから高さ変更
        setTimeout(() => {
          this.initDirectGridIfReady();
          this.calculateGridHeight();
        }, 300);

        // スクロール位置復元
        this.$nextTick(() => {
        const restoredGridContent = this.getGridContentElement();
        if (restoredGridContent) {
          restoredGridContent.scrollTop = currentScrollTop;
          restoredGridContent.scrollLeft = currentScrollLeft;
        }
        });
      }
    },
    getOrdNoForSideBarRecord() {
      if(this.srcFuncName !== 'indication' && this.srcFuncName !== ''){
        this.$nextTick(() => {
          this.addCustomClass();
        });
      }
    },
    // 機能名と患者リストの両方をひとまとめにwatch
    // 同じ初期化処理が2回動く場合があるため1つにまとめる
    funcNameAndTreatmentPatListForWatch :{
      async handler([a,b]) {
        if(this.srcFuncName !== 'indication' && this.srcFuncName !== ''){
          // 機能別患者リスト作成
          await this.setGridData();
        }
      }
    },
  },
  methods: {
    getGridRef() {
      return this.$refs.grid || null;
    },
    getGridRootEl() {
      const gridRef = this.getGridRef();
      if (gridRef?.nodeType === 1) {
        return gridRef;
      }
      return gridRef?.gridRootEl?.() || gridRef?.$el || null;
    },
    getGridWidget() {
      return this.directGridWidget || this.getGridRef()?.gridWidget?.() || this.getGridRef()?.kendoWidget?.() || null;
    },
    getGridTbodyEl() {
      return this.getGridRef()?.gridTbodyEl?.() || this.getGridWidget()?.tbody?.[0] || null;
    },
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 start
    // // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
    // refreshData () {
    //   this.searchedPatList.forEach((element) => {
    //     if (element.pat_id ===  this.selectedPatId) {
    //       this.setSelectedPat(element.pat_id, element.ord_no, element.hosp_pat_id)
    //     }
    //   });
    // },
    // // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
    // // #6876 患者を切り替えると内容破棄確認モーダルが表示される 訾浩 start
    // // #6876 患者を切り替えると内容破棄確認モーダルが表示される 訾浩 end
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 end
    // mod FNSI-患者情報共有よりの改修 江 start
    // ...mapActions("pat-info", ["selectPat", "sortPatList"]),
    ...mapActions("pat-info", ["selectPat", "sortPatList","setDefaultSelectedPatId","setPatListGridColumn","setGridColumnWidth"]),
    // add 10389 患者リストのソートが遅い gjn start
    ...mapActions("pat-group", ["sortPatListRight"]),
    // add 10389 患者リストのソートが遅い gjn end
    ...mapActions("loading-screen", [
      "setLoadingScreenMessage",
      "setLoadingScreenVisible",
      "executeWithLoadingScreen"
    ]),
    // mod FNSI-患者情報共有よりの改修 江 end
    ...mapMutations("pat-info", {
      setPat: "setSelectedPat",
      setIsLoadingPat: "setIsLoadingPat",
      setIsNullPat: "setIsNullPat",
      setIsPatInfoChaned: "setIsPatInfoChaned",
      // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
      setSortPatInfo: "setSortPatInfo",
      // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
      resetEditedComponent: "resetEditedComponent",
      setStartRenderPatInfoContent: "setStartRenderPatInfoContent",
	  setPatSearchedTreatDate: "setPatSearchedTreatDate"
    }),
    ...mapActions("treatment-record/common", ["setOrdNo", "setOrdNoForSideBarRecord"]),
    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start
    ...mapActions("schedule-list", ["setHeaderInfo","setIsScheduleEnabled"]),
    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    getGridContentElement() {
      const gridRef = this.getGridRef();
      return gridRef?.gridContentEl?.() || queryScopedSelector('.k-grid-content', this.getGridRootEl() || this.$el || null);
    },
    getGridAutoScrollableElement() {
      const gridRef = this.getGridRef();
      return gridRef?.gridAutoScrollableEl?.()
        || queryScopedSelector('.k-auto-scrollable, .k-virtual-scrollable-wrap, .k-grid-content', this.getGridRootEl() || this.$el || null)
        || this.getGridContentElement();
    },
    getDirectGridDataSourceOption() {
      const source = this.listDataSource || createPatListDataSource({ data: [] });
      return source;
    },
    getDirectGridColumnSignature() {
      return JSON.stringify((this.getPatListGridColumn || []).map(column => ({
        field: column.field,
        hidden: !!column.hidden,
        title: column.title || "",
        width: column.width?.[this.selectedFontSize] || "",
        headerTemplate: !!column.headerTemplate,
        template: !!column.template
      })));
    },
    buildDirectGridColumns() {
      return (this.getPatListGridColumn || []).map(column => ({
        headerAttributes: { class: 'color-header' },
        headerTemplate: column.headerTemplate,
        hidden: !!column.hidden,
        field: column.field,
        template: column.template,
        title: this.$sanitize ? this.$sanitize(column.title) : column.title,
        width: column.width?.[this.selectedFontSize],
        attributes: column.field === 'pat_id' ? { class: 'pat-id-body' } : {}
      }));
    },
    installDirectGridFacade() {
      const root = this.getGridRef();
      if (!root || root.nodeType !== 1) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridDataSource = () => this.directGridWidget?.dataSource || null;
      root.gridRootEl = () => root;
      root.gridTbodyEl = () => this.directGridWidget?.tbody?.[0] || null;
      root.gridContentEl = () => queryScopedSelector('.k-grid-content', root);
      root.gridAutoScrollableEl = () => queryScopedSelector('.k-auto-scrollable, .k-virtual-scrollable-wrap, .k-grid-content', root);
      root.resizeGrid = () => this.resizeDirectGrid();
    },
    initDirectGridIfReady() {
      const root = this.getGridRootEl();
      const columns = this.buildDirectGridColumns();
      if (!root || columns.length === 0 || this.srcFuncName === 'indication' || this.srcFuncName === '') {
        return;
      }
      const nextSignature = this.getDirectGridColumnSignature();
      if (this.directGridWidget) {
        if (this.directGridColumnSignature !== nextSignature) {
          this.directGridWidget.setOptions({ columns });
          this.directGridColumnSignature = nextSignature;
        }
        this.applyDirectGridDataSourceContract();
        this.installDirectGridFacade();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      const $root = $$(root);
      $root.kendoGrid({
        dataSource: this.getDirectGridDataSourceOption(),
        columns,
        resizable: true,
        selectable: 'row',
        sortable: { compare: this.compareByField },
        height: this.kendoGridHeight,
        sort: event => this.sortHandler(event),
        columnResize: event => this.columnResizeEvevt(event),
        change: event => this.onRowClick(event),
        dataBound: () => this.gridSetting()
      });
      this.directGridWidget = markRaw($root.data('kendoGrid'));
      this.directGridColumnSignature = nextSignature;
      this.installDirectGridFacade();
      this.applyDirectGridStyleContract();
    },
    applyDirectGridDataSourceContract() {
      const grid = this.getGridWidget();
      if (!grid || !this.listDataSource) {
        return;
      }
      if (grid.dataSource !== this.listDataSource) {
        grid.setDataSource(this.listDataSource);
      }
      if (this.currentSort) {
        grid.dataSource.sort(this.currentSort);
      }
    },
    applyDirectGridStyleContract() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      root.classList.add('ntss-kendo-grid-legacy', 'k-widget', 'k-grid', 'k-display-block');
      root.querySelectorAll('.k-grid-header th, .k-grid-header .k-table-th').forEach(th => th.classList.add('k-header'));
      root.querySelectorAll('.k-grid-content tbody tr').forEach((tr, index) => {
        tr.classList.add('k-master-row');
        tr.classList.toggle('k-alt', index % 2 === 1);
      });
      root.querySelectorAll('.k-grid-content tbody td').forEach(td => td.classList.add('k-td', 'k-table-td'));
    },
    resizeDirectGrid() {
      const grid = this.getGridWidget();
      if (!grid) {
        return;
      }
      try {
        grid.setOptions({ height: this.kendoGridHeight });
        grid.resize(true);
      } catch (_error) {
        // direct jq grid should not rebuild on resize failure.
      }
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        this.resizeDirectGrid();
        this.applyDirectGridStyleContract();
      });
    },
    destroyDirectGrid() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
        this.directGridLayoutRafId = null;
      }
      try {
        this.directGridWidget?.destroy?.();
      } catch (_error) {
        // noop
      }
      this.directGridWidget = null;
      this.directGridColumnSignature = "";
      const root = this.getGridRef();
      if (root?.nodeType === 1) {
        root.innerHTML = "";
      }
    },

    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start
    findScheduleListDispdataCellByPatId(patId) {
      const st = this.$store.state["schedule-list"];
      if (!st || !Array.isArray(st.treatDateDim) || !st.treatDateDim.length || !st.dispdata) {
        return null;
      }
      const targetPid = Number(patId);
      if (Number.isNaN(targetPid)) {
        return null;
      }
      for (let di = 0; di < st.treatDateDim.length; di++) {
        const treatKey = st.treatDateDim[di];
        const dayBlock = st.dispdata[treatKey];
        if (!dayBlock || !Array.isArray(dayBlock)) {
          continue;
        }
        const kurLimit = Math.max(0, dayBlock.length - 1);
        for (let ki = 0; ki < kurLimit; ki++) {
          const kurBlock = dayBlock[ki];
          if (!kurBlock) {
            continue;
          }
          const scanBed = cell => {
            if (
              cell &&
              cell.pat_id != null &&
              Number(cell.pat_id) === targetPid &&
              cell.isDummy !== "1"
            ) {
              let td = cell.treatDate;
              if (!td || td === "--------") {
                td = treatKey;
              } else if (typeof td === "string") {
                td = td.replace(/[/-]/g, "");
              } else {
                td = treatKey;
              }
              return { ...cell, treatDate: td };
            }
            return null;
          };
          if (kurBlock.beddata && Array.isArray(kurBlock.beddata)) {
            for (let bi = 0; bi < kurBlock.beddata.length; bi++) {
              const hit = scanBed(kurBlock.beddata[bi]);
              if (hit) {
                return hit;
              }
            }
          }
          if (kurBlock.bedNotYet && Array.isArray(kurBlock.bedNotYet)) {
            for (let bi = 0; bi < kurBlock.bedNotYet.length; bi++) {
              const hit = scanBed(kurBlock.bedNotYet[bi]);
              if (hit) {
                return hit;
              }
            }
          }
        }
      }
      return null;
    },
    async syncScheduleListHeaderFromPatList(selectedPatId, selectedOrdNo, selectedHospitalPatId, patRecord) {
      this.setDefaultSelectedPatId(selectedPatId);
      this.setOrdNo(null);
      const treatDateStr = this.getBaseDate == null
        ? dayjs().format("YYYYMMDD")
        : dayjs(this.getBaseDate).format("YYYYMMDD");
      if (this.srcFuncName !== "") {
        this.setOrdNoForSideBarRecord(selectedOrdNo);
      }
      try {
        if (selectedOrdNo) {
          const response = await ApiHelper.get(
            `/mainData/getOrdInfoListForPatListByOrdNo/${this.facilityCd}/${selectedOrdNo}`
          );
          const ordInfo = response?.data?.[selectedOrdNo] || {};
          this.setHeaderInfo({
            ...ordInfo,
            ordNo: selectedOrdNo,
            pat_id: selectedPatId,
            hospPatId: selectedHospitalPatId,
            patLastName: patRecord.pat_last_name,
            patFirstName: patRecord.pat_first_name,
            inOutClass: patRecord.in_out_class,
            isSame: patRecord.is_same,
            bed_cd: patRecord.bed_cd ?? patRecord.bedCd,
            treatDate: treatDateStr
          });
          return;
        }
        const cell = this.findScheduleListDispdataCellByPatId(selectedPatId);
        if (cell) {
          cell.treatDate = treatDateStr;
          this.setHeaderInfo(cell);
          return;
        }
        this.setHeaderInfo({
          patLastName: patRecord.pat_last_name,
          patFirstName: patRecord.pat_first_name,
          hospPatId: selectedHospitalPatId,
          pat_id: selectedPatId,
          isSame: patRecord.is_same,
          ordNo: null,
          dialysisState: 0,
          inOutClass: patRecord.in_out_class,
          treatDate: treatDateStr
        });
      } catch (error) {
        getErrorMessage("PatList.vue", "syncScheduleListHeaderFromPatList", error);
      }
    },
    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end

    /**
     * @description 患者選択
     * @summary 選択した患者の患者情報レコードをストアに格納する
     */
    // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start
    async setSelectedPat(selectedPatId, selectedOrdNo, selectedHospitalPatId, patRecord = null) {
      if (this.$route.name === "pat-info-sharing-detail") {
        return;
      }

      this.closeMenu();
      
      // 预定画面の患者切替禁止
      const isScheduleListView = this.$route.name == "schedule-list" ? true : false;
      if (isScheduleListView && this.getIsPatientEnabled) return;
      this.setIsScheduleEnabled(true);
      if (isScheduleListView) {
        if (patRecord) {
          await this.syncScheduleListHeaderFromPatList(
            selectedPatId,
            selectedOrdNo,
            selectedHospitalPatId,
            patRecord
          );
        }
        //return;
      }
      //if (isScheduleListView) return;
      // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end
      // 患者情報画面展開状態の患者切替禁止
      if (this.isPatInfoVisible) return;
      if (this.isPatInfoChaned) {
        let isCanceled = false;
        await this.$ons.notification.confirm({
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer === 0) {
              isCanceled = true;
            } else {
              this.setIsPatInfoChaned(false);
              this.resetEditedComponent();
            }
          }
        });
        if (isCanceled) return;
      }
      this.setDefaultSelectedPatId(selectedPatId);
      this.setIsLoadingPat(true);
      // オーダ番号をクリア
      this.setOrdNo(null);
      if (this.srcFuncName !== "") {
        // 選択されている ord_no の更新
        this.setOrdNoForSideBarRecord(selectedOrdNo);
      }
      // 選択患者のpatIdがnullの場合
      if (selectedPatId === null) {
        this.setPat(null);
        this.setIsNullPat(true);
        this.setIsLoadingPat(false);
        // 現在の表示画面が治療状況リストの場合、治療状況を再読み込みさせる
        if (this.$route.name.indexOf("treatment-record") === 0) {
          EventBus.$emit("refresh");
          // delete start 馬 #9559
          //   EventBus.$emit("initOrdNoList");
          // delete end 馬 #9559
        }
        return;
      }
      // 現在の表示画面が体重計の場合、患者カードを置いた際と同じ挙動をさせる
      if (this.$route.name.indexOf("weight-mode") === 0) {
        this.setIsLoadingPat(false);
        EventBus.$emit("searchHospPatIdSchedule", {
          hospPatId: selectedHospitalPatId
        });
        return;
      }
      this.setIsNullPat(false);
      let patInfoViewFlg = this.$route.name == "pat-info" ? true : false;
      if (patInfoViewFlg){
        // console.log("patInfo view……");
        this.setLoadingScreenMessage("処理中・・・");
        this.setLoadingScreenVisible(true);
      }
      /*add FNSI-改修内容redmain6647 任 start*/
      // mod #9231 this.$parent.$parent.$data.beforeSelectPatId を this.selectedPatId に変更 朴 start
      // if((this.$route.name !== "pat-info" && this.$route.name !== "pat-prescription") || this.$parent.$parent.$data.beforeSelectPatId === ""){
      //     this.$parent.$parent.$data.beforeSelectPatId = selectedPatId
      if((this.$route.name !== "pat-info" && this.$route.name !== "pat-prescription") || this.selectedPatId === null){
      // mod #9231 this.$parent.$parent.$data.beforeSelectPatId を this.selectedPatId に変更 朴 end
          let patInfoViewFlg = this.$route.name == "pat-info" ||  this.$route.name == "pat-prescription" ? true : false;
          /*add FNSI-改修内容redmain6647 任 end*/
          //add #12462 患者情報共有 Ji start
          let selectedFacility = null;
          if (this.$route.name === "pat-info") {
            selectedFacility =
              this.getPatientShareMode === 1
                ? this.facilityCd
                : this.getOtherFacilityCd;
          } else if (this.$route.name === "pat-calendar") {
            selectedFacility =
              this.getPatientShareMode === 1
                ? this.facilityCd
                : (this.getOtherFacilityCd == null ? null : this.facilityCd);
          }
          //mod #12462 患者情報共有 Ji end
          await this.selectPat({selectedPatId, selectedFacility}).catch(() => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('PatList.vue', 'setSelectedPat', "[PatList.vue]setSelectedPat(): 患者選択失敗");
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            // TODO: エラー処理検討
            throw new Error("[PatList.vue]setSelectedPat(): 患者選択失敗");
          }).finally(() =>{
            if (patInfoViewFlg){
              this.setLoadingScreenVisible(false);
              const btn = getScopedElementsByClassName("right-exe-btn", this.$el || null)[0];
              if (!btn) {
                return;
              }
              let headerHeight = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
              let windowHeight = this.windowHeight;
              const footHeight = getFooterMenuClientHeight(this.$el || null);
              const cardListDOM = getScopedElementsByClassName("card-list", this.$el || null)[0];
              let btnHeight = btn.clientHeight;
              if (undefined === cardListDOM || null === cardListDOM) {
                return;
              }
              let cardListNewHeight = windowHeight - headerHeight - footHeight - btnHeight - 4;
              cardListDOM.style.height = cardListNewHeight + "px";
            }
          });
          if(this.$route.name === "pat-prescription"){
            EventBus.$emit("search",-1);
          }
          if(this.$route.name === "pat-info"){
            this.setStartRenderPatInfoContent(true);
          }
        /*add FNSI-改修内容redmain6647 任 start*/
      }else{
        if(this.$route.name === "pat-info"){
          this.setStartRenderPatInfoContent(true);
          EventBus.$emit("searchAlert",selectedPatId);
        }else{
          EventBus.$emit("searchAlertPatPre",selectedPatId);
        }

        this.setLoadingScreenVisible(false);
      }
      /*add FNSI-改修内容redmain6647 任 end*/
      if(this.$route.name !== "pat-prescription"){
        EventBus.$emit("search",-1);
      }
      this.setIsLoadingPat(false);
    },

    showPopover(e) {
      this.popoverTarget = e;
      this.popoverVisible = true;
    },

    async sort() {
      // mod 患者検索のソートの処理状態を追加 吉 start
      // this.sortPatList(this.sortConditions);
      if(null != this.searchedPatList && this.searchedPatList.length >0){
        this.popoverVisible= false;
        this.islodingFlag=true;
        // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
        // add FNSi6299-抽出条件を設定している状態で指示受け（指示承認）画面を開き、その後元の画面に戻ると表示順が勝手に入れ替わる 周 start
        // if(null !== this.sortConditions[0].key) {
        // add FNSi6299-抽出条件を設定している状態で指示受け（指示承認）画面を開き、その後元の画面に戻ると表示順が勝手に入れ替わる 周 end
        // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
          this.setSortPatInfo(this.sortConditions);
          // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
          await this.sortPatList(this.sortConditions);
        // add FNSi6299-抽出条件を設定している状態で指示受け（指示承認）画面を開き、その後元の画面に戻ると表示順が勝手に入れ替わる 周 start

          // add 10389 患者リストのソートが遅い gjn start
          // OK -> 患者グループ画面がソート順に更新される
          let sc = deepCopy(this.sortConditions);
          var param = { patGroup: null }
          sc.push(param)
          // 患者グループ画面左側の患者リストを順に更新
          await this.sortPatList(sc);
          // 患者グループ画面右側の患者リストをソート順に更新
          await this.sortPatListRight(sc);
          // add 10389 患者リストのソートが遅い gjn end
        // }
        // add FNSi6299-抽出条件を設定している状態で指示受け（指示承認）画面を開き、その後元の画面に戻ると表示順が勝手に入れ替わる 周 end
        this.islodingFlag=false;
        // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
      }
      // mod 患者検索のソートの処理状態を追加 吉 end
    },
    // 個人設定で登録した初期値を登録する
    // -----------------------------------------
    setDefaultCondition() {
      // 初期値を入れる
      this.sortConditions = [
        { key: null, isAsc: 1 },
        { key: null, isAsc: 1 },
        { key: null, isAsc: 1 }
      ];

      // デフォルト設定
      const defaultCondition = deepCopy(this.getDefaultSetting[PATIENT_SEARCH.KEY_NAME]);
      if (defaultCondition) {
        // デフォルト設定が存在する場合は適用
        if (defaultCondition[PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS] != null) {
          this.sortConditions = defaultCondition[PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS];
        }
      }

	  this.setPatSearchedTreatDate(this.treatDate);
      // del FutreNetWeb+SI課題管理No4106対応 趙 start
      // this.sort();
      // del FutreNetWeb+SI課題管理No4106対応 趙 end
    },
    // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
    scrollBottom(scrollToFlg) {
      if(this.srcFuncName === '' || this.srcFuncName === 'indication'){
        this.$nextTick(() => {
          let scrollEl = this.$refs.mianScroll;
          if (scrollToFlg) {
            // 患者情報編集の場合は、スクロールを編集した患者に設定する
            const child = queryScopedSelector(`.pat-list-area .pat-area .selected-pat`, this.$el || null);
            if (child) {
              scrollEl.scrollTo({ top: child.offsetTop - 38, behavior: 'smooth' });
            }
          } else {
            // 新規患者の場合は、スクロールを一番下に設定する
            scrollEl.scrollTo({ top: scrollEl.scrollHeight, behavior: 'smooth' });
          }
        });
      }
    },
    // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
    // add 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 start
    scrollTop() {
      if(this.srcFuncName === '' || this.srcFuncName === 'indication'){
        this.$nextTick(() => {
          let scrollEl = this.$refs.mianScroll;
          scrollEl.scrollTo({ top: 0});
        });
      }
    },
    // add 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 end
    closeMenu() {
      // フッターを閉じる
      EventBus.$emit("closeFooterList");
    },
    /**
     * gridデータ設定
     */
    async setGridData(){
      // 表示用のリストを初期化
      this.listDataSource = createPatListDataSource({
        data: []
      });

      // チェックリストグリッド列作成
      await this.setPatListGridColumn(this.searchedCountText);

      let newTreatmentPatList = [];

      // 表示対象のオーダー番号の治療情報部分を取得
      if (this.treatmentPatList.length) {
        this.setLoadingScreenMessage("処理中・・・");
        this.setLoadingScreenVisible(true);
        const ordNos = this.treatmentPatList.map(item => item.ord_no).join(",");
        const response = await ApiHelper.get(
          `/mainData/getOrdInfoListForPatListByOrdNo/${this.facilityCd}/${ordNos}`).catch(error => {
          this.setLoadingScreenVisible(false);
          getErrorMessage('PatList.vue', 'setGridData', error);
          throw new Error("[PatList.vue]setGridData(): 機能別患者リスト用治療情報取得失敗");
        });
        newTreatmentPatList = this.treatmentPatList.map((item)=>{
          const resData = response?.data[item.ord_no] || {};
          return ({...item,...resData});
        });

        // システム共通患者名ソート用(フリガナ優先文字列)を追加
        newTreatmentPatList = addPatNameSortToList(newTreatmentPatList);
      }

      // 最終的な表示用のリストをgridにセット
      this.listDataSource = createPatListDataSource({
        data: newTreatmentPatList
      });

      this.$nextTick(() => {
        this.initDirectGridIfReady();
        this.applyDirectGridDataSourceContract();
        // 高さ計算
        this.calculateGridHeight();
      });
      this.setLoadingScreenVisible(false);
    },
    /**
     * grid設定
     */
    gridSetting(){
      // クラス設定
      this.addCustomClass();
    },
    /**
     * クラス設定
     */
    addCustomClass() {
      const ordNoForSideBarRecord = this.getOrdNoForSideBarRecord;
      const grid = this.getGridWidget();
      const visibleColumns = (grid?.columns || []).filter(column => !column.hidden);
      Array.from(this.getGridTbodyEl()?.querySelectorAll?.("tr") || []).forEach(rowEl => {
        const rowData = grid?.dataItem?.(rowEl);
        if (!rowData) {
          return;
        }
        const cells = rowEl.querySelectorAll("td");
        cells.forEach((cell, cellIndex) => {
          const field = visibleColumns[cellIndex]?.field;

          // 患者名追加クラス設定
          if (field == 'patName' && rowData['inOutClass'] == 1) {
            cell?.classList?.add("in_class");
            return;
          }

          // 回診強調表示クラス設定
          if (field == 'roundState') {
            switch (rowData['roundHighlighting']) {
              case "1":
                cell?.classList?.add("round-state-td-highlighting-1");
                break;
              case "2":
                cell?.classList?.add("round-state-td-highlighting-2");
                break;
            }
            return;
          }
        });
        // 選択行クラス設定
        $$(rowEl).toggleClass("selected-pat", rowData?.['ord_no'] == ordNoForSideBarRecord);
      });
    },
    /**
     * 列選択時
     * @param {*} e
     */
    async onRowClick(e) {
      e?.preventDefault?.();
      await this.executeWithLoadingScreen(async () => {
        const grid = this.getGridWidget();
        const selectedRow = grid?.select?.();
        const selectedRowData = grid?.dataItem?.(selectedRow);
        if (!selectedRowData) {
          return;
        }
        await this.setSelectedPat(selectedRowData.pat_id, selectedRowData.ord_no, selectedRowData.hosp_pat_id)
      });
    },
    /**
     * 列ヘッダクリック時にソート順を設定
     * @param {*} e
     */
    sortHandler(e) {
      this.currentSort = e.sort;
    },
    /**
     * 列ヘッダクリック時のソート処理
     * @param {*} a
     * @param {*} b
     */
    compareByField(a, b) {
      // ソートなしはreturn
      if (!this.currentSort || !this.currentSort.field) return;

      const sortField = SORT_KEY_MAP[this.currentSort.field] || this.currentSort.field;

      // 回診状態の場合は専用のソート
      if (sortField === "roundStateForSort") {
        // フィールド値の昇順降順が逆になるので4番目の引数はfalseとする
        return sortableCompare(a, b, sortField, false);
      }

      // 共通関数でソート
      return sortableCompare(a, b, sortField, true);
    },
    /**
     * 列幅変更時
     * @param {*} event
     */
    columnResizeEvevt (event) {
      this.setGridColumnWidth({
        field: event.column.field,
        selectedFontSize: this.selectedFontSize,
        width: event.newWidth
      });
      this.calculateGridHeight();
    },
    /**
     * Windowの高さからGirdコンポーネント領域の高さを算出してリサイズ
     */
    calculateGridHeight() {
      // スクロール位置保持
      const gridContent = this.getGridContentElement();
      const currentScrollTop = gridContent?.scrollTop || 0;
      const currentScrollLeft = gridContent?.scrollLeft || 0;

      // リサイズ
      const wh = this.windowHeight;
      const tableTop = getScopedElementsByClassName("grid-area", this.$el || null)[0]?.getBoundingClientRect?.().top || 0;
      const fmh =
        (this.isDispMenu === 1
          ? getFooterMenuClientHeight(this.$el || null)
          : 0);
      this.kendoGridHeight = wh - tableTop - fmh - 8;
      this.resizeDirectGrid();

      // スクロール位置復元
      this.$nextTick(() => {
        const restoredGridContent = this.getGridContentElement();
        if (restoredGridContent) {
          restoredGridContent.scrollTop = currentScrollTop;
          restoredGridContent.scrollLeft = currentScrollLeft;
        }
      });
    },
  },

  created() {
    // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
    EventBus.$off("scrollBottom", this.scrollBottom);
    EventBus.$on("scrollBottom", this.scrollBottom);
    // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
    // add 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 start
    EventBus.$off("scrollTop", this.scrollTop);
    EventBus.$on("scrollTop", this.scrollTop);
    // add 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 end
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 start
    //  let Authority = this.getUserAuthorityCds();
    //   if(Authority.indexOf("072")!=-1 || Authority.indexOf("073")!=-1)
    //     this.authorityCd072and073 = true;
    //   else this.authorityCd072and073 = false;
    // // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
    // EventBus.$off("refresh", this.refreshData);
    // EventBus.$on("refresh", this.refreshData);
    // // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
    // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 end    // 初期設定の適用
    EventBus.$off("calculatePatListGridHeight", this.calculateGridHeight);
    EventBus.$on("calculatePatListGridHeight", this.calculateGridHeight);
    this.setDefaultCondition();
  },
  // add 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 start
  beforeUnmount() {
    EventBus.$off("scrollBottom", this.scrollBottom);
    EventBus.$off("scrollTop", this.scrollTop);
    EventBus.$off("calculatePatListGridHeight", this.calculateGridHeight);
    this.destroyDirectGrid();
  },
  // add 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 end
  // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 start
  // // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
  // beforeDestroy() {
  //   EventBus.$off("refresh", this.refreshData);
  // }
  // // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
  // del 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 end
};
</script>

<style scoped>
.pat-list-area {
  overflow-y: scroll;
  height: 400px;
  border: 1px solid #dddddd;
}

@media screen and (max-height: 800px) {
  .pat-list-area {
    height: 280px;
  }
}

@media screen and (max-height: 420px) {
  .pat-list-area {
    height: 200px;
  }
}

.pat-area {
  width: 100%;
  border-collapse: collapse;
}

.pat-area tr th {
  border-right: 1px solid var(--ntss-list-border-color);
  text-align: left;
  font-weight: normal;
  position: sticky;
  top: 0;
  z-index: 1;
}

.pat-area tr th:first-child {
  width: 30%;
}

.pat-area tr:nth-child(2n) {
  background-color: var(--ntss-list-content-2nd-background-color);
}

.pat-area tr {
  background-color: var(--ntss-list-item-background-color);
  border-color: 1px solid  var(--master-maintenance-kgrid-border-color);
  height: 2em;
}

.pat-area tr:hover {
  background-color: var(--master-maintenance-kgrid-item-hover-background-color);
}

.pat-area tr td {
  border: 1px solid var(--ntss-list-border-color);
}

.pat-area tr td:first-child {
  text-align: right;
}

.pat-area tr td:nth-child(2) {
  text-align: left;
}

a {
  color: var(--ntss-list-body-color);
  text-decoration: none;
}

a:focus {
  outline: none;
}

.saving-modal {
  text-align: center;
}

.pat-id-area,
.pat-name-area {
  display: inline-block;
  width: 100%;
}

.button-area {
  display: flex;
  justify-content: space-between;
  margin: 2px 0 2px 2px;
}

.sort-popover :deep(.popover__content) {
  width: auto;
  min-width: 17em;
  padding: 10px;
}

.pat-list-sort-title {
  display: flex;
  white-space: nowrap;
  flex-wrap: wrap;
}

.pat-list-sort-condition {
  white-space: nowrap;
  margin-left: 5px;
}

/*mod FNSI-画面部品デザイン じょはく start*/
.selected-pat {
  /*outline: 3px solid #0000ff;*/
  outline: 3px solid #2ca06f;
  outline-offset: -3px;
}
/*mod FNSI-画面部品デザイン じょはく end*/
.same-icon{
  position: relative;
  top: 0.25em;
  height: 20px;
}
/*add FNSI-入外区分が入院の場合、患者名は紫色にする dou start */
.in_class {
  color: #A356A3;
}
/*add FNSI-入外区分が入院の場合、患者名は紫色にする dou end */
/* add 患者検索フォントサイズ対応 趙 start */
.loading-modal {
  text-align: center;
  font-size: 30px;
}
/* add 患者検索フォントサイズ対応 趙 end */
.searched-cnt {
  float: right;
  padding-right: 2px;
  font-size: 0.75em;
}
</style>
