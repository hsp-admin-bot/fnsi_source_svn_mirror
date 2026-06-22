package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.TimeZone;
import java.util.concurrent.atomic.AtomicBoolean;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.utils.DateTimeUtils;
// add FNSI-改修内容 薬剤マスタ、医療材料マスタの更新にて、ord_mainのjson内容も合わせて更新する。 周 start
import jp.co.nikkiso.ntss.core.entity.OrdMain;
// add FNSI-改修内容 薬剤マスタ、医療材料マスタの更新にて、ord_mainのjson内容も合わせて更新する。 周 end
import jp.co.nikkiso.ntss.core.logevent.LogServiceCoreImpl;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.seasar.doma.Dao;
import org.seasar.doma.MapKeyNamingType;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.OptimisticLockException;
import org.seasar.doma.jdbc.SqlLogType;
import org.seasar.doma.jdbc.builder.InsertBuilder;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.seasar.doma.jdbc.builder.UpdateBuilder;

import com.google.common.base.CaseFormat;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.Field;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.FieldType;
import org.springframework.util.StringUtils;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@ConfigAutowireable
@Dao
public interface MasterMaintenanceGenericDao {

  /**
   * oeration項目名.
   */
  static final String OPERATION = "operation";

  /**
   * code項目名.
   */
  static final String ALIAS_CODE = "code";

  /**
   * name項目名.
   */
  static final String ALIAS_NAME = "name";

  /**
   * ソート用項目名(第1ソートキー).
   */
  static final String SORT_RANK = "sortRank";

   /**
   * ソート用追加時刻項目名(第2ソートキー).
   */
  static final String SORT_INPUT_TIME = "sortInputTime";

  /**
   * 表示フラグ.
   */
  static final String IS_DISP = "isDisp";

  /**
   * 削除フラグ.
   */
  static final String IS_DEL = "isDel";

  /**
   * 更新日時.
   */
  static final String UP_DATE = "upDate";
  //医療材料分類マスタ start Du
  /**
   * 新規フラグ.
   */
  static final String IS_ADDROW = "isAddRow";
  //医療材料分類マスタ end Du

  /**
   * モーダル.
   */
  static final String MODAL = "$modalType";

  /**
   * 日時フォーマット.
   */
  static final String ZONED_DATE_TIME_ISO8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX";

  /**
   * insert時のシリアル値を取得します.
   *
   * @param primaryKeyName プライマリキーのカラム名
   * @param masterPhysicalName マスタ名(物理名称)
   * @return シリアル値
   */
  @Select
  Long selectCurrentSeq(String primaryKeyName, String masterPhysicalName);

