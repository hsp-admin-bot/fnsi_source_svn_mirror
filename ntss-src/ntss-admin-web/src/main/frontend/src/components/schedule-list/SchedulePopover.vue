<!-- スケジュール表吹き出し-->
<template>
  <!-- mod FutreNetWeb+SI課題管理No4981対応 呉 start -->
  <!--  <v-ons-popover-->
  <!--    :v-if="popoverVisible"-->
  <!--    :visible="popoverVisible"-->
  <!--    :target="resolvedPopoverTarget"-->
  <!--    :direction="popoverDirection"-->
  <!--    :cover-target="popoverCoverTarget"-->
  <!--    cancelable-->
  <!--    @posthide="closePopover"-->
  <!--    :class="fontSizeSet"-->
  <!--  >-->
  <v-ons-popover
    id="popover-area"
    :visible="popoverVisible"
    :target="resolvedPopoverTarget"
    :direction="popoverDirection"
    :cover-target="popoverCoverTarget"
    cancelable
    :class="[fontSizeSet, 'schedule-popover-area']"
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="closePopover(); popoverPosthide($event)"
  >
    <!-- mod FutreNetWeb+SI課題管理No4981対応 呉 end -->
    <div ref="popoverAreaRoot" class="popover-area">
      <v-ons-row style="margin-bottom: 10px;" align="top">
        <v-ons-col class="popover-col-margin" style="font-size: 1.5em;">表示基準日</v-ons-col>
        <v-ons-col>
          <div class="flex-align-center">
            <date-input
              v-model="startDate"
              :classes="'ntss-input-date ntss-custom-input'"
              id="treatment-date"
              name="treatment-date"
              data-validation-scope="treatment"
              min="1880-01-01"
              max="2099-12-31"
              isRequired
            />
            <common-calendar v-model="startDate" />
          </div>
          <!-- add FNSI 共通展開No.1 start -- Sanjingye Sun 20210104 -->
          <span class="error-message">{{
            getValidationError("treatment.treatment-date")
          }}</span>
          <!-- add FNSI 共通展開No.1 end -- Sanjingye Sun 20210104 -->
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="popover-row">
        <v-ons-col class="popover-col-margin">表示期間</v-ons-col>
        <v-ons-col style="display: flex; flex-wrap: wrap;">
          <div style="white-space: nowrap; margin-right: 5px;">
            <v-ons-radio
              v-model="dispWeekDuration"
              name="radiogroupDispTerm"
              value="1"
              modifier="round"
              input-id="radDispWeekDuration1"
            />
            <label for="radDispWeekDuration1" class="popover-rad-lbl">1週</label>
          </div>
          <div style="white-space: nowrap; margin-right: 5px;">
            <v-ons-radio
              v-model="dispWeekDuration"
              name="radiogroupDispTerm"
              value="2"
              modifier="round"
              input-id="radDispWeekDuration2"
            />
            <label for="radDispWeekDuration2" class="popover-rad-lbl">2週</label>
          </div>
          <div style="white-space: nowrap;">
            <v-ons-radio
              v-model="dispWeekDuration"
              name="radiogroupDispTerm"
              value="3"
              modifier="round"
              input-id="radDispWeekDuration3"
            />
            <label for="radDispWeekDuration3" class="popover-rad-lbl">3週</label>
          </div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="popover-row">
        <v-ons-col class="popover-col-margin">休日表示</v-ons-col>
        <v-ons-col>
          <v-ons-checkbox input-id="chkDispHoliday" v-model="isCheckedHoliday" />
          <label for="chkDispHoliday" class="popover-chk-lbl">休日を表示する</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="popover-row popover-row-kur" align="top">
        <v-ons-col class="popover-col-margin">クール</v-ons-col>
        <v-ons-col class="schedule-kur-multiselect">
          <kendo-multiselect
            v-if="kurNum !== null && kurMultiselectReady"
            v-model="selectedKurIndexList"
            :data-source="kurNamesForOption"
            data-text-field="kurName"
            data-value-field="index"
            placeholder="クール"
            style="width: 100%;"
            @open="onScheduleKurMultiselectOpen($event)">
          </kendo-multiselect>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="popover-row">
        <v-ons-col class="popover-col-margin" style="white-space: pre-line;">{{ "ベッドグループ\n透析室" }}</v-ons-col>
        <v-ons-col>
          <!-- mod 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 start -->
