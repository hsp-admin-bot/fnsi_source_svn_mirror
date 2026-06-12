<template>
  <div class="modelTitle_box">
    <div class="multi-select-list">
      <div class="color-header modelTitle">
        <!-- mod スタッフ選択モーダルの表示不正 5672 関 start -->
        <!-- <div class="modelTitleID">ユーザ名</div>
        <div class="modelTitleName">ユーザ職種</div> -->
        <div class="modelTitleID">スタッフ名</div>
        <div class="modelTitleName">職種</div>
        <!-- mod スタッフ選択モーダルの表示不正 5672 関 end -->
      </div>
      <div v-for="(item, index) in itemList" :key="index" :class="computeClassItemLabel(item)">
        <label
          @click.exact="checkMultiItem(index)"
          @click.ctrl.exact="checkMultiItem(index)"
          @click.shift.exact="checkRangeItem(index)"
          @click.ctrl.shift.exact="checkMultiRangeItem(index)"
          @keydown.up.exact="checkPreItem(index, checkItem)"
          @keydown.down.exact="checkNextItem(index, checkItem)"
          @keydown.shift.up.exact="checkPreItem(index, checkRangeItem)"
          @keydown.shift.down.exact="checkNextItem(index, checkRangeItem)"
          ref="label"
          :tabindex="-1"
          class="item-label select-item-row"
        >
          <div class="modelTitleID_box" :class="computeClassItemDiv()">
            <!-- mod FNSI-入外区分が入院の場合、患者名は紫色にする dou start -->
            <!-- <span class="item-name" :class="computeClassItemName(item)">{{ item.name }}</span> -->
            <span
              class="item-name"
              :class="[computeClassItemName(item), inOutFlag(item)]"
              >{{ item.name }}</span
            >
            <!-- mod FNSI-入外区分が入院の場合、患者名は紫色にする dou end -->
            <img
              v-if="item.isSame === '1'"
              class="same-icon"
              :src="image_src_same"
            />
          </div>
          <!-- mod FNSI-改修内容施設イベント选择子画面样式修正 関 start -->
          <!-- <div style="width: calc(100% - 130px);float: right;margin-left: 0.25em;"> -->
          <div class="modelTitleName_box">
            <!-- mod FNSI-改修内容施設イベント选择子画面样式修正 関 end -->
            <span
              class="item-name"
              v-if="item.cdType"
              :class="computeClassItemName(item)"
              >{{ item.jobName }}</span
            >
            <span class="item-name" v-else :class="computeClassItemName(item)">{{
              item.hostCd
            }}</span>
          </div>
        </label>
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import nameDuplicationImg from "@/assets/name_duplication.png";

export default {
  props: {
    // 表示対象データ配列
    itemList: {
      type: Array,
      required: true,
    },
    // 全チェック解除
    // ※ソート機能が有効な場合にはチェックを解除しない.
    isUnchecked: {
      type: Boolean,
      default: true,
    },
  },
  data() {
    return {
      image_src_same: nameDuplicationImg,
      // 直前のチェック項目インデックス
      latestCheckedIndex: null,
    };
  },

  computed: {
    ...mapGetters("bbs-info", ["getJobCd"]),
    ...mapGetters("account-edit", ["getTheme"]),
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
    },
  },

  watch: {
    /**
     * @description 親の選択実行による項目一覧変化の監視
     */
    itemList() {
      this.latestCheckedIndex = null;
      // 全チェック解除
      if (this.isUnchecked) {
        this.itemList.forEach((item) => (item.isChecked = false));
      }
    },
  },

  methods: {
    /**
     * @description 単一チェック処理
     * @summary クリックした1つの項目のみチェックフラグを立てる
     * @param {Number} checkedIndex チェック項目インデックス
     */
    ...mapActions("bbs-info", ["setJobCd"]),
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
        "item-label-checked": selectedItem.isChecked,

        "lable-border-bottom-black": !this.getTheme,
        "lable-border-bottom-white": this.getTheme,
      };
    },
    computeClassItemDiv() {
      return {
        "div-border-right-black": !this.getTheme,
        "div-border-right-white": this.getTheme,
      };
    },
    async getName(jobCd) {
      /*const responseObsRec = ApiHelper.get(
        `bbsInfo/getJobName/${jobCd}`
      )*/
      await this.setJobCd(jobCd);
      return this.getJobCd;
    },
    /**
     * @description チェック状態に応じたCSSクラス付与
     */
    computeClassItemName(selectedItem) {
      return {
        "item-name-checked": selectedItem.isChecked,
      };
    },
    // add FNSI-入外区分が入院の場合、患者名は紫色にする dou start
    inOutFlag(selectedItem) {
      return {
        "in-out": selectedItem.isInClass == 1 ? true : false,
      };
    },
    // add FNSI-入外区分が入院の場合、患者名は紫色にする dou end
  },
};
</script>

<style scoped>
/* マルチ選択リスト全体 */
.multi-select-list {
  height: 300px;
  border: 1px solid;
  overflow-y: auto;
  overflow-x: hidden;
  box-sizing: border-box;
}

.item-label {
  display: flex;
}

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
/* mod スタッフ選択モーダルの表示不正 5672  関 start */
/* .item-name {
  width: 100%;
  height: 100%;
  word-wrap: break-word;
  white-space: pre-wrap;
  word-break: break-all;
} */
.item-name {
  width: 100%;
  height: 100%;
  /* user-select: none; */
  word-wrap: break-word;
  white-space: pre-wrap;
  word-break: break-all;
  display: block;
  margin-top: 5px;
}
/* mod スタッフ選択モーダルの表示不正 5672  関 end */
.same-icon {
  height: 1em;
  display: inline-block;
  margin-left: 0.5em;
}

/* マルチ選択項目名チェック時 */
.item-name-checked {
  color: white;
}
/* add FNSI-入外区分が入院の場合、患者名は紫色にする dou start */
.in-out {
  color: #a356a3;
}
/* add FNSI-入外区分が入院の場合、患者名は紫色にする dou end */
/* mod FNSI-改修内容施設イベント选择子画面样式修正 関　start */
/* .lable-border-bottom-black{
 border-bottom: 1px  black solid
} */
.lable-border-bottom-black {
  border-bottom: 1px solid #dee2e6;
}
/* mod FNSI-改修内容施設イベント选择子画面样式修正 関　end */
.lable-border-bottom-white {
  border-bottom: 1px white solid;
}
/* add スタッフ選択モーダルの表示不正 5672 shan　start */
/* .div-border-right-white {
  border-right: 1px white solid;
} */

.modelTitle {
  display: flex;
  align-items: center;
  box-sizing: border-box;
  position: sticky;
  top: 0px;
  z-index: 3;
}
.modelTitleID {
  width: 63%;
  border-right: 1px solid #dee2e6;
  padding-left: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.modelTitleName {
  width: 50%;
  padding-left: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
/* mod スタッフ選択モーダルの表示不正 5672 関 start */
/* .modelTitleID_box {
  width: 50%;
  padding-left: 2px;
} */
.modelTitleID_box {
  width: 63%;
  padding-left: 2px;
  min-height: 30px;
}
/* mod スタッフ選択モーダルの表示不正 5672 関 end */
.modelTitleName_box {
  width: 50%;
  padding-left: 2px;
  border-left: 1px solid #dee2e6;
  min-height: 30px;
}

.color-header {
  padding-left: 0px !important;
}
.modelTitle_box {
  overflow: hidden;
}
/* add スタッフ選択モーダルの表示不正 5672 shan　end */
</style>
