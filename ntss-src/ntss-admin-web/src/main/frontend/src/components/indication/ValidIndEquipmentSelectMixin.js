/**
 * 共通部品 医療材料選択(指示有効なマスタからの選択).
 */
import { mapMutations, mapGetters, mapActions } from "@/compat/vue/vuex";
import { encryptPersistentCodeToInternalCd } from "@/functions/EquipTypeFunctions";
import { ApiHelper } from "@/apis/AxiosHelper";
import { EventBus } from "@/compat/vue/event-bus.js";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import IndicationOwnerMixin from "@/components/indication/IndicationOwnerMixin";
import {
  buildValidIndEquipmentListData,
  fetchValidIndEquipmentsList,
  loadValidIndMasterData,
  resolveInitialEquipmentDisplay,
  shapeDateFormat,
} from "@/components/indication/validIndEquipmentData";

export default {
  mixins: [IndicationOwnerMixin],
  props: {
    fieldsData: {
      type: Object,
      default: () => ({
        cd: null,
        amount: 0,
        unit: null,
        equipType: 0,
      }),
    },
    showAllSelectTag: {
      type: Boolean,
      default: false,
    },
  },

  data() {
    return {
      mstEquipmentClass: [],
      mstEquipment: [],
      mstDialyzer: [],
      validIndEquipments: [],
      mstEquipmentDialyzerIncludedDeleted: [],
      popoverDataValidIndEquipment: {
        popoverContentSelected: {},
      },
      currentOrdMainData: {},
      masterLabelForCd: null,
      rstNameForCd: null,
      forceShowAllSelectTag: false,
    };
  },

  computed: {
    ...mapGetters("pat-viewer", { getIndEndDate: "getIndEndDate" }),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["selectedPatId"]),

    indEditBaseComponent() {
      return this._indicationFlowOwner();
    },
    structData() {
      const owner = this.indEditBaseComponent;
      return owner && owner.structData ? owner.structData : null;
    },
    effectiveShowAllSelectTag() {
      return this.showAllSelectTag || this.forceShowAllSelectTag;
    },
  },

  watch: {
    structData: {
      handler() {
        this.executeWithLoadingScreen(
          () => this.getValidIndEquipments()
        );
      },
      deep: true,
      immediate: true,
    },
  },

  created() {
    this.forceShowAllSelectTag = true;
  },

  async mounted() {
    if (this.settingIndData && this.settingIndData.ordNo) {
      this.currentOrdMainData = await ApiHelper.get(
        `/mainData/getOrdMainByOrdNo/${this.settingIndData.ordNo}`
      );
    }
    await this.setUpMaster();
    try {
      await this.getValidIndEquipments();
      await this.syncDisplayFromListData();
    } catch (e) {
      getErrorMessage("ValidIndEquipmentSelectMixin.js", "mounted", e);
    }
  },

  methods: {
    ...mapMutations("pat-viewer-popover", ["setIndStartDate"]),
    ...mapActions("loading-screen", ["executeWithLoadingScreen"]),

    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },

    async beforeMasterCreatePopover() {
      await this.getValidIndEquipments();
    },

    async getValidIndEquipments() {
      if (!this.indEditBaseComponent || !this.structData) {
        return;
      }
      if (!this.facilityCd || this.selectedPatId == null || this.selectedPatId === "") {
        return;
      }
      const structData = this.structData;
      if (!structData.indWeeks || !Array.isArray(structData.indWeeks)) {
        return;
      }

      this.validIndEquipments = await fetchValidIndEquipmentsList(
        this.facilityCd,
        this.selectedPatId,
        structData
      );
      await this.syncDisplayFromListData();
    },

    async setUpMaster() {
      const treatDate = this.structData?.indStartDate || this.getIndStartDate;
      const loaded = await loadValidIndMasterData(
        this.facilityCd,
        this.selectedPatId,
        treatDate
      );
      this.mstEquipmentClass = loaded.mstEquipmentClass;
      this.mstEquipment = loaded.mstEquipment;
      this.mstDialyzer = loaded.mstDialyzer;
      this.mstEquipmentDialyzerIncludedDeleted =
        loaded.mstEquipmentDialyzerIncludedDeleted;

      let selectedEquipmentCd = this.fieldsData.cd;
      let selectedEquipmentEquipType = this.fieldsData.equipType;
      if (this.selectedEquipment?.cd) {
        selectedEquipmentCd = this.selectedEquipment.cd;
        selectedEquipmentEquipType = this.selectedEquipment.equipType;
      }

      this.popoverDataValidIndEquipment.popoverContentSelected =
        this.mstEquipmentDialyzerIncludedDeleted.find(
          equipment =>
            equipment.value ==
            encryptPersistentCodeToInternalCd(
              selectedEquipmentCd,
              selectedEquipmentEquipType
            )
        ) || {};
    },

    async syncDisplayFromListData() {
      if (!this.structData) return;
      const listData = await buildValidIndEquipmentListData({
        facilityCd: this.facilityCd,
        patientId: this.selectedPatId,
        structData: this.structData,
        fieldsData: this.fieldsData,
        showAllSelectTag: this.effectiveShowAllSelectTag,
        selectedEquipment: this.selectedEquipment,
        popoverContentSelected:
          this.popoverDataValidIndEquipment.popoverContentSelected,
        mstEquipmentClass: this.mstEquipmentClass,
        mstEquipment: this.mstEquipment,
        mstDialyzer: this.mstDialyzer,
        mstEquipmentDialyzerIncludedDeleted:
          this.mstEquipmentDialyzerIncludedDeleted,
        currentOrdMainData: this.currentOrdMainData,
        validIndEquipments: this.validIndEquipments,
        refreshValidList: false,
      });
      if (!listData) return;

      this.masterLabelForCd = listData.masterLabelForCd;
      this.rstNameForCd = listData.rstNameForCd;

      if (listData.selectedItem) {
        this.popoverDataValidIndEquipment.popoverContentSelected = listData.selectedItem;
      }

      const displayText = resolveInitialEquipmentDisplay(
        this.fieldsData.cd,
        this.fieldsData.equipType,
        this.mstEquipmentDialyzerIncludedDeleted,
        {
          currentOrdMainData: this.currentOrdMainData,
          persistentCd: this.fieldsData.cd,
        }
      );

      if (this.isActualRst && this.rstNameForCd) {
        this.equipmentInputValue.editValue = this.rstNameForCd;
        this.equipmentInputValue.initValue = this.rstNameForCd;
      } else if (displayText != null) {
        this.equipmentInputValue.editValue = displayText;
        this.equipmentInputValue.initValue = this.masterLabelForCd || displayText;
      }
    },

    shapeDateFormat,
  },
};
