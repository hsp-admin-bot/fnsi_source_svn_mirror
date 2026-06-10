<!-- デフォルト設定タブ - 患者情報共有のコンポーネント -->
<template>
  <v-ons-list style="height: auto" class="record-accordion">
    <v-ons-list-item
      modifier="nodivider"
      class="ntss-theme-screen"
      expandable
      :expanded.sync="isExpanded"
    >
      <div class="top">
        <div class="center card-header color-header">
          {{ funcName }}
        </div>
        <div class="right"></div>
      </div>
      <div class="expandable-content card-contents">
        <table>
          <tbody>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">
                  フリーワード
                </label>
              </td>
              <td class="default-setting-content">
                <v-ons-input
                  input-id="freeWord"
                  type="text"
                  v-model="freeWord"
                ></v-ons-input>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">性別</label>
              </td>
              <td class="default-setting-content">
                <v-ons-select v-model="gender" class="w-60">
                  <option
                    v-for="(option, index) in genderList"
                    :key="index"
                    :value="option.value"
                  >
                    {{ option.displayValue }}
                  </option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">血液型</label>
              </td>
              <td class="default-setting-content">
                <v-ons-select v-model="bloodType" class="w-60">
                  <option
                    v-for="(option, index) in bloodTypeList"
                    :key="index"
                    :value="option.value"
                  >
                    {{ option.displayValue }}
                  </option>
                </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">
                  生年月日開始
                </label>
              </td>
              <td class="default-setting-content">
                <date-input
                  id="birthdayFrom"
                  class="ntss-input-date ntss-control-size w-60"
                  v-model="birthdayFrom"
                  @handleClearInput="birthdayFrom = null"
                />
                <common-calendar v-model="birthdayFrom" />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">
                  生年月日終了
                </label>
              </td>
              <td class="default-setting-content">
                <date-input
                  id="birthdayTo"
                  class="ntss-input-date ntss-control-size w-60"
                  v-model="birthdayTo"
                  @handleClearInput="birthdayTo = null"
                />
                <common-calendar v-model="birthdayTo" />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">共有先施設</label>
              </td>
              <td class="default-setting-content">
                <common-search-select
                  v-model="facilityCdTo"
                  :items="getShrFacilityList"
                  text-field="text"
                  value-field="value"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">共有元施設</label>
              </td>
              <td class="default-setting-content">
                <common-search-select
                  v-model="facilityCdFrom"
                  :items="getShrFacilityList"
                  text-field="text"
                  value-field="value"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">共有先</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="isShowShareTo"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">共有元</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="isShowShareFrom"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">共有禁止</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="isShowShareRefuse"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">未完了</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-switch v-model="isShowShare"></v-ons-switch>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </v-ons-list-item>
  </v-ons-list>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import { PAT_INFO_SHARING } from "@/constants/defaultSettingConstants";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { EventBus } from "@/eventBus.js";
import {
  PAT_BLOOD_TYPE_ABO_OPTIONS,
  PAT_PERSONAL_MAIN_COL_PAT_SEX_OPTIONS,
} from "@/constants/PatInfo.js";
import DateInput from "@/components/common/DateInput.vue";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import CommonSearchSelect from "@/components/common/CommonSearchSelect.vue";

