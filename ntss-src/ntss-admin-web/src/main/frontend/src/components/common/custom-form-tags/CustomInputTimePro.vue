<template>
  <div
    class="custom-time-input"
    :class="{
      'is-disabled': disabled,
      'is-readonly': readonly,
    }"
  >
    <input
      type="number"
      v-model="hours"
      @input="handleInput"
      @focus="handleFocus('hours', $event)"
      @blur="handleBlur('hours')"
      @keydown="handleKeyDown"
      :min="0"
      :max="maxHours"
      :disabled="disabled"
      :readonly="readonly"
      :placeholder="placeholder ? '--' : '00'"
      ref="hoursInput"
    />
    <span class="colon">:</span>
    <input
      type="number"
      v-model="minutes"
      @input="handleInput"
      @focus="handleFocus('minutes', $event)"
      @blur="handleBlur('minutes')"
      @keydown="handleKeyDown"
      :min="0"
      :max="59"
      :disabled="disabled"
      :readonly="readonly"
      :placeholder="placeholder ? '--' : '00'"
      ref="minutesInput"
    />
  </div>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: String,
      default: undefined
    },
    value: {
      type: String,
      default: ''
    },
    maxHours: {
      type: Number,
      default: 72
    },
    disabled: {
      type: Boolean,
      default: false
    },
    readonly: {
      type: Boolean,
      default: false
    },
    placeholder: {
      type: Boolean,
      default: false
    }
  },
  emits: ["update:modelValue", "input"],
  data() {
    return {
      hours: '',
      minutes: '',
      isFocused: false,
      activeField: null
    };
  },
  computed: {
    externalValue() {
      return this.modelValue !== undefined ? this.modelValue : this.value;
    }
  },
  watch: {
    externalValue: {
      immediate: true,
      handler(newVal) {
        if (newVal) {
          const [h, m] = newVal.split(':');
          this.hours = h;
          this.minutes = m;
        } else {
          this.hours = this.placeholder ? '' : '00';
          this.minutes = this.placeholder ? '' : '00';
        }
      }
    }
  },
  methods: {
    emitInputValue(value) {
      this.$emit('update:modelValue', value);
      this.$emit('input', value);
    },

    handleInput() {
      if (this.hours !== '') {
        let parsedHours = parseInt(this.hours, 10);
        if (isNaN(parsedHours)) {
          parsedHours = 0;
        }
        parsedHours = Math.min(this.maxHours, Math.max(0, parsedHours));
        this.hours = String(parsedHours).padStart(2, '0');

        if (this.hours === '72') {
          this.minutes = '00';
        }
      }

      if (this.minutes !== '') {
        let parsedMinutes = parseInt(this.minutes, 10);
        if (isNaN(parsedMinutes)) {
          parsedMinutes = 0;
        }
        parsedMinutes = Math.min(59, Math.max(0, parsedMinutes));
        this.minutes = String(parsedMinutes).padStart(2, '0');
      }

      const formattedTime = this.formatTime();
      this.emitInputValue(formattedTime);

      if (String(Number(this.hours)).length === 2 && this.activeField === 'hours') {
        this.$refs.minutesInput?.focus?.();
      }
    },

    formatTime() {
      if (!this.hours && !this.minutes) return '';
      const h = this.hours || '00';
      const m = this.minutes || '00';
      return `${h}:${m}`;
    },

    handleFocus(field, event) {
      this.isFocused = true;
      this.activeField = field;
      event?.target?.select?.();
    },

    handleBlur(field) {
      this.activeField = null;
      setTimeout(() => {
        if (!this.activeField) {
          this.isFocused = false;
          this.formatOnBlur();
        }
      }, 100);
    },

    formatOnBlur() {
      if (!this.hours && !this.minutes) {
        if (!this.placeholder) {
          this.hours = '00';
          this.minutes = '00';
        }
      } else {
        this.hours = this.hours.padStart(2, '0');
        this.minutes = this.minutes.padStart(2, '0');
      }
      this.handleInput();
    },

    handleKeyDown(event) {
      if (this.disabled || this.readonly) return;

      const target = event.target;
      const isHoursInput = target === this.$refs.hoursInput;
      const isMinutesInput = target === this.$refs.minutesInput;

      switch (event.key) {
        case 'ArrowUp':
          event.preventDefault();
          if (isHoursInput) {
            let currentHours = parseInt(this.hours || '0', 10);
          currentHours = Math.min(this.maxHours, currentHours + 1);
          this.hours = String(currentHours).padStart(2, '0');
          } else if (isMinutesInput) {
            let currentMinutes = parseInt(this.minutes || '0', 10);
          currentMinutes = Math.min(59, currentMinutes + 1);
          this.minutes = String(currentMinutes).padStart(2, '0');
        }
        this.handleInput();
          break;

        case 'ArrowDown':
          event.preventDefault();
          if (isHoursInput) {
            let currentHours = parseInt(this.hours || '0', 10);
          currentHours = Math.max(0, currentHours - 1);
          this.hours = String(currentHours).padStart(2, '0');
          } else if (isMinutesInput) {
            let currentMinutes = parseInt(this.minutes || '0', 10);
          currentMinutes = Math.max(0, currentMinutes - 1);
          this.minutes = String(currentMinutes).padStart(2, '0');
        }
        this.handleInput();
          break;

        case 'Tab':
          if (isHoursInput && !event.shiftKey) {
            event.preventDefault();
            this.$refs.minutesInput?.focus?.();
          } else if (isMinutesInput && event.shiftKey) {
            event.preventDefault();
            this.$refs.hoursInput?.focus?.();
          }
          break;

        case ':':
          if (isHoursInput) {
            event.preventDefault();
            this.$refs.minutesInput?.focus?.();
          }
          break;
      }
    }
  }
};
</script>

<style scoped>
.custom-time-input {
  display: inline-flex;
  align-items: center;
  border-radius: 3px;
  border: 2px inset;
  background-color: #fff;
  transition: all 0.2s;
  width: fit-content;
}

.custom-time-input.is-disabled {
  background-color: #f5f7fa;
  border-color: #e4e7ed;
  cursor: not-allowed;
}

.custom-time-input.is-readonly {
  cursor: default;
}

.custom-time-input input {
  width: 24px;
  height: calc(2em - 4px);
  text-align: center;
  border: none;
  outline: none;
  background: transparent;
  color: #606266;
  padding: 0;
  -moz-appearance: textfield;
}

.custom-time-input input:disabled {
  background-color: transparent;
  color: #c0c4cc;
  cursor: not-allowed;
}

.custom-time-input input:read-only {
  cursor: default;
}

.custom-time-input input::placeholder {
  color: #c0c4cc;
}

.custom-time-input input::-webkit-outer-spin-button,
.custom-time-input input::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

.colon {
  padding: 0;
  color: #606266;
  user-select: none;
}

.is-disabled .colon {
  color: #c0c4cc;
}
</style>
