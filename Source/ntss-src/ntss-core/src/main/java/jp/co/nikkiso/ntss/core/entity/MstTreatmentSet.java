package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstTreatmentSetEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 治療方法セットマスタ情報クラス
 */
@Entity(listener = MstTreatmentSetEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_treatment_set")
@Getter
@Setter
public class MstTreatmentSet extends BaseBlankEntity {
  /**
   * 治療方法セットコード
   */
  @Id
  private Integer treatmentSetCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 治療方法セット名
   */
  private String treatmentSetName;
  /**
   * 治療方法コード
   */
  private Integer treatmentCd;
  /**
   * 治療条件
   */
  private String indCondInfo;
  /**
   * 投与薬剤
   */
  private String indMediInfo;
  /**
   * 医療材料
   */
  private String indEquipInfo;
  /**
   * 指示コメント
   */
  private String indIndCommentInfo;
  /**
   * 装置設定
   */
  private String indDeviceSetInfo;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 登録日時
   */
  private Timestamp regDate;
  /**
   * 更新日時
   */
  /* add by chamaojia 2023-04-21 [8271] 直列化と逆直列化のフォーマットは一貫しています --start */
  @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
  /* add by chamaojia 2023-04-21 [8271] 直列化と逆直列化のフォーマットは一貫しています --end */
  private Timestamp upDate;
}
