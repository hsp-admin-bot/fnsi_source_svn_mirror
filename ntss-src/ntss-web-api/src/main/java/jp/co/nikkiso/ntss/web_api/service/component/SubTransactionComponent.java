package jp.co.nikkiso.ntss.web_api.service.component;

// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.BACKUP_FILE_ENCODING_BY_UTF_8;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.DB_KIND_AUTH;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.DB_KIND_DEFAULT;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PATH_PARAM_DATE;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PATH_PARAM_DB_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PATH_PARAM_FACILITY_CD;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PATH_PARAM_TABLE_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_FNSI_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_REMS_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_BACKUP_END;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_BACKUP_START;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_BACKUP_PATH;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_DB_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_DB_CLASS;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_TABLE_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_ALIAS_COLUMN_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_TIME_COLUMN_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_FACILITY_HASH;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_USER_AUTHENTICATION;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_SELECTOR;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_SYS_SIGNIN_MANAGER;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_PAT_HASH;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_MACHINE;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TOPIC_BASE;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.CONNECT_URI_BASE;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.net.URI;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.MntClientConnect;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelManage;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstJob;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.SysDataSet;
import jp.co.nikkiso.ntss.core.entity.SysFunction;
import jp.co.nikkiso.ntss.core.entity.SysFunctionAdvanced;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.csv.QuoteMode;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.SelectOptions;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceUtils;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.FlagType;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.IsNkkFlg;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.SystemUseDisp;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.SystemUseSettings;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntClientConnectDao;
import jp.co.nikkiso.ntss.core.dao.MntFacilityCancelManageDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstDeviceEdgeDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstJobDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstPatHashDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.SysFunctionAdvancedDao;
import jp.co.nikkiso.ntss.core.dao.SysFunctionDao;
import jp.co.nikkiso.ntss.core.dao.SysSigninManagerDao;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.config.FacilityCancelConfig;
import jp.co.nikkiso.ntss.web_api.service.component.IndHistory;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.util.ClockWrapper;
import jp.co.nikkiso.ntss.web_api.util.ErrorMessageUtil;
import jp.co.nikkiso.ntss.web_api.util.FacilityCancelStatUtil;
import jp.co.nikkiso.ntss.web_api.util.JDBCUtil;
import lombok.Data;

/**
 * Serviceレイヤより下の細かいトランザクション制御を実行するためのコンポーネントクラス。
 */
@Component
public class SubTransactionComponent {

  // DAO
  /** 解約施設管理 */
  @Autowired
  private MntFacilityCancelManageDao mntFacilityCancelManageDao;

  /** 利用者マスタ(DB4) */
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  /** 利用者マスタ(DB5) */
  @Autowired
  private MstUserDao mstUserDao;

  /** 施設マスタハッシュ */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  /** 患者用施設マスタハッシュ */
  @Autowired
  private MstPatHashDao mstPatHashDao;

  /** 施設マスタ */
  @Autowired
  private MstFacilityDao mstFacilityDao;

  /** 職種マスタ */
  @Autowired
  private MstJobDao mstJobDao;

  /** 装置マスタ */
  @Autowired
  private MstMachineDao mstMachineDao;

  /** 装置マスタ */
  @Autowired
  private SysSigninManagerDao sysSigninManagerDao;

  /** 機能マスタ */
  @Autowired
  private SysFunctionDao sysFunctionDao;

  /** 拡張機能マスタ */
  @Autowired
  private SysFunctionAdvancedDao sysFunctionAdvancedDao;

  /** デバイスエッジマスタ */
  @Autowired
  private MstDeviceEdgeDao mstDeviceEdgeDao;

  /** 連携施設マスタ */
  @Autowired
  private MstCoopFacilityDao mstCoopFacilityDao;

  /** WebSocketクライアント接続状態 */
  @Autowired
  private MntClientConnectDao mntClientConnectDao;
  // JdbcTemplate
  /** DB4 */
  @Autowired
  private JdbcTemplate jdbcTemplateAuth;

  /** DB5 */
  @Autowired
  private JdbcTemplate jdbcTemplate;

  /** DB6 */
  @Autowired
  private JdbcTemplate jdbcTemplatePersonal;

  /** システム日付ラッパ */
  @Autowired
  private ClockWrapper clockWrapper;

  // 設定
  /** sys_system_define */
  @Autowired
  private FacilityCancelConfig config;

  // サービス
  /** ログサービス */
  @Autowired
  private LogService logService;

  /** 指示記録削除処理(MongoDB) */
  @Autowired
  private MongodbProcComponent mongodbProcComponent;

  /**
   * デバイスエッジ通知アプリのRestAPI呼び出し用クラス(body格納用).
   */
  @Data
  private static class SendMessageJson {
    public String targetId;
    public String message;
  };

  /** 連携IF解除リクエスト用 ntss-coop-apiのURL */
  @Value("${ntss.web-api.coop-api.url}")
  private String coopApi;

  /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
  @Value("${ntss.web-api.coop-api.header-name}")
  private String headerKey;
  @Value("${ntss.web-api.coop-api.header-value}")
  private String headerValue;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */

  // 施設解約登録

  /**
   * 施設解約を登録する。
   *
   * @param mfcm MntFacilityCancelManage
   * @return 登録件数
   */
  @Transactional(propagation = Propagation.NESTED)
  public Integer insert(MntFacilityCancelManage mfcm) {
    return mntFacilityCancelManageDao.insert(mfcm);
  }

  // 削除対象レコードバックアップ

