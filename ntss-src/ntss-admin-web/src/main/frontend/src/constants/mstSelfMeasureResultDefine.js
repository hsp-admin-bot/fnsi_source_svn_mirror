/**
 * 自己診断判定マスタの定数クラス.
 */

/**
 * 配管自己診断結果
 */
export const UFRC = [
  {
    key: "result",
    type: "配管自己診断",
    name: "配管自己診断結果",
    jsonAddress: "47",
    isCheckOnly: true,
    input_min: 0,
    input_max: 0,
    step: 0,
    default_failure_low: "0",
    default_failure_up: "0",
    default_caution_low: "0",
    default_caution_up: "0"
  },
  {
    key: "negativePipeLeakage",
    type: "",
    name: "配管漏れ(陰圧)[mmHg]",
    unit: "mmHg",
    jsonAddress: "43",
    isCheckOnly: false,
    input_min: -400,
    input_max: 400,
    step: 1,
    default_failure_low: "",
    default_failure_up: "20",
    default_caution_low: "",
    default_caution_up: "20"
  },
  {
    key: "positivePipeLeakage",
    type: "",
    name: "配管漏れ(陽圧)[mmHg]",
    unit: "mmHg",
    jsonAddress: "44",
    isCheckOnly: false,
    input_min: -400,
    input_max: 400,
    step: 1,
    default_failure_low: "-50",
    default_failure_up: "",
    default_caution_low: "-50",
    default_caution_up: ""
  },
  {
    key: "removal",
    type: "",
    name: "除水テスト[mmHg]",
    unit: "mmHg",
    jsonAddress: "48",
    isCheckOnly: false,
    input_min: -400,
    input_max: 400,
    step: 1,
    default_failure_low: "",
    default_failure_up: "-200",
    default_caution_low: "",
    default_caution_up: "-200"
  },
  {
    key: "balance",
    type: "",
    name: "バランステスト[mmHg]",
    unit: "mmHg",
    jsonAddress: "46",
    isCheckOnly: false,
    input_min: -400,
    input_max: 400,
    step: 1,
    default_failure_low: "-80",
    default_failure_up: "80",
    default_caution_low: "-80",
    default_caution_up: "80"
  },
  {
    key: "cfLeakage",
    type: "",
    name: "CF漏れ[mmHg]",
    unit: "mmHg",
    jsonAddress: "45",
    isCheckOnly: false,
    input_min: -400,
    input_max: 400,
    step: 1,
    default_failure_low: "",
    default_failure_up: "50",
    default_caution_low: "",
    default_caution_up: "50"
  },
  {
    key: "cf2Leakage",
    type: "",
    name: "CF2漏れ[mmHg]",
    unit: "mmHg",
    jsonAddress: "49",
    isCheckOnly: false,
    input_min: -400,
    input_max: 400,
    step: 1,
    default_failure_low: "",
    default_failure_up: "50",
    default_caution_low: "",
    default_caution_up: "50"
  }
];

/**
 * 漏血自己診断結果
 */
export const BLOOD_LEAKAGE = [
  {
    key: "voltageRed",
    type: "漏血自己診断",
    name: "赤電圧[V]",
    unit: "V",
    jsonAddress: "53",
    isCheckOnly: false,
    input_min: 0.000,
    input_max: 9.999,
    step: 0.001,
    default_failure_low: "1.000",
    default_failure_up: "",
    default_caution_low: "1.000",
    default_caution_up: ""
  },
  {
    key: "voltageGreen",
    type: "",
    name: "緑電圧[V]",
    unit: "V",
    jsonAddress: "54",
    isCheckOnly: false,
    input_min: 0.000,
    input_max: 9.999,
    step: 0.001,
    default_failure_low: "1.000",
    default_failure_up: "",
    default_caution_low: "1.000",
    default_caution_up: ""
  }
];

/**
 * 透析液流量自己診断結果
 */
export const DIALYSATE_FLOW_RATE = [
  {
    key: "dialysateFlowRate",
    type: "透析液流量自己診断",
    name: "透析液流量[mL/min]",
    unit: "mL/min",
    jsonAddress: "58",
    isCheckOnly: false,
    input_min: 0,
    input_max: 999,
    step: 1,
    default_failure_low: "450",
    default_failure_up: "550",
    default_caution_low: "450",
    default_caution_up: "550"
  }
];

/**
 * 濃度自己診断結果
 */
export const CONCENTRATION = [
  {
    key: "result",
    type: "濃度自己診断",
    name: "濃度自己診断結果",
    jsonAddress: "65",
    isCheckOnly: true,
    input_min: 0,
    input_max: 0,
    step: 0,
    default_failure_low: "0",
    default_failure_up: "0",
    default_caution_low: "0",
    default_caution_up: "0"
  },
  {
    key: "dialysateA",
    name: "透析液濃度[%]",
    unit: "％",
    jsonAddress: "64",
    isCheckOnly: false,
    input_min: -99.9,
    input_max: 99.9,
    step: 0.1,
    default_failure_low: "-5.0",
    default_failure_up: "5.0",
    default_caution_low: "-5.0",
    default_caution_up: "5.0"
  },
  {
    key: "dialysateB",
    name: "B原液濃度[%]",
    unit: "％",
    jsonAddress: "63",
    isCheckOnly: false,
    input_min: -99.9,
    input_max: 99.9,
    step: 0.1,
    default_failure_low: "-5.0",
    default_failure_up: "5.0",
    default_caution_low: "-5.0",
    default_caution_up: "5.0"
  }
];
//add 全マスタ CSV 楊 strat
export const items = new Map([
  ["ufrc_result", {name:"配管自己診断結果", type:"配管自己診断", jsonAddress:"47"}],
  ["negativePipeLeakage", {name:"配管漏れ(陰圧)[mmHg]", type:"", jsonAddress:"43"}],
  ["positivePipeLeakage", {name:"配管漏れ(陽圧)[mmHg]", type: "", jsonAddress: "44"}],
  ["removal", {name:"除水テスト[mmHg]", type: "", jsonAddress: "48"}],
  ["balance", {name:"バランステスト[mmHg]", type: "", jsonAddress: "46"}],
  ["cfLeakage", {name:"CF漏れ[mmHg]", type: "", jsonAddress: "45"}],
  ["cf2Leakage", {name:"CF2漏れ[mmHg]", type: "", jsonAddress: "49"}],
  ["voltageRed", {name:"赤電圧[V]", type: "漏血自己診断", jsonAddress: "53"}],
  ["voltageGreen", {name:"緑電圧[V]", type: "", jsonAddress: "54"}],
  ["dialysateFlowRate", {name:"透析液流量[mL/min]", type: "透析液流量自己診断", jsonAddress: "58"}],
  ["concentration_result", {name:"濃度自己診断結果", type: "濃度自己診断", jsonAddress: "65"}],
  ["dialysateA", {name:"透析液濃度[%]", type: "", jsonAddress: "64"}],
  ["dialysateB", {name:"B原液濃度[%]", type: "", jsonAddress: "63"}]
]);
//add 全マスタ CSV 楊 end