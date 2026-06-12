<template>
  <div ref="root" v-bind="$attrs">
    <slot />
  </div>
</template>

<script>
import $ from "@/compat/jquery";
import { ensureJQueryKendo } from "@/compat/kendo/kendo-jquery.js";
import { findKendoSchedulerRoot, findKendoSchedulerLayout, findKendoSchedulerToolbar, findKendoSchedulerHeaderWrap, findKendoSchedulerHeaderAllDay, findKendoSchedulerContent, findKendoSchedulerAllDay, findKendoSchedulerHeader, findKendoSchedulerNavigation, findKendoSchedulerViews, findKendoSchedulerFooter, findKendoSchedulerTitle, findKendoSchedulerNavCurrent, findKendoSchedulerNavToday, findKendoSchedulerNavPrev, findKendoSchedulerNavNext, findKendoSchedulerTables, findKendoSchedulerEvents } from "@/compat/kendo/dom.js";
import { createViewTimingGate } from "@/utils/viewTimingGate";
import { createLegacyKendoEvent, updateLegacySenderState } from "@/compat/kendo/legacy-sender.js";

function cloneResources(resources) {
  return Array.isArray(resources)
    ? resources.map((resource) => ({
        ...resource,
        dataSource: Array.isArray(resource?.dataSource)
          ? [...resource.dataSource]
          : resource?.dataSource
      }))
    : [];
}

function normalizeDataSource(source) {
  if (!source) {
    return [];
  }
  if (Array.isArray(source)) {
    return source;
  }
  if (typeof source.view === "function") {
    const view = source.view();
    if (Array.isArray(view)) {
      return view;
    }
  }
  if (typeof source.data === "function") {
    const data = source.data();
    if (Array.isArray(data)) {
      return data;
    }
  }
  if (Array.isArray(source.data)) {
    return source.data;
  }
  return source;
}


function normalizeDate(value) {
  if (value instanceof Date) {
    return new Date(value.getTime());
  }
  if (value) {
    const date = new Date(value);
    if (!Number.isNaN(date.getTime())) {
      return date;
    }
  }
  return new Date();
}

function readSchedulerDate(widget) {
  if (!widget || typeof widget.date !== "function") {
    return null;
  }
  try {
    return widget.date();
  } catch (_error) {
    return null;
  }
}

function writeSchedulerDate(widget, value) {
  if (!widget || typeof widget.date !== "function") {
    return;
  }
  try {
    widget.date(value);
  } catch (_error) {
    // Kendo 2026 can briefly expose a Scheduler instance while its internal model is rebuilding.
  }
}

function addClassBySelector(root, selector, className) {
  root?.querySelector?.(selector)?.classList?.add(className);
}

function addClasses(element, classNames) {
  if (!element || !classNames) {
    return;
  }
  String(classNames).split(/\s+/).filter(Boolean).forEach((className) => {
    element.classList?.add?.(className);
  });
}

function addClassesToAll(elements, classNames) {
  (elements || []).forEach((element) => addClasses(element, classNames));
}

function findButtonByRefOrText(root, selectors, fallbackText = "") {
  for (const selector of selectors) {
    const button = root?.querySelector?.(selector);
    if (button) {
      return button;
    }
  }
  if (!fallbackText) {
    return null;
  }
  return Array.from(root?.querySelectorAll?.("button, a") || []).find((button) => {
    return String(button.textContent || "").trim() === fallbackText;
  }) || null;
}

function isPlainObject(value) {
  return value != null && typeof value === "object" && !Array.isArray(value);
}

