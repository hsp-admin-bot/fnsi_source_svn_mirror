<template>
  <modal-base @onClose="closeHistory" class="custom-modal">
    <div slot="header">
      <component :is="header"></component>
            </div>
    <div slot="body" style="font-size: 1.5em">
      <v-ons-row class="title-padding" >
        <div class="scroll-area-modal" id="scrollCondModal">
          <div class="sub_title">
            <table class="ntss-list-detail">
              <tr>
                <th class="list-header-th-center list-header-th-bed-name">ベッド</th>
                <th class="list-header-th-center list-header-th-machine-type">型式</th>
                <th class="list-header-th-center list-header-th-machine-serial">製造番号</th>
                <th class="list-header-th-center list-header-th-machine-name">装置名</th>
              </tr>
              <tr>
                <td class="ntss-list-body-td no-wrap"> {{ editData.machineInfor.bedName }}</td>
                <td class="ntss-list-body-td no-wrap">{{ editData.machineInfor.machineType }}</td>
                <td class="ntss-list-body-td no-wrap">{{ editData.machineInfor.machineSerial }}</td>
                <td class="ntss-list-body-td no-wrap clearfix">
                  <div id="div-stop-watch">{{ editData.machineInfor.machineName }}</div>
                  <img v-if="this.getTheme === 0" src="img/periodic-inspection/stop-watch.png" id="stop-watch-icon" @click="ShowSomeThing(editData.machineInfor.machineTypeCd, editData.machineInfor.machineSerial)" />
                  <img v-else-if="this.getTheme === 1" src="img/periodic-inspection/stop-watch-dark.png" id="stop-watch-icon" @click="ShowSomeThing(editData.machineInfor.machineTypeCd, editData.machineInfor.machineSerial)" />
                </td>
              </tr>
            </table>
          </div>
          <div class="custom-ons-col-flex-end">
            <div class="custom-line-height no-wrap clearfix">
              <!-- mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start -->
              <!--#11059:定期点検履歴画面の日付IF修正Start-->
              <!-- <date-input
                  id="input-search-date"
                  class="hide-arrow-calendar start-date"
                  type="date"
                  isRequired
                  :default-date="defaultDate"
                  v-model="searchDate" />
              <common-calendar
                  v-model="searchDate"
                  :disabled="false"
              /> -->
              <!--#11059:定期点検履歴画面の日付IF修正End-->
              <date-input
                id="input-search-date"
                class="hide-arrow-calendar start-date"
                type="date"
                isRequired
                :default-date="defaultDate"
                v-model="condition.date" />
              <common-calendar
                v-model="condition.date"
                :disabled="false"
              />
              <!-- mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end -->
              <label> から</label>
            </div>
            <div class="custom-line-height no-wrap clearfix">
              <label>過去 </label>
              <!--#11059:定期点検履歴画面の日付IF修正Start-->
              <input class="distance-time" type="number" @change="inputNumber($event)"
                @mousewheel.prevent="stopScrollFun($event)" @blur="formatValue($event)" @focus="handleFocus"
                :min="1"
                :max="99"
                v-model="condition.numOfYear"
                />
              <!--#11059:定期点検履歴画面の日付IF修正End-->
              <label> 年</label>
            </div>
            <div class="custom-line-height no-wrap clearfix">
              <button class="btn3-normal button custom-search-btn" :disabled="showErrorStartDate"
                @click="search()">再表示</button>
            </div>
          </div>
        </div>
      </v-ons-row>
      <v-ons-row class="befor-start" >
        <div class="scroll-area-modal" id="scrollAreaModal">
          <table class="ntss-list-table" id="scrollTableModal" style="table-layout: auto; min-width: max-content;">
            <thead>
              <tr>
                <th class="list-header-th-left list-header-th-1 word-break-th ntss-list-header-th-sticky manual-width"
                >点検実施日</th>
                <th class="list-header-th-left list-header-th-2 word-break-th ntss-list-header-th-sticky manual-width"
                >記録番号</th>
                <th class="list-header-th-left list-header-th-3 word-break-th ntss-list-header-th-sticky manual-width"
                >点検名</th>
                <th class="list-header-th-left list-header-th-4 word-break-th ntss-list-header-th-sticky manual-width"
                >総合判定</th>
                <th class="list-header-th-left list-header-th-5 word-break-th ntss-list-header-th-sticky manual-width"
                >点検者コメント</th>
                <th class="list-header-th-left list-header-th-6 word-break-th ntss-list-header-th-sticky manual-width"
                >点検者</th>
                <th class="list-header-th-left list-header-th-7 word-break-th ntss-list-header-th-sticky manual-width"
                >確認者</th>
                <th class="list-header-th-left list-header-th-8 word-break-th ntss-list-header-th-sticky manual-width"
                >点検記録最終更新日時</th>
              </tr>
            </thead>
            <tbody class="ntss-list-body-tr-black">
              <tr v-for="(item, idx) in lisData" :key="idx" style="height: 2em;"
                @click="openPeriodicHistoryDetail(item)">
                <td class="ntss-list-body-td" :class="getStyle(item.menteDate)">{{ formattedMenteDate(item.menteDate) }}</td>
                <td class="ntss-list-body-td">{{ item.recNo }}</td>
                <td class="ntss-list-body-td">{{ item.layoutGroupName }}</td>
                <td class="ntss-list-body-td"
                  :class="{ 'inspected-radian-red': '3' == item.menteAns1 }">
                  {{ convertStatus(item.menteAns1) }}
                </td>
                <td class="ntss-list-body-td">{{item.menteComment1}}</td>
                <td class="ntss-list-body-td">{{ item.checker1 }}</td>
                <td class="ntss-list-body-td">{{ item.checker2 }}</td>
                <td class="ntss-list-body-td">{{ 
                  (item.checker2 === "" && item.menteAns1 === "")
                    ? ""
                    : formattedUpDate(item.upDate)
                }}</td>
              </tr>

            </tbody>
          </table>
        </div>
      </v-ons-row>
    </div>
    <div slot="footer" class="flex-container justify-content-flex-end">
      <div class="denial-btn-area custom-close-btn" style="background:none">
        <v-ons-button class="btn2-cancel button denial-btn" @click="closeHistory">閉じる</v-ons-button>
    </div>
  </div>
  </modal-base>
