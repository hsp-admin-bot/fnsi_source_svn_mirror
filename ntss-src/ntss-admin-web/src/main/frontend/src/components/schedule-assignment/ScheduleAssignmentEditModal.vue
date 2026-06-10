/** * 指示ベース画面 */

<template>
  <div>
    <div class="indInfo-style-modal-container scroll-style">
      <div class="IndBaseHeader">
          <v-ons-row class="div-style" style="clear: left;">
            <v-ons-col class="indInfo-style-label-position header-info">
              <!--mod FNSI redmine 5923 start-->
              <label>ベッド：{{structData.bedName}}？？？？患者治療に割り当てる、患者ID：{{structData.hospPatId}}&#8195;患者名：{{structData.patName}}&#8195;さんの治療予定を作成します。</label>
              <!--mod FNSI redmine 5923 end-->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="div-style" style="clear: left;">
            <v-ons-col class="indInfo-style-label-position">
              <label>治療日</label>
            </v-ons-col>
            <v-ons-col>
              <input
                v-model="indStartDate"
                type="date"
                class="date-input common-style-input ntss-input-date ntss-custom-input"
                data-target="indStartDate"
                :disabled="updateDisable"
                 @blur="changeInterval"
              />
              <custom-calendar
                v-model="indStartDate"
                 :disabled="updateDisable"
                @input="createDateList"
              />
            </v-ons-col>
          </v-ons-row>
        </div>
    <hr class="hr-style"/>
    <!-- mod FutreNetWeb+SI課題管理No5110対応 于 start -->
<!--     <div class="slot-style" style="height:560px;overflow:auto">-->
<!--       <ind-plan-create ref="incluceMediTreatPlan" :is-update-method="true" />-->
<!--     </div>-->
    <div class="slot-style">
      <ind-plan-create ref="incluceMediTreatPlan" :is-update-method="true" />
    </div>
    <!-- mod FutreNetWeb+SI課題管理No5110対応 于 end -->
    <hr class="hr-style"/>
    <div>
      <v-ons-row class="div-style" width="100%">
        <v-ons-col
          style="text-align: end; padding-right: 10px; margin: auto;"
        >
          <label>指示者</label>
        </v-ons-col>
        <v-ons-col width="170px">
          <kendo-dropdownlist
            v-model="structData.indUser"
            :data-source="structData.userOptions"
            :data-text-field="'fullName'"
            :data-value-field="'user_id'"
            style="width: 100%;"
            class="common-style-input input-style-required"
            :disabled="updateDisable"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row width="100%"   style="position:relative;margin-bottom: 10px;">
        <v-ons-col width="50%">
          <!-- mod 画面スタイル(ボタン)対応 徐 start -->
          <!-- &nbsp;&nbsp;<v-ons-button style="width:auto" class="button denial-btn" @click="dispCancel"  :disabled="updateDisable">キャンセル</v-ons-button> -->
          &nbsp;&nbsp;<v-ons-button style="width:auto" class="button btn2-cancel" @click="dispCancel"  :disabled="updateDisable">キャンセル</v-ons-button>
          <!-- mod 画面スタイル(ボタン)対応 徐 end -->
        </v-ons-col>
        <v-ons-col width="50%" class="right" style="text-align:right">
          <!-- mod 画面スタイル(ボタン)対応 徐 start -->
          <!-- <v-ons-button style="width:auto" class="common-style-ok-button button" @click="updSetting" :disabled="updateDisable">&#8195;&#8195;確定&#8195;&#8195;</v-ons-button>&nbsp;&nbsp; -->
          <!-- mod redMine #5119対応 陳 start -->
          <!--<v-ons-button style="width:auto" class="btn1-execute button" @click="updSetting" :disabled="updateDisable">&#8195;&#8195;確定&#8195;&#8195;</v-ons-button>&nbsp;&nbsp;-->
          <v-ons-button style="width:auto" class="btn1-execute button" @click="updSetting" :disabled="updateDisable">&#8195;&#8195;割り当て&#8195;&#8195;</v-ons-button>&nbsp;&nbsp;
          <!-- mod redMine #5119対応 陳 end -->
          <!-- mod 画面スタイル(ボタン)対応 徐 end -->
        </v-ons-col>
      </v-ons-row>
    </div>
   </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import CustomCalendar from "@/components/common/custom-calendar/CustomCalendar";
