/**
 * 標準医薬品マスタ検索モーダル
 * 本モーダルにて選択された医薬品はStoreに格納されます。
 * キャンセルボタンがクリックされた場合、Storeにはnullが設定されます。
 * また、確定ボタンクリックされた場合の処理については、呼出元で`applySysMedicineSubModal()`を実装して下さい。
 * ※Storeから選択された医薬品を取得し、適宜処理を行って下さい。
 *
 * computed に以下を追加して下さい。
 * // 標準医薬品マスタ検索モーダルStore
 * ...mapGetters("sys-medicine-sub-modal",["getSelectedSysMedicine"]),
 */
<template>
  <modal-base @onClose="cancel">
    <div slot="body" class="main-content">
      <div class="filter-content">
        <v-ons-row>
          <v-ons-col width="9em">
            <label id="filter_content_title">フリーワード</label>
          </v-ons-col>
          <v-ons-col width="60%">
            <v-ons-input
              type="text"
              input-id="searcg-text"
              style="font-size: inherit;"
              v-model="strToSearch.inProgress"
              @blur="changeSearch"
              @keydown.enter="onSearch">
            </v-ons-input>
          </v-ons-col>
          <v-ons-col width="16%">
            <div class="registration-btn-area" style="background:none">
              <!-- mod 画面デザイン 對應 王 start-->
              <!-- <button-->
              <!-- class="button registration-btn btn3-normal"-->
              <!-- style="margin-left: 20px;height: 2em; min-width: 5em;"-->
              <!-- :disabled="!hasInputSearchText"-->
              <!-- @click="onSearch">検索</button>-->
              <button
                class="button registration-btn btn3-normal"
                style="margin-left: 20px;height: 2em; min-width: 5em;"
                :disabled="!hasInputSearchText"
                @click="onSearch">検索</button>
              <!-- mod 画面デザイン 對應 王 end-->
            </div>
          </v-ons-col>
        </v-ons-row>
      </div>
      <div class="list-content">
        <div class="scroll-table" ref="scrollDiv"  >
          <table id="sys-medicine-list" class="ntss-list" style="position: inherit;">
            <thead>
              <tr>
                <th class="ntss-list-header-th-sticky" style="min-width:500px">医薬品名</th>
                <th class="ntss-list-header-th-sticky" style="min-width:150px">販売会社</th>
                <th class="ntss-list-header-th-sticky" style="min-width:200px">規格単位</th>
                <th class="ntss-list-header-th-sticky" style="min-width:50px">区分</th>
                <th class="ntss-list-header-th-sticky" style="min-width:60px">HOTコード</th>
                <th class="ntss-list-header-th-sticky" style="min-width:50px">JANコード</th>
                <th class="ntss-list-header-th-sticky" style="min-width:50px">YJコード</th>
                <th class="ntss-list-header-th-sticky" style="width:40px">薬価基準収載医薬品コード</th>
                <th class="ntss-list-header-th-sticky" style="width:30px">包装形態</th>
                <th class="ntss-list-header-th-sticky" style="width:30px">包装単位</th>
                <th class="ntss-list-header-th-sticky" style="width:30px">包装単位単位</th>
                <th class="ntss-list-header-th-sticky" style="width:30px">包装総量数</th>
                <th class="ntss-list-header-th-sticky" style="width:30px">包装総量単位</th>
                <th class="ntss-list-header-th-sticky" style="width:30px">指示単位</th>
                <th class="ntss-list-header-th-sticky" style="width:30px">レセ単位</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(data, index) in sysMedicineFilterData"
                class="ntss-list-body-tr"
                @click="onSelectRow(index)"
                @dblclick="onDoubleClick"
                :key=index
                :id="'sys-medicine-row-' + index">
                <!-- 医薬品名 -->
                <td class="ntss-list-body-td">{{ data.receiptMedicineName }}</td>
                <!-- 販売会社 -->
                <td class="ntss-list-body-td">{{ data.salesCompany }}</td>
                <!-- 規格単位 -->
                <td class="ntss-list-body-td">{{ data.standardUnit }}</td>
                <!-- 区分 -->
                <td class="ntss-list-body-td">{{ getClass(data.usageCategoryClass) }}</td>
                <!-- HOTコード -->
                <td class="ntss-list-body-td">{{ data.standardNo }}</td>
                <!-- JANコード -->
                <td class="ntss-list-body-td">{{ data.janCd }}</td>
                <!-- YJコード -->
                <td class="ntss-list-body-td">{{ data.standardMedicineCd }}</td>
                <!-- 薬価基準収載医薬品コード -->
                <td class="ntss-list-body-td">{{ data.drugPriceStandardCd }}</td>
                <!-- 包装形態 -->
                <td class="ntss-list-body-td">{{ data.pkgPresentation }}</td>
                <!-- 包装単位数 -->
                <td class="ntss-list-body-td">{{ data.pkgAmount }}</td>
                <!-- 包装単位単位 -->
                <td class="ntss-list-body-td">{{ data.pkgUnit }}</td>
                <!-- 包装総量数 -->
                <td class="ntss-list-body-td">{{ data.pkgTotalAmount }}</td>
                <!-- 包装総量単位 -->
                <td class="ntss-list-body-td">{{ data.pkgTotalUnit }}</td>
                <!-- 指示単位 -->
                <td class="ntss-list-body-td">{{ data.unit }}</td>
                <!-- レセ単位 -->
                <td class="ntss-list-body-td">{{ data.unitSecond }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <!-- mod 画面デザイン 對應 王 start-->
        <!-- <button class="button denial-btn" @click="cancel">キャンセル</button>-->
        <button class="button denial-btn btn2-cancel" @click="cancel">キャンセル</button>
        <!-- mod 画面デザイン 對應 王 end-->
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- mod 画面デザイン 對應 王 start-->
        <!-- <button class="button registration-btn" :disabled="!isSelected" @click="reflect">確定</button>-->
        <button class="button registration-btn btn1-execute" :disabled="!isSelected" @click="reflect">確定</button>
        <!-- mod 画面デザイン 對應 王 end-->
      </div>
    </div>
  </modal-base>
</template>

<script>
import { mapActions } from "vuex";
import SubModalBase from "@/components/modals/SubModalBase";
import MultiSubModalMixin from "@/components/modals/MultiSubModalMixin";
import { EventBus } from "@/eventBus.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
/* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --start */
import {ApiHelper} from "@/apis/AxiosHelper";
/* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --end */
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
import debounce from 'lodash/debounce';

export default {
  // mixinの読込
  mixins: [MultiSubModalMixin],

  components: {
    "modal-base": SubModalBase
  },
  data() {
    return {
      /**
       * 標準医薬品マスタ(全データ)
       */
      sysMedicineData: [],
      /**
       * フィルタした標準医薬品マスタ
       */
      sysMedicineFilterData:[],
      /**
       * 行選択フラグ
       * ※確定ボタンの活性/非活性制御に使用
       */
      isSelectedMedicine: false,
      /**
       * 検索文字列
       */
      strToSearch: {
        inProgress: "", // 入力中の文字列にバインドする。「検索」ボタン押下時にinUsedへコピーされる。
        inUsed: "" // 実際に検索に使われる文字列
      },
      /**
       * 区分変換テーブル
       */
      convertClass: {
        "1" : "内服",
        "2" : "外用",
        "3" : "注射",
        "4" : "歯科",
      },
      endingPoint: 10,
      /* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --start */
      offset: 0,
      keyword: "isNullOrEmpty",
      scrollTop: 0,
      /* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --end */
      isSearchStatue: true
    };
  },
  methods: {
    ...mapActions("sys-medicine-sub-modal", ["setSelectedSysMedicine", "getSysMedicineAll"]),
    ...mapActions("loading-screen", {setLoadingScreenVisible: "setLoadingScreenVisible"}),
    /**
     * 初期処理
     */
    async init() {
      // 検索用APIコール
      await Promise.all([this.getSysMedicineAll()])
        .then(response =>{
          /* modify by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --start */
          /*this.sysMedicineData = response[0].data.map(d => {
            // 検索用文字列作成
            d.searchText =
              [
                d.receiptMedicineName,
                d.salesCompany,
                d.standardUnit,
                this.getClass(d.usageCategoryClass),
                d.standardNo,
                d.janCd,
                d.standardMedicineCd,
                d.drugPriceStandardCd,
                d.pkgPresentation,
                // ゼロも有効な数値としてみなす
                d.pkgAmount !== null ? String(d.pkgAmount) : "",
                d.pkgUnit,
                // ゼロも有効な数値としてみなす
                d.pkgTotalAmount !== null ? String(d.pkgTotalAmount) : "",
                d.pkgTotalUnit
              ];
            return d;
          });
          // フィルタデータに取得した全データを設定
          this.sysMedicineFilterData = this.sysMedicineData.slice(0, 100);*/
          this.sysMedicineFilterData = response[0].data;
          /* modify by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --end */

        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('SysMedicineSearchSubModalComponent.vue', 'init', '標準医薬品マスタの取得に失敗しました.');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          console.log("標準医薬品マスタの取得に失敗しました.", error);
        });
    },
    /**
     * キャンセルボタン押下時イベント処理
     */
    cancel() {
      // Store内の選択した標準医薬品マスタ情報をクリア.
      this.setSelectedSysMedicine(null);
      // モーダルを閉じる.
      this.hideModal();
    },
    /**
     * 確定ボタン押下時イベント処理
     * ※呼出元の`applySysMedicineSubModal`を呼びだします.
     */
    reflect() {
      // 行選択イベントにて選択された標準医薬品マスタは格納済なので、
      // 確定ボタン押下時の処理はモーダルを閉じるのみ.
      EventBus.$emit("applySysMedicineSubModal");
      this.hideModal();
    },
    /**
     * 検索ボタン押下時イベント
     */
    onSearch() {
      this.setLoadingScreenVisible(true);
      // 選択クリア
      this.clearSelectRow();
      /* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --start */
      this.offset = 0;
      this.hasLoadAllFlag = false;
      this.$refs.scrollDiv.scrollTo(0,0);
      /* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --end */
      // 入力確定された文字列
      this.strToSearch.inUsed = this.strToSearch.inProgress;
      /* modify by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --start */
      /*// 入力確定された文字列がnull若しくは空文字の場合には全データを表示用データに設定
      if (!this.strToSearch.inUsed || this.strToSearch.inUsed === "") {
        this.setLoadingScreenVisible(false);
        this.isSearchStatue = true;
        this.sysMedicineFilterData = this.sysMedicineData.slice(0, 200);
        return;
      }
      // 入力文字を含むレコードに絞り込む
      this.sysMedicineFilterData = this.sysMedicineData.filter(s => {
        return s.searchText.some(text => text === null
          ? false
          : text.indexOf(this.strToSearch.inUsed) > -1
        );
      });*/
      // 入力確定された文字列がnull若しくは空文字の場合
      if (!this.strToSearch.inUsed || this.strToSearch.inUsed === "") {
        this.keyword = "isNullOrEmpty";
      } else {
        this.keyword = this.strToSearch.inUsed;
      }
      // 検索用APIコール
      ApiHelper.get("/sys_medicine/getSysMedicineByKeyword/" + this.keyword + "/" + this.offset)
        .then(response =>{
          this.sysMedicineFilterData = response.data;
        })
        .catch(error => {
          getErrorMessage('SysMedicineSearchSubModalComponent.vue', 'onSearch', '標準医薬品マスタの取得に失敗しました.');
          console.log("標準医薬品マスタの取得に失敗しました.", error);
        });
      /* modify by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --end */
      this.setLoadingScreenVisible(false);
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
      this.isSelectedMedicine = false;
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
      this.isSelectedMedicine = true;
      // Storeに選択された標準医薬品マスタ情報を格納する.
      this.setSelectedSysMedicine(this.sysMedicineFilterData[index]);
    },
    /**
     * 行ダブルクリック時のイベント
     * ※イベント発火時の処理は、確定処理と同じ.
     * ※このイベント発火前に行選択イベント(onSelectRow)が発火する.
     */
    onDoubleClick() {
      this.reflect();
    },
    /**
     * 区分を正式名に変換する.
     * 変換出来ない場合(convertClass)は、codeをそのまま返します。
     * @param {String} code 変換前の区分コード(1:内服、2:外用、3:注射、4:歯科)
     * @returns 変換後の文字列
     */
    getClass(code) {
      return this.convertClass[code] || code;
    },

    /* modify by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --start */
    /*scrollGet() {
      if (this.$refs.scrollDiv.scrollTop + this.$refs.scrollDiv.clientHeight === this.$refs.scrollDiv.scrollHeight) {
        if (this.isSearchStatue) {
          this.endingPoint += 100;
          this.sysMedicineFilterData = this.sysMedicineData.slice(0, this.endingPoint);
        }
      }
    },*/
    // modify start 馬 #10226
    async scrollGet(e) {
      if (e.target.scrollTop + e.target.clientHeight + 1 >= e.target.scrollHeight && !this.hasLoadAllFlag) {
        this.offset += 1;
        this.scrollTop = e.target.scrollTop;
        this.setLoadingScreenVisible(true);
        // 検索用APIコール
        await Promise.all([ApiHelper.get("/sys_medicine/getSysMedicineByKeyword/" + this.keyword + "/" + this.offset)])
          .then(response => {
            if (response[0].data.length) {
              this.sysMedicineFilterData = this.sysMedicineFilterData.concat(response[0].data);
            } else {
              this.hasLoadAllFlag = true;
            }
          })
          .catch(error => {
            getErrorMessage('SysMedicineSearchSubModalComponent.vue', 'scrollGet', '標準医薬品マスタの取得に失敗しました.');
            console.log("標準医薬品マスタの取得に失敗しました.", error);
          }).finally(() => {
            this.setLoadingScreenVisible(false);
          });
      }
    },
    // modify end 馬 #10226
    /* modify by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --end */

    changeSearch() {
      if (!this.strToSearch.inProgress || this.strToSearch.inProgress === "") {
        this.isSearchStatue = true;
      } else {
        this.isSearchStatue = false;
      }
    }
  },
  /**
   * computed
   */
  computed: {
    /**
     * 標準医薬品マスタが選択されているか否かを返す.
     * @returns true : 選択済、false : 未選択
     */
    isSelected() {
      return this.isSelectedMedicine;
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
    // 初期処理
    await this.init();
    // add start 馬 #10226
    this.debouncedScrollGet = debounce(this.scrollGet, 200);
    this.$refs.scrollDiv.addEventListener('scroll', this.debouncedScrollGet);
    // add end 馬 #10226
  },
  // add start 馬 #10226
  beforeDestroy() {
    this.$refs.scrollDiv.removeEventListener('scroll', this.debouncedScrollGet);
  },
  // add end 馬 #10226
}
</script>

<style scoped>
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
  background-color: inherit;
  background-image: none;
  font-family: inherit;
  padding: 0 0.5em;
  height: 3em;
}
/**
 * 絞込条件エリア内のons-rowのスタイル
 */
.filter-content >>> ons-row {
  margin-top: 5px;
  overflow-x: auto;
  display: flex;
  flex-wrap: nowrap;
}
/**
 * 絞込条件のラベルのスタイル
 * mod フリーワードの文字サイズ font-sizeの改修 鞠
 */
#filter_content_title {
  vertical-align: -webkit-baseline-middle;
  font-size: 1em;
  margin-left: 10px;
}
/**
 * 一覧部の大枠のスタイル
 * （フリーワード検索欄の高さ：3em + 5px）
 */
.list-content {
  height: calc(100% - 3em - 5px);
}
/**
 * 一覧部のスタイル
 */
.scroll-table {
  overflow: auto;
  width: calc(100% - 20px);
  margin: 0 10px;
  height: 100%;
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
/**
 * 以下の高さを引く。
 * ・ヘッダの高さ：45px
 * ・フッタの高さ：10px + 2em + 10px
 * （上下のマージン10px、ボタン高さ2em）
 */
div >>> .sub-modal-body {
  height: calc(100% - 45px - 10px - 2em - 10px);
}
</style>
