<template>
  <tr>
    <!-- 項目 -->
    <td class="item-cell">{{ infectionName }}</td>
    <!-- 結果 -->
    <td class="item-cell radio-area">
      <custom-select
        style = "width: 70px;"
        :value = "infectionValue"
        :options="dispComboLists"
        :disabled="displayMode || editFlag || otherFacility"
      />
    </td>
    <!-- 検査日 -->
    <td class="item-cell">
      <custom-input-date :value="examdateValue" :disabled="displayMode || editFlag || otherFacility"/>
    </td>
    <!-- 更新日 -->
    <td class="item-cell">{{ update }}</td>
  </tr>
</template>

<script>
import customInputDate from "@/components/common/custom-form-tags/CustomInputDate";
// add FNSI-Change style and use common component 関 start
import customSelect from "@/components/common/custom-form-tags/CustomSelect.vue";
// add FNSI-Change style and use common component 関 end
export default {
  components: {
    "custom-input-date": customInputDate,
    // add FNSI-Change style and use common component 関 start
    "custom-select": customSelect
    // add FNSI-Change style and use common component 関 end
  },

  props: {
    update: {
      required: true
    },
    infectionName: {
      required: true
    },
    infection: {
      required: true
    },
    examdate: {
      required: true
    },
    displayMode: {
      type: Boolean,
      default: false
    },
    editFlag: {
      type: Boolean,
      default: false
    },
    otherFacility: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      dispComboList: [
        { value: "0", name: "不明" },
        { value: "2", name: "(＋)"},
        { value: "1", name: "(－)"}
      ],
      // add FNSI-Change style and use common component 関 start
      dispComboLists: [
        { value: "0", displayValue: "不明" },
        { value: "2", displayValue: "(＋)"},
        { value: "1", displayValue: "(－)"}
      ],
      // add FNSI-Change style and use common component 関 end

    };
  },

  computed: {
    infectionValue() {
      return this.infection;
    },

    examdateValue() {
      return this.examdate;
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    isEdited() {
      //「コメント」内容未变更时，输入框样式表示为内容变更的样式。
      return this.infection.initValue !== this.infection.editValue;
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  },
};
</script>

<style scoped>
.item-cell {
  border: 1px solid;
  text-align: center;
}

.radio-area {
  text-align: center;
}
</style>
