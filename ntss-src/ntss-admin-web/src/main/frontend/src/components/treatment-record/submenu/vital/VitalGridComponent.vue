/**
* グリッドコンポーネント
*/
<template>
  <div>
    <div class="scroll-table">
      <table class="treatment-record-list vital-grid">
        <thead>
        <!-- add FNSI-改修内容 新規ボタン追加 房 start -->
        <!-- mod redmine4094修正 房 start -->
        <tr>
          <td class="header-component">
            <div>
              <!-- 画面スタイル(ボタン)対応 姜 start -->
              <!-- <v-ons-button class="button toolbar-btn" :disabled="!isShared" style="float: left;" @click="addRow()">新規</v-ons-button> -->
              <!-- redmine4783 修正 姜 mod start -->
              <!-- <v-ons-button class="button toolbar-btn btn3-normal" :disabled="!isShared" style="float: left;" @click="addRow()">新規</v-ons-button>-->
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
              <v-ons-button class="button toolbar-btn btn3-normal" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" style="float: left;" @click="addRow()">追加</v-ons-button>
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
              <!-- redmine4783 修正 姜 mod start -->
              <!-- 画面スタイル(ボタン)対応 姜 end -->
            </div>
          </td>
          <td class="header-component" :colspan="displayVitalItem.length + 3"></td>
        </tr>
        <!-- add FNSI-改修内容 新規ボタン追加 房 end -->
        <tr>
          <th class="ntss-list-header-th-sticky header-component-th" @click="sort">日時{{ sortMarker }}</th>
          <th class="ntss-list-header-th-sticky header-component-th">前血圧<br>後血圧</th>
          <!-- 表示項目 -->
          <th v-for="(column, index) in displayVitalItem"
              :key="index"
              class="ntss-list-header-th-sticky header-component-th">
            <label>{{ column.shortName }}</label>
            <br>
            <label v-if="column.unit">[{{ column.unit }}]</label>
          </th>
          <th class="ntss-list-header-th-sticky header-component-th">更新者</th>
          <th class="ntss-list-header-th-sticky header-component-th"></th>
        </tr>
        <!-- mod redmine4094修正 房 end -->
        </thead>
        <tbody>
        <tr v-for="(e, index) in vitalData" :key="index" :class="['ntss-list-body-tr', e.isNew ? 'added-item' : '', e.isDel ? 'deleted-item' : '']">
          <td class="ntss-list-body-td">
            <div class="flex-align-center">
              <!--add 共有設定の追加 周雨晴  2020/09/22  start -->
              <!-- mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start -->
             <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
              <com-time-input
                class="time-input"
                :classes="'time-input-required ' + isEditClass(e.occurTime, getTime(getJstDate(initData[index].initialData.occurDate)))"
                input-id="occur-time"
                v-model="e.occurTime"
                @input="checkModified(e); dateInit(index)"
                @focus="onFocusOccurTime(index)"
                :index="index"
                :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
                ref="timeInputComponent"
              />
              <!-- mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end -->
              <!--add 共有設定の追加 周雨晴  2020/09/22  end -->
              <!--add 共有設定の追加 周雨晴  2020/09/22  start -->
              <common-calendar :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" v-model="e.occurDateCalendar" @input="checkModified(e)"/>
              <!--add 共有設定の追加 周雨晴  2020/09/22  end -->
             <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
            </div>
          </td>
          <td class="ntss-list-body-td">
            <!--add 共有設定の追加 周雨晴  2020/09/22  start -->
            <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
            <v-ons-select
              class="selectbox"
              :class="isEditSelectClass(e.bpClass, getInitValue(e, initData[index].bpClass, 'bpClass'))"
              input-id="bp-class"
              v-model="e.bpClass"
              name="bp-class"
              @change="onChangeBpClass(e); checkModified(e)"
              :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
            >
           <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
              <!--add 共有設定の追加 周雨晴  2020/09/22  end -->
              <option v-for="item in bpClassList" :key="item.cd" :value="item.cd">{{ item.text }}</option>
            </v-ons-select>
          </td>
          <!-- バイタルデータ -->
          <td v-for="(column, index2) in displayVitalItem" :key="index2" class="ntss-list-body-td">
            <!-- 数値 -->
            <!--add 共有設定の追加 周雨晴  2020/09/22  start -->
            <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
            <monitor-number-input
              v-if="column.isNumber"
              v-model="e.monitorData[column.dataIndex]"
              :step="column.step"
              :min="column.min"
              :max="column.max"
              @blur="e.reCalcBpAve(); checkModified(e)"
              :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
              :initValue="getInitValue(e, initData[index].monitorData[column.dataIndex])"
              :monitorUniqueId="index + '_' + index2"
            />
            <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
            <!--add 共有設定の追加 周雨晴  2020/09/22  end -->
            <!-- 選択肢 -->
            <!--add 共有設定の追加 周雨晴  2020/09/22  start -->
            <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
            <v-ons-select
              v-else-if="column.selectItem"
              class="selectbox"
              :class="isEditSelectClass(e.monitorData[column.dataIndex], getInitValue(e, initData[index].monitorData[column.dataIndex]))"
              v-model="e.monitorData[column.dataIndex]"
              @change="checkModified(e)"
              :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" >
            <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
              <!--add 共有設定の追加 周雨晴  2020/09/22  end -->
              <option
                v-for="(item, index) in column.selectItem"
                :key="index"
                :value="item.cd"
                :hidden="item.hidden"
                :disabled="item.hidden"
              >{{ item.text }}</option>
            </v-ons-select>
            <!-- 文字列（選択肢無） -->
            <!--add 共有設定の追加 周雨晴  2020/09/22  start -->
            <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
            <custom-simple-textarea-b v-else
              v-model="e.monitorData[column.dataIndex]"
              @blur="checkModified(e)"
              :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
              class="vital-grid-textarea"
              autoWidth
              :initValue="getInitValue(e, initData[index].monitorData[column.dataIndex])"
              :isEdit="true"
            />
            <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
            <!--add 共有設定の追加 周雨晴  2020/09/22  end -->
          </td>
          <td class="ntss-list-body-td staff-name-cell">{{ e.updStaffName }}</td>
          <td class="align-center ntss-list-body-td">
            <button class="ntss-btn-outset button-delete" @click="delRow(index)" :disabled=!isShared>
              <v-ons-icon icon="fa-trash"/>
            </button>
          </td>
        </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
  import CommonTimeComponent from "@/components/treatment-record/submenu/common/CommonTimeComponent";
  import MonitorNumberInputComponent from "@/components/treatment-record/submenu/monitor/MonitorNumberInputComponent";
  //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
  // import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
  import { CODES } from "@/constants/TreatmentRecord";
  import CommonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
  import CustomTextareaB from "@/components/common/custom-form-tags/CustomSimpleTextareaTypeB";
  import { mapActions, mapGetters } from "vuex";
  import {
    dateFormat,
    DATE_FORMAT,
    SHORT_TIME_FORMAT
  } from "@/functions/common/DateTimeUtils";
  //add FNSI-改修内容 新規ボタン追加 房 start
  import {
    Vital,
  } from "@/models/treatment-record/vital/Vital";
  //add FNSI-改修内容 新規ボタン追加 房 end
  import { getAuthorized } from "@/functions/common/CommonFunctions";
  //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
  export default {
    //#10359 del 編集権限の動作不正 2024-06-05 卓 start
    // mixins: [UserAuthorityMixin],
    //#10359 del 編集権限の動作不正 2024-06-05 卓 end
    components: {
      "com-time-input": CommonTimeComponent,
      "monitor-number-input": MonitorNumberInputComponent,
      "common-calendar": CommonCalender,
      "custom-simple-textarea-b": CustomTextareaB
    },
    props: {
      value: {
        type: Array,
        default: () => []
      },
      //#10359 del 編集権限の動作不正 2024-06-05 卓 start
      // cds: Array,
      //#10359 del 編集権限の動作不正 2024-06-05 卓 end
      /**
       * バイタルで表示する項目のリスト
       */
      displayVitalItem: Array,
      ordNo: Number,
      //add FNSI修正 NKK3827 房 start
      treatEndDate: null,
      //add FNSI修正 NKK3827 房 end
    },
    data() {
      return {
        sortOrder: 1,
        vitalData: [],
        bpClassList: CODES.BP_CLASS,
        // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
        initData: [],
        // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
      };
    },
    computed: {
      ...mapGetters("treatment-record/common", ["getDialysisState", "getRstEditionDate"]),
      ...mapGetters("treatment-record/common", [
        "getOrd",
        "getSharedFacilityCd"
      ]),

      ...mapGetters("user", ["getFacilityCd"]),

      sortMarker() {
        return this.sortOrder > 0 ? "▲" : "▼";
      },
      // add 共有設定の追加 周雨晴  2020/09/22  start
      isShared() {
        return this.getFacilityCd === this.getSharedFacilityCd;
      }
      // add 共有設定の追加 周雨晴  2020/09/22  end
    },
    methods: {
      ...mapActions("treatment-record/weight", ["getTreatmentRecordWeight"]),
      //#10359 add 編集権限の動作不正 2024-06-05 卓 start
      getItemAuthorized(pageCd, itemCd) {
        return getAuthorized(pageCd, itemCd);
      },
      //#10359 add 編集権限の動作不正 2024-06-05 卓 end
      /**
       * 一覧をソートする.
       */
      sort() {
        this.sortOrder = this.sortOrder * -1;
        const newRecords = this.vitalData.filter(e => e.isNew);
        const sortedData = this.vitalData
          .filter(e => !e.isNew)
          .sort((a, b) => (a.occurDate - b.occurDate) * this.sortOrder);
        sortedData.unshift(...newRecords);
        this.vitalData = sortedData;
        // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
        const newInitRecords = this.initData.filter(e => e.isNew);
        const sortedInitData = this.initData
          .filter(e => !e.isNew)
          .sort((a, b) => (a.occurDate - b.occurDate) * this.sortOrder);
        sortedInitData.unshift(...newInitRecords);
        this.initData = sortedInitData;
        // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
        
        // 親コンポーネントにsort後のデータを通知
        this.$emit("updateVitalData", this.vitalData);
      },
      /**
       * 編集されたことを通知する.
       */
      checkModified(model) {
        this.$nextTick(() => {
          // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
          // if (model.isModified()) {
          // this.$emit("modifiedValue");
          this.$emit("modifiedValue", model.isModified());
          // }
          // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
        });
      },
      /**
       * 血圧区分が変更された.
       */
      onChangeBpClass(model) {
        if (!model.isBpNone) {
          // 前血圧/後血圧に変更された場合は削除チェックボックスを外す
          model.selected = false;

          // 既存の前血圧/後血圧をなしに変更する
          this.vitalData
            .filter(e => e !== model && e.bpClass === model.bpClass)
            .forEach(e => e.bpClass = CODES.BP_CLASS.NONE.cd);
        }
      },

      onChangeDateCalendar(model) {
        this.vitalData
          .filter(e => e !== model && e.occurDateCalendar === model.occurDateCalendar)
      },
      //add FNSI-改修内容 新規ボタン追加 房 start
      addRow() {
        this.vitalData.push(new Vital());
        // デフォルト日時設定
        this.setDefaultDate(this.vitalData[this.vitalData.length - 1], true);
        // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
        this.initData.push(new Vital());
        // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
      },
      delRow(targetIndex) {
        if (this.vitalData[targetIndex].isNew) {
          // 新規追加行は物理削除
          this.vitalData.splice(targetIndex, 1);
          this.initData.splice(targetIndex, 1);
          this.$emit("modifiedValue", JSON.stringify( this.vitalData) !== JSON.stringify( this.initData));
        } else {
          // 登録済みデータは論理削除
          this.vitalData[targetIndex].isDel = !this.vitalData[targetIndex].isDel;
          this.initData[targetIndex].isDel = !this.initData[targetIndex].isDel;
        }
      },
      //add FNSI-改修内容 新規ボタン追加 房 end
      isEditClass(value, initValue){
        if (value === initValue) {
          return "";
        }
        return "custom-input-edited";
      },
      // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
      isEditSelectClass(value, initValue){
        let isChange = true;
        if ((value === initValue) || (!value && !initValue)) {
          isChange = false
        }
        return {
          "custom-select-edited-box": isChange
        }
      },
      initTimeComponent(){
        if (this.$refs["timeInputComponent"].length > 0) {
          for (let i = 0; i < this.$refs["timeInputComponent"].length; i++) {
            this.$refs["timeInputComponent"][i].indexNumInit();
          }
        }
      },
      // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
      /** 
      * 実施日時未入力の場合にデフォルト値を設定
      * @param setTimeFlg デフォルト時刻をセットするかのフラグ
      */
      setDefaultDate(record, setTimeFlg) {
        if (!record.occurTime) {
          record.occurDateCalendar = dateFormat.format(this.getDefaultDate(), DATE_FORMAT);
          record.occurTime = setTimeFlg ? this.getTime(this.getDefaultDate()) : null;
        }
      },
      /** 
      * 発生日時をクリア（×ボタン、手入力クリア）した際、カレンダー表示した際のデフォルト日付を変更するためデフォルト値を日付（非表示）に設定
      * ※時刻はクリア状態
      */
      dateInit(index){
        // デフォルト日付を設定
        this.setDefaultDate(this.vitalData[index], false);
      },
      /** 
      * 発生日時 時刻入力フォーカス
      */
      onFocusOccurTime(index){
        // 時刻が空の場合、デフォルト日時を設定
        this.setDefaultDate(this.vitalData[index], true);
      },
      /**
       * UTC文字列をJSTに変換後、Date型に変換して取得
       */
      getJstDate(dateStr) {
        return dateStr ? new Date(dateFormat.utc2Jst(dateStr)) : null;
      },
      /** 
      * 実施状況(投与日時)のデフォルト値を取得
      *   rst_dialysis_state1～5の場合：sysdate
      *   rst_dialysis_state6の場合の場合：実績初版確定日時
      */
      getDefaultDate() {
        let defaultDate = new Date();
        if (+this.getDialysisState === +CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd) {
          // rst_dialysis_state6
          defaultDate =  this.getRstEditionDate ? new Date(this.getRstEditionDate) : new Date();
        }
        return defaultDate;
      },
      /**
       * 時刻を"HH:mm"形式の文字列で取得
       */
      getTime(date) {
        if (!date) {
          return "";
        }
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        return `${hours}:${minutes}`;
      },
      /**
       * 日付以外の項目の初期値取得
       */
      getInitValue(e, initData, field) {
        // 追加行を残して削除した際、追加行の編集前データが編集後データで上書きされるため、追加行の編集前データは常にnullとする
        return !e.isNew ? initData : field === "bpClass" ? CODES.BP_CLASS.NONE.cd : null;
      }
    },
    watch: {
      value() {
        // 初期表示
        let initFlag = false;
        if (this.value.length === 0 || this.value[0].sortOrder != null) {
          // 日時昇順ソートされるのでソート指定を▲に設定
          this.sortOrder = 1;
          if (this.value.length > 0) {
            this.value[0].sortOrder = null; // クリア
          }
          
          // 初期表示の場合のみ編集前データを設定する
          // 初期表示：メニューから遷移、実績切替時、パンくずリスト押下、保存、削除 ※行追加、ソートは除く
          initFlag = true;
        }
      
        this.vitalData = this.value;
        if (initFlag) {
          // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
          this.initData = JSON.parse(JSON.stringify(this.vitalData));
          this.initData.forEach(el=>el["occurDate"] = new Date(el["occurDate"]))
          // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
        }
        // add FNSI-受信した値が-32768（8000h）の場合は、空欄を表示する 徐 start
        if (this.vitalData) {
          for (let i = 0; i < this.vitalData.length; i++) {
            if (this.vitalData[i].monitorData) {
              if (this.vitalData[i].monitorData[90] == '-32768') {
                this.vitalData[i].monitorData[90] = null;
              }
              if (this.vitalData[i].monitorData[91] == '-32768') {
                this.vitalData[i].monitorData[91] = null;
              }
              if (this.vitalData[i].monitorData[92] == '-32768') {
                this.vitalData[i].monitorData[92] = null;
              }
              if (this.vitalData[i].monitorData[93] == '-32768') {
                this.vitalData[i].monitorData[93] = null;
              }
              if (this.vitalData[i].monitorData[94] == '-32768') {
                this.vitalData[i].monitorData[94] = null;
              }
            }
          }
        }
        // add FNSI-受信した値が-32768（8000h）の場合は、空欄を表示する 徐 end
      }
    },
    created() {
      this.authorityCds = this.cds;
    },
    beforeDestroy() {
      // dataの初期化
      Object.assign(this.$data, this.$options.data());
    }
  };
