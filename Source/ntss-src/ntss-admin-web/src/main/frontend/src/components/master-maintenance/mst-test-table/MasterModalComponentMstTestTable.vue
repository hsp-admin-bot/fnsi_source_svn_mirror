/**
 * マスタメンテナンス マスタ編集モーダルのサンプル（メインコンポーネント）
 * マスタ一覧から「テストマスタ」を選択し、「編集」ボタンを押下すると表示されます。
 */
<template>
  <div>
    <table>
      <thead>
        <tr>
          <template v-for="(column, index) in normalizedColumnDefinition" :key="index">
            <th v-if="!validationField(column.field)">
              <span>{{ column.title }}</span>
            </th>
          </template>
        </tr>
      </thead>
      <tbody>
        <tr>
          <template v-for="(column, index) in normalizedColumnDefinition" :key="index">
            <td v-if="!validationField(column.field)">
              <div v-if="getSchemaByField(column.field).type === 'string'">
                <input type="text"
                  :placeholder="getValueByField(column.field)"
                  @blur="updateEditRecord(column.field, $event)"
                />
              </div>
              <div v-else-if="getSchemaByField(column.field).type === 'json'" >
                <input type="text"
                  :placeholder="getValueByField(column.field)"
                  @blur="updateEditRecord(column.field, $event)"
                />
              </div>
              <div v-else-if="getSchemaByField(column.field).type === 'number'">
                <input type="number"
                  :placeholder="getValueByField(column.field)"
                  @blur="updateEditRecord(column.field, $event)"
                />
              </div>
              <div v-else-if="getSchemaByField(column.field).type === 'date'">
                <input type="date"
                  :placeholder="getValueByField(column.field)"
                  @blur="updateEditRecord(column.field, $event)"
                />
              </div>
            </td>
          </template>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";

/**
 * サンプルに記載する情報
 * 「データとして利用できるもの」と「その定義」
 *  schema.model.fields.typeに設定され得る値
 *  ・string
 *  ・number
 *  ・date
 *  ・json
 * 「データとして利用できるもの」のうち、差し替え先では編集させない（表示させない）もの
 *  1. sortInputTime
 *  2. operation
 *  3. allowAddRecord
 *  4. allowSort
 *  5. isDel
 *  6. code
 *  7. $modalType
 *  8. sortRank
 * データのストアからの取得方法
 * データのストアへの反映方法 → done
 * type=dateの項目について、フォーマットを明示する。
 */
export default {
  name: "MstTestTable",
  computed: {
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    normalizedColumnDefinition() {
      // データの定義にあわせてcolumnを正規化する。
      const recordKeys = Object.keys(this.editRecord);
      return this.columnDefinition.filter(cd => recordKeys.includes(cd.field));
    }
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    getValueByField(field) {
      return this.editRecord[field];
    },
    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },
    updateEditRecord(key, ev) {
      this.editRecord[key] = ev.target.value;
      this.setEditRecord(this.editRecord);
    },
    validationField(field) {
      return [
        "sortInputTime",
        "operation",
        "allowAddRecord",
        "allowSort",
        "isDel",
        "code",
        "$modalType",
        "sortRank"
      ].some(el => el === field);
    }
  }
};
</script>

<style scoped>
table {
  border-collapse: collapse;
}
table th,
table td {
  border: solid 1px black;
}
</style>
