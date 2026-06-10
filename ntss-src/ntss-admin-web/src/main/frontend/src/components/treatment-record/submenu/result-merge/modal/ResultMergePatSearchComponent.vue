<template>
  <modal-base @onClose="cancel">
    <div slot="body" class="main-content">
      <div class="filter-content">
        <v-ons-icon class="icon-position" icon="fa-search" size="1.5em" style="color:gray;"></v-ons-icon>
        <input type="text" class="search-input-icon" v-model="searchParam">
      </div>
      <div class="list-content">
        <div class="scroll-table">
          <table id="sys-medicine-list" class="ntss-list" style="position: inherit;">
            <thead>
              <tr>
                <th class="ntss-list-header-th-sticky manual-width" style="min-width: 3em;">
                  <div class="resizable-header">
                    <span @click="sortBy('hospPatId')" class="clickable-header-label" :class="sortedClass('hospPatId')">患者ID</span>
                  </div>
                </th>
                <th class="ntss-list-header-th-sticky manual-width" style="min-width: 8em;">
                  <div class="resizable-header">
                    <span @click="sortBy('patName')" class="clickable-header-label" :class="sortedClass('patName')">患者名</span>
                  </div>
                </th>
                <th class="ntss-list-header-th-sticky manual-width" style="min-width: 5em;">
                  <div class="resizable-header">
                    <span @click="sortBy('treatDate')" class="clickable-header-label" :class="sortedClass('treatDate')">治療日</span>
                  </div>
                </th>
                <th class="ntss-list-header-th-sticky manual-width" style="min-width: 5em;">
                  <div class="resizable-header">
                    <span @click="sortBy('kurName')" class="clickable-header-label" :class="sortedClass('kurName')">クール</span>
                  </div>
                </th>
                <th class="ntss-list-header-th-sticky manual-width" style="min-width: 12em;">
                  <div class="resizable-header">
                    <span @click="sortBy('bedName')" class="clickable-header-label" :class="sortedClass('bedName')">ベッド</span>
                  </div>
                </th>
                <th class="ntss-list-header-th-sticky manual-width" style="min-width: 5em;">
                  <div class="resizable-header">
                    <span @click="sortBy('treatmentName')" class="clickable-header-label" :class="sortedClass('treatmentName')">治療方法</span>
                  </div>
                </th>
                <th class="ntss-list-header-th-sticky manual-width" style="min-width: 5em;">
                  <div class="resizable-header">
                    <span @click="sortBy('dialysisState')" class="clickable-header-label" :class="sortedClass('dialysisState')">治療状況</span>
                  </div>
                </th>
                <th class="ntss-list-header-th-sticky manual-width" style="min-width: 19em;">
                  <div class="resizable-header">
                    <span @click="sortBy('treatStartEndDate')" class="clickable-header-label" :class="sortedClass('treatStartEndDate')">治療開始終了日時</span>
                  </div>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(data, index) in sortedList"
                :class="{
                  'ntss-list-body-tr': true,
                  'ntss-list-body-tr-blue': data.selected
                }"
                @click="onSelectRow(index)"
                @dblclick="onDoubleClick(index)"
                :key=index
                :id="'sys-medicine-row-' + index">
                <!-- 患者ID -->
                <td class="ntss-list-body-td hosp-pat-id-body">{{ data.hospPatId }}</td>
                <!-- 患者名 -->
                <td class="ntss-list-body-td">{{ data.patName }}</td>
                <!-- 治療日 -->
                <td class="ntss-list-body-td">{{ data.treatDate }}</td>
                <!-- クール -->
                <td class="ntss-list-body-td">{{ data.kurName }}</td>
                <!-- ベッド -->
                <td class="ntss-list-body-td">{{ data.bedName }}</td>
                <!-- 治療方法 -->
                <td class="ntss-list-body-td">{{ data.treatmentName }}</td>
                <!-- 治療状況 -->
                <td class="ntss-list-body-td dialysis_state_style">
                  <div :class="`rst-state-common rst-state-${data.dialysisState}`" v-if="data.dialysisState !== 0">
                    <label class="rst-state-inner">{{ dialysisStateNames[data.dialysisState] }}</label>
                  </div>
                </td>
                <!-- 治療開始終了日時 -->
                <td class="ntss-list-body-td">{{ data.treatStartEndDate }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
      <div class="denial-btn-area" style="background:none">
        <button class="button denial-btn btn2-cancel" @click="cancel">キャンセル</button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <button class="button registration-btn btn3-normal" :disabled="!isSelected" @click="reflect">確定</button>
      </div>
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
    </div>
  </modal-base>
</template>

<script>
import {mapActions, mapGetters} from "vuex";
import SubModalBase from "@/components/modals/SubModalBase";
import MultiSubModalMixin from "@/components/modals/MultiSubModalMixin";
import moment from "moment";
import { addPatNameSortToList, updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";

export default {
  // mixinの読込
  mixins: [MultiSubModalMixin],

  components: {
    "modal-base": SubModalBase
  },
  data() {
    return {
      detailList:[],
      detailSearchList:[],
      // 実績状況と表示名
      dialysisStateNames: {
        1 : "前体重\n測定済",
        2 : "患者\n確認済",
        3 : "治療中",
        4 : "後体重\n未測定",
        5 : "未確定\n実績",
        6 : "確定実績"
      },
      searchParam: "",
      isSelected:false,
      requestData:null,
      sort: {
        key: "",
        isAsc: true
      },
    };
  },
  methods: {

    ...mapActions("treatment-record/result-merge", ["getResultMergeList","setParamData"]),

    /**
     * 初期処理
     */
    async init() {
      
      // 実績マージデータ選択データ作成関数
      const createDetailData = (ele) => {
        return {
          patId: ele.pat_id,
          patName: this.patNameHandle(ele.pat_id, ele.pat_name),
          treatDate: ele.treat_date != null ? this.treatDateFormat(ele.treat_date) : "",
          kurName: ele.rst_kur_name,
          bedName: ele.rst_bed_name,
          treatmentName: ele.rst_treatment_name,
          dialysisState: ele.rst_dialysis_state,
          treatStartEndDate: this.treatStartAndEndDate(ele.rst_start_date, ele.rst_end_date),
          selected: false,
          ordNo: ele.ord_no,
          hospPatId: ele.hosp_pat_id,
          patNameSort: ele.patNameSort,
          kurStartTime: ele.rst_kur_start_time,
          treatmentOrderIndex: ele.rst_treatment_order_index,
          bedOrderIndex: ele.rst_bed_order_index
        };
      };
      
      // 実績マージデータ選択リスト取得
      this.getResultMergeList({ord_no:this.getSearchParam.ord_no, start_date:this.getSearchParam.start_date,
        end_date:this.getSearchParam.end_date, is_unknown:this.getSearchParam.is_unknown}).then(response=> {
        this.requestData = response.data;

        if (response.data) {
          // システム共通患者名ソート用(フリガナ優先文字列)を追加
          const mergeList = addPatNameSortToList(response.data);
          
          mergeList.forEach(ele => {
            // マージ対象が治療中 -> 治療中以外のデータをリストに追加
            if (this.getSearchParam.state == 3) {
              if (ele.rst_dialysis_state != 3) {
                const data = createDetailData(ele);
                this.detailList.push(data);
                this.detailSearchList.push(data);
              }
            } else {
              // マージ対象が治療中以外 -> すべてリストに追加
              const data = createDetailData(ele);
              this.detailList.push(data);
              this.detailSearchList.push(data);
            }
          })

          if (this.detailList.length === 0 || this.detailSearchList.length === 0) {
            this.$ons.notification.alert({
              title: "実績マージデータ検索結果",
              message: "該当データがありません。"
            });
          }
        } else {
          this.$ons.notification.alert({
            title: "実績マージデータ検索結果",
            message: "該当データがありません。"
          });
        }
      })
    },
    /**
     * キャンセルボタン押下時イベント処理
     */
    cancel() {
      // モーダルを閉じる.
      this.hideModal();
    },
    /**
     * 確定ボタン押下時イベント処理
     * ※呼出元の`applySysMedicineSubModal`を呼びだします.
     */
    reflect() {
      let seletedRecord = this.sortedList.find(x=>x.selected === true);
      let paramData = this.requestData.find(x=>x.ord_no === seletedRecord.ordNo);
      this.setParamData(paramData);
      // 確定ボタン押下時の処理はモーダルを閉じるのみ.
      this.hideModal();
    },
    onSelectRow (index) {
      this.isSelected = true;
      this.sortedList.forEach((ele, recordIndex)=>{
        if (recordIndex === index) {
          ele.selected = true;
        } else {
          ele.selected = false;
        }
      });
    },
    patNameHandle(patId, PatName){
      if (patId === null) {
        return "？？？？患者";
      }
      return PatName;
    },
    treatDateFormat(treatDate){
      return moment(treatDate).format("YYYY/MM/DD");
    },
    treatStartAndEndDate(startDate, endDate){
      if (startDate != null) {
        let tempDate = endDate != undefined ? moment(new Date(endDate)).format("YYYY/MM/DD HH:mm") : "";
        return moment(new Date(startDate)).format("YYYY/MM/DD HH:mm") + " ～ " + tempDate;
      } else {
        return "";
      }
    },
    override(flag){
      if (flag) {
        return "ntss-list-body-tr-blue";
      } else {
        return null;
      }
    },
    onDoubleClick(index) {
      this.sortedList.forEach((ele, recordIndex)=>{
        if (recordIndex === index) {
          ele.selected = true;
        } else {
          ele.selected = false;
        }
      });
      this.reflect();
    },
    // 昇順/降順のclassを作成
    sortedClass(key) {
      return getSortedClass(key, this.sort);
    },
    // ソートするキーを設定する
    sortBy(key) {
      updateSort(key, this.sort);
    },
  },
  /**
   * computed
   */
  computed: {
    ...mapGetters("treatment-record/result-merge", ["getSearchParam"]),
    /**
     * 一覧表示データ
     * - ソートキーに従ってソート実施
     */
    sortedList() {
      const list = this.detailSearchList.slice();
      if (this.sort.key) {
        list.sort((a, b) => {
          return sortableCompare(a, b, this.sort.key, this.sort.isAsc);
        });
      }
      return list;
    }
  },
  /**
   * created
   */
  async created() {
    // 初期処理
    await this.init();
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  watch: {
    searchParam: {
      handler(newValue) {
        if (newValue === "" || newValue == null) {
          this.detailSearchList = this.detailList;
        } else {
          this.detailSearchList = this.detailList.filter(ele => {
            // if (ele.patId != null && ele.patId != undefined) {
            //   if ((ele.patId + "").indexOf(newValue) != -1) {
            //     return true;
            //   }
            // }
            // mode 【結合テスト】実績マージ 患者ID検索处理不正 2023/06/09 kang start
            if (ele.hospPatId != null && ele.hospPatId != undefined) {
              if ((ele.hospPatId + "").indexOf(newValue) != -1) {
                return true;
              }
            }
            // mode 【結合テスト】実績マージ 患者ID検索处理不正 2023/06/09 kang end
            if (ele.patName != null && ele.patName != undefined) {
              if (ele.patName.indexOf(newValue) != -1) {
                return true;
              }
            }
            return false;
          })
          // 確定ボタンの活性or非活性制御
          this.isSelected = this.detailSearchList.some(item => item.selected);
        }
      }
    }
  }
}
</script>

<style scoped>
/** 実績状況の共通スタイル */
.rst-state-common {
  color:#fff;
  text-align:center;
  display: table;
  position: relative;
  width: 100%;
  height: 2.5em;
  border-radius: none;
  vertical-align:middle;
}
/** 実績状況表示部の内部要素のスタイル */
.rst-state-inner{
  display: table-cell;
  vertical-align: middle;
  white-space: pre;
  line-height: 1.2em;
}
/** 実績状況の背景色(条件送信後) */
.rst-state-1 {
  background:#42CB92;
}
/** 実績状況の背景色(条件送信確認済) */
.rst-state-2 {
  background:#42CB92;
}
/** 実績状況の背景色(治療中) */
.rst-state-3 {
  background:#2CA06F;
}
/** 実績状況の背景色(排液済) */
.rst-state-4 {
  background:#557769;
}
/** 実績状況の背景色(実績未確定) */
.rst-state-5 {
  background:#557769;
}
/** 実績状況の背景色(過去実績) */
.rst-state-6 {
  background:#808080;
}
.icon-position {
  margin-top: 0.1em;
}
.dialysis_state_style {
  text-align:center;
  vertical-align:middle;
}
/**
 * メインエリアのスタイル
 */
.main-content {
  height: 100%;
  overflow: hidden;
}
/**
 * 絞込条件部のスタイル
 */
.filter-content {
  background-color: #ffffff;
  background-image: none;
  font-family: inherit;
  margin-top: 0.5em;
  margin-left: 0.8em;
  margin-right: 0.8em;
  display: flex;
  border: 1px #CCC solid;
  border-radius:5px;
}
.search-input-icon {
  background-color: #ffffff;
  outline: none;
  border:none;
  height: 2em;
  margin: 0;
  width: 100%;
}
.ntss-list-header-th-sticky {
  z-index: 1;
}
.ntss-list-body-tr-blue {
  background-color: #007bff40 !important;
}
/**
 * 絞込条件エリア内のons-rowのスタイル
 */
.filter-content >>> ons-row {
  margin-top: 5px;
}
/**
 * 絞込条件のラベルのスタイル
 */
#filter_content_title {
  vertical-align: -webkit-baseline-middle;
  font-size: 1.5em;
  margin-left: 10px;
}
/**
 * 一覧部の大枠のスタイル
 */
.list-content {
  height: calc(100% - 3.3em);
}
/**
 * 一覧部のスタイル
 */
.scroll-table {
  overflow: auto;
  width: calc(100% - 20px);
  margin: 10px;
  height: calc(100% - 0.1em);
}
/**
 * 偶数行の背景色の設定
 */
tr:nth-child(2n){
  background-color: var(--ntss-list-content-2nd-background-color);
  color: var(--ntss-list-body-color);
}
.manual-width .resizable-header {
  display: inline-block;
  resize: horizontal;
  overflow: hidden;
  min-width: 100%;
  white-space: nowrap;
  box-sizing: border-box;
  vertical-align: top;
}
.clickable-header-label {
  display: block;
  width: 100%;
  padding: 0 4px;
  box-sizing: border-box;
  overflow: hidden;
}
@media print {
  .sub-modal-mask >>> .sub-modal-container {
    width: fit-content !important;
  }
}
</style>
