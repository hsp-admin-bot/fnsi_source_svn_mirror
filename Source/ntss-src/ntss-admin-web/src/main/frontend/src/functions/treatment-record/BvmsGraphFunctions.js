import { EventIcon } from "@/models/treatment-record/bvms/EventIcon";

const validate = (obj) => {
  if (typeof obj !== 'object') {
    throw new Error(
      "[BvmsGraphFunctions.js]: Wrong response"
    );
  }
  return true;
};

const eventNameKey = 'events';

const ignoreKeys = [
  eventNameKey,
  'xaxis'
];

const Columns = {
  bvGraph: {
    dbvs: [0, "%"],
    dbvbaseValues: [0, "%"],
    dbvreferenceAreaUpperLimits: [0, "%"],
    dbvreferenceAreaLowerLimits: [0, "%"],
    dbvavr5mins: [0, "%"],
    ufpspeeds: [0, "L/h"],
    prrs: [0, "L/h"],
    sysBPs: [1, "mmHg"],
    diaBPs: [1, "mmHg"],
    pulses: [1, "bpm"],
    totalConds: [1, "mS/cm"]
  },
  ddmGraph: {
    ktVs: [0, "kt/V"],
    ufpspeeds: [0, "L/h"],
    urrs: [1, "%"],
    bpspeeds: [1, "mL/min"],
    totalConds: [1, "mL/min"],
    qss: [1, "mL/min"]
  },
  htGraph: {
    hts: [0, "%"],
    ufpspeeds: [0, "L/h"],
    prrs: [0, "L/h"],
    sysBPs: [1, "mmHg"],
    diaBPs: [1, "mmHg"],
    pulses: [1, "bpm"],
    totalConds: [1, "mS/cm"]
  },
  rrGraph: {
    recirculationRates: [0, "%"]
  }
};

const mapGraph = (obj, graphName, param) => {
  if (validate(obj)) {
    let result = {
      data: {
        graphEvents: [],
        subGraphEvents: [],
        graphData: [],
        subGraphData: []
      }
    };
    let points;
    let eventPoints;
    let iconClass = new EventIcon();
    if (obj.data) {
      Object.keys(obj.data).some(function (valueName) {
        if (valueName.search("graph") > -1) {
          points = {};
          eventPoints = [];
          Array(obj.data[valueName]).some(function (item) {
            Object.keys(item).some(function (key) {
              if (!ignoreKeys.includes(key)) { // data point
                if (!points[key]) {
                  var axis = Columns[graphName] ? (Columns[graphName][key][0] > -1 ? Columns[graphName][key][0] : 0) : 0;
                  points[key] = {
                    yAxis: axis,
                    name: convertToJapanese(key),
                    unit: Columns[graphName][key][1],
                    data: [],
                    graphName: graphName
                  }
                }
                Object.values(item[key]).some(function (axis) {
                  points[key].data.push({
                    x: axis["xaxis"],
                    y: axis["yaxis"]
                  });
                });
              } else if (key === eventNameKey) { // event point
                Object.values(item[key]).some(function (axis) {
                  if (axis["yaxis"] > 0) {
                    eventPoints.push({
                      name: '',
                      x: axis["xaxis"],
                      y: param.graph1Y1To || param.graph2Y1To,
                      marker: { symbol: 'url(' + iconClass.getIconPath(axis["yaxis"]) + ')', width: 12, height: 12 },
                      text: iconClass.getIconName(axis["yaxis"])
                    });
                  }
                });
              }
            })
          });
          if (valueName.search("graph2") > -1) {
            result.data.subGraphData = Object.values(points);
            result.data.subGraphEvents = eventPoints;
          } else if (valueName.search("graph") > -1) {
            result.data.graphData = Object.values(points);
            result.data.graphEvents = eventPoints;
          }
        }
      });
    }

    return result;
  }
};

function convertToJapanese(text) {
  switch (text) {
    case "sysBPs":
      return "最高血圧";
    case "diaBPs":
      return "最低血圧";
    case "pulses":
      return "脈拍";
    case "events":
      return "イベント";
    case "dbvavr5mins":
      return "ΔBV移動平均";
    case "dbvbaseValues":
      return "ΔBV基準線";
    case "dbvs":
      return "ΔBV";
    case "dbvreferenceAreaLowerLimits":
      return "ΔBVリファレンスエリア下限";
    case "dbvreferenceAreaUpperLimits":
      return "ΔBVリファレンスエリア上限";
    case "totalConds":
      return "透析液濃度(mS/cm)";
    case "ufpspeeds":
      return "除水速度(L/h)";
    case "prrs":
      return "PRR";
    case "ktVs":
      return "Kt/V";
    case "urrs":
      return "URR(%)";
    case "qss":
      return "透析液流量(mL/min)";
    case "bpspeeds":
      return "補液速度(L/h)";
    case "recirculationRates":
      return "再循環率(%)";
    default:
      return text;
  }
}

export const BvmsGraphFunctions = {
  mapGraph
};
