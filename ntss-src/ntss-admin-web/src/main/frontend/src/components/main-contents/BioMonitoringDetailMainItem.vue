<template>
  <div id='detail-page'>
    <div class='maindate'>
      <div class='detail-head'>
        <div class='detail-head-left'>
          <div class='detail-head-left-content'>
            <div class='monitoring-detail-info-label detail-machine-name'>{{machinedata[detailGraphIndex].machineName}}</div>
            <div class='monitoring-detail-info-label detail-machine-name'>{{machinedata[detailGraphIndex].bedName}}</div>
            <div id='alertinfo' class='monitoring-detail-info-label detail-machine-name'
              v-bind:class='machinedata[detailGraphIndex].alertTextStyle'>
                  {{machinedata[detailGraphIndex].alertInfo}}
            </div>
          </div>
          <div class='detail-head-left-content'>
            <!--
            <span class='detail-lbl-moni-name'>{{graphsettings.detail.moni_text.name}}</span>
            <span class='ntss-monitoring-highlight-text-1'>{{detailmachinedata.latedata}}</span>
            <span>{{graphsettings.detail.moni_text.unit}}</span>
            -->
          </div>
          <div>
            <!--
            <span id='state' class='detail-lbl-moni-state'>{{detailmachinedata.state}}</span>
            <span>{{detailmachinedata.latedate}}</span>
            -->
          </div>
        </div>
        <div class='detail-head-right'>
          <v-ons-select
            class='detail-select-setting' v-model=settingNo>
            <option id='selectctlno'
              v-for='option in detailgraph_settingslist'
              :key=option.length :value='option.ctlNo'>{{ option.templateName }}</option>
          </v-ons-select>
          <!--<v-ons-button @click='switchDisplay' class='detail-sw-btn' >
            <v-ons-icon icon='fa-list' size='0.8em' />
          </v-ons-button>-->
        </div>
      </div>
    </div>
    <div id='detail-graphs'>
      <div class='ntss-monitoring-basepane detail-basepane' v-show='detailgraph_view[0]'>
        <div id='divleft1' class='detail-panel-left'>
        </div>
        <div class='detail-panel-right'>
        <div id='divright1'>
        </div>
        <div class='detail-panel-time' v-show="detailgrptime1 > 4">{{detailgrptime1}}h</div>
        </div>
        <div class='detail-panel-center'>
          <highcharts :options='detailgrpoptions[0]' ref='highcharts1'></highcharts>
        </div>
      </div>
      <div class='ntss-monitoring-basepane detail-basepane' v-show='detailgraph_view[1]'>
        <div id='divleft2' class='detail-panel-left'>
        </div>
        <div class='detail-panel-right'>
        <div id='divright2'>
        </div>
        <div class='detail-panel-time' v-show="detailgrptime2 > 4">{{detailgrptime2}}h</div>
        </div>
        <div class='detail-panel-center'>
          <highcharts :options='detailgrpoptions[1]' ref='highcharts2'></highcharts>
        </div>
      </div>
      <div class='ntss-monitoring-basepane detail-basepane' v-show='detailgraph_view[2]'>
        <div id='divleft3' class='detail-panel-left'>
        </div>
        <div class='detail-panel-right'>
        <div id='divright3'>
        </div>
        <div class='detail-panel-time' v-show="detailgrptime3 > 4">{{detailgrptime3}}h</div>
        </div>
        <div class='detail-panel-center'>
          <highcharts :options='detailgrpoptions[2]' ref='highcharts3'></highcharts>
        </div>
      </div>
      <div class='ntss-monitoring-basepane detail-basepane' v-show='detailgraph_view[3]'>
        <div id='divleft4' class='detail-panel-left'>
        </div>
        <div class='detail-panel-right'>
        <div id='divright4'>
        </div>
        <div class='detail-panel-time' v-show="detailgrptime4 > 4">{{detailgrptime4}}h</div>
        </div>
        <div class='detail-panel-center'>
          <highcharts :options='detailgrpoptions[3]' ref='highcharts4'></highcharts>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getScopedElementsByClassName, queryScopedSelectorAll, getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
/* eslint-disable */
import { mapState, mapActions,mapGetters  } from "@/compat/vue/vuex";
import Highcharts from '@/compat/charts/highcharts';
import { Boost as loadBoost } from '@/compat/charts/highcharts';

