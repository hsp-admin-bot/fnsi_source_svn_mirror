package jp.co.nikkiso.ntss.core.dto.indSchedule;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;


@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdNoAndConnectedTableKeyData {
  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * オーダ番号
   */
  private Long ordNo;

  // add #11716 曜日パターン変更の不正 関 start
  /**
   * 治療日
   */
  private String treatDate;
  // add #11716 曜日パターン変更の不正 関 end

  /**
   * Key
   */
  @Column(name = "key")
  private Long key;

  /**
   * data
   */
  @Column(name = "data")
  private Object data;
}
