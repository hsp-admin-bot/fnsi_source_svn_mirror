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
          <common-master-selector
            :masterType="MasterType.PERSONAL_USER_TREATMENT_RECORD"
            :facilityCd="facilityCd"
            :initItem="pickerInitItem1"
            :editItem="pickerEditItem1"
            :selectedItemClass="'selector-input'"
            :backgroundColor="'#f7f7f7'"
            :btnClass="'com-basic-sub-btn'"
            :hasUnregisteredOption="true"
            :btnDisabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
            @popover-return="onPopoverUser1"
          />
        </v-ons-col>
      </v-ons-row>

      <v-ons-row class="user-name-2">
        <v-ons-col class="title">
          <label>{{ typeName }}者2</label>
        </v-ons-col>

        <v-ons-col class="value d-flex align-items-center">
          <common-master-selector
            :masterType="MasterType.PERSONAL_USER_TREATMENT_RECORD"
            :facilityCd="facilityCd"
            :initItem="pickerInitItem2"
            :editItem="pickerEditItem2"
            :selectedItemClass="'selector-input'"
            :backgroundColor="'#f7f7f7'"
            :btnClass="'com-basic-sub-btn'"
            :hasUnregisteredOption="true"
            :btnDisabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
            @popover-return="onPopoverUser2"
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
                :model-value="dateObj.date"
                @update:model-value="setDateObjValue('date', $event)"
                @input="setDateObjValue('date', $event)"
                @handleClearInput="setDateObjValue('date', null)"
                name="input-date"
                :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
              />
              <common-calendar
                :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
                :model-value="dateObj.date"
                @update:model-value="setDateObjValue('date', $event)"
                @input="setDateObjValue('date', $event)" />
              <time-input
                :classes="inputClass('time')"
                model-event="change"
                input-id="input-time"
                :model-value="dateObj.time"
                @update:model-value="setDateObjValue('time', $event)"
                @input="setDateObjValue('time', $event)"
                @handleClearInput="setDateObjValue('time', null)"
                name="input-time"
                :disabled="!isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end -->
              <!-- #5590 2023/04/23 ×を常に表示するように修正 張博 end -->
              <!--- add FNSI-共有設定の追加 周雨晴 2020/09/21 end -->
              <p
                v-show="hasValidationError('input-time')"
                class="error-message"
              >{{ getValidationError('input-time') }}</p>
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
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import dayjs from "@/compat/date/dayjs";
import { mapGetters } from "@/compat/vue/vuex";
import DateInput from "@/components/common/DateInput.vue";
import TimeInput from "@/components/common/TimeInput.vue";
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";

