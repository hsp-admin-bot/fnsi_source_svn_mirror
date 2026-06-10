package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Date;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 機械検査定期スケジュールEntity
 */
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class CusMenteMainAddMore {
  /**
   * 機械番号
   */
  private Long machineNo;
  /**
   * 検査日
   */
  private Date menteDate;
  /**
   * 検査レイアウトコード
   */
  private Long menteLayoutCd;
  /**
   * 検査レイアウトグループコード
   */
  private Long menteLayoutGroupCd;
}
