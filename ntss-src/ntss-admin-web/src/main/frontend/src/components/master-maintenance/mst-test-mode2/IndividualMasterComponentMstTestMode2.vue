/**
 * マスタメンテナンス 独自マスタ編集のサンプル（メインコンポーネント）
 * マスタ一覧から「独自マスタ」を選択すると表示されます。
 */
<template>
  <div class="main-content-area">
    <h1>独自マスタのメイン</h1>
  </div>
</template>

<script>
import NextTransitionMixin from "@/components/NextTransitionMixin";

export default {
  name: "MstTestMode2",
  mixins: [NextTransitionMixin],


};
</script>

<style scoped>
</style>
