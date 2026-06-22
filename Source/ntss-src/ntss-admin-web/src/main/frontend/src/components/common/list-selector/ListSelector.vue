<template>
  <v-ons-popover
    :class="[fontSizeSet, 'popover-style']"
    :visible="visible"
    :target="target"
    cancelable
    :direction="popoverDisplayDirection"
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="closeComponent(); popoverPosthide()"
  >
    <div class="list-selector-div">
      <v-ons-row> {{ title }} </v-ons-row>
      <!-- 区分1 -->
      <v-ons-row v-if="class1 !== null">
        <v-ons-col width="100px"> {{ class1.label }}</v-ons-col>
        <v-ons-col>
          <v-ons-select v-model="class1Cd">
            <option value="">指定しない</option>
            <option
              v-for="(classObj, index) in class1.classes"
              :key="index"
              :value="classObj.cd"
            >
              {{ classObj.name }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <!-- 区分2 -->
      <v-ons-row v-if="class2 !== null">
        <v-ons-col width="100px"> {{ class2.label }}</v-ons-col>
        <v-ons-col>
          <v-ons-select v-model="class2Cd">
            <option value="">指定しない</option>
            <option
              v-for="(classObj, index) in class2.classes"
              :key="index"
              :value="classObj.cd"
            >
              {{ classObj.name }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <!-- フリーワード抽出 -->
      <v-ons-row class="flex-align-center">
        <!-- add 130px 鞠 文字サイズ：特大の際のレイアウト不正     -->
        <v-ons-col width="130px" style="flex: 0 0 130px; max-width: 130px;"> フリーワード</v-ons-col>
        <v-ons-col class="mb-1"><input v-model="freeWord" type="text"/></v-ons-col>
      </v-ons-row>
      <v-ons-row style="margin-top:5px; flex-wrap: nowrap;">
        <!-- 未選択リスト -->
        <v-ons-col width="200px">
          <selection-list
            :item-list="unselectedItemList"
            @check="toggleCheckUnselectedList"
          />
        </v-ons-col>
        <!-- 選択ボタン -->
        <v-ons-col class="select-item">
          <div class="select-item-button-area d-flex flex-column">
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
        <!-- 選択リスト -->
        <v-ons-col width="200px">
          <selection-list
            :item-list="selectedItemList"
            :isUnchecked="!sort"
            @check="toggleCheckSelectedList"
          />
        </v-ons-col>
        <!-- 並び替えボタン -->
        <v-ons-col v-show="sort" class="select-item">
          <div class="select-item-button-area d-flex flex-column list-selector-sort-buttons">
            <button
              type="button"
              class="k-button k-button-icon list-selector-sort-btn"
              @click="sortTopItem"
              :disabled="isSortDisable"
            >
              <span class="k-icon k-i-arrow-double-60-up"></span>
            </button>

            <button
              type="button"
              class="k-button k-button-icon list-selector-sort-btn"
              @click="sortUpItem"
              :disabled="isSortDisable"
            >
              <span class="k-icon k-i-arrow-60-up"></span>
            </button>

            <button
              type="button"
              class="k-button k-button-icon list-selector-sort-btn"
              @click="sortDownItem"
              :disabled="isSortDisable"
            >
              <span class="k-icon k-i-arrow-60-down"></span>
            </button>

            <button
              type="button"
              class="k-button k-button-icon list-selector-sort-btn"
              @click="sortBottomItem"
              :disabled="isSortDisable"
            >
              <span class="k-icon k-i-arrow-double-60-down"></span>
            </button>
          </div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="close-commit-area">
          <v-ons-button
            class="btn2-cancel common-style-cancel-button"
            @click="closeComponent()"
          >
            キャンセル
          </v-ons-button>
          <v-ons-button class="button registration-btn common-style-select-button" @click="commitSelection()">
            確定
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </v-ons-popover>
</template>

<script>
/**
 * @description リスト選択コンポーネント
 * @summary 左の未選択リストから項目を選択して右の選択済みリストに移したり、その逆をしたりするUI
 *   ■機能
 *     ○チェック操作
 *       ・単一チェック: クリック / 上下キー
 *       ・複数チェック: ctrl+クリック
 *       ・範囲チェック: shift+クリック / shift+上下キー
 *       ・複数範囲チェック: ctrl+shift+クリック / shift+上下キー
 *     ○選択/未選択操作
 *       ・チェック項目を選択/未選択リストへ移動する
 *     ○項目のフィルタリング
 *       ・propsで定義した区分
 *       ・フリーワード
 *     ○選択項目の取得
 *       ・選択操作を行い確定すると選択済みリストの一覧を返す
 *
 *   ■props
 *     ・itemList(必須): 項目のオブジェクト配列
 *       ※専用の作成関数で作った配列を渡すこと
 *          @/functions/for-componet/ListSelector.js createItemListData()
 *     ・class1/2(任意): 分類フィルタのオブジェクト配列
 *       ※専用の作成関数で作った配列を渡すこと
 *          @/functions/for-componet/ListSelector.js createClassData()
 *     ・defaultSelection(任意): 初期表示時に選択済みとする項目コードの配列
 *     ・title(任意): 画面上部に表示するタイトル
 *     ・visible(必須): 表示フラグ
 *       ※sync修飾子を付与すること
 *     ・target(必須): ポップオーバーの表示起点要素
 *     ・sort(任意): ソート有無フラグ
 *                   true: ソートボタンを表示
 *                   false: ソートボタンを非表示(デフォルト)
 *
 *   ■イベント
 *     ・commit
 *       発火タイミング: 確定ボタン押下時
 *       イベントハンドラ引数: {Array} 選択済み項目のオブジェクト配列 [{ cd, name }, ...]
 * @example
 */
import selectionList from "@/components/common/list-selector/SelectionList.vue";
import PopoverMixin from "@/components/PopoverMixin";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { getViewportHeight, getViewportWidth } from "@/functions/common/LayoutMeasureHelper";

export default {
  mixins: [PopoverMixin],

  components: {
    "selection-list": selectionList
  },

  props: {
    itemList: {
      type: Array,
      default: () => []
    },

    class1: {
      type: Object,
      default: null
    },

    class2: {
      type: Object,
      default: null
    },

    /**
     * @summary コードが重複する場合、キー設定
     * [{cd: 1, cdType: null}, {cd: 1, cdType: '2'}]
     */
    defaultSelection: {
      type: Array,
      default: () => []
    },

    /**
     * タイトル
     */
    title: {
      type: String,
      default: ""
    },

    /**
     * 表示フラグ
     */
    visible: {
      type: Boolean,
      default: false
    },

    /**
     * 表示方向
     */
    target: {
      required: true
    },

    /**
     * 選択済の選択肢での並び替え機能有無
     * デフォルト(未指定時)はfalse
     */
    sort: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      // 表示項目リストにチェックフラグと選択フラグを付与したリスト
      selectionItemList: [],
      class1Cd: "",
      class2Cd: "",
      freeWord: "",
      /**
       * 選択項目リスト
       * ※画面右側に表示する項目リスト
       */
      selectedItemList: [],
      /**
       * @description 画面の幅(レスポンシブ対応)
       */
      windowWidth: getViewportWidth(),
      /**
       * @description 画面の高さ(レスポンシブ対応)
       */
      windowHeight: getViewportHeight()
    };
  },

  computed: {
    // add redmine 4544 小窓表示にするとモーダルが見切れる 孔 start
    /**
     * @description 表示方向
     */
    popoverDisplayDirection() {
      if (!this.visible) return null;

      const elemPosition = this.target.$el
        ? this.target.$el.getBoundingClientRect()
        : this.target.getBoundingClientRect();
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

      return direction;
    },
    // add redmine 4544 小窓表示にするとモーダルが見切れる 孔 end
    /**
     * @description 区分とフリーワードによるフィルタリング済みリスト
     */
    filteredList() {
      // 除外される項目のチェックを外す
      this.selectionItemList
        .filter(item => !item.name.includes(this.freeWord))
        .forEach(item => (item.isChecked = false));
      // 区分1でフィルタリング
      let filteredList = this.selectionItemList;
      if (this.class1 !== null && this.class1Cd !== "") {
        filteredList = filteredList.filter(
          item => item.class1 === this.class1Cd);
      }
      // 区分2でフィルタリング
      if (this.class2 !== null && this.class2Cd !== "") {
        filteredList = filteredList.filter(
          item => item.class2 === this.class2Cd);
      }
      // フリーワードでフィルタリング
      if (this.freeWord !== "") {
        filteredList = filteredList.filter(item =>
          item.name.includes(this.freeWord));
      }
      return filteredList;
    },

    /**
     * @description 未選択項目リスト
     */
    unselectedItemList() {
      return this.filteredList.filter(item => !item.isSelected);
    },

    /**
     * 選択済リストで行がチェックされているか（並び替えの対象があるか）
     * ※ここで .some まで書いておかないと、computed から methods 経由だと
     *   isChecked の依存が取れず disabled が更新されない場合がある
     */
    hasCheckedSelectedRow() {
      return this.selectedItemList.some(item => !!item.isChecked);
    },

    /**
     * 選択済で行チェックが無い、またはソート無効時は並び替えボタンを無効化
     */
    isSortDisable() {
      if (!this.sort) {
        return true;
      }
      return !this.hasCheckedSelectedRow;
    }
  },

  created() {
    // 表示項目リストにチェックフラグと選択フラグを付与
    this.selectionItemList = this.itemList.map(item => {
      // 初期選択状態判定
      const defaultSelection = this.defaultSelection.map(info => {
        if (Object.prototype.hasOwnProperty.call(info, "cdType")) {
          return info.cdType === item.cdType ? info.cd : null;
        } else {
          return info;
        }
      });
      const isDefaultSelected = defaultSelection.includes(item.cd);
      // 表示順
      // ※defaultSelectionに格納されている順番は表示順である事
      const defaultDispOrder = defaultSelection.indexOf(item.cd);
      return { ...item, isChecked: false, isSelected: isDefaultSelected , dispOrder: defaultDispOrder};
    });
    // 選択項目リスト
    this.selectedItemList = this.selectionItemList.filter(item => item.isSelected);
    // ソートが有効な場合
    if (this.sort) {
      // 表示順番による並び替え
      this.selectedItemList.sort((a, b) => (a.dispOrder < b.dispOrder) ? -1 : 1);
    }
    // 並び替えボタン表示の為、ポップオーバ幅を変更
    this.$nextTick(() => {
      const element = this.$el.querySelector(".list-selector-div");
      element.style.width = (this.sort && element) ? "595px" : "510px";
    });

  },

  methods: {
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * @description 未選択項目リストのチェック切り替え
     * @summary 子のチェックイベントを購読し表示項目リストにチェック状態を反映する
     * @param {Object} { checkedIndex(チェック項目インデックス), isChecked(チェック状態) }
     */
    toggleCheckUnselectedList({ checkedIndex, isChecked }) {
      this.unselectedItemList[checkedIndex].isChecked = isChecked;
    },

    /**
     * @description 選択項目リストのチェック切り替え
     * @summary 子のチェックイベントを購読し表示項目リストにチェック状態を反映する
     * @param {Object} { checkedIndex(チェック項目インデックス), isChecked(チェック状態) }
     */
    toggleCheckSelectedList({ checkedIndex, isChecked }) {
      this.selectedItemList[checkedIndex].isChecked = isChecked;
    },

    /**
     * @description 項目全選択処理
     * @summary 全ての項目を選択状態とする
     */
    selectAllItem() {
      // ソートが有効な場合
      if (this.sort) {
        // 非選択項目リストに表示されている全項目を選択項目リストへ追加
        this.selectedItemList.push(...this.unselectedItemList.filter(item => !item.isSelected));
      } else {
        // mod FNSI-改修内容5668修正 関 start
        // this.selectedItemList = this.selectedItemList;
        this.selectedItemList = this.filteredList;
        // mod FNSI-改修内容5668修正 関 end
      }
      // 非選択項目リスト内の全項目の選択フラグを更新
      this.unselectedItemList.forEach(item => {
        item.isChecked = false;
        item.isSelected = true;
      });
    },

    /**
     * @description 項目選択処理
     * @summary チェック状態の項目を選択状態とする
     */
    selectItem() {
      // ソートが有効な場合
      if (this.sort) {
        // 非選択項目リストで選択されている項目を選択項目リストへ追加
        this.selectedItemList.push(...this.unselectedItemList.filter(item => item.isChecked));
      }
      // 非選択項目リストのフラグを更新
      this.unselectedItemList
        .filter(item => item.isChecked)
        .forEach(item => {
          item.isChecked = false;
          item.isSelected = true;
        });
      // ソート不要の場合
      if (!this.sort) {
        this.selectedItemList = this.selectionItemList.filter(item => item.isSelected);
      }
    },

    /**
     * @description 項目選択解除処理
     * @summary チェック状態の項目を未選択状態とする
     */
    unselectItem() {
      // 選択されていない項目でリストを再構築
      this.selectedItemList = this.selectedItemList.filter(item => !item.isChecked);
      // フラグを更新
      this.selectionItemList
        .filter(item => item.isChecked)
        .forEach(item => {
          item.isChecked = false;
          item.isSelected = false;
        });
    },

    /**
     * @description 項目全選択解除処理
     * @summary 全ての項目を未選択状態とする
     */
    unselectAllItem() {
      // 選択リストをクリア
      this.selectedItemList = [];
      // 全項目のフラグを更新
      this.selectionItemList.forEach(item => {
        item.isChecked = false;
        item.isSelected = false;
      });
    },

    /**
     * 選択されている項目を一番上に移動する.
     */
    sortTopItem() {
      if (this.isSortDisable) {
        return;
      }
      // 行選択されている項目を取得
      const checkedItems = this.selectedItemList.filter(item => item.isChecked);
      // 取得した行選択リストに行未選択の項目を追加
      checkedItems.push(...this.selectedItemList.filter(item => !item.isChecked));
      this.selectedItemList = checkedItems;
    },

    /**
     * 選択されている項目を一つ上に移動する.
     */
    sortUpItem() {
      if (this.isSortDisable) {
        return;
      }
      this.selectedItemList = this.sortItem(this.selectedItemList);
    },

    /**
     * 選択されている項目を一つ下に移動する.
     */
    sortDownItem() {
      if (this.isSortDisable) {
        return;
      }
      this.selectedItemList = this.sortItem(this.selectedItemList.reverse());
      // 逆順を元に戻す
      this.selectedItemList.reverse();
    },

    /**
     * リストの並び替え処理
     * @param sortItemList 並び替え対象のリスト
     * @returns 並び替えた結果のリスト
     */
    sortItem(sortItemList) {
      sortItemList.forEach((item, index) => {
        // index===0又は、選択されていない場合はスキップ.
        if (index === 0 || !item.isChecked) {
          return;
        }
        const idx = index - 1;
        sortItemList.splice(idx, 2, sortItemList[idx + 1], sortItemList[idx]);
      });
      return sortItemList;
    },

    /**
     * 選択されている項目を一番下に移動する.
     */
    sortBottomItem() {
      if (this.isSortDisable) {
        return;
      }
      // 未選択の項目の取得
      const unCheckedItems = this.selectedItemList.filter(item => !item.isChecked);
      // 取得した未選択項目リストに行選択されている項目を追加
      unCheckedItems.push(...this.selectedItemList.filter(item => item.isChecked));
      this.selectedItemList = unCheckedItems;
    },

    /**
     * @description 選択確定処理
     * @summary 選択リストから不要なフラグを除去しイベントとして渡す
     */
    commitSelection() {
      const selection = this.selectedItemList.map((item, index) => ({
        cd: item.cd,
        name: item.name,
        cdType: item.cdType,
        dispOrder: index + 1
      }));
      this.$emit("commit", selection);
      this.closeComponent();
    },

    closeComponent() {
      this.$emit("update:visible", false);
    }
  }
};
</script>

<style scoped>
/* ntss.css の width:300px の打ち消しが必要 */
.popover-style :deep(.popover--top) {
  width: unset;
}
/*add bug #5054 修正 chen start*/
@media screen and (max-width: 600px){
  .list-selector-div {
    /* 横スクロール発生時に右側のpaddingが見切れる為の対策 */
    padding-right: 10px;
  }
}
/*add bug #5054 修正 chen end*/

.select-item-button-area {
  width: 100%;
  min-width: 60px;
}

/** 並び替えボタンのスタイル */
.select-item-button,
.sort-item-button {
  width: 50%;
  font-size: 20px;
  margin: 2px 0;
  cursor: pointer;
  border-style: outset;
  border-image-repeat: stretch;
  border-color: unset;
}

.k-button {
  margin: auto;
  box-shadow: none;
  margin-bottom: 0.4em;
}

.select-item-button:disabled,
.sort-item-button:disabled {
  cursor: default;
}

/* 配置位置 */
.popover-style :deep(.popover__content) {
  width: auto;
  padding: 10px;
  margin: 3px;
}

.close-commit-area {
  display: flex;
  justify-content: space-between;
  margin-top: 5px;
}

.select-item {
  display: flex;
  align-items: center;
  text-align: center;
}

.mb-1 {
  margin-bottom: 0.25em;
}

/* 無効時もグローバルスタイル等でクリックが貫通するのを防ぐ */
.list-selector-sort-buttons .list-selector-sort-btn:disabled {
  pointer-events: none;
  opacity: 0.45;
  cursor: not-allowed;
}
</style>