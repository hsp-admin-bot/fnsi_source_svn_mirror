<template>
  <component
  :is="modalComponent"
  @onClose="hideModal()"
  class="custom-modal"
  >
    <template #body>
      <div class="container-area" id="container-area">
        <div class="header-area" id="header-area">
        <div class="header-details">
          <v-ons-row id="list-header-wrapper">
            <!-- <v-ons-col class="color-header title-search" style="display:flex;"> -->
            <!-- mod FutreNetWeb+SI課題管理-NO.4798 劉全航 start -->
            <v-ons-col class="color-header title-search" style="display:flex;line-height:0px;">
            <!-- mod FutreNetWeb+SI課題管理-NO.4798 劉全航 end -->
            <div style="flex:1">
              <span>検索</span>
            </div>
              <div>
                <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 start-->
                <!-- <v-ons-button class="button denial-btn btn-search" id="clear-btn" @click="searchAll()">クリア</v-ons-button> -->
                <v-ons-button class="btn2-cancel" id="clear-btn" @click="searchAll()">クリア</v-ons-button>
                <!-- <v-ons-button class="btn-search" id="search-btn" @click="searchDrug()">検索</v-ons-button> -->
                <v-ons-button class="btn3-normal" id="search-btn" @click="searchDrug()">検索</v-ons-button>
                <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 end-->
              </div>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="input-row">
            <v-ons-col width="20%" class="input-search-title">
              <span style="margin-left: 5px">薬剤分類</span>
            </v-ons-col>
            <v-ons-col>
              <v-ons-select v-model="searchFilter.classCd">
                <option :value="nullValue">すべて</option>
                <template v-for="item in medicineClassList" :key="item.classCd">
                  <option :value="item.classCd">{{ item.className }}</option>
                </template>
              </v-ons-select>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="input-row">
            <v-ons-col width="20%" class="input-search-title">
              <span style="margin-left: 5px">薬剤名</span>
            </v-ons-col>
            <v-ons-col>
              <v-ons-input type="text" v-model="searchFilter.medicineName"></v-ons-input>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="input-row">
            <v-ons-col width="20%" class="input-search-title">
              <span style="margin-left: 5px">一般名処方</span>
            </v-ons-col>
            <v-ons-col>
              <v-ons-input type="text" v-model="searchFilter.genericName"></v-ons-input>
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>
        <div class="detail-area print-height-auto" :style="detailAreaHeight" ref="ntssList" @scroll="handleScroll">
        <table border="1" class="table-area custom-table-area">
          <thead>
            <tr>
              <th class="ntss-list-header-th-sticky color-shadow" style="padding-left: 4px">薬剤名</th>
              <th class="ntss-list-header-th-sticky color-shadow" style="padding-left: 4px">一般名処方</th>
            </tr>
          </thead>
          <tbody :key="keySelectedCount">
            <!-- mod FutreNetWeb+SI課題管理-NO.4798 劉全航 start  -->
            <!-- <tr
              class="custom-table-row-data"
              v-for="(drug, index) in getDrugList"
              :key="index"
              :class="{'selected-row': drug.medicineCd === selectedRow.medicineCd && drug.genericCd === selectedRow.genericCd }"
            > -->
            <!-- mod FutreNetWeb+SI課題管理-NO.4798 劉全航 end  -->
            <!-- mod #10225 処方薬剤選択に一般名処方が表示しない。yqz start -->
            <!-- <tr
              class="custom-table-row-data"
              v-for="(drug, index) in getDrugList"
              :key="index"
              :class="drug.medicineCd === selectedRow.medicineCd && drug.genericCd === selectedRow.genericCd?'selected-row': `ntss-list-body-td-${index%2}` "
            > -->
            <tr
              class="custom-table-row-data"
              v-for="(drug, index) in newGetDrugList"
              :key="index"
              :class="drug.medicineCd === selectedRow.medicineCd && drug.genericCd === selectedRow.genericCd?'selected-row': `ntss-list-body-td-${index%2}` "
            >
             <!-- mod #10225 処方薬剤選択に一般名処方が表示しない。yqz end -->
             <!-- mod FutreNetWeb+SI課題管理-NO.4798 劉全航 start  -->
              <!-- <td class="ntss-list-body-td ntss-pat-event-label"> -->
              <td class="ntss-pat-event-label">
                <!-- mod FutreNetWeb+SI課題管理-NO.4798 劉全航 end  -->
                <a
                  href=""
                  class="ntss-pat-pre-td"
                  @dblclick.prevent.stop="setSelectedOption(drug)"
                  @click.prevent.stop="setSelectedRow(drug)"
                  v-if="drug.medicineTabooType === '0'"
                >{{ drug.medicineName }}</a>
                <a
                  href=""
                  @dblclick.prevent.stop="setSelectedOption(drug)"
                  @click.prevent.stop="setSelectedRow(drug)"
                  style="color: red"
                  v-if="drug.medicineTabooType === '1'"
                >{{TABOO_CLASS_PREFIX}} {{ drug.medicineName }}</a>
                <a
                  href=""
                  @dblclick.prevent.stop="setSelectedOption(drug)"
                  @click.prevent.stop="setSelectedRow(drug)"
                  style="color: red"
                  v-if="drug.medicineTabooType === '2'"
                >{{ALLERGY_CLASS_PREFIX}} {{ drug.medicineName }}</a>
                <a
                  href=""
                  @dblclick.prevent.stop="setSelectedOption(drug)"
                  @click.prevent.stop="setSelectedRow(drug)"
                  style="color: red"
                  v-if="drug.medicineTabooType === '3'"
                >{{TABOO_ALLERGY_CLASS_PREFIX}} {{ drug.medicineName }}</a>
              </td>
              <td class="ntss-pat-event-label">
                <a
                  href=""
                  @dblclick.prevent.stop="setSelectedOption(drug, true)"
                  @click.prevent.stop="setSelectedRow(drug)"
                  v-if="drug.genericTabooType === '0'"
                >{{ drug.genericName }}</a>
                <a
                  href=""
                  @dblclick.prevent.stop="setSelectedOption(drug, true)"
                  @click.prevent.stop="setSelectedRow(drug)"
                  style="color: red"
                  v-if="drug.genericTabooType === '1'"
                >{{TABOO_CLASS_PREFIX}} {{ drug.genericName }}</a>
                <a
                  href=""
                  @dblclick.prevent.stop="setSelectedOption(drug, true)"
                  @click.prevent.stop="setSelectedRow(drug)"
                  style="color: red"
                  v-if="drug.genericTabooType === '2'"
                >{{ALLERGY_CLASS_PREFIX}} {{ drug.genericName }}</a>
                <a
                  href=""
                  @dblclick.prevent.stop="setSelectedOption(drug, true)"
                  @click.prevent.stop="setSelectedRow(drug)"
                  style="color: red"
                  v-if="drug.genericTabooType === '3'"
                >{{TABOO_ALLERGY_CLASS_PREFIX}} {{ drug.genericName }}</a>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      </div>
    </template>
    <template #footer>
      <div class="flex-container my-flex-container">
      <!-- mod no5047 薬剤選択モーダルの薬剤名が見切れる 張 end-->
      <div class="denial-btn-area" style="background:none">
        <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 start-->
        <!-- <button class="button denial-btn" @click="hideModal()">キャンセル</button> -->
        <v-ons-button class="btn2-cancel" @click="hideModal()">キャンセル</v-ons-button>
        <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 end-->
      </div>
      <div class="flex-container my-flex-container">
        <div class="registration-btn-area" style="background:none">
            <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 start-->
            <!-- <button
              class="button registration-btn"
              @click="setSelectedMedicineOption"
              :disabled="!canSelect || !selectedRow.medicineCd"
            >薬剤を反映</button> -->
            <v-ons-button
              class="btn3-normal"
              @click="setSelectedMedicineOption"
              :disabled="!canSelect || !selectedRow.medicineCd"
            >薬剤を反映</v-ons-button>
            <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 end-->
          </div>
          <div class="registration-btn-area" style="background:none">
            <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 start-->
            <!-- <button
              class="button registration-btn"
              @click="setSelectedGenericOption"
              :disabled="!canSelect || !selectedRow.genericCd"
            >一般名処方を反映</button> -->
            <v-ons-button
              class="btn3-normal"
              @click="setSelectedGenericOption"
              :disabled="!canSelect || !selectedRow.genericCd"
            >一般名処方を反映</v-ons-button>
            <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 end-->
          </div>
        </div>
      </div>
    </template>
  </component>
