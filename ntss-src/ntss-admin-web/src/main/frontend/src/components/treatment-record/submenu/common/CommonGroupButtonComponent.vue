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
      <v-ons-segment
        ref="segment"
        v-model:index="currentValue"
        style="width: 4em"
        class="treatment-record-common-group-button"
      >
        <button
          v-for="radioItem in unitOptions"
          :key="radioItem.cd"
          :value="radioItem.cd"
          class="more-width"
          :data-non-authorize="nonAuthorize"
          :disabled="disabled"
          @click="onSelectUnit(radioItem.cd)"
        >
          {{ radioItem.text }}
        </button>
      </v-ons-segment>
    </v-ons-col>
  </v-ons-row>
</template>

<script>
export default {
  // Vue3 default v-model は modelValue / update:modelValue を使用する。
  // Vue2 時代の value/input を modelValue/update:modelValue に置換する。
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
    modelValue: {
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
  emits: ["update:modelValue"],
  computed: {
    unitOptions() {
      return Object.values(this.radioItems || {}).sort((a, b) => a.cd - b.cd);
    },
    currentValue: {
      get() {
        return this.modelValue;
      },
      set(newVal) {
        if (this.modelValue !== newVal) {
          this.$emit("update:modelValue", newVal);
        }
      }
    }
  },
  watch: {
    modelValue() {
      this.syncSegmentIndex();
    }
  },
  mounted() {
    this.syncSegmentIndex();
  },
  methods: {
    onSelectUnit(cd) {
      this.currentValue = cd;
      this.syncSegmentIndex();
    },
    /** vue-onsenui 3.x で segment の選択表示を同期する */
    syncSegmentIndex() {
      this.$nextTick(() => {
        const seg = this.$refs.segment?.$el;
        if (seg?.setActiveButton && this.modelValue != null) {
          seg.setActiveButton(this.modelValue, { reject: false });
        }
      });
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
.more-width :deep(.segment__button) {
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
