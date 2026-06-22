package jp.co.nikkiso.ntss.core.dto.MstListCompose.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MstListComposeKeyMapping {

  /**
   * 結果データに設定するキー名称を生成する。
   * 例：key_type / key_class
   */
  private String keyName;

  /**
   * 値の取得元
   *
   * ・テーブルのカラム名：class_cd
   * ・固定値：literal:-1
   * ・統合元識別子：sourceTag
   */
  private String valueFrom;
}
