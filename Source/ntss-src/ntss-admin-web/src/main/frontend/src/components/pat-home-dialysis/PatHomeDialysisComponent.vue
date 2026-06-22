<!-- お知らせ画面 -->
<template>
  <div class='main-content-area'>
    <div class="header-content">
      <label class="msg-lbl">{{ getUserName + "さん、" +  msg }}</label>
    </div>
    <div class="main-content">
    <v-touch @swipeleft="selectNextWeek()">
      <v-touch @swiperight="selectPreWeek()">
        <table class="grid-record-list" style="width: 98%;" align="center">
          <thead>
            <tr class="tr-month-list">
              <th colspan="7">
                <span @click="selectPreWeek()">＜＜</span>
                <span>{{dispCalender.preMonth}}月</span>
                <span>{{dispCalender.targetYear}}年{{dispCalender.targetMonth}}月</span>
                <span>{{dispCalender.nextMonth}}月</span>
                <span @click="selectNextWeek()">＞＞</span>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr>
            </tr>
            <tr class="tr-week-list">
              <th v-for='(item, index) in dispCalender.weeks' :key="index" :style="borderStyleTop(index)" :class="weeksStyle(index)">{{ item }}</th>
            </tr>
            <tr class="tr-week-list">
              <th v-for='(item, index) in dispCalender.weekDaylist' :key="index" :style="borderStyleCenter(index)" :class="daysStyle(index)">{{ item }}</th>
            </tr>
            <tr class="tr-event-list">
              <td v-for='(item, index) in dispCalender.weekDaylist' :key="index" :style="borderStyleBottom(index)" valign="top">
                  <div v-for='(eItem, eIndex) in eventData' :key="eIndex">
                    <div v-if="check(eItem,index)" class="td-event" @click="clickEvent(eItem)">
                      {{(eItem.categoryName ? eItem.categoryName : "") + (eItem.subCategoryName ? eItem.subCategoryName : "")}}
                    </div>
                  </div>
              </td>
            </tr>
          </tbody>
        </table>
      </v-touch>
    </v-touch>
    </div>
    <div class="main-content">
    <table class="info-from-hosp">
      <thead>
        <tr class="tr-info-head" align="left">
          <th>病院からのお知らせ</th>
        </tr>
      </thead>
      <tbody align="top">
        <tr class="tr-info-list" valign="top" >
          <td>
            <ul class="ul-info-list">
              <li v-for='(Item, Index) in eventData' :key="Index" @click="clickEvent(Item)">
                {{Item.strEventDate + " " + (Item.categoryName ? Item.categoryName : "") + (Item.subCategoryName ? Item.subCategoryName : "")}}
              </li>
            </ul>
          </td>
        </tr>
      </tbody>
    </table>
    </div>
    <div style="text-align:center; height:100px;"><v-ons-button class="button registration-btn start-btn" @click="next">透析を始める</v-ons-button></div>
  </div>
</template>

