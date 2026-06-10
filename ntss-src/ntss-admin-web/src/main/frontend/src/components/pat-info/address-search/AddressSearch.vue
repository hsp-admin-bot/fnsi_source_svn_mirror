/** * 住所検索 */

<template>
  <modal-base @onClose="hideModalIncludeSub">
    <div slot="body">
      <div class="modal-contents-custom">
        <kendo-tabstrip ref="tabContainer" :activate="activateCalc">
          <ul class="tab-container" style="display: flex; flex-wrap: nowrap;">
            <li ref="prefTabHeader" class="k-state-active">都道府県</li>
            <li ref="cityTabHeader">市区町村</li>
            <li ref="townTabHeader">町域名</li>
            <li ref="searchTabHeader" style="margin-left: auto;">検索</li>
          </ul>
          <div class="address-search-tab-area">
            <div class="tab-content-title">
              {{ selectedPref.prefName }}
              {{ selectedCity.cityName }}
              {{ selectedTown.townName }}
            </div>
            <v-ons-row style="height: calc(100% - 2em);">
              <v-ons-col v-if="japanMap" style="min-width: 15em;">
                <div v-for="pref in prefAreas" :key="pref.name">
                  <label
                    :style="{ 'background-color': pref.color }"
                    class="pref-label"
                  ></label>
                  <a
                    v-for="prefCode in pref.prefectures"
                    :key="prefCode"
                    href="#"
                    @click="
                      selectPrefecture({
                        prefName: japanMap.findPrefectureByCode(prefCode).name
                      })
                    "
                    >{{ japanMap.findPrefectureByCode(prefCode).name }}</a
                  >
                </div>
              </v-ons-col>
              <v-ons-col id="map-canvas">
                <div ref="prefMap" class="pref-map"></div>
              </v-ons-col>
            </v-ons-row>
          </div>
          <div class="address-search-table address-search-tab-area">
            <div class="tab-content-title">
              {{ selectedPref.prefName }}
              {{ selectedCity.cityName }}
              {{ selectedTown.townName }}
            </div>
            <kendo-tabstrip
              ref="cityTabStrip"
              @select="
                (function (e) {
                  e.preventDefault();
                })($event)
              "
            >
              <ul class="tab-container">
                <li
                  v-for="(filter, index) in gridFilter"
                  :key="filter.name"
                  :class="{ 'k-state-active': index === 0 }"
                  @click="jumpToRow(0, filter.regex)"
                >
                  {{ filter.name }}
                </li>
              </ul>
            </kendo-tabstrip>
            <kendo-grid
              ref="cityGrid"
              :data-source="cityGridData"
              :columns="cityGridColumns"
              :selectable="true"
              class="grid-style"
              @change="selectCity"
            />
          </div>
          <div class="address-search-table address-search-tab-area">
            <div class="tab-content-title">
              {{ selectedPref.prefName }}
              {{ selectedCity.cityName }}
              {{ selectedTown.townName }}
            </div>
            <kendo-tabstrip
              ref="townTabStrip"
              @select="
                (function (e) {
                  e.preventDefault();
                })($event)
              "
            >
              <ul class="tab-container">
                <li
                  v-for="(filter, index) in gridFilter"
                  :key="filter.name"
                  :class="{ 'k-state-active': index === 0 }"
                  @click="jumpToRow(1, filter.regex)"
                >
                  {{ filter.name }}
                </li>
              </ul>
            </kendo-tabstrip>
            <kendo-grid
              ref="townGrid"
              :data-source="townGridData"
              :columns="townGridColumns"
              :selectable="true"
              class="grid-style"
              @change="selectTown"
            />
          </div>
          <div class="address-search-table address-search-tab-area">
            <div class="tab-content-title">
              {{ selectedPref.prefName }}
              {{ selectedCity.cityName }}
              {{ selectedTown.townName }}
            </div>
