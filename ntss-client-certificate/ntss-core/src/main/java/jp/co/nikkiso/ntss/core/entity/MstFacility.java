package jp.co.nikkiso.ntss.core.entity;


import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * 施設マスタのEntity.
 */
@Entity(naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_facility")
@Getter
@Setter
public class MstFacility {
  /**
   * 施設コード.
   */
  private String facilityCd;
  
  /**
   * 施設名.
   */
  private String facilityName;
  
  /**
   * 都道府県コード.
   */
  private String prefecturesCd;
  
  /**
   * 部署符号.
   */
  private String departmentCd;
  
  /**
   * 緊急発報メールテンプレート.
   */
  private String mNoticeMailTemplate;
  
  /**
   * 自動データ収集開始時刻.
   */
  private String autoGatheringStartTime;
  
  /**
   * 死活監視間隔.
   */
  private Integer aliveMoniInterval;
    
  /**
   * 登録日時.
   */
  private Timestamp regDate;
  
  /**
   * 更新日時.
   */
  private Timestamp upDate;
  
  /**
   * 施設カナ名.
   */
  private String facilityNameKana;
  
  /**
   * 認証キー.
   */
  private String certificationKey;
  
  /**
   * 使用可能機能.
   */
  private String useFunction;
  
  /**
   * 拡張設定
   */
  private String advancedSettings;
}

