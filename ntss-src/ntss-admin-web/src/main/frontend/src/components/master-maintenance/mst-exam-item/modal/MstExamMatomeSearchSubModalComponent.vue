/**
 * 臨床検査マスタ検索
 *
 */
<template>
  <modal-base @onClose="cancel">
    <div slot="body" class="main-content">
      <div class="filter-content">
        <v-ons-row>
          <!-- #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng start -->
          <!-- <v-ons-col> -->
          <v-ons-col width="6.5em">
          <!-- #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng end -->
            <label id="filter_content_title">フリーワード</label>
          </v-ons-col>
          <!-- #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng start -->
          <!-- <v-ons-col width="65%"> -->
          <v-ons-col>
          <!-- #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng end -->
            <v-ons-input
              type="text"
              input-id="searcg-text"
              style="font-size: inherit;"
              v-model="strToSearch.inProgress"
              @keydown.enter="onSearch">
            </v-ons-input>
          </v-ons-col>
          <!-- #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng start -->
          <!-- <v-ons-col width="10%"> -->
          <v-ons-col width="6.5em">
          <!-- #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng end -->  
            <div class="registration-btn-area" style="background:none">
              <button
                class="button registration-btn btn3-normal"
                style="margin-left: 20px;height: 2em; min-width: 5em;"
                :disabled="!hasInputSearchText"
                @click="onSearch">検索</button>
            </div>
          </v-ons-col>
        </v-ons-row>
      </div>
      <div class="list-content">
        <div class="scroll-table">
          <table id="sys-medicine-list" class="ntss-list" style="position: inherit;">
            <thead>
              <tr>
                <th class="ntss-list-header-th-sticky" style="width:20%">JLAC10ｺｰﾄﾞ（１７桁）</th>
                <th class="ntss-list-header-th-sticky" style="width:25%">名称（固有）</th>
                <!-- #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng start -->
                <!-- <th class="ntss-list-header-th-sticky" style="width:25%">測定法</th>
                <th class="ntss-list-header-th-sticky" style="width:20%">材料</th> -->
                <th class="ntss-list-header-th-sticky" style="width:25%; min-width: 200px">測定法</th>
                <th class="ntss-list-header-th-sticky" style="width:20%; min-width: 150px">材料</th>
                <!-- #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng end -->
                <th class="ntss-list-header-th-sticky" style="width:10%">単位</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(data, index) in mstExamMatomeFilterData"
                class="ntss-list-body-tr"
                @click="onSelectRow(index)"
                @dblclick="onDoubleClick"
                :key=index
                :id="'sys-medicine-row-' + index">
                <!-- JLAC10ｺｰﾄﾞ（１７桁） -->
                <td class="ntss-list-body-td">{{ data.examMatomeCd }}</td>
                <!-- 名称（固有） -->
                <td class="ntss-list-body-td">{{ data.resultRecognitionInherentName }}</td>
                <!-- 測定法 -->
                <td class="ntss-list-body-td">{{ data.assayName }}</td>
                <!-- 材料 -->
                <td class="ntss-list-body-td">{{ data.materialName }}</td>
                <!-- 単位 -->
                <td class="ntss-list-body-td">{{ data.referenceUnit }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <button class="button denial-btn btn2-cancel" @click="cancel">キャンセル</button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <button class="button registration-btn btn1-execute" :disabled="!isSelected" @click="reflect">確定</button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import SubModalBase from "@/components/modals/SubModalBase";
import MultiSubModalMixin from "@/components/modals/MultiSubModalMixin";
import { EventBus } from "@/eventBus.js";
import { ApiHelper } from "@/apis/AxiosHelper.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end

export default {
  // mixinの読込
  mixins: [MultiSubModalMixin],

  components: {
    "modal-base": SubModalBase
  },
  data() {
    return {
      /**
       * 臨床検査マスタ(全データ)
       */
      mstExamMatomeData: [],
      /**
       * フィルタした臨床検査マスタ
       */
      mstExamMatomeFilterData:[],
      /**
       * 行選択フラグ
       * ※確定ボタンの活性/非活性制御に使用
       */
      isSelectedExamMatome: false,
      /**
       * 検索文字列
       */
      strToSearch: {
        inProgress: "", // 入力中の文字列にバインドする。「検索」ボタン押下時にinUsedへコピーされる。
        inUsed: "" // 実際に検索に使われる文字列
      },
      getMstExamMatomeAll:[]
    };
  },
  methods: {
    ...mapActions("mst-exam-matome", ["setSelectedMstExamMatome"]),
    ...mapActions("loading-screen", {
        setLoadingScreenVisible: "setLoadingScreenVisible",
        setLoadingScreenMessage: "setLoadingScreenMessage"
      }),
    /**
     * 初期処理
     */
    async init() {
    // 検索用APIコール
      // add マスタ一覧 施設切替を可能とする 王 start
    const requestParam = {
      // facilityCd: this.getFacilityCd
      facilityCd: this.getFacilitySwitch
    };
      // add マスタ一覧 施設切替を可能とする 王 end
    await Promise.all([
      await ApiHelper.get(`/mstInfo/mstExamMatome`,requestParam)
        .then(response =>{
          this.getMstExamMatomeAll = response.data;
          this.mstExamMatomeData = response.data.map(d => {
            // 検索用文字列作成
            d.searchText =
            [
              d.examMatomeCd,
              d.resultRecognitionInherentName,
              d.assayName,
              d.materialName,
              d.referenceUnit,
            ];
            return d;
          });
          //フィルタデータに取得した全データを設定
          this.mstExamMatomeFilterData = this.mstExamMatomeData;
        })
      ])
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstExamMatomeSearchSubModalComponent.vue', 'init', '臨床検査マスタの取得に失敗しました');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          console.log("臨床検査マスタの取得に失敗しました.", error);
        });
    },
    /**
     * キャンセルボタン押下時イベント処理
     */
    cancel() {
      // Store内の選択した臨床検査マスタ情報をクリア.
      this.setSelectedMstExamMatome(null);
      // モーダルを閉じる.
      this.hideModal();
    },
    /**
     * 確定ボタン押下時イベント処理
     * ※呼出元の`applyMstExamMatome`を呼びだします.
     */
    reflect() {
      // 行選択イベントにて選択された臨床検査マスタは格納済なので、
      // 確定ボタン押下時の処理はモーダルを閉じるのみ.
      EventBus.$emit("applyMstExamMatome");
      this.hideModal();
    },
    /**
     * 検索ボタン押下時イベント
     */
    onSearch() {
      // 選択クリア
      this.clearSelectRow();
      // 入力確定された文字列
      this.strToSearch.inUsed = this.strToSearch.inProgress;
      // 入力確定された文字列がnull若しくは空文字の場合には全データを表示用データに設定
      if (!this.strToSearch.inUsed || this.strToSearch.inUsed === "") {
        this.mstExamMatomeFilterData = this.mstExamMatomeData;
        return;
      }
      // 入力文字を含むレコードに絞り込む
      this.mstExamMatomeFilterData = this.mstExamMatomeData.filter(s => {
        return s.searchText.some(text => text === null
          ? false
          : text.indexOf(this.strToSearch.inUsed) > -1
        );
      });
    },
    /**
     * 選択行をクリアする.
     * selected-rowをclassにもつ要素を取得し、classからselected-rowを削除する.
     */
    clearSelectRow() {
      // 選択済の行をクリアする.
      Array.from(document.getElementsByClassName("selected-row")).forEach(element => {
        element.classList.remove("selected-row");
      });
      // 選択済フラグ
      this.isSelectedExamMatome = false;
    },
    /**
     * 行クリック時のイベント
     */
    onSelectRow(index) {
      // 選択行をクリア
      this.clearSelectRow();
      // クリック要素取得
      const clickElement = document.getElementById("sys-medicine-row-" + index);
      // 要素無し.
      if (!clickElement) {
        return;
      }
      // クラス付与
      clickElement?.classList?.add("selected-row");
      // 選択済フラグ
      this.isSelectedExamMatome = true;
      // Storeに選択された標準医薬品マスタ情報を格納する.
      this.setSelectedMstExamMatome(this.mstExamMatomeFilterData[index]);
    },
    /**
     * 行ダブルクリック時のイベント
     * ※イベント発火時の処理は、確定処理と同じ.
     * ※このイベント発火前に行選択イベント(onSelectRow)が発火する.
     */
    onDoubleClick() {
      this.reflect();
    },
  },
  /**
   * computed
   */
  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("mst-exam-matome", ["getSearchMstExamMatomeCd"]),
    /**
     * 臨床検査マスタが選択されているか否かを返す.
     * @returns true : 選択済、false : 未選択
     */
    isSelected() {
      return this.isSelectedExamMatome;
    },
    /**
     * 検索文字列が入力されているか否かを返す.
     * @returns true : 入力済、false : 未入力(null or empty)
     */
    hasInputSearchText() {
      //return !this.strToSearch.inProgress || this.strToSearch.inProgress === "" ? false : true;
      return true;
    }
  },
  /**
   * created
   */
  async created() {
    this.setLoadingScreenMessage("処理中...");
    this.setLoadingScreenVisible(true);
    // 初期処理
    await this.init();
    if (this.getSearchMstExamMatomeCd) {
      this.strToSearch.inProgress = this.getSearchMstExamMatomeCd
      this.onSearch();
    }
    this.setLoadingScreenVisible(false);
  }
}
</script>

