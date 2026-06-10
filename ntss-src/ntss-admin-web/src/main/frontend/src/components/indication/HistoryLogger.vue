/**
 * 履歴ロガー コンポーネント

    プロパティ:
      propHistoryJson:ログ出力監視用プロパティ(ログ文字列(Json形式)も兼ねる)
      propSaveFlag   :ログ登録発火用フラグ

    呼び出し例)
          import inputCalendar from './inputCalendar';
          <inputCalendar ref="refInputCalendarFrom" :propDispFlag="showFlag" :propSetMinMaxFromTodayTo1Year="true" @getDateValue="getDateValueFrom"></inputCalendar>
          export default {
            components: {
              inputCalendar
            },
          }
          methods: {
            getDateValueFrom(value) {
                this.copyDateFrom = value ;
            },
          }

     日付フォーマット変換メソッド:  yyyy-mm-dd -> yyyy年m月d日(曜日)に変換
     buildDispDate
        @param  targetDate:入力日付 文字列:yyyy-mm-dd
        @return フォーマットされた日付文字列
     使い方:
          インポートしたコンポーネントにref属性(例えば,ref="refCalendarInput")を付与
          this.$refs.refCalendarInput.buildDispDate(targetDate) で実行する。
          ※Dom生成のタイミングによってはうまく変換されない場合(コンポーネントが組み込まれていないなど)は、this.$nextTickで更新待ちすると解決する(可能性が高い)
 */

<template>
<div>
履歴ロガーコンポーネント(仮文字列:ホントは何も表示しない)
</div>
</template>

<script>
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end

