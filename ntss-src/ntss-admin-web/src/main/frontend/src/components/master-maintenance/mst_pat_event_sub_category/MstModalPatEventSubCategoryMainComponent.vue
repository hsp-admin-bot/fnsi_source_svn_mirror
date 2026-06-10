<template>
  <div class="main-area">
    <table class="disp-item-area">
      <tr>
        <td>
          <div class="disp-item-content-area">
            <draggable>
                <v-ons-row
                  :class="{ 'layout-item-dragging': isDraggingCategory }"
                  class="layout-item"
                  @mouseup="isDraggingCategory = false"
                  @touchend="isDraggingCategory = false"
                >
                  <v-ons-col>
                      <v-ons-row
                        :class="{
                          'layout-item-dragging': isDraggingSubCategory
                        }"
                        class="layout-item"
                        @mouseup="isDraggingSubCategory = false"
                        @touchend="isDraggingSubCategory = false"
                      >
                        <v-ons-row class="color-header">
                          <v-ons-col class="layout-item">
                            帳票選択
                          </v-ons-col>
                        </v-ons-row>
                        <v-ons-col>
                          <draggable
                            v-model="dispItemInfo"
                            :options="{
                              ...dragOptions,
                              handle: '.sub-category-item-handle'
                            }"
                            @change="setDispItemInfo(dispItemInfo)"
                            @choose="isDraggingSubCategoryItem = true"
                            @end="isDraggingSubCategoryItem = false"
                          >
                            <v-ons-col
                              v-for="subCategoryItem in dispItemInfo"
                              :key="subCategoryItem.itemNo"
                              :class="{
                                'layout-item-dragging': isDraggingSubCategoryItem
                              }"
                              class="layout-item"
                              @mouseup="isDraggingSubCategoryItem = false"
                              @touchend="isDraggingSubCategoryItem = false"
                            >
                              <label>{{ subCategoryItem.itemName }} </label>
                              <v-ons-icon
                                icon="fa-bars"
                                class="sub-category-item-handle sub-category-handle-area"
                                style="margin-left: 25%"
                              />
                              <span  v-if="subCategoryItem.itemNo == 1" style="float:right;width:3%">回分</span>
                              <v-ons-select
                                style="margin-right:3%;float:right;width:15%"
                                v-if="subCategoryItem.itemNo != 1"
                                v-model="subCategoryItem.reportCd"
                                >
                                <template
                                  v-for="(item, index) in reportlist"
                                >
                                  <option :key="index" v-if="item.reportClass == subCategoryItem.itemNo" :value="item.reportCd">
                                      {{ item.reportName }}
                                  </option>
                                </template>
                              </v-ons-select>
                              <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
                              <!-- <v-ons-input
                                type="number"
                                @input="isIputNumber"
                                style="float:right;width:15%"
                                @mousewheel="stopScrollFun($event)"
                                @DOMMouseScroll="stopScrollFun($event)"
                                v-if="subCategoryItem.itemNo == 1"
                                v-model="subCategoryItem.times"
                                max="15"
                                >
                              </v-ons-input> -->
                              <v-ons-input
                                type="number"
                                @change="isIputNumber"
                                style="float:right;width:15%"
                                @mousewheel.prevent="stopScrollFun($event)"
                                @blur="formatValue($event)"
                                @focus="handleFocus"
                                v-if="subCategoryItem.itemNo == 1"
                                v-model="subCategoryItem.times"                                >
                              </v-ons-input>
                              <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end                           -->
                              <span  v-if="subCategoryItem.itemNo == 1" style="float:right;width:23%">治療方法ごとに指定した帳票　過去レポートの印刷回数</span>
                            </v-ons-col>
                          </draggable>
                        </v-ons-col>
                      </v-ons-row>
                  </v-ons-col>
                </v-ons-row>
            </draggable>
          </div>
        </td>
      </tr>
    </table>

  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import { mstPatEventSubCategoryDefine } from "@/constants/mstPatEventSubCategoryDefine";
