package jp.co.nikkiso.ntss.admin_web.request.statusList;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Data
@Getter
@Setter
public class CheckAfterWeightRequest {
  /**
   * 治療番号
   */
  private Long ordNo;
  /**
   * 投薬未実施を確認済みにするフラグ
   */
  private boolean doCompleteMedi;
  /**
   * 実施者の利用者ID
   */
  private Long userId;
  // #10518 2024.05.23 add 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 start
  /**
   * 治療対象患者ID
   */
  private Long patId;
  // #10518 2024.05.23 add 患者指定で「実績確定・削除時装置レポート画像更新」通知を行う TDC片口 end

  // #10338 2024.03.26 add 外部連携用パラメータ追加 TDC片口 start
  /**
   * 外部連携用パラメータ
   */
  private List<JournalParameter> journal;

  @Data
  @Getter
  @Setter
  public static class JournalParameter{
    private String opeCd;
    private Long patId;
    private String hospPatId;
    private String crud;
    private Long userId;
    private String baseDate;
  }
  // #10338 2024.03.26 add 外部連携用パラメータ追加 TDC片口 end
}
