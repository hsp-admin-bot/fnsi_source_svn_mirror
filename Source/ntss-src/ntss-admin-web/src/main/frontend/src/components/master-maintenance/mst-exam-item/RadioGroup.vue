<template>
  <div>
    <label v-for="(value, text) in values" :key="value">
      <v-ons-radio
        :value="value"
        v-model="isCover"
        :name="radioGroupName"
        class="radio-button radio-button--round"
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
      radioGroupName: "",
      values: {
        "する" : "true",
        "しない" : "false",
      }
    };
  },
  mounted() {
    this.isCover = this.templateArgs.item.isCover.toString();
    this.index = this.templateArgs.item.index;
    this.radioGroupName = `rec-booking-overwrite-${this.index}`;
  },
  methods: {
    handleToggle(event) {
      this.templateArgs.parentComponent.rightDataSource[this.index].isCover =
        event.target.value === "true";
    },
  },
};
</script>

<style lang="css" scoped>
label {
  display: inline-flex;
  align-items: center;
  margin-right: 1em;
  cursor: pointer;
  white-space: nowrap;
}
:deep(ons-radio.radio-button) {
  display: inline-flex;
  vertical-align: middle;
  margin-right: 4px;
  line-height: 0;
}
:deep(.radio-button--round__checkmark) {
  display: inline-block;
  position: relative;
  width: 22px;
  height: 22px;
  flex-shrink: 0;
}
:deep(.radio-button--round__checkmark::before) {
  content: "";
  position: absolute;
  box-sizing: border-box;
  width: 22px;
  height: 22px;
  border: 1px solid #c7c7cd;
  border-radius: 50%;
  left: 0;
  top: 0;
  background: #fff;
}
:deep(.radio-button--round__checkmark::after) {
  content: "";
  position: absolute;
  top: 7px;
  left: 5px;
  width: 11px;
  height: 5px;
  border: 1px solid #fff;
  border-top: none;
  border-right: none;
  transform: rotate(-45deg);
  opacity: 0;
}
:deep(:checked + .radio-button--round__checkmark::before) {
  background-color: #3B7FA3;
  border: none;
}
:deep(:checked + .radio-button--round__checkmark::after) {
  opacity: 1;
}
</style>