<script>
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import { CHANGE_IND_CATEGORY } from "@/constants/facilitySetting";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  data() {
    return {
      targetDate: new Date(),
      today:"",
      msg: "",
      dispCalender: {
        weeks:["月","火","水","木","金","土","日"],
        weekDaylist:[],
        weekDatelist:[],
        targetYear:"",
        targetMonth:"",
        nextMonth:"",
        preMonth:""
      },
      eventData:[],
      indChangeCategoryCd:""
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", [ "getStateUserAccountInfo", "getUserId","getUserName"]),
    ...mapGetters("pat-info", {
      headerPatId: "selectedPatId"
    }),
    weeksStyle(){
      return function (index) {
        if (index == 5) {
          return "th-week-satur"
        }
        else if(index == 6){
          return "th-week-sun"
        }
        else{
          return "th-week-days"
        }
      }
    },
    daysStyle(){
      return function (index) {
        let dt = new Date(this.dispCalender.weekDatelist[index]);
        let dtyear = dt.getFullYear();
        let dtMonth = dt.getMonth() + 1;

        if (this.dispCalender.targetYear == dtyear &&
            this.dispCalender.targetMonth == dtMonth){
          return "this-month";
        }
        else{
          return "another-month";
        }
      }
    },
    borderStyleTop(){
      return function (index) {
        if (this.dispCalender.weekDatelist[index] == this.today) {
          return { "border-left": "solid 4px lightcoral",
                   "border-right": "solid 4px lightcoral",
                   "border-top": "solid 4px lightcoral",
                   "height": "-webkit-calc(100% - 5px)"};
        }
      }
    },
    borderStyleCenter(){
      return function (index) {
        if (this.dispCalender.weekDatelist[index] == this.today) {
          return { "border-left": "solid 4px lightcoral",
                   "border-right": "solid 4px lightcoral"};
        }
      }
    },
    borderStyleBottom(){
      return function (index) {
        if (this.dispCalender.weekDatelist[index] == this.today) {
          return { "border-left": "solid 4px lightcoral",
                   "border-right": "solid 4px lightcoral",
                   "border-bottom": "solid 4px lightcoral",
                   "height": "-webkit-calc(100% - 5px)"};
        }
      }
    }
  },
  methods: {
    // 共通ローダー設定
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage"
    ]),
    ...mapActions("pat-info", [ "selectPat" ]),
    ...mapMutations("pat-info", {
      setPat: "setSelectedPat",
      setIsLoadingPat: "setIsLoadingPat"
    }),
    ...mapActions("multi-modal", [ "showHomeDialysisInstrConfirmModal" ]),

    // 患者情報ヘッダーに表示する患者を設定する
    async setHeaderPatId(patId) {
      this.setIsLoadingPat(true);
      this.setPat(null);
      await this.selectPat(patId).catch(() => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatHomeDialysisComponent.vue', 'setHeaderPatId', '患者選択失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        throw new Error("[PatHomeDialysisStatusComponent.vue]setHeaderPatId(): 患者選択失敗");
      });
      this.setIsLoadingPat(false);
    },
    next() {
      this.$router.push({ name: "pat-home-dialysis-weight-before" });
    },
    next2() {
      this.$router.push({ name: "pat-home-dialysis-status" });
    },

    check(Item,Index) {
      if (this.dispCalender.weekDatelist[Index] === Item.strEventDate)
      {
        return true;
      }else{
        return false;
      }
    },
    clickEvent(item) {

      if(this.indChangeCategoryCd == item.categoryCd){
        // 指示変更イベント：透析指示書確認画面の表示
        this.showHomeDialysisInstrConfirmModal()
      }else{
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "開発中",
          // message: "その他のイベントです"
          title: DIALOG_MESSAGES[12000311].title,
          message: messageFormat(DIALOG_MESSAGES[12000311].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
      }
    },
    formedDateOfThisWeek(){
      let baseDay = this.targetDate;
      let this_year = baseDay.getFullYear();
      let this_month = baseDay.getMonth();
      let date = baseDay.getDate();
      let day_num = baseDay.getDay();
      let this_monday = date - day_num + 1;

      //週の日付リストの取得
      let weekDaylist = [];
      let weekDatelist = [];
      for (  let i = 0;  i < 7;  i++  ) {
        let dt = new Date(this_year, this_month, this_monday + i);
        let y = dt.getFullYear();
        let m = ("00" + (dt.getMonth()+1)).slice(-2);
        let d = ("00" + dt.getDate()).slice(-2);
        let result =  y + "/" + m + "/" + d;
        // 繰り返し処理
        weekDaylist.push(dt.getDate());
        weekDatelist.push(result);
      }
      this.dispCalender.weekDaylist = weekDaylist;
      this.dispCalender.weekDatelist = weekDatelist;

      //表示月ヘッダーの取得
      this.dispCalender.targetYear = this_year;
      this.dispCalender.targetMonth = this_month + 1 ;

      //前月ヘッダーの取得
      let preDate = String(baseDay);
      preDate = new Date(preDate);
      preDate = new Date(preDate.setMonth(preDate.getMonth() - 1));
      this.dispCalender.preMonth = preDate.getMonth() + 1;

      //次月ヘッダーの取得
      let nextDate = String(baseDay);
      nextDate = new Date(nextDate);
      nextDate = new Date(nextDate.setMonth(nextDate.getMonth() + 1));
      this.dispCalender.nextMonth = nextDate.getMonth() + 1;
    },
    async selectNextWeek(){
      this.targetDate = new Date(this.targetDate.setDate(this.targetDate.getDate() + 7));
      this.formedDateOfThisWeek();
      this.getEventData();
    },
    async selectPreWeek(){
      this.targetDate = new Date(this.targetDate.setDate(this.targetDate.getDate() - 7));
      this.formedDateOfThisWeek();
      this.getEventData();
    },

    async getEventData(){
      if(this.getStateUserAccountInfo.patId && this.dispCalender.weekDatelist[0] && this.dispCalender.weekDatelist[6]){
        // イベント一覧を取得
        const requestParam = {
          patId: this.getStateUserAccountInfo.patId,
          startEventdate: this.dispCalender.weekDatelist[0],
          endEventdate: this.dispCalender.weekDatelist[6]
        };
        const uri = "/pat_home_dialysis/getEventByPatIdNewest";
        const response = await ApiHelper.get(uri, requestParam).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatHomeDialysisComponent.vue', 'getEventData', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          throw new Error(
            `[OtherContactCardContent.vue]created(): 取得失敗
            エラー内容: ${error}`
          );
        });
        this.eventData = response.data;

        // 施設設定マスタから指示変更カテゴリIDを取得
        sendRequestGetMstFacilitySettingValue(this.facilityCd, CHANGE_IND_CATEGORY).then(responseFacilitySetting => {
          this.indChangeCategoryCd = responseFacilitySetting.data;
        });

      }
    },

    isChanged() {
      this.$nextTick(() => {
        this.disableElement(this.$el);
      });
    }
  },
  watch: {
    selectedPatId: function () {this.getEventData()}
  },
  async created() {
    // 共通ローダー:表示開始
    this.setLoadingScreenMessage("処理中・・・");
    this.setLoadingScreenVisible(true);
    let dt = new Date();
    let y = dt.getFullYear();
    let m = ("00" + (dt.getMonth()+1)).slice(-2);
    let d = ("00" + dt.getDate()).slice(-2);
    let time = dt.getHours();
    dt = y + "/" + m + "/" + d;
    this.today = dt;

    if (time >= 5 && time <=10 ){
      this.msg = "おはようございます。"
    }
    else if (time >= 11 && time <= 17) {
      this.msg = "こんにちは。"
    }
    else {
      this.msg = "こんばんは。"
    }

    this.formedDateOfThisWeek();
    this.getEventData();
    // 共通ローダー:表示終了
    this.setLoadingScreenVisible(false);
  },
  mounted() {
    // 患者情報ヘッダーの設定
    if (this.headerPatId === null && this.getStateUserAccountInfo.patId !== null) {
      this.setHeaderPatId(this.getStateUserAccountInfo.patId);
    }
  },

};
</script>

