/**
 * 休日マスタモーダル
 * MstHolidayMainModalComponent
 */
<template>
  <div>
    <div class="holiday-header">
      <!-- <ul class="h-text">
        <li><a @click="prevYear" :class="{ 'disabled': isEdited }"><i class="zmdi zmdi-chevron-left"></i></a></li>
        <li>{{getEditRecord.year}}年</li>
        <li><a @click="nextYear" :class="{ 'disabled': isEdited }"><i class="zmdi zmdi-chevron-right"></i></a></li>
      </ul> -->
      <v-ons-select
       v-model="getEditRecord.year"
       @change="nextYear()"
      >
        <template v-for="item in yearList">
          <option :key="item" :value="item">{{ item }}年</option>
        </template>
      </v-ons-select>
    </div>
    <div id="mst-holiday">
      <div class="holiday-content print-height-auto" :style="heightStyles" style="min-width: 60%;" v-if="reRender">
        <div slot='body' class='account-edit'>
          <vc-date-picker
            :columns="$screens({ default: 1, md: 2, lg: 2 ,xl: 3})"
            :rows="$screens({ default: 12, md: 6,  lg: 6, xl: 4 })"
            :is-expanded='true'
            :min-date="canSelectMinDate"
            :max-date="canSelectMaxDate"
            :select-attribute="selectAttribute"
            :attributes="attributes"
            class="ntss-theme-screen"
            color="orange"
            mode="multiple"
            v-model="selectedDateList"
            is-inline>
            <div slot='header-title' slot-scope='page' style="color:white">
              {{page.yearLabel}}年{{page.monthLabel}}
            </div>
          </vc-date-picker>
        </div>
      </div>
      <div class="selected-table print-height-auto" :style="heightStyles">
        <table>
          <thead>
            <th class="ntss-list-header-th-sticky" style="width: 25%">日</th>
            <th class="ntss-list-header-th-sticky" style="width: 45%">名称</th>
            <th class="ntss-list-header-th-sticky" style="width: 30%">区分</th>
          </thead>
          <tbody>
            <tr v-for="(item, key) in filterHolidayJson" v-bind:key="key">
              <td>{{item.date}}</td>
              <!-- 名称、区分 -->
              <!-- 日機装施設-祝日 権限有りの場合は編集可 -->
              <!-- 日機装施設-施設固有 常に編集可 -->
              <!-- 顧客施設-祝日、施設固有 常に編集可 -->
              <td>
                <input type="text" v-if="isNkk && item.class === '1'" v-model="item.name" />
                <input type="text" v-else-if="isNkk" v-model="item.name" :disabled="!(isUserHolidayAuthorityCds && isAdmin)" />
                <input type="text" v-else v-model="item.name" :disabled="item.nkk" />
              </td>
              <td>
                <v-ons-select v-if="item.nkk" class="holiday-class" v-model="item.holidayClass" :disabled="!(isUserHolidayAuthorityCds && isAdmin)">
                  <option value="0">祝日</option>
                  <option value="1">施設固有日</option>
                </v-ons-select>
                <v-ons-select v-if="!item.nkk" class="holiday-class" v-model="item.class">
                  <option value="0" v-if="(isNkk && isUserHolidayAuthorityCds && isAdmin) || !isNkk">祝日</option>
                  <option value="1">施設固有日</option>
                </v-ons-select>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { formatDatetime } from "@/functions/common/CommonFunctions";
