package jp.co.nikkiso.ntss.core.entity.utils;

import com.google.common.base.CaseFormat;
import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import org.seasar.doma.Column;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.builder.SelectBuilder;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * {@link BaseEntity}のユーティリティクラス.
 */
public class BaseEntityUtils {

  /**
   * 引数で指定されたEntityクラスをもとに{@link SelectBuilder}を生成します.
   * <pre>
   * ＜対象テーブル＞
   * 　Entityクラスに指定されているテーブル
   * ＜抽出条件＞
   * 　<code>@ID</code>が付与されている項目
   * 　更新日時
   * </pre>
   * @param entity Entityクラス
   * @param config DB構成情報
   * @param isUpdate 更新日時を含むか否か
   *                  true : 含む
   *                  false : 含まない
   * @return {@link SelectBuilder}
   */
  public static SelectBuilder createSelectBuilder(BaseEntity entity, Config config, boolean isUpdate) {

    Class<?> clazz = entity.getClass();
    SelectBuilder selectBuilder = SelectBuilder.newInstance(config);
    selectBuilder.sql(" select * from ");

    // テーブル名を取得する
    if (!clazz.isAnnotationPresent(Table.class)) {
      return null;
    }
    selectBuilder.sql(clazz.getAnnotation(Table.class).name());

    // 抽出条件を取得する
    List<Field> fields = Arrays.stream(clazz.getDeclaredFields())
      .filter(f -> f.isAnnotationPresent(Id.class))
      .collect(Collectors.toList());
    if (fields.isEmpty()) {
      return null;
    }

    String condition = " where ";
    for (Field field : fields) {

      selectBuilder.sql(condition);

      // カラム名を取得する
      String name;
      if (field.isAnnotationPresent(Column.class)) {
        name = field.getAnnotation(Column.class).name();
      } else {
        name = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, field.getName());
      }

      selectBuilder.sql(name).sql(" = ");

      // 値を取得する
      Object obj = null;
      try {
        field.setAccessible(true);
        obj = field.get(entity);
      } catch (IllegalAccessException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      } finally {
        field.setAccessible(false);
      }

      if (obj == null) {
        return null;
      }

      if (obj instanceof String) {
        selectBuilder.param(String.class, (String) obj);
      } else if (obj instanceof Integer) {
        selectBuilder.param(Integer.class, (Integer) obj);
      } else if (obj instanceof Long) {
        selectBuilder.param(Long.class, (Long) obj);
      } else if (obj instanceof Timestamp) {
        selectBuilder.param(Timestamp.class, (Timestamp) obj);
      }

      condition = " and ";
    }

    // 更新日付を含む場合
    if (isUpdate) {
      // 更新日時を抽出条件に追加する
      if (entity.getUpDate() == null) {
        return null;
      }
      selectBuilder.sql(" and up_date = ").param(Timestamp.class, entity.getUpDate());
    }

    return selectBuilder;
  }

  /**
   * エンティティからテーブル名を取得する.
   * エンティティに"@Table"が指定されていない場合、空文字を返却する.
   *
   * @param entity エンティティ
   * @return テーブル名
   */
  public static String getTableName(BaseEntity entity) {
    Class<?> clazz = entity.getClass();
    // @Tableが付与されているか否かをチェック
    // 付与されていない場合は空文字を返却
    if (!clazz.isAnnotationPresent(Table.class)) {
      return "";
    }
    return clazz.getAnnotation(Table.class).name();
  }

  /**
   * 与えられたエンティティから施設コードを取得する.
   * ※エンティティ内に"facilityCd"がない場合、<code>null</code>を返します.
   *
   * @param entity エンティティ
   * @return 施設コード
   */
  public static String getFacilityCd(BaseEntity entity) {
    try {
      Method method = entity.getClass().getDeclaredMethod("getFacilityCd");
      method.setAccessible(true);
      String facilityCd = (String) method.invoke(entity);
      return facilityCd;
    } catch (Exception ex) {
      // 例外発生時は"targetFacilityCd"から取得する.
      return entity.getTargetFacilityCd();
    }
  }
}
