/** * 除外期間 */
<template>
  <modal-base @onClose="cancel">
    <div slot="body" class="main-content">
      <div class="padding-top" style="display: flex; flex-wrap: wrap; align-items: center;">
        <label class="padding-left ex-period-lb-nowrap">患者ID: {{ hospPatId }}</label>
        <div class="ex-period-flex-nowrap" style="align-items: center;">
          <label class="padding-left ex-period-lb-nowrap">患者名: {{ patName }}</label>
          <img class="same-icon" v-show="isSame === '1'" :src="image_src_same" />
        </div>
      </div>
      <div class="ex-period-flex-nowrap padding-top" style="align-items: center; justify-content: space-between;">
        <label class="padding-left ex-period-lb-nowrap" style="padding-right: 0.5em;">除外期間</label>
        <!-- mod FNSI-患者経過総合ビューア 画面デザイン 徐 start -->
        <!-- <button
          class="button registration-btn"
          style="float: right;margin-right: 0.5em;"
          @click="addList"
        > -->
        <button
          class="btn3-normal registration-btn button"
          style="margin-right: 0.5em; min-width: 7em;"
          @click="addList"
        >
          <!-- mod FNSI-患者経過総合ビューア 画面デザイン 徐 end -->
          除外期間追加
        </button>
      </div>
      <div class="padding-top">
        <table class="mon-table">
          <thead>
            <tr>
              <th class="mon-table-head-one">No</th>
              <!-- mod FNSI-redmine5062 徐 start -->
              <!-- <th class="mon-table-head-one">From</th>
              <th class="mon-table-head-one">To</th> -->
              <th class="mon-table-head-one">除外開始日</th>
              <th class="mon-table-head-one">除外終了日</th>
              <!-- mod FNSI-redmine5062 徐 end -->
              <th class="mon-table-head-one">削除</th>
            </tr>
          </thead>
          <tbody>
            <template v-for="(data, index) in dateList">
              <tr :key="index">
                <td class="align-center mon-list-body-td">
                  {{ index + 1 }}
                </td>
                <td class="mon-list-body-td">
                  <div class="ex-period-flex-nowrap">
                    <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
                    <!-- <input
                      :id="'dateFrom-' + index"
                      class="ntss-input-date ntss-control-size"
                      type="date"
                      name="dialysis-from-date"
                      max="9999-12-31"
                      v-validate="'date_format:yyyy-MM-dd'"
                      v-model="data.exceptionPeriodFrom"
                      @keyup="showStartMsg(index)"
                    /> -->
                    <date-input
                      :id="'dateFrom-' + index"
                      class="ntss-input-date ntss-control-size"
                      :classes="isEdited(index, 'exceptionPeriodFrom')"
                      name="dialysis-from-date"
                      v-validate="'date_format:yyyy-MM-dd'"
                      v-model="data.exceptionPeriodFrom"
                      @handleClearInput="data.exceptionPeriodFrom = null"
                      @keyup="showStartMsg(index)"
                    />
                    <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
                    <common-calendar v-model="data.exceptionPeriodFrom" />
                  </div>
                </td>
                <td class="mon-list-body-td">
                  <div class="ex-period-flex-nowrap">
                    <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
                    <!-- <input
                      :id="'dateTo-' + index"
                      class="ntss-input-date ntss-control-size"
                      type="date"
                      name="dialysis-to-date"
                      max="9999-12-31"
                      v-validate="'date_format:yyyy-MM-dd'"
                      v-model="data.exceptionPeriodTo"
                      @keyup="showEndMsg(index)"
                    /> -->
                    <date-input
                      :id="'dateTo-' + index"
                      class="ntss-input-date ntss-control-size"
                      :classes="isEdited(index, 'exceptionPeriodTo')"
                      name="dialysis-to-date"
                      v-validate="'date_format:yyyy-MM-dd'"
                      v-model="data.exceptionPeriodTo"
                      @handleClearInput="data.exceptionPeriodTo = null"
                      @keyup="showEndMsg(index)"
                    />
                    <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
                    <common-calendar v-model="data.exceptionPeriodTo" />
                  </div>
                </td>
                <td class="mon-list-body-td">
                  <v-ons-select
                    input-id="isDel"
                    v-model="data.isDel"
                  >
                    <option
                      v-for="(option, index) in nextPatList"
                      :key="option.length"
                      :value="index"
                    >
                      {{ option.name }}
                    </option>
                  </v-ons-select>
                </td>
              </tr>
            </template>
          </tbody>
        </table>
      </div>
    </div>
    <!-- 閉じる、保存ボタン -->
    <div slot="footer" class="flex-container">
      <!-- mod FNSI-患者経過総合ビューア 画面デザイン 徐 start -->
      <!-- <button class="common-style-cancel-button button" @click="cancel">閉じる</button>
      <button class="common-style-ok-button button" @click="reflect">保存</button> -->
      <button class="btn2-cancel button" style="width: 80px;padding-top: 8px;" @click="cancel">閉じる</button>
      <button class="btn1-execute button" style="width: 80px;padding-top: 8px;" @click="reflect">保存</button>
      <!-- mod FNSI-患者経過総合ビューア 画面デザイン 徐 end -->
    </div>
  </modal-base>
