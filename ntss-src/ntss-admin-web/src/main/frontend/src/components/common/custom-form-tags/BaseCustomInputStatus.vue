<script>
export default {
  props: {
    disabled: {
      default: false
    },
    isRequired: {
      type: Boolean,
      default: false
    },
    validators: {
      type: Array,
      default: () => [],
      validator: functions => {
        for (const func of functions) {
          if (typeof func !== "function") {
            return false;
          }
        }
        return true;
      }
    }
  },
  data() {
    return {
      isValid: true,
      value:{initValue:null,editValue:null},
      el:null
    };
  },
  computed: {
    valueInput: {
      get() {
        let value;
        if(this.inputModel.date === null) {
          value = this.editValue;
        }else {
          value = this.inputModel.date;
        }
        return value;
      },
      set(value) {
        if(value === ""){
          value = null;
        }
        this.editValue = value;
        this.inputModel.date = value;
      }
    },
    initValue: {
      get() {
        return this.value.initValue;
      },
      set(value) {
        this.value.initValue = value;
      }
    },
    editValue: {
      get() {
        return this.value.editValue;
      },
      set(value) {
        this.value.editValue = value;
      }
    },
    isEdited() {
      return this.initValue !== this.editValue;
    },
    classObject() {
      return {
        "custom-input": true,
        "custom-input-disabled": this.disabled,
        "custom-input-edited": this.isEdited,
        "custom-input-required": this.isRequired,
        "custom-input-invalid": !this.isValid
      };
    }
  },
  watch: {
    editValue() {
      this.isValid = true;
    }
  },
  methods: {
    addFocusCss(event) {
      this.el = event.target;
      this.el?.classList?.add("custom-input-edited");
    },
    delFocusCss() {
      if (!this.isEdited) {
        this.el.classList.remove("custom-input-edited");
      }
    },
    validate() {
      let invalidReason = "";
      if (this.editValue !== null) {
        for (const validator of this.validators) {
          invalidReason = validator(this.editValue);
          if (invalidReason !== "") {
            this.isValid = false;
            break;
          }
        }
      }
      return invalidReason;
    },
    checkRequired() {
      let isValid = true;
      if (this.isRequired && this.editValue === null) {
        isValid = false;
      }
      this.isValid = isValid;
      return isValid;
    },
    validateForCommitting() {
      return this.validate() === "" && this.checkRequired();
    }
  }
}
</script>
