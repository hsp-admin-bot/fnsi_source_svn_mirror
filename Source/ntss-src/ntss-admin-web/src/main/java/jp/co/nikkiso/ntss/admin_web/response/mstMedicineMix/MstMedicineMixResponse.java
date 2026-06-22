package jp.co.nikkiso.ntss.admin_web.response.mstMedicineMix;

import lombok.Getter;
import lombok.Setter;

import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
/**
 * 調製薬剤マスタクラスのレスポンスクラス(使用期限判定に使用する日付含む)
 */
@Getter
@Setter
public class MstMedicineMixResponse extends MstMedicineMix {

  /**
   * 使用開始日(配下の薬剤の中で一番遅い開始日)
   */
  private String maxUseStartDate;
  /**
   * 使用終了日(配下の薬剤の中で一番早い終了日)
   */
  private String minUseEndDate;

}
