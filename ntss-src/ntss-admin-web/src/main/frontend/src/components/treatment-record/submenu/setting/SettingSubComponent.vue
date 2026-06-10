<template>
  <div class="expandable-content">
    <div v-if="values.length > 0">
      <div class="table-wrapper">
        <table class="treat-condition-table">
          <thead>
            <tr class="treat-condition-table-header">
              <th style="position: sticky; left: 0; top: 0; white-space: nowrap; background-color: inherit;" class="treat-condition-table-header-th">
                項目名
              </th>
              <th v-for="(model, index) in values" :key="index" class="treat-condition-table-header-th">
                <div>
                  <div style="white-space: nowrap;">
                    {{ model.getFormattedReceiveDate() }}
                  </div>
                  <div style="white-space: nowrap;">
                    {{ model.getTreatClassName() }}
                  </div>
                </div>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(title, titleIndex) in titles" :key="titleIndex">
              <td class="ntss-list-body-td title-table-body-td">
                <div class="treat-condition-table-title-width">
                  {{ title }}
                </div>
              </td>
              <td v-for="(data, index) in dataList[titleIndex]" :key="index" class="ntss-list-body-td treat-condition-table-body-td">
                <div class="treat-condition-table-body-width" @click="onCellClick(data.jsonKey, index)">
                  {{ data.value == null || (typeof data.value === "string" && data.value.trim() === "") ? "&nbsp;" : data.value }}
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  props: {
    titles: {
      type: Array,
      default: () => []
    },
    values: {
      type: Array,
      default: () => []
    },
    count: {
      type: Number,
      default: 0
    },
    category: {
      type: String,
      default: ""
    }
  },
  computed: {
    dataList() {

      // #11124 2025.08.26 mod 酸素飽和度対応 TDC高村 start
      //const values = this.values.map(v => v.getValueWithJsonKey());
      let values;
      if ( this.category == "bv" ) {
        values = this.values.map(v => v.getValueWithJsonKey(this.count));
      }
      else {
        values = this.values.map(v => v.getValueWithJsonKey());
      }
      // #11124 2025.08.26 mod 酸素飽和度対応 TDC高村 end

      const arr = [];

      this.titles.forEach((title, titleIndex) => {
        const _arr = [];
        values.forEach((value) => {
          _arr.push(value[titleIndex]);
        })
        arr.push(_arr);
      });

      return arr;
    }
  },
  methods: {
    //mod FNSI修正 装置設定バッグ改修 房 start
    onCellClick(jsonKey, index) {
      this.$emit("onCellClick", this.category, jsonKey, index);
    }
    //mod FNSI修正 装置設定バッグ改修 房 end
  },
};
</script>
<style scoped>
.expandable-content {
  padding: 0.2em 0px 0.2em 0;
}
.table-wrapper {
  width: 100%;
  overflow: auto;
}
.treat-condition-table {
  border-collapse: separate;
  border-spacing: 0;
}
.treat-condition-table-header {
  color: white;
  background-color: var(--ntss-list-header-background-color);
  height: 2em;
}
.treat-condition-table-header-th {
  padding: 4px;
  border: solid 1px var(--ntss-list-border-color);
  border-top: none;
  border-left: none;
  font-weight: unset;
}
.title-table-body-td {
  position: sticky;
  left: 0;
  background-color: var(--body-background-color);
  border-top: none;
}
.treat-condition-table-body-td {
  border-top: none;
  border-left: none;
}
.treat-condition-table-title-width {
  width: 12em;
}
.treat-condition-table-body-width {
  width: 8em;
}
@media screen and (max-width: 600px) {
  .treat-condition-table-title-width {
    width: 8em;
  }
  .treat-condition-table-body-width {
    width: 6em;
  }
}
</style>
