<template>
  <!-- add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
  <master-picker
    :initItem="innerInitItem"
    :editItem="innerEditItem"
    :popoverData="innerPopoverData"
    :bizDirection="directionByBiz"
    :selectedItemClass="selectedItemClass"
    :backgroundColor="backgroundColor"
    :btnClass="btnClass"
    :btnDisabled="btnDisabled"
    :btnVisible="btnVisible"
    :popoverAnchorElement="popoverAnchorElement"
    :buttonName="buttonName"
    :visible="visible"
    :hasUnregisteredOption="hasUnregisteredOption"
    :isSelectionRequired="isSelectionRequired"
    @create-popover-data="createPopover"
    @popover-close="$emit('popover-close')"
    @popover-return="handlePopoverReturn"
    @master-load-more="onMasterLoadMore"
    @master-reset-request="onMasterResetRequest"
  />
  <!-- add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
</template>

<script>
import MasterPicker from "@/components/common/master-selector/MasterPicker";
import {
  buildMasterPopover,
  buildInitSelectedItem,
  getPaginatedComposeHandlers,
} from "@/components/common/master-selector/builder/builderFactory";
import { FACILITY_PAT_INFO_FAVORITE_PREF_CD } from "@/components/common/master-selector/builder/masterPaginationRegistry";
import { MASTER } from "@/components/common/master-selector/MasterType";
import {
  appendChangedOptionsIfNeeded,
  buildUnregisteredMasterItem,
  isUnregisteredMasterItem,
  removePrefixFromOptions,
  handleMasterLoadError,
  normalizeTextForCompare,
} from "@/components/common/master-selector/utils/MasterSelectorUtil";
import { cloneDeep } from "@/compat/collections/lodash";

