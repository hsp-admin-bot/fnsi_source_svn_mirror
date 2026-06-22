package jp.co.nikkiso.ntss.admin_web.request.userSettings;

import java.util.List;

import lombok.Data;

/**
 * ユーザー設定のメニューバー表示設定APIのRequestクラス.
 */
@Data
public class AlterMenuBarRequest {

  /**
   * ユーザーID.
   */
  private Long userId;

  /**
   * メニューバー表示フラグ.
   */
  private Integer isDispMenu;

  /**
   * 使用機能コードリスト.
   */
  private List<String> useFunctions;

  /**
   * 初期表示機能コード.
   */
  private String initialFunction;

}
