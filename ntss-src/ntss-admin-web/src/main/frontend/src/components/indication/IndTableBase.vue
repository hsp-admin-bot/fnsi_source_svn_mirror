/** * 風袋・除水ベース画面 */

<template>
    <div class="table-content">
    <div class="header-style color-header" style="margin-bottom: 5px;">
      <label>{{ tableData.tableTitle }}</label>
    </div>
    <div>
      <v-ons-row>
        <v-ons-col style="text-align: start;">
          <v-ons-segment style="width: 120px;" :disabled="isButtonEditable">
            <button @click="selectUnit" value=0 class="segment-button">g</button>
            <button @click="selectUnit" value=1 class="segment-button">kg</button>
          </v-ons-segment>
        </v-ons-col>
        <v-ons-col style="text-align: end;" class="radio-class">
          <!-- TODO: 一時的にコメント(現在ラジオボタンだが、メッセージで確認を取る可能性もあり※検討中) -->
          <!-- <label>治療情報への反映</label>
          <label><input type="radio" name="reflectOrdMain" value=1 v-model="ordMainFlag" />反映する</label>
          <label><input type="radio" name="reflectOrdMain" value=0 v-model="ordMainFlag" />しない</label> -->
        </v-ons-col>
      </v-ons-row>
      <div><slot></slot></div>
      <v-ons-row>
        <v-ons-col>
          <v-ons-button
            class="common-style-cancel-button"
            style="float: left;"
            @click="hideModal"
          >
            キャンセル
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <v-ons-button
            class="common-style-ok-button"
            style="float: right;"
            @click="updateOrdMain"
            :disabled="isButtonEditable"
          >
            保存
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    tableData: {
      tableTitle: "除水補正",
      patId: ""
    }
  },

  data() {
    return {
      structData: {
        pat_id: "1",
        hederTitle: this.tableTitle
      },
      unit: 0,
      ordMainFlag: 0,
      isDirectlyCommit: false,
      isButtonEdit: false
    };
  },

  methods: {
    hideModal() {
      this.$slots.default[0].componentInstance.clickCancel(this.ordMainFlag);
    },

    updateOrdMain() {
      this.$slots.default[0].componentInstance.clickSave(this.ordMainFlag);
    },

    selectUnit(event) {
      this.$slots.default[0].componentInstance.selectUnit(event.target.value);
    }
  },

  computed: {
    isButtonEditable() {
      // 子コンポーネントとでtrue,falseを切り替える
      return this.isButtonEdit;
    }
  }
};
</script>

<style scoped>
.table-content {
  padding: 2%;
  width: 90vw;
  margin: auto;
  box-sizing: border-box;
  padding: 5px;
  background: var(--ntss-base-background-color);
  text-align: left;
}

.header-style {
  text-align: left;
  padding: 3px;
  font-size: 15px;
}

.radio-class {
  color: black;
  font-size: 15px;
}
</style>
