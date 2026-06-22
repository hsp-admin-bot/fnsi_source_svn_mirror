package jp.co.nikkiso.ntss.admin_web.response;

import java.util.List;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 装置記録用データのResponse.
 */
@Getter
@AllArgsConstructor
public class MachineRecordResponse {

  @Getter
  @AllArgsConstructor
  @JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
  public static class MachineRecord {
    /**
     * 装置記録コード.
     */
    private String code;
    /**
     * 装置記録メッセージ.
     */
    private String message;
    /**
     * 推奨項目
     */
    private String isDefault;
    /**
     * ログ分類
     */
    private String logClass;
    /**
     * 対象機種
     */
    private String targetModel;
  }

  private List<MachineRecord> machineRecords;
}
