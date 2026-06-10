<template>
  <div class="multi-select-list">
    <div v-for="(item, index) in itemList" :key="index" :class="computeClassItemLabel(item)">
      <label
        @click.exact="checkMultiItem(index);"
        @click.ctrl.exact="checkMultiItem(index);"
        @click.shift.exact="checkRangeItem(index);"
        @click.ctrl.shift.exact="checkMultiRangeItem(index);"
        @keydown.up.exact="checkPreItem(index, checkItem);"
        @keydown.down.exact="checkNextItem(index, checkItem);"
        @keydown.shift.up.exact="checkPreItem(index, checkRangeItem);"
        @keydown.shift.down.exact="checkNextItem(index, checkRangeItem);"
        ref="label"
        :tabindex="-1"
        class="item-label select-item-row"
      >
        <span class="item-name" :class="computeClassItemName(item)">{{ item.name }}</span>
      </label>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    // 表示対象データ配列
    itemList: {
      type: Array,
      required: true
    },
    // 全チェック解除
    // ※ソート機能が有効な場合にはチェックを解除しない.
    isUnchecked: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      // 直前のチェック項目インデックス
      latestCheckedIndex: null
    };
  },

  computed: {
    /**
     * @description 直前のチェック項目インデックスの絶対値
     * @summary 複数チェック解除時の負数インデックスを正数として扱うため
     */
    absLatestCheckedIndex() {
      return Math.abs(this.latestCheckedIndex);
    },

    /**
     * @description 直前のチェック解除フラグ
     * @summary 複数範囲選択時の特殊なチェック処理のため
     */
    isMultiUnchecked() {
      return this.latestCheckedIndex < 0;
    },

    /**
     * @description 項目名<label>要素
     * @summary キーイベントを発火させるためのフォーカス用
     */
    itemLabels() {
      return this.$refs.label;
    }
  },

  watch: {
    /**
     * @description 親の選択実行による項目一覧変化の監視
     */
    itemList() {
      this.latestCheckedIndex = null;
      // 全チェック解除
      if (this.isUnchecked) {
        this.itemList.forEach(item => (item.isChecked = false));
      }
    }
  },

  methods: {
    /**
     * @description 単一チェック処理
     * @summary クリックした1つの項目のみチェックフラグを立てる
     * @param {Number} checkedIndex チェック項目インデックス
     */
    checkItem(checkedIndex) {
      for (const index in this.itemList) {
        if (Number(index) === checkedIndex) {
          this.toggleCheck(index, true);
        } else {
          this.toggleCheck(index, false);
        }
      }
      this.latestCheckedIndex = checkedIndex;
    },

    /**
     * @description 複数チェック処理
     * @summary クリックした項目のチェック状態に応じてチェックフラグを切り替える
     * @param {Number} checkedIndex チェック項目インデックス
     */
    checkMultiItem(checkedIndex) {
      this.toggleCheck(checkedIndex, !this.itemList[checkedIndex].isChecked);
      if (this.itemList[checkedIndex].isChecked) {
        this.latestCheckedIndex = checkedIndex;
      } else {
        // 複数範囲チェック時の特殊処理判定用に負数とする
        this.latestCheckedIndex = checkedIndex * -1;
      }
    },

    /**
     * @description 範囲チェック処理
     * @summary 対象範囲のみチェックフラグを立てる
     * @param {Number} checkedIndex チェック項目インデックス
     */
    checkRangeItem(checkedIndex) {
      if (this.latestCheckedIndex === null) {
        // 未チェック時は1項目のみチェック
        this.latestCheckedIndex = checkedIndex;
        this.toggleCheck(checkedIndex, true);
        return;
      }
      const [startIndex, endIndex] = this.getRangeIndex(checkedIndex);
      for (const indexKey in this.itemList) {
        const itemIndex = Number(indexKey);
        if (startIndex <= itemIndex && itemIndex <= endIndex) {
          this.toggleCheck(itemIndex, true);
        } else {
          this.toggleCheck(itemIndex, false);
        }
      }
    },

    /**
     * @description 複数範囲チェック処理
     * @summary 複数の対象範囲にチェックフラグを立てる
     * @param {Number} checkedIndex チェック項目インデックス
     */
    checkMultiRangeItem(checkedIndex) {
      if (this.latestCheckedIndex === null) {
        // 未チェック時は何もしない
        return;
      }
      const [startIndex, endIndex] = this.getRangeIndex(checkedIndex);
      for (const indexKey in this.itemList) {
        const itemIndex = Number(indexKey);
        if (startIndex <= itemIndex && itemIndex <= endIndex) {
          // 通常は対象範囲をチェック、直前に複数チェック解除をしていた場合は対象範囲のチェックを全て外す
          this.toggleCheck(itemIndex, this.isMultiUnchecked ? false : true);
        }
      }
    },

    /**
     * @description 範囲チェック時の対象範囲取得
     * @summary 直前のチェック項目インデックスと現在のインデックスから対象チェック範囲を算出する
     * @param {Number} checkedIndex チェック項目インデックス
     */
    getRangeIndex(checkedIndex) {
      let startIndex, endIndex;
      if (checkedIndex <= this.absLatestCheckedIndex) {
        startIndex = checkedIndex;
        if (this.isMultiUnchecked) {
          endIndex = this.absLatestCheckedIndex - 1;
        } else {
          endIndex = this.absLatestCheckedIndex;
        }
      } else {
        endIndex = checkedIndex;
        if (this.isMultiUnchecked) {
          startIndex = this.absLatestCheckedIndex + 1;
        } else {
          startIndex = this.absLatestCheckedIndex;
        }
      }
      return [startIndex, endIndex];
    },

    /**
     * @description チェック状態切り替え
     * @summary
     *   イベントを発火し親にチェック状態を切り替えさせる
     *   (表示項目リストは親から渡されているため直接変更できない)
     * @param {Number} checkedIndex チェック項目インデックス
     * @param {Boolean} isChecked チェック状態
     */
    toggleCheck(checkedIndex, isChecked) {
      this.$emit("check", { checkedIndex, isChecked });
    },

    /**
     * @description 1つ上の項目を選択
     * @summary 現在のチェック項目の上の項目にフォーカスし、単一または範囲チェック処理を行う
     * @param {Number} checkedIndex チェック項目インデックス
     * @param {Function} checkFunction 単一、または範囲チェック関数
     */
    checkPreItem(checkedIndex, checkFunction) {
      if (checkedIndex > 0) {
        this.itemLabels[checkedIndex - 1].focus();
        checkFunction(checkedIndex - 1);
      }
    },

    /**
     * @description 1つ下の項目を選択
     * @summary 現在のチェック項目の下の項目にフォーカスし、単一または範囲チェック処理を行う
     * @param {Number} checkedIndex チェック項目インデックス
     * @param {Function} checkFunction 単一、または範囲チェック関数
     */
    checkNextItem(checkedIndex, checkFunction) {
      if (checkedIndex < this.itemList.length - 1) {
        this.itemLabels[checkedIndex + 1].focus();
        checkFunction(checkedIndex + 1);
      }
    },

    /**
     * @description チェック状態に応じたCSSクラス付与
     */
    computeClassItemLabel(selectedItem) {
      return {
        // マウスオーバー時の薄い背景色
        "item-label-hovered": !selectedItem.isChecked,
        // チェック時の背景色
        "item-label-checked": selectedItem.isChecked
      };
    },

    /**
     * @description チェック状態に応じたCSSクラス付与
     */
    computeClassItemName(selectedItem) {
      return {
        "item-name-checked": selectedItem.isChecked
      };
    }
  }
};
</script>

<style scoped>
/* マルチ選択リスト全体 */
.multi-select-list {
  height: 300px;
  border: 1px solid;
  overflow: auto;
}

/* マルチ選択項目ラベル */
.item-label {
  display: inline-block;
  width: 100%;
  outline: none;
  padding-top: 0.2em;
  padding-bottom: 0.2em;
}

/* マルチ選択項目ホバー時 */
.select-item-row:hover {
  background-color: #ddeeff80;
  transition: background-color 0.3s;
}

/* マルチ選択項目チェック時 */
.item-label-checked {
  background-color: #0076ff;
  transition: background-color 0.3s;
}

/* マルチ選択項目名 */
.item-name {
  user-select: none;
  margin-left: 5px;
}

/* マルチ選択項目名チェック時 */
.item-name-checked {
  color: white;
}
</style>
