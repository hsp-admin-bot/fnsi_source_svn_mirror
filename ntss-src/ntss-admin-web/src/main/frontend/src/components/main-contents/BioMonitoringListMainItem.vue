<template>
  <div id='listbox' >
    <div class='ntss-monitoring-basepane box'
      v-for='(category, idx) in machinedata' :key=category.machineSerial
      v-bind:class='category.alertStyle'
      v-bind:id="['cate' + category.machineSerial]" v-show='category.visible'>
      <Appitem v-bind:index-number=idx ref='m_box'></Appitem>
    </div>
    <div class='emptybox' v-for='i in 5' :key=i></div>
    <!-- スタイル取得用隠し要素 -->
    <div class='ntss-monitoring-legend-style' />
    <div class='ntss-monitoring-legend-hidden-style' />
    <div class='ntss-monitoring-legend-hover-style' />
  </div>
</template>

<script>
import { getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
/* eslint-disable */
import { mapState, mapActions } from "@/compat/vue/vuex";
import Appitem from "@/components/main-contents/sub-contents/Appitem";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
export default {

  components: {
    Appitem
  },
  data: {
    wsConnect: false,
    wsMessage: "",
    timerAction: 0,
    timerUpdate: 0,
    dtLastRecieved: new Date()
  },
  computed: {
    ...mapState("listGraph", ["machinedata", "graphsettings"]),
    ...mapState("user", ["facilityCd"]),
    //...mapState('websocket', ['socket']),
    title() {
      return "";
    },
    wsConnect: function() {
      if (this.$store.state.websocket.socket.isConnected == true) {
        // WesSocket リクエスト
        this.wsRequest();
      }
      return this.$store.state.websocket.socket.isConnected;
    },
    wsMessage: function() {
      if (
        this.$store.state.websocket.socket.isConnected == true &&
        this.$store.state.websocket.socket.message != ""
      ) {
        // WesSocket レスポンス
        this.wsRresponse();
      }
      return this.$store.state.websocket.socket.message;
    }
  },

  methods: {
    ...mapActions("listGraph", {
      setFacilityCode: "setFacilityCode",
      fetchGraphSettingList: "fetchGraphSettingList",
      fetchGraphSetting: "fetchGraphSetting",
      fetchDataMachine: "fetchDataMachine",
      fetchDataMonitor: "fetchDataMonitor",
      fetchDataResult: "fetchDataResult",
      reDrawChart: "reDrawChart",
      reDrawChartNow: "reDrawChartNow",
      setDetailGraph: "setDetailGraph",
      setState: "setState"
    }),
    loadData() {
      // データ取得開始
      this.setState(true);

      // グラフ設定一覧情報取得
      this.fetchGraphSettingList(this.facilityCd).then(result => {
        if (result == false) {
          //alert('グラフの設定一覧情報の取得失敗');
        }
        // グラフ設定情報取得
        this.fetchGraphSetting({
          listmode: true,
          facilityCd: this.facilityCd
        }).then(result => {
          if (result == false) {
            alert("グラフの設定情報の取得失敗");
          }

          // モニタデータ項目情報取得
          this.fetchDataMonitor(this.facilityCd).then(result => {
            if (result == false) {
              alert("モニタデータ項目情報の取得失敗");
            }

            // 装置一覧取得
            this.fetchDataMachine({
              mode: 0,
              facilityCd: this.facilityCd
            }).then(async result => {
              if (result == false) {
                alert("装置一覧情報の取得失敗");
              }

              // グラフ読み込み
              for (let i = 0; i < this.machinedata.length; i++) {
                await this.fetchDataResult({
                  mode: 0,
                  index: i
                });
                await this.reDrawChart(i);
              }

              // データ取得完了
              this.setState(false);

              // TODO: タイマー更新機能不要時には削除
              this.timerUpdate = setInterval(() => {
                // NOTE: デバッグ用・websocket自動更新受信を強制的に発生させる
                this.$store.state.websocket.socket.isConnected = true;
                this.$store.state.websocket.socket.message = { data: "UPDATE" };
              }, 20000);
            });
          });
        });
      });
    },
    getMonitoringListNextdata() {
      // 装置一覧取得
      this.fetchDataMachine({ mode: 1, facilityCd: this.facilityCd }).then(
        async result => {
          if (result == false) {
            alert("装置一覧情報の取得失敗");
          }
          // グラフ読み込み
          for (let i = 0; i < this.machinedata.length; i++) {
            // console.time("function time");
            await this.fetchDataResult({
              mode: 1,
              index: i
            });
            await this.reDrawChartNow({
              gitem: this.$refs.m_box[i],
              index: i
            });
            // console.timeEnd("function time");
          }
        }
      );
      // // データ取得完了
      this.setState(false);
    },
    // 詳細グラフ最新データ更新
    getlatestdata() {
      // 装置一覧取得
      this.fetchDataMachine({ mode: 1, facilityCd: this.facilityCd }).then(
        async result => {
          if (result == false) {
            alert("装置一覧情報の取得失敗");
          }

          // 詳細グラフ読み込み
          await this.setDetailGraph({ gitem: null, mode: 1 });

          // リストグラフ最新データ取得
          for (let i = 0; i < this.machinedata.length; i++) {
            await this.fetchDataResult({
              mode: 1,
              index: i
            });
            await this.reDrawChartNow({
              gitem: this.$refs.m_box[i],
              index: i
            });
          }
        }
      );

      // // データ取得完了
      this.setState(false);
    },
    // WesSocket リクエスト
    wsRequest: function() {
      let tag = `NTSS${this.facilityCd}WEBMONI`;
      this.$socket.send(tag);
      // console.log(`socket send tag: ${tag}`);
      this.timerAction = setInterval(() => {
        try {
          // 接続確認確認実施
          this.$socket.send(" ");
        } catch (e) {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('BioMonitoringListMainItem.vue', 'wsRequest', e);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          // console.log("socket send error : " + e);
        }
        // 現在日時取得
        let now = new Date();

        // 最終受信日時からの秒数算出
        let sec = (now - this.dtLastRecieved) / 1000;
        // 60秒間受信がない場合
        if (60 <= sec) {
          // エラーと判断してWebSocketを再接続する
          // console.log("socket error detect. sec :" + sec);

          // タイマー終了
          clearInterval(this.timerAction);

          // 再接続実施
          this.$connect();
        }
      }, 30000);
    },
    // WesSocket レスポンス
    wsRresponse: function() {
      //const msg = JSON.stringify(storews.state.socket.message);
      const msg = this.$store.state.websocket.socket.message;
      // console.log(msg.data);

      // 最終受信日時設定
      this.dtLastRecieved = new Date();

      if (msg.data == "UPDATE") {
        // メッセージをクリアする
        this.$store.state.websocket.socket.message = "";

        // データ取得中でない場合
        if (this.$store.state.listGraph.loadstate == false) {
          // // データ取得開始
          this.setState(true);

          // リストグラフ表示中の場合
          if (this.$store.state.listGraph.dispNo == 0) {
            // リストグラフ最新データ取得
            this.getMonitoringListNextdata();
          } else if (this.$store.state.listGraph.dispNo == 1) {
            // 詳細グラフ表示中の場合
            // 詳細グラフ最新データ更新
            this.getlatestdata();
          }
        }
      }
    }
  },
  watch: {
    // WesSocket リクエスト
    wsConnect: function() {},
    // WesSocket レスポンス
    wsMessage: function() {}
  },
  created() {
    // websocket接続
    this.$connect();
  },
  mounted() {
    // リスト画面の要素にクラス名を追加
    let elm = getScopedElementsByClassName("page", this.$el || null)[0];
    elm?.classList?.add("ntss-monitoring-listMainItem");

    this.loadData();
  },
  unmounted() {
    clearInterval(this.timerAction);

    // TODO: タイマー更新機能不要時には削除
    clearInterval(this.timerUpdate);

    this.$disconnect();

    this.$store.commit("listGraph/RECEIVE_MSTMACHINE", { machinedata: [] });
  }
};
</script>
<style scoped>
#listbox {
  text-align: center;
  height: 100%;
  overflow: auto;
  /* display: inline-flex; */
  flex-wrap: wrap;
  justify-content: center;
}
.emptybox {
  width: 372px;
  display: inline-block;
  margin: 0;
  padding: 0;
}
.box {
  width: 370px;
  height: 90px;
  /* height: 98px;*/
  display: inline-block;
  /* box-shadow:1px 1px rgba(21,21,21,0.5); */
  overflow: hidden;
  position: relative;
  margin: 0px 1px 0px 1px;
  padding: 0;
  z-index: 1;
}
.hide-appitembox {
  display: none;
}
.cont {
  z-index: 10;
  float: left;
}
.leftbox {
  float: left;
  padding-top: 7px;
}
.bedtable {
  color: white;
  font-size: 10.5px;
  margin-top: 5px;
}
.revall {
  font-size: 18px;
  color: orange;
}
.prrvall {
  font-size: 14px;
  color: mediumturquoise;
  font-weight: bold;
}
.bvvall {
  font-size: 14px;
  color: green;
  font-weight: bold;
}
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
