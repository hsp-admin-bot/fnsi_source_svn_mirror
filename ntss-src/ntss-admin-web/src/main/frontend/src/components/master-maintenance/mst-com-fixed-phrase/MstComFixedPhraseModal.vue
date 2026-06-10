<template>
  <div :class="['main-area', modalMessageSize]">
    <div class="upper">
    <v-ons-row class="custom-row">
      <div class="item">
        <span style="line-height:2.5rem;">定型文</span>
      </div>
      <v-ons-col>
        <com-textarea
          :content="fixedPhraseInputValue"
          idTextarea="com-textarea-fixed-phrase"
          cssClass="item-textarea textarea-resize-vertical"
          @set-content-data="setContentData"
          @change="changeButton"
        />
      </v-ons-col>
    </v-ons-row>
    </div>
    <!-- 職種選択エリア -->
    <div class="bed-select-area">
      <div class="select-upper">
      <v-ons-row>
        <v-ons-col class="color-header item-word">
          職種選択
        </v-ons-col>
      </v-ons-row>

      <!-- フリーワード抽出 -->
      <v-ons-row class="freeword-area">
        <v-ons-col class="item-word-noborder">
          フリーワード検索
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="freeword-area">
        <v-ons-input v-model="freeWord" />
      </v-ons-row>
      </div>
      <!-- 選択リスト -->
      <v-ons-row class="select-area">
        <!-- 未選択 -->
        <v-ons-col>
          <selection-list
            class="item-word select-item-list"
            :item-list="unselectedItemList"
            @check="toggleCheckUnselectedList"
          />
        </v-ons-col>

        <v-ons-col class="select-item">
          <div class="select-button-area d-flex flex-column">
            <button
              class="k-button k-button-icon"
              @click="selectAllItem"
              :disabled="false"
            >
              <span class="k-icon k-i-arrow-double-60-right"></span>
            </button>

            <button
              class="k-button k-button-icon"
              @click="selectItem"
              :disabled="false"
            >
              <span class="k-icon k-i-arrow-60-right"></span>
            </button>

            <button
              class="k-button k-button-icon"
              @click="unselectItem"
              :disabled="false"
            >
              <span class="k-icon k-i-arrow-60-left"></span>
            </button>

            <button
              class="k-button k-button-icon"
              @click="unselectAllItem"
              :disabled="false"
            >
              <span class="k-icon k-i-arrow-double-60-left"></span>
            </button>
          </div>
        </v-ons-col>

        <!-- 選択 -->
        <v-ons-col>
          <selection-list
            class="item-word select-item-list"
            :item-list="selectedList"
            @check="toggleCheckSelectedList"
          />
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import selectionList from "@/components/common/list-selector/SelectionList.vue";
import { createItemListData } from "@/functions/for-componet/ListSelector.js";
import CommonTextArea from "@/components/common/CommonTextArea";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
import {EventBus} from "@/eventBus";

