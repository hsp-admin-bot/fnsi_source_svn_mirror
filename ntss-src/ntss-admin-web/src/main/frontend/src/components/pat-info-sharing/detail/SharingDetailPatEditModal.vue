<!-- 患者情報共有詳細編集 -->
<template>
  <modal-base
    v-if="isReady"
    @onClose="closePatEditModal"
    class="send-condition-pat-modal-base"
  >
    <template #header>
      <component :is="header"></component>
    </template>
    <template #body>
      <div
        class="send-condition-body"
        style="margin: 10px 20px 20px 20px"
      >
      <v-ons-row class="condition-row">
        <v-ons-col width="110px" style="display: flex; align-items: center">
          <label style="white-space: nowrap">患者ID</label>
        </v-ons-col>
        <v-ons-col width="24%" style="display: flex; align-items: center">
          <label v-if="!unfinishedShareFlg" style="margin-right: 8px">
            {{ initHospPatId }}
          </label>
          <v-ons-button
            v-if="this.getUnfinishedShareFlg"
            class="btn3-normal btn-pat-search"
            @click="onClickPatSearch"
          >
            患者選択
          </v-ons-button>
        </v-ons-col>
        <v-ons-col width="23%" vertical-align="center">
          <label class="label-width">性別</label>
          <label>{{ patSex }}</label>
        </v-ons-col>
        <v-ons-col vertical-align="center">
          <label>生年月日</label>
          <label style="margin-left: 15px">{{ patBirthday }}</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="condition-row">
        <v-ons-col width="110px" style="display: flex; align-items: center">
          <label style="white-space: nowrap">患者名</label>
        </v-ons-col>
        <v-ons-col width="24%" style="display: flex; align-items: center">
          <label>{{ patName }}</label>
        </v-ons-col>
        <v-ons-col width="60%" vertical-align="center">
          <label class="label-width">血液型</label>
          <label>{{ patBloodTypeAbo }}({{ patBloodTypeRh }})</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="condition-row">
        <v-ons-col width="110px" vertical-align="center">
          <label>住所</label>
        </v-ons-col>
        <v-ons-col width="90%" vertical-align="center">
          <label class="label-width-address">{{ patAddress }}</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="condition-row">
        <v-ons-col width="110px" vertical-align="center">
          <label>共有元施設</label>
        </v-ons-col>
        <v-ons-col width="90%" vertical-align="center">
          <label v-if="!isFrom || !isCreate">
            {{ getTextByValue(getAllShrFacilityList, shrPatInfo.facilityCdFrom) }}
          </label>
          <common-search-select
            v-else
            v-model="shrPatInfo.facilityCdFrom"
            :is-edited="isChanged('facilityCdFrom')"
            :class="['width-select', { 'custom-select-edited': isChanged('facilityCdFrom') }]"
            :items="getShrFacilityList"
            text-field="text"
            value-field="value"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="condition-row">
        <v-ons-col width="110px" vertical-align="center">
          <label>共有先施設</label>
        </v-ons-col>
        <v-ons-col width="24%" vertical-align="center">
          <label v-if="isFrom || !isCreate">
            {{ getTextByValue(getAllShrFacilityList, shrPatInfo.facilityCdTo) }}
          </label>
          <common-search-select
            v-else
            v-model="shrPatInfo.facilityCdTo"
            :is-edited="isChanged('facilityCdTo')"
            :class="['width-select', { 'custom-select-edited': isChanged('facilityCdTo') }]"
            :items="getShrFacilityList"
            text-field="text"
            value-field="value"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row v-if="!isAffiliatedFacility" class="condition-row">
        <v-ons-col width="110px" vertical-align="center">
          <label>自施設合意</label>
        </v-ons-col>
        <v-ons-col
          width="24%"
          min-width="250px"
          vertical-align="center"
          style="min-width: 230px"
        >
          <v-ons-select
            v-if="isFrom"
            v-model="shrPatInfo.consentTo"
            :disabled="unfinishedShareFlg || sharedState == '9'"
            :class="['width-100p', { 'custom-select-edited': isChanged('consentTo') }]"
          >
            <option
              v-for="(option, index) in consentList"
              :key="index"
              :value="option.value"
            >
              {{ option.text }}
            </option>
          </v-ons-select>
          <v-ons-select
            v-else
            v-model="shrPatInfo.consentFrom"
            :disabled="unfinishedShareFlg || sharedState == '9'"
            :class="['width-100p', { 'custom-select-edited': isChanged('consentFrom') }]"
          >
            <option
              v-for="(option, index) in consentList"
              :key="index"
              :value="option.value"
            >
              {{ option.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
        <v-ons-col width="70px" vertical-align="center">
          <label class="label-width">担当者</label>
        </v-ons-col>
        <v-ons-col width="150px" vertical-align="center">
          <v-ons-select
            v-if="isFrom"
            v-model="shrPatInfo.staffTo"
            :disabled="unfinishedShareFlg || sharedState == '9'"
            :class="['width-100p', { 'custom-select-edited': isChanged('staffTo') }]"
          >
            <option
              v-for="(option, index) in staffList"
              :key="index"
              :value="option.userId"
            >
              {{ option.userName }}
            </option>
          </v-ons-select>
          <v-ons-select
            v-else
            v-model="shrPatInfo.staffFrom"
            :disabled="unfinishedShareFlg || sharedState == '9'"
            :class="['width-100p', { 'custom-select-edited': isChanged('staffFrom') }]"
          >
            <option
              v-for="(option, index) in staffList"
              :key="index"
              :value="option.userId"
            >
              {{ option.userName }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row v-if="!isAffiliatedFacility" class="condition-row">
        <v-ons-col width="110px" vertical-align="center">
          <label>{{ isFrom ? "共有元合意" : "共有先合意" }}</label>
        </v-ons-col>
        <v-ons-col width="24%" vertical-align="center" style="min-width: 230px">
          <v-ons-select
            v-if="!isFrom"
            v-model="shrPatInfo.consentTo"
            :disabled="true"
            :class="['width-100p', { 'custom-select-edited': isChanged('consentTo') }]"
          >
            <option
              v-for="(option, index) in consentList"
              :key="index"
              :value="option.value"
            >
              {{ option.text }}
            </option>
          </v-ons-select>
          <v-ons-select
            v-else
            v-model="shrPatInfo.consentFrom"
            :disabled="true"
            :class="['width-100p', { 'custom-select-edited': isChanged('consentFrom') }]"
          >
            <option
              v-for="(option, index) in consentList"
              :key="index"
              :value="option.value"
            >
              {{ option.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
        <v-ons-col width="70px" vertical-align="center">
          <label class="label-width">担当者</label>
        </v-ons-col>
        <v-ons-col width="150px" vertical-align="center">
          <v-ons-select
            v-if="!isFrom"
            ref="staffToSelect"
            v-model="shrPatInfo.staffTo"
            :disabled="true"
            :class="['width-100p', { 'custom-select-edited': isChanged('staffTo') }]"
          >
            <option
              v-for="(option, index) in staffToList"
              :key="index"
              :value="option.user_id"
            >
              {{ option.fullName }}
            </option>
          </v-ons-select>
          <v-ons-select
            v-else
            ref="staffToFrom"
            v-model="shrPatInfo.staffFrom"
            :disabled="true"
            :class="['width-100p', { 'custom-select-edited': isChanged('staffFrom') }]"
          >
            <option
              v-for="(option, index) in staffFromList"
              :key="index"
              :value="option.user_id"
            >
              {{ option.fullName }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row v-if="!isAffiliatedFacility" class="condition-row">
        <v-ons-col width="110px" vertical-align="center">
          <label>患者合意</label>
        </v-ons-col>
        <v-ons-col width="24%" vertical-align="center">
          <v-ons-select
            :disabled="unfinishedShareFlg || sharedState == '9'"
            v-model="shrPatInfo.patConsent"
            :class="['width-100p', { 'custom-select-edited': isChanged('patConsent') }]"
          >
            <option
              v-for="(option, index) in consentList"
              :key="index"
              :value="option.value"
            >
              {{ option.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col width="110px">
          <label>添付ファイル</label>
        </v-ons-col>
        <v-ons-col width="24%" vertical-align="center">
          <div class="distance-column">
            <file-uploader
              ref="fileUploader"
              :class="['width-select', { 'custom-select-edited': isChanged('fileInfo') }]"
              :disabled="unfinishedShareFlg || sharedState == '9'"
              v-model="shrPatInfo.fileInfo"
              @error="(val) => (inlineError = val)"
              @clear-error="inlineError = ''"
            />
            <file-downloader
              ref="fileDownloader"
              v-model="shrPatInfo.fileInfo"
              @clear-error="inlineError = ''"
            />
          </div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="condition-row">
        <v-ons-col width="110px" vertical-align="center"></v-ons-col>
        <v-ons-col width="24%" vertical-align="center">
          <div v-if="inlineError" class="local-error-message">
            {{ inlineError }}
          </div>
        </v-ons-col>
      </v-ons-row>
      </div>
    </template>
    <template #footer>
      <div class="footer-class">
        <div class="left-side">
          <v-ons-button
            class="button btn2-cancel denial-btn btn-cancel"
            @click="closePatEditModal"
          >
            キャンセル
          </v-ons-button>
        </div>
        <div class="right-side">
          <v-ons-button
            v-if="!isCreate && (isAffiliatedFacility || shrPatInfo.deletionFlag)"
            class="btn4-alert registration-btn delete-button"
            @click="deleteShr"
          >
            削除
          </v-ons-button>
          <v-ons-button
            v-if="sharedState != '9'"
            class="button btn1-execute registration-btn btn-save"
            :disabled="isSaveDisabled"
            @click="handleSaveClick"
          >
            保存
          </v-ons-button>
        </div>
        <message-dialog
          v-model:visible="isEditedMessage"
          :message-cd="20010001"
          type="2"
          @confirm="confirmEdit"
        />
      </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import moment from "@/compat/date/dayjs";
import { calculateAge } from "@/functions/PatInfoFunctions";
import { EventBus } from "@/compat/vue/event-bus.js";
import PopoverMixin from "@/components/PopoverMixin";
import {
  PAT_BLOOD_TYPE_ABO_OPTIONS,
  PAT_BLOOD_TYPE_RH_OPTIONS,
  PAT_PERSONAL_MAIN_COL_PAT_SEX_OPTIONS,
} from "@/constants/PatInfo.js";
import { CONSENT_OPTIONS, CONSENT_STATUS } from "@/constants/PatShrInfo.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import FileUploader from "@/components/pat-info-sharing/utils/SharingPatFileUploader";
import FileDownloader from "@/components/pat-info-sharing/utils/SharingPatFileDownloader";
import CommonSearchSelect from "@/components/common/CommonSearchSelect.vue";
import messageDialog from "@/components/common/message-dialog/MessageDialog";

export default {
  mixins: [PopoverMixin, IndUserSelectMixin],
  components: {
    "modal-base": ModalBase,
    FileUploader,
    FileDownloader,
    "common-search-select": CommonSearchSelect,
    "message-dialog": messageDialog,
  },
  data() {
    return {
      isEditedMessage: false,
      isReady: false,
      header: "",
      localPatMain: null,
      localSearchResult: false,
      localSearchedPatId: "",
      isCreate: true,
      isFrom: false,
      hospPatId: "",
      sharedState: "",
      initStaffId: "",
      originalPatId: "",
      shrPatInfo: {
        shrPatInfoId: "",
        facilityCdFrom: "",
        facilityCdTo: "",
        patIdFrom: "",
        patIdTo: "",
        deletionFlag: true,
        consentFrom: CONSENT_STATUS.UNPROCESSED,
        consentTo: CONSENT_STATUS.UNPROCESSED,
        staffFrom: "",
        staffTo: "",
        staffFromName: "",
        staffToName: "",
        patConsent: CONSENT_STATUS.UNPROCESSED,
        shareDirection: "",
        fileInfo: [],
      },
      originalShrPatInfo: null,
      consentList: CONSENT_OPTIONS,
      staffList: [],
      selectDoctor: null,
      inlineError: "",
    };
  },
  computed: {
    ...mapGetters("pat-info-sharing", [
      "getShrFacilityList",
      "getAllShrFacilityList",
      "getAffiliatedfacilities",
      "getCondition",
      "getOurPatList",
      "getShrFromInfoList",
      "getShrToInfoList",
      "getUnfinishedShareFlg",
      "getOutHospPatId",
    ]),
    ...mapGetters("multi-modal", ["getInitValues"]),
    ...mapGetters("pat-info", {
      selectedPat: "selectedShrPat"
    }),
    ...mapGetters("window-size", {
      sidebarWidth: "getSidebarWidth",
    }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    unfinishedShareFlg() {
      if (this.localSearchResult) {
        return false;
      }
      return this.getUnfinishedShareFlg;
    },
    patMain() {
      return this.localPatMain || this.selectedPat?.pat_personal_main || {};
    },
    patId() {
      return this.patMain?.pat_id || null;
    },
    facilityCd() {
      return this.patMain?.facility_cd || null;
    },
    initHospPatId() {
      if (!this.unfinishedShareFlg && this.patMain) {
        return this.patMain?.hosp_pat_id;
      }
      return "";
    },
    patName() {
      if (!this.patMain) return "";
      const { pat_last_name: last = "", pat_first_name: first = "" } =
        this.patMain;
      return `${last} ${first}`.trim();
    },
    patBloodTypeAbo() {
      const dbValue = this.patMain.pat_blood_type_abo;
      const patBloodTypeAboData = PAT_BLOOD_TYPE_ABO_OPTIONS.find(
        (patBloodTypeAbo) => patBloodTypeAbo.value === dbValue
      );
      if (patBloodTypeAboData === undefined) {
        return "不明";
      }
      return patBloodTypeAboData.displayValue;
    },
    patBloodTypeRh() {
      const dbValue = this.patMain.pat_blood_type_rh;
      const patBloodTypeRhData = PAT_BLOOD_TYPE_RH_OPTIONS.find(
        (patBloodTypeRh) => patBloodTypeRh.value === dbValue
      );
      if (patBloodTypeRhData === undefined) {
        return "不明";
      }
      return patBloodTypeRhData.displayValue;
    },
    patBirthday() {
      if (!this.patMain?.pat_birthday) return "不明";
      const { pat_birthday, is_die, die_date } = this.patMain;
      const birthdayStr = moment(pat_birthday).format("YYYY/MM/DD");
      const endDate = is_die == 1 ? die_date : new Date();
      const age = calculateAge(
        pat_birthday,
        moment(endDate).format("YYYYMMDD")
      );
      return age > 0 ? `${birthdayStr}(${age}歳)` : birthdayStr;
    },
    patSex() {
      const dbValue = this.patMain?.pat_sex;
      const option = PAT_PERSONAL_MAIN_COL_PAT_SEX_OPTIONS.find(
        (opt) => opt.value === dbValue
      );
      return option?.displayValue || "不明";
    },
    patAddress() {
      const jsonStr = this.patMain?.pat_contact_info;
      if (!jsonStr) return "不明";
      const contactInfo = JSON.parse(jsonStr);
      return contactInfo.address || "不明";
    },
    isAffiliatedFacility() {
      const targetCd = this.isFrom
        ? this.shrPatInfo.facilityCdFrom
        : this.shrPatInfo.facilityCdTo;
      if (!targetCd) return true;
      const data = this.getAffiliatedfacilities;
      if (
        !data ||
        !Array.isArray(data.fromCorresponding) ||
        !Array.isArray(data.toCorresponding)
      ) {
        return true;
      }
      const isInFrom = data.fromCorresponding.includes(targetCd);
      const isInTo = data.toCorresponding.includes(targetCd);
      return isInFrom && isInTo;
    },
    staffToList() {
      if (!this.isCreate && !this.isFrom) {
        return [
          {
            user_id: this.shrPatInfo.staffTo || "",
            fullName: this.shrPatInfo.staffToName || "",
          },
        ];
      }
      return this.staffList;
    },
    staffFromList() {
      if (!this.isCreate && this.isFrom) {
        return [
          {
            user_id: this.shrPatInfo.staffFrom || "",
            fullName: this.shrPatInfo.staffFromName || "",
          },
        ];
      }
      return this.staffList;
    },
    isSaveDisabled() {
      if (this.unfinishedShareFlg) return true;
      if (!this.isDataModified) return true;
      if (this.isCreate) {
        if (this.isFrom) {
          if (!this.shrPatInfo.facilityCdFrom) return true;
        } else {
          if (!this.shrPatInfo.facilityCdTo) return true;
        }
      }
      if (!this.isAffiliatedFacility) {
        if (this.isFrom) {
          if (!this.shrPatInfo.staffTo) return true;
        } else {
          if (!this.shrPatInfo.staffFrom) return true;
        }
      }
      return false;
    },
    isChanged() {
      return (key) => {
        if (!this.originalShrPatInfo) return false;
        return JSON.stringify(this.shrPatInfo[key]) !== JSON.stringify(this.originalShrPatInfo[key]);
      };
    },
    isDataModified() {
      if (!this.originalShrPatInfo) return false;
      return JSON.stringify(this.shrPatInfo) !== JSON.stringify(this.originalShrPatInfo);
    },
  },

  methods: {
    ...mapActions("pat-info-sharing", [
      "setOurPatList",
      "setSelectedShrInfo",
      "setShrFacilityList",
      "setAffiliatedfacilities",
      "setUnfinishedShareFlg",
      "setSelectedPatId",
      "fetchShrInfoList",
      "fetchShrDetailsInfoList",
      "addShrPatInfo",
      "updShrPatInfo",
      "delShrPatInfo",
    ]),
    ...mapActions("pat-info", ["selectSharePat", "clearSelectedShrPat"]),
    ...mapActions("mst-wheel-chair", ["fetchPatPersonalSimpleByFacilityCd"]),
    ...mapActions("send-condition/schedule", [
      "setScheduleList",
      "searchWeightSchedule",
    ]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("multi-sub-modal", ["showShrPatSearch"]),
    ...mapMutations("pat-info-sharing", ["setSelectedShrInfo"]),

    /**
     * 新規作成または編集モードのデータを初期化する
     */
    initShrInfo(param) {
      this.localPatMain = null;
      this.localSearchResult = false;
      if (param.isCreate) {
        this.shrPatInfo = Object.assign({}, this.$options.data().shrPatInfo);
        if (param.isFrom) {
          this.shrPatInfo.facilityCdTo = this.facilityCd;
          this.shrPatInfo.patIdTo = this.patId;
          this.shrPatInfo.consentTo = CONSENT_STATUS.AGREED;
          if (!this.isAffiliatedFacility) {
            this.shrPatInfo.staffTo = this.initStaffId;
          }
        } else {
          this.shrPatInfo.facilityCdFrom = this.facilityCd;
          this.shrPatInfo.patIdFrom = this.patId;
          this.shrPatInfo.consentFrom = CONSENT_STATUS.AGREED;
          if (!this.isAffiliatedFacility) {
            this.shrPatInfo.staffFrom = this.initStaffId;
          }
        }
        this.shrPatInfo.patConsent = CONSENT_STATUS.AGREED;
      } else {
        const data = param.dataItem;
        this.shrPatInfo.shrPatInfoId = data.shrPatInfoId;
        this.shrPatInfo.shareDirection = data.shareDirection;
        this.shrPatInfo.consentFrom = data.isFromConsent;
        this.shrPatInfo.consentTo = data.isToConsent;
        this.shrPatInfo.facilityCdFrom = data.fromFacilityCd;
        this.shrPatInfo.facilityCdTo = data.toFacilityCd;
        if (!this.isAffiliatedFacility) { 
          this.shrPatInfo.staffFrom = data.fromUserId;
          this.shrPatInfo.staffTo = data.toUserId;
        }
        this.shrPatInfo.patConsent = data.isPatConsent;
        this.shrPatInfo.fileInfo = this.getParsedFileInfo(data.shrAttachment);
        this.shrPatInfo.patIdFrom = data.fromPatId;
        this.shrPatInfo.patIdTo = data.toPatId;
        this.shrPatInfo.deletionFlag = data.deletionFlag;
        this.shrPatInfo.shareDirection = data.shareDirection;
        this.sharedState = data.sharedState;
        if (param.isFrom) {
          this.shrPatInfo.staffFromName = data.userName;
        } else {
          this.shrPatInfo.staffToName = data.userName;
        }
      }
      this.inlineError = "";
      this.originalPatId = this.patId;
      this.isCreate = param.isCreate;
      this.isFrom = param.isFrom;
      this.originalShrPatInfo = JSON.parse(JSON.stringify(this.shrPatInfo));
      this.setSelectedShrInfo(JSON.parse(JSON.stringify(this.shrPatInfo)));
    },
    /**
     * 添付ファイルJSON文字列を解析し、ファイル情報の配列を返却する
     */
    getParsedFileInfo(attachmentStr) {
      if (!attachmentStr || attachmentStr.trim() === "") {
        return [];
      }
      try {
        const attachments = JSON.parse(attachmentStr);
        if (Array.isArray(attachments)) {
          return attachments.map((item) => {
            const { file_name, file_path, ...rest } = item;
            return {
              ...rest,
              name: file_name,
              path: file_path,
            };
          });
        }
        return [];
      } catch (error) {
        console.error("添付ファイルJSONの解析に失敗しました:", error);
        return [];
      }
    },
    /**
     * 患者編集モーダルクローズ処理
     */
    closePatEditModal() {
      if (this.isDataModified) {
        this.isEditedMessage = true;
      } else {
        this.hideModal();
      }
    },
    /**
     * 編集内容破棄の確認
     */
    confirmEdit(answer) {
      this.isEditedMessage = false;
      if (answer === "OK") {
        this.hideModal();
      }
    },
    /**
     * 患者検索ダイアログを表示する
     */
    async onClickPatSearch() {
      await this.setLoadingScreenVisible(true);
      await this.setOurPatList();
      this.showShrPatSearch();
      await this.setLoadingScreenVisible(false);
    },

    /**
     * 共有情報を保存（新規登録または更新）する
     */
    async saveShr() {
      await this.$refs.fileUploader.fileExistsCheck();
      const formData = new FormData();
      const info = this.shrPatInfo;
      const baseParam = {
        fromFacilityCd: info.facilityCdFrom,
        toFacilityCd: info.facilityCdTo,
        fromPatId: info.patIdFrom,
        toPatId: info.patIdTo,
        isFromConsent: info.consentFrom,
        isToConsent: info.consentTo,
        fromUserId: this.isAffiliatedFacility ? "" : info.staffFrom,
        toUserId: this.isAffiliatedFacility ? "" : info.staffTo,
        isPatConsent: info.patConsent,
        shrAttachment: info.fileInfo.map((file) => {
          const { name, path, ...rest } = file;
          return {
            ...rest,
            file_name: name,
            file_path: path,
          };
        }),
      };
      if (!this.isCreate) {
        baseParam.shrPatInfoId = info.shrPatInfoId;
        baseParam.shareDirection = info.shareDirection;
      }
      Object.keys(baseParam).forEach((key) => {
        const value = baseParam[key];
        if (value === null || value === undefined) {
          formData.append(key, "");
        } else if (typeof value === "object") {
          formData.append(key, JSON.stringify(value));
        } else {
          formData.append(key, value);
        }
      });
      const binaryFiles = this.$refs.fileUploader.payload;
      if (binaryFiles && binaryFiles.length > 0) {
        binaryFiles.forEach((file) => {
          if (file) formData.append("files", file);
        });
      }
      try {
        await this.setLoadingScreenVisible(true);
        const padId = this.localSearchedPatId || this.patId;
        if (this.isCreate) {
          await this.addShrPatInfo(formData);
        } else {
          await this.updShrPatInfo(formData);
          if (this.localSearchedPatId) {
            await this.selectSharePat(this.localSearchedPatId);
            this.setUnfinishedShareFlg(false);
          }
          this.setSelectedPatId(padId);
        }
        await Promise.all([
          this.setAffiliatedfacilities(),
          this.fetchShrDetailsInfoList(padId),
          this.fetchShrInfoList({
            ...this.getCondition,
            currentSelectedPatId: padId
          }),
        ]);
        this.shrPatInfo.fileInfo = [];
      } catch (error) {
        console.error("共有情報の保存に失敗しました", error);
      } finally {
        await this.setLoadingScreenVisible(false);
      }
    },

    /**
     * 共有情報を削除する
     */
    async deleteShr() {
      try {
        await this.setLoadingScreenVisible(true);
        await this.delShrPatInfo(this.shrPatInfo.shrPatInfoId);
        this.hideModal();
        this.shrPatInfo.fileInfo = [];
        await Promise.all([
          this.setAffiliatedfacilities(),
          this.fetchShrDetailsInfoList(this.originalPatId),
          this.fetchShrInfoList({
            ...this.getCondition,
            currentSelectedPatId: this.originalPatId
          }),
        ]);
      } catch (error) {
        console.error("共有情報の削除に失敗しました", error);
      } finally {
        await this.setLoadingScreenVisible(false);
      }
    },

    /**
     * オプションリストから指定された値に対応するテキストを取得する
     */
    getTextByValue(options, value) {
      if (!options || options.length === 0) return "読み込み中...";
      const option = options.find((opt) => opt.value === value);
      return option ? option.text : "";
    },
    /**
     * 担当者一覧を取得する
     */
    async getStaffToList(staffCd) {
      const params = { facility_cd: this.facilityCd };
      if (this.patId) {
        params.selectedPatId = this.patId;
      }
      const mstPersonalUserResponse = await ApiHelper.get(
        "/mstInfo/mstPersonalUserIncludeDel",
        params
      );
      return (
        mstPersonalUserResponse?.data
          .filter((item) => {
            return item.isDisp == "1" || item.userId == staffCd;
          })
          .map((item) => ({
            ...item,
            userLastName:
              item.isDisp === "0"
                ? `【削除済み】${item.userLastName}`
                : item.userLastName,
          })) || []
      );
    },

    /**
     * 患者検索がキャンセルされた際の処理を行う
     */
    async handleSearchCancel() {
      this.localPatMain = null;
      this.localSearchResult = false;
      this.localSearchedPatId = "";
    },

    /**
     * 患者検索で選択された患者を共有情報に反映して保存する
     */
    async handleSearchSave(patId) {
      try {
        await this.setLoadingScreenVisible(true);
        await this.$nextTick();
        const targetPat = this.getOurPatList.find((p) => p.patId === patId);
        if (!targetPat) return;
        targetPat.facility_cd = targetPat.facilityCd;
        this.localPatMain = targetPat;
        this.localSearchResult = true;
        this.localSearchedPatId = patId;
        await this.$nextTick();
        this.staffList = await this.getStaffToList(this.initStaffId);
        const staffId = String(this.getStateUserAccountInfo.userId);
        if (this.isFrom) {
          this.shrPatInfo.patIdTo = patId;
          this.shrPatInfo.consentTo = CONSENT_STATUS.AGREED;
          this.shrPatInfo.staffTo = staffId;
        } else {
          this.shrPatInfo.patIdFrom = patId;
          this.shrPatInfo.consentFrom = CONSENT_STATUS.AGREED;
          this.shrPatInfo.staffFrom = staffId;
        }
      } finally {
        await this.setLoadingScreenVisible(false);
      }
    },

    /**
     * 保存処理
     */
    async handleSaveClick() {
      await this.saveShr();
      this.hideModal();
    },

    /**
     * 削除対象ファイルがダウンローダー側に存在するか確認し、削除処理を行う
     */
    deleteFile(deleteList) {
      deleteList.forEach((file) =>
        this.$refs.fileDownloader.checkForDeletedFiles(file)
      );
    },
  },
  watch: {
    sidebarWidth(w) {
      document.documentElement.style.setProperty("--side-w", w + "px");
    },
    async facilityCd(newVal, oldVal) {
      if (!newVal || newVal === oldVal) return;
      this.staffList = await this.getStaffToList(this.initStaffId);
    },
    isAffiliatedFacility: {
      immediate: true,
      handler(newVal) {
        if (this.isCreate) {
          if (newVal) {
            this.shrPatInfo.staffTo = "";
            this.shrPatInfo.staffFrom = "";
          } else {
            if (this.isFrom) {
              this.shrPatInfo.staffTo = this.initStaffId;
            } else {
              this.shrPatInfo.staffFrom = this.initStaffId;
            }
          }
          if (this.originalShrPatInfo) {
            this.originalShrPatInfo.staffTo = this.shrPatInfo.staffTo;
            this.originalShrPatInfo.staffFrom = this.shrPatInfo.staffFrom;
          }
        }
      }
    },
    localSearchResult(newVal) {
      if (newVal) {
        if (!this.isAffiliatedFacility) {
          const staffId = this.getStateUserAccountInfo.userId;
          if (this.isFrom) {
            this.shrPatInfo.staffTo = staffId;
            this.shrPatInfo.consentTo = CONSENT_STATUS.AGREED;
          } else {
            this.shrPatInfo.staffFrom = staffId;
            this.shrPatInfo.consentFrom = CONSENT_STATUS.AGREED;
          }
        }
      }
    },
  },
  async created() {
    await Promise.all([
      this.setShrFacilityList(),
      this.setAffiliatedfacilities(),
    ]);
    this.initStaffId = this.getStateUserAccountInfo.userId;
    this.staffList = await this.getStaffToList(this.initStaffId);
    this.initShrInfo(this.getInitValues);
    this.isReady = true;
    EventBus.$on("shrPatSearchCancelEvent", this.handleSearchCancel);
    EventBus.$on("shrPatSearchSaveEvent", this.handleSearchSave);
  },
  mounted() {
    document.documentElement.style.setProperty(
      "--side-w",
      this.sidebarWidth + "px"
    );
  },
  beforeUnmount() {
    Object.assign(this.$data, this.$options.data());
    EventBus.$off("shrPatSearchCancelEvent");
    EventBus.$off("shrPatSearchSaveEvent");
  },
};
</script>
<style scoped>
.send-condition-pat-modal-base :deep(.modal-body) {
  overflow-x: auto;
}
.width-100p {
  width: 150px !important;
}
.condition-row {
  flex-wrap: nowrap;
  min-width: 560px;
}
.btn-pat-search {
  width: 100px !important;
  min-width: 75px !important;
}
.local-error-message {
  color: #ff4d4f;
  font-size: 15px;
  font-weight: bold;
  animation: fadeIn 0.3s ease;
  white-space: pre-line;
}
.btn-save {
  background-color: #1a71cc !important;
  color: #ffffff !important;
  background-image: none !important;
}
.btn-save[disabled] {
  background-color: #dddddd !important;
  color: #c1c1c1 !important;
  background-image: none !important;
}
.footer-class {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 10px 15px;
}
.right-side {
  display: flex;
  gap: 10px;
}
.send-condition-pat-modal-base .width-100p[disabled],
.send-condition-pat-modal-base .width-100p:disabled,
.send-condition-pat-modal-base .width-100p.disabled {
  background-color: #ebebe4 !important;
  opacity: 0.6 !important;
}
.send-condition-pat-modal-base :deep(select:disabled) {
  border-radius: 4px !important;
}
.label-width {
  display: inline-block;
  width: 70px;
}
.label-width-address {
  display: block;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  min-width: 0;
}
.width-select {
  width: 270px;
}
</style>
