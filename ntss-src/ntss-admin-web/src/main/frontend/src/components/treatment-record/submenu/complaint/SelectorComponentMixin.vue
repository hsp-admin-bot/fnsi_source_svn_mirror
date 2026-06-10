<script>

export default {
  props: {
    popoverVisible: {
      type: Boolean,
      default: false
    },
    popoverTarget: {
      type: HTMLElement,
      default: null
    }
  },
  data() {
    return {
      searchText: null,
      searchTextConformed: null,
      selectedIndex: null,
      selectItems: [],
      nonSelectValue: null 
    }
  },
  watch: {
    popoverVisible(visible) {
      if (visible) {
        this.init();
        this.selectedIndex = null;
        this.searchText = null;
        this.searchTextConformed = null;
      }
    }
  },
  methods: {
    /**
     * 検索テキストボックスEnter押下時ハンドラ.
     */
    onSearchEnter(ev) {
      if (ev.keyCode === 13) {
        this.onSearchClick();
      }
    },
    /**
     * 検索ボタンクリック時ハンドラ.
     */
    onSearchClick() {
      this.searchTextConformed = this.searchText;
    },
    /**
     * 選択行クリック時ハンドラ.
     */
    onItemClick(index) {
      this.selectedIndex = index;
    },
    /**
     * 選択行ダブルクリック時ハンドラ.
     */
    onItemDblClick(index) {
      this.onItemClick(index);
      this.onOk();
    },
    hasMatchedName(item) {
      return !this.searchTextConformed ||
        item.searchText.includes(this.searchTextConformed);
    },
    /**
     * 明細行のクラス.
     */
    itemRowClass(index, conditionOfItemVisible) {
      return [
        index === this.selectedIndex ? "selected-item-tr" : null,
        this.isLastRowPerPage(this.selectItems, index, conditionOfItemVisible) ? "border-per-page-bottom" : null
      ];
    },
    /**
     * OKボタンクリック時ハンドラ.
     */
    onOk() {
      this.$emit(
        "popover-close",
        this.selectedIndex < 0
          ? this.nonSelectValue
          : this.selectItems[this.selectedIndex]
      );
      this.selectItems = [];
    },
    /**
     * キャンセルボタンクリック時ハンドラ.
     */
    onCancel() {
      this.$emit("popover-close", null);
      this.selectItems = [];
    }
  },
}
</script>

