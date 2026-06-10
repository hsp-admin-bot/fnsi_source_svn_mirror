/**
 * デフォルト設定タブ - 検査結果設定のコンポーネント
 */
<template>
  <v-ons-list style="height: auto;" class="record-accordion">
    <v-ons-list-item modifier="nodivider" class="ntss-theme-screen" expandable :expanded.sync="isExpanded">
      <div class="top"><!-- OnsenUI挙動制御：自動挿入されるラッパー用divを予め書いておき適用されるスタイルを制御 -->
        <div class="center card-header color-header">
          {{ funcName }}
        </div>
        <div class="right"><!-- OnsenUI挙動制御：空にすることで矢印を抑制 --></div>
      </div>
      <div class="expandable-content card-contents">
        <table>
          <tbody>
            <tr>
              <td class="default-setting-content-title"></td>
              <td class="default-setting-content">
                <div>
                  <input id="show-result-display" type="radio" class="identification" name="viewDayType" value="1" @click="changeDayType(1);" :checked="isShow"/>
                  <label for="show-result-display" class="label first-of-type">最新結果日</label>
                  <input id="show-exam-display" type="radio" class="identification" name="viewDayType" value="2" @click="changeDayType(2);" :checked="!isShow"/>
                  <label for="show-exam-display" class="label last-of-type">最新検査日</label>
                </div>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">検査日開始</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispTermStart"
                  v-model="examDateSt"
                  data-text-field="title"
                  data-value-field="value"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">検査日終了</label>
              </td>
              <td class="default-setting-content">
                <kendo-dropdownlist
                  :data-source="lstDispTermEnd"
                  v-model="examDateEd"
                  data-text-field="title"
                  data-value-field="value"
                />
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <!--mod FNSI-改修内容4214 任 start-->
                <!--<label class="default-setting-content-label">患者ID列表示</label>-->
                <label id="pc-show-exam-record" class="default-setting-content-label white-space-nowrap">患者ID列表示</label>
                <label id="phone-show-exam-record" class="default-setting-content-label white-space-nowrap">患者ID列表示</label>
                <!--mod FNSI-改修内容4214 任 end-->
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="viewPatId"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">検査日列表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="viewExamDate"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">検査セット</label>
              </td>
              <td class="default-setting-content">
              <v-ons-select class="select-width" v-model="examSetCd">
                <option :value="-1"></option>
                <option v-for="(option, index) in examSetNameList" :key="index" :value="option.examSetCd">
                  {{ option.examSetName }}
                </option>
              </v-ons-select>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label white-space-nowrap">異常値のみ表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="outRange"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title">
                <label class="default-setting-content-label">正常範囲列表示</label>
              </td>
              <td class="default-setting-content">
                <v-ons-switch v-model="normalRange"></v-ons-switch>
              </td>
            </tr>
            <tr>
              <td class="default-setting-content-title-last-row">
                <label class="default-setting-content-label">単位列表示</label>
              </td>
              <td class="default-setting-content-last-row">
                <v-ons-switch v-model="unitDisplay"></v-ons-switch>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </v-ons-list-item>
  </v-ons-list>
</template>

<script>
import {mapGetters, mapActions} from "vuex";
/*add FNSI-改修内容4214 任 start*/
import $ from "jquery";
/*add FNSI-改修内容4214 任 end*/
import {DATE_CHOICES, EXAM_RECORD} from "@/constants/defaultSettingConstants";
import {deepCopy} from "@/functions/common/CommonFunctions";
import {sendRequestGetMstExamSetList, sendRequestGetMstExamSetSort} from "@/apis/exam-Record";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
import { makeDefaultCondition } from "@/functions/exam-record/ExamRecordFunctions";
//add FNSI-5687 劉全航 start
import { EventBus } from "@/eventBus.js";
//add FNSI-5687 劉全航 end

