export class Graphs {
  constructor() {
  }

  getGraphIcons(events) {
    return {
      yAxis: 0,
      type: 'scatter',
      name: 'Events',
      showInLegend: false,
      shared: false,
      tooltip: {
        headerFormat: '',
        pointFormat: '<strong>{point.name}</strong><br/>{point.text}',
        shared: false
      },
      data: events
    };
  }

  getBVGraph(events, graphData) {
    if (!events) events = [];
    if (!graphData) graphData = [];
    return {
      cd: 1,
      name: "BVグラフ",
      graphSetting: [{
        cd: 1,
        name: "-7.5 ~ 2.5",
        setting: {
          yAxis: [{
            title: {
              margin: 10,
              text: "ΔBV[%]"
            },
            min: -7.5,
            max: 2.5,
            tickInterval: 2.5
          },
          {
            title: {
              margin: 20,
              text: "血圧[mmHg]/脈拍[bpm]"
            },
            min: 0,
            max: 200,
            tickInterval: 50
          }]
        }
      }, {
        cd: 2,
        name: "-15 ~ 5",
        setting: {
          yAxis: [{
            min: -15,
            max: 5,
            tickInterval: 5
          }]
        }
      }, {
        cd: 3,
        name: "-30 ~ 10",
        setting: {
          yAxis: [{
            min: -30,
            max: 10,
            tickInterval: 10
          }]
        }
      }],
      setting: {
        xAxis: {
          title: {
            text: '経過時間[h]'
          }
        },
        series: events.length > 0 ? [this.getGraphIcons(events)].concat(graphData) : graphData
      }
    };
  }

  getBVSubGraph(events, graphData) {
    if (!events) events = [];
    if (!graphData) graphData = [];
    return {
      cd: 1,
      name: "BVグラフサブチャート",
      graphSetting: [{
        cd: 1,
        name: "0 ~ 2",
        setting: {
          yAxis: [{
            title: {
              margin: 10,
              text: "除水速度[L/h]/PRR[L/h]"
            },
            min: 0,
            max: 2,
            tickInterval: 0.5
          },
          {
            title: {
              margin: 20,
              text: "透析液濃度[mS/cm]"
            },
            min: 12,
            max: 16,
            tickInterval: 2
          }]
        }
      }, {
        cd: 2,
        name: "0 ~ 4",
        setting: {
          yAxis: [{
            min: 0,
            max: 4,
            tickInterval: 1
          }]
        }
      }],
      setting: {
        xAxis: {
          title: {
            text: '経過時間[h]'
          }
        },
        series: events.length > 0 ? [this.getGraphIcons(events)].concat(graphData) : graphData
      }
    };
  }

  getRenalReplacementTherapyGraph(events, graphData) {
    if (!events) events = [];
    if (!graphData) graphData = [];
    return {
      cd: 2,
      name: "透析量モニタ（DDM）グラフ",
      graphSetting: [{
        cd: 1,
        name: "0 ~ 2",
        setting: {
          yAxis: [{
            title: {
              margin: 10,
              text: "[Kt/V]"
            },
            min: 0,
            max: 2,
            tickInterval: 0.5
          },
          {
            title: {
              margin: 20,
              text: "URR[%]"
            },
            min: 0,
            max: 100,
            tickInterval: 25
          }]
        }
      }, {
        cd: 2,
        name: "0 ~ 3",
        setting: {
          yAxis: [{
            min: 0,
            max: 3,
            tickInterval: 0.5
          }]
        }
      }],
      setting: {
        xAxis: {
          title: {
            text: '経過時間[h]'
          }
        },
        series: events.length > 0 ? [this.getGraphIcons(events)].concat(graphData) : graphData
      }
    };
  }

  getRenalReplacementTherapySubGraph(events, graphData) {
    if (!events) events = [];
    if (!graphData) graphData = [];
    return {
      cd: 2,
      name: "透析量モニタ（DDM）グラフ サブチャート",
      graphSetting: [{
        cd: 1,
        name: "0 ~ 2",
        setting: {
          yAxis: [{
            title: {
              margin: 10,
              text: "除水速度[L/h]"
            },
            min: 0,
            max: 2,
            tickInterval: 0.5
          },
          {
            title: {
              margin: 20,
              text: "流量[mL/min]"
            },
            min: 0,
            max: 800,
            tickInterval: 200
          }]
        }
      }, {
        cd: 2,
        name: "0 ~ 4",
        setting: {
          yAxis: [{
            min: 0,
            max: 4,
            tickInterval: 1
          }]
        }
      }],
      setting: {
        xAxis: {
          title: {
            text: '経過時間[h]'
          }
        },
        series: events.length > 0 ? [this.getGraphIcons(events)].concat(graphData) : graphData
      }
    };
  }

