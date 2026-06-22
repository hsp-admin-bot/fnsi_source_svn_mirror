package jp.co.nikkiso.ntss.coop_api.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * If Edge Configulation
 *
 */
@Component
@ConfigurationProperties(prefix = "websocket.if-edge-mnt")
@Data
public class IfEdgeConfigulation {

  /** 連携エッジWebsocket受信パス */
  private String wsPath;

  /** 別サーバーへの通知APIを呼び出すためのhttp部分 */
  private String requestHTTP;

  /** 別サーバーへの通知APIを呼び出すためのURI */
  private String postMsgAPI;

  /** 送信対象ディレクトリパス */
  private String resourcePath;

  /** 連携エッジスリープ時間 */
  private Integer waitMills;

  /** 連携エッジスリープ実施回数 */
  private Integer waitcount;

  /** 連携エッジ実行コマンド保存ディレクトリ */
  private String commandSaveDir;

  /** コマンド設定ファイルディレクトリ */
  private String commandSettingDir;

  /** コマンド設定ファイル名 */
  private String commandSettingFile;
}
