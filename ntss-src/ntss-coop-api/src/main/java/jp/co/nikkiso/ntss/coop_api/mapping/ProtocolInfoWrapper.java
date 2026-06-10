package jp.co.nikkiso.ntss.coop_api.mapping;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonInclude.Include;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;
import lombok.NoArgsConstructor;


/**
 * 配信プロトコルWrapper
 * mst_coop_distribute.distribute_settingからマッピングされる配信プロトコル情報になる
 * 当該カラムでの配信プロトコル設定は「{"protocolInfo":~~」から始まる構造体を持つJSONのため {@link ProtocolInfo} をラップしている
 */
@NoArgsConstructor
@Data
public class ProtocolInfoWrapper {
  /** {@link ProtocolInfo} */
  @JsonProperty("protocolInfo")
  private ProtocolInfo protocolInfo;

  @NoArgsConstructor
  @JsonInclude(Include.NON_NULL)
  @Data
  public static class ProtocolInfo {
    /** 配信プロトコル("file", "socket", "ftp", "soap") */
    @JsonProperty("protocol")
    private String protocol;
    /** 配信先 */
    @JsonProperty("address")
    private String address;
    /** コピー時にリネームしたい場合の拡張子規則 */
    @JsonProperty("renameWhenCopying")
    private String renameWhenCopying;
    /** ダミーファイルのコピー権限 */
    @JsonProperty("dummy")
    private String dummy;
    /** 削除権限 */
    @JsonProperty("delete")
    private String delete;
    /** 置換処理 */
    @JsonProperty("replace")
    private String replace;
    /** ソケット種別("normal", "standard") */
    @JsonProperty("socket-type")
    private String socketType;
    /** 配信先ホスト名 */
    @JsonProperty("host")
    private String host;
    /** 配信先ポート */
    @JsonProperty("port")
    private String port;
    /** 認証ユーザ */
    @JsonProperty("user")
    private String user;
    /** 認証パスワード */
    @JsonProperty("password")
    private String password;
    /** リトライ回数 */
    @JsonProperty("retryMax")
    private String retryMax;
    /** タイムアウト値 */
    @JsonProperty("timeout")
    private String timeOut;
    /** 連携種別値 */
    @JsonProperty("sendType")
    private String sendType;
// add 2021-07-19 #5429:患者番号の前ゼロの扱いについて 孫 start
    /** 表示用患者IDの最大長さ */
    @JsonProperty("hospPatIdLen")
    private String hospPatIdLen;
// add 2021-07-19 #5429:患者番号の前ゼロの扱いについて 孫 end
// add 2022-03-21 #7104:rep_dial連携で送信するFTPフォルダ名 孫 start
    /** パーミッション変更 */
    @JsonProperty("permissionChange")
    private String permissionChange;
// add 2022-03-21 #7104:rep_dial連携で送信するFTPフォルダ名 孫 end
// add 2022-11-26 bug #7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 start
    /** 再接続回数 */
    @JsonProperty("retryTime")
    private String retryTime;
    /** 再接続待機時間(秒) */
    @JsonProperty("retryInterval")
    private String retryInterval;
// add 2022-11-26 bug #7710 【富士通指摘事項】IFエッジでエラー受信時、タイムアウト時の挙動について 孫 end
    /** ファイルの区切り文字 */
    @JsonProperty("fileSplitDelimiterFormat")
    private String fileSplitDelimiterFormat;
    /** ファイル名の囲み文字 */
    @JsonProperty("fileNameDelimiter")
    private String fileNameDelimiter;
  }
}
