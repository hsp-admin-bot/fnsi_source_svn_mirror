package jp.co.nikkiso.ntss.coop_api.utils;

import java.lang.reflect.InvocationTargetException;
import java.sql.Timestamp;
import java.util.Map;
import java.util.stream.Collectors;

import org.apache.commons.beanutils.BeanUtils;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.MutablePropertyValues;
import org.springframework.beans.PropertyAccessorFactory;
import org.springframework.beans.PropertyValues;
import org.springframework.core.convert.ConversionService;
import org.springframework.core.convert.converter.Converter;
import org.springframework.core.convert.support.DefaultConversionService;

import com.google.common.base.CaseFormat;

import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * エンティティ作成の共通機能をまとめたユーティリティクラス。
 */
public class EntityCreatorUtil {
  private static final String STR_VAL_NULL = "null";

  /**
   * lower snake記法のデリミタ。
   */
  private static final String DELIM_LOWER_SNAKE = "_";

  /**
   *エンティティを作成する。
   *
   * @param clazz エンティティクラス
   * @param paramMap フィールドと値の対応マップ
   * @return エンティティ
   * @throws NoSuchMethodException
   */
  public static <T> T createEntity(Class<T> clazz, Map<String, Object> paramMap) {
    try {
      Map<String, String> flatMap = EntityJsonUtil.flatten(paramMap);
      T entity = clazz.newInstance();
      populate(entity, flatMap);
      return entity;
    } catch (InstantiationException | IllegalAccessException | InvocationTargetException | NoSuchMethodException e) {
      String errMsg = String.format("エンティティの作成でエラーが発生しました。 エンティティクラス:[%s]", clazz.getSimpleName());
      throw new NtssException(errMsg, e);
    }
  }

