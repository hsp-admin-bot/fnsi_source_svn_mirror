<template>
  <div id='listplace' v-on:click='detaildisp()'>
    <div class='leftbox'>
      <div class='namebox'>
        <div class='txtmachinename ntss-monitoring-basepane-text'>{{machinedata[indexNumber].machineName}}</div>
        <div class='txtpatName ntss-monitoring-basepane-text'>{{machinedata[indexNumber].patName}}</div>
      </div>
      <div class='bedbox'>
        <div class='latedata ntss-monitoring-basepane-text'>{{graphsettings.list.moni_text[0].name}}</div>
        <div class='latedata ntss-monitoring-basepane-text'>{{graphsettings.list.moni_text[1].name}}</div>
        <div class='latedata ntss-monitoring-basepane-text'>{{graphsettings.list.moni_text[2].name}}</div>
        <div style='clear: both;'>
          <div class='latedata ntss-monitoring-basepane-text'>{{graphsettings.list.moni_text[0].unit}}</div>
          <div class='latedata ntss-monitoring-basepane-text'>{{graphsettings.list.moni_text[1].unit}}</div>
          <div class='latedata ntss-monitoring-basepane-text'>{{graphsettings.list.moni_text[2].unit}}</div>
        </div>
        <div style='clear: both;'>
          <div class='latedata fontL ntss-monitoring-highlight-text-1'>{{machinedata[indexNumber].latedata[0]}}</div>
          <div class='latedata fontM ntss-monitoring-highlight-text-2'>{{machinedata[indexNumber].latedata[1]}}</div>
          <div class='latedata fontM ntss-monitoring-highlight-text-3'>{{machinedata[indexNumber].latedata[2]}}</div>
        </div>
      </div>
    </div>
    <div class='cont'>
      <div v-bind:id="['Listleft' + indexNumber]" class='list-panel-left'></div>
      <div v-bind:id="['Listright' + indexNumber]" class='list-panel-right'></div>
      <div class='list-panel-time' v-show="listgrptime > 4">{{listgrptime}}h</div>
      <highcharts :options='option' ref='lineCharts'></highcharts>
    </div>
  </div>
</template>

<script>
/* eslint-disable */
import { mapState, mapActions, mapGetters } from "@/compat/vue/vuex";
import { getViewportWidth } from "@/functions/common/LayoutMeasureHelper";
import Highcharts from "@/compat/charts/highcharts";
import { Boost as loadBoost } from "@/compat/charts/highcharts";
import BioMonitoringDetailPage from "@/pages/BioMonitoringDetailPage";

