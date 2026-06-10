package jp.co.nikkiso.ntss.admin_web.response.masterMaintenance;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.ComboValue;
import lombok.AllArgsConstructor;

/**
 * 画面に表示するカラム情報1件を表すクラス.
 */
@AllArgsConstructor
public class MasterColumn {

  /**
   * 物理カラム名.
   */
  public String field;

  /**
   * 表示カラム名.
   */
  public String title;

  /**
   * 隠し項目属性.
   */
  public boolean hidden;

  /**
   * 固定列属性.
   */
  public boolean locked;

  /**
   * 書式.
   */
  public String format;

  /**
   * コンボデータ.
   */
  public List<ComboValue> values;

  /**
   * 編集定義.
   */
  public boolean editable;
  
  /**
   * カラムのデータ型.
   */
  public String dataType;

}
