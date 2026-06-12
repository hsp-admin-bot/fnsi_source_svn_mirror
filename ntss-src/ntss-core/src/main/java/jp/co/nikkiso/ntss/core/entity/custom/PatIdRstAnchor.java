package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 患者IDと実績開始日時アンカー（{@code ord_main.rst_start_date} 比較用）の組。
 * データリスト templateCd=5 の一括クエリパラメータ用。
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatIdRstAnchor {

  private Long patId;

  private Timestamp anchorTs;

  public PatIdRstAnchor() {
  }

  public PatIdRstAnchor(Long patId, Timestamp anchorTs) {
    this.patId = patId;
    this.anchorTs = anchorTs;
  }
}
