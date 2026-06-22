/**
 * パターン２（カテゴリ、日付、予実）表示コンポーネント.
 */
<template>
  <div class="tree-row" @click="onClick(model)">
    <!-- mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start -->
    <!-- <div class="tree-col">
      {{ model.indRstTypeName }} {{ model.treatmentName }} {{ model.kurName }} {{ model.treatTime }} {{ model.bedName }}
    </div> -->
    <div v-if="!model.type" class="tree-col">
      {{ model.indRstTypeName }} {{ model.treatmentName }} {{ model.kurName }} {{ model.treatTime }} {{ model.bedName }}
    </div>
    <div v-else-if="model.type && model.type == 'pat_event'" class="tree-col">
      <!--mod FNSI-No.6276 患者イベントに時刻が登録されていない場合の、予実リスト＞患者イベントの時刻表示の不正 周安寧 start-->
      <!-- {{ '【イベント】' }} {{ model.subCategoryName }} {{ model.eventStartTime + ' 〜 ' }} {{ model.eventEndTime }}-->
      {{ '【イベント】' }} {{ model.subCategoryName }} {{ model.eventStartTime}} 
      {{ (model.eventStartTime === null || model.eventStartTime === "" ) && (model.eventEndTime === null || model.eventEndTime === "" )? '' : ' 〜 '}} {{ model.eventEndTime }}
      <!--mod FNSI-No.6276 患者イベントに時刻が登録されていない場合の、予実リスト＞患者イベントの時刻表示の不正 周安寧 end-->
    </div>
    <!-- mod 6273 検査予定、検査結果、処方を表示している際、スクロールバーの位置がおかしい 周安寧 start -->
    <!-- <div v-else-if="model.type && model.type == 'in_schedule'" class="tree-col">
      {{ '【予定】' }} {{ model.count + '項目' }}
    </div>
    <div v-else-if="model.type && model.type == 'in_result'" class="tree-col">
      {{ '【結果】' }} {{ model.count + '項目' }}
    </div>
    <div v-else-if="model.type && model.type == 'in_photo'" class="tree-col">
      {{ '【予定】' }} {{ model.count + '項目' }}
    </div>
    <div v-else-if="model.type && model.type == 'prescription'" class="tree-col">
      {{ '【' + model.issueState + '】' }} {{ model.prescriptionType }} {{ model.count + '剤' }}
    </div> -->
    <div v-else-if="model.type && model.type == 'in_schedule'" class="tree-col" style="width: 300px">
      {{ '【予定】' }} {{ model.count + '項目' }}
    </div>
    <div v-else-if="model.type && model.type == 'in_result'" class="tree-col" style="width: 300px">
      {{ '【結果】' }} {{ model.count + '項目' }}
    </div>
    <div v-else-if="model.type && model.type == 'in_photo'" class="tree-col" style="width: 300px">
      {{ '【予定】' }} {{ model.count + '項目' }}
    </div>
    <div v-else-if="model.type && model.type == 'prescription'" class="tree-col" style="width: 300px">
      {{ '【' + model.issueState + '】' }} {{ model.prescriptionType }} {{ model.count + '剤' }}
    </div>
    <!-- mod 6273 検査予定、検査結果、処方を表示している際、スクロールバーの位置がおかしい 周安寧 end -->
    <!-- mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end -->
  </div>
</template>

<script>
import TreeViewMixin from "@/components/indication-result/tree-view-pattern/TreeViewMixin.js"

export default {
  mixins: [ TreeViewMixin ]
}
</script>

<style scoped>
.tree-row {
  display: flex;
  flex-wrap: nowrap;
  justify-content: space-between;
  padding: 0;
  margin: 0;
  width: 100%;
}
.tree-col {
  margin: 0.1em 0.5em 0.2em 0;
}
</style>
