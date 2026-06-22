<template>
  <div :class="{'in_class': templateArgs.item.in_out_class === 1}">
    {{templateArgs.item.patName}}
    <img v-if="templateArgs.item.is_same === '1'" class='same-icon' :src="imgSrc" />
  </div>
</template>

<script>
import nameDuplicationImg from "@/assets/name_duplication.png";
export default {
  name: "PatNameCell",
  data() {
    return {
      templateArgs: {},
      imgSrc: nameDuplicationImg,
    };
  },
};
</script>

<style lang="css" scoped>
.in_class {
  color: #A356A3;
}
.same-icon{
  position: relative;
  top: 0.25em;
  height: 20px;
}
</style>
