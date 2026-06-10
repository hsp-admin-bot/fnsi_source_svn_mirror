import { EventIcon } from "@/models/treatment-record/bvms/EventIcon";

export class DataGraphs {
  constructor() {
    let iconClass = new EventIcon();
    this.bvGraphEvents = [{
      name: 'IBM',
      x: 1,
      y: 0,
      marker: { symbol: 'url(' + iconClass.getIconPath(1) + ')', width: 16, height: 16 },
      text: 'Packt Publishing published <em>Learning Highcharts by Example</em>. Since then, many other books are written about Highcharts.'
    }, {
      name: 'Sony',
      x: 2,
      y: 0,
      marker: { symbol: 'url(' + iconClass.getIconPath(2) + ')', width: 16, height: 16 },
      text: 'Highsoft won "Entrepeneur of the Year" in Sogn og Fjordane, Norway'
    }];
    this.bvGraphData = [{
      yAxis: 0,
      name: 'NVDA',
      data: [{x: 0, y: -34.8}, {x: 1, y: 43.0}, {x: 2, y: 51.2}, {x: 3, y: 41.4}, {x: 4, y: 64.9}, {x: 5, y: 72.4}],
      color: '#90ed7d'
    }, {
      yAxis: 0,
      name: 'JAWS',
      data: [{x: 0, y: -69.6}, {x: 1, y: -63.7}, {x: 2, y: -63.9}, {x: 3, y: 43.7}, {x: 4, y: 66.0}, {x: 5, y: 61.7}],
      color: '#7cb5ec'
    }, {
      yAxis: 0,
      name: 'VoiceOver',
      data: [{x: 0, y: 20.2}, {x: 1, y: 30.7}, {x: 2, y: 36.8}, {x: 3, y: -30.9}, {x: 4, y: -39.6}, {x: 5, y: 47.1}],
      color: '#434348'
    }, {
      yAxis: 0,
      name: 'Narrator',
      data: [{x: 3, y: -21.4}, {x: 4, y: 30.3}],
      color: '#91e8e1'
    }, {
      yAxis: 1,
      name: 'ZoomText/Fusion',
      data: [{x: 0, y: 6.1}, {x: 1, y: 6.8}, {x: 2, y: -5.3}, {x: 3, y: -27.5}, {x: 4, y: 6.0}, {x: 5, y: 5.5}],
      color: '#f15c80'
    }, {
      yAxis: 1,
      name: 'Other',
      data: [{x: 0, y: 42.6}, {x: 1, y: 51.5}, {x: 2, y: 54.2}, {x: 3, y: 45.8}, {x: 4, y: 20.2}, {x: 5, y: 15.4}],
      color: '#f7a35c'
    }];
    this.bvSubGraphEvents = [];
    this.bvSubGraphData = [{
      yAxis: 0,
      name: 'Apple',
      data: [{x: 0, y: 6.1}, {x: 1, y: 6.8}, {x: 2, y: -5.3}, {x: 3, y: -27.5}, {x: 4, y: 6.0}, {x: 5, y: 5.5}],
      color: '#90ed7d'
    }, {
      yAxis: 0,
      name: 'Microsoft',
      data: [{x: 0, y: 1.5}, {x: 1, y: 2}, {x: 2, y: 36.8}, {x: 3, y: -30.9}, {x: 4, y: -39.6}, {x: 5, y: 47.1}],
      color: '#8085e9'
    }, {
      yAxis: 1,
      name: 'Other',
      data: [{x: 0, y: -69.6}, {x: 1, y: -63.7}, {x: 2, y: -63.9}, {x: 3, y: 43.7}, {x: 4, y: 66.0}, {x: 5, y: 61.7}],
      color: '#f7a35c'
    }];
    this.renalReplacementTherapyGraphEvents = [{
      name: 'IBM',
      x: 1,
      y: 0,
      marker: { symbol: 'url(' + iconClass.getIconPath(3) + ')', width: 16, height: 16 },
      text: 'Packt Publishing published <em>Learning Highcharts by Example</em>. Since then, many other books are written about Highcharts.'
    }];
    this.renalReplacementTherapyGraphData = [{
      yAxis: 0,
      name: 'NVDA',
      data: [{x: 0, y: -34.8}, {x: 1, y: 43.0}, {x: 2, y: 51.2}, {x: 3, y: 41.4}, {x: 4, y: 64.9}, {x: 5, y: 72.4}],
      color: '#90ed7d'
    }, {
      yAxis: 0,
      name: 'JAWS',
      data: [{x: 0, y: -69.6}, {x: 1, y: -63.7}, {x: 2, y: -63.9}, {x: 3, y: 43.7}, {x: 4, y: 66.0}, {x: 5, y: 61.7}],
      color: '#7cb5ec'
    }];
    this.renalReplacementTherapySubGraphEvents = [];
    this.renalReplacementTherapySubGraphData = [{
      yAxis: 0,
      name: 'Apple',
      data: [{x: 0, y: 6.1}, {x: 1, y: 6.8}, {x: 2, y: -5.3}, {x: 3, y: -27.5}, {x: 4, y: 6.0}, {x: 5, y: 5.5}],
      color: '#90ed7d'
    }, {
      yAxis: 0,
      name: 'Microsoft',
      data: [{x: 0, y: 20.2}, {x: 1, y: 30.7}, {x: 2, y: 36.8}, {x: 3, y: -30.9}, {x: 4, y: -39.6}, {x: 5, y: 47.1}],
      color: '#8085e9'
    }, {
      yAxis: 0,
      name: 'Other',
      data: [{x: 0, y: -21}, {x: 1, y: 1}, {x: 2, y: 1.5}, {x: 3, y: 3}, {x: 4, y: 12.0}, {x: 5, y: 25}],
      color: '#0b7a27'
    }, {
      yAxis: 1,
      name: 'Other',
      data: [{x: 0, y: -69.6}, {x: 1, y: -63.7}, {x: 2, y: -63.9}, {x: 3, y: 43.7}, {x: 4, y: 66.0}, {x: 5, y: 61.7}],
      color: '#f7a35c'
    }];
    this.htGraphEvents = [{
      name: 'IBM',
      x: 1,
      y: 0,
      marker: { symbol: 'url(' + iconClass.getIconPath(4) + ')', width: 16, height: 16 },
      text: 'Packt Publishing published <em>Learning Highcharts by Example</em>. Since then, many other books are written about Highcharts.'
    }, {
      name: 'Sony',
      x: 2,
      y: 0,
      marker: { symbol: 'url(' + iconClass.getIconPath(5) + ')', width: 16, height: 16 },
      text: 'Highsoft won "Entrepeneur of the Year" in Sogn og Fjordane, Norway'
    }];
    this.htGraphData = [{
      yAxis: 0,
      name: 'NVDA',
      data: [{x: 0, y: -34.8}, {x: 1, y: 43.0}, {x: 2, y: 51.2}, {x: 3, y: 41.4}, {x: 4, y: 64.9}, {x: 5, y: 72.4}],
      color: '#90ed7d'
    }, {
      yAxis: 0,
      name: 'JAWS',
      data: [{x: 0, y: -69.6}, {x: 1, y: -63.7}, {x: 2, y: -63.9}, {x: 3, y: 43.7}, {x: 4, y: 66.0}, {x: 5, y: 61.7}],
      color: '#7cb5ec'
    }, {
      yAxis: 0,
      name: 'VoiceOver',
      data: [{x: 0, y: 20.2}, {x: 1, y: 30.7}, {x: 2, y: 36.8}, {x: 3, y: -30.9}, {x: 4, y: -39.6}, {x: 5, y: 47.1}],
      color: '#434348'
    }, {
      yAxis: 0,
      name: 'Narrator',
      data: [{x: 3, y: -21.4}, {x: 4, y: 30.3}],
      color: '#91e8e1'
    }, {
      yAxis: 1,
      name: 'ZoomText/Fusion',
      data: [{x: 0, y: 6.1}, {x: 1, y: 6.8}, {x: 2, y: -5.3}, {x: 3, y: -27.5}, {x: 4, y: 6.0}, {x: 5, y: 5.5}],
      color: '#f15c80'
    }, {
      yAxis: 1,
      name: 'Other',
      data: [{x: 0, y: 42.6}, {x: 1, y: 51.5}, {x: 2, y: 54.2}, {x: 3, y: 45.8}, {x: 4, y: 20.2}, {x: 5, y: 15.4}],
      color: '#f7a35c'
    }];
    this.htSubGraphEvents = [];
    this.htSubGraphData = [{
      yAxis: 0,
      name: 'Apple',
      data: [{x: 0, y: 6.1}, {x: 1, y: 6.8}, {x: 2, y: -5.3}, {x: 3, y: -27.5}, {x: 4, y: 6.0}, {x: 5, y: 5.5}],
      color: '#90ed7d'
    }, {
      yAxis: 0,
      name: 'Microsoft',
      data: [{x: 0, y: 20.2}, {x: 1, y: 30.7}, {x: 2, y: 36.8}, {x: 3, y: -30.9}, {x: 4, y: -39.6}, {x: 5, y: 47.1}],
      color: '#8085e9'
    }, {
      yAxis: 1,
      name: 'Other',
      data: [{x: 0, y: -69.6}, {x: 1, y: -63.7}, {x: 2, y: -63.9}, {x: 3, y: 43.7}, {x: 4, y: 66.0}, {x: 5, y: 61.7}],
      color: '#f7a35c'
    }];
    this.recirculationRateGraphEvents = [];
    this.recirculationRateGraphData = [{
      yAxis: 0,
      name: 'NVDA',
      data: [{x: 0, y: -34.8}, {x: 1, y: 43.0}, {x: 2, y: 51.2}, {x: 3, y: 41.4}, {x: 4, y: 64.9}, {x: 5, y: 72.4}],
      color: '#90ed7d'
    }, {
      yAxis: 0,
      name: 'JAWS',
      data: [{x: 0, y: -69.6}, {x: 1, y: -63.7}, {x: 2, y: -63.9}, {x: 3, y: 43.7}, {x: 4, y: 66.0}, {x: 5, y: 61.7}],
      color: '#7cb5ec'
    }];
    this.recirculationRateSubGraphEvents = [];
    this.recirculationRateSubGraphData = [];
  }
}
