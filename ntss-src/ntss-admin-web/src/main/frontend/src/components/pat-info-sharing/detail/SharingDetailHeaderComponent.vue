<!-- 患者情報共有詳細ヘーダ -->
<template>
  <div class="pat-header">
    <v-touch
      :disabled="
        searchedPatList.length === 0 || !isPatSelected || isPatInfoVisible
      "
      @swipeleft="selectPatPre()"
    >
      <v-touch
        :disabled="
          searchedPatList.length === 0 || !isPatSelected || isPatInfoVisible
        "
        @swiperight="selectPatNext()"
      >
        <table class="event-area">
          <tbody>
            <tr>
              <td class="search-button-area">
                <div
                  class="search-button"
                  @click="
                    getStateUserAccountInfo.patId === null
                      ? (isSideBarVisble = !isSideBarVisble)
                      : (isSideBarVisble = false)
                  "
                ></div>
              </td>
              <td class="pat-name-area" id="pat-name-area">
                <label>
                  <span
                    v-show="!isCreatePage || isNullShrPat"
                    class="hosp-pat-id"
                    ref="displayPos"
                    @mousedown="checkPatInfoLongPress(1)"
                    @mouseup="checkPatInfoLongPress(0)"
                    @touchstart="checkPatInfoLongPress(1)"
                    @touchend="checkPatInfoLongPress(0)"
                  >
                    {{
                      isNullShrPat ? "患者割り当てをしてください。" : hospPatId
                    }}
                    <img v-if="isSame" class="same-icon" :src="image_src_same" />
                  </span>
                  <br />
                  <span
                    :class="patNameClass"
                    id="pat-header-pat-name"
                    @click="clickHeader()"
                  >
                    {{ isNullShrPat ? "？？？？患者" : patName }}
                  </span>
                  <v-ons-popover
                    :target="popoverTarget"
                    v-model:visible="computedPopoverVisible"
                    :class="[fontSizeSet, 'popover-style']"
                    direction="down"
                    cancelable
                  >
                    <p style="text-align: center">保守ID: {{ patId }}</p>
                  </v-ons-popover>
                </label>
              </td>
              <td
                v-if="!isCreatePage && !getUnfinishedShareFlg"
                class="pat-icon-area"
              >
                <span v-if="isPatSelected">
                  <div class="in-out-area">{{ inOutClassName }}</div>
                  <div
                    class="icon-area"
                    v-if="getStateUserAccountInfo.patId === null"
                  >
                    <span
                      class="icon-padding taboo-allergy-area"
                      @click="showTabooAllergy"
                    >
                      <img
                        class="pat-icon"
                        :src="iconTabooAllergy"
                        alt="pat-icon-taboo"
                      />
                      <v-ons-popover
                        :class="[fontSizeSet, 'vons-popover']"
                        v-model:visible="isTabooAllergyVisible"
                        :target="popoverTarget"
                        direction="down"
                        cancelable
                        @preshow="popoverPreShow"
                        @postshow="popoverPostShow"
                        @posthide="popoverPosthide"
                      >
                        <div class="taboo-allergy-popover-div">
                          <taboo-allergy-detail
                            class-name="禁忌"
                            class="fab-font-color"
                            v-bind="allTabooDetailName"
                            v-if="hasTabooAllergy"
                          />
                          <taboo-allergy-detail
                            class-name="アレルギー"
                            class="fab-font-color"
                            v-bind="allAllergyDetailName"
                            v-if="hasTabooAllergy"
                          />
                          <div class="fab-font-color" v-show="!hasTabooAllergy">
                            禁忌・アレルギー無し
                          </div>
                        </div>
                      </v-ons-popover>
                    </span>
                    <span class="icon-padding infect-area" @click="showInfection">
                      <img
                        class="pat-icon"
                        :src="iconInfect"
                        alt="pat-icon-infection"
                      />
                      <v-ons-popover
                        :class="[fontSizeSet, 'infection-popover']"
                        v-model:visible="isInfectionVisible"
                        :target="popoverTarget"
                        direction="down"
                        cancelable
                        @preshow="popoverPreShow"
                        @postshow="popoverPostShow"
                        @posthide="popoverPosthide"
                      >
                        <div class="infection-popover-div">
                          <infection-items
                            :mst-infection="mstInfection"
                            :infection-data="infectionData"
                          />
                        </div>
                      </v-ons-popover>
                    </span>
                    <span class="icon-padding implant-area" @click="showImplant">
                      <img
                        class="pat-icon"
                        :src="iconImplant"
                        alt="pat-icon-implant"
                      />
                      <v-ons-popover
                        :class="[fontSizeSet, 'implant-popover']"
                        v-model:visible="isImplantVisible"
                        :target="popoverTarget"
                        direction="down"
                        cancelable
                        @preshow="popoverPreShow"
                        @postshow="popoverPostShow"
                        @posthide="popoverPosthide"
                      >
                        <div class="implant-popover-div">
                          <div
                            class="fab-font-color"
                            v-show="implantData.length == 0"
                          >
                            インプラント無し
                          </div>
                          <div
                            class="fab-font-color"
                            v-show="implantData.length !== 0"
                          >
                            インプラント一覧
                          </div>
                          <span>
                            <span
                              v-for="(pat, patIndex) in implantData"
                              :key="patIndex"
                            >
                              <div class="fab-font-color">
                                {{ patIndex + 1 }}:
                                {{
                                  mstCdToNameOrNull(
                                    mstImplant,
                                    pat.implant_cd,
                                    "implantCd",
                                    "implantName"
                                  )
                                }}
                              </div>
                              <div class="fab-font-color">
                                {{
                                  showFromToDateString(
                                    pat.reg_date,
                                    pat.remove_date
                                  )
                                }}
                              </div>
                            </span>
                          </span>
                        </div>
                      </v-ons-popover>
                    </span>
                  </div>
                </span>
              </td>
              <td class="patinfo-treattime-area">
                <div class="patinfo-treattime-area-scroll">
                  <div
                    class="patinfo-treattime-area-scroll-child"
                    style="width: max-content; padding-left: 20px"
                  >
                    <div
                      v-if="!isCreatePage && isPatSelected"
                      class="pat-header-pat-info-area"
                    >
                      <div>
                        {{ patSex }} {{ patBloodTypeAbo }}({{ patBloodTypeRh }})
                      </div>
                      <div>{{ patBirthday }}({{ age }})</div>
                    </div>
                    <div
                      v-if="
                        !isCreatePage &&
                        isPatSelected &&
                        !isUpdatingAcceptanceStatusInfo &&
                        treatmentCount !== 0
                      "
                      class="treatment-time-area"
                      @click="showAcceptanceStatusInfo"
                    >
                      <div
                        v-if="isTreatmentTime(0)"
                        :style="treatmentTimeStyle(0)"
                      >
                        <span
                          v-if="isTreatmentCount(2)"
                          :style="treatmentcountStyle(0)"
                          class="treatment-count-area"
                        >
                          {{ treatmentCount }}
                        </span>
                        <div :style="treatmentProgressStyle(0)"></div>
                      </div>
                      <div v-else>&emsp;</div>
                      <v-ons-popover
                        :class="[fontSizeSet, 'acceptance-status-info-popover']"
                        v-model:visible="popoverAcceptanceStatusInfoVisible"
                        :target="popoverAcceptanceStatusInfoTarget"
                        direction="down"
                        cancelable
                      >
                        <div
                          v-if="isTreatmentCount(1)"
                          class="acceptance-status-info-area"
                        >
                          <span
                            v-for="(
                              itemData, itemIndex
                            ) in this.acceptanceStatusInfo()"
                            :key="itemIndex"
                          >
                            <div
                              v-if="isTreatmentTime(itemIndex)"
                              class="acceptance-status-info-bar"
                            >
                              <div :style="treatmentTimeStyle(itemIndex)">
                                <div
                                  :style="treatmentProgressStyle(itemIndex)"
                                ></div>
                              </div>
                            </div>
                          </span>
                        </div>
                        <div class="acceptance-statusn-info-button-area">
                          <ons-button
                            class="common-style-ok-button btn3-normal"
                            :disabled="!isPatEditAuthority"
                            @click="updateAcceptanceStatusInfo"
                          >
                            更新
                          </ons-button>
                        </div>
                      </v-ons-popover>
                    </div>
                  </div>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </v-touch>
    </v-touch>

    <div v-if="isSideBarVisble" style="width: 0">
      <side-bar />
    </div>
    <div
      v-if="!isPatInfoPageShowing && isPatInfoVisible && isPatSelected"
      :class="['card-list', cardListSize]"
    >
      <card-list
        :pat-record="selectedPat"
        :header-click="true"
        ref="cardList"
      />
      <div v-if="selectedPat !== null">
        <img
          class="menu-btn"
          id="menu-btn"
          :src="imgUrl"
          @click="menuDisplay()"
        />
      </div>
    </div>
  </div>
