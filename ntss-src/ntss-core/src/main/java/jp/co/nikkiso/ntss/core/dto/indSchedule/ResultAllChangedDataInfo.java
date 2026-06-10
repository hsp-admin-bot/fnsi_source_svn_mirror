package jp.co.nikkiso.ntss.core.dto.indSchedule;

import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class ResultAllChangedDataInfo {
  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * テーブル名
   */
  private String tablePhysicalName;

  /**
   * 主Key
   */
  private List<Map<String, List<Object>>> key;
}