</template>
<script>
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";

import dayjs from "@/compat/date/dayjs";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import ModalBase from "@/components/modals/ModalBase";
import SubModalBase from "@/components/modals/SubModalBase";
import { sendRequestGetAllMedicineClass } from "@/apis/pat-prescription";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// const _MESSAGE = "禁忌・アレルギーの医薬品が選択されています。反映してよろしいですか？";
const _MESSAGE = messageFormat(DIALOG_MESSAGES[13000115].message);
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end
import { 
  MEDICINE_TYPE,
  TABOO_CLASS_PREFIX,
  ALLERGY_CLASS_PREFIX,
  TABOO_ALLERGY_CLASS_PREFIX
} from "@/constants/patPrescriptionConstants";

export default {
  components: {
    ModalBase,
    SubModalBase
  },
  data() {
    return {
      // add #10225 処方薬剤選択に一般名処方が表示しない。yqz start
      currentPage: 1,
      pageSize: 100,
      allData: [],
      newGetDrugList: [],
      // add #10225 処方薬剤選択に一般名処方が表示しない。yqz end
      TABOO_CLASS_PREFIX: TABOO_CLASS_PREFIX,
      ALLERGY_CLASS_PREFIX: ALLERGY_CLASS_PREFIX,
      TABOO_ALLERGY_CLASS_PREFIX: TABOO_ALLERGY_CLASS_PREFIX,
      selectedRow: {
        medicineCd: null,
        genericCd: null,
        medicineType: null,
        medicineName: null,
        genericName: null,
        medicineTabooType: null,
        genericTabooType: null,
        unit: null,
        unitSecond: null
      },
      medicineClassList: [],
      keySelectedCount: 0,
      clickCounter: 0,
      clickTimer: null,
      searchFilter: {
        medicineName: "",
        genericName: "",
        classCd: null,
        facilityCd: "",
        patId: null
      },
      nullValue: null,
      contentAreaHeight: 550
    };
  },

  computed: {
    ...mapGetters("pat-prescription", [
      "getSelectedDrug",
      "getDrugList",
      "getIndexRow"
    ]),

    ...mapGetters("user", ["getFacilityCd"]),

    ...mapGetters("pat-info", ["selectedPatId"]),

    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("multi-sub-modal", {
      getSubModalName: "getModalName"
    }),
    // 薬剤と一般名処方を選択有無
    canSelect() {
      return this.selectedRow.medicineCd || this.selectedRow.genericCd;
    },

    medicineTabooPrefix() {
      switch(this.selectedRow.medicineTabooType) {
        case "1": return TABOO_CLASS_PREFIX;
        case "2": return ALLERGY_CLASS_PREFIX;
        case "3": return TABOO_ALLERGY_CLASS_PREFIX;
        default: return null;
      }
    },

    genericTabooPrefix() {
      switch(this.selectedRow.genericTabooType) {
        case "1": return TABOO_CLASS_PREFIX;
        case "2": return ALLERGY_CLASS_PREFIX;
        case "3": return TABOO_ALLERGY_CLASS_PREFIX;
        default: return null;
      }
    },

    detailAreaHeight() {
      return { height: `${this.contentAreaHeight}px` }
    },
    
    modalComponent() {
      // 処方セットマスタから呼び出しの場合はサブモーダル
      return this.isSubModal ? SubModalBase : ModalBase;
    },
    /** サブモーダルか否か(処方セットマスタから呼び出しの場合はサブモーダル) */
    isSubModal() {
      return this.getSubModalName !== "";
    }
  },

  watch: {
    windowHeight() {
      this.calculateTableHeight();
    },
    // add #10225 処方薬剤選択に一般名処方が表示しない。yqz start
    getDrugList(newVal, oldVal) {
      this.allData = newVal
      this.newGetDrugList = this.allData.slice(0, this.pageSize);
    },
    // add #10225 処方薬剤選択に一般名処方が表示しない。yqz end    
  },
  async created() {
    // 共通ローダー:表示開始
    this.setLoadingScreenMessage("処理中...");
    this.setLoadingScreenVisible(true);
    this.searchFilter.facilityCd = this.getFacilityCd;
    const res = await sendRequestGetAllMedicineClass(this.getFacilityCd, this.selectedPatId);
    this.medicineClassList = res.data;
    // mod FNSI5516処方薬剤選択画面の表示が遅い 周 start
    //this.searchDrug();
    await this.searchDrug();
    // mod FNSI5516処方薬剤選択画面の表示が遅い 周 end
    // 共通ローダー：表示終了
    this.setLoadingScreenVisible(false);
    this.calculateTableHeight();
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),

    ...mapActions("multi-modal", {
      hideMainModal: "hideModal"
    }),    
    ...mapActions("multi-sub-modal", {
      hideSubModal: "hideModal"
    }),

    ...mapActions("pat-prescription", ["setChildEditRecord", "setDrugList", "addDrugListFrom"]),

    // add FNSI5516処方薬剤選択画面の表示が遅い 周 start
    // スクロール時の動作設定
    async handleScroll() {
      const e = this.$refs.ntssList;
      // mod #5516 処方薬剤選択画面の表示が遅い 付 start
      const scrollHeight = e.scrollHeight
      const clientHeight = e.clientHeight
      const scrollTop = e.scrollTop
      // const isScrolledBottom = Math.abs(e.scrollTop + e.clientHeight - e.scrollHeight) < 4;
      // del #10225 処方薬剤選択に一般名処方が表示しない。yqz start
      // if (clientHeight + scrollTop === scrollHeight) {
      // // mod #5516 処方薬剤選択画面の表示が遅い 付 end
      //   this.searchFilter.medicineName = this.searchFilter.medicineName.trim();
      //   this.searchFilter.genericName = this.searchFilter.genericName.trim();
      //   this.searchFilter.patId = this.selectedPatId;
      //   this.searchFilter.offset = this.getDrugList.length;
      //   // mod #5516 処方薬剤選択画面の表示が遅い 付 start
      //   this.setLoadingScreenVisible(true);
      //   await this.addDrugListFrom(this.searchFilter);
      //   this.setLoadingScreenVisible(false);
      //   // this.addDrugListFrom(this.searchFilter);
      //   // mod #5516 処方薬剤選択画面の表示が遅い 付 end
      // }
      // del #10225 処方薬剤選択に一般名処方が表示しない。yqz end
      // add #10225 処方薬剤選択に一般名処方が表示しない。yqz start
      // mod #10225 処方薬剤選択に一般名処方が表示しない。yqz start
      if (scrollHeight - (clientHeight + scrollTop) < 10) {
        // if ((e.scrollHeight - (e.offsetHeight + e.scrollTop)) / e.scrollHeight <= 0) {
        // mod #10225 処方薬剤選択に一般名処方が表示しない。yqz end
        this.initPage();
      }
      // add #10225 処方薬剤選択に一般名処方が表示しない。yqz end      
    },
    // add FNSI5516処方薬剤選択画面の表示が遅い 周 end
    // add #10225 処方薬剤選択に一般名処方が表示しない。yqz start
    initPage() {
      this.currentPage = this.currentPage + 1;
      const newList1 = this.allData.slice(this.newGetDrugList.length, this.currentPage * this.pageSize);
      this.newGetDrugList.push(...newList1)
    },
    //add #10225 処方薬剤選択に一般名処方が表示しない。yqz end
    // 薬剤行を選択
    setSelectedRow(drug) {
      this.selectedRow = {
        medicineCd: drug.medicineCd,
        medicineType: drug.medicineType,
        genericCd: drug.genericCd,
        medicineName: drug.medicineName,
        genericName: drug.genericName,
        medicineTabooType: drug.medicineTabooType,
        genericTabooType: drug.genericTabooType,
        unit: drug.unit,
        unitSecond: drug.unitSecond,
        genUnitFirst: drug.genUnitFirst,
        genUnitSecond: drug.genUnitSecond,
        unitDecimalPoint: drug.unitDecimalPoint
      };
    },

    /**
     * 薬剤を反映 ボタン押下時の処理
     */
    setSelectedMedicineOption() {
      if (this.selectedRow && this.selectedRow.medicineCd) {
        this.setSelectedOption(this.selectedRow, false);
      }
    },
    
    /**
     * 選択した薬剤情報をストアに設定する
     * @param {*} drug 選択行データ
     * @param {*} isGeneric  一般名処方かのフラグ
     */
    setSelectedOption(drug, isGeneric = false) {
      // 禁忌・アレルギー医薬品かのフラグ
      const isTaboo = isGeneric ? drug.genericTabooType !== "0" : drug.medicineTabooType !== "0";
      const cd = isGeneric ? drug.genericCd : drug.medicineCd;
      // 禁忌・アレルギー医薬品の場合は接頭辞付き、それ以外はそのままの名前
      const name = isTaboo ? 
        (isGeneric ? this.genericTabooPrefix + drug.genericName : this.medicineTabooPrefix + drug.medicineName) : 
        (isGeneric ? drug.genericName : drug.medicineName);
      const unit = isGeneric ? this.selectedRow.genUnitFirst : this.selectedRow.unit;
      const unitSecond = isGeneric ? this.selectedRow.genUnitSecond : this.selectedRow.unitSecond;
      // 1: 薬剤マスタ、4: 一般名処方マスタ
      const type = isGeneric ? MEDICINE_TYPE.GENERIC : MEDICINE_TYPE.MEDICINE;
    
      const data = {
        index: this.getIndexRow,
        cd: cd,
        type: type,
        name: name,
        unitDecimalPoint: this.selectedRow.unitDecimalPoint,
        dataList: {
          unit: unit ?? "", // nullまたはundefinedの場合は空文字列
          unitSecond: unitSecond ?? ""
        }
      };
    
      if (isTaboo) {
        // 禁忌・アレルギー医薬品の場合はアラート表示
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000115].title,
          message: _MESSAGE,
          callback: answer => {
            if (answer === 1) {
              this.setChildEditRecord(data);
              this.hideModal();
            }
          }
        });
      } else {
        this.setChildEditRecord(data);
        this.hideModal();
      }
    },
    
    /**
     * 一般名処方を反映 ボタン押下時の処理
     */
    setSelectedGenericOption() {
      if (this.selectedRow && this.selectedRow.genericCd) {
        this.setSelectedOption(this.selectedRow, true);
      }
    },

    // 薬剤を検索
    // mod FNSI5516処方薬剤選択画面の表示が遅い 周 start
    //searchDrug() {
    async searchDrug() {
    // mod FNSI5516処方薬剤選択画面の表示が遅い 周 end
      //  add 10225処方薬剤選択に一般名処方が表示しない。 関  start
      this.setLoadingScreenMessage("処理中...");
      this.setLoadingScreenVisible(true);
      //  add 10225処方薬剤選択に一般名処方が表示しない。 関  end    
      this.selectedRow = {
        medicineCd: null,
        genericCd: null,
        medicineType: null
      };
      this.searchFilter.medicineName = this.searchFilter.medicineName.trim();
      this.searchFilter.genericName = this.searchFilter.genericName.trim();
      this.searchFilter.patId = !this.isSubModal ? this.selectedPatId : null;
      // mod FNSI5516処方薬剤選択画面の表示が遅い 周 start
      //this.setDrugList(this.searchFilter);
      await this.setDrugList(this.searchFilter);
      // mod FNSI5516処方薬剤選択画面の表示が遅い 周 end
      //  add 10225処方薬剤選択に一般名処方が表示しない。 関  start
      this.setLoadingScreenVisible(false);
      //  add 10225処方薬剤選択に一般名処方が表示しない。 関  end      
    },

    // 全て検索
    searchAll() {
      this.selectedRow = {
        medicineCd: null,
        genericCd: null,
        medicineType: null
      };
      this.searchFilter.medicineName = "";
      this.searchFilter.genericName = "";
      this.searchFilter.classCd = null;
      this.searchDrug();
    },

    calculateTableHeight() {
      let containerAreaHeight = getScopedElementById("container-area", this.$el || this)?.clientHeight || 0;
      let headerAreaHeight = getScopedElementById("header-area", this.$el || this)?.scrollHeight || 0;
      let detailAreaHeight = containerAreaHeight - headerAreaHeight - 10;
      //  mod no5047 薬剤選択モーダルの薬剤名が見切れる 張 start
      // this.contentAreaHeight = detailAreaHeight;
      this.contentAreaHeight = detailAreaHeight<300?550:detailAreaHeight;
      //  mod no5047 薬剤選択モーダルの薬剤名が見切れる 張 end
    },
    
    /** モーダルを閉じる */
    hideModal() {
      if (this.isSubModal) {
        // 処方セットマスタ → MultiSubModalStore.jsのhideModalを呼ぶ
        this.hideSubModal();
      } else {
        // 処方画面 → MultiModalStore.jsのhideModalを呼ぶ
        this.hideMainModal();
      }
    }
  }
};
</script>
<style scoped>
@media print {
  .print-height-auto{
    height: auto !important;
  }
}
.main-prescription-area {
  margin: 0 5px;
  height: 100%;
}

