package jp.co.nikkiso.ntss.web_api.util;

import org.springframework.jdbc.core.JdbcTemplate;

import jp.co.nikkiso.ntss.core.entity.SysDataSet;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * JDBCコネクションに関するユーティリティクラス。
 */
public class JDBCUtil {

  /**
   * データベース種別から対応するJdbcTemplateを取得する。
   *
   * @param dbClass データベース種別
   * @param jdbcTemplateAuth JdbcTemplate (DB4)
   * @param jdbcTemplate JdbcTemplate (DB5)
   * @param jdbcTemplatePersonal JdbcTemplate (DB6)
   * @return JdbcTemplate データベース名に対応するJdbcTemplate
   */
  public static JdbcTemplate getJdbcTemplate(Integer dbClass, JdbcTemplate jdbcTemplateAuth,
      JdbcTemplate jdbcTemplate, JdbcTemplate jdbcTemplatePersonal) {
    if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
      return jdbcTemplateAuth;
    }
    if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
      return jdbcTemplate;
    }
    if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
      return jdbcTemplatePersonal;
    }
    // データベースが対応対象外の場合、例外を発生させる。
    throw new NtssException(String.format("サポートされていないデータベースです。 データベース種別:[%s]", dbClass));
  }
}