function collectSchedulerViewsFromVNodes(nodes, acc = []) {
  (nodes || []).forEach((node) => {
    if (!node || typeof node !== "object") {
      return;
    }
    if (Array.isArray(node)) {
      collectSchedulerViewsFromVNodes(node, acc);
      return;
    }
    const nodeType = node.type;
    const nodeName = typeof nodeType === "object"
      ? (nodeType.name || nodeType.__name || "")
      : "";
    if (["KendoSchedulerView", "SchedulerView", "kendo-scheduler-view"].includes(nodeName)) {
      acc.push({ ...(node.props || {}) });
      return;
    }
    if (Array.isArray(node.children)) {
      collectSchedulerViewsFromVNodes(node.children, acc);
      return;
    }
    if (isPlainObject(node.children)) {
      Object.values(node.children).forEach((child) => {
        if (typeof child === "function") {
          try {
            collectSchedulerViewsFromVNodes(child(), acc);
          } catch (_error) {
            // noop
          }
        }
      });
    }
  });
  return acc;
}

function normalizeSchedulerView(view) {
  const normalized = {};
  Object.entries(view || {}).forEach(([key, value]) => {
    const normalizedKey = String(key).replace(/-([a-z])/g, (_m, char) => char.toUpperCase());
    normalized[normalizedKey] = value;
  });
  return normalized;
}