</template>

<script>
import _ from "@/compat/collections/lodash";
import moment from "@/compat/date/dayjs";
import VTouch from "@/components/common/VTouch.vue";
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import { calculateAge } from "@/functions/PatInfoFunctions";
import {
  PAT_BLOOD_TYPE_ABO_OPTIONS,
  PAT_BLOOD_TYPE_RH_OPTIONS,
  PAT_PERSONAL_MAIN_COL_PAT_SEX_OPTIONS,
} from "@/constants/PatInfo.js";
import {
  deduplicateObjects,
  deserializeJsonColumn,
  mstCdToName,
  mstCdToNameIncludeExpiredAndDeleted,
} from "@/functions/common/CommonFunctions.js";
import PopoverMixin from "@/components/PopoverMixin";
import cardList from "@/components/pat-info/PatInfoCardList.vue";
import sideBar from "@/components/side-contents/SideBar.vue";
import infectionItems from "@/components/header-contents/PatHeaderInfectionItems.vue";
import tabooAllergyDetail from "@/components/pat-info/taboo-allergy-card/TabooAllergyDetail.vue";
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
import * as functionCd from "@/constants/function-code";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {
  popoverPosthide,
  popoverPostShow,
  popoverPreShow,
} from "@/functions/common/CommonPopoverFunctions";
import { createTimerManager } from "@/functions/for-componet/TimerManagerFunctions";
import { PAT_HEADER } from "@/components/pat-info/PatInfoConfig.js";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from "@/functions/common/MessageFormat";
import { getMstInfo } from "@/apis/mst-info";
import nameDuplication3Img from "../../../assets/name_duplication3.png";
import tabooOnImg from "../../../assets/taboo_on.png";
import tabooOffImg from "../../../assets/taboo_off.png";
import infectionOnImg from "../../../assets/infection_on.png";
import infectionOffImg from "../../../assets/infection_off.png";
import implantOnImg from "../../../assets/implant_on.png";
import implantOffImg from "../../../assets/implant_off.png";