<!--            mod #10473 郵便番号検索が遅い 20240402 ztc start-->
<!--            <input-->
<!--                v-model="searchQuery"-->
<!--                class="search-style"-->
<!--                type="search"-->
<!--                placeholder="住所を入力してください"-->
<!--            />-->
            <input
              ref="searchInput"
              v-model="searchQuery"
              class="search-style"
              type="search"
              :disabled="searchQueryDisabled"
              placeholder="住所を入力してください"
            />
<!--            mod #10473 郵便番号検索が遅い 20240402 ztc end-->
            <kendo-grid
              ref="searchGrid"
              :data-source="searchGridData"
              :columns="searchGridColumns"
              :selectable="true"
              :scrollable-endless="true"
              :pageable-numeric="false"
              :pageable-previous-next="false"
              class="grid-style"
              @change="selectTown"
            />
          </div>
        </kendo-tabstrip>
      </div>
    </div>
    <div slot="footer" class="modal-footer-custom">
      <v-ons-row>
        <v-ons-col>
          <v-ons-button
            class="btn2-cancel common-style-cancel-button button-cancel"
            @click="hideModalIncludeSub"
          >
            キャンセル
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <!-- mod 7778 limingyang start-->
          <v-ons-button
            :disabled="confirmButtonDisabled"
            class="btn1-execute common-style-ok-button button-confirm"
            @click="
              selectAddress();
              hideModalIncludeSub();
              editSaveButton();
            "
          >
          <!-- mod 7778 limingyang end-->
            OK
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </modal-base>
</template>

<script>
import { ApiHelper } from "@/apis/AxiosHelper";
import { EventBus } from "@/eventBus.js";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import JapanMap from "@/components/pat-info/address-search/JapanMap.js";
import kendo from "@progress/kendo-ui";
import _ from "underscore";
import ModalBase from "@/components/modals/ModalBase";
// mod 8282 住所検索中が共通ローダーではない　周安寧 start
//import { mapGetters, mapMutations } from "vuex";
import { mapGetters, mapMutations,mapActions } from "vuex";
// mod 8282 住所検索中が共通ローダーではない　周安寧 end
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end

