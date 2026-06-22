package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 通信サーバ用患者情報関連クラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvPatRelated extends BaseEntity {

  @Id
  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  /**
   * 透析回数
   */
  private int dialysisCount;

  /**
   * 治療進捗状態 (pat_main)
   */
  private String acceptanceStatusInfo;

  /**
   * 共通診療情報 (pat_main)
   */
  private String medicalCareInfo;

}