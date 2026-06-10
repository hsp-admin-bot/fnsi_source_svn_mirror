package jp.co.nikkiso.ntss.core.dto.MstListCompose.response;

import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Map;

@Getter
@Setter
public class MstListComposeWrapper {

  /**
   * 列表 ID
   */
  private String id;

  /**
   * 列表名称
   */
  private String name;

  /**
   * 实际数据行
   *
   * 每一行：
   *  - 原始 mst 列
   *  - + key_xxx 索引字段
   */
  private List<Map<String, Object>> items;

}
