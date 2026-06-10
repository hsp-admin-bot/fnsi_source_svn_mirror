package jp.co.nikkiso.ntss.admin_web.response.masterMaintenance;

import lombok.AllArgsConstructor;

/**
 * マスタ一覧のマスタ1件を表すクラス.
 */
@AllArgsConstructor
public class MasterInfo {

  /**
   * マスタ物理名称.
   */
  public String masterPhysicalName;

  /**
   * マスタ名称.
   */
  public String masterName;

  /**
   * マスタ編集画面の起動方法.<br>
   * <li>1：モード1
   * <li>2：モード2
   */
  public String mode;

  /**
   * マスタ編集画面の権限.<br>
   * <li>1：全ユーザ
   * <li>2：管理者のみ
   * <li>3：日機装社員のみ
   * <li>4：日機装社員・管理者のみ
   */
  public String editLevel;

  /**
   * 表示順.
   */
  public Integer dispOrder;

  /**
   * システム利用設定表示
   */
  public String systemUseDisp;

}
