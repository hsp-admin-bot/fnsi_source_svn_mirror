package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;

/**
 * 個人設定タブ定義の「タブ表示名」「タブコンテンツID」のペア
 */
@Entity(immutable = true, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_personal_tab_define")
@Getter
public class TabDisplayNameAndContentsId extends BaseBlankEntity {
  /**
   * タブ定義コード　タブ定義コード
   */
  private final Integer tabDefineCd;

  /**
   * タブ表示名
   */
  private final String displayName;

  /**
   * タブコンテンツID
   */
  private final String contentsId;

  /**
   * モード（1.共通画面を使用 2.個別画面を使用）
   */
  private final String mode;

  /**
   * コンストラクタ
   * @param tabDefineCd タブ定義コード
   * @param displayName タブ表示名
   * @param contentsId タブコンテンツID
   * @param mode モード
   */
  public TabDisplayNameAndContentsId(Integer tabDefineCd, String displayName, String contentsId, String mode) {
    this.tabDefineCd = tabDefineCd;
    this.displayName = displayName;
    this.contentsId = contentsId;
    this.mode = mode;
  }
}
