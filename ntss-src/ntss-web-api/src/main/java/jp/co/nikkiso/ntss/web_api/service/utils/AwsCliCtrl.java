package jp.co.nikkiso.ntss.web_api.service.utils;

import java.io.InputStream;
import java.io.PrintStream;

import java.util.concurrent.TimeUnit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.service.LogService;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end


/**
 * AWS CLIでサービス操作を行うクラス
 */
public class AwsCliCtrl {
  /**
   * Logger.
   */
  private final Logger logger = LoggerFactory.getLogger(getClass());

  /**
   * S3へファイルアップロード/S3からファイルダウンロード
   *
   * @param from S3へアップロードするファイルの格納先のパス(EC2内パス) / S3からファイルをダウンロードするファイルの格納先のパス(S3のパス)
   * @param to S3へのアップロード先のパス(S3のパス) / S3からダウンロードしたファイルの格納先のパス(EC2内パス)
   * @param processTimeout プロセス処理の最大待ち時間
   * @return 0：成功、0以外：失敗
   */
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
  //public static int S3IO(String from, String to, int processTimeout) {
  public static int S3IO(String from, String to, int processTimeout, LogService logService) {
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    int iRet = -1;
    try {

      // コマンド実行
      // ・AWS CLIのインストールが必要(EC2(AmazonLinux)は既存でインストール済み)
      //  - EC2上で実施する場合は、ロールおよびポリシーの権限付与が必要
      //  - ローカル上で実施する場合は、認証キーの設定が必要(コマンド「aws configure」で確認および設定)

      // コマンド作成
      String awsCommand = "aws";
      //String awsCommand = "C:\\Program Files\\Amazon\\AWSCLI\\aws"; // デバッグ実行時はこっちにしないと動かない場合がある(環境変数を設定していても)
      String[] command = { awsCommand, "s3", "--region", "ap-northeast-1", "cp", from, to };


      // プロセス開始
      Runtime runtime = Runtime.getRuntime();
      Process process = runtime.exec(command);

      // 標準出力・エラーストリーム読み取り処理
      //  外部ﾌﾟﾛｾｽ実行時、出力ストリームやエラーストリームへ出力を行っているが、
      //  上記ストリームのバッファサイズには上限があり、それを使い果たすと待ち状態と
      //  なってしまう。(今回はwaitFor()でフリーズ)
      ReadStream error = new ReadStream(process.getErrorStream(), System.err, false);
      ReadStream output = new ReadStream(process.getInputStream(), System.out, false);
      error.start();
      output.start();

      // プロセスが終了するまで待機
      process.waitFor(processTimeout, TimeUnit.SECONDS);

      // プロセスのexit値を取得
      iRet = process.exitValue();
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[ntss-web-api]AWSCLI): ファイルアップロード/ダウンロード プロセス実行結果:" + iRet);
      logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      // スレッド終了まで待機
      error.join();
      output.join();

      // 終了処理作業
      process.getInputStream().close();
      process.getErrorStream().close();
      process.getOutputStream().close();
      process.destroy();
    } catch (Exception ex) {
      // 例外
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    }

    return iRet;
  }

  /**
   * S3のファイルを削除
   *
   * @param deleteFilePath 削除対象ファイルパス(ファイル名も含む)
   * @param waitTimeout プロセス処理の最大待ち時間
   * @return 0：成功、0以外：失敗
   */
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
  //public static int S3Delete(String deleteFilePath, int processTimeout) {
  public static int S3Delete(String deleteFilePath, int processTimeout, LogService logService) {
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    int iRet = -1;
    try {
      // コマンド作成
      String awsCommand = "aws";
      //String awsCommand = "C:\\Program Files\\Amazon\\AWSCLI\\aws"; // デバッグ実行時はこっちにしないと動かない場合がある(環境変数を設定していても)
      String[] command = { awsCommand, "s3", "--region", "ap-northeast-1", "rm", deleteFilePath };

      // プロセス開始
      Runtime runtime = Runtime.getRuntime();
      Process process = runtime.exec(command);

      // 標準出力・エラーストリーム読み取り処理
      //  外部ﾌﾟﾛｾｽ実行時、出力ストリームやエラーストリームへ出力を行っているが、
      //  上記ストリームのバッファサイズには上限があり、それを使い果たすと待ち状態と
      //  なってしまう。(今回はwaitFor()でフリーズ)
      ReadStream error = new ReadStream(process.getErrorStream(), System.err, false);
      ReadStream output = new ReadStream(process.getInputStream(), System.out, false);
      error.start();
      output.start();

      // プロセスが終了するまで待機
      process.waitFor(processTimeout, TimeUnit.SECONDS);

      // プロセスのexit値を取得
      iRet = process.exitValue();
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[ntss-web-api]AWSCLI): ファイル削除 プロセス実行結果:" + iRet);
      logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      // スレッド終了まで待機
      error.join();
      output.join();

      // 終了処理作業
      process.getInputStream().close();
      process.getErrorStream().close();
      process.getOutputStream().close();
      process.destroy();
    } catch (Exception ex) {
      // 例外
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    }

    return iRet;
  }
}

/**
 * 標準出力・エラーストリーム読み取り用スレッドクラス
 *
 */
class ReadStream extends Thread {
  InputStream is;
  PrintStream ps;
  boolean isLog;
  ReadStream(InputStream is, PrintStream ps, boolean isLog) {
    this.is = is;
    this.ps = ps;
    this.isLog = isLog;
  }

  public void run() {
    try {
      int c;
      while (-1 != (c = is.read())) {
        if (true == isLog) {
          ps.print((char)c);
        }
      }
    }
    catch (Exception ex) {
    }
  }
}
