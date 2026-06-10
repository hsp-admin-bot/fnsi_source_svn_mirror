<template>
  <div class="list-selector-div">
    <v-ons-row style="margin-top:5px; flex-wrap: nowrap;">
      <!-- 未選択リスト -->
      <v-ons-col width="40%">
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
      <v-ons-col width="40%">
        <selection-list
          :item-list="selectedItemList"
          :isUnchecked="!sort"
          @check="toggleCheckSelectedList"
        />
      </v-ons-col>
      <!-- 並び替えボタン -->
      <v-ons-col v-show="sort" class="select-item">
        <div class="select-item-button-area d-flex flex-column">
          <button
            class="k-button k-button-icon"
            @click="sortTopItem"
            :disabled="isSortDisable"
          >
            <span class="k-icon k-i-arrow-double-60-up"></span>
          </button>

          <button
            class="k-button k-button-icon"
            @click="sortUpItem"
            :disabled="isSortDisable"
          >
            <span class="k-icon k-i-arrow-60-up"></span>
          </button>

          <button
            class="k-button k-button-icon"
            @click="sortDownItem"
            :disabled="isSortDisable"
          >
            <span class="k-icon k-i-arrow-60-down"></span>
          </button>

          <button
            class="k-button k-button-icon"
            @click="sortBottomItem"
            :disabled="isSortDisable"
          >
            <span class="k-icon k-i-arrow-double-60-down"></span>
          </button>
        </div>
      </v-ons-col>
    </v-ons-row>
  </div>
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
 *
 *   ■props
 *     ・itemList(必須): 項目のオブジェクト配列
 *       ※専用の作成関数で作った配列を渡すこと
 *          @/functions/for-componet/ListSelector.js createItemListData()
 *     ・defaultSelection(任意): 初期表示時に選択済みとする項目コードの配列
 *     ・sort(任意): ソート有無フラグ
 *                   true: ソートボタンを表示
 *                   false: ソートボタンを非表示(デフォルト)
 *
 *   ■イベント
 *     ・update:selected-items
 *       発火タイミング: 選択済みのリスト変更時
 *       イベントハンドラ引数: {Array} 選択済み項目のオブジェクト配列 [{ cd, name }, ...]
 * @example
 */
import _ from "underscore";
import selectionList from "@/components/common/list-selector/SelectionList.vue";

export default {
  components: {
    "selection-list": selectionList
  },

  props: {
    itemList: {
      type: Array,
      default: () => []
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
     * 選択済の選択肢での並び替え機能有無
     * デフォルト(未指定時)はfalse
     */
    sort: {
      type: Boolean,
      default: false
    },
  },

  data() {
    return {
      // 表示項目リスト
      selectionItemList: [],
      /**
       * 並び替えボタンの活性、非活性フラグ
       */
      isSortDisable: true,
      /**
       * 選択項目リスト
       * ※画面右側に表示する項目リスト
       */
      selectedItemList: [],
    };
  },

  computed: {
    /**
     * @description 未選択項目リスト
     */
    unselectedItemList() {
      return this.selectionItemList.filter(item => !item.isSelected);
    }
  },

  created() {
    // 表示項目リストにチェックフラグと選択フラグを付与
    this.selectionItemList = this.itemList.map(item => {
      // 初期選択状態判定
      const defaultSelection = this.defaultSelection.map(info => {
        if (_.has(info, "cdType")) {
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
  },
  watch: {
    selectedItemList: {
      deep: true,
      handler(newList) {
        const selection = newList.map((item, index) => ({
          cd: item.cd,
          name: item.name,
          cdType: item.cdType,
          dispOrder: index + 1
        }));
        this.$emit("update:selected-items", selection);
      }
    }
  },

  methods: {
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
      // 選択項目リストでチェックされている場合、並び替えボタンを活性化
      this.isSortDisable = !this.hasCheckedItem();
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
        this.selectedItemList = this.selectedItemList;
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
      // ソートボタンの活性、非活性の制御
      this.isSortDisable = !this.hasCheckedItem();
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
      // ソートボタンの活性、非活性の制御
      this.isSortDisable = !this.hasCheckedItem();
    },

    /**
     * 選択されている項目を一番上に移動する.
     */
    sortTopItem() {
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
      this.selectedItemList = this.sortItem(this.selectedItemList);
    },

    /**
     * 選択されている項目を一つ下に移動する.
     */
    sortDownItem() {
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
      // 未選択の項目の取得
      const unCheckedItems = this.selectedItemList.filter(item => !item.isChecked);
      // 取得した未選択項目リストに行選択されている項目を追加
      unCheckedItems.push(...this.selectedItemList.filter(item => item.isChecked));
      this.selectedItemList = unCheckedItems;
    },

    /**
     * 選択済リストで行選択されている項目があるか否か
     * @returns 行選択されている場合はtrue、それ以外はfalse
     */
    hasCheckedItem() {
      return this.selectedItemList.filter(item => item.isChecked).length > 0;
    },
  }
};
</script>

<style scoped>
.select-item-button-area {
  width: 100%;
  min-width: 60px;
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

</style>