export default {
  components: {
    "common-calendar": commonCalender,
    "date-input":DateInput,
    "time-input":TimeInput,
    "common-master-selector": commonMasterSelector
  },
  // 親 ResultComponent が `:value` / `@input` の明示バインディングで使用しているため
  // Vue2 と同じ props/event 形式を維持する。
  emits: ["input"],
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
      },
      isSyncingValueFromParent: false
    };
  },
  watch: {
    value(val) {
      this.isSyncingValueFromParent = true;
      try {
        if (val !== null && val !== undefined) {
          Object.keys(val).forEach((key) => {
            this.setInputModelValue(key, val[key]);
          });
        }
        if (this.showDate && val !== null) {
          this.setDateObjIfChanged(this.validateDateTime(val?.date));
        }
        this.setInputModelValue("user_last_name_1", this.inputModel.user_last_name_1 || null);
        this.setInputModelValue("user_first_name_1", this.inputModel.user_first_name_1 || null);
        this.setInputModelValue("date_1", this.inputModel.date_1 || null);
        this.setInputModelValue("user_last_name_2", this.inputModel.user_last_name_2 || null);
        this.setInputModelValue("user_first_name_2", this.inputModel.user_first_name_2 || null);
        this.setInputModelValue("date_2", this.inputModel.date_2 || null);
      } finally {
        this.$nextTick(() => {
          this.isSyncingValueFromParent = false;
        });
      }
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
        if (this.isSyncingValueFromParent) {
          return;
        }
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
        if (this.isSameUserSubValue(value, this.value)) {
          return;
        }
        this.$emit("input", value);
      },
      deep: true
    },
    dateObj: {
      handler(obj) {
        this.setInputModelValue("date", this.composeDateTimeValue(obj));
      },
      deep: true
    }
  },
  computed: {
    MasterType() {
      return MasterType;
    },
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
    effectiveUserId1() {
      return this.nullOrEmpty(this.inputModel.user_id_1)
        ? this.userInfo.userId
        : this.inputModel.user_id_1;
    },
    effectiveUserId2() {
      return this.nullOrEmpty(this.inputModel.user_id_2)
        ? this.userInfo.userId
        : this.inputModel.user_id_2;
    },
    pickerInitItem1() {
      const text =
        this.userName1Value.initValue != null
          ? this.userName1Value.initValue
          : (this.userName1 || "");
      return {
        value: this.effectiveUserId1,
        text: text || ""
      };
    },
    pickerEditItem1() {
      const text =
        this.userName1Value.editValue != null
          ? this.userName1Value.editValue
          : (this.userName1 || "");
      return {
        value: this.effectiveUserId1,
        text: text || ""
      };
    },
    pickerInitItem2() {
      const text =
        this.userName2Value.initValue != null
          ? this.userName2Value.initValue
          : (this.userName2 || "");
      return {
        value: this.effectiveUserId2,
        text: text || ""
      };
    },
    pickerEditItem2() {
      const text =
        this.userName2Value.editValue != null
          ? this.userName2Value.editValue
          : (this.userName2 || "");
      return {
        value: this.effectiveUserId2,
        text: text || ""
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
    nullOrEmpty(v) {
      return v == null || v === "";
    },
    setDateObjValue(key, value) {
      const normalizedValue = key === "date" ? this.normalizeDatePart(value) : this.normalizeTimePart(value);
      if (this.isSameValue(this.dateObj[key], normalizedValue)) {
        return;
      }
      this.dateObj[key] = normalizedValue;
    },
    composeDateTimeValue(obj) {
      const datePart = this.normalizeDatePart(obj?.date);
      const timePart = this.normalizeTimePart(obj?.time);
      if (datePart && timePart) {
        const composed = dayjs(`${datePart} ${timePart}`, "YYYY-MM-DD HH:mm", true);
        return composed.isValid() ? composed.format("YYYY-MM-DDTHH:mm:ss.SSS+09:00") : null;
      }
      if (!datePart && !timePart) {
        return null;
      }
      return datePart ? datePart.replaceAll("-", "/") : timePart;
    },
    normalizeDatePart(value) {
      if (value === null || value === undefined || value === "") {
        return null;
      }
      if (value instanceof Date) {
        return Number.isNaN(value.getTime()) ? null : dayjs(value).format("YYYY-MM-DD");
      }
      const text = `${value}`.trim();
      if (!text) {
        return null;
      }
      const parsed = dayjs(text, ["YYYY-MM-DD", "YYYY/MM/DD", "YYYYMMDD"], true);
      if (parsed.isValid()) {
        return parsed.format("YYYY-MM-DD");
      }
      const looseParsed = dayjs(text);
      return looseParsed.isValid() ? looseParsed.format("YYYY-MM-DD") : null;
    },
    normalizeTimePart(value) {
      if (value === null || value === undefined || value === "") {
        return null;
      }
      const text = `${value}`.trim();
      if (!text) {
        return null;
      }
      const parsed = dayjs(text, ["HH:mm", "HH:mm:ss"], true);
      return parsed.isValid() ? parsed.format("HH:mm") : null;
    },
    setInputModelValue(key, value) {
      if (this.isSameValue(this.inputModel[key], value)) {
        return;
      }
      this.inputModel[key] = value;
    },
    setDateObjIfChanged(nextDateObj) {
      const normalizedDateObj = {
        date: this.normalizeDatePart(nextDateObj?.date),
        time: this.normalizeTimePart(nextDateObj?.time)
      };
      if (this.isSameValue(this.dateObj.date, normalizedDateObj.date) && this.isSameValue(this.dateObj.time, normalizedDateObj.time)) {
        return;
      }
      this.dateObj = normalizedDateObj;
    },
    isSameUserSubValue(left, right) {
      if (left === right) {
        return true;
      }
      if (!left || !right) {
        return false;
      }
      const keys = [
        "user_id_1",
        "user_last_name_1",
        "user_first_name_1",
        "user_id_2",
        "user_last_name_2",
        "user_first_name_2",
        "date_1",
        "date_2",
        "date"
      ];
      return keys.every((key) => this.isSameValue(left[key], right[key]));
    },
    isSameValue(left, right) {
      if (left === right) {
        return true;
      }
      if (left == null && right == null) {
        return true;
      }
      if (left instanceof Date && right instanceof Date) {
        return left.getTime() === right.getTime();
      }
      const leftDate = this.normalizeComparableDate(left);
      const rightDate = this.normalizeComparableDate(right);
      if (leftDate !== null || rightDate !== null) {
        return leftDate === rightDate;
      }
      return false;
    },
    normalizeComparableDate(value) {
      if (value === null || value === undefined || value === "") {
        return null;
      }
      if (value instanceof Date) {
        const time = value.getTime();
        return Number.isNaN(time) ? null : time;
      }
      if (typeof value === "string") {
        const parsed = dayjs(value);
        return parsed.isValid() ? parsed.valueOf() : null;
      }
      return null;
    },
    validateDateTime(input) {
      if (input === null || input === undefined || input === "") {
        return { date: null, time: null };
      }

      const isoFormat = 'YYYY-MM-DDTHH:mm:ss.SSSZ';
      const isoDateTime = dayjs(input, isoFormat, true);
      if (isoDateTime.isValid()) {
          return {
            // type: 'ISO 8601',
            date: isoDateTime.format("YYYY-MM-DD"),
            time: isoDateTime.format("HH:mm")
          };
      }

      const date = this.normalizeDatePart(input);
      if (date && !this.normalizeTimePart(input)) {
          return {
            // type: 'Date',
            date,
            time: null
          };
      }

      const time = this.normalizeTimePart(input);
      if (time) {
          return {
            // type: 'Time',
            date: null,
            time
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

    onPopoverUser1(item) {
      this.applyPopoverUser(item, "1");
    },
    onPopoverUser2(item) {
      this.applyPopoverUser(item, "2");
    },
    applyPopoverUser(item, slot) {
      if (!item) {
        return;
      }
      const uid = item.value != null ? item.value : item.key_cd ?? item.userId;
      if (uid == null || uid === "") {
        if (slot === "1") {
          this.inputModel.user_id_1 = null;
          this.inputModel.user_last_name_1 = null;
          this.inputModel.user_first_name_1 = null;
          this.inputModel.date_1 = null;
          this.userName1Value.editValue = null;
        } else {
          this.inputModel.user_id_2 = null;
          this.inputModel.user_last_name_2 = null;
          this.inputModel.user_first_name_2 = null;
          this.inputModel.date_2 = null;
          this.userName2Value.editValue = null;
        }
        return;
      }
      const lastName = item.userLastName != null ? item.userLastName : null;
      const firstName = item.userFirstName != null ? item.userFirstName : null;
      if (slot === "1") {
        this.inputModel.user_id_1 = uid;
        this.inputModel.user_last_name_1 = lastName;
        this.inputModel.user_first_name_1 = firstName;
        this.inputModel.date_1 = dayjs().toDate();
        this.userName1Value.editValue = this.userName1 ? this.userName1 : null;
      } else {
        this.inputModel.user_id_2 = uid;
        this.inputModel.user_last_name_2 = lastName;
        this.inputModel.user_first_name_2 = firstName;
        this.inputModel.date_2 = dayjs().toDate();
        this.userName2Value.editValue = this.userName2 ? this.userName2 : null;
      }
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
.custom-input-edited :deep(input) {
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
