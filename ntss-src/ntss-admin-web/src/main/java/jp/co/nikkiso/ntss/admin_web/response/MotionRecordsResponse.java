package jp.co.nikkiso.ntss.admin_web.response;

import java.util.Collections;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

import jp.co.nikkiso.ntss.core.entity.custom.MotionRecord;
import lombok.AllArgsConstructor;

/**
 * 装置動作記録のResponse.
 */
@AllArgsConstructor
public class MotionRecordsResponse {

  /**
   * 基準日(yyyyMMdd形式).
   */
  @JsonProperty("baseDate")
  public String baseDate;

  /**
   * 装置動作記録のリスト.
   */
  @JsonProperty("motionRecords")
  public List<MotionRecord> motionRecords;

  /**
   * データ収集可否.
   */
  @JsonProperty("isGatheringOk")
  public boolean isGatheringOk;

  /**
   * 基準日と空の装置動作記録のリストを返却するコンストラクタ.
   * 指定期間内のデータ0件時のレスポンスに使用
   */
  public MotionRecordsResponse(String baseDate) {
    this.baseDate = baseDate;
    this.motionRecords = Collections.emptyList();
  }

  /**
   * 空の装置動作記録のリストを返却するコンストラクタ.
   * これ以上データが存在しない場合のレスポンスに使用
   */
  public MotionRecordsResponse() {
    this.baseDate = "";
    this.motionRecords = Collections.emptyList();
  }

  /**
   * 装置動作記録のリストと空の基準日を返却するコンストラクタ.
   * 期間指定で検索された場合のレスポンスに使用
   */
  public MotionRecordsResponse(List<MotionRecord> motionRecords) {
    this.baseDate = "";
    this.motionRecords = motionRecords;
  }

}