export default {
  components: {
    ModalBase,
  },

  mixins: [MultiModalMixin],

  props: {
    /**
     * @description 郵便番号か住所の初期値
     */
    zipCd: {
      type: String,
      default: null,
    },
  },

  data() {
    return {
      /**
       * @description 日本地図オブジェクト
       */
      japanMap: null,

      /**
       * @description 日本地図(都道府県選択用)の定義
       */
      mapOptions: {
        field: null,
        areas: {},
        selection: "prefecture",
        showsPrefectureName: true,
        prefectureNameType: "short",
        movesIslands: true,
        width: 950,
        height: 600,
        fontSize: 10,
        fontShadowColor: "white",
        drawsBoxLine: false,
        onSelect: (data) => {
          this.selectPrefecture({ prefName: data.fullName });
        },
      },

      /**
       * @description 日本地図(都道府県選択用)の定義
       */
      prefAreas: [
        {
          code: 1,
          name: "北海道地方",
          color: "#ceffff",
          hoverColor: "#d3e8e8",
          prefectures: [1]
        },
        {
          code: 2,
          name: "東北地方",
          color: "#33cbff",
          hoverColor: "#5bbee0",
          prefectures: [2, 3, 4, 5, 6, 7]
        },
        {
          code: 3,
          name: "関東地方",
          color: "#9bfdcc",
          hoverColor: "#abdec4",
          prefectures: [8, 9, 10, 11, 12, 13, 14]
        },
        {
          code: 4,
          name: "中部地方",
          color: "#fd9acc",
          hoverColor: "#d997b8",
          prefectures: [15, 16, 17, 18, 19, 20, 21, 22, 23]
        },
        {
          code: 5,
          name: "近畿地方",
          color: "#ffe69c",
          hoverColor: "#e5d5a4",
          prefectures: [24, 25, 26, 27, 28, 29, 30]
        },
        {
          code: 6,
          name: "中国地方",
          color: "#cc9afd",
          hoverColor: "#bc9fd9",
          prefectures: [31, 32, 33, 34, 35]
        },
        {
          code: 7,
          name: "四国地方",
          color: "#9bccfe",
          hoverColor: "#a9c9ea",
          prefectures: [36, 37, 38, 39]
        },
        {
          code: 8,
          name: "九州地方・沖縄地方",
          color: "#f3cea9",
          hoverColor: "#ffd7c5",
          prefectures: [40, 41, 42, 43, 44, 45, 46, 47]
        }
      ],

      /**
       * @description ア行～ワ行フィルタデータ
       */
      gridFilter: [
        { name: "全一覧", regex: "", disabled: false },
        { name: "ア行", regex: RegExp("^[ｱ-ｵ]"), disabled: false },
        { name: "カ行", regex: RegExp("^[ｶ-ｺ]"), disabled: false },
        { name: "サ行", regex: RegExp("^[ｻ-ｿ]"), disabled: false },
        { name: "タ行", regex: RegExp("^[ﾀ-ﾄ]"), disabled: false },
        { name: "ナ行", regex: RegExp("^[ﾅ-ﾉ]"), disabled: false },
        { name: "ハ行", regex: RegExp("^[ﾊ-ﾎ]"), disabled: false },
        { name: "マ行", regex: RegExp("^[ﾏ-ﾓ]"), disabled: false },
        { name: "ヤ行", regex: RegExp("^[ﾔ-ﾖ]"), disabled: false },
        { name: "ラ行", regex: RegExp("^[ﾗ-ﾛ]"), disabled: false },
        { name: "ワ行", regex: RegExp("^[ﾜ-ﾝ]"), disabled: false }
      ],

      /**
       * @description kendo-grid内の市区町村のカラム
       */
      cityGridColumns: [
        { field: "cityName", title: "市区町村名" },
        { field: "cityNameKana", title: "市区町村名(カナ)" }
      ],

      /**
       * @description kendo-grid内の町域のカラム
       */
      townGridColumns: [
        { field: "townName", title: "町域名" },
        { field: "townNameKana", title: "町域名(カナ)" },
        { field: "zipCd", title: "郵便番号" }
      ],

      /**
       * @description kendo-grid内の検索のカラム
       */
      searchGridColumns: [
        { field: "zipCd", title: "郵便番号" },
        { field: "address", title: "住所" },
        { field: "addressKana", title: "住所(カナ)" }
      ],

      /**
       * @description 市区町村選択用データソース
       */
      cityGridData: [],

      /**
       * @description 町域選択用データソース
       */
      townGridData: [],

      /**
       * @description 検索用データソース
       */
      searchGridData: {},

      /**
       * @description 選択された都道府県
       */
      selectedPref: {},

      /**
       * @description 選択された市区町村
       */
      selectedCity: {},

      /**
       * @description 選択された町域
       */
      selectedTown: {},

      /**
       * @description フリーワード
       */
      searchQuery: "",

      /**
       * @description OKボタン有効無効
       *              都道府県、市区町村、町域はすべて選択がある場合だけ有効とする
       *              それとも、検索で選択がある場合は有効とする
       */
      confirmButtonDisabled: true,

      /**
       * @description kendo-datasource(検索用)は初期読込かどうか
       */
      isSearchInitialLoad: true,
      // add #10473 郵便番号検索が遅い 20240402 ztc start
      /**
       * @description フリーワード入力可否
       */
      searchQueryDisabled: false,
      lastScrollTop: 0,
      // add #10473 郵便番号検索が遅い 20240402 ztc end
    };
  },

  computed: {
    ...mapGetters("multi-modal", ["getInitValues"]),
    // MultiSubModalから呼び出されている場合に使用
    ...mapGetters("multi-sub-modal", {
      subModalName: "getModalName",
      subInitValues: "getInitValues"
    }),
    ...mapGetters("account-edit", {
      fontSize: "getFontSize"
    }),

    addressComputed() {
      return {
        zipCd: this.selectedTown.zipCd,
        address: this.selectedTown.address
      };
    }
  },

  watch: {
    selectedTown() {
      this.confirmButtonDisabled = !this.selectedTown.address;
    },

    searchQuery() {
      this.selectedPref = {};
      this.selectedCity = {};
      this.selectedTown = {};
      this.updateSearchData();
    },

    zipCd(data) {
      if (data) {
        this.$refs.tabContainer
          .kendoWidget()
          .activateTab(this.$refs.searchTabHeader);
        this.searchQuery = data;
      }
    },

    fontSize() {
      this.calculateHeight();
    }
  },

  mounted() {
    this.initializeJapanMap();
    this.initializeTabContainerHeaders();
    this.calculateHeight();
  },

  methods: {
    // MultiSubModalから呼び出されている場合に使用
    ...mapMutations("multi-sub-modal", {
      subHideModal: "hideModal"
    }),
    // add 8282 住所検索中が共通ローダーではない　周安寧 start
     ...mapActions("loading-screen", ["setLoadingScreenMessage","setLoadingScreenVisible","resetLoadingScreenVisibleCount"]),
    // add 8282 住所検索中が共通ローダーではない　周安寧 end
    /**
     * @description 日本地図(都道府県用)の初期化
     */
    initializeJapanMap() {
      this.mapOptions.areas = this.prefAreas;
      this.mapOptions.field = this.$refs.prefMap;
      this.japanMap = new JapanMap(this.mapOptions);
    },

    /**
     * @description 日本地図(都道府県用)の初期化
     */
    initializeTabContainerHeaders() {
      // MultiSubModalから呼び出されている場合に読み込み先を分ける
      let isZipCd = null;
      let isAddress = null;
      if (this.subModalName === "") {
        isZipCd = !this.getInitValues.postalCode
          ? this.getInitValues.postalCode
          : this.getInitValues.postalCode.trim();
        isAddress = !this.getInitValues.address
          ? this.getInitValues.postalCode
          : this.getInitValues.address.trim();
      } else {
        isZipCd = !this.subInitValues.postalCode
          ? this.subInitValues.postalCode
          : this.subInitValues.postalCode.trim();
        isAddress = !this.subInitValues.address
          ? this.subInitValues.postalCode
          : this.subInitValues.address.trim();
      }

      if (!isZipCd && !isAddress) {
        this.$refs.tabContainer
          .kendoWidget()
          .disable(this.$refs.cityTabHeader)
          .disable(this.$refs.townTabHeader);
      } else {
        if (isZipCd && !isAddress) {
          this.searchQuery = isZipCd;
        } else if (!isZipCd && isAddress) {
          this.searchQuery = isAddress;
        } else if (isZipCd && isAddress) {
          // mod FNSI-Fix Bug 関 start
          // this.searchQuery = isAddress;
          this.searchQuery = isZipCd;
          // mod FNSI-Fix Bug 関 end
        }
        this.updateSearchData();
        this.$refs.tabContainer
          .kendoWidget()
          .activateTab(this.$refs.searchTabHeader);
      }
    },

    /**
     * @description 都道府県の選択後コールバック
     */
    async selectPrefecture(prefecture) {
      // add 8282 住所検索中が共通ローダーではない　周安寧 start
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      // add 8282 住所検索中が共通ローダーではない　周安寧 end
      const tabContainer = this.$refs.tabContainer.kendoWidget();

      // ロードアイコンを表示
      // del 8282 住所検索中が共通ローダーではない　周安寧 start
      //kendo.ui.progress(tabContainer.element, true);
      // del 8282 住所検索中が共通ローダーではない　周安寧 end

      const cityTabStrip = this.$refs.cityTabStrip.kendoWidget();
      const requestParam = {
        prefName: prefecture.prefName,
        size: 2000,
      };
      const cityData = await ApiHelper.get(
        "mstInfo/sysAddress",
        requestParam
      ).catch((error) => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage("AddressSearch.vue", "selectPrefecture", error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        // ロードアイコンを非表示
        // mod 8282 住所検索中が共通ローダーではない　周安寧 start
        //kendo.ui.progress(tabContainer, false);
        this.setLoadingScreenVisible(false);
        // mod 8282 住所検索中が共通ローダーではない　周安寧 end
        throw error;
      });

      // 市区町村タブに移す
      tabContainer.enable(this.$refs.cityTabHeader);
      tabContainer.disable(this.$refs.townTabHeader);
      tabContainer.activateTab(this.$refs.cityTabHeader);

      // 市区町村と町域を初期化
      this.selectedPref = prefecture;
      this.selectedCity = {};
      this.selectedTown = {};
      this.cityGridData = cityData.data.content;

      // ア行～ワ行のフィルタで該当する項目がない場合、そのフィルタを無効にする
      this.gridFilter.forEach((filter, index) => {
        const data = this.cityGridData.find((item) => {
          return item.cityNameKana.match(filter.regex);
        });
        if (!data) {
          cityTabStrip.disable(cityTabStrip.tabGroup.children().eq(index));
        }
      });

      // ロードアイコンを非表示
      // mod 8282 住所検索中が共通ローダーではない　周安寧 start
      //kendo.ui.progress(tabContainer.element, false);
      this.setLoadingScreenVisible(false);
      // mod 8282 住所検索中が共通ローダーではない　周安寧 end
    },

    /**
     * @description 市区町村の選択後コールバック
     */
    async selectCity(e) {
      // add 8282 住所検索中が共通ローダーではない　周安寧 start
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      // add 8282 住所検索中が共通ローダーではない　周安寧 end
      e.preventDefault();

      const tabContainer = this.$refs.tabContainer.kendoWidget();
      const cityGrid = this.$refs.cityGrid.kendoWidget();

      // ロードアイコンを表示
      // del 8282 住所検索中が共通ローダーではない　周安寧 start
      //kendo.ui.progress(cityGrid.element, true);
      // del 8282 住所検索中が共通ローダーではない　周安寧 end

      const townTabStrip = this.$refs.townTabStrip.kendoWidget();
      const selectedCity = cityGrid.dataItem(cityGrid.select()[0]);
      const requestParam = {
        cityName: selectedCity.cityName,
        size: 2000,
      };
      const townData = await ApiHelper.get(
        "mstInfo/sysAddress",
        requestParam
      ).catch((error) => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage("AddressSearch.vue", "selectCity", error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        // ロードアイコンを非表示
        // mod 8282 住所検索中が共通ローダーではない　周安寧 start
        //kendo.ui.progress(cityGrid.element, false);
        this.setLoadingScreenVisible(false);
        // mod 8282 住所検索中が共通ローダーではない　周安寧 end
        throw error;
      });

      // 町域タブに移す
      tabContainer.enable(this.$refs.townTabHeader);
      tabContainer.activateTab(this.$refs.townTabHeader);

      // 町域を初期化
      this.selectedCity = selectedCity;
      this.selectedTown = {};
      this.townGridData = townData.data.content;

      // ア行～ワ行のフィルタで該当する項目がない場合、そのフィルタを無効にする
      this.gridFilter.forEach((filter, index) => {
        const data = this.townGridData.find((item) => {
          // item.townNameKana が null の場合 property 'match' of null" エラーになる
          return item.townNameKana
            ? item.townNameKana.match(filter.regex)
            : null;
        });
        if (!data) {
          townTabStrip.disable(townTabStrip.tabGroup.children().eq(index));
        }
      });

      // 「以下に掲載がない場合」の選択肢は先頭に移動
      const unregisteredTownIndex = this.townGridData.findIndex((item) => {
        return item.townName === "以下に掲載がない場合";
      });
      if (unregisteredTownIndex !== -1) {
        this.townGridData.unshift(
          this.townGridData.splice(unregisteredTownIndex, 1)[0]
        );
      }

      // ロードアイコンを非表示
      // mod 8282 住所検索中が共通ローダーではない　周安寧 start
      //kendo.ui.progress(cityGrid.element, false);
      this.setLoadingScreenVisible(false);
      // mod 8282 住所検索中が共通ローダーではない　周安寧 end
    },

    /**
     * @description 町域の選択後コールバック
     */
    selectTown(e) {
      // add 8282 住所検索中が共通ローダーではない　周安寧 start
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      // add 8282 住所検索中が共通ローダーではない　周安寧 end
      e.preventDefault();

      const selectedItem = e.sender.element
        .getKendoGrid()
        .dataItem(e.sender.element.getKendoGrid().select()[0]);

      this.selectedPref = selectedItem;
      this.selectedCity = selectedItem;
      this.selectedTown = selectedItem;

      if (selectedItem.townName === "以下に掲載がない場合") {
        this.selectedTown.townName = "";
      }
      // add 8282 住所検索中が共通ローダーではない　周安寧 start
      this.setLoadingScreenVisible(false);
      // add 8282 住所検索中が共通ローダーではない　周安寧 end
    },

    /**
     * @description kendo-gridで、ア行～ワ行フィルタにより、該当する項目(テーブル行)にスクロールする
     */
    jumpToRow(src, regex) {
      const grid =
        src === 0
          ? this.$refs.cityGrid.kendoWidget()
          : this.$refs.townGrid.kendoWidget();
      const rows = grid.items().toArray();
      const row = rows.find((item) => {
        return item.childNodes[1].innerHTML.match(regex);
      });

      // スクロールを上に寄せる処理
      if (row) {
        row.scrollIntoView();
      }
    },

    /**
     * @description フリーワード入力をすると、APIからデータを取得して、kendo-datasourceを作成
     *              入力後は500ミリ秒でAPIリクエストを遅延させる
     */
    updateSearchData: _.debounce(function () {
      if (!this.searchQuery) {
        this.searchGridData = [];
        return;
      }

      const searchEl = this.$refs.searchGrid.kendoWidget().element;
      const that = this;

      that.isSearchInitialLoad = true;

      that.searchGridData = new kendo.data.DataSource({
        transport: {
          read: {
            url: "api/mstInfo/sysAddress",
            dataType: "json",
          },
          parameterMap(data) {
            return {
              searchString: that.searchQuery,
              page: data.page - 1,
              size: data.pageSize,
            };
          },
        },
        pageSize: 100,
        serverPaging: true,
        schema: {
          data(response) {
            return response.d ? response.d.results : response.content;
          },
          total(response) {
            return response.totalElements;
          },
        },
        requestStart(e) {
          if (that.isSearchInitialLoad) {
            e.preventDefault();
            that.isSearchInitialLoad = !that.isSearchInitialLoad;
          }
          // mod 8282 住所検索中が共通ローダーではない　周安寧 start
          // add #10473 郵便番号検索が遅い 20240402 ztc start
          that.searchQueryDisabled = true;
          that.lastScrollTop = document.getElementsByClassName('k-grid-content k-auto-scrollable')[2].scrollTop;
          // add #10473 郵便番号検索が遅い 20240402 ztc end
          that.setLoadingScreenMessage("処理中・・・");
          that.setLoadingScreenVisible(true);
          // ロードアイコンを表示
          //kendo.ui.progress(searchEl, true);
          // mod 8282 住所検索中が共通ローダーではない　周安寧 end
        },
        requestEnd() {
          // mod 8282 住所検索中が共通ローダーではない　周安寧 start
          // add #10473 郵便番号検索が遅い 20240402 ztc start
          that.searchQueryDisabled = false;
          that.$nextTick(() => {
            that.$refs.searchInput.focus();
            document.getElementsByClassName('k-grid-content k-auto-scrollable')[2].scrollTop = that.lastScrollTop;
          })
          // add #10473 郵便番号検索が遅い 20240402 ztc end
          that.setLoadingScreenVisible(false);
          that.resetLoadingScreenVisibleCount();
          // ロードアイコンを非表示
          //kendo.ui.progress(searchEl, false);
          // mod 8282 住所検索中が共通ローダーではない　周安寧 end
        },
      });
   }, 500),
    selectAddress() {
      EventBus.$emit("selectPatInfoAddress", this.addressComputed);
      // mod #10789 新患登録画面を経由すると患者情報の住所が上書きできなくなる 本田 start
      // // add FutreNetWeb+SI課題管理No5546 趙 start
      // EventBus.$emit("selectPatInfoAddressOtherContact", this.addressComputed);
      // EventBus.$emit("selectPatInfoAddressVendorContact", this.addressComputed);
      // // add FutreNetWeb+SI課題管理No5546 趙 end
      EventBus.$emit("selectPatInfoAddressNew", this.addressComputed);
      EventBus.$emit("selectPatInfoAddressChange", this.addressComputed);
      EventBus.$emit("selectPatInfoAddressOtherContactNew", this.addressComputed);
      EventBus.$emit("selectPatInfoAddressOtherContactChange", this.addressComputed);
      EventBus.$emit("selectPatInfoAddressVendorContactNew", this.addressComputed);
      EventBus.$emit("selectPatInfoAddressVendorContactChange", this.addressComputed);
      // mod #10789 新患登録画面を経由すると患者情報の住所が上書きできなくなる 本田 end
    },

    // MultiSubModalから呼び出されている場合は、MultiSubModalの閉じる処理を呼ぶ
    hideModalIncludeSub() {
      if (this.subModalName === "") {
        this.hideModal();
      } else {
        this.subHideModal();
      }
    },

    // add FNSI7778-患者情報を編集したが保存ボタンが押せない。 limingyang start
    editSaveButton() {
      let res = {isDatePicker:true};
      EventBus.$emit("calendarFlag", res);
    },
    // add FNSI7778-患者情報を編集したが保存ボタンが押せない。 limingyang end

    // レイアウトの調整処理
    calculateHeight() {
      let modalBody = document.getElementsByClassName("modal-body");
      let tabContainer = document.getElementsByClassName("tab-container");
      if (modalBody.length > 0 && tabContainer.length > 0) {
        modalBody = modalBody[0];
        tabContainer = tabContainer[0];
        let tabArea = document.getElementsByClassName("address-search-tab-area");
        if (tabArea.length >= 4) {
          const tabHeight = (modalBody.offsetHeight - tabContainer.offsetHeight - 18) + "px";
          tabArea[0].style.height = tabHeight;
          tabArea[0].style.overflowY = "auto";
          tabArea[1].style.height = tabHeight;
          tabArea[2].style.height = tabHeight;
          tabArea[3].style.height = tabHeight;
        }
      }
    },

    // タブ移動時に高さがリセットされてしまう(kendoの動作と考える)為、タブ切替のタイミングでレイアウトの調整処理を実施
    activateCalc() {
      setTimeout(() => {
        this.calculateHeight();
      }, 200);
    }
  },
};
</script>

