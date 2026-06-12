/**
 * 予実リスト オーダー一覧表示用 TreeView コンポーネント.
 */
<template>
  <li>
    <div @click="toggle" >
      <span v-if="isParent" :class="{ rotate : !isOpen }">▼</span>
      <span v-if="isParent">{{ item.title }}</span>
      <tree-view-pattern-1 v-if="!isParent && item.pattern === 1" :model="item" />
      <tree-view-pattern-2 v-if="!isParent && item.pattern === 2" :model="item" />
      <tree-view-pattern-3 v-if="!isParent && item.pattern === 3" :model="item" />
      <tree-view-pattern-4 v-if="!isParent && item.pattern === 4" :model="item" />
      <tree-view-pattern-5 v-if="!isParent && item.pattern === 5" :model="item" />
      <tree-view-pattern-6 v-if="!isParent && item.pattern === 6" :model="item" />
    </div>
    <ul v-show="isOpen" v-if="isParent">
      <tree-item
        class="item"
        v-for="(child, index) in item.children"
        :key="index"
        :item="child"
      ></tree-item>
    </ul>
  </li>
</template>

<script>
import TreeViewPattern1Component from "@/components/indication-result/tree-view-pattern/TreeViewPattern1Component"
import TreeViewPattern2Component from "@/components/indication-result/tree-view-pattern/TreeViewPattern2Component"
import TreeViewPattern3Component from "@/components/indication-result/tree-view-pattern/TreeViewPattern3Component"
import TreeViewPattern4Component from "@/components/indication-result/tree-view-pattern/TreeViewPattern4Component"
import TreeViewPattern5Component from "@/components/indication-result/tree-view-pattern/TreeViewPattern5Component"
import TreeViewPattern6Component from "@/components/indication-result/tree-view-pattern/TreeViewPattern6Component"

export default {
  name: "tree-item",
  components: {
    "tree-view-pattern-1": TreeViewPattern1Component,
    "tree-view-pattern-2": TreeViewPattern2Component,
    "tree-view-pattern-3": TreeViewPattern3Component,
    "tree-view-pattern-4": TreeViewPattern4Component,
    "tree-view-pattern-5": TreeViewPattern5Component,
    "tree-view-pattern-6": TreeViewPattern6Component
  },

  props: {
    item: Object
  },

  data() {
    return {
      isOpen: true
    };
  },

  computed: {
    /**
     * 親要素かどうか.
     */
    isParent() {
      return this.item.children && this.item.children.length;
    }
  },

  methods: {
    /**
     * Tree展開と収束を管理する.
     */
    toggle() {
      if (this.isParent) {
        this.isOpen = !this.isOpen;
      }
    }
  }
};
</script>

<style scoped>
.rotate {
  display: inline-block;
  transform: rotate(-90deg);
}
.item {
  cursor: pointer;
}
.bold {
  font-weight: bold;
}
ul {
  padding-left: 0.5em;
  line-height: 1.5em;
  list-style: none;
}
</style>
