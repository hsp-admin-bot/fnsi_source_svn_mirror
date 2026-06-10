/** * マスタ選択 */

<template>
  <!-- #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng start -->
  <!-- <v-ons-popover
    v-if="popoverVisibleDisea"
    :target="targetPositionElement"
    :visible="popoverVisibleDisea"
    :direction="popoverDisplayDirection"
    :class="[fontSizeSet, 'popover-style']"
    cancelable
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="closePopover(); popoverPosthide()"
  > -->
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
  <!-- #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng end -->
    <div>
      <v-ons-row>
        <h2 class="popover-header-style">{{ popoverTitleHeader }}</h2>
      </v-ons-row>
      <hr />
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
            class="btn2-cancel common-style-cancel-button button-cancel btn2-cancel"
            @click="closePopover"
          >
            キャンセル
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <v-ons-button
            class="btn1-execute common-style-ok-button button-confirm btn3-normal"
            @click="saveChanges"
            :disabled="this.popoverContentSelectedItem === undefined || isChanged"
          >
            OK
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </v-ons-popover>
</template>

<script>
import PopoverMixin from "@/components/PopoverMixin";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import {ApiHelper} from "@/apis/AxiosHelper";
import {mapGetters} from "vuex";
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";

export default {
  mixins: [PopoverMixin],

  props: {

    /* add スタッフ追加の複数追加と空欄追加 楊 start */
    popoverBlankLine: {
      type: Boolean,
      default: false,
    },
    /* add スタッフ追加の複数追加と空欄追加 楊 end */
    /**
     * @description ポップオーバー表示非表示
     */
    // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng start
    // popoverVisibleDisea: {
    popoverVisible: {
      type: Boolean,
      default: false,
    },
    // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng end

    /**
     * @description ポップオーバーヘッダーテキスト
     */
    popoverTitleHeader: {
      type: String,
      default: "",
    },

    // add FNSI-改修内容 保険マスタから選択する機能の改修 趙 start
    /**
     * @description フリーワード
     */
    popoverSearchQuery: {
      type: String,
      default: "",
    },
    // add FNSI-改修内容 保険マスタから選択する機能の改修 趙 end

    /**
     * @description 抽出条件
     *              ※ 何も渡さないと抽出条件の入力フィルドが表示されない
     *              ※ 配列の中身: { popoverFilterLabel: '', popoverFilterDataset: [] }
     */
    popoverFilter: {
      type: Array,
      default: () => [],
    },

    /**
     * @description 抽出条件の選択有効無効
     */
    popoverFilterDisabled: {
      type: Boolean,
      default: false,
    },

    /**
     * @description 抽出結果のラベル
     */
    popoverContentLabel: {
      type: String,
      default: "",
    },

    /**
     * @description 抽出する選択肢
     *              ※ 抽出結果は計算プロパティ「popoverFilteredContent」に定義されている
     */
    popoverContentDataset: {
      type: Array,
      default: () => [],
    },

    /**
     * @description 抽出結果の選択項目
     */
    popoverContentSelected: {
      type: Object,
      default: () => {
        return {
          value: "",
          fnValue: {},
          text: "",
        };
      },
    },

    /**
     * @description ポップオーバーの呼び出し元(DOMオブジェクト)
     */
    targetPositionElement: {
      type: [Object, HTMLElement],
      default() {
        return this.$parent;
      },
    },

    /**
     * @description 「未登録」選択の有無
     */
    hasUnregisteredOption: {
      type: Boolean,
      default: true,
    },

    /**
     * @description 選択肢の表示条件：削除済みもすべて表示させる場合、 true
     */
     isAllValues: {
      type: Boolean,
      default: true,
    },
  },

  data() {
    return {
      // popoverFilteredContent:[],

      popoverLocalContentDataset: [],

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
       * @description フリーワードによる抽出結果
       */
      popoverSearchDataset: [],

      // del FNSI-改修内容 保険マスタから選択する機能の改修 趙 start
      /**
       * @description フリーワード入力値
       */
      // popoverSearchQuery: "",
      // del FNSI-改修内容 保険マスタから選択する機能の改修 趙 end

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

      scrollerDataList:[],
      formData: { // 分页 一页20条
        pageIndex: 1,
        pageSize: 20,
    　},

      isChanged: false, // add #6512 患者情報画面-既往歴の病名の分の修正 劉
    };
  },
  directives: {
    loadMore: {
      bind(el, binding) {
        // 获取element-ui定义好的scroll盒子
        // console.log("loadMore.el is : ",el);
        const SELECTWRAP_DOM = el.getElementsByTagName('select')[0];
        SELECTWRAP_DOM.addEventListener("scroll", function () {
          const CONDITION =
            // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng start
            // this.scrollHeight - this.scrollTop <= this.clientHeight;
            Math.abs(this.scrollHeight - this.scrollTop - this.clientHeight) < 4;
            // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng end
          // console.log("SELECTWRAP_DOM.CONDITION is : ",CONDITION);
          if (CONDITION) {
            binding.value();
          }
        });
      },
    },
  },
  computed: {

    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    /**
     * @description 表示方向
     */
    popoverDisplayDirection() {
      // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng start
      // if (!this.popoverVisibleDisea) return null;
      if (!this.popoverVisible) return null;
      // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng end

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
     * @description 抽出結果
     *              ※ popoverContentDatasetから抽出条件によって絞り込む結果
     */
    popoverFilteredContent: {
      get() {
        let serchQuery = this.popoverSearchQuery;
        if(serchQuery){
          const q = new RegExp(this.popoverSearchQuery, "gi");
          return this.popoverLocalContentDataset.filter(item => {
              return item.text.search(q) > -1;
          });
        }else{
          if (this.scrollerDataList.length == 0){
              return this.scrollerData(this.formData);
          }else{
              return this.scrollerDataList;
          }
        }},
      set() {}
    },
  },

  watch: {
    // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng start
    // popoverVisibleDisea(visible) {
    popoverVisible(visible) {
    // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng end
      // console.log("popoverVisible is: ",visible);
      if (visible) {
        this.initializeFilterSelected();
      }
    },
    // add #6512 患者情報画面-既往歴の病名の分の修正 劉 start
    popoverContentSelectedItem: {
      handler(value) {
        this.isChanged = value === this.popoverContentSelected.value? true : false
      },
      immediate: true
    }
    // add #6512 患者情報画面-既往歴の病名の分の修正 劉 end
  },

  mounted() {
    // modify by 史 for 6119 ブラウザがOut of Memoryのエラーが発生する
    window.addEventListener("resize", this.resize);
  },
  methods: {
    // modify by 史 for 6119 ブラウザがOut of Memoryのエラーが発生する
    resize(){
      this.windowHeight = window.innerHeight;
      this.windowWidth = window.innerWidth;
    },
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    loadMoreData(){
      this.formData.pageIndex ++;
      this.scrollerDataList = this.scrollerData(this.formData);
    },
    // add 投薬支援マスタ 薬剤名css 鞠
    setListClassOne(cd) {
      const selectedList = this.popoverContentSelectedItem
        ? this.popoverContentSelectedItem
        : [];
      const obj = {
        "selected-color": false,
        "dis-selected-color": false,
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
    //add end

    scrollerData(formData){
      // console.log("scrollerData is begin : ",JSON.stringify(formData));
      const refArr = this.popoverLocalContentDataset;
      let retArr = [];
      let num = formData.pageIndex * formData.pageSize;

        retArr = refArr.filter((item,index) =>{
          return index < num;
        });
      /* mod スタッフ追加の複数追加と空欄追加 楊 start */
      if (this.hasUnregisteredOption && this.popoverBlankLine) {
        retArr.unshift({ text: "", value: null });
      } else if (this.hasUnregisteredOption) {
        retArr.unshift({ text: "未登録", value: null });
      }
      /* mod スタッフ追加の複数追加と空欄追加 楊 end */

      return retArr;
    },

    /**
     * @description ポップオーバー非表示
     */
    closePopover() {
      this.$emit("popover-close", false);
      // this.popoverVisibleDisea = false;
      this.popoverDirection = "";
      this.scrollerDataList=[];
      this.formData={ // 分页 一页20条
        pageIndex: 1,
        pageSize: 20,
    　};
      this.popoverLocalContentDataset = [];
      this.popoverFilteredContent = [];
      this.clearSearch();
    },

    /**
     * @description 抽出条件の初期化
     *              ※ 「popoverContentSelected」は指定されている場合、抽出結果に強調して、各抽出条件を指定する
     *              ※ 「popoverContentSelected」は指定されてない場合、各抽出条件を先頭の項目を指定する
     */
    async initializeFilterSelected() {

      // #9482 get flash disease data when popover being show up.
      let that = this;
      await ApiHelper.get("/mstInfo/mstDiseaseIncludeDeleted", {facilityCd: that.facilityCd}).then(
        res => {
          // データをマッピングする関数
          const mapData = (item) => ({
            value: item.cd,
            fnValue: item.facilityCd,
            text: item.nm,
          });

          if (!this.isAllValues) {
            that.popoverLocalContentDataset = res.data.filter(
              item => (item.isDisp !== "0" && item.isDel !== "1")
            ).map(mapData);
          } else {
            // 「新患/患者情報」以外の場合、すべて設定
            that.popoverLocalContentDataset = res.data.map(mapData);
          }

          that.popoverContentSelectedItem = that.popoverContentSelected.value;

          that.popoverFilter.forEach((item) => {
            that.popoverFilterSelectedItem = {
              ...that.popoverFilterSelectedItem,
              [item.popoverFilterLabel]: item.popoverFilterDataset[0].value,
            };
          });
        }
      ).catch(error => {
        getErrorMessage('DiseaMasterSelector.vue', 'created', error);
        throw error;
      })

    },

    /**
     * @description フリーワード入力クリア
     */
    clearSearch() {
      this.popoverSearchQuery = "";
      this.popoverSearchDataset = [];
    },

    /**
     * @description 選択項目を呼出元に返す
     */
    saveChanges() {
      let retVal =
        this.popoverContentSelectedItem === null
          ? { text: "", value: null }
          : this.popoverLocalContentDataset.find((item) => {
              return item.value === this.popoverContentSelectedItem;
            });

      this.$emit("popover-return", retVal);
      this.isChanged = true // add #6512 患者情報画面-既往歴の病名の分の修正 劉
      this.closePopover();
    },

    /**
     * @description 表示方向設定
     */
    setPopoverDirection(direction) {
      this.popoverDirection = direction;
    },

    /**
     * @description フリーワード用データセット設定
     */
    setPopoverSearchDataset(dataset) {
      this.popoverSearchDataset = dataset;
    },
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

.button-cancel {
  float: left;
}

.button-confirm {
  float: right;
}

.popover-footer-style {
  margin-top: 15px;
}

.needle-hidden {
  visibility: hidden;
  height: 0px;
}

.select-has-size {
  font-size: 13.3333px;
}

/* スマホ対応 */
@media screen and (max-width: 420px) {
  .popover-style >>> .popover__content {
    width: auto;
    padding: 10px;
  }
}

@media screen and (max-height: 420px) {
  .popover-style >>> .popover__content {
    width: 350px;
    padding: 5px;
  }
}
/* add start 鞠*/
.selected-color {
  background-color: #0076ff !important;
  color: white;
  width: max-content;
  min-width: 100%;
}
.dis-selected-color:hover {
  background-color: #dddddd;
}
/* add end 鞠*/
</style>