import { deepCopy } from "@/functions/common/CommonFunctions";
import vuedraggable from "vuedraggable";
import { ApiHelper } from "@/apis/AxiosHelper.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end

export default {

  components: {
    draggable: vuedraggable
  },

  data() {
    return {
      dragOptions: {
        animation: 250,
        ghostClass: "ghost",
        dragClass: "drag",
        forceFallback: true,
        fallbackClass: "layout-item-fallback"
      },
      isDraggingCategory: false,
      isDraggingSubCategory: false,
      isDraggingSubCategoryItem: false,
      /**
       * 表示項目情報
       */
      dispItemInfo: [],
      dispItemInfoTemp: [],
      reportlist: [],
      // mod #5589 2023/04/01 数値IFのスタイル全不正 張博 start
      minValue:0,
      maxValue:15,
      blurFlg:false,
      focusFlg:false,
      // mod #5589 2023/04/01 数値IFのスタイル全不正 張博 end
    };
  },
  computed: {
    ...mapGetters("master-maintenance", { editRecord: "getEditRecord", getFacilitySwitch: "getFacilitySwitch" }),
    ...mapGetters("user", ["getFacilityCd", "getAdvancedSettings"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
  },

  async created() {
    if(!this.getAdvancedSettings.func_advcds) {
      this.getAdvancedSettings.func_advcds = [];
    }
    await Promise.all([
      // mod マスタ一覧 1･施設切替を可能とする 孔s this.facilityCd => this.getFacilitySwitch
      // ApiHelper.get("/report/getMstReportByFacilityCd/" + this.facilityCd).then(response => {
      // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
      // ApiHelper.get("/report/getMstReportByFacilityCd/" + this.getFacilitySwitch).then(response => {
      ApiHelper.get("/report/getMstReportByFacilityCdNoIsDisp/" + this.getFacilitySwitch).then(response => {
      // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
        if(response.data) {
          response.data.forEach(element => {
            // del #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
            // if (element.isDisp == "1"){
            // del #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
              if(element.reportClass == 1) {
                this.reportlist.push({
                  times: element.times,
                  reportName: element.reportName,
                  reportClass: element.reportClass,
                });
              }else{
                this.reportlist.push({
                  reportCd: element.reportCd,
                  reportName: element.reportName,
                  reportClass: element.reportClass,
                });
              }
            // del #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
            // }
            // del #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
          });
          // 「未選択」を追加
          // 単患者帳票
          this.reportlist.unshift({
            reportCd: 0,
            reportName: "未選択",
            reportClass: 2,
          });
          // ラベル
          this.reportlist.unshift({
            reportCd: 0,
            reportName: "未選択",
            reportClass: 8,
          });
          // 集計帳票
          this.reportlist.unshift({
            reportCd: 0,
            reportName: "未選択",
            reportClass: 10,
          });
        }
      })
    ])
    .catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
      getErrorMessage('MstModalPatEventSubCategoryMainComponent.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
      throw error;
    });
    this.dataSelection();
    this.retrieveMstData();
  },

  watch: {
    /**
     * @description 表示項目並び替えウォッチャー
     */
    dispItemInfo: {
      handler(data) {
        this.setDispItemInfo(data);
      },
      deep: true
    }
  },

  mounted() {
    this.$el.parentElement.style.height = "100%";
  },

  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),

    /**
     * @description データソース選択
     */
    dataSelection(){
      const temp = mstPatEventSubCategoryDefine;
      this.dispItemInfoTemp = temp;
    },
    /**
     * @description レイアウトデータ取得
     */
    retrieveMstData() {
      const temp = this.editRecord.dispItemInfo
        ? JSON.parse(this.editRecord.dispItemInfo)
        //mod デフォルトで非選択状態 孔s start
        // : this.dispItemInfoTemp;
        : [];
        //mod デフォルトで非選択状態 孔s end
      this.dispItemInfo = this.insertIsDispOption(temp);
    },
    stopScrollFun(e) {
      // mod #5589 2023/04/11 数値IFのスタイル全不正 張博 start
      if (!this.focusFlg) {
        return;
      }
      // let value = e.target.value;
      // e.target.value = value;
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      let value = parseFloat(e.target.value);
      const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      if (value > this.maxValue) {
        value = this.minValue;
      }
      if(value < this.minValue) {
        value = this.maxValue;
      }
      e.target.value = value
      // mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end
    },
    isIputNumber(e) {
      if (!(e.target.value === undefined || e.target.value === null) && e.target.value.length == 0) {
        // 回数が空欄になった場合は「0」を設定
        e.target.value=e.target.value = 0;
      } else if (e.target.value.length==1) {
        e.target.value=e.target.value.replace(/[^0-9]/g,'');
      } else {
        if (e.target.value.substring(0,1) ==0) {
          e.target.value=e.target.value.replace(/0/g,'');
        }
        // mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start
        // let tmpValue = e.target.value.replace(/[^0-9]/g,'');
        // // 最大値を超えていた場合
        // if (tmpValue > this.maxValue) {
        //   e.target.value = this.maxValue;
        //   console.log('e.target.value',e.target.value);

        // } else {
        //   e.target.value = tmpValue;
        //   console.log('e.target.value',e.target.value);

        // }
        //   console.log('e.target.value',e.target.value);
      }
        // 数値範囲内かどうかの確認
        if (this.minValue !== undefined && this.maxValue !== undefined) {
          if (e.target.value > this.maxValue) {
            e.target.value = this.minValue;
            this.blurFlg=true;
          } else if (e.target.value < this.minValue) {
            e.target.value= this.maxValue;
            this.blurFlg=true;
          }else{
            this.blurFlg=false;
          }
        }
    },
    formatValue(event){
      // 限界値判定
      let value = event.target.value;
      if (value == this.maxValue && this.blurFlg) {
        event.target.value = this.minValue;
        this.blurFlg = false;
      }else if (value == this.minValue && this.blurFlg) {
        event.target.value = this.maxValue;
        this.blurFlg = false;
      }
      this.focusFlg=false;
    },
    handleFocus(){
      this.focusFlg=true;
    },
    // mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end
    /**
     * @description 表示項目変更
     * @param { Array } value 編集内容
     */
    setDispItemInfo(value) {
      this.editRecord.dispItemInfo = JSON.stringify(value);
      let editRecord = this.editRecord;
      // 編集中マスタを更新
      this.setEditRecord(editRecord);
    },

    /**
     * @description レイアウトマスタ定義を元に編集用のデータを生成する.
     *              レイアウトマスタ定義に存在しない項目は非表示扱いとする.
     * @param { Array } data 編集レイアウト
     */
    insertIsDispOption(data) {
      // 患者経過総合ビューアレイアウトマスタの項目定義
      const src = deepCopy(this.dispItemInfoTemp);
      // 編集中マスタ
      const dest = deepCopy(data);
      src.forEach(srcCategory => {
        const destCategory = dest.find(categoryOther => {
          return categoryOther.itemNo === srcCategory.itemNo;
        });
        // 編集中マスタに項目が存在しないと非表示にする
        if (!destCategory) {
          if (srcCategory.itemNo == 1) {
            // itemNo：1 治療経過表の回数の初期値を設定
            srcCategory.times = 0;
          } else {
            // itemNo：1 治療経過表以外の場合のレポートの初期値(未選択)を設定
            srcCategory.reportCd = 0;
          }
          dest.push(srcCategory);
        } else {
          destCategory.itemName = srcCategory.itemName;
          if (destCategory.itemNo == 1 && (destCategory.times == undefined || destCategory.times == null)) {
            destCategory.times = 0;
          } else if (destCategory.itemNo !== 1 && !destCategory.reportCd) {
            destCategory.reportCd = 0;
          }
        }
      });
      return dest;
    },

    /**
     * @description 保存用にデータを整形
     * @param { Array } data 編集レイアウト
     */
    formattingData(data) {
      let res = deepCopy(data);
      res.forEach(category => {
        if (category.itemNo !== 1 && category.reportCd == 0) {
          // 治療経過表以外で、未選択が選択されていた場合は、reportCd を除去
          delete category.reportCd;
        } else if (category.itemNo == 1 && category.times == "") {
          // 治療経過表で、回数が空欄の場合は、0で保存する
          category.times = 0;
        }
      });
      return res;
    },

    /**
     * 確定ボタン押下時の処理
     * @description
     */
    validateOnRegistration() {
      this.editRecord.dispItemInfo = JSON.stringify(this.formattingData(JSON.parse(this.editRecord.dispItemInfo)));
      this.setEditRecord(this.editRecord);
      return true;
    }
  }
};
</script>

