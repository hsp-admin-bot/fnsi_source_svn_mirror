<template>
  <modal-base @onClose="cancel" class="custom-modal">
    <div slot="body" class="body-content">
      <div class="search-item">
        <div class="display_box0">
          <label style="font-size: 1.5em;" class="header_padding">基準日</label>
          <date-input
            class="input-time ntss-input-date ntss-custom-input start-date"
            max="9999-12-31"
            :isRequired="true"
            v-model="getParamsCalendar.date"
            @blur="applyParamsDate"
          />
          <common-calendar
            class="calender start-date-comment"
            v-model="getParamsCalendar.date"
            @blur="applyParamsDate"
            @todayButtonClick="applyParamsDate"
          />
        </div>

        <div class="display_box1">
          <label id="lbl-select" style="font-size: 1.5em;">点検項目</label>
          <v-ons-select
            v-model="getParamsCalendar.layoutGroupCd"
            class="select-item"
            :disabled="getParamsCalendar.isModify"
          >
            <option
              v-for="item in listLayoutGroup"
              :key="item.mainteLayoutGroupCd"
              :value="item.mainteLayoutGroupCd"
            >{{ item.groupName }}</option>
          </v-ons-select>
        </div>
      </div>
      <vc-date-picker
        class="ntss-theme-screen"
        :columns="$screens({ default: 1, md: 2, lg: 3, xl: 4 })"
        :rows="$screens({ default: 12, md: 6, lg: 4, xl: 3 })"
        :is-expanded="true"
        :from-page="fromPage"
        :max-date="canSelectMaxDate"
        color="orange"
        mode="multiple"
        v-model="selectedDateList"
        is-inline
        @update:from-page="fromPageChanged"
        @transition-start="transitionStarted"
        @transition-end="transitionEnded"
      >
        <div
          slot="header-title"
          slot-scope="page"
          style="color: white;"
        >{{ page.yearLabel }}年{{ page.monthLabel }}</div>
      </vc-date-picker>
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background: none;">
        <button
          class="btn2-cancel button denial-btn"
          @click="cancel"
        >キャンセル</button>
      </div>
      <div class="registration-btn-area" style="background: none;">
        <button
          class="btn1-execute button registration-btn"
          :disabled="!isChanged"
          @click="registration"
        >保存</button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapActions, mapGetters } from "vuex";
import moment from "moment";
import { EventBus } from "@/eventBus";
import { sendRequestGetResultByDateSpan } from "@/apis/periodic-inspection";
import { InvalidLayoutGroupCd } from "@/constants/mainteConstants";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { deepCopy, hasEqualValues } from "@/functions/common/CommonFunctions";
import {
  confirmIsOkByKey,
  alertByKey,
} from "@/functions/common/OnsenFunctions";
import DateInput from "@/components/common/DateInput";

const TodayStyle = "background-color: #FFB6C1; color: #fff;";
const PlannedStyle = "background-color: #00BFFF; color: #fff;";
const SelectedStyle = "background-color: #dd6b20; color: #fff;";
const LabelFormat = "Y年M月D日";

