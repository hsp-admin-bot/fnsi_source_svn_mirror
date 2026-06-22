/** 治療予定コピー */
<template>
  <!--  mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc start-->
  <!--  <modal-base @onClose="hideModal">-->
  <modal-base @onClose="hideModal('hide-modal')">
<!--  mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240103 ztc end-->
        <template #body>
<div ref="modalBodyRoot" class="indInfo-style-modal-container" style="overflow: initial;">
      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right-title">
          <label>コピー元 治療日</label>
        </v-ons-col>
        <v-ons-col v-if="0 === propSelFlag" class="col-style-left">
          <label>{{ dispTreatDate }}</label>
        </v-ons-col>
        <v-ons-col v-else class="col-style-left">
          <!-- mod FNSI-横展開--inputの色 関 start -->
          <!-- <input
            v-model="selectedDialysisDate"
            type="date"
            class="date-input common-style-input ntss-input-date ntss-custom-input"
            :max="maxDate"
          /> -->
          <date-input
            v-model="selectedDialysisDate"
            id="date-copy"
            class="date-input common-style-input ntss-input-date ntss-custom-input date-copy-input"
            classes="date-input-required date-input-unjust-size date-input-focus"
            :max="maxDate"
            :class="classObject"
            @focus="beforeDialysisDate = selectedDialysisDate"
            @blur="onBlurDialysisDate"
            isRequired
            defaultEmpty
          />
          <!-- mod FNSI-横展開--inputの色 関 end -->
          <!-- mod FNSI-7629 劉全航 start -->
          <!-- <custom-calendar
            v-if="customCalendarFlag"
            v-model="selectedDialysisDate"
            :is-disabled-past-dates="true"
            :selected-dates="treatDatelist"
            :disabled-dates="disabledDates"
            :disable-dates-after="disableDatesAfter"
          /> -->
          <custom-calendar
            v-if="customCalendarFlag"
            v-model="calendarDialysisDate"
            :is-disabled-past-dates="false"
            :selected-dates="treatDatelist"
            :disabled-dates="disabledDates"
            :disable-dates-after="disableDatesAfter"
            :disable-dates-before="this.treatList[0]"
          />
          <!-- mod FNSI-7629 劉全航 end -->
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right"> </v-ons-col>
        <v-ons-col class="col-style-left">
          <label>治療方法&ensp;:&ensp;{{ dispTreatmethod }}</label>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right"> </v-ons-col>
        <v-ons-col v-if="0 === propSelFlag" class="col-style-left">
          <label>クール&emsp;&ensp;:&ensp;{{ dispKur }}</label>
        </v-ons-col>
        <v-ons-col v-else class="col-style-left">
          <label>クール&emsp;&ensp;:&ensp;</label>
          <v-ons-select v-model="ordNo" style="width: max-content">
            <option
              v-for="(item, index) in treatmentAndKurList"
              :key="index"
              :value="item.ordNo"
            >
              {{ item.kurName }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right"> </v-ons-col>
        <v-ons-col class="col-style-left">
          <label>ベッド&emsp;&ensp;:&ensp;{{ dispBed }}</label>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right">
          <label style="font-weight: bold"
            >&emsp;&emsp;&emsp;&emsp;↓&emsp;&emsp;&emsp;</label
          >
        </v-ons-col>
        <v-ons-col class="col-style-left">
          <label style="font-weight: bold"
            >&emsp;&emsp;&emsp;&emsp;↓&emsp;&emsp;&ensp;</label
          >
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right-title">
          <label>コピー先 治療日</label>
        </v-ons-col>
        <v-ons-col v-if="0 === propSelFlag" class="col-style-left">
          <!-- mod FNSI-横展開--inputの色 関 start -->
          <!-- <input
            v-model="selectedDialysisDate"
            type="date"
            class="date-input common-style-input ntss-input-date ntss-custom-input"
            :max="maxDate"
          /> -->
          <date-input
            v-model="selectedDialysisDate"
            id="date-copy"
            class="date-input common-style-input ntss-input-date ntss-custom-input date-copy-input"
            classes="date-input-required date-input-unjust-size date-input-focus"
            :max="maxDate"
            :class="classObject"
            @focus="beforeDialysisDate = selectedDialysisDate"
            @blur="onBlurDialysisDate"
            isRequired
            defaultEmpty
          />
          <!-- mod FNSI-横展開--inputの色 関 end -->
          <!-- add FNSI-予定コピー仕様修正、障害票一覧_患者経過総合ビューアNo.16-19 start -->
          <!-- <custom-calendar
            v-model="selectedDialysisDate"
            :is-disabled-past-dates="true"
            :disable-dates-after="disableDatesAfter"
          /> -->
          <custom-calendar
            v-model="calendarDialysisDate"
            :is-disabled-past-dates="false"
            :disable-dates-after="disableDatesAfter"
          />
          <!-- add FNSI-予定コピー仕様修正、障害票一覧_患者経過総合ビューアNo.16-19 end -->
        </v-ons-col>
        <v-ons-col v-else class="col-style-left">
          <label>{{ dispTreatDate }}</label>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right"> </v-ons-col>
        <v-ons-col class="col-style-left">
          <label>治療方法&ensp;:&ensp;{{ dispTreatmethod }}</label>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right"> </v-ons-col>
        <v-ons-col class="col-style-left">
          <label>クール&emsp;&ensp;:&ensp;</label>
          <v-ons-select v-model="selectKurCdCopyTo" style="width: max-content">
            <option
              v-for="(item, index) in dispKurListCopyTo"
              :key="index"
              :value="item.kurCd"
            >
              {{ item.kurName }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right"> </v-ons-col>
        <v-ons-col class="col-style-left">
          <label>ベッド&emsp;&ensp;:&ensp;</label>
          <v-ons-select v-model="selectBedCdCopyTo" style="width: max-content">
            <option
              v-for="(item, index) in dispBedListCopyTo"
              :key="index"
              :value="item.bedCd"
            >
              {{ item.bedName }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style">
        <v-ons-col class="col-style-right"> </v-ons-col>
        <v-ons-col class="col-style-left">
          <v-ons-checkbox
            v-model="isIncludingMedicine"
            input-id="checkIncludingMedicine"
          />
          <label for="checkIncludingMedicine">投与薬剤を含めてコピーする</label>
        </v-ons-col>
      </v-ons-row>

      <div v-if="messageDialogInfo.isDialogVisible">
        <message-dialog
          v-model:visible="messageDialogInfo.isDialogVisible"
          :message-cd="messageDialogInfo.messageCd"
          :type="messageDialogInfo.type"
          :string-params="messageDialogInfo.stringParams"
          @confirm="confirmResult"
        />
      </div>
    </div>
    </template>

        <template #footer>
<div ref="modalFooterRoot" class="in-ind-dropdown-area">
      <v-ons-row class="row-style-footer">
        <v-ons-col style="text-align: end; padding-right: 10px; margin: auto">
          <label>指示者</label>
        </v-ons-col>
        <v-ons-col width="170px">
          <kendo-dropdownlist
            v-model="indUser"
            :data-source="userOptions"
            :data-text-field="'fullName'"
            :data-value-field="'user_id'"
            style="width: 100%"
            class="common-style-input select-style-list"
            @open="onIndUserDropdownOpen"
          />
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="row-style-footer">
        <v-ons-col>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
          <!-- <v-ons-button
            class="common-style-cancel-button"
            style="float: left;"
            @click="hideModal()"
          >
            キャンセル
          </v-ons-button> -->
          <!--          mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start-->
          <!--          <v-ons-button-->
          <!--            class="btn2-cancel width-padding"-->
          <!--            style="float: left;"-->
          <!--            @click="hideModal()"-->
          <!--          >-->
          <v-ons-button
            class="btn2-cancel width-padding"
            style="float: left"
            @click="hideModal('hide-modal')"
          >
            <!--            mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end-->
            キャンセル
          </v-ons-button>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
        </v-ons-col>

        <v-ons-col>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
          <!-- <v-ons-button
            class="common-style-ok-button"
            style="float: right;"
            :disabled="updateDisable"
            @click="updateInfo()"
          >
            保存
          </v-ons-button> -->
          <!--          mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start-->
          <!--          <v-ons-button-->
          <!--              class="btn1-execute width-padding"-->
          <!--              style="float: right;"-->
          <!--              :disabled="updateDisable"-->
          <!--              @click="updateInfo()"-->
          <!--          >-->
          <v-ons-button
            class="btn1-execute width-padding"
            style="float: right"
            :disabled="updateDisable"
            @click="updateInfo()"
          >
            <!--          mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end-->
            保存
          </v-ons-button>
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
        </v-ons-col>
      </v-ons-row>
    </div>
    </template>
  </modal-base>
</template>
<script>
import { ApiHelper } from "@/apis/AxiosHelper";
/**
 * Vue関連
 */
import { mapGetters, mapActions } from "@/compat/vue/vuex";

import CustomCalendar from "@/components/common/custom-calendar/CustomCalendar";

/**
 * 日付操作
 */
import dayjs from "@/compat/date/dayjs";
import { dateFormat, fitTermCheckForUpdate } from "@/functions/common/DateTimeUtils";

/**
 * メッセージダイアログ
 */
import messageDialog from "@/components/common/message-dialog/MessageDialog";

import ModalBase from "@/components/modals/ModalBase";

/**
 * 指示者関連
 */
import { AUTHORITY_CODES } from "@/constants/userAuthority";

import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";

//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { getScopedElementById, getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";
import DateInput from "@/components/common/DateInput";

// mod #6107 2023/03/22 メッセージボックス全調整 張博 end

export default {
  // mod FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 start
  // mixins: [IndUserSelectMixin],
  mixins: [IndUserSelectMixin],
  // mod FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 end

  components: {
    "custom-calendar": CustomCalendar,
    "message-dialog": messageDialog,
    ModalBase,
    "date-input": DateInput,
  },

  props: {
    /**
     * 施設コード
     */
    propFacilityCd: {
      type: String,
      required: true,
    },

    /**
     * 患者ID
     */
    propPatId: {
      type: Number,
      required: true,
    },

    /**
     * オーダー番号
     */
    propOrdNo: {
      type: Number,
      default: null,
    },

    /**
     * コピーフラグ(0->日付がコピー元,1->日付がコピー先)
     */
    propSelFlag: {
      type: Number,
      required: true,
    },

    /**
     * 表示する日付
     */
    propDialysisDate: {
      type: String,
      required: true,
    },
  },

  data() {
    return {
      /**
       * 指示者リスト格納
       */
      userOptions: [],
      /**
       * 選択支持者
       */
      indUser: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initIndUser: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      /**
       * 参照元で画面更新を行うかどうかのフラグ
       * @summary 更新を行うかどうかは参照元画面で判断
       */
      isRefresh: false,
      /**
       * 施設コード
       */
      facilityCd: this.propFacilityCd,
      /**
       * 患者ID
       */
      patId: this.propPatId,
      /**
       * オーダー番号
       */
      ordNo: this.propOrdNo,
      /**
       * 表示用治療日
       */
      dispDialysisDate: this.propDialysisDate,
      /**
       * 選択治療日
       */
      selectedDialysisDate: "",
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initSelectedDialysisDate: "",
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      /**
       * 治療方法表示文字
       */
      dispTreatmethod: "",
      /**
       * クール表示文字
       */
      dispKur: "",
      /**
       * ベッド表示文字
       */
      dispBed: "",

      /**
       * 治療日リスト
       */
      treatList: [],
      /**
       * 治療方法リスト
       * { ordNo: 0, text: "HD" }
       */
      treatmenList: [],

      /**
       * クールリスト(コピー元)
       * { kurCd: 0, kurName: "午前", ordNo: 123456 }
       */
      treatmentAndKurList: [],
      /**
       * 選択したクールコード(コピー先)
       */
      selectKurCdCopyTo: 0,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initSelectKurCdCopyTo: 0,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      /**
       * クールリスト(コピー先)
       * { kurCd: 0, kurName: "午前" }
       */
      dispKurListCopyTo: [],

      /**
       * 選択したベッドコード
       */
      selectBedCdCopyTo: 0,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initSelectBedCdCopyTo: 0,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      /**
       * ベッドリスト(施設内の全ベッド)
       * { bedCd: 0, bedName: "ベッド１" }
       */
      bedListAll: [],
      /**
       * ベッドリスト
       * { bedCd: 0, bedName: "ベッド１" }
       */
      dispBedListCopyTo: [],

      /**
       * メッセージダイアログ情報
       */
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: "22010001",
        type: "1",
        stringParams: [],
      },

      /**
       * 治療日元カスタムカレンダー表示フラグ
       */
      customCalendarFlag: false,

      /**
       * 治療日無しリスト
       */
      disabledDateList: [],
      /**
       * 治療情報リスト
       */
      ordMainList: [],
      /**
       * スタイル
       */
      styleObj: { "max-width": "370px", width: "370px" },
      /**
       * 更新不可フラグ
       */
      updateDisable: false,

      /**
       * 対象治療日のクール・ベッド指定済みスケジュールリスト
       * (空きベッド候補表示処理で使用)
       */
      ordSchList: [],

      /**
       * 「投与薬剤を含めてコピーする」データ
      */
      isIncludingMedicine: false,
      initIsIncludingMedicine: false,
      // 変更前 コピー元治療日／コピー先治療日
      beforeDialysisDate: "",
      // custom-calendar用 コピー元治療日／コピー先治療日がカレンダーから選択されたかを判別可能とする
      calendarDialysisDate: "",
    };
  },

  computed: {
    //add 5619 装置と紐づいていないベッドも表示 張 start
    // ...mapGetters("pat-viewer", ["getMstTreatmentData", "getMstKurData", "getMstBedData"]),
    ...mapGetters("pat-viewer", [
      "getMstTreatmentData",
      "getMstKurData",
      "getMstBedData",
      "getBedAndMachine",
    ]),
    //add 5619 装置と紐づいていないベッドも表示 張 end
    ...mapGetters("pat-info", ["selectedPat"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    //add 張 start
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    //add 張 end
    // add FutreNetWeb+SI課題管理No7067 趙 start
    ...mapGetters("pat-viewer-popover", ["getCopyFlag"]),
    // add FutreNetWeb+SI課題管理No7067 趙 end
    /**
     * 治療方法マスタ
     */
    mstTreamentData() {
      return this.getMstTreatmentData;
    },

    /**
     * クールマスタ
     */
    mstKurData() {
      return this.getMstKurData;
    },

    /**
     * ベッドマスタ
     */
    mstBedData() {
      //mod 5619 装置と紐づいていないベッドも表示 張 start
      // return this.getMstBedData;
      return this.getBedAndMachine;
      //mod 5619 装置と紐づいていないベッドも表示 張 end
    },

    /**
     * 表示治療日
     */
    dispTreatDate() {
      const dispStr = dayjs(this.dispDialysisDate, "YYYY-MM-DD").format(
        "YYYY/MM/DD(ddd)"
      );
      return dispStr;
    },

    /**
     * 治療日リスト
     */
    treatDatelist() {
      return this.treatList;
    },

    /**
     * 治療日無しリスト
     */
    disabledDates() {
      return this.disabledDateList;
    },

    /**
     * 終了日の最大日(本日から一年未満)
     */
    maxDate() {
      const day = dayjs().format("YYYYMMDD");
      // 一年後に最大日を設定
      let endMaxDate = this.schExtEndDate
        ? dayjs(this.schExtEndDate, "YYYYMMDD")
        : dayjs(day).add(1, "year");
      endMaxDate = dayjs(endMaxDate).endOf("month");
      return dayjs(endMaxDate).format("YYYY-MM-DD");
    },

    /**
     * 指定日以降編集不可
     */
    disableDatesAfter() {
      return dayjs(this.maxDate).format("YYYYMMDD");
    },

    /**
     * スケジュール自動延長最終日
     */
    schExtEndDate() {
      // TODO: 自動延長の実行タイミングによりデータ不一致が発生する可能性がある
      return this.selectedPat.pat_main.sch_ext_end_date;
    },
    // mod FNSI-横展開--inputの色 関 start
    classObject() {
      return {
        // 編集時に適用されるclass
        "custom-input-edited": false,
      };
    },
    // mod FNSI-横展開--inputの色 関 end
    // add FutreNetWeb+SI課題管理No7067 趙 start
    copyFlag() {
      return this.getCopyFlag;
    },
    // add FutreNetWeb+SI課題管理No7067 趙 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    isChanged() {
      return (
        this.initSelectedDialysisDate !==
          JSON.stringify(this.selectedDialysisDate) ||
        this.initSelectKurCdCopyTo !== JSON.stringify(this.selectKurCdCopyTo) ||
        this.initSelectBedCdCopyTo !== JSON.stringify(this.selectBedCdCopyTo) ||
        //mod  #12334 患者経過総合ビューア－予定コピー画面で保存ボタンが活性化されず保存ができない zhaojinzhao start
        this.initIsIncludingMedicine != this.isIncludingMedicine
      );
      //mod  #12334 患者経過総合ビューア－予定コピー画面で保存ボタンが活性化されず保存ができない zhaojinzhao end
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
  },

  watch: {
    calendarDialysisDate(value) {
      this.selectedDialysisDate = value;

      // 選択治療日が空の場合もしくはコピー先治療日の変更の場合処理終了
      if (null === value || "" === value) {
        return;
      } else {
        this.setDateCopyBackground("#ffff99");
      }
      // 選択治療日が1年後よりも後に行かないよう制御
      const maxDate = parseInt(dayjs(this.maxDate).format("YYYYMMDD"));
      const date = parseInt(dayjs(value).format("YYYYMMDD"));
      if (date > maxDate) {
        this.calendarDialysisDate = this.maxDate;
        return;
      }
      if (0 !== this.propSelFlag) {
        // 治療方法&クールリスト作成
        // #10196 2つの異なる予定がありますが、第2の治療予定を選択した場合は、第1の治療が予定されている治療法となります。 linjunfeng start
        // this.setTreatmentAndKurList(value);
        this.setTreatmentAndKurList(value, "selectdDate");
        // #10196 2つの異なる予定がありますが、第2の治療予定を選択した場合は、第1の治療が予定されている治療法となります。 linjunfeng end
      } else {
        // クールを未登録に変更する
        this.selectKurCdCopyTo = 0;
        // 選択日の治療予定を全件取得(空きベッド候補表示用)
        this.setOrdSchList(value);
      }
    },

    selectKurCdCopyTo(value) {
      // クール選択時にベッドドロップダウンに空きベッド候補を表示
      // クール変更時にはベッドを一度未登録に変更する
      this.selectBedCdCopyTo = 0;
      if (value === 0) {
        // クール未登録 → 全ベッドを候補に表示
        this.dispBedListCopyTo = this.bedListAll;
      } else {
        // 対象クールで予定がないベッドのみを表示
        this.dispBedListCopyTo = this.bedListAll.filter(
          (bed) =>
            !this.ordSchList.some(
              (sch) => bed.bedCd === sch.bedCd && sch.kurCd === value
            )
        );
      }
    },

    // 入力の監視
    isIncludingMedicine(value) {
      // 入力値の格納
      this.isIncludingMedicine = value;
    },

    ordNo(value) {
      if (value === null) {
        this.dispTreatmethod = "";
        this.dispBed = "";
      } else {
        // コピー元のクールを指定した場合、治療方法・ベッドを表示する
        const treatInfo = this.treatmentAndKurList.find((item) => {
          return item.ordNo === value;
        });
        this.dispTreatmethod = treatInfo.treatmentName;
        this.dispBed = treatInfo.bedName;
        // add FutreNetWeb+SI課題管理No7067 趙 start
        const settingData = {};
        settingData.propOrdNo = treatInfo.ordNo;
        settingData.propFacilityCd = this.facilityCd;
        settingData.propDialysisDate = this.selectedDialysisDate;
        settingData.propSelFlag = this.copyFlag;
        settingData.propPatId = this.patId;
        this.setSettingIndData({ settingIndData: settingData });
        // add FutreNetWeb+SI課題管理No7067 趙 end
      }
    },
  },

  created() {
    // 指示者リスト作成
    this.getIndUserList(
      AUTHORITY_CODES.IND_EDIT,
      AUTHORITY_CODES.IND_PEDIT
    ).then((response) => {
      this.userOptions = response.doctorList;
      this.$nextTick(() => {
        this.indUser = response.iniSelectId;
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
        this.initIndUser = this.indUser;
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
        // 表示領域の調整
        const dropdownArea = getScopedElementsByClassName(
          "in-ind-dropdown-area",
          this.$refs?.modalFooterRoot || this.getScopedRoot()
        )[0];
        if (dropdownArea?.parentElement?.parentElement) {
          dropdownArea.parentElement.parentElement.style.height = "calc(5rem + 1em)";
        }
      });
    });
    // コピー元治療日が格納された場合治療方法&クールリスト作成
    if (0 === this.propSelFlag) {
      this.setTreatmentAndKurList(this.dispDialysisDate);
    }

    // 表示用クールリスト作成
    const objKurNon = { kurCd: 0, kurName: "未登録" };
    this.dispKurListCopyTo = [objKurNon, ...this.mstKurData];

    // 表示用ベッドリスト作成
    const objBedNon = { bedCd: 0, bedName: "未登録" };
    this.bedListAll = [objBedNon, ...this.mstBedData];
    this.dispBedListCopyTo = this.bedListAll;

    // 指定の患者すべての治療日を取得
    this.getTreatDateList();

    if (0 !== this.propSelFlag) {
      // コピー先治療日の治療予定を全件取得(空きベッド候補表示用)
      this.setOrdSchList(this.dispDialysisDate);
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    this.initSelectedDialysisDate = JSON.stringify(this.selectedDialysisDate);
    this.initSelectKurCdCopyTo = JSON.stringify(this.selectKurCdCopyTo);
    this.initSelectBedCdCopyTo = JSON.stringify(this.selectBedCdCopyTo);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
  },

  methods: {
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    // 予実リストへの変更通知
    ...mapActions("indication-result", ["setResultUpdate"]),
    // add FutreNetWeb+SI課題管理No7067 趙 start
    ...mapActions("pat-viewer-modal", ["setSettingIndData"]),
    // add FutreNetWeb+SI課題管理No7067 趙 end

    getScopedRoot() {
      return this.$refs?.modalBodyRoot || this.$refs?.modalFooterRoot || this.$el || this;
    },

    getDateCopyInput() {
      return getScopedElementById("date-copy", this.getScopedRoot());
    },

    setDateCopyBackground(background) {
      const dateCopyInput = this.getDateCopyInput();
      if (dateCopyInput?.style) {
        dateCopyInput.style.setProperty("background", background, "important");
      }
    },

    /**
     * モーダルを閉じる
     */
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    // hideModal() {
    hideModal(type) {
      if (this.isChanged && type === "hide-modal") {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: (answer) => {
            if (answer === 1) {
              // モーダル閉じる
              this.$emit("hide-modal");
            }
          },
        });
      } else {
        // モーダル閉じる
        this.$emit("hide-modal");
      }
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
    },

    /**
     * 更新処理
     */
    async updateInfo() {
      // 更新不可フラグをtrue
      this.updateDisable = true;
      // 入力チェック(入力漏れがあればメッセージ表示
      if (this.checkInputLeak()) {
        // コピー先に治療方法、クールが被るものがないかチェック
        if (this.checkDuplicateData()) {
          return;
        }
        const sendJson = {};
        // オーダー番号
        sendJson.ord_no = this.ordNo;
        // コピー先日時
        sendJson.dialysis_date_to =
          0 === this.propSelFlag
            ? this.selectedDialysisDate
            : this.dispDialysisDate;
        // 施設情報
        sendJson.facility_cd = this.facilityCd;
        // 患者情報
        sendJson.pat_id = this.patId;
        // 指示者
        sendJson.ind_user = this.indUser;
        // 更新者
        sendJson.upd_user = this.getStateUserAccountInfo.userId;
        // クール
        sendJson.ind_kur_cd = this.selectKurCdCopyTo;
        // ベッド
        sendJson.ind_bed_cd = this.selectBedCdCopyTo;
        // 投与薬剤有無
        sendJson.is_including_medicine = this.isIncludingMedicine;
        // 期限切れ確認
        if (!(await this.chkInExpiryDate(sendJson.dialysis_date_to))) {
          return;
        }

        // 共通ローダー表示
        // this.startLoadingScreen("保存中...");
        console.log("TreatPlanCopy.vue updateInfo this.startLoadingScreen();");
        this.startLoadingScreen();

        // 更新API呼び出し
        const response = await ApiHelper.post(
          "/mainData/copyTreatPlan",
          sendJson
        ).catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage("TreatPlanCopy.vue", "updateInfo", error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          console.log(
            "TreatPlanCopy.vue updateInfo throw error; this.finishLoadingScreen();"
          );
          this.finishLoadingScreen();
          throw error;
        });
        if (200 === response.status && undefined !== response.data.msgCd) {
          // メッセージ表示
          this.messageDialogInfo.messageCd = parseInt(response.data.msgCd);
          this.messageDialogInfo.type = "1";
          this.messageDialogInfo.stringParams = [""];
          this.messageDialogInfo.isDialogVisible = true;
          console.log(
            "TreatPlanCopy.vue updateInfo return; this.finishLoadingScreen();"
          );
          this.finishLoadingScreen();
          return;
        }

        // 処理タイプ(2:予定コーピ)
        sendJson.species = 2;

        // del #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
        // // 計算材料保持処理呼び出し
        // if (200 === response.status) {
        //   const params = {
        //     ope_cd: "",
        //     crud: "",
        //     facility_cd: this.facilityCd,
        //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
        //     pat_id: this.patId,
        //     ord_no: response.data,
        //     base_date: "",
        //     user_id: this.getStateUserAccountInfo.userId
        //   };
        //   let opeId = null;
        //   let kurEditMode = null;
        //   let baseDate = null;
        //   // 移動元クールが未登録ではなく
        //
        //   if (
        //     // mod FNSI7749-クール未登録の状態にもかかわらず連携イベントが登録される 周 start
        //     //this.selectKurCd != 0
        //     this.selectKurCdCopyTo != 0
        //     // mod FNSI7749-クール未登録の状態にもかかわらず連携イベントが登録される 周 end
        //   ) {
        //     //  新規
        //     kurEditMode = "C";
        //     opeId = "004007";
        //     // mod FutreNetWeb+SI課題管理No7067 趙 start
        //     // baseDate = this.selectedDialysisDate.replace(/-/g,"");
        //     if (this.propSelFlag === 0) {
        //       baseDate = this.selectedDialysisDate.replace(/-/g, "");
        //     } else {
        //       baseDate = this.dispDialysisDate.replace(/-/g, "");
        //     }
        //     // mod FutreNetWeb+SI課題管理No7067 趙 end
        //   }
        //
        //   // ビューア画面のスケジュールモーダルにてクールを未確定状態からクールを選択し保存した時
        //   if (this.settingIndData.propOrdNo) {
        //     // this.startLoadingScreen();
        //     await createJournal({ ...params, ope_cd: opeId, crud: kurEditMode, base_date: baseDate }).finally(() => {
        //       // this.finishLoadingScreen();
        //     });
        //   }
        // }
        // // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
        // del #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
        // 参照元画面更新フラグをON
        this.isRefresh = true;
        // 予実リストの更新
        this.setResultUpdate(new Date());
        console.log(
          "TreatPlanCopy.vue updateInfo hideModal this.finishLoadingScreen();"
        );
        // モーダルを閉じる
        this.finishLoadingScreen();
        this.hideModal();
      }
    },

    /**
     * 入力漏れチェック
     */
    checkInputLeak() {
      // メッセージ置換文字配列初期化
      this.messageDialogInfo.stringParams = [];
      // メッセージコード
      let messageCd = 22010001;
      // メッセージ表示文字列
      let dispStr = null;

      // 治療日入力チェック
      if (
        null === this.selectedDialysisDate ||
        "" === this.selectedDialysisDate
      ) {
        if (0 === this.propSelFlag) {
          dispStr = "コピー先 治療日";
        } else {
          dispStr = "コピー元 治療日";
        }
      }
      //コピー元 治療日 コピー先 治療日の必須入力スタイル
      if ("" === this.selectedDialysisDate) {
        this.setDateCopyBackground("rgba(255, 0, 0, 0.5)");
      }
      if ("" !== this.selectedDialysisDate) {
        this.setDateCopyBackground("#ffff99");
      }
      // 治療方法&クール入力チェック
      if (null === this.ordNo && null === dispStr) {
        dispStr = "コピー元 治療日 クール";
      }

      // 治療方法&クール入力チェック
      // コピー元治療日に治療日がない場合
      if (0 === this.treatmentAndKurList.length && null === dispStr) {
        dispStr = "コピー元 クール";
      }

      // 指示者入力チェック
      if (!this.indUser && !dispStr) {
        dispStr = "指示者";
      }

      // コピー先治療日上限チェック
      if (0 === this.propSelFlag && null === dispStr) {
        const maxDate = parseInt(dayjs(this.maxDate).format("YYYYMMDD"));
        const treatDate = parseInt(
          dayjs(this.selectedDialysisDate).format("YYYYMMDD")
        );
        if (treatDate > maxDate) {
          messageCd = 22010002;
          dispStr = `コピー先治療日は${dayjs(
            this.maxDate,
            "YYYY-MM-DD"
          ).format("YYYY年M月D日以下")}`;
        }
      }

      if (null !== dispStr) {
        // メッセージ表示
        this.messageDialogInfo.stringParams = [dispStr];
        this.messageDialogInfo.messageCd = messageCd;
        this.messageDialogInfo.isDialogVisible = true;
        return false;
      } else {
        // 入力漏れなし
        return true;
      }
    },

    /**
     * 使用期限のチェック
     */
    async chkInExpiryDate(CopyToDate) {
      // コピー元予定データの取得
      let treatSetObj = null;

      // mod 障害票一覧_患者経過総合ビューア_予定コピーNo.1 李 start
      // const storeTreatmentData = this.$store.getters["pat-viewer/getTreatmentData"][0];
      let storeTreatmentData =
        this.$store.getters["pat-viewer/getTreatmentData"][0];
      // mod 障害票一覧_患者経過総合ビューア_予定コピーNo.1 李 end

      for (const index in storeTreatmentData) {
        if (
          storeTreatmentData[index] &&
          storeTreatmentData[index].ordNo === this.ordNo
        ) {
          treatSetObj = storeTreatmentData[index];
        }
      }

      // add 障害票一覧_患者経過総合ビューア_予定コピーNo.1 李 start
      if (!treatSetObj) {
        // APIの引数作成
        const sendData = {};
        // 施設コード
        sendData.facility_cd = this.facilityCd;
        // 患者ID
        sendData.pat_id = this.patId;
        // 抽出開始日
        // #10266 同じ日に2つの異なる予定があります。2つ目の治療予定行セルコピを選択した場合、保存ボタンをクリックします。linjunfeng start
        // sendData.ind_start_date = this.selectedDialysisDate;
        sendData.ind_start_date = this.propDialysisDate;
        // #10266 同じ日に2つの異なる予定があります。2つ目の治療予定行セルコピを選択した場合、保存ボタンをクリックします。linjunfeng end
        // 抽出終了日
        // #10266 同じ日に2つの異なる予定があります。2つ目の治療予定行セルコピを選択した場合、保存ボタンをクリックします。linjunfeng start
        // sendData.ind_end_date = this.selectedDialysisDate;
        sendData.ind_end_date = this.propDialysisDate;
        // #10266 同じ日に2つの異なる予定があります。2つ目の治療予定行セルコピを選択した場合、保存ボタンをクリックします。linjunfeng end
        // 曜日パターン
        sendData.week_pattern = `[{ 'text': '全', 'done': true, 'value': 0 }]`;

        // RestAPI実行
        const response = await ApiHelper.post(
          "/mainData/sharingInfo/TreatDateList",
          sendData
        ).catch((err) => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage("TreatPlanCopy.vue", "chkInExpiryDate", err);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw err;
        });

        storeTreatmentData = response.data;
        for (const index in storeTreatmentData) {
          if (
            storeTreatmentData[index] &&
            storeTreatmentData[index].ordNo === this.ordNo
          ) {
            treatSetObj = storeTreatmentData[index];
          }
        }
      }
      // add 障害票一覧_患者経過総合ビューア_予定コピーNo.1 李 end

      let msg = "";
      // 治療条件
      const condObj = JSON.parse(treatSetObj.indCondInfo);
      const keyList = Object.keys(condObj);
      keyList.forEach((key) => {
        switch (Number(key)) {
          case 5: {
            // ダイアライザ,  dialyzer.dialyzerCd == condObj[5].value(文字列)
            const tmpDialyzerObj = this.$store.getters[
              "pat-viewer/getMstDialyzerData"
            ].filter((dialyzer) => dialyzer.dialyzerCd == condObj[key].value); // mod #9973 value Number→文字列  shiyw
            if (tmpDialyzerObj.length === 0) {
              break;
            }
            const dialyzerObj = tmpDialyzerObj[0];
            if (
              !fitTermCheckForUpdate(
                dialyzerObj.useStartDate,
                dialyzerObj.useEndDate,
                CopyToDate,
                CopyToDate
              )
            ) {
              msg +=
                "</br>" +
                dialyzerObj.modelNumber +
                "：" +
                dateFormat.normalDateWithCheck(dialyzerObj.useStartDate) +
                "～" +
                dateFormat.normalDateWithCheck(dialyzerObj.useEndDate);
            }
            break;
          }
          case 6:
          case 7:
          case 8:
          case 9:
          case 10:
          case 11:
          case 13: {
            // 吸着カラム/1次膜/2次膜/穿刺針(A/V/SN)/血液回路
            if (!condObj[key].value) {
              // シングルニードル使用の有無により、A/V、SNのいずれかがnullになる
              break;
            }
            // equipment.equipmentCd == condObj[13].value(文字列)
            const tmpEquipmentObj = this.$store.getters[
              "pat-viewer/getMstEquipmentData"
            ].filter(
              (equipment) => equipment.equipmentCd == condObj[key].value
            ); // mod #9973 value Number→文字列  shiyw
            if (tmpEquipmentObj.length === 0) {
              break;
            }
            const equipmentObj = tmpEquipmentObj[0];
            if (
              !fitTermCheckForUpdate(
                equipmentObj.useStartDate,
                equipmentObj.useEndDate,
                CopyToDate,
                CopyToDate
              )
            ) {
              msg +=
                "</br>" +
                equipmentObj.equipmentName +
                "：" +
                dateFormat.normalDateWithCheck(equipmentObj.useStartDate) +
                "～" +
                dateFormat.normalDateWithCheck(equipmentObj.useEndDate);
            }
            break;
          }
          case 15:
          case 19:
          case 25: {
            // 薬剤/調製薬剤項目
            // mod #9973 shiyw start
            //if (condObj[key].medicine_type === "1") {
            if (condObj[key].medicine_type == 1) {
              // mod #9973 shiyw  end
              // 薬剤の場合,medi.medicineCd == condObj[25].value(文字列)
              const tmpMediObj = this.$store.getters[
                "pat-viewer/getMstMedicineData"
              ].filter((medi) => medi.medicineCd == condObj[key].value); // mod #9973 value Number→文字列  shiyw
              if (tmpMediObj.length === 0) {
                break;
              }
              const mediObj = tmpMediObj[0];
              if (
                !fitTermCheckForUpdate(
                  mediObj.useStartDate,
                  mediObj.useEndDate,
                  CopyToDate,
                  CopyToDate
                )
              ) {
                msg +=
                  "</br>" +
                  mediObj.medicineName +
                  "：" +
                  dateFormat.normalDateWithCheck(mediObj.useStartDate) +
                  "～" +
                  dateFormat.normalDateWithCheck(mediObj.useEndDate);
              }
              // mod #9973 shiyw  start
              //} else if (condObj[key].medicine_type === "2") {
            } else if (condObj[key].medicine_type == 2) {
              // mod #9973 shiyw  end
              // 調製薬剤の場合,medi.medicineMixCd == condObj[25].value(文字列)
              const tmpMediObj = this.$store.getters[
                "pat-viewer/getMstMedicineMixTabooAllergyData"
              ].filter((medi) => medi.medicineMixCd == condObj[key].value); // mod #9973 value Number→文字列  shiyw
              if (tmpMediObj.length === 0) {
                break;
              }
              const mediObj = tmpMediObj[0];
              if (
                !fitTermCheckForUpdate(
                  mediObj.maxUseStartDate,
                  mediObj.minUseEndDate,
                  CopyToDate,
                  CopyToDate
                )
              ) {
                msg +=
                  "</br>" +
                  mediObj.medicineMixName +
                  "：" +
                  dateFormat.normalDateWithCheck(mediObj.maxUseStartDate) +
                  "～" +
                  dateFormat.normalDateWithCheck(mediObj.minUseEndDate);
              }
            }
            break;
          }
        }
      });

      // 投与薬剤
      const mediInfoObj = JSON.parse(treatSetObj.indMediInfo);
      for (const key in mediInfoObj) {
        // mod #9973 shiyw  start
        //if (mediInfoObj[key].medicine_type === "1") {
        if (mediInfoObj[key].medicine_type == 1) {
          // mod #9973 shiyw  end
          // 薬剤の場合
          const tmpMediObj = this.$store.getters[
            "pat-viewer/getMstMedicineData"
          ].filter((medi) => medi.medicineCd === mediInfoObj[key].cd);
          if (tmpMediObj.length === 0) {
            continue;
          }
          const mediObj = tmpMediObj[0];
          if (
            !fitTermCheckForUpdate(
              mediObj.useStartDate,
              mediObj.useEndDate,
              CopyToDate,
              CopyToDate
            )
          ) {
            msg +=
              "</br>" +
              mediObj.medicineName +
              "：" +
              dateFormat.normalDateWithCheck(mediObj.useStartDate) +
              "～" +
              dateFormat.normalDateWithCheck(mediObj.useEndDate);
          }
        } else {
          // 調製薬剤の場合
          const tmpMediObj = this.$store.getters[
            "pat-viewer/getMstMedicineMixTabooAllergyData"
          ].filter((medi) => medi.medicineMixCd === mediInfoObj[key].cd);
          if (tmpMediObj.length === 0) {
            continue;
          }
          const mediObj = tmpMediObj[0];
          if (
            !fitTermCheckForUpdate(
              mediObj.maxUseStartDate,
              mediObj.minUseEndDate,
              CopyToDate,
              CopyToDate
            )
          ) {
            msg +=
              "</br>" +
              mediObj.medicineMixName +
              "：" +
              dateFormat.normalDateWithCheck(mediObj.maxUseStartDate) +
              "～" +
              dateFormat.normalDateWithCheck(mediObj.minUseEndDate);
          }
        }
      }

      // 医療材料
      const equipInfoObj = JSON.parse(treatSetObj.indEquipInfo);
      for (const key in equipInfoObj) {
        if (equipInfoObj[key].equip_type === 0) {
          // 医療材料
          const tmpEquipObj = this.$store.getters[
            "pat-viewer/getMstEquipmentData"
          ].filter(
            (equipment) => equipment.equipmentCd === equipInfoObj[key].cd
          );
          if (tmpEquipObj.length === 0) {
            continue;
          }
          const equipObj = tmpEquipObj[0];
          if (
            !fitTermCheckForUpdate(
              equipObj.useStartDate,
              equipObj.useEndDate,
              CopyToDate,
              CopyToDate
            )
          ) {
            msg +=
              "</br>" +
              equipObj.equipmentName +
              "：" +
              dateFormat.normalDateWithCheck(equipObj.useStartDate) +
              "～" +
              dateFormat.normalDateWithCheck(equipObj.useEndDate);
          }
        } else if (equipInfoObj[key].equip_type === 1) {
          // ダイアライザ
          const tmpDialyzerObj = this.$store.getters[
            "pat-viewer/getMstDialyzerData"
          ].filter((dialyzer) => dialyzer.dialyzerCd === equipInfoObj[key].cd);
          if (tmpDialyzerObj.length === 0) {
            continue;
          }
          const dialyzerObj = tmpDialyzerObj[0];
          if (
            !fitTermCheckForUpdate(
              dialyzerObj.useStartDate,
              dialyzerObj.useEndDate,
              CopyToDate,
              CopyToDate
            )
          ) {
            msg +=
              "</br>" +
              dialyzerObj.modelNumber +
              "：" +
              dateFormat.normalDateWithCheck(dialyzerObj.useStartDate) +
              "～" +
              dateFormat.normalDateWithCheck(dialyzerObj.useEndDate);
          }
        }
      }

      if (msg) {
        let rtn = false;
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "",
          title: DIALOG_MESSAGES[13000072].title,
          // message: "指示期間に使用期間外となる項目が含まれています。" + msg + "</br>登録してよろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000072].message, msg),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: (answer) => {
            if (answer === 1) {
              rtn = true;
            } else {
              // 処理を中止するので保存ボタン無効を解除
              this.updateDisable = false;
            }
          },
        });
        return rtn;
      } else {
        // チェック対象項目なし / 期限切れ項目なしの場合
        return true;
      }
    },

    /**
     * 治療方法/クール/ベッドリスト作成
     * @description コピー元日時が選択されたタイミングでリスト作成
     * @param date コピー元治療日
     */
    // #10196 2つの異なる予定がありますが、第2の治療予定を選択した場合は、第1の治療が予定されている治療法となります。 linjunfeng start
    // async setTreatmentAndKurList(date) {
    async setTreatmentAndKurList(date, type) {
      this.startLoadingScreen();

      // #10196 2つの異なる予定がありますが、第2の治療予定を選択した場合は、第1の治療が予定されている治療法となります。 linjunfeng end
      const dataList = [];
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = this.facilityCd;
      // 患者情報
      paramJson.pat_id = this.patId;
      // 治療開始日時
      paramJson.ind_start_date = date;
      // 治療終了日時
      paramJson.ind_end_date = date;
      // 曜日パターン
      paramJson.week_pattern = "[{'text': '全','done': false,'value': 0}]";
      // 対象日時の治療情報取得
      const response = await ApiHelper.post(
        "/mainData/TreatDateList",
        paramJson
      ).catch((error) => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage("TreatPlanCopy.vue", "setTreatmentAndKurList", error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      }).finally(() => {
        this.finishLoadingScreen();
      });
      if (0 !== response.data) {
        response.data.forEach((eleItem) => {
          // リスト作成用オブジェクト
          const obj = {};
          // オーダー番号
          obj.ordNo = eleItem.ordNo;
          // 治療方法名
          const treatmentName = this.translateMstName(
            eleItem.indTreatmentCd,
            "treatment",
            this.mstTreamentData
          );
          // クール名
          const kurName = this.translateMstName(
            eleItem.indKurCd,
            "kur",
            this.mstKurData
          );
          // ベッド名
          const bedName = this.translateMstName(
            eleItem.indBedCd,
            "bed",
            this.mstBedData
          );
          // 表示文字列
          obj.text = this.addSpace(treatmentName, 7) + kurName;
          obj.treatmentName = treatmentName;
          obj.kurName = kurName;
          obj.bedName = bedName;
          dataList.push(obj);
        });
        // コピー元が格納されている場合、治療方法&クール表示文字列に格納
        if (0 === this.propSelFlag) {
          const orgTreatInfo = dataList.find((item) => {
            return item.ordNo === this.ordNo;
          });
          this.dispTreatmethod = orgTreatInfo.treatmentName;
          this.dispKur = orgTreatInfo.kurName;
          this.dispBed = orgTreatInfo.bedName;
        }
      }
      this.treatmentAndKurList = dataList;
      // オーダー番号を格納
      if (0 !== this.treatmentAndKurList.length) {
        // リスト0番目を選択状態にする
        // #10196 2つの異なる予定がありますが、第2の治療予定を選択した場合は、第1の治療が予定されている治療法となります。 linjunfeng start
        // this.ordNo = this.treatmentAndKurList[0].ordNo;
        if (type === "selectdDate") {
          this.ordNo = this.treatmentAndKurList[0].ordNo;
        }
        // #10196 2つの異なる予定がありますが、第2の治療予定を選択した場合は、第1の治療が予定されている治療法となります。 linjunfeng end
      } else {
        // 未選択状態にする
        this.ordNo = null;
      }
    },

    /**
     * @description 対象日の[クール・ベッド設定済み治療予定]を取得する
     * @param date 対象治療日
     */
    async setOrdSchList(date) {
      // 共通ローダー表示
      this.setLoadingScreenMessage("治療予定取得中...");
      this.setLoadingScreenVisible(true);

      const formatDate = dayjs(date).format("YYYYMMDD");
      const url = "/mainData/getReservedOrdScheduleList/" + this.facilityCd + "/" + formatDate + "/" + this.patId;
      const response = await ApiHelper.post(
        url
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage("TreatPlanCopy.vue", "setOrdSchList", error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        this.setLoadingScreenVisible(false);
        throw error;
      });
      if (response.data) {
        this.ordSchList = [];
        response.data.forEach((eleItem) => {
          const obj = {
            patId: eleItem.patId,
            kurCd: eleItem.kurCd,
            bedCd: eleItem.bedCd,
          };
          this.ordSchList.push(obj);
        });
      }
      this.setLoadingScreenVisible(false);
    },

    /**
     * マスタ翻訳
     * @param cd 変換元のコード
     * @param mstName 翻訳するためのマスタ名(treatment, kur)
     * @param mstInfo 翻訳するマスタ情報(mstTreamentData, mstKurData)
     */
    translateMstName(cd, mstName, mstInfo) {
      const mstData = mstInfo.find((item) => {
        // 変換元コードとマスタのコードが一致するものを返す
        return item[`${mstName}Cd`] === cd;
      });
      // マスタにコードが存在しなければ
      if (!mstData) {
        return "未登録";
      } else {
        return mstData[`${mstName}Name`];
      }
    },

    /**
     * 文字列調整処理
     * @param  inputStr   入力文字列
     * @param  distLength 出力文字列
     * @return 調整した文字列
     */
    addSpace(inputStr, distLength) {
      //全角SPの準備
      const zenSpStr = "　";
      //半角SPの準備
      const hanSpStr = " ";

      //返却文字列
      let retStr = inputStr;

      //現在の文字列長の取得
      const nowLength = inputStr.length;
      //追加文字列長の取得
      const addLength = distLength - nowLength;

      //全角の個数の計算
      const zenSp = Math.floor(addLength / 2);
      //半角の個数の計算
      const hanSp = addLength % 2;

      //全角spの付加
      for (let i = 0; i < zenSp; i++) {
        retStr += zenSpStr;
      }

      //半角spの付加
      for (let i = 0; i < hanSp; i++) {
        retStr += hanSpStr;
      }
      //返却
      return retStr;
    },

    /**
     * 指定患者のすべての治療予定のある日付を取得
     */
    async getTreatDateList() {
      const dataList = [];
      // 本日の日付取得
      //mod FNSI-7629 劉全航 start
      //const day = dayjs().format("YYYYMMDD");
      //mod FNSI-7629 劉全航 end
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = this.facilityCd;
      // 患者情報
      paramJson.pat_id = this.patId;
      // 治療開始日時
      paramJson.ind_start_date = "0001-01-01";
      // 治療終了日時
      paramJson.ind_end_date = "9999-12-31";
      // 曜日パターン
      paramJson.week_pattern = "[{'text': '全','done': false,'value': 0}]";
      // 対象日時の治療情報取得
      const response = await ApiHelper.post(
        "/mainData/TreatDateList",
        paramJson
      ).catch((error) => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage("TreatPlanCopy.vue", "getTreatDateList", error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      if (0 !== response.data.length) {
        // 指定患者のすべての治療情報を格納
        this.ordMainList = response.data;
        response.data.forEach((eleItem) => {
          // add FNSI-改修内容 論理削除したの治療情報を修正 楊 start
          if (eleItem.isDel === "1") {
            return;
          }
          // add FNSI-改修内容 論理削除したの治療情報を修正 楊 end
          const treatDate = eleItem.treatDate;
          // 重複無しフラグ
          let disDuplicate = true;
          // すでに格納済みの治療日がある場合はfalseを返す
          dataList.forEach((treatItem) => {
            if (treatItem === treatDate) {
              disDuplicate = false;
            }
          });
          // 重複がなければ格納する
          if (disDuplicate) {
            // 治療日が今日含む未来日のみを格納する
            //mod FNSI-7629 劉全航 start
            // if (Number(treatDate) >= Number(day)) {
            //   dataList.push(treatDate);
            // }
            dataList.push(treatDate);
            //mod FNSI-7629 劉全航 end
          }
        });
      }
      this.treatList = dataList;
      // 治療日無しリストの作成
      this.getDisTreatDateList(dataList);
      // コピー元治療日のカスタムカレンダー表示フラグをtrueに切替
      this.customCalendarFlag = true;
    },

    /**
     * 治療がない日付の取得
     * @description 本日から来年の昨日までの期間で
     *              治療予定のない日時をリストで作成し渡す
     * @param dataList 治療日リスト
     */
    getDisTreatDateList(dataList) {
      // 治療日無しリスト初期化
      this.disabledDateList = [];
      // 対象期間のすべての日時リスト
      const targetPeriodDateList = [];

      // 本日の日付を取得
      let startDate = dayjs(dataList[0]);
      // 本日から1年後の日付を取得
      let endDate = dayjs(startDate).add(1, "year");
      // 一年後から1日戻す
      endDate = dayjs(endDate).subtract(1, "days");

      // 今日から来年の昨日までの日時をリストで取得
      while (startDate.diff(endDate) <= 0) {
        targetPeriodDateList.push(dayjs(startDate).format("YYYYMMDD"));
        startDate = startDate.add(1, "days");
      }

      // 今日から来年の昨日までの日付をループ
      targetPeriodDateList.forEach((eleDate) => {
        // 重複無しフラグ
        let disDuplicateFlag = true;
        // 治療日の日をループ
        dataList.forEach((date) => {
          // 重複があれば重複無しフラグをfalseに変更
          if (eleDate === date) {
            disDuplicateFlag = false;
          }
        });
        // 重複が無い場合、格納する
        if (disDuplicateFlag) {
          this.disabledDateList.push(eleDate);
        }
      });
    },

    /**
     * コピー先に治療方法、クールの被りがないかチェック
     */
    checkDuplicateData() {
      // 治療元の治療情報を取得
      const ordMain = this.ordMainList.filter((obj) => {
        obj.ordNo = this.ordNo;
      });
      let duplicateFlag = false;
      // コピー先に治療方法、クールの被りがあればtrue
      this.ordMainList.forEach((ordMainitem) => {
        if (
          ordMainitem.indTreatmentCd === ordMain.indTreatmentCd &&
          ordMainitem.indKurCd === ordMain.indKurCd &&
          ordMainitem.treatDate ===
            dayjs(this.selectedDialysisDate, "YYYY-MM-DD").format("YYYYMMDD")
        ) {
          duplicateFlag = true;
        }
      });
      return duplicateFlag;
    },

    /**
     * メッセージダイアログ返答処理
     */
    confirmResult() {
      // メッセージが表示された場合、更新不可フラグをfalseに
      this.updateDisable = false;
    },
    /** コピー元治療日／コピー先治療日フォーカスアウト時の処理 */
    onBlurDialysisDate() {
      if (this.beforeDialysisDate === this.selectedDialysisDate) {
        return;
      }
      this.calendarDialysisDate = this.selectedDialysisDate;
    },
  },
};
</script>

<style scoped>
.row-style {
  padding: 5px 10px;
}

.row-style-footer {
  padding: 5px 10px;
}

.col-style-right,
.col-style-right-title {
  text-align: right;
  padding-right: 2em;
}

.col-style-left {
  min-width: 200px;
  text-align: left;
  padding-left: 2em;
}

input::-webkit-calendar-picker-indicator {
  display: none;
}

@media screen and (max-width: 450px) {
  .row-style {
    padding: 5px 0px;
  }

  .col-style-right {
    display: none;
  }

  .col-style-right-title {
    text-align: left;
    padding-right: 0.1em;
  }

  .col-style-left {
    text-align: left;
    padding-left: 0;
  }

  .date-input {
    width: 120px;
  }
}
/* add FNSI-患者経過総合ビューア 画面デザイン 李 start */
.width-padding {
  width: 100px;
  padding-top: 8px;
}
/* add FNSI-患者経過総合ビューア 画面デザイン 李 end */
/* add 7952 必須項目にも関わらず背景色が黄色になっていない 張 start */
.select-style-list > span {
  background-color: #ffff99 !important;
}
/* add 7952 必須項目にも関わらず背景色が黄色になっていない 張 end */
</style>
