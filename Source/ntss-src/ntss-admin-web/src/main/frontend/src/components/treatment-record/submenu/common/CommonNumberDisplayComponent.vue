/**
 * 数値表示共通コンポーネント
 */
<template>
  <v-ons-row>
    <v-ons-col class="title">
      <label class="theme">
        {{labelName}}
      </label>
    </v-ons-col>
    <v-ons-col class="num-value">
      <label class="theme">
        {{currentValue}}
      </label>
      <label class="theme" style="margin-left: 0.5em;">{{unitName}}</label>
    </v-ons-col>
  </v-ons-row>
</template>

<script>
export default {
  props: {
    labelName: {
      type: String
    },
    unitName: {
      type: String
    },
    base: {
      type: Number,
      default: 1
    },
    digits: {
      type: Number,
      default: 0
    },
    value: {
      type: Number
    }
  },
  computed: {
    currentValue() {
      return this.value != null ? (this.value / this.base).toFixed(this.digits) : null;
    }
  }
};
</script>

<style scoped>
</style>
