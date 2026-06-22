/**
 * グリッドコンポーネント
 */
<template>
  <div class="monitor-grid-container">
    <div class="scroll-table">
      <table class="treatment-record-list monitor-grid">
        <thead>
          <!-- add FNSI-改修内容 新規ボタン追加 房 start -->
          <!-- mod redmine4094修正 房 start -->
          <tr>
            <td class="header-component">
              <div>
                <!-- 画面スタイル(ボタン)対応 姜 start -->
                <!-- <v-ons-button class="button toolbar-btn" :disabled="!isShared" style="float: left;" @click="addRow()">新規</v-ons-button> -->
                <!-- redmine4783 修正 姜 mod start -->
                <!-- <v-ons-button class="button toolbar-btn btn3-normal" :disabled="!isShared" style="float: left;" @click="addRow()">新規</v-ons-button> -->
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                <v-ons-button class="button toolbar-btn btn3-normal" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" style="float: left;" @click="addRow()">追加</v-ons-button>
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                <!-- redmine4783 修正 姜 mod end -->
                <!-- 画面スタイル(ボタン)対応 姜 end -->
              </div>
            </td>
            <td class="header-component hide-sticky-border" :colspan="isDispPartFormat ? displayMonitorItem.length + 2 : displayAllMonitorItem.length + 3">
              <div class="monitor-selection-area">
                <span v-for="item in monitorDispFormatList" :key="item.cd" class="monitor-disp-format">
                  <v-ons-radio
                    name="monitor-disp-format"
                    :input-id="'monitor-disp-format-' + item.cd"
                    :value="item.cd"
                    v-model="monitorDispFormatIni"
                    model-event="change"
                    modifier="round"
                    data-non-authorize="true"
                  />
                  <label :for="'monitor-disp-format-' + item.cd">{{ item.text }}</label>
                </span>
              </div>
            </td>
          </tr>
          <!-- add FNSI-改修内容 新規ボタン追加 房 end -->
          <tr>
            <th class="ntss-list-header-th-sticky header-component-th" @click="sort">日時{{ sortMarker }}</th>
            <th
              v-for="(column, index) in isDispPartFormat ? displayMonitorItem : displayAllMonitorItem"
              :key="index"
              class="ntss-list-header-th-sticky header-component-th"
            >
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
          <tr v-for="(e, index) in monitorData" :key="index" :class="['ntss-list-body-tr', e.isNew ? 'added-item' : '', e.isDel ? 'deleted-item' : '']">
            <!-- 時刻 -->
            <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 start -->
            <td class="ntss-list-body-td">
              <div class="flex-align-center">
                <!-- mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start -->
                <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
                <!-- <com-time-input
                  class="time-input"
                  input-id="occur-time"
                  v-model="e.occurTime"
                  @input="checkModified(e)"
                  :disabled="!isShared"
                  ref="timeInputComponent"
                /> -->
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
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
                <!-- mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end -->
              <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 end -->
              <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 start -->
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                <common-calendar :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" v-model="e.occurDateString" @input="checkModified(e)"/>
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
              <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 end -->
              </div>
            </td>
            <!-- モニタデータ -->
            <!-- mod 8453 ljx start -->
