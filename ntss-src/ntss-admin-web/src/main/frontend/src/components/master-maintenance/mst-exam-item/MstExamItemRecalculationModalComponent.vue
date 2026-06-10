/**
 * 検査再計算ツール
 */
<template>
  <modal-base @onClose="closeModal(false)">
    <div slot="header">
      <component :is="header" />
    </div>
    <div slot="body" style="margin-left: 5%;overflow-y: scroll;max-height:100%">
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label>対象期間</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-txt-long">
          <!-- mod #7523 「対象期間を選択するカレンダー表示」について、対応する。 dengshen start-->
          <!-- <input type="date" v-if="getFacilityCd=='nkknkk'" v-model="oldCurrentDate"/>-->
          <!-- <input type="date" v-if="getFacilityCd!='nkknkk'" :min="oldCurrentTime" v-model="oldCurrentDate"/>-->
          <input type="date" v-if="getFacilityCd=='nkknkk'" v-model="oldCurrentDate" class="custom-input-date ntss-input-date fromDate"/>
          <input type="date" v-if="getFacilityCd!='nkknkk'" :min="oldCurrentTime" v-model="oldCurrentDate" class="custom-input-date ntss-input-date fromDate"/>
          <common-calendar v-if="getFacilityCd=='nkknkk'" v-model="oldCurrentDate" class="calender fromDate-comment"/>
          <common-calendar v-if="getFacilityCd!='nkknkk'" v-model="oldCurrentDate" :min="oldCurrentTime" class="calender fromDate-comment"/>
          <!-- mod #7523 「対象期間を選択するカレンダー表示」について、対応する。 dengshen end-->
        </v-ons-col>
        <v-ons-col class="input-label">
          <label>～</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt-long">
          <!-- mod #7523 「対象期間を選択するカレンダー表示」について、対応する。 dengshen start-->
          <!-- <input type="date" :max="currentTime" v-model="currentDate"/>-->
          <input type="date" :max="currentTime" v-model="currentDate" class="custom-input-date ntss-input-date fromDate"/>
          <common-calendar v-model="currentDate" class="calender fromDate-comment"/>
          <!-- mod #7523 「対象期間を選択するカレンダー表示」について、対応する。 dengshen end-->
        </v-ons-col>
        <v-ons-col class="col-button">
          <v-ons-button class="btn3-normal" @click="onSearch" :disabled="isBatTime">検索 </v-ons-button>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label>対象患者</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <div class="exam-item-set-wrapper">
          <div class="exam-item-set-table">
            <table class="exam-item-list" style="width: 100%">
              <thead>
                <tr>
                  <th class="exam-item-list-header" style="width: 15.3%">
                    <input
                      type="checkbox"
                      name="patExamMain"
                      @click="allSelect"
                      :checked="isPatPersonalChecked"
                      :disabled="isBatTime"
                    />
                  </th>
                  <th class="exam-item-list-header" style="width: 32.2%">ID</th>
                  <th class="exam-item-list-header">氏名</th>
                </tr>
              </thead>
              <tbody>
                <template v-for="(itemcd, index) in displayPatExamMainList" >
                <tr :key="index">
                  <td style="text-align: center" :style="{ backgroundColor:itemcd.isComplete ?  'rgb(138 137 137)' : 'var(--ntss-list-item-background-color)' }">
                    <input type="checkbox" v-model="itemcd.isDisp" :disabled="isBatTime" />
                  </td>
                  <!-- mod #7523 「患者とIDの並びが中央揃えのため見づらくなっている」について、対応する。 dengshen start-->
                  <!-- <td style="text-align: center" :style="{ backgroundColor:itemcd.isComplete ?  'rgb(138 137 137)' : 'var(--ntss-list-item-background-color)' }">{{ itemcd.id }}</td>-->
                  <!-- <td style="text-align: center" :style="{ backgroundColor:itemcd.isComplete ?  'rgb(138 137 137)' : 'var(--ntss-list-item-background-color)' }" >{{ itemcd.name }}</td>-->
                  <td style="text-align: right" :style="{ backgroundColor:itemcd.isComplete ?  'rgb(138 137 137)' : 'var(--ntss-list-item-background-color)' }">{{ itemcd.id }}</td>
                  <td style="text-align: left" :style="{ backgroundColor:itemcd.isComplete ?  'rgb(138 137 137)' : 'var(--ntss-list-item-background-color)' }" >{{ itemcd.name }}</td>
                  <!-- mod #7523 「患者とIDの並びが中央揃えのため見づらくなっている」について、対応する。 dengshen end-->
                </tr>
                </template>
              </tbody>
            </table>
          </div>
        </div>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label>再計算項目</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <div class="exam-item-set-wrapper" style="width: 76%">
          <div class="exam-item-set-table">
            <table class="exam-item-list" style="width: 100%">
              <thead>
                <tr>
                  <th class="exam-item-list-header" style="width: 12%">
                    <input
                      type="checkbox"
                      name="examItemList"
                      @click="allSelect"
                      :checked="isExamItemListChecked"
                      :disabled="isBatTime "
                    />
                  </th>
                  <th class="exam-item-list-header" style="width: 25%">
                    計算検査名
                  </th>
                  <th class="exam-item-list-header" style="width: 25%">
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(itemcd, index) in getExamItemList" :key="index" >
                  <td style="text-align: center">
                    <input type="checkbox" v-model="itemcd.isDispMenu"  @click="deselect($event,index)" :disabled="isBatTime "/>
                  </td>
                  <td style="text-align: center">{{ itemcd.examItemName }}    </td>
                  <td style="text-align: center">
                    <input type="checkbox" name="cover" :checked="itemcd.isCover === true"  @click="isCover($event,index)"
                      :disabled="isBatTime || !itemcd.isDispMenu"/>再計算して上書きする
                    <input type="checkbox" name="unCover" :checked="itemcd.isCover === false" @click="isCover($event,index)"
                      :disabled="isBatTime  || !itemcd.isDispMenu"/>計算しない
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <v-ons-col class="col-button2">
          <v-ons-button class="btn3-normal" @click="refresh" :disabled="isBatTime "> 再表示</v-ons-button>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label>メッセージ</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <!-- mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start -->
          <!-- <textarea style="width: 95%; height: 7em; max-width: 70vw; max-height: 80vh; font-size: inherit; font-family: inherit;" :value="mntRecalcQue.journal"></textarea> -->
          <textarea
            style="width: 95%; height: 7em; max-width: 70vw; max-height: 80vh; font-size: inherit; font-family: inherit;"
            disabled="true" :value="msg"></textarea>
          <!-- mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end -->
        </v-ons-col>
      </v-ons-row>
    </div>
    <div
      slot="footer"
      class="flex-container"
      style="justify-content: initial"
      id="footer"
    >
      <div class="denial-btn-area" style="background: none; margin-left: 4.5%">
        <!-- mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start -->
        <!-- <v-ons-button class="btn2-cancel denial-btn" @click="clear" :disabled="isBatTime && isClear" -->
        <!--   >クリア</v-ons-button -->
        <!-- > -->
        <v-ons-button class="btn2-cancel denial-btn" @click="beforClear" :disabled="isBatTime || isComplete || isClear"
          >クリア</v-ons-button
        >
        <!-- mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end -->
      </div>
      <div class="denial-btn-area" style="background: none">
        <v-ons-button class="btn2-cancel denial-btn" @click="closeModal"
          >キャンセル</v-ons-button
        >
      </div>
      <div
        v-show="searchEnabled"
        class="registration-btn-area"
        style="background: none;margin-left:auto"
      >
        <!-- mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start -->
        <!-- <v-ons-button v-if="!startFalg" :disabled="isBatTime && isSuspension" class="btn1-execute registration-btn" @click="handleSuspension" -->
        <!--   >処理中止</v-ons-button -->
        <!-- > -->
        <v-ons-button v-if="!startFalg" :disabled="isBatTime" class="btn1-execute registration-btn" @click="handleSuspension"
          >処理中止</v-ons-button
        >
        <!-- mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end -->
        <v-ons-button v-if="startFalg" :disabled="isBatTime || displayPatExamMainList.length <=0" style="margin-left:auto" class="btn1-execute registration-btn" @click="handleStart"
          >処理開始</v-ons-button
        >
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapActions, mapGetters } from "vuex";
import { sendRequestGetMstExamItemList} from "@/apis/exam-Record";
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
// add #7523 「対象期間を選択するカレンダー表示」について、対応する。 dengshen start
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import {EXAM_RECALC_MSG, EXAM_RECALC_STATUS} from "@/constants/mstExamItemDefine";
// add #7523 「対象期間を選択するカレンダー表示」について、対応する。 dengshen end

