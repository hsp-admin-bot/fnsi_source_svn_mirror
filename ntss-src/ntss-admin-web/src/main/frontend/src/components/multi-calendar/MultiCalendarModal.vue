/**
 * マルチカレンダー
 */
<template>
  <modal-base @onClose="cancel" class="custom-modal">
    <div slot='body' class='account-edit'>
      <div class="monthPicker" v-show="getModalTitle === '水質検査予定作成'">
        <label style="margin-right:20px;">指定年月</label>
        <input
          type="month"
          v-model="selectedMonth"
          max="2099-12"
          :min="sysMonth"
          @change="onChangeMonth($event)"
        />
      </div>
      <vc-date-picker
        :key="calendarKey"
        :columns="$screens({ default: 1, md: 2, lg: 3 ,xl: 4})"
        :rows="$screens({ default: 12, md: 6,  lg: 4, xl:3 })"
        :is-expanded='true'
        :min-date="canSelectMinDate"
        :max-date="canSelectMaxDate"
        color="orange"
        mode="multiple"
        v-model="selectedDateList"
        is-inline>
        <div slot='header-title' slot-scope='page' style="color:white">
          {{page.yearLabel}}年{{page.monthLabel}}
        </div>
      </vc-date-picker>
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button class="button denial-btn" @click="cancel">キャンセル</button> -->
        <button class="button btn2-cancel" @click="cancel">キャンセル</button>
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
      </div>
      <div class="registration-btn-area" style="background:none">
        <!--mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start-->
        <!-- <button class="button registration-btn" @click="registration" >確定</button> -->
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button class="button registration-btn" @click="registration" >保存</button> -->
        <span v-if="getModalTitle === '水質検査予定作成'">
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start-->
<!--          <button class="button registration-btn btn1-execute" @click="registration" >保存</button>  -->
          <button class="button registration-btn btn1-execute" :disabled="!isChanged" @click="registration" >保存</button>
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end-->
        </span>
        <span v-else>
          <button class="button registration-btn btn1-execute" @click="registration" >確定</button>
        </span>
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
        <!--mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end-->
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
import moment from 'moment';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "multi-calender",
  mixins: [MultiModalMixin],
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      //選択済の日付リスト
      selectedDateList: [],
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
      initSelectedDateList: [],
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
      //最小選択可能日付
      canSelectMinDate: null,
      //最大選択可能日付
      canSelectMaxDate: null,
      //指定年月
      selectedMonth: null,
      //現在年月
      sysMonth: null,
      //カレンダーキー
      calendarKey: 1
    };
  },
  computed: {
    ...mapGetters("multi-calendar", [
      "getSelectedDateList",
      "getDisplaySelectedDateList"
    ]),
    ...mapGetters("multi-modal", ["getModalTitle"]),
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
    isChanged() {
      let copySelectedDateList = JSON.parse(JSON.stringify(this.selectedDateList));
      if(copySelectedDateList === null || copySelectedDateList === ''){
        copySelectedDateList = [];
      }
      return JSON.stringify(this.initSelectedDateList) !== JSON.stringify(copySelectedDateList)
    }
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
  },
  methods: {
    ...mapActions("multi-calendar", [
      "setSelectedDateList",
      "setDisplaySelectedDateList",
      "setDsplayState"
    ]),
    /**
     * キャンセル処理
     */
    cancel() {
      const storeList = this.getDisplaySelectedDateList;
      const inputList = this.selectedDateList;
      // 変更の有無を判断
      var isChange = false;
      if (storeList.length != inputList.length){
        isChange = true;
      }else{
        for (let i = 0, n = storeList.length; i < n; ++i) {
          if (storeList[i] !== inputList[i]) isChange = true;
        }
      }
      // 変更がある場合はメッセージを表示
      if (isChange) {
        this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 1) {
              //OK
              this.close();
            }
          }
        });
      } else {
        this.close();
      }
    },
    /**
     * 確定処理
     */
    registration() {
      this.setDisplaySelectedDateList(this.selectedDateList);
      this.setSelectedDateList(this.convertSelectedDateList());
      this.close();
      EventBus.$emit("onCloseMultiCalendarModal");
      EventBus.$emit("createBulkPlan");
    },
    /**
     * 選択済の日付をyyyy-mm-ddに変換
     */
    convertSelectedDateList(){
      const dtList = [];
      this.selectedDateList.forEach(dt => {
        const y = dt.getFullYear();
        const m = ("00" + (dt.getMonth()+1)).slice(-2);
        const d = ("00" + dt.getDate()).slice(-2);

        dtList.push(y + "-" + m + "-" + d);
      });
      return dtList;
    },
    /**
     * ダイアログを閉じる
     */
    close(){
      this.hideModal();
      this.setDsplayState(false);
    },
    /**
     * 指定年月選択時の処理
     */
    onChangeMonth(e) {
      this.calendarKey = e.target.value;
      const sysDate = new Date();
      const selectMonth = new Date(e.target.value);

      if (e.target.value > this.sysMonth) {
        //未来の年月を指定した場合、指定年月から計算して最小日付・最大日付を更新する
        this.canSelectMinDate = moment(selectMonth).format("YYYY-MM-DD");
        this.canSelectMaxDate = moment(new Date(selectMonth.getFullYear(), selectMonth.getMonth() + 12, 0)).format("YYYY-MM-DD");
      } else {
        //現在年月を指定した場合、現在日付から計算して最小日付・最大日付を更新する
        this.canSelectMinDate = moment(sysDate).format("YYYY-MM-DD");
        this.canSelectMaxDate = moment(new Date(sysDate.getFullYear(), sysDate.getMonth() + 12, 0)).format("YYYY-MM-DD");
      }

      this.$nextTick(() => {
        this.reStyleCalendar();
      })
    },
    /**
     * カレンダーのスタイル設定(DOMでクラス設定ができない為ここでクラスを付与する)
     */
    reStyleCalendar() {
      let elemReset = document.getElementsByClassName('vc-reset');
      elemReset = Array.from( elemReset ) ;
      elemReset.forEach(obj => obj.style.border = "none");

      let elemsWeeks = document.getElementsByClassName('vc-weeks');
      elemsWeeks = Array.from( elemsWeeks ) ;
      elemsWeeks.forEach(obj => obj.style.padding = "0px");

      let elemSunDay = document.getElementsByClassName('weekday-1');
      elemSunDay = Array.from( elemSunDay ) ;
      elemSunDay.forEach(obj => obj.style.color = "red");

      let elemSuturDay = document.getElementsByClassName('weekday-7');
      elemSuturDay = Array.from( elemSuturDay ) ;
      elemSuturDay.forEach(obj => obj.style.color = "blue");
    }
  },
  created() {
    //表示状態を更新
    this.setDsplayState(true);
    //選択済日付リストの設定
    this.selectedDateList = Array.from(this.getDisplaySelectedDateList);
    //最小選択可能日付の設定（システム日付）
    const minDay = new Date();
    this.canSelectMinDate = minDay;
    //最大選択可能日付の設定（11か月後の月末）
    const maxDt = new Date(minDay.getFullYear(), minDay.getMonth() + 12, 0);
    this.canSelectMaxDate = maxDt;
    //現在年月
    this.sysMonth = moment(new Date()).format("YYYY-MM");
    //指定年月
    this.selectedMonth = this.sysMonth;
  },
  mounted() {
    this.reStyleCalendar();
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc start
    this.initSelectedDateList = JSON.parse(JSON.stringify(this.selectedDateList))
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_水質管理 20231225 ztc end
  }
};
</script>

<style scoped>
.monthPicker {
  margin: 5px 20px 20px 20px;
  text-align: left;
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
  .account-edit >>> .vc-reset {
    margin-left: -10px;
  }
  /* 各月のpaneの余白調整 */
  .account-edit >>> .vc-pane {
    margin-left: 5px !important;
    margin-right: 5px !important;
    break-inside: avoid;
  }
}
</style>