loadBoost(Highcharts);
export default {
  props: {
    // 親から渡されるプロパティ
    indexNumber: Number
  },
    name: 'c',
  data: {
    grptime: 4  // デフォルト4時間
  },
  computed: {
    ...mapState('listGraph', ['machinedata', 'appitems', 'graphsettings']),
    ...mapGetters('listGraph',['listgraphsettings']),
    listgrptime: function() {
      this.grptime = Math.floor(this.appitems[this.indexNumber].xAxis.max / 3600);
      return this.grptime;
    },
  },
  data() {
    return {
      option: {},
      patname: ''
    };
  },
  methods: {
    ...mapActions('listGraph', {
      setDefaultGraphIndex: 'setDefaultGraphIndex',
      setFrameShowMode: 'setFrameShowMode',
      setDispNo: 'setDispNo'
    }),
    setDetailIndex() {
      this.setDefaultGraphIndex(this.indexNumber);
    },
    getScopedElementById(id) {
      return this.$el?.querySelector?.(`#${id}`) || this.$el?.ownerDocument?.getElementById?.(id) || null;
    },
    getMonitoringPageRoot() {
      return this.$el?.closest?.(".ntss-monitoring-listMainItem") || this.$el?.ownerDocument?.getElementsByClassName?.("ntss-monitoring-listMainItem")?.[0] || null;
    },
    // シンボルマークを削除する
    clearGraphsymbol(){
      // 左のシンボルマークを削除
      let divPositionL = this.getScopedElementById('Listleft' + this.indexNumber);
      while (divPositionL.firstChild) {
        divPositionL.removeChild(divPositionL.firstChild);
      }
      // 右のシンボルマークを削除
      let divPositionR = this.getScopedElementById('Listright' + this.indexNumber);
      while (divPositionR.firstChild) {
        divPositionR.removeChild(divPositionR.firstChild);
      }
    },
    // シンボルマークに色を付ける
    setGraphsymbol() {
      let moniInfo = this.graphsettings.list.moni_graph.graph_info.moni_info;
      for (let i=0;i<moniInfo.length;i++) {
        if(moniInfo[i].moni_no != null)
        {
          let divPosition;
          if (moniInfo[i].y_axis == 0) {
            //要素を取得
            divPosition = this.getScopedElementById('Listleft' + this.indexNumber);
          }
          else {
            divPosition = this.getScopedElementById('Listright' + this.indexNumber);
          }
          //divの生成
          const ownerDocument = divPosition?.ownerDocument || this.$el?.ownerDocument || document;

          //divの生成
          var symbolPosition = ownerDocument.createElement('div');
          //挿入する文字の生成
          symbolPosition.innerHTML = '●';
          //styleを設定
          symbolPosition.style.cssText = 'color :' + moniInfo[i].l_color;
          //symbolPosition.style.cssText = 'color :' + "#ffffff";
          //divに挿入
          divPosition.appendChild(symbolPosition);
        }
      }
    },
    /**
     * optionプロパティの差し替え
     */
    updateOption: function() {
      this.option = this.appitems[this.indexNumber];
    },

    detaildisp: function() {
      // データ取得中でない場合
      if (this.$store.state.listGraph.loadstate == false) {
        // 画面サイズを取得
        let innerwidth = getViewportWidth();

        // 一覧画面要素取得
        let elm_page   = this.getMonitoringPageRoot();
        let elm_header = elm_page.lastChild.firstChild;
        let elm_main   = elm_page.lastChild.lastChild;
        let elm = null;
        let width = "";

        // フレーム分割判定
        this.setFrameShowMode(0);
        if(( 372 * 2.6) <= innerwidth ) {
          // 画面サイズが372x2.8以上の場合はフレーム分割を行う
          this.setFrameShowMode(1);
          //alert("フレーム分割あり");

          // 選択状態を解除
          elm = this.$el?.ownerDocument?.getElementsByClassName?.("ntss-monitoring-select-machine-list")?.[0] || null;
          if( elm != undefined && elm.classList.contains("ntss-monitoring-select-machine-list") == true ) {
            //elm.style.border = "";
            elm.classList.remove("ntss-monitoring-select-machine-list");
          }

          let id = "cate" + this.$store.state.listGraph.machinedata[this.indexNumber].machineSerial;
          // console.log( "id: " + id );

          // 選択状態を設定
          elm = this.getScopedElementById(id);
          elm?.classList?.add("ntss-monitoring-select-machine-list");

          // 一覧画面の幅を固定する
          elm_page?.classList?.add("ntss-monitoring-split-frame-list");
          elm_header?.classList?.add("ntss-monitoring-split-frame-list");
          elm_main?.classList?.add("ntss-monitoring-split-frame-list");
        } else {
          // 一覧画面の幅を初期化する
          elm_page.classList.remove("ntss-monitoring-split-frame-list");
          elm_header.classList.remove("ntss-monitoring-split-frame-list");
          elm_main.classList.remove("ntss-monitoring-split-frame-list");
        }

        // // 装置を選択している場合
        // if(elm !=  null ) {
        //   // 選択装置をスクロールして先頭に表示
        //   document.getElementById("listbox").scrollTop = elm.offsetTop;
        // }

        // フレーム分割なしで運転中でない場合
        if( this.$store.state.listGraph.frameShowMode == 0
         && this.$store.state.listGraph.machinedata[this.indexNumber].machinestate == 0) {
           // 詳細画面を表示しない
           return;
        }

        // 現在表示中の画面を取得
        let detailShown = this.$store.state.listGraph.dispNo;

        // 表示中画面番号セット
        this.setDispNo(1);

        // 選択された装置の番号セット
        this.setDetailIndex();

        // 詳細画面が表示されているかどうか判定
        if( detailShown == 1 ) {
          // 詳細画面表示中
          //alert("詳細画面表示中");

        } else {
          // 一覧画面表示中

          // 新規追加
          this.$store.commit('navigator/push', {
            label: '生体モニタリング詳細',
            component: BioMonitoringDetailPage
          });
        }
      }
    }
  },
  watch: {
    // $route: 'fetchData',
    listgraphsettings: {
      handler: function() {
        this.clearGraphsymbol();
        this.setGraphsymbol();
      }
    }
  },

  mounted() {
    // 読み込み完了時にオプションを差し替え
    this.updateOption();

    // シンボルマークを追加する
    this.setGraphsymbol();
  }
};

</script>
<style scoped>
.cont {
  z-index: 10;
  float: left;
}
.leftbox {
  float: left;
}
.namebox {
  width: 140px;
}
.bedbox {
  width: 140px;
  clear: both;
  font-size: 10.5px;
  margin-top: 5px;
}
.latedata{
  float: left;
  width: 42px;
  height: 15px;
  overflow: hidden;
  font-size: 10px;
  margin-left: 3px;

}
.fontL
{
  font-size: 18px;
  height: 18px;
}
.fontM
{
  font-size: 14px;
  height: 18px;
}
.txtmachinename {
  font-size: 12px;
  width: 65px;
  height: 17px;
  overflow: hidden;
}
.txtpatName {
  font-size: 12px;
  width: 70px;
  height: 17px;
  overflow: hidden;
  margin-bottom: 5px;
}
.list-panel-left {
  margin-left:5px;
  width: 10px;
  position: absolute;
  z-index: 10;
}
.list-panel-right {
  margin-left:5px;
  width: 10px;
  right: 0%;
  position: absolute;
  z-index: 10;
}
.list-panel-time {
  width: 18px;
  top:60%;
  right: 2.5%;
  position: absolute;
  text-align:center;
  line-height: 13px;
  border-radius: 3px;
  color:black;
  background-color:lightgreen;
  z-index: 5;
}
/*.textList05 {
  display: none;
  font-size: 14px;
  color: green;
  font-weight: bold;
  float: left;
  width: 50px;
  text-align: center;
}*/
/*#bedtitle {
  color: white;
  font-size: 16px;
  width: 100px;
}*/
/*.highcharts-container {
  width: 350px;
  height: 200px;
}
.highcharts-root {
  width: 350px;
  height: 200px;
}
.highcharts-background {
  width: 350px;
  height: 200px;
}*/
/*.container {
  min-width: 350px;
  height: 95px;
  margin: 0 auto;
}*/
</style>
