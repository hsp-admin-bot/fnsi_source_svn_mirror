package jp.co.nikkiso.ntss.core.dto.ordMaterialSave;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import lombok.Getter;
import lombok.Setter;
import org.apache.commons.lang3.StringUtils;

import java.util.List;

@Getter
@Setter
public class OrdMaterialSaveBatchHandleDTO {

  /** オーダ番号List */
  private List<Long> ordNoList;

  /** エンティティが作成されている場合は、再search必要が無い */
  private List<OrdMain> cacheOrdMainList;

  /** 治療条件更新Flg */
  private int treatMode;

  public OrdMaterialSaveBatchHandleDTO(List<Long> ordNoList, int treatMode) {
    this.ordNoList = ordNoList;
    this.treatMode = treatMode;
  }

  public OrdMaterialSaveBatchHandleDTO(List<Long> ordNoList, List<OrdMain> cacheOrdMainList
    , int treatMode) {
    this.ordNoList = ordNoList;
    this.cacheOrdMainList = cacheOrdMainList;
    this.treatMode = treatMode;
  }

  public OrdMaterialSaveBatchHandleDTO(List<Long> ordNoList, boolean treatCondition, boolean medicament
    , boolean equipment, boolean complaint, String indRstClass,
                                       boolean rstUpdFlg) {
    this.ordNoList = ordNoList;
    this.treatMode = getBatchModifiedMode(treatCondition, medicament, equipment, complaint, indRstClass, rstUpdFlg);
  }

  public OrdMaterialSaveBatchHandleDTO(List<Long> ordNoList, List<OrdMain> cacheOrdMainList, boolean treatCondition
    , boolean medicament, boolean equipment, boolean complaint, String indRstClass,
                                       boolean rstUpdFlg) {
    this.ordNoList = ordNoList;
    this.cacheOrdMainList = cacheOrdMainList;
    this.treatMode = getBatchModifiedMode(treatCondition, medicament, equipment, complaint, indRstClass, rstUpdFlg);
  }

  public static int getBatchModifiedMode(
    boolean treatCondition,
    boolean medicament,
    boolean equipment,
    boolean complaint,
    String rstClass,
    boolean rstUpdFlg
  ) {
    return (treatCondition ? 1 : 0)
      | (medicament ? 1 << 1 : 0)
      | (equipment ? 1 << 2 : 0)
      | (complaint ? 1 << 3 : 0)
      | (StringUtils.equals(OrdMaterialSaveDto.RST_CLASS, rstClass) ? 1 << 4 : 0)
      | (rstUpdFlg ? 1 << 5 : 0);
  }
}
