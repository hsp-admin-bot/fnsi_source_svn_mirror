package web.entity;

import java.util.List;
// add #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 start
/**
 * ord_,material_save要求エンティティ
 */
public class OrdMaterialSaveRequest {
  /**
   * 処理データのリスト
   */
  public List<Long> ordMainCds;
  /**
   * 実績または予約のフラグ
   * 実績:TRUE
   * 予約:FALSE
   */
  public boolean indRstFlag;
  /**
   * 実績同時更新予約
   */
  public boolean  rstUpdFlag;

  // add #10843 djy start
  /**
   * 差分フラグ
   * 差分:TRUE
   * 初回:FALSE
   */
  public boolean diffFlag;
  // add #10843 djy end

}
// add #10067 ord_material_saveのコンバートが正しくない 20240522　孟堅 end