export default {
  mixins: [PopoverMixin, UserAuthorityMixin],
  components: {
    VTouch,
    "card-list": cardList,
    "side-bar": sideBar,
    "infection-items": infectionItems,
    "taboo-allergy-detail": tabooAllergyDetail,
  },
  props: {
    isCreatePage: {
      type: Boolean,
      default: false,
    },
    isCannotSwipe: {
      type: Boolean,
      default: false,
    },
    isWeightScale: {
      type: Boolean,
      default: false,
    },
  },

  data() {
    return {
      imgUrl: "",
      direction: null,
      isSideBarVisble: false,
      isInfectionVisible: false,
      isImplantVisible: false,
      isTabooAllergyVisible: false,
      popoverTarget: null,
      iconHasTabooAllergy: "●",
      iconNoTabooAllergy: "○",
      iconHasInfect: "●",
      iconNoInfect: "○",
      iconHasImplant: "●",
      iconNoImplant: "○",
      mstTabooAllergy: null,
      mstMedicine: null,
      mstMedicineMix: null,
      mstEquipment: null,
      mstDialyzer: null,
      sysGenericMedicine: null,
      mstInfection: null,
      mstImplant: null,
      image_src_same: nameDuplication3Img,
      image_src_taboo_on: tabooOnImg,
      image_src_taboo_off: tabooOffImg,
      image_src_infection_on: infectionOnImg,
      image_src_infection_off: infectionOffImg,
      image_src_implant_on: implantOnImg,
      image_src_implant_off: implantOffImg,
      blowTimer: 0,
      popoverVisible: false,
      isAndroid: false,
      isIOS: false,
      timerManager: null,

      popoverAcceptanceStatusInfoVisible: false,
      popoverAcceptanceStatusInfoTarget: null,
      initDate: null,
      facilityOptions: [],
      facilitySelectValue: {
        initValue: null,
        editValue: null,
      },
    };
  },

  computed: {
    ...mapGetters("account-edit", ["getTheme"]),
    ...mapGetters("pat-info-sharing", ["getUnfinishedShareFlg"]),
    ...mapGetters("send-condition/weight", ["getWeightMode"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", [
      "searchedPatList",
      "isPatInfoPageShowing",
      "isPatInfoVisible",
      "isNullShrPat",
      "isUpdatingAcceptanceStatusInfo",
      "isPatInfoChaned",
    ]),
    ...mapGetters("pat-info", {
      selectedPat: "selectedShrPat",
    }),
    ...mapGetters("window-size", {
      windowWidth: "getMainWindowWidth",
    }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getFontSize"]),

    computedPopoverVisible: {
      get() {
        return !this.getUnfinishedShareFlg && this.popoverVisible;
      },
      set(val) {
        this.popoverVisible = val;
      },
    },

    selectedPatId() {
      const pat = this.selectedPat;
      if (!pat || !pat.pat_personal_main) {
        return null;
      }
      return pat.pat_personal_main.pat_id || null;
    },

    selectedPatName() {
      const pat = this.selectedPat;
      if (!pat || !pat.pat_personal_main) {
        return "";
      }

      const lastName = pat.pat_personal_main.pat_last_name || "";
      const firstName = pat.pat_personal_main.pat_first_name || "";

      return lastName && firstName
        ? lastName + " " + firstName
        : lastName + firstName;
    },

    patName() {
      if (this.isCreatePage) {
        return "新規登録する患者情報を入力して下さい";
      }
      if (this.selectedPat === null && this.selectedPatIdIndex === -1) {
        return "患者未選択";
      }
      return this.selectedPatName;
    },

    patNameClass() {
      return {
        "pat-create": this.isCreatePage,
        "pat-name": !this.isCreatePage,
      };
    },

    patIdList() {
      let patIdList = [];
      this.searchedPatList.forEach((record) => {
        patIdList.push({ patId: record.pat_id });
      });
      return patIdList;
    },
    hospPatIdList() {
      let hospPatIdList = [];
      this.searchedPatList.forEach((record) => {
        hospPatIdList.push({ hospPatId: record.hosp_pat_id });
      });
      return hospPatIdList;
    },

    selectedPatIdIndex() {
      let indexNo = -1;
      this.patIdList.some((obj, index) => {
        if (obj.patId && obj.patId === this.selectedPatId) {
          indexNo = index;
          return true;
        }
      }, this);
      return indexNo;
    },

    patId() {
      return this.selectedPatId;
    },

    hospPatId() {
      return this.isPatSelected
        ? "ID:" +
            (!this.getUnfinishedShareFlg
              ? this.getPatPersonalMainColumnData("hosp_pat_id")
              : "")
        : "";
    },

    inOutClassName() {
      let value = "不明";
      switch (this.getPatPersonalMainColumnData("in_out_class")) {
        case 0:
          value = "外来";
          break;
        case 1:
          value = "入院";
          break;
        case 2:
          value = "死亡";
          break;

        case 3:
          value = "－";
          break;
        default:
          value = "不明";
      }
      return value;
    },

    patSex() {
      const dbValue = this.getPatPersonalMainColumnData("pat_sex");
      const patSexData = PAT_PERSONAL_MAIN_COL_PAT_SEX_OPTIONS.find(
        (patSex) => patSex.value === dbValue
      );
      if (patSexData === undefined) {
        return "不明";
      }
      return patSexData.displayValue;
    },

    patBloodTypeAbo() {
      const dbValue = this.getPatPersonalMainColumnData("pat_blood_type_abo");
      const patBloodTypeAboData = PAT_BLOOD_TYPE_ABO_OPTIONS.find(
        (patBloodTypeAbo) => patBloodTypeAbo.value === dbValue
      );
      if (patBloodTypeAboData === undefined) {
        return "不明";
      }
      return patBloodTypeAboData.displayValue;
    },

    patBloodTypeRh() {
      const dbValue = this.getPatPersonalMainColumnData("pat_blood_type_rh");
      const patBloodTypeRhData = PAT_BLOOD_TYPE_RH_OPTIONS.find(
        (patBloodTypeRh) => patBloodTypeRh.value === dbValue
      );
      if (patBloodTypeRhData === undefined) {
        return "不明";
      }
      return patBloodTypeRhData.displayValue;
    },

    patBirthday() {
      if (this.getPatPersonalMainColumnData("pat_birthday") === null) {
        return "不明";
      }
      return moment(this.getPatPersonalMainColumnData("pat_birthday")).format(
        "YYYY/MM/DD"
      );
    },

    age() {
      const age = calculateAge(
        this.getPatPersonalMainColumnData("pat_birthday"),
        this.getPatPersonalMainColumnData("is_die") == 1
          ? moment(this.getPatPersonalMainColumnData("die_date")).format(
              "YYYYMMDD"
            )
          : moment(new Date()).format("YYYYMMDD")
      );
      return age > 0 ? `${age}歳` : "不明";
    },

    isPatSelected() {
      return this.selectedPat !== null;
    },

    isSame() {
      return this.isPatSelected && !this.isCreatePage
        ? this.getPatMainColumnData("is_same") === "1"
        : false;
    },

    iconTabooAllergy() {
      return this.hasTabooAllergy
        ? this.image_src_taboo_on
        : this.image_src_taboo_off;
    },

    iconInfect() {
      return this.hasInfect
        ? this.image_src_infection_on
        : this.image_src_infection_off;
    },

    iconImplant() {
      return this.hasImplant
        ? this.image_src_implant_on
        : this.image_src_implant_off;
    },

    hasTabooAllergy() {
      return (
        JSON.parse(this.getPatMainColumnData("taboo_allergy_info")).length !== 0
      );
    },

    hasInfect() {
      return this.getPatMainColumnData("is_infect") === "1";
    },

    hasImplant() {
      return this.getPatMainColumnData("is_implant") === "1";
    },

    patInfoRaw() {
      return {
        ...this.selectedPat.pat_main,
      };
    },

    infectionData() {
      const deserializedRecord = deserializeJsonColumn(this.patInfoRaw, [
        "infect_info",
      ]);
      if (this.mstInfection == null) {
        return deserializedRecord.infect_info;
      }
      let mstInfectionTmp = [];
      for (const mst of this.mstInfection) {
        const targetInfection = deserializedRecord.infect_info.find(
          (infection) => {
            return infection.infection_cd === mst.infectionCd;
          }
        );
        let infection_cd;
        let infect;
        let exam_date;
        let up_date;
        if (targetInfection === undefined) {
          infection_cd = mst.infectionCd;
          infect = "0";
          exam_date = null;
          up_date = null;
          const infection = {
            infect,
            up_date,
            exam_date,
            infection_cd,
          };
          mstInfectionTmp.push(infection);
        } else {
          mstInfectionTmp.push(targetInfection);
        }
      }
      deserializedRecord.infect_info = mstInfectionTmp;
      return deserializedRecord.infect_info;
    },

    implantData() {
      const deserializedRecord = deserializeJsonColumn(this.patInfoRaw, [
        "implant_info",
      ]);
      return deserializedRecord.implant_info;
    },

    tabooAllergyData() {
      return JSON.parse(this.selectedPat.pat_main.taboo_allergy_info);
    },

    allTabooDetail() {
      return this.collectAllTabooAllergyDetail(PAT_HEADER.CLASS_TABOO);
    },

    allTabooMedicine() {
      return this.extractMedicineNameFromDetail(this.allTabooDetail);
    },

    allTabooMedicineMix() {
      return this.extractMedicineMixNameFromDetail(this.allTabooDetail);
    },

    allTabooEquip() {
      return this.extractEquipNameFromDetail(this.allTabooDetail);
    },

    allTabooDialyzer() {
      return this.extractDialyzerNameFromDetail(this.allTabooDetail);
    },

    allTabooGenericMedicine() {
      return this.extractGenericMedicineNameFromDetail(this.allTabooDetail);
    },

    allTabooFreeWord() {
      return this.extractFreeWordNameFromDetail(this.allTabooDetail);
    },

    allTabooDetailName() {
      return {
        medicine: this.allTabooMedicine,
        medicineMix: this.allTabooMedicineMix,
        equip: this.allTabooEquip,
        dialyzer: this.allTabooDialyzer,
        genericMedicine: this.allTabooGenericMedicine,
        freeWord: this.allTabooFreeWord,
      };
    },

    allAllergyDetail() {
      return this.collectAllTabooAllergyDetail(PAT_HEADER.CLASS_ALLERGY);
    },

    allAllergyMedicine() {
      return this.extractMedicineNameFromDetail(this.allAllergyDetail);
    },

    allAllergyMedicineMix() {
      return this.extractMedicineMixNameFromDetail(this.allAllergyDetail);
    },

    allAllergyEquip() {
      return this.extractEquipNameFromDetail(this.allAllergyDetail);
    },

    allAllergyDialyzer() {
      return this.extractDialyzerNameFromDetail(this.allAllergyDetail);
    },

    allAllergyGenericMedicine() {
      return this.extractGenericMedicineNameFromDetail(this.allAllergyDetail);
    },

    allAllergyFreeWord() {
      return this.extractFreeWordNameFromDetail(this.allAllergyDetail);
    },

    allAllergyDetailName() {
      return {
        medicine: this.allAllergyMedicine,
        medicineMix: this.allAllergyMedicineMix,
        equip: this.allAllergyEquip,
        dialyzer: this.allAllergyDialyzer,
        genericMedicine: this.allAllergyGenericMedicine,
        freeWord: this.allAllergyFreeWord,
      };
    },

    acceptanceStatusInfos() {
      return this.acceptanceStatusInfo();
    },
    treatmentCount() {
      let ret = 0;
      const info = this.acceptanceStatusInfo();
      if (info != null) {
        info.forEach((item, index) => {
          if (this.treatmentProgress(info, index) != null) {
            ret = ret + 1;
          }
        });
      }
      return ret;
    },
    isPatEditAuthority() {
      return (
        this.getUserAuthorityCds().includes(AUTHORITY_CODES.PAT_EDIT) ||
        this.getUserAuthorityCds().includes(AUTHORITY_CODES.PAT_PEDIT)
      );
    },

    cardListSize() {
      switch (+this.getFontSize) {
        case 0:
          return "small";
        case 1:
          return "medium";
        case 2:
          return "big";
        case 3:
          return "xbig";
        default:
          return "";
      }
    },
  },

  watch: {
    getTheme(val) {
      if (val == 0) {
        if (this.direction == "left") {
          this.imgUrl = "img/pat-info/left_w.png";
        } else if (this.direction == "right") {
          this.imgUrl = "img/pat-info/right_w.png";
        }
      } else if (val == 1) {
        if (this.direction == "left") {
          this.imgUrl = "img/pat-info/left_b.png";
        } else if (this.direction == "right") {
          this.imgUrl = "img/pat-info/right_b.png";
        }
      }
    },
    direction(val) {
      if (val == "left") {
        if (this.getTheme == 0) {
          this.imgUrl = "img/pat-info/left_w.png";
        } else if (this.getTheme == 1) {
          this.imgUrl = "img/pat-info/left_b.png";
        }
      } else if (val == "right") {
        if (this.getTheme == 0) {
          this.imgUrl = "img/pat-info/right_w.png";
        } else if (this.getTheme == 1) {
          this.imgUrl = "img/pat-info/right_b.png";
        }
      }
    },
    selectedPat: {
      handler() {
        this.isSideBarVisble = false;
        if (this.timerManager) {
          this.timerManager.setTimeout(this.calPatNameAreaWidth, 1000);
        }
        this.rebuildAcceptanceStatusInfo();
      },
      deep: true,
    },
    windowWidth() {
      this.calPatNameAreaWidth();
    },
    getFontSize() {
      this.calPatNameAreaWidth();
    },
  },

  async created() {
    this.timerManager = createTimerManager();
    this.path = this.$router.currentRoute.name;
    if (this.path !== "pat-viewer") {
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
    }
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }

    if (!this.isPatInfoPageShowing) {
      this.setIsPatInfoVisible(false);
    }
    this.direction = "left";

    const reqMstNames = [
      "mstTabooAllergyIncludeDeleted",
      "mstMedicineIncludeDeleted",
      "mstEquipmentIncludeDeleted",
      "mstDialyzerIncludeDeleted",
      "sysGenericMedicineIncludeDeleted",
      "mstInfection",
      "mstMedicineMixIncludeDeleted",
      "mstImplant",
    ];
    await getMstInfo({
      reqMstNamesArr: reqMstNames,
    })
      .then((response) => {
        if (response.status === 200 && response.data) {
          response = response.data;
          this.mstTabooAllergy = response.mstTabooAllergyIncludeDeleted;
          this.mstMedicine = response.mstMedicineIncludeDeleted;
          this.mstEquipment = response.mstEquipmentIncludeDeleted;
          this.mstDialyzer = response.mstDialyzerIncludeDeleted;
          this.sysGenericMedicine = response.sysGenericMedicineIncludeDeleted;
          this.mstInfection = response.mstInfection;
          this.mstMedicineMix = response.mstMedicineMixIncludeDeleted;
          this.mstImplant = response.mstImplant;
        }
      })
      .catch(() => {
        getErrorMessage("SharingDetailHeaderComponent.vue", "created", "マスタ取得失敗");
        throw new Error("[SharingDetailHeaderComponent.vue]created(): マスタ取得失敗");
      });
    this.rebuildAcceptanceStatusInfo();

    if (this.path !== "pat-viewer") {
      this.setLoadingScreenVisible(false);
    }
  },

  mounted() {
    if (this.getWeightMode.isWeightMode) {
      this.calPatNameAreaWidthWeightMode();
    }
  },

  beforeUnmount() {
    this.setIsPatInfoVisible(false);
    this.timerManager.destroy();
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    getWidthByClass(className) {
      const el = document.getElementsByClassName(className)[0];
      return el ? el.clientWidth : 0;
    },

    getWidthById(id) {
      const el = document.getElementById(id);
      return el ? el.clientWidth : 0;
    },

    getFirstChildWidthByClass(className) {
      const parent = document.getElementsByClassName(className)[0];
      return parent && parent.firstElementChild
        ? parent.firstElementChild.clientWidth
        : 0;
    },
    menuDisplay() {
      let name = document.getElementById("menu-bar-id");
      if (name.classList.contains("block")) {
        this.direction = "right";
        document.getElementById("menu-btn").style.marginLeft = "-14px";
        document
          .getElementById("menu-bar-id")
          .setAttribute("class", "menu-bar-contents button-size none");
        document.getElementsByClassName("card-infos")[0].style.marginLeft =
          "0px";
      } else {
        this.direction = "left";
        document.getElementById("menu-btn").style.marginLeft = "130px";
        document
          .getElementById("menu-bar-id")
          .setAttribute("class", "menu-bar-contents button-size block");
        document.getElementsByClassName("card-infos")[0].style.marginLeft =
          "143px";
      }
    },
    changeBodyClass() {
      return this.getWeightMode.isWeightMode ? "pat-header_mode" : "pat-header";
    },
    mstCdToName,
    ...mapActions("pat-info", [
      "selectSharePat",
      "rebuildAcceptanceStatusInfo",
      "clearSelectedPat",
    ]),
    ...mapActions("loading-screen", [
      "setLoadingScreenMessage",
      "setLoadingScreenVisible",
    ]),
    ...mapActions("pat-info-sharing", [
      "setUnfinishedShareFlg",
      "fetchShrDetailsInfoList",
      "setSelectedPatId",
    ]),
    ...mapMutations("pat-info", {
      setIsPatInfoPageShowing: "setIsPatInfoPageShowing",
      setIsPatInfoVisible: "setIsPatInfoVisible",
      setIsNullShrPat: "setIsNullShrPat",
    }),
    ...mapGetters("user", ["getUserAuthorityCds"]),

    async clickHeader() {
      if (this.getUnfinishedShareFlg) {
        return true;
      }
      if (this.path == "pat-info") {
        return true;
      }
      if (this.selectedPat !== null) {
        if (!this.hasNextAuthority(functionCd.FUNC_PAT_INFO)) {
          return true;
        }
      } else {
        if (this.isPatInfoVisible) this.setIsPatInfoVisible(false);
        return true;
      }

      if (!this.isPatInfoVisible) {
        this.setIsPatInfoVisible(true);
      } else {
        if (this.isPatInfoChaned) {
          await this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[13000004].title,
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: (answer) => {
              if (answer !== 0) {
                this.isPatInfoChaned(false);
                this.setIsPatInfoVisible(false);
              }
            },
          });
        } else {
          this.setIsPatInfoVisible(false);
        }
      }
    },

    mstCdToNameOrNull(mstData, mstCd, mstCdColumn, mstNameColumn) {
      const returnName = mstCdToName(
        mstData,
        mstCd,
        mstCdColumn,
        mstNameColumn
      );
      if (returnName == null) {
        return "削除済み";
      }
      return returnName;
    },

    checkPatInfoLongPress(isMouseDown) {
      if (isMouseDown) {
        this.blowTimer = setTimeout(() => {
          this.showSearchPopover();
        }, 5000);
      } else {
        if (!this.popoverVisible) {
          this.clickHeader();
        }
        clearTimeout(this.blowTimer);
      }
    },

    showSearchPopover() {
      this.popoverTarget = this.$refs.displayPos;
      this.popoverVisible = true;
    },

    async setSelectedPat(selectedPatId, selectedFacility) {
      this.setIsNullShrPat(false);
      if (selectedPatId === null) {
        this.clearSelectedPat();
        this.setIsNullShrPat(true);
      } else {
        await this.selectSharePat({
          selectedPatId,
          selectedFacility,
          unfinishedShareFlg: this.getUnfinishedShareFlg,
        }).catch(() => {
          getErrorMessage("SharingDetailHeaderComponent.vue", "selectSharePat", "患者選択失敗");
          throw new Error("[SharingDetailHeaderComponent.vue]selectSharePat(): 患者選択失敗");
        });
        await this.fetchShrDetailsInfoList(selectedPatId);
      }
    },

    async selectPatPre() {
      if (this.isPatInfoVisible) return;
      if (this.isPatInfoChaned) {
        let isCanceled = false;
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: (answer) => {
            if (answer === 0) {
              isCanceled = true;
            } else {
              this.isPatInfoChaned(false);
            }
          },
        });
        if (isCanceled) return;
      }
      if (this.getStateUserAccountInfo.patId !== null) return;
      if (this.isCannotSwipe) return;
      if (this.selectedPatIdIndex != -1) {
        const prePatIdIndex =
          this.selectedPatIdIndex === 0
            ? this.patIdList.length - 1
            : this.selectedPatIdIndex - 1;
        const prePatId = this.patIdList[prePatIdIndex].patId;
        const preHostPatId = this.hospPatIdList[prePatIdIndex].hospPatId;
        const hasHospPatId = Boolean(preHostPatId);
        this.setUnfinishedShareFlg(!hasHospPatId);
        this.setSelectedPat(prePatId);
        this.setSelectedPatId(prePatId);
      }
    },

    async selectPatNext() {
      if (this.isPatInfoVisible) return;
      if (this.isPatInfoChaned) {
        let isCanceled = false;
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: (answer) => {
            if (answer === 0) {
              isCanceled = true;
            } else {
              this.isPatInfoChaned(false);
            }
          },
        });
        if (isCanceled) return;
      }
      if (this.getStateUserAccountInfo.patId !== null) return;
      if (this.isCannotSwipe) return;
      if (this.selectedPatIdIndex != -1) {
        const nextPatIdIndex =
          this.selectedPatIdIndex === this.patIdList.length - 1
            ? 0
            : this.selectedPatIdIndex + 1;
        const nextPatId = this.patIdList[nextPatIdIndex].patId;
        const nextHostPatId = this.hospPatIdList[nextPatIdIndex].hospPatId;
        const hasHospPatId = Boolean(nextHostPatId);
        this.setUnfinishedShareFlg(!hasHospPatId);
        this.setSelectedPat(nextPatId);
        this.setSelectedPatId(nextPatId);
      }
    },

    getPatPersonalMainColumnData(columnName) {
      return this.selectedPat.pat_personal_main[columnName];
    },

    getPatMainColumnData(columnName) {
      return this.selectedPat.pat_main[columnName];
    },

    showInfection(event) {
      this.isInfectionVisible = true;
      this.popoverTarget = event;
    },

    showTabooAllergy(event) {
      this.isTabooAllergyVisible = true;
      this.popoverTarget = event;
    },

    showImplant(event) {
      this.isImplantVisible = true;
      this.popoverTarget = event;
    },

    extractMedicineNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        PAT_HEADER.CLASS_MEDICINE,
        this.mstMedicine,
        "medicineCd",
        "medicineName"
      );
    },
    extractMedicineMixNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        PAT_HEADER.CLASS_MEDICINMIX,
        this.mstMedicineMix,
        "medicineMixCd",
        "medicineMixName"
      );
    },

    extractEquipNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        PAT_HEADER.CLASS_EQUIPMENT,
        this.mstEquipment,
        "equipmentCd",
        "equipmentName"
      );
    },

    extractDialyzerNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        PAT_HEADER.CLASS_DIALYZER,
        this.mstDialyzer,
        "dialyzerCd",
        "modelNumber"
      );
    },

    extractGenericMedicineNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        PAT_HEADER.CLASS_GENERIC_MEDICINE,
        this.sysGenericMedicine,
        "genericCd",
        "genericName"
      );
    },

    extractFreeWordNameFromDetail(tabooAllergyDetail) {
      if (tabooAllergyDetail === undefined) {
        return;
      }
      return tabooAllergyDetail
        .filter((detail) => detail.classCd === PAT_HEADER.CLASS_FREEWORD)
        .map((detail) =>
          detail.isDispDeleted ? PAT_HEADER.DELETED + detail.name : detail.name
        );
    },

    extractTabooAllergyNameFromDetail(
      tabooAllergyDetail,
      tabooAllergyClass,
      mst,
      cdColumn,
      nameColumn
    ) {
      if (tabooAllergyDetail === undefined) {
        return;
      }
      return tabooAllergyDetail
        .filter(
          (detail) =>
            detail.classCd === tabooAllergyClass &&
            detail.tabooAllergyDeleted != true
        )
        .map((detail) =>
          mstCdToNameIncludeExpiredAndDeleted(
            mst,
            detail.cd,
            cdColumn,
            nameColumn,
            detail.isDispDeleted
          )
        );
    },

    collectAllTabooAllergyDetail(tabooAllergyClass) {
      if (this.mstTabooAllergy === null) {
        return;
      }

      const tabooAllergy = [];
      const otherDetailInfoList = [];
      this.tabooAllergyData.forEach((el) => {
        if (el.category_class === "0" || el.category_class === "5") {
          tabooAllergy.push(el);
        } else {
          if (el.taboo_allergy_class === tabooAllergyClass) {
            otherDetailInfoList.push({
              classCd: el.category_class,
              cd: el.taboo_allergy_cd,
            });
          }
        }
      });

      if (_.isEmpty(tabooAllergy) && _.isEmpty(otherDetailInfoList)) {
        return;
      }

      const allDetail = [...otherDetailInfoList];
      for (const taboo of tabooAllergy) {
        if (taboo.taboo_allergy_cd !== null) {
          if (tabooAllergyClass === taboo.taboo_allergy_class) {
            const targetMst = this.mstTabooAllergy.find(
              (mst) => mst.tabooAllergyCd === taboo.taboo_allergy_cd
            );
            if (targetMst !== undefined) {
              if (targetMst.detailInfo !== null) {
                const detailInfo = JSON.parse(targetMst.detailInfo).map(
                  (item) => {
                    return {
                      ...item,
                      tabooAllergyCd: targetMst.tabooAllergyCd,
                      tabooAllergyDeleted:
                        targetMst.isDisp === "0" || targetMst.isDel === "1",
                    };
                  }
                );
                allDetail.push(...detailInfo);
              }
            }
          }
        } else {
          if (tabooAllergyClass === taboo.taboo_allergy_class) {
            const detailInfo = {
              cd: null,
              name: taboo.content,
              classCd: PAT_HEADER.CLASS_FREEWORD,
              tabooAllergyCd: taboo.taboo_allergy_cd,
              tabooAllergyDeleted: false,
              type: null,
            };
            allDetail.push(detailInfo);
          }
        }
      }

      const allDetailProcessed = allDetail.map((detail) => {
        const isAllDeleted = allDetail
          .filter(
            (item) => item.cd === detail.cd && item.classCd === detail.classCd
          )
          .every((item) => {
            return item.tabooAllergyDeleted;
          });

        return {
          ...detail,
          isDispDeleted: isAllDeleted,
        };
      });

      return deduplicateObjects(allDetailProcessed, "classCd", "cd", "name");
    },

    formatDate(date) {
      return date === null ? null : moment(date).format("YYYY/MM/DD");
    },

    showFromToDateString(from, to) {
      if ((from == null || from == "") && (to == null || to == "")) {
        return "";
      } else if ((from == null || from == "") && to != null && to != "") {
        return "～ " + this.formatDate(to);
      } else if (from != null && from != "" && (to == null || to == "")) {
        return this.formatDate(from) + " ～ ";
      } else {
        return this.formatDate(from) + " ～ " + this.formatDate(to);
      }
    },
    calPatNameAreaWidth() {
      if (this.getWeightMode.isWeightMode) {
        this.calPatNameAreaWidthWeightMode();
        return;
      }

      const getFirstElementByClassName = (className) => {
        const elements = document.getElementsByClassName(className);
        return elements.length > 0 ? elements[0] : null;
      };

      const patInfoArea = getFirstElementByClassName(
        "pat-header-pat-info-area"
      );
      if (patInfoArea) {
        patInfoArea.style.display = "inline-block";
      }
      const treatmentTimeArea = getFirstElementByClassName(
        "treatment-time-area"
      );
      if (treatmentTimeArea) {
        treatmentTimeArea.style.display = "inline-block";
      }

      const nameArea = document.getElementById("pat-header-pat-name");
      if (
        nameArea &&
        nameArea.classList &&
        nameArea.classList.contains("pat-create")
      ) {
        return;
      }

      const header = document.getElementsByClassName("pat-header")[0];
      if (!header) return;
      const calcPatNameMaxWidth = () => {
        return (
          this.getWidthByClass("pat-header") -
          this.getWidthByClass("search-button-area") -
          this.getWidthByClass("pat-icon-area") -
          this.getFirstChildWidthByClass("patinfo-treattime-area-scroll") -
          this.getWidthById("user-menu")
        );
      };
      let patNameMaxWidth = getFirstElementByClassName("pat-header")
        ? calcPatNameMaxWidth()
        : 0;

      const patNameMinWidth =
        375 -
        this.getWidthByClass("search-button-area") -
        this.getWidthByClass("pat-icon-area") -
        this.getWidthById("user-menu");

      if (patNameMaxWidth < patNameMinWidth) {
        if (treatmentTimeArea) {
          treatmentTimeArea.style.display = "none";
        }

        patNameMaxWidth = calcPatNameMaxWidth();
      }

      if (patNameMaxWidth < patNameMinWidth) {
        if (patInfoArea) {
          patInfoArea.style.display = "none";
        }

        patNameMaxWidth = calcPatNameMaxWidth();
      }

      if (patNameMaxWidth < patNameMinWidth) {
        patNameMaxWidth = patNameMinWidth;
      }

      if (nameArea) {
        nameArea.style.fontSize = "3.5em";
      }

      const patNameArea = document.getElementById("pat-name-area");
      if (patNameArea) {
        patNameArea.style.minWidth = patNameMinWidth + "px";
        patNameArea.style.maxWidth = patNameMaxWidth + "px";
      }
      if (nameArea) {
        nameArea.style.maxWidth = patNameMaxWidth + "px";

        let changedWidth = nameArea.clientWidth;

        if (changedWidth >= patNameMaxWidth) {
          nameArea.style.fontSize = "2.5em";

          changedWidth = nameArea.clientWidth;
        }

        if (changedWidth >= patNameMaxWidth) {
          nameArea.style.fontSize = "1.5em";
        }
      }
    },

    calPatNameAreaWidthWeightMode() {
      if (document.getElementsByClassName("treatment-time-area").length > 0) {
        document.getElementsByClassName(
          "treatment-time-area"
        )[0].style.display = "none";
      }

      const header = document.getElementsByClassName("pat-header")[0];
      if (!header) return;

      let patNameMaxWidth =
        document.getElementsByClassName("pat-header")[0].clientWidth -
        document.getElementsByClassName("search-button-area")[0].clientWidth -
        document.getElementsByClassName("pat-icon-area")[0].clientWidth -
        document.getElementsByClassName("patinfo-treattime-area-scroll")[0]
          .firstElementChild.clientWidth -
        document.getElementById("user-menu").clientWidth;

      let patNameMinWidth = 410;

      if (patNameMaxWidth < patNameMinWidth) {
        patNameMaxWidth = patNameMinWidth;
      }

      document.getElementById("pat-header-pat-name").style.fontSize = "6em";

      document.getElementById("pat-name-area").style.minWidth =
        patNameMinWidth + "px";
      document.getElementById("pat-name-area").style.maxWidth =
        patNameMaxWidth + "px";
      document.getElementById("pat-header-pat-name").style.maxWidth =
        patNameMaxWidth + "px";

      let changedWidth = document.getElementById(
        "pat-header-pat-name"
      ).clientWidth;

      if (changedWidth >= patNameMaxWidth) {
        document.getElementById("pat-header-pat-name").style.fontSize = "5em";

        changedWidth = document.getElementById(
          "pat-header-pat-name"
        ).clientWidth;

        if (changedWidth >= patNameMaxWidth) {
          document.getElementById("pat-header-pat-name").style.fontSize = "4em";
        }
      }
    },

    sortAcceptanceStatusInfo(info) {
      let ret = JSON.parse(info);
      if (!(ret instanceof Array)) {
        ret = JSON.parse("[" + info + "]");
      }
      ret.sort(function (a, b) {
        if (a.class < b.class) {
          return -1;
        } else if (a.class > b.class) {
          return 1;
        } else if (b.start_date < a.start_date) {
          return -1;
        } else if (b.start_date > a.start_date) {
          return 1;
        } else if (a.start_date != null && b.start_date == null) {
          return -1;
        } else if (a.start_date == null && b.start_date != null) {
          return 1;
        } else if (b.ord_no < a.ord_no) {
          return -1;
        } else if (b.ord_no > a.ord_no) {
          return 1;
        } else {
          return 0;
        }
      });
      return ret;
    },
    acceptanceStatusInfo() {
      let ret = null;
      if (this.selectedPat != null && this.selectedPat.pat_main != null) {
        ret = this.sortAcceptanceStatusInfo(
          this.selectedPat.pat_main.acceptance_status_info
        );
      }
      return ret;
    },
    isTreatmentCount(num) {
      return num <= this.treatmentCount;
    },
    colorStyle(index) {
      let color;
      const classType = this.treatmentClassType(
        this.acceptanceStatusInfo(),
        index
      );
      if (classType === "1" || classType === "2") {
        color = "#42CB92";
      } else if (classType === "3") {
        color = "#2CA06F";
      } else if (classType === "4" || classType === "5") {
        color = "#557769";
      }
      return color;
    },

    treatmentcountStyle(index) {
      let color;
      const classType = this.treatmentClassType(
        this.acceptanceStatusInfo(),
        index
      );
      if (classType === "1" || classType === "2" || classType === "3") {
        color = "#050505";
      } else if (classType === "4" || classType === "5") {
        color = "white";
      }
      return `color: ${color};`;
    },

    treatmentTimeStyle(index) {
      return `border: 1px solid; color: ${this.colorStyle(
        index
      )}; height: 25px; width: ${120}px; border-radius: 25px; position: relative; background-color: white;`;
    },

    treatmentProgressStyle(index) {
      const info = this.acceptanceStatusInfo();
      return `background-color: ${this.colorStyle(
        index
      )}; height: 25px; width: ${
        this.treatmentProgress(info, index) + 25
      }px; border-radius: 25px;`;
    },

    treatmentProgress(info, index) {
      const classType = this.treatmentClassType(info, index);

      if (classType === "1" || classType === "2") {
        return 0;
      }
      if (classType === "4" || classType === "5") {
        return 95;
      }
      if (
        classType === "0" ||
        classType === "6" ||
        classType === null ||
        classType === undefined
      ) {
        return null;
      }

      const start_date_time = info[index].start_date_time;
      const treatment_time = info[index].treatment_time;
      if (start_date_time === null || treatment_time === null) {
        if (classType === "3") {
          return 0;
        }
        return null;
      }

      const treatmentStartDateTime = moment(start_date_time);
      const now = this.initDate != null ? this.initDate : moment();
      this.initDate = now;

      const treatmentProgressTime = now.diff(treatmentStartDateTime) / 60000;

      let treatmentTimeRatio = (treatmentProgressTime / treatment_time) * 100;
      treatmentTimeRatio *= 0.95;

      if (treatmentTimeRatio < 0) {
        return 0;
      }

      return treatmentTimeRatio >= 95 ? 95 : treatmentTimeRatio;
    },

    isTreatmentTime(index) {
      const info = this.acceptanceStatusInfo();
      return this.treatmentProgress(info, index) !== null;
    },

    treatmentClassType(info, index) {
      let ret = null;
      if (
        info &&
        index < info.length &&
        info[index] &&
        "class" in info[index]
      ) {
        ret = info[index].class;
      }
      return ret;
    },

    showAcceptanceStatusInfo(event) {
      this.popoverAcceptanceStatusInfoTarget = event;
      this.popoverAcceptanceStatusInfoVisible = true;
    },
    async updateAcceptanceStatusInfo() {
      this.popoverAcceptanceStatusInfoVisible = false;
      await this.$ons.notification.confirm({
        modifier: "info",
        title: DIALOG_MESSAGES[13000042].title,
        message: messageFormat(DIALOG_MESSAGES[13000042].message),
        callback: async (answer) => {
          if (answer == 1) {
            this.initDate = moment();
            this.rebuildAcceptanceStatusInfo();
          }
        },
      });
    },
  },
};
</script>

