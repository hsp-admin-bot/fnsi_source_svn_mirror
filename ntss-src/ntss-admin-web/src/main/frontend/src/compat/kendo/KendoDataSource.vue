<script>
import { markRaw, toRaw } from "vue";
import { createDataSource, normalizeKendoDataSourceOptions, setKendoDataSourceItems, readKendoDataSource, refreshKendoDataSource, syncKendoDataSource, getKendoDataSourceItemByUid, getKendoDataSourceDirtyItems, hasKendoDataSourceChanges } from "@/compat/kendo/data-source.js";

export default {
  name: "KendoDataSource",
  inheritAttrs: false,
  props: {
    data: { type: [Array, Object], default: undefined },
    transport: { type: Object, default: undefined },
    schema: { type: Object, default: undefined },
    pageSize: { type: [Number, String], default: undefined },
    serverPaging: { type: Boolean, default: undefined },
    serverSorting: { type: Boolean, default: undefined },
    serverFiltering: { type: Boolean, default: undefined },
    sort: { type: [Array, Object], default: undefined },
    filter: { type: [Array, Object], default: undefined },
    group: { type: [Array, Object], default: undefined },
    aggregate: { type: [Array, Object], default: undefined }
  },
  data() {
    return {
      dataSource: null
    };
  },
  created() {
    this.recreateDataSource();
  },
  watch: {
    data: { deep: true, handler(nextData) { this.setData(nextData); } },
    transport: { deep: true, handler() { this.recreateDataSource(); } },
    schema: { deep: true, handler() { this.recreateDataSource(); } },
    pageSize() { this.recreateDataSource(); },
    serverPaging() { this.recreateDataSource(); },
    serverSorting() { this.recreateDataSource(); },
    serverFiltering() { this.recreateDataSource(); },
    sort: { deep: true, handler() { this.recreateDataSource(); } },
    filter: { deep: true, handler() { this.recreateDataSource(); } },
    group: { deep: true, handler() { this.recreateDataSource(); } },
    aggregate: { deep: true, handler() { this.recreateDataSource(); } },
    $attrs: { deep: true, handler() { this.recreateDataSource(); } }
  },
  methods: {
    buildOptions() {
      const options = {};
      [
        "data",
        "transport",
        "schema",
        "pageSize",
        "serverPaging",
        "serverSorting",
        "serverFiltering",
        "sort",
        "filter",
        "group",
        "aggregate"
      ].forEach((key) => {
        if (this[key] !== undefined) {
          options[key] = toRaw(this[key]);
        }
      });
      Object.entries(this.$attrs || {}).forEach(([key, value]) => {
        if (options[key] === undefined) {
          options[key] = toRaw(value);
        }
      });
      return normalizeKendoDataSourceOptions(options);
    },
    recreateDataSource() {
      const options = this.buildOptions();
      this.dataSource = markRaw(createDataSource(options));
      return this.dataSource;
    },
    kendoWidget() {
      return this.dataSource;
    },
    getDataSource() {
      return this.dataSource;
    },
    setData(nextData) {
      if (!this.dataSource) {
        this.recreateDataSource();
      }
      return setKendoDataSourceItems(this.dataSource, toRaw(nextData));
    },
    data(nextData) {
      if (!this.dataSource) {
        this.recreateDataSource();
      }
      if (nextData !== undefined) {
        return this.setData(nextData);
      }
      return this.dataSource?.data?.() || [];
    },
    view() {
      return this.dataSource?.view?.() || this.data();
    },
    read() {
      return readKendoDataSource(this.dataSource);
    },
    refresh() {
      return refreshKendoDataSource(this.dataSource);
    },
    sync() {
      return syncKendoDataSource(this.dataSource);
    },
    total() {
      return this.dataSource?.total?.() ?? this.view().length;
    },
    at(index) {
      return this.dataSource?.at?.(index) || this.view()[index] || null;
    },
    get(id) {
      return this.dataSource?.get?.(id) || null;
    },
    getByUid(uid) {
      return getKendoDataSourceItemByUid(this.dataSource, uid);
    },
    page(nextPage) {
      if (nextPage !== undefined) {
        return this.dataSource?.page?.(nextPage);
      }
      return this.dataSource?.page?.() ?? 1;
    },
    pageSize(nextPageSize) {
      if (nextPageSize !== undefined) {
        return this.dataSource?.pageSize?.(nextPageSize);
      }
      return this.dataSource?.pageSize?.() ?? this.view().length;
    },
    sort(nextSort) {
      if (nextSort !== undefined) {
        return this.dataSource?.sort?.(toRaw(nextSort));
      }
      return this.dataSource?.sort?.() || null;
    },
    filter(nextFilter) {
      if (nextFilter !== undefined) {
        return this.dataSource?.filter?.(toRaw(nextFilter));
      }
      return this.dataSource?.filter?.() || null;
    },
    group(nextGroup) {
      if (nextGroup !== undefined) {
        return this.dataSource?.group?.(toRaw(nextGroup));
      }
      return this.dataSource?.group?.() || null;
    },
    dirtyItems() {
      return getKendoDataSourceDirtyItems(this.dataSource);
    },
    hasChanges() {
      return hasKendoDataSourceChanges(this.dataSource);
    },
    bind(eventName, handler) {
      return this.dataSource?.bind?.(eventName, handler);
    },
    unbind(eventName, handler) {
      return this.dataSource?.unbind?.(eventName, handler);
    },
    trigger(eventName, args) {
      return this.dataSource?.trigger?.(eventName, args);
    }
  },
  render() {
    return null;
  }
};
</script>
