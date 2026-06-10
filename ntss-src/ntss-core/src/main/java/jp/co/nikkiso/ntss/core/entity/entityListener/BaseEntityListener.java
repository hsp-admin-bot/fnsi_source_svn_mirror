package jp.co.nikkiso.ntss.core.entity.entityListener;

import com.google.common.base.CaseFormat;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.BaseEntityDao;
import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import jp.co.nikkiso.ntss.core.entity.utils.BaseEntityUtils;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil;
import jp.co.nikkiso.ntss.core.logevent.IDataUpdateLogEvent;
import jp.co.nikkiso.ntss.core.logevent.LogEventUtil;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.NoArgsConstructor;
import org.seasar.doma.Column;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.OptimisticLockException;
import org.seasar.doma.jdbc.SqlLogType;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.seasar.doma.jdbc.entity.EntityListener;
import org.seasar.doma.jdbc.entity.PostUpdateContext;
import org.seasar.doma.jdbc.entity.PreDeleteContext;
import org.seasar.doma.jdbc.entity.PreInsertContext;
import org.seasar.doma.jdbc.entity.PreUpdateContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.lang.reflect.Field;
import java.sql.Timestamp;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * Entity基底クラスのEntityListener.
 */
@Component
@NoArgsConstructor
public class BaseEntityListener<T extends BaseEntity> implements EntityListener<T> {

  /**
   * {@link BaseEntityDao}
   */
  @Autowired
  private BaseEntityDao baseEntityDao;

  // DB更新ログ出力ロジック xie start
  @Autowired
  private IDataUpdateLogEvent dataAccessLogEvent;
  // DB更新ログ出力ロジック xie end

  /**
   * {@link EventLoggerFactory}
   */
  @Autowired
  private EventLoggerFactory logger;

  @Autowired
  protected EventLoggerFactory eventLoggerFactory;

  @Autowired
  protected LogServiceCore logServiceCore;

  //#8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-03-11 start
//  protected boolean hasData = false;
  //  protected DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
  private static ThreadLocal<DataUpdateLogCommonNew> logCommonThreadlocal = new ThreadLocal<DataUpdateLogCommonNew>();
  //#8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-03-11 end

  /**
   * ログメッセージの共通テンプレート
   * テンプレート内に埋め込まれる文字列は下記の通り.
   * {0} : 処理区分（INSERT or UPDATE or DELETE
   * {1} : 物理テーブル名
   * {2} : ログメッセージ
   * ※出力フォーマットは、登録、削除と更新で異なる.
   */
  private static final String TEMPLATE_LOG_MESSAGE = "[{0}]\tTABLE_NAME:[{1}]\t{2}";

  /**
   * データ登録、削除時のログメッセージのテンプレート
   * テンプレート内に埋め込まれる文字列は下記の通り.
   * {0} : 物理カラム名
   * {1} : 値
   */
  private static final String TEMPLATE_INS_OR_DEL = "{0}:[{1}]";

  /**
   * データ更新時のログメッセージのテンプレート
   * テンプレート内に埋め込まれる文字列は下記の通り.
   * {0} : 物理カラム名
   * {1} : 変更前の値
   * {2} : 変更後の値
   */
  private static final String TEMPLATE_UPD = "{0}:[{1} -> {2}]";

