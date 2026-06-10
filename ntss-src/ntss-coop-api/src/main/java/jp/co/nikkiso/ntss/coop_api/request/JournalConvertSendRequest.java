package jp.co.nikkiso.ntss.coop_api.request;

import org.springframework.util.StringUtils;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

import lombok.Data;

/**
 * 送信用ジャーナル変換リクエスト
 *
 */
@Data
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class JournalConvertSendRequest {

  /** 施設コード */
  private String facilityCd;
  //mod #8350 ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 2023-03-09 卓 start
  /** 次世代FutureNetオーダ番号 */
  private Long ordNo;
  /** 患者番号(システム) */
  private Long patId;
  /** 患者番号(電子カルテ連携システム用) */
  private String hospPatId;
  /** 電文種別 */
  private String coopCd;
  /** 操作者ID */
  private Long userId;
  //mod #8350 ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 2023-03-09 卓 end

  /**
   * パラメータが正しいか検証する。
   *
   * @return 正しい場合はtrue、不正な場合はfalse
   */
  public boolean validate() {
    return !StringUtils.isEmpty(facilityCd);
  }
}
