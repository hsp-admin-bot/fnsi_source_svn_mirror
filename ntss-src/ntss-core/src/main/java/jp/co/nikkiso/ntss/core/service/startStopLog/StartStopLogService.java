package jp.co.nikkiso.ntss.core.service.startStopLog;

import jp.co.nikkiso.ntss.core.logevent.LogEvent;

/**
 * 起動停止ログサービスインターフェース
 *
 * OS、Tomcat、アプリケーション（WAR/JAR）の起動・停止イベントを
 * MongoDBに記録するためのサービスインターフェース
 */
public interface StartStopLogService {

  /**
   * OS起動ログを記録する
   * Linuxコマンド「who -b」を使用してOS起動時刻を取得し、ログイベントを作成する
   */
  void osBootLog();

  /**
   * OSシャットダウンログを記録する
   * Linuxコマンド「last -F -x shutdown」を使用して最終シャットダウン時刻を取得し、ログイベントを作成する
   */
  void osDownLog();

  /**
   * OSイベントログをMongoDBに保存する
   *
   * @param logEvent 保存するログイベント
   */
  void saveOsEventLog(LogEvent logEvent);

  /**
   * Tomcat起動ログを記録する
   * JVMランタイムから起動時刻を取得し、Tomcat起動イベントを作成する
   */
  void tomcatBootLog();

  /**
   * Tomcat停止ログを記録する
   * Tomcat停止イベントを作成し、MongoDBに記録する
   */
  void tomcatDownLog();

  /**
   * JARアプリケーション起動ログを記録する
   * Spring Boot JARとして起動した場合のログを記録する
   */
  void jarBootLog();

  /**
   * JARアプリケーション停止ログを記録する
   * Spring Boot JARアプリケーションの停止ログを記録する
   */
  void jarDownLog();

  /**
   * WARアプリケーション起動ログを記録する
   * 外部TomcatにデプロイされたWARとして起動した場合のログを記録する
   */
  void warBootLog();

  /**
   * WARアプリケーション停止ログを記録する
   * WARアプリケーションの停止ログを記録する
   */
  void warDownLog();

  /**
   * サーバーのIPアドレスを取得する
   *
   * @return サーバーのIPアドレス（ローカルホストまたはEC2プライベートIP）
   */
  String getServerIp();

  /**
   * サーバーのホスト名を取得する
   *
   * @return サーバーのホスト名
   */
  String getServerHostName();

}
