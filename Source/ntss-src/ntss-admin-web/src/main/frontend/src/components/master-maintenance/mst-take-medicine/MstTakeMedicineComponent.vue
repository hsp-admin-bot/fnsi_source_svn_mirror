<template>
<div
    ref="viewScroll"
    :class="['view', modalMessageSize]"
    @scroll="onViewScroll"
    @input.capture="onViewInputCapture"
    @focusin="onViewFocusIn"
  >
      <p>{{editRecord.name}}</p>
      <com-textarea
        :content="textareaInitialContent"
        idTextarea="com-textarea-take-medicine"
        cssClass="textarea"
        @set-content-data="setContentData"
      />
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import CommonTextArea from "@/components/common/CommonTextArea";
import {EventBus} from "@/compat/vue/event-bus.js";
export default {
  name: "MstTakeMedicineModal",
  mixins: [MasterMaintenanceMixin],
  components: {
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      listDetail: "",
      initDetail: "",
      // 入力のたびに content を更新すると CommonTextArea が再同期され、スクロール位置が先頭に戻る
      textareaInitialContent: "",
      savedViewScrollTop: 0,
      restoreViewScrollFrameId: null,
    }
  },
  computed: {
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      masterName: "getMasterName",
      editRecord: "getEditRecord",
      columns: "getColumns"
    }),
    ...mapGetters("account-edit", ["getFontSize"]),
    modalMessageSize() {
      switch (+this.getFontSize) {
        case 0:
          return "small";
        case 1:
          return "medium";
        case 2:
          return "big";
        case 3:
          return "xbig";
        default:
          return "";
      }
    }
  },
  mounted() {
    //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", !this.isDetailChanged(this.listDetail));
    }, 200);
  },
  beforeUnmount() {
    this.cancelRestoreViewScroll();
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    // editRecordから取得
    getSelectByField(field) {
       return this.editRecord[field];
    },
     //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },

    onViewScroll() {
      this.savedViewScrollTop = this.$refs.viewScroll?.scrollTop || 0;
    },
    onViewInputCapture(event) {
      if (event.target?.tagName !== "TEXTAREA") {
        return;
      }
      // textarea の高さ再計算より前にスクロール位置を保持する
      this.savedViewScrollTop = this.$refs.viewScroll?.scrollTop || 0;
    },
    cancelRestoreViewScroll() {
      if (this.restoreViewScrollFrameId !== null) {
        cancelAnimationFrame(this.restoreViewScrollFrameId);
        this.restoreViewScrollFrameId = null;
      }
    },
    restoreViewScroll() {
      const el = this.$refs.viewScroll;
      if (!el) {
        return;
      }
      const top = this.savedViewScrollTop;
      const apply = () => {
        el.scrollTop = top;
      };
      this.cancelRestoreViewScroll();
      apply();
      this.$nextTick(() => {
        apply();
        this.restoreViewScrollFrameId = requestAnimationFrame(() => {
          apply();
          this.restoreViewScrollFrameId = requestAnimationFrame(() => {
            apply();
            this.restoreViewScrollFrameId = null;
          });
        });
      });
    },
    onViewFocusIn(event) {
      if (event.target?.tagName !== "TEXTAREA") {
        return;
      }
      this.onViewScroll();
      this.restoreViewScroll();
    },
    setContentData(newValue) {
      // textarea の element.value は \n のみ返すため、比較時は改行コードのみ揃える
      const normalized = this.trimTrailingLineBreaks(newValue);
      this.listDetail = normalized;
      // mod 10291 【因島データ】 Convert '\r\n' (Windows) and '\n' (Unix Mac)  to  '\r\n' shiyw start
      this.editRecord.listDetails = normalized;
      // mod 10291 【たくしん会】処方のコンバートが正しくない shiyw end
      this.setEditRecord(this.editRecord);
      //mod マスタ詳細画面がありません破棄メッセージ 张博 start
      if (this.isDetailChanged(newValue)) {
        this.changeButton();
      } else {
        EventBus.$emit("mstHolidayRegistered", true);
      }
      //mod マスタ詳細画面がありません破棄メッセージ 张博 end
      this.restoreViewScroll();
    },
    isDetailChanged(newValue) {
      return this.lineBreakConversion(newValue ?? "") !== this.lineBreakConversion(this.initDetail ?? "");
    },
    //add 10291 【たくしん会】処方のコンバートが正しくない  shiyw start
    lineBreakConversion(text){
      if( text === null || text === undefined) {
        return "";
      }
      const  regex = /\r?\n/g;
      let result = text.replaceAll(regex,'\r\n');
      return result
    },
    trimTrailingLineBreaks(text) {
      let resultText = this.lineBreakConversion(text);
      while (resultText.endsWith('\r\n')) {
        resultText = resultText.substring(0, resultText.length - 2);
      }
      return resultText;
    }
    //add 10291 【因島データ】 Convert '\r\n' (Windows) and '\n' (Unix Mac)  to  '\r\n'  shiyw end
  },
  created() {
    //mod 10291 【因島データ】 Convert '\r\n' (Windows) and '\n' (Unix Mac)  to  '\r\n' shiyw start
    //var list = this.getSelectByField("listDetails").split(",");
    this.listDetail = this.trimTrailingLineBreaks(this.getSelectByField("listDetails"));
    //mod 10291 【因島データ】 Convert '\r\n' (Windows) and '\n' (Unix Mac)  to  '\r\n' shiyw end
    this.initDetail = this.listDetail;
    this.textareaInitialContent = this.listDetail;
  }
}
</script>

<style scoped>
.view{
  padding: 0 10px 10px 10px;
  overflow-y: auto;
}

.textarea{
  width: 100%;
  height: auto;
  font-size: unset;
}

.view.small {
  max-height: calc(100% - 21px);
}

.view.medium {
  max-height: calc(100% - 12px);
}

.view.big {
  max-height: calc(100% - 6px);
}

.view.xbig {
  max-height: calc(100% - 2px);
}
</style>
