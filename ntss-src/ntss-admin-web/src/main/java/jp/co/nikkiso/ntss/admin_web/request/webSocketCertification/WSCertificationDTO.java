/**
 *
 */
package jp.co.nikkiso.ntss.admin_web.request.webSocketCertification;

import lombok.Data;

/**
 * WebSocket認証キー作成依頼用
 * @author ntss
 *
 */
@Data
public class WSCertificationDTO {
  /**
   * 施設コード
   */
  public String facilityCd;
}