  /**
   * {@inheritDoc}
   */
  @Override
  public void preInsert(T base, PreInsertContext<T> context) {
    // システム日時を取得
    Timestamp currentDate = getCurrentDate();
    // 登録日時設定
    base.setRegDate(currentDate);
    // 更新日時設定
    base.setUpDate(currentDate);
    // 登録情報をイベントログに出力
    outputLog("Insert", base, context.getConfig());
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void preUpdate(T base, PreUpdateContext<T> context) {
    // 更新有無を判定
    isUpdated(base, context.getConfig());
    // 更新日時設定
    base.setUpDate(getCurrentDate());
    // 更新情報をイベントログに出力
    outputLog("Update", base, context.getConfig());
  }

  @Override
  public void postUpdate(T entity, PostUpdateContext<T> context) {
    try {
      //#8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-03-11 start
      DataUpdateLogCommonNew logCommon = logCommonThreadlocal.get();
      if (logCommon.getHasData()) {
//        add 8074 【デグレ】ログに誤った利用者が記録される 関 start
        if (entity.getLogUserId() != null) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setUserId(entity.getLogUserId());
          logCommon.setCommonEventLogMessage(eventLogMessage);
        }
//        add 8074 【デグレ】ログに誤った利用者が記録される 関  end
        logCommon.updateLog();
        //#8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-03-11 end
      }
      init();
    } catch (Exception e) {
      init();
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void preDelete(T base, PreDeleteContext<T> context) {
    // 削除情報をイベントログに出力
    outputLog("Delete", base, context.getConfig());
  }

  /**
   * システム日時を取得します.
   *
   * @return システム日時
   */
  private Timestamp getCurrentDate() {
    return new Timestamp(System.currentTimeMillis());
  }

  /**
   * 更新されているかどうかをチェックします.
   *
   * @param base   Entityクラス
   * @param config DB構成情報
   * @throws OptimisticLockException 楽観的排他エラー
   */
  private void isUpdated(T base, Config config) throws OptimisticLockException {
    getBeforeData(base, config, true);
  }

  /**
   * 更新前のデータを取得する.
   *
   * @param base     Entityクラス
   * @param config   DB構成情報
   * @param isUpdate 取得時のSQLに更新日時を含むか否か
   *                 これは楽観的排他の場合に使用する.
   *                 データ取得のみの場合は、<code>false</code>を指定して下さい.
   *                 true : 含む
   *                 false : 含まない
   * @return 検索結果のリスト
   * リスト内のマップ内の構造は下記の通りである.
   * key : カラムの物理名
   * value : 値
   * @throws {@link OptimisticLockException} 楽観的排他エラー
   *                ※<code>isUpdate</code>が<code>true</code>で
   *                検索結果がゼロの場合にスローされる.
   * @see BaseEntityUtils#createSelectBuilder(BaseEntity, Config, boolean)
   */
  private List<Map<String, Object>> getBeforeData(T base, Config config, boolean isUpdate) {
    // DB更新ログ出力ロジック xie start
    if (isUpdate) {
      // dataAccessLogEvent.outputDataAccessLog(base, config, results, true);
      // DB更新ログ出力ロジック xie Start

      try {
        //#8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-03-11 start
        DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
        logCommon.setEventLoggerFactory(eventLoggerFactory);
        logCommon.setLogServiceCore(logServiceCore);
        logCommon.setConfig(config);
        logCommon.setTableName(BaseEntityUtils.getTableName(base));
        StringBuffer buffer = createWhereBuilder(base);
        logCommon.setWhereStr(buffer);
        logCommon.setCommonEventLogMessage(LogEventUtil.getEventLogMessage(base));
        if (buffer == null) {
          logCommon.setHasData(false);
//          hasData = false;
        } else {
          logCommon.setHasData(logCommon.setInfo());
//          hasData = logCommon.setInfo();
        }
        logCommonThreadlocal.set(logCommon);
        //#8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-03-11 end

      } catch (Exception e) {
        init();
        LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
      }
    }
    // DB更新ログ出力ロジック xie end

    // Select文の作成.
    SelectBuilder selectBuilder = BaseEntityUtils.createSelectBuilder(base, config, isUpdate);
    if (selectBuilder == null) {
      return null;
    }
    // Select文の実行
    List<Map<String, Object>> results = baseEntityDao.executeSql(selectBuilder);

    // 結果がゼロ件の場合、楽観的排他エラーをスロー
    if (isUpdate && results.isEmpty()) {
      throw new OptimisticLockException(SqlLogType.NONE, selectBuilder.getSql());
    }
    return results;
  }

  /**
   * 施設コードに該当する{@link EventLogger}を取得する.
   * 施設コードが<code>null</code>の場合、共通のロガーを返却する.
   *
   * @param facilityCd 施設コード
   * @return 施設コードに該当する {@link EventLogger}
   */
  private EventLogger getEventLogger(String facilityCd) {
    if (StringUtils.isEmpty(facilityCd)) {
      return logger.getLogger();
    }
    // DB更新ログ出力ロジック xie start
    //return logger.getLogger(facilityCd, LogClass.EVENT);
    return logger.getLogger(facilityCd, LogClass.APP);
    // DB更新ログ出力ロジック xie end
  }

  /**
   * ログを出力する.
   *
   * @param processType 処理区分(Insert or Update or Delete)
   * @param base        Entityクラス
   * @param config      DB構成情報
   */
  private void outputLog(String processType, T base, Config config) {
    // 施設コードを取得
    String facilityCd = BaseEntityUtils.getFacilityCd(base);
    // ロガー取得
    EventLogger eventLogger = getEventLogger(facilityCd);
    // 出力内容
    EventLogMessage eventLogMessage = new EventLogMessage();
    // DB更新ログ出力ロジック xie start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // DB更新ログ出力ロジック xie end
    // 施設コード設定
    eventLogMessage.setFacilityCd(facilityCd);
    //　操作者ID
    eventLogMessage.setUserId(base.getOperatorId() == null ? "" : base.getOperatorId().toString());
    // ログ出力メッセージ
    if (processType.equals("Insert")) {
      eventLogMessage.setLogMessage(createInsertLogMessage(base));
    } else if (processType.equals("Update")) {
      eventLogMessage.setLogMessage(createUpdateLogMessage(base, config));
    } else if (processType.equals("Delete")) {
      eventLogMessage.setLogMessage(createDeleteLogMessage(base, config));
    } else {
      eventLogMessage.setLogMessage("想定外の処理区分が指定されました.処理区分:[" + processType + "]");
    }
    // ログ出力
    eventLogger.info(eventLogMessage);
  }

  /**
   * データ登録のログメッセージ文字列を作成する.
   *
   * @param base Entityクラス
   * @return ログメッセージ文字列
   */
  private String createInsertLogMessage(T base) {
    // 各フィールド名と値を出力
    List<Field> fields = Arrays.stream(base.getClass().getDeclaredFields())
      .collect(Collectors.toList());
    // フィールドがない場合は空文字を返却する.
    if (fields.isEmpty()) {
      return MessageFormat.format(
        TEMPLATE_LOG_MESSAGE,
        "INSERT",
        BaseEntityUtils.getTableName(base),
        "登録するカラムがありません."
      );
    }
    // フィールド事に文字列を生成
    List<String> colInfoList = new ArrayList<>();
    // 更新するデータをマップに変換
    Map<String, Object> insertDataMap = convertEntityToMap(base);
    insertDataMap.keySet().forEach(columnName -> {
      // データ取得
      Object value = insertDataMap.get(columnName);
      // 生成した文字列をリストに追加
      colInfoList.add(MessageFormat.format(TEMPLATE_INS_OR_DEL, columnName, convertObjectToString(value)));
    });
    String message = MessageFormat.format(
      TEMPLATE_LOG_MESSAGE,
      "INSERT",
      BaseEntityUtils.getTableName(base),
      String.join("\t", colInfoList)
    );
    return message;
  }

  /**
   * データ更新のログメッセージ文字列を作成する.
   *
   * @param base   Entityクラス
   * @param config DB構成情報
   * @return ログメッセージ文字列
   */
  private String createUpdateLogMessage(T base, Config config) {
    // 更新前のデータ取得.
    List<Map<String, Object>> beforeList = getBeforeData(base, config, false);
    // 更新するデータをマップに変換
    Map<String, Object> afterData = convertEntityToMap(base);
    // 更新前のデータ取得が出来なかった場合
    if (Objects.isNull(beforeList) || beforeList.isEmpty()) {
      return MessageFormat.format(
        TEMPLATE_LOG_MESSAGE,
        "UPDATE",
        BaseEntityUtils.getTableName(base),
        "更新前のデータ取得に失敗しました."
      );
    }

    // 本関数の最初にisEmptyのチェックを行っている為、
    // チェック無しでのget(index)で例外が発生する事はない.
    Map<String, Object> beforeData = beforeList.get(0);
    // フィールド事に文字列を生成
    List<String> colInfoList = new ArrayList<>();
    // 更新後のデータでループ
    afterData.keySet().forEach(columnName -> {
      // columnName に該当する列が存在しない場合
      // ※Entityなので、sql文のWhere句に指定する為の変数も存在する.
      if (!beforeData.containsKey(columnName)) {
        return;
      }
      // 更新前のデータ取得
      Object beforeValue = beforeData.get(columnName);
      // 更新後のデータ取得
      Object afterValue = afterData.get(columnName);
      // 更新前後のデータが両方共、nullの場合はログに出さない
      if (Objects.isNull(beforeValue) && Objects.isNull(afterValue)) {
        return;
      }
      // どちらか一方がnullの場合又は、更新前後で異なる場合
      if ((Objects.isNull(beforeValue) || Objects.isNull(afterValue)) ||
        (!beforeValue.toString().equals(afterValue.toString()))) {
        // 生成した文字列をリストに追加
        colInfoList.add(MessageFormat.format(
          TEMPLATE_UPD,
          columnName,
          convertObjectToString(beforeValue),
          convertObjectToString(afterValue))
        );
        return;
      }
    });
    String message = MessageFormat.format(
      TEMPLATE_LOG_MESSAGE,
      "UPDATE",
      BaseEntityUtils.getTableName(base),
      String.join("\t", colInfoList)
    );
    return message;
  }

  /**
   * データ削除のログメッセージ文字列を作成する.
   *
   * @param base   Entityクラス
   * @param config DB構成情報
   * @return ログメッセージ文字列
   */
  private String createDeleteLogMessage(T base, Config config) {
    // 更新前のデータ取得.
    List<Map<String, Object>> deleteDataList = getBeforeData(base, config, false);
    // 更新前のデータ取得が出来なかった場合
    if (Objects.isNull(deleteDataList) || deleteDataList.isEmpty()) {
      return MessageFormat.format(
        TEMPLATE_LOG_MESSAGE,
        "DELETE",
        BaseEntityUtils.getTableName(base),
        "削除するデータ取得に失敗しました."
      );
    }

    // 本関数の最初にisEmptyのチェックを行っている為、
    // チェック無しでのget(index)で例外が発生する事はない.
    Map<String, Object> deleteData = deleteDataList.get(0);
    // フィールド事に文字列を生成
    List<String> colInfoList = new ArrayList<>();

    deleteData.keySet().forEach(columnName -> {
      // 削除するデータ取得
      Object deleteValue = deleteData.get(columnName);
      // 生成した文字列をリストに追加
      colInfoList.add(MessageFormat.format(
        TEMPLATE_INS_OR_DEL,
        columnName,
        convertObjectToString(deleteValue)
      ));
    });
    String message = MessageFormat.format(
      TEMPLATE_LOG_MESSAGE,
      "DELETE",
      BaseEntityUtils.getTableName(base),
      String.join("\t", colInfoList)
    );
    return message;
  }

  /**
   * 与えられた<code>object</code>を文字列に変換する.
   * <code>object</code>が<code>null</code>の場合、<code>null</code>を返却する.
   *
   * @param object 文字列対象のオブジェクト
   * @return オブジェクトの文字列
   */
  private String convertObjectToString(Object object) {
    return Objects.isNull(object) ? null : object.toString();
  }

  /**
   * エンティティからマップに変換する.
   * 空（変数無し)のエンティティの場合、空のマップを返却する.
   * マップの構造は下記の通りである.
   * key : 物理カラム名
   * value　: 値
   *
   * @param base Entityクラス
   * @return 変換したマップ
   */
  private Map<String, Object> convertEntityToMap(T base) {
    // 返却用のマップ
    Map<String, Object> resultMap = new HashMap<>();
    // 各フィールド名と値を出力
    List<Field> fields = Arrays.stream(base.getClass().getDeclaredFields())
      .collect(Collectors.toList());
    // フィールドがない場合は空マップを返却する.
    if (fields.isEmpty()) {
      return resultMap;
    }
    for (Field field : fields) {
      // カラム名を取得する
      String name = field.isAnnotationPresent(Column.class)
        ? field.getAnnotation(Column.class).name()
        : CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, field.getName());
      // 値を取得する
      Object obj = null;
      try {
        field.setAccessible(true);
        obj = field.get(base);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      } finally {
        field.setAccessible(false);
      }
      resultMap.put(name, obj);
    }
    return resultMap;
  }

  /**
   * Where条件取得
   *
   * @param entity
   * @return
   */
  public StringBuffer createWhereBuilder(Object entity) {
    try {
      Class<?> clazz = entity.getClass();
      StringBuffer selectBuilder = new StringBuffer("");

      // テーブル名を取得する
      if (!clazz.isAnnotationPresent(Table.class)) {
        return null;
      }

      // 抽出条件を取得する
      List<Field> fields = Arrays.stream(clazz.getDeclaredFields())
        .filter(f -> f.isAnnotationPresent(Id.class))
        .collect(Collectors.toList());
      if (fields.isEmpty()) {
        return null;
      }

      String condition = " where ";
      for (Field field : fields) {

        selectBuilder.append(condition);

        // カラム名を取得する
        String name;
        if (field.isAnnotationPresent(Column.class)) {
          name = field.getAnnotation(Column.class).name();
        } else {
          name = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, field.getName());
        }

        selectBuilder.append(name).append(" = ");

        // 値を取得する
        Object obj = null;
        try {
          field.setAccessible(true);
          obj = field.get(entity);
        } catch (IllegalAccessException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
        } finally {
          field.setAccessible(false);
        }

        if (obj == null) {
          return null;
        }

        if (obj instanceof String) {
          selectBuilder.append("'" + DataUpdateLogInfoUtil.convertString(obj) + "'");
        } else if (obj instanceof Integer) {
          selectBuilder.append((Integer) obj);
        } else if (obj instanceof Long) {
          selectBuilder.append((Long) obj);
        } else if (obj instanceof Timestamp) {
          selectBuilder.append((Timestamp) obj);
        }

        condition = " and ";
      }

      return selectBuilder;
    } catch (Exception e) {
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
      return null;
    }
  }

  /**
   * メッセージ設定
   *
   * @return 設定したメッセージ
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    return eventLogMessage;
  }

  /**
   * 変数初期化処理
   */
  private void init() {
    //#8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-03-11 start
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setHasData(false);
    logCommonThreadlocal.set(logCommon);
//    hasData = false;
    //#8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-03-11 end

  }
}
