package jp.co.nikkiso.ntss.admin_web.response.mstDialyzer;

import lombok.Getter;
import lombok.Setter;


/**
 * ダイアライザーマスターを表すクラス.
 */
@Getter
@Setter
public class DialyzerSharingInfoResponse {

  /**
   * ダイヤライザー名.
   */
  public String dialyzerName;

  /**
   * タブーアレルギーかどうか.
   */
  public Boolean isTabooAllergy;

  /**
   * プレフィックス.
   */
  public String prefix;

  /**
   * 使用開始日
   */
  private String useStartDate;

  /**
   * 使用終了日
   */
  private String useEndDate;

}