export default {
  components: {
  },
  props: {
    // カード開閉初期状態
    defaultExpanded: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      // 対象の画面名
      funcName:"検査結果",
      // データ初期値
      initialValue: {},
      // 編集する検査結果設定レコード
      editRecord: {},
      // 検査セット一覧
      examSetNameList: [],
      // 検査日開始・選択肢
      lstDispTermStart: [
        DATE_CHOICES.TODAY,
        DATE_CHOICES.BEFORE_ONE_MONTH,
        DATE_CHOICES.BEFORE_THREE_MONTH,
        DATE_CHOICES.BEFORE_SIX_MONTH,
        DATE_CHOICES.BEFORE_ONE_YEAR,
        DATE_CHOICES.BEFORE_THREE_YEAR
      ],
      // 検査日終了・選択肢
      lstDispTermEnd: [
        DATE_CHOICES.TODAY,
        DATE_CHOICES.AFTER_ONE_MONTH,
        DATE_CHOICES.AFTER_THREE_MONTH,
        DATE_CHOICES.AFTER_SIX_MONTH,
        DATE_CHOICES.AFTER_ONE_YEAR,
        DATE_CHOICES.AFTER_THREE_YEAR
      ],
      // カード開閉状態(初期値をfalseにすることでOnsenUI内部挙動との競合を抑制)
      isExpanded: false,
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", {
      userInfo: "getStateUserAccountInfo",
      getDefaultSetting: "getDefaultSetting"
    }),

    // 検査日開始
    examDateSt: {
      get() {
        return this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_START_DATE];
      },
      set(value) {
        this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_START_DATE] = value;
      }
    },
    // 検査日終了
    examDateEd: {
      get() {
        return this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_END_DATE];
      },
      set(value) {
        this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_END_DATE] = value;
      }
    },
    // 患者ID列表示
    viewPatId: {
      get() {
        return this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_PAT_ID];
      },
      set(value) {
        this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_PAT_ID] = value;
      }
    },
    // 検査日列表示
    viewExamDate: {
      get() {
        return this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_EXAM_DATE];
      },
      set(value) {
        this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_EXAM_DATE] = value;
      }
    },
    // 検査セット
    examSetCd: {
      get() {
        return this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_SET_CD];
      },
      set(value) {
        this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_SET_CD] = value;
      }
    },
    // 異常値のみ表示
    outRange: {
      get() {
        return this.editRecord[EXAM_RECORD.KEY_NAME_OUT_RANGE];
      },
      set(value) {
        this.editRecord[EXAM_RECORD.KEY_NAME_OUT_RANGE] = value;
      }
    },
    // 正常範囲列表示
    normalRange: {
      get() {
        return this.editRecord[EXAM_RECORD.KEY_NAME_NORMAL_RANGE];
      },
      set(value) {
        this.editRecord[EXAM_RECORD.KEY_NAME_NORMAL_RANGE] = value;
      }
    },
    // 単位列表示
    unitDisplay: {
      get() {
        return this.editRecord[EXAM_RECORD.KEY_NAME_UNIT_DISPLAY];
      },
      set(value) {
        this.editRecord[EXAM_RECORD.KEY_NAME_UNIT_DISPLAY] = value;
      }
    },
    // 表示条件
    isShow() {
      return this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_DAY_TYPE] === 1 ? true : false;
    },
  },
  methods: {
    ...mapActions(
      "loading-screen", ["startLoadingScreen","finishLoadingScreen"]
    ),
    getSaveData() {
      let rtnData = {
        name: EXAM_RECORD.KEY_NAME,
        data: {}
      };
      rtnData.data[EXAM_RECORD.KEY_NAME_VIEW_DAY_TYPE] = this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_DAY_TYPE];
      rtnData.data[EXAM_RECORD.KEY_NAME_EXAM_START_DATE] = this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_START_DATE];
      rtnData.data[EXAM_RECORD.KEY_NAME_EXAM_END_DATE] = this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_END_DATE];
      rtnData.data[EXAM_RECORD.KEY_NAME_VIEW_PAT_ID] = this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_PAT_ID];
      rtnData.data[EXAM_RECORD.KEY_NAME_VIEW_EXAM_DATE] = this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_EXAM_DATE];
      rtnData.data[EXAM_RECORD.KEY_NAME_EXAM_SET_CD] = this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_SET_CD];
      rtnData.data[EXAM_RECORD.KEY_NAME_OUT_RANGE] = this.editRecord[EXAM_RECORD.KEY_NAME_OUT_RANGE];
      rtnData.data[EXAM_RECORD.KEY_NAME_NORMAL_RANGE] = this.editRecord[EXAM_RECORD.KEY_NAME_NORMAL_RANGE];
      rtnData.data[EXAM_RECORD.KEY_NAME_UNIT_DISPLAY] = this.editRecord[EXAM_RECORD.KEY_NAME_UNIT_DISPLAY];
      return rtnData;
    },
    // 表示条件の切替処理
    changeDayType(dayType) {
      this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_DAY_TYPE] = dayType;
    },
  },
  watch: {
    //add FNSI-5687 劉全航 start
    editRecord: {
      handler(newValue, oldValue){
        var keySet = Object.keys(this.initialValue);
        for(let key of keySet){
          let initialValue = this.initialValue[key];
          let editValue = newValue[key];
          if(JSON.stringify(initialValue) !== JSON.stringify(editValue)){
            EventBus.$emit("isChanged", {componentName: "examRecord", value: true});
            return;
          }
        }
        EventBus.$emit("isChanged", {componentName: "examRecord", value: false});
      },
      deep: true
    },
    //add FNSI-5687 劉全航 end
  },
  async created() {
    // 共通ローダー表示開始
    this.startLoadingScreen();
    // 検査セットデータ生成処理：
    this.examSetNameList = [];
    const mstExamSetList = await sendRequestGetMstExamSetList(this.facilityCd);

    // 検査セットソート順データセット処理
    let nameList = mstExamSetList.data;
    let sortList = [];
    let sortNameList = [];
    let sort = null;
    // 更新画面生成時：患者検査結果テーブルより生成
    try{
      sort = await sendRequestGetMstExamSetSort(this.facilityCd);
    }catch(e){
      //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
      getErrorMessage('examRecordSettingCard.vue', 'created', '検査項目セット取得処理エラー');
      //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
      console.error(e);
      throw new Error("検査項目セット取得処理エラー");
    }
    //検査セット ソート処理
    sort.data.forEach(e => sortList = sortList.concat(e.orderSettings.items));

    // itemキーにあってSortキーにないコードを末尾に順につける
    for(let itemkey = 0; itemkey < nameList.length; itemkey++){
      let itemFlg = false;
      for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
        if (sortList[sortkey].code == nameList[itemkey].examSetCd){
          itemFlg =true;
        }
      }
      if(!itemFlg){
        //Sortデータにいない項目はソートリスト末尾にIDをセット
        let pushData = {code:Number(nameList[itemkey].examSetCd), name:"追加項目名"}
        sortList.push(pushData);
      }
    }
    //検査セットソート実行
    for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
      for(let itemkey = 0; itemkey < nameList.length; itemkey++){
        if (sortList[sortkey].code === nameList[itemkey].examSetCd) {
          sortNameList.splice(sortkey,0,nameList[itemkey]);
        }
      }
    }
    this.examSetNameList = sortNameList;

    // 初期値未設定の場合のデフォルト値
    const initialDefault = makeDefaultCondition(true);
    this.initialValue[EXAM_RECORD.KEY_NAME_VIEW_DAY_TYPE] = initialDefault.viewDayType;
    this.initialValue[EXAM_RECORD.KEY_NAME_EXAM_START_DATE] = initialDefault.examDateSt;
    this.initialValue[EXAM_RECORD.KEY_NAME_EXAM_END_DATE] = initialDefault.examDateEd;
    this.initialValue[EXAM_RECORD.KEY_NAME_VIEW_PAT_ID] = initialDefault.viewPatId;
    this.initialValue[EXAM_RECORD.KEY_NAME_VIEW_EXAM_DATE] = initialDefault.viewExamDate;
    this.initialValue[EXAM_RECORD.KEY_NAME_EXAM_SET_CD] = initialDefault.examSetCd;
    this.initialValue[EXAM_RECORD.KEY_NAME_OUT_RANGE] = initialDefault.outRange;
    this.initialValue[EXAM_RECORD.KEY_NAME_NORMAL_RANGE] = initialDefault.normalRange;
    this.initialValue[EXAM_RECORD.KEY_NAME_UNIT_DISPLAY] = initialDefault.unitDisplay;

    this.$nextTick(() => {
      this.editRecord = deepCopy(this.getDefaultSetting[EXAM_RECORD.KEY_NAME]);
      // データが空の場合は初期値を適用する
      if (!this.editRecord || Object.keys(this.editRecord).length === 0) {
        this.editRecord = deepCopy(this.initialValue);
      } else {
        if (this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_DAY_TYPE] == null) {
          this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_DAY_TYPE] = this.initialValue[EXAM_RECORD.KEY_NAME_VIEW_DAY_TYPE];
        }
        if (this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_START_DATE] == null) {
          this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_START_DATE] = this.initialValue[EXAM_RECORD.KEY_NAME_EXAM_START_DATE];
        }
        if (this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_END_DATE] == null) {
          this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_END_DATE] = this.initialValue[EXAM_RECORD.KEY_NAME_EXAM_END_DATE];
        }
        if (this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_PAT_ID] == null) {
          this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_PAT_ID] = this.initialValue[EXAM_RECORD.KEY_NAME_VIEW_PAT_ID];
        }
        if (this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_EXAM_DATE] == null) {
          this.editRecord[EXAM_RECORD.KEY_NAME_VIEW_EXAM_DATE] = this.initialValue[EXAM_RECORD.KEY_NAME_VIEW_EXAM_DATE];
        }
        if (this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_SET_CD] == null) {
          this.editRecord[EXAM_RECORD.KEY_NAME_EXAM_SET_CD] = this.initialValue[EXAM_RECORD.KEY_NAME_EXAM_SET_CD];
        }
        if (this.editRecord[EXAM_RECORD.KEY_NAME_OUT_RANGE] == null) {
          this.editRecord[EXAM_RECORD.KEY_NAME_OUT_RANGE] = this.initialValue[EXAM_RECORD.KEY_NAME_OUT_RANGE];
        }
        if (this.editRecord[EXAM_RECORD.KEY_NAME_NORMAL_RANGE] == null) {
          this.editRecord[EXAM_RECORD.KEY_NAME_NORMAL_RANGE] = this.initialValue[EXAM_RECORD.KEY_NAME_NORMAL_RANGE];
        }
        if (this.editRecord[EXAM_RECORD.KEY_NAME_UNIT_DISPLAY] == null) {
          this.editRecord[EXAM_RECORD.KEY_NAME_UNIT_DISPLAY] = this.initialValue[EXAM_RECORD.KEY_NAME_UNIT_DISPLAY];
        }
        this.initialValue = deepCopy(this.editRecord);
      }
      /*add FNSI-改修内容4214 任 start*/
      if($("#phone-show-exam-record").css("display") === "inline"){
        document.getElementById("phone-show-exam-record").innerText =  document.getElementById("phone-show-exam-record").innerText + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0';
      }
      /*add FNSI-改修内容4214 任 end*/
      // 共通ローダー表示終了
      this.finishLoadingScreen();
      this.isExpanded = this.defaultExpanded;
    });
  },
  mounted() {
  }
};
</script>

<style scoped>
.select-width {
  min-width: 140px;
  width: 12.4em;
}
/*add FNSI-改修内容4214 任 start*/
@media (max-width: 500px){
  #pc-show-exam-record{display:none;}
}
@media (min-width: 501px){
  #phone-show-exam-record{display:none;}
}
/*add FNSI-改修内容4214 任 end*/

input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  width: 6em; /* ボックスの横幅を指定する */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
}
.first-of-type {
  border-radius: 10px 0 0 10px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
}
</style>
