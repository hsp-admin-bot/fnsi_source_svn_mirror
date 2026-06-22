<!-- 処方一覧画面 -->
<template>
  <div class='main-content-area kendo-grid-style-page' style="overflow: hidden;">
    <div
      class='prescription-list-main-content'
      @mousedown.capture="rememberGridCellEventTarget"
      @click.capture="rememberGridCellEventTarget"
    >
      <div
        ref='prescriptionlistgrid'
        class='prescription-list-direct-grid'
      ></div>
    </div>
    <popover-prescription-info
      ref="popoverPrescriptionInfo"
      v-if="popoverData.popoverVisible"
      v-bind="popoverData"
      :target-position-element="popoverTarget"
      :target-position-rect="popoverTargetRect"
      @popover-close="closePopover"
    />
  </div>
</template>

<script>
import $$ from "@/compat/jquery";
import Kendo from "@progress/kendo-ui";
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
import { sendRequestGetprescriptionList } from "@/apis/pat-prescription";
import dayjs from "@/compat/date/dayjs";
import PopoverMixin from "@/components/PopoverMixin";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
// #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
import { EventBus } from "@/compat/vue/event-bus.js";
// #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
import { sortableCompare } from "@/functions/SortFunctions";
import PrescriptionInfoContent from "@/components/prescription/PrescriptionInfoContent";
import nameDuplicationImg from "../../assets/name_duplication.png";
import { getMainContentAreaElement, getScopedElementById, resolveRefElement } from "@/functions/common/LayoutMeasureHelper";
import PrintMixin from "@/components/PrintMixin";

// カラム定数
const CNO_PAT_ID = 1;
const CNO_PAT_NAME = 2;
const CNO_DATE_INFO = 3;
const CNO_CLASS_INFO = 4;
const CNO_NEXT_STATE_INFO = 8;
const CNO_NEXT_DATE_INFO = 9;
const CNO_NEXT_CLASS_INFO = 10;
const CNO_PRE_1_DATE_INFO = 12;
const CNO_PRE_1_CLASS_INFO = 13;
const CNO_PRE_2_DATE_INFO = 16;
const CNO_PRE_2_CLASS_INFO = 17;
const CNO_PRE_3_DATE_INFO = 20;
const CNO_PRE_3_CLASS_INFO = 21;

// ソートキー変換用のマップ
const SORT_KEY_MAP = {
  p_save_state: "p_save_state_org",       // 指定日情報.交付
  p_class: "p_class_org",                 // 指定日情報.処方区分
  next_save_state: "next_save_state_org", // 次回処方.交付
  next_class: "next_class_org",           // 次回処方.処方区分
  pre_1_class: "pre_1_class_org",         // 前回処方.処方区分
  pre_2_class: "pre_2_class_org",         // 2回前処方.処方区分
  pre_3_class: "pre_3_class_org",         // 3回前処方.処方区分
  kur: "kur_start_time",                  // クール
  bed_name: "bed_order_index",            // ベッド
  treatment_method: "treatment_order_index" // 治療方法
};