  /**
   * 施設コードに紐付く、マスタ定義で設定されている項目のデータを取得します.
   *
   * @param define     マスタ定義
   * @param facilityCd 施設コード
   * @return 該当データ(HashMapのリスト)
   */
  public default List<Map<String, Object>> getMasterData(SysMasterDefine define, String facilityCd) {
    String tableName = define.getMasterPhysicalName();
    // カラム情報にalias=codeがあるか否か.
    AtomicBoolean hasAliasCode = new AtomicBoolean(false);
    SelectBuilder builder = SelectBuilder.newInstance(Config.get(this));

    builder.sql("SELECT");

    // マスタ定義に設定されているカラム情報を取得する
    // 別名が指定されている場合には、別名で取得する
    define.getColumnInfo().getFields().stream()
      .filter(e -> e.getType() != FieldType.MODAL)
      .forEach(e -> {
        String alias = e.getAlias() == null ? "" : " as " + e.getAlias();
        if (tableName.equals("mst_device_edge") ||
            tableName.equals("mst_facility") ||
            tableName.equals("sys_medicine") ||
            tableName.equals("sys_facility")) {
          // デバイスエッジマスタと施設マスタ、標準医薬品マスタはcodeのBIGINTキャスト不要
          builder.sql(e.getPhysicalName() + alias).sql(", ");
        } else {
          builder.sql(e.getSqlColumnName() + alias).sql(", ");
        }

        // aliasにcodeが含まれているか否か
        if (!hasAliasCode.get() && ALIAS_CODE.equals(e.getAlias())) {
          hasAliasCode.set(true);
        }

    });

    // 標準医薬品マスタは施設コードが不要なのでクリアする.
    if (tableName.equals("sys_medicine")) {
      facilityCd = null;
    }

    // 必ず更新日時を取得
    builder.sql("up_date");

    if (facilityCd == null) {
      builder
        .sql(" FROM ")
        .sql(tableName);
    } else {
      builder
        .sql(" FROM ")
        .sql(tableName)
        .sql(" WHERE ")
        .sql("facility_cd = ")
        .param(String.class, facilityCd);
    }
    //8104   心電図mstexamset展示       ljd Start
    if(tableName.equals("mst_exam_set")) {
      builder
              .sql(" and ")
              .sql(" ( ")
              .sql(" case ")
              .sql(" when ")
              .sql("(")
              .sql(" select ")
              .sql(" count(1) ")
              .sql(" FROM ")
              .sql(" mst_facility F ")
              .sql(" , ")
              .sql(" jsonb_array_elements ")
              .sql(" (F.advanced_settings->'func_advcds') func ")
              .sql(" where ")
              .sql(" F.facility_cd = ")
              .param(String.class, facilityCd)
              .sql(" and ")
              .sql(" func->>'func_advcd'= 'A12') ")
              .sql(" = '0' ")
              .sql(" then ")
              .sql(" exam_set_class != '3'")
              .sql(" else ")
              .sql(" ( ")
              .sql(" exam_set_class = '0' ")
              .sql(" or ")
              .sql(" exam_set_class = '1' ")
              .sql(" or ")
              .sql(" exam_set_class = '2' ")
              .sql(" or ")
              .sql(" exam_set_class = '3' ")
              .sql(" ) ")
              .sql(" end ")
              .sql(" ) ");
    }
    //8104   心電図mstexamset展示       ljd end
    // 下記の条件に合致する場合、"order by code" をSQLに付与する.
    //  mode = "1"
    //  alias に code が含まれている.
    //  allow_sort=0 または null
    if (define.getMode().equals("1") && hasAliasCode.get() &&
       (StringUtils.isEmpty(define.getAllowSort()) || define.getAllowSort().equals("0"))) {
      builder
        .sql(" ORDER BY ")
        .sql(ALIAS_CODE);
    }

    // add redmine 6238 標準医薬品マスタでデータが表示されない 標準医薬品マスタ 一時的なクエリ2000条 宋qy start
    if (tableName.equals("sys_medicine")) {
      // mod redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
      builder.sql(" ORDER BY standard_no ");
      builder.sql(" LIMIT 100 ");
      // mod redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
    }
    // add redmine 6238 標準医薬品マスタでデータが表示されない 標準医薬品マスタ 一時的なクエリ2000条 宋qy end

    // del #10151 shiyw start
    // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 start
    //if (tableName.equals("mst_disease")) {
    //  builder.sql(" LIMIT 100 ");
    //}
    // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 end
    // del #10151 shiyw end

    // add #6217 全施設マスタ画面が遅い 関昊 start
    if (tableName.equals("sys_facility")) {
      builder.sql(" ORDER BY medical_institution_cd ");
      builder.sql(" LIMIT 100 ");
    }
    // add #6217 全施設マスタ画面が遅い 関昊 end

    return builder.getMapResultList(MapKeyNamingType.CAMEL_CASE);
  }

