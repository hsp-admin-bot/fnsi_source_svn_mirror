<template>
  <div class="side-bar">
    <kendo-tabstrip style="overflow-y: hidden">
      <ul>
        <li class="k-state-active">
          患者検索
        </li>
        <li>
          予実リスト
        </li>
      </ul>
      <div>
        <!-- 簡易検索 -->
        <simple-search :user-query="userSearchQuery" />
        <button
          class="detailed-search-button color-btn-ok"
          @click="showDetailedSearchModal"
        >
          もっと詳しく検索
        </button>
        <!-- 患者リスト -->
        <pat-list />
      </div>
      <div>
        <div id="indication-result-wrapper">
          <indication-result style="font-size: 0.6em;" />
        </div>
      </div>
    </kendo-tabstrip>
  </div>
</template>

<script>
// コンポーネント
import simpleSearch from "@/components/side-contents/SimpleSearch.vue";
import patList from "@/components/side-contents/PatList.vue";
import { SearchQuery } from "@/components/side-contents/SearchDefinitions.js";
import IndicationResultComponent from "@/components/indication-result/IndicationResultComponent";
import { mapActions } from "vuex";

/**
 * @description サイドバー
 */
export default {
  components: {
    "simple-search": simpleSearch,
    "pat-list": patList,
    "indication-result": IndicationResultComponent
  },

  data() {
    return {
      // クエリオブジェクト配列
      userSearchQuery: []
    };
  },

  created() {
    // TODO: ユーザ設定のクエリ取得API実装待ち

    // クエリはプレーンオブジェクトで取得されるのでSearchQueryオブジェクトとしてインスタンス化
    this.userSearchQuery = this.userSearchQuery.map(el => {
      return {
        queryName: el.queryName,
        query: new SearchQuery(el.query)
      };
    });
  },

  methods: {
    ...mapActions("multi-modal", ["showDetailedSearchModal"])
  }
};
</script>

<style scoped>
.side-bar {
  max-width: 460px;
  height: auto;
  position: relative;
  display: inline-block;
  background-color: var(--ntss-base-background-color);
  font-size: 150%;
  z-index: 1;
  box-shadow: 5px 5px 10px grey;
}

.detailed-search-button {
  width: 100%;
}
#indication-result-wrapper {
  width: 430px;
}
@media screen and (max-width: 500px) {
  #indication-result-wrapper {
    width: 340px;
  }
}
</style>
