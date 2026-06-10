package jp.co.nikkiso.ntss.admin_web.request.userSettings;

import java.util.List;

import lombok.Data;

/**
 * ユーザー設定のメニューバー表示設定APIのRequestクラス.
 */
@Data
public class AlterUseAuthFunctionsRequest {

  /**
   * ユーザーID.
   */
  private Long userId;

  /**
   * 使用可能機能コードリスト.
   */
  private List<String> useAuthFunctions;

  /**
   * 初期表示機能コード.
   */
  private String initialFunction;

  /**
   * 職種コード.
   */
  private String jobCd;

  /**
   * サインアウトフラグ(権限変更時に対象利用者をサインアウトさせる).
   */
  private Boolean signoutFlg;

}