export default {
  components: {
    "modal-base": ModalBase,
    // add #7523 「対象期間を選択するカレンダー表示」について、対応する。 dengshen start
    "common-calendar": commonCalender,
    // add #7523 「対象期間を選択するカレンダー表示」について、対応する。 dengshen end
  },
  data() {
    return {
      header: "",
      countDetection: 0,
      searchEnabled: true,
      messageList: [],
      timerId: 0,
      gridHeight: 150,
      getPatPersonal: [],
      getExamItemList: [],
      getpatExamMainList: [],
      currentDate: "",
      oldCurrentDate: "",
      displayPatExamMainList: [],
      startFalg: true,
      mntRecalcQue: "",
      isBatTime: false,
      isSuspension: true,
      isClear: true,
      // add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
      isComplete: false,
      // add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
    }),
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
      accountInfo: "getStateUserAccountInfo",
    }),
    // add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
    msg() {
      if (this.displayPatExamMainList.length <= 0) {
        return "";
      }
      if (this.isBatTime) {
        return EXAM_RECALC_MSG.IN_PROGRESS;
      }
      if (this.mntRecalcQue.status == EXAM_RECALC_STATUS.PROGRESS_PAUSE) {
        return this.mntRecalcQue.journal;
      }
      if (this.isClear) {
        return EXAM_RECALC_MSG.IS_CLEAR;
      }
      if (this.mntRecalcQue.status == EXAM_RECALC_STATUS.UNPROGRESS) {
        return EXAM_RECALC_MSG.UNPROGRESS;
      } else if (this.mntRecalcQue.status == EXAM_RECALC_STATUS.PROGRESS_COMPLETE) {
        return this.mntRecalcQue.journal;
      } else if (this.mntRecalcQue.status == EXAM_RECALC_STATUS.PROGRESS_STOPED) {
        return EXAM_RECALC_MSG.PROGRESS_STOPED;
      }
      return this.mntRecalcQue.journal;
    },
    // add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
    isPatPersonalChecked() {
      return (
        this.getpatExamMainList.length ==
        this.getpatExamMainList.filter((item) => item.isDisp == true).length
      );
    },
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    isExamItemListChecked() {
      return (
        this.getExamItemList.length ==
        this.getExamItemList.filter((item) => item.isDispMenu == true).length
      );
    },
    currentTime() {
      let currentTime = new Date;
      return currentTime.getFullYear() + '-'+ currentTime.getMonth()+1 + '-' +currentTime.getDate();
    },
    oldCurrentTime() {
      let currentTime = new Date;
      return currentTime.getFullYear()-1 + '-'+ currentTime.getMonth()+1 + '-' +currentTime.getDate();
    }
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount",
    }),
    ...mapActions("mst-wheel-chair", ["fetchPatPersonalSimpleByFacilityCd"]),
    /* del by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
    // ...mapActions("pat-viewer", ["getPatExamMain"]),
    /* del by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      // モーダルのbodyの高さ
      const mb = document.getElementsByClassName("modal-body")[0];
      const mh = mb ? mb.clientHeight : 0;
      // モーダルのヘッダの高さ
      const hElm = document.getElementById("infomation-box");
      const hh = hElm ? hElm.clientHeight : 0;
      this.gridHeight = mh - hh;
      -35;
    },
    closeModal() {
        // モーダルを非表示に
        this.hideModal();
    },
    // add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
    beforClear() {
      this.$ons.notification.confirm({
        title: DIALOG_MESSAGES[74000006].title,
        message: messageFormat(DIALOG_MESSAGES[74000006].message),
        callback: answer => {
          if (answer == 1) {
            //OK
            this.clear();
          }
        }
      });
    },
    // add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
    async clear() {
      this.getExamItemList.forEach(e =>{
        e.isDispMenu = false;
        e.isCover = "";
      })
      this.displayPatExamMainList.forEach(e=>{
        e.isDisp = true;
      })
      if (this.mntRecalcQue)
        await ApiHelper.post(
        `/exam/updateMntRecalcQue/`,{
          dispFlg:"0",
          upId:this.accountInfo.userId,
          recalcQueCd:this.mntRecalcQue.recalcQueCd
      }).
      catch(error => {
         //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
         getErrorMessage('MstExamItemRecalculationModalComponent.vue', 'clear', error);
         //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
         throw error;
      });
      this.isBatTime = false;
      this.startFalg = true;
      this.isClear = true;
      if (this.mntRecalcQue) {
        this.mntRecalcQue = "";
      }
    },
    allSelect(e) {
      if (e.target.name == "patExamMain")
        this.getpatExamMainList.forEach((item) => {item.isDisp = e.target.checked;});

      if (e.target.name == "examItemList"){
        this.getExamItemList.forEach((item) => {item.isDispMenu = e.target.checked;});
        if (e.target.checked)
        this.getExamItemList.forEach((item) => {item.isCover = true;});
        if (!e.target.checked)
        this.getExamItemList.forEach((item) => {item.isCover = "";});
      }
    },
    onSearch() {
      this.displayPatExamMainList = this.getpatExamMainList.filter(e => e.regDate >= this.oldCurrentDate && e.regDate < this.currentDate);
    },
    refresh() {
      this.getExamItem();
    },
    isCover(e, index) {
      if (e.target.name == "cover" && e.target.checked) {
        this.getExamItemList[index].isCover = true;
        document.getElementsByName("unCover")[index].checked = false;
      }
      if (e.target.name == "unCover" && e.target.checked) {
        this.getExamItemList[index].isCover = false;
        document.getElementsByName("cover")[index].checked = false;
      }
    },
    deselect(e, index) {
      if (!e.target.checked)
        this.getExamItemList[index].isCover = "";
      if (e.target.checked)
        this.getExamItemList[index].isCover = true;
    },
    async handleStart() {
     this.startFalg = false;
     this.isSuspension = false;
     let choicePats = [];
     this.displayPatExamMainList.forEach(item => {
       if (item.isDisp) {
         choicePats.push(item.patId)
       }
     })
     let choiceExam = [];
     this.getExamItemList.forEach(item => {
        if (item.isDispMenu) {
          let newItem = {
            exam_item_cd:item.examItemCd,
            compute_cover:item.isCover
          }
          choiceExam.push(newItem)
        }
     })
     let content = {
       pat_id: choicePats,
       to_date: this.currentDate,
       from_date: this.oldCurrentDate,
       item:choiceExam
     }
     let detail = {
       exam_main_cd: "",
       total_cnt: 0,
       done_cnt: 0
     }
     // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
     // if (!this.mntRecalcQue || !this.mntRecalcQue.recalcQueCd)
     if (this.mntRecalcQue.status == EXAM_RECALC_STATUS.PROGRESS_COMPLETE || this.isClear) {
     // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
       await ApiHelper.post(
         `/exam/createMntRecalcQue/`,{
           facilityCd:this.getFacilityCd,
           status:"0",
           content: JSON.stringify(content),
           detail:JSON.stringify(detail),
           regId:this.accountInfo.userId
         }
       ).
       catch(error => {
         //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
         getErrorMessage('MstExamItemRecalculationModalComponent.vue', 'handleStart', error);
         //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
         throw error;
       });
     // add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
     } else {
     // add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
       if (this.mntRecalcQue) {
         await ApiHelper.post(
           `/exam/updateMntRecalcQue/`,{
             status: "0",
             content: JSON.stringify(content),
             upId:this.accountInfo.userId,
             recalcQueCd:this.mntRecalcQue.recalcQueCd
           }).
         catch(error => {
           //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
           getErrorMessage('MstExamItemRecalculationModalComponent.vue', 'handleStart', error);
           //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
           throw error;
         });
         // del #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
         // this.isBatTime = true;
         // this.isClear = false;
         // del #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
       }
     }
      this.closeModal()
    },
    async handleSuspension() {
      await ApiHelper.get(
      `/exam/MntRecalcQue/${this.getFacilitySwitch}`
      ).then((response) =>{
        if(response.data ) {
          response.data.forEach (e =>{
            if (e.status != "2" && e.status != "9") {
              this.mntRecalcQue = e;
            }
            if (e.status == "9") {
              this.mntRecalcQue = e;
              this.startFalg = true;
            }
          })
        }
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstExamItemRecalculationModalComponent.vue', 'handleSuspension', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });
      if (this.mntRecalcQue.status == "0") {
        // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
        // await ApiHelper.post(
        //   `/exam/updateMntRecalcQue/`,{
        //     status:"9",
        //     content: this.mntRecalcQue.content,
        //     upId:this.accountInfo.userId,
        //     recalcQueCd:this.mntRecalcQue.recalcQueCd
        //   } ).
        // catch(error => {
        //   //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        //   getErrorMessage('MstExamItemRecalculationModalComponent.vue', 'handleSuspension', error);
        //   //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        //   throw error;
        // });
        // this.startFalg = true;
        // this.isBatTime = false;
        // this.isSuspension= true;
        this.updateForProgressStopedu();
      } else if (this.mntRecalcQue.status == EXAM_RECALC_STATUS.PROGRESS_PAUSE) {
        if (this.mntRecalcQue.status == EXAM_RECALC_STATUS.PROGRESS_PAUSE) {
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[74000005].title,
            message: messageFormat(DIALOG_MESSAGES[74000005].message),
            callback: answer => {
              if (answer == 1) {
                //OK
                this.updateForProgressStopedu();
                // モーダルを閉じる
                this.closeModal()
              }
            }
          });
        }
      }
    },
    async updateForProgressStopedu() {
      this.mntRecalcQue.status = "9";
      await ApiHelper.post(
        `/exam/updateMntRecalcQue/`,{
          status: this.mntRecalcQue.status,
          content: this.mntRecalcQue.content,
          upId:this.accountInfo.userId,
          recalcQueCd:this.mntRecalcQue.recalcQueCd
        } ).
      catch(error => {
        getErrorMessage('MstExamItemRecalculationModalComponent.vue', 'handleSuspension', error);
        throw error;
      });
      this.startFalg = true;
      this.isSuspension= true;
    },
    // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
    async getExamItem() {
      let getExamItemList = [];
      await sendRequestGetMstExamItemList(this.getFacilitySwitch)
        .then((response) => {
          if (response.data) {
            response.data.forEach((item) => {
              if (
                item.isDisp == "1" &&
                (item.examClass == "1" || item.examClass == "2")
              ) {
                item["isDispMenu"] = "";
                item["isCover"] = "";
                getExamItemList.push(item);
              }
            });
          }
        })
        .catch(() => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstExamItemRecalculationModalComponent.vue', 'getExamItem', '検査項目マスタ取得失敗');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "エラー",
            // message: "検査項目マスタ取得失敗",
            title: DIALOG_MESSAGES['00200054'].title,
            message: messageFormat(DIALOG_MESSAGES['00200054'].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        });
    this.getExamItemList = getExamItemList;
    },
    startPolling() {
      this.endPolling();
      this.timerId = setInterval(this.numberOfDevices, 30000);
    },
    endPolling() {
      clearInterval(this.timerId);
    },
    numberOfDevices() {},
    calculateModalWidthHeight() {
      document.getElementsByClassName("modal-container")[0].style.maxWidth =
        "1200px";
      document.getElementsByClassName("modal-container")[0].style.maxHeight =
        "1120px";
      ("70%");

      document.getElementsByClassName("modal-container")[0].style.width = "58%";
      let bottomBar = document.getElementsByClassName("bottom-bar")[0].clientHeight;
      document.getElementsByClassName("modal-container")[0].style.height =
        "70%";
      document.getElementsByClassName("modal-body")[0].style.overflow =
        "hidden";
      document.getElementsByClassName("modal-body")[0].style.height =
        "calc(100% - "+bottomBar +"px- 2em)";
    },
    async init() {
      // add #8598「検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない」について、対応する。 dengshen start
      const sysSystemDefine = await ApiHelper.get(`/sys_system_define/getSysSystemDefine/${13}`);
      let BatTime = JSON.parse(sysSystemDefine.data[0].value);
      let currentTime = new Date;
      let time = (Array(1).join('0') + currentTime.getHours()) + (Array(1).join('0') + currentTime.getMinutes())
      if (BatTime.startTime <= time && BatTime.endTime >= time) {
        this.isBatTime = true;
      // add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
      } else {
        this.isBatTime = false;
      }
      // add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
      // add #8598「検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない」について、対応する。 dengshen end
      let patIdList = [];
      await this.fetchPatPersonalSimpleByFacilityCd(this.getFacilitySwitch)
      .then((response) => {
        if (response.data)
          response.data.forEach((item) => {
            this.getPatPersonal.push({
              id: item.hosp_pat_id,
              name: item.pat_last_name + "" + item.pat_first_name,
              isDisp: true,
              pat_id: item.pat_id
            });
            patIdList.push(item.pat_id)
          });
      })
      .catch(() => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstExamItemRecalculationModalComponent.vue', 'init', '所有患者氏名取得失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "エラー",
          // message: "所有患者氏名取得失敗",
          title: DIALOG_MESSAGES['00200055'].title,
          message: messageFormat(DIALOG_MESSAGES['00200055'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
      });
      let getpatExamMainList = []
      // データの取得
      let patLists = this.getPatPersonal;
      await ApiHelper.get(
        `/exam/TreatDateList/${this.getFacilitySwitch}`
      ).then((response) =>{
        if(response.data) {
          response.data.forEach(item =>{
            if (item.facilityCd == this.getFacilitySwitch) {
              let patFilterLists = patLists.filter(e => e.pat_id == item.patId);
              if (patFilterLists.length !== 0){
                item["name"] = patFilterLists[0].name;
                item["id"] = patFilterLists[0].id;
                item["isDisp"] = true;
                if (!getpatExamMainList.map(e=> e.patId).includes(item.patId) && item.examResultInfo)
                  getpatExamMainList.push(item)
              }
            }
          })
        }
      })
     .catch(error => {
       //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
       getErrorMessage('MstExamItemRecalculationModalComponent.vue', 'init', error);
       //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });
      this.getpatExamMainList = getpatExamMainList;
      this.displayPatExamMainList = getpatExamMainList;
      this.getExamItem();
          // データの取得
      await ApiHelper.get(
      `/exam/MntRecalcQue/${this.getFacilitySwitch}`
      ).then((response) =>{
        if(response.data ) {
          response.data.forEach (e =>{
            if (e.status != "2" && e.status != "9") {
              this.startFalg = false;
              this.isSuspension= false;
              // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
              // this.mntRecalcQue = e;
            }
            // if (e.status == "9") {
            //
            //   this.mntRecalcQue = e;
            // }
            // if (e.status == "2") {
            //   this.mntRecalcQue = {
            //     journal:"",
            //   }
            //   this.mntRecalcQue.journal = e.journal;
            // }
            this.mntRecalcQue = e;
            // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
          })
        }
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstExamItemRecalculationModalComponent.vue', 'init', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });
      // del #8598「検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない」について、対応する。 dengshen start
      // const sysSystemDefine = await ApiHelper.get(`/sys_system_define/getSysSystemDefine/${13}`);
      // let BatTime = JSON.parse(sysSystemDefine.data[0].value);
      // let currentTime = new Date;
      // let time = (Array(1).join('0') + currentTime.getHours()) + (Array(1).join('0') + currentTime.getMinutes())
      // if (BatTime.startTime <= time && BatTime.endTime >= time) this.isBatTime = true;
      // del #8598「検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない」について、対応する。 dengshen end
    },
    unprocessedContentLoad() {
      let mntRecalcQue = JSON.parse(this.mntRecalcQue.content);
      this.displayPatExamMainList.forEach(ietm => {
        ietm.isDisp = false
        if (mntRecalcQue.pat_id.indexOf(ietm.patId) > -1)
          ietm.isDisp = true
      });
      let items = mntRecalcQue.item.map((d) => d.exam_item_cd)
      this.getExamItemList.forEach(ietm => {
        if (items.indexOf(ietm.examItemCd) > -1) {
          ietm.isDispMenu = true
          ietm.isCover = mntRecalcQue.item.filter(e => e.exam_item_cd == ietm.examItemCd)[0].compute_cover;
        }
      })
    },
  },
  watch: {
    windowHeight() {
      this.calculateModalWidthHeight();
    },
    isDispMenu() {
      this.calculateModalWidthHeight();
    },
    getFontSize() {
      this.calculateModalWidthHeight();
    },
  },
  mounted() {
    // 画面高さと幅を調整
    this.calculateModalWidthHeight();
    // ポーリング開始
    this.startPolling();
    this.$nextTick(() => {
      this.calculateModalWidthHeight();
    });
  },
  async created() {
    this.setLoadingScreenVisible(true);
    let currentTime = new Date();
    this.currentDate = currentTime.getFullYear() + '-'+ currentTime.getMonth()+1 + '-' +currentTime.getDate();
    this.oldCurrentDate = currentTime.getFullYear()-1 + '-'+ currentTime.getMonth()+1 + '-' +currentTime.getDate();
    await this.init();

    if ( this.mntRecalcQue.status == "9") this.unprocessedContentLoad();
    if ( this.mntRecalcQue.status == "0") {
      this.unprocessedContentLoad();
      // del #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
      // this.isBatTime = true;
      // this.isClear = false;
      // del #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
    }
    if ( this.mntRecalcQue.status && this.mntRecalcQue.journal) {
      // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
      // this.isBatTime = true;

    }
    if (this.mntRecalcQue.status == EXAM_RECALC_STATUS.PROGRESS_COMPLETE) {
      this.isComplete = true;
    } else {
      this.isComplete = false;
    }
    // mod #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
    this.isClear = false;
    this.setLoadingScreenVisible(false);
  },
  beforeDestroy() {
    // ポーリング終了
    this.endPolling();
  },
};
</script>

<style scoped>
#footer {
  margin: 0;
  /* mod redmine 5454 「クリア」、「キャンセル」、「処理開始」ボタンがモーダル下部に接している 宋qy start */
  padding: 2.5px 5px 2.5px 5px;
  /* mod redmine 5454 「クリア」、「キャンセル」、「処理開始」ボタンがモーダル下部に接している 宋qy end */
  bottom: 0;
  position: relative;
  width: inherit;
}
table {
  border-collapse: collapse;
}
table th,
table td {
  border: solid 1px var(--ntss-list-border-color);
}
.machine-record-list-wrapper {
  overflow: auto;
}
table.exam-item-list {
  border-collapse: collapse;
}
.exam-item-set-wrapper {
  font-size: 1em;
  width: 95%;
  height: 10em;
  overflow-y: scroll;
  overflow-x: hidden;
  border: solid 1px var(--ntss-list-border-color);
}
th.exam-item-list-header {
  z-index: 1;
  background-color: var(--ntss-list-header-background-color);
  border: solid 1px var(--ntss-list-border-color);
  font-weight: 100;
  position: -webkit-sticky;
  position: sticky;
  top: 0;
  color: #fff;
}
table.machine-list {
  width: 100%;
}
.table-width td {
  text-align: center;
}
table.machine-list thead {
  color: white;
  background-color: var(--ntss-list-header-background-color);
}
table.machine-list thead tr.machine-list-header th {
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
  position: -webkit-sticky;
  position: sticky;
  --top: 0px;
  top: var(--top);
  z-index: 1;
}
table.machine-list thead tr {
  height: 33px;
}
table.machine-list tbody tr.even-row {
  background-color: var(--ntss-list-item-background-color);
}
table.machine-list tbody tr.odd-row {
  background-color: var(--ntss-list-content-2nd-background-color);
}
table.machine-list tbody tr td.send-checkbox {
  text-align: center;
}
.title {
  width: 12em;
}
tr {
  height: 2em;
  padding: 0 0.75rem;
}
.machine-record-list-wrapper tr:hover {
  background-color: var(--master-maintenance-kgrid-item-hover-background-color);
}
.select {
  width: 99%;
  height: 2em;
  min-height: 31px;
  font-size: 1em;
  display: flex;
  align-items: center;
}
.select >>> .select-input {
  font-size: 1em;
  line-height: unset;
}
.input-item-txt-long {
  max-width: 24%;
}
.input-label {
  max-width: 2%;
  margin: 0 11%;
}
.col-button {
  max-width: 19%;
  margin-left: 4%;
}
.col-button2 {
  max-width: 19%;
  /* add redmine 5454 「再表示」ボタンが再計算項目のスクロールバーと接している 宋qy start */
  margin-left: 5px;
  /* add redmine 5454 「再表示」ボタンが再計算項目のスクロールバーと接している 宋qy end */
}
.center {
  text-align: center;
}
.vertical-middle {
  vertical-align: middle;
}
.margin-left {
  margin: 0 0 0 2.76em;
}
.infomationbox {
  width: 100%;
  background-color: #89c7de;
  color: #fff;
  text-align: center;
  padding: 13px 0;
  position: absolute;
  bottom: 0;
}
.infomationbox p {
  margin: 0;
  padding: 0;
}
</style>
