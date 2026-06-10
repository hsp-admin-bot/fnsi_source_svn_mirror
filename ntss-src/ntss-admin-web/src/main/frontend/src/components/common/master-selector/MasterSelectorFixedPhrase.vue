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
        <h2 class="popover-header-style">定型文</h2>
      </v-ons-row>
      <hr />
      <v-ons-row
        v-for="filter in popoverFilter"
        :key="filter.popoverFilterLabel"
        class="div-style"
      >
        <v-ons-col width="30%">
          <label class="label-style">種類</label>
        </v-ons-col>
        <v-ons-col>
          <select
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
          </select>
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
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="div-style">
        <v-ons-col width="30%">
          <label class="label-style">定型文</label>
        </v-ons-col>
        <v-ons-col>
          <select
            v-model="popoverContentSelectedItem"
            class="select-content-style select-has-size"
            size="10"
            @dblclick="saveChanges"
          >
            <option
              v-for="content in popoverFilteredContent"
              :key="content.id"
              :value="content.value"
            >
              {{ content.text }}
            </option>
          </select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col>
          <v-ons-button
            class="btn2-cancel common-style-cancel-button button-cancel"
            @click="closePopover"
          >
            キャンセル
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <v-ons-button
            class="btn1-execute common-style-ok-button button-confirm"
            @click="saveChanges"
          >
            OK
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </v-ons-popover>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import _ from "underscore";
import { ApiHelper } from "@/apis/AxiosHelper";
import { TAB_DEFINE_CD_FIXED_PHRASE } from "@/constants/PersonalSettingConstants";
import PopoverMixin from "@/components/PopoverMixin";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";

