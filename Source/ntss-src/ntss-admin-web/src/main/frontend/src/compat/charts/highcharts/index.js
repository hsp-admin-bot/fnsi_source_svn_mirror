import * as HighchartsModule from "highcharts";
import * as BoostModule from "highcharts/modules/boost";
import * as ExportingModule from "highcharts/modules/exporting";
import * as XrangeModule from "highcharts/modules/xrange";
import * as HighchartsMoreModule from "highcharts/highcharts-more";
import * as BrokenAxisModule from "highcharts/modules/broken-axis";
import * as HighchartsVueModule from "highcharts-vue";

const Highcharts = HighchartsModule.default || HighchartsModule;
const HighchartsVue = HighchartsVueModule.default || HighchartsVueModule;
const Chart = HighchartsVueModule.Chart || HighchartsVueModule.default?.Chart;

const INIT_FLAG = "__ntssCommonHighchartsInitialized__";
const SET_OPTIONS_BRIDGE_FLAG = "__ntssLegacyHighchartsSetOptionsBridgeInstalled__";
const MODULE_INIT_FLAGS = {
  boost: "__ntssHighchartsBoostInitialized__",
  exporting: "__ntssHighchartsExportingInitialized__",
  xrange: "__ntssHighchartsXrangeInitialized__",
  more: "__ntssHighchartsMoreInitialized__",
  brokenAxis: "__ntssHighchartsBrokenAxisInitialized__"
};

function getModuleInitializer(moduleInitializer) {
  return moduleInitializer?.default || moduleInitializer;
}

function normalizeLegacyHighchartsOptions(options) {
  if (!options || typeof options !== "object") {
    return options;
  }

  const legacyGlobal = options.global;
  if (!legacyGlobal || !Object.prototype.hasOwnProperty.call(legacyGlobal, "useUTC")) {
    return options;
  }

  const useUTC = legacyGlobal.useUTC;
  const time = {
    ...(options.time || {})
  };

  if (!Object.prototype.hasOwnProperty.call(time, "useUTC")) {
    time.useUTC = useUTC;
  }

  if (!Object.prototype.hasOwnProperty.call(time, "timezone")) {
    time.timezone = useUTC ? "UTC" : undefined;
  }

  return {
    ...options,
    time
  };
}

function installLegacySetOptionsBridge() {
  if (Highcharts[SET_OPTIONS_BRIDGE_FLAG] || typeof Highcharts.setOptions !== "function") {
    return;
  }

  const nativeSetOptions = Highcharts.setOptions.bind(Highcharts);
  Highcharts.setOptions = function setOptionsWithLegacyTimeBridge(options) {
    return nativeSetOptions(normalizeLegacyHighchartsOptions(options));
  };

  Object.defineProperty(Highcharts, SET_OPTIONS_BRIDGE_FLAG, {
    value: true,
    configurable: false,
    enumerable: false,
    writable: false
  });
}

function applyHighchartsModule(moduleInitializer, flagName) {
  const initializer = getModuleInitializer(moduleInitializer);

  if (flagName && Highcharts[flagName]) {
    return Highcharts;
  }

  if (typeof initializer === "function") {
    initializer(Highcharts);
  }

  if (flagName) {
    Object.defineProperty(Highcharts, flagName, {
      value: true,
      configurable: false,
      enumerable: false,
      writable: false
    });
  }

  return Highcharts;
}

function createLegacyModuleInitializer(moduleInitializer, flagName) {
  return function legacyHighchartsModuleInitializer() {
    return applyHighchartsModule(moduleInitializer, flagName);
  };
}

const Boost = createLegacyModuleInitializer(BoostModule, MODULE_INIT_FLAGS.boost);
const Exporting = createLegacyModuleInitializer(ExportingModule, MODULE_INIT_FLAGS.exporting);
const Xrange = createLegacyModuleInitializer(XrangeModule, MODULE_INIT_FLAGS.xrange);
const HighchartsMore = createLegacyModuleInitializer(HighchartsMoreModule, MODULE_INIT_FLAGS.more);
const BrokenAxis = createLegacyModuleInitializer(BrokenAxisModule, MODULE_INIT_FLAGS.brokenAxis);

function initializeHighcharts() {
  installLegacySetOptionsBridge();

  if (Highcharts[INIT_FLAG]) {
    return Highcharts;
  }

  [
    Boost,
    Exporting,
    Xrange,
    HighchartsMore,
    BrokenAxis
  ].forEach((moduleInitializer) => moduleInitializer(Highcharts));

  Highcharts.setOptions({
    lang: {
      shortWeekdays: ["日", "月", "火", "水", "木", "金", "土"],
      shortMonths: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
      resetZoom: "ズーム初期化",
      resetZoomTitle: "ズーム初期化 レベル 1:1"
    },
    global: {
      useUTC: false
    },
    time: {
      useUTC: false,
      timezone: undefined
    }
  });

  Object.defineProperty(Highcharts, INIT_FLAG, {
    value: true,
    configurable: false,
    enumerable: false,
    writable: false
  });

  return Highcharts;
}

const initializedHighcharts = initializeHighcharts();

export {
  initializedHighcharts as Highcharts,
  HighchartsVue,
  Chart,
  Boost,
  Exporting,
  Xrange,
  HighchartsMore,
  BrokenAxis,
  applyHighchartsModule,
  initializeHighcharts,
  normalizeLegacyHighchartsOptions
};

export default initializedHighcharts;
