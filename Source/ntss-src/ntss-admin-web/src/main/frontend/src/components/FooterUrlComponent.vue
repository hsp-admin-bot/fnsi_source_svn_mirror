<template>
  <div
    @click="showLinkRegisterModal"
    class="toolbar-button"
    style="padding-top: 0;"
  >
    <img :src="img" class="ntss-footer-icon" />
  </div>
</template>

<script>
import { openUrlLinkRegister } from '@/functions/UrlLinkFunctions';

export default {
  props: {
    img: {
      type: String,
      required: true,
      default() {
        return "";
      }
    },
    link: {
      type: String,
      default() {
        return "";
      }
    }
  },
  methods: {
    // ダイアログを開き、データをパラメータに置き換えます
    async showLinkRegisterModal(event) {
      event.preventDefault();
      this.$emit("click");
      openUrlLinkRegister(this.link, this.$el);
    },
  }
};
</script>
