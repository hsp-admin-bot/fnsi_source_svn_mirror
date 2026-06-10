package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 緊急発報マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_m_notice")
@Getter
@Setter
public class MstMNotice extends BaseEntity  {

  /**
   * コンストラクタ
   * emailAddress, emailNameは空文字で設定する
   */
  public MstMNotice() {
    this.facilityCd = null;
    this.machineRecordCd = null;
    this.machineRecordMessage = null;
    this.emailAddress = "";
    this.emailName = "";
  }
  
  /**
   * 施設コード.
   */
  private String facilityCd;
  
  /**
   * 装置記録コード.
   */
  private String machineRecordCd;
  
  /**
   * 装置記録メッセージ.
   */
  private String machineRecordMessage;
    
  /**
   * メールアドレス.
   */
  private String emailAddress;
  
  /**
   * 宛先名称.
   */
  private String emailName;

}