</template>

<script>
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import {mapGetters, mapActions, mapMutations} from "vuex";
import { EventBus } from "@/eventBus.js";
import moment from "moment";
import {
  sendRequestGetHistory
} from "@/apis/periodic-inspection";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import store from "@/stores";
import { messageFormat } from '@/functions/common/MessageFormat';
import ModalBase from "@/components/modals/ModalBase";
//#11059:定期点検履歴画面の日付IF修正Start
import DateInput from "@/components/common/DateInput.vue";
import CommonCalender from "@/components/common/custom-calendar/CustomCalendar";
//#11059:定期点検履歴画面の日付IF修正End
import { getHolidayStyle } from "@/functions/common/CommonFunctions";

export default {
  name: "PeriodicHistoryModel",
  mixins: [MasterMaintenanceMixin],
  components: {
    "modal-base": ModalBase,
    //#11059:定期点検履歴画面の日付IF修正Start
    DateInput,
    "common-calendar": CommonCalender,
    //#11059:定期点検履歴画面の日付IF修正End
  },
  data() {
    return {
      header: "点検履歴",
      lisData: [],
      condition: {
        date: moment(new Date()).format("YYYY-MM-DD"),
        menteClass: 2,
        machineNo: 0,
        numOfYear: 5,
        bedName: "",
        machineType: "",
        machineSerial: "",
        machineName: "",      
      },
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorStartDate: false,
      searchDate:moment(new Date()).format("YYYY-MM-DD"),
      min:0,
      max:99,
      blurFlg:false,
      focusFlg:false,
      targetID: null,
      intervalIDList: [],
      isClicked: false,
      isOvered: false,
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth",
    }),
    ...mapGetters("account-edit", { getFontSize: "getFontSize" }),
    ...mapGetters("account-edit", ["getTheme","getStateUserAccountInfo"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("periodic-inspection", { editData: "getDetailData" }),
    ...mapGetters("periodic-inspection", [
      "getAllUser",
      "getDetailData",
      "getParamsGetDetail",
      "getHistoryParams",
      "getLayoutGroupList"
    ]),
    //#11059:定期点検履歴画面の日付IF修正Start
    defaultDate() {
      return this.condition.date;
    },
    //#11059:定期点検履歴画面の日付IF修正End
  },
  methods: {
    ...mapActions("periodic-inspection", [
      "sendRequestGetDetail",
      "setHistoryParams",
      "sendRequestGetAllLayoutGroup"
    ]),
    ...mapMutations("periodic-inspection", [
      "setParamsGetDetail",
      "setMachine",
      "setBeforeModel",
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      "setIsOpenByHistoryView",
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
    ]),
    ...mapActions("multi-modal", [
      "showMachineModal"
    ]),
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible"
    ]),
    inputNumber(e){
        // 数値範囲内かどうかの確認
        if (this.min !== undefined && this.max !== undefined) {
          if (e.target.value > this.max) {
            this.condition.numOfYear = this.min;
            this.blurFlg=true;
          } else if (e.target.value < this.min) {
            this.condition.numOfYear = this.max;
            this.blurFlg=true;
          }else{
            this.blurFlg=false;
          }
        }
    },
    stopScrollFun(e){
      if (!this.focusFlg) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = 0
      }
      let value = parseFloat(e.target.value);
      const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      // 数値範囲内かどうかの確認
      if (value > this.max) {
        value = this.min;
      }
      if(value < this.min) {
        value = this.max;
      }
      this.condition.numOfYear=value;
    },
    formatValue(event){
            // 限界値判定
      let value = event.target.value;
      if (value == this.max && this.blurFlg) {
        this.condition.numOfYear = this.min;
        this.blurFlg = false;
      }else if (value == this.min && this.blurFlg) {
        this.condition.numOfYear = this.max;
        this.blurFlg = false;
      }
      this.focusFlg=false;
    },
    handleFocus(){
      this.focusFlg=true;
    },
    convertStatus(status) {
      const statusText = [
        { key: "", value: "" },
        { key: "1", value: "合格" },
        { key: "3", value: "不合格" },
        { key: "2", value: "作業中" }
      ];
      return statusText.find(x => x.key === status).value;
    },
    showStartMsg(){
      this.showErrorStartDate = document.getElementsByClassName("start-date")[0].validationMessage !== "";
    },
    getStartDate(){
      this.showErrorStartDate = document.getElementsByClassName("start-date")[0].validationMessage !== "";
    },
    closeHistory() {
      EventBus.$emit("closeHistory");
    },
    async search() {
      let validate = true;

      // del #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      //this.condition.date=this.searchDate;
      // del #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      if (!this.condition.date) {
        validate = false;
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES['00200005'].title,
          message: messageFormat(DIALOG_MESSAGES['00200005'].message)
        })
      }
      if (this.condition.numOfYear < 1) {
        validate = false;
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES["03300013"].title,
          message: DIALOG_MESSAGES["03300013"].message
        })
        return;
      }
      if (this.condition.numOfYear > 15) {
        this.condition.numOfYear = 15
      }
      if (validate) {
        // del #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
        //this.setHistoryParams(this.condition);
        // del #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
        await this.searchAll();
      }
    },
    async searchAll() {
      this.lisData = [];
      let responseData = [];
      this.condition.machineNo = this.getDetailData.machineInfor.machineNo;

      this.condition.machineType = this.getDetailData.machineInfor.machineType;
      this.condition.machineName = this.getDetailData.machineInfor.machineName;
      this.condition.machineSerial = this.getDetailData.machineInfor.machineSerial;
      this.condition.bedName = this.getDetailData.machineInfor.bedName;

      // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      // if(null!=this.getHistoryParams && null!=this.getHistoryParams.numOfYear && this.getHistoryParams.numOfYear>0){
      //   this.condition.numOfYear=this.getHistoryParams.numOfYear;
      // }
      if(null!=this.getHistoryParams && null!=this.getHistoryParams.searchNumOfYear && this.getHistoryParams.searchNumOfYear>0){
        this.condition.numOfYear=this.getHistoryParams.searchNumOfYear;
      }
      // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      if(null!=this.getHistoryParams && null!=this.getHistoryParams.searchDate){
        // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
        //this.searchDate=this.getHistoryParams.searchDate;
        this.condition.date = this.getHistoryParams.searchDate;
        // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      }
      // del #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      // this.condition.date=this.searchDate;
      // del #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      await sendRequestGetHistory(this.condition).then(res => {
        responseData = res.data;
      });
      await this.sendRequestGetAllLayoutGroup();
      responseData.forEach(item => {
        const checker1 = this.getAllUser.find(
          x => x.user_id === item.checkerId1
        );
        const checker2 = this.getAllUser.find(
          x => x.user_id === item.checkerId2
        );
        const layoutGroupName = this.getLayoutGroupList.find(
          x =>x.menteLayoutGroupCd === item.menteLayoutGroupCd
        ).groupName;
        this.lisData.push({
          recNo: item.recNo,
          menteComment1 : item.menteComment1,
          devMenteNo: item.devMenteNo,
          checker1: checker1 ? checker1.checkerFullName : "",
          checker2: checker2 ? checker2.checkerFullName : "",
          menteAns1: item.menteAns1 != null ? item.menteAns1 : "",
          menteAns2: item.menteAns2 != null ? item.menteAns2 : "",
          menteDate: moment(item.menteDate).format("YYYY/MM/DD"),
          upDate: moment(item.upDate).format("YYYY/MM/DD HH:mm"),
          facilityCd: item.facilityCd,
          menteLayoutGroupCd: item.menteLayoutGroupCd,
          machineTypeCd: item.machineTypeCd,
          machineNo: item.machineNo,
          menteLayoutCd: item.menteLayoutCd,
          layoutGroupName: layoutGroupName
        });
        // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
        let devMenteNoArr = [];
        if(null != this.lisData && this.lisData.length>0){
          devMenteNoArr = this.lisData.map((x) => x.devMenteNo);
        }
        this.setHistoryParams({
          machineNo: this.condition.machineNo,
          date: this.condition.date,
          numOfYear: this.condition.numOfYear,
          devMenteNoArr: devMenteNoArr,
        });
        // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      });
    },
    async openPeriodicHistoryDetail(item) {
      if(null != this.lisData && this.lisData.length>0){
        let devMenteNoArr= [];
        let letmenteLayoutGroupNo=[];
        for(var i=0;i<this.lisData.length;i++){
          if( this.lisData[i].menteDate == item.menteDate){
            devMenteNoArr.push(this.lisData[i].devMenteNo);
            letmenteLayoutGroupNo.push(this.lisData[i].menteLayoutGroupCd);
          }
        }
        const paramsGetDetail = {
          facilityCd: item.facilityCd,
          menteLayoutGroupCd: item.menteLayoutGroupCd,
          machineTypeCd: item.machineTypeCd,
          machineNo: item.machineNo,
          devMenteNo: item.devMenteNo,
          menteLayoutCd: item.menteLayoutCd,
          menteDate: item.menteDate,
          letmenteLayoutGroupName:item.letmenteLayoutGroupName,
          letmenteLayoutGroupNo:letmenteLayoutGroupNo,
          devMenteNoArr:devMenteNoArr
        };
        this.setParamsGetDetail(paramsGetDetail);
      }
      EventBus.$emit("reload");
      EventBus.$emit("closesMachineModal", {name: 'PeriodicInspectionModal'});
    },
    hideArrowDate() {
      const getInputDateID = document.getElementById("input-search-date");
      getInputDateID.addEventListener('keydown', (event) => {
        if (event.key == "ArrowDown") {
          event.preventDefault();
        }
      }, false);
    },
    // 表示エリアサイズの設定
    setDisplayAreaSize() {
      // スクロールエリアサイズの設定
      this.setScrollAreaSize();
    },
    // スクロールエリアサイズの設定
    setScrollAreaSize() {
      // -----height-----
      // ヘッダー高の取得
      const headerHeight = document.getElementsByClassName("modal-header")[0].offsetHeight;
      // フッター高の取得
      const footerHeight = document.getElementsByClassName("modal-footer")[0].clientHeight;
      // 条件高の取得
      const scrollCondModalHeight = document.getElementById("scrollCondModal").clientHeight;

      // スクロールエリア高の計算
      const scrollAreaHeight = document.getElementById("scrollbody").clientHeight - headerHeight - footerHeight - scrollCondModalHeight - 10; 
      // スクロールテーブル高の取得
      const scrollTableHeight = document.getElementById("scrollTableModal").clientHeight;
      // スクロールエリア高 > スクロールテーブル高
      if (scrollAreaHeight > scrollTableHeight) {
        // スクロールエリア高 + 調整高
        const val = scrollTableHeight + 18;
        // スクロールエリア高の設定
        document.getElementById("scrollAreaModal").style.height = val + "px";
      } else {
        // スクロールエリア高 - 調整高
        const val = scrollAreaHeight + (20 - 8);
        // スクロールエリア高の設定
        document.getElementById("scrollAreaModal").style.height = val + "px";
      }
    },
    ShowSomeThing(machineTypeCd, machineSerial) {
      const params = {
        facilityCd: this.getFacilityCd,
        machineTypeCd: machineTypeCd,
        machineSerial: machineSerial,
      };
      this.setMachine(params);
      this.setBeforeModel({
        name: "PeriodicHistoryModel",
        data: {
          searchDate: this.searchDate,
          // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
          //numOfYear: this.condition.numOfYear
          searchNumOfYear: this.condition.numOfYear,
          // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
        }
      });
      let arg = [];
      this.showSubModals(this.showMachineModal, arg);
    },
    showSubModals(callModalFunction, arg) {
      callModalFunction(arg);
    },
    formattedUpDate(dateStr){
      const date = moment(dateStr);
      return date.format("YYYY/MM/DD(dd) HH:mm");
    },
    formattedMenteDate(dateStr){
      const date = moment(dateStr);
      return date.format("YYYY/MM/DD(dd)");
    },
     /**
     * 休日のスタイル取得
     */
    getStyle(date) {
      return getHolidayStyle(date, true);
    },
  },
  async created() {
    this.setLoadingScreenVisible(true);
    const paramsGetDetail = await this.getParamsGetDetail;
    await this.sendRequestGetDetail(paramsGetDetail);
    await this.searchAll();
    // 画面の表示
    setTimeout(() => {
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
    }, 500);
    this.setLoadingScreenVisible(false);
  },
  // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
  beforeDestroy() {
    store.dispatch("report/getMstReport", { funcCd: "03301", printFlag: 0 });
    this.setIsOpenByHistoryView(false);
  },
  // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
  watch : {
    //#11059:定期点検履歴画面の日付IF修正StartEnd(共通部品で補填する為、watchエラー判定削除)
    // WindowHeightの監視
    windowHeight() {
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
    },
    // windowWidthの監視
    windowWidth() {
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
    },
    // FontSizeの監視
    getFontSize() {
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
    },
  }
};
</script>

