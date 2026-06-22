package jp.co.nikkiso.ntss.admin_web.response.patIndApprove;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.util.List;

@Data
public class PatIndApproveDto {

  /**
   * カテゴリ名
   */
  private String component;

  /**
   * サブカテゴリ番号
   */
  private Integer subCategoryNo;

  /**
   * サブカテゴリアイテム
   */
  private List<ItemInfo> subCategoryItem;

  /**
   * サブカテゴリ名称
   */
  private String subCategoryName;

  @JsonInclude(JsonInclude.Include.NON_NULL)
  private ItemInfo.Item itemInfo;
}
