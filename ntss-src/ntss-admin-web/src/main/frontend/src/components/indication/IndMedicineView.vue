/* 投薬補助画面 */

<template>
  <modal-base @onClose="hideModal">
        <template #body>
<div class="modal-container-custom" id="modal-indHistory">
      <div class="modal-contents">
        <v-ons-row>
          <v-ons-col>{{ dispDataItem.shiji_kaishi_nichi.label }}</v-ons-col>
          <v-ons-col>{{ this.dateFormat(dispDataItem.shiji_kaishi_nichi.value) }}</v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>{{ dispDataItem.shiji_shuuryou_nichi.label }}</v-ons-col>
          <v-ons-col>{{ this.dateFormat(dispDataItem.shiji_shuuryou_nichi.value) }}</v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>{{ dispDataItem.touyo_kankaku.label }}</v-ons-col>
          <v-ons-col>{{ this.getDateInterval(dispDataItem.touyo_kankaku.value) }}</v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>{{ dispDataItem.youbi.label }}</v-ons-col>
          <v-ons-col>{{ this.getWeek(dispDataItem.youbi.value) }}</v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>{{ dispDataItem.shokai_touyo_nichi.label }}</v-ons-col>
          <v-ons-col>{{ this.dateFormat(dispDataItem.shokai_touyo_nichi.value) }}</v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>{{ dispDataItem.bunrui_meishou.label }}</v-ons-col>
          <v-ons-col>{{ this.nameFormat(dispDataItem.bunrui_meishou.value) }}</v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>{{ dispDataItem.yakuzai_meishou.label }}</v-ons-col>
          <v-ons-col>{{ this.nameFormat(dispDataItem.yakuzai_meishou.value) }}</v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>{{ dispDataItem.shugi.label }}</v-ons-col>
          <v-ons-col>{{ this.getProcedure(dispDataItem.shugi.value) }}</v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>{{ dispDataItem.touyo_taimingu.label }}</v-ons-col>
          <v-ons-col>{{ this.getTiming(dispDataItem.touyo_taimingu.value) }}</v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>{{ dispDataItem.komento.label }}</v-ons-col>
          <v-ons-col>{{ dispDataItem.komento.value }}</v-ons-col>
        </v-ons-row>
      </div>
    </div>
    </template>
        <template #footer>
<div class="modal-footer-custom">
      <v-ons-row>
        <v-ons-col>
          <v-ons-button class="btn3-normal width-padding" @click="hideModal">
            OK
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
    </template>
  </modal-base>
</template>

<script>
import { mapGetters } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import dayjs from "@/compat/date/dayjs";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import PopoverMixin from "@/components/PopoverMixin";

