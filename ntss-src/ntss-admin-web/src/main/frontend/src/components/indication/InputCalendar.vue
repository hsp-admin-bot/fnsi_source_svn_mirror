/** * カレンダーインプット コンポーネント プロパティ:
propMinDate:カレンダー開始日 yyyy-mm-dd
※nullor空文字でpropSetMinMaxFromTodayTo1Year=true扱い
propMaxDate:カレンダー終了日 yyyy-mm-dd
※nullor空文字でpropSetMinMaxFromTodayTo1Year=true扱い
propSetMinMaxFromTodayTo1Year:(必須)1年カレンダーフラグ
true:本日から1年後(来年の昨日まで)のカレンダー propDispFlag:(必須)表示フラグ
true:表示 false:非表示 ※画面書き換えのため フラグの変動が必要 false->true
propWidth:横幅 ※指定されない場合は、150px(推奨サイズ) propHeight:縦幅
※指定されない場合は、30px(推奨サイズ) 呼び出し側のメソッド:
@getDateValueイベントで日付変更時に変更された日付(yyyy-mm-dd)が送られてくるので、受信のためのメソッドが必要(例参照)
呼び出し例) import inputCalendar from './inputCalendar';
<inputCalendar
  ref="refInputCalendarFrom"
  :propDispFlag="showFlag"
  :propSetMinMaxFromTodayTo1Year="true"
  @getDateValue="getDateValueFrom"
></inputCalendar>
export default { components: { inputCalendar }, } methods: {
getDateValueFrom(value) { this.copyDateFrom = value ; }, }
日付フォーマット変換メソッド: yyyy-mm-dd -> yyyy年m月d日(曜日)に変換
buildDispDate @param targetDate:入力日付 文字列:yyyy-mm-dd @return
フォーマットされた日付文字列 使い方:
インポートしたコンポーネントにref属性(例えば,ref="refCalendarInput")を付与
this.$refs.refCalendarInput.buildDispDate(targetDate) で実行する。
※Dom生成のタイミングによってはうまく変換されない場合(コンポーネントが組み込まれていないなど)は、this.$nextTickで更新待ちすると解決する(可能性が高い)
*/

<template>
  <div style="position:relative;">
    <!--
      <input
        :ref="refName"
        type="date"
        v-model="dateValue"
        :min="minDate"
        :max="maxDate"
        @change="changeDate"
        style="width:150px;height:30px;display:block;"
      />
    -->
    <input
      ref="refName"
      v-model="dateValue"
      type="date"
      class="calender-input"
      :max="maxDate"
      :min="minDate"
      @change="changeDate"
    />
    <custom-calendar v-model="dateValue" />
    <input
      :ref="refNameRap"
      v-model="dateValueDisp"
      type="text"
      readonly="readonly"
      style="z-index:-1;position:absolute;top:1px;left:1px;width:10px;height:12px;"
    />
  </div>
</template>

<script>
import CustomCalendar from "@/components/common/custom-calendar/CustomCalendar";
import moment from "moment"; //日付扱い用