export default {
  components: {
    "selection-list": selectionList,
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      // 職種マスタ
      mstJob: null,
      // 選択済みの職種
      selectedOccupations: [],
      // フリーワード検索
      freeWord: "",
      // 職種未選択リスト
      unselectedItemList: [],
      // 職種選択リスト
      selectedList: [],

      /**
       * @description 「定型文」入力値
       */
      fixedPhraseInputValue: {
        initValue: "",
        editValue: ""
      },

    };
  },

  computed: {
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch"}),
    ...mapGetters("master-maintenance", ["getColumns", "getEditRecord"]),
    ...mapGetters("user", { facility_cd: "getFacilityCd" }),
    ...mapGetters("account-edit", ["getFontSize"]),
    /**
     * @description 職種選択肢(選択済み・未選択)
     * @returns { Object }
     * cd: 職種コード
     * class1: 絞り込み1
     * class2: 絞り込み2
     * isChecked: 選択フラグ
     * isSelected: 選択済みフラグ
     * name: 職種名称
     */
    selectionList() {
      if (this.mstJob === null) {
        return [];
      }
      return this.mstJob.map(item => {
        // 選択済みフラグ
        let isSelected = false;

        // 各情報を設定
        if (this.selectedOccupations.length > 0) {
          // 職種が選択済みの場合
          if (this.selectedOccupations.includes(item.cd)) {
            isSelected = true;
          }
        }
        return { ...item, isChecked: false, isSelected };
      });
    },

    /**
     * @description フリーワードによる絞り込み職種リスト
     */
    filteredList() {
      const regexp = new RegExp(`.*${this.freeWord}.*`);
      const filteredList = this.selectionList.filter(record => {
        return regexp.test(record.name);
      });
      return filteredList;
    },

    modalMessageSize() {
      switch (+this.getFontSize) {
        case 0:
          return "small";
        case 1:
          return "medium";
        case 2:
          return "big";
        case 3:
          return "xbig";
        default:
          return "";
      }
    }
  },

  watch: {
    filteredList() {
      this.unselectedItemList = this.filteredList.filter(
        item => !item.isSelected
      );
    },

    selectionList() {
      this.selectedList = this.selectionList.filter(item => item.isSelected);
    },
    getFontSize(value) {
      this.calculateGridHeight(value);
    }
  },
  mounted() {
    this.calculateGridHeight()
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
  },

  async created() {
    this.setLoadingScreenVisible(true);
    // DB登録済みの職種コードを取得し設定
    const occupations = this.getEditRecord.occupations ? JSON.parse(this.getEditRecord.occupations) : null;
    this.selectedOccupations = occupations === null ? [] : occupations;

    // 共通定型文マスタ取得
    const responseJob = await ApiHelper.get(
      `/master_maintenance/mst_user/mst_job/${this.getFacilitySwitch}`
    ).catch(() => {
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      getErrorMessage('MstComFixedPhraseModal.vue', 'created', 'マスタ取得失敗');
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      throw new Error("マスタ取得失敗");
    });
    // リスト表示形式へ変換
    this.mstJob = createItemListData(responseJob.data, "jobCd", "jobName");

    // 定型文を設定
    this.fixedPhraseInputValue.initValue = this.getEditRecord.name;
    this.fixedPhraseInputValue.editValue = this.getEditRecord.name;
    this.$nextTick(() => {
      const element = document.getElementById("com-textarea-fixed-phrase");
      this.resizeTextarea(element);
    });

    /* add 職種デフォルトを全件対象扱いとする 楊zc start */
    if(this.getEditRecord.isDel === "") {
      this.unselectedItemList = this.filteredList.filter(
        item => !item.isSelected
      );
      this.selectAllItem();
    }
    /* add 職種デフォルトを全件対象扱いとする 楊zc start */
  },

  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    calculateGridHeight(value){
      document.getElementsByClassName("multi-select-list")[0].style.fontSize = ""
      let newHeight = document.getElementsByClassName("modal-body")[0].clientHeight - document.getElementsByClassName("upper")[0].clientHeight-
                      document.getElementsByClassName("select-upper")[0].clientHeight - 70;
      if(value == "0") {
        document.getElementsByClassName("multi-select-list")[0].style.fontSize = "15px"
      }
      if(value == "1") {
        document.getElementsByClassName("multi-select-list")[0].style.fontSize = "17px"
      }
      if(value == "2") {
        document.getElementsByClassName("multi-select-list")[0].style.fontSize = "19px"
      }
      if(value == "3") {
        document.getElementsByClassName("multi-select-list")[0].style.fontSize = "21px"
      }
      document.getElementsByClassName("multi-select-list")[0].style
      document.getElementsByClassName("select-area")[0].style.height = newHeight + "px"
    },
    /**
     * @description 定型文更新
     */
    setBedName(value) {
      const name = value;
      this.setEditRecord({ ...this.getEditRecord, name });
    },

    /**
     * @description 職種を選択状態切り替え
     * @summary 子イベントで発火
     * @param {Object} { checkedIndex(チェック項目インデックス), isChecked(チェック状態) }
     */
    toggleCheckUnselectedList({ checkedIndex, isChecked }) {
      this.unselectedItemList[checkedIndex].isChecked = isChecked;
    },

    /**
     * @description 職種を選択状態切り替え
     * @summary 子イベントで発火
     * @param {Object} { checkedIndex(チェック項目インデックス), isChecked(チェック状態) }
     */
    toggleCheckSelectedList({ checkedIndex, isChecked }) {
      this.selectedList[checkedIndex].isChecked = isChecked;
    },

    /**
     * @description 全職種を選択済みリストへ
     */
    selectAllItem() {
      const selectedList = this.unselectedItemList.map(item => {
        return { ...item, isChecked: false, isSelected: true };
      });
      this.setOccupations([...this.selectedList, ...selectedList]);
      this.changeButton();
    },

    /**
     * @description 選択した職種を選択済みリストへ
     */
    selectItem() {
      const selectedList = this.unselectedItemList.map(item => {
        if (item.isChecked) {
          item.isChecked = false;
          item.isSelected = true;
          return item;
        }
        return item;
      });
      this.setOccupations([...this.selectedList, ...selectedList]);
      this.changeButton();
    },

    /**
     * @description 選択した職種を未選択リストへ
     */
    unselectItem() {
      const selectedList = this.selectedList.map(item => {
        if (item.isChecked) {
          item.isChecked = false;
          item.isSelected = false;
          return item;
        }
        return item;
      });
      this.setOccupations(selectedList);
      this.changeButton();
    },

    /**
     * @description 全職種を未選択リストへ
     */
    unselectAllItem() {
      const selectedList = this.selectedList.map(item => {
        return { ...item, isChecked: false, isSelected: false };
      });
      this.setOccupations(selectedList);
      this.changeButton();
    },

    /**
     * @description ベッドグループに含めるベッド一覧情報を更新
     * @param {Object} list 未選択リスト + 選択済みリスト
     */
    setOccupations(list) {
      // 選択済みリストを取得
      const selectedList = list.filter(item => item.isSelected);
      // 選択済みから職種コードリスト取得
      const occupations = selectedList.map(item => item.cd);

      // マスタ更新
      this.setEditRecord({
        ...this.getEditRecord,
        occupations: JSON.stringify(occupations)
      });
      // 画面更新
      this.selectedOccupations = occupations;
    },

    setContentData(newValue) {
      this.fixedPhraseInputValue.editValue = newValue;
      //mod マスタ詳細画面がありません破棄メッセージ 张博 start
      if (this.fixedPhraseInputValue.initValue!==this.fixedPhraseInputValue.editValue) {
        this.changeButton();
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }
      //mod マスタ詳細画面がありません破棄メッセージ 张博 end
      this.setBedName(newValue);
    },

    resizeTextarea(el) {
      el.style.height = `${el.scrollHeight + 5}px`;
    },
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    }
  }
};
</script>

