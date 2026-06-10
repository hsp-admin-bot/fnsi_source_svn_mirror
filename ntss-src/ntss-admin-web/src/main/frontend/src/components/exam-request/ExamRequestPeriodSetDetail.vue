<template>
  <div>
    <div v-if="className !== ''" class="set-exam-class">
      {{ className }}
    </div>
    <div class="set-detail">
      <label v-if="!detail || detail.length === 0">なし</label>
      <ul>
        <li v-for="(name, index) in detail" :key="index">{{ name.item_name }}</li>
      </ul>
    </div>
  </div>
</template>

<script>

export default {
  props: {
    className: {
      type: String,
      default: ""
    },
    detail: {
      required: true
    },
  },
};
</script>

<style scoped>
.set-exam-class {
  font-weight: bold;
}

.set-detail ul {
  margin: 0 0 15px 0;
}
</style>