loadBoost(Highcharts);
export default {
    name: 'c',
  data: {
    grptime1: 4,  // デフォルト4時間
    grptime2: 4,  // デフォルト4時間
    grptime3: 4,  // デフォルト4時間
    grptime4: 4,   // デフォルト4時間
    oldshowMachineNo: 0,
    showMachineNo: 0,
    showFrameMode: 0
  },
  computed: {
    ...mapState('listGraph', [
      'detailgraph_view',
      'loadstate',
      'machinedata',
      'appitems',
      'graphsettings',
      'viewindexno',
      'detailgrpoptions',
      'detailGraphIndex',
      'detailmachinedata',
      'detailgraph_settingslist',
      'detailgraph_settings_select_no'
    ]),
    ...mapState('user', ['facilityCd']),
    ...mapGetters('listGraph', ['machineStatePatId']),
    settingNo:{
      get: function() {
        return this.detailgraph_settings_select_no;
      },
      set: function(value) {
        this.$store.commit('listGraph/CHANGE_GRAPHSETTING_DETAIL', {
          detailgraph_settings_select_no: value
          });
        this.setGraphSeting();
      }
    },
    detailgrptime1: function() {
      this.grptime1 = Math.floor(this.detailgrpoptions[0].xAxis.max / 3600);
      return this.grptime1;
    },
    detailgrptime2: function() {
      this.grptime2 = Math.floor(this.detailgrpoptions[1].xAxis.max / 3600);
      return this.grptime2;
    },
    detailgrptime3: function() {
      this.grptime3 = Math.floor(this.detailgrpoptions[2].xAxis.max / 3600);
      return this.grptime3;
    },
    detailgrptime4: function() {
      this.grptime4 = Math.floor(this.detailgrpoptions[3].xAxis.max / 3600);
      return this.grptime4;
    },
    showMachineNo: function() {

      if( this.oldshowMachineNo != this.$store.state.listGraph.detailGraphIndex ) {

        // 表示装置の変更
        // console.log( 'showMachineNo' );

        //// 詳細グラフクリア
        //this.clearDetailGraph();

        // 詳細グラフのデータセット
        this.setDetailData(this);

        this.oldshowMachineNo = this.$store.state.listGraph.detailGraphIndex;
      }

      return this.$store.state.listGraph.detailGraphIndex;
    }
  },

  methods: {
    ...mapActions('listGraph', {
      setDefaultOption: 'setDefaultOption',
      fetchGraphSetting:'fetchGraphSetting',
      fetchDataMonitor:'fetchDataMonitor',
      setDetailGraph: 'setDetailGraph',
      setDispNo: 'setDispNo',
      setState: 'setState'
    }),
    ...mapActions('patInfoHeader', [
      'setPatientData'
    ]),
    setPatientHeaderParameter(){
      let machineData = this.machinedata[this.$store.state.listGraph.detailGraphIndex];
      this.setPatientData({
        patId: machineData.patId,
        hospPatId: machineData.hospPatId,
        patName: machineData.patName,
        sexType: machineData.patSex,
        patBloodTypeAbo: machineData.patBloodTypeAbo,
        patBloodTypeRh: machineData.patBloodTypeRh,
        patBirthday: machineData.patBirthday,
        inOutClass: machineData.inOutClass,
        isInfect: machineData.isInfect,
        tabooInfo: machineData.tabooInfo,
        isImplant: machineData.isImplant,
        isSame: machineData.isSame
      });
    },
    setDefaultDetail() {
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      let legendElem = ownerWindow.getComputedStyle(getScopedElementsByClassName('ntss-monitoring-legend-style', this.$el || null)[0], null);
      let legendHoverElem = ownerWindow.getComputedStyle(getScopedElementsByClassName('ntss-monitoring-legend-hover-style', this.$el || null)[0], null);
      let legendHiddenElem = ownerWindow.getComputedStyle(getScopedElementsByClassName('ntss-monitoring-legend-hidden-style', this.$el || null)[0], null);
      let legendColor = {
        legendColor:legendElem.getPropertyValue('color'),
        hoverColor:legendHoverElem.getPropertyValue('color'),
        hiddenColor:legendHiddenElem.getPropertyValue('color')
      };
      // console.log( legendColor );

      this.setDefaultOption(legendColor);
    },
    setDetailData(vueobj) {
      // データ取得開始
      vueobj.setState(true);

      this.setDetailGraph({
        gitem: this.$refs,
        mode: 0
      });

      // データ取得完了
      vueobj.setState(false);
    },
    // シンボルマークを削除する
    clearGraphsymbol(){
      for(let i=1;i<=this.graphsettings.detail.moni_graph.length;i++)
      {

        // 左のシンボルマークを削除
        if (getScopedElementById('divleft' + i, this.$el || null).hasChildNodes())
        {
          while (getScopedElementById('divleft' + i, this.$el || null).childNodes.length > 0)
          {
            getScopedElementById('divleft' + i, this.$el || null).removeChild(getScopedElementById('divleft'+ i, this.$el || null).firstChild)
          }
        }

        // 右のシンボルマークを削除
        if (getScopedElementById('divright' + i, this.$el || null).hasChildNodes())
        {
          while (getScopedElementById('divright' + i, this.$el || null).childNodes.length > 0)
          {
            getScopedElementById('divright' + i, this.$el || null).removeChild(getScopedElementById('divright' + i, this.$el || null).firstChild)
          }
        }
      }
    },
    // シンボルマークに色を付ける
    setGraphsymbol(){
      for(let i=0;i<4;i++){
        for(let j=0;j<6;j++)
        {
          // モニタ項目が設定されている場合
          if(this.graphsettings.detail.moni_graph[i].graph_info.moni_info[j].moni_no != null)
          {
            let divPosition;
            if(this.graphsettings.detail.moni_graph[i].graph_info.moni_info[j].y_axis == 0)
            {
              //要素を取得
              divPosition = getScopedElementById('divleft'+( i + 1), this.$el || null);
            }
            else{
              divPosition = getScopedElementById('divright' +( i + 1), this.$el || null);
            }
            //divの生成
            const ownerDocument = divPosition?.ownerDocument || this.$el?.ownerDocument || document;

            //divの生成
            var symbolPosition = ownerDocument.createElement('div');
            //挿入する文字の生成
            symbolPosition.innerHTML = '●';
            //styleを設定
            symbolPosition.style.cssText = 'color :' + this.graphsettings.detail.moni_graph[i].graph_info.moni_info[j].l_color;
            //divに挿入
            divPosition.appendChild(symbolPosition);
          }
        }
      }
    },
    setGraphSeting()
    {

      // 初期値のグラフオプションセット
      this.setDefaultDetail();

      // グラフ設定情報取得
      this.fetchGraphSetting({listmode:false, facilityCd: this.facilityCd}).then(result =>
      {
        if(result == false)
        {
          alert('グラフの設定情報の取得失敗');
        }

          // モニタデータ項目情報取得
          this.fetchDataMonitor(this.facilityCd).then(result =>
          {
            if(result == false)
            {
              alert('モニタデータ項目情報の取得失敗');
            }
            //  詳細グラフのデータセット
            this.setDetailData(this);

            // シンボルマークを削除する
            this.clearGraphsymbol();

            // シンボルマークを追加する
            this.setGraphsymbol();
          });
      });
    },
    clearDetailGraph() {

      // 詳細グラフのoption
      let grpoptions = this.$store.state.listGraph.detailgrpoptions;

      // 詳細グラフ件数分
      let graphcount = this.$store.state.listGraph.detailgraph_items.length;
      if ( graphcount != undefined && 0 < graphcount ) {
        // console.log( "this.$store.state.listGraph.detailgraph_items.length :" + graphcount );
        for (let datai = 0; datai < graphcount; datai++) {
          // 透析開始線・終了線セット
          //setStartEndLine(this.$store.state.listGraph.detailgraph_items[datai].options, this.$store.state.listGraph.detailGraphIndex);

          // 系列分
          let chart = this.$store.state.listGraph.detailgraph_items[datai].chart;
          let series = chart.series;
          // console.log( "chart :" + chart );
          // console.log( "series :" + series );
          if( chart != undefined && series != undefined && 0 < series.length ) {
            for (let dataj = 0; dataj < series.length; dataj++) {
              // グラフデータ削除
              if( series[dataj].data != undefined && 0 < series[dataj].data.length) {
                //console.log( "before chart.series[dataj].data.length :" + chart.series[dataj].data.length );
                series[dataj].data.splice(0);
                // console.log( "after chart.series[dataj].data.length :" + chart.series[dataj].data.length );
              }
            }
            // for (let dataj = series.length - 1; 0 <= dataj; dataj--) {
            //   // グラフデータ削除
            //   if( series[dataj] != undefined ) {
            //     series[dataj].remove();
            //     console.log( "remove chart.series[dataj]:" + dataj );
            //   }
            // }

            chart.redraw();
            //chart.update();
          }
        }
      }
    },
    switchDisplay(){}
  },
  watch: {
    // 表示装置の変更
    showMachineNo: function() {
    },
    machineStatePatId:{
      handler: function() {
        this.setPatientHeaderParameter();
      }
    }
  },
  created() {
    // 初期値のグラフオプションセット
    this.setDefaultDetail();
  },

  mounted: function() {

    //  詳細グラフのデータセット
    this.setDetailData(this);

    // シンボルマークを追加する
    this.setGraphsymbol();

    // 患者情報ヘッダーに患者情報をセット
    this.setPatientHeaderParameter();

    // リスト画面の要素にクラス名を追加
    Array.prototype.forEach.call(queryScopedSelectorAll('.page', this.$el || null),function(elm){
      if( elm.classList.contains('ntss-monitoring-listMainItem') == false ) {
        elm?.classList?.add('ntss-monitoring-detailMainItem');
      }
    });

    // フレーム分割ありの場合
    this.showFrameMode = this.$store.state.listGraph.frameShowMode;
    if( this.showFrameMode == 1 ) {
      // 詳細画面の幅を残り領域すべてにする
      let elm_page   = getScopedElementsByClassName("ntss-monitoring-detailMainItem", this.$el || null)[0];
      let elm_header = elm_page.lastChild.firstChild;
      let elm_main   = elm_page.lastChild.lastChild;
      elm_page?.classList?.add("ntss-monitoring-split-frame-detail");
      elm_header?.classList?.add("ntss-monitoring-split-frame-detail");
      elm_main?.classList?.add("ntss-monitoring-split-frame-detail");
    }

    setTimeout( () => {
      // 一覧画面を表示する
      let elm_page = getScopedElementsByClassName("ntss-monitoring-listMainItem", this.$el || null)[0];
      elm_page.style.display = "block";

      // リサイズイベント発生
      (this.$el?.ownerDocument?.defaultView || window).dispatchEvent(new Event('resize'));

      // フレーム分割ありの場合
      if( this.showFrameMode == 1 ) {
        // 一覧画面のパンくずリスト「生体モニタリング詳細」を消去する
        let elm = queryScopedSelectorAll('.ntss-monitoring-listMainItem .breadcrumb-content > li', this.$el || null)[1];
        elm.style.display = "none";
        // 詳細画面のパンくずリスト「生体モニタリング」を消去する
        elm = queryScopedSelectorAll('.ntss-monitoring-detailMainItem .breadcrumb-content > li', this.$el || null)[0];
        elm.style.display = "none";
      }
    }, 2500 );

    setTimeout( () => {
      // 一覧画面を表示する
      let elm_page = getScopedElementsByClassName("ntss-monitoring-listMainItem", this.$el || null)[0];
      elm_page.style.display = "block";

      // リサイズイベント発生
      (this.$el?.ownerDocument?.defaultView || window).dispatchEvent(new Event('resize'));
    }, 5000 );

    setTimeout( () => {
      // 一覧画面を表示する
      let elm_page = getScopedElementsByClassName("ntss-monitoring-listMainItem", this.$el || null)[0];
      elm_page.style.display = "block";

      // リサイズイベント発生
      (this.$el?.ownerDocument?.defaultView || window).dispatchEvent(new Event('resize'));
    }, 8000 );
  },

  beforeUnmount()
  {
    // 表示中画面番号セット
    this.setDispNo(0);

    // 一覧画面を元に戻す
    Array.prototype.forEach.call(queryScopedSelectorAll('.ntss-monitoring-split-frame-list', this.$el || null),function(elm){
      elm.classList.remove('ntss-monitoring-split-frame-list');
    });

    // 選択状態を解除
    let elm = getScopedElementsByClassName("ntss-monitoring-select-machine-list", this.$el || null)[0];
    if( elm != undefined && elm.classList.contains("ntss-monitoring-select-machine-list") == true ) {
      elm.style.border = "";
      elm.classList.remove("ntss-monitoring-select-machine-list");
    }

    // Array.prototype.forEach.call(document.querySelectorAll('.hide-appitembox'), function(elm){
    //   elm.classList.remove('hide-appitembox');
    // });
  }
};
</script>
<style scoped>
#detail-page {
  height: 100%;
  /*overflow: auto;*/
}
.detail-head {
  display: flex;
  margin-top:3px;
  height: 2.5em;
  overflow: hidden;
  justify-content: space-between;
}
#detail-graphs {
  overflow: auto;
  position: absolute;
  top: 3em; /*30px;*/
  left: 0px;
  right: 0px;
  bottom: 0;
}

