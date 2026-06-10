/**
 * 穿刺者/返血者/担当者情報アコーディオン内部
 */
<template>
  <div class="expandable-content">
    <div class="min-width-s">
      <v-ons-row class="user-name-1">
        <v-ons-col class="title">
          <label>{{ typeName }}者1</label>
        </v-ons-col>

        <v-ons-col class="value d-flex align-items-center">
         <custom-input
            class="user-sub-component-input"
            :value="userName1Value"
            :disabled="true"
          />
          <com-master-selector
            name="personal-user-all"
            :value="createValue1"
            :showLabelName="false"
            :showClassFilter="true"
            :readMasterData="fetchPersonalUserAll"
            :masterDefine="personalUserDefine"
            @changePersonalUser="setUser1"
            :isDisabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
            :class="['isClass']"
          />
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="user-name-2">
        <v-ons-col class="title">
          <label>{{ typeName }}者2</label>
        </v-ons-col>

        <v-ons-col class="value d-flex align-items-center">
          <custom-input
            class="user-sub-component-input"
            :value="userName2Value"
            :disabled="true"
          />
          <com-master-selector
            name="personal-user-all"
            :value="createValue2"
            :showLabelName="false"
            :showClassFilter="true"
            :readMasterData="fetchPersonalUserAll"
            :masterDefine="personalUserDefine"
            @changePersonalUser="setUser2"
            :class="['isClass']"
            :isDisabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
          />
        </v-ons-col>
      </v-ons-row>

      <v-ons-row v-if="showDate" class="input-time">
        <v-ons-col class="title">
          <label>{{ typeName }}日時</label>
        </v-ons-col>

        <v-ons-col colspan="2" class="value">
          <div>
            <div style="display: flex; flex-wrap: nowrap; min-width: 16em;">
              <date-input
                :classes="'ntss-input-date ntss-control-size ' + timeClass('date')"
                model-event="change"
                :id="'input-date-' + id"
                v-model="dateObj.date"
                @handleClearInput="dateObj.date = null"
                name="input-date"
                :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
              />
              <common-calendar
                :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                v-model="dateObj.date" />
              <time-input
                :classes="inputClass('time')"
                model-event="change"
                input-id="input-time"
                v-model="dateObj.time"
                @handleClearInput="dateObj.time = null"
                name="input-time"
                :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end -->
              <!-- #5590 2023/04/23 ×を常に表示するように修正 張博 end -->
              <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
              <p
                v-show="errors.has('input-time')"
                class="error-message"
              >{{ errors.first('input-time') }}</p>
            </div>
            <span class="error-message">{{ this.msgDiaLog }}</span>
          </div>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import {
  DATE_FORMAT,
  dateFormat,
} from "@/functions/common/DateTimeUtils.js";
import CommonMasterSelectorComponent from "@/components/common/master-selector/TreatmentRecordSelectorComponent";
import { sendRequestGetMstPersonalUser, sendRequestMstGetJobs } from "@/apis/user-selector-popover";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import moment from "moment";
import { personalUser } from "@/components/common/master-selector/MasterSelectorDefinitions";
import { mapGetters } from "vuex";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import DateInput from "@/components/common/DateInput.vue";
import TimeInput from "@/components/common/TimeInput.vue";

