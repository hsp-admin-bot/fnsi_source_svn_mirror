/* eslint-disable */
import axios from 'axios';
import * as types from './mutation-types';

// 施設コード
// const facilitycd = 999900;
// スタッフコード 12桁
const staffcd = 'nkk';

// const apiPrefix = '';
const apiPrefix = '/monitoring/';

// url
// ベッドグループ一覧情報取得
const getbedgrouplist = `${apiPrefix}api/bed_group/`;
// グラフ設定情報取得
const getgraphsettinglist = `${apiPrefix}api/bio_moni_frame_pattern/`;
const getgraphsetting = `${apiPrefix}api/bio_moni_frame_pattern/`;
// モニタデータ項目一覧情報取得
const getmonitoritems = `${apiPrefix}api/moni_item/`;
// 装置一覧情報取得
const getmachineitems = `${apiPrefix}api/machines/`;
// モニタデータ取得
// const getmonitordata = `${apiPrefix}api/mni_monitor/search?`;

// TODO: タイマー更新機能不要時には削除してもよし <<<<
// 自動更新デモ用API（使用している個所はソースコード内に NOTE: と記述）
const getmonitordata = `${apiPrefix}api/mni_monitor/search_ex?`;
const getmonitordataDiff = `${apiPrefix}api/mni_monitor/search_ex_diff?`;
// >>>>

// 工程
const processstate = [
  { no: 1, textno: '01', name: 'プリセット', shortname: 'プ' },
  { no: 2, textno: '02', name: '洗浄', shortname: '洗' },
  { no: 3, textno: '03', name: '酸洗', shortname: '酸' },
  { no: 4, textno: '04', name: '消毒', shortname: '消' },
  { no: 5, textno: '05', name: '滞留', shortname: '滞' },
  { no: 6, textno: '06', name: '液置換', shortname: '液' },
  { no: 7, textno: '07', name: '透析準備', shortname: '準' },
  { no: 8, textno: '08', name: 'ガスパージ', shortname: 'ガ' },
  { no: 9, textno: '09', name: '排液', shortname: '排' },
  { no: 10, textno: '10', name: '停止', shortname: '停' },
  { no: 11, textno: '11', name: '運転', shortname: '運' }
];

// 治療モード
const treatmode = [
  { no: 0, name: 'HD', shortname: 'HD' },
  { no: 1, name: 'ECUM', shortname: 'ECUM' },
  { no: 2, name: 'HDF', shortname: 'HDF' },
  { no: 3, name: 'HF', shortname: 'HF' },
  { no: 4, name: 'HD＋補液', shortname: 'HD+補液' },
  { no: 5, name: '予約', shortname: '予約' },
  { no: 6, name: 'AFBF', shortname: 'AFBF' },
  { no: 7, name: 'OHDF', shortname: 'OHDF' },
  { no: 8, name: 'OHF', shortname: 'OHF' },
  { no: 9, name: '予約', shortname: '予約' },
  { no: 10, name: 'I-HDF', shortname: 'I-HDF' }
];


const defaultAppItemChartOption = {
  chart: {
    width: 230,
    height: 90,
    //backgroundColor: 'black',
    // backgroundColor: 'rgba(0,0,0,0)',
    //animation: false,
    plotBorderWidth: 1
  },
  boost: {
    allowForce: false,
    useGPUTranslations: true,
    usePreallocated: true
  },
  title: false,
  subtitle: false,
  alignTicks: false,
  legend: false,
  xAxis: {
    // visible: false,
    min: -1800,
    max: 16200,
    tickInterval: 3600,
    tickLength: 0,
    minorTickInterval: 30,
    gridLineWidth: 1,
    labels: {
      enabled: false
    },
    plotLines: []
  },
  yAxis: [
    // 1つ目のy軸設定
    {
      lineWidth: 1,
      title: false,
      plotLines: [],
      labels: {
        style: {
          color: 'inherit'
        },
        //align: 'left',
        x: -2
      }
    },
    // 2つ目のy軸設定
    {
      lineWidth: 1,
      title: false,
      plotLines: [],
      labels: {
        style: {
          color: 'inherit'
        },
        x: 1
      },
      opposite: true // trueの場合グラフの右側にy軸を配置する
    }
  ],
  plotOptions: {
    series: {
      //animation:false,
      label: { connectorAllowed: false },
      marker: { enabled: false, radius: 3 },
      states: {
        hover: {
          enabled: false
        }
      }
    }
  },
  tooltip: {
    animation: false,
    enabled: false
  },
  credits: {
    enabled: false
  },
  series: []
};


// initial state
const state = {
  // TODO: <<<< 正式リリース時には削除
  // NOTE: 学会スペシャルな警報・報知
  exAlert: {
    machineCd: '7898006',
    moniNo: 11,
    moniName: ''
  },
  exInfo: {
    machineCd: '7898012',
    moniNo: 17,
    moniName: ''
  },
  // >>>>ここまで
  staffcd: staffcd,
  facilityCd: '',
  // フレーム分割表示有無(0:なし、1：あり)
  frameShowMode: 0,
  // 表示中画面（0：リストグラフ、1：詳細グラフ）
  dispNo: 0,
  // データ取得状況（true：取得中、false：取得完了）
  loadstate: false,
  // ベッドグループ一覧情報
  bedgrouplist: [],
  // リストグラフ設定情報
  listgraph_settingslist: [],
  listgraph_settings_select_no: 0,
  // 詳細グラフ設定情報
  detailgraph_settingslist: [],
  detailgraph_settings_select_no: 0,
  // グラフ設定情報
  graphsettings: {
    // 一覧表示用設定
    list: {
      // 左に表示する最新値のモニタデータ項目
      moni_text: [{
        id: 'latest1',
        moni_no: 89,
        data: 0
      },
      {
        id: 'latest2',
        moni_no: 88,
        data: 0
      },
      {
        id: 'latest3',
        moni_no: 17,
        data: 0
      }
      ],
      // 右のグラフに表示するモニタデータ項目
      moni_graph: {
        id: '表示エリアの<div>タグのid名',
        graph_info: {
          y_l_max: 100,
          y_l_min: 0,
          y_r_max: 200,
          y_r_min: 0,
          moni_info: [{
            moni_no: 5,
            name: '',
            y_axis: 0,
            l_color: 'green',
            l_width: 1,
            is_symbol: true
          },
          {
            moni_no: 6,
            name: '',
            y_axis: 0,
            l_color: 'pink',
            l_width: 1,
            is_symbol: true
          },
          {
            moni_no: 7,
            name: '',
            y_axis: 0,
            l_color: 'red',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 8,
            name: '',
            y_axis: 1,
            l_color: 'blue',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 9,
            name: '',
            y_axis: 0,
            l_color: 'white',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 92,
            name: '',
            y_axis: 1,
            l_color: 'gray',
            l_width: 1,
            is_symbol: false
          }
          ]
        }
      },
      // 報知
      moni_area: {
        moni_no: 0,
        alert_max: 100,
        alert_min: 0
      }
    },
    // 詳細表示用設定
    detail: {
      moni_text: {
        id: 'latest',
        moni_no: 89,
        data: 0,
        name: '',
        unit: ''
      },
      moni_graph: [{
        id: '表示エリアの<div>タグのid名',
        graph_info: {
          y_l_max: 50,
          y_l_min: -50,
          y_r_max: 100,
          y_r_min: 0,
          moni_info: [{
            moni_no: 5,
            name: '',
            y_axis: 0,
            l_color: 'green',
            l_width: 1,
            is_symbol: true
          },
          {
            moni_no: 6,
            name: '',
            y_axis: 1,
            l_color: 'pink',
            l_width: 1,
            is_symbol: true
          },
          {
            moni_no: 7,
            name: '',
            y_axis: 1,
            l_color: 'red',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 8,
            name: '',
            y_axis: 1,
            l_color: 'blue',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 9,
            name: '',
            y_axis: 0,
            l_color: 'white',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 92,
            name: '',
            y_axis: 1,
            l_color: 'gray',
            l_width: 1,
            is_symbol: false
          }
          ]
        }
      },
      {
        id: '表示エリアの<div>タグのid名',
        graph_info: {
          y_l_max: 50,
          y_l_min: -50,
          y_r_max: 100,
          y_r_min: 0,
          moni_info: [{
            moni_no: 5,
            name: '',
            y_axis: 0,
            l_color: 'green',
            l_width: 1,
            is_symbol: true
          },
          {
            moni_no: 6,
            name: '',
            y_axis: 1,
            l_color: 'pink',
            l_width: 1,
            is_symbol: true
          },
          {
            moni_no: 7,
            name: '',
            y_axis: 1,
            l_color: 'red',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 8,
            name: '',
            y_axis: 1,
            l_color: 'blue',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 9,
            name: '',
            y_axis: 0,
            l_color: 'white',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 92,
            name: '',
            y_axis: 1,
            l_color: 'gray',
            l_width: 1,
            is_symbol: false
          }
          ]
        }
      },
      {
        id: '表示エリアの<div>タグのid名',
        graph_info: {
          y_l_max: 50,
          y_l_min: -50,
          y_r_max: 100,
          y_r_min: 0,
          moni_info: [{
            moni_no: 5,
            name: '',
            y_axis: 0,
            l_color: 'green',
            l_width: 1,
            is_symbol: true
          },
          {
            moni_no: 6,
            name: '',
            y_axis: 1,
            l_color: 'pink',
            l_width: 1,
            is_symbol: true
          },
          {
            moni_no: 7,
            name: '',
            y_axis: 1,
            l_color: 'red',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 8,
            name: '',
            y_axis: 1,
            l_color: 'blue',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 9,
            name: '',
            y_axis: 0,
            l_color: 'white',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 92,
            name: '',
            y_axis: 1,
            l_color: 'gray',
            l_width: 1,
            is_symbol: false
          }
          ]
        }
      },
      {
        id: '表示エリアの<div>タグのid名',
        graph_info: {
          y_l_max: 50,
          y_l_min: -50,
          y_r_max: 100,
          y_r_min: 0,
          moni_info: [{
            moni_no: 5,
            name: '',
            y_axis: 0,
            l_color: 'green',
            l_width: 1,
            is_symbol: true
          },
          {
            moni_no: 6,
            name: '',
            y_axis: 1,
            l_color: 'pink',
            l_width: 1,
            is_symbol: true
          },
          {
            moni_no: 7,
            name: '',
            y_axis: 1,
            l_color: 'red',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 8,
            name: '',
            y_axis: 1,
            l_color: 'blue',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 9,
            name: '',
            y_axis: 0,
            l_color: 'white',
            l_width: 1,
            is_symbol: false
          },
          {
            moni_no: 92,
            name: '',
            y_axis: 1,
            l_color: 'gray',
            l_width: 1,
            is_symbol: false
          }
          ]
        }
      }
      ]
    }
  },
  // 詳細グラフ用
  // 詳細グラフ表示状態[true:表示,false:非表示]
  detailgraph_view:[true,true,true,true],
  detailgraph_items: [],
  appitems: [],
  // 装置情報
  machinedata: [],
  // 詳細グラフ用の初期オプション
  defaultoption: {
    boost: {
      allowForce: false,
      useGPUTranslations: true,
      usePreallocated: true
    },
    chart: {
      //height: (5.5 / 16 * 100) + '%', // 16:9 ratio
      height: (5.5 / 16 * 100) + 5 + '%', // 16:9 ratio
      // backgroundColor: 'rgba(0,0,0,0)'
    },
    title: false,
    subtitle: false,
    alignTicks: false,
    legend: {
      align: 'right',
      layout: 'vertical',   //凡例垂直
      verticalAlign: 'top', //凡例配置
      floating: true,       //プロット領域を無視し凡例を表示
      symbolWidth: 5,       //シンボルマークについている線の長さ
      x: 0,
      y: 0,
      itemStyle: {
        // color: '#cccccc',
        fontSize: '0.7em',
        fontWeight: ''
      },
      itemHoverStyle: {},
      itemHiddenStyle: {}
    },
    xAxis: {
      min: -1800,//x軸最小値
      max: 16200,//y軸最大値
      gridLineWidth: 1,//目盛線の太さ
      gridLineColor: 'gray',//目盛線の色
      tickInterval: 3600,//目盛間隔
      labels: false,
      tickWidth: 0,
      plotLines: []
    },
    yAxis: [
      // 1つ目のy軸設定
      {
        //gridLineColor: 'black',
        gridLineWidth: 1,//目盛線の太さ
        gridLineColor: 'gray',//目盛線の色
        //lineWidth: 1,
        title: false,
        labels:{
          style:{
            color: 'inherit'
          }
        }
      },
      // 2つ目のy軸設定
      {
        //gridLineColor: 'black',
        gridLineWidth: false,
        //lineWidth: 1,
        title: false,
        labels:{
          style:{
            color: 'inherit'
          }
        },
        opposite: true // trueの場合グラフの右側にy軸を配置する
      }
    ],
    plotOptions: {
      series: {
        label: {
          connectorAllowed: false
        },
        marker: {
          enabled: false,
          radius: 3,
          symbol: 'circle'
        },
        states: {
          hover: {
            enabled: false
          }
        }
      }
    },
    tooltip: {
      animation: false,
      enabled: false
    },
    credits: {
      enabled: false
    },
    series: [],
    //レスポンシブ対応
    responsive: {
      rules: [{
        condition: {
          maxWidth: 500
        },
        chartOptions: {
          legend: {
            // align: 'center',
            // verticalAlign: 'bottom',
            // layout: 'horizontal',
            itemStyle: {
              fontSize: '0.6em',
              fontWeight: ''
            }
          }
        }
      }, {
        condition: {
          minWidth: 1000
        },
        chartOptions: {
          legend: {
            // align: 'center',
            // verticalAlign: 'bottom',
            // layout: 'horizontal',
            itemStyle: {
              fontSize: '1.0em',
              fontWeight: ''
            }
          }
        }
      }]
    }
  },
  // 選択詳細グラフインデックス
  detailGraphIndex: 0,
  // 詳細グラフ用の初期オプション
  detailgrpoptions: [
    [],
    [],
    [],
    []
  ],
  // 詳細グラフ用の装置データ
  detailmachinedata: {
    machineName: '',
    bedName: '',
    patName: '',
    latedata: 0,
    state: ''
  }
};