<style src="@/components/deviceset-info/base-modules/BeseDeviceSetInfoStyle.css" scoped></style>

<style scoped>
.ntss-list-table {
  background-color: var(--ntss-list-background-color);
  border-collapse: collapse;
  margin: 0;
  position: relative;
  top: 0px;
  width: -webkit-fill-available;
}

.ntss-list-table tr:nth-child(2n) {
  background-color: var(--ntss-list-content-2nd-background-color);
}

.ntss-list-table tr {
  background-color: var(--ntss-list-item-background-color);
  border-color: 1px solid var(--master-maintenance-kgrid-border-color);
}

.history-header-modal-left {
  float: left;
  margin: 2px 17px;
  width: 61%;
}

.history-header-modal {
  float: right;
  margin: 2px 17px;
  width: 33%;
}

.table-top-select-item {
  position: relative;
  border: 1px solid var(--ntss-list-border-color);
  overflow: auto;
  margin: 10px 100px 0px 100px;
}

.distance-time {
  width: 45px;
}

.icon-left {
  cursor: pointer;
  float: left;
}

.icon-right {
  cursor: pointer;
  float: right;
}

.text-header-center {
  color: #ffffff;
  border-top: 1px solid #cccccc;
  text-align: center;
}
.custom-search-btn {
  float: right;
}