import IndPlanCreate from "@/components/indication/IndPlanCreate";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import { deepCopy } from "@/functions/common/CommonFunctions";
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
import moment from "moment";
// add FNSI redmine 6706 劉祥霖 start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
// add FNSI redmine 6706 劉祥霖 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  // add  FNSI-？？？？患者割り当て 陳 start
  // mixins: [MasterMaintenanceMixin, IndUserSelectMixin],
  mixins: [MasterMaintenanceMixin, IndUserSelectMixin,UserAuthorityMixin],
  // add  FNSI-？？？？患者割り当て 陳 end
  components: {
    "custom-calendar": CustomCalendar,
    "ind-plan-create": IndPlanCreate
  },
  props: {
    settingData: {
      type: Object,
      default: () => ({
        headerTitle: {
          type: String
        },
        segmentLabel1: {
          type: String
        },
        segmentLabel2: {
          type: String
        },
        segmentLabel3: {
          type: String
        },
        segmentLabel4: {
          type: String
        },
        segmentLabel5: {
          type: String
        },
        facilityCd: {
          type: String,
          required: true
        },
        ordNo: {
          type: String,
          default: null
        },
        patId: {
          type: String,
          required: true
        },
        patName: {
          type: String,
          required: true
        },
        bedName: {
          type: String,
          required: true
        },
        startDate: {
          type: String,
          default: "2018-01-01"
        },
        endDate: {
          type: String,
          default: ""
        },
        showSegment: {
          type: Boolean,
          default: true
        },
        showNewEdit: {
          type: Boolean
        },
        showDelete: {
          type: Boolean,
          default: false
        },
        showWeeks: {
          type: Boolean,
          default: true
        },
        showKur: {
          type: Boolean,
          default: false
        },
        showTreat: {
          type: Boolean,
          default: false
        },
        allWeek: {
          type: Boolean,
          default: false
        },
        monday: {
          type: Boolean,
          default: false
        },
        tuesday: {
          type: Boolean,
          default: false
        },
        wednesday: {
          type: Boolean,
          default: false
        },
        thursday: {
          type: Boolean,
          default: false
        },
        friday: {
          type: Boolean,
          default: false
        },
        saturday: {
          type: Boolean,
          default: false
        },
        sunday: {
          type: Boolean,
          default: false
        },
        hrOnder: {
          type: Boolean,
          default: true
        },
        hrUnder: {
          type: Boolean,
          default: true
        },
        startDateEdit: {
          type: Boolean,
          default: false
        },
        endDateEdit: {
          type: Boolean,
          default: false
        },
        disIndUserEdit: {
          default: false,
          type: Boolean
        }
      })
    },
    /**
     * モーダル表示フラグ
     */
    modalVisible: {
      type: Boolean,
      default: false
    },
    /**
     * コンポーネントID
     */
    componentId: {
      type: String,
      default: null
    },
    /**
     * クール名
     */
    indKurName: {
      type: String,
      default: "未登録"
    },
    /**
     * 治療開始時刻
     */
    indTreatStartTime: {
      type: String,
      default: "未登録"
    },
    /**
     * ベッド名
     */
    indBedName: {
      type: String,
      default: "未登録"
    }
  },
  data() {
    return {
      structData: {
        patId: this.settingData.patId,
        patName: this.settingData.patName,
        bedName: this.settingData.bedName,
        indStartDate: this.settingData.startDate,
        indEndDate: this.settingData.endDate,
        indUser: null,
        indWeeks: [
          {
            text: "全",
            done: this.settingData.allWeek,
            value: 0
          },
          {
            text: "月",
            done: this.settingData.monday,
            value: 1
          },
          {
            text: "火",
            done: this.settingData.tuesday,
            value: 2
          },
          {
            text: "水",
            done: this.settingData.wednesday,
            value: 3
          },
          {
            text: "木",
            done: this.settingData.thursday,
            value: 4
          },
          {
            text: "金",
            done: this.settingData.friday,
            value: 5
          },
          {
            text: "土",
            done: this.settingData.saturday,
            value: 6
          },
          {
            text: "日",
            done: this.settingData.sunday,
            value: 7
          }
        ],
        facilityCd: this.settingData.facilityCd,
        selectedKur: [],
        kurOptions: [],
        selectedTreat: [],
        treatOptions: [],
        /**
         * 治療方法リストの初期値
         */
        initTreatOptions: [],

        userOptions: [],
        cycleWeek: "0",
        isDeadline: true,
        // 治療種別を表示フラグ(予定作成で使用)
        isShowTreatType: this.settingData.showSegment,
        // 警告受け入れフラグ(予定作成で使用)
        acceptWarnFlag: false
      },
      selOrdNo:"selOrdNo",
      indStartDate: null,
      planStartDate: null,
      selectedDates: [],
      selectedTreatDate: "",
      ordMainInfo: "",
      mstTreatmentInfo: null,
      mstKurInfo: null,
      schInfo: [
        { cd: "1", label: "クール", value: "" },
        { cd: "2", label: "治療開始時刻", value: "" },
        { cd: "3", label: "ベッド", value: "" }
      ],
      selectedOrdMain: { label: "", ordNo: "", upDate: "" },
      ordMainList: [
        {
        }
      ],
      baseData: null,
      treatInfo: { cd: "", name: "" },
      showPastInd: false,
      // add FNSI-？？？？患者割り当て 陳 start
      updateDisable: false,
      // add FNSI-？？？？患者割り当て 陳 end
      selectedDialDate: ""
    };
  },
  created() {
    // 別の modal-body 内に表示している為、フッター領域も含めて高さを確保する必要があります
    const topObj = document.getElementsByClassName("modal-body");
    if (topObj.length > 0) {
      topObj[0].style.height = "100%";
    }
    this.getIndUserList(
      AUTHORITY_CODES.IND_EDIT,
      AUTHORITY_CODES.IND_PEDIT
    ).then(response => {
      this.structData.userOptions = response.doctorList;
      this.structData.indUser = null;
      this.$nextTick(() => {
        this.structData.indUser = response.iniSelectId;
      });
    });

    // add FNSI-？？？？患者割り当て 陳 start
    this.updateDisable = true;
    // add FNSI-？？？？患者割り当て 陳 end
  },
  destroyed() {
    const topObj = document.getElementsByClassName("modal-body");
    if (topObj.length > 0) {
      topObj[0].style.height = "";
    }
  },
  computed: {
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd","getAdvancedSettings"]),
    ...mapGetters("schedule-assignment/modal", [
      "getStructData"
    ]),
  },
  mounted() {
    this.structData = this.getStructData;
    this.indStartDate = this.structData.indStartDate;

    // add FNSI-？？？？患者割り当て 陳 start
    var authFlg = this.getTreatmentRecordAuthority();
    this.updateDisable = !authFlg;
    this.$refs.incluceMediTreatPlan.updateDisable = !authFlg;

    this.$refs.incluceMediTreatPlan.schInfo[2].value = this.structData.bedName;
    //    add FNSI redmine 劉祥霖 5923 start
    this.$refs.incluceMediTreatPlan.bedCd = this.structData.bedCd;
    //    add FNSI redmine 劉祥霖 5923 end
    // add FNSI-？？？？患者割り当て 陳 end
  },
  methods: {
    ...mapActions("schedule-assignment/modal", [
      "setStructData",
      "setScheduleAssignment"
    ]),
    // add FNSI redmine 6706 劉祥霖 start
    ...mapActions("treatment-record/common", ["getMstMachineByOrdNoRst", "sendGetNoticeMedi"]),
    ...mapActions("treatment-record/mediInfo", {
      sendRequestChangeIndMediInfoRst: "sendRequestChangeIndMediIn",
    }),
    // add FNSI redmine 6706 劉祥霖 end
    // キャンセルボタン
    dispCancel() {
      // 体重計設定画面表示
      this.$emit("close");
    },
    async updSetting() {

      // add FNSI-？？？？患者割り当て 陳 start
      if("" === this.$refs.incluceMediTreatPlan.selectedSet.cd){
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "",
          // message: "</br>予定内容は必須入力項目です。</br>必ず値を入力してください。</br></br>"
          title: DIALOG_MESSAGES[12000209].title,
          message: messageFormat(DIALOG_MESSAGES[12000209].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });

        return;
      }

      if("" === this.$refs.incluceMediTreatPlan.kurInfo){
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "",
          // message: "</br>クールは必須入力項目です。</br>必ず値を入力してください。</br></br>"
          title: DIALOG_MESSAGES[12000210].title,
          message: messageFormat(DIALOG_MESSAGES[12000210].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });

        return;
      }

      if(!this.structData.indUser) {
        // title: "必須項目未入力",
        // message: "{$1}は必須入力項目です。\n必ず値を入力してください。"
        const { title, message } = DIALOG_MESSAGES[22010001];
        this.$ons.notification.alert({
          title,
          message: messageFormat(message, "指示者"),
        });

        return;
      }
      // add FNSI-？？？？患者割り当て 陳 end

      this.baseData = deepCopy(this.structData);
      this.baseData.updUser = this.structData.indUser;
      this.baseData.flag = 1;

      this.baseData.indStartDate = moment(this.indStartDate).format('YYYY-MM-DD');
      this.baseData.indEndDate = this.baseData.indStartDate;


      var date = new Date(this.baseData.indStartDate);
      var week = 7;
      if (date.getDay() != 0) {
        week = date.getDay();
      }
      this.baseData.patId = this.structData.patId;
      this.baseData.facilityCd = this.getFacilityCd;
      this.baseData.indWeeks = this.structData.indWeeks;

      this.baseData.indWeeks.forEach(item => {
        if (item.value == week) {
          item.done = true;
        } else {
          item.done = false;
        }
      });

        // add FNSI-？？？？患者割り当て 陳 start
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "？？？？患者スケジュール割り当て",
          title: DIALOG_MESSAGES[13000119].title,
          // message:
          //   "指定した患者と予定を作成し、？？？？患者治療データに割り当てます。</br>実行すると元に戻すことができません。</br>実行してよろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000119].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
          // callback: answer => {
          callback: async answer => {
            // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
            if (answer == 1) {
        // add FNSI-？？？？患者割り当て 陳 end

                // mod FNSI-？？？？患者割り当て 陳 start
                // this.$refs.incluceMediTreatPlan.updateIndInfo(this.baseData).then(() => {
              // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
              var checkOkFlg = true;
              // 禁忌・アレルギー警告チェック
              if (this.$refs.incluceMediTreatPlan.isWarnTabooAllergyFlag) {
                const title = DIALOG_MESSAGES[12010004].title;
                const msg = messageFormat(DIALOG_MESSAGES[12010004].message);
                await this.$ons.notification.confirm({
                  title: title,
                  message: msg.replace(/{\$\d*}/, "<br>登録してよろしいですか？"),
                  callback: answer => {
                    if (answer === 1) {
                      // IndPlanCreate.updateIndInfoの「禁忌・アレルギー警告」チェックをスキップする
                      this.baseData.acceptWarnFlag = true;
                    } else {
                      checkOkFlg = false;
                    }
                  }
                });
              }

              if (checkOkFlg) {
                // 使用期限のチェック
                const treatSetObj = this.$refs.incluceMediTreatPlan.mstTreatSetInfo
                  .filter(set => set.treatmentCd === this.$refs.incluceMediTreatPlan.selectedSet.treatmentCd
                    && set.treatmentSetCd === this.$refs.incluceMediTreatPlan.selectedSet.cd)[0];
                var treatDateList = await this.$refs.incluceMediTreatPlan.getTreatDateList(this.baseData);
                if (Array.isArray(treatDateList) && !await this.$refs.incluceMediTreatPlan.chkInExpiryDate(
                  treatSetObj, treatDateList[0], treatDateList[treatDateList.length - 1])) {
                  const title2 = DIALOG_MESSAGES[12010008].title;
                  const msg2 = messageFormat(DIALOG_MESSAGES[12010008].message);
                  await this.$ons.notification.confirm({
                    title: title2,
                    message: msg2.replace(/{\$\d*}/, "<br>登録してよろしいですか？"),
                    callback: answer => {
                      if (answer === 1) {
                        // IndPlanCreate.updateIndInfoの「使用期限」チェックをスキップする
                        this.baseData.chkExpiredFlag = true;
                      } else {
                        checkOkFlg = false;
                      }
                    }
                  });
                }
              }
              if (checkOkFlg) {
                // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
                this.$refs.incluceMediTreatPlan.updateIndInfo(this.baseData).then((res1) => {
                  // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
                  if (!res1) {
                    return;
                  }
                  // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
                  if(res1.result === true && res1.message != undefined && res1.message !== ""){
                    var messageStr = "";
                    //mod FNSI redmine 6588 劉祥霖 start
                    var messageTitle="";
                    if(res1.message == "Dummy治療予定重複エラー"){
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                      // messageTitle = "長時間予定との予定重複";
                      // messageStr = "他の予定と重複するためスケジュール変更できません。";
                      messageTitle = DIALOG_MESSAGES[12000212].title;
                      messageStr = messageFormat(DIALOG_MESSAGES[12000212].message);
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    }else
                    if (res1.message == "3治療予定重複エラー"){
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                      // messageTitle = "治療予定重複エラー";
                      // messageStr = "選択患者に既に同日、同クール、同治療方法の予定が存在するため登録できません。</br> 作成済みの予定を割り当てるにはスケジュール割り当てを実施してください。";
                      messageTitle = DIALOG_MESSAGES[12000213].title;
                      messageStr = messageFormat(DIALOG_MESSAGES[12000213].message);
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                      
                    }else {
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                      // messageTitle = "治療予定重複エラー";
                      // messageStr = "指定した日に既に予定が存在するため登録できません。</br> 予定を移動するか別のクールを選択してください。";
                      messageTitle = DIALOG_MESSAGES[12000214].title;
                      messageStr = messageFormat(DIALOG_MESSAGES[12000214].message);
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    }

                    // エラーメッセージ表示
                    this.$ons.notification.alert({
                      title: messageTitle,
                      message: messageStr
                    });
                    //mod FNSI redmine 6588 劉祥霖 end
                  }else {
                  // mod FNSI-？？？？患者割り当て 陳 end

                // 患者割当ての場合
                this.setScheduleAssignment({
                  selOrdNo : this.selOrdNo,
                  rstInputClass : 4
                  }).then(res => {
                  if (res.result === false) {
                    // エラーメッセージ表示
                    this.$ons.notification.alert({
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                      // title: "スケジュール割当失敗",
                      title: DIALOG_MESSAGES["00300022"].title,
                      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                      message: res.message
                    });
                    // 「登録」ボタン活性
                    this.setDisabledButton( false );

                  // del FNSI-？？？？患者割り当て 陳 start
                  // add FNSI-？？？？患者割り当て 陳 start
                  //} else {
                  // }else if(res.result === true && res.message != undefined && res.message !== ""){

                  //   var messageStr = "";
                  //   if (res.message == "3治療予定重複エラー"){

                  //     messageStr = "選択患者に既に同日、同クール、同治療方法の予定が存在するため登録できません。</br> 作成済みの予定を割り当てるにはスケジュール割り当てを実施してください。";
                  //   }else {

                  //     messageStr = "指定した日に既に予定が存在するため登録できません。</br> 予定を移動するか別のクールを選択してください。";
                  //   }

                  //   // エラーメッセージ表示
                  //   this.$ons.notification.alert({
                  //     title: "治療予定重複エラー",
                  //     message: messageStr
                  //   });
                  //   // 「登録」ボタン非活性
                  //   this.setDisabledButton( true );
                 // add FNSI-？？？？患者割り当て 陳 end
                 // del FNSI-？？？？患者割り当て 陳 end
                  } else {
                    // 通信サーバ通知処理
                    this.$emit("comserverNotification");
                    // add FNSI redmine 6706 劉祥霖  start
                    //add FNSI redmine 6706 劉祥霖  start 追加再修正：？？？？患者予定部分に投薬がないと通知しない
                    if(res.sendMediNoticeFlag == true){
                    //add FNSI redmine 6706 劉祥霖  end 追加再修正：？？？？患者予定部分に投薬がないと通知しない
                      this.sendGetNoticeMedi(this.selOrdNo).then(results=>{
                        if (results.data == true) {
                          this.getMstMachineByOrdNoRst(this.selOrdNo).then(machineRes => {
                            const params = {
                              ordNo: this.selOrdNo, //オーダー番号
                              machineNo: machineRes.data[0].machineNo, //装置マスタ.装置番号
                              deviceEdgeNo: machineRes.data[0].deviceEdgeNo, //デバイスエッジ番号
                              facilityCd: this.facilityCd //施設コード
                            };
                            try {
                              this.sendRequestChangeIndMediInfoRst(params);
                            } catch (e) {
                              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
                              getErrorMessage('ScheduleAssignmentModalStore.js', 'setScheduleAssignment', '装置へ送信に失敗しました。');
                              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
                              this.$ons.notification.alert({
                                modifier: "warn",
                                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                                // title: "送信に失敗しました",
                                // message: `装置へ送信に失敗しました。`
                                title: DIALOG_MESSAGES['00200033'].title,
                                message: messageFormat(DIALOG_MESSAGES['00200033'].message),
                                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                              });
                            }
                          });
                        }
                      });
                    }
                    // add FNSI redmine 6706 劉祥霖 end
                  }
                });
                  }
              });
        // add FNSI-？？？？患者割り当て 陳 start
            }
              // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
            }
            // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
          }
        });
        // add FNSI-？？？？患者割り当て 陳 end




    },

    // add  FNSI-？？？？患者割り当て 陳 start
    getTreatmentRecordAuthority() {
      return this.hasAuthorityByCd(AUTHORITY_CODES.IND_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.IND_EDIT);
    },
    // add  FNSI-？？？？患者割り当て 陳 end

    async createDateList() {
      // リスト情報リセット
      /*this.indStartDate.selectedKur = [];
      this.indStartDate.kurOptions = [];
      this.indStartDate.selectedTreat = [];
      this.indStartDate.treatOptions = [];*/
      this.dataList = [];

    },
    // add FNSI redMine #5116 陳 start
    changeInterval() {

      this.$nextTick(function(){
        if(this.indStartDate !== ""){
          this.$refs.incluceMediTreatPlan.changeInterval();
        }
      });

    }
    // add FNSI redMine #5116 陳 end

  }
}
</script>