<style scoped>
.patinfo-select-area {
  width: 300px;
  min-width: 300px;
}
.select-style {
  width: 50%;
  min-width: 50%;
}
.card-list {
  font-size: 150%;
  position: absolute;
  top: 0;
  left: 0;
  width: 100% !important;
  height: calc(100vh - 145px) !important;
  overflow: auto !important;
  background-color: #ffffff;
  padding: 20px;
  box-sizing: border-box;
  z-index: 9999;
}
.card-list.small {
  top: 49.59px;
  height: calc(100% - 52px);
}

.card-list.medium {
  top: 62px;
  height: calc(100% - 64px);
}

.card-list.big {
  top: 68.19px;
  height: calc(100% - 71px);
}

.card-list.xbig {
  top: 80.59px;
  height: calc(100% - 82px);
}
.card-list.hidden {
  opacity: 0;
  height: 0;
  visibility: hidden;
}
.card-list :deep(.menu-bar) {
  position: absolute;
  left: 161px !important;
  top: 20px;
}
.card-list :deep(.card-infos) {
  height: 100% !important;
  margin-left: 143px;
  overflow-y: scroll;
}
.card-list :deep(.pat-info-header-area .btn-cancel),
.card-list :deep(.pat-info-header-area .btn-save) {
  position: absolute;
}