  /**
   * 施設コードに紐付く、マスタ定義で設定されている項目のデータを取得します.
   *
   * @param define     マスタ定義
   * @param facilityCd 施設コード
   * @return 該当データ(HashMapのリスト)
   */
  public default List<Map<String, Object>> getMasterDataCoop(SysMasterDefine define, String facilityCd) {
    String tableName = define.getMasterPhysicalName();
    // カラム情報にalias=codeがあるか否か.
    AtomicBoolean hasAliasCode = new AtomicBoolean(false);
    SelectBuilder builder = SelectBuilder.newInstance(Config.get(this));

    builder.sql("SELECT");

    // マスタ定義に設定されているカラム情報を取得する
    // 別名が指定されている場合には、別名で取得する
    define.getColumnInfo().getFields().stream()
      .filter(e -> e.getType() != FieldType.MODAL)
      .forEach(e -> {
        String alias = e.getAlias() == null ? "" : " as " + e.getAlias();
        if (tableName.equals("mst_device_edge") ||
          tableName.equals("mst_facility") ||
          tableName.equals("sys_medicine") ||
          tableName.equals("sys_facility")) {
          // デバイスエッジマスタと施設マスタ、標準医薬品マスタはcodeのBIGINTキャスト不要
          builder.sql(e.getPhysicalName() + alias).sql(", ");
        } else {
          builder.sql(e.getSqlColumnName() + alias).sql(", ");
        }

        // aliasにcodeが含まれているか否か
        if (!hasAliasCode.get() && ALIAS_CODE.equals(e.getAlias())) {
          hasAliasCode.set(true);
        }

      });

    // 標準医薬品マスタは施設コードが不要なのでクリアする.
    if (tableName.equals("sys_medicine")) {
      facilityCd = null;
    }

    // 必ず更新日時を取得
    builder.sql("up_date");

    if (facilityCd == null) {
      builder
        .sql(" FROM ")
        .sql(tableName);
    } else {
      builder
        .sql(" FROM ")
        .sql(tableName)
        .sql(" WHERE ")
        .sql("facility_cd = ")
        .param(String.class, facilityCd);
    }
    //8104   心電図mstexamset展示       ljd Start
    if(tableName.equals("mst_exam_set")) {
      builder
        .sql(" and ")
        .sql(" ( ")
        .sql(" case ")
        .sql(" when ")
        .sql("(")
        .sql(" select ")
        .sql(" count(1) ")
        .sql(" FROM ")
        .sql(" mst_facility F ")
        .sql(" , ")
        .sql(" jsonb_array_elements ")
        .sql(" (F.advanced_settings->'func_advcds') func ")
        .sql(" where ")
        .sql(" F.facility_cd = ")
        .param(String.class, facilityCd)
        .sql(" and ")
        .sql(" func->>'func_advcd'= 'A12') ")
        .sql(" = '0' ")
        .sql(" then ")
        .sql(" exam_set_class != '3'")
        .sql(" else ")
        .sql(" ( ")
        .sql(" exam_set_class = '0' ")
        .sql(" or ")
        .sql(" exam_set_class = '1' ")
        .sql(" or ")
        .sql(" exam_set_class = '2' ")
        .sql(" or ")
        .sql(" exam_set_class = '3' ")
        .sql(" ) ")
        .sql(" end ")
        .sql(" ) ");
    }
    //8104   心電図mstexamset展示       ljd end
    // 下記の条件に合致する場合、"order by code" をSQLに付与する.
    //  mode = "1"
    //  alias に code が含まれている.
    //  allow_sort=0 または null
    if (define.getMode().equals("1") && hasAliasCode.get() &&
      (StringUtils.isEmpty(define.getAllowSort()) || define.getAllowSort().equals("0"))) {
      builder
        .sql(" ORDER BY ")
        .sql(ALIAS_CODE);
    }

    // add redmine 6238 標準医薬品マスタでデータが表示されない 標準医薬品マスタ 一時的なクエリ2000条 宋qy start
    if (tableName.equals("sys_medicine")) {
      // mod redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
      builder.sql(" ORDER BY standard_no ");
      builder.sql(" LIMIT 100 ");
      // mod redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
    }
    // add redmine 6238 標準医薬品マスタでデータが表示されない 標準医薬品マスタ 一時的なクエリ2000条 宋qy end

//    // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 start
//    if (tableName.equals("mst_disease")) {
//      builder.sql(" LIMIT 100 ");
//    }
//    // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 end

    // add #6217 全施設マスタ画面が遅い 関昊 start
    if (tableName.equals("sys_facility")) {
      builder.sql(" ORDER BY medical_institution_cd ");
      builder.sql(" LIMIT 100 ");
    }
    // add #6217 全施設マスタ画面が遅い 関昊 end

    return builder.getMapResultList(MapKeyNamingType.CAMEL_CASE);
  }