</script>

<style scoped>
  .scroll-table {
    width: 1px;
  }
  .selectbox >>> select {
    width: fit-content;
  }
  .vital-grid >>> .num-value ons-input {
    width: 4em;
  }
  .ntss-list-header-th-sticky {
    z-index: 1;
  }
  .ntss-list-body-td >>> .select-input {
    border: solid 1px var(--treatment-record-select-border-color);
  }
  .flex-align-center {
    display: flex;
  }
  .align-center {
    text-align: center;
  }
  .input-date >>> .custom-input-date {
    width: auto;
  }
  .input-date {
    margin-top: 5%;
  }
  .textStyle {
    color: #00b050;
  }
  .toolbar-btn {
    font-size: 1.0em;
    padding: 0.2em 1em 0em 1em;
    line-height: 2em;
    width: auto;
    margin: 0.1em;
  }
  .header-component {
    z-index: 1;
    top: 0;
    position: sticky;
    background-color: var(--ntss-list-background-color);
  }
  .header-component-th {
    top: 2.35em;
  }
  .vital-grid-textarea >>> textarea {
    border-color: unset;
    border-style: inset;
    min-width: 100%;
  }
  /* add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start */
  .custom-select-edited-box >>> select {
    border: 2px green solid !important;
    outline: 0;
    border-radius: 5px;
  }
  /* add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end */
  .staff-name-cell {
    white-space: nowrap;
  }
  /* 追加項目 */
  .added-item {
    background-color: #ccffcc !important;
  }
  /* 削除項目 */
  .deleted-item {
    background-color: rgba(255, 0, 0, 0.5);
  }
  /* 削除ボタン */
  .button-delete {
    max-width: 25px;
  }
</style>