export default {
  props: {
    //履歴情報(Json文字列)
    propHistoryJson: {
      type: Object
    },
    //登録発火用フラグ
    propSaveFlag: {
      type: Boolean
    }
  },

  data() {
    return {
      history: [], //履歴格納
      history_num: 0, //履歴個数（インデックスでもある）
      edithistory: 0, //編集履歴数（個別）
      value_before: "", //変更前の値
      value_after: "", //変更後の値
      historyjson: {
        //履歴用JSON
        num: 0, //履歴番号(大きいほど新しい)
        row: null, //データ行番号
        key: null, //データキー（列）
        tag: "", //タグ名or要素名
        before: "", //変更前の値
        after: "", //変更後の値
        pointer2num: 0, //履歴番号へのポインター（同じ要素の履歴トレース）
        updateuser: "", //変更ユーザー
        updatetime: "" //変更時間
      }
    };
  },
  mounted() {
    //リスナーの登録
    //console.log('Listener');
    // add 性能改善メモリ不足 shan start
    this.$parent.$off("ntss-loggerCompornent", this.getLogInfo);
    // add 性能改善メモリ不足 shan end
    this.$parent.$on("ntss-loggerCompornent", this.getLogInfo);
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy(){
    this.$parent.$off("ntss-loggerCompornent", this.getLogInfo);
  },
  // add 性能改善メモリ不足 shan end
  watch: {
    //ログの更新情報フラグ兼ログ文字列 監視
    propHistoryJson() {
      //console.log("ログが設定された") ;
      //console.log("Log:" + JSON.stringify(newJson)) ;
      //this.addHistory(newJson);
      this.addHistory();
    },
    //ログ登録(API呼び出し)発火監視
    propSaveFlag(newFlag) {
      if (newFlag) {
        //フラグ false -> true
        //console.log("ログをWebAPIに送信") ;
        this.sendLogDataViaWebAPI(); //ログ送信 非同期
      }
    }
  },
  computed: {},
  methods: {
    /**
     *ログ送信処理(WebAPIへ送信)  非同期処理
     */
    async sendLogDataViaWebAPI() {
      const tmpJson = { logdata: JSON.stringify(this.history) };

      //サーバーへデータを送信 同期化
      await ApiHelper.post("/scheduleList/History/Logger", tmpJson)
        .then(
          function(/*response*/) {
            //正常終了
            //console.log("response:" + response);
          }.bind(this)
        )
        .catch(function(error) {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('HistoryLogger.vue', 'sendLogDataViaWebAPI', error);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          if (error.response) {
            // The request was made and the server responded with a status code
            // that falls out of the range of 2xx
            //console.log('error.response.data:'   + error.response.data);
            //console.log('error.response.status:' + error.response.status);
            //console.log('error.response.headers:'+ error.response.headers);
          } else if (error.request) {
            // The request was made but no response was received
            // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
            // http.ClientRequest in node.js
            //console.log('error.request:'+error.request);
          } else {
            // Something happened in setting up the request that triggered an Error
            //console.log('Error:', error.message);
          }
          //console.log(error.config);
        });
      //        return JSON.parse(response.data[0]);
    },

    /**
     */
    getLogInfo(/*value*/) {
      //console.log("なにか実施された");
    },

    /** 歴追加処理
     */
    //addHistory(inputHistoryjson) {
    addHistory() {
      //値は仮
      const strRow = "select";
      const strKey = "piyo";
      const strTag = "SELECT";

      const strOldValue = "old";
      const strNewValue = "new";

      //格納データ

      const tmpHistoryjson = JSON.parse(JSON.stringify(this.historyjson));

      tmpHistoryjson.row = strRow; //type
      tmpHistoryjson.key = strKey; //name
      tmpHistoryjson.tag = strTag;
      tmpHistoryjson.before = strOldValue;
      tmpHistoryjson.after = strNewValue;

      //履歴の追加
      ++this.history_num;

      const nownum = this.history_num;

      //送られてきた情報のキーと一致する履歴情報に絞り込みます
      const filteredHistory = this.history.filter(function(item) {
        if (item.row == tmpHistoryjson.row && item.key == tmpHistoryjson.key)
          return true;
      });

      //最新のポインター番号を取得(過去履歴がない場合は0)
      const pointer = filteredHistory.length == 0 ? 0 : filteredHistory[0].num;

      //登録日時の作成
      const date = new Date();
      let formatedDate = "YYYYMMDDhhmmss";

      // フォーマット文字列内のキーワードを日付に置換する
      formatedDate = formatedDate.replace(/YYYY/g, date.getFullYear());
      formatedDate = formatedDate.replace(
        /MM/g,
        `0${date.getMonth() + 1}`.slice(-2)
      );
      formatedDate = formatedDate.replace(
        /DD/g,
        `0${date.getDate()}`.slice(-2)
      );
      formatedDate = formatedDate.replace(
        /hh/g,
        `0${date.getHours()}`.slice(-2)
      );
      formatedDate = formatedDate.replace(
        /mm/g,
        `0${date.getMinutes()}`.slice(-2)
      );
      formatedDate = formatedDate.replace(
        /ss/g,
        `0${date.getSeconds()}`.slice(-2)
      );

      //更新者名
      const updateuser = "hoge"; //（仮）

      //値の格納
      tmpHistoryjson.num = nownum;
      tmpHistoryjson.pointer2num = pointer;
      tmpHistoryjson.updateuser = updateuser;
      tmpHistoryjson.updatetime = formatedDate;

      //console.log("tmpHistoryjson:" + tmpHistoryjson) ;

      //履歴への追加
      this.history.unshift(tmpHistoryjson);

      // //内容表示 for debug
      // for (let i in this.history) {
      //   console.log("---"+i+"---------------------------------------------------------");
      //   console.log("num:"          + this.history[i]["num"]) ;
      //   console.log("row:"          + this.history[i]["row"]) ;
      //   console.log("key:"          + this.history[i]["key"]) ;
      //   console.log("tag:"          + this.history[i]["tag"]) ;
      //   console.log("before:"       + this.history[i]["before"]) ;
      //   console.log("after:"        + this.history[i]["after"]) ;
      //   console.log("pointer2num:"  + this.history[i]["pointer2num"]) ;
      //   console.log("updateuser:"   + this.history[i]["updateuser"]) ;
      //   console.log("updatetime:"   + this.history[i]["updatetime"]) ;
      //   console.log("------------------------------------------------------------");
      // }
    }
  }
};
</script>

/**
 * スタイル定義
 */
<style scoped>
.modal-container {
  font-size: 10pt;
  margin: auto;
  max-width: 100%;
  background-color: white;
  color: black;
}

.header-style {
  text-align: left;
  color: white;
  background-color: black;
  padding: 3px;
}

.button-style {
  padding: 0 !important;
  width: 100px !important;
  height: 30px !important;
  font-size: 10pt !important;
}

.div-style {
  padding: 5px 10px;
}

.onColor:checked + span {
  background-color: #9acd32;
}
</style>
