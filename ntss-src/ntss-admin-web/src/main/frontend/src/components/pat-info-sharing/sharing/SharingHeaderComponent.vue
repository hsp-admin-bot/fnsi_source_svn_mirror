<!-- 患者情報共有ヘッダ -->
<template>
  <v-card>
    <div class="header-item">
      <v-ons-row class="mark-leftmost-header">
        <v-ons-col class="condition-search-col">
          <common-searcharea
            :conditionList="conditionList"
            @show-popover="showPopover($event)"
          />
        </v-ons-col>
        <v-ons-col>
          <div class="filter-area"></div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div style="margin: 12px">
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>フリーワード</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-input
              input-id="freeWord"
              type="text"
              float
              v-model="editingCondition.freeWord"
            ></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>性別</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select v-model="editingCondition.gender" class="w-60">
              <option
                v-for="(option, index) in genderList"
                :key="index"
                :value="option.value"
              >
                {{ option.displayValue }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>血液型</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select v-model="editingCondition.bloodType" class="w-60">
              <option
                v-for="(option, index) in bloodTypeList"
                :key="index"
                :value="option.value"
              >
                {{ option.displayValue }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>生年月日（開始）</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <date-input
              id="birthdayFrom"
              class="ntss-input-date ntss-control-size w-60"
              v-model="editingCondition.birthdayFrom"
              @handleClearInput="editingCondition.birthdayFrom = null"
            />
            <common-calendar v-model="editingCondition.birthdayFrom" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>生年月日（終了）</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <date-input
              id="birthdayTo"
              class="ntss-input-date ntss-control-size w-60"
              v-model="editingCondition.birthdayTo"
              @handleClearInput="editingCondition.birthdayTo = null"
            />
            <common-calendar v-model="editingCondition.birthdayTo" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>共有先施設</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <common-search-select
              v-model="editingCondition.facilityCdTo"
              :items="getShrFacilityList"
              text-field="text"
              value-field="value"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>共有元施設</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <common-search-select
              v-model="editingCondition.facilityCdFrom"
              :items="getShrFacilityList"
              text-field="text"
              value-field="value"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>共有先</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-switch
              v-model="editingCondition.isShowShareTo"
            ></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>共有元</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-switch
              v-model="editingCondition.isShowShareFrom"
            ></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>共有禁止</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-switch
              v-model="editingCondition.isShowShareRefuse"
            ></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>未完了</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-switch v-model="editingCondition.isShowShare"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <div class="condition-row" style="height: 30px; margin-bottom: 5px">
          <div style="float: left">
            <v-ons-button class="clear btn2-cancel" @click="dialogClear">
              クリア
            </v-ons-button>
          </div>
          <div style="float: right">
            <v-ons-button class="ok btn3-normal" @click="dialogOk">
              OK
            </v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import { deepCopy } from "@/functions/common/CommonFunctions";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import commonSearchArea from "@/components/common/CommonSearchArea";
import PopoverMixin from "@/components/PopoverMixin";
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";
import {
  PAT_BLOOD_TYPE_ABO_OPTIONS,
  PAT_PERSONAL_MAIN_COL_PAT_SEX_OPTIONS,
} from "@/constants/PatInfo.js";
import DateInput from "@/components/common/DateInput.vue";
import CommonSearchSelect from "@/components/common/CommonSearchSelect.vue";
import { PAT_INFO_SHARING } from "@/constants/defaultSettingConstants";

export default {
  mixins: [PopoverMixin],
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    "date-input": DateInput,
    "common-search-select": CommonSearchSelect,
  },
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      condition: {
        freeWord: "",
        gender: null,
        bloodType: null,
        birthdayFrom: "",
        birthdayTo: "",
        facilityCdFrom: "",
        facilityCdTo: "",
        isShowShareTo: false,
        isShowShareFrom: false,
        isShowShareRefuse: false,
        isShowShare: false,
      },
      editingCondition: {
        freeWord: "",
        gender: null,
        bloodType: null,
        birthdayFrom: "",
        birthdayTo: "",
        facilityCdFrom: "",
        facilityCdTo: "",
        isShowShareTo: false,
        isShowShareFrom: false,
        isShowShareRefuse: false,
        isShowShare: false,
      },
      conditionList: [],
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
  computed: {
    ...mapGetters("pat-info-sharing", [
      "getShrFacilityList",
      "getAllShrFacilityList",
      "getCondition",
    ]),
    ...mapGetters("account-edit", ["getDefaultSetting"]),
  },
  methods: {
    ...mapActions("pat-info-sharing", [
      "setShrFacilityList",
      "setCondition",
      "setFilterSignal",
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * ポップオーバー表示処理
     */
    showPopover(event) {
      this.condition = deepCopy(this.getCondition);
      this.editingCondition = deepCopy(this.getCondition);
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    /**
     * 条件クリア処理
     */
    dialogClear() {
      const defaultCondition = this.createDefaultCondition();
      this.condition = deepCopy(defaultCondition);
      this.editingCondition = deepCopy(this.condition);
      this.setCondition(deepCopy(this.condition));
      this.popoverVisible = false;
      this.search();
    },
    /**
     * 条件確定処理
     */
    dialogOk() {
      this.popoverVisible = false;
      this.condition = deepCopy(this.editingCondition);
      this.setCondition(deepCopy(this.editingCondition));
      this.search();
    },
    /**
     * 検索処理
     */
    search() {
      this.setFilterSignal(true).then(() => {
        EventBus.$emit("filterPatInfoSharingList", deepCopy(this.condition));
      });
      this.setConditionList();
    },
    /**
     * 条件リスト設定処理
     */
    setConditionList() {
      let condList = [];
      const condObj = this.condition;
      // フリーワード
      if (condObj.freeWord) {
        condList.push({ name: "フリーワード", text: condObj.freeWord });
      }
      // 性別
      if (condObj.gender) {
        condList.push({
          name: "性別",
          text: this.genderList.find((item) => item.value === condObj.gender)
            .displayValue,
        });
      }
      // 血液型
      if (condObj.bloodType) {
        condList.push({
          name: "血液型",
          text: this.bloodTypeList.find(
            (item) => item.value === condObj.bloodType
          ).displayValue,
        });
      }
      // 生年月日開始
      if (condObj.birthdayFrom) {
        condList.push({
          name: "生年月日開始",
          text: condObj.birthdayFrom.replace(/-/g, "/"),
        });
      }
      // 生年月日終了
      if (condObj.birthdayTo) {
        condList.push({
          name: "生年月日終了",
          text: condObj.birthdayTo.replace(/-/g, "/"),
        });
      }
      // 共有先施設
      if (condObj.facilityCdTo) {
        condList.push({
          name: "共有先施設",
          text: this.getAllShrFacilityList.find(
            (item) => item.value === condObj.facilityCdTo
          ).text,
        });
      }
      // 共有元施設
      if (condObj.facilityCdFrom) {
        condList.push({
          name: "共有元施設",
          text: this.getAllShrFacilityList.find(
            (item) => item.value === condObj.facilityCdFrom
          ).text,
        });
      }
      // 共有先
      if (condObj.isShowShareTo) {
        condList.push({ text: "共有先" });
      }
      this.conditionList = condList;
      // 共有元
      if (condObj.isShowShareFrom) {
        condList.push({ text: "共有元" });
      }
      this.conditionList = condList;
      // 共有禁止
      if (condObj.isShowShareRefuse) {
        condList.push({ text: "共有禁止" });
      }
      this.conditionList = condList;
      // 未完了
      if (condObj.isShowShare) {
        condList.push({ text: "未完了" });
      }
      this.conditionList = condList;
    },
    createDefaultCondition() {
      const defaults = this.getDefaultSetting[PAT_INFO_SHARING.KEY_NAME];
      if (!defaults)
        return {
          freeWord: "",
          gender: null,
          bloodType: null,
          birthdayFrom: "",
          birthdayTo: "",
          facilityCdTo: "",
          facilityCdFrom: "",
          isShowShareTo: false,
          isShowShareFrom: false,
          isShowShareRefuse: false,
          isShowShare: true,
        };
      const mapping = {
        freeWord: PAT_INFO_SHARING.KEY_NAME_FREEWORD,
        gender: PAT_INFO_SHARING.KEY_NAME_GENDER,
        bloodType: PAT_INFO_SHARING.KEY_NAME_BLOODTYPE,
        birthdayFrom: PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_FROM,
        birthdayTo: PAT_INFO_SHARING.KEY_NAME_BIRTHDAY_TO,
        facilityCdTo: PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_TO,
        facilityCdFrom: PAT_INFO_SHARING.KEY_NAME_FACILITY_CD_FROM,
        isShowShareTo: PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_TO,
        isShowShareFrom: PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_FROM,
        isShowShareRefuse: PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE_REFUSE,
        isShowShare: PAT_INFO_SHARING.KEY_NAME_IS_SHOW_SHARE,
      };
      const condition = {};
      Object.entries(mapping).forEach(([key, defaultKey]) => {
        const value = defaults[defaultKey];
        if (value != null) {
          condition[key] = value;
        }
      });
      return condition;
    },
  },
  beforeUnmount() {
    Object.assign(this.$data, this.$options.data());
  },

  async created() {
    await this.setShrFacilityList();
    if (this.getCondition) {
      this.condition = this.getCondition;
    } else {
      this.condition = this.createDefaultCondition();
    }
    this.setCondition(this.condition);
    this.setConditionList();
    this.$nextTick(() => {
      this.search();
    });
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
};
</script>
<style scoped>
ons-popover :deep(.popover) {
  min-width: 380px;
}
.search-group {
  height: 38px;
  width: 100%;
}
.label:hover {
  background-color: #31a9ee;
}
.label {
  display: block;
  float: left;
  width: 100%;
  height: 2em;
  padding-left: 5px;
  padding-right: 5px;
  background-color: #87cefa;
  color: #ffffff;
  text-align: center;
  line-height: 2em;
  cursor: pointer;
  margin: 15px 0px;
  white-space: nowrap;
}
.ons-switch-label {
  width: 85px;
}
.label-style {
  margin-right: 35px;
}
.switch-group > div {
  margin-bottom: 5px;
}
.actions {
  margin: 8px;
}
.custom-input,
.custom-input-number,
.custom-textarea,
.custom-select {
  font-size: inherit;
  display: inline-block;
  width: 100%;
  box-sizing: border-box;
}
.w-60 {
  width: 60%;
}
.condition-row {
  margin-bottom: 13px;
}
</style>
