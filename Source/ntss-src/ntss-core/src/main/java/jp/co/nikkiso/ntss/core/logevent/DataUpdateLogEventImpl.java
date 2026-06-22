package jp.co.nikkiso.ntss.core.logevent;

import com.google.common.base.CaseFormat;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.BaseEntityDao;
import jp.co.nikkiso.ntss.core.entity.BaseBlankEntity;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.UpdateLogInfo;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.TableCommentInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.seasar.doma.Column;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.lang.reflect.Field;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class DataUpdateLogEventImpl implements IDataUpdateLogEvent {

  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  /**
   * {@link BaseEntityDao}
   */
  @Autowired
  private BaseEntityDao baseEntityDao;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogServiceCore logServiceCore;

  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
//   private Config dbConfig;

//   /**
//    * カラム情報を取得する
//    * @param entity
//    * @return カラム情報
//    */
//   private Map<String, UpdateLogInfo> getFieldInfo(Object entity) {

//     Class<?> clazz = entity.getClass();

//     // テーブル名を取得する
//     if (!clazz.isAnnotationPresent(Table.class)) {
//       return null;
//     }

//     String tableName = getTableName(entity);

//     List<TableCommentInfo> fieldCommentList = DataUpdateLogInfoUtil.getAllFieldComment(dbConfig, tableName);
//     if (fieldCommentList == null || fieldCommentList.size() == 0) {
//       return null;
//     }

//     // fieldを取得する
//     List<Field> fields = Arrays.stream(clazz.getDeclaredFields()).collect(Collectors.toList());
//     if (fields.isEmpty()) {
//       return null;
//     }

//     Map<String, UpdateLogInfo> map = new HashMap<String, UpdateLogInfo>();
//     UpdateLogInfo info = null;
//     for (Field field : fields) {

//       info = new UpdateLogInfo();
//       // カラム名を取得する
//       String name;
//       if (field.isAnnotationPresent(Column.class)) {
//         name = field.getAnnotation(Column.class).name();
//       } else {
//         name = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, field.getName());
//       }

//       info.setTableName(tableName);
//       info.setTableComment(DataUpdateLogInfoUtil.getTableComment(fieldCommentList));
//       info.setFieldName(name);
//       info.setFieldComment(DataUpdateLogInfoUtil.getFieldComment(info.getFieldName(), fieldCommentList));
//       info.setKeyStep(DataUpdateLogInfoUtil.getKeyStep(fieldCommentList, info.getFieldName()));

//       if (StringUtils.isEmpty(info.getFieldName()) || StringUtils.isEmpty(info.getFieldComment())) {
//         continue;
//       }
//       try {
//         field.setAccessible(true);
//         info.setAfterUpdateValue(field.get(entity));
//       } catch (IllegalAccessException e) {
//         // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
// //      e.printStackTrace();
//         // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//         // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
//         EventLogMessage eventLogMessage = new EventLogMessage();
//         eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
//         logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
//         // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
//       }
//       map.put(info.getFieldName(), info);
//     }

//     return map;
//   }
  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  // #10337 2024.05.21 del 混乱するので不使用のロジックを削除 TDC片口 start
//  /**
//   * データ変更ログを出力する
//   * @param base
//   */
//  public void outputDataAccessLog(Object base, Config cfg, List<Map<String, Object>> res, boolean isBaseEntity) {
//    String facilityCd = "";
//    String patId = "";
//    try {
//      dbConfig = cfg;
//      Map<String, UpdateLogInfo> logOutputInfoMap = getFieldInfo(isBaseEntity == true ? (BaseBlankEntity) base : base);
//      if (logOutputInfoMap == null || logOutputInfoMap.size() == 0) {
//        return;
//      }
//
//      if (isBaseEntity) {
//        DataUpdateLogInfoUtil.setBeforeFieldValue(res, logOutputInfoMap);
//        facilityCd = DataUpdateLogInfoUtil.getFacilityCd(res);
//        patId = DataUpdateLogInfoUtil.getPatId(res);
//      } else {
//        // Select文の実行
//        SelectBuilder selectBuilder = createSelectBuilder((BaseBlankEntity) base);
//        if (selectBuilder == null) {
//          return;
//        }
//        List<Map<String, Object>> results = baseEntityDao.executeSql(selectBuilder);
//        facilityCd = DataUpdateLogInfoUtil.getFacilityCd(results);
//        patId = DataUpdateLogInfoUtil.getPatId(results);
//        DataUpdateLogInfoUtil.setBeforeFieldValue(results, logOutputInfoMap);
//      }
//
//      DataUpdateLogInfoUtil.setUpdated(dbConfig, logOutputInfoMap);
//      Iterator<String> iter = logOutputInfoMap.keySet().iterator();
//      String tableName = "";
//      EventLogMessage eventLogMessage = null;
//      while (iter.hasNext()) {
//        eventLogMessage = new EventLogMessage();
//        eventLogMessage.setFacilityCd(facilityCd);
//        eventLogMessage.setPatId(patId);
//        //FNSI-修正 ログ対応 xiebzh add start
//        eventLogMessage.setInvokeClass(this.getClass().getName());
//        //FNSI-修正 ログ対応 xiebzh add end
//        String key = iter.next();
//        UpdateLogInfo outputInfo = logOutputInfoMap.get(key);
//        if (StringUtils.isEmpty(tableName)) {
//          tableName = outputInfo.getTableComment();
//        }
//
//        if (!outputInfo.isJson()) {
//          if (!outputInfo.isUpdated()) {
//            continue;
//          }
//          DataUpdateLogInfoUtil.outputDataAccessLogNoJson(eventLogMessage, logServiceCore, outputInfo, tableName);
//        } else {
//          DataUpdateLogInfoUtil.outputDataAccessLogForJson(eventLogMessage, logServiceCore, outputInfo, tableName);
//        }
//      }
//    } catch (NotExistException ole) {
//      ole.printStackTrace();
//      return;
//    } catch (Exception e) {
//      e.printStackTrace();
//      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
//    }
//  }
//
//  /**
//   * エラーメッセージ取得
//   * @return
//   */
//  private String getErrorMessage(Exception e) {
//    if (!StringUtils.isEmpty(e.getMessage())) {
//      return e.getMessage();
//    }
//    StringWriter stringWriter= new StringWriter();
//    PrintWriter writer= new PrintWriter(stringWriter);
//    e.printStackTrace(writer);
//    StringBuffer buffer = stringWriter.getBuffer();
//    return buffer.toString();
//  }
  // #10337 2024.05.21 del 混乱するので不使用のロジックを削除 TDC片口 end

  /**
   * エンティティからテーブル名を取得する.
   * エンティティに"@Table"が指定されていない場合、空文字を返却する.
   *
   * @param entity エンティティ
   * @return テーブル名
   */
  public String getTableName(Object entity) {
    try {
      Class<?> clazz = entity.getClass();
      // @Tableが付与されているか否かをチェック
      // 付与されていない場合は空文字を返却
      if (!clazz.isAnnotationPresent(Table.class)) {
        return "";
      }
      return clazz.getAnnotation(Table.class).name();
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
    }

    return "";
  }

  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
//   /**
//    * 引数で指定されたEntityクラスをもとに{@link SelectBuilder}を生成します.
//    * <pre>
//    * ＜対象テーブル＞
//    * 　Entityクラスに指定されているテーブル
//    * ＜抽出条件＞
//    * 　<code>@ID</code>が付与されている項目
//    * 　更新日時
//    * </pre>
//    * @param entity Entityクラス
//    * @return {@link SelectBuilder}
//    */
//   public SelectBuilder createSelectBuilder(BaseBlankEntity entity) {
//     try {
//       Class<?> clazz = entity.getClass();
//       SelectBuilder selectBuilder = SelectBuilder.newInstance(dbConfig);
//       selectBuilder.sql(" select * from ");

//       // テーブル名を取得する
//       if (!clazz.isAnnotationPresent(Table.class)) {
//         return null;
//       }
//       selectBuilder.sql(clazz.getAnnotation(Table.class).name());

//       // 抽出条件を取得する
//       List<Field> fields = Arrays.stream(clazz.getDeclaredFields())
//         .filter(f -> f.isAnnotationPresent(Id.class))
//         .collect(Collectors.toList());
//       if (fields.isEmpty()) {
//         return null;
//       }

//       String condition = " where ";
//       for (Field field : fields) {

//         selectBuilder.sql(condition);

//         // カラム名を取得する
//         String name;
//         if (field.isAnnotationPresent(Column.class)) {
//           name = field.getAnnotation(Column.class).name();
//         } else {
//           name = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, field.getName());
//         }

//         selectBuilder.sql(name).sql(" = ");

//         // 値を取得する
//         Object obj = null;
//         try {
//           field.setAccessible(true);
//           obj = field.get(entity);
//         } catch (IllegalAccessException e) {
//           // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
// //      e.printStackTrace();
//           // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//           // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
//           EventLogMessage eventLogMessage = new EventLogMessage();
//           eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
//           logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
//           // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
//         } finally {
//           field.setAccessible(false);
//         }

//         if (obj == null) {
//           return null;
//         }

//         if (obj instanceof String) {
//           selectBuilder.param(String.class, DataUpdateLogInfoUtil.convertString(obj));
//         } else if (obj instanceof Integer) {
//           selectBuilder.param(Integer.class, (Integer) obj);
//         } else if (obj instanceof Long) {
//           selectBuilder.param(Long.class, (Long) obj);
//         } else if (obj instanceof Timestamp) {
//           selectBuilder.param(Timestamp.class, (Timestamp) obj);
//         }

//         condition = " and ";
//       }

//       return selectBuilder;
//     } catch (Exception e) {
//       LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
//       return null;
//     }
//   }
  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
}
