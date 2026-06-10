<script>
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
import { getMstListCompose } from "@/apis/pat-prescription";
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
import {
  sendRequestGetMstProcedureWithoutLoaderByFacilityCd,
  getMedicineAllWithoutLoaderByFacilityCd,
  sendRequestGetMstMedicineClassWithoutLoaderByFacilityCd,
  sendRequestGetMstProcedureWithoutLoaderIncludeDeletedByFacilityCd
} from "@/apis/treatment-record";

export default {
  data() {
    return {
      perPage: 8 // 1ページ中に表示される愁訴処置の数
    }
  },
  methods: {
    /**
     * 薬剤マスタ取得.
     */
    fetchMedicineAll(facilityCd) {
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      const item = {
          lists: [
            {
              id: "list1",
              name: "固定分类",
              sourceType: "FIXED",
              fixedItems: [
                { value: 0, text: "すべて" },
                { value: "1", text: "通常薬剤" },
                { value: "2", text: "調製薬剤" }
              ],
              keyMapping: [
                { keyName: "key_type", valueFrom: "value" }
              ]
            },
            {
              id: "list2",
              name: "药剂分类MST",
              sourceType: "MST",
              mstSource: {
                mstCode: "mstMedicineClassDaoImpl",
                sqlParams: { facilityCd: facilityCd }
              },
              keyMapping: [
                { keyName: "key_class", valueFrom: "classCd" }
              ]
            },
            {
              id: "list3",
              name: "通常药剂 + 调制药剂 合并",
              sourceType: "MST_COMBINED",
              mstSourceList: [
                {
                  mstCode: "mstMedicineDaoImpl",
                  sourceTag: "1",
                  sqlParams: { facilityCd: facilityCd,patId:this.selectedPatId ? String(this.selectedPatId) : null },
                  keyMapping: [
                    { keyName: "key_type", valueFrom: "sourceTag" },
                    { keyName: "key_class", valueFrom: "classCd" },
                    { keyName: "key_cd", valueFrom: "medicineCd" }
                  ]
                },
                {
                  mstCode: "mstMedicineMixDaoImpl",
                  sourceTag: "2",
                  sqlParams: { facilityCd: facilityCd,patId:this.selectedPatId ? String(this.selectedPatId) : null },
                  keyMapping: [
                    { keyName: "key_type", valueFrom: "sourceTag" },
                    { keyName: "key_class", valueFrom: "classCd" },
                    { keyName: "key_cd", valueFrom: "medicineMixCd" }
                  ]
                }
              ]
            }
          ]
        }
      return Promise.all([
        getMedicineAllWithoutLoaderByFacilityCd(facilityCd),
        sendRequestGetMstMedicineClassWithoutLoaderByFacilityCd(facilityCd),
        getMstListCompose(item)
      ]);
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    },
    /**
     * 手技マスタ取得.
     */
    fetchProcedureAll(facilityCd) {
      return sendRequestGetMstProcedureWithoutLoaderByFacilityCd(facilityCd);
    },
    /**
     * 手技マスタ取得（削除済み含む）.
     */
    fetchProcedureAllIncludeDeleted(facilityCd) {
      return sendRequestGetMstProcedureWithoutLoaderIncludeDeletedByFacilityCd(facilityCd);
    },
    /**
     * TODO 処置マスタディープコピー
     */
    deepCopyMstCompTreatment(dest, source, numberConvert) {
        dest.code = source.code;
        dest.treatment = source.treatment;
        dest.treatClass = source.treatClass;
        if(numberConvert){
          dest.amount = source.amount ? Number(source.amount) : null;
        }else{
          dest.amount = source.amount ? String(source.amount) : null;
        }
        dest.treatMedicine.code = source.treatMedicine.code;
        dest.treatMedicine.name = source.treatMedicine.name;
        dest.treatMedicine.unit = source.treatMedicine.unit;
        dest.treatMedicine.decPoint = source.treatMedicine.decPoint;
        dest.procedure.code =  source.procedure.code;
        dest.procedure.name =  source.procedure.name;
        dest.takeMedicine.code =  source.takeMedicine.code;
        dest.takeMedicine.name =  source.takeMedicine.name;
        dest.isDisp= source.isDisp;
        dest.up_date = source.up_date;
        dest.inHospAStartdate = source.inHospAStartdate;
        dest.inHospBStartdate = source.inHospBStartdate;
        dest.inHospitalCdA1 = source.inHospitalCdA1;
        dest.inHospitalCdA2 = source.inHospitalCdA2;
        dest.inHospitalCdA3 = source.inHospitalCdA3;
        dest.inHospitalCdA4 = source.inHospitalCdA4;
        dest.inHospitalCdB1 = source.inHospitalCdB1;
        dest.inHospitalCdB2 = source.inHospitalCdB2;
        dest.inHospitalCdB3 = source.inHospitalCdB3;
        dest.inHospitalCdB4 = source.inHospitalCdB4;
    },

    compareData(dest, source) {
      if (dest.code != source.code) {
        return false;
      }
      if (dest.treatment != source.treatment) {
        return false;
      }
      if (dest.treatClass != source.treatClass) {
        return false;
      }
      if (dest.amount != source.amount) {
        return false;
      }
      if (dest.treatMedicine.code != source.treatMedicine.code) {
        return false;
      }
      if (dest.treatMedicine.name != source.treatMedicine.name) {
        return false;
      }
      if (dest.treatMedicine.unit != source.treatMedicine.unit) {
        return false;
      }
      if (dest.treatMedicine.decPoint != source.treatMedicine.decPoint) {
        return false;
      }
      if (dest.procedure.code !=  source.procedure.code) {
        return false;
      }
      if (dest.procedure.name !=  source.procedure.name) {
        return false;
      }
      if (dest.takeMedicine.code !=  source.takeMedicine.code) {
        return false;
      }
      if (dest.takeMedicine.name !=  source.takeMedicine.name) {
        return false;
      }
      if (dest.isDisp!= source.isDisp) {
        return false;
      }
      if (dest.inHospAStartdate != source.inHospAStartdate) {
        return false;
      }
      if (dest.inHospBStartdate != source.inHospBStartdate) {
        return false;
      }
      if (dest.inHospitalCdA1 != source.inHospitalCdA1) {
        return false;
      }
      if (dest.inHospitalCdA2 != source.inHospitalCdA2) {
        return false;
      }
      if (dest.inHospitalCdA3 != source.inHospitalCdA3) {
        return false;
      }
      if (dest.inHospitalCdA4 != source.inHospitalCdA4) {
        return false;
      }
      if (dest.inHospitalCdB1 != source.inHospitalCdB1) {
        return false;
      }
      if (dest.inHospitalCdB2 != source.inHospitalCdB2) {
        return false;
      }
      if (dest.inHospitalCdB3 != source.inHospitalCdB3) {
        return false;
      }
      if (dest.inHospitalCdB4 != source.inHospitalCdB4) {
        return false;
      }
      return true;
    }
  }
}
</script>