<style scoped>
.modal-container {
  height: auto;
  color: black;
  transform: none;
}

.modal-contents-custom >>> .k-widget {
  font-size: 1em;
}

.modal-header-custom {
  text-align: left;
  color: white;
  background-color: black;
  padding: 3px;
  height: auto;
  width: auto;
  position: initial;
}

.modal-footer-custom {
  padding: 10px;
}

.tab-container {
  display: block;
  text-align: left;
}

.tab-container > li {
  display: inline-block;
}

.k-tabstrip > .k-content {
  height: 100%;
  overflow: inherit;
}

.address-search-tab-area {
  border-bottom: 0px;
}

.grid-style {
  height: calc(100% - 5em);
}

/* mod FNSI-NO345 住所検索画面の不正。検索欄の切れ、表高さの不適切。 佟凯洋 start */
.grid-style >>> .k-grid-content {
  /* mod FNSI-NO345 住所検索画面の不正。検索欄の切れ、表高さの不適切。 関 start */
  /* height: 580px; */
  /* add by maxueqiang bug:4896 begin*/
  /* height: calc(700px - 10em); */
  height: calc(100% - 2em - 9px) !important;
  /* add by maxueqiang bug:4896 end*/
  /* mod FNSI-NO345 住所検索画面の不正。検索欄の切れ、表高さの不適切。 関 start */
  overflow: auto;
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}
/* mod FNSI-NO345 住所検索画面の不正。検索欄の切れ、表高さの不適切。 佟凯洋 end */
.grid-style >>> .k-grid-pager {
  display: none;
}
/*add #10473 郵便番号検索が遅い 20240402 ztc start*/
.grid-style >>> .k-loading-mask {
  display: none;
}
/*add #10473 郵便番号検索が遅い 20240402 ztc start*/

