<template>
  <div>
    <v-ons-row class="condition-row">
      <v-ons-col vertical-align="center">
        <label>フリーワード：</label>
      </v-ons-col>
      <v-ons-col vertical-align="center">
        <v-ons-input v-model="freeWord" class="input-area" type="text"></v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <div class="condition-row condition-button-area">
      <div class="ok-button">
        <v-ons-button class="ok" @click="filterOK">OK</v-ons-button>
      </div>
    </div>
  </div>
</template>

<script>
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";

export default {
  mixins: [baseCustomForm],

  props: {
    freeWord: {
      type: String,
      default: ""
    }
  },

  computed: {},

  methods: {
    filterOK() {}
  }
};
</script>
<style scoped>
</style>