export default {
  name: "multi-calender",
  mixins: [MultiModalMixin],
  components: {
    "common-calendar": commonCalender,
    "modal-base": ModalBase,
    "date-input": DateInput,
  },
  data() {
    return {
      selectedDateList: [],
      // システム日付の10年後までを選択可能範囲とする（過去日は制限なし）
      canSelectMaxDate: moment().add(10, "years").toDate(),
      fromPage: null,
      lastShowPage: null,
      oldDate: "",
      resultData: [],
      getResultDataPromise: null,
      lastChangedPage: null,
    };
  },
  computed: {
    ...mapGetters("periodic-inspection", [
      "getLayoutGroupListByMachineType",
      "getListMachine",
      "getMachineSelected",
      "getParamsCalendar",
      "getDataTemp",
    ]),
    selectedMachines() {
      return this.getListMachine.filter(
        x => this.getMachineSelected.includes(x.machineNo)
      );
    },
    listLayoutGroup() {
      // 点検レイアウトグループの選択肢を
      // 選択されているすべての装置の型式が対象のもののみに絞り込む
      const listLayoutGroup = [];
      this.getLayoutGroupListByMachineType.forEach(({
        typeInfo,
        mainteLayoutGroupCd,
        groupName,
      }) => {
        const includesEveryMachine = this.selectedMachines.every(
          item => typeInfo.includes(item.machineTypeCd)
        );
        if (includesEveryMachine) {
          listLayoutGroup.push({ mainteLayoutGroupCd, groupName });
        }
      });
      return listLayoutGroup;
    },
    isChanged() {
      // この画面では画面開始時には常に日付選択されていない状態になっているので
      // 日付が1件以上選択されている場合はtrueを返す
      return !!this.selectedDateList.length;
    },
    plannedStrings() {
      const plannedStrings = [];
      this.resultData.forEach(item => {
        const dateString = moment(item.menteDate, "YYYY-MM-DD")
          .format(LabelFormat);
        if (plannedStrings.includes(dateString)) return;
        plannedStrings.push(dateString);
      });
      return plannedStrings;
    },
  },
  methods: {
    ...mapActions("periodic-inspection", ["sendRequestCreateMenteTemp"]),
    ...mapActions("loading-screen", ["executeWithLoadingScreen"]),

    async cancel() {
      if (this.isChanged) {
        // title: "内容破棄",
        // message: "編集中の情報が破棄されます\nキャンセルしてよろしいですか？",
        const isOk = await confirmIsOkByKey(13000117);
        if (!isOk) {
          // 破棄確認でキャンセルされた場合は処理を中断する
          return;
        }
      }
      // （破棄確認でキャンセルされなかった場合は）この画面を閉じる
      this.close();
    },
    async registration() {
      const { layoutGroupCd: layoutGroupId, isModify } = this.getParamsCalendar;
      if (layoutGroupId === InvalidLayoutGroupCd) {
        // 点検項目（レイアウトグループ）が未選択の場合
        // title: "点検項目未選択",
        // message: "点検項目を選択してください。"
        alertByKey("00200120");
        return;
      }
      // #11961対応時のメモ：
      // 点検項目（レイアウトグループ）が選択されている場合は
      // this.getParamsCalendar.layoutGroupCd には
      // リストの選択肢のvalue値として
      // レイアウトグループコードを文字列にしたものが入っている
      // （ただし予定移動の場合は数値のままのレイアウトグループコードが入っている）

      await this.executeWithLoadingScreen(async () => {
        const machineInfoList = this.selectedMachines.map(item => ({
          machineNo: String(item.machineNo),
          machineTypeCd: item.machineTypeCd,
        }));
        const menteDateList = this.selectedDateList.map(
          dt => moment(dt).format("YYYY-MM-DD")
        );
        // 予定移動の場合は移動元の日付の情報を設定する
        const oldDate = [isModify ? this.oldDate : null];
        await this.sendRequestCreateMenteTemp({
          layoutGroupId,
          body: {
            machineInfoList,
            menteDateList,
            oldDate,
          },
        });
      });
      if (this.getDataTemp.length) {
        // 装置＋日付＋レイアウトグループコードが重複する既存レコードが存在した場合
        const { machineNo, menteDate } = this.getDataTemp[0];
        const machineName = this.selectedMachines.find(
          x => x.machineNo === machineNo
        )?.machineName || "";
        // title: "チェックエラー",
        // message: "装置「{machineName}」が{menteDate}に同じレイアウト予約があるので保存できません。",
        alertByKey(12000323, machineName, menteDate);
        return;
      }

      // 追加成功時はこの画面を閉じる
      this.close();
    },
    close() {
      // 親画面の表示更新を行う
      EventBus.$emit("postUpdate");
      this.hideModal();
    },
    fromPageChanged(page) {
      // ページ切り替え操作時などの transitionStarted を起点とした
      // 点検結果再読み込み処理で使用するために切り替え後のpage情報を保持する
      this.lastChangedPage = page;
    },
    transitionStarted() {
      // ページ切り替え操作時などに発生する直前の fromPageChanged で保持した
      // pageに従って点検結果データの再取得を開始する
      this.getResultDataPromise = this.executeWithLoadingScreen(
        this.getResultData(this.lastChangedPage)
      );
    },
    transitionEnded() {
      // カレンダーの切り替え前ページのDOM要素が消えるのを待つためのsetTimeoutと
      // transitionStarted で開始した点検結果データの再取得の完了を待って
      // 日付のDOM要素のスタイル設定を行う
      const tasks = [new Promise(resolve => { setTimeout(resolve); })];
      if (this.getResultDataPromise) {
        tasks.push(this.getResultDataPromise);
        this.getResultDataPromise = null;
      }
      this.executeWithLoadingScreen(
        Promise.all(tasks).then(this.setDayContentStyle)
      );
    },
    applyParamsDate() {
      // カレンダーの表示期間開始月を基準日に合わせて変更する
      const newFromDate = moment(this.getParamsCalendar.date);
      // 通常は this.fromPage からの12か月がカレンダー表示されるが
      // カレンダーには this.canSelectMaxDate の日付の月までしか表示されないので
      // その場合は this.fromPage の月とカレンダーの表示期間の開始月がずれ、
      // カレンダー表示期間が変化するかどうかの判定などに影響するため
      // this.canSelectMaxDate を考慮して補正した値にしておく
      const fromDateMax = moment(this.canSelectMaxDate).startOf("month")
        .subtract(11, "months");
      const fromDate = (newFromDate.isBefore(fromDateMax, "month"))
        ? newFromDate : fromDateMax;
      const newFromPage = {
        year: fromDate.year(),
        month: fromDate.month() + 1,
      };
      // 表示中の期間から変化がない場合は以降の処理は行わない
      if (hasEqualValues(this.fromPage, newFromPage)) return;
      this.fromPage = newFromPage;
      // #11961対応時のメモ：
      // this.fromPage を更新してカレンダー表示期間が変化する場合は
      // fromPageChanged transitionStarted transitionEnded の処理で
      // 点検結果を再取得して日付のスタイルの再設定が行われる
    },
    async getResultData(page) {
      // 点検結果を取得済みの期間から変化がない場合はAPIの呼び出しは行わない
      if (hasEqualValues(this.lastShowPage, page)) return;
      this.lastShowPage = null;

      // pageの月から12か月分の点検結果データを取得する
      const aMoment = moment({
        year: page.year,
        month: page.month - 1,
        day: 1,
      });
      const startDate = aMoment.format("YYYY-MM-DD");
      aMoment.add(11, "months").endOf("month");
      const endDate = aMoment.format("YYYY-MM-DD");
      const resultRes = await sendRequestGetResultByDateSpan(startDate, endDate);
      // 選択中の装置のデータのみに絞り込む
      const resultData = resultRes.data.filter(
        item => this.getMachineSelected.includes(item.machineNo)
      );
      this.resultData.splice(0, Infinity, ...resultData);
      this.lastShowPage = deepCopy(page);
    },
    setDayContentStyle() {
      const selectedStrings = this.selectedDateList.map(date => (
        moment(date).format(LabelFormat)
      ));
      const todayString = moment().format(LabelFormat);

      const elements = document.getElementsByClassName("vc-day-content");
      Array.from(elements).forEach(element => {
        const dayLabel = element.getAttribute("aria-label");
        const dayString = dayLabel.substring(0, dayLabel.indexOf("日") + 1);

        const style = selectedStrings.includes(dayString)
          ? SelectedStyle // 選択中の日付のスタイル設定
          : this.plannedStrings.includes(dayString)
            ? PlannedStyle // 点検予約がある日付のスタイル設定
            : (todayString === dayString)
              ? TodayStyle // システム日付のスタイル設定
              : ""; // スタイル設定の解除
        element.setAttribute("style", style);
      });
    },
  },
  created() {
    // 予定移動時の移動元日付の保持
    this.oldDate = this.getParamsCalendar.date;
    // this.getParamsCalendar.date を this.fromPage に反映する
    this.applyParamsDate();
    // #11961対応時のメモ：
    // created の時点で this.fromPage を設定しておくことで
    // （ this.getParamsCalendar.date がシステム日付以外の月の場合でも）
    // 画面開始時に transitionStarted transitionEnded が
    // 発生しないようにしている
  },
  mounted() {
    // 選択された装置に対する有効な点検レイアウトグループの選択肢が
    // 存在しない場合は以降の処理を中断する
    // （アラートメッセージを閉じるとこの画面も閉じられる）
    if (!this.listLayoutGroup.length) {
      // title: "定期点検レイアウト",
      // message: "選択したすべての装置に対応する定期点検レイアウトが存在しません。\n対象装置を変更するか、マスタをご確認ください。",
      alertByKey("00200159").then(this.close);
      return;
    }

    // 点検結果データの取得の完了を待って日付のDOM要素のスタイル設定を行う
    this.executeWithLoadingScreen(
      this.getResultData(this.fromPage).then(this.setDayContentStyle)
    );
  },
  watch: {
    selectedDateList() {
      // 日付のDOM要素のスタイル設定を再実行する
      this.setDayContentStyle();
    },
  },
};
</script>

