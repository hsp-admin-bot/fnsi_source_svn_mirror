/**
 * マスタ編集用モーダル画面の基本レイアウト
 */
<template>
  <div class="modal-mask">
    <div class="modal-wrapper">
      <div class="modal-container">

        <div class="modal-header">
          <ons-toolbar>
            <div class="left toolbar__title">
              <slot name="header"></slot>
            </div>
            <div class="right">
              <ons-toolbar-button class="close-btn" @click="$emit('onClose')">
                <ons-icon icon="fa-times"></ons-icon>
              </ons-toolbar-button>
            </div>
          </ons-toolbar>
        </div>
        <div class="modal-body modal-overflow-hidden custom-modal-body">
          <slot name="body"></slot>
        </div>

        <div class="modal-footer">
          <v-ons-bottom-toolbar>
            <slot name="footer"></slot>
          </v-ons-bottom-toolbar>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {};
</script>

<style scoped>
@import "../../assets/styles/master-maintenance/modal.css";
@import "../../assets/styles/modal.css";

/*
 * TODO 以下のように、cssのパスをエイリアスで設定できるようにしたい。
 * @import "@/assets/styles/modal.css";
 *
 * webpackでエイリアスを設定すればできそう。
 * https://vue-loader-v14.vuejs.org/ja/configurations/asset-url.html
 */
.custom-modal-body :deep(.k-textbox) {
  font-size: unset;
  box-sizing: border-box;
}
</style>