<!--          <v-ons-select v-if="roomBedGroupNum !== null" input-id="bedGroupCd" v-model="selectedBedIndexList">-->
<!--                <option-->
<!--                  v-for="option in roomBedOption"-->
<!--                  :key="option.length"-->
<!--                  :value="option.bedCd"-->
<!--                >{{ option.bedName }}</option>-->
<!--              </v-ons-select>-->
          <v-ons-select v-if="roomBedGroupNum !== null" input-id="bedGroupCd" v-model="selectedRoomBedGroupCd">
                <option
                  v-for="option in roomBedOption"
                  :key="option.length"
                  :value="option.bedCd"
                >{{ option.bedName }}</option>
              </v-ons-select>
          <!-- <kendo-dropdownlist
            v-if="roomBedGroupNum !== null"
            v-model="selectedRoomBedGroupCd"
            :data-source="roomBedOption"
            data-text-field="bedName"
            data-value-field="bedCd"
            style="width: 12em;">
          </kendo-dropdownlist> -->
          <!-- mod 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 end -->
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="popover-row">
        <v-ons-col class="popover-col-margin">姓のみ表示</v-ons-col>
        <v-ons-col>
          <v-ons-checkbox input-id="chkDispOnlyLastName" v-model="isCheckedName" />
          <label for="chkDispOnlyLastName" class="popover-chk-lbl">姓のみ表示する</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="popover-row">
        <v-ons-col class="popover-col-margin">不一致！表示</v-ons-col>
        <v-ons-col>
          <v-ons-checkbox input-id="chkUnmatchMark" v-model="isCheckedUnmatch" />
          <label for="chkUnmatchMark" class="popover-chk-lbl">表示する</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="popover-row">
        <v-ons-col class="popover-col-margin">他の予定有◆表示</v-ons-col>
        <v-ons-col>
          <v-ons-checkbox input-id="chkOtherPlanMark" v-model="isCheckedPlan" />
          <label for="chkOtherPlanMark" class="popover-chk-lbl">表示する</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="popover-row">
        <v-ons-col class="popover-col-margin">定期点検・水質検査予定■表示</v-ons-col>
        <v-ons-col>
          <v-ons-checkbox input-id="chkMainteWaterPlanMark" v-model="isCheckedPlanMainteWater" />
          <label for="chkMainteWaterPlanMark" class="popover-chk-lbl">表示する</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="popover-row">
        <v-ons-col vertical-align="top" class="popover-col-margin">凡例の表示</v-ons-col>
        <v-ons-col>
          <v-ons-switch v-model="isShowUsageGuide"></v-ons-switch>
        </v-ons-col>
      </v-ons-row>
      <!--
          <v-ons-row>
            <v-ons-col>日付の非表示確認</v-ons-col>
            <v-ons-col>
              <v-ons-button @click="hiddenDays([7, 9])">
                Hide
              </v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col>POPOVER</v-ons-col>
            <v-ons-col>
              <v-ons-button @click="showPopoverSetting($event, 'down', false)">
                Show
              </v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col>※画面モード</v-ons-col>
            <v-ons-col>
              <v-ons-button @click="setPrintMode">印刷用表示</v-ons-button>
              <v-ons-button @click="setNormalMode">通常表示</v-ons-button>
            </v-ons-col>
          </v-ons-row>
          -->
      <v-ons-row class="popover-button-row">
        <v-ons-col colspan="2">
          <!-- mod FNSI 共通展開No.1 start -- Sanjingye Sun 20210105 -->
          <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
          <!-- <v-ons-button
            class="cls-select common-style-ok-button"
            style="float: right;"
            @click="changeSetting"
            :disabled="selectedKurIndexList.length === 0 || hasValidationErrorsIn('treatment')"
          >
            OK
          </v-ons-button> -->
          <v-ons-button
            class="cls-select common-style-ok-button btn1-execute"
            style="float: right;"
            @click="changeSetting"
            :disabled="selectedKurIndexList.length === 0 || hasValidationErrorsIn('treatment')"
          >
            OK
          </v-ons-button>
          <!-- mod FNSI 共通展開No.1 end -- Sanjingye Sun 20210105 -->
          <!-- <v-ons-button
            class="cls-select common-style-cancel-button"
            style="float: left;"
            @click="closePopover"
          >
            キャンセル
          </v-ons-button> -->
          <v-ons-button
            class="cls-select common-style-cancel-button btn2-cancel"
            style="float: left;"
            @click="closePopover"
          >
            キャンセル
          </v-ons-button>
          <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
        </v-ons-col>
      </v-ons-row>
      <!--/table-->
    </div>
  </v-ons-popover>