// getters
const getters = {
  listgraphsettings: (state) => state.graphsettings.list,
  machineStatePatId: (state) => state.machinedata[state.detailGraphIndex].patId
};

// actions
const actions = {
  async setFacilityCode({ commit }, facilityCode) {
    commit(types.SET_FACILITY_CODE, {
      facilityCd: facilityCode
    });

    return true;
  },

  /*
   * ベッドグループ一覧情報取得
   */
  async fetchBedGroupList({
    state,
    commit
  }, facilityCd) {
    try {
      // 施設コードを指定してベッドグループ一覧情報を取得
      let getstr = getbedgrouplist + facilityCd; //999000
      const response = await axios.get(getstr);
      const dataList = response.data.copyWithin(0, 0);

      let setdataList = [{ bedGroupName: 'すべて' }];
      dataList.forEach((value, index, array) => {
        array[index].bedList = JSON.parse(array[index].bedList);
        setdataList.push(array[index]);
      });

      // 初期値の選択中ベッドグループセット
      dataList.bedGroupIndex = -1;

      // ベッドグループ一覧情報をセットする
      commit(types.RECEIVE_BEDGROUPLIST, {
        bedgrouplist: setdataList
      });

      // 成功
      return true;
    } catch (e) {
      // 失敗
      return false;
    }
  },
  /*
   * グラフ設定一覧情報取得
   */
  async fetchGraphSettingList({
    state,
    commit
  }, facilityCd) {
    try {
      // 施設コードを指定してグラフ設定一覧情報を取得
      let getstr = getgraphsettinglist +
        + facilityCd; //999000
      const response = await axios.get(getstr);
      const dataList = response.data.copyWithin(0, 0);

      let listgraphsettings = [];
      let listgraphsettings_selectno = 0;
      let detailgraphsettings = [];
      let detailgraphsettings_selectno = 0;
      dataList.forEach((value, index, array) => {
        array[index].defineInfo = JSON.parse(array[index].defineInfo);

        // リストグラフの設定の場合
        if (array[index].frameType == 0) {
          if (listgraphsettings.length == 0) {
            // 初期値の管理番号セット
            listgraphsettings_selectno = array[index].ctlNo;
          }

          listgraphsettings.push(array[index]);
        }
        // 詳細グラフの設定の場合
        else {
          if (detailgraphsettings.length == 0) {
            // 初期値の管理番号セット
            detailgraphsettings_selectno = array[index].ctlNo;
          }

          detailgraphsettings.push(array[index]);
        }
      });

      // グラフの設定一覧情報をセットする
      commit(types.RECEIVE_GRAPHSETTINGLIST, {
        // リストグラフ設定情報
        listgraph_settingslist: listgraphsettings,
        listgraph_settings_select_no: listgraphsettings_selectno,
        // 詳細グラフ設定情報
        detailgraph_settingslist: detailgraphsettings,
        detailgraph_settings_select_no: detailgraphsettings_selectno
      });

      let gsettings = state.graphsettings;

      // 初期設定をセット
      gsettings.list = listgraphsettings[0].defineInfo;
      gsettings.detail = detailgraphsettings[0].defineInfo

      // グラフの設定情報をセットする
      commit(types.RECEIVE_GRAPHSETTING, {
        graphsettings: gsettings
      });

      // 成功
      return true;
    } catch (e) {
      // 失敗
      return false;
    }
  },
  /*
   * グラフ設定情報取得
   */
  async fetchGraphSetting({
    state,
    commit
  }, payload) {
    let isListMode = payload.listmode;
    let facilityCd = payload.facilityCd;
    try {
      // グラフ設定
      let gsettings = state.graphsettings;

      // 施設コードと管理番号を指定してグラフの設定情報を取得
      let getstr = getgraphsetting +
        + facilityCd //999000
        + '/'

      // リストグラフ表示時
      if (isListMode || state.dispNo == 0) {
        getstr += state.listgraph_settings_select_no //0
      }
      // 詳細グラフ表示時
      else if (state.dispNo == 1) {
        getstr += state.detailgraph_settings_select_no //1
      }
      const response = await axios.get(getstr);

      // JSON形式に変換する
      const dataList = JSON.parse(response.data[0].defineInfo);

      // リストグラフ表示時
      if (isListMode || state.dispNo == 0) {
        gsettings.list = dataList;
      }
      // 詳細グラフ表示時
      else if (state.dispNo == 1) {
        gsettings.detail = dataList;
      }

      // グラフの設定情報をセットする
      commit(types.RECEIVE_GRAPHSETTING, {
        graphsettings: gsettings
      });

      // 成功
      return true;
    } catch (e) {
      // 失敗
      return false;
    }
  },
  /*
   * モニタデータ項目一覧取得
   */
  async fetchDataMonitor({
    state,
    commit
  }, facilityCd) {
    try {
      // 施設コードを指定してモニタデータ項目一覧情報を取得
      let getstr = getmonitoritems + facilityCd; //999000
      const response = await axios.get(getstr);
      const dataList = response.data.copyWithin(0, 0);

      // グラフ設定情報
      let graphdata = state.graphsettings;
      // 最新値のモニタ項目登録用
      let moni_text = state.graphsettings.list.moni_text;
      // リストグラフのモニタ項目登録用
      let listmoni_info = state.graphsettings.list.moni_graph.graph_info.moni_info;
      // 詳細グラフのモニタ項目登録用
      let detailmoni_info = state.graphsettings.detail.moni_graph;

      dataList.forEach((value, index, array) => {

        // 最新値のモニタ項目 state.graphsettings.list.moni_text[0].moni_no
        for (let i = 0; i < moni_text.length; i++) {
          if (moni_text[i].moni_no == null) {
            moni_text[i].name = ''; // mon_data_name
            moni_text[i].unit = '';
          }
          else if (array[index].moniNo == moni_text[i].moni_no) {
            moni_text[i].name = array[index].monDataShortName; // mon_data_name
            if (isNaN(array[index].unit)) {
              moni_text[i].unit = '[' + array[index].unit + ']';
            }
          }
        }

        // 警報報知のモニタ項目
        if(graphdata.list.moni_area.moni_no == null)
        {
          graphdata.list.moni_area.name = ''
        }
        else if (array[index].moniNo == graphdata.list.moni_area.moni_no) {
          graphdata.list.moni_area.name = array[index].monDataName; // mon_data_name
        }

        // TODO: <<<<< 警報報知スペシャルのモニタ項目
        if(array[index].moniNo == state.exAlert.moniNo){
          state.exAlert.moniName = array[index].monDataName;
        }else if(array[index].moniNo == state.exInfo.moniNo){
          state.exInfo.moniName = array[index].monDataName;
        }
        // >>>>>

        // リストグラフのモニタ項目 state.graphsettings.list.moni_graph.graph_info.moni_info[0].moni_no
        for (let i = 0; i < listmoni_info.length; i++) {
          if (listmoni_info[i].moni_no == null) {
            listmoni_info[i].name = ''; // mon_data_name
          }
          else if (array[index].moniNo == listmoni_info[i].moni_no) {
            listmoni_info[i].name = array[index].monDataShortName; // mon_data_short_name
          }
        }

        // 詳細グラフの最新値のモニタ項目
        if (graphdata.detail.moni_text.moni_no == null) {
          graphdata.detail.moni_text.name = ''; // mon_data_name
          graphdata.detail.moni_text.unit = '';
        }
        else if (array[index].moniNo == graphdata.detail.moni_text.moni_no) {
          graphdata.detail.moni_text.name = array[index].monDataShortName;
          graphdata.detail.moni_text.unit = array[index].unit;
        }
        // 詳細グラフのモニタ項目
        for (let i = 0; i < detailmoni_info.length; i++) {
          for (let j = 0; j < detailmoni_info[i].graph_info.moni_info.length; j++) {
            if (detailmoni_info[i].graph_info.moni_info[j].moni_no == null) {
              detailmoni_info[i].graph_info.moni_info[j].name = '';
            }
            else if (array[index].moniNo == detailmoni_info[i].graph_info.moni_info[j].moni_no) {
              detailmoni_info[i].graph_info.moni_info[j].name = array[index].monDataShortName; // mon_data_short_name
            }
          }
        }
      });

      commit(types.RECEIVE_MSTMONITOR, {
        graphsettings: graphdata
      });

      // 成功
      return true;
    } catch (e) {
      // 失敗
      return false;
    }
  },

  /**
   * 装置一覧取得
   * @param {*} param0
   * @param {取得モード} mode [0:全データ取得,1:最新値取得,2:グラフ設定変更時]
   */
  async fetchDataMachine({
    commit
  }, payload) {
    let mode = payload.mode;
    let facilityCd = payload.facilityCd;
    try {
      let getstr = getmachineitems + facilityCd; //facilitycd  //999999
      const response = await axios.get(getstr);
      const dataList = response.data.copyWithin(0, 0);
      dataList.forEach((value, index, array) => {

        // 患者が有効かどうか
        array[index].view_patInfo= true;
        if (value.patId == null ) {
          array[index].view_patInfo= false;
        }

        // 登録日時
        if (value.regDate) {
          array[index].regDate = formatDate(value.regDate);
        }

        // 表示用患者情報作成
        // 性別
        array[index].view_patSex = '';
        if( array[index].patId != null ) {
          switch (array[index].patSex) {
            case 0:
              array[index].view_patSex = '不明';
              break;
            case 1:
              array[index].view_patSex = '男性';
              break;
            case 2:
              array[index].view_patSex = '女性';
              break;
          }
        }

        // 血液型
        array[index].view_patBloodType = '';
        if( array[index].patId != null ) {
          switch (array[index].patBloodTypeAbo) {
            case 0:
              array[index].view_patBloodType = '不明';
              break;
            case 1:
              array[index].view_patBloodType = 'A型';
              break;
            case 2:
              array[index].view_patBloodType = 'B型';
              break;
            case 3:
              array[index].view_patBloodType = 'O型';
              break;
            case 4:
              array[index].view_patBloodType = 'AB型';
              break;
          }

          switch (array[index].patBloodTypeRh) {
            case 0:
              array[index].view_patBloodType += '(不明)';
              break;
            case 1:
              array[index].view_patBloodType += '(Rh＋)';
              break;
            case 2:
              array[index].view_patBloodType += '(Rh－)';
              break;
          }
        }

        // 生年月日
        array[index].view_patBirthday = '';
        if (array[index].patBirthday != null && array[index].patBirthday.length == 8) {
          array[index].view_patBirthday = array[index].patBirthday.substring(0, 4) + '/' + array[index].patBirthday.substring(4, 6) + '/' + array[index].patBirthday.substring(6, 8);
          // Dateインスタンスに変換
          let birthDate = new Date(array[index].view_patBirthday);

          // 文字列に分解
          let y2 = birthDate.getFullYear().toString().padStart(4, '0');
          let m2 = (birthDate.getMonth() + 1).toString().padStart(2, '0');
          let d2 = birthDate.getDate().toString().padStart(2, '0');

          // 今日の日付
          let today = new Date();
          let y1 = today.getFullYear().toString().padStart(4, '0');
          let m1 = (today.getMonth() + 1).toString().padStart(2, '0');
          let d1 = today.getDate().toString().padStart(2, '0');

          // 引き算
          let age = Math.floor((Number(y1 + m1 + d1) - Number(y2 + m2 + d2)) / 10000);
          array[index].view_patBirthday += '(' + age + '歳)'
        }

        // 入外アイコン
        // 外来の場合
        array[index].view_inClass = false;
        array[index].view_outClass = false;

        // 外来の場合
        if (array[index].patId != null && array[index].inOutClass == 0) {
          array[index].view_outClass = true;
        }
        // 入院の場合
        if (array[index].inOutClass == 1) {
          array[index].view_inClass = true;
        }

        // 同姓同名アイコン
        array[index].view_isSame = false;
        if (array[index].isSame == 1) {
          array[index].view_isSame = true;
        }

        // 禁忌アレルギーアイコン
        array[index].view_tabooInfo = false;
        if (array[index].tabooInfo != null ) {

          array[index].view_tabooInfo = true;
        }

        // 感染症アイコン
        array[index].view_isInfect = false;
        if (array[index].isInfect == 1) {
          array[index].view_isInfect = true;
        }

        // インプラントアイコン
        array[index].view_isImplant = false;
        if (array[index].isImplant == 1) {
          array[index].view_isImplant = true;
        }

        // リストグラフ用
        array[index].data = [];
        array[index].moninolist = [];
        array[index].latedata = [];

        // 詳細グラフ用
        array[index].detaildata = [];
        array[index].detaillatedata = [];
        array[index].detailstepdata = [];
        array[index].detailmoninolist = [];

        array[index].ctlno = 0;
        //array[index].old_ordNo = array[index].ordNo;
        array[index].old_startDate = array[index].startDate;

        // 最新情報取得の場合
        if (mode == 1) {
          array[index].ctlno = state.machinedata[index].ctlno;
          array[index].latedata = state.machinedata[index].latedata;
          array[index].detaillatedata = state.machinedata[index].detaillatedata;
          array[index].detailstepdata = state.machinedata[index].detailstepdata;
          // 警報・報知情報[0:通常,1:警報,2:報知]
          array[index].alertstate = state.machinedata[index].alertstate;
          array[index].alertInfo = state.machinedata[index].alertInfo;
          array[index].alertStyle = state.machinedata[index].alertStyle;
          array[index].alertTextStyle = state.machinedata[index].alertTextStyle;
          // 最新情報取得中に患者が変更された場合
          //if(state.machinedata[index].ordNo != array[index].ordNo)
          if (state.machinedata[index].startDate != array[index].startDate) {
            array[index].ctlno = 0;
            //array[index].old_ordNo = state.machinedata[index].ordNo;
            array[index].old_startDate = state.machinedata[index].startDate;

            // 警報・報知情報[0:通常,1:警報,2:報知]クリア
            array[index].alertstate = 0;
            array[index].alertInfo = '';
            // 背景色を変更
            array[index].alertStyle = {};
            array[index].alertTextStyle = {};
          }
        }
        else
        {
          // 警報・報知情報[0:通常,1:警報,2:報知]
          array[index].alertstate = 0;
          array[index].alertInfo = '';// 背景色を変更
          array[index].alertStyle = {};
          array[index].alertTextStyle = {};
        }

        // 抽出条件用表示・非表示
        array[index].visible = true;
        // 最新情報取得の場合
        if (mode > 0) {
          array[index].visible = state.machinedata[index].visible;
        }


        // 装置の運転状況情報[0:治療外,1:条件送信～運転開始前,2:運転開始～排液前,3:排液～後体重測定]
        // 0:治療外
        array[index].machinestate = 0;
        // if(array[index].ordNo != null)
        // {
        //   // 1:条件送信～運転開始前
        //   if(array[index].condSendDate != null)
        //   {
        //     array[index].machinestate = 1;
        //   }

        //   // 2:運転開始～排液前
        //   if(array[index].startDate != null)
        //   {
        //     array[index].machinestate = 2;

        //     // 3:排液～後体重測定
        //     if(array[index].processState != 10 && array[index].processState != 11)
        //     {
        //       array[index].machinestate = 3;
        //     }
        //   }
        // }
        if (array[index].condSendDate != null) {
          // 1:条件送信～運転開始前
          array[index].machinestate = 1;
        }
        else if (array[index].startDate != null) {
          // 2:運転開始～排液前
          array[index].machinestate = 2;
        }

        // 基準日時（透析開始日時）
        // 0:治療外
        array[index].basedate = '';
        // 1:条件送信～運転開始前
        if (array[index].machinestate == 1) {
          array[index].basedate = formatDate(array[index].condSendDate);
        }
        // 2:運転開始～排液前
        // 3:排液～後体重測定
        else if (array[index].machinestate > 1) {
          array[index].basedate = formatDate(array[index].startDate);
        }

      });

      // 初期情報取得の場合
      if (mode == 0) {
        commit(types.SET_DEFAULT_APPITEM, {
          size: dataList.length
        });

      }

      commit(types.RECEIVE_MSTMACHINE, {
        machinedata: dataList
      });

      // 成功
      return true;
    } catch (e) {
      // 失敗
      return false;
    }
  },

  /*
   * モニタデータ取得
   */
  async fetchDataResult({
    state,
    commit
  }, item) {
    try {

      // let indexno = gitem.indexNumber
      let dispdata = state.machinedata;
      let indexno = item.index;

      // 運転中でない場合はモニタデータを取得しない
      if (dispdata[indexno].machinestate == 0) {
        return true;
      }

      let settingdata = state.graphsettings.list;
      let rest = getmonitordata;
      let getstr =
        'facilityCd=' + dispdata[indexno].facilityCd + '&' //999900
        +
        'machineTypeCd=' + dispdata[indexno].machineTypeCd + '&' //003
        +
        'machineSerial=' + dispdata[indexno].machineSerial + '&' //TDC0001
        +
        //'ordNo=' + dispdata[indexno].ordNo;
        'occurDate=' + dispdata[indexno].basedate.replace(/\//g, '-').replace(' ', '%20');

      // 差分データのみ取得してくる場合
      if (item.mode == 1) {
        // TODO: <<<< タイマー更新機能不要時には削除
        // NOTE: 差分1点のみ返すスペシャルなAPI
        rest = getmonitordataDiff;
        // >>>> ここまで

        getstr += '&' + 'bioMoniCtlNo=' + dispdata[indexno].ctlno;
      }

      // リストグラフで必要な項目のみ取得
      // グラフに表示するデータ(MAX6)
      for (let i = 0; i < settingdata.moni_graph.graph_info.moni_info.length; i++) {
        if (settingdata.moni_graph.graph_info.moni_info[i].moni_no != null && settingdata.moni_graph.graph_info.moni_info[i].moni_no != undefined) {
          getstr = getstr + '&monitorKeys=' + settingdata.moni_graph.graph_info.moni_info[i].moni_no;
        }
      }
      // 最新値を表示するデータ(MAX3)
      for (let i = 0; i < settingdata.moni_text.length; i++) {
        if (settingdata.moni_text[i].moni_no != null && settingdata.moni_text[i].moni_no != undefined) {
          getstr = getstr + '&monitorKeys=' + settingdata.moni_text[i].moni_no;
        }
      }
      // 閾値判定用のデータ
      if (settingdata.moni_area.moni_no != null && settingdata.moni_area.moni_no != undefined) {
        getstr = getstr + '&monitorKeys=' + settingdata.moni_area.moni_no;
      }

      const response = await axios.get(rest + getstr);
      const dataList = response.data.copyWithin(0, 0);

      // データがある場合
      if (dataList.length > 0) {
        // 最新値（リストグラフ・詳細グラフ表示用）・閾値用のモニタデータ項目番号リスト
        let latedatalist = [];
        for (let i = 0; i < state.graphsettings.list.moni_text.length; i++) {
          if (state.graphsettings.list.moni_text[i].moni_no != null) {
            latedatalist[i] = state.graphsettings.list.moni_text[i].moni_no;
          }
        }

        // 閾値用のモニタデータ項目番号
        if (state.graphsettings.list.moni_area.moni_no != null) {
          latedatalist.push(state.graphsettings.list.moni_area.moni_no);
        }


        // リストグラフ用のモニターデータ項目番号リスト
        // リストグラフ表示項目
        let graphdatalist = [];
        for (let i = 0; i < state.graphsettings.list.moni_graph.graph_info.moni_info.length; i++) {
          if (state.graphsettings.list.moni_graph.graph_info.moni_info[i].moni_no != null) {
            graphdatalist[i] = state.graphsettings.list.moni_graph.graph_info.moni_info[i].moni_no;
          }
        }

        // 重複削除
        graphdatalist = graphdatalist.filter(function (x, i, self) {
          return self.indexOf(x) === i;
        });

        // リスト・詳細グラフ表示用
        let setdata = new Array(6);
        for (let i = 0; i < setdata.length; i++) {
          setdata[i] = [];
        }
        // 閾値チェック用
        let graphareasetting = state.graphsettings.list.moni_area;
        let setlatedata = [];
        // bioMoniCtlNo用
        let ctlno = dispdata[indexno].ctlno;

        let oldminute = -1;

        dataList.forEach((value, index, array) => {

          // 発生日時
          if (value.occurDate) {
            array[index].occurDate = formatDate(value.occurDate);
          }

          // 基準日が設定されていない場合
          // if (state.machinedata[indexno].basedate == '')
          // {
          //   // 基準日時に設定する
          //   state.machinedata[indexno].basedate = array[index].occurDate;
          // }


          // 経過時間計算
          let basedate = (new Date(state.machinedata[indexno].basedate)).getTime();
          // 運転開始日時がある場合はそちらを使う
          if( state.machinedata[indexno].startDate != null ) {
            basedate = (new Date(formatDate(state.machinedata[indexno].startDate))).getTime();
          }
          let occurdate = (new Date(array[index].occurDate)).getTime();
          let xdate = Math.floor((occurdate - basedate) / (1000));

          // // 経過時間を60秒単位に換算し前回と同じ場合は前回データを上書き
          // let pushflag = 0;
          // let x = Math.floor( xdate / 60 );
          // if( x != oldminute ) {
          //   pushflag = 1;
          //   oldminute = x;
          // }

          // モニタデータをJSON形式に変換
          let moniData = JSON.parse(array[index].monitorData);

          // ΔBVが項目にある場合
          if (isNaN(moniData[17]) == false && isNaN(moniData[100]) == false) {
            if (moniData[100] != null) {
              moniData[17] = moniData[100];
            }
            else {
              moniData[100] = moniData[17];
            }
          }

          // リストグラフのデータ取得
          for (let i = 0; i < graphdatalist.length; i++) {
            // データがある場合のみ
            if (moniData[graphdatalist[i]] != '' && moniData[graphdatalist[i]] != undefined && moniData[graphdatalist[i]] != null) {
              setdata[i].push([xdate, parseFloat(moniData[graphdatalist[i]])]);

              // //
              // if( pushflag == 1 ) {
              //   // 追加
              //   setdata[i].push([xdate, parseFloat(moniData[graphdatalist[i]])]);
              // } else {
              //   // 更新
              //   setdata[i].pop();
              //   setdata[i].push([xdate, parseFloat(moniData[graphdatalist[i]])]);
              // }
            }
          }

          // リストの最新データ・閾値チェック用のデータ取得
          for (let i = 0; i < latedatalist.length; i++) {
            // データがある場合のみ
            if (moniData[latedatalist[i]] != '' && moniData[latedatalist[i]] != undefined && moniData[latedatalist[i]] != null) {
              setlatedata[i] = parseFloat(moniData[latedatalist[i]]);

              // 工程の場合
              if(latedatalist[i] == 0)
              {
                processstate.forEach((val, idx, ary) =>
                {
                  if(ary[idx].no == setlatedata[i])
                  {
                    setlatedata[i] = ary[idx].shortname;
                  }
                });
              }

              // 治療モードの場合
              if(latedatalist[i] == 31)
              {
                treatmode.forEach((val, idx, ary) =>
                {
                  if(ary[idx].no == setlatedata[i])
                  {
                    setlatedata[i] = ary[idx].shortname;
                  }
                });
              }
            }
          }
          // bioMoniCtlNo用
          ctlno = array[index].bioMoniCtlNo;
        });

        // 最新値・閾値データ更新
        for (let i = 0; i < setlatedata.length; i++) {
          // データがある場合のみ
          if (setlatedata[i] != null) {
            dispdata[indexno].latedata.splice(i, 1, setlatedata[i]);
          }
        }

        // bioMoniCtlNo用
        dispdata[indexno].ctlno = ctlno;

        // 閾値チェック
        var checkdata = parseFloat(setlatedata[setlatedata.length - 1]);

        // 警報・報知のモニタ項目が設定されている場合
        if (isNaN(checkdata) == false && graphareasetting.moni_no != null) {
          // 警報チェック
          if (checkdata < graphareasetting.alert_min || checkdata > graphareasetting.alert_max) {
            // 警報・報知情報[0:通常,1:警報,2:報知]
            dispdata[indexno].alertstate = 1;
            dispdata[indexno].alertInfo = settingdata.moni_area.name +' で警報発生中';
            // 背景色を変更
            dispdata[indexno].alertStyle = { 'ntss-monitoring-basepane-alert': true };
            dispdata[indexno].alertTextStyle = { 'ntss-monitoring-basepane-alert-text': true };
          }
          // 報知チェック
          else if (checkdata < graphareasetting.info_min || checkdata > graphareasetting.info_max) {
            // 警報・報知情報[0:通常,1:警報,2:報知]
            dispdata[indexno].alertstate = 2;
            dispdata[indexno].alertInfo = settingdata.moni_area.name + ' で報知発生中';
            // 背景色を変更
            dispdata[indexno].alertStyle = { 'ntss-monitoring-basepane-info': true };
            dispdata[indexno].alertTextStyle = { 'ntss-monitoring-basepane-info-text': true };
          }
          // 通常の場合
          else {
            // 警報・報知情報[0:通常,1:警報,2:報知]
            dispdata[indexno].alertstate = 0;
            dispdata[indexno].alertInfo = '';
            // 背景色を変更
            dispdata[indexno].alertStyle = {};
            dispdata[indexno].alertTextStyle = {};
          }
        }

        // <<<<< 学会スペシャル装置指定警報報知
        if(state.exAlert.machineCd == dispdata[indexno].machineSerial){
          // 警報・報知情報[0:通常,1:警報,2:報知]
          dispdata[indexno].alertstate = 1;
          dispdata[indexno].alertInfo = state.exAlert.moniName +' で警報発生中';
          // 背景色を変更
          dispdata[indexno].alertStyle = { 'ntss-monitoring-basepane-alert': true };
          dispdata[indexno].alertTextStyle = { 'ntss-monitoring-basepane-alert-text': true };
        }else if(state.exInfo.machineCd == dispdata[indexno].machineSerial){
          // 警報・報知情報[0:通常,1:警報,2:報知]
          dispdata[indexno].alertstate = 2;
          dispdata[indexno].alertInfo = state.exInfo.moniName + ' で報知発生中';
          // 背景色を変更
          dispdata[indexno].alertStyle = { 'ntss-monitoring-basepane-info': true };
          dispdata[indexno].alertTextStyle = { 'ntss-monitoring-basepane-info-text': true };
        }
        // >>>>>

        // リスト・詳細グラフデータ更新
        for (let i = 0; i < setdata.length; i++) {
          dispdata[indexno].data.push(setdata[i]);
          dispdata[indexno].moninolist.push(graphdatalist[i]);
        }

        commit(types.RECEIVE_DATRST, {
          machinedata: dispdata
        });
      }

      // 成功
      return true;
    } catch (e) {
      // 失敗
      return false;
    }
  },
  /**
   * HighChartの描画
   * @param {Number} index 要素番号
   */
  async reDrawChart({ state }, index) {
    // グラフＸ軸（時間軸）の最大値取得
    let max = getPlotxAxisMax(0, state.machinedata[index], state.graphsettings.list.moni_graph.graph_info.moni_info);
    if (max && max != state.appitems[index].xAxis.max) {
      // グラフＸ軸（時間軸）の最大値設定
      state.appitems[index].xAxis.max = max;
    }

    // 透析開始線・終了線セット
    setStartEndLine(state.appitems[index], index);

    // グラフデータクリア
    state.appitems[index].series.splice(0, state.appitems[index].series.length);

    // リストグラフデータ更新
    for (let i = 0; i < state.graphsettings.list.moni_graph.graph_info.moni_info.length; i++) {
      // モニタ項目番号が設定されている場合
      if (state.graphsettings.list.moni_graph.graph_info.moni_info[i].moni_no != null) {
        // y軸の参照位置(0:左or1:右)
        let yaxis = state.graphsettings.list.moni_graph.graph_info.moni_info[i].y_axis
        // y軸が片方しかない場合
        if (state.appitems[index].yAxis.length == 1) {
          yaxis = 0;
        }

        // グラフセット
        state.appitems[index].series.push({
          // boostThreshold: 1, // プロット数が1より大きい場合にブースト,
          turboThreshold: 1,
          animation: {
            duration: 10
          },
          name: state.graphsettings.list.moni_graph.graph_info.moni_info[i].name,
          color: state.graphsettings.list.moni_graph.graph_info.moni_info[i].l_color,
          yAxis: yaxis,
          lineWidth: state.graphsettings.list.moni_graph.graph_info.moni_info[i].l_width,
          marker: {
            enabled: state.graphsettings.list.moni_graph.graph_info.moni_info[i].is_symbol
          },
          'events': {
            'afterAnimate': function () {
              // 最新プロット点滅セット
              setPlotMarkerBlink(0, this.chart.series[i]);
            }
          },
          data: getdata(state.machinedata[index], state.graphsettings.list.moni_graph.graph_info.moni_info[i].moni_no)
        });
      }
    }

    // storeのデータクリア
    state.machinedata[index].data = [];
  },

  /**
   * 最新データ取得後のHighChartの描画
   * @param {Object} item.gitem Highcharts
   * @param {Number} item.index 要素番号
   */
  async reDrawChartNow({ dispatch, state }, item) {
    let gitem = item.gitem;
    let index = item.index;

    // 患者が変更になった場合
    //if(state.machinedata[index].old_ordNo != state.machinedata[index].ordNo)
    if (state.machinedata[index].old_startDate != state.machinedata[index].startDate) {
      await dispatch('reDrawChart', index);
    }
    else {
      // グラフＸ軸（時間軸）の最大値取得
      let max = getPlotxAxisMax(0, state.machinedata[index], state.graphsettings.list.moni_graph.graph_info.moni_info);
      if (max && max != gitem.$refs.lineCharts.options.xAxis.max) {
        // グラフＸ軸（時間軸）の最大値設定
        gitem.$refs.lineCharts.options.xAxis.max = max;
      }

      // 透析開始線・終了線セット
      setStartEndLine(gitem.$refs.lineCharts.options, index);

      // リストグラフデータ更新
      for (let i = 0; i < state.graphsettings.list.moni_graph.graph_info.moni_info.length; i++) {
        // グラフ
        if (state.appitems[index].series[i] != null && state.graphsettings.list.moni_graph.graph_info.moni_info[i].moni_no != null) {
          // グラフ表示用データ取得
          let data = getdata(state.machinedata[index], state.graphsettings.list.moni_graph.graph_info.moni_info[i].moni_no);

          // グラフ表示用データがある場合
          if (data.length > 0) {
            let chart = gitem.$refs.lineCharts.chart;

            // 最新プロット点滅リセット
            setPlotMarkerReset(chart.series[i]);

            // 既にグラフにデータがある場合
            if (chart.series[i].points.length > 0) {
              // ポイント追加
              for (var j = 0; j < data.length; j++) {
                chart.series[i].addPoint(data[j], true, false);
                // // 経過時間を60秒単位に換算し前回と同じ場合は前回データを上書き
                // let xdate = data[j][0];
                // let x = Math.floor( xdate / 60 );
                // let oldminute = Math.floor( chart.series[i].points[chart.series[i].points.length - 1].x / 60 );
                // if( x != oldminute ) {
                //   // 追加
                // } else {
                //   // 更新
                //   chart.series[i].removePoint(chart.series[i].points.length - 1, false );
                //   //console.log('removePoint :' + xdate + ' / ' + x + ' - ' + oldminute );
                // }
                // chart.series[i].addPoint(data[j], true, false);
                // //console.log('addPoint :' + xdate  + ' / ' + x + ' - ' + oldminute );
              }
            }
            else {
              // ポイント追加
              for (var j = 0; j < data.length; j++) {
                state.appitems[index].series[i].data.push(data[j]);
              }
            }

            // 最新プロット点滅セット
            setPlotMarkerBlink(0, chart.series[i]);
            chart = null;
          }
          data = null;
        }
      }
    }
    // storeのデータクリア
    state.machinedata[index].data = [];
  },

  /**
   * フレーム分割表示有無設定
   * @param {number} mode (0：なし、1：あり)
   */
  setFrameShowMode({
    state,
    commit
  }, mode) {
    commit(types.SET_FRAME_SHOW_MODE, {
      frameShowMode: mode
    });
  },
  /**
   * 表示中画面の番号セット
   * @param {Number} no （0：リストグラフ、1：詳細グラフ）
   */
  setDispNo({
    state,
    commit
  }, no) {
    commit(types.SET_DISPNO, {
      dispNo: no
    });
  },

  /**
   * データの読込状況
   * @param {boolean} setstate （true：読込中、false：読込完了）
   */
  setState({
    commit
  }, setstate) {
    commit(types.SET_STATE, {
      loadstate: setstate
    });
  },

  /**
   * 表示する詳細グラフのインデックス番号
   * @param {Number} index 選択したグラフのインデックス
   */
  setDefaultGraphIndex({
    state,
    commit
  }, index) {
    commit(types.SET_DETAILINDEX, {
      detailGraphIndex: index
    });
  },
  /*
   * 詳細グラフのオプションに初期値をセットする
   */
  setDefaultOption({
    state,
    commit
  }, payload) {

    // 詳細グラフのオプション設定
    state.defaultoption.legend.itemStyle.color = payload.legendColor;
    state.defaultoption.legend.itemHoverStyle.color = payload.hoverColor;
    state.defaultoption.legend.itemHiddenStyle.color = payload.hiddenColor;

    let grpoptions = [state.defaultoption, state.defaultoption, state.defaultoption, state.defaultoption];
    let graphview = [true, true, true, true];

    commit(types.SET_DETAILGRAPH, {
      detailgraph_view : graphview,
      detailgrpoptions: grpoptions
    });
  },
  /*
   * モニタデータを詳細グラフにセットする
   */
  async setDetailGraph({
    dispatch,
    state,
    commit
  }, item) {

    let gitem;
    if (item.gitem != null) {
      gitem = [item.gitem.highcharts1, item.gitem.highcharts2, item.gitem.highcharts3, item.gitem.highcharts4];
    }
    let mode = item.mode;
    let indexno = state.detailGraphIndex;
    let viewmachinedata = state.detailmachinedata;

    try {
      // let indexno = gitem.indexNumber
      let dispdata = state.machinedata;
      let settingdata = state.graphsettings.list;
      let rest = getmonitordata;
      let getstr =
        'facilityCd=' + dispdata[indexno].facilityCd + '&' //999900
        +
        'machineTypeCd=' + dispdata[indexno].machineTypeCd + '&' //003
        +
        'machineSerial=' + dispdata[indexno].machineSerial + '&' //TDC0001
        +
        //'ordNo=' + dispdata[indexno].ordNo;
        'occurDate=' + dispdata[indexno].basedate.replace(/\//g, '-').replace(' ', '%20');

      // 差分データのみ取得してくる場合
      if (mode == 1) {
        // TODO: タイマー更新機能不要時には削除？残しても動くかも <<<<
        // NOTE: 差分1点のみ返すスペシャルなAPI
        rest = getmonitordataDiff;
        // >>>> ここまで

        gitem = state.detailgraph;
        getstr += '&' + 'bioMoniCtlNo=' + dispdata[indexno].ctlno;
      } else if(mode == 0) {
        // 初期読込
        // TODO: タイマー更新機能不要時には削除？残しても動くかも <<<<
        // NOTE: 学会対応、静的データのうち一覧グラフで読み込み済みの範囲を取得する
        getstr += '&' + 'lastBioMoniCtlNo=' + dispdata[indexno].ctlno;
        // >>>> ここまで
      }

      // 最新値（詳細グラフ表示用）項目番号
      // 詳細グラフ表示用最新値のモニタデータ項目番号
      let latedatano;
      if (state.graphsettings.detail.moni_text.moni_no != null
        && state.graphsettings.detail.moni_text.moni_no != undefined) {
        latedatano = state.graphsettings.detail.moni_text.moni_no;
      }


      // 詳細グラフ用のモニターデータ項目番号リスト
      let graphdatalist = [];
      // 詳細グラフ表示項目
      for (let i = 0; i < state.graphsettings.detail.moni_graph.length; i++) {
        for (let j = 0; j < state.graphsettings.detail.moni_graph[i].graph_info.moni_info.length; j++) {
          if (state.graphsettings.detail.moni_graph[i].graph_info.moni_info[j].moni_no != null
            && state.graphsettings.detail.moni_graph[i].graph_info.moni_info[j].moni_no != undefined) {
            graphdatalist.push(state.graphsettings.detail.moni_graph[i].graph_info.moni_info[j].moni_no);
          }
        }
      }

      // 詳細グラフ表示用最新値のモニタデータ項目番号
      if (latedatano != null && latedatano != undefined) {
        graphdatalist.push(latedatano);
      }


      // 重複削除
      graphdatalist = graphdatalist.filter(function (x, i, self) {
        return self.indexOf(x) === i;
      });


      // 詳細グラフで必要な項目のみ取得
      for (let i = 0; i < graphdatalist.length; i++) {
        getstr = getstr + '&monitorKeys=' + graphdatalist[i];
      }

      let dataList = [];
      try {

        const response = await axios.get(rest + getstr);
        dataList = response.data.copyWithin(0, 0);

      } catch (e) {

      }

      // 詳細グラフ表示用
      let setdata = new Array(25);
      for (let i = 0; i < setdata.length; i++) {
        setdata[i] = [];
      }

      // // 装置名称
      // viewmachinedata.machineName = state.machinedata[indexno].machineName;
      // // ベッド名称
      // viewmachinedata.bedName = state.machinedata[indexno].bedName;
      // // 警報・報知情報
      // viewmachinedata.alertInfo = state.machinedata[indexno].alertInfo;
      // // 患者名
      // viewmachinedata.patName = state.machinedata[indexno].patName;
      // // 装置状態
      // if(state.machinedata[indexno].processState != null)
      // {
      //   // 装置状態取得
      //   let nowstate = getState(state.machinedata[indexno].processState);
      //   // 装置状態セット
      //   viewmachinedata.state = nowstate.name;

      //   // 装置状態の文字色
      //   let classlist = document.getElementById('state').classList;
      //   // 既に色が設定されている場合
      //   if(classlist[classlist.length -1].indexOf('ntss-monitoring-state') > -1)
      //   {
      //     // 色のスタイル削除
      //     classlist.remove(classlist[classlist.length -1]);
      //   }
      //   // 装置状態の文字色セット
      //   document.getElementById('state')?.classList?.add( 'ntss-monitoring-state'+ nowstate.no );
      // }
      // // 最新データ日付
      // const moment = require('moment');
      // moment.locale('ja');
      // const dateformat = 'YYYY年MM月DD日dddd';
      // const momentDate = moment(new Date());
      // let setdate = momentDate.format(dateformat);
      // viewmachinedata.latedate = setdate;

      // 最新値表示用
      let setlatedata = null;

      // データがある場合
      if (dataList.length > 0) {
        dataList.forEach((value, index, array) => {
          // 発生日時
          if (value.occurDate) {
            array[index].occurDate = formatDate(value.occurDate);
          }

          // 経過時間計算
          let basedate = (new Date(state.machinedata[indexno].basedate)).getTime();
          // 運転開始日時がある場合はそちらを使う
          if( state.machinedata[indexno].startDate != null ) {
            basedate = (new Date(formatDate(state.machinedata[indexno].startDate))).getTime();
          }
          let occurdate = (new Date(array[index].occurDate)).getTime();
          let xdate = Math.floor((occurdate - basedate) / (1000));

          // モニタデータをJSON形式に変換
          let moniData = JSON.parse(array[index].monitorData);

          // ΔBVが項目にある場合
          if (isNaN(moniData[17]) == false && isNaN(moniData[100]) == false) {
            if (moniData[100] != null) {
              moniData[17] = moniData[100];
            }
            else {
              moniData[100] = moniData[17];
            }
          }

          // 詳細グラフのデータ取得
          for (let i = 0; i < graphdatalist.length; i++) {
            // データがある場合のみ
            if (moniData[graphdatalist[i]] != '' && moniData[graphdatalist[i]] != undefined && moniData[graphdatalist[i]] != null) {
              setdata[i].push([xdate, parseFloat(moniData[graphdatalist[i]])]);
            }
          }

          // 詳細グラフ表示用最新値のモニタデータ取得
          // データがある場合のみ
          if (moniData[latedatano] != '' && moniData[latedatano] != undefined && moniData[latedatano] != null) {
            setlatedata = parseFloat(moniData[latedatano]);
          }

        });
      }

      // 最新値データ更新
      if (setlatedata != null) {
        dispdata[indexno].detaillatedata.splice(0, 1);
        dispdata[indexno].detaillatedata.push(setlatedata);
      }

      // 詳細グラフデータ更新
      dispdata[indexno].detaildata.splice(0, dispdata[indexno].detaildata.length);
      for (let i = 0; i < setdata.length; i++) {
        dispdata[indexno].detaildata.push(setdata[i]);
      }

      // 詳細グラフのモニター項目リスト更新
      dispdata[indexno].detailmoninolist.splice(0, dispdata[indexno].detailmoninolist.length);
      for (let i = 0; i < graphdatalist.length; i++) {
        dispdata[indexno].detailmoninolist.push(graphdatalist[i]);
      }

      // モニタデータ最新値
      viewmachinedata.latedata = dispdata[indexno].detaillatedata[0];

      commit(types.RECEIVE_DATRST, {
        machinedata: dispdata
      });

      // 全データ取得の場合
      if (mode == 0) {
        commit(types.SET_DETAILGRAPH_ITEM, {
          detailgraph_items: gitem
        });

        // 詳細グラフ描画
        await dispatch('reDrawDetailChart', indexno);

      }
      // 差分データのみ取得してくる場合
      else if (mode == 1) {
        // 詳細グラフ描画
        await dispatch('reDrawDetailChartNow', indexno);
      }
      // storeのデータクリア
      state.machinedata[indexno].detaildata = [];


      commit(types.SET_VIEWDATA, {
        detailmachinedata: viewmachinedata
      });

      // 成功
      //return true;
    } catch (e) {
      // 失敗
      //return false;
    }
  },
  /**
   * 詳細グラフのHighChartの描画
   * @param {Number} index 要素番号
   */
  async reDrawDetailChart({ state, commit }, index) {

    // console.log(`reDrawDetailChart ${index}`);
    let grpoptions = [];
    let graph_visible = state.detailgraph_view;

    // グラフデータ更新
    for (let i = 0; i < state.graphsettings.detail.moni_graph.length; i++) {
      let setoption = JSON.parse(JSON.stringify(state.defaultoption));
      // let setoption = state.defaultoption;

      // グラフＸ軸（時間軸）の最大値取得
      let max = getPlotxAxisMax(1, state.machinedata[index], state.graphsettings.detail.moni_graph[i].graph_info.moni_info);
      if (max && max != setoption.xAxis.max) {
        // グラフＸ軸（時間軸）の最大値設定
        setoption.xAxis.max = max;
      }

      // 透析開始線・終了線セット
      setStartEndLine(setoption, index);

      let yaxissettings = state.graphsettings.detail.moni_graph[i];
      // 左のy軸
      if (isNaN(yaxissettings.graph_info.y_l_max) || isNaN(yaxissettings.graph_info.y_l_min)
          || yaxissettings.graph_info.y_l_max == yaxissettings.graph_info.y_l_min) {
          // 左のy軸削除
        setoption.yAxis.shift();
      }
      else {
        setoption.yAxis[0].max = yaxissettings.graph_info.y_l_max;
        setoption.yAxis[0].min = yaxissettings.graph_info.y_l_min;
        let positions = [];
        let tick = (setoption.yAxis[0].max - setoption.yAxis[0].min) / 4;
        positions.push(setoption.yAxis[0].min);
        for (let j = 1; j <= 3; j++ ) {
          positions.push((tick * j) + setoption.yAxis[0].min);
          //positions.push(Math.round( (tick * j) + setoption.yAxis[0].min) );
        }
        positions.push(setoption.yAxis[0].max);
        setoption.yAxis[0].tickPositions = positions;
      }
      // 右のy軸
      if (isNaN(yaxissettings.graph_info.y_r_max) || isNaN(yaxissettings.graph_info.y_r_min)
          || yaxissettings.graph_info.y_r_max == yaxissettings.graph_info.y_r_min) {
        // 右のy軸削除
        setoption.yAxis.pop();
      }
      else {
        let len = setoption.yAxis.length - 1;
        setoption.yAxis[len].max = yaxissettings.graph_info.y_r_max;
        setoption.yAxis[len].min = yaxissettings.graph_info.y_r_min;
        let positions = [];
        let tick = (setoption.yAxis[len].max - setoption.yAxis[len].min) / 4;
        positions.push(setoption.yAxis[len].min);
        for (let j = 1; j <= 3; j++ ) {
          positions.push((tick * j) + setoption.yAxis[len].min);
          //positions.push( Math.round((tick * j) + setoption.yAxis[len].min) );
        }
        positions.push(setoption.yAxis[len].max);
        setoption.yAxis[len].tickPositions = positions;
      }

      setoption.series = [];
      grpoptions[i] = setoption;

      let settings = state.graphsettings.detail.moni_graph[i].graph_info.moni_info;
      // グラフデータ更新
      for (let j = 0; j < settings.length; j++) {
        // 項目が設定されている場合
        if (settings[j].moni_no != null) {
          // y軸の参照位置(0:左or1:右)
          let yaxis = settings[j].y_axis;
          // y軸が片方しかない場合
          if (grpoptions[i].yAxis.length == 1) {
            yaxis = 0;
          }

          // グラフセット
          grpoptions[i].series.push({
            // boostThreshold: 1,
            turboThreshold: 1,
            animation: {
              duration: 10
            },
            name: settings[j].name,
            color: settings[j].l_color,
            yAxis: yaxis,
            lineWidth: settings[j].l_width,
            marker: {
              enabled: settings[j].is_symbol
            },
            'events': {
              'afterAnimate': function () {
                // 最新プロット点滅セット
                setPlotMarkerBlink(1, this.chart.series[j]);
              }
            },
            data: getdetaildata(state.machinedata[index], settings[j].moni_no)
          });
        }
      }

      // モニタ項目設定が1つもないグラフは非表示にする
      if(grpoptions[i].series.length == 0)
      {
        graph_visible[i] = false;
      }
      setoption = null;
      yaxissettings = null;
      settings = null;
    }

    commit(types.SET_DETAILGRAPH, {
      detailgraph_view : graph_visible,
      detailgrpoptions: grpoptions
    });
    grpoptions = null;
  },
  /**
  * 最新データ取得後のHighChartの描画
  * @param {Number} index 要素番号
  */
  async reDrawDetailChartNow({ dispatch, state }, index) {

    // 患者が変更になった場合
    // if(state.machinedata[index].old_ordNo != state.machinedata[index].ordNo)
    if (state.machinedata[index].old_startDate != state.machinedata[index].startDate) {
      await dispatch('reDrawDetailChart', index);
    }
    else {
      // 詳細グラフのoption
      let grpoptions = state.detailgrpoptions;

      // グラフデータ更新
      for (let datai = 0; datai < grpoptions.length; datai++) {
        // グラフＸ軸（時間軸）の最大値取得
        let max = getPlotxAxisMax(1, state.machinedata[index], state.graphsettings.detail.moni_graph[datai].graph_info.moni_info);
        if (max && max != state.detailgraph_items[datai].options.xAxis.max) {
          // グラフＸ軸（時間軸）の最大値設定
          state.detailgraph_items[datai].options.xAxis.max = max;
        }

        // 透析開始線・終了線セット
        setStartEndLine(state.detailgraph_items[datai].options, index);

        // 詳細グラフの設定
        let detailsettings = state.graphsettings.detail.moni_graph[datai].graph_info.moni_info;

        // グラフデータセット（追加描画）
        for (let dataj = 0; dataj < grpoptions[datai].series.length; dataj++) {
          if (grpoptions[datai].series != null && detailsettings[dataj].moni_no != null) {
            var detdata = getdetaildata(state.machinedata[index], detailsettings[dataj].moni_no);

            // グラフに表示するデータがある場合
            if (detdata.length > 0) {
              let chart = state.detailgraph_items[datai].chart;

              // 最新プロット点滅リセット
              setPlotMarkerReset(chart.series[dataj]);

              // 既にグラフにデータがある場合
              if (chart.series[dataj].points.length > 0) {
                // ポイント追加
                for (var k = 0; k < detdata.length; k++) {
                  chart.series[dataj].addPoint(detdata[k], true, false);
                }
              }
              else {
                // ポイント追加
                for (var k = 0; k < detdata.length; k++) {
                  state.detailgrpoptions[datai].series[dataj].data.push(detdata[k]);
                }
              }
              // 最新プロット点滅セット
              setPlotMarkerBlink(1, chart.series[dataj]);

              chart = null;
            }
            detdata = null;
          }
        }
        detailsettings = null;
      }
      grpoptions = null;
    }
  },
  /*
   * リストグラフをクリアする
   */
  clearListGraph({
    commit
  }) {

    commit(types.RECEIVE_MSTMACHINE, {
      machinedata: []
    });
  }
};

/**
 * リストグラフ用データからモニタ項目番号が一致する実績を返す
 * @param {リストグラフ用データ} data
 * @param {モニタ項目番号} monino
 */
function getdata(data, monino) {
  if (data.data != null && data.data.length > 0) {
    // 検索
    for (let ilp = 0; ilp < data.moninolist.length; ilp++) {
      if (data.moninolist[ilp] == monino) {
        return data.data[ilp];
      }
    }
  }
  return [];
}

/**
 * 詳細グラフ用データからモニタ項目番号が一致する実績を返す
 * @param {詳細グラフ用データ} data
 * @param {モニタ項目番号} monino
 */
function getdetaildata(data, monino) {
  if (data.detaildata != null && data.detaildata.length > 0) {
    // 検索
    for (let ilp = 0; ilp < data.detailmoninolist.length; ilp++) {
      if (data.detailmoninolist[ilp] == monino) {
        return data.detaildata[ilp];
      }
    }
  }
  return [];
}

/**
 * 工程番号から工程状態を返す
 * @param {工程番号} stateno
 */
function getState(stateno) {
  // 検索
  for (let ilp = 0; ilp < detailstate.length; ilp++) {
    if (detailstate[ilp].no == stateno) {
      return detailstate[ilp];
    }
  }
  return detailstate[0];
}

/**
 * グラフに透析開始線と透析終了線を描画する
 * @param {Object} gobj セットするグラフのオブジェクト
 * @param {Number} idx 選択した装置のインデックス
 */
function setStartEndLine(gobj, idx) {
  // 患者変更時
  // if((state.machinedata[idx].old_ordNo != state.machinedata[idx].ordNo) ||
  if ((state.machinedata[idx].old_startDate != state.machinedata[idx].startDate) ||
    // 透析開始日が削除された場合
    (gobj.xAxis.plotLines.length > 0 && state.machinedata[idx].startDate == null)) {
    // 開始線・終了線クリア
    gobj.xAxis.plotLines.splice(0, gobj.xAxis.plotLines.length);
  }

  // 透析開始日時セット
  if (gobj.xAxis.plotLines.length == 0 && state.machinedata[idx].startDate != null) {
    gobj.xAxis.plotLines.push({ color: 'green', width: 2, value: 0 })
  }

  // 透析終了日時セット
  if (gobj.xAxis.plotLines.length == 1 && state.machinedata[idx].endDate != null) {
    // 透析終了日時計算
    let xdate = getElapsedTime(state.machinedata[idx].endDate, idx)

    gobj.xAxis.plotLines.push({ color: 'green', width: 2, value: xdate })
  }

  // 透析終了日時
  if (gobj.xAxis.plotLines.length == 2) {
    // 削除された場合
    if (state.machinedata[idx].endDate == null) {
      // 終了線クリア
      gobj.xAxis.plotLines.splice(1, 1);
    }
    else {
      // 透析終了日時が変更された場合
      if (gobj.xAxis.plotLines[1].value != getElapsedTime(state.machinedata[idx].endDate, idx)) {
        // 終了線クリア
        gobj.xAxis.plotLines.splice(1, 1);
        gobj.xAxis.plotLines.push({ color: 'green', width: 2, value: xdate })
      }
    }
  }
}

/**
 * 日付時刻を[YYYY/MM/DD HH:mm:ss]の形式に変換する
 * @param {日付時刻} date
 */
function formatDate(date) {
  const moment = require('moment');
  const dateformat = 'YYYY/MM/DD HH:mm:ss';
  const momentDate = moment(date);
  return momentDate.format(dateformat);
}

// 経過時間を秒単位で返す
function getElapsedTime(date, didx) {
  // 経過時間計算
  let basedate = (new Date(state.machinedata[didx].basedate)).getTime();
  let objdate = (new Date(formatDate(date))).getTime();
  return Math.floor((objdate - basedate) / (1000));
}

// カラーコードをrgbに変換
function convertColorcodeToRgb(colorcode) {
  // 先頭に#が含まれている場合は除外
  if (colorcode.split('')[0] === '#') {
    colorcode = colorcode.substring(1);
  }

  // カラーコードが省略されている場合は6桁に戻す
  if (colorcode.length === 3) {
    let codeArr = colorcode.split('');
    colorcode = codeArr[0] + codeArr[0] + codeArr[1] + codeArr[1] + codeArr[2] + codeArr[2];
  }

  // カラーコードが6桁でない場合
  if (colorcode.length !== 6) {
    return false;
  }
  let r = parseInt(colorcode.substring(0, 2), 16);
  let g = parseInt(colorcode.substring(2, 4), 16);
  let b = parseInt(colorcode.substring(4, 6), 16);
  return [r, g, b];
}

// rgbから反対色のカラーコードを取得
function complementaryColor(R, G, B) {
  //各値全てが数値かつ0以上255以下
  if (!isNaN(R + G + B) && 0 <= R && R <= 255 && 0 <= G && G <= 255 && 0 <= B && B <= 255) {
    //最大値、最小値を得る
    let max = Math.max(R, Math.max(G, B));
    let min = Math.min(R, Math.min(G, B));
    //最大値と最小値を足す
    let sum = max + min;
    //R、G、B 値を和から引く
    let newR = sum - R;
    let newG = sum - G;
    let newB = sum - B;
    let comColor = 'rgb(' + newR + ', ' + newG + ', ' + newB + ')';
    //文字列を返す
    return comColor;
  } else {
    //if 条件から外れた場合は null を返す
    return null;
  }
}

// グラフ最新プロット点滅セット
function setPlotMarkerBlink(type, series) {
  // グラフ最大数取得
  if (series == undefined || series.points == undefined) {
    return;
  }
  let max = series.points.length;
  // type 0:一覧 1:詳細
  let size = 2;
  if (type != 0) {
    size = 4;
  }
  if (max > 0) {
    let pos = series.points[max - 1];
    if (pos.x >= -1800 && pos.x <= 86400) {
      // 30分前～24時間まで
      let rgb = convertColorcodeToRgb(series.color);
      let col = complementaryColor(rgb[0], rgb[1], rgb[2]);
      pos.update({
        marker: {
          enabled: true,
          symbol: 'circle',
          fillColor: col,
          radius: size
        }
      });
      if (pos.graphic != undefined) {
        pos.graphic.css({
          '-webkit-animation': 'switchtext 0.5s infinite alternate',
          '-moz-animation': 'switchtext 0.5s infinite alternate',
          animation: 'switchtext 0.5s infinite alternate'
        });
      }
      series.points[max - 1] = pos;
    }
    pos = null;
  }
}

// グラフ最新プロット点滅リセット（点滅を元に戻す）
function setPlotMarkerReset(series) {
  // グラフ最大数取得
  if (series.points == undefined) {
    return;
  }
  let max = series.points.length;
  if (max > 0) {
    let pos = series.points[max - 1];
    if (pos.x >= -1800 && pos.x <= 86400) {
      // 30分前～24時間まで
      if (pos.graphic != undefined) {
        pos.graphic.css({});
      }
      pos.update({
        marker: {}
      });
      series.points[max - 1] = pos;
    }
    pos = null;
  }
}

// グラフＸ軸（時間軸）の最大値取得
function getPlotxAxisMax(type, data, minfo) {
  let def = 16200; //16200(4.5H(s))
  let max = 0;
  let mon_data;
  let no_list;

  // type 0:一覧 1:詳細
  if (type == 0) {
    mon_data = data.data;
    no_list = data.moninolist;
  }
  else {
    mon_data = data.detaildata;
    no_list = data.detailmoninolist;
  }

  if (mon_data != undefined && mon_data.length > 0) {
    // 全グラフデータから最大値を取得
    for (let i = 0; i < minfo.length; i++) {
      for (let ilp = 0; ilp < no_list.length; ilp++) {
        if (no_list[ilp] == minfo[i].moni_no) {
          if (mon_data[ilp] == undefined) continue;
          let len = mon_data[ilp].length;
          if (len <= 0) continue;
          if (max == 0) max = def;
          let x = mon_data[ilp][len - 1][0];
          if (x <= max) continue;
          // 最大値を求める
          for (let j = 1, h = 0; j <= 20; j++) {
            h = (j * 3600);
            if (j == 20) h -= 1800; // 最大24時間まで
            if (x < (h + def) || j == 20) {
              max = h + def;
              break;
            }
          }
          break;
        }
      }
    }
  }
  mon_data = null;
  no_list = null;
  return max;

}

// mutations
const mutations = {
  [types.SET_FACILITY_CODE](state, payload) {
    state.facilityCd = payload.facilityCd;
  },
  [types.RECEIVE_BEDGROUPLIST](state, payload) {
    state.bedgrouplist = payload.bedgrouplist;
  },
  [types.RECEIVE_GRAPHSETTINGLIST](state, payload) {
    state.listgraph_settingslist = payload.listgraph_settingslist;
    state.listgraph_settings_select_no = payload.listgraph_settings_select_no;
    state.detailgraph_settingslist = payload.detailgraph_settingslist;
    state.detailgraph_settings_select_no = payload.detailgraph_settings_select_no;
  },
  [types.CHANGE_GRAPHSETTING_LIST](state, payload) {
    state.listgraph_settings_select_no = payload.listgraph_settings_select_no;
  },
  [types.CHANGE_GRAPHSETTING_DETAIL](state, payload) {
    state.detailgraph_settings_select_no = payload.detailgraph_settings_select_no;
  },
  [types.RECEIVE_GRAPHSETTING](state, payload) {
    state.graphsettings = payload.graphsettings;
  },
  [types.RECEIVE_MSTMONITOR](state, payload) {
    state.graphsettings = payload.graphsettings;
  },
  [types.RECEIVE_MSTMACHINE](state, payload) {
    state.machinedata = payload.machinedata;
  },
  [types.RECEIVE_DATRST](state, payload) {
    state.machinedata = payload.machinedata;
  },
  [types.SET_DETAILINDEX](state, payload) {
    state.detailGraphIndex = payload.detailGraphIndex;
  },
  [types.SET_DETAILGRAPH](state, payload) {
    state.detailgraph_view = payload.detailgraph_view
    state.detailgrpoptions = payload.detailgrpoptions;
  },
  [types.SET_VIEWDATA](state, payload) {
    state.detailmachinedata = payload.detailmachinedata;
  },
  [types.SET_STATE](state, payload) {
    state.loadstate = payload.loadstate;
  },
  [types.SET_FRAME_SHOW_MODE](state, payload) {
    state.frameShowMode = payload.frameShowMode;
  },
  [types.SET_DISPNO](state, payload) {
    state.dispNo = payload.dispNo;
  },
  [types.SET_DETAILGRAPH_ITEM](state, payload) {
    state.detailgraph_items = payload.detailgraph_items;
  },
  [types.SET_DEFAULT_APPITEM](state, payload) {
    state.appitems.splice(0, state.appitems.length);
    for (let i = 0; i < payload.size; i++) {
      let setoption = JSON.parse(JSON.stringify(defaultAppItemChartOption));

      // 左のy軸
      if (isNaN(state.graphsettings.list.moni_graph.graph_info.y_l_max) || isNaN(state.graphsettings.list.moni_graph.graph_info.y_l_min)
          || state.graphsettings.list.moni_graph.graph_info.y_l_max == state.graphsettings.list.moni_graph.graph_info.y_l_min) {
          // 左のy軸削除
        setoption.yAxis.shift();
      }
      else {
        setoption.yAxis[0].max = state.graphsettings.list.moni_graph.graph_info.y_l_max;
        setoption.yAxis[0].min = state.graphsettings.list.moni_graph.graph_info.y_l_min;
        let positions = [];
        positions.push(setoption.yAxis[0].min);
        positions.push(((setoption.yAxis[0].max - setoption.yAxis[0].min) / 2) + setoption.yAxis[0].min);
        //positions.push(Math.round((setoption.yAxis[0].max - setoption.yAxis[0].min) / 2) + setoption.yAxis[0].min);
        positions.push(setoption.yAxis[0].max);
        setoption.yAxis[0].tickPositions = positions;
      }

      // 右のy軸
      if (isNaN(state.graphsettings.list.moni_graph.graph_info.y_r_max) || isNaN(state.graphsettings.list.moni_graph.graph_info.y_r_min)
          || state.graphsettings.list.moni_graph.graph_info.y_r_max == state.graphsettings.list.moni_graph.graph_info.y_r_min) {
          // 右のy軸削除
        setoption.yAxis.pop();
      }
      else {
        let len = setoption.yAxis.length - 1;
        setoption.yAxis[len].max = state.graphsettings.list.moni_graph.graph_info.y_r_max;
        setoption.yAxis[len].min = state.graphsettings.list.moni_graph.graph_info.y_r_min;
        let positions = [];
        positions.push(setoption.yAxis[len].min);
        positions.push(((setoption.yAxis[len].max - setoption.yAxis[len].min) / 2) + setoption.yAxis[len].min);
        //positions.push(Math.round((setoption.yAxis[len].max - setoption.yAxis[len].min) / 2) + setoption.yAxis[len].min);
        positions.push(setoption.yAxis[len].max);
        setoption.yAxis[len].tickPositions = positions;
      }

      if (setoption.yAxis.length > 0) {
        // y軸の真中にプロット線を引く
        setoption.yAxis[0].plotLines.push({ width: 1, value: Math.round((Math.abs(setoption.yAxis[0].max) - Math.abs(setoption.yAxis[0].min)) / 2) });
      }

      setoption.series = [];

      state.appitems.push(setoption);
    }
  }

};

export default {
  namespaced: true,
  state,
  actions,
  mutations,
  getters,
};
