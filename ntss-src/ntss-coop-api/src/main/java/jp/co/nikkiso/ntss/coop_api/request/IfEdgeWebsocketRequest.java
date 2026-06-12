package jp.co.nikkiso.ntss.coop_api.request;

import org.springframework.util.StringUtils;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.ExeType;
import lombok.Data;

/**
 * 連携エッジwebsocket通信リクエスト
 *
 */
@Data
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class IfEdgeWebsocketRequest {
  /** 施設コード */
  private String facilityCd;

  // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
  /** シリアル番号 */
  private String serialNo;
  // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end

  /** 指示種別 */
  private String type;

  /** コマンド */
  private String command;

  /** サーバステータス */
  private String dirPath;

  /**
   * パラメータが正しいか検証する。
   *
   * @return 正しい場合はtrue、不正な場合はfalse
   */
  public boolean validate() {

    // 施設コード必須
    if (StringUtils.isEmpty(facilityCd)) {
      return false;
    }

    // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
    // シリアル番号必須
//    if (StringUtils.isEmpty(serialNo)) {
//      return false;
//    }
    // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start

    // 指示種別必須
    if (StringUtils.isEmpty(type)) {
      return false;
    }

    // 指示種別がfileだったらパス形式チェック
    if (ExeType.FILE.getType().equals(type)) {
      if (StringUtils.isEmpty(dirPath)
          || dirPath.startsWith("..")) {
        return false;
      }
    }

    return true;
  }
}