<style scoped>
@media print {
  .select-area {
    height: auto !important;
  }
}
.main-area {
  margin: 0 5px;
  overflow-y: auto;
  min-width: 450px;
}

.item-word {
  padding: 2px;
  border: 1px solid #d3d3d3;
}

/* add 画面のレイアウト、部品修正 楊zc start */
.item-word-noborder {
  padding: 2px;
}

.item {
  height: 2.5rem;
  width: 5rem;
}
/* add 画面のレイアウト、部品修正 楊zc end */

div >>> .item-textarea {
  width: 100%;
  box-sizing: border-box;
  padding: 5px 0;
}

.freeword-area {
  width: 30.5vw;
}

.bed-select-area {
  margin-top: 10px;
}

.select-area {
  margin-top: 10px;
}

.select-button-area {
  width: 100%;
  min-width: 60px;
}

.select-button {
  /*width: 40%;*/
  width: 60%;
  max-width: 8em;
  padding: 1px;
  margin-bottom: 2px;
}

.k-button {
  margin: auto;
  box-shadow: none;
  margin-bottom: 0.4em;
}

.select-item {
  display: flex;
  align-items: center;
  text-align: center;
}

.select-item-list {
  height: 100%;
  width: 35vw;
}
.custom-row {
  height: auto;
}
.main-area {
  overflow-y: auto;
}
.main-area.small {
  max-height: calc(100% - 24px);
}

.main-area.medium {
  max-height: calc(100% - 14px);
}

.main-area.big {
  max-height: calc(100% - 11px);
}

.main-area.xbig {
  max-height: calc(100% - 5px);
}
</style>