.custom-ons-col {
  height: auto;
}

.custom-ons-col-flex-end {
  display: flex;
  justify-content: flex-end;
}
.custom-ons-col-flex-end > div {
  margin-left: 5px; 
;}
.custom-line-height {
  line-height: 2em;
}


.custom-h3 {
  color: #ffffff;
  padding-left: 0.5em;
}

.custom-col-55 {
  flex: 0 0 55%;
  max-width: 55%;
}

.custom-col-25 {
  flex: 0 0 25%;
  max-width: 25%;
}

.custom-col-20 {
  flex: 0 0 20%;
  max-width: 20%;
}

.custom-modal-mask {
  background: rgba(0, 0, 0, 0.8);
}

.hide-arrow-calendar {
  width: 60%;
}

.hide-arrow-calendar::-webkit-inner-spin-button,
.hide-arrow-calendar::-webkit-calendar-picker-indicator {
  display: none;
  -webkit-appearance: none;
}

.ntss-list-body-tr-black {
  background-color: var(--ntss-base-background-color);
}

.periodic-history-modal {
  z-index: 10000;
}

.periodic-history-modal >>> .modal-container {
  margin: 0;
  width: 100%;
  height: 100%;
}


.ntss-list-detail {
  border-collapse: collapse;
  margin: 0 auto;
  width: -webkit-fill-available;
  top: 0px;
  background-color: var(--ntss-list-background-color);
}

