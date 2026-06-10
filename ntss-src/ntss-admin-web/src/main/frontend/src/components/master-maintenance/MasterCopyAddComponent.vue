/**
 * コピー追加ポップオーバー
 */
<template>
  <v-ons-popover
    cancelable
    :visible="popoverVisible"
    :target="popoverTarget"
    direction="down"
    :cover-target="false"
    :class="[fontSizeSet, 'popover-area']"
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="handleCancel(); popoverPosthide($event)"
  >
    <div style="padding: 10px;">
      <div style="line-height: 30px;">
        <v-ons-select class="copy-add-combo" v-model="selectedCopySrc">
          <option
            v-for="item in copySrcData"
            :key="item.code"
            :value="item.code"
          >{{ item.name }}</option>
        </v-ons-select>
      </div>
      <template>
        <div style="margin-top: 5px; line-height: 30px;">
          <v-ons-button
            class="btn3-normal ok common-style-ok-button"
            style="height: 2em; margin-left: 8em;"
            :disabled="!isSelectedCopySrc"
            @click="addRow"
          >追加</v-ons-button>
        </div>
      </template>
    </div>
  </v-ons-popover>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import PopoverMixin from "@/components/PopoverMixin";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";

export default {
  mixins: [PopoverMixin],
  props: {
    popoverVisible: {
      type: Boolean,
      default: false
    },
    popoverTarget: {
      type: HTMLElement,
      default: null
    },
    copySrcData: {
      type: Array,
      default: () => []
    },
  },
  data() {
    return {
      selectedCopySrc: null,
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      masterPhysicalName: "getMasterName",
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      editRecord: "getEditRecord"
    }),
    /**
     * コピー元が選択されているか否か
     */
    isSelectedCopySrc() {
      return this.selectedCopySrc !== null;
    },
  },
  methods: {
    ...mapActions("master-maintenance", [
      "edit",
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * 追加ボタンクリック時ハンドラ.
     */
    addRow() {
      // コピー元のデータ複製
      const originalRecord = this.getMasterRecordList.data.find(item => item.code === this.selectedCopySrc);
      const targetRecord = JSON.parse(JSON.stringify(originalRecord));
      targetRecord.code = 0;
      targetRecord.isDisp = "1";

      // 体重計マスタ
      if (this.masterPhysicalName === "mst_weight") {
        // - 体重計番号、体重計名は複製しない
        targetRecord.weightNo = 0;
        targetRecord.name = "";
      }
      // 装置通信仮想端末マスタ
      if (this.masterPhysicalName === "mst_comsv_setting") {
        // - デバイスエッジ名は複製しない
        targetRecord.deviceEdgeNo = "";
      }

      // 並び順 新しいレコードに全レコードの並び順の最大値をセット
      targetRecord.sortRank = this.getFilteredMasterRecordList.data.length + 1;
      
      // 一覧に行追加
      this.edit({ editRecord: targetRecord, isSortMode: this.isSortMode });
      // 行をコピー追加した時のイベント発火
      this.$emit("added-row");
      
      // 吹き出しを閉じる
      this.onCancel();
    },
    handleCancel () {
      this.$parent.masterCopyAddVisible = false
    },
    onCancel() {
      this.$emit("popover-close", null);
    },
  },
  watch: {
    /**
     * propのcopySrcDataが更新されたときの初期値設定
     */
    copySrcData: {
      immediate: true,
      handler(newData) {
        if (newData?.length) {
          // プルダウンリスト設定ありでコピー元が未選択の場合は一番上の要素を選択
          this.selectedCopySrc ??= newData[0].code;
        } else {
          // プルダウンリスト設定なしの場合は選択値クリア
          this.selectedCopySrc = null;
        }
      }
    }
  }
};
</script>

<style scoped>
.copy-add-combo {
  width: 100%;
  margin-bottom: -5px;
}
</style>