  /**
   * 対象マスタにレコードを追加します。.
   *
   * @param masterData 該当データ(HashMap)
   * @param define     マスタ定義
   * @param facilityCd 施設コード
   * @return 更新件数
   */
  public default void insertMasterData(Map<String, Object> masterData, SysMasterDefine define, String facilityCd) {

    InsertBuilder builder = InsertBuilder.newInstance(Config.get(this));

    // ダイアライザマスタとxxxxとxxxx画面の「使用開始日、使用終了日」項目のデータピッカ化を対応　-start
    // mst_dialyzer-ダイアライザマスタ;
    // use_start_date-使用開始日;use_end_date-使用終了日
    // mod redmine 4868 使用開始日終了日一覽頁面日付フォーマット表示 医療材料マスタ 宋qy start
    if ("mst_dialyzer".equals(define.getMasterPhysicalName()) || "mst_equipment".equals(define.getMasterPhysicalName())
    // mod redmine 4868 使用開始日終了日一覽頁面日付フォーマット表示 医療材料マスタ 宋qy end
        || "mst_medicine".equals(define.getMasterPhysicalName())
    ) {
      String useStartDate = DateTimeUtils.dateStirng_iso8601ToDateString_yyyyMMdd((String) masterData.get("useStartDate"));
      String useEndDate = DateTimeUtils.dateStirng_iso8601ToDateString_yyyyMMdd((String) masterData.get("useEndDate"));
      masterData.put("useStartDate", useStartDate);
      masterData.put("useEndDate", useEndDate);
    }
    //-end

    builder.sql("INSERT INTO ")
      .sql(define.getMasterPhysicalName())
      .sql(" (");

    // フィールド名を作成
    for (Map.Entry<String, Object> record : masterData.entrySet()) {
      // operation、PK項目 を除外してSQLを作成
      if ( isNeedEdit(record) ) {
        /* mod #8747 装置マスタをCSVで取り込んだデータで保存できない by zhangruixue 2023-05-29 --start */
        if (!"sys_medicine".equals(define.getMasterPhysicalName()) && "facility_cd".equals(getFieldName(record.getKey(), define))) {
          continue;
        }
        builder.sql(getFieldName(record.getKey(), define)).sql(", ");
        /* mod #8747 by zhangruixue 2023-05-29 --end */
      }
    }
    if ("sys_medicine".equals(define.getMasterPhysicalName())) {
//      鞠 mod 標準医薬品マスタstandard_noの修正、一覧に表示　start
//      builder.sql("standard_no").sql(", ").
//      鞠 mod 標準医薬品マスタstandard_noの修正、一覧に表示　end
      builder.
      sql("up_date").sql(", ")
        .sql("reg_date").sql(" ) values (");
    }else {
      // 施設コードと登録日・更新日を追加
      builder.sql("facility_cd").sql(", ")
        .sql("up_date").sql(", ")
        .sql("reg_date").sql(" ) values (");
    }

    // 値をパラメータとして設定
    for (Map.Entry<String, Object> record : masterData.entrySet()) {
      // operation、PK項目 を除外してSQLを作成
      if ( isNeedEdit(record) ) {
        /* mod #8747 装置マスタをCSVで取り込んだデータで保存できない by zhangruixue 2023-05-29 --start */
        if (!"sys_medicine".equals(define.getMasterPhysicalName()) && "facility_cd".equals(getFieldName(record.getKey(), define))) {
          continue;
        }
        /* mod #8747 by zhangruixue 2023-06-09 --end */
        /*  mod #6279 by zhangruixue 2023-05-29 --start */
        builder.param(String.class, isNullOrEmptyRecord(record) ? null : record.getValue().toString().equals("NaN") ? null : record.getValue().toString()).sql(", ");
        /* mod #6279 by zhangruixue 2023-06-09 --end */
      }
    }
    if (!"sys_medicine".equals(define.getMasterPhysicalName())) {
      // 施設コードと登録日・更新日を追加
      builder.param(String.class, facilityCd).sql(", ");
    }
//      鞠 mod 標準医薬品マスタstandard_noの修正、一覧に表示　start
//    else{
//      builder.param(String.class, masterData.get("code").toString()).sql(", ");
//    }
//      鞠 mod 標準医薬品マスタstandard_noの修正、一覧に表示　end

    Timestamp timestamp = new Timestamp(System.currentTimeMillis());
    builder.param(Timestamp.class, timestamp).sql(", ");
    builder.param(Timestamp.class, timestamp).sql(")");
    builder.execute();
  }