.list-header-th-center {
  text-align: center;
  background-color: var(--ntss-list-header-background-color);
  height: 27px;
  color: #fff;
  border: solid 1px #cccccc;
  font-weight: normal;
}

.list-header-th-left {
  text-align: left;
  padding-left: 8px;
  background-color: var(--ntss-list-header-background-color);
  height: 27px;
  color: #fff;
  border: solid 1px #cccccc;
  font-weight: normal;
}

.list-header-nogradient {
  background-image: none;
}

.list-header-th-bed-name {
  min-width: 10em;
  max-width: 10em;
  width: 10em;
}

.list-header-th-machine-type {
  min-width: 10em;
  max-width: 10em;
  width: 10em;
}

.list-header-th-machine-serial {
  min-width: 10em;
  max-width: 10em;
  width: 10em;
}

.list-header-th-machine-name {
  min-width: 10em;
  max-width: 10em;
  width: 10em;
}

.list-header-th-1 {
  min-width: 5em;
  width: 5em;
}

.list-header-th-2 {
  min-width: 4em;
  width: 4em;
}

.list-header-th-3 {
  min-width: 9em;
}

.list-header-th-4 {
  min-width: 4em;
  width: 4em;
}

.list-header-th-5 {
  min-width: 9em;
}

.list-header-th-6 {
  min-width: 8em;
  width: 8em;
}