  /**
   * フィールド名をキー、フィールド値を値とするマップを取得する。<br/>
   * マップのキーはlower snakeとする。<br/>
   * エンティティのフィールドはlower snake/lower camelを問わない。
   *
   * @param dst コピー先（マップ）
   * @param src コピー元（エンティティオブジェクト）
   * @throws IllegalAccessException
   * @throws InvocationTargetException
   * @throws NoSuchMethodException
   */
  public static Map<String, String> describe(Object src)
      throws IllegalAccessException, InvocationTargetException, NoSuchMethodException {
    // コピー先はlower snake決め打ちとする。
    // （コピー元の命名規約がlower snakeの場合は、lower camelの前提に合わないので
    // そのまま出力される。）
    Map<String, String> m = BeanUtils.describe(src);
    return m.entrySet().stream().collect(Collectors.toMap(
        e -> CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, e.getKey()),
        e -> e.getValue()));
  }

  /**
   * マップで与えられるフィールド値を、エンティティの対応するフィールドにコピーする。<br/>
   * マップのキーはlower snakeとする。<br/>
   * エンティティのフィールドはlower snake/lower camelを問わない。
   *
   * @param dst コピー先（エンティティオブジェクト）
   * @param src コピー元（マップ）
   * @throws IllegalAccessException
   * @throws InvocationTargetException
   * @throws NoSuchMethodException
   */
  public static void populate(Object dst, Map<String, ?> src)
      throws IllegalAccessException, InvocationTargetException, NoSuchMethodException {
    // コピー先エンティティのプロパティ命名規約を調べる。
    // lower camelの場合、コピー元マップのキーをlower camelに変換する。
    Map<String, ?> m = src;
    if (isNamingLowerCamel(dst)) {
      m = src.entrySet().stream().collect(Collectors.toMap(
          e -> CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, e.getKey()),
          e -> e.getValue()));
    }

    // マップからエンティティを作成する。
    // 以前はApache CommonsのBeanUtils.populate()を使用していたが、コピー元マップが多段の場合には使用できない。
    // （エンティティクラスのフィールドが数値型かStringの場合にしか使用できない。）
    // MstUserクラスのjsonb型カラムに対応するフィールドの型が独自内部クラスであり、この制限を満たさなくなったため、
    // SpringのBeanWrapperを使用する方法に変更した。
    BeanWrapper wrapper = PropertyAccessorFactory.forBeanPropertyAccess(dst);
    wrapper.setConversionService(createConversionService());

    wrapper.setAutoGrowNestedPaths(true);
    PropertyValues pvs = new MutablePropertyValues(m);

    // マップのキーに対応するフィールドが存在しない場合、無視して（第2引数=true）変換する。
    wrapper.setPropertyValues(pvs, true);

    // MstPersonalUserの救済措置
    // lower camelの中にlower snakeが混在しているため、該当するフィールドを個別に設定する。
    if (dst instanceof MstPersonalUser) {
      MstPersonalUser mpu = (MstPersonalUser) dst;
      mpu.setInHospitalCd_1((String) src.get("in_hospital_cd_1"));
      mpu.setInHospitalCd_2((String) src.get("in_hospital_cd_2"));
    }
  }

  /**
   * 型変換サービス（Spring）を作成する。
   *
   * @return 型変換サービス
   * @see DefaultConversionService
   */
  private static ConversionService createConversionService() {
    DefaultConversionService dcs = new DefaultConversionService();

    // Apache CommonsのBeanUtils#populate()はコピー元とコピー先で型が異なるが変換可能の時、
    // 自動的に変換される。
    // DefaultConversionServiceクラスではStringからTimestamp等への変換が設定されていない。
    // そのためここで独自に設定する。
    dcs.addConverter(String.class, Timestamp.class, new StringToTimeStampConverter());
    dcs.addConverter(String.class, Integer.class, new StringToIntegerConverter());
    dcs.addConverter(String.class, Long.class, new StringToLongConverter());
    dcs.addConverter(String.class, String.class, new StringToStringConverter());

    return dcs;
  }

  /**
   * エンティティのプロパティの命名規約を調べる。
   *
   * @param obj エンティティオブジェクト
   * @return lower camelの場合はtrue、lower snakeの場合はfalse
   * @throws IllegalAccessException
   * @throws InvocationTargetException
   * @throws NoSuchMethodException
   */
  private static boolean isNamingLowerCamel(Object obj)
      throws IllegalAccessException, InvocationTargetException, NoSuchMethodException {
    // MstPersonalUserはlower camelとlower snakeが混在している。
    // （inHospitalCd_1、inHospitalCd_2）
    // 暫定的にlower camelと判定し、後の処理で上記2つのフィールドは個別に設定する。
    if (obj instanceof MstPersonalUser) {
      return true;
    }

    Map<String, String> m = BeanUtils.describe(obj);
    return m.keySet().stream().noneMatch(e -> e.contains(DELIM_LOWER_SNAKE));
  }

  // BeanWrapperで使用する型変換クラス群。

  /**
   * StringからTimestampへの変換クラス。
   */
  public static class StringToTimeStampConverter implements Converter<String, Timestamp> {
    @Override
    public Timestamp convert(String source) {
      if (source == null || source.equals(STR_VAL_NULL)) {
        return null;
      }
      return Timestamp.valueOf(source);
    }
  }

  /**
   * StringからIntegerへの変換クラス。
   */
  public static class StringToIntegerConverter implements Converter<String, Integer> {
    @Override
    public Integer convert(String source) {
      if (source == null || source.equals(STR_VAL_NULL)) {
        return null;
      }

      return Integer.parseInt(source);
    }
  }

  /**
   * StringからLongへの変換クラス。
   */
  public static class StringToLongConverter implements Converter<String, Long> {
    @Override
    public Long convert(String source) {
      if (source == null || source.equals(STR_VAL_NULL)) {
        return null;
      }

      return Long.parseLong(source);
    }
  }


  /**
   * StringからStringへの変換クラス。
   * ※nullを文字列にさせないため
   * */
  public static class StringToStringConverter implements Converter<String, String> {
    @Override
    public String convert(String source) {
      if (source == null || source.equals(STR_VAL_NULL)) {
        return null;
      }
      return source;
    }
  }
}