<style scoped>
.body-content {
  padding: 10px;
}
.body-content >>> .vc-reset {
  border: none;
}
.body-content >>> .vc-weeks {
  padding: 0px;
}
.body-content >>> .weekday-1 {
  color: red;
}
.body-content >>> .weekday-7 {
  color: blue;
}
.search-item {
  display: flex;
  flex-wrap: wrap;
  width: 100%;
  margin-bottom: 20px;
}
.select-item {
  width: 200px;
  margin-left: 20px;
  height: 2em;
  font-size: 1.5em;
}
.input-time {
  font-size: 1.7em;
  margin-left: 20px;
}
@media only screen and (max-width: 750px) {
  .input-time {
    width: 66%;
    font-size: 1.7em;
  }
  #lbl-select {
    margin-left: 0px !important;
  }
  .select-item {
    width: 70%;
    margin-left: 16px;
    height: 2em;
    font-size: 1.5em;
  }
  .display_box1 {
    width: 95%;
    display: flex;
    align-items: center;
    margin-top: 5px;
  }
  .display_box0 {
    width: 90%;
    display: flex;
    align-items: center;
  }
  .header_padding {
    padding-left: 0px !important;
  }
}
@media only screen and (max-width: 360px) {
  .input-time {
    width: 60%;
    font-size: 1.7em;
    padding-left: 10px;
  }
  #lbl-select {
    margin-left: 0px !important;
  }
  .select-item {
    width: 65%;
    margin-left: 16px;
    height: 2em;
    font-size: 1.5em;
    margin-top: 8px;
  }
  .header_padding {
    padding-left: 0px !important;
  }
}

@media print {
  /* モーダル全般 */
  .modal-mask >>> .modal-container {
    width: 99%;
  }
  
  /* ページわかれるのを防止 */
  .modal-mask >>> .modal-wrapper {
    width: 100%;
  }
  .body-content >>> .vc-reset {
    margin-left: -10px;
  }
  /* 各月のpaneの余白調整 */
  .body-content >>> .vc-pane {
    margin-left: 5px !important;
    margin-right: 5px !important;
    break-inside: avoid;
  }
}
</style>
<style>
  .vc-text-lg {
    font-size: 18px;
    pointer-events: none;
  }
  .item-number {
    background-color: #00BFFF;
    color: #fff
  }
  .display_box1 {
    width: 50%;
    display: flex;
    align-items: center;
  }
  .display_box0 {
    width: 50%;
    display: flex;
    align-items: center;
  }
  .header_padding {
    padding-left: 15px;
  }
</style>
