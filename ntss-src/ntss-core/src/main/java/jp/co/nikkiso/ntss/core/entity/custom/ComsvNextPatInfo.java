package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

/**
 * 通信サーバ用次患者情報クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvNextPatInfo {

  @Id
  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ordNo;

  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  /**
   * 治療日
   */
  private String treatDate;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 施設名
   */
  private String facilityName;

  /**
   * 指示：治療方法コード
   */
  private int indTreatmentCd;
  // #9290 2023.10.19 add 実績展開後の名称を取得する TDC片口 start
  /**
   * 指示：治療方法名称
   */
  private String indTreatmentName;
  //#9290 2023.10.19 add 実績展開後の名称を取得する TDC片口 end

  /**
   * 指示：クール名
   */
  private String kurName;

  /**
   * 指示：治療開始時刻
   */
  private String indTreatStartTime;

  /**
   * 指示：治療条件情報
   */
  private String indCondInfo;

  /**
   * 指示：投与薬剤情報
   */
  private String indMediInfo;

  /**
   * 指示：医療材料情報
   */
  private String indEquipInfo;

  /**
   * 指示：装置設定情報
   */
  private String indDeviceSetInfo;

  // #9147 2024.02.15 add 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 start
  /**
   * 指示：DW
   */
  private BigDecimal indDw;
  // #9147 2024.02.15 add 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 end

  /**
   * 感染症有無
   */
  private int isInfect;

}
