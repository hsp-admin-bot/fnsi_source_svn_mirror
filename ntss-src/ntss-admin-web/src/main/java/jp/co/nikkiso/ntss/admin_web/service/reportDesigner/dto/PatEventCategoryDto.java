package jp.co.nikkiso.ntss.admin_web.service.reportDesigner.dto;

/**
 * 帳票デザイナ、患者イベントカテゴリのフィルター取得用構造体
 *
 */
public class PatEventCategoryDto {

  /**
   * カテゴリコード
   */
  public Long categoryCd;

  /**
   * カテゴリ名称
   */
  public String categoryName;

  /**
   * サブカテゴリコード
   */
  public Long subCategoryCd;

  /**
   * サブカテゴリ名称
   */
  public String subCategoryName;

}
