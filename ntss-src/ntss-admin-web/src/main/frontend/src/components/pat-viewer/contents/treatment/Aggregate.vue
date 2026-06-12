/** * 患者経過総合ビュア薬剤集計、医療材料集計、ダイアライザ集計 */
<template>
    <base-content
    :func-name="funcName"
    :disp-data-list="itemDataList"/>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import { ApiHelper } from "@/apis/AxiosHelper";
// このコンポーネントへ表示する情報を渡す
import baseContent from "@/components/pat-viewer/contents/base/BaseContent";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end

export default {
  components: {
    "base-content": baseContent
  },

  props: {
    // 患者経過総合ビューアレイアウトマスタ選択情報
    layout: {
      type: Object,
      default: () => {}
    }
  },

  data() {
    return {
      //表示するデータのリスト,親コンポーネントに渡す情報
      itemDataList: []
    };
  },

  computed: {
    // mod #12462 患者情報共有->患者経過総合ビューア fang start
    ...mapGetters("pat-info", {
      patId: "selectedPatId",
      // facilityCd: "selectedPatFacilityCd"
    }),
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
    // mod #12462 患者情報共有->患者経過総合ビューア fang end
    ...mapGetters("pat-viewer",
    ["getDateList",
    "getSelectedPeriod",
    "getMstMedicineData",
    "getMstEquipmentData"]),

    // add #12462 患者情報共有->患者経過総合ビューア fang start
    ...mapGetters("account-edit", {
      getPatientShareMode: "getPatientShareMode",
      getPatientShareFacilityCdMode: "getPatientShareFacilityCdMode"
    }),
    // add #12462 患者情報共有->患者経過総合ビューア fang end

    //一覧に表示するデータのリスト
    dateList() {
      return this.getDateList;
    },

    // 一覧上の期間切替
    selectedPeriod() {
      return this.getSelectedPeriod;
    },

    // 薬剤マスタデータ
    mstMedicineData() {
      return this.getMstMedicineData;
    },

    // 医療材料マスタデータ
    mstEquipmentData() {
      return this.getMstEquipmentData;
    },

    funcName() {
      let name = "";
      switch (this.layout.component) {
        case "dialyzer":
          name = "ダイアライザ集計"
          break;
        case "medical":
          name = "医療材料集計";
          break;
        case "drugAggregate":
          name = "薬剤集計"
          break;
      }
      return name;
    }
  },

  async created() {
    this.startLoadingScreen();
    // 表示用に治療条件情報を加工
    this.convertDrugInfo().then(itemDataList => {
      this.itemDataList = itemDataList;
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    async convertDrugInfo() {
      let startDate = dayjs(this.dateList[0],"YYYYMMDD").startOf("day");
      let endDate = dayjs(this.dateList[this.dateList.length - 1],"YYYYMMDD").endOf("day");

      switch (this.selectedPeriod) {
        case "4":
          endDate = endDate.add(1, "week").endOf("day");
          break;
        case "5":
        case "6":
          startDate = startDate.startOf("month");
          endDate = endDate.endOf("month");
          break;
        case "7":
          startDate = startDate.startOf("month");
          endDate = endDate.add(11, "months").endOf("month");
          break;
      }

      // APIの引数作成
      const sendData = {};
      sendData.facility_cd = this.facilityCd;
      sendData.pat_id = this.patId;
      sendData.supplies_base_date_begin = startDate.format("YYYYMMDD");
      // mod #12462 患者情報共有->患者経過総合ビューア fang start
      sendData.supplies_base_date_end = endDate.clone().add(1, "month").startOf("month").format("YYYYMMDD");
      sendData.shareMode = this.getPatientShareMode == '0' && !this.getPatientShareFacilityCdMode ? '0' : '1';
      // mod #12462 患者情報共有->患者経過総合ビューア fang end

      // RestAPI実行「計算材料情報を取得」
      const ordMaterialSave = await ApiHelper.post(
        "/mainData/getOrdMaterialSave",
        sendData
      ).catch(err => {
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage('Aggregate.vue', 'convertDrugInfo', err);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        throw err;
      });
      let ordMaterialSaveData = [];
      if (ordMaterialSave) {
        // mod #12462 患者情報共有->患者経過総合ビューア fang start
        ordMaterialSaveData = this.otherFacilityOrdMaterialSaveConvert(this.facilityCd, ordMaterialSave, this.getMstMedicineData)
        // ordMaterialSaveData = ordMaterialSave.data;
        // mod #12462 患者情報共有->患者経過総合ビューア fang end
      }

      let suppliesClass = "";
      let mstTable= "";

      switch (this.layout.component) {
        case "dialyzer":
          // ダイアライザ
          suppliesClass = '01';
          break;
        case "medical":
          // 医療材料
          suppliesClass = '11';
          mstTable = this.mstEquipmentData;
          break;
        case "drugAggregate":
          // 投与薬剤
          suppliesClass = '12';
          mstTable = this.mstMedicineData;
          break;
      }

      // 加工した表示用データ格納用
      const convertData = [];
      //レイアウトのサブアイテム取得（横方向のタイトル）
      const subItem = this.layout.categoryItem[0].subCategoryItem;
      subItem.forEach(item =>{
        //mod FutreNetWeb+SI課題管理 no.6309 劉全航 start
        var tempDrug;
        if(this.layout.component === "medical"||this.layout.component ==="dialyzer"){
            tempDrug = {
            data: [],
            itemName: "「" + item.itemName + "」" + item.plans,
            itemNo: -1
          };
        }else{
          tempDrug = {
          data: [],
          itemName: "「" + item.itemName + "」" + item.plans + " "+item.unit,
          itemNo: -1
          };
        }
        // const tempDrug = {
        //   data: [],
        //   itemName: "「" + item.itemName + "」" + item.plans + " "+item.unit,//「物品名」予定　単位
        //   itemNo: -1
        // };
        //mod FutreNetWeb+SI課題管理 no.6309 劉全航 end
        // 物品コード
        const itemNo = item.itemNo + '';
        // 指示・実績区分
        const indRstClass = (item.plans === '予定') ? "1" : "2";

        let unit = "";
        if (this.layout.component === "dialyzer") {
          // ダイアライザの単位は「本」とする。
          unit = "本";
        } else {
        // 単位を取得するため、マスターから該当物品を抽出
          const mstData = mstTable.find(mstItem => {
            if (this.layout.component === "medical"){
              return mstItem.equipmentCd +'' === itemNo;
            }else if (this.layout.component === "drugAggregate"){
              return mstItem.medicineCd +'' === itemNo;
            }
          });
         if (mstData) {
            if (this.layout.component === "medical"){
              unit = mstData.unit ? mstData.unit : "";
            }else if (this.layout.component === "drugAggregate"){
              unit = (item.unit === "指示単位") ?
              (mstData.unit ? mstData.unit : "") :
              (mstData.unitSecond ? mstData.unitSecond : "");
            }
          }
        }
        for (let i=0; i<this.dateList.length; i++){
          let endDt = (i<(this.dateList.length -1)) ? this.dateList[i+1]:"99999999";
          // 物品と表示期間毎にデータをフィルタする。
          const itemData = ordMaterialSaveData.filter(data =>
            suppliesClass === data.suppliesClass &&
            itemNo === data.suppliesCd &&
            this.dateList[i] <= data.suppliesBaseDate &&
            endDt > data.suppliesBaseDate &&
            indRstClass === data.indRstClass
           );
          let sumValue = 0;
          itemData.forEach(subiItemData =>{
            //mod 5634 2023-02-21 11:40 長期間表示の医療材料集計，薬剤集計，ダイアライザ集計が表示されない 張 start
            // if (item.unit === "指示単位") {
            //   sumValue += subiItemData.indRstValue ? Number(subiItemData.indRstValue) : 0;
            // }
            // if (item.unit === "レセ単位") {
            //   sumValue += subiItemData.receiptValue ? Number(subiItemData.receiptValue) : 0;
            // }
            //mod FutreNetWeb+SI課題管理 no.5978 start
            // if(this.layout.categoryItem[0].component === "medical") {
              sumValue += subiItemData.indRstValue ? Number(subiItemData.indRstValue) : 0;
            // }
            //mod FutreNetWeb+SI課題管理 no.5978 end
            //mod 5634 2023-02-21 11:40 長期間表示の医療材料集計，薬剤集計，ダイアライザ集計が表示されない 張 end
          });
          sumValue = sumValue.toFixed().replace(/\d{1,3}(?=(\d{3})+(\.\d*)?$)/g, '$&,');
          tempDrug.data.push({
            treatDate: null,
            ordNo: null,
            value1: (Number(sumValue) === 0) ? null : sumValue + " " + unit,
            value2: null,
            isNotClickable: true,
            colorFlg: 0,
            deviceMode: -1,
            treatMethodCd: 0,
            isRstRoundsFlg: false,
            type :"cf"
          });
        }
        convertData.push(tempDrug);
      });
      return convertData;
    },
    // add #12462 患者情報共有->患者経過総合ビューア fang start
    otherFacilityOrdMaterialSaveConvert(facilityCd, ordMaterialSave, mstMedicine) {
      let reuslt = []
      if(ordMaterialSave && ordMaterialSave.data && ordMaterialSave.data.length > 0) {
        for(let i = 0; i < ordMaterialSave.data.length; i++) {
          let detail = ordMaterialSave.data[i]
          if(detail.facilityCd != facilityCd) {
            // 通常薬剤だけ処理する
            if(detail.suppliesClass != '12' && detail.suppliesClass != '23' && detail.suppliesClass != '24') {
              // 通常薬剤以外を除く
              continue;
            } else {
              if(detail.standardMedicineCd){
                let medicineIndex = mstMedicine.findIndex(el => el.standardMedicineCd == detail.standardMedicineCd)
                if(medicineIndex != -1) {
                  // 本施設の薬剤コードに転換
                  detail.suppliesCd = mstMedicine[medicineIndex].medicineCd + "";
                  reuslt.push(detail)
                }
              }
            }
          } else {
            reuslt.push(detail)
          }
        }
      }
      return reuslt;
    }
    // add #12462 患者情報共有->患者経過総合ビューア fang end
  }
};
</script>

<style scoped lang="scss">
@use "../../css/style.scss" as *;

/* 患者経過総合ビューア共通スタイル定義 */
div :deep(.list-content-col) {
  width: 0px;
}
</style>