.container-area {
  height: 100%;
/* add no5047 薬剤選択モーダルの薬剤名が見切れる 張 start */
  min-height: 400px;
/* add no5047 薬剤選択モーダルの薬剤名が見切れる 張 end */
}

.header-details {
  width: 100%;
  border: solid 1px rgb(138, 138, 138);
}

.table-area {
  width: 100%;
  border-collapse: collapse;
}

.header-area {
  display: flex;
  flex-flow: column;
  justify-content: center;
  padding: 0 0.5em 0 0.5em;
}

.detail-area {
  display: flex;
  flex-flow: column;
  margin: 5px 0.5em 0 0.3em;
  height: 550px;
  overflow-y: scroll;
}

tr {
  width: 100%;
}

th,
td {
  width: 32.6% !important;
  padding: 0;
}

.btn-search {
  width: 5rem;
  height: 1.6rem;
  padding: 0;
  margin: 3px 5px;
  font-size: 1em;
}

.title-search {
  display: flex;
  align-items: center;
  /* box-shadow: 0 2px 2px 0 rgba(255,255,255,.2) inset,0 2px 20px 0 rgba(255,255,255,.5) inset,0 -2px 2px 0 rgba(0,0,0,.1); */
}

.btn-search-wrapper {
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.input-search-title {
  display: flex;
  align-items: center;
}

.input-row {
  width: 98.5%;
  margin: 5px 0;
}

ons-input :deep(.text-input) {
  font-size: 15px;
}

ons-select {
  width: 100%;
  background: white;
}

#clear-btn {
  font-size: 100%;
}