export default {
  components: {
    "common-calendar": commonCalender,
    "com-master-selector": CommonMasterSelectorComponent,
    "custom-input": customInput,
    "date-input":DateInput,
    "time-input":TimeInput
  },
  props: {
    typeName: {
      type: String
    },
    showDate: {
      type: Boolean
    },
    value: {
      type: Object
    },
    initValue: {
      type: Object
    },
    masterDefinition: {
      type: Object
    },
    id:{
      type: String
    }
  },
  data() {
    return {
      inputModel: {
        user_id_1: "",
        user_last_name_1: "",
        user_first_name_1: "",
        user_id_2: "",
        user_last_name_2: "",
        user_first_name_2: "",
        date: "",
        time: "",
        date_1: null,
        date_2: null
      },
      initData: {
        user_id_1: "",
        user_last_name_1: "",
        user_first_name_1: "",
        user_id_2: "",
        user_last_name_2: "",
        user_first_name_2: "",
        date: "",
        time: "",
        date_1: null,
        date_2: null
      },
      personalUserDefine: personalUser,
      msgDiaLog: null,
      userName1Value: {
        initValue: null,
        editValue: null
      },
      userName2Value: {
        initValue: null,
        editValue: null
      },
      hasTreatmentRecordAuthority: false,
      dateObj: {
        date: null,
        time: null
      }
    };
  },
  watch: {
    value(val) {
      Object.assign(this.inputModel, val);
      if (this.showDate && val !== null) {
        this.dateObj = this.validateDateTime(val.date)
      }
      this.inputModel.user_last_name_1 = this.inputModel.user_last_name_1 || null;
      this.inputModel.user_first_name_1 = this.inputModel.user_first_name_1 || null;
      this.inputModel.date_1 = this.inputModel.date_1 || null;
      this.inputModel.user_last_name_2 = this.inputModel.user_last_name_2 || null;
      this.inputModel.user_first_name_2 = this.inputModel.user_first_name_2 || null;
      this.inputModel.date_2 = this.inputModel.date_2 || null;
    },
    initValue: {
      handler(val) {
        this.initData.date = val.date ? this.validateDateTime(val.date)?.date : null;
        this.initData.time = val.date ? this.validateDateTime(val.date)?.time : null;
        let userName1;
        if (this.inputModel.user_last_name_1) {
          userName1 = `${this.inputModel.user_last_name_1} `;
        }
        if (this.inputModel.user_first_name_1) {
          userName1 = userName1 + `${this.inputModel.user_first_name_1}`;
        }
        let userName2;
        if (this.inputModel.user_last_name_2) {
          userName2 = `${this.inputModel.user_last_name_2} `;
        }
        if (this.inputModel.user_first_name_2) {
          userName2 = userName2 + `${this.inputModel.user_first_name_2}`;
        }

        this.userName1Value.initValue = userName1 ? userName1 : null;
        this.userName1Value.editValue = userName1 ? userName1 : null;

        this.userName2Value.initValue = userName2 ? userName2 : null;
        this.userName2Value.editValue = userName2 ? userName2 : null;
      },
      // immediate: true
    },
    inputModel: {
      handler(newVal) {
        const value = {
          user_id_1: newVal.user_id_1,
          user_last_name_1: newVal.user_last_name_1,
          user_first_name_1: newVal.user_first_name_1,
          user_id_2: newVal.user_id_2,
          user_last_name_2: newVal.user_last_name_2,
          user_first_name_2: newVal.user_first_name_2,
          date_1: newVal.date_1,
          date_2: newVal.date_2
        };
        if (this.showDate) {
          value.date = newVal.date;
        }
        this.$emit("input", value);
      },
      deep: true
    },
    dateObj: {
      handler(obj) {
        if (obj.date && obj.time) {
          this.inputModel.date = dateFormat.utc2Jst(`${obj.date} ${obj.time}`);
        } else if (!obj.date && !obj.time) {
          this.inputModel.date = null;
        } else {
          this.inputModel.date = (obj.date || obj.time)?.replaceAll('-', '/');
        }
      },
      deep: true
    }
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    // add FNSI-共有設定の追加 周雨晴 start
    ...mapGetters("treatment-record/common", [
      "getOrd",
      "getSharedFacilityCd",
      "getOrdNo"
    ]),

    ...mapGetters("user", ["getFacilityCd"]),
    // add FNSI-共有設定の追加 周雨晴 end

    // add 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm start
    ...mapGetters("account-edit", {userInfo: "getStateUserAccountInfo"}),
    // add 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm end
    userName1() {
      let userName;
      if (this.inputModel.user_last_name_1) {
        userName = `${this.inputModel.user_last_name_1} `;
      }
      if (this.inputModel.user_first_name_1) {
        userName = userName + `${this.inputModel.user_first_name_1}`;
      }
      return userName;
    },
    userName2() {
      let userName;
      if (this.inputModel.user_last_name_2) {
        userName = `${this.inputModel.user_last_name_2} `;
      }
      if (this.inputModel.user_first_name_2) {
        userName = userName + `${this.inputModel.user_first_name_2}`;
      }
      return userName;
    },
    createValue1() {
      return {
        // mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm start
        // cd: this.inputModel.user_id_1
        cd: null == this.inputModel.user_id_1 || "" === this.inputModel.user_id_1 ? this.userInfo.userId : this.inputModel.user_id_1
        // mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm end
      };
    },
    createValue2() {
      return {
        // mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm start
        // cd: this.inputModel.user_id_2
        cd: null == this.inputModel.user_id_2 || "" === this.inputModel.user_id_2 ? this.userInfo.userId : this.inputModel.user_id_2
        // mod 11778 【因島】実績の穿刺者や返血者の選択ダイアログでログイン者が選択されていない zkm end
      };
    },
    // add FNSI-共有設定の追加 周雨晴 start
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    // del #10359 編集権限の動作不正 dengshen start
    // getTreatmentRecordAuthority() {
    //   const userAuthorityCds = this.getUserAuthorityCds();
    //   return userAuthorityCds.includes(AUTHORITY_CODES.RST_PEDIT) || userAuthorityCds.includes(AUTHORITY_CODES.RST_EDIT);
    // },
    // del #10359 編集権限の動作不正 dengshen end
    // add FNSI-共有設定の追加 周雨晴 end
  },
  methods: {
    validateDateTime(input) {
      const isoFormat = 'YYYY-MM-DDTHH:mm:ss.SSSZ';
      if (moment(input, isoFormat, true).isValid()) {
          return {
            // type: 'ISO 8601',
            date: dateFormat.format(new Date(input), DATE_FORMAT),
            time: moment(input).format("HH:mm")
          };
      }

      if (moment(input, "YYYY-MM-DD", true).isValid() || moment(input, "YYYY/MM/DD", true).isValid()) {
          return {
            // type: 'Date',
            date: dateFormat.format(new Date(input), DATE_FORMAT),
            time: null
          };
      }

      if (moment(input, "HH:mm", true).isValid()) {
          return {
            // type: 'Time',
            date: null,
            time: moment(input, "HH:mm").format("HH:mm")
          };
      }
      return {
        date: null,
        time: null
      }
    },
    // del #10359 編集権限の動作不正 dengshen start
    // ...mapGetters("user", ["getUserAuthorityCds"]),
    // del #10359 編集権限の動作不正 dengshen end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    fetchPersonalUserAll() {
      return Promise.all([sendRequestGetMstPersonalUser(this.facilityCd), sendRequestMstGetJobs(this.facilityCd)]);
    },
    setUser1(userInfo) {
      this.inputModel.user_id_1 = userInfo ? userInfo.id : null;
      this.inputModel.user_last_name_1 = userInfo ? userInfo.lastName : null;
      this.inputModel.user_first_name_1 = userInfo ? userInfo.firstName : null;
      this.inputModel.date_1 = userInfo ? moment().toDate() : null;
      // FNSI-add redmine4824 徐 start
      this.userName1Value.editValue = this.userName1 ? this.userName1 : null;
      // FNSI-add redmine4824 徐 end
    },
    setUser2(userInfo) {
      this.inputModel.user_id_2 = userInfo ? userInfo.id : null;
      this.inputModel.user_last_name_2 = userInfo ? userInfo.lastName : null;
      this.inputModel.user_first_name_2 = userInfo ? userInfo.firstName : null;
      this.inputModel.date_2 = userInfo ? moment().toDate() : null;
      // FNSI-add redmine4824 徐 start
      this.userName2Value.editValue = this.userName2 ? this.userName2 : null;
      // FNSI-add redmine4824 徐 end
    },
    inputClass(element){
      if (this.initData[element] == null && this.dateObj[element] == "") {
        return "";
      } else if (this.initData[element] != this.dateObj[element]) {
        return "custom-input-edited";
      } else {
        return "";
      }
    },
    timeClass(element){
      if (this.initData[element] == null && this.dateObj[element] == "") {
        return "";
      } else if (this.initData[element] != this.dateObj[element]) {
        return "time-input-edited";
      } else {
        return "";
      }
    }
  }
};
</script>

<style scoped>
label {
  color: var(--treatment-record-text-color);
}
.select {
  width: 6em;
}
.error-message {
  white-space: nowrap;
}
.custom-input-edited >>> input {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
.time-input-edited {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
/* mod FutreNetWeb+SI課題管理 no.5531 劉全航 start */
/* add FNSI-redmine3855 徐 start */
/* .isClass {
  margin-left:5px;
  width: 5.0rem;
} */
/* add FNSI-redmine3855 徐 end */
/* mod FutreNetWeb+SI課題管理 no.5531 劉全航 end */
.expandable-content {
  overflow: auto;
  /* mod FutreNetWeb+SI課題管理 no.5531 劉全航 start */
  align-self:baseline;
  /* mod FutreNetWeb+SI課題管理 no.5531 劉全航 end */
  padding: 0.2em 0px 0.2em 0;
}
.user-sub-component-input {
  min-width: 11em;
}
</style>