<style scoped>
.layout-item {
  border-bottom: 1px solid #999;
  transition: max-height 500ms;
  overflow: hidden;
  max-height: 99999px;
}

.layout-item-fallback,
.layout-item.layout-item-dragging {
  max-height: 26px;
}

ons-col.layout-item, .color-header {
  border-left: 1px solid #999;
  border-right: 1px solid #999;
}

ons-col.layout-item {
  padding-left: 4px;
}

.color-header .layout-item {
  border: 0;
  padding-left: 0 !important;
}

.color-header .sub-category-handle-area {
  margin-top: 0 !important;
}

.ghost {
  opacity: 0.5;
}

.drag {
  display: none;
}

/* .layout-name-area,
.disp-period,
.disp-item-name-area {
  padding-left: 8px;
  vertical-align: top;
} */

/* .disp-item-no,
.k-textbox {
  width: 100%;
} */

.disp-item-content-area {
  overflow-y: scroll;
  height: 100%;
}

.disp-item-area {
  height: 97%;
  width: 100%;
  border-collapse: collapse;
}

/* .disp-item-area tr {
  height: 30px;
} */

.disp-item-area tr th {
  text-align: left;
}

.disp-item-area tr th:first-child,
.disp-item-area tr th:nth-child(2) {
  width: 30%;
}

