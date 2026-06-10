/**
 * ラジオボタン入力共通コンポーネント
 */
<template>
  <v-ons-row>
    <v-ons-col class="title">
      <label class="theme">
        {{labelName}}
      </label>
    </v-ons-col>
    <v-ons-col class="radio-items">
      <span v-for="radioItem in radioItems" :key="radioItem.cd" style="display: flex; flex-wrap: nowrap; align-items: center;">
        <v-ons-radio
          :name=name
          :input-id="name + radioItem.cd"
          :value="radioItem.cd"
          modifier="round"
          :disabled="disabled"
          model-event="change"
          v-model="currentValue" />
        <label class="theme" :for="name + radioItem.cd">{{ radioItem.text }}</label>
      </span>
    </v-ons-col>
  </v-ons-row>
</template>

<script>
export default {
  props: {
    name: {
      type: String
    },
    labelName: {
      type: String
    },
    radioItems: {
      type: Object
    },
    value: {
      type: String
    },
    disabled: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    currentValue: {
      get() {
        return this.value;
      },
      set(newVal) {
        if (this.value !== newVal) {
          this.$emit("input", newVal);
        }
      }
    }
  }
};
</script>

<style scoped>
</style>
