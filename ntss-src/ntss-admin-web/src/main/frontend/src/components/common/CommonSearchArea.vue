<template>
  <div id='condition-search-top-area' class='condition-search-area' @click="emitShowPopover($event)">
    <!-- スクロールバー位置調整用div -->
    <div style="overflow: auto; height: 100%; width: 100%;" class="print_condition-search-area">
      <div
        v-if="isRequestCond"
        class='condition-search-icon-area'
        style="line-height: unset; height: 5em; display: flex; align-items: center;">
        <div style="word-break: break-all; width: 2.5em; font-size:1.3em;">依頼条件</div>
      </div>
      <div
        v-else
        class='condition-search-icon-area'
        :style="{ 'line-height': lineHeight ? lineHeight : null }">
        <v-ons-icon icon='fa-search' size='2.0em' style="color:gray;"></v-ons-icon>
      </div>
      <div class='condition-items-area'>
        <label v-for="(condition, index) in conditionList" :key="index"
          class='condition-label'>
          {{ condition.name ? condition.name + '：' : null }}{{ condition.text }}
        </label>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * @description 共通検索エリア
 * @example
 *   ■ ポップオーバー呼出
 *     ・show-popoverでemitしているので、下記の様に呼び出してください
 *       @show-popover='showPopover($event)'
 *
 *   ■ パラメータ
 *     ・lineHeight   ：アイコン位置(高さ)を調整する (例→:lineHeight="'7em'")
 *                      1行表示(height:4.7em基準)の場合は、3.8emを指定する
 *     ・conditionList：共通検索エリアに表示するデータの配列
 *     ・isRequestCond：検査依頼、一般撮影検査依頼画面では表示を変える
 *
 *   ■ conditionList のデータ形式
 *     ・name を省略すると、表示ラベルのない形式で表示します
 *     [
 *       {
 *         name："表示ラベル名",
 *         text："検索条件テキスト"
 *       },
 *       {
 *         text："検索条件テキスト"
 *       }
 *       ....
 *     ]
 */
export default {
  props: {
    /**
     * @description アイコン位置調整
     */
    lineHeight: {
      type: String,
      default: ""
    },
    /**
     * @description 検索条件テキスト
     */
    conditionList: {
      type: Array,
      default: () => []
    },
    /**
     * @description 検索条件テキスト
     */
    isRequestCond: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {};
  },

  methods: {
    /**
     * ポップオーバー表示
     */
    emitShowPopover(event) {
      let rtnTarget = event;
      if (event.target.classList.contains("condition-label") || event.target.classList.contains("condition-items-area")) {
        // condition-label、condition-items-area にはスクロールが発生している場合がある為、親要素を返す
        rtnTarget = event.target.closest(".condition-search-area");
      }
      this.$emit('show-popover', rtnTarget);
    }
  }
};
</script>

// add 印刷レイアウト対応 解 start
<style scoped lang="scss">
@media print {
  .print_condition-search-area {
    overflow: auto !important;
  }
}
</style>
// add 印刷レイアウト対応 解 end