export default {
  name: "CommonMasterSelector",
  components: { MasterPicker },
  emits: [
    "popover-open",
    "popover-close",
    "popover-return",
    "update:initItem",
    "update:editItem",
  ],

  props: {
    btnDisabled: Boolean,
    btnVisible: {
      type: Boolean,
      default: true,
    },
    masterType: {
      type: String,
      required: true,
    },
    initItem: {
      type: Object,
      default: () => ({}),
    },
    editItem: {
      type: Object,
      default: () => ({}),
    },
    patientId: {
      type: [String, Number],
    },
    facilityCd: {
      type: [String, Number],
    },
    extraParams: {
      type: Object,
      default: () => ({}),
    },
    popoverAnchorElement: {
      default: null,
    },
    selectedItemClass: {
      type: [Object, String, Array],
      default: () => ({}),
    },
    btnClass: {
      type: [Object, String, Array],
      default: () => ({}),
    },
    backgroundColor: {
      type: String,
    },
    hasUnregisteredOption: {
      type: Boolean,
      default: true,
    },
    hasChangedOption: {
      type: Boolean,
      default: false,
    },
    changeOptionMode: {
      type: String,
      default: "nameOnly",
      validator: (v) => ["nameOnly", "nameAndUnit"].includes(v),
    },
    
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    btnName: {
      type: String,
    },
    isVisible: {
      type: Boolean,
      default: true,
    },
    isMedicament: {
      type: String,
      default: "0"
    },
    dialysisState: {
      type: Number,
      default: 0
    },
    allowedFields: {
      type: [Object, String, Array],
      default: () => ({}),
    },
    
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    isSelectionRequired: {
      type: Boolean,
      default: false
    },
    beforeCreatePopover: {
      type: Function,
      default: null,
    },
    popoverExtraClass: {
      type: String,
      default: "",
    },
  },

  data() {
    return {
      /** facility_pat_info：mst-list-compose キーワード再検索用 */
      composeKeyword: "",
      innerInitItem: {},
      innerEditItem: {},
      innerPopoverData: {},
      buttonName:'',
      visible:true,
    };
  },

  watch: {
    initItem: {
      immediate: true,
      deep: true,
      handler(val) {
        this.innerInitItem = cloneDeep(val || {});
      },
    },
    editItem: {
      immediate: true,
      deep: true,
      handler(val) {
        this.innerEditItem = cloneDeep(val || {});
      },
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    btnName:{
      immediate: true,
      handler(val) {
        this.buttonName = cloneDeep(val || '選択');
      },
    },
    isVisible:{
      immediate: true,
      handler(val) {
        this.visible = cloneDeep(val);
      },
    },
    
    //add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
  },

  computed: {
    directionByBiz() {
      const master = MASTER[this.masterType];
      return master && master.popoverDirection != null ? master.popoverDirection : null;
    },
  },

  methods: {
    async initSelector() {
      try {
        const result = await buildInitSelectedItem(
          this.masterType,
          this.createContext()
        );
        if (!result) return;

        const newInitItem = cloneDeep(result.initItem || {});
        const newEditItem = cloneDeep(result.selectedItem || {});
        this.innerInitItem = newInitItem;
        this.innerEditItem = newEditItem;
        this.$emit("update:initItem", newInitItem);
        this.$emit("update:editItem", newEditItem);
      } catch (e) {
        console.error("[CommonMasterSelector] 初期選択生成失敗", e);
        handleMasterLoadError(e, "initSelector");
      }
    },

    openPopover() {
      return this.createPopover();
    },

    async createPopover() {
      if (!this.masterType) return;
      try {
        if (typeof this.beforeCreatePopover === "function") {
          await this.beforeCreatePopover(this.createContext());
        }
        const popoverData = await buildMasterPopover(
          this.masterType,
          this.createContext()
        );
        if (!popoverData) return;
        appendChangedOptionsIfNeeded(popoverData, this.createContext());
        this.alignMasterSelectedToEditItem(popoverData);

        this.innerPopoverData = cloneDeep(popoverData || {});
        this.composeKeyword = "";
        if (this.popoverExtraClass) {
          this.innerPopoverData.popoverExtraClass = this.popoverExtraClass;
        }
        ((this.innerPopoverData)["popoverVisible"] = true);

        this.$emit("popover-open", {
          masterType: this.masterType,
          popoverData: cloneDeep(this.innerPopoverData),
        });
      } catch (e) {
        console.error("[CommonMasterSelector] Popover生成失敗", e);
        handleMasterLoadError(e, "createPopover");
      }
    },
    alignMasterSelectedToEditItem(popoverData) {
      const sel = this.innerEditItem;
      if (!popoverData?.master || !sel) return;
      if (isUnregisteredMasterItem(sel)) {
        popoverData.master.selectedItem = buildUnregisteredMasterItem(sel);
        return;
      }
      const opts = popoverData?.master?.options;
      if (!Array.isArray(opts) || !opts.length) return;
      const sameV = opts.filter(o => String(o.value) === String(sel.value));
      if (!sameV.length) return;
      let pick = null;

      if (sameV.length > 1) {
        const selTextNorm = normalizeTextForCompare(sel.text);
        const selUnit = String(sel.unit ?? "");
        const selUnitSecond = String(sel.unitSecond ?? "");
        const selProc = String(sel.procedureCd ?? sel.procedure_cd ?? "");
        const selTiming = String(
          sel.medicateTimingCd ??
            sel.medicate_timing_cd ??
            sel.timingCd ??
            sel.timing_cd ??
            ""
        );
        const eqIfPresent = (selVal, optVal) => (selVal !== "" ? optVal === selVal : true);
        const hasChangedRow = sameV.some(o => o && o.__isMasterChangedRow === true);
        const canDiscriminateBySel =
          selUnit !== "" || selUnitSecond !== "" || selProc !== "" || selTiming !== "";
        if (hasChangedRow && canDiscriminateBySel) {
          pick = sameV.find(o => {
            const oTextNorm = normalizeTextForCompare(o.text);
            const oUnit = String(o.unit ?? "");
            const oUnitSecond = String(o.unitSecond ?? "");
            const oProc = String(o.procedureCd ?? o.procedure_cd ?? "");
            const oTiming = String(
              o.medicateTimingCd ??
                o.medicate_timing_cd ??
                o.timingCd ??
                o.timing_cd ??
                ""
            );
            return (
              oTextNorm === selTextNorm &&
              eqIfPresent(selUnit, oUnit) &&
              eqIfPresent(selUnitSecond, oUnitSecond) &&
              eqIfPresent(selProc, oProc) &&
              eqIfPresent(selTiming, oTiming)
            );
          });
        }
      }
      if (sel.text != null && sel.text !== "" && !pick) {
        pick =
          sameV.find(o => String(o.text) === String(sel.text)) ||
          sameV.find(
            o => normalizeTextForCompare(o.text) === normalizeTextForCompare(sel.text)
          );
      }
      if (!pick && sameV.length === 1) pick = sameV[0];
      if (!pick && sameV.length) pick = sameV[0];
      if (pick) {
        popoverData.master.selectedItem = pick;
      }
    },
    async onMasterLoadMore() {
      const paginatedHandlers = getPaginatedComposeHandlers(this.masterType);
      if (!paginatedHandlers?.appendPage) return;
      const pagination = this.innerPopoverData?.master?.pagination;
      if (
        !pagination ||
        pagination.mode !== "paged" ||
        !pagination.hasMore ||
        pagination.loading
      ) {
        return;
      }
      pagination.loading = true;
      try {
        const result = await paginatedHandlers.appendPage(
          this.innerPopoverData,
          this.createContext()
        );
        if (!result?.newOptions?.length) {
          pagination.hasMore = false;
          return;
        }
        const merged = [
          ...(this.innerPopoverData.master.options || []),
          ...result.newOptions,
        ];
        const seen = new Set();
        const deduped = merged.filter(option => {
          const key = String(option.value ?? "");
          if (seen.has(key)) return false;
          seen.add(key);
          return true;
        });
        this.innerPopoverData.master.options = deduped;
        pagination.page = result.nextPage;
        pagination.hasMore = result.hasMore === true;
      } catch (e) {
        console.error("[CommonMasterSelector] master-load-more 失敗", e);
        handleMasterLoadError(e, "onMasterLoadMore");
      } finally {
        pagination.loading = false;
      }
    },

    async onMasterResetRequest(payload) {
      const paginatedHandlers = getPaginatedComposeHandlers(this.masterType);
      if (!paginatedHandlers?.fetchPage) return;
      const prefecturesCd =
        payload && payload.prefecturesCd != null ? payload.prefecturesCd : null;
      const keyword =
        payload && payload.keyword != null ? String(payload.keyword) : "";
      this.composeKeyword = keyword;
      try {
        const cachedFavoriteCds =
          this.innerPopoverData.favoriteFacilityMedicalInstitutionCds;
        const isFavoritePref =
          prefecturesCd == null ||
          String(prefecturesCd) === FACILITY_PAT_INFO_FAVORITE_PREF_CD;
        const next = await paginatedHandlers.fetchPage(this.createContext(), {
          prefecturesCategoryValue: prefecturesCd,
          keyword: this.composeKeyword,
          page: 0,
          alignPrefectureToSelection: false,
          favoriteCds: isFavoritePref
            ? undefined
            : Array.isArray(cachedFavoriteCds)
              ? cachedFavoriteCds
              : [],
        });
        this.applyRefetchedPopover(next);
      } catch (e) {
        console.error("[CommonMasterSelector] master-reset-request 失敗", e);
        handleMasterLoadError(e, "onMasterResetRequest");
      }
    },

    applyRefetchedPopover(next) {
      if (!next || !this.innerPopoverData) return;
      this.innerPopoverData.headerTitle = next.headerTitle;
      this.innerPopoverData.categories = next.categories;
      this.innerPopoverData.master = { ...next.master };
      this.innerPopoverData.favoriteFacilityMedicalInstitutionCds =
        next.favoriteFacilityMedicalInstitutionCds;
      appendChangedOptionsIfNeeded(this.innerPopoverData, this.createContext());
      this.alignMasterSelectedToEditItem(this.innerPopoverData);
    },

    async handlePopoverReturn(item) {
      try {
        const resultItem = removePrefixFromOptions(item, this.createContext());
        this.innerEditItem = cloneDeep(resultItem);
        if (this.innerPopoverData && this.innerPopoverData.master) {
          ((this.innerPopoverData.master)["selectedItem"] = cloneDeep(resultItem));
        }
        this.$emit("popover-return", cloneDeep(resultItem));
      } catch (e) {
        console.error("[CommonMasterSelector] Popover返却失敗", e);
        handleMasterLoadError(e, "handlePopoverReturn");
      }
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    createContext() {
      return {
        vm: this,
        masterType: this.masterType,
        patientId: this.patientId,
        facilityCd: this.facilityCd,
        initItem: this.innerInitItem,
        selectedItem: this.innerEditItem,
        extraParams: this.extraParams,
        hasChangedOption: this.hasChangedOption,
        changeOptionMode: this.changeOptionMode,
        isMedicament: this.isMedicament,
        dialysisState: this.dialysisState,
        allowedFields: this.allowedFields,
        composeKeyword: this.composeKeyword,
      };
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
  },
};
</script>
