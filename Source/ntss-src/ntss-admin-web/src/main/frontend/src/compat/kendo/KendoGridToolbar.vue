<template>
  <div class="k-grid-toolbar" v-bind="$attrs">
    <slot />
  </div>
</template>

<script>
export default {
  name: "KendoGridToolbar",
  inheritAttrs: false
};
</script>