export default {
  name: "KendoScheduler",
  inheritAttrs: false,
  props: {
    selectable: { type: Boolean, default: false },
    editable: { type: [Boolean, Object], default: false },
    footerCommand: { type: [Boolean, String], default: true },
    dataSource: { type: [Array, Object], default: () => [] },
    currentTimeMarker: { type: Boolean, default: true },
    allDayEventTemplate: { type: Function, default: null },
    eventTemplate: { type: Function, default: null },
    dateHeaderTemplate: { type: Function, default: null },
    majorTimeHeaderTemplate: { type: Function, default: null },
    workWeekStart: { type: Number, default: 1 },
    workWeekEnd: { type: Number, default: 5 },
    workDayStart: { type: Date, default: null },
    workDayEnd: { type: Date, default: null },
    resources: { type: Array, default: () => [] },
    views: { type: Array, default: () => [] },
    dataBinding: { type: Function, default: null },
    dataBound: { type: Function, default: null },
    change: { type: Function, default: null },
    edit: { type: Function, default: null },
    save: { type: Function, default: null },
    remove: { type: Function, default: null },
    add: { type: Function, default: null },
    cancel: { type: Function, default: null },
    moveStart: { type: Function, default: null },
    move: { type: Function, default: null },
    moveEnd: { type: Function, default: null },
    resizeStart: { type: Function, default: null },
    resize: { type: Function, default: null },
    resizeEnd: { type: Function, default: null },
    height: { type: [Number, String], default: null },
    timezone: { type: String, default: null }
  },
  emits: ["navigate", "dataBinding", "dataBound", "change", "edit", "save", "remove", "add", "cancel", "moveStart", "move", "moveEnd", "resizeStart", "resize", "resizeEnd"],
  data() {
    return {
      widget: null,
      internalResources: cloneResources(this.resources),
      refreshTimer: null,
      domSyncTimer: null,
      domSyncFrame: null,
      schedulerTimingGate: null,
      pendingStructureRefresh: false,
      pendingDataRefresh: false,
      lastStructureSignature: "",
      currentDate: null
    };
  },
  created() {
    this.schedulerTimingGate = createViewTimingGate("kendo-scheduler");
  },
  watch: {
    resources: {
      deep: true,
      handler(value) {
        this.internalResources = cloneResources(value);
        this.scheduleRefresh({ rebuild: true });
      }
    },
    views: {
      deep: true,
      handler() {
        this.scheduleRefresh({ rebuild: true });
      }
    },
    dataSource: {
      deep: true,
      handler() {
        this.scheduleRefresh({ rebuild: false });
      }
    },
    selectable() { this.scheduleRefresh({ rebuild: true }); },
    editable: {
      deep: true,
      handler() {
        this.scheduleRefresh({ rebuild: true });
      }
    },
    currentTimeMarker() { this.scheduleRefresh({ rebuild: true }); },
    workWeekStart() { this.scheduleRefresh({ rebuild: true }); },
    workWeekEnd() { this.scheduleRefresh({ rebuild: true }); },
    workDayStart() { this.scheduleRefresh({ rebuild: true }); },
    workDayEnd() { this.scheduleRefresh({ rebuild: true }); },
    height() { this.scheduleRefresh({ rebuild: true }); },
    timezone() { this.scheduleRefresh({ rebuild: true }); }
  },
  mounted() {
    this.scheduleRefresh({ rebuild: true });
  },
  beforeUnmount() {
    clearTimeout(this.refreshTimer);
    clearTimeout(this.domSyncTimer);
    if (typeof cancelAnimationFrame === 'function' && this.domSyncFrame !== null) {
      cancelAnimationFrame(this.domSyncFrame);
    }
    this.schedulerTimingGate?.destroy?.();
    this.destroyWidget();
  },
  methods: {
    captureSchedulerTimingToken() {
      return this.schedulerTimingGate?.capture?.() ?? 0;
    },
    isSchedulerTimingActive(token = null) {
      if (!this.schedulerTimingGate) {
        return true;
      }
      return token == null
        ? this.schedulerTimingGate.isAlive()
        : this.schedulerTimingGate.isCurrent(token);
    },
    buildStructureSignature() {
      return JSON.stringify({
        selectable: this.selectable,
        editable: this.editable,
        footerCommand: this.footerCommand,
        currentTimeMarker: this.currentTimeMarker,
        workWeekStart: this.workWeekStart,
        workWeekEnd: this.workWeekEnd,
        workDayStart: this.workDayStart ? new Date(this.workDayStart).toISOString?.() || String(this.workDayStart) : null,
        workDayEnd: this.workDayEnd ? new Date(this.workDayEnd).toISOString?.() || String(this.workDayEnd) : null,
        height: this.height,
        timezone: this.timezone,
        views: this.resolveViews().map((view) => ({ ...view, template: undefined })),
        resources: (this.internalResources || []).map((resource) => ({
          field: resource?.field,
          dataTextField: resource?.dataTextField,
          dataValueField: resource?.dataValueField,
          valuePrimitive: resource?.valuePrimitive,
          multiple: resource?.multiple
        }))
      });
    },
    needsStructureRebuild() {
      return !this.widget || this.lastStructureSignature !== this.buildStructureSignature();
    },
    scheduleRefresh({ rebuild = true } = {}) {
      clearTimeout(this.refreshTimer);
      if (rebuild) {
        this.pendingStructureRefresh = true;
      } else {
        this.pendingDataRefresh = true;
      }
      const token = this.schedulerTimingGate?.invalidate?.() ?? 0;
      this.refreshTimer = setTimeout(() => {
        this.$nextTick(() => {
          if (!this.isSchedulerTimingActive(token)) {
            return;
          }
          const shouldRebuild = this.pendingStructureRefresh || this.needsStructureRebuild();
          this.pendingStructureRefresh = false;
          this.pendingDataRefresh = false;
          if (shouldRebuild) {
            this.createWidget(token);
            return;
          }
          this.refreshDataOnly(token);
        });
      }, 0);
    },
    scheduleDomSync() {
      clearTimeout(this.domSyncTimer);
      if (typeof cancelAnimationFrame === 'function' && this.domSyncFrame !== null) {
        cancelAnimationFrame(this.domSyncFrame);
      }
      const run = () => {
        this.afterDataBound();
      };
      if (typeof requestAnimationFrame === 'function') {
        this.domSyncFrame = requestAnimationFrame(() => {
          this.domSyncFrame = null;
          this.domSyncTimer = setTimeout(run, 0);
        });
      } else {
        this.domSyncTimer = setTimeout(run, 0);
      }
    },
    refreshDataOnly(token = this.captureSchedulerTimingToken()) {
      if (!this.widget || !this.isSchedulerTimingActive(token)) {
        return;
      }
      if (typeof this.widget.setDataSource === "function") {
        this.widget.setDataSource(this.dataSource);
      } else if (this.widget.dataSource?.data && Array.isArray(this.dataSource)) {
        this.widget.dataSource.data(this.dataSource);
      } else {
        this.createWidget(token);
        return;
      }
      this.refreshScheduler();
    },
    destroyWidget() {
      if (this.widget?.destroy) {
        this.widget.destroy();
      }
      this.widget = null;
    },
    resolveCurrentDate(previousWidget = null) {
      const widgetDate = readSchedulerDate(previousWidget);
      if (widgetDate) {
        this.currentDate = normalizeDate(widgetDate);
        return this.currentDate;
      }
      if (this.$attrs?.date) {
        this.currentDate = normalizeDate(this.$attrs.date);
        return this.currentDate;
      }
      if (this.currentDate) {
        return normalizeDate(this.currentDate);
      }
      this.currentDate = new Date();
      return this.currentDate;
    },
    resolveCurrentViewName(previousWidget = null) {
      const currentView = previousWidget?.view?.();
      if (currentView?.name) {
        return currentView.name;
      }
      if (currentView?.type) {
        return currentView.type;
      }
      const sourceViews = this.resolveViews();
      const selected = sourceViews.find((view) => view.selected)?.type;
      return selected || sourceViews[0]?.type || "day";
    },
    resolveViews() {
      const slotViews = collectSchedulerViewsFromVNodes(this.$slots.default ? this.$slots.default() : []);
      if (slotViews.length > 0) {
        return slotViews.map((view) => normalizeSchedulerView(view));
      }
      if (Array.isArray(this.views) && this.views.length > 0) {
        return this.views;
      }
      return [{ type: "day", selected: true }];
    },
    buildViews(selectedViewName) {
      return this.resolveViews().map((view, index) => {
        const normalized = { ...view };
        const selected = normalized.type === selectedViewName || (!selectedViewName && normalized.selected === true) || (!selectedViewName && index === 0);
        return {
          ...normalized,
          selected,
          type: normalized.type || "day",
          workWeekStart: normalized.workWeekStart ?? this.workWeekStart,
          workWeekEnd: normalized.workWeekEnd ?? this.workWeekEnd,
          workDayStart: normalized.workDayStart ?? this.workDayStart,
          workDayEnd: normalized.workDayEnd ?? this.workDayEnd
        };
      });
    },
    buildResources() {
      return (this.internalResources || []).map((resource) => ({
        ...resource,
        dataSource: normalizeDataSource(resource?.dataSource)
      }));
    },
    createSchedulerLegacyEventHandler(eventName, propHandler = null) {
      return (e) => {
        this.scheduleDomSync();
        const compatEvent = this.createSchedulerEvent(e, {
          type: eventName,
          eventName,
          event: e?.event,
          slot: e?.slot,
          start: e?.start,
          end: e?.end,
          resources: e?.resources,
          data: e?.data,
          item: e?.item
        });
        this.$emit(eventName, compatEvent);
        if (typeof propHandler === "function") {
          propHandler(compatEvent);
        }
        return compatEvent;
      };
    },
    buildOptions(previousWidget = null) {
      const selectedViewName = this.resolveCurrentViewName(previousWidget);
      const options = {
        selectable: this.selectable,
        editable: this.editable,
        footer: this.footerCommand,
        footerCommand: this.footerCommand,
        dataSource: this.dataSource,
        currentTimeMarker: this.currentTimeMarker,
        views: this.buildViews(selectedViewName),
        resources: this.buildResources(),
        date: this.resolveCurrentDate(previousWidget),
        navigate: (e) => {
          this.scheduleDomSync();
          const compatEvent = this.createSchedulerEvent(e, {
            type: "navigate",
            action: e?.action,
            viewName: e?.view || e?.viewName
          });
          this.currentDate = normalizeDate(compatEvent.date || readSchedulerDate(compatEvent.sender));
          this.$emit("navigate", compatEvent);
        },
        dataBinding: this.createSchedulerLegacyEventHandler("dataBinding", this.dataBinding),
        dataBound: (e) => {
          this.afterDataBound();
          const compatEvent = this.createSchedulerEvent(e, { type: "dataBound" });
          this.$emit("dataBound", compatEvent);
          if (typeof this.dataBound === "function") {
            this.dataBound(compatEvent);
          }
        },
        change: this.createSchedulerLegacyEventHandler("change", this.change),
        edit: this.createSchedulerLegacyEventHandler("edit", this.edit),
        save: this.createSchedulerLegacyEventHandler("save", this.save),
        remove: this.createSchedulerLegacyEventHandler("remove", this.remove),
        add: this.createSchedulerLegacyEventHandler("add", this.add),
        cancel: this.createSchedulerLegacyEventHandler("cancel", this.cancel),
        moveStart: this.createSchedulerLegacyEventHandler("moveStart", this.moveStart),
        move: this.createSchedulerLegacyEventHandler("move", this.move),
        moveEnd: this.createSchedulerLegacyEventHandler("moveEnd", this.moveEnd),
        resizeStart: this.createSchedulerLegacyEventHandler("resizeStart", this.resizeStart),
        resize: this.createSchedulerLegacyEventHandler("resize", this.resize),
        resizeEnd: this.createSchedulerLegacyEventHandler("resizeEnd", this.resizeEnd)
      };
      if (this.eventTemplate) {
        options.eventTemplate = this.eventTemplate;
      }
      if (this.allDayEventTemplate) {
        options.allDayEventTemplate = this.allDayEventTemplate;
      }
      if (this.dateHeaderTemplate) {
        options.dateHeaderTemplate = this.dateHeaderTemplate;
      }
      if (this.majorTimeHeaderTemplate) {
        options.majorTimeHeaderTemplate = this.majorTimeHeaderTemplate;
      }
      if (this.height !== null && this.height !== undefined) {
        options.height = this.height;
      }
      if (this.timezone) {
        options.timezone = this.timezone;
      }
      return options;
    },
    createSchedulerEvent(rawEvent = null, payload = {}) {
      const sender = rawEvent?.sender || this.widget;
      const senderDate = readSchedulerDate(sender) || this.resolveCurrentDate(sender);
      if (sender) {
        updateLegacySenderState(sender, {
          value: senderDate,
          text: sender.view?.()?.title || sender.view?.()?.name || sender.view?.()?.type || "",
          element: sender.element || $(this.$refs.root),
          wrapper: sender.wrapper || sender.element || $(this.$refs.root)
        });
      }
      return createLegacyKendoEvent(rawEvent, sender, {
        view: sender?.view?.(),
        date: senderDate,
        dataSource: sender?.dataSource,
        ...payload
      });
    },
    async createWidget(token = this.captureSchedulerTimingToken()) {
      await ensureJQueryKendo();
      const root = this.$refs.root;
      if (!root || !this.isSchedulerTimingActive(token)) {
        return;
      }
      const $root = $(root);
      const previousWidget = this.widget || $root.data("kendoScheduler") || null;
      const options = this.buildOptions(previousWidget);
      if (previousWidget?.destroy) {
        previousWidget.destroy();
      }
      $root.addClass("k-widget k-scheduler ntss-kendo-scheduler-legacy");
      $root.empty();
      $root.kendoScheduler(options);
      if (!this.isSchedulerTimingActive(token)) {
        try {
          $root.data("kendoScheduler")?.destroy?.();
        } catch (_error) {
          // noop
        }
        return;
      }
      this.widget = $root.data("kendoScheduler") || null;
      this.lastStructureSignature = this.buildStructureSignature();
      this.afterDataBound();
      this.scheduleDomSync();
    },
    afterDataBound() {
      this.syncWidgetCompatRefs();
    },
    syncWidgetCompatRefs() {
      const root = this.$refs.root;
      if (!root || !this.widget) {
        return;
      }
      const schedulerRoot = findKendoSchedulerRoot(root) || root;
      this.widget.element = this.widget.element || $(root);
      this.widget.wrapper = this.widget.wrapper || $(schedulerRoot);
      this.applyLegacySchedulerClasses(schedulerRoot);
      const schedulerDate = readSchedulerDate(this.widget) || this.resolveCurrentDate(this.widget);
      updateLegacySenderState(this.widget, {
        value: schedulerDate,
        text: this.widget.view?.()?.title || this.widget.view?.()?.name || this.widget.view?.()?.type || "",
        element: this.widget.element,
        wrapper: this.widget.wrapper
      });
    },
    applyLegacySchedulerClasses(schedulerRoot) {
      if (!schedulerRoot) {
        return;
      }
      addClasses(schedulerRoot, "k-widget k-scheduler ntss-kendo-scheduler-legacy");
      addClasses(findKendoSchedulerLayout(schedulerRoot), "k-scheduler-layout");
      addClasses(findKendoSchedulerToolbar(schedulerRoot), "k-scheduler-toolbar k-toolbar");
      addClasses(findKendoSchedulerNavigation(schedulerRoot), "k-scheduler-navigation");
      addClasses(findKendoSchedulerViews(schedulerRoot), "k-scheduler-views");
      addClasses(findKendoSchedulerHeader(schedulerRoot), "k-scheduler-header");
      addClasses(findKendoSchedulerHeaderWrap(schedulerRoot), "k-scheduler-header-wrap");
      addClasses(findKendoSchedulerHeaderAllDay(schedulerRoot), "k-scheduler-header-all-day");
      addClasses(findKendoSchedulerContent(schedulerRoot), "k-scheduler-content");
      addClasses(findKendoSchedulerAllDay(schedulerRoot), "k-scheduler-times-all-day");
      addClasses(findKendoSchedulerFooter(schedulerRoot), "k-scheduler-footer");
      addClassesToAll(findKendoSchedulerTables(schedulerRoot), "k-scheduler-table");
      addClassesToAll(findKendoSchedulerEvents(schedulerRoot), "k-event");

      const current = findKendoSchedulerNavCurrent(schedulerRoot);
      addClasses(current, "k-nav-current");
      const today = findButtonByRefOrText(schedulerRoot, ["[ref-nav-today]", ".k-nav-today", ".k-scheduler-navigation .k-today"], "今日");
      const prev = findButtonByRefOrText(schedulerRoot, ["[ref-nav-prev]", ".k-nav-prev", ".k-scheduler-navigation .k-prev"], "前");
      const next = findButtonByRefOrText(schedulerRoot, ["[ref-nav-next]", ".k-nav-next", ".k-scheduler-navigation .k-next"], "次");
      addClasses(today, "k-button k-nav-today");
      addClasses(prev, "k-button k-nav-prev");
      addClasses(next, "k-button k-nav-next");
      this.applyLegacyToolbarClasses(schedulerRoot);
    },
    applyLegacyToolbarClasses(schedulerRoot) {
      addClassBySelector(schedulerRoot, "[ref-nav-today]", "k-nav-today");
      addClassBySelector(schedulerRoot, "[ref-nav-prev]", "k-nav-prev");
      addClassBySelector(schedulerRoot, "[ref-nav-next]", "k-nav-next");
      addClassBySelector(schedulerRoot, "[ref-view-day]", "k-view-day");
      addClassBySelector(schedulerRoot, "[ref-view-week]", "k-view-week");
      addClassBySelector(schedulerRoot, "[ref-view-month]", "k-view-month");
      addClassBySelector(schedulerRoot, "[ref-view-agenda]", "k-view-agenda");
      const toolbar = findKendoSchedulerToolbar(schedulerRoot) || schedulerRoot;
      Array.from(toolbar?.querySelectorAll?.("button, .k-button, [role='button']") || []).forEach((button) => {
        addClasses(button, "k-button k-button-icontext ntss-kendo-scheduler-button-legacy");
        Array.from(button.querySelectorAll?.(".k-icon, .k-svg-icon, svg") || []).forEach((icon) => {
          addClasses(icon, "ntss-kendo-scheduler-icon-legacy");
        });
        if (button.classList?.contains("k-selected") || button.getAttribute?.("aria-pressed") === "true") {
          addClasses(button, "k-state-active k-state-selected");
        }
      });
      Array.from(toolbar?.querySelectorAll?.("[data-role='buttongroup'], .k-button-group, .k-button-group-stretched") || []).forEach((group) => {
        addClasses(group, "k-button-group");
      });
      const viewButton = schedulerRoot?.querySelector?.("[ref-view-day], [ref-view-week], [ref-view-month], [ref-view-agenda]");
      viewButton?.closest?.('[data-role="buttongroup"], .k-button-group, .k-button-group-stretched')?.classList?.add("k-scheduler-views", "k-button-group");
    },
    schedulerRootEl() {
      return findKendoSchedulerRoot(this.$refs.root) || this.$refs.root || null;
    },
    schedulerLayoutEl() {
      return findKendoSchedulerLayout(this.schedulerRootEl()) || null;
    },
    schedulerToolbarEl() {
      return findKendoSchedulerToolbar(this.schedulerRootEl()) || null;
    },
    schedulerHeaderWrapEl() {
      return findKendoSchedulerHeaderWrap(this.schedulerRootEl()) || null;
    },
    schedulerHeaderAllDayEl() {
      return findKendoSchedulerHeaderAllDay(this.schedulerRootEl()) || null;
    },
    schedulerContentEl() {
      return findKendoSchedulerContent(this.schedulerRootEl()) || null;
    },
    schedulerAllDayEl() {
      return findKendoSchedulerAllDay(this.schedulerRootEl()) || null;
    },
    schedulerTitleEl() {
      return findKendoSchedulerTitle(this.schedulerRootEl()) || null;
    },
    queryScheduler(selector) {
      return this.schedulerRootEl()?.querySelector?.(selector) || null;
    },
    querySchedulerAll(selector) {
      return Array.from(this.schedulerRootEl()?.querySelectorAll?.(selector) || []);
    },
    schedulerTableEls() {
      return findKendoSchedulerTables(this.schedulerRootEl());
    },
    schedulerEventEls(selector = null) {
      if (selector) {
        return this.querySchedulerAll(selector);
      }
      return findKendoSchedulerEvents(this.schedulerRootEl());
    },
    schedulerNavCurrentEl() {
      return findKendoSchedulerNavCurrent(this.schedulerRootEl()) || null;
    },
    schedulerNavTodayEl() {
      return findKendoSchedulerNavToday(this.schedulerRootEl()) || null;
    },
    schedulerNavPrevEl() {
      return findKendoSchedulerNavPrev(this.schedulerRootEl()) || null;
    },
    schedulerNavNextEl() {
      return findKendoSchedulerNavNext(this.schedulerRootEl()) || null;
    },
    setSchedulerView(viewName) {
      if (!viewName) {
        return;
      }
      this.widget?.view?.(viewName);
      this.scheduleDomSync();
    },
    setSchedulerDate(value) {
      if (!value) {
        return;
      }
      this.currentDate = normalizeDate(value);
      writeSchedulerDate(this.widget, this.currentDate);
      this.scheduleDomSync();
    },
    refreshScheduler() {
      this.widget?.refresh?.();
      this.afterDataBound();
      this.scheduleDomSync();
    },
    setSchedulerResourceData(index, data) {
      const resource = this.widget?.resources?.[index];
      if (resource?.dataSource?.data) {
        resource.dataSource.data(Array.isArray(data) ? data : []);
        const currentViewName = this.widget?.view?.()?.name || this.widget?.view?.()?.type || null;
        if (currentViewName && this.widget?.view) {
          this.widget.view(currentViewName);
        } else {
          this.widget?.refresh?.();
        }
        this.afterDataBound();
        this.scheduleDomSync();
      }
    },
    kendoWidget() {
      return this.widget;
    }
  }
};
</script>