@media screen and (orientation: portrait) {
  /* 縦向きの場合のスタイル*/
  .detail-head {
    height: 4.5em;
  }
  #detail-graphs {
    top: 5em; /*50px;*/
  }
}

#imgbox {
  width: 890px;
  text-align: right;
}
/*#closebt {
  margin-left: auto;
}*/
/*
.detail-head {
  display: flex;
  margin-top:3px;
}
*/
.detail-head-left {
  display: flex;
  flex-wrap: wrap;
  /* width: 70%; */
}
.detail-head-right {
  margin-top: -10px;
  /* width: 30%; */
  display: flex;
  justify-content: flex-end;
  align-items: center;
}
.detail-head-left-content {
  display: flex;
  flex-wrap: wrap;
}
.detail-machine-name {
  padding-left: 10px;
  font-size: 1.8em;
  line-height: 1.2em;
}
.detail-lbl-moni-name {
  padding-left: 2px;
}
.detail-lbl-moni-state {
  padding-left: 2px;
}

.detail-select-setting {
  /* height: 80%; */
  background-color:white;
  color:black;
}
.select{
    -webkit-appearance: none;
    -moz-appearance: none;
    /* appearance: none; */
    font-size: 0.5em;
    height: 25px;
    /* background: transparent; */
    position: relative;
    z-index: 1;
    /* padding: 0 40px 0 10px; */
    border: 1px;
}
.detail-sw-btn {
  width:40px;
  height: 30px;
}