export default {
  components: {
    ModalBase
  },

  mixins: [MultiModalMixin, PopoverMixin],

  data() {
    return {
      sourceDataItem: {
        amount: null,
        cd: null,
        classCd: null,
        data: [],
        dateInterval: null,
        decPoint: null,
        index: null,
        isTabooAllergy: null,
        itemName: null,
        itemNo: null,
        medicateTimingCd: null,
        medicineType: null,
        procedureCd: null,
        unit: null,
      },
      dispDataItem: {
        // 指示開始日
        shiji_kaishi_nichi: {
          label: "指示開始日：",
          value: ""
        },
        // 指示終了日
        shiji_shuuryou_nichi: {
          label: "指示終了日：",
          value: ""
        },
        // 投与間隔
        touyo_kankaku: {
          label: "投与間隔：",
          value: ""
        },
        // 曜日
        youbi: {
          label: "曜日：",
          value: ""
        },
        // 初回投与日
        shokai_touyo_nichi: {
          label: "初回投与日：",
          value: ""
        },
        // 分類名称
        bunrui_meishou: {
          label: "分類名称：",
          value: ""
        },
        // 薬剤名称
        yakuzai_meishou: {
          label: "薬剤名称：",
          value: ""
        },
        // 手技
        shugi: {
          label: "手技：",
          value: ""
        },
        // 投与タイミング
        touyo_taimingu: {
          label: "投与タイミング：",
          value: ""
        },
        // コメント
        komento: {
          label: "コメント：",
          value: ""
        },
      },
      MedicineString: "medicineDel"
    };
  },

  computed: {
    // 呼出元からのパラメータ取得
    ...mapGetters("multi-modal", ["getInitValues"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer", [
      // 手技マスタ
      "getMstProcedureData",
      // 投与タイミングマスタ
      "getMstMedicateTimingData"
    ]),
  },

  methods: {
    dateFormat(txt) {
      return dayjs(txt).format("YYYY/MM/DD");
    },
    nameFormat(txt) {
      return txt.replace(this.MedicineString, "");
    },

    getDateInterval(code) {
      switch (code) {
        case 0: return "毎回";
        case 1: return "毎週";
        case 2: return "1回／2週";
        case 3: return "1回／3週";
        case 4: return "1回／4週";
        case 5: return "1回／月：第1曜日";
        case 6: return "1回／月：第2曜日";
        case 7: return "1回／月：第3曜日";
        case 8: return "1回／月：第4曜日";
        case 9: return "1回／月：最終曜日";
        case 10: return "1回／月：最終治療日";
        default: return "";
      }
    },

    getProcedure(code) {
      const mediFind = this.getMstProcedureData.find(mstData => {
        return mstData.procedureCd === code;
      });
      if (mediFind) {
        return mediFind.pricedureName;
      }
    },

    getTiming(code) {
      const mediFind = this.getMstMedicateTimingData.find(mstData => {
        return mstData.medicateTimingCd === code;
      });
      if (mediFind) {
        return mediFind.medicateTimingName;
      }
    },

    getWeek(code) {
      const result = [{
        key: 1,
        disp: false,
        name: "月",
        sort: 10
      }, {
        key: 2,
        disp: false,
        name: "火",
        sort: 20
      }, {
        key: 3,
        disp: false,
        name: "水",
        sort: 30
      }, {
        key: 4,
        disp: false,
        name: "木",
        sort: 40
      }, {
        key: 5,
        disp: false,
        name: "金",
        sort: 50
      }, {
        key: 6,
        disp: false,
        name: "土",
        sort: 60
      }, {
        key: 0,
        disp: false,
        name: "日",
        sort: 100
      }];
      for (const resultItem of result) {
        if (code.indexOf(resultItem.key) > -1) {
          resultItem.disp = true;
        }
      }
      return result
        .filter(p => p.disp)
        .sort(function(a, b) {
          return a.sort > b.sort ? 1 : -1;
        })
        .map(p => p.name)
        .join('、');
    }
  },

  async created() {
    this.sourceDataItem = this.getInitValues;

    // 投与間隔
    this.dispDataItem.touyo_kankaku.value = this.sourceDataItem.dateInterval2;
    // 分類名称
    this.dispDataItem.bunrui_meishou.value = this.sourceDataItem.className;
    // 薬剤名称
    this.dispDataItem.yakuzai_meishou.value = this.sourceDataItem.medicineName;
    // 手技
    this.dispDataItem.shugi.value = this.sourceDataItem.procedureCd2;
    // 投与タイミング
    this.dispDataItem.touyo_taimingu.value = this.sourceDataItem.medicateTimingCd2;
    // コメント
    this.dispDataItem.komento.value = this.sourceDataItem.comment;

    const url = `mainData/getIndMediInfoHistory/${this.selectedPatId}/${this.getFacilityCd}/${this.sourceDataItem.itemNo}`;
    ApiHelper.get(url).then(response => {
      // 開始日
      this.dispDataItem.shiji_kaishi_nichi.value = response.data.mindate;
      // 終了日
      this.dispDataItem.shiji_shuuryou_nichi.value = response.data.maxdate;
      // 曜日
      this.dispDataItem.youbi.value = response.data.dow;
      // 初回投与日
      this.dispDataItem.shokai_touyo_nichi.value = this.dispDataItem.shiji_kaishi_nichi.value;
    })
    .catch(error => {
        throw error;
    });
  },

  beforeUnmount() {
    (this.$el?.ownerDocument?.defaultView || window).removeEventListener("resize", this.onResize);
  }
};
</script>

<style scoped>
.modal-container-custom {
  height: auto;
  color: black;
}
.modal-footer-custom {
  padding: 10px;
  text-align: center;
}
.width-padding {
  width: 80px;
  padding-top: 8px;
}

.modal-contents > ons-row {
  border: 1px solid var(--ntss-border-color);
  color: var(--ntss-base-color);
  padding: 10px;
  margin: 0px 10px;
  width: auto;
}
.modal-contents > ons-row > ons-col:not(:first-child) {
  margin: auto;
  min-width: 69%;
  flex: 0 0 9%;
  white-space: normal;
}
.modal-contents > ons-row > ons-col:first-child {
  margin: auto;
  max-width: 30%;
  text-align: right;
}
</style>