export default {
  components: {
    "common-calendar": commonCalender,
    "date-input": DateInput,
    "common-search-select": CommonSearchSelect,
  },
  props: {
    defaultExpanded: {
      type: Boolean,
      default: true,
    },
  },
  data() {
    return {
      funcName: "患者情報共有",
      initialValue: {},
      editRecord: {},
      isExpanded: false,
      genderList: [
        { label: "", value: null },
        ...PAT_PERSONAL_MAIN_COL_PAT_SEX_OPTIONS,
      ],
      bloodTypeList: [
        { label: "", value: null },
        ...PAT_BLOOD_TYPE_ABO_OPTIONS,
      ],
    };
  },
  methods: {
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    ...mapActions("pat-info-sharing", ["setShrFacilityList"]),
    getSaveData() {
      let rtnData = {
        name: PAT_INFO_SHARING.KEY_NAME,
        data: {},
      };
      rtnData.data[PAT_INFO_SHARING.KEY_NAME_FREEWORD] =
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_FREEWORD];
      rtnData.data[PAT_INFO_SHARING.KEY_NAME_GENDER] =
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_GENDER];
      rtnData.data[PAT_INFO_SHARING.KEY_NAME_BLOODTYPE] =
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_BLOODTYPE];
      rtnData.data[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_FROM] =
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_FROM];
      rtnData.data[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_TO] =
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_TO];
      rtnData.data[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_TO] =
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_TO];
      rtnData.data[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_FROM] =
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_FROM];
      rtnData.data[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_TO] =
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_TO];
      rtnData.data[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_FROM] =
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_FROM];
      rtnData.data[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_REFUSE] =
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_REFUSE];
      rtnData.data[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE] =
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE];
      return rtnData;
    },
  },
  computed: {
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting",
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info-sharing", [
      "getShrFacilityList",
      "getAllShrFacilityList",
    ]),
    freeWord: {
      get() {
        return this.editRecord[PAT_INFO_SHARING.KEY_NAME_FREEWORD];
      },
      set(value) {
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_FREEWORD] = value;
      },
    },
    gender: {
      get() {
        return this.editRecord[PAT_INFO_SHARING.KEY_NAME_GENDER];
      },
      set(value) {
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_GENDER] = value;
      },
    },
    bloodType: {
      get() {
        return this.editRecord[PAT_INFO_SHARING.KEY_NAME_BLOODTYPE];
      },
      set(value) {
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_BLOODTYPE] = value;
      },
    },
    birthdayFrom: {
      get() {
        return this.editRecord[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_FROM];
      },
      set(value) {
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_FROM] = value;
      },
    },
    birthdayTo: {
      get() {
        return this.editRecord[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_TO];
      },
      set(value) {
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_TO] = value;
      },
    },
    facilityCdTo: {
      get() {
        return this.editRecord[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_TO];
      },
      set(value) {
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_TO] = value;
      },
    },
    facilityCdFrom: {
      get() {
        return this.editRecord[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_FROM];
      },
      set(value) {
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_FROM] = value;
      },
    },
    isShowShareTo: {
      get() {
        return this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_TO];
      },
      set(value) {
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_TO] = value;
      },
    },
    isShowShareFrom: {
      get() {
        return this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_FROM];
      },
      set(value) {
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_FROM] = value;
      },
    },
    isShowShareRefuse: {
      get() {
        return this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_REFUSE];
      },
      set(value) {
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_REFUSE] = value;
      },
    },
    isShowShare: {
      get() {
        return this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE];
      },
      set(value) {
        this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE] = value;
      },
    },
  },
  watch: {
    editRecord: {
      handler(newValue, oldValue) {
        var keySet = Object.keys(this.initialValue);
        for (let key of keySet) {
          let initialValue = this.initialValue[key];
          let editValue = newValue[key];
          if (JSON.stringify(initialValue) !== JSON.stringify(editValue)) {
            EventBus.$emit("isChanged", {
              componentName: "patInfoSharing",
              value: true,
            });
            return;
          }
        }
        EventBus.$emit("isChanged", {
          componentName: "patInfoSharing",
          value: false,
        });
      },
      deep: true,
    },
  },
  async created() {
    await this.setShrFacilityList();
    this.startLoadingScreen();
    this.initialValue[PAT_INFO_SHARING.KEY_NAME_FREEWORD] = "";
    this.initialValue[PAT_INFO_SHARING.KEY_NAME_GENDER] = "";
    this.initialValue[PAT_INFO_SHARING.KEY_NAME_BLOODTYPE] = "";
    this.initialValue[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_FROM] = "";
    this.initialValue[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_TO] = "";
    this.initialValue[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_TO] = "";
    this.initialValue[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_FROM] = "";
    this.initialValue[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_TO] = false;
    this.initialValue[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_FROM] = false;
    this.initialValue[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_REFUSE] = false;
    this.initialValue[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE] = true;

    this.$nextTick(() => {
      this.editRecord = deepCopy(
        this.getDefaultSetting[PAT_INFO_SHARING.KEY_NAME]
      );
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[PAT_INFO_SHARING.KEY_NAME_FREEWORD] == null) {
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_FREEWORD] =
            this.initialValue[PAT_INFO_SHARING.KEY_NAME_FREEWORD];
        }
        if (this.editRecord[PAT_INFO_SHARING.KEY_NAME_GENDER] == null) {
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_GENDER] =
            this.initialValue[PAT_INFO_SHARING.KEY_NAME_GENDER];
        }
        if (this.editRecord[PAT_INFO_SHARING.KEY_NAME_BLOODTYPE] == null) {
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_BLOODTYPE] =
            this.initialValue[PAT_INFO_SHARING.KEY_NAME_BLOODTYPE];
        }
        if (this.editRecord[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_FROM] == null) {
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_FROM] =
            this.initialValue[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_FROM];
        }
        if (this.editRecord[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_TO] == null) {
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_TO] =
            this.initialValue[PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_TO];
        }
        if (this.editRecord[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_TO] == null) {
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_TO] =
            this.initialValue[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_TO];
        }
        if (
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_FROM] == null
        ) {
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_FROM] =
            this.initialValue[PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_FROM];
        }
        if (
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_TO] == null
        ) {
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_TO] =
            this.initialValue[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_TO];
        }
        if (
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_FROM] == null
        ) {
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_FROM] =
            this.initialValue[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_FROM];
        }
        if (
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_REFUSE] ==
          null
        ) {
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_REFUSE] =
            this.initialValue[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_REFUSE];
        }
        if (this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE] == null) {
          this.editRecord[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE] =
            this.initialValue[PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
  },
  mounted() {},
};
</script>
<style>
.w-60 {
  width: 60%;
}
</style>