// URI
const uriGetComFixedPhrase = "mstInfo/mstComFixedPhrase/";

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
     * @description 抽出結果の選択項目
     */
    popoverContentSelected: {
      type: Object,
      default: () => {
        return {
          value: "",
          text: "",
          comPersonal: ""
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
    }
  },

  data() {
    return {
      /**
       * @description 抽出する選択肢
       *              ※ 抽出結果は計算プロパティ「popoverFilteredContent」に定義されている
       */
      popoverContentDataset: [],

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
       * @description フリーワードによる抽出結果
       */
      popoverSearchDataset: [],

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
       * @description 個人用定型文
       */
      personalFixedPhraseList: [],

      /**
       * @description 職種別共通定型文
       */
      comFixedPhraseList: []
    };
  },

  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),

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
        if (this.windowWidth > 420) {
          // heightが狭い(スマホ横とか)ときは上下じゃ途切れるので右か左に表示
          if (elemPosition.right < this.windowWidth / 2) {
            direction = "right";
          } else {
            direction = "left";
          }
        } else {
          // heightが狭い & widthも狭い(Androidで文字入力中の場合など)は上か下に表示
          if (elemPosition.top < this.windowHeight / 2) {
            direction = "down";
          } else {
            direction = "up";
          }
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
    popoverFilteredContent() {
      const refArr = this.popoverSearchQuery
        ? this.popoverSearchDataset
        : this.popoverContentDataset;
      let retArr = [];

      if (this.popoverSearchQuery) {
        const q = new RegExp(this.popoverSearchQuery, "gi");

        retArr = refArr.filter(item => {
          return item.text.search(q) > -1;
        });
      } else {
        retArr = refArr.filter(item => {
          const filterVal = this.popoverFilterSelectedItem[
            this.popoverFilter[0].popoverFilterLabel
          ];
          // 種類(すべて、個人用定型文、共通定型文)を取得
          const searchVal = item.comPersonal;

          if (filterVal === "0") {
            // "すべて"を選択した場合
            return true;
          } else if (filterVal !== searchVal) {
            // 1件のフィルタ(且条件)に満たされないため、抽出結果に加えない
            return false;
          } else {
            // 検索条件に合致する
            return true;
          }
        });

        this.setPopoverSearchDataset(retArr);
      }

      retArr.unshift({ text: "未登録", value: null });

      return retArr;
    }
  },

  async mounted() {
    window.addEventListener("resize",this.resizeEventListener);
    // フィルターを設定する
    const filterDataset = [
      { text: "すべて", value: "0" },
      { text: "個人設定", value: "1" },
      { text: "共通設定", value: "2" }
    ];
    this.popoverFilter = [
      {
        popoverFilterLabel: "種類",
        popoverFilterDataset: filterDataset
      }
    ];

    await this.fetchPersonalFixedPhraseList();
    await this.fetchComFixedPhraseList();

    for (let idx = 0; idx < this.personalFixedPhraseList.length; idx++){
      let phrase = {};
      phrase.id = this.personalFixedPhraseList[idx].identifier;
      phrase.value = this.personalFixedPhraseList[idx].value;
      phrase.text = this.personalFixedPhraseList[idx].value;
      phrase.comPersonal = "1";

      this.popoverContentDataset.push(phrase);
    }

    for (let idx = 0; idx < this.comFixedPhraseList.length; idx++){
      let phrase = {};
      phrase.id = this.comFixedPhraseList[idx].comFixedPhraseCd;
      phrase.value = this.comFixedPhraseList[idx].comFixedPhrase;
      phrase.text = this.comFixedPhraseList[idx].comFixedPhrase;
      phrase.comPersonal = "2";

      this.popoverContentDataset.push(phrase);
    }
    this.initializeFilterSelected();
  },
  methods: {
    ...mapActions("personal-setting", ["getPersonalSettings", "setPersonalSettingsTmp", "setComFixedPhraseList"]),
    ...mapGetters("personal-setting", ["getPersonalSettingsTmp", "getComFixedPhraseList"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // modify by 史 for 6119 ブラウザがOut of Memoryのエラーが発生する
    resizeEventListener(){
      this.windowHeight = window.innerHeight;
      this.windowWidth = window.innerWidth;
    },
    /**
     * @description ポップオーバー非表示
     */
    closePopover() {
      this.$emit("popover-close", false);
      this.popoverDirection = "";
    },

    /**
     * @description 抽出条件の初期化
     *              ※ 「popoverContentSelected」は指定されている場合、抽出結果に強調して、各抽出条件を指定する
     *              ※ 「popoverContentSelected」は指定されてない場合、各抽出条件を先頭の項目を指定する
     */
    initializeFilterSelected() {
      if (!_.isEmpty(this.popoverContentSelected.value)) {
        this.popoverContentSelectedItem = this.popoverContentSelected.value;
      }

      // 未選択状態 → 初期フィルタは「すべて」
      this.popoverFilter.forEach(item => {
        this.popoverFilterSelectedItem = {
          ...this.popoverFilterSelectedItem,
          [item.popoverFilterLabel]: "0"
        };
      });
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
          : this.popoverContentDataset.find(item => {
              return item.value === this.popoverContentSelectedItem;
            });

      this.$emit("popover-return", retVal);
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

    /**
     * @description 抽出条件の選択項目が変わる時のコールバック
     */
    filterChange() {
      this.clearSearch();
    },

    /**
     * 個人用定型文取得
     */
    async fetchPersonalFixedPhraseList() {
      let personalSettings = [];
      // mod bug 5482 修正 chen start
      let personalSettingsTmp =  this.getPersonalSettingsTmp();
      if (!personalSettingsTmp) {
        personalSettingsTmp = await this.getPersonalSettings(TAB_DEFINE_CD_FIXED_PHRASE);
        this.setPersonalSettingsTmp(personalSettingsTmp);
      }
      const response = personalSettingsTmp;
      // const response = await this.getPersonalSettings(TAB_DEFINE_CD_FIXED_PHRASE);
      // mod bug 5482 修正 chen end
      if (response.data.length === 0) {
        personalSettings = [];
      } else {
        personalSettings = response.data;
      }
      this.personalFixedPhraseList = personalSettings;
    },

    /**
     * 共通定型文取得
     */
    async fetchComFixedPhraseList() {
      let comSettings = [];
      if (this.getStateUserAccountInfo.jobCd) {
        // mod bug 5482 修正 chen start
        let response = null;
        let comFixedPhraseListTmp = this.getComFixedPhraseList();
        if (comFixedPhraseListTmp.length > 0) {
          let jobCdComFixedPhraseList = comFixedPhraseListTmp.filter(el => el.id === this.getStateUserAccountInfo.jobCd);
          if (jobCdComFixedPhraseList.length > 0) {
            response = jobCdComFixedPhraseList[0].response;
          }
        }
        if (!response) {
          response = await ApiHelper.get(uriGetComFixedPhrase + this.getStateUserAccountInfo.jobCd);
          comFixedPhraseListTmp.push({id: this.getStateUserAccountInfo.jobCd, response: response});
          this.setComFixedPhraseList(comFixedPhraseListTmp);
        }
        // const response = await ApiHelper.get(uriGetComFixedPhrase + this.getStateUserAccountInfo.jobCd)
        // mod bug 5482 修正 chen end
        if (response.data.length > 0) {
          comSettings = response.data;
        }
      }
      this.comFixedPhraseList = comSettings;
    }
  },
  beforeDestroy() {
    window.removeEventListener("resize", this.resizeEventListener);
    // dataの初期化
    this.popoverContentDataset = [];
    this.popoverFilter = [];
    this.popoverFilterSelectedItem = {};
    this.popoverContentSelectedItem = null;
    this.popoverSearchDataset = [];
    this.popoverSearchQuery = "";
    this.popoverDirection = "";
    this.windowHeight = null;
    this.windowWidth = null;
    this.personalFixedPhraseList = [];
    this.comFixedPhraseList = [];
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