import { mapActions, mapGetters } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {EventBus} from "@/eventBus";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  mixins: [MasterMaintenanceMixin],
  name: "mstHolidayMainModal",
  data() {
    return {
      selectedDateList: [],
      dsplayState: false,
      canSelectMinDate: null,
      canSelectMaxDate: null,
      contentsAreaHeight: 400,
      reRender: true,
      holidayJson: [],
      yearList:[],
      nkkHolidayJson: [],
      attributes: [],
      isEdited: false
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getFontSize"]),
    ...mapGetters("master-maintenance", ["getEditRecord", "getFilteredMasterRecordList",　"getMasterRecordList", "getFacilitySwitch"]),
    ...mapGetters("user",["getUserAuthorityCds"]), // ADD 休日マスタ編集権限の対応 劉
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    heightStyles() {
      return { height: `${this.contentsAreaHeight}px` };
    },
    selectAttribute() {
      let self = this;

      let nkkCompareList = self.nkkHolidayJson.map(e => {
        return e.date;
      });
      let compareList = self.holidayJson.filter(e => {
        return !e.nkk;
      }).map(e => {
        return e.date;
      });

      // レコードを追加する
      let selectedArr = [];
      self.selectedDateList.forEach(date => {
        const dateStr = self.formatDate(date);
        if(date.getHours() == 0) {
          let newItem = {
            date: dateStr,
            name: "",
            class: ""
          };
          if(nkkCompareList.includes(dateStr)) {
            if(self.countItem(self.holidayJson, dateStr) == 1){
              self.holidayJson.push(newItem);
            }
          } else {
            if(!compareList.includes(dateStr)) {
              self.holidayJson.push({
            date: dateStr,
            name: "",
            class: this.isNkk ? "" : "1"
          });
            }
          }
        }
        selectedArr.push(dateStr);
      });
      // レコードを削除する
      self.holidayJson.forEach((item, index) => {
        if (!selectedArr.includes(item.date) && !item.nkk) {
          self.holidayJson.splice(index, 1);
        }
      })

      // ソート順
      self.holidayJson.sort(self.sortByProperty('date'));

      return {};
    },
    // -----------------------------------------
    // 日機装ユーザーか否か
    // 日機装ユーザーの場合、trueを返します。
    // -----------------------------------------
    isNkk() {
      return this.getStateUserAccountInfo.facilityCd == "nkknkk" && this.getFacilitySwitch === "nkknkk" ? true : false;
    },
    // add 休日マスタ編集権限の対応 劉 start
    isUserHolidayAuthorityCds(){
      // 顧客施設の場合、祝日権限は設定不可なので常にOFF
      return (this.getUserAuthorityCds.filter(rows => rows === "123")).length > 0 && this.isNkk
    },
    isAdmin() {
      return this.getStateUserAccountInfo.administrator === 1 ? true : false;
    },
    // add 休日マスタ編集権限の対応 劉 end
    filterHolidayJson() {
      return this.holidayJson.filter(rec => {
        return rec.date.substring(0,4) == this.getEditRecord.year;
      })
    }
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    filterHolidayJson: {
      handler(newValue, oldValue) {
        this.modRegisteredFlag(false);
      },
      deep: true
    }
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    ...mapActions("user",["fetchUserAuthorityCds"]), // ADD 休日マスタ編集権限の対応 劉
    updateEditRecord(key, value) {
      this.getEditRecord[key] = value;
      this.setEditRecord(this.getEditRecord);
    },
    isMobile() {
      let isMobile = window.matchMedia("only screen and (max-width: 760px)").matches;
      return isMobile;
    },
    countItem(arr, item){
      let count = 0;
      arr.forEach(e => {
        if(e.date == item) {
          count ++;
        }
      });
      return count;
    },
    /**
     * ソートする
     *
     * @param property
     * @returns {Function}
     */
    sortByProperty(property) {
      return function (x, y) {
          return ((x[property] === y[property]) ? 0 : ((x[property] > y[property]) ? 1 : -1));
      };
    },
    calculateGridHeight() {
      const modal = document.getElementsByClassName("modal-container")[0];
      const modalHeight = modal.clientHeight;
      const modalHeaderHeight = modal.firstElementChild.firstElementChild.clientHeight; // modal-headerはheightが0のため、その下のelementのheightを取得
      const modalFooterHeight = modal.lastElementChild.clientHeight;
      const holidayHeader = document.getElementsByClassName("holiday-header")[0].clientHeight;
      this.contentsAreaHeight = modalHeight - modalHeaderHeight - modalFooterHeight - holidayHeader - 10; // -10は余白の微調整
    },
    validateOnRegistration() {
      // add 休日マスタ編集権限の対応 劉 start
      if (this.isNkk && !(this.isUserHolidayAuthorityCds && this.isAdmin)){
        this.holidayJson = JSON.parse(JSON.stringify(this.holidayJson.map(rec => {
          delete rec.nkk;
          return rec;
        })).replace(/holidayClass/g,"class"));
      }
      // add 休日マスタ編集権限の対応 劉 end
      const list = this.holidayJson.filter(
        item => item.nkk != true
          && +item.date.substring(0,4) == this.getEditRecord.year
      );
      this.getEditRecord.holiday = JSON.stringify(list);

      let existFlg = false;
      const mstData = this.getMasterRecordList.data;
      if(mstData) {
        mstData.forEach(element => {
          if(element.code !== this.getEditRecord.code &&
              this.getEditRecord.regDate == "" &&
              element.year == this.getEditRecord.year && element.isDisp == "1" && element.class=="0"
            ) {
            existFlg = true;
          }
        });
      }
      if(existFlg) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "選択情報（年）が重複しています。",
          title: DIALOG_MESSAGES['00200060'].title,
          message: messageFormat(DIALOG_MESSAGES['00200060'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        this.updateEditRecord("holiday", "");
        return false;
      }

      this.setEditRecord(this.getEditRecord);
      return true;
    },
    convertSelectedDateList(dateList){
      const dtList = [];
      dateList.forEach(dt => {
        const y = dt.getFullYear();
        const m = ("00" + (dt.getMonth()+1)).slice(-2);
        const d = ("00" + dt.getDate()).slice(-2);
        dtList.push(y + "-" + m + "-" + d);
      });
      return dtList;
    },
    formatToSelectedDate() {
      let currList = this.holidayJson.filter(rec => {
        return !rec.nkk;
      });
      if(this.getEditRecord.holiday) {
        currList = JSON.parse(this.getEditRecord.holiday);
      }
      if (this.isNkk) {
        let holidays = []
        let nkkHolidays = this.nkkHolidayJson.map(e=>e.date);
        currList.forEach(e => {
          if (!nkkHolidays.includes(e.date))
          holidays.push(e);
        })
        currList = holidays;
      }
      this.holidayJson = currList.concat(this.nkkHolidayJson);
      if(this.holidayJson.length > 0) {
        let curUserList = currList.map(l => {
          return new Date(l.date.substring(0, 4), +l.date.substring(5, 7) - 1, l.date.substring(8, 10), 0 , 0, 0, 0);
        });
        let nkkList = this.nkkHolidayJson.map(l => {
          return new Date(l.date.substring(0, 4), +l.date.substring(5, 7) - 1, l.date.substring(8, 10), 12 , 0, 0, 0);
        });
        this.attributes.push({
          highlight: 'red',
          dates: nkkList,
        });
        return curUserList;
      }
      return [];
    },
    async prevYear() {
      this.setLoadingScreenVisible(true);
      const currentYear = this.getEditRecord.year;
      const prevYear = String(parseInt(currentYear) - 1);
      this.getEditRecord.year = prevYear;
      await ApiHelper.get("/mstInfo/mstHoliday/nkk", {
        holidayY : prevYear
      }).then(response => {
        if(response.status == 200) {
          // mod 休日マスタ編集権限の対応 劉 start
          // this.nkkHolidayJson = response.data;
          this.nkkHolidayJson = response.data.filter(date =>  date.holidayClass === "0");
          // mod 休日マスタ編集権限の対応 劉 end
        }
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstHolidayMainModalComponent.vue', 'prevYear', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        this.setLoadingScreenVisible(false);
      });
      this.selectedDateList = this.formatToSelectedDate();
      this.setPickerDate(prevYear);
      this.reRender = false;
      this.setLoadingScreenVisible(false);
      this.$nextTick(() => {
        this.reRender = true;
        this.$nextTick(() => {
          this.mountedFunc();
        });
      });
    },
    async nextYear() {
      this.setLoadingScreenVisible(true);
      const currentYear = this.getEditRecord.year;
      const nextYear = String(parseInt(currentYear));
      this.getEditRecord.year = nextYear;
      await ApiHelper.get("/mstInfo/mstHoliday/nkk", {
        holidayY : nextYear
      }).then(response => {
        if(response.status == 200) {
          // mod 休日マスタ編集権限の対応 劉 start
          // this.nkkHolidayJson = response.data;
          this.nkkHolidayJson = response.data.filter(date =>  date.holidayClass === "0");
          // mod 休日マスタ編集権限の対応 劉 end
        }
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstHolidayMainModalComponent.vue', 'nextYear', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        this.setLoadingScreenVisible(false);
      });
      this.selectedDateList = this.formatToSelectedDate();
      this.setPickerDate(nextYear);
      this.reRender = false;
      this.setLoadingScreenVisible(false);
      this.$nextTick(() => {
        this.reRender = true;
        this.$nextTick(() => {
          this.mountedFunc();
        });
      });
    },
    setPickerDate(year) {
      const minDate = new Date(year, 0, 1);
      const maxDate = new Date(minDate.getFullYear(), 11, 31);
      this.canSelectMinDate = minDate;
      this.canSelectMaxDate = maxDate;
      this.reRender = false;

      this.$nextTick(() => {
        this.reRender = true;
        this.$nextTick(() => {
          this.mountedFunc();
        });
      });
    },
    mountedFunc() {
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
    },
    /**
     * @description フォーマット変更
     */
    formatDate(value) {
      if (value === null || value === "") {
        return null;
      }
      return formatDatetime(value, "YYYY-MM-DD");
    },
    modRegisteredFlag(flag) {
      EventBus.$emit("mstHolidayRegistered", flag);
    }
  },
  async created() {
    this.setLoadingScreenVisible(true);
    let self = this;
    if(self.getEditRecord.regDate != ""){
      self.isEdited = true;
    }
    let oldYearList = [];
    const mstData = this.getMasterRecordList.data;
      if(mstData) {
        mstData.forEach(element => {
          if(element.year != this.getEditRecord.year && element.isDisp == "1" && element.class=="0" && element.year !=""
            ) {
            oldYearList.push(parseInt(element.year))
          }
        });
      }
    if (!self.getEditRecord.year) {
      self.getEditRecord.year = String(new Date().getFullYear());
    }
    self.fetchUserAuthorityCds; // add 休日マスタ編集権限の対応 劉
    if(!(self.isUserHolidayAuthorityCds && this.isAdmin)){
      await ApiHelper.get("/mstInfo/mstHoliday/nkk", {
        holidayY : self.getEditRecord.year
      }).then(response => {
        if(response.status == 200) {
          // mod 休日マスタ編集権限の対応 劉 start
          // this.nkkHolidayJson = response.data;
          this.nkkHolidayJson = response.data.filter(date =>  date.holidayClass === "0");
          // mod 休日マスタ編集権限の対応 劉 end
        }
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstHolidayMainModalComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        this.setLoadingScreenVisible(false);
      });
    }
    let newYearList = Object.keys(Array.apply(null, {length:201})).map(function(item){
      return (1899+parseInt(item)+1);
    })
    this.yearList = newYearList.filter(e => !oldYearList.includes(e));
    while(this.yearList.filter(e=> e == parseInt(this.getEditRecord.year)).length == 0) {
      this.getEditRecord.year = parseInt(this.getEditRecord.year) +1;
    }
    self.dsplayState = true;
    self.selectedDateList = self.formatToSelectedDate();
    self.setPickerDate(self.getEditRecord.year);
  },
  mounted() {
    this.mountedFunc();
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    setTimeout(() => {
      this.modRegisteredFlag(true);
      this.setLoadingScreenVisible(false);
    }, 800)

  }
};
</script>

<style scoped>
@media print{
  .print-height-auto, .holiday-content{
    height: auto !important;
  }
}
#mst-holiday {
  display: flex;
}
.holiday-content {
  flex: 1;
  overflow: auto;
}
.selected-table {
  overflow: auto;
  min-width: calc(30% - 20px);
}
.selected-table th {
  text-align: left;
}
.selected-table table {
  position: relative;
  width: auto;
  min-width: 100%;
}
.selected-table table tbody tr {
  line-height: 30px;
}
.selected-table table td {
  padding: 2px;
}
.selected-table input[type="text"] {
  width: calc(100% - 10px);
  margin: 2px 2px;
  line-height: 18px;
  padding-left: 4px;
}
ons-select >>> .select-input {
  margin: 2px 2px;
  line-height: 20px;
  padding-left: 4px;
}
/* .selected-table .holiday-class {
  height: 24px;
} */
.selected-table select {
  width: 100%;
}
ul.h-text li {
  display: inline;
  font-weight: 600;
  padding: 0 22px;
}
.holiday-header {
  text-align: center;
}