.detail-basepane {
  margin: 2px 5px 3px 5px;
}
.detail-panel-left {
  margin-left:5px;
  width: 10px;
  float: left;
}
.detail-panel-right {
  margin-left:5px;
  width: 10px;
  float: right;
}
.detail-panel-center {
  margin-left:20px;
  margin-right:20px;
}
.detail-panel-time {
  margin-top:20px;
  width: 20px;
  float:right;
  text-align:center;
  line-height: 15px;
  border-radius: 4px;
  color:black;
  background-color:lightgreen;
}

ol.topic-path {
  margin: 0; /* マージン（上下左右） */
  padding: 7px 5px; /* パディング（上下、左右） */
  background-color: black; /* 背景色 */
  color: white;
  list-style-type: none; /* リストマーク非表示 */
  text-align: left;
}
/* リスト項目 */
ol.topic-path li {
  display: inline; /* 項目を横並び */
}
/* リンクエリア */
ol.topic-path li a {
  padding-right: 18px; /* 右パディング */
}
/* リンク色 */
ol.topic-path li a {
  color: #4682b4;
}
/* リンク色（マウスオーバー） */
ol.topic-path li a:hover {
  color: #79a7cc;

  /*カーソルを合わせると指マークにする*/
  cursor: pointer;
  cursor: hand;
}

.titlebar {
  display: table;
  display: inline; /* 項目を横並び */
}
.item {
  display: table-cell;
  color: #ffffff;
  text-align: left;
  float: left;
}
.name {
  display: table-cell;
  color: #ffffff;
  text-align: left;
  float: left;
}
.Recirculation-rate {
  display: table-cell;
  color: #ffffff;
  text-align: left;
  float: left;
}
.day {
  display: table-cell;
  color: #ffffff;
  text-align: right;
  float: right;
}
.mode {
  display: table-cell;
  color: #008000;
  text-align: right;
  float: right;
}
.maindate {
  color: #ffffff;
  text-align: left;
}
</style>
