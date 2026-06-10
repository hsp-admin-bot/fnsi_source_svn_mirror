package jp.co.nikkiso.ntss.admin_web.response.combo;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * コンボボックスのアイテム1件を表すクラス.
 */
@Getter
@AllArgsConstructor
public class Combo {

  /**
   * コンボに表示するテキスト.
   */
  private String text;

  /**
   * コンボのvalue値.
   */
  private Long cd;

}
