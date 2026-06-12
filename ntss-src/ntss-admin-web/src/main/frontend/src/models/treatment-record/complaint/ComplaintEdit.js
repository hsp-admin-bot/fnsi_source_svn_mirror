import { Master } from "@/models/common/master-selector-condition/Master";
import { MasterAndNumber } from "@/models/common/MasterAndNumber";
import { MstComplaint } from "@/models/treatment-record/complaint/MstComplaint";
import { MstCompTreatment } from "@/models/treatment-record/complaint/MstCompTreatment";
import BigNumber from "@/compat/number/bignumber";
import { CODES } from "@/constants/TreatmentRecord";
/**
 * 愁訴処置編集モーダル画面用のモデルクラス
 */
export class ComplaintEdit {
  constructor(complaint, treatment, isNew = false, isDummy = false) {
    this.rowNo = complaint?.complaint?.rowNo || treatment?.rowNo;
    if (complaint) {
      // 愁訴
      this.complaint = new MstComplaint(
        complaint.complaint.cd,
        complaint.complaint.name
      );
    } else {
      this.complaint = new MstComplaint();
    }

    if (treatment) {
      // 処置
      this.treatment = new MstCompTreatment(
        treatment.treat.cd,
        treatment.treat.name,
        treatment.treatClass
      );

      // 処置区分
      this.treatClass = treatment.treatClass;

      // 薬剤区分
      this.medicineType = treatment.medicineType;

      // 名称がnullの場合に""をセットしているのは、マスタ選択部品で「未登録」が選択されたときに未変更であると判定させるため。
      // （マスタ選択部品では""がセットされる）

      // 処置薬剤
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231214 ztc start
      this.treatMedicine = new MasterAndNumber(
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //treatment.medicineType === CODES.MEDICINE_TYPE.NORMAL.cd
        treatment.medicineType == CODES.MEDICINE_TYPE.NORMAL.cd
       // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
          ? treatment.treatMedicine.cd
          // : treatment.treatMedicine.cd + "$",
          // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
          //: treatment.treatMedicine.cd ? treatment.treatMedicine.cd + "$" : null,
          : treatment.treatMedicine.cd ? treatment.treatMedicine.cd : null,
          // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
        // treatment.treatMedicine.name ? treatment.treatMedicine.name : "",
        treatment.treatMedicine.name ? treatment.treatMedicine.name : null,
        treatment.amount
      );
      // this.treatMedicineUnit = treatment.unit;
      this.treatMedicineUnit = treatment.unit ? treatment.unit : null;
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231214 ztc end

      // 小数点ステップ数
      // 指示単位小数部:step制御用パラメータ
      var num = parseInt(treatment.treatMedicine.decPoint ? treatment.treatMedicine.decPoint : null);
      if(isNaN(num)){
        num = 0;
      }
      this.treatMedicineStep = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());

      // 手技
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231214 ztc start
      this.procedure = new Master(
        treatment.procedure.cd,
        // treatment.procedure.name ? treatment.procedure.name : ""
        treatment.procedure.name ? treatment.procedure.name : null
      );
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231214 ztc end

      // 処置者
      this.treatStaff = new Master(
        treatment.treatStaffCd,
        treatment.treatStaffName ? treatment.treatStaffName : ""
      );
    } else {
      this.treatment = new MstCompTreatment();
      this.treatMedicine = new MasterAndNumber();
      this.procedure = new Master();
      this.treatStaff = new Master();
    }

    this.isDel = false;
    this.isNew = isNew;
    // ダミー行有無
    this.isDummy = isDummy;
  }

  // 入力されていないかどうかを返す
  isEmpty() {
    return this.complaint.isEmpty() && this.treatment.isEmpty() && this.treatStaff.isEmpty();
  }
}
