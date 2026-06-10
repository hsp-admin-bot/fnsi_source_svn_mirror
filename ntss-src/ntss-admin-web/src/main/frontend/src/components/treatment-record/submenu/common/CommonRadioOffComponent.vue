/**
 * ラジオボタン入力共通コンポーネント
 */
<template>
  <v-ons-row>
    <v-ons-col class="title">
      <label class="theme">
        {{labelName}}
      </label>
    </v-ons-col>
    <v-ons-col class="radio-items">
      <span v-for="(radioItem, index) in dataList" :key="radioItem.cd" style="display: flex; align-items: center; flex-wrap: nowrap;">
        <v-ons-checkbox
          type="checkbox"
          :input-id="'checkbox-' + index"
          :value="radioItem.cd"
          @click="check(index)"
          :disabled="disabled"
          v-model="radioItem.displayFlag">
        </v-ons-checkbox>
        <label class="theme" :for="name + radioItem.cd">{{ radioItem.text }}</label>
      </span>
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
      type: String
    },
    disabled: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      dataList:[],
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
    },
  },
  methods: {
    check(id){
      this.dataList.forEach((item, index)=>{
        if (id == index) {
          if (item.displayFlag == true) {
            item.displayFlag = false;
            this.currentValue = null;
          } else {
            item.displayFlag = true;
            this.currentValue = item.cd;
          }
        } else {
          item.displayFlag = false;
        }
      })
    },
  },
  created() {
    for (let key in this.radioItems) {
      this.dataList.push({
        cd: this.radioItems[key].cd,
        text: this.radioItems[key].text,
        displayFlag: false,
      });
    }
  },
  watch: {
    currentValue: {
      handler(newValue){
        this.dataList.forEach(el=>{
          if (el.cd == newValue) {
            if (el.displayFlag == false) {
              el.displayFlag = true;
            }
          // add #10779  実績マージ後の画面でマージ内容が即反映されない zhangyue start
          } else {
            el.displayFlag = false;
          }
          // add #10779  実績マージ後の画面でマージ内容が即反映されない zhangyue end
        })
      }
    }
  }
};
</script>

<style scoped>
</style>