<!--            <td v-for="(column, index2) in isDispPartFormat ? displayMonitorItem : displayAllMonitorItem"
                :key="index2" class="ntss-list-body-td">
              &lt;!&ndash; 時間(時分) &ndash;&gt;
              <com-time-input
                v-if="column.dataType == 3 && column.unit == '時分'"
                :value="convertToTimeFormat(e.monitorData[column.dataIndex])"
                @input="checkModified(e); inputTimeData($event, e.monitorData, column.dataIndex, column.min, column.max);"
                :disabled="!isShared"
              />
              &lt;!&ndash; 数値 &ndash;&gt;
              &lt;!&ndash; add FNSI-共有設定の追加 周雨晴 2020/09/22 start &ndash;&gt;
              <monitor-number-input
                v-else-if="column.isNumber"
                v-model="e.monitorData[column.dataIndex]"
                :step="column.step"
                :min="column.min"
                :max="column.max"
                @blur="checkModified(e)"
                :disabled="!isShared"
                :initValue="initData[index].monitorData[column.dataIndex]"
                :monitorUniqueId="index + '_' + index2"
              />
              &lt;!&ndash; add FNSI-共有設定の追加 周雨晴 2020/09/22 end &ndash;&gt;
              &lt;!&ndash; 選択肢 &ndash;&gt;
              &lt;!&ndash; add FNSI-共有設定の追加 周雨晴 2020/09/22 start &ndash;&gt;
              <v-ons-select
                v-else-if="column.selectItem"
                class="selectbox"
                v-model="e.monitorData[column.dataIndex]"
                @change="checkModified(e)"
                :disabled="!isShared"
                :class="isEditClass(e.monitorData[column.dataIndex], initData[index].monitorData[column.dataIndex])">
                &lt;!&ndash; add FNSI-共有設定の追加 周雨晴 2020/09/22 end &ndash;&gt;
                &lt;!&ndash; mod FNSI改修内容 治療モードなど不明改修 房 start &ndash;&gt;
                <option
                  v-for="(item, index) in testMethod(column, e)"
                  :key="index"
                  :value="item.cd"
                  :hidden="item.hidden"
                  :disabled="item.hidden"
                >{{ item.text }}</option>
                &lt;!&ndash; mod FNSI改修内容 治療モードなど不明改修 房 end &ndash;&gt;
              </v-ons-select>
              &lt;!&ndash; 文字列（選択肢無） &ndash;&gt;
              <custom-simple-textarea-b v-else
                                        v-model="e.monitorData[column.dataIndex]"
                                        @blur="checkModified(e)"
                                        :disabled="!isShared"
                                        class="monitor-grid-textarea"
                                        :initValue="initData[index].monitorData[column.dataIndex]"
                                        :isEdit="true"
              />
            </td>-->
            <td
              v-show="isDispPartFormat"
              v-for="(column, index2) in displayMonitorItem"
              :key="`part${index2}`"
              :monitorUniqueId="index + '_' + index2"
              class="ntss-list-body-td">
              <!-- 時間(時分) -->
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
              <custom-input-time-special
                v-if="column.dataType == 3 && column.unit == '時分'"
                :key="`${isDispPartFormat}-${column.dataIndex}`"
                :value="e.monitorData[column.dataIndex]"
                @input="checkModified(e); inputTimeData($event, e.monitorData, column.dataIndex, column.min, column.max);"
                :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
                :uniqueId="`_part${index}_${index2}`"
                :defaultValue="''"
              />
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
              <!-- 数値 -->
              <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 start -->
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
              <monitor-number-input
                v-else-if="column.isNumber"
                v-model="e.monitorData[column.dataIndex]"
                :step="column.step"
                :min="column.min"
                :max="column.max"
                @blur="checkModified(e)"
                :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
                :initValue="getInitValue(e, initData[index].monitorData[column.dataIndex])"
                :monitorUniqueId="index + '_' + index2"
              />
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
              <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 end -->
              <!-- 選択肢 -->
              <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 start -->
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
              <v-ons-select
                v-else-if="column.selectItem"
                class="selectbox"
                v-model="e.monitorData[column.dataIndex]"
                @change="checkModified(e)"
                :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
                :class="isEditSelectClass(e.monitorData[column.dataIndex], getInitValue(e, initData[index].monitorData[column.dataIndex]))">
                <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
              <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 end -->
                <!-- mod FNSI改修内容 治療モードなど不明改修 房 start -->
                <option
                  v-for="(item, index) in testMethod(column, e)"
                  :key="index"
                  :value="item.cd"
                  :hidden="item.hidden"
                  :disabled="item.hidden"
                >{{ item.text }}</option>
                <!-- mod FNSI改修内容 治療モードなど不明改修 房 end -->
              </v-ons-select>
              <!-- 文字列（選択肢無） -->
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
              <custom-simple-textarea-b v-else
                v-model="e.monitorData[column.dataIndex]"
                @blur="checkModified(e)"
                :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
                class="monitor-grid-textarea"
                autoWidth
                :initValue="getInitValue(e, initData[index].monitorData[column.dataIndex])"
                :isEdit="true"
              />
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
            </td>
            <td
              v-show="!isDispPartFormat"
              v-for="(column, index2) in displayAllMonitorItem"
                :key="`all${index2}`"
                class="ntss-list-body-td">
              <!-- 時間(時分) -->
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
              <custom-input-time-special
                v-if="column.dataType == 3 && column.unit == '時分'"
                :key="`${isDispPartFormat}-${column.dataIndex}`"
                :value="e.monitorData[column.dataIndex]"
                @input="checkModified(e); inputTimeData($event, e.monitorData, column.dataIndex, column.min, column.max);"
                :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
                :uniqueId="`_all${index}_${index2}`"
                :defaultValue="''"
              />
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
              <!-- 数値 -->
              <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 start -->
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
              <monitor-number-input
                v-else-if="column.isNumber"
                v-model="e.monitorData[column.dataIndex]"
                :step="column.step"
                :min="column.min"
                :max="column.max"
                @blur="checkModified(e)"
                :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
                :initValue="getInitValue(e, initData[index].monitorData[column.dataIndex])"
                :monitorUniqueId="index + '_' + index2"
              />
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
              <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 end -->
              <!-- 選択肢 -->
              <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 start -->
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
              <v-ons-select
                v-else-if="column.selectItem"
                class="selectbox"
                v-model="e.monitorData[column.dataIndex]"
                @change="checkModified(e)"
                :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
                :class="isEditSelectClass(e.monitorData[column.dataIndex], getInitValue(e, initData[index].monitorData[column.dataIndex]))">
               <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
              <!-- add FNSI-共有設定の追加 周雨晴 2020/09/22 end -->
                <!-- mod FNSI改修内容 治療モードなど不明改修 房 start -->
                <option
                  v-for="(item, index) in testMethod(column, e)"
                  :key="index"
                  :value="item.cd"
                  :hidden="item.hidden"
                  :disabled="item.hidden"
                >{{ item.text }}</option>
                <!-- mod FNSI改修内容 治療モードなど不明改修 房 end -->
              </v-ons-select>
              <!-- 文字列（選択肢無） -->
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
              <custom-simple-textarea-b v-else
                v-model="e.monitorData[column.dataIndex]"
                @blur="checkModified(e)"
                :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
                class="monitor-grid-textarea"
                autoWidth
                :initValue="getInitValue(e, initData[index].monitorData[column.dataIndex])"
                :isEdit="true"
              />
              <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
            </td>
            <!-- mod 8453 ljx end -->
            <!-- 更新者 -->
            <td class="ntss-list-body-td staff-name-cell">{{ e.updStaffName }}</td>
            <!-- 削除ボタン -->
            <td class="align-center ntss-list-body-td">
              <button class="ntss-btn-outset button-delete" :disabled="!isShared" @click="delRow(index)">
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
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
import CommonTimeComponent from "@/components/treatment-record/submenu/common/CommonTimeComponent";
import MonitorNumberInputComponent from "@/components/treatment-record/submenu/monitor/MonitorNumberInputComponent";
// import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
import { CODES } from "@/constants/TreatmentRecord";
import CommonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import CustomSimpleTextareaTypeB from "@/components/common/custom-form-tags/CustomSimpleTextareaTypeB";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import {
  dateFormat,
  DATE_FORMAT,
  diffDateInMinutes,
  diffTimeInMinutes
} from "@/functions/common/DateTimeUtils";
import {
  Monitor,
} from "@/models/treatment-record/monitor/Monitor";
import { getAuthorized } from "@/functions/common/CommonFunctions";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
import CustomInputTimeSpecial from "@/components/common/custom-form-tags/CustomInputTimeSpecial";