.list-header-th-7 {
  min-width: 8em;
  width: 8em;
}

.list-header-th-8 {
  min-width: 10em;
  width: 10em;
}

div >>> .modal-header .toolbar {
  background-color: var(--ntss-header-background-color);
}

div >>> .modal-header .toolbar__title.toolbar__left {
  color: var(--ntss-header-color) !important;
}

div >>> .modal-search,
div >>> .modal-body,
div >>> .modal-footer,
div >>> .modal-footer .bottom-bar {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}

div >>> .modal-footer ons-bottom-toolbar {
  height: auto;
}

#stop-watch-icon {
  float: left; 
  width: 20px;
  height: 20px;
}

#div-stop-watch{
  float: left; 
}

.scroll-area-modal {
  overflow-y: visible;
  width: auto;
  overflow: auto;
}

.no-wrap{
  white-space: nowrap;
  overflow: hidden;
}
.manual-width {
  resize: horizontal;
  overflow: hidden;
}

.clearfix::after {
    content: "";
    display: block;
    clear: both;
}

.start-date{
  /*#11059:定期点検履歴画面の日付IF修正Start */
  width: 60%;
  /*#11059:定期点検履歴画面の日付IF修正End */
}

.title-padding{
  padding-left: 8px;
  padding-right: 8px;
  padding-top: 6px;
}

.befor-start{
  padding: 8px;
}

#scrollAreaModal,
#scrollTableModal{
  width: 100%;
}

#scrollCondModal
{
  width: 100%;
  display: flex;
  justify-content: space-between;
}

.inspected-radian-red {
  color: #FF6666;
}

@media print {
  .modal-mask >>> .modal-container {
    width: 95%;
  }
  /* ヘッダ */
  .ntss-list-detail .ntss-list-body-td {
    white-space: normal;
  }
  
  /* テーブル全体を印刷幅に収める */
  #scrollAreaModal {
    height: auto !important;
  }
  .ntss-list-table {
    width: 100% !important;
    table-layout: fixed !important;
    min-width: unset !important;
  }
  .ntss-list-table th,
  .ntss-list-table td {
    width: auto;
    min-width: unset !important;
    word-break: break-all !important;
    white-space: normal !important;
    overflow-wrap: break-word !important;
  }
  
  /* 点検実施日 */
  .ntss-list-table .list-header-th-1 { width: 7em !important; min-width: 7em !important; }
  /* 記録番号 */
  .ntss-list-table .list-header-th-2 { width: 5em !important; min-width: 5em !important; }
  /* 点検名 */
  .ntss-list-table .list-header-th-3 { width: 7em !important; min-width: 7em !important; }
  /* 総合判定 */
  .ntss-list-table .list-header-th-4 { width: 4em !important; min-width: 4em !important; }
  /* 点検者コメント */
  .ntss-list-table .list-header-th-5 { width: 10em !important; min-width: 10em !important; }
  /* 点検者 */
  .ntss-list-table .list-header-th-6 { width: 5em !important; min-width: 5em !important; }
  /* 確認者 */
  .ntss-list-table .list-header-th-7 { width: 5em !important; min-width: 5em !important; }
  /* 点検記録最終更新日時 */
  .ntss-list-table .list-header-th-8 { width: 10em !important; min-width: 10em !important; }
}
</style>