<style scoped>
table{
  border-collapse: collapse;
}

th {
  border: solid 1px lightgray;
}

td {
  border: solid 1px lightgray;
}
.main-content-area {
  min-width: 200px;
}
.tr-month-list{
  background-color:lightskyblue;
  font-size: 1em;
  color: white;
}
.tr-month-list th span{
  margin: 3%;
}
.tr-week-list th{
  height: 24px;
  width: 14%;
  font-size: 1em;
}
.th-week-days{
  background-color:black;
  color: white;
}
.th-week-satur{
  background-color:dodgerblue;
  color: white;
}
.th-week-sun{
  background-color:tomato;
  color: white;
}
.tr-event-list td{
  height: 150px;
}
.td-event {
  font-size: 1.8em;
  color: blue;
  display: block;
  padding: 5px;
  text-align: center;
  text-decoration:underline;
}
.this-month{
  background-color:#D3EDFB;
}
.another-month{
  background-color:#ffe6e9;
}
.info-from-hosp{
  margin-left:15px;
  width: 60%;
}
.tr-info-head th{
  background-color:lightskyblue;
  font-size: 2em;
  color: white;
  padding-left: 5px;
}
.tr-info-list {
  height: 180px;
  font-size: 2em;
  color: blue;
}
.tr-info-list > td {
  padding: 0;
  background-color:#ffe6e9;
}
.ul-info-list {
  min-height: 150px;
  overflow-y: auto;
  margin: 0;
  text-decoration:underline;
}
.start-btn{
  font-size: 2.5em;
  width: 30%;
  text-align: center;
}
.msg-lbl{
  font-size: 3em;
}
.header-content{
  min-height:50px;
}
.main-content{
  min-height:250px;
}
@media screen and (max-width: 480px) {
  .start-btn {
    font-size: 2em;
    width: 80%;
  }
  .msg-lbl{
    font-size: 2em;
  }
  .info-from-hosp{
    margin:0;
    width: 100%;
  }
  .tr-event-list td{
    height: 120px;
  }
  .tr-info-list {
    height: 150px;

  }
  .main-content{
    min-height:210px;
    font-size: 0.8em;
  }
  .header-content{
    min-height:30px;
  }
}
</style>