</template>

<script>
  import { ApiHelper } from "@/apis/AxiosHelper";
  import dayjs from "@/compat/date/dayjs";
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  import PopoverMixin from "@/components/PopoverMixin";
  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
  import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
  import {
    popoverPreShow as commonPopoverPreShow,
    popoverPostShow as commonPopoverPostShow,
    popoverPosthide as commonPopoverPosthide
  } from "@/functions/common/CommonPopoverFunctions";
  import {EventBus} from "@/compat/vue/event-bus.js";
  import DateInput from "@/components/common/DateInput";

  export default {
    mixins: [PopoverMixin],
    components: {
      "common-calendar": commonCalender,
      "date-input": DateInput,
    },
    props: {
      popoverVisible: {
        type: Boolean,
        required: true,
        default: false
      },

      popoverTarget: {
        type: [Object, MouseEvent],
        default: null,
        required: false
      },

      popoverDirection: {
        type: String,
        required: true
      },

      popoverCoverTarget: {
        type: Boolean,
        required: true
      },

      kurNum: {
        type: Number,
        required: true
      },

      kurNamesForOption: {
        type: Array,
        required: true
      },

      roomBedGroupNum: {
        type: Number,
        required: true
      },

      roomBedGroupNamesForOption: {
        type: Array,
        required: true
      },

      startDateMain: {
        type: String,
        required: true
      },

      isCheckedHolidayMain: {
        type: Boolean,
        required: true
      },

      dispWeekDurationMain: {
        type: String,
        required: true
      },

      selectedKurIndexListMain: {
        type: Array,
        required: true
      },

      selectedRoomBedGroupCdMain: {
        type: Number,
        required: true
      },

      isCheckedNameMain: {
        type: Boolean,
        required: true
      },

      notYetLineMain: {
        type: Number,
        required: true
      },

      isCheckedUnmatchMain: {
        type: Boolean,
        required: true
      },

      isCheckedPlanMain: {
        type: Boolean,
        required: true
      },

      isCheckedPlanMainteWaterMain: {
        type: Boolean,
        required: true
      },

      isShowUsageGuideMain: {
        type: Boolean,
        required: false
      }
    },

    data() {
      return {
        // 設定変更前の条件
        dispSettingNow: null,

        //カレンダー表示開始日
        startDate: this.startDateMain,
        // 表示する週間
        dispWeekDuration: this.dispWeekDurationMain,
        // 休日フラグ
        isCheckedHoliday: this.isCheckedHolidayMain,
        // 選択したクール
        selectedKurIndexList: this.selectedKurIndexListMain,
        // 選択したベッド
        selectedRoomBedGroupCd: this.selectedRoomBedGroupCdMain,

        isCheckedName: this.isCheckedNameMain,

        notYetLine: this.notYetLineMain,

        isCheckedUnmatch: this.isCheckedUnmatchMain,

        isCheckedPlan: this.isCheckedPlanMain,
        
        isCheckedPlanMainteWater: this.isCheckedPlanMainteWaterMain,

        isShowUsageGuide: this.isShowUsageGuideMain,

        // ポップオーバー位置確定前に Kendo MultiSelect を描画しない（×・矢印のチラつき防止）
        kurMultiselectReady: false
      };
    },

    computed: {
      resolvedPopoverTarget() {
        const target = this.popoverTarget;
        if (target?.target?.nodeType === 1) {
          return target.target;
        }
        if (target?.nodeType === 1) {
          return target;
        }
        return target || this.$el?.parentElement || this.$el || null;
      },
      roomBedOption() {
        return [{ bedCd: 0, bedName: "すべて" }, ...this.roomBedGroupNamesForOption];
      },

      /**
       * @description 表示開始日取得
       */
      getStartDate() {
        if (this.startDate === "" || this.startDate === null) {
          // 日付がありえない場合、this.dispStartDateが""になるので、代わりに当日を設定
          return dayjs().format("YYYY-MM-DD");
        }

        return this.startDate;
      },

    },

    watch: {
      // add FNSI 共通展開No.1 start -- Sanjingye Sun 20210104
      "startDate":{
        handler(){
          this.resetValidation("treatment");
          setTimeout(() => {
            this.validateField("treatment.treatment-date");
          }, 0);
        }
      }
      // add FNSI 共通展開No.1 end -- Sanjingye Sun 20210104
    },

    created() {
      // del #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
      // add 7936 掲示板に連携通知がコンバートされていない 関 start
      // if (this.$route.params.startDate != undefined) {
      //   this.startDate = dayjs(this.$route.params.startDate).format("YYYY-MM-DD");
      // }
      // add 7936 掲示板に連携通知がコンバートされていない 関  end
      // del #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
      this.dispSettingNow = this.getDispSettingInfo();
    },

    beforeUnmount() {
      // dataの初期化
      Object.assign(this.$data, this.$options.data());
    },

    methods: {
      popoverPreShow(event) {
        this.kurMultiselectReady = false;
        commonPopoverPreShow(event);
      },
      popoverPostShow(event) {
        commonPopoverPostShow(event);
        this.$nextTick(() => {
          this.kurMultiselectReady = true;
        });
      },
      popoverPosthide(event) {
        commonPopoverPosthide(event);
        this.kurMultiselectReady = false;
      },
      // クール MultiSelect 下拉：升级前はボタン行と重なる位置に開き、升级後は次行へずれるため位置と z-index を補正する。
      onScheduleKurMultiselectOpen(e) {
        const anchorEl = e?.sender?.wrapper?.[0]
          || e?.sender?.mountNode?.firstElementChild
          || e?.sender?.mountNode
          || null;
        const popoverRoot = this.$refs.popoverAreaRoot
          || anchorEl?.closest?.(".schedule-popover-area")
          || document.getElementById("popover-area");
        const ownerDocument = popoverRoot?.ownerDocument || anchorEl?.ownerDocument || document;
        if (!popoverRoot?.querySelector && !anchorEl) {
          return;
        }
        let attempts = 0;
        const adjust = () => {
          const popupEl = Array.from(ownerDocument.querySelectorAll(".k-animation-container"))
            .filter((el) => {
              const style = ownerDocument.defaultView?.getComputedStyle(el);
              return style && style.display !== "none" && style.visibility !== "hidden";
            })
            .pop();
          const resolvedAnchor = anchorEl
            || popoverRoot?.querySelector?.(
              ".schedule-kur-multiselect .k-legacy-multiselect, .schedule-kur-multiselect .k-multiselect"
            );
          const buttonRow = popoverRoot?.querySelector?.(".popover-button-row");
          if (!popupEl?.offsetHeight || !resolvedAnchor) {
            if (++attempts < 15) {
              requestAnimationFrame(adjust);
            }
            return;
          }
          popupEl.style.setProperty("z-index", "20002", "important");
          popupEl.classList.remove("ntss-schedule-kur-popup-up");
          popupEl.style.removeProperty("--ntss-schedule-kur-popup-shift");
          if (!buttonRow) {
            return;
          }
          const popupTop = popupEl.getBoundingClientRect().top;
          const buttonTop = buttonRow.getBoundingClientRect().top;
          if (popupTop >= buttonTop - 1) {
            const shift = popupTop - buttonTop + 4;
            popupEl.style.setProperty("--ntss-schedule-kur-popup-shift", `${shift}px`);
            popupEl.classList.add("ntss-schedule-kur-popup-up");
          }
        };
        this.$nextTick(() => {
          adjust();
        });
      },
      messageContact(message, contactMsg){
        if (message != "") {
          message = message + "、" + contactMsg;
        } else {
          message = contactMsg;
        }
        return message;
      },
      /**
       * @description 各条件変更
       */
      changeSetting() {
        // 設定後の条件
        const dispSettingCommitted = this.getDispSettingInfo();
        // add FNS 検索条件ログ start -- Sanjingye Sun 20210127
        let message = "";
        // 表示開始日
        if (dispSettingCommitted.startDate) {
          message = this.messageContact(message, dispSettingCommitted.startDate);
        }
        // 表示期間
        if (dispSettingCommitted.dispTermNum) {
          message = this.messageContact(message, "表示期間:" + Number(dispSettingCommitted.dispTermNum) + "週");
        }
        // 休日表示
        if (dispSettingCommitted.dispHolidayFlag) {
          message = this.messageContact(message, "休日を表示する");
        }
        // クール
        if (dispSettingCommitted.dispKurDimStr) {
          const dispKurDimStr = dispSettingCommitted.dispKurDimStr.split(':');
          dispKurDimStr.forEach(i => {
            this.kurNamesForOption.forEach(j => {
              if (i == j.index) {
                message = this.messageContact(message, "クール:" + j.kurName);
              }
            });
          });
        }
        // ベッドグループ
        if (dispSettingCommitted.dispGroupDimStr === "all") {
          message = this.messageContact(message, "ベッドグループ透析室:すべて");
        } else {
          this.roomBedOption.forEach(i => {
            if (i.bedCd === dispSettingCommitted.dispGroupDimStr) {
              message = this.messageContact(message, "ベッドグループ透析室:" + i.bedName);
            }
          });
        }
        // 姓のみ表示
        if (dispSettingCommitted.dispNameFlag) {
          message = this.messageContact(message, "姓のみ表示");
        }
        // 不一致！表示
        if (dispSettingCommitted.dispUnmatchFlag) {
          message = this.messageContact(message, "不一致！表示");
        }
        // 他の予定有◆表示
        if (dispSettingCommitted.dispPlanFlag) {
          message = this.messageContact(message, "他の予定有◆表示");
        }
        // 定期点検・水質検査予定■表示
        if (dispSettingCommitted.dispPlanMainteWaterFlag) {
          message = this.messageContact(message, "定期点検・水質検査予定■表示");
        }
        // 凡例の表示
        if (dispSettingCommitted.dispUsageGuide) {
          message = this.messageContact(message, "凡例の表示");
        }
        if (message != "") {
          let msg = "検索条件が[" + message + "]で検索しました。";
          let paramObj = {'message': msg, 'functionName': 'スケジュール表'};
          ApiHelper.put("/logs/event/conditionlog", paramObj)
            .catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
              getErrorMessage('SchedulePopover.vue', 'messageContact', error);
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            });
        }
        // add FNSI 検索条件ログ end -- Sanjingye Sun 20210127
        // 設定前後の差分を確認: 差分があれば変更を実施
        const settingDiffFlag = this.isEditedSettingInfo(
          this.dispSettingNow,
          dispSettingCommitted
        );

        if (settingDiffFlag) {
          // 差分がある
          //変更を適用する(変更されている場合)
          // mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 start
          // this.$emit("apply-status", this.dispSettingNow, dispSettingCommitted);
          this.$emit("apply-status", this.dispSettingNow, dispSettingCommitted,"change");
          // mod #10388 施設カレンダからスケジュール表へ遷移した際の動作が正しくない 張玲 end
          // add #9725 特定の操作を行うとスケジュール表の予定が重なる/内容保持がされていない dou start
          this.dispSettingNow = dispSettingCommitted;
          // add #9725 特定の操作を行うとスケジュール表の予定が重なる/内容保持がされていない dou end
        }
        // add redmine 6057 yuqizheng start
        EventBus.$emit("indicationRefresh");
        // add redmine 6057 yuqizheng end
        // ポップオーバーを閉じる
        this.closePopover();
      },

      /**
       * @description 現在の設定条件取得
       */
      getDispSettingInfo() {
        const dispSettingInfo = {};

        //  表示開始日:YYYYMMDD
        dispSettingInfo.startDate = this.getStartDate;

        //  表示期間 「1週: "1"」「2週: "2"」「3週: "3"」
        dispSettingInfo.dispTermNum = this.dispWeekDuration;

        //  休日表示
        dispSettingInfo.dispHolidayFlag = this.isCheckedHoliday;

        //  クール
        let tmpIndexlist = "";
        this.selectedKurIndexList.forEach(i => {
          tmpIndexlist = tmpIndexlist + String(i) + ":";
        });
        dispSettingInfo.dispKurDimStr = tmpIndexlist.slice(0, -1);

        //  ベッドグループ
        // mod 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 start
        // if (this.selectedRoomBedGroupCd === "0") {
        if (this.selectedRoomBedGroupCd == "0") {
        // mod 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 end
          dispSettingInfo.dispGroupDimStr = "all";
        } else {
          dispSettingInfo.dispGroupDimStr = this.selectedRoomBedGroupCd;
        }

        //  姓のみ表示
        dispSettingInfo.dispNameFlag = this.isCheckedName;

        //  未登録エリア
        // v-modelでStringに変わるため
        dispSettingInfo.dispNotYetLineNum = Number(this.notYetLine);

        //  不一致表示
        dispSettingInfo.dispUnmatchFlag = this.isCheckedUnmatch;

        //  他の予定あり表示
        dispSettingInfo.dispPlanFlag = this.isCheckedPlan;
        
        //  定期点検・水質検査予定あり表示
        dispSettingInfo.dispPlanMainteWaterFlag = this.isCheckedPlanMainteWater;

        //  凡例の表示
        dispSettingInfo.dispUsageGuide = this.isShowUsageGuide;

        return dispSettingInfo;
      },

      /**
       * @description 選択した選択肢番号取得
       * @returns { String } "1:2:3:4:5"
       * TODO: この形式で返す必要は？
       */
      getSelectedKurIndex(optionList, selectedList) {
        let selectedIndexList = "";
        optionList.forEach((option, index) => {
          if (selectedList.includes(option)) {
            // 選択肢から選択された場合

            if (selectedIndexList !== "") {
              // 各番号を「：」で結合
              selectedIndexList += ":";
            }
            const selectedIndex = String(index + 1);
            selectedIndexList += selectedIndex;
          }
        });
        return selectedIndexList;
      },

      /**
       * @description 選択した選択肢番号取得
       * @returns { String } "1:2:3:4:5" また「"すべて"」は"0"
       * TODO: この形式で返す必要は？
       */
      getSelectedBedIndex(optionList, selectedList) {
        const all = selectedList.find(item => item === "すべて");
        if (all) {
          return "all";
        }

        // "all"は外す
        const options = optionList.filter(item => item !== "すべて");
        let selectedIndexList = "";
        options.forEach((option, index) => {
          if (selectedList.includes(option)) {
            // 選択肢から選択された場合

            if (selectedIndexList !== "") {
              // 各番号を「：」で結合
              selectedIndexList += ":";
            }
            const selectedIndex = String(index + 1);
            selectedIndexList += selectedIndex;
          }
        });
        return selectedIndexList;
      },

      /**
       * @description 条件設定前後の差分
       * @param 設定(変更前)
       * @param 設定(変更後)
       * @return true:変更あり false:変更なし
       */
      isEditedSettingInfo(beforeSetting, afterSetting) {
        for (const prop in beforeSetting) {
          if (beforeSetting[prop] !== afterSetting[prop]) {
            //不一致が見つかったので終了
            return true;
          }
        }
        return false;
      },

      /**
       * @description ポップオーバー非表示
       */
      closePopover() {
        this.$emit("popover-close", false);
      },

      getNameByIndex(nameList, indexList) {
        return nameList.filter((kur, index) => indexList.includes(index + 1));
      }
    }
  };