a {
  color: black;
}

a.disabled {
  pointer-events: none;
  cursor: default;
  color: gray;
  opacity: 0.5;
}

th.ntss-list-header-th-sticky {
  z-index: 1;
}

@media screen and (min-width:650px) and (max-width: 850px) {
  .input-item-converted{
    max-width: 15%;
    min-width: 15%;
  }
  .input-item-converted-label{
    max-width: 20%;
    min-width: 20%;
  }
}

@media screen and (max-width: 650px) {
  .input-item-name {
    text-align: left;
    font-weight: bold;
    margin-bottom: 5px;
    min-width: 95%;
  }
  .input-item-txt {
    min-width: 90%;
  }
  .input-item-txt-long {
    text-align: left;
    min-width: 90%;
  }
  .input-item-txt-short {
    min-width: 90%;
  }
  .input-item-button {
    text-align: left;
    min-width: 90%;
  }
  .input-item-radio {
    min-width: 6.5em;
  }
  .input-item-check {
    min-width: 90%;
  }
  .input-item-date{
    text-align: left;
  }
  .input-item-symbol{
    min-width: 90%;
    text-align: left;
  }
  .input-item-converted{
    text-align: left;
    min-width: 30%;
    max-width: 30%;
  }
  .input-item-converted-label{
    text-align: left;
    min-width: 35%;
    max-width: 35%;
  }
  .input-item-converted-equal{
    text-align: center;
    min-width: 10%;
    max-width: 10%;
  }
  .input-newline{
    min-width:90%;
    max-width:90%;
  }
}
</style>