  /**
   * 1テーブルのバックアップを作成する。
   *
   * @param facilityCd 施設コード
   * @param procClass 処理区分
   * @param stat 1テーブル分の統計情報
   * @param startTime 処理開始日時
   * @param criteriaTime 削除対象基準日時（システム時刻-処理対象期間）
   */
  @Transactional(propagation = Propagation.NESTED)
  public void backupTableRecord(String facilityCd, String procClass, Map<String, Object> stat, Long startTime, Long criteriaTime) {
    final String pathTemplate = config.getBackupPathTemplate(procClass);

    // add FNSI-改修内容#6014 周 start
    if(null == stat) {
      return;
    }
    // add FNSI-改修内容#6014 周 end
    Integer dbClass = (Integer) stat.get(STAT_KEY_DB_CLASS);
    // add FNSI-改修内容#6014 周 start
    if(!((dbClass >= SysDataSet.DB_CLASS_DB4) && (dbClass <= SysDataSet.DB_CLASS_MONGODB))) {
      return;
    }
    // add FNSI-改修内容#6014 周 end
    String dbName = (String) stat.get(STAT_KEY_DB_NAME);
    String tableName = (String) stat.get(STAT_KEY_TABLE_NAME);
    String aliasColumnName = (String) stat.get(STAT_KEY_ALIAS_COLUMN_NAME);
    String timeColumnName = (String) stat.get(STAT_KEY_TIME_COLUMN_NAME);

    String filePath = pathTemplate.replace(PATH_PARAM_DATE, getBackupDateTimeStr(startTime))
        .replace(PATH_PARAM_FACILITY_CD, facilityCd)
        .replace(PATH_PARAM_DB_NAME, dbName);

    if (StringUtils.isEmpty(aliasColumnName)) {
      filePath = filePath.replace(PATH_PARAM_TABLE_NAME, tableName);
    } else {
      filePath = filePath.replace(PATH_PARAM_TABLE_NAME, tableName + "_" + aliasColumnName);
    }

    // バックアップファイルと親ディレクトリを作成する。
    // （親ディレクトリは、既存の場合は再利用する。）
    File file = new File(filePath);
    file.getParentFile().mkdirs();

    try (FileOutputStream fos = new FileOutputStream(file);
        OutputStreamWriter osw = new OutputStreamWriter(fos, BACKUP_FILE_ENCODING_BY_UTF_8);
        BufferedWriter bw = new BufferedWriter(osw)) {

      // 統計情報にバックアップ開始日時を記録する。
      stat.put(STAT_KEY_BACKUP_START, clockWrapper.getCurrentTimeStr());

      // テーブルのバックアップを作成する。
      JdbcTemplate jdbc = JDBCUtil.getJdbcTemplate(dbClass, jdbcTemplateAuth, jdbcTemplate, jdbcTemplatePersonal);
      writeTableToFile(jdbc, facilityCd, tableName, aliasColumnName, timeColumnName, criteriaTime, bw);

      // 作成したパスを設定
      stat.put(STAT_KEY_BACKUP_PATH, filePath);

      // 統計情報にバックアップ終了日時を記録する。
      stat.put(STAT_KEY_BACKUP_END, clockWrapper.getCurrentTimeStr());
    } catch (IOException e) {
      // add FNSI-改修内容#6014 周 start
      //String msg = String.format("テーブルのバックアップ作成中にエラーが発生しました。 テーブル:[%s]", tableName);
      String msg = String.format("テーブルのバックアップ作成中にエラーが発生しました。 データベース:[%s], テーブル:[%s]", dbName, tableName);
      // add FNSI-改修内容#6014 周 end
      errorLog(facilityCd, msg, e);
      throw new NtssException(msg, e);
    }
  }

  /**
   * MongoDBの指示履歴テーブルのバックアップを作成する。
   *
   * @param facilityCd 施設コード
   * @param procClass 処理区分
   * @param statsNosql 統計情報(NoSQLDB)中の1エントリ
   * @param startTime 処理開始日時
   */
  public void backupTableNosqlRecord(String facilityCd, String procClass, Map<String, Object> statsNosql, Long startTime) {
    final String pathTemplate = config.getBackupPathTemplate(procClass);

    String dbName = "ntss";
    String tableName = (String) statsNosql.get(STAT_KEY_TABLE_NAME);

    String filePath = pathTemplate.replace(PATH_PARAM_DATE, getBackupDateTimeStr(startTime))
        .replace(PATH_PARAM_FACILITY_CD, facilityCd)
        .replace(PATH_PARAM_DB_NAME, dbName);

    filePath = filePath.replace(PATH_PARAM_TABLE_NAME, tableName);

    // バックアップファイルと親ディレクトリを作成する。
    // （親ディレクトリは、既存の場合は再利用する。）
    File file = new File(filePath);
    boolean isSuccess = file.getParentFile().mkdirs();

    try (FileOutputStream fos = new FileOutputStream(file);
        OutputStreamWriter osw = new OutputStreamWriter(fos, BACKUP_FILE_ENCODING_BY_UTF_8);
        BufferedWriter bw = new BufferedWriter(osw)) {

      // 統計情報にバックアップ開始日時を記録する。
      statsNosql.put(STAT_KEY_BACKUP_START, clockWrapper.getCurrentTimeStr());

      // テーブルのバックアップを作成する。
      writeTableNosqlToFile(facilityCd, bw);

      // 作成したパスを設定
      statsNosql.put(STAT_KEY_BACKUP_PATH, filePath);

      // 統計情報にバックアップ終了日時を記録する。
      statsNosql.put(STAT_KEY_BACKUP_END, clockWrapper.getCurrentTimeStr());
    } catch (IOException e) {
      String stackTraceMsg = jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString(e);
      String msg = String.format("MongoDBテーブルのバックアップ作成中にエラーが発生しました。 テーブル:[%s], mkdirsResult:[%s] , error:[%s]", tableName, isSuccess, stackTraceMsg );
      errorLog(facilityCd, msg, e);
      throw new NtssException(msg, e);
    }
  }

