/**
 * 予定情報
 */

<template>
<div>
  <v-ons-row class="row-style">
    <v-ons-col width="30%" style="text-align: start;">
      <label>開始日</label>
    </v-ons-col>
    <v-ons-col>
      <v-ons-input type="date" class="form-control" id="date-start" :value="value.dateStart" @input="update('dateStart', $event.target.value)" />
    </v-ons-col>
  </v-ons-row>
  <v-ons-row class="row-style">
    <v-ons-col width="30%" style="text-align: start;">
      <label>終了日</label>
    </v-ons-col>
    <v-ons-col>
      <v-ons-input type="date" class="form-control" id="date-end" :value="value.dateEnd" @input="update('dateEnd', $event.target.value)" />
    </v-ons-col>
  </v-ons-row>
  <v-ons-row class="row-style" v-if="value.weekSelect">
    <v-ons-col style="text-align: start;">
      <label>曜日</label>
    </v-ons-col>
    <v-ons-col width="283px">
      <div v-for="(week, index) in weeks" :key="index">
        <label>
        <input class="onColor"
          type="checkbox"
          v-on:change="chkChange(week)"
          v-bind:checked="week.done"
          style="display: none;">
          <span class="week-button">{{ week.text }}</span>
      </label>
      </div>
    </v-ons-col>
  </v-ons-row>
  <v-ons-row class="row-style" v-if="value.kurSelect">
    <v-ons-col width="30%" style="text-align: start;">
      <label>クール</label>
    </v-ons-col>
    <v-ons-col>
      <select @input="update('selectedKur', $event.target.value)">
        <option v-for="(kur, index) in kurOptions" :key="index" :value="kur.value">
          {{ kur.text }}
        </option>
      </select>
    </v-ons-col>
  </v-ons-row>
  <v-ons-row class="row-style" v-if="value.treatSelect">
    <v-ons-col width="30%" style="text-align: start;">
      <label>治療方法</label>
    </v-ons-col>
    <v-ons-col>
      <select @input="update('selectedTreat', $event.target.value)">
        <option v-for="(treat, index) in treatOptions" :key="index" :value="treat.value">
          {{ treat.text }}
        </option>
      </select>
    </v-ons-col>
  </v-ons-row>
</div>
</template>

<script>
import {
  mapState,
  mapActions
} from "@/compat/vue/vuex";

const components = {};

const data = function() {
  return {};
};

const methods = {
  ...mapActions('dialysisCond', {
    getDialysisCond: 'getDialysisCond',
  }),
  chkChange: function(week) {
    week.done = !week.done
  },
};

const computed = {
  ...mapState('dialysisCond', [
    'dialysisCondData',
    'keyList'
  ]),
};

const filters = {};

const created = function() {};

const mounted = function() {};

const watch = {};

export default {
  components,
  // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
  emits: ["update:modelValue"],
  props: {
    modelValue: {
      patId: {
        type: String,
        required: true,
      },
      dateStart: String,
      dateEnd: String,
      weekSelect: {
        type: Boolean,
        default: true,
      },
      kurSelect: {
        type: Boolean,
        default: true,
      },
      treatSelect: {
        type: Boolean,
        default: true,
      },
    },
    },
    data() {
      return {
        weeks: [
          { text: "全", done: false },
          { text: "月", done: false },
          { text: "火", done: false },
          { text: "水", done: false },
          { text: "木", done: false },
          { text: "金", done: false },
          { text: "土", done: false },
          { text: "日", done: false }
        ],
        kurOptions: [
          { text: '午前', vlue: '001' },
          { text: '午後', vlue: '002' },
          { text: '夜間', vlue: '003' },
        ],
        treatOptions: [
          { text: 'HD',   vlue: '001' },
          { text: 'ECUM', vlue: '002' },
          { text: 'HDF',  vlue: '003' },
          { text: 'HF',   vlue: '004' },
        ]
      };
    },
    methods: {
      update(key, value) {
        this.modelValue[key] = value;
        this.$emit('update:modelValue', this.modelValue);
      },
    },
    computed,
    filters,
    created,
    mounted,
    watch,
  };
</script>

<style scoped>
.week-button {
  padding: 5px 10px;
  float: left;
  border: solid;
  border-color: #C0C0C0;
  border-width: 1px;
}

.row-style {
  padding: 3px 0px;
}

.onColor:checked+span {
  background-color: #9ACD32;
}
</style>
