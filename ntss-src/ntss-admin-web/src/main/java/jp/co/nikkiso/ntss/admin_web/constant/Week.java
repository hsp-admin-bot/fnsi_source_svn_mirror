package jp.co.nikkiso.ntss.admin_web.constant;

import lombok.Getter;

import java.util.Arrays;
import java.util.Optional;

/**
 * 曜日のenumクラス.
 */
@Getter
public enum Week {

  MONDAY((short)1, "月"),
  TUESDAY((short)2, "火"),
  WEDNESDAY((short)3, "水"),
  THURSDAY((short)4, "木"),
  FRIDAY((short)5, "金"),
  SATURDAY((short)6, "土"),
  SUNDAY((short)7, "日");

  /**
   * コード.
   */
  private Short cd;

  /**
   * テキスト.
   */
  private String text;

  /**
   * コンストラクタ.
   *
   * @param cd コード
   * @param text テキスト
   */
  Week(Short cd, String text) {
    this.cd = cd;
    this.text = text;
  }

  /**
   * コードに該当する曜日を取得する.
   *
   * @param cd コード
   * @return 曜日
   */
  public static Optional<Week> valueOf(Short cd) {
    // コードに一致するenumを探す
    return Arrays.stream(values()).filter(e -> cd.equals(e.getCd())).findAny();
  }
}
