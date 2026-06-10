package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * mst_facility_setting(施設設定マスタ)のエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_facility_setting")
@Getter
@Setter
public class MstFacilitySetting extends BaseBlankEntity {
  /**
   * 施設設定番号
   */
  private String facilitySettingNo;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 値
   */
  private String value;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;
}
