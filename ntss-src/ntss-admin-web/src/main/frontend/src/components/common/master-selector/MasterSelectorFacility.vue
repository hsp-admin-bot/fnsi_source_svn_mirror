/** * マスタ選択 */

<template>
  <v-ons-popover
    v-if="popoverVisible"
    :target="targetPositionElement"
    :visible="popoverVisible"
    :direction="popoverDisplayDirection"
    :class="[fontSizeSet, 'popover-style']"
    cancelable
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="closePopover(); popoverPosthide()"
  >
    <div>
      <v-ons-row>
        <h2 class="popover-header-style">{{ popoverTitleHeader }}</h2>
      </v-ons-row>
      <hr />
      <v-ons-row
        v-for="filter in popoverFilter"
        :key="filter.popoverFilterLabel"
        class="div-style"
      >
        <v-ons-col width="30%">
          <label class="label-style">{{ filter.popoverFilterLabel }}</label>
        </v-ons-col>
        <v-ons-col>
          <v-ons-select
            v-model="popoverFilterSelectedItem[filter.popoverFilterLabel]"
            class="select-filter-style"
            @change="filterChange"
          >
            <option
              v-for="data in filter.popoverFilterDataset"
              :key="data.id"
              :value="data.value"
            >
              {{ data.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="div-style">
        <v-ons-col width="30%">
          <label class="label-style">フリーワード</label>
        </v-ons-col>
        <v-ons-col>
          <input
            v-model="popoverSearchQuery"
            class="search-style"
            type="search"
            placeholder="検索"
            @input = "inputChange"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="div-style">
        <v-ons-col width="30%">
          <label class="label-style">{{ popoverContentLabel }}</label>
        </v-ons-col>
        <v-ons-col>
          <v-ons-select
            v-model="popoverContentSelectedItem"
            class="select-content-style select-has-size select-font-inherit"
            size="10"
            @dblclick="saveChanges"
            v-loadMore="loadMoreData"
          >
            <option
              v-for="content in popoverFilteredContent"
              :key="content.id"
              :value="content.value"
              :class="setListClassOne(content.value)"
            >
              {{ content.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col>
          <v-ons-button
            class="common-style-cancel-button button-cancel btn2-cancel"
            @click="closePopover"
          >
            キャンセル
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <v-ons-button
            class="common-style-ok-button button-confirm btn1-execute"
            @click="saveChanges"
            :disabled="!isChanged"
          >
            OK
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </v-ons-popover>
</template>

<script>
import {ApiHelper} from "@/apis/AxiosHelper";
import PopoverMixin from "@/components/PopoverMixin";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
import {popoverPosthide, popoverPostShow, popoverPreShow} from "@/functions/common/CommonPopoverFunctions";
import {mapGetters} from "vuex";

const PrefectureFilterLabel = "都道府県";
const FavoritePrefecturesValue = "9999";
const AllPrefecturesValue = "0";
const UnregisteredOption = { text: "未登録", value: null };
const PrefectureFilterDataset = [
  { text: "よく使う施設", value: FavoritePrefecturesValue },
  { text: "全国", value: AllPrefecturesValue },
  { text: "北海道", value: "01" },
  { text: "青森県", value: "02" },
  { text: "岩手県", value: "03" },
  { text: "宮城県", value: "04" },
  { text: "秋田県", value: "05" },
  { text: "山形県", value: "06" },
  { text: "福島県", value: "07" },
  { text: "茨城県", value: "08" },
  { text: "栃木県", value: "09" },
  { text: "群馬県", value: "10" },
  { text: "埼玉県", value: "11" },
  { text: "千葉県", value: "12" },
  { text: "東京都", value: "13" },
  { text: "神奈川県", value: "14" },
  { text: "新潟県", value: "15" },
  { text: "富山県", value: "16" },
  { text: "石川県", value: "17" },
  { text: "福井県", value: "18" },
  { text: "山梨県", value: "19" },
  { text: "長野県", value: "20" },
  { text: "岐阜県", value: "21" },
  { text: "静岡県", value: "22" },
  { text: "愛知県", value: "23" },
  { text: "三重県", value: "24" },
  { text: "滋賀県", value: "25" },
  { text: "京都府", value: "26" },
  { text: "大阪府", value: "27" },
  { text: "兵庫県", value: "28" },
  { text: "奈良県", value: "29" },
  { text: "和歌山県", value: "30" },
  { text: "鳥取県", value: "31" },
  { text: "島根県", value: "32" },
  { text: "岡山県", value: "33" },
  { text: "広島県", value: "34" },
  { text: "山口県", value: "35" },
  { text: "徳島県", value: "36" },
  { text: "香川県", value: "37" },
  { text: "愛媛県", value: "38" },
  { text: "高知県", value: "39" },
  { text: "福岡県", value: "40" },
  { text: "佐賀県", value: "41" },
  { text: "長崎県", value: "42" },
  { text: "熊本県", value: "43" },
  { text: "大分県", value: "44" },
  { text: "宮崎県", value: "45" },
  { text: "鹿児島県", value: "46" },
  { text: "沖縄県", value: "47" }
];

const toFacilityListItem = (aSysFacility) => ({
  value: aSysFacility.medicalInstitutionCd,
  text: aSysFacility.facilityName,
  prefecturesCd: aSysFacility.prefecturesCd,
  medicalInstitutionCd: aSysFacility.medicalInstitutionCd,
});
const toFacilityList = (sysFacilities) => sysFacilities.map(toFacilityListItem);
const isNotFavoriteFacilityDeleted = (aFavoriteFacility) => (
  (!aFavoriteFacility.isFavDel || aFavoriteFacility.isFavDel === "0")
  && (!aFavoriteFacility.isSysDel || aFavoriteFacility.isSysDel === "0")
);
const toFavoriteFacilityListItem = (aFavoriteFacility) => ({
  value: aFavoriteFacility.medicalInstitutionCd,
  text: aFavoriteFacility.name,
  prefecturesCd: aFavoriteFacility.prefCd,
  medicalInstitutionCd: aFavoriteFacility.medicalInstitutionCd,
});
const toFavoriteFacilityList = (favoriteFacilities) => favoriteFacilities
  .filter(isNotFavoriteFacilityDeleted)
  .map(toFavoriteFacilityListItem);

export default {
  mixins: [PopoverMixin],

  props: {
    /**
     * @description ポップオーバー表示非表示
     */
    popoverVisible: {
      type: Boolean,
      default: false
    },

    /**
     * @description ポップオーバーヘッダーテキスト
     */
    popoverTitleHeader: {
      type: String,
      default: ""
    },

    /**
     * @description 抽出結果のラベル
     */
    popoverContentLabel: {
      type: String,
      default: ""
    },

    /**
     * @description 選択結果となり得る選択肢
     */
    popoverContentDataset: {
      type: Array,
      default: () => []
    },

    /**
     * @description 抽出結果の選択項目
     */
    popoverContentSelected: {
      type: Object,
      default: () => {
        return {
          value: "",
          text: "",
          prefecturesCd: ""
        };
      }
    },

    /**
     * @description ポップオーバーの呼び出し元(DOMオブジェクト)
     */
    targetPositionElement: {
      type: [Object, HTMLElement],
      default() {
        return this.$parent;
      }
    },

    /**
     * @description 「未登録」選択の有無
     */
    hasUnregisteredOption: {
      type: Boolean,
      default: true
    }
  },

  data() {
    return {
      /**
       * @description 抽出条件
       *              ※ 何も渡さないと抽出条件の入力フィルドが表示されない
       *              ※ 配列の中身: { popoverFilterLabel: '', popoverFilterDataset: [] }
       */
      popoverFilter: [],

      /**
       * @description 各抽出条件の選択項目
       *              ※ popoverContentDatasetから抽出条件によって絞り込む結果
       *              ※ key:「popoverFilter」の「popoverFilterLabel」
       *              ※ value:「popoverFilter」の「popoverFilterDataset」からの項目
       */
      popoverFilterSelectedItem: {},

      /**
       * @description 抽出結果の選択項目
       */
      popoverContentSelectedItem: this.popoverContentSelected.value,

      /**
       * @description フリーワード入力値
       */
      popoverSearchQuery: "",

      /**
       * @description 表示方向
       */
      popoverDirection: "",

      /**
       * @description 画面の高さ(レスポンシブ対応)
       */
      windowHeight: window.innerHeight,

      /**
       * @description 画面の幅(レスポンシブ対応)
       */
      windowWidth: window.innerWidth,

      /**
       * @description よく使う施設リスト
       */
      favoriteFacilities: [],

      /**
       * @description 抽出結果
       */
      popoverFilteredContent: [],

      /**
       * @description 都道府県フィルタの状態
       */
      prefectureFilterState: {
        /**
         * @description popoverFilterSelectedItemの中の"都道府県"の値
         */
        value: FavoritePrefecturesValue,
        /**
         * @description 「よく使う施設」が選択されている場合はtrue
         */
        isFavorite: true,
        /**
         * @description 「全国」が選択されている場合はtrue
         */
        isAll: false,
        /**
         * @description 特定の都道府県が選択されている場合はtrue
         */
        isOne: false,
      },

      /**
       * @description 施設リストの情報
       */
      facilitiesData: {
        /**
         * @description 取得済みの施設情報
         */
        list: [],
        /**
         * @description 取得済みのページ数
         */
        loadedPage: 0,
        /**
         * @description 全ページ取得済みならtrue
         */
        allLoaded: false,
        /**
         * @description 取得処理中ならtrue
         */
        loading: false,
        /**
         * @description 保留中の取得処理があるならtrue
         */
        waiting: false,
        /**
         * @description 条件変更後取得処理前ならtrue
         */
        isNewCondition: true,
      },
      /* add by chamaojia 2025-05-21 [11871]  --start */
      // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
      // 定義変数受信初期化リストデータ
      contentDataset: [],
      /* add by chamaojia 2025-05-21 [11871]  --end */
    };
  },
  /* add by guanhao 20221020[7177] 紹介状画面を開くとメモリオーバーフローにてブラウザが落ちる --start*/
  directives: {
    loadMore: {
      bind(el, binding) {
        const SELECTWRAP_DOM = el.getElementsByTagName('select')[0];
        SELECTWRAP_DOM.addEventListener("scroll", function () {
          const CONDITION =
            Math.abs(this.scrollHeight - this.scrollTop - this.clientHeight) < 4;
          if (CONDITION) {
            binding.value();
          }
        });
      },
    },
  },
  /* add by guanhao 20221020[7177] 紹介状画面を開くとメモリオーバーフローにてブラウザが落ちる --end*/
  computed: {

    ...mapGetters("user", ["getFacilityCd"]),
    /**
     * @description 表示方向
     */
    popoverDisplayDirection() {
      if (!this.popoverVisible) return null;

      const elemPosition = this.targetPositionElement.$el
        ? this.targetPositionElement.$el.getBoundingClientRect()
        : this.targetPositionElement.getBoundingClientRect();
      let direction = "right";

      if (this.windowHeight <= 420) {
        // heightが狭い(スマホ横とか)ときは上下じゃ途切れるので右か左に表示
        if (elemPosition.right < this.windowWidth / 2) {
          direction = "right";
        } else {
          direction = "left";
        }
      } else if (this.windowWidth - elemPosition.right < 500) {
        if (elemPosition.top < this.windowHeight / 2) {
          direction = "down";
        } else {
          direction = "up";
        }
      }

      this.setPopoverDirection(direction);

      return direction;
    },

    /**
     * @description popoverFilterの中の"都道府県"の要素
     */
    prefectureFilterData() {
      if (!Array.isArray(this.popoverFilter)) return null;
      return this.popoverFilter.find(filter => filter.popoverFilterLabel === PrefectureFilterLabel);
    },

    isChanged() {
      return this.popoverContentSelectedItem !== this.popoverContentSelected.value;
    },
  },

  watch: {
    async popoverVisible(visible) {
      if (visible) {
        await this.initializeFilterSelected();
      }
    },
  },

  async mounted() {
    window.addEventListener("resize", this.resize);

    // フィルターを設定する
    this.popoverFilter = [
      {
        popoverFilterLabel: PrefectureFilterLabel,
        popoverFilterDataset: PrefectureFilterDataset,
      },
    ];
  },
  methods: {
    // modify by 史 for 6119 ブラウザがOut of Memoryのエラーが発生する
    resize() {
      this.windowHeight = window.innerHeight;
      this.windowWidth = window.innerWidth;
    },
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    /**
     * @description 取得済み施設リスト情報クリア
     */
    clearFacilitiesData() {
      this.facilitiesData.list.length = 0;
      this.facilitiesData.loadedPage = 0;
      this.facilitiesData.allLoaded = false;
      // loadingとwaitingは多重呼び出し制御のための情報なのでここではクリアしない
      this.facilitiesData.isNewCondition = true;
    },

    async loadFavoriteFacilities() {
      this.clearFavoriteFacilities();
      this.proccessFavoriteFacilitiyResponse(await this.getFavoriteFacilitiyResponse());
    },
    async getFavoriteFacilitiyResponse() {
      try {
        const response = await ApiHelper.get(`/master_maintenance/mst_favorite_facility/data/sql/${this.getFacilityCd}`);
        return response;
      } catch (error) {
        getErrorMessage('MasterSelectorFacility.vue', 'getFavoriteFacilitiyResponse', 'よく使う施設マスタの取得に失敗しました.' + String(error));
        console.log("よく使う施設マスタの取得に失敗しました.", error);
        throw error;
      }
    },
    proccessFavoriteFacilitiyResponse(response) {
      // API呼び出し時のエラーで結果が取れていない場合は処理しない
      if (!response || !response.data || !response.data.localDataSource || !response.data.localDataSource.data) return;

      this.favoriteFacilities.push(...toFavoriteFacilityList(response.data.localDataSource.data));
      // よく使う施設はページングがないので以降は条件変更するまでAPI呼び出しをスキップする
      this.facilitiesData.allLoaded = true;
    },

    async getSysFacilityResponse() {
      const params = {
        page: this.facilitiesData.loadedPage,
      };
      if (this.prefectureFilterState.isOne) {
        // 特定の都道府県が選択されている場合はprefecturesCdパラメータを設定する
        params.prefecturesCd = this.prefectureFilterState.value;
      }
      if (this.popoverSearchQuery) {
        // 空文字列でなければkeywordパラメータを設定する
        params.keyword = this.popoverSearchQuery;
      }
      try {
        const response = await ApiHelper.get("mstInfo/getSysFacilityBySearchConditions/", params);
        return response;
      } catch (error) {
        this.facilitiesData.loading = false;
        getErrorMessage('MasterSelectorFacility.vue', 'getSysFacilityResponse', '施設マスタの取得に失敗しました.' + String(error));
        console.log("施設マスタの取得に失敗しました.", error);
      }
    },
    proccessSysFacilityResponse(response) {
      // API呼び出し時のエラーで結果が取れていない場合は処理しない
      if (!response || !response.data) return;

      if (response.data.length === 0) {
        // 取得結果がゼロ件の場合は以降は条件変更するまでAPI呼び出しをスキップする
        this.facilitiesData.allLoaded = true;
        return;
      }
      this.facilitiesData.list.push(...toFacilityList(response.data));
      ++this.facilitiesData.loadedPage;
    },

    async loadOnePageData() {
      if (this.facilitiesData.loading) {
        // API処理中に呼ばれた場合
        if (this.facilitiesData.isNewCondition && !this.facilitiesData.waiting) {
          // 新しい条件の場合は処理を保留し、現在の処理が終わった後に処理しなおす
          // （新しい条件でない場合は多重呼び出し処理はスキップする）
          this.facilitiesData.waiting = true;
        }
        return;
      }

      // 最終ページまで到達している場合は以降の処理は行わない
      if (this.facilitiesData.allLoaded) return;

      this.facilitiesData.loading = true;
      this.facilitiesData.isNewCondition = false;
      const response = this.prefectureFilterState.isFavorite
        ? await this.getFavoriteFacilitiyResponse()
        : await this.getSysFacilityResponse();
      this.facilitiesData.loading = false;
      if (this.facilitiesData.waiting) {
        // 多重呼び出しによる保留がある場合
        this.facilitiesData.waiting = false;
        // 今回の結果は処理せず最新の条件で再度APIを呼びなおす
        this.loadOnePageData();
        return;
      }
      if (this.prefectureFilterState.isFavorite) {
        this.proccessFavoriteFacilitiyResponse(response);
      } else {
        this.proccessSysFacilityResponse(response);
      }
      this.updatePopoverFilteredContent();
      /* add by chamaojia 2025-05-21 [11871]  --start */
      // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
      // リストデータの初期化
      let popoverContentDataset = [];
      let arr = [];
      if(this.prefectureFilterState.isFavorite) {
        if (!response || !response.data || !response.data.localDataSource || !response.data.localDataSource.data) return;
        arr = response.data.localDataSource.data;
      }else {
        if (!response || !response.data) return;
        arr = response.data;
      }
      for (let mst of arr) {
        popoverContentDataset.push({
          //update データを修正 facilityCd -> medicalInstitutionCd 顔
          value: mst["medicalInstitutionCd"],
          //end データを修正 facilityCd -> medicalInstitutionCd 顔
          text: mst["facilityName"],
          prefecturesCd: mst["prefecturesCd"],
          //add FNSI-施設選択の箇所を対応する 江 start
          medicalInstitutionCd: mst["medicalInstitutionCd"]
          //add FNSI-施設選択の箇所を対応する 江 end
        });
      }
      this.contentDataset.push(...popoverContentDataset);
      /* add by chamaojia 2025-05-21 [11871]  --end */
    },

    updatePopoverFilteredContent() {
      let newList = [];
      if (this.prefectureFilterState.isFavorite) {
        // 「よく使う施設」の場合
        if (this.popoverSearchQuery) {
          // フロントエンドでフリーワード条件を反映する
          newList = this.favoriteFacilities.filter(item => item.text.includes(this.popoverSearchQuery));
        } else {
          newList = this.favoriteFacilities;
        }
      } else {
        // 「全国」や特定の都道府県の場合はAPIでフリーワード条件を反映済み
        newList = this.facilitiesData.list;
      }

      if (
        this.hasUnregisteredOption
        && newList.length > 0
        && newList[0].text !== UnregisteredOption.text
      ) {
        // 「未登録」の選択肢を追加
        newList.unshift(UnregisteredOption);
      }

      this.popoverFilteredContent.length = 0;
      this.popoverFilteredContent.push(...newList);
      /* add by chamaojia 2025-05-21 [11871]  --start */
      // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
      // 新規入出力時、データリスト初期話
      let popoverContentDataset = [];
      popoverContentDataset.push(...newList);
      this.contentDataset.push(...popoverContentDataset);
      /* add by chamaojia 2025-05-21 [11871]  --end */
    },

    async inputChange() {
      await this.loadWithNewConditions();
    },

    async loadMoreData() {
      // 「よく使う施設」の場合は追加読み込みは行わない
      if (this.prefectureFilterState.isFavorite) return;

      // 1ページ目を取得済みでない場合は処理しない
      if (this.facilitiesData.loadedPage < 1) return;

      await this.loadOnePageData();
    },

    /**
     * @description ポップオーバー非表示
     */
    closePopover() {
      this.$emit("popover-close", false);
      this.clearPopoverDirection();
      this.clearSearchQuery();
      this.clearFacilitiesData();
      this.clearFavoriteFacilities();
      this.updatePopoverFilteredContent();
    },

    /**
     * @description 抽出条件の初期化
     */
    async initializeFilterSelected() {
      /* add by chamaojia 2025-05-21 [11871]  --start */
      // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
      // 根据当前施设cd获取都道府県コード
      const response = await ApiHelper.get('/sysFacility/getSysFacilityByCd/'+this.popoverContentSelected.value );
      if(response.data) {
        this.popoverContentSelected.prefecturesCd = response.data.prefecturesCd;
      }
      /* add by chamaojia 2025-05-21 [11871]  --end */
      this.popoverContentSelectedItem = this.popoverContentSelected.value;
      // 「よく使う施設」をデフォルト設定とする
      let initialPrefectureFilterValue = FavoritePrefecturesValue;
      // 「よく使う施設」に存在しない項目が選択されている場合、
      // 選択中の項目の都道府県コードが都道府県の選択肢に存在するなら
      // その都道府県を初期選択する
      await this.loadFavoriteFacilities();
      if (this.popoverContentSelected
        && this.popoverContentSelected.value
        && this.favoriteFacilities
        && this.favoriteFacilities.findIndex(
          item => item.value === this.popoverContentSelected.value
        ) < 0
        && this.popoverContentSelected.prefecturesCd
        && this.prefectureFilterData
        && this.prefectureFilterData.popoverFilterDataset.findIndex(
          item => item.value === this.popoverContentSelected.prefecturesCd
        ) > -1
      ) {
        initialPrefectureFilterValue = this.popoverContentSelected.prefecturesCd;
        this.clearFavoriteFacilities();
      }
      this.popoverFilterSelectedItem[PrefectureFilterLabel] = initialPrefectureFilterValue;
      this.updatePrefectureFilterState();
      await this.loadWithNewConditions();
    },

    /**
     * @description よく使う施設情報クリア
     */
    clearFavoriteFacilities() {
      this.favoriteFacilities.length = 0;
    },

    /**
     * @description フリーワード入力クリア
     */
    clearSearchQuery() {
      this.popoverSearchQuery = "";
    },

    getSelectedContent() {
      if (this.popoverContentSelectedItem === null) return { text: "", value: null };
      /* modify by chamaojia 2025-05-21 [11871]  --start */
      // iPhoneアクセスプログラム、画面メモリオーバーフロー改造
      // 選択したデータのフィルタ
      // return this.popoverContentDataset.find(item => {
      //   return item.value === this.popoverContentSelectedItem;
      // });
      return this.contentDataset.find(item => {
        return item.value === this.popoverContentSelectedItem;
      });
      /* modify by chamaojia 2025-05-21 [11871]  --end */
    },

    /**
     * @description 選択項目を呼出元に返す
     */
    saveChanges() {
      // （#6512の対応に合わせて）OKボタンが非活性の場合はダブルクリックによる選択確定操作も無効とする
      if (!this.isChanged) return;

      this.$emit("popover-return", this.getSelectedContent());
      this.closePopover();
    },

    /**
     * @description 表示方向設定
     */
    setPopoverDirection(direction) {
      this.popoverDirection = direction;
    },
    clearPopoverDirection() {
      this.setPopoverDirection("");
    },

    async loadWithNewConditions() {
      this.clearFacilitiesData();
      if (this.prefectureFilterState.isFavorite && this.favoriteFacilities.length > 0) {
        // 都道府県切替時でない場合などfavoriteFacilitiesの情報が残っている場合は
        // APIを呼びなおさずその情報を使用する
        this.updatePopoverFilteredContent();
      } else {
        await this.loadOnePageData();
      }
    },

    updatePrefectureFilterState() {
      // ここで更新している情報をcomputedにした際に
      // this.popoverFilterSelectedItem[PrefectureFilterLabel]の変化時に
      // 更新されない現象が起きたためcomputedを使わずfilterChangeなどでdataを更新する形にした
      const stateObj = this.prefectureFilterState;
      stateObj.value = this.popoverFilterSelectedItem[PrefectureFilterLabel];
      stateObj.isFavorite = stateObj.value === FavoritePrefecturesValue;
      stateObj.isAll = stateObj.value === AllPrefecturesValue;
      stateObj.isOne = !stateObj.isFavorite && !stateObj.isAll;
    },

    /**
     * @description 抽出条件の選択項目が変わる時のコールバック
     */
    async filterChange() {
      this.updatePrefectureFilterState();
      this.clearFavoriteFacilities();
      this.clearSearchQuery();

      await this.loadWithNewConditions();
    },
    // add #6512 患者情報画面の分の修正のため、施設POP画面を修正 劉 start
    setListClassOne(cd) {
      const selectedList = this.popoverContentSelectedItem ? this.popoverContentSelectedItem : [];
      const obj = {
        "selected-color": false,
        "dis-selected-color": false
      };
      // 選択状態フラグを格納
      let isSelected = false;
      isSelected = selectedList === cd ? true : isSelected;
      // // 選択中クラスを付与
      obj["selected-color"] = isSelected;
      // 未選択中クラスを付与
      obj["dis-selected-color"] = !isSelected;
      return obj;
    },
    // add #6512 患者情報画面の分の修正のため、施設POP画面を修正 劉 end
  },
  beforeDestroy() {
    window.removeEventListener("resize", this.resize);
  }
};
</script>

<style scoped>
.popover-style >>> .popover--top,
.popover-style >>> .popover--right,
.popover-style >>> .popover--left,
.popover-style >>> .popover--bottom {
  width: initial;
}

.popover-style >>> .popover__content {
  width: 500px;
  height: 100%;
  padding: 25px;
  border: solid 1px var(--preventive-checked-border-color);
  margin: 3px;
}

.popover-header-style {
  margin: 0px;
}

.select-filter-style,
.search-style {
  width: 100%;
}

.select-content-style {
  width: 100%;
  height: 100%;
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}

.label-style {
  font-size: 15px;
}

.button-cancel {
  float: left;
}

.button-confirm {
  float: right;
}

.popover-footer-style {
  margin-top: 15px;
}

.select-has-size {
  font-size: 13.3333px;
}

/* add #6512 患者情報画面の分の修正のため、施設POP画面を修正 劉 start*/
.selected-color {
  background-color: #0076ff !important;
  color: white;
  width: max-content;
  min-width: 100%;
}
.dis-selected-color:hover {
  background-color: #dddddd;
}
/* add #6512 患者情報画面の分の修正のため、施設POP画面を修正 劉 end*/

/* スマホ対応 */
@media screen and (max-width: 420px) {
  .popover-style >>> .popover__content {
    width: auto;
    padding: 10px;
  }

  .label-style {
    font-size: 12px;
  }

  .popover-header-style {
    font-size: 18px;
  }
}

@media screen and (max-height: 420px) {
  .popover-style >>> .popover__content {
    width: 350px;
    padding: 5px;
  }

  .label-style {
    font-size: 12px;
  }

  .popover-header-style {
    font-size: 18px;
  }
}
</style>
