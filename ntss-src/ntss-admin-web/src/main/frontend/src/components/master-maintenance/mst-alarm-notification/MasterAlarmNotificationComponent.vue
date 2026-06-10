/**
 * マスタメンテナンス 警報通知マスタ（メインコンポーネント）
 */
<template>
  <div id="alarm-notification-modal-content">
    <div class="facility-and-group-wrapper">
      <div v-if="isAdminUser">
        <v-ons-row>
          <v-ons-col class="header-input-label">
            <label for="facility-cd">対象施設</label>
          </v-ons-col>
          <v-ons-col class="header-input">
            <v-ons-select
              class="selectbox"
              select-id="facility-cd"
              v-model="inputModel.facility_cd"
              name="facility-cd"
              :disabled="existSendFacilityCd">
              <option v-for="(item, index) in comboList.facility" :key="index" :value="item.facilityCd">{{ item.facilityName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
      </div>
      <div class="header-input-alarm-name-wrapper">
        <v-ons-row>
          <v-ons-col class="header-input-label">
            <label for="alarm-name">警報通知名</label>
          </v-ons-col>
          <v-ons-col class="header-input">
            <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start-->
            <!-- <v-ons-input type="text" input-id="alarm-name" v-model="inputModel.alarm_name" @change="changeName()"></v-ons-input> -->
            <v-ons-input type="text" input-id="alarm-name" v-model="inputModel.alarm_name"></v-ons-input>
            <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end-->
          </v-ons-col>
        </v-ons-row>
      </div>
      <div>
        <v-ons-row>
          <v-ons-col class="header-input-label">
            <label for="group-cd">送信先</label>
          </v-ons-col>
          <v-ons-col class="header-input">
            <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start-->
            <!-- <v-ons-select
              class="selectbox"
              select-id="group-cd"
              v-model="inputModel.group_cd"
              @change="changeGroup()"
              name="group-cd"> -->
              <v-ons-select
              class="selectbox"
              select-id="group-cd"
              v-model="inputModel.group_cd"
              name="group-cd">
             <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end-->
              <option v-for="(item, index) in comboList.group" :key="index" :value="item.cd"  :hidden="item.hidden" :disabled="item.hidden">{{ item.text }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
      </div>
      <div >
        <v-ons-row>
          <v-ons-col class="header-input-label">
            <label for="alarm-sms-tel">SMS電話番号</label>
          </v-ons-col>
          <v-ons-col class="header-input header-input-sms">
            <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start-->
            <!-- <v-ons-input
              type="tel"
              class="input-sms custom-input-required"
              input-id="alarm-sms-tel"
              maxlength="12"
              pattern="^[0-9]*$"
              v-model="inputModel.sms_tel"
              @change="changeTel()"
              @input="setSmsTel($event.target.value)"
            /> -->
            <v-ons-input
              type="tel"
              class="input-sms custom-input-required"
              input-id="alarm-sms-tel"
              maxlength="12"
              pattern="^[0-9]*$"
              v-model="inputModel.sms_tel"
              @input="setSmsTel($event.target.value)"
            />
            <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end-->
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>

    <div id="schedule-table-wrapper">
      <table id="schedule-table">
        <tbody>
          <tr class="schedule-table-header schedule-table-body-row">
            <th class="schedule-table-header-day">曜日</th>
            <td>月</td>
            <td>火</td>
            <td>水</td>
            <td>木</td>
            <td>金</td>
            <td>土</td>
            <td>日</td>
          </tr>
          <tr class="schedule-table-body-row">
            <th>通知ON</th>
            <td v-for="(day, index) in days" :key="index">
              <div class="center">
                <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start-->
                <!-- <v-ons-checkbox
                  v-model="inputModel.schedule[day].isNoticeBool"
                  @change="changeSchedule()"
                /> -->
                <v-ons-checkbox
                  v-model="inputModel.schedule[day].isNoticeBool"
                />
              <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end-->
              </div>
            </td>
          </tr>
          <tr class="schedule-table-body-row">
            <th>開始時間</th>
            <td v-for="(day, index) in days" :key="index">
              <div>
                <div class="input-time-wrapper vertical-middle margin-left">
                   <!--   #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 start -->
                  <!-- <input class="time-input" type="time" @change="changeButton()" @keydown="onTimeKeyDown($event)" @blur="onTimeBlur($event)" :id="`startTime${day}`"
                    v-model="inputModel.schedule[day].startTime"
                  /> -->
                  <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start-->
                  <time-input :classes="'time-input ' +isEditedTime('startTime', day)" :width="6.5" :left="70" @keydown="onTimeKeyDown($event)" @blur="onTimeBlur($event)" :id="`startTime${day}`"
                    v-model="inputModel.schedule[day].startTime" @handleClearInput="inputModel.schedule[day].startTime = null"
                  />
                  <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end-->
                  <!--   #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 end -->
                </div>
              </div>
            </td>
          </tr>
          <tr class="schedule-table-body-row">
            <th>終了時間</th>
            <td v-for="(day, index) in days" :key="index">
              <div>
                <div class="vertical-middle next-day-checkbox-wrapper">
                  <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start-->
                  <!-- <input type="checkbox" @change="changeBool()" class="next-day-checkbox" :id="day" v-model="inputModel.schedule[day].isNextDayBool" /> -->
                  <input type="checkbox" class="next-day-checkbox" :id="day" v-model="inputModel.schedule[day].isNextDayBool" />
                  <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end-->
                  <label :for="day" class="next-day-label">翌</label>
                </div>
                <div class="input-time-wrapper vertical-middle">
                 <!--   #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 start -->
                  <!-- <input class="time-input" type="time" @change="changeButton()" @keydown="onTimeKeyDown($event)" @blur="onTimeBlur($event)" :id="`endTime${day}`"
                    v-model="inputModel.schedule[day].endTime"
                  /> -->
                  <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start-->
                  <time-input :classes="'time-input ' +isEditedTime('endTime', day)" :width="6.5" :left="70"  @keydown="onTimeKeyDown($event)" @blur="onTimeBlur($event)" :id="`endTime${day}`"
                    v-model="inputModel.schedule[day].endTime" @handleClearInput="inputModel.schedule[day].endTime = null"
                  />
                  <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end-->
                  <!-- #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 start -->
                </div>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 装置記録検索 -->
    <div class="machine-record-search-wrapper" id="machine-record-search-area">
      <machine-record-search :isNewRecord="isNewRecord"/>
    </div>
    <!-- 一覧 -->
    <div class="machine-record-list-wrapper">
      <table class="machine-list">
        <thead>
          <tr class="machine-list-header">
            <th width="5%" :style="topStyles">
              <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start-->
              <!-- <v-ons-checkbox
                :checked="allSelectFlg"
                @change="changeButton()"
                @click="onMachinesAllSelect" >
              </v-ons-checkbox> -->
              <v-ons-checkbox
                :checked="allSelectFlg"
                @click="onMachinesAllSelect" >
              </v-ons-checkbox>
              <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end-->
            </th>
            <!--mod 【試験T】【結合テスト】警報通知マスタ 20230703 zhaoqi start-->
            <th width="10%" :style="topStyles">ログメッセージコード</th>
            <!--mod 【試験T】【結合テスト】警報通知マスタ 20230703 zhaoqi end-->
            <th width="55%" :style="topStyles">装置記録</th>
            <th width="15%" :style="topStyles">ログ分類</th>
            <th width="15%" :style="topStyles">対象機種</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(machineRecord, index) in machineRecordList" :key="index" :class="index%2 === 0 ? 'even-row' : 'odd-row'">
            <td class='send-checkbox'>
              <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start-->
              <!-- <v-ons-checkbox @change="changeButton()" @click="onChange(machineRecord, $event)" v-model="machineRecord.beSendEmail" >
              </v-ons-checkbox> -->
              <v-ons-checkbox @click="onChange(machineRecord, $event)" v-model="machineRecord.beSendEmail" >
              </v-ons-checkbox>
              <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end-->
            </td>
            <td>{{ machineRecord.cd }}</td>
            <td>{{ machineRecord.message }}</td>
            <td>{{ machineRecord.logClassName }}</td>
            <td>{{ machineRecord.targetModelName }}</td>
          </tr>
          <tr></tr>
          <tr></tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import {EventBus} from "@/eventBus";
import { ApiHelper } from "@/apis/AxiosHelper";
import MachineRecordSearchComponent from "@/components/master-maintenance/mst-alarm-notification/MachineRecordSearchComponent";
import Schedule from "@/models/master-maintenance/mst-alarm-notification/Schedule";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
//#5590 2023/04/18 ×を常に表示するように修正 張博 start
import TimeInput from "@/components/common/TimeInput.vue";
//#5590 2023/04/18 ×を常に表示するように修正 張博 end
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start
import cloneDeep from "lodash/cloneDeep";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end
export default {
  name: "MstAlarmNotification",
  components: {
    "machine-record-search": MachineRecordSearchComponent,
//#5590 2023/04/18 ×を常に表示するように修正 張博 start
    TimeInput
//#5590 2023/04/18 ×を常に表示するように修正 張博 end
  },
  data() {
    return {
      machineRecordList: [],
      allSelectFlg: false,
      comboList: {
        facility: undefined,
        group: undefined
      },
      days: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
      inputModel: {
        facility_cd: "",
        alarm_name: "",
        group_cd: "",
        schedule: {
          Mon: new Schedule(),
          Tue: new Schedule(),
          Wed: new Schedule(),
          Thu: new Schedule(),
          Fri: new Schedule(),
          Sat: new Schedule(),
          Sun: new Schedule()
        },
        sms_tel: ""
      },
      existSendFacilityCd: false,
      allSelectFlgTransitionHandler: () => {},
      stickeyTop: 61,
      //mod マスタ詳細画面がありません破棄メッセージ
      initName:"",
      initGroup:"",
      initTel:"",
      initSchedule:{},
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/08 start
      editRecordDefault:{},
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/08 end
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      masterName: "getMasterName",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("mst-alarm-notification", {
      recordsByCondition: "recordsByCondition"
    }),
    ...mapGetters("account-edit", {
      accountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", {
      // isAdminUser: "isAdminUser",
      userIsAdminUser: "isAdminUser",
      userFacilityCd: "getFacilityCd"
    }),
    // add マスタ一覧 1･施設切替を可能とする 孔s start
    isAdminUser(){
      return this.userIsAdminUser && this.getFacilitySwitch === "nkknkk"
    },
    // add マスタ一覧 1･施設切替を可能とする 孔s end
    isNewRecord() {
      return this.editRecord["operation"] === 1;
    },
    topStyles() {
      // 一覧のヘッダtop位置をCSS変数を利用して書き換え
      return { "--top": `${this.stickeyTop}px` };
    }
  },
  watch: {
    inputModel: {
      handler(newVal) {
        this.editRecord["destinationFacilityCd"] = newVal.facility_cd;
        this.editRecord["name"] = newVal.alarm_name;
        this.editRecord["destinationGroupCd"] = newVal.group_cd;

        this.days.forEach(day => {
          this.editRecord[`isNotice${day}`] = newVal.schedule[
            day
          ].getIsNoticeBoolAsString();
          this.editRecord[`startTime${day}`] = newVal.schedule[day].startTime;
          this.editRecord[`endTime${day}`] = newVal.schedule[day].endTime;
          this.editRecord[`isNextDay${day}`] = newVal.schedule[
            day
          ].getIsNextDayBoolAsString();
        });
        this.editRecord["smsTel"] = newVal.sms_tel;
        this.setEditRecord(this.editRecord);
      },
      deep: true
    },
    allSelectFlg: {
      handler(newVal) {
        this.allSelectFlgTransitionHandler(newVal);
      }
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start
    editRecord: {
      handler(val) {
        const newVal = JSON.parse(JSON.stringify(val));
        if (this.editRecordDefault) {
          EventBus.$emit("mstHolidayRegistered", this.compareObjects(this.editRecordDefault, newVal));
        }
      },
      deep: true
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("reference-combo", ["getDestinationGroupComboList","getDestinationGroupComboListByFacilityCd"]),
    ...mapActions("mst-alarm-notification", [
      "fetchStaffFacilities",
      "fetchAllRecords",
      "findGroupName",
      "conditionsClear",
      "saveRecord",
      "setCollectMachineRecords",
      "setConditionOnlySendEmail",
      "setConditionIsDefault"
    ]),
    // 5400 警報通知マスタ詳細の表示が遅い 鞠 start
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible"
    }),
    // 5400 警報通知マスタ詳細の表示が遅い 鞠 end
    /**
     * Stickyな一覧のヘッダのtop位置を計算する
     */
    calculateStickyTop() {
      const height = document.getElementById("machine-record-search-area").clientHeight;
      this.stickeyTop = height - 1;
    },
    // 「全選択」チェックボックス押下時の処理
    // allSelectFlgの状態変化時の処理を上書きする
    onMachinesAllSelect() {
      this.allSelectFlgTransitionHandler = newVal => {
        // 装置記録の全選択・全選択解除
        const notification = {
          cds: []
        };
        // 全選択時はすべての機器を追加
        for (let i = 0; i < this.machineRecordList.length; i++) {
          if (newVal) {
            const machineRecord = {
              machine_record_cd: this.machineRecordList[i].cd
            };
            notification.cds.push(machineRecord);
          }
          this.machineRecordList[i].beSendEmail = newVal;
        }
        this.editRecord["targetMachineRecord"] = JSON.stringify(notification);
        this.setEditRecord(this.editRecord);
      };
      this.allSelectFlg = !this.allSelectFlg;
    },
    // 装置記録一覧のチェックボックス押下時の処理
    // allSelectFlgの状態変化時の処理を上書きする
    onChange(machineRecord, ev) {
      this.allSelectFlgTransitionHandler = () => {
        // 何もしない
        return;
      };
      this.allSelectFlg = false;
      // ストアの更新
      machineRecord.beSendEmail = ev.target.checked;
      this.saveRecord(machineRecord);

      // 装置記録リストからチェック押下された装置記録を削除
      const notification = this.convertToDestinationJson();
      const recordIndex = notification.cds.findIndex(
        _record => _record.machine_record_cd === machineRecord.cd
      );
      if (recordIndex !== -1) {
        notification.cds.splice(recordIndex, 1);
      }

      // 送信対象なら装置記録リストに追加する
      if (machineRecord.beSendEmail) {
        const record = {
          machine_record_cd: machineRecord.cd
        };
        notification.cds.push(record);
      }
      this.editRecord["targetMachineRecord"] = JSON.stringify(notification);
      this.setEditRecord(this.editRecord);
    },
    onTimeBlur(ev) {
      // iOSでCommonTimeInputComponentがうまく表示できなかった
      // しかし、同等の振る舞いを持たせたかったのでこのコンポーネントに同等の処理を実装した
      if (ev && !ev.target.value) {
        // 入力不備がある場合、未入力状態にする
        const timeControl = this.$el.querySelector(`#${ev.target.id}`);
        timeControl.value = null;
      }
      //mod マスタ詳細画面がありません破棄メッセージ
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start
      // if (JSON.stringify(this.initSchedule)!==JSON.stringify(this.inputModel.schedule)) {
      //   this.changeButton();
      // }else{
      //   EventBus.$emit("mstHolidayRegistered", true);
      // }
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end
    },
    /**
     * @description 全角入力時にフォーカスを戻す
     */
    onTimeKeyDown(ev) {
      if(ev.keyCode === 229){
        setTimeout(() => ev.target.focus(), 5);
      }
    },
    setSmsTel (value) {
      if(value === "" || !isNaN(Number(value)) && document.getElementsByClassName("custom-input-invalid")[0])
      document.getElementsByClassName("custom-input-invalid")[0].classList.remove("custom-input-invalid");
    },
    mappingToSendMachine() {
      const notification = this.convertToDestinationJson();
      let tmpMachineRecord = [];

      for (let i = 0; i < this.machineRecordList.length; i++) {
        let machineRecord = this.machineRecordList[i];
        const index = notification.cds.findIndex(
          u => u.machine_record_cd === machineRecord.cd
        );
        if (index !== -1) {
          machineRecord.beSendEmail = true;
          tmpMachineRecord.push(machineRecord);
        }
      }
      this.setCollectMachineRecords(tmpMachineRecord);
    },
    convertToDestinationJson() {
      const emptyMachineRecord = {
        cds: []
      };
      const notification =
        this.editRecord["targetMachineRecord"] ||
        JSON.stringify(emptyMachineRecord);
      return JSON.parse(notification);
    },
    getValueByField(field) {
      return this.editRecord[field];
    },
    updateEditRecord(key, ev) {
      this.editRecord[key] = ev.target.value;
      this.setEditRecord(this.editRecord);
    },
    destinationComboListMatching(cd, text) {
      const list = this.comboList.group;
      const node = list.find(elem => elem.cd === cd);
      // 削除なしの場合は何もしない
      if (node !== undefined && node.text === text) {
        return;
      }
      list.unshift({ cd: cd, text: text, hidden: true });
    },
    setMachineRecordList() {
      this.machineRecordList = this.recordsByCondition;
    },
    validateSchedule() {
      // 通知ONにチェックがついている曜日
      // 必須チェックの対象となる曜日を取得
      const noticeDays = this.days.filter(day => {
        return this.inputModel.schedule[day].isNoticeBool;
      });

      // 通知ONにチェックがついている、かつ開始時間と終了時間がどっちも空 or どっちも入力されている曜日
      // 大小チェックの対象となる曜日を取得
      const hasStartTimeAndEndTimeDays = noticeDays.filter(day => {
        return this.inputModel.schedule[day].hasStartTimeAndEndTime();
      });

      // SMS通知先電話番号が数値のみであるチェック
      const isSmsTelValid = this.inputModel.sms_tel === "" || !isNaN(Number(this.inputModel.sms_tel));

      return {
        required: noticeDays.every(day =>
          this.inputModel.schedule[day].hasStartTimeAndEndTime()
        ),
        correctRange: hasStartTimeAndEndTimeDays.every(day =>
          this.inputModel.schedule[day].isStartTimeSameOrBeforeThanEndTime()
        ),
        smsTelValid: isSmsTelValid
      };
    },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start
     //[確認]ボタンの状態の変更をトリガーします
    // changeButton() {
    //   EventBus.$emit("mstHolidayRegistered", false);
    // },
    //mod マスタ詳細画面がありません破棄メッセージ
    // changeName(){
    //  if (this.inputModel.alarm_name!==this.initName) {
    //   this.changeButton();
    //  }else{
    //   EventBus.$emit("mstHolidayRegistered", true);
    //  }
    // },
    // changeGroup(){
    //  if (this.inputModel.group_cd!==this.initGroup) {
    //   this.changeButton();
    //  }else{
    //   EventBus.$emit("mstHolidayRegistered", true);
    //  }
    // },
    // changeTel(){
    //  if (this.inputModel.sms_tel!==this.initTel) {
    //   this.changeButton();
    //  }else{
    //   EventBus.$emit("mstHolidayRegistered", true);
    //  }
    // },
    // changeSchedule(){
    //   if (JSON.stringify(this.initSchedule)===JSON.stringify(this.inputModel.schedule)) {
    //     this.changeButton();
    //   }else{
    //     EventBus.$emit("mstHolidayRegistered", true);
    //   }
    // },
    // changeBool(){
    //   if (JSON.stringify(this.initSchedule)!==JSON.stringify(this.inputModel.schedule)) {
    //     this.changeButton();
    //   }else{
    //     EventBus.$emit("mstHolidayRegistered", true);
    //   }
    // },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end
    validateOnRegistration() {
      const validationResult = this.validateSchedule();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      if (!validationResult.smsTelValid) {
        document.getElementsByClassName("custom-input-required")[0]?.classList?.add("custom-input-invalid");
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES['00200039'].title;
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.required
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "時刻を指定する場合は開始/終了時間を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200039'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.correctRange
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "終了時間は開始時間より前に設定できません。"
              ? messageFormat(DIALOG_MESSAGES['00200040'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.smsTelValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "SMS通知先電話番号は数値のみで入力してください。"
              ? messageFormat(DIALOG_MESSAGES['00200041'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
    compareObjects(obj1, obj2) {
      if (this.isJSON(obj1)) {
        obj1 = JSON.parse(obj1)
      }
      if (this.isJSON(obj2)) {
        obj2 = JSON.parse(obj2)
      }

      // 基本型(文字列、数字など)の場合は、そのまま等価比較をします。
      if (!this.isObject(obj1)) {
        if (obj1 == "" && obj2 == null) {
          return true;
        }
        return obj1 == obj2;
      }

      // 1つ目のオブジェクトの属性名を全て取得します
      const keys = Object.keys(obj1);
      // 属性を横断して深さを比較します
      for (let key of keys) {
        if (key === "destinationFacilityCd") {
          continue;
        }
        if (key === 'cds') {
          obj1[key].sort((a, b) => a.machine_record_cd.localeCompare(b.machine_record_cd))
          if (obj2[key]) {
            obj2[key].sort((a, b) => a.machine_record_cd.localeCompare(b.machine_record_cd))
          } else {
            continue;
          }
          if (obj1[key].length !== obj2[key].length) {
            return false;
          }
        }
        if (!this.compareObjects(obj1[key], obj2[key])) {
          return false;
        }
      }
      return true;
    },

    isObject(value) {
      return value && typeof value === 'object';
    },
    isJSON(str) {
      try {
        JSON.parse(str);
        return true;
      } catch (e) {
        return false;
      }
    },
    // #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start
    isEditedTime(field, day) {
      let beforeVal = this.editRecordDefault[`${field}${day}`];
      let afterVal = this.editRecord[field + day];
      if (beforeVal != afterVal) {
        return "time-input-edited";
      }
      return "";
    },
  },
  async created() {
    // 5400 警報通知マスタ詳細の表示が遅い 鞠 start
    this.setLoadingScreenVisible(true);
    // 5400 警報通知マスタ詳細の表示が遅い 鞠 end
    if (typeof this.editRecord["targetMachineRecord"] === "undefined") {
      // 詳細を開いたタイミングで保持データが存在しない場合、データの取得を行う
      const param = {
        alarmNotificationCd: this.editRecord["code"]
      };
      const res = await ApiHelper.get("/mstInfo/mstAlarmNotification/detail", param).catch(
        error => {
          throw error;
        }
      );
      // 取得データをセット
      this.editRecord["destinationGroupCd"] = res.data["destinationGroupCd"];
      this.days.forEach(day => {
        this.editRecord[`isNotice${day}`] = res.data[`isNotice${day}`];
        this.editRecord[`startTime${day}`] = res.data[`startTime${day}`];
        this.editRecord[`endTime${day}`] = res.data[`endTime${day}`];
        this.editRecord[`isNextDay${day}`] = res.data[`isNextDay${day}`];
      });
      this.editRecord["smsTel"] = res.data["smsTel"];
      this.editRecord["targetMachineRecord"] = JSON.stringify(res.data["targetMachineRecord"]);
      this.setEditRecord(this.editRecord);
    }
    // 装置記録一覧をAPIで取得
    await this.fetchAllRecords({payload: this.convertToDestinationJson(),facility: this.getFacilitySwitch});

    // コンボリストをAPIで取得
    const groupCd = this.editRecord["destinationGroupCd"];
    const staffResponse = await this.fetchStaffFacilities(
      this.accountInfo.userId
    );
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // const groupResponse = await this.getDestinationGroupComboList();
    const groupResponse = await this.getDestinationGroupComboListByFacilityCd(this.getFacilitySwitch);
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
    let groupName = "";
    if (groupCd) {
      const groupNameResponse = await this.findGroupName(groupCd);
      groupName = groupNameResponse.data.name;
    }

    // 対象施設の設定
    this.comboList.facility = await staffResponse.data.staffFacilities.filter(
      f => f.isCharge
    );
    if (this.isAdminUser) {
      // 日機装ユーザーの場合
      // 既存行の場合、非活性にする
      const facilityCd = this.editRecord["destinationFacilityCd"];
      const operation = this.editRecord["operation"];
      // 新規以外で
      if (operation !== 1) {
        // 新規以外で対象施設に設定されてていた施設が、担当施設に含まれていない場合は追加する
        const includeFlg = this.comboList.facility.find((v) => v.facilityCd == facilityCd);
        if (!includeFlg) {
          const facilityObj = staffResponse.data.staffFacilities.find((v) => v.facilityCd == facilityCd);
          this.comboList.facility.push(facilityObj);
        }
      }
      this.inputModel.facility_cd = facilityCd;
      this.existSendFacilityCd = operation !== 1;
    } else {
      // 一般ユーザーの場合
      // mod マスタ一覧 1･施設切替を可能とする 孔s start
      // this.inputModel.facility_cd = this.userFacilityCd;
      this.inputModel.facility_cd = this.getFacilitySwitch;
      // mod マスタ一覧 1･施設切替を可能とする 孔s end
    }

    // 送信先グループの設定
    this.comboList.group = groupResponse.data;
    if (!this.comboList.group.length) {
      this.$ons.notification.alert({
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // title: "取得失敗",
        // message: "送信先が登録されていません。送信先を登録してください。",
        title: DIALOG_MESSAGES['00200042'].title,
        message: messageFormat(DIALOG_MESSAGES['00200042'].message),
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        callback: () => {
          // OKボタン押下でモーダルを閉じる
          this.$emit("closeMasterEditModal");
        }
      });
    }
    this.destinationComboListMatching(groupCd, groupName);
    this.inputModel.group_cd = groupCd;

    // 警報通知名の設定
    this.inputModel.alarm_name = this.editRecord["name"];

    // スケジュールの設定
    this.days.forEach(day => {
      this.inputModel.schedule[day] = new Schedule(
        this.editRecord[`isNotice${day}`] === ""
          ? undefined
          : this.editRecord[`isNotice${day}`],
        this.editRecord[`startTime${day}`] || undefined,
        this.editRecord[`endTime${day}`] || undefined,
        this.editRecord[`isNextDay${day}`] === ""
          ? undefined
          : this.editRecord[`isNextDay${day}`]
      );
    });

    // SMS通知先電話番号の設定
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/17 start
    this.inputModel.sms_tel = this.editRecord["smsTel"] ?  this.editRecord["smsTel"] : "";
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/17 end
    //mod マスタ詳細画面がありません破棄メッセージ
    this.initName = this.inputModel.alarm_name;
    this.initGroup = this.inputModel.group_cd;
    this.initTel = this.inputModel.sms_tel;
    this.initSchedule = JSON.parse(JSON.stringify(this.inputModel.schedule));
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/17 start
    this.inputModelDefault = cloneDeep(this.inputModel)
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/17 end
    // 装置記録の状態を設定
    this.setMachineRecordList();
    this.mappingToSendMachine();
    EventBus.$on("setMachineRecordList", this.setMachineRecordList);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 start
    this.$nextTick(()=>{
      this.editRecordDefault = cloneDeep(this.editRecord)
      this.editRecordDefault.targetMachineRecord = this.editRecordDefault.targetMachineRecord ? this.editRecordDefault.targetMachineRecord: JSON.stringify({ "cds":[] })
    })
    
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_警報通知マスタ 張玲 2024/01/05 end
    // 5400 警報通知マスタ詳細の表示が遅い 鞠 start
    this.setLoadingScreenVisible(false);
    // 5400 警報通知マスタ詳細の表示が遅い 鞠 end
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateStickyTop();
    });
     setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("setMachineRecordList", this.setMachineRecordList);
    this.conditionsClear();
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<style scoped>
#alarm-notification-modal-content {
  width: 100%;
  height: 100%;
  overflow-y: auto;
  overflow-x: hidden;
}
.header-input-label {
  width: 40%;
}
.header-input {
  width: 57%;
}
.header-input-alarm-name-wrapper >>> ons-input .text-input {
  font-size: 1.0em;
  height: 2em;
  min-height: 25px;
  width: 90%;
  padding-left: 4px;
}
.header-input-sms {
  display: flex;
  justify-content: flex-start;
}
.input-sms{
  max-width: 12em;
}
.input-sms .text-input{
  width: 100%!important;
}
.machine-record-search-wrapper {
  position: sticky;
  top: 0;
  z-index: 1;
}
table {
  border-collapse: collapse;
}
table th,
table td {
  border: solid 1px var(--ntss-list-border-color);
}
.machine-record-list-wrapper {
  z-index: 2;
}
table.machine-list {
  width: 100%;
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
  --top: 61px;
  top: var(--top);
  z-index: 1;
}
.custom-input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
table.machine-list thead tr {
  height: 33px;
}
table.machine-list tbody tr.even-row {
  background-color: var(---ntss-list-item-background-color);
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
  height: 2.5em;
  padding: 0 0.75rem;
}
.machine-record-list-wrapper tr:hover {
  background-color: var(--master-maintenance-kgrid-item-hover-background-color);
}
.selectbox {
  width: 90%;
  height: 2em;
  min-height: 31px;
  font-size: 1.0em;
  display: flex;
  align-items: center;
}
.selectbox >>> .select-input {
  font-size: 1.0em;
  line-height: unset;
}
#schedule-table-wrapper {
  width: 100%;
  overflow-x: auto;
  margin-bottom: 5px;
}
#schedule-table {
  table-layout: fixed;
  width: 75em;
}
.schedule-table-header {
  color: white;
  background-color: var(--ntss-list-header-background-color);
  height: 2em !important;
  background-image: -webkit-linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}
.schedule-table-header td {
  text-align: center;
}
.schedule-table-header-day {
  table-layout: fixed;
  width: 5em;
}
.schedule-table-body-row {
  height: 2.5em;
}
.schedule-table-body-row th {
  color: white;
  background-color: var(--ntss-list-header-background-color);
  z-index: 1;
  position: sticky;
  left: 0;
  font-weight: inherit;
}
.schedule-table-body-row td {
  padding: 0 0.5em;
}
.time-input {
  box-sizing: border-box;
  font: inherit;
  border: none;
  outline: none;
  letter-spacing: 0;
  box-shadow: none;
  color: #1f1f21;
  padding: 0;
  margin: 0;
  /* #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 start  */
  /* width: 5em; */
  width: 5.5em;
  /* #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 end  */
  min-width: 60px;
  font-size: 1.0em;
  font-weight: 400;
}
.input-time-wrapper {
  display: inline-block;
  padding: 0;
  color: #aaa;
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
  border-radius: 3px;
  -webkit-box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
  -moz-box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
  box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);

  position: relative;
}
.next-day-checkbox-wrapper {
  display: inline-block;
}
.next-day-checkbox {
  display: none;
}
.next-day-checkbox + label {
  /* ブロックレベル要素化する */
  display: inline-block;
  /* テキストのセンタリングを指定する */
  text-align: center;
  /* 行の高さを指定する */
  line-height: 2.1em;
  margin: 0 0.5em 0 0;
  width: 2.1em;
  border: solid 1px #cccccc;
  /* 角を丸くする */
  border-radius: 5px;
  /* 背景色を指定する */
  background-color: #fafafa;
  color: #cccccc;
}
.next-day-checkbox:checked + label {
  /* 背景色を指定する */
  background-color: #3B7FA3;
  color: #fafafa;
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
</style>