/* mod FutreNetWeb+SI課題管理 NO.4889 劉全航 start */
/* .ntss-list-body-td.ntss-pat-event-label a {
  display: flex;
  width: 100%;
  text-decoration: none;
  align-items: center;
  height: 35px;
} */
.ntss-pat-event-label a {
  display: flex;
  width: 100%;
  text-decoration: none;
  align-items: center;
  /* height: 35px; */
  color: var(--pat-event-text-color);
}

.ntss-list-body-td-0 {
  background-color: var(--ntss-list-content-2nd-background-color);
}

.ntss-list-body-td-1 {
  background-color: var(--ntss-list-item-background-color);
}
/* mod FutreNetWeb+SI課題管理 NO.4889 劉全航 end */

.selected-row {
  background: rgb(0, 118, 255) !important;
}

.color-shadow {
  box-shadow: 0 2px 2px 0 rgba(255,255,255,.2) inset,0 2px 20px 0 rgba(255,255,255,.5) inset,0 -2px 2px 0 rgba(0,0,0,.1);
}

.custom-table-row-data td {
  /* mod FutreNetWeb+SI課題管理 NO.4889 劉全航 start */
  /* padding: 5px; */
  height: 2em;
  color: #333333;
  border-color: #dee2e6;
  /* mod FutreNetWeb+SI課題管理 NO.4889 劉全航 end */
}

.custom-table-area th, .custom-table-area td{
  border-style: hidden;
  box-shadow: 0 0 0 0.5px var(--ntss-list-border-color);
}

#clear-btn,
#search-btn {
  /* mod FutreNetWeb+SI課題管理-NO.4798 劉全航 start */
  /* height: 2em; */
  height: 2.0em;
  width: 100px;
  /* mod FutreNetWeb+SI課題管理-NO.4798 劉全航 end */
  margin: 0 0.5em;
}

.ntss-pat-pre-td {
  color: var(--pat-event-text-color);
}
/* add no5047 薬剤選択モーダルの薬剤名が見切れる 張 start */
.my-flex-container{
  margin: 3px !important;
}
/* add no5047 薬剤選択モーダルの薬剤名が見切れる 張 end */
</style>