table,
table th,
table td {
  height: 100%;
}

.search-button {
  width: 2em;
  height: 6.2em;
  background-color: rgb(64, 64, 64);
  visibility: hidden;
}

.pat-header {
  width: 100%;
  height: 6.2em;
  background-color: var(--header-item-background-color);
  background-image: -webkit-linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  background-image: linear-gradient(
    rgba(210, 210, 210, 0.2) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  font-size: 1em;
  position: relative;
  overflow: visible !important;
}
:deep(.ntss-layout-split__header) {
  overflow: visible !important;
  position: relative !important;
  z-index: 1001;
}
.pat-header_mode {
  width: 100%;
  height: 8.5em;
  background-color: var(--header-item-background-color);
  background-image: -webkit-linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  background-image: linear-gradient(
    rgba(210, 210, 210, 0.2) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  font-size: 1em;
}
.event-area {
  color: var(--ntss-header-color);
  width: 100%;
  border-collapse: collapse;
  table-layout: auto;
}

.search-button-area {
  width: 2em;
}

.pat-name-area {
  width: 20em;
}

.hosp-pat-id {
  width: 100%;
  font-size: 1.1em;
  display: inline-block;
  word-break: keep-all;
}

.same-icon {
  height: 1em;
  display: inline-block;
  margin-left: 0.5em;
  vertical-align: -0.1em;
}

.loading-modal {
  text-align: center;
  font-size: 30px;
}

.pat-icon-area {
  width: 80px;
  min-width: 80px;
  vertical-align: top;
}

.in-out-area {
  margin-top: 0.5em;
}

.icon-area {
  font-size: 22px;
}

.patinfo-treattime-area {
  max-width: calc(100% - 4em - 285px);
  font-size: 1.5em;
  vertical-align: top;
}

.patinfo-treattime-area-scroll {
  overflow-x: auto;
}

.patinfo-treattime-area-scroll::-webkit-scrollbar {
  display: none;
}

.pat-header-pat-info-area {
  width: 10em;
  display: inline-block;
  margin-top: 0.5em;
}
.pat-name {
  display: inline-block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 3.5em;
}
.pat-name-in-hospital {
  color: rgb(163, 86, 163);
}

.pat-create {
  display: inline-block;
  width: auto;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.taboo-allergy-area {
  color: red;
}

.infect-area {
  color: orange;
}

.implant-area {
  color: yellow;
}

.treatment-time-area {
  position: relative;
  width: max-content;
  margin-right: 2em;
  display: inline-block;
  cursor: pointer;
}

.treatment-count-area {
  position: absolute;
  color: var(--ntss-base-color);
  line-height: 28px;
  display: flex;
  width: 100%;
  justify-content: center;
}

@media screen and (max-width: 500px) {
  .pat-header-pat-info-area,
  .treatment-time-area,
  .patinfo-treattime-area-scroll-child {
    display: none;
  }

  .pat-icon-area {
    padding-right: 15px;
  }

  .hosp-pat-id {
    font-size: 11px;
  }
}
@media screen and (min-height: 650px) {
  .taboo-allergy-popover-div,
  .infection-popover-div,
  .implant-popover-div {
    max-height: 600px !important;
  }
}

.vons-popover :deep(.popover__content) {
  max-width: 500px;
  margin: 3px;
}

.infection-item :deep(.calender) {
  display: none;
}

.infection-popover :deep(.popover__content) {
  max-width: 500px;
  margin: 3px;
}

.infection-popover :deep(input[type="date"]) {
  width: 100%;
}

.implant-popover :deep(.popover__content) {
  max-width: 500px;
  margin: 3px;
}

.taboo-allergy-popover-div,
.implant-popover-div {
  padding: 25px;
  overflow: auto;
  height: calc(100% - 50px);
}

.infection-popover-div {
  padding: 15px;
  overflow: auto;
  height: calc(100% - 30px);
}

.acceptance-status-info-popover :deep(.popover--top) {
  max-width: 150px;
}
.acceptance-status-info-popover :deep(.popover__content) {
  min-height: auto;
  margin: 3px 3px 3px 0;
}
.acceptance-status-info-popover :deep(.acceptance-status-info-area) {
  max-height: 10em;
  margin: 5px 0 0 5px;
  overflow-y: auto;
}
.acceptance-status-info-popover :deep(.acceptance-status-info-bar) {
  padding: 1px 3px 3px 1px;
}
.acceptance-status-info-popover :deep(.acceptance-statusn-info-button-area) {
  text-align: right;
  padding: 5px;
}
.acceptance-status-info-popover :deep(.common-style-ok-button) {
  width: 100%;
}
.popover-style :deep(.popover__content) {
  width: 300px;
  height: 2em;
  font-size: 2em;
  margin: 3px;
}
.pat-icon {
  max-height: 30px;
  max-width: 26px;
  display: inline-block;
  cursor: pointer;
}
.pat-info-header-area {
  width: 100%;
  height: calc(100% - 40px);
}
@media screen and (max-width: 600px) {
  #pat-name-area {
    width: 15em !important;
  }
}
:deep(.ntss-layout-split__header) {
  position: relative !important;
  z-index: 2000 !important;
  overflow: visible !important;
}
:deep(.pat-info-header-area) {
  min-width: 1350px;
  height: auto !important;
  overflow: visible !important;
  display: block !important;
  border: none;
}
:deep(.pat-info-header-area > div) {
  height: auto !important;
  overflow: visible !important;
}
:deep(.menu-btn) {
  margin-left: 130px;
}
:deep(.pat-info-header-area .btn-group) {
  bottom: 45px !important;
  z-index: 2;
}
</style>
