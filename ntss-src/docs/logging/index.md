## ログの出力先を設定する方法

### アプリの設定ファイルにログ出力先項目を追加する

1. 各環境の設定ファイル（`yml`）に以下内容を設定してください。

   |No|キー|説明|
   |:--:|:---|:---|
   |1|ntss.logging.appender.file-name|ログファイル名（絶対パス）|
   |2|ntss.logging.rolling.file-name-pattern|ログローテーションファイル名（絶対パス）|
   |3|ntss.logging.rolling.max-history|最大履歴日数|

1. 設定例
   1. 施設別にログ出力する場合
      ```yml
       ntss:
         logging:
           appender:
             file-name: /tmp/ntss-admin-web/log/{0}/{0}.log
           rolling:
             file-name-pattern:  /tmp/ntss-admin-web/log/{0}/{0}_%d'{'yyyyMMdd'}'.log
             max-history: 14
      ```
      `{0}` ... 施設コードに置換されます。

   1. １ファイルにログを出力する場合
      ```yml
       ntss:
         logging:
           appender:
             file-name: /tmp/ntss-admin-web/log/event.log
           rolling:
             file-name-pattern:  /tmp/ntss-admin-web/log/event_%d'{'yyyyMMdd'}'.log
             max-history: 14
      ```

1. 実装例
   1. 共通実装
      ```java
         @Autowired
         private EventLoggerFactory loggerFactory;
      ```

   1. 施設別にログ出力する場合
      ```java
       final EventLogMessage eventLogMessage = new EventLogMessage(...);
       final EventLogger logger = loggerFactory.getLogger(facilityCd);
       logger.info(eventLogMessage);
      ```
      
   1. １ファイルにログを出力する場合
      ```java
       final EventLogMessage eventLogMessage = new EventLogMessage(...);
       final EventLogger logger = loggerFactory.getLogger();
       logger.info(eventLogMessage);
      ```
