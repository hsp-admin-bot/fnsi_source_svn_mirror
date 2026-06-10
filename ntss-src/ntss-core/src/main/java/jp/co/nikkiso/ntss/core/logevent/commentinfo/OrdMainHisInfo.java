package jp.co.nikkiso.ntss.core.logevent.commentinfo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class OrdMainHisInfo {
  private String ordNo;
  /**
   * 実績：版番号
   */
  private String rstEdition;

  /**
   * 最終更新者ID
   */
  private String upUserId;

  /**
   * 更新日時
   */
  private String upDate;
}
