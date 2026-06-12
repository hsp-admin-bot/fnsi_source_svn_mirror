/**
 * 治療記録の子機能 処置選択ポップオーバー
 */
<template>
  <v-ons-popover
    cancelable
    :visible="popoverVisible"
    :target="popoverTarget"
    direction="down up"
    :class="[fontSizeSet, 'treatment-popover']"
    ref="selector-popover"
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="onCancel(); popoverPosthide($event)"
  >
    <div class="filter-area">
      <v-ons-input type="text" v-model="searchText" @keydown.enter="onSearchEnter" />
      <v-ons-button class="btn3-normal search-button" @click="onSearchClick">検索</v-ons-button>
    </div>
    <div class="list-area">
      <table class="ntss-list" style="width: max-content; min-width: 100%; max-width: 780px;">
        <thead>
          <tr>
            <th class="ntss-list-header-th-sticky" style="width: 3em;"><label>頁番号</label></th>
            <th class="ntss-list-header-th-sticky"><label>処置</label></th>
            <th class="ntss-list-header-th-sticky" style="width: 250px;"><label>処置薬剤</label></th>
            <th class="ntss-list-header-th-sticky" style="width: 200px;"><label>手技</label></th>
          </tr>
        </thead>
        <tbody :class="themeBlack">
          <tr class="ntss-list-body-tr">
            <td class="ntss-list-body-td border-per-page-bottom"></td>
            <td
              class="ntss-list-body-td border-per-page-bottom"
              colspan="3"
              :class="itemRowClass(-1, hasMatchedName)"
              @click="onItemClick(-1)"
              @dblclick="onItemDblClick(-1)"
            >
              <label>未登録</label>
            </td>
          </tr>
          <template v-for="(item, index) in selectItems" :key="index">
            <tr class="ntss-list-body-tr">
              <td
                v-if="(index % perPage) == 0"
                v-show="isVisiblePage(selectItems, index, hasMatchedName)"
                class="ntss-list-body-td border-per-page-bottom"
                :rowspan="perPage"
              >
                <label>{{ (index / perPage) + 1 }}</label>
              </td>
              <td
                v-for="(displayItem, index2) in item.displayItems"
                :key="index + '-' + index2"
                v-show="isVisibleItem(selectItems, index, hasMatchedName)"
                class="ntss-list-body-td"
                :class="itemRowClass(index, hasMatchedName)"
                @click="onItemClick(index)"
                @dblclick="onItemDblClick(index)"
              >
                <label style="word-break: break-all;">{{ displayItem || '&nbsp;' }}</label>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>
    <div class="button-area flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button denial-btn btn2-cancel" @click="onCancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button registration-btn btn3-normal" :disabled="selectedIndex === null" @click="onOk">OK</v-ons-button>
      </div>
    </div>
  </v-ons-popover>
</template>

<script>
import { mapGetters } from "@/compat/vue/vuex";
import { MstCompTreatment } from "@/models/treatment-record/complaint/MstCompTreatment";
import ComplaintComponentMixin from "@/components/treatment-record/submenu/complaint/ComplaintComponentMixin";
import SelectorComponentMixin from "@/components/treatment-record/submenu/complaint/SelectorComponentMixin";
import { CODES } from "@/constants/TreatmentRecord";
import BigNumber from "@/compat/number/bignumber";
import PopoverMixin from "@/components/PopoverMixin";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { getMstListCompose } from "@/apis/pat-prescription";
import { getMasterConfig } from "@/components/common/master-selector/builder/masterPopoverConfig";
import * as MasterType from "@/components/common/master-selector/MasterType";

// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
const CLASS_MISMATCH_LABEL = "【分類不一致】";
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end

