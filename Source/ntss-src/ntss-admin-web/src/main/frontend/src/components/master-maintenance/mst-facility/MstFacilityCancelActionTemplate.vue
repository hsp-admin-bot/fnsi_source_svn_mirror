<template>
  <div>
    <div v-if="!templateArgs?.isActionTemplate">
      <a class="k-button d-button" @click="downloadBackup">
        <img class="d-img" src="img/master-maintenance/download.png" alt="バックアップファイルダウンロード">
      </a>
      <a class="k-button btn4-alert" style="box-shadow: unset; padding: 0.5em; margin-right: 0.3em; height: 2em;" @click="completeDelete" v-if="dispCompleteDeleteBtn">
        完全削除
      </a>
      <a class="k-button btn4-alert" style="box-shadow: unset; padding: 0.5em; height: 2em;" @click="dataDelete" v-if="dispDeleteBtn">
        データ削除
      </a>
    </div>
  </div>
</template>

<script>

export default {
  name: "cancelActionTemplate",
  props: {
    templateArgs: {
      type: Object,
      default: () => ({})
    }
  },
  methods: {
    // "バックアップファイルダウンロードボタンが押下されたときの処理
    downloadBackup: function() {
      // 親コンポーネントメソッドの呼出し
      this.templateArgs?.parentComponent?.onClickDownloadBackup?.(
        this.templateArgs?.rowData,
      );
    },
    // 完全削除ボタンが押下されたときの処理
    completeDelete: function() {
      // 親コンポーネントメソッドの呼出し
      this.templateArgs?.parentComponent?.onClickCompleteDelete?.(
        this.templateArgs?.rowData,
      );
    },
    // データ削除ボタンが押下されたときの処理
    dataDelete: function() {
      // 親コンポーネントメソッドの呼出し
      this.templateArgs?.parentComponent?.onClickDataDelete?.(
        this.templateArgs?.rowData,
      );
    }
  },
  computed: {
    // 完全削除ボタン表示
    dispCompleteDeleteBtn() {
      // 解約データ削除完了 = 4
      return this.templateArgs?.rowData?.isCancel === "4";
    },
    // データ削除ボタン表示
    dispDeleteBtn() {
      // ReMSのみ解約データ削除完了 = R4 / FNSiのみ解約データ削除完了 = F4
      const isCancel = this.templateArgs?.rowData?.isCancel;
      return isCancel === "R4" || isCancel === "F4";
    }
  }
};
</script>
<style scoped>
.d-button {
  border-radius: 100%;
  width: 2.0em;
  height: 2.0em;
  margin-right: 5px;
  background-image: linear-gradient(#e4e7eb, #e4e7eb) !important;
  border-bottom: solid 3px var(--btn-common-border-color) !important;
  box-shadow: unset;
}
.d-img {
  width: 1.5em;
  height: 1.5em;
}
.grid-join {
  border-left: 0 !important;
  padding-left: 0 !important;
}
</style>