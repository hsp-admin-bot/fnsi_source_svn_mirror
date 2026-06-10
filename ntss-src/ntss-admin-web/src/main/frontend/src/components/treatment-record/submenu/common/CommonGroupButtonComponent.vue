/**
 * グループボタン入力共通コンポーネント
 */
<template>
  <v-ons-row>
    <v-ons-col class="title">
      <label class="theme">
        {{labelName}}
      </label>
    </v-ons-col>
    <v-ons-col class="button-items">
      <v-on-toolbar>
        <v-ons-segment :index.sync="currentValue" style="width: 4em" class="treatment-record-common-group-button">
          <v-ons-button class="more-width" :data-non-authorize="nonAuthorize" v-for="radioItem in radioItems" :key="radioItem.cd" :disabled="disabled">
            {{ radioItem.text}}
          </v-ons-button>
        </v-ons-segment>
      </v-on-toolbar>
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
      type: Number
    },
    disabled: {
      type: Boolean,
      default: false
    },
    nonAuthorize: {
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
.button-items button {
  width: 3em;
}
.more-width {
  width: 2em;
  color: #ffffff;
  box-shadow: unset;
  background-image: linear-gradient(#72a8de, #72a8de) !important;
}
.more-width >>> .segment__button {
  border: 0;
  height: inherit;
  color: inherit;
  font-size: inherit;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: solid 3px #72a8de;
}
.more-width:first-child {
  border-radius: 10px 0 0 10px;
}
.more-width:last-child {
  border-radius: 0 10px 10px 0;
}
</style>