export default {
  mixins: [PopoverMixin, PrintMixin],
  components: {
    "popover-prescription-info": PrescriptionInfoContent
  },
  data() {
    return {
      isChkDisabled: "",
      prescriptionDataSource1: {},
      treatDate: dayjs().format("YYYY/MM/DD"),
      popoverTarget: null,
      //ポップオーバーの呼び出し元の要素の表示位置
      popoverTargetPosition: {
        //行番号
        rowIndex: -1,
        //列番号
        colIndex: -1
      },
      popoverData: {
        // ポップオーバー表示フラグ
        popoverVisible: false,
        // 処方情報
        prescriptionInfoData: null,
        // 処方箋の詳細情報
        prescriptionDetailList: []
      },
      gridCellData: "",
      popoverTargetRect: null,
      // Grid 高さ
      kendoGridHeight: 300,
      firstLoadFlg: true,
      //自画面の名称
      selfScreenName: "",
      //同姓同名アイコン
      imageSrcSame: nameDuplicationImg,
      currentSort: null,
      scrollPosition: {
        top: 0,
        left: 0
      },
      resizeFlg: false,
      lastGridCellEventTarget: null,
      directGridWidget: null,
      directGridColumnSignature: "",
      directGridLayoutRafId: null,
      lockedScrollSyncCleanup: [],
      prescriptionGridScrollbarProxy: null,
      prescriptionGridBodyClickHandler: null,
      prescriptionGridHeaderClickHandler: null,
      // PrintMixin（Vue2 PrescriptionListComponent と同じ）
      scrollQuerySelector: ".k-grid-content",
      addClassTargetQuerySelector: [
        ".k-grid-header-wrap table",
        ".k-grid-content table"
      ],
      prescriptionGridPrintLayoutSnapshot: null
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      sidebarWidth: "getSidebarWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
      getPatientShareMode: "getPatientShareMode",
      getPatientShareFacilityCdMode: "getPatientShareFacilityCdMode"
    }),
    ...mapGetters("prescription/list", [
      "getCondition",
      "getOrdPreNo"
    ]),

    ...mapGetters("pat-info", [
      "searchedPatList",
      "selectedPatId",
      "getIsOtherFacility",
      "getOtherFacilityCd"
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-prescription", ["getRouteFlag", "getAppointedDate", "getInputModal", "getPrescriptionDetail"]),
    prescriptionGridColumns() {
      return [
        {
          field: "pat_id",
          hidden: true,
          locked: true,
          title: "患者ID(システムID)"
        },
        {
          field: "hosp_pat_id",
          hidden: false,
          locked: true,
          title: "患者ID",
          width: "160px",
          attributes: { class: 'hosp-pat-id-body' }
        },
        {
          field: "pat_name",
          hidden: false,
          locked: true,
          title: "患者名",
          template: `<span class="#: in_out_class === 1 ? 'in_class_prescription' : '' #">#: pat_name # ` +
                    `# if(is_same === '1'){ # <img src="#: image_src_same #" class="pat-name-same-icon"> # } #</span>`,
          width: "139.6px",
        },
        {
          field: "date_info",
          headerAttributes: {
            class: "no-click-cell"
          },
          hidden: false,
          title: "指定日情報 " + this.getAppointedDate,
          columns: [
            {
              // 処方-交付
              field: "p_save_state",
              hidden: false,
              title: "交付",
              width: "6em",
              attributes: {
                class: "ellipsis-cell"
              }
            },
            {
              // 処方-処方区分
              field: "p_class",
              hidden: false,
              title: "処方区分",
              width: "8em",
              attributes: {
                class: "ellipsis-cell"
              }
            },
            {
              // クール
              field: "kur",
              hidden: false,
              title: "クール",
              width: "8em",
              attributes: {
                class: "ellipsis-cell"
              }
            },
            {
              // ベッド
              field: "bed_name",
              hidden: false,
              title: "ベッド",
              width: "10em",
              attributes: {
                class: "ellipsis-cell"
              }
            },
            {
              // 治療
              field: "treatment_method",
              hidden: false,
              title: "治療方法", // mod #10184 処方画面文言修正 宮崎
              width: "6em",
              attributes: {
                class: "ellipsis-cell"
              }
            }
          ],
          values: [
            {
              value: 0
            }
          ]
        },
        {
          // 次回処方
          field: "next",
          headerAttributes: {
            class: "no-click-cell"
          },
          hidden: false,
          lockable: false,
          title: "次回処方",
          columns: [
            {
              // 次回処方-交付
              field: "next_save_state",
              hidden: false,
              title: "交付",
              width: "8em"
            },
            {
              // 次回処方-処方日
              field: "next_date",
              hidden: false,
              title: "処方日",
              width: "8em"
            },
            {
              // 次回処方-処方区分
              field: "next_class",
              hidden: false,
              title: "処方区分",
              width: "8em"
            },
          ],
          values: [
            {
              value: 1
            }
          ]
        },
        {
          // 前回処方日
          field: "pre_1",
          headerAttributes: {
            class: "no-click-cell"
          },
          hidden: false,
          lockable: false,
          title: "前回処方日",
          columns: [
            {
              // 前回処方日-チェック
              field: "pre_1_check",
              hidden: false,
              title: "Pre1CheckAll",
              headerTemplate: `<div style="">` +
                              `<input type="checkbox" ${ this.isChkDisabled } id="pre1-header-chb" class="checkbox__input header-checkbox">` +
                              `<span class="checkbox__checkmark"></span></div>`,
              template: `<div class="checkbox" # if(typeof pre_1_check === 'undefined' || pre_1_date == null || pre_1_date == ''){ # style="display: none;" # } #>` +
                        `<input type="checkbox" id="pre_1_check_#: pre_1_ord_pre_no #" class="checkbox__input"
                          # if(pre_1_disabled || '${this.isChkDisabled}' === 'disabled'){ # disabled # } #
                          # if(typeof pre_1_check !== 'undefined' && pre_1_check){ # checked # } #>` +
                        `<span class="checkbox__checkmark"></span></div>`,
              width: "4em",
              sortable: false,
              attributes: {
                class: "#= pre_1_disabled ? 'other-facility-cell' : '' #"
              }
            },
            {
              // 前回処方日-処方日
              field: "pre_1_date",
              hidden: false,
              title: "処方日",
              width: "8em",
              attributes: {
                class: "#= pre_1_disabled ? 'other-facility-cell' : '' #"
              }
            },
            {
              // 前回処方日-処方区分
              field: "pre_1_class",
              hidden: false,
              title: "処方区分",
              width: "8em",
              attributes: {
                class: "#= pre_1_disabled ? 'other-facility-cell' : '' #"
              }
            },
            {
              // 前回処方日-処方オーダー番号
              field: "pre_1_ord_pre_no",
              hidden: true,
              title: "処方オーダー番号"
            },
          ],
          values: [
            {
              value: 2
            }
          ]
        },
        {
          // 2回前処方日
          field: "pre_2",
          headerAttributes: {
            class: "no-click-cell"
          },
          hidden: false,
          lockable: false,
          title: "2回前処方日",
          columns: [
            {
              // 2回前処方日-チェック
              field: "pre_2_check",
              hidden: false,
              title: "Pre2CheckAll",
              headerTemplate: `<div style="">` +
                              `<input type="checkbox" ${ this.isChkDisabled } id="pre2-header-chb" class="checkbox__input header-checkbox">` +
                              `<span class="checkbox__checkmark"></span></div>`,
              template: `<div class="checkbox" # if(typeof pre_2_check === 'undefined' || pre_2_date == null || pre_2_date == ''){ # style="display: none;" # } #>` +
                        `<input type="checkbox" id="pre_2_check_#: pre_2_ord_pre_no #" class="checkbox__input"
                          # if(pre_2_disabled || '${this.isChkDisabled}' === 'disabled'){ # disabled # } #
                          # if(typeof pre_2_check !== 'undefined' && pre_2_check){ # checked # } #>` +
                        `<span class="checkbox__checkmark"></span></div>`,
              width: "4em",
              sortable: false,
              attributes: {
                class: "#= pre_2_disabled ? 'other-facility-cell' : '' #"
              }
            },
            {
              // 2回前処方日-処方日
              field: "pre_2_date",
              hidden: false,
              title: "処方日",
              width: "8em",
              attributes: {
                class: "#= pre_2_disabled ? 'other-facility-cell' : '' #"
              }
            },
            {
              // 2回前処方日-処方区分
              field: "pre_2_class",
              hidden: false,
              title: "処方区分",
              width: "8em",
              attributes: {
                class: "#= pre_2_disabled ? 'other-facility-cell' : '' #"
              }
            },
            {
              // 2回前処方日-処方オーダー番号
              field: "pre_2_ord_pre_no",
              hidden: true,
              title: "処方オーダー番号"
            },
          ],
          values: [
            {
              value: 2
            }
          ]
        },
        {
          // 3回前処方日
          field: "pre_3",
          headerAttributes: {
            class: "no-click-cell"
          },
          hidden: false,
          lockable: false,
          title: "3回前処方日",
          columns: [
            {
              // 3回前処方日-チェック
              field: "pre_3_check",
              hidden: false,
              title: "Pre3CheckAll",
              headerTemplate: `<div style="">` +
                              `<input type="checkbox" ${ this.isChkDisabled } id="pre3-header-chb" class="checkbox__input header-checkbox">` +
                              `<span class="checkbox__checkmark"></span></div>`,
              template: `<div class="checkbox" # if(typeof pre_3_check === 'undefined' || pre_3_date == null || pre_3_date == ''){ # style="display: none;" # } #>` +
                        `<input type="checkbox" id="pre_3_check_#: pre_3_ord_pre_no #" class="checkbox__input"
                          # if(pre_3_disabled || '${this.isChkDisabled}' === 'disabled'){ # disabled # } #
                          # if(typeof pre_3_check !== 'undefined' && pre_3_check){ # checked # } #>` +
                        `<span class="checkbox__checkmark"></span></div>`,
              width: "4em",
              sortable: false,
              attributes: {
                class: "#= pre_3_disabled ? 'other-facility-cell' : '' #"
              }
            },
            {
              // 3回前処方日-処方日
              field: "pre_3_date",
              hidden: false,
              title: "処方日",
              width: "8em",
              attributes: {
                class: "#= pre_3_disabled ? 'other-facility-cell' : '' #"
              }
            },
            {
              // 3回前処方日-処方区分
              field: "pre_3_class",
              hidden: false,
              title: "処方区分",
              width: "8em",
              attributes: {
                class: "#= pre_3_disabled ? 'other-facility-cell' : '' #"
              }
            },
            {
              // 3回前処方日-処方オーダー番号
              field: "pre_3_ord_pre_no",
              hidden: true,
              title: "処方オーダー番号"
            },
          ],
          values: [
            {
              value: 2
            }
          ]
        }
      ]
    }
  },
  methods: {
    getScopedElementByIdSafe(id) {
      return getScopedElementById(id, this.$el || null);
    },
    getScopedCheckboxChecked(id) {
      const checkbox = this.getScopedElementByIdSafe(id);
      return checkbox?.disabled !== true && checkbox?.checked === true;
    },
    setScopedCheckboxChecked(id, checked) {
      const checkbox = this.getScopedElementByIdSafe(id);
      if (!checkbox) {
        return false;
      }
      if (checkbox.disabled && checked) {
        return false;
      }
      checkbox.checked = checked;
      return true;
    },
    getDirectGridRootFromTarget(target) {
      if (!target) {
        return null;
      }
      if (target.nodeType === 1) {
        return target.classList?.contains("k-grid") ? target : target.closest?.(".k-grid");
      }
      const widget = target?.kendoWidget?.() || target?.gridWidget?.() || target;
      return widget?.element?.[0] || null;
    },
    capturePrescriptionGridScrollPosition(target = this.getPrescriptionListGridWidget()) {
      const content = this.getPrescriptionGridScrollContentEl(
        this.getDirectGridRootFromTarget(target) || this.getPrescriptionListGridRootEl()
      );
      return {
        top: content?.scrollTop || 0,
        left: content?.scrollLeft || 0
      };
    },
    restorePrescriptionGridScrollPosition(target = this.getPrescriptionListGridWidget(), position = {}) {
      const root = this.getDirectGridRootFromTarget(target) || this.getPrescriptionListGridRootEl();
      const content = this.getPrescriptionGridScrollContentEl(root);
      const lockedContent = root?.querySelector?.(".k-grid-content-locked");
      if (!content) {
        return;
      }
      content.scrollTop = position.top || 0;
      content.scrollLeft = position.left || 0;
      if (lockedContent) {
        lockedContent.scrollTop = content.scrollTop;
      }
    },
    getPrescriptionGridScrollContentEl(root = this.getPrescriptionListGridRootEl()) {
      return root?.querySelector?.(".k-grid-content:not(.k-grid-content-locked)")
        || root?.querySelector?.(".k-grid-content.k-auto-scrollable")
        || root?.querySelector?.(".k-grid-content")
        || null;
    },
    getPrescriptionGridLockedContentEl(root = this.getPrescriptionListGridRootEl()) {
      return root?.querySelector?.(".k-grid-content-locked") || null;
    },
    clearPrescriptionGridLockedScrollSync() {
      (this.lockedScrollSyncCleanup || []).forEach(cleanup => {
        try {
          cleanup();
        } catch (_error) {
          // noop
        }
      });
      this.lockedScrollSyncCleanup = [];
    },
    removePrescriptionGridScrollbarProxy() {
      this.prescriptionGridScrollbarProxy?.remove?.();
      this.prescriptionGridScrollbarProxy = null;
    },
    updatePrescriptionGridScrollbarProxy() {
      const content = this.getPrescriptionGridScrollContentEl();
      const proxy = this.prescriptionGridScrollbarProxy;
      if (!content || !proxy?.isConnected) {
        return;
      }
      const scrollRange = Math.max(0, (content.scrollHeight || 0) - (content.clientHeight || 0));
      const scrollbarWidth = Math.max((content.offsetWidth || 0) - (content.clientWidth || 0), 14);
      const host = proxy.parentElement;
      if (!host) {
        return;
      }
      if (getComputedStyle(host).position === "static") {
        host.style.position = "relative";
      }
      const hostRect = host.getBoundingClientRect();
      const contentRect = content.getBoundingClientRect();
      proxy.style.display = scrollRange > 0 ? "block" : "none";
      proxy.style.top = `${contentRect.top - hostRect.top + host.scrollTop}px`;
      proxy.style.left = `${contentRect.right - hostRect.left - scrollbarWidth + host.scrollLeft}px`;
      proxy.style.width = `${scrollbarWidth}px`;
      proxy.style.height = `${contentRect.height}px`;
    },
    ensurePrescriptionGridScrollbarProxy() {
      const root = this.getPrescriptionListGridRootEl();
      const content = this.getPrescriptionGridScrollContentEl(root);
      if (!root || !content) {
        return null;
      }
      let proxy = this.prescriptionGridScrollbarProxy;
      if (!proxy?.isConnected) {
        proxy = root.querySelector(".prescription-grid-scrollbar-proxy");
      }
      if (!proxy) {
        proxy = document.createElement("div");
        proxy.className = "prescription-grid-scrollbar-proxy";
        proxy.setAttribute("aria-hidden", "true");
        (content.parentElement || root).appendChild(proxy);
      }
      this.prescriptionGridScrollbarProxy = proxy;
      this.updatePrescriptionGridScrollbarProxy();
      return proxy;
    },
    enablePrescriptionGridLockedScrollSync() {
      const content = this.getPrescriptionGridScrollContentEl();
      const lockedContent = this.getPrescriptionGridLockedContentEl();
      const proxy = this.ensurePrescriptionGridScrollbarProxy();
      if (!content || !lockedContent || !proxy || this.lockedScrollSyncCleanup.length > 0) {
        return;
      }
      let applyingScrollTop = false;
      const applySharedScrollTop = (top) => {
        if (!Number.isFinite(top)) {
          return;
        }
        const maxTop = Math.max(0, (content.scrollHeight || 0) - (content.clientHeight || 0));
        const nextTop = Math.min(maxTop, Math.max(0, top));
        applyingScrollTop = true;
        content.scrollTop = nextTop;
        lockedContent.scrollTop = nextTop;
        applyingScrollTop = false;
      };
      const syncLockedFromContent = () => {
        if (!applyingScrollTop) {
          applySharedScrollTop(content.scrollTop);
        }
      };
      const onWheel = (event) => {
        if (event.ctrlKey || Math.abs(event.deltaY) < Math.abs(event.deltaX || 0)) {
          return;
        }
        let deltaY = event.deltaY;
        if (event.deltaMode === 1) {
          deltaY *= 16;
        } else if (event.deltaMode === 2) {
          deltaY *= event.view?.innerHeight || 640;
        }
        event.preventDefault();
        applySharedScrollTop(content.scrollTop + deltaY);
      };
      const getVerticalScrollRange = () => Math.max(0, (content.scrollHeight || 0) - (content.clientHeight || 0));
      const getVerticalTrackRange = () => Math.max(1, content.clientHeight || 0);
      const estimateThumbSize = () => {
        const trackRange = getVerticalTrackRange();
        const scrollHeight = Math.max(content.scrollHeight || 0, 1);
        if (getVerticalScrollRange() <= 0) {
          return trackRange;
        }
        return Math.max(24, trackRange * (content.clientHeight / scrollHeight));
      };
      let scrollbarDragActive = false;
      let scrollbarDragStartY = 0;
      let scrollbarDragStartTop = 0;
      const stopScrollbarDrag = (event) => {
        if (!scrollbarDragActive) {
          return;
        }
        scrollbarDragActive = false;
        try {
          if (event?.pointerId != null) {
            proxy.releasePointerCapture(event.pointerId);
          }
        } catch (_error) {
          // noop
        }
      };
      const onProxyPointerMove = (event) => {
        if (!scrollbarDragActive) {
          return;
        }
        event.preventDefault();
        const dy = event.clientY - scrollbarDragStartY;
        const scrollRange = getVerticalScrollRange();
        const trackRange = getVerticalTrackRange();
        const thumbSize = estimateThumbSize();
        const trackScrollRange = Math.max(trackRange - thumbSize, 1);
        applySharedScrollTop(scrollbarDragStartTop + (dy / trackScrollRange) * scrollRange);
      };
      const onProxyPointerDown = (event) => {
        if (event.button !== 0) {
          return;
        }
        event.preventDefault();
        event.stopPropagation();
        const scrollRange = getVerticalScrollRange();
        const trackRange = getVerticalTrackRange();
        const thumbSize = estimateThumbSize();
        const proxyRect = proxy.getBoundingClientRect();
        const offsetY = event.clientY - proxyRect.top;
        const thumbTop = scrollRange > 0
          ? (content.scrollTop / scrollRange) * Math.max(trackRange - thumbSize, 1)
          : 0;
        if (offsetY < thumbTop || offsetY > thumbTop + thumbSize) {
          const trackScrollRange = Math.max(trackRange - thumbSize, 1);
          applySharedScrollTop(((offsetY - thumbSize / 2) / trackScrollRange) * scrollRange);
        }
        scrollbarDragActive = true;
        scrollbarDragStartY = event.clientY;
        scrollbarDragStartTop = content.scrollTop;
        try {
          proxy.setPointerCapture(event.pointerId);
        } catch (_error) {
          // noop
        }
      };
      proxy.addEventListener("pointerdown", onProxyPointerDown, { passive: false });
      proxy.addEventListener("pointermove", onProxyPointerMove, { passive: false });
      proxy.addEventListener("pointerup", stopScrollbarDrag);
      proxy.addEventListener("pointercancel", stopScrollbarDrag);
      content.addEventListener("scroll", syncLockedFromContent, { passive: true });
      content.addEventListener("wheel", onWheel, { passive: false });
      lockedContent.addEventListener("wheel", onWheel, { passive: false });
      this.lockedScrollSyncCleanup.push(() => {
        stopScrollbarDrag();
        proxy.removeEventListener("pointerdown", onProxyPointerDown);
        proxy.removeEventListener("pointermove", onProxyPointerMove);
        proxy.removeEventListener("pointerup", stopScrollbarDrag);
        proxy.removeEventListener("pointercancel", stopScrollbarDrag);
        content.removeEventListener("scroll", syncLockedFromContent);
        content.removeEventListener("wheel", onWheel);
        lockedContent.removeEventListener("wheel", onWheel);
      });
      applySharedScrollTop(content.scrollTop);
    },
    repairPrescriptionGridLockedLayout() {
      if (this.prescriptionGridPrintLayoutSnapshot) {
        return;
      }
      const content = this.getPrescriptionGridScrollContentEl();
      const lockedContent = this.getPrescriptionGridLockedContentEl();
      if (!content || !lockedContent) {
        return;
      }
      const height = content.clientHeight || 0;
      if (height > 0) {
        lockedContent.style.height = `${height}px`;
        lockedContent.style.maxHeight = `${height}px`;
      }
      lockedContent.scrollTop = content.scrollTop;
      this.updatePrescriptionGridScrollbarProxy();
    },
    capturePrescriptionGridPrintLayoutSnapshot() {
      const captureEl = (element) => {
        if (!(element instanceof HTMLElement)) {
          return null;
        }
        return {
          scrollTop: element.scrollTop,
          scrollLeft: element.scrollLeft,
          height: element.style.height,
          maxHeight: element.style.maxHeight,
          overflow: element.style.overflow,
          overflowX: element.style.overflowX,
          overflowY: element.style.overflowY
        };
      };
      const root = this.getPrescriptionListGridRootEl();
      const wrapper = this.directGridWidget?.wrapper?.[0];
      return {
        root: captureEl(root),
        wrapper: captureEl(wrapper),
        content: captureEl(this.getPrescriptionGridScrollContentEl()),
        lockedContent: captureEl(this.getPrescriptionGridLockedContentEl()),
        mainArea: captureEl(this.$el?.querySelector?.(".main-content-area"))
      };
    },
    restorePrescriptionGridPrintLayoutSnapshot(snapshot) {
      if (!snapshot) {
        return;
      }
      const restoreEl = (element, state) => {
        if (!(element instanceof HTMLElement) || !state) {
          return;
        }
        element.scrollTop = state.scrollTop ?? 0;
        element.scrollLeft = state.scrollLeft ?? 0;
        element.style.height = state.height ?? "";
        element.style.maxHeight = state.maxHeight ?? "";
        element.style.overflow = state.overflow ?? "";
        element.style.overflowX = state.overflowX ?? "";
        element.style.overflowY = state.overflowY ?? "";
      };
      restoreEl(this.getPrescriptionListGridRootEl(), snapshot.root);
      restoreEl(this.directGridWidget?.wrapper?.[0], snapshot.wrapper);
      restoreEl(this.getPrescriptionGridScrollContentEl(), snapshot.content);
      restoreEl(this.getPrescriptionGridLockedContentEl(), snapshot.lockedContent);
      restoreEl(this.$el?.querySelector?.(".main-content-area"), snapshot.mainArea);
    },
    preparePrescriptionGridForPrint() {
      if (!this.prescriptionGridPrintLayoutSnapshot) {
        this.prescriptionGridPrintLayoutSnapshot = this.capturePrescriptionGridPrintLayoutSnapshot();
      }
      const content = this.getPrescriptionGridScrollContentEl();
      const lockedContent = this.getPrescriptionGridLockedContentEl();
      const root = this.getPrescriptionListGridRootEl();
      const wrapper = this.directGridWidget?.wrapper?.[0];
      const mainArea = this.$el?.querySelector?.(".main-content-area");
      [content, lockedContent].forEach(element => {
        if (!(element instanceof HTMLElement)) {
          return;
        }
        element.scrollTop = 0;
        element.scrollLeft = 0;
        element.style.height = "auto";
        element.style.maxHeight = "none";
        element.style.overflow = "visible";
      });
      [root, wrapper, mainArea].forEach(element => {
        if (!(element instanceof HTMLElement)) {
          return;
        }
        element.style.height = "auto";
        element.style.maxHeight = "none";
        element.style.overflow = "visible";
      });
    },
    restorePrescriptionGridAfterPrint() {
      if (!this.prescriptionGridPrintLayoutSnapshot) {
        return;
      }
      const snapshot = this.prescriptionGridPrintLayoutSnapshot;
      this.prescriptionGridPrintLayoutSnapshot = null;
      this.restorePrescriptionGridPrintLayoutSnapshot(snapshot);
      this.$nextTick(() => {
        this.repairPrescriptionGridLockedLayout();
        this.runDirectGridLayoutContract();
      });
    },
    getPrescriptionGridSelectedCell(sender = this.getPrescriptionListGridWidget()) {
      return sender?.select?.()?.closest?.("td,th")?.[0] || null;
    },
    getPrescriptionListGridRef() {
      return this.$refs.prescriptionlistgrid || null;
    },
    getPrescriptionListGridWidget() {
      return this.directGridWidget || this.getPrescriptionListGridRef()?.gridWidget?.() || this.getPrescriptionListGridRef()?.kendoWidget?.() || null;
    },
    getPrescriptionListGridRootEl() {
      const ref = this.getPrescriptionListGridRef();
      if (ref?.nodeType === 1) {
        return ref;
      }
      return ref?.gridRootEl?.() || this.getPrescriptionListGridWidget()?.element?.[0] || null;
    },
    getPrescriptionListGridTableEl() {
      return this.getPrescriptionListGridRef()?.gridTableEl?.() || this.getPrescriptionListGridWidget()?.table?.[0] || null;
    },
    getPrescriptionListGridTheadEl() {
      return this.getPrescriptionListGridRef()?.gridTheadEl?.() || this.getPrescriptionListGridWidget()?.thead?.[0] || null;
    },
    clearPrescriptionGridSelection() {
      const grid = this.getPrescriptionListGridWidget();
      if (!grid) {
        return;
      }
      grid.clearSelection?.();
      const selectedCells = this.getPrescriptionListGridRootEl()?.querySelectorAll?.(
        ".k-selected, .k-state-selected"
      ) || [];
      selectedCells.forEach(el => {
        el.classList.remove("k-selected", "k-state-selected");
      });
    },
    isPrescriptionGridCellElement(cell) {
      const gridRoot = this.getPrescriptionListGridRootEl();
      return !!(cell?.getBoundingClientRect
        && cell.isConnected !== false
        && (!gridRoot || gridRoot.contains?.(cell)));
    },
    rememberGridCellEventTarget(event) {
      const cell = event?.target?.closest?.("td,th") || null;
      if (this.isPrescriptionGridCellElement(cell)) {
        this.lastGridCellEventTarget = cell;
        const position = this.capturePrescriptionGridScrollPosition(
          event?.sender || this.getPrescriptionListGridRef() || this.getPrescriptionListGridWidget()
        );
        this.scrollPosition.top = position.top;
        this.scrollPosition.left = position.left;
        // 同一セル再クリック時は change が発火しないため、選択を一度解除する
        if (
          event?.type === "click"
          && cell?.closest?.("tbody")
          && !this.popoverData.popoverVisible
          && !event.target?.closest?.("input[type=checkbox]")
        ) {
          const grid = this.getPrescriptionListGridWidget();
          if (grid?.select?.()?.[0] === cell) {
            grid.clearSelection?.();
          }
        }
      }
    },
    getPopoverTargetCellByPosition(rowIndex = this.popoverTargetPosition.rowIndex, colIndex = this.popoverTargetPosition.colIndex) {
      if (rowIndex < 0 || colIndex < 0) {
        return null;
      }
      const rows = Array.from(this.getPrescriptionListGridTableEl()?.querySelectorAll?.("tbody > tr") || []);
      return rows[rowIndex]?.cells?.[colIndex] || null;
    },
    getPopoverTargetRectSnapshot(element) {
      const rect = element?.getBoundingClientRect?.();
      if (!rect || (rect.width <= 0 && rect.height <= 0)) {
        return null;
      }
      return {
        top: rect.top,
        left: rect.left,
        right: rect.right,
        bottom: rect.bottom,
        width: rect.width,
        height: rect.height
      };
    },
    resolvePopoverTargetCell(event) {
      const gridRoot = this.getPrescriptionListGridRootEl();
      const candidates = [
        this.lastGridCellEventTarget,
        event?.selectedCell,
        this.getPrescriptionGridSelectedCell(event?.sender),
        event?.target?.closest?.("td,th"),
        event?.currentTarget?.closest?.("td,th"),
        this.getPopoverTargetCellByPosition()
      ];
      return candidates.find((candidate) => {
        return candidate?.getBoundingClientRect
          && candidate.isConnected !== false
          && (!gridRoot || gridRoot.contains?.(candidate));
      }) || null;
    },
    getPopoverTargetPositionFromEvent(event, selcolIndex, row) {
      const targetCell = this.resolvePopoverTargetCell(event);
      const targetRow = targetCell?.closest?.("tr") || null;
      const fallbackRowIndex = this.prescriptionDataSource1.view().indexOf(row);
      const domRowIndex = typeof targetRow?.sectionRowIndex === "number" && targetRow.sectionRowIndex >= 0
        ? targetRow.sectionRowIndex
        : null;
      const domColIndex = typeof targetCell?.cellIndex === "number" && targetCell.cellIndex >= 0
        ? targetCell.cellIndex
        : null;
      return {
        rowIndex: domRowIndex ?? fallbackRowIndex,
        colIndex: domColIndex ?? selcolIndex - 3
      };
    },
    getPrescriptionGridColumnsForCondition() {
      return this.prescriptionGridColumns.map(col => {
        const newCol = { ...col };
        if (newCol.field === "hosp_pat_id") {
          newCol.hidden = !this.getCondition.viewPatId;
        }
        if (newCol.field === "date_info") {
          newCol.hidden = !this.getCondition.viewDateInfo;
        }
        return newCol;
      });
    },
    getDirectGridColumnSignature() {
      const summarize = (column = {}) => ({
        field: column.field || "",
        title: column.title || "",
        width: column.width || "",
        hidden: column.hidden === true,
        locked: column.locked === true,
        template: !!column.template,
        headerTemplate: !!column.headerTemplate,
        columns: Array.isArray(column.columns) ? column.columns.map(summarize) : []
      });
      return JSON.stringify(this.getPrescriptionGridColumnsForCondition().map(summarize));
    },
    buildDirectGridColumns() {
      return this.getPrescriptionGridColumnsForCondition().map(column => ({ ...column }));
    },
    installDirectGridFacade() {
      const root = this.getPrescriptionListGridRef();
      if (!root || root.nodeType !== 1) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridDataSource = () => this.directGridWidget?.dataSource || null;
      root.gridRootEl = () => root;
      root.gridTableEl = () => this.directGridWidget?.table?.[0]
        || root.querySelector(".k-grid-content:not(.k-grid-content-locked) table")
        || root.querySelector(".k-grid-content table");
      root.gridTheadEl = () => this.directGridWidget?.thead?.[0] || root.querySelector(".k-grid-header-wrap thead");
      root.gridHeaderWrapEl = () => root.querySelector(".k-grid-header-wrap");
      root.gridContentEl = () => this.getPrescriptionGridScrollContentEl(root);
      root.gridAutoScrollableEl = () => this.getPrescriptionGridScrollContentEl(root);
      root.gridLockedContentEl = () => this.getPrescriptionGridLockedContentEl(root);
    },
    initDirectGridIfReady() {
      const root = this.getPrescriptionListGridRootEl();
      if (!root || typeof this.prescriptionDataSource1?.data !== "function") {
        return;
      }
      const nextSignature = this.getDirectGridColumnSignature();
      if (this.directGridWidget) {
        if (this.directGridColumnSignature !== nextSignature) {
          this.directGridWidget.setOptions({ columns: this.buildDirectGridColumns() });
          this.directGridColumnSignature = nextSignature;
        }
        this.applyDirectGridDataSourceContract();
        this.installDirectGridFacade();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      const $root = $$(root);
      $root.kendoGrid({
        dataSource: this.prescriptionDataSource1,
        columns: this.buildDirectGridColumns(),
        editable: false,
        reorderable: false,
        resizable: true,
        selectable: "cell",
        height: this.kendoGridHeight,
        scrollable: true,
        sortable: { compare: this.compareByField },
        change: event => this.onClick(event),
        dataBound: event => this.setFontColor(event),
        sort: event => this.sortHandler(event)
      });
      this.directGridWidget = $root.data("kendoGrid") || null;
      this.directGridColumnSignature = nextSignature;
      this.installDirectGridFacade();
      this.applyDirectGridStyleContract();
      this.enablePrescriptionGridLockedScrollSync();
    },
    applyDirectGridDataSourceContract() {
      const grid = this.getPrescriptionListGridWidget();
      if (!grid || typeof this.prescriptionDataSource1?.data !== "function") {
        return;
      }
      if (grid.dataSource !== this.prescriptionDataSource1) {
        grid.setDataSource(this.prescriptionDataSource1);
      } else {
        grid.refresh();
      }
      this.installDirectGridFacade();
      this.scheduleDirectGridLayoutContract();
    },
    applyDirectGridStyleContract() {
      const root = this.getPrescriptionListGridRootEl();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-display-block");
      root.querySelectorAll(".k-grid-header th, .k-grid-header .k-table-th").forEach(th => th.classList.add("k-header"));
      [".k-grid-content tbody", ".k-grid-content-locked tbody"].forEach(selector => {
        root.querySelectorAll(selector).forEach(tbody => {
          Array.from(tbody.children || []).forEach((tr, index) => {
            tr.classList.add("k-master-row");
            tr.classList.toggle("k-alt", index % 2 === 1);
          });
        });
      });
      root.querySelectorAll(".k-grid-content tbody td, .k-grid-content-locked tbody td").forEach(td => td.classList.add("k-td", "k-table-td"));
    },
    runDirectGridLayoutContract() {
      const grid = this.getPrescriptionListGridWidget();
      if (!grid) {
        return;
      }
      const root = this.getPrescriptionListGridRootEl();
      if (root) {
        root.style.height = `${this.kendoGridHeight}px`;
      }
      try {
        grid.wrapper?.height?.(this.kendoGridHeight);
        grid.resize?.(true);
      } catch (_error) {
        // noop
      }
      this.applyDirectGridStyleContract();
      this.repairPrescriptionGridLockedLayout();
      this.restorePrescriptionGridScrollPosition(grid, this.scrollPosition);
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        this.runDirectGridLayoutContract();
      });
    },
    destroyDirectGrid() {
      this.clearPrescriptionGridLockedScrollSync();
      this.removePrescriptionGridScrollbarProxy();
      try {
        this.directGridWidget?.destroy?.();
      } catch (_error) {
        // noop
      }
      this.directGridWidget = null;
      this.directGridColumnSignature = "";
      const root = this.getPrescriptionListGridRef();
      if (root?.nodeType === 1) {
        root.innerHTML = "";
      }
    },
    applyPrescriptionGridColumnVisibility() {
      const gridObj = this.getPrescriptionListGridWidget();
      if (!gridObj) {
        return false;
      }
      const nextSignature = this.getDirectGridColumnSignature();
      if (this.directGridColumnSignature !== nextSignature) {
        gridObj.setOptions({
          columns: this.buildDirectGridColumns()
        });
        this.directGridColumnSignature = nextSignature;
        this.scheduleDirectGridLayoutContract();
      }
      return true;
    },
    resetPrescriptionGridColumnWidths() {
      const grid = this.getPrescriptionListGridWidget();
      if (!grid) {
        return;
      }
      try {
        grid.setOptions({ columns: this.buildDirectGridColumns() });
        this.directGridColumnSignature = this.getDirectGridColumnSignature();
        this.scheduleDirectGridLayoutContract();
      } catch (_error) {
        // noop
      }
    },
    ...mapActions("pat-info", ["selectPat", "setSearchedPatList"]),
    ...mapMutations("pat-prescription", ["setRouteFlag", "setAppointedDate"]),
    ...mapActions("prescription/list", [
      "setOrdPreNo",
    ]),
    ...mapActions("pat-prescription", ["sendRequestGetOrderPrescriptionDetail"]),
    
    /**
     * 列ヘッダクリック時にソート順を設定
     * @param {*} e 
     */
    sortHandler(e) {
      this.currentSort = e.sort;
    },
    /**
     * 列ヘッダクリック時のソート処理
     * @param {*} a 
     * @param {*} b 
     */
    compareByField(a, b) {
      // ソートなしはreturn
      if (!this.currentSort || !this.currentSort.field) return;

      const sortFieldName = SORT_KEY_MAP[this.currentSort.field] || this.currentSort.field;
      // 共通関数でソート      
      return sortableCompare(a, b, sortFieldName, true);
    },

    async getList(){

      const patList = this.searchedPatList.map(x=>{
        return {
          pat_id: Number(x.pat_id),
          hosp_pat_id: x.hosp_pat_id,
          pat_name: (x.pat_last_name == null ? "": x.pat_last_name) + ' ' + (x.pat_first_name == null ? "": x.pat_first_name),
          in_out_class: x.in_out_class,
          is_same: x.is_same,
          pat_name_sort: x.pat_name_sort, // 患者名ソート用文字列
        }
      });
      const patIdList = patList.map(x => x.pat_id).filter(y => y);
      let prescriptionTypeList = [];
      if(this.getCondition.viewPreOut){
        prescriptionTypeList.push('1')
      }
      if(this.getCondition.viewPreIn){
        prescriptionTypeList.push('2')
      }
      if (this.getAppointedDate == ""){
        this.setAppointedDate(dayjs().format("YYYY/MM/DD"));
      }
      const patientShareMode =
        this.getIsOtherFacility === false ||
        (this.getOtherFacilityCd !== null &&
          this.getOtherFacilityCd !== this.getFacilityCd)
          ? 1
          : this.getPatientShareMode;
      const newList = await sendRequestGetprescriptionList(
        patIdList,
        this.getAppointedDate.replace(/\//g, ""),
        prescriptionTypeList,
        patientShareMode
      ).then(result => result.data);
      newList.map(x => {
        // ソートで使用するため元の値を保管
        x.prescriptionTypeOrg = x.prescriptionType;
        x.issueStateOrg = x.issueState;
        x.prescriptionType2Org = x.prescriptionType2;
        x.issueState2Org = x.issueState2;
        
        if(x.prescriptionType == "1"){
          x.prescriptionType = "院外";
        }else if(x.prescriptionType == "2"){
          x.prescriptionType = "院内";
        }
        if(x.issueState == "0"){
          x.issueState = "未"
        }else if(x.issueState == "1"){
          x.issueState = "済"
        }

        if(x.prescriptionType2 == "1"){
            x.prescriptionType2 = "院外";
        }else if(x.prescriptionType2 == "2"){
            x.prescriptionType2 = "院内";
        }
        if(x.issueState2 == "0"){
          x.issueState2 = "未"
        }else if(x.issueState2 == "1"){
          x.issueState2 = "済"
        }

        return x;
      });
      const nowDate = dayjs().format("YYYY/MM/DD");
      const grouped = this.groupBy(newList, x => x.patId);
      const resultList = patList.map(pat => {
        const x = grouped.filter(y => pat.pat_id == y[0].patId)[0];
        const hasNext = x.filter(y => y.issueDate > nowDate);
        const len = x.length;
        let has2 = false;
        let has3 = false;
        let has4 = false;
        if (hasNext.length > 0) {
          switch (len) {
            case 2:
              has2 = true;
              break;
            case 3:
              has2 = true;
              has3 = true;
              break;
            case 4:
              has2 = true;
              has3 = true;
              has4 = true;
              break;
            default:
              break;
          }
          return {
            pat_id: x[0].patId,
            hosp_pat_id: pat.hosp_pat_id,
            in_out_class: pat.in_out_class,
            is_same: pat.is_same,
            image_src_same: this.imageSrcSame,
            pat_first_name: "",
            pat_last_name: "",
            pat_name: pat.pat_name,
            p_save_state: x[0].issueState2,
            p_class: x[0].prescriptionType2,
            p_save_state_org: x[0].issueState2Org,   // 指定日情報.交付
            p_class_org: x[0].prescriptionType2Org,  // 指定日情報.処方区分
            p_ord_pre_no: x[0].ordPrescriptionNo2,
            kur: x[0].indKurName,
            bed_name: x[0].indBedName,
            treatment_method: x[0].indTreatmentName,
            next_save_state: x[0].issueState,
            next_date: x[0].issueDate,
            next_class: x[0].prescriptionType,
            next_save_state_org: x[0].issueStateOrg, // 次回処方.交付
            next_class_org: x[0].prescriptionTypeOrg,// 次回処方.処方区分
            next_ord_pre_no: x[0].ordPrescriptionNo,
            pre_1_check: false,
            pre_1_date: has2 ? x[1].issueDate : "",
            pre_1_class: has2 ? x[1].prescriptionType : "",
            pre_1_class_org: has2 ? x[1].prescriptionTypeOrg : "",// 前回処方.処方区分
            pre_1_ord_pre_no: has2 ? x[1].ordPrescriptionNo : "",
            pre_2_check: false,
            pre_2_date: has3 ? x[2].issueDate : "",
            pre_2_class: has3 ? x[2].prescriptionType : "",
            pre_2_class_org: has3 ? x[2].prescriptionTypeOrg : "",// 2回前処方.処方区分
            pre_2_ord_pre_no: has3 ? x[2].ordPrescriptionNo : "",
            pre_3_check: false,
            pre_3_date: has4 ? x[3].issueDate : "",
            pre_3_class: has4 ? x[3].prescriptionType : "",
            pre_3_class_org: has4 ? x[3].prescriptionTypeOrg : "",// 3回前処方.処方区分
            pre_3_ord_pre_no: has4 ? x[3].ordPrescriptionNo : "",
            pat_name_sort: pat.pat_name_sort,
            kur_start_time: x[0].kurStartTime,
            bed_order_index: x[0].bedOrderIndex,
            treatment_order_index: x[0].treatmentOrderIndex,
            pre_1_disabled: !(has2 && x[1]) || x[1].facilityCd !== this.getFacilityCd,
            pre_2_disabled: !(has3 && x[2]) || x[2].facilityCd !== this.getFacilityCd,
            pre_3_disabled: !(has4 && x[3]) || x[3].facilityCd !== this.getFacilityCd
          }
        } else {
          switch (len) {
            case 2:
              has2 = true;
              break;
            case 3:
              has2 = true;
              has3 = true;
              break;
            default:
              break;
          }
          return {
            pat_id: x[0].patId,
            hosp_pat_id: pat.hosp_pat_id,
            in_out_class: pat.in_out_class,
            is_same: pat.is_same,
            image_src_same: this.imageSrcSame,
            pat_first_name: "",
            pat_last_name: "",
            pat_name: pat.pat_name,
            p_save_state: x[0].issueState2,
            p_class: x[0].prescriptionType2,
            p_save_state_org: x[0].issueState2Org,   // 指定日情報.交付
            p_class_org: x[0].prescriptionType2Org,  // 指定日情報.処方区分
            p_ord_pre_no: x[0].ordPrescriptionNo2,
            kur: x[0].indKurName,
            bed_name: x[0].indBedName,
            treatment_method: x[0].indTreatmentName,
            next_save_state: "",
            next_date: "",
            next_class: "",
            next_save_state_org: "", // 次回処方.交付
            next_class_org: "",      // 次回処方.処方区分
            next_ord_pre_no: "",
            pre_1_check: false,
            pre_1_date: x[0].issueDate,
            pre_1_class: x[0].prescriptionType,
            pre_1_class_org: x[0].prescriptionTypeOrg,// 前回処方.処方区分
            pre_1_ord_pre_no: x[0].ordPrescriptionNo,
            pre_2_check: false,
            pre_2_date: has2 ? x[1].issueDate : "",
            pre_2_class: has2 ? x[1].prescriptionType : "",
            pre_2_class_org: has2 ? x[1].prescriptionTypeOrg : "",// 2回前処方.処方区分
            pre_2_ord_pre_no: has2 ? x[1].ordPrescriptionNo : "",
            pre_3_check: false,
            pre_3_date: has3 ? x[2].issueDate : "",
            pre_3_class: has3 ? x[2].prescriptionType : "",
            pre_3_class_org: has3 ? x[2].prescriptionTypeOrg : "",// 3回前処方.処方区分
            pre_3_ord_pre_no: has3 ? x[2].ordPrescriptionNo : "",
            pat_name_sort: pat.pat_name_sort,
            kur_start_time: x[0].kurStartTime,
            bed_order_index: x[0].bedOrderIndex,
            treatment_order_index: x[0].treatmentOrderIndex,
            pre_1_disabled: !x[0] || x[0].facilityCd !== this.getFacilityCd,
            pre_2_disabled: !(has2 && x[1]) || x[1].facilityCd !== this.getFacilityCd,
            pre_3_disabled: !(has3 && x[2]) || x[2].facilityCd !== this.getFacilityCd
          }
        } 
      });
      
      // 患者検索でソート更新・検索実行した場合、処方側のソート状態を保持する（処方画面でソート指定したときのみソート条件保持）
      this.prescriptionDataSource1 = new Kendo.data.DataSource({data: resultList, sort: this.currentSort ? this.currentSort : null});
      this.$nextTick(() => {
        this.initDirectGridIfReady();
        // 選択中の処方オーダー番号の更新
        this.updateOrdPreNo();
        // チェックボックスの再描画
        const ordPreNoList = this.getOrdPreNo;
        ordPreNoList.forEach(function(id) {
          this.setCheckBoxes(id);
        }, this);
        // 全チェックボタンの状態を確認
        this.checkAllBtnStatus();
      });
    },

    groupBy(array, f) {
      var groups = {};
      array.forEach(x => {
          var group = JSON.stringify(f(x));
          groups[group] = groups[group] || [];
          groups[group].push(x);
      });
      return Object.keys(groups).map(x => groups[x]);
    },

    initGoToInfo(){
      if (this.selectedPatId && this.getRouteFlag) {
        this.$router.push({ name: "pat-prescription" });
      }
    },

    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      // mod #10225 処方薬剤選択に一般名処方が表示しない。yqz start
      // this.kendoGridHeight = document.getElementsByClassName("main-content-area kendo-grid-style-page")[0].clientHeight;
      this.kendoGridHeight = getMainContentAreaElement(this.$el || document)?.clientHeight || 0;
      this.scheduleDirectGridLayoutContract();
      // mod #10225 処方薬剤選択に一般名処方が表示しない。yqz end
    },
    setFontColor(ev){
      // Databaund 時のイベント
      // console.log("Databaund - setFontColorイベント");
      // Grid高さの調整
      this.$nextTick(() => {
        this.calculateGridHeight();
      });

      if (this.firstLoadFlg) {
        this.$nextTick(() => {
          setTimeout(() => {
            // console.log("初期表示の時にはリサイズが必要");
            $$(window).trigger('resize');
          }, 1);
        });
        this.firstLoadFlg = false;
      }

      // ヘッダースタイル適用
      this.setHeaderStyle();

      // CheckBox チェック時のイベントを一旦削除してから付与する(再描画の度にイベントが外れる為、都度設定する)
      if (!this.prescriptionGridBodyClickHandler) {
        this.prescriptionGridBodyClickHandler = (e) => this.chektestfnk(e);
      }
      if (!this.prescriptionGridHeaderClickHandler) {
        this.prescriptionGridHeaderClickHandler = (e) => this.allCheck(e);
      }
      const gridTableEl = this.getPrescriptionListGridTableEl() || ev?.sender?.table?.[0] || null;
      const checkboxEventRoot = this.$el?.querySelector?.(".prescription-list-main-content");
      gridTableEl?.removeEventListener("click", this.prescriptionGridBodyClickHandler);
      checkboxEventRoot?.removeEventListener("click", this.prescriptionGridHeaderClickHandler);
      // CheckBox チェック時のイベントを付与
      gridTableEl?.addEventListener("click", this.prescriptionGridBodyClickHandler);
      // ヘッダ全選択は thead 再生成後も効くよう、固定の親要素へ委譲する
      checkboxEventRoot?.addEventListener("click", this.prescriptionGridHeaderClickHandler);

      // チェック状態が消えるためチェックボックスの再描画
      const ordPreNoList = this.getOrdPreNo;
      ordPreNoList.forEach(function(id) {
        this.setCheckBoxes(id);
      }, this);
      // 全チェックボタンの状態を確認
      this.checkAllBtnStatus();
      this.repairPrescriptionGridLockedLayout();
      //処方情報のポップオーバー表示時にウィンドウのリサイズによってグリッドの再描画が発生した場合
      const shouldRestorePopoverAfterResize = this.popoverTarget && this.resizeFlg;
      if(shouldRestorePopoverAfterResize){
        //処方情報のポップオーバーの非表示への切替
        this.$refs.popoverPrescriptionInfo.updateVisibleFlg(false, true);
      }
      this.$nextTick(() => {
        if (this.resizeFlg || this.scrollPosition.top !== 0 || this.scrollPosition.left !== 0) {
          //スクロールバーの位置をイベント発生前の位置に戻す
          this.restorePrescriptionGridScrollPosition(ev?.sender || ev, {
            top: this.scrollPosition.top,
            left: this.scrollPosition.left
          });
          if (this.resizeFlg && !this.firstLoadFlg) {
            this.resizeFlg = false;
          }
        }
        //処方情報のポップオーバー表示時にウィンドウのリサイズによってグリッドの再描画が発生した場合
        if(shouldRestorePopoverAfterResize && this.popoverTarget){
          //ポップオーバーの呼び出し元の要素の再取得
          const nextPopoverTarget = this.getPopoverTargetCellByPosition();
          if (nextPopoverTarget) {
            this.popoverTarget = nextPopoverTarget;
            const nextPopoverTargetRect = this.getPopoverTargetRectSnapshot(nextPopoverTarget);
            if (nextPopoverTargetRect) {
              this.popoverTargetRect = nextPopoverTargetRect;
            }
          }
          //処方情報のポップオーバーの再表示
          this.$refs.popoverPrescriptionInfo.updateVisibleFlg(true, false);
        }
      });
    },
    setHeaderStyle() {
      // ヘッダーにスタイル適用
      const root = resolveRefElement(this, "prescriptionlistgrid") || this.getPrescriptionListGridRootEl();
      root?.classList?.add("master-grid-header");
      root?.querySelector?.(".k-grid-header")?.classList?.add("master-grid-header");
    },
    // 患者ID、患者名項目をクリックした場合は、処方画面に遷移
    async onClick(e) {
      if (e.sender) {
        // 選択行取得
        const selcolIndex = e.sender.cellIndex(e.sender.select().closest("td"));
        const patId = e.sender.dataItem(e.sender.select().closest("tr")).pat_id;
        // 患者ID、患者名列の場合
        if (selcolIndex === CNO_PAT_ID || selcolIndex === CNO_PAT_NAME) {
          await this.selectPat(patId);
          await this.$router.push({ name: "pat-prescription" });
        } else {
          const prescriptionData = this.prescriptionDataSource1.data().find((item) => {
            return item.pat_id === patId;
          });
          let ordPrescriptionNo = null;
          // 指定日情報-交付、指定日情報-処方区分列の場合
          if (selcolIndex === CNO_DATE_INFO || selcolIndex === CNO_CLASS_INFO) {
            ordPrescriptionNo = prescriptionData.p_ord_pre_no;
          // 次回処方-交付、次回処方-処方日、次回処方-処方区分列の場合
          } else if (selcolIndex === CNO_NEXT_STATE_INFO || selcolIndex === CNO_NEXT_DATE_INFO || selcolIndex === CNO_NEXT_CLASS_INFO) {
            ordPrescriptionNo = prescriptionData.next_ord_pre_no;
            console.log(ordPrescriptionNo);
          // 前回処方日-処方日、前回処方日-処方区分列の場合
          } else if (selcolIndex === CNO_PRE_1_DATE_INFO || selcolIndex === CNO_PRE_1_CLASS_INFO) {
            ordPrescriptionNo = prescriptionData.pre_1_ord_pre_no;
          // 2回前処方日-処方日、2回前処方日-処方区分列の場合
          } else if (selcolIndex === CNO_PRE_2_DATE_INFO || selcolIndex === CNO_PRE_2_CLASS_INFO) {
            ordPrescriptionNo = prescriptionData.pre_2_ord_pre_no;
          // 3回前処方日-処方日、3回前処方日-処方区分列の場合
          } else if (selcolIndex === CNO_PRE_3_DATE_INFO || selcolIndex === CNO_PRE_3_CLASS_INFO) {
            ordPrescriptionNo = prescriptionData.pre_3_ord_pre_no;
          }
          //選択したデータの処方オーダー番号が取得できた場合
          if(ordPrescriptionNo){
            const row = e.sender.dataItem(e.sender.select().closest("tr"));
            const targetCell = this.resolvePopoverTargetCell(e);
            const targetRect = this.getPopoverTargetRectSnapshot(targetCell);
            const position = this.getPopoverTargetPositionFromEvent(e, selcolIndex, row);
            //呼び出し元の要素の表示位置(行番号)の設定
            this.popoverTargetPosition.rowIndex = position.rowIndex;
            //呼び出し元の要素の表示位置(列番号)の設定
            this.popoverTargetPosition.colIndex = position.colIndex;
            if (targetRect) {
              this.popoverTargetRect = targetRect;
            }
            await this.sendRequestGetOrderPrescriptionDetail({
              ordPrescriptionNo,
              selectedPatId: patId
            });
            this.showPopover(e);
          }
        }
      }
    },
    /**
     * ポップオーバー表示処理
     */
    showPopover(event) {
      this.popoverTarget = this.resolvePopoverTargetCell(event) || this.getPopoverTargetCellByPosition();
      const targetRect = this.getPopoverTargetRectSnapshot(this.popoverTarget);
      if (targetRect) {
        this.popoverTargetRect = targetRect;
      }
      if (!this.popoverTarget && !this.popoverTargetRect) {
        return;
      }
      this.popoverData.popoverVisible = true;
      this.popoverData.prescriptionInfoData = this.getInputModal;
      this.popoverData.prescriptionDetailList = this.getPrescriptionDetail;
    },
    /**
     * ポップオーバー非表示処理
     */
    closePopover() {
      const grid = this.getPrescriptionListGridRef() || this.getPrescriptionListGridWidget();
      const position = this.capturePrescriptionGridScrollPosition(grid);
      this.scrollPosition.top = position.top;
      this.scrollPosition.left = position.left;
      this.popoverData.popoverVisible = false;
      this.popoverTarget = null;
      this.popoverTargetRect = null;
      this.popoverTargetPosition.rowIndex = -1;
      this.popoverTargetPosition.colIndex = -1;
      this.clearPrescriptionGridSelection();
      this.$nextTick(() => {
        this.calculateGridHeight();
        this.restorePrescriptionGridScrollPosition(grid, this.scrollPosition);
      });
    },
    // チェック時にチェック状態を保持
    allCheck(e) {
      if (!e.target?.id || e.target.id.indexOf("header-chb") < 0) {
        return;
      }
      if (e.target.checked != null && this.prescriptionDataSource1._data.length !== 0) {

        // データ分だけチェックボックスにチェックを入れる
        if (e.target.id.indexOf("pre1-header-chb") >= 0) {
          // 前回処方日
          this.prescriptionDataSource1._data.forEach(function(obj) {
            if (typeof obj.pre_1_date !== 'undefined' && (obj.pre_1_date !== null && obj.pre_1_date !== '')) {
              const targetId = "pre_1_check_" + obj.pre_1_ord_pre_no;
              this.setScopedCheckboxChecked(targetId, e.target.checked);
              if (e.target.checked) {
                // 他のチェックを解除
                if (typeof obj.pre_2_date !== 'undefined') {
                  const pre2Id = "pre_2_check_" + obj.pre_2_ord_pre_no;
                  this.setScopedCheckboxChecked(pre2Id, false);
                }
                if (typeof obj.pre_3_date !== 'undefined') {
                  const pre3Id = "pre_3_check_" + obj.pre_3_ord_pre_no;
                  this.setScopedCheckboxChecked(pre3Id, false);
                }
              }
            }
          }, this);
        } else if (e.target.id.indexOf("pre2-header-chb") >= 0) {
          // 2回前処方日
          this.prescriptionDataSource1._data.forEach(function(obj) {
            if (typeof obj.pre_2_date !== 'undefined' && (obj.pre_2_date !== null && obj.pre_2_date !== '')) {
              const targetId = "pre_2_check_" + obj.pre_2_ord_pre_no;
              this.setScopedCheckboxChecked(targetId, e.target.checked);
              if (e.target.checked) {
                // 他のチェックを解除
                if (typeof obj.pre_1_date !== 'undefined') {
                  const pre1Id = "pre_1_check_" + obj.pre_1_ord_pre_no;
                  this.setScopedCheckboxChecked(pre1Id, false);
                }
                if (typeof obj.pre_3_date !== 'undefined') {
                  const pre3Id = "pre_3_check_" + obj.pre_3_ord_pre_no;
                  this.setScopedCheckboxChecked(pre3Id, false);
                }
              }
            }
          }, this);
        } else if (e.target.id.indexOf("pre3-header-chb") >= 0) {
          // 3回前処方日
          this.prescriptionDataSource1._data.forEach(function(obj) {
            if (typeof obj.pre_3_date !== 'undefined' && (obj.pre_3_date !== null && obj.pre_3_date !== '')) {
              const targetId = "pre_3_check_" + obj.pre_3_ord_pre_no;
              this.setScopedCheckboxChecked(targetId, e.target.checked);
              if (e.target.checked) {
                // 他のチェックを解除
                if (typeof obj.pre_1_date !== 'undefined') {
                  const pre1Id = "pre_1_check_" + obj.pre_1_ord_pre_no;
                  this.setScopedCheckboxChecked(pre1Id, false);
                }
                if (typeof obj.pre_2_date !== 'undefined') {
                  const pre2Id = "pre_2_check_" + obj.pre_2_ord_pre_no;
                  this.setScopedCheckboxChecked(pre2Id, false);
                }
              }
            }
          }, this);
        }
        // 全チェックボタンの状態を確認
        this.checkAllBtnStatus();
        this.checkOrdPreNo();
      }
    },
    // チェック時にチェック状態を保持
    chektestfnk(e) {
      if (e.target.checked != null) {
        let targetPre = "";
        if (e.target.id.indexOf("pre_1_check_") >= 0) {
          targetPre = "pre1Checks";
        } else if (e.target.id.indexOf("pre_2_check_") >= 0) {
          targetPre = "pre2Checks";
        } else if (e.target.id.indexOf("pre_3_check_") >= 0) {
          targetPre = "pre3Checks";
        }

        // 同じ行の他チェックを排他処理
        const ordPreNo = e.target.id.slice(12);
        const targetObj = this.prescriptionDataSource1._data.find(function(obj) {
          return obj.pre_1_ord_pre_no === Number(ordPreNo) || obj.pre_2_ord_pre_no === Number(ordPreNo) || obj.pre_3_ord_pre_no === Number(ordPreNo);
        });
        if (!targetObj) {
          return;
        }

        if (targetPre === "pre1Checks") {
          if(typeof targetObj.pre_2_date !== 'undefined'){
            this.setScopedCheckboxChecked("pre_2_check_" + targetObj.pre_2_ord_pre_no, false);
          }
          if(typeof targetObj.pre_3_date !== 'undefined'){
            this.setScopedCheckboxChecked("pre_3_check_" + targetObj.pre_3_ord_pre_no, false);
          }
        } else if (targetPre === "pre2Checks") {
          this.setScopedCheckboxChecked("pre_1_check_" + targetObj.pre_1_ord_pre_no, false);
          if(typeof targetObj.pre_3_date !== 'undefined'){
            this.setScopedCheckboxChecked("pre_3_check_" + targetObj.pre_3_ord_pre_no, false);
          } 
        } else if (targetPre === "pre3Checks") {
          this.setScopedCheckboxChecked("pre_1_check_" + targetObj.pre_1_ord_pre_no, false);
          this.setScopedCheckboxChecked("pre_2_check_" + targetObj.pre_2_ord_pre_no, false);
        }

        // 全チェックボタンの状態を確認
        this.checkAllBtnStatus();
        this.checkOrdPreNo();
      }
    },
    // チェック処理後の全チェックボタン制御
    checkAllBtnStatus() {
      let pre1AllFlg = true;
      let pre2AllFlg = true;
      let pre3AllFlg = true;

      let pre1Count = 0;
      let pre2Count = 0;
      let pre3Count = 0;

      // チェック状態確認
      if(typeof this.prescriptionDataSource1._data !== 'undefined'){
        this.prescriptionDataSource1._data.forEach(function(obj) {
          if (pre1AllFlg && typeof obj.pre_1_date !== 'undefined') {
            // 配列にないか、チェックされていない(false)
            const pre1Id = "pre_1_check_" + obj.pre_1_ord_pre_no;
            const pre1Checkbox = this.getScopedElementByIdSafe(pre1Id);
            if (
              pre1Checkbox &&
              !pre1Checkbox.disabled &&
              obj.pre_1_date !== null &&
              obj.pre_1_date !== ''
            ) {
              if (!pre1Checkbox.checked) {
                pre1AllFlg = false;
              }
              pre1Count++;
            }
          }
          if (pre2AllFlg && typeof obj.pre_2_date !== 'undefined') {
            const pre2Id = "pre_2_check_" + obj.pre_2_ord_pre_no;
            const pre2Checkbox = this.getScopedElementByIdSafe(pre2Id);
            if (
              pre2Checkbox &&
              !pre2Checkbox.disabled &&
              obj.pre_2_date !== null &&
              obj.pre_2_date !== ''
            ) {
              if (!pre2Checkbox.checked) {
                pre2AllFlg = false;
              }
              pre2Count++;
            }
          }
          if (pre3AllFlg && typeof obj.pre_3_date !== 'undefined') {
            const pre3Id = "pre_3_check_" + obj.pre_3_ord_pre_no;
            const pre3Checkbox = this.getScopedElementByIdSafe(pre3Id);
            if (
              pre3Checkbox &&
              !pre3Checkbox.disabled &&
              obj.pre_3_date !== null &&
              obj.pre_3_date !== ''
            ) {
              if (!pre3Checkbox.checked) {
                pre3AllFlg = false;
              }
              pre3Count++;
            }
          }
        }, this);
      }
      // 状態に応じてチェック状態を変更する
      this.setScopedCheckboxChecked("pre1-header-chb", pre1Count > 0 ? pre1AllFlg : false);
      this.setScopedCheckboxChecked("pre2-header-chb", pre2Count > 0 ? pre2AllFlg : false);
      this.setScopedCheckboxChecked("pre3-header-chb", pre3Count > 0 ? pre3AllFlg : false);

    },

    // 選択した処方の処方オーダー番号を一括コピー対象に設定
    checkOrdPreNo() {
      let ordPreNo = [];

      // チェック状態確認
      this.prescriptionDataSource1._data.forEach(function(obj) {
        if (typeof obj.pre_1_date !== 'undefined') {
          // 配列にないか、チェックされていない(false)
          const pre1Obj = this.getScopedCheckboxChecked("pre_1_check_" + obj.pre_1_ord_pre_no);
          if(pre1Obj === true){
            ordPreNo.push(obj.pre_1_ord_pre_no);
          }
        }
        if (typeof obj.pre_2_date !== 'undefined') {
          const pre2Obj = this.getScopedCheckboxChecked("pre_2_check_" + obj.pre_2_ord_pre_no);
          if(pre2Obj === true){
            ordPreNo.push(obj.pre_2_ord_pre_no);
          }
        }
        if (typeof obj.pre_3_date !== 'undefined') {
          const pre3Obj = this.getScopedCheckboxChecked("pre_3_check_" + obj.pre_3_ord_pre_no);
          if(pre3Obj === true){
            ordPreNo.push(obj.pre_3_ord_pre_no);
          }
        }
      }, this);

      // 選択したOrdPreNoを設定
      this.setOrdPreNo(ordPreNo);
    },

    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$route.name) {
        this.resetPrescriptionGridColumnWidths();
        this.getList();
      }
    },

    // 検索条件が変わった場合のordPreNoの更新
    updateOrdPreNo() {
      const ordPreNoList = this.getOrdPreNo;
      if (ordPreNoList.length !== 0 && typeof this.prescriptionDataSource1._data !== 'undefined') {
        let newOrdPreNoList = [];
        this.prescriptionDataSource1._data.forEach(function(obj) {
          if(ordPreNoList.indexOf(obj.pre_1_ord_pre_no) >= 0) {
            newOrdPreNoList.push(obj.pre_1_ord_pre_no);
          }
          if(ordPreNoList.indexOf(obj.pre_2_ord_pre_no) >= 0) {
            newOrdPreNoList.push(obj.pre_2_ord_pre_no);
          }
          if(ordPreNoList.indexOf(obj.pre_3_ord_pre_no) >= 0) {
            newOrdPreNoList.push(obj.pre_3_ord_pre_no);
          }
        }, this);
        this.setOrdPreNo(newOrdPreNoList);
      }
    },
    // チェックボックスの再描画
    setCheckBoxes(id) {
      const pre1Id = "pre_1_check_" + id;
      const pre2Id = "pre_2_check_" + id;
      const pre3Id = "pre_3_check_" + id;

      if (this.getScopedElementByIdSafe(pre1Id) != null) {
        this.setScopedCheckboxChecked(pre1Id, true);
      }
      if (this.getScopedElementByIdSafe(pre2Id) != null) {
        this.setScopedCheckboxChecked(pre2Id, true);
      }
      if (this.getScopedElementByIdSafe(pre3Id) != null) {
        this.setScopedCheckboxChecked(pre3Id, true);
      }
    },
    getAuthority() {
      const pEdit = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PRESCRIPTION_PEDIT);
      const edit = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PRESCRIPTION_EDIT);
      if(pEdit == false && edit == false){
        this.isChkDisabled = "disabled" ;
      }else{
        this.isChkDisabled = "" ;
      }
    },
  },

  watch: {
    searchedPatList() {
      this.getList();
    },
    selectedPatId(){
      if(this.selectedPatId){
        this.$router.push({ name: "pat-prescription" });
      }
    },
    windowHeight() {
      //イベント発生前のスクロールバーの位置を保持
      const position = this.capturePrescriptionGridScrollPosition();
      this.scrollPosition.top = position.top;
      this.scrollPosition.left = position.left;
      this.resizeFlg = true;
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      // 画面印刷中は処理しない
      if (this.isPrint) return;

      this.calculateGridHeight();
    },
    sidebarWidth() {
      $$(window).trigger('resize');
    },
    // ヘッダ検索条件
    getCondition() {
      this.applyPrescriptionGridColumnVisibility();
      this.getList();
    },
    getPatientShareMode() {
      this.getList();
    },
    getPatientShareFacilityCdMode() {
      this.getList();
    }
  },
  mounted() {
    this.initGoToInfo();
    this.setRouteFlag(true);
    window.addEventListener("beforeprint", this.preparePrescriptionGridForPrint);
    window.addEventListener("afterprint", this.restorePrescriptionGridAfterPrint);
    this.$nextTick(() => {
      this.initDirectGridIfReady();
      this.applyPrescriptionGridColumnVisibility();
    });
  },
  created() {
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
    EventBus.$off("refresh", this.refresh);
    EventBus.$on("refresh", this.refresh);
    EventBus.$off("printing", this.preparePrescriptionGridForPrint);
    EventBus.$on("printing", this.preparePrescriptionGridForPrint);
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    this.getAuthority();
  },
  updated() {
    this.applyPrescriptionGridColumnVisibility();
  },
  beforeUnmount() {
    window.removeEventListener("beforeprint", this.preparePrescriptionGridForPrint);
    window.removeEventListener("afterprint", this.restorePrescriptionGridAfterPrint);
    this.clearPrescriptionGridLockedScrollSync();
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("printing", this.preparePrescriptionGridForPrint);
    // #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end
    if (this.directGridLayoutRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = null;
    }
    this.destroyDirectGrid();
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style scoped>
.main-content-area {
  min-width: 200px;
}
.prescription-list-main-content {
  font-size:1em;
}

.prescription-list-main-content :deep(.k-grid-header th .k-cell-inner),
.prescription-list-main-content :deep(.k-grid-header-locked th .k-cell-inner) {
  min-height: 2.4em;

  display: flex;
  align-items: center;

  box-sizing: border-box;
}

.prescription-list-main-content :deep(.k-grid-header th),
.prescription-list-main-content :deep(.k-grid-header-locked th) {
  padding-top: 0 !important;
  padding-bottom: 0 !important;
}

.prescription-list-main-content :deep(.k-grid-header-locked th),
.prescription-list-main-content :deep(.k-grid-header-locked .k-table-th) {
  vertical-align: middle !important;
  padding-top: 0 !important;
  padding-bottom: 0 !important;
}

.prescription-list-main-content :deep(.k-grid-content-locked),
.prescription-list-main-content :deep(.k-grid-content) {
  background-color: var(--main-background-color);
}

.prescription-list-main-content :deep(.k-grid-header-locked th),
.prescription-list-main-content :deep(.k-grid-header-locked .k-table-th) {
  text-align: left;
  vertical-align: middle;
}


.prescription-list-main-content :deep(.k-grid-header tr),
.prescription-list-main-content :deep(.k-grid-header-locked tr) {
  height: 2.6em;
}
.prescription-list-main-content :deep(.k-grid-header th),
.prescription-list-main-content :deep(.k-grid-header-locked th) {
  overflow: hidden;
}

.prescription-list-main-content :deep(.k-grid-header th),
.prescription-list-main-content :deep(.k-table-th) {
  height: 2.4em;
  padding-top: 0.2em;
  padding-bottom: 0.2em;
  padding-left: 0.3em;
  padding-right: 0.3em;
  line-height: 1.2;
  vertical-align: middle;
  box-sizing: border-box;
}

.prescription-list-main-content :deep(.k-cell-inner) {
  display: flex;
  align-items: center;
  /* min-height: 2.4em; */
  padding: 0;
}

.prescription-list-main-content :deep(.k-column-title) {
  white-space: nowrap;
}
.prescription-list-main-content :deep(.k-link) {
  white-space: normal !important;
  position: relative;
}

.prescription-list-main-content :deep(.k-sort-icon svg),
.prescription-list-main-content :deep(.k-sort-icon .k-svg-icon) {
  display: none !important;
}

.prescription-list-main-content :deep(.k-sort-icon::before) {
  display: inline-flex;
  align-items: center;
  justify-content: center;

  width: 1em;
  height: 1em;

  font-family: WebComponentsIcons;
  font-size: 16px;
  line-height: 16px;

  transform: translateY(1px);
}

.prescription-list-main-content :deep(th[aria-sort="ascending"] .k-sort-icon::before) {
  color: #ffffff !important;
  content: "▲";
}

.prescription-list-main-content :deep(th[aria-sort="descending"] .k-sort-icon::before) {
  color: #ffffff !important;
  content: "▼";
}

/* Vue2 同様: 固定列は縦スクロール可（スクロールバー非表示）、印刷時は @media print で全行展開 */
.prescription-list-main-content :deep(.k-grid-content-locked) {
  touch-action: auto;
  -webkit-overflow-scrolling: touch;
  overflow-y: auto;
  overflow-x: hidden;
  scrollbar-width: none;
}
.prescription-list-main-content :deep(.k-grid-content-locked::-webkit-scrollbar) {
  display: none;
}
.prescription-list-main-content :deep(.k-grid-header-locked),
.prescription-list-main-content :deep(.k-grid-header-locked th),
.prescription-list-main-content :deep(.k-grid-header-locked .k-table-th) {
  border-color: var(--master-maintenance-kgrid-header-background-color);
}
.prescription-list-main-content :deep(.k-grid-header-locked th:last-child),
.prescription-list-main-content :deep(.k-grid-content-locked td:last-child) {
  border-right: none !important;
}

.prescription-list-main-content :deep(.k-grid-header-wrap th:first-child),
.prescription-list-main-content :deep(.k-grid-content td:first-child) {
  border-left: none !important;
}

.prescription-list-main-content :deep(.k-grid-content-locked),
.prescription-list-main-content :deep(.k-grid-header-locked) {
  border-right: 0px solid #bfbfbf;
}

.prescription-list-main-content :deep(.k-grid td),
.prescription-list-main-content :deep(.k-grid th) {
  border-style: solid;
  border-color: inherit;
}

.prescription-list-main-content :deep(.k-grid-content-locked td),
.prescription-list-main-content :deep(.k-grid-header-locked th) {
  border-right: 1px solid #bfbfbf;
}

.prescription-list-main-content :deep(.k-grid-header-wrap) {
  border-left: none !important;
}

.prescription-list-main-content :deep(.k-grid-content) {
  border-left: 0.5px solid #d9d9d9 !important;
}

.prescription-list-main-content :deep(.prescription-grid-scrollbar-proxy) {
  position: absolute;
  z-index: 12;
  background: transparent;
  touch-action: none;
  cursor: default;
  user-select: none;
}

.prescription-list-main-content :deep(.k-grid tbody tr) {
  height: 2.5em;
}

.prescription-list-main-content :deep(.k-grid tbody td) {
  height: 2.5em;
  padding-top: 0.2em;
  padding-bottom: 0.2em;
  line-height: 1.2;
  box-sizing: border-box;
}

.k-grid-header tr:first-child .k-header.no-click-cell {
  cursor: default !important;
}

:deep(.ellipsis-cell) {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}


/* Vue2 Kendo locked layout contract.
   Kendo 2026 renders locked content inside flex containers; keep the locked area
   at the width Kendo/column definitions already calculated, as Kendo 2019 did. */
:deep(.k-grid-lockedcolumns .k-grid-header-locked),
:deep(.k-grid-lockedcolumns .k-grid-content-locked),
:deep(.k-grid-lockedcolumns .k-grid-footer-locked) {
  flex: 0 0 auto;
  flex-shrink: 0;
}
:deep(.k-grid-header-table .k-table-thead .k-table-row:nth-child(1) .k-link){
  cursor: default !important;
}
:deep(.master-grid-header){
  background-image: none !important;
}
/* :deep(.prescription-list-direct-grid .k-grid-header .k-grid-header-locked .k-grid-header-table .k-table-row){
  height: 78px !important;
} */
/* :deep(.prescription-list-direct-grid .k-grid-header .k-grid-header-wrap .k-grid-header-table .k-table-row){
  height: 2.667em !important;
} */

/* 印刷時スタイル（Vue2 PrescriptionListComponent copy.vue と同契約） */
@media print {
  .main-content-area {
    overflow: visible !important;
    height: auto !important;
  }

  .prescription-list-main-content :deep(.k-grid-header-wrap),
  .prescription-list-main-content :deep(.k-grid-content) {
    overflow: hidden !important;
    height: auto !important;
    max-height: none !important;
  }

  .prescription-list-main-content :deep(.k-grid-content-locked) {
    height: auto !important;
    max-height: none !important;
    overflow: visible !important;
  }

  .prescription-list-main-content :deep(.k-grid-header-locked::after) {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-header-background-color);
    pointer-events: none;
  }

  .prescription-list-main-content :deep(.k-grid-content-locked::after) {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-border-color, #bfbfbf);
    pointer-events: none;
  }

  .prescription-list-main-content :deep(.k-grid-header) {
    padding-right: 0 !important;
  }

  .prescription-list-main-content :deep(.k-grid) {
    width: 100vw;
    height: auto !important;
  }

  .prescription-list-main-content {
    display: inline-block;
  }

  .prescription-list-main-content:has(table.scroll-rightmost) :deep(.k-grid-content-locked),
  .prescription-list-main-content:has(table.scroll-rightmost) :deep(.k-grid-header-locked) {
    z-index: 1;
  }

  .main-content-area:has(table.scroll-rightmost) {
    margin-left: -1px !important;
  }

  .prescription-list-main-content :deep(.k-grid-header-wrap:has(table.scroll-rightmost)),
  .prescription-list-main-content :deep(.k-grid-content:has(table.scroll-rightmost)) {
    position: static;
  }
}
:deep(.prescription-list-main-content .k-grid tbody td ){
  height: 2.667em !important;
}
:deep(.k-column-title){
  margin-top: -1px;
  /* margin-left: 1.7px; */
}
:deep(.k-grid td.k-selected:not(.master-sort-edited)),
:deep(.k-table-td.k-selected:not(.master-sort-edited)){
  background-color: transparent !important;
  box-shadow: none !important;
}
</style>
<style >
.in_class_prescription {
  color: #A356A3;
}
</style>