export default {
  mixins: [ComplaintComponentMixin, SelectorComponentMixin, PopoverMixin],
  computed: {
    ...mapGetters("account-edit", ["getTheme"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    themeBlack() {
      return this.getTheme === 1 ? "ntss-list-body-tr-black" : "";
    }
  },
  methods: {
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    ...mapGetters("treatment-record/common", ["getDialysisState"]),
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * 初期化処理.
     */
    async init() {
      this.nonSelectValue = new MstCompTreatment();

      const query = getMasterConfig(MasterType.COMP_TREATMENT_RECORD, {
        facilityCd: this.facilityCd
      });
      const response = await getMstListCompose(query);
      const items = response?.data?.master?.items ?? [];
      this.selectItems = items
        .filter(e => e.isDisp === "1")
        .map(
          e =>
            new MstCompTreatment(
              e.compTreatmentCd,
              e.treatment,
              e.treatClass,
              e.treatMedicineCd,
              e.amount,
              e.procedureCd));

      // 薬剤名・手技名を設定する
      const treatMedicines = await this.readMedicineItems();
      const mstMedicine = treatMedicines.filter(m => {
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //return m.medicineType === CODES.MEDICINE_TYPE.NORMAL.cd;
        return m.medicineType == CODES.MEDICINE_TYPE.NORMAL.cd;
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      });
      const mstMedicineMix = treatMedicines.filter(m => {
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //return m.medicineType === CODES.MEDICINE_TYPE.MIX.cd;
        return m.medicineType == CODES.MEDICINE_TYPE.MIX.cd;
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      });
      const procedures = await this.readProcedureItems();

      this.selectItems.forEach(e => {
        // 薬剤マスタ or 調整薬剤マスタ
        let treatMedicine = null;
        const treatClassCd = e.treatClass != null ? Number(e.treatClass) : null;
        const treatMedicineCd = e?.treatMedicine?.cd != null ? String(e.treatMedicine.cd) : null;
        if (treatClassCd === CODES.TREATMENT_CLASS.MIX.cd) {
          // 調整薬剤マスタから名称及び単位を取得
          treatMedicine = mstMedicineMix.find(
            medi => treatMedicineCd != null && String(medi.cd) === treatMedicineCd
          );
        } else if (treatClassCd === CODES.TREATMENT_CLASS.NORMAL.cd) {
          // 薬剤マスタから名称及び単位を取得
          treatMedicine = mstMedicine.find(
            medi => treatMedicineCd != null && String(medi.cd) === treatMedicineCd
          );
        }
        if (treatMedicine) {
          Object.assign(e.treatMedicine, treatMedicine);
          let numbers = String(e.amount).split('.');
          let decPoint = (numbers[1]) ? numbers[1].length : 0;
          if(decPoint > treatMedicine.decPoint){
            e.amount = BigNumber(1 * e.amount).toFixed();
          }else{
            e.amount = BigNumber(1 * e.amount).toFixed(treatMedicine.decPoint);
          }
        }

        if (e.procedure.cd) {
          const procedure = procedures.find(m => m.cd === e.procedure.cd);
          if (procedure) {
            Object.assign(e.procedure, procedure);
          }
        }
      });
    },
    /**
     * 薬剤マスタ/調整薬剤マスタの取得.
     */
    async readMedicineItems() {
      const medicineAndClassResponse = await this.fetchMedicineAll();
// mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      // const medicines = medicineAndClassResponse[0].data;
      const medicines = medicineAndClassResponse[2].data.master.items;
      

      return medicines.map(e => {
        
        let statusText = '';
        let keyName = 'medicineName'
        let keyCd = 'medicineCd'
        if(e.key_type == 2){
          keyName = 'medicineMixName'
          keyCd = 'medicineMixCd'
        }
        const prefix = e.classInconsistent || '';
        
        if (this.getDialysisState() == 0) {
          statusText = `${e.expired}${e.deleted}${e.includeDeleted}`;
        }
        return {
          //medicineType: e.medicineType,
          //cd: e.medicineCd,
          //name: e.medicineName,
          medicineType: e.key_type,
          cd: e[keyCd],
          name: prefix + e.tabooAllergy + statusText + e[keyName],
          unit: e.unit,
          decPoint: e.unitDecimalPoint
        };
      });
      // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    },
    /**
     * 手技マスタの取得.
     */
    async readProcedureItems() {
      const procedureResponse = await this.fetchProcedureAll();
      const procedures = procedureResponse.data;

      return procedures.map(e => {
        return {
          cd: e.procedureCd,
          name: e.pricedureName
        };
      });
    }
  }
};
</script>

<style scoped>
.treatment-popover {
  padding: 4px;
}
.filter-area ons-input,
.filter-area ons-button {
  margin: 4px;
}
.search-button {
  width: 4em;
  font-size: 1.5em;
}
.treatment-popover :deep(.popover__content) {
  padding: 5px;
}
.treatment-popover :deep(.popover__content),
.treatment-popover :deep(.popover--top),
.treatment-popover :deep(.popover--bottom) {
  width: 700px;
  max-width: 98vw;
}
.list-area {
  overflow: auto;
  /* vh、% 指定の場合、画面サイズ変更で吹き出しの表示が崩れる */
  height: 400px;
}
@media print {
  .list-area{
    height: auto !important;
  }
}
@media screen and (max-height: 600px) {
  .list-area {
    height: 250px;
  }
}
.ntss-list {
  position: relative;
}
.button-area {
  margin: 8px 0px;
  height: auto;
}
.selected-item-tr {
  background-color: var(--treatment-record-complaint-selected-background-color);
  color: var(--treatment-record-complaint-selected-color);
}
.ntss-list-body-td {
  padding: 2px;
}
.border-per-page-bottom {
  border-bottom: solid 1px var(--treatment-record-complaint-per-page-border) !important;
}
/* TODO モーダルのブラックテーマ適用時に以下のスタイルを全て削除する */
.ntss-list {
  background-color: #fafafa;
}
.ntss-list-header-th-sticky {
  background-color: #333333;
  border: solid 1px #cccccc;
  border-top: none;
}
.ntss-list-body-tr {
  border: solid 1px #cccccc;
  color: var(--ntss-base-color);
  background-color:var(--ntss-list-item-background-color);
}
.ntss-list-body-td {
  border: solid 1px #cccccc;
}

.ntss-list-body-tr-black {
  background-color: var(--ntss-base-background-color);
  color: #fafafa;
}
</style>
