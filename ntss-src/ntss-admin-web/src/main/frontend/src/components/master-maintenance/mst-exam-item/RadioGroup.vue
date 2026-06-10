<template>
  <div>
    <label v-for="(value, text) in values" :key="value">
      <v-ons-radio
        :value="value"
        v-model="isCover"
        @change="handleToggle"
        modifier="round"
      ></v-ons-radio>
      <!-- <input
        type="radio"
        v-model="isCover"
        :value="value"
        @change="handleToggle"
      /> -->
      {{ text }}
    </label>
  </div>
</template>

<script>
export default {
  name: "RadioGroup",
  data() {
    return {
      templateArgs: {},
      isCover: "false",
      index: null,
      values: {
        "する" : "true",
        "しない" : "false",
      }
    };
  },
  mounted() {
    this.isCover = this.templateArgs.item.isCover.toString();
    this.index = this.templateArgs.item.index;
  },
  methods: {
    handleToggle(event) {
      this.templateArgs.parentComponent.rightDataSource[this.index].isCover =
        Boolean(event.target.value);
    },
  },
};
</script>

<style lang="css" scoped>
</style>