export default {
  components: {
    "custom-calendar": CustomCalendar
  },
  props: {
    //最小日付
    propMinDate: {
      type: String,
      validator(value) {
        const regx = new RegExp(/^[0-9]{4}-[0-9]{2}-[0-9]{2}/);
        return regx.test(value);
      }
    },
    //最大日付
    propMaxDate: {
      type: String,
      validator(value) {
        const regx = new RegExp(/^[0-9]{4}-[0-9]{2}-[0-9]{2}/);
        return regx.test(value);
      }
    },
    //1年カレンダーフラグ   true:1年カレンダー(本日～来年の昨日)
    propSetMinMaxFromTodayTo1Year: {
      type: Boolean,
      required: true
    },
    //表示フラグ  true:表示
    propDispFlag: {
      type: Boolean,
      required: true
    },
    //幅
    propWidth: {
      type: Number
    },
    //高さ
    propHeight: {
      type: Number
    }
  },
  data() {
    return {
      //格納用日付
      dateValue: "",
      //表示用日付
      dateValueDisp: "",
      //日付 最小値
      minDate: "2018-10-20",
      //日付 最大値
      maxDate: "2018-10-29",
      refName: "refName",
      refNameRap: "refNameRap"
    };
  },
  watch: {
    //モーダルの表示非表示のフラグを監視  ※モーダル表示時の初期化タイミング
    // propDispFlag: function(newFlag, oldFlag) {
    // propDispFlag(newFlag) {
    //   if (newFlag) {
    //     //非表示->表示時の処理
    //     //初期化(デフォルトをもらっておいたほうがいい?)
    //     this.dateValue = '';
    //     this.dateValueDisp = '';
    //     //位置合わせ
    //     console.log('changed to true');
    //     this.$nextTick(() => {
    //       console.log('start this.calibrateBox');
    //       this.calibrateBox();
    //       console.log('changed to true done');
    //     });
    //   } else {
    //     console.log('changed to false');
    //   }
    // },
  },
  mounted() {
    //Idの個別化処理  複数コンポーネントを使用した場合、idがかぶるので、個別化します

    //日付のミリ秒を取得します
    const idAddition = new Date().getTime();

    //console.log("idAddition:" + idAddition) ;

    //上側のIDに付加
    //console.log("bf this.refName:" + this.refName) ;
    this.refName += idAddition;
    //console.log("af this.refName:" + this.refName) ;

    //下側のIDに付加
    this.refNameRep += idAddition;

    //カレンダーの最大値と最小値を取得
    this.minDate = this.propMinDate;
    this.maxDate = this.propMaxDate;

    {
      //本日から1年後(1年後の昨日まで)指定があった場合(または、min,maxの指定がなかった場合を含む)
      //日付の最大値・最小値の設定
      //最小値は、本日
      const today = new Date();
      this.minDate = `${today.getFullYear()}-${`0${today.getMonth() + 1}`.slice(
        -2
      )}-${`0${today.getDate()}`.slice(-2)}`;
      //console.log("this.minDate:"+ this.minDate) ;

      //最大値は1年後(1年後の今日の前日まで)
      today.setFullYear(today.getFullYear() + 1); //1年進める
      today.setDate(today.getDate() - 1); //1日減らす
      this.maxDate = `${today.getFullYear()}-${`0${today.getMonth() + 1}`.slice(
        -2
      )}-${`0${today.getDate()}`.slice(-2)}`;
      //console.log("this.maxDate:"+ this.maxDate) ;
    }

    if (!this.propSetMinMaxFromTodayTo1Year) {
      if (
        undefined === this.propMinDate ||
        null === this.propMinDate ||
        0 === this.propMinDate.length
      ) {
        this.minDate = null;
      }
    }

    // this.$nextTick(() => {
    //   //Dom更新待ちで処理します
    //   //サイズの設定
    //   console.log(`this.refName: ${this.refName}`);
    //   const elem = this.$refs[this.refName];

    //   console.log(`elem:${elem}`);

    //   let tmpSize;

    //   console.log(`this.propWidth:${this.propWidth}`);
    //   tmpSize = null !== this.propWidth ? this.propWidth : 150;
    //   //幅の設定
    //   elem.style.width = `${tmpSize}px`;
    //   console.log(`this.propHeight:${this.propHeight}`);
    //   tmpSize = null !== this.propHeight ? this.propHeight : 30;
    //   //高さの設定
    //   elem.style.height = `${tmpSize}px`;

    //   //位置合わせ
    //   this.$nextTick(() => {
    //     //位置合わせは、DOM の更新サイクル後に行う
    //     this.calibrateBox();
    //   });
    // });
  },
  methods: {
    //位置あわせ
    calibrateBox() {
      //console.log("comp calibration start!!") ;

      const standardElem = this.$refs[this.refName];

      const targetElem = this.$refs[this.refNameRap];

      const rect = standardElem.getBoundingClientRect();

      const height = rect.height;
      const width = rect.width;
      const top = 0;
      const left = 0;

      //console.log("comp ref before top:" + top + " left:" + left + " width:" + width + " height:" + height) ;

      targetElem.style.top = `${top}px`;
      targetElem.style.left = `${left}px`;
      targetElem.style.height = `${height - 6}px`;
      targetElem.style.width = `${width - 23}px`;

      /*
      //以下は移動したかの確認のためのコード  ここから----↓↓↓↓↓↓↓
  		rect = targetElem.getBoundingClientRect();

  		height = rect.height;
  		width = rect.width ;
  		top = rect.top;
  		left = rect.left ;
  		//console.log("comp ref after  top:" + top + " left:" + left + " width:" + width + " height:" + height) ;
      //ここまで-------------------------------↑↑↑↑↑↑↑↑↑↑↑
*/
      //console.log("comp calibrated!!") ;
    },
    /**
     *     日付が選択変更された時の処理
     *       下のボックスの日付を整形して上のボックスのvalueにセットします
     * @param e    イベント変数
     */
    changeDate(e) {
      //選択された日付を取得
      const selectedDateStr = e.target.value;

      //日付の整形
      const outStr = this.buildDispDate(selectedDateStr);

      //console.log("outStr:" + outStr) ;

      //表示先にセット
      this.dateValueDisp = outStr;

      //選択値を親に送る
      this.$emit("getDateValue", selectedDateStr);
    },
    /**
     *   表示データ組み立て処理
     *      yyyy年m月d日(曜日)
     * @param targetDate  入力日付
     */
    buildDispDate(targetDate) {
      //const selectedDate = new Date(targetDate);
      const selectedDate = moment(targetDate);

      //console.log("selectedDate:" + selectedDate) ;

      //年、月、日、曜日を取得
      //const year = selectedDate.getFullYear();
      //const month = selectedDate.getMonth() + 1;
      //const day = selectedDate.getDate();
      //const weekday = selectedDate.getDay();
      const year = selectedDate.year();
      const month = selectedDate.month() + 1;
      const day = selectedDate.date();
      const weekday = selectedDate.day();

      //曜日を日本語化
      const weekdayStr = "日月火水木金土".charAt(weekday);

      //出力の組み立て yyyy年m月d日(曜日)
      const outStr = `${year}年${month}月${day}日(${weekdayStr})`;

      return outStr;
    }
  }
};
</script>

/** * スタイル定義 */
<style scoped>
/* 開始日・終了日inputタブ */
.calender-input {
  font-size: 15px;
  width: 164px;
}

input::-webkit-calendar-picker-indicator {
  display: none;
}
</style>
