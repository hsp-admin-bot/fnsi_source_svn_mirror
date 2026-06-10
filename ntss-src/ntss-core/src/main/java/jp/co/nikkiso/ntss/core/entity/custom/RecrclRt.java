package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * 再循環率測定
 */
@Data
public class RecrclRt {
  /**
   * 有効値,登録時の最新値の番号
   */
  // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
  // public String valid_no;
  public int valid_no;
  // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
  @JsonProperty("1")
  public RecrclRtElement _1;
  @JsonProperty("2")
  public RecrclRtElement _2;
  @JsonProperty("3")
  public RecrclRtElement _3;
  @JsonProperty("4")
  public RecrclRtElement _4;
  @JsonProperty("5")
  public RecrclRtElement _5;
}