<style scoped>
/**
 * メインエリアのスタイル
 */
.main-content {
  height: calc(100% - 5px);
  overflow: hidden;
}
/**
 * 絞込条件部のスタイル
 */
.filter-content {
  background-color: inherit;
  background-image: none;
  font-family: inherit;
  /* #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng start */
  /* padding: 0.5em; */
  padding: 0.5em 0.5em 0 0.5em;
  /* #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng end */
}
/**
 * 絞込条件エリア内のons-rowのスタイル
 */
.filter-content >>> ons-row {
  margin-top: 5px;
}
/* add #10826 フリーワードのフォントが表のフォントと異なる。 linjunfeng start */
.filter-content >>> input {
  font-family: inherit;
}
/* add #10826 フリーワードのフォントが表のフォントと異なる。 linjunfeng end */
/**
 * 絞込条件のラベルのスタイル
 */
#filter_content_title {
  vertical-align: -webkit-baseline-middle;
  /* del #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng start */
  /* font-size: 1.5em;
  margin-left: 10px; */
  /* del #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng end */
}
/**
 * 一覧部の大枠のスタイル
 */
.list-content {
  /* #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng start */
  /* height: calc(100% - 60px); */
  height: calc(100% - 40px);
  /* #10826 検査項目マスタ＞詳細＞臨床検査マスタ検索 linjunfeng end */
}
/**
 * 一覧部のスタイル
 */
.scroll-table {
  overflow: auto;
  width: calc(100% - 20px);
  margin: 10px;
  height: calc(100% - 1em);
}
/**
 * 選択行のスタイル
 * ※選択行の色はマスタメンテナンス画面で選択された時の色に合わせる.
 */
.selected-row {
  background-color: var(--master-maintenance-kgrid-selected-background-color) !important;
}
/**
 * 偶数行の背景色の設定
 */
tr:nth-child(2n){
  background-color: var(--ntss-list-content-2nd-background-color);
  color: var(--ntss-list-body-color);
}
</style>
