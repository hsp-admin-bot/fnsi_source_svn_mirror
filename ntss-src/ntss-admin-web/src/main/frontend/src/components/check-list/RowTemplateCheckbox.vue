<template>
  <input type="checkbox" v-model="checkState" />
</template>

<script>
export default {
  name: "rowTemplateCheckbox",
  methods: {},
  data() {
    return {
      templateArgs: {}
    };
  },
  computed: {
    item() {
      return this.templateArgs.dataItem;
    },
    checkState: {
      get() {
        return this.item.check;
      },
      set() {
        this.templateArgs.parentComponent.setCheckInfo(this.item);
      }
    }
  }
};
</script>
