<template>
  <table class="infection-table ntss-list">
    <thead>
      <tr class="ntss-list-header-tr">
        <th class="ntss-list-header-th">項目名</th>
        <th class="ntss-list-header-th infection-result">結果</th>
        <th class="ntss-list-header-th infection-examdate">検査日</th>
      </tr>
    </thead>
    <tbody v-if="mstInfection !== null">
      <tr
        class="ntss-list-body-tr"
        v-for="(infection, index) in infectionData"
        :key="`infection${index}`"
      >
        <!-- 項目 -->
        <td class="ntss-list-body-td">
          {{ mstCdToName(
          mstInfection,
          infection.infection_cd,
          'infectionCd',
          'infectionName'
          ) }}
        </td>
        <!-- 結果 -->
        <td class="ntss-list-body-td infection-item">
          <span v-if="+infection.infect === 2">(＋)</span>
          <span v-if="+infection.infect === 1">(－)</span>
          <span v-if="+infection.infect === 0">不明</span>
        </td>
        <!-- 検査日 -->
        <td class="ntss-list-body-td">
          <span>{{ formatExamDate(infection.exam_date) }}</span>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import { mstCdToName } from "@/functions/common/CommonFunctions.js";

export default {
  props: {
    mstInfection: {
      required: true
    },
    infectionData: {
      required: true
    }
  },

  methods: {
    mstCdToName,
    formatExamDate(examDate) {
      if (examDate === undefined || examDate === null || examDate === "") {
        return "―";
      }

      return (
        examDate.substr(0, 4) +
        "/" +
        examDate.substr(4, 2) +
        "/" +
        examDate.substr(6, 2)
      );
    }
  }
};
</script>

<style scoped>
.infection-table {
  position: relative;
}
.infection-table .ntss-list-body-td {
  padding: 4px;
}

.infection-examdate {
  width: 30%;
}

.infection-result {
  width: 20%;
  text-align: center;
}

.infection-item {
  text-align: center;
}
</style>