/** * スタイル定義 */
<style scoped>
.div-style {
  padding: 5px 10px;
}
.date-input {
  width: calc(100% - 32px);
  padding-right: 2px !important;
}
.cond-table-style {
  border-top: 0.5px solid #cccccc;
  border-bottom: 0.5px solid #cccccc;
}

.cond-row-style {
  padding: 5px 0px;
  font-size:1.0em;
}

.cond-title-style,
.cond-title-style-device-set {
  color: #fafafa;
  background-color: #333333;
  text-align: center;
  padding: 3px 5px 3px 0px;
  word-break: break-all;
}

.cond-sub-title-style {
  margin-left: 2em;
}

.cond-item-style {
  display: flex;
  flex-flow: column;
  align-content: center;
  text-align: center;
  word-break: break-all;
}

.cond-item-style > div {
  flex: 1;
}

.cond-item-style >>> .highcharts-container {
  margin: 0 auto;
}

.cond-td-style {
  border-bottom: 0.5px solid #cccccc;
  border-right: 0.5px solid #cccccc;
}

.cond-header-style {
  -webkit-writing-mode: vertical-lr;
  -ms-writing-mode: vertical-lr;
  writing-mode: vertical-lr;
  color: #fafafa;
  background-color: #333333;
  text-align: left;
  align-items: center;
  padding: 5px 2px 5px 2px;
}

.cond-item-main-style {
  display: grid;
}

.ons-row {
  height: auto;
}

.column-size {
  flex: 0 0 160px;
  max-width: 160px;
}

.comment-content {
  height: 100% !important;
}

.taboo-allergy {
  color: red;
}
.slot-style {
    padding: 5px 10px;
    overflow-y: auto;
    margin-bottom: 10px;
    height: calc(100vh - (220px + 8em));
}
.hr-style {
  margin: 0px 10px;
}
@media print {
  /** 文字折り返す */
  .indInfo-style-modal-container {
    white-space: normal !important;
    word-break: break-word;
  }
  .indInfo-style-label-position.header-info {
    flex: unset;
  }
}
</style>