export default {
  // mixins: [UserAuthorityMixin],
  components: {
    "com-time-input": CommonTimeComponent,
    "monitor-number-input": MonitorNumberInputComponent,
    "common-calendar": CommonCalender,
    "custom-simple-textarea-b": CustomSimpleTextareaTypeB,
    "custom-input-time-special": CustomInputTimeSpecial
  },
  props: {
    value: {
      type: Array,
      default: () => []
    },
    // cds: Array,
    /**
     * 表示形式
     */
    monitorDispFormat: {
      type: String,
      default: CODES.MONITOR_DISP_FORMAT.PART.cd
    },
    /**
     * 表示形式が「一部」の場合に表示する項目
     */
    displayMonitorItem: Array,
    /**
     * 表示形式が「すべて表示」の場合に表示する項目
     */
    displayAllMonitorItem: Array,
    /**
     * オーダー番号
     */
    ordNo: Number,
    //add FNSI修正 NKK3827 房 start
    treatEndDate: null,
    //add FNSI修正 NKK3827 房 end
  },
  data() {
    return {
      sortOrder: 1,
      monitorData: [],
      // モニタ表示形式
      monitorDispFormatList: CODES.MONITOR_DISP_FORMAT,
      // 初期表示時の表示形式(一部)
      monitorDispFormatIni: CODES.MONITOR_DISP_FORMAT.PART.cd,
      // 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
      initData: [],
      // 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
    };
  },
  computed: {
    ...mapGetters("treatment-record/common", [
      "getDialysisState", 
      "getRstEditionDate",
      "getRstStartDate",
      "getRstEndDate"
    ]),
    sortMarker() {
      return this.sortOrder > 0 ? "▲" : "▼";
    },
    // add 共有設定の追加 周雨晴 2020/09/22 start
    ...mapGetters("treatment-record/common", [
      "getOrd",
      "getSharedFacilityCd"
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    // add 共有設定の追加 周雨晴 2020/09/22 end
    // add 共有設定の追加 周雨晴 2020/09/22 start
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    // add 共有設定の追加 周雨晴 2020/09/22 end
    /**
     * 一部表示か否かを判断する.
     * true:一部表示
     * false:すべて表示
     */
    isDispPartFormat() {
      return this.monitorDispFormatIni === CODES.MONITOR_DISP_FORMAT.PART.cd;
    }
  },
  methods: {
    ...mapActions("treatment-record/weight", ["getTreatmentRecordWeight"]),
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    /**
     * 一覧をソートする.
     */
    sort() {
      this.sortOrder = this.sortOrder * -1;
      const newRecords = this.monitorData.filter(e => e.isNew);
      const sortedData = this.monitorData
        .filter(e => !e.isNew)
        .sort((a, b) => (a.occurDate - b.occurDate) * this.sortOrder);
      sortedData.unshift(...newRecords);
      this.monitorData = sortedData;
      // 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
      const newInitRecords = this.initData.filter(e => e.isNew);
      const sortedInitData = this.initData
        .filter(e => !e.isNew)
        .sort((a, b) => (a.occurDate - b.occurDate) * this.sortOrder);
      sortedInitData.unshift(...newInitRecords);
      this.initData = sortedInitData;
      // 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
      
      // 親コンポーネントにsort後のデータを通知
      this.$emit("updateMonitorData", this.monitorData);
    },
    /**
     * 編集されたことを通知する.
     */
    checkModified(model) {
      this.$nextTick(() => {
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
        // if (model.isModified()) {
        //   this.$emit("modifiedValue");
          this.$emit("modifiedValue", model.isModified());
          this.$emit("changeValue",this.monitorData)
        // }
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
      });
    },
    //add FNSI改修内容 治療モードなど不明改修 房 start
    testMethod(param, e){
      let returnArray = [];
      param.selectItem.forEach(copyValue=>{
        let newOption = {
          cd: copyValue.cd,
          text:copyValue.text
        }
        returnArray.push(newOption);
      });
      if (param.dataType == 0) {
        let value = e.monitorData[param.dataIndex];
        if (value != null) {
          let result = param.selectItem.filter(el=>el.cd == value);
          if (result.length === 0) {
            let newValue = {
              cd:value,
              text:"不明"
            }
            returnArray.push(newValue)
          }
        }
      }
      // console.log(returnArray);
      return returnArray;
    },
    //add FNSI改修内容 治療モードなど不明改修 房 end
    //add FNSI-改修内容 新規ボタン追加 房 start
    addRow() {
      this.monitorData.push(new Monitor(null, null, false, null, null, null, null, this.getDefaultTime()));
      // デフォルト日時設定
      this.setDefaultDate(this.monitorData[this.monitorData.length - 1], true);
      this.initData.push(new Monitor());
    },
    delRow(targetIndex) {
      if (this.monitorData[targetIndex].isNew) {
        // 新規追加行は物理削除
        this.monitorData.splice(targetIndex, 1);
        this.initData.splice(targetIndex, 1);
        this.$emit("modifiedValue", JSON.stringify( this.monitorData) !== JSON.stringify( this.initData));
      } else {
        // 登録済みデータは論理削除
        this.monitorData[targetIndex].isDel = !this.monitorData[targetIndex].isDel;
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
     * 入力された時分の最大値、最小値のチェック処理
     * 入力された時分＞最大値の場合：最大値で補正、入力された時分＜最小値の場合：最小値で補正
     */
    inputTimeData(inputValue, monitorData, dataIndex, min, max) {
      if (!inputValue) {
        // 0、空入力の場合
        monitorData[dataIndex].editValue = inputValue;
      } else {
        // データがある場合
        // 最大値、最小値のチェック処理
        if (min > inputValue) {
          monitorData[dataIndex].editValue = min;
        } else if (max < inputValue) {
          monitorData[dataIndex].editValue = max;
        } else {
          monitorData[dataIndex].editValue = inputValue;
        }
      }
    },
    /** 
    * 実施日時未入力の場合にデフォルト値を設定
    * @param setTimeFlg デフォルト時刻をセットするかのフラグ
    */
    setDefaultDate(record, setTimeFlg) {
      if (!record.occurTime) {
        record.occurDateString = dateFormat.format(this.getDefaultOccurDate(), DATE_FORMAT);
        record.occurTime = setTimeFlg ? this.getTime(this.getDefaultOccurDate()) : null;
      }
    },
    /** 
    * 発生日時をクリア（×ボタン、手入力クリア）した際、カレンダー表示した際のデフォルト日付を変更するためデフォルト値を日付（非表示）に設定
    * ※時刻はクリア状態
    */
    dateInit(index){
      // デフォルト日付を設定
      this.setDefaultDate(this.monitorData[index], false);
    },
    /** 
    * 発生日時 時刻入力フォーカス
    */
    onFocusOccurTime(index){
      // 時刻が空の場合、デフォルト日時を設定
      this.setDefaultDate(this.monitorData[index], true);
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
    getDefaultOccurDate() {
      let defaultDate = new Date();
      if (+this.getDialysisState === +CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd) {
        // rst_dialysis_state6
        defaultDate =  this.getRstEditionDate ? new Date(this.getRstEditionDate) : new Date();
      }
      return defaultDate;
    },
    /** 
    * 経過時間のデフォルト値を取得
    *   rst_dialysis_state1～5の場合：現在時刻－治療開始時刻 ※データない場合は00:00
    *   rst_dialysis_state6の場合の場合：治療終了日時－治療開始日時 ※データない場合は00:00
    * @return 経過時間 分単位（数値）
    */
    getDefaultTime() {
      let defaultTime = 0;
      if (+this.getDialysisState === +CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd) {
        // rst_dialysis_state6
        if (this.getRstStartDate && this.getRstEndDate) {
          defaultTime = diffDateInMinutes(new Date(this.getRstStartDate), new Date(this.getRstEndDate));
        }
      } else {
        // rst_dialysis_state1～5
        if (this.getRstStartDate) {
          defaultTime = diffTimeInMinutes(new Date(this.getRstStartDate), new Date());
        }
      }
      return defaultTime < 0 ? 0 : defaultTime;
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
    getInitValue(e, initData) {
      // 追加行を残して削除した際、追加行の編集前データが編集後データで上書きされるため、追加行の編集前データは常にnullとする
      return !e.isNew ? initData : null;
    }
  },
  watch: {
    value() {
      // del #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
      // const convertToNumber = (value) => {
      //   // 数値型でない場合、数値に変換する
      //   return value != null && typeof value !== "number" ? Number(value) : value;
      // };
      // del #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end

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
            
      this.monitorData = this.value;
      if (this.monitorData && this.displayAllMonitorItem) {
        // 数値項目の値をstringからnumberに変換しておく
        this.monitorData.forEach(rowData => {
          const monitorData = rowData.monitorData;
          const dataIndexies = Object.keys(monitorData);
          dataIndexies.forEach(dataIndex => {
            const columnItem = this.displayAllMonitorItem.find(item => item.dataIndex === dataIndex);
            const dataValue = monitorData[dataIndex];
            if (columnItem?.isNumber) {
              if (columnItem.dataType === 3 && columnItem.unit === "時分") {
                monitorData[dataIndex] = {
                  // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
                  // editValue: convertToNumber(dataValue.editValue),
                  // initValue: convertToNumber(dataValue.initValue)
                  editValue: dataValue.editValue,
                  initValue: dataValue.initValue
                  // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end
                };
                // del #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
              // } else {
                //   monitorData[dataIndex] = convertToNumber(dataValue);
                // del #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end
              }
            }
          });
        });
      }
      if (initFlag) {
        // 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
        this.initData = JSON.parse(JSON.stringify(this.monitorData));
        this.initData.forEach(el=>el["occurDate"] = new Date(el["occurDate"]));
        // 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
      }
      // add FNSI-受信した値が-32768（8000h）の場合は、空欄を表示する 徐 start
      if (this.monitorData) {
        for (let i = 0; i < this.monitorData.length; i++) {
          if (this.monitorData[i].monitorData) {
            for (let j = 0; j < 103; j++) {
              if (j !== 0
              && j !== 16
              && j !== 31
              && j !== 52
              && j !== 53
              && j !== 81
              && j !== 82
              && j !== 83
              && j !== 84
              && j !== 85
              && j !== 86
              && j !== 87
              && j !== 89
              && j !== 95
              && j !== 96
              && j !== 99) {
                if (this.monitorData[i].monitorData[j] == '-32768') {
                  this.monitorData[i].monitorData[j] = null;
                }
              }
            }
          }
        }
      }
    }
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  /**
   * コンポーネント生成
   */
  created() {
    this.authorityCds = this.cds;
  }
};
</script>

<style scoped>
.monitor-grid-container {
  height: 100%;
  min-height: 0;
}
.scroll-table {
  width: 1px;
}
.selectbox :deep(select) {
  width: fit-content;
}
.common-time-input {
  width: auto;
}
.ntss-list-header-th-sticky {
  z-index: 1;
}
.align-center {
  text-align: center;
}
.ntss-list-body-td ons-input {
  min-width: 3em;
}
/**
 * 選択肢の場合のスタイル定義
 */
.ntss-list-body-td ons-select {
  min-width: 6.5em;
}
.text-style {
  color: #00b050;
}
.flex-align-center {
  display: flex;
  align-items: center;
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
.monitor-selection-area {
  display: flex;
  flex-wrap: nowrap;
  align-items: center;
}
.monitor-selection-area label {
  color: var(--ntss-list-body-color);
  white-space: nowrap;
}
.monitor-disp-format {
  margin-left: 5px;
  display: flex;
  flex-wrap: nowrap;
}
.monitor-disp-format ons-radio {
  margin-right: 4px;
}
.hide-sticky-border::after {
  content: "";
  border-right: 1px solid var(--main-background-color);
  position: absolute;
  right: -1px;
  top: 0;
  height: 100%;
}
.monitor-grid-textarea :deep(textarea) {
  border-color: unset;
  border-style: inset;
  min-width: 100%;
}
 
/* add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start */
.custom-select-edited-box :deep(select) {
  outline: 0 !important;
  border-radius: 5px !important;
  border: 2px green solid;
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
