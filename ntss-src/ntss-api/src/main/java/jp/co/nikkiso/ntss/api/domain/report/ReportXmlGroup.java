package jp.co.nikkiso.ntss.api.domain.report;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

/**
 * 帳票定義XMLのgroupタグを表すクラス.
 */
@Getter
@AllArgsConstructor
public class ReportXmlGroup {

  /**
   * 改ページするかどうか：改ページしない
   */
  public static final Integer IS_NEW_PAGE_NO = 0;

  /**
   * 改ページするかどうか：改ページする
   */
  public static final Integer IS_NEW_PAGE_YES = 1;

  /**
   * id属性.
   */
  private final String id;

  /**
   * repeatMax属性.
   */
  private final Integer repeatMax;

  /**
   * isNewPage属性.
   */
  private final Integer isNewPage;

  /**
   * filterType属性.
   */
  private final String filterType;

  /**
   * filter要素のリスト.
   */
  private final List<ReportXmlFilter> reportXmlFilters;

}
