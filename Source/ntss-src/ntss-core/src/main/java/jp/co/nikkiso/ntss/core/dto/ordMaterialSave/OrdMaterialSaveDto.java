package jp.co.nikkiso.ntss.core.dto.ordMaterialSave;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class OrdMaterialSaveDto {


  public static final String IND_CLASS = "1";
  public static final String RST_CLASS = "2";

  /**
   * オーダ番号
   */
  private Long ordNo;
  /**
   * 治療条件更新Flg
   */
  private Boolean treatCondition;
  /**
   * 投与薬剤更新Flg
   */
  private Boolean medicament;
  /**
   * 医療材料更新Flg
   */
  private Boolean equipment;
  /**
   * 愁訴更新Flg
   */
  private Boolean complaint;
  /**
   * 指示・実績区分 ("1":指示,"2":実績)
   */
  private String indRstClass;

  /** エンティティが作成されている場合は、再search必要が無い */
  private OrdMain ordMainParam;

  public OrdMaterialSaveDto(Long ordNo, Boolean treatCondition, Boolean medicament
    , Boolean equipment, Boolean complaint, String indRstClass) {
    this.ordNo = ordNo;
    this.treatCondition = treatCondition;
    this.medicament = medicament;
    this.equipment = equipment;
    this.complaint = complaint;
    this.indRstClass = indRstClass;
  }

  public OrdMaterialSaveDto(Long ordNo, Boolean treatCondition, Boolean medicament
    , Boolean equipment, Boolean complaint, String indRstClass, OrdMain ordMainParam) {
    this.ordNo = ordNo;
    this.treatCondition = treatCondition;
    this.medicament = medicament;
    this.equipment = equipment;
    this.complaint = complaint;
    this.indRstClass = indRstClass;
    this.ordMainParam = ordMainParam;
  }
}
