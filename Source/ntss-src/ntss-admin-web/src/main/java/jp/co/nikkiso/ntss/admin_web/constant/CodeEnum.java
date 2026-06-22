package jp.co.nikkiso.ntss.admin_web.constant;

import java.util.Arrays;

/**
 * コード定義用のEnumのインターフェース.
 */
public interface CodeEnum<E extends Enum<E>> {

  String getCode();

  /**
   * コード値が同一かどうかをチェックする.
   * @param code コード値
   * @return チェック結果
   */
  default boolean equalsByCode(String code) {
    return getCode().equals(code);
  }

  /**
   * 指定されたCodeEnumに、指定されたコード値を持つ列挙子が存在するかチェックする.
   *
   * @param clazz CodeEnum
   * @param code 指定されたコード値
   * @param <E> CodeEnumの型パラメータ
   * @return チェック結果
   */
  static <E extends Enum<E>> boolean hasCode(Class<? extends CodeEnum<E>> clazz, String code) {
    return Arrays.stream(clazz.getEnumConstants())
      .anyMatch(e -> e.equalsByCode(code));
  }


}