</template>

<script>
import { ApiHelper } from "@/apis/AxiosHelper";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { mapActions, mapGetters } from "vuex";
import SubModalBase from "@/components/modals/SubModalBase";
import MultiSubModalMixin from "@/components/modals/MultiSubModalMixin";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end;
//FNSI-修正 #5660子ページのデータが保存すると、親ページが更新する lijiaxing add start
import { EventBus } from "@/eventBus.js";
//FNSI-修正 #5660子ページのデータが保存すると、親ページが更新する lijiaxing add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
//#5590 2023/04/20 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/20 ×を常に表示するように修正 張博 end

export default {
  // mixinの読込
  mixins: [MultiSubModalMixin],
  components: {
    "common-calendar": commonCalender,
    "modal-base": SubModalBase,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 end

  },
  data() {
    return {
      hospPatId: "",
      initDateList: [], // 編集前のデータ
      dateList: [],
      patName: "",
      // 同姓同名
      isSame: "",
      image_src_same: require("@/assets/name_duplication3.png"),
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      nextPatList: [
        { no: 0, name: "" },
        { no: 1, name: "削除" }
      ],
    };
  },
  methods: {
    ...mapActions("pat-viewer", ["selectOrdExceptionPeriod"]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
    }),
    addList() {
      this.dateList.push({
        exceptionPeriodFrom: null,
        exceptionPeriodTo: null,
        exceptionPeriodNo: null,
        patId: this.selectedPat ? this.selectedPat.pat_personal_main.pat_id : 0,
        facilityCd: this.getFacilityCd,
        isDel: 0,
      });
    },
    showStartMsg(e) {
      let saveButtonErrorFlg = {
        name: "dateFrom-" + e,
        id: "dateFrom-" + e,
        scope: "dateFrom-" + e,
      };
      if (this.dateList[e]["exceptionPeriodFrom"] && document.getElementById("dateFrom-" + e).validationMessage) {
        this.$validator.errors.items.push(saveButtonErrorFlg);
      } else {
        this.$validator.errors.removeById("dateFrom-" + e);
      }
    },
    showEndMsg(e) {
      let saveButtonErrorFlg = {
        name: "dateTo-" + e,
        id: "dateTo-" + e,
        scope: "dateTo-" + e,
      };
      if (this.dateList[e]["exceptionPeriodTo"] && document.getElementById("dateTo-" + e).validationMessage) {
        this.$validator.errors.items.push(saveButtonErrorFlg);
      } else {
        this.$validator.errors.removeById("dateTo-" + e);
      }
    },
    /**
     * キャンセルボタン押下時イベント処理
     */
    cancel() {
      // モーダルを閉じる.
      this.hideModal();
    },
    /**
     * 確定ボタン押下時イベント処理
     */
    reflect() {
      if (this.$validator.errors.items.length > 0) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES["00300006"].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: this.msgDiaLog,
        });
        return;
      }

      for (let i = 0; i < this.dateList.length; i++) {
        if (
          this.dateList[i].exceptionPeriodFrom &&
          this.dateList[i].exceptionPeriodTo
        ) {
          const startDate = this.dateList[i].exceptionPeriodFrom.replace(
            /-/g,
            ""
          );
          const endDate = this.dateList[i].exceptionPeriodTo.replace(/-/g, "");
          if (startDate && endDate) {
            if (Number(startDate) > Number(endDate)) {
              this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "チェックエラー",
                // message: "終了日時は開始日時より前に設定出来ません。",
                title: DIALOG_MESSAGES['00200117'].title,
                message: messageFormat(DIALOG_MESSAGES['00200117'].message)
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              });
              return;
            }
          }
        }
      }
      if (this.hospPatId) {
        this.setLoadingScreenMessage("処理中・・・");
        this.setLoadingScreenVisible(true);
        ApiHelper.post(
          "exceptionPeriod/saveExceptionPeriod",
          this.dateList
        ).finally(() => {
          this.setLoadingScreenVisible(false);
        });
      }
      // モーダルを閉じる.
      this.hideModal();
      //FNSI-修正 #5660子ページのデータが保存すると、親ページが更新する lijiaxing add start
      EventBus.$emit("refreshdata");
      //FNSI-修正 #5660子ページのデータが保存すると、親ページが更新する lijiaxing add end
    },
    isEdited(index, dateField) {
      // 編集前の値を取得
      const beforeVal = this.initDateList[index] ? this.initDateList[index][dateField] : null;
      // 編集後の値を取得
      const afterVal = this.dateList[index][dateField] ? this.dateList[index][dateField] : null;
      if (beforeVal != afterVal) {
        return "date-input-edited";
      }
      return "";
    },
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPat", "selectedPatName"]),
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
  },
  
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  async created() {
    this.hospPatId = this.selectedPat
      ? this.selectedPat.pat_personal_main.hosp_pat_id
      : "";
    this.patName = this.selectedPatName ? this.selectedPatName : "";
    this.isSame = this.selectedPat ? this.selectedPat.pat_main.is_same : "0";

    const patId = this.selectedPat
      ? this.selectedPat.pat_personal_main.pat_id
      : 0;
    const facilityCd = this.getFacilityCd;
    this.setLoadingScreenMessage("処理中・・・");
    this.setLoadingScreenVisible(true);
    const exceptionPeriodList = await ApiHelper.get(
      `exceptionPeriod/${patId}/${facilityCd}`
    ).catch((error) => {
      //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
      getErrorMessage("PatExcludedPeriodComponent.vue", "created", error);
      //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
      throw error;
    });
    this.setLoadingScreenVisible(false);

    if (exceptionPeriodList) {
      this.dateList = exceptionPeriodList.data;
    }

    if (this.dateList.length < 10) {
      const paramLength = 10 - this.dateList.length;
      for (let i = 0; i < paramLength; i++) {
        this.dateList.push({
          exceptionPeriodFrom: null,
          exceptionPeriodTo: null,
          exceptionPeriodNo: null,
          patId: this.selectedPat
            ? this.selectedPat.pat_personal_main.pat_id
            : 0,
          facilityCd: this.getFacilityCd,
          isDel: 0
        });
      }
    }
    // 編集前のデータを退避
    this.initDateList = JSON.parse(JSON.stringify(this.dateList));
  },
  watch: {},
};
</script>

<style scoped>
.mon-table-head-one {
  color: #fff;
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
  padding: 4px;
  border: solid 1px var(--ntss-list-border-color);
  border-top: none;
  white-space: pre;
  text-align: left;
  position: -webkit-sticky;
  position: sticky;
  top: 0;
  z-index: 1;
}
.mon-list-body-td {
  border: solid 1px var(--ntss-list-border-color);
  padding: 1px;
  color: var(--ntss-list-body-color);
}
.mon-table {
  border-collapse: collapse;
  width: 100%;
  margin: 0 auto;
  font-size: 1em;
  background-color: var(--ntss-list-background-color);
}
.align-center {
  text-align: center;
}
.same-icon {
  height: 1em;
  display: inline-block;
  margin-left: 0.5em;
}
.padding-top {
  padding-top: 0.3em;
}
.padding-left {
  padding-left: 1em;
}
.ex-period-flex-nowrap {
  display: flex;
  flex-wrap: nowrap;
}
.ex-period-lb-nowrap {
  white-space: nowrap;
}
</style>