.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2),
.disp-item-area tr td:nth-child(3) {
  border: 1px solid lightgray;
  text-align: left;
}

.disp-item-area tr:nth-child(3) td:nth-child(3) {
  height: 100%;
}

.category-handle {
  cursor: move;
  float: right;
  margin: 2px 5px;
}
/* .right-category-handle {
  margin-right: 5px;
} */

.sub-category-handle-area {
  float: right;
  margin-top: 2px;
  margin-right: 5px;
}

/* .item-handle-icon {
  margin: 0 4px;
} */

.popover-style >>> .popover__content {
  width: 500px;
  height: 100%;
  padding: 25px;
}

/* .selector-title {
  margin: 0;
} */

/* .mult-selector {
  overflow-y: auto;
  max-height: 300px;
  min-height: 300px;
  border: solid 1px #bbbbbb;
} */

/* .select-label-style {
  padding: 0px 2px 1px;
  white-space: nowrap;
  box-sizing: border-box;
} */

/* 3 */

:disabled + .checkbox__checkmark {
  opacity: 100;
}

/* .dis-selected-color:hover {
  background-color: #dddddd;
} */

.button-cancel {
  float: left;
}

.button-confirm {
  float: right;
}

/* .rdo-period {
  margin-right: 10px;
} */

/* .graph-setting > div {
  margin-bottom: 5px;
} */

.graph-setting:first-child {
  margin-right: 5px;
}

.graph-setting:nth-child(2) {
  margin-left: 5px;
}

.graph-setting >>> label {
  margin-right: 5px;
}

.flex-container {
  padding: 2px 5px;
  height: auto;
  align-items: flex-start;
  line-height: unset !important;
}

ons-col.color-header {
  background-image: unset !important;
}
</style>
