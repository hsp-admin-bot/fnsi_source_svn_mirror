/**
 * 予実リストツリー表示コンポーネント.
 */
<template>
  <div>
    <div style="overflow: auto">
      <ul v-for="(order, index) in treeData" :key="index" >
        <tree-item class="item" :item="order" />
      </ul>
    </div>
  </div>
</template>

<script>
import {
  convertToTreeDataPattern1,
  convertToTreeDataPattern2,
  convertToTreeDataPattern3,
  convertToTreeDataPattern4,
  convertToTreeDataPattern5,
  convertToTreeDataPattern6,
} from "@/components/indication-result/convert-to-tree-data"

export default {
  props: {
    orderList: {
      type: Array,
      default: () => []
    },

    filter: {
      type: Object,
      default: () => {
        return {
          result: true,
          indication: true,
          pastIndication: false,
          // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
          // 患者イベント
          patEvent: this.patEvent,
          // 検査結果
          inspectionResult: this.inspectionResult,
          // 検査予定
          inspectionSchedule: this.inspectionSchedule,
          // 一般撮影検査予定
          genPhoto: this.genPhoto,
          // 処方
          prescription: this.prescription
          // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
        }
      }
    },

    pattern: {
      type: Number,
      default: 1
    }
  },

  data() {
    return {
      treeData: [ ]
    }
  },

  watch: {
    /**
     * 予実リスト（props）を監視し、更新があった場合、Tree表示用データに変換する.
     */
    orderList: {
      handler() {
        this.createTreeData();
      },
      deep: true
    },

    /**
     * 予実リスト（props）を監視し、更新があった場合、Tree表示用データに変換する.
     */
    filter: {
      handler() {
        this.createTreeData();
      },
      deep: true
    },

    /**
     * 予実リスト（props）を監視し、更新があった場合、Tree表示用データに変換する.
     */
    pattern: {
      handler() {
        this.createTreeData();
      },
      deep: true
    }
  },

  methods: {
    /**
     * ツリーデータ作成
     */
    createTreeData() {
      if (this.orderList.length <= 0) {
        this.treeData = [];
        return;
      }

      // フィルタリング＆データ変換
      const list = this.orderList.slice();
      list.forEach(e => { e.pattern = this.pattern; })
      const filterdList = this.doFilter(list);
      this.treeData = this.convertToTreeData(filterdList);
    },

    /**
     * 予実データ配列をフィルタ情報に基づき、フィルタリンクする.
     * @param {*} list 予実データ配列
     */
    doFilter(list) {
      const filterdList = [];
      if (this.filter.result) {
        // 実績；true
        Array.prototype.push.apply(filterdList, list.filter(e => e.isResult));
      }
      if (this.filter.indication && !this.filter.pastIndication) {
        // 予定；true、過予；false
        Array.prototype.push.apply(filterdList, list.filter(e => e.isIndication && !e.isPastIndication));
      }
      if (this.filter.indication && this.filter.pastIndication) {
        // 予定；true、過予；true
        Array.prototype.push.apply(filterdList, list.filter(e => e.isIndication));
      }
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
      if (this.filter.patEvent) {
        // 患者イベント
        Array.prototype.push.apply(filterdList, list.filter(e => e.type == 'pat_event'));
      }
      if (this.filter.inspectionSchedule) {
        // 検査予定
        Array.prototype.push.apply(filterdList, list.filter(e => e.type == 'in_schedule'));
      }
      if (this.filter.inspectionResult) {
        // 検査結果
        Array.prototype.push.apply(filterdList, list.filter(e => e.type == 'in_result'));
      }
      if (this.filter.genPhoto) {
        // 一般撮影検査予定
        Array.prototype.push.apply(filterdList, list.filter(e => e.type == 'in_photo'));
      }
      if (this.filter.prescription) {
        // 処方
        Array.prototype.push.apply(filterdList, list.filter(e => e.type == 'prescription'));
      }
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
      return filterdList;
    },

    /**
     * 予実データ配列をツリー表示用データに変換する.
     * @param {*} list 予実データ配列
     */
    convertToTreeData(list) {
      if (this.pattern === 1) {
        // パターン１
        return convertToTreeDataPattern1(list);
      }
      if (this.pattern === 2) {
        // パターン２
        return convertToTreeDataPattern2(list);
      }
      if (this.pattern === 3) {
        // パターン３
        return convertToTreeDataPattern3(list);
      }
      if (this.pattern === 4) {
        // パターン４
        return convertToTreeDataPattern4(list);
      }
      if (this.pattern === 5) {
        // パターン５
        return convertToTreeDataPattern5(list);
      }
      // パターン６
      return convertToTreeDataPattern6(list);
    }
  }
}
</script>

<style scoped>
ul {
  padding-left: 0.5em;
  line-height: 1.5em;
  list-style: none;
}
</style>