.address-search-table >>> .k-grid .k-grid-content tr {
  border-color: var(--master-maintenance-kgrid-border-color);
  color: var(--master-maintenance-kgrid-body-color);
  background-color: var(--master-maintenance-kgrid-item-background-color);
}
.address-search-table >>> .k-grid .k-grid-content tr:nth-child(2n) {
  background-color: var(--ntss-list-content-2nd-background-color);
}
.address-search-table >>> .k-grid tr.k-state-selected > td {
  color: unset;
}

.icon-close {
  float: right;
  padding: 3px;
  cursor: pointer;
}

.tab-content-title {
  text-align: left;
  border: 1px solid #dfdfe0;
  min-height: 1.4em;
}

.search-style {
  margin: 10px 0px;
  font-size: 1em;
  width: 100%;
  border: none;
  border-bottom: 1px solid #999;
}

.button-cancel {
  float: left;
}

.button-confirm {
  float: right;
}

.pref-label {
  border: 0.25px solid #e2e2e3;
  padding: 0px 5px;
}

.pref-map {
  border: 1px solid #dfdfe0;
  /* add by maxueqiang */
  /* overflow: auto;
  height: 452px; */
}

div > a {
  color: #0076ff;
  margin: 0px 5px;
}

/* TODO: 共通スタイル(modal.css)に定義 */
div >>> .modal-header .toolbar {
  background-color: var(--ntss-header-background-color);
}