  getHtGraph(events, graphData) {
    if (!events) events = [];
    if (!graphData) graphData = [];
    return {
      cd: 3,
      name: "Htグラフ",
      graphSetting: [{
        cd: 1,
        name: "10 ~ 30",
        setting: {
          yAxis: [{
            title: {
              margin: 10,
              text: "Ht[%]"
            },
            min: 10,
            max: 30,
            tickInterval: 5
          },
          {
            title: {
              margin: 20,
              text: "血圧[mmHg]/脈拍[bpm]"
            },
            min: 0,
            max: 200,
            tickInterval: 50
          }]
        }
      }, {
        cd: 2,
        name: "15 ~ 35",
        setting: {
          yAxis: [{
            min: 15,
            max: 35,
            tickInterval: 5
          }]
        }
      }, {
        cd: 3,
        name: "20 ~ 40",
        setting: {
          yAxis: [{
            min: 20,
            max: 40,
            tickInterval: 5
          }]
        }
      }, {
        cd: 4,
        name: "25 ~ 45",
        setting: {
          yAxis: [{
            min: 25,
            max: 45,
            tickInterval: 5
          }]
        }
      }, {
        cd: 5,
        name: "30 ~ 50",
        setting: {
          yAxis: [{
            min: 30,
            max: 50,
            tickInterval: 5
          }]
        }
      }, {
        cd: 6,
        name: "35 ~ 55",
        setting: {
          yAxis: [{
            min: 35,
            max: 55,
            tickInterval: 5
          }]
        }
      }, {
        cd: 7,
        name: "40 ~ 60",
        setting: {
          yAxis: [{
            min: 40,
            max: 60,
            tickInterval: 5
          }]
        }
      }],
      setting: {
        xAxis: {
          title: {
            text: '経過時間[h]'
          }
        },
        series: events.length > 0 ? [this.getGraphIcons(events)].concat(graphData) : graphData
      }
    };
  }

  getHtSubGraph(events, graphData) {
    if (!events) events = [];
    if (!graphData) graphData = [];
    return {
      cd: 3,
      name: "Htグラフサブチャート",
      graphSetting: [{
        cd: 1,
        name: "0 ~ 2",
        setting: {
          yAxis: [{
            title: {
              margin: 10,
              text: "除水速度[L/h]/PRR[L/h]"
            },
            min: 0,
            max: 2,
            tickInterval: 0.5
          },
          {
            title: {
              margin: 20,
              text: "透析液濃度[mS/cm]"
            },
            min: 12,
            max: 16,
            tickInterval: 2
          }]
        }
      }, {
        cd: 2,
        name: "0 ~ 4",
        setting: {
          yAxis: [{
            min: 0,
            max: 4,
            tickInterval: 1
          }]
        }
      }],
      setting: {
        xAxis: {
          title: {
            text: '経過時間[h]'
          }
        },
        series: events.length > 0 ? [this.getGraphIcons(events)].concat(graphData) : graphData
      }
    };
  }

  getRecirculationRateGraph(events, graphData) {
    if (!events) events = [];
    if (!graphData) graphData = [];
    return {
      cd: 4,
      name: "再循環率グラフ",
      graphSetting: [{
        cd: 1,
        name: "0 ~ 50",
        setting: {
          yAxis: [{
            title: {
              margin: 10,
              text: "[%]"
            },
            min: 0,
            max: 50,
            tickInterval: 10
          },
          {
            title: {
              margin: 20,
              text: ""
            },
            min: null,
            max: null,
          }]
        }
      }, {
        cd: 2,
        name: "0 ~ 100",
        setting: {
          yAxis: [{
            min: 0,
            max: 100,
            tickInterval: 20
          }]
        }
      }],
      setting: {
        xAxis: {
          title: {
            text: '経過時間[h]'
          }
        },
        series: events.length > 0 ? [this.getGraphIcons(events)].concat(graphData) : graphData
      }
    };
  }
  getRecirculationRateSubGraph(events, graphData) {
    if (!events) events = [];
    if (!graphData) graphData = [];
    return {
      cd: 4,
      name: "再循環率グラフサブチャート",
      setting: {
        xAxis: {
          title: {
            text: '経過時間[h]'
          }
        },
        series: events.length > 0 ? [this.getGraphIcons(events)].concat(graphData) : graphData
      }
    };
  }
}
