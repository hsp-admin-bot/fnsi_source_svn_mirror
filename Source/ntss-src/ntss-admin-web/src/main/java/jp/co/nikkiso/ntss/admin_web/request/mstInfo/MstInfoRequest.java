package jp.co.nikkiso.ntss.admin_web.request.mstInfo;

import lombok.Getter;
import lombok.Setter;

/**
 * Master情報一括取得パラメータ定義<br>
 * Called by {@link jp.co.nikkiso.ntss.admin_web.web.rest.MstInfoResource#getMstInfo(MstInfoRequest)}
 * @author IES_shiyw
 */
@Getter
@Setter
public class MstInfoRequest {

    /**
     * 施設コード
     */
    private String facilityCd;

    /**
     * （.）で区切る　例えば：mstKur,mstBed,mstVaDeleted,mstMedicineIncludeDeleted
     * See {@link ReqMstName}
     */
    private String reqMstNames;

  /* add by chamaojia 2026-02-11 [11893] キャッシュ軽減対応 --start */
  private Long patId;
  /* add by chamaojia 2026-02-11 [11893] キャッシュ軽減対応 --end */

    /**
     * Masterパラメータkey定義
     */
    public enum ReqMstName {

        /**
         * 禁忌・アレルギークラス
         */
        MST_TABOO_ALLERGY("mstTabooAllergy"),
        /**
         * 禁忌・アレルギークラス (削除されたを含む)
         */
        MST_TABOO_ALLERGY_INCLUDE_DELETED("mstTabooAllergyIncludeDeleted"),
        /**
         * 薬剤クラス
         */
        MST_MEDICINE("mstMedicine"),
        /**
         * 薬剤クラス (削除されたを含む)
         */
        MST_MEDICINE_INCLUDE_DELETED("mstMedicineIncludeDeleted"),
        /**
         * 薬剤分類クラス
         */
        MST_MEDICINE_CLASS("mstMedicineClass"),
        /**
         * 調製薬剤マスタクラス
         */
        MST_MEDICINE_MIX("mstMedicineMix"),
        /**
         * 薬剤分類クラス (削除されたを含む)
         */
        MST_MEDICINE_CLASS_INCLUDE_DELETED("mstMedicineClassIncludeDeleted"),
        /**
         * 調製薬剤マスタクラス (削除されたを含む)
         */
        MST_MEDICINE_MIX_INCLUDE_DELETED("mstMedicineMixIncludeDeleted"),
        /**
         * 治療方法マスタ
         */
        MST_TREATMENT("mstTreatment"),
        /**
         * 治療方法マスタ(削除された)
         */
        MST_TREATMENT_DELETED("mstTreatmentDeleted"),
        /**
         * 治療方法マスタ (削除されたを含む)
         */
        MST_TREATMENT_INCLUDE_DELETED("mstTreatmentIncludeDeleted"),
        /**
         * クールクラス
         */
        MST_KUR("mstKur"),
        /**
         * ベッドマスタ
         */
        MST_BED("mstBed"),
        /**
         * VAクラス
         */
        MST_VA("mstVa"),
        /**
         * VAクラス(削除された)
         */
        MST_VA_DELETED("mstVaDeleted"),
        /**
         * 医療材料クラス
         */
        MST_EQUIPMENT("mstEquipment"),
        /**
         * 医療材料クラス (削除されたを含む)
         */
        MST_EQUIPMENT_INCLUDE_DELETED("mstEquipmentIncludeDeleted"),
        /**
         * 医療材料分類クラス
         */
        MST_EQUIPMENT_CLASS("mstEquipmentClass"),
        /**
         * ダイアライザクラス
         */
        MST_DIALYZE("mstDialyze"),
        /**
         * ダイアライザクラス(削除された)
         */
        MST_DIALYZE_DELETED("mstDialyzeDeleted"),
        /**
         * ダイアライザクラス (削除されたを含む)
         */
        MST_DIALYZER_INCLUDE_DELETED("mstDialyzerIncludeDeleted"),
        /**
         * 一般名処方クラス (削除されたを含む)
         */
        SYS_GENERIC_MEDICINE_INCLUDE_DELETED("sysGenericMedicineIncludeDeleted"),
        /**
         * 感染症クラ
         */
        MST_INFECTION("mstInfection"),
        /**
         * インプラントクラス
         */
        MST_IMPLANT("mstImplant"),
        /**
         * 手技クラス
         */
        MST_PROCEDURE("mstProcedure"),
        /**
         * 投与タイミングクラス
         */
        MST_MEDICATE_TIMING("mstMedicateTiming"),
        /**
         * 投薬支援マスタ
         */
        MNT_MEDICINE_SUPPORT("mntMedicineSupport");
        
        private String name;
        
        ReqMstName(String name) {
            this.name = name;
        }
        
        public String getName() {
            return name;
        }
    }

}