div >>> .modal-header .toolbar__title.toolbar__left {
  color: var(--ntss-header-color) !important;
}

div >>> .modal-search,
div >>> .modal-body,
div >>> .modal-footer,
div >>> .modal-footer .bottom-bar,
div >>> .k-tabstrip .k-content {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}
/* add by maxueqiang */
div >>> .modal-body {
  overflow-y: hidden !important;
}
@media screen and (max-width: 768px) {
  /* .pref-map {
    overflow: auto;
  } */
}
@media print {
  .modal-container div {
    height: auto !important;
  }
  div >>> .modal-body {
    overflow: visible !important;
  }
  .pref-map {
    transform: scale(0.7);
  }
  div *,
  ons-row * {
    height: auto !important;
  }
  div > a {
    margin: 0px 1px;
  }
  /** 市区町村、町域名 表余白除去 */
  .address-search-table >>> .k-grid-header {
    padding-right: 0 !important;
  }
  .address-search-table >>> .k-selectable tbody tr td {
    white-space: wrap;
  }
}
/* 横向き */
@media print and (orientation: landscape) {
  .pref-map {
    transform: scale(0.6);
  }
  ons-row > ons-col:first-child {
    width: 40% !important;
    flex: 0 0 40% !important;
  }
  #map-canvas {
    width: 90% !important;
    flex: 0 0 90% !important;
    margin-top: -100px;
    margin-left: -150px;
  }
  ons-row {
    flex-wrap: nowrap !important;
  }
}
</style>