</script>

<!-- 個別スタイル定義 -->
<style scoped>
  .schedule-popover-area :deep(.popover) {
    width: auto;
  }
  .schedule-popover-area :deep(.popover__content) {
    width: 390px;
  }
  .popover-area {
    padding: 10px;
  }
  .popover-row {
    margin-bottom: 0.5em;
    font-size: 1.5em;
  }
  .popover-col-margin {
    flex: 0 0 45%;
    margin-right: 0.5em;
  }
  .popover-rad-lbl {
    margin-right: 0.3em;
  }

  /* add FNSI 共通展開No.1 start -- Sanjingye Sun 20210104 */
  .error-message {
    font-size: 0.8em;
  }
  input[type="date"] ~ .error-message {
    min-width: 180px;
  }
  /* add FNSI 共通展開No.1 end -- Sanjingye Sun 20210104 */

  /* クール行：ons-row の flex-wrap により label と MultiSelect が縦積みになるのを防ぐ */
  .schedule-popover-area :deep(ons-row.popover-row-kur),
  .schedule-popover-area :deep(.popover-row-kur) {
    flex-wrap: nowrap !important;
  }

  .schedule-popover-area :deep(ons-row.popover-row-kur .schedule-kur-multiselect),
  .schedule-popover-area :deep(.popover-row-kur .schedule-kur-multiselect) {
    flex: 1 1 0 !important;
    width: auto !important;
    min-width: 0 !important;
  }

  .schedule-popover-area .schedule-kur-multiselect :deep(> div),
  .schedule-popover-area .schedule-kur-multiselect :deep(.k-legacy-multiselect.k-multiselect),
  .schedule-popover-area .schedule-kur-multiselect :deep(.k-widget.k-multiselect.k-legacy-multiselect) {
    width: 100%;
    max-width: 100%;
    box-sizing: border-box;
    min-height: 0 !important;
  }

  .schedule-popover-area .schedule-kur-multiselect :deep(.k-legacy-multiselect > .k-input-values.k-multiselect-wrap::before) {
    content: none !important;
    display: none !important;
    height: 0 !important;
    float: none !important;
  }

  .schedule-popover-area .schedule-kur-multiselect :deep(.k-input-values.k-multiselect-wrap),
  .schedule-popover-area .schedule-kur-multiselect :deep(.k-multiselect-wrap.k-floatwrap) {
    display: flex !important;
    flex-wrap: wrap !important;
    align-items: center !important;
    align-content: flex-start !important;
    gap: 0 !important;
    min-height: 0 !important;
    max-height: 5em;
    overflow-y: auto;
  }

  .schedule-popover-area .schedule-kur-multiselect :deep(.k-chip-list.k-reset),
  .schedule-popover-area .schedule-kur-multiselect :deep(.k-selection-multiple.k-reset),
  .schedule-popover-area .schedule-kur-multiselect :deep(.k-multiselect-wrap > ul.k-reset) {
    display: contents !important;
  }

  .schedule-popover-area .schedule-kur-multiselect :deep(.k-chip.k-button),
  .schedule-popover-area .schedule-kur-multiselect :deep(.k-multiselect-wrap > ul.k-reset > li.k-button) {
    flex: 0 0 auto !important;
  }

  .schedule-popover-area .schedule-kur-multiselect :deep(.k-input-inner.k-input),
  .schedule-popover-area .schedule-kur-multiselect :deep(input.k-input) {
    flex: 0 1 20px !important;
    width: auto !important;
    min-width: 20px !important;
    max-width: 100% !important;
  }

  /* preshow 中（.popover が visibility:hidden）×・矢印だけ先に見えるのを防ぐ */
  .schedule-popover-area :deep(.popover[style*="visibility: hidden"] .schedule-kur-multiselect .k-clear-value),
  .schedule-popover-area :deep(.popover[style*="visibility: hidden"] .schedule-kur-multiselect .k-chip-remove-action),
  .schedule-popover-area :deep(.popover[style*="visibility: hidden"] .schedule-kur-multiselect .k-input-button),
  .schedule-popover-area :deep(.popover[style*="visibility: hidden"] .schedule-kur-multiselect .k-select) {
    visibility: hidden !important;
    opacity: 0 !important;
    pointer-events: none !important;
  }
</style>

<style>
.ntss-schedule-kur-popup-up {
  transform: translateY(calc(-1 * var(--ntss-schedule-kur-popup-shift, 0px))) !important;
}
</style>