  /**
   * 1テーブルのレコードをファイルに書き出す。
   *
   * @param jdbc JdbcTemplate（DB4～DB6のいずれか）
   * @param facilityCd 施設コード
   * @param tableName テーブル名
   * @param aliasColumnName 施設コードの別名カラム
   * @param timeColumnName 日時比較対象のカラム名
   * @param criteriaTime 削除対象基準日時（システム時刻-処理対象期間）
   * @param bw BufferedWriter
   */
  private void writeTableToFile(JdbcTemplate jdbc, String facilityCd, String tableName,
      String aliasColumnName, String timeColumnName, Long criteriaTime, BufferedWriter bw) {

    // クエリ1回あたりのフェッチサイズを設定する。
    jdbc.setFetchSize(config.getBackupFetchSize());

    String timeCond = StringUtils.isEmpty(timeColumnName) ? "" : "AND " + timeColumnName + " < ?";

    // 施設コードカラムの設定
    String facilityCdColumn = StringUtils.isEmpty(aliasColumnName) ? "facility_cd" : aliasColumnName;
    // クエリ（単純なSELECT文）
    final String q = String.format("SELECT * FROM %s WHERE %s = ? %s", tableName, facilityCdColumn, timeCond);

    // Spring JdbcTemplateにはResultSetを取得するクエリが存在しない。
    // そのためJdbcTemplateからJDBC Connectionを取得し、直接JDBCを使用してクエリを発行する。

    // SpringからJDBCコネクションを取得する。
    Connection c = DataSourceUtils.getConnection(jdbc.getDataSource());

    try (PreparedStatement s = c.prepareStatement(q)) {
      // PreparedStatement#setString()はリソース宣言でないため、
      // try(...){...}構文のリソース宣言部に書けない。
      // 結果としてtry文を二重にする必要がある。
      s.setString(1, facilityCd);
      if (!StringUtils.isEmpty(timeColumnName)) {
        s.setTimestamp(2, new Timestamp(criteriaTime));
      }
      //add 10994 解約処理が停止する start
      s.setFetchSize(config.getBackupFetchSize());
      //add 10994 解約処理が停止する end
      // ResultSetでフェッチされるレコードをすべてファイルに出力する。
      // printRecords(rs)で出力するとXMLやバイナリが正しく出力されないためカラム単位に出力を行う
      // ダブルクォーテーションで囲って出力
      try (ResultSet rs = s.executeQuery();
          CSVPrinter printer = new CSVPrinter(bw, CSVFormat.EXCEL
              .withHeader(rs)
              .withQuoteMode(QuoteMode.ALL))) {
        while (rs.next()) {
          for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
            // カラムごとに文字列で出力

            if (!StringUtils.isEmpty(rs.getString(i))
                && "timestamp".equals(rs.getMetaData().getColumnTypeName(i))) {
              // Timestampの場合、フォーマット指定
              DateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
              printer.print(format.format(rs.getTimestamp(i)));
            } else {
              printer.print(rs.getString(i));
            }
          }
          // 改行
          printer.println();
        }
      }
    } catch (SQLException e) {
      String msg = "削除対象レコードのバックアップでDBエラーが発生しました。";
      errorLog(null, msg, e);
      throw new NtssException(msg, e);
    } catch (IOException e) {
      String msg = "削除対象レコードのバックアップでファイルシステムエラーが発生しました。";
      errorLog(null, msg, e);
      throw new NtssException(msg, e);
    } finally {
      if (c != null) {
        DataSourceUtils.releaseConnection(c, jdbc.getDataSource());
      }
    }
  }

  /**
   * MongoDBの指示履歴テーブルのレコードをファイルに書き出す。
   *
   * @param facilityCd 施設コード
   * @param bw BufferedWriter
   */
  private void writeTableNosqlToFile(String facilityCd, BufferedWriter bw) {
    try(CSVPrinter printer = new CSVPrinter(bw, CSVFormat.EXCEL
        .withHeader(
            "_id",
            "pat_id",
            "facility_cd",
            "ord_no",
            "log_date",
            "treatment_start_date",
            "treatment_end_date",
            "treatment_weekday",
            "treatment_method",
            "treatment_course",
            "sort_no",
            "log_target",
            "log_class",
            "log_content",
            "receiver_1",
            "receive_date1",
            "receiver_2",
            "receive_date2",
            "approver_1",
            "approval_date1",
            "approver_2",
            "approval_date2",
            "created_by",
            "updated_by",
            "created_user_id",
            "updated_user_id",
            "_class"
            )
        .withQuoteMode(QuoteMode.ALL))) {
      List<IndHistory> resultList = mongodbProcComponent.getBackupTarget(facilityCd);
      // add FNSI-改修内容#6013 周 start
      if(null == resultList || resultList.isEmpty()) {
        return;
      }
      // add FNSI-改修内容#6013 周 end
      for (IndHistory indHistObj : resultList) {
        // カラムごとに文字列で出力
        printer.print(indHistObj.get_id());
        printer.print(indHistObj.getPatId());
        printer.print(indHistObj.getFacilityCd());
        printer.print(indHistObj.getOrdNo());
        printer.print(indHistObj.getLogDate());
        printer.print(indHistObj.getTreatmentStartDate());
        printer.print(indHistObj.getTreatmentEndDate());
        printer.print(indHistObj.getTreatmentWeekday());
        printer.print(indHistObj.getTreatmentMethod());
        printer.print(indHistObj.getTreatmentCourse());
        printer.print(indHistObj.getSortNo());
        printer.print(indHistObj.getLogTarget());
        printer.print(indHistObj.getLogClass());
        printer.print(indHistObj.getLogContent());
        printer.print(indHistObj.getReceiver1());
        printer.print(indHistObj.getReceiveDate1());
        printer.print(indHistObj.getReceiver2());
        printer.print(indHistObj.getReceiveDate2());
        printer.print(indHistObj.getApprover1());
        printer.print(indHistObj.getApprovalDate1());
        printer.print(indHistObj.getApprover2());
        printer.print(indHistObj.getApprovalDate2());
        printer.print(indHistObj.getCreatedBy());
        printer.print(indHistObj.getUpdatedBy());
        printer.print(indHistObj.getCreatedUserId());
        printer.print(indHistObj.getUpdatedUserId());
        printer.print(indHistObj.getClass());
        // 改行
        printer.println();
      }
    } catch (IOException e) {
      String msg = "MongoDBの削除対象レコードのバックアップでファイルシステムエラーが発生しました。";
      errorLog(null, msg, e);
      throw new NtssException(msg, e);
    } catch (Exception e) {
      String msg = "MongoDBの削除対象レコードのバックアップでDBエラーが発生しました。";
      errorLog(null, msg, e);
      throw new NtssException(msg, e);
    }
  }

  /**
   * バックアップ開始日時を整形した文字列を取得する。
   * 整形フォーマットはsys_system_defineテーブルで設定された値を用いる。
   *
   * @param startTime バックアップ開始日時
   * @return システム時刻文字列
   */
  private String getBackupDateTimeStr(Long startTime) {
    String format = config.getBackupPathDateFormat();
    SimpleDateFormat sdf = new SimpleDateFormat(format);

    Date d = new Date(startTime);
    return sdf.format(d);
  }

  // 削除対象レコードバックアップ(mst_selector)

  /**
   * ReMSのみ解約、FNSiのみ解約指定時にmst_selector(選択肢マスタ)のバックアップを取得する
   *
   * @param facilityCd 施設コード
   * @param procClass 処理区分
   * @param startTime 処理開始日時
   * @param statsLIst 統計情報リスト
   * @param stats mst_selectorの統計情報
   */
  @Transactional(propagation = Propagation.NESTED)
  public void backupMstSelectorRecord(String facilityCd, String procClass, Long startTime, List<Map<String, Object>> statsList, Map<String, Object> stats) {
    final String pathTemplate = config.getBackupPathTemplate(procClass);

    String dbName = (String) stats.get(STAT_KEY_DB_NAME);
    String tableName = (String) stats.get(STAT_KEY_TABLE_NAME);

    String filePath = pathTemplate.replace(PATH_PARAM_DATE, getBackupDateTimeStr(startTime))
        .replace(PATH_PARAM_FACILITY_CD, facilityCd)
        .replace(PATH_PARAM_DB_NAME, dbName)
        .replace(PATH_PARAM_TABLE_NAME, tableName);

    // バックアップファイルと親ディレクトリを作成する。
    // （親ディレクトリは、既存の場合は再利用する。）
    File file = new File(filePath);
    file.getParentFile().mkdirs();

    try (FileOutputStream fos = new FileOutputStream(file);
        OutputStreamWriter osw = new OutputStreamWriter(fos, BACKUP_FILE_ENCODING_BY_UTF_8);
        BufferedWriter bw = new BufferedWriter(osw)) {

      // 統計情報にバックアップ開始日時を記録する。
      stats.put(STAT_KEY_BACKUP_START, clockWrapper.getCurrentTimeStr());

      String strTargetMstNm = statsList.stream().map(stat -> (String)stat.get(STAT_KEY_TABLE_NAME)).collect(Collectors.joining("','"));
      strTargetMstNm = "'" + strTargetMstNm + "'";
      // mst_selectorテーブルのバックアップを取得
      writeTableMstSelectorToFile(facilityCd, strTargetMstNm, bw);

      // 統計情報に作成したパスを設定
      stats.put(STAT_KEY_BACKUP_PATH, filePath);

      // 統計情報にバックアップ終了日時を記録する。
      stats.put(STAT_KEY_BACKUP_END, clockWrapper.getCurrentTimeStr());
    } catch (IOException e) {
      String msg = String.format("テーブルのバックアップ作成中にエラーが発生しました。 テーブル:[%s]", tableName);
      errorLog(facilityCd, msg, e);
      throw new NtssException(msg, e);
    }
  }

  /**
   * mst_selectorテーブルのレコードをファイルに書き出す。
   *
   * @param facilityCd 施設コード
   * @param lstTargetMstNm 対象のマスタ物理名称(","区切りで対象テーブル指定)
   * @param bw BufferedWriter
   */
  private void writeTableMstSelectorToFile(String facilityCd, String lstTargetMstNm, BufferedWriter bw) {
    JdbcTemplate jdbc = jdbcTemplate;

    // 条件部
    String conditions = "facility_cd = ?";
    conditions += " AND master_physical_name in (" + lstTargetMstNm + ")";

    // クエリ（単純なSELECT文）
    final String q = String.format("SELECT * FROM %s WHERE %s;", TABLE_NAME_MST_SELECTOR, conditions);

    // Spring JdbcTemplateにはResultSetを取得するクエリが存在しない。
    // そのためJdbcTemplateからJDBC Connectionを取得し、直接JDBCを使用してクエリを発行する。

    // SpringからJDBCコネクションを取得する。
    Connection c = DataSourceUtils.getConnection(jdbc.getDataSource());

    try (PreparedStatement s = c.prepareStatement(q)) {
      // PreparedStatement#setString()はリソース宣言でないため、
      // try(...){...}構文のリソース宣言部に書けない。
      // 結果としてtry文を二重にする必要がある。
      s.setString(1, facilityCd);

      // ResultSetでフェッチされるレコードをすべてファイルに出力する。
      // printRecords(rs)で出力するとXMLやバイナリが正しく出力されないためカラム単位に出力を行う
      // ダブルクォーテーションで囲って出力
      try (ResultSet rs = s.executeQuery();
          CSVPrinter printer = new CSVPrinter(bw, CSVFormat.EXCEL
              .withHeader(rs)
              .withQuoteMode(QuoteMode.ALL))) {
        while (rs.next()) {
          for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
            // カラムごとに文字列で出力

            if (!StringUtils.isEmpty(rs.getString(i))
                && "timestamp".equals(rs.getMetaData().getColumnTypeName(i))) {
              // Timestampの場合、フォーマット指定
              DateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
              printer.print(format.format(rs.getTimestamp(i)));
            } else {
              printer.print(rs.getString(i));
            }
          }
          // 改行
          printer.println();
        }
      }
    } catch (SQLException e) {
      String msg = "削除対象レコードのバックアップでDBエラーが発生しました。";
      errorLog(null, msg, e);
      throw new NtssException(msg, e);
    } catch (IOException e) {
      String msg = "削除対象レコードのバックアップでファイルシステムエラーが発生しました。";
      errorLog(null, msg, e);
      throw new NtssException(msg, e);
    } finally {
      if (c != null) {
        DataSourceUtils.releaseConnection(c, jdbc.getDataSource());
      }
    }
  }

  // 施設解約実行

  /**
   * 解約対象施設を無効化する。
   *
   * @param facilityCd 施設コード
   * @param statsLIst 統計情報リスト
   */
  @Transactional(propagation = Propagation.NESTED)
  public void invalidateFacility(String facilityCd, List<Map<String, Object>> statsList) {
    try {
      // mst_user_authenticationレコードの無効化
      Map<String, Object> muaStat = FacilityCancelStatUtil.findStat(statsList, DB_KIND_AUTH,
          TABLE_NAME_MST_USER_AUTHENTICATION);
      String muaStart = clockWrapper.getCurrentTimeStr();
      Integer muaCount = mstUserAuthenticationDao.deleteByFacilityCd(facilityCd);
      FacilityCancelStatUtil.updateStat(muaStat, muaCount, muaStart, clockWrapper.getCurrentTimeStr());

      // mst_facility_hashレコードの無効化
      Map<String, Object> mfhStat = FacilityCancelStatUtil.findStat(statsList, DB_KIND_AUTH,
          TABLE_NAME_MST_FACILITY_HASH);
      String mfhStart = clockWrapper.getCurrentTimeStr();
      Integer mfhCount = mstFacilityHashDao.deleteByCd(facilityCd);
      FacilityCancelStatUtil.updateStat(mfhStat, mfhCount, mfhStart, clockWrapper.getCurrentTimeStr());

      // sys_signin_managerレコードの無効化
      Map<String, Object> ssmStat = FacilityCancelStatUtil.findStat(statsList, DB_KIND_AUTH,
          TABLE_NAME_SYS_SIGNIN_MANAGER);
      String ssmStart = clockWrapper.getCurrentTimeStr();
      Integer ssmCount = sysSigninManagerDao.deleteByFacilityCd(facilityCd);
      FacilityCancelStatUtil.updateStat(ssmStat, ssmCount, ssmStart, clockWrapper.getCurrentTimeStr());

      // mst_pat_hashレコードの無効化
      Map<String, Object> mphStat = FacilityCancelStatUtil.findStat(statsList, DB_KIND_AUTH,
          TABLE_NAME_MST_PAT_HASH);
      String mphStart = clockWrapper.getCurrentTimeStr();
      Integer mphCount = mstPatHashDao.deleteByCd(facilityCd);
      FacilityCancelStatUtil.updateStat(mphStat, mphCount, mphStart, clockWrapper.getCurrentTimeStr());

      // mst_machineレコードの無効化
      Map<String, Object> mmStat = FacilityCancelStatUtil.findStat(statsList, DB_KIND_DEFAULT,
          TABLE_NAME_MST_MACHINE);
      String mmStart = clockWrapper.getCurrentTimeStr();
      Integer mmCount = mstMachineDao.deleteByFacilityCd(facilityCd);
      FacilityCancelStatUtil.updateStat(mmStat, mmCount, mmStart, clockWrapper.getCurrentTimeStr());

    } catch (Exception e) {
      String msg = "解約対象施設の無効化でDBエラーが発生しました。 ";
      errorLog(facilityCd, msg, e);
      throw new NtssException(msg, e);
    }
  }

  /**
   * レコードを物理削除する。
   *
   * @param dbClass データベース種別
   * @param tableName テーブル名
   * @param facilityCd 施設コード
   * @param limit 一度に削除する上限件数
   * @param aliasColumnName 施設コードの別名カラム
   * @param timeColumnName 日時比較対象のカラム名
   * @param criteriaTime 比較日時（この値より古いレコードを削除する）
   * @return 削除件数
   */
  @Transactional(propagation = Propagation.NESTED)
  public Integer delete(Integer dbClass, String tableName, String facilityCd, Integer limit,
      String aliasColumnName, String timeColumnName, Long criteriaTime) {
    JdbcTemplate jdbc = JDBCUtil.getJdbcTemplate(dbClass, jdbcTemplateAuth, jdbcTemplate, jdbcTemplatePersonal);

    String timeCond;
    Object[] args;

    if (StringUtils.isEmpty(timeColumnName)) {
      timeCond = "";
      args = new Object[] { facilityCd, limit };
    } else {
      timeCond = "AND " + timeColumnName + " < ?";
      args = new Object[] { facilityCd, new Timestamp(criteriaTime), limit };
    }

    // 施設コードカラムの設定
    String facilityCdColumn = StringUtils.isEmpty(aliasColumnName) ? "facility_cd" : aliasColumnName;
    String q = String.format(
        "DELETE FROM %s WHERE ctid = ANY(ARRAY(SELECT ctid FROM %s WHERE %s = ? %s LIMIT ?))",
        tableName, tableName, facilityCdColumn,timeCond);

    try {
      return jdbc.update(q, args);
    } catch (DataAccessException e) {
      String msg = "解約施設のレコード削除でDBエラーが発生しました。";
      errorLog(facilityCd, msg, e);
      throw new NtssException(msg, e);
    }
  }

  /**
   * レコードを物理削除する。
   *
   * @param dbClass データベース種別
   * @param tableName テーブル名
   * @param facilityCd 施設コード
   * @param timeColumnName 日時比較対象のカラム名
   * @param criteriaTime 比較日時（この値より古いレコードを削除する）
   * @return 削除件数
   */
  @Transactional(propagation = Propagation.NESTED)
  public Integer delete(Integer dbClass, String tableName, List<String> facilityCd, String timeColumnName, Long criteriaTime) {
    JdbcTemplate jdbc = JDBCUtil.getJdbcTemplate(dbClass, jdbcTemplateAuth, jdbcTemplate, jdbcTemplatePersonal);

    String timeCond;
    Object[] args;

    if (StringUtils.isEmpty(timeColumnName)) {
      return 0;
    } else {
      timeCond = timeColumnName + " < ?";
    }

    String strfacilityCd = "('" + String.join("','", facilityCd) + "')";
    args = new Object[] { new Timestamp(criteriaTime) };

    // 施設コードカラムの設定
    String q = String.format(
        "DELETE FROM %s WHERE ctid = ANY(ARRAY(SELECT ctid FROM %s WHERE facility_cd in %s AND %s ))",
        tableName, tableName, strfacilityCd, timeCond);

    try {
      return jdbc.update(q, args);
    } catch (DataAccessException e) {
      String msg = "期間指定レコード削除でDBエラーが発生しました。";
      errorLog("", msg, e);
      throw new NtssException(msg, e);
    }
  }

  /**
   * mst_selectorのレコードを物理削除する。
   *
   * @param dbClass データベース種別
   * @param tableName テーブル名
   * @param facilityCd 施設コード
   * @param strTargetMstNm 対象のマスタ物理名称(","区切りで対象テーブル指定)
   * @return 削除件数
   */
  @Transactional(propagation = Propagation.NESTED)
  public Integer deleteMstSelector(Integer dbClass, String tableName, String facilityCd, String strTargetMstNm) {
    JdbcTemplate jdbc = JDBCUtil.getJdbcTemplate(dbClass, jdbcTemplateAuth, jdbcTemplate, jdbcTemplatePersonal);

    // 条件部
    String conditions = "facility_cd = '" + facilityCd + "'";
    conditions += " AND master_physical_name in (" + strTargetMstNm + ")";

    // 削除用SQL組み立て
    String q = String.format(
        "DELETE FROM %s WHERE ctid = ANY(ARRAY(SELECT ctid FROM %s WHERE %s))",
        tableName, tableName, conditions);

    try {
      return jdbc.update(q);
    } catch (DataAccessException e) {
      String msg = "解約施設のレコード削除でDBエラーが発生しました。";
      errorLog(facilityCd, msg, e);
      throw new NtssException(msg, e);
    }
  }

  /**
   * 期間外削除の対象施設を取得する。
   *
   * @param procClass 処理種別
   * @param status 取得対象とする処理ステータス（複数指定可）
   * @return MntFacilityCancelManageのリスト
   */
  public List<MntFacilityCancelManage> getTargetFacilityList(List<String> procClassList, String... status) {
    // 解約対象施設のレコード削除条件
    List<String> statusList = Arrays.asList(status);

    try {
      Timestamp now = new Timestamp(clockWrapper.getClockMillis());
      return mntFacilityCancelManageDao.select(statusList, procClassList, now);
    } catch (Exception e) {
      errorLog(null, "JDBC例外", e);
      throw new NtssException("JDBC例外", e);
    }
  }

  /**
   * 指定された施設コードに対応する削除対象レコードの件数を取得する。
   *
   * @param dbClass データベース種別
   * @param tableName テーブル名
   * @param facilityCd 施設コード
   * @param aliasColumnName 施設コードの別名カラム
   * @param timeColumnName 日時比較対象のカラム名
   * @param criteriaTime 比較日時（この値より古いレコードを削除する）
   * @return レコード件数
   */
  public Long getRecordCount(Integer dbClass, String tableName, String facilityCd,
      String aliasColumnName, String timeColumnName, Long criteriaTime) {
    JdbcTemplate jdbc = JDBCUtil.getJdbcTemplate(dbClass, jdbcTemplateAuth, jdbcTemplate, jdbcTemplatePersonal);

    String timeCond;
    Object[] args;

    if (StringUtils.isEmpty(timeColumnName)) {
      timeCond = "";
      args = new Object[] { facilityCd };
    } else {
      timeCond = "AND " + timeColumnName + " < ?";
      args = new Object[] { facilityCd, new Timestamp(criteriaTime) };
    }

    // 施設コードカラムの設定
    String facilityCdColumn = StringUtils.isEmpty(aliasColumnName) ? "facility_cd" : aliasColumnName;
    String q = String.format("SELECT COUNT(*) FROM %s WHERE %s = ? %s", tableName, facilityCdColumn, timeCond);

    String logArgs = args.length == 1? (String) args[0] : (String) args[0] + ", " + args[1];
    debugLog(facilityCd, String.format("countRecord SQL = [%s] args = [%s]", q, logArgs));
    return jdbc.queryForObject(q, Long.class, args);
  }

  /**
   * システム利用設定の更新、許可メニューの更新を行う
   *
   * @param facilityCd 施設コード
   * @param procClass 処理区分("3":ReMSのみ解約、"4":FNSiのみ解約)
   */
  public void updSystemUseSetting(String facilityCd, String procClass) {
    // システム利用設定にて許可されたメニューリスト
    List<String> functionCdList = new ArrayList<String>();
    List<String> advancedCdList = new ArrayList<String>();
    List<String> isNkkList = new ArrayList<String>();
    List<String> systemUseDispList = new ArrayList<String>();
    // システム利用設定更新
    if (PROC_CLASS_REMS_CANCEL.equals(procClass)) {
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(facilityCd);
      mstFacilityHash.setSystemUseSetting(SystemUseSettings.FNSI_ONLY);
      mstFacilityHashDao.update(mstFacilityHash);

      // メニュー設定編集のため、使用可能メニュー一覧を取得
      isNkkList.add(IsNkkFlg.ALL_FACILITIES);
      systemUseDispList.add(SystemUseDisp.FNSI_REMS);
      systemUseDispList.add(SystemUseDisp.INCLUDE_FNSI);
      List<SysFunction> sysFunctionList = sysFunctionDao.selectByDelAndDisp(FlagType.FLAG_OFF, FlagType.FLAG_ON, isNkkList, systemUseDispList);
      functionCdList = sysFunctionList.stream().map(function -> function.getFunctionCd()).collect(Collectors.toList());
      // 拡張機能設定編集のため、使用可能拡張機能一覧を取得
      List<SysFunctionAdvanced> SysFunctionAdvancedList = sysFunctionAdvancedDao.selectByDelAndDisp(FlagType.FLAG_OFF, FlagType.FLAG_ON, isNkkList, systemUseDispList);
      advancedCdList = SysFunctionAdvancedList.stream().map(function -> function.getFunctionAdvCd()).collect(Collectors.toList());
    } else if (PROC_CLASS_FNSI_CANCEL.equals(procClass)) {
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(facilityCd);
      mstFacilityHash.setSystemUseSetting(SystemUseSettings.REMS_ONLY);
      mstFacilityHashDao.update(mstFacilityHash);

      // メニュー設定編集のため、使用可能メニュー一覧を取得
      isNkkList.add(IsNkkFlg.ALL_FACILITIES);
      systemUseDispList.add(SystemUseDisp.FNSI_REMS);
      systemUseDispList.add(SystemUseDisp.INCLUDE_REMS);
      List<SysFunction> sysFunctionList = sysFunctionDao.selectByDelAndDisp(FlagType.FLAG_OFF, FlagType.FLAG_ON, isNkkList, systemUseDispList);
      functionCdList = sysFunctionList.stream().map(function -> function.getFunctionCd()).collect(Collectors.toList());
      // 拡張機能設定編集のため、使用可能拡張機能一覧を取得
      List<SysFunctionAdvanced> SysFunctionAdvancedList = sysFunctionAdvancedDao.selectByDelAndDisp(FlagType.FLAG_OFF, FlagType.FLAG_ON, isNkkList, systemUseDispList);
      advancedCdList = SysFunctionAdvancedList.stream().map(function -> function.getFunctionAdvCd()).collect(Collectors.toList());
    }

    // 施設の許可機能設定変更
    MstFacility mstFaciity = mstFacilityDao.selectByCd(facilityCd);
    if (mstFaciity.getUseFunction() != null) {
      JSONObject functionData = new JSONObject(mstFaciity.getUseFunction());
      JSONArray functionCds = functionData.getJSONArray("func_cds");
      JSONArray newFunctionCds = new JSONArray();
      for (int idx = 0; idx < functionCds.length(); idx++) {
        String funcCd = functionCds.getJSONObject(idx).getString("func_cd");
        if (functionCdList.contains(funcCd)) {
          JSONObject func = new JSONObject();
          func.put("func_cd", funcCd);
          newFunctionCds.put(func);
        }
      }
      functionData.put("func_cds", newFunctionCds);
      mstFaciity.setUseFunction(functionData.toString());
    }
    // 施設の拡張機能設定変更
    if (mstFaciity.getAdvancedSettings() != null) {
      JSONObject advancedData = new JSONObject(mstFaciity.getAdvancedSettings());
      JSONArray functionAdvcds = advancedData.getJSONArray("func_advcds");
      JSONArray newFunctionAdvCds = new JSONArray();
      for (int idx = 0; idx < functionAdvcds.length(); idx++) {
        String advCd = functionAdvcds.getJSONObject(idx).getString("func_advcd");
        if (advancedCdList.contains(advCd)) {
          JSONObject func = new JSONObject();
          func.put("func_advcd", advCd);
          newFunctionAdvCds.put(func);
        }
      }
      advancedData.put("func_advcds", newFunctionAdvCds);
      mstFaciity.setAdvancedSettings(advancedData.toString());
    }
    // mst_facility更新
    mstFaciity.setUpDate(new Timestamp(System.currentTimeMillis()));
    mstFacilityDao.update(mstFaciity);

    // 職種のデフォルト許可機能設定変更
    SelectOptions selectOptions = SelectOptions.get();
    // 指定したfacilityCdの職種情報を全件取得
    List<MstJob> lstMstJob = mstJobDao.selectByFacilityCd(facilityCd, selectOptions);
    for(MstJob job : lstMstJob) {
      // 使用機能一覧
      List<String> lstUseFunc = job.getDefaultMenuSettings().getUseFunctions();
      // 更新用使用機能一覧
      List<String> newLstUseFunc = new ArrayList<String>();
      // 使用機能一覧を編集
      for(String function : lstUseFunc) {
        if(functionCdList.contains(function)) {
          newLstUseFunc.add(function);
        }
      }
      // 更新用の職種情報
      MstJob updMstJob = job;
      // 今回の編集で使用機能が外された場合
      MstJob.DefaultMenuSettings menuSetting = updMstJob.getDefaultMenuSettings();
      menuSetting.setUseFunctions(newLstUseFunc);
      // 初期表示メニューの編集
      if (!newLstUseFunc.contains(updMstJob.getDefaultMenuSettings().getInitialFunction())) {
        if (newLstUseFunc.size() > 0) {
          menuSetting.setInitialFunction(newLstUseFunc.get(0));
        } else {
          menuSetting.setInitialFunction("");
        }
      }
      updMstJob.setDefaultMenuSettings(menuSetting);
      // メニュー設定更新
      mstJobDao.updateDefaultMenuSettings(updMstJob);
    }

    // 施設内利用者の許可機能設定変更
    List<MstUserAuthentication> users = mstUserAuthenticationDao.selectByFacility(facilityCd);
    for(MstUserAuthentication user: users) {
      MstUser mstUser = mstUserDao.selectById(user.getUserId());
      // 現在対象ユーザに許可されている機能一覧
      List<String> lstAuthorizedFunctions = mstUser.getUserSettings().getAuthorizedFunctions();
      // 更新用 許可機能一覧
      List<String> newLstAuthorizedFunctions = new ArrayList<String>();
      for(String function : lstAuthorizedFunctions) {
        if(functionCdList.contains(function)) {
          newLstAuthorizedFunctions.add(function);
        }
      }
      MstUser.UserSettings userSettings = mstUser.getUserSettings();
      userSettings.setAuthorizedFunctions(newLstAuthorizedFunctions);

      // 使用機能の編集
      List<String> lstUseFunctions = userSettings.getUseFunctions();
      List<String> newLstUseFunctions = new ArrayList<String>();
      for(String function : lstUseFunctions) {
        if(functionCdList.contains(function)) {
          newLstUseFunctions.add(function);
        }
      }
      userSettings.setUseFunctions(newLstUseFunctions);

      // 初期起動画面の編集
      if (!newLstAuthorizedFunctions.contains(userSettings.getInitialFunction())) {
        if (newLstUseFunctions.size() > 0) {
          userSettings.setInitialFunction(newLstUseFunctions.get(0));
        } else if (newLstAuthorizedFunctions.size() > 0) {
          userSettings.setInitialFunction(newLstAuthorizedFunctions.get(0));
        } else {
          userSettings.setInitialFunction("");
        }
      }

      mstUser.setUserSettings(userSettings);
      mstUserDao.updateUserSettings(mstUser);
    }
  }

  /**
   * デバイスエッジ同期トリガーを実行する
   *
   * @param facilityCd 施設コード
   * @return 同期実行成否(true:成功、false:失敗)
   */
  public boolean synchroMstMachine(String facilityCd) {
    // 戻り値
    boolean ret = true;

    List<MstDeviceEdge> lstMstDeviceEdge = mstDeviceEdgeDao.selectByFacilityCd(facilityCd);
    for (MstDeviceEdge deviceEdge : lstMstDeviceEdge) {
      // 後続処理スキップフラグ
      boolean isSkip = false;

      Integer deviceEdgeNo = deviceEdge.getDeviceEdgeNo();
      List<MstMachine> lstMstMachine = mstMachineDao.selectByFacilityAndDeviceEdgeNo(facilityCd, deviceEdgeNo);
      if (null == lstMstMachine) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[マスタ同期]装置マスタの取得失敗 ： 施設コード[" + facilityCd + "]、デバイスエッジ番号[" + deviceEdgeNo +"]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // 次のデバイスエッジ処理に移行
        ret = false;
        break;
      }

      // デバイスエッジへ送信するデータ格納用
      String payload = "";

      for (int i = 0; i < lstMstMachine.size(); i++) {
        // 1件ずつ処理
        MstMachine data = lstMstMachine.get(i);

        try {
          // 型式コード
          payload += StringPadding(data.getMachineTypeCd(), 3);
          // 通信フォーマット
          payload += StringPadding(data.getComFormatCd(), 1);
          // 製造番号
          payload += StringPadding(data.getMachineSerial(), 8);

          // IPアドレス
          // IPアドレスを'.'で区切って頭0埋め(各3byteの合計15byte)
          String ipAdress = "";
          String[] lstIpAdress = data.getIpAddress().toString().split("\\.");
          for (int j = 0; j < lstIpAdress.length; j++) {
            if ("".compareTo(ipAdress) != 0) {
              ipAdress += ".";
            }

            // 文字列に対してはいきなり0埋めは出来ないので、まずは空白詰めを実施し、空白を0に置換している
            ipAdress += String.format("%3s", lstIpAdress[j]).replace(' ', '0');
          }
          payload += ipAdress;

          // ポート番号
          payload += StringPadding(data.getPort(), 5);
          // FTP収集
          payload += StringPadding(data.getIsFtp(), 1);
          // 通信種別
          payload += (null == data.getComType()) ? " " : data.getComType();
        } catch (Exception e) {

          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("[マスタ同期]ペイロードのbyte精査処理で異常 ： 型式コード[" +  data.getMachineTypeCd() + "]、通信フォーマット["
              + data.getComFormatCd() + "]、製造番号[" + data.getMachineSerial() + "]、IPアドレス[" + data.getIpAddress().toString() + "]、ポート番号["
              + data.getPort() + "]、FTP収集[" + data.getIsFtp() + "]、通信種別[" + data.getComType() + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

          isSkip = true;
          break;
        }
      }

      if (isSkip) {
        // 次のデバイスエッジ処理を行う
        ret = false;
        break;
      }

      // 同期依頼
      String topic = TOPIC_BASE + "/" + facilityCd + "/" + deviceEdgeNo;

      // 送信情報
      // 通知先判定情報(施設コード + "EDGE"(固定大文字) + DE番号(左0埋め))
      String targerId = facilityCd + "EDGE" + (null == deviceEdgeNo ? "" : String.format("%02d", deviceEdgeNo));

      // 通知先に送るメッセージ情報(AWSIoTトピック名 + {TAB記号} + ペイロード文字列)
      String message = topic + "\t" + payload;

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[DE通知API]送信情報 ： targerId[" + targerId + "]、message[" + message + "]");
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS, null);

      // Base64化
      targerId = Base64.getEncoder().encodeToString(targerId.getBytes());
      message = Base64.getEncoder().encodeToString(message.getBytes());

      try {

        // 接続先IPアドレスを取得(サーバ種別は0固定)
        String ipAddress = getConnectIp(facilityCd, 0);
        if (true == StringUtils.isEmpty(ipAddress)) {
          // 次のデバイスエッジ処理を行う
          ret = false;
          break;
        }

        // 送信URI
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[DE通知API]接続先URI ： ["+ String.format(CONNECT_URI_BASE, ipAddress) + "]");
        logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS, null);
        URI uri = new URI(String.format(CONNECT_URI_BASE, ipAddress));
        RestTemplate rt = new RestTemplate();

        // body作成
        SendMessageJson json = new SendMessageJson();
        json.setTargetId(targerId);
        json.setMessage(message);

        // リクエスト作成
        RequestEntity<SendMessageJson> request = RequestEntity
            .post(uri)
            .contentType(MediaType.APPLICATION_JSON)
            .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
            .body(json);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        // リクエスト処理
        ResponseEntity<HttpStatus> response = rt.exchange(request, HttpStatus.class);
        HttpStatus status = response.getStatusCode();
        // log start
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.web_api.service.component.SubTransactionComponent");
        map.put("methodName", "synchroMstMachine");
        map.put("method", request.getMethod());
        map.put("url", request.getUrl());
        map.put("headers", request.getHeaders().toSingleValueMap());
        map.put("requestParameter", request.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        restTemplateEventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
        if (HttpStatus.OK != status) {
          eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("[マスタ同期・DE通知API]DE通知API処理で失敗(RestAPI側で接続失敗) ： [" + status + "]、施設コード[" + facilityCd +"]、デバイスエッジ番号[" + deviceEdgeNo +"]");
          logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS, null);
          // 次のデバイスエッジ処理を行う
          ret = false;
          break;
        }
      } catch (Exception ex) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[マスタ同期・DE通知API]DE通知API処理で失敗(RestAPI側で例外発生) ：]" + ex.getMessage() +"]、施設コード[" + facilityCd +"]、デバイスエッジ番号[" + deviceEdgeNo +"]");
        logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS, null);
        // 次のデバイスエッジ処理を行う
        ret = false;
        break;
      }
    }
    // 1台でも同期に失敗していた場合はfalseを返却
    return ret;
  }

  /**
   * 指定文字列のPadding処理 ・指定文字列のbyte数が指定byte数より少ない場合：50byte以降を切り捨て.
   * ・指定文字列のbyte数が指定byte数より多い場合：50byte以降になるまで右側に半角スペース埋め.
   *
   * @param target 対象文字列
   * @param byteNum 指定byte数
   * @return 処理後の文字列
   * @throws Exception
   */
  private String StringPadding(String target, int byteNum) throws Exception {
    // 戻り値用変数
    String resultMsg = "";

    if (false == StringUtils.isEmpty(target)) {
      // 対象文字列を1文字ずつ分割しbyte数チェックをしながら結合
      String[] arrayMsg = target.split("");

      for (int i = 0; i < arrayMsg.length; i++) {
        if (byteNum < (resultMsg + arrayMsg[i]).getBytes("SJIS").length) {
          // 対象文字列が指定byte数を超える場合は終了
          break;
        }

        // 1文字を結合
        resultMsg += arrayMsg[i];
      }
    }

    // 指定byte数になるまで右側に半角スペースを付与
    // ※String.format("%-" + byteNum + "s", resultMsg)で実施すると指定バイト数分の文字列数となるのでNG
    for (int i = byteNum; resultMsg.getBytes("SJIS").length < i;) {
      resultMsg += " ";
    }

    return resultMsg;
  }

  /**
   * DeviceEdgeと繋がっているサーバーのIPアドレスを取得.
   *
   * @param facilityCd 施設コード
   * @param serverType サーバ種別(0：DeviceServer、1：WebApServer)
   * @return IPアドレス
   */
  private String getConnectIp(String facilityCd, int serverType) {

    // DeviceEdgeと繋がっているサーバーのIPアドレスを取得
    List<MntClientConnect> ipList = this.mntClientConnectDao.selectByServerType(facilityCd, serverType);
    if (null == ipList) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[DE通知API]RestAPI呼び出し先IPアドレスの取得失敗 ： 施設コード[" + facilityCd +"]、サーバ種別[" + serverType +"]");
      eventLogMessage.setSqlIdentification("(facilityCd = "+ facilityCd +", serverType = "+ serverType +")");
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,"MntClientConnectDao/selectByServerType");
      return null;
    }
    if (0 == ipList.size()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[DE通知API]RestAPI呼び出し先IPアドレスの取得件数0件 ： 施設コード[" + facilityCd + "]、サーバ種別[" + serverType +"]");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS, null);
      return null;
    }

    return ipList.get(0).getIpAddress();
  }

  /**
   * 連携IF停止を行う
   * @param facilityCd 施設コード
   */
  public void stopIfEdge(String facilityCd) {
    // 連携設定を取得
    MstCoopFacility coopFacility = mstCoopFacilityDao.select(facilityCd);
    if (coopFacility != null) {
      // IFエッジ設定をnullで更新(後続処理でIFエッジの設定ファイルを空にするため)
      coopFacility.setIfEdgeSetting(null);
      mstCoopFacilityDao.updateMstMstCoopFacility(coopFacility);

      boolean isReqSuccess = true;
      // 連携IFの設定ファイルを更新(空ファイルで更新する)
      JSONObject payLoadUpdateSettingFile = new JSONObject();
      payLoadUpdateSettingFile.put("facilityCd", facilityCd);
      payLoadUpdateSettingFile.put("type", "command");
      payLoadUpdateSettingFile.put("command", "sendEdgeSetting");
      isReqSuccess = requestIfEdgeMaintenance(facilityCd, payLoadUpdateSettingFile);
      if (!isReqSuccess) {
        // 設定ファイル更新失敗
        String msg = String.format("連携エッジ設定ファイル更新処理に失敗しました。 施設コード:[%s]", facilityCd);
        errorLog(null, msg, new Exception());
      }

      // 連携IFの停止コマンドを実行する
      JSONObject payLoadStopIf = new JSONObject();
      payLoadStopIf.put("facilityCd", facilityCd);
      payLoadStopIf.put("type", "command");
      payLoadStopIf.put("command", "stop");
      isReqSuccess = requestIfEdgeMaintenance(facilityCd, payLoadStopIf);
      if (!isReqSuccess) {
        // 停止失敗
        String msg = String.format("連携エッジの停止に失敗しました。 施設コード:[%s]", facilityCd);
        errorLog(null, msg, new Exception());
      }
    } else {
      // 連携IFエッジなし
      String msg = String.format("連携エッジ情報が存在しません。 施設コード:[%s]", facilityCd);
      debugLog(null, msg);
    }
  }

  /**
   * 連携エッジメンテナンスAPIリクエスト
   *
   * @param payload
   * @param ntssUser
   * @return
   * @throws Exception
   */
  private boolean requestIfEdgeMaintenance(String facilityCd, JSONObject jsonBody) {
    try {
      RestTemplate rt = new RestTemplate();
      URI uri = new URI(coopApi + "/ifedge/maintenance");
      RequestEntity<String> request = RequestEntity
              .post(uri)
              .contentType(MediaType.APPLICATION_JSON)
              /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
              .header(headerKey, headerValue)
              /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
              .body(jsonBody.toString());
	// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<Object> response = rt.exchange(request, Object.class);
      HttpStatus status = response.getStatusCode();
      // log start
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.web_api.service.component.SubTransactionComponent");
      map.put("methodName", "requestIfEdgeMaintenance");
      map.put("method", request.getMethod());
      map.put("url", request.getUrl());
      map.put("headers", request.getHeaders().toSingleValueMap());
      map.put("requestParameter", request.getBody());
      map.put("status",status);
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      restTemplateEventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      if (HttpStatus.OK != status) {
        String msg = String.format("施設の連携IF停止リクエスト時にエラーが発生しました。 施設コード:[%s]", facilityCd);
        errorLog(null, msg, new Exception());
        return false;
      }
      return true;
    } catch (Exception ex) {
      String msg = String.format("施設の連携IF停止リクエスト時に例外が発生しました。 施設コード:[%s]", facilityCd);
      errorLog(null, msg, ex);
      return false;
    }
  }

  /**
   * エラーログを出力する。
   *
   * @param facilityCd 施設コード
   * @param errMsg エラーメッセージ
   * @param t 例外
   */
  private void errorLog(String facilityCd, String errMsg, Throwable t) {
    EventLogMessage msg = ErrorMessageUtil.createMessage(facilityCd, errMsg);
    msg.setSupportMessage(t.toString());
    logService.log(LogLevel.ERROR, msg, null, SERVICE_NAME.REMS, null);
  }

  /**
   * デバッグログを出力する。
   *
   * @param facilityCd 施設コード
   * @param errMsg エラーメッセージ
   */
  private void debugLog(String facilityCd, String errMsg) {
    EventLogMessage msg = ErrorMessageUtil.createMessage(facilityCd, errMsg);
    logService.log(LogLevel.DEBUG, msg, null, SERVICE_NAME.REMS, null);
  }
}