  /**
   * 対象マスタにレコードを更新します.
   *
   * @param masterData 更新データ該当データ(HashMap)
   * @param define マスタ定義
   * @return 更新件数
   */
  public default void updateMasterData(Map<String, Object> masterData, SysMasterDefine define) {
    // aliasにcodeが指定されている物理フィールド名
    String codeName = "";
    // 値
    Object codeValue = null;
    // 更新テーブル名
    String tableName = define.getMasterPhysicalName();

    // ダイアライザマスタとxxxxとxxxx画面の「使用開始日、使用終了日」項目のデータピッカ化を対応　-start
    // mst_dialyzer-ダイアライザマスタ;
    // useStartDate-使用開始日;useEndDate-使用終了日
    // mod redmine 4868 使用開始日終了日一覽頁面日付フォーマット表示 医療材料マスタ 宋qy start
    if ("mst_dialyzer".equals(tableName) || "mst_equipment".equals(tableName)
    // mod redmine 4868 使用開始日終了日一覽頁面日付フォーマット表示 医療材料マスタ 宋qy end
      || "mst_medicine".equals(tableName)) {
      String useStartDate = DateTimeUtils.dateStirng_iso8601ToDateString_yyyyMMdd((String) masterData.get("useStartDate"));
      String useEndDate = DateTimeUtils.dateStirng_iso8601ToDateString_yyyyMMdd((String) masterData.get("useEndDate"));
      masterData.put("useStartDate", useStartDate);
      masterData.put("useEndDate", useEndDate);
    }
    //-end

    // add FNSI-redMine #4569対応　陳 start
    if ("mst_weight".equals(tableName)) {

      // 体重計機種が「A&D」場合
      if("0".equals(String.valueOf(masterData.get("deviceClass")))) {
        masterData.put("telegramFormat", "{\"telegram_format\": \"ST,+{0:00000.00} kg[CR][LF]\"}");
      }

      // 体重計機種が「田中衛機」場合
      if("1".equals(String.valueOf(masterData.get("deviceClass")))) {
        masterData.put("telegramFormat", "{\"telegram_format\": \"ST,GS,+{0:0000.00} kg[CR][LF]\"}");
      }

      // 体重計機種が「ヤマトハカリ」場合
      if("2".equals(String.valueOf(masterData.get("deviceClass")))) {
        masterData.put("telegramFormat", "{\"telegram_format\": \"[SOH][SOH]17  [STX]CD000,DTDATE,NW{0:00000.00}kg,TW999.99Kg,GW999.99Kg,CT999,VH999kg,VL999Kg,[ETX][BCC][CR]\"}");
      }
    }
    // add FNSI-redMine #4569対応　陳 end

    UpdateBuilder builder = UpdateBuilder.newInstance(Config.get(this));

    builder.sql("UPDATE ")
      .sql(define.getMasterPhysicalName())
      .sql(" set");

    // TODO codeNameとcodeValueを求める処理と、SQLを組み立てる処理を分ける。
    // refs: https://github.com/esminc/ntss/pull/2253#discussion_r245906926
    // 更新値をパラメータとして設定
    for (Map.Entry<String, Object> record : masterData.entrySet()) {
      // operation と未入力を除外してSQLを作成
      if (isEntityColumn(record)) {
        // CODEはWhere句で使用し、それ以外は更新対象として作成
        if (record.getKey().equals(ALIAS_CODE)) {
          codeName = getFieldName(record.getKey(), define);
          codeValue = Long.parseLong(record.getValue().toString());
        } else {
          if(record.getKey() != "facilityCd"){
            builder.sql(getFieldName(record.getKey(), define))
              .sql("=")
              .param(String.class, isNullOrEmptyRecord(record) ? null : record.getValue().toString())
              .sql(",");
          }
        }
      }
    }
    // 更新日を設定
    builder.sql("up_date=")
      .param(Timestamp.class, new Timestamp(System.currentTimeMillis()));

    // TODO codeNameとcodeValueが空の考慮をする。
    // refs: https://github.com/esminc/ntss/pull/2253#discussion_r245907104
    // Where句を作成 code値を対象
    builder
      .sql("where ")
      .sql(codeName)
      .sql("=");

    if (tableName.equals("sys_medicine")) {
      builder.param(String.class, codeValue.toString());
    } else {
      builder.param(Long.class, (Long)codeValue);
    }

    if (tableName.equals("mst_pat_memo")) {
      builder
        .sql("and ")
        .sql("facility_cd=")
        .param(String.class, masterData.get("facilityCd").toString());
    }

    // 排他制御用に条件として前回の更新日時を設定する
    Optional.ofNullable(masterData.get(UP_DATE)).ifPresent(e -> {
      SimpleDateFormat sf = new SimpleDateFormat(ZONED_DATE_TIME_ISO8601);
      sf.setTimeZone(TimeZone.getTimeZone(CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO));

      try {
        Date dt = sf.parse((String)e);

        builder
          .sql("and ")
          .sql("up_date=")
          .param(Timestamp.class, new Timestamp(dt.getTime()));
      } catch (ParseException e1) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e1.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
        LogServiceCoreImpl logServiceCore = new LogServiceCoreImpl();
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e1));
        if (logServiceCore != null) {
          logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
      }
    });

    if (builder.execute() != 1) {
      // 更新件数が1件の場合は排他エラーとする
      throw new OptimisticLockException(SqlLogType.NONE, builder.getSql());
    };
  }

  // add FNSI-改修内容 薬剤マスタ、医療材料マスタの更新にて、ord_mainのjson内容も合わせて更新する。 周 start

  /**
   * 施設コードと情報に紐付く、マスタ定義で設定されている項目のデータを取得します.
   *
   * @param define     マスタ定義
   * @param facilityCd 施設コード
   * @param infoData   json情報(HashMap)
   * @return 該当データ(OrdMainのリスト)
   */
  public default List<OrdMain> getMasterDataByInfo(SysMasterDefine define, String facilityCd, Map<String, Object> infoData) {
    // 値
    Object codeValue = null;
    // 更新テーブル名
    String tableName = define.getMasterPhysicalName();

    SelectBuilder builder = SelectBuilder.newInstance(Config.get(this));

    for (Map.Entry<String, Object> record : infoData.entrySet()) {
      // operation と未入力を除外してSQLを作成
      if (isEntityColumn(record)) {
        // CODEはWhere句で使用し、それ以外は更新対象として作成
        if (record.getKey().equals(ALIAS_CODE)) {
          codeValue = Long.parseLong(record.getValue().toString());
          break;
        }
      }
    }

    builder.sql("SELECT");
    builder.sql(" ord_no ");
    // 更新対象を取得
    if (tableName.equals("mst_medicine")){
      builder.sql(" ,rst_medi_info ");
    }
    else if (tableName.equals("mst_equipment")){
      builder.sql(" ,rst_equip_info ");
    }

    builder.sql("  FROM ord_main");
    builder.sql(" WHERE facility_cd = ").param(String.class, facilityCd);
    // 更新対象を取得
    if (tableName.equals("mst_medicine")){
      builder.sql("   AND rst_medi_info @> ").param(String.class, "[{\"cd\":" + codeValue + "}]");
      builder.sql(" ::jsonb ");
    }
    else if (tableName.equals("mst_equipment")){
      builder.sql("   AND rst_equip_info @> ").param(String.class, "[{\"cd\":" + codeValue + "}]");
      builder.sql(" ::jsonb ");
    }

    return builder.getEntityResultList(OrdMain.class);
  }

  /**
   * json情報を更新します.
   *
   * @param define     マスタ定義
   * @param ordNo      主キー
   * @param jsonData   更新データ
   */
  public default void updateOrderData(SysMasterDefine define, String ordNo, String jsonData) {
    // 更新テーブル名
    String tableName = define.getMasterPhysicalName();

    UpdateBuilder builder = UpdateBuilder.newInstance(Config.get(this));

    builder.sql("UPDATE ord_main ");
    builder.sql("   SET ");
    // 更新対象を取得
    if (tableName.equals("mst_medicine")){
      builder.sql(" rst_medi_info = ").param(String.class, jsonData);
    }
    else if (tableName.equals("mst_equipment")){
      builder.sql(" rst_equip_info = ").param(String.class, jsonData);
    }
    builder.sql(" WHERE ord_no = ").param(String.class, ordNo);

    if (builder.execute() != 1) {
      // 更新件数が1件の場合は排他エラーとする
      throw new OptimisticLockException(SqlLogType.NONE, builder.getSql());
    };
  }
  // add FNSI-改修内容 薬剤マスタ、医療材料マスタの更新にて、ord_mainのjson内容も合わせて更新する。 周 end

  /**
   * レスポンスデータのカラム名からフィールド定義を取得します.
   *
   * @param columnName レスポンスカラム名
   * @param define    マスタ定義
   * @return フィールド定義
   */
  public default Field getFieldInfo(String columnName, SysMasterDefine define) {

    // カラム名で物理名とエイリアスを検索
    return define.getColumnInfo().getFields().stream()
        .filter(e -> e.getCamelFieldName().equals(columnName))
        .findFirst().orElse(null);

  }

  /**
   * レスポンスデータのカラム名からカラムの物理名を取得します.
   *
   * @param columnName レスポンスカラム名
   * @param define    マスタ定義
   * @return カラム名
   */
  public default String getFieldName(String columnName, SysMasterDefine define) {
    return CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, getFieldInfo(columnName, define).getPhysicalName());
  }

  /**
   * 更新対象カラムかを判定します.
   *
   * @param record 対象レコード
   * @return boolean
   */
  public default boolean isNeedEdit(Map.Entry<String, Object> record) {
    return isEntityColumn(record) && !isNullOrEmptyRecord(record) && !record.getKey().equals(ALIAS_CODE);
  }

  /**
   * テーブルに存在するカラムかを判定します.
   *
   * @param record 対象レコード
   * @return boolean
   */
  public default boolean isEntityColumn(Map.Entry<String, Object> record) {
	//医療材料分類マスタ strt DU
    // Entityにないカラム(内部的に追加したカラム)
    String[] ExclusionField = { OPERATION, SORT_RANK, SORT_INPUT_TIME, UP_DATE, IS_ADDROW};

    // 内部的に追加したカラムでないかを判定
    return (Arrays.stream(ExclusionField).filter(e -> e.equals(record.getKey())).findFirst().orElse(null) == null);
  }

  /**
   * NULLまたは空文字かを判定します.
   *
   * @param record 対象レコード
   * @return boolean
   */
  public default boolean isNullOrEmptyRecord(Map.Entry<String, Object> record) {
    return record.getValue() == null || record.getValue().toString().isEmpty();
  }


  /**
   * 患者メモマスタ更新に伴う患者メモ展開
   * @param facilityCd 施設コード
   * @param strSql JSON更新用SQL
   * @return
   */
  public default void updatePatMemoInfo(String facilityCd, String strSql) {
    UpdateBuilder builder = UpdateBuilder.newInstance(Config.get(this));

    // JSON更新用SQLがNULLの場合、処理を行わない
    if (strSql == null) {
      return;
    }

    builder.sql("update pat_main");
    builder.sql("set");
    builder.sql("pat_memo_info = ").sql(strSql);
    builder.sql("up_date = ").param(Timestamp.class, new Timestamp(System.currentTimeMillis()));
    builder.sql("where");
    builder.sql("facility_cd = ").param(String.class, facilityCd);

    builder.execute();
  }
}
