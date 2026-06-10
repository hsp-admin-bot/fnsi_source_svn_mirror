package jp.co.nikkiso.ntss.web_api.config;

import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.CONF_KEY_BACKUP_FETCH_SIZE;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.CONF_KEY_EXCLUDE_TABLE_LIST;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.CONF_KEY_INCLUDE_TABLE_LIST;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.CONF_KEY_PRIORITY_TABLE_LIST;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.CONF_KEY_REMS_CANCEL_TARGET_TABLE_LIST;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.CONF_KEY_FNSI_CANCEL_EXCLUDE_TABLE_LIST;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.CONF_KEY_FILE_PATH_DATE_FORMAT;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.CONF_KEY_FILE_PATH_TEMPLATE_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.CONF_KEY_FILE_PATH_TEMPLATE_EXPIRE;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.CONF_KEY_MAX_DELETE_LIMIT;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.DEFAULT_EXPIRATION;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.DEFAULT_MAX_DELETE_LIMIT;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.FACILITY_CANSEL_SETTING_NO;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.FACILITY_CANCEL_TARGET_TABLE;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.EXPIRE_TARGET_TABLE_REMS_ONLY;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MNT_FACILITY_CANCEL_MANAGE;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_FACILITY_HASH;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_USER_AUTHENTICATION;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.DB_KIND_AUTH;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.DB_KIND_DEFAULT;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.DB_KIND_PERSONAL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_DB_CLASS;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_REMS_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_FNSI_CANCEL;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.util.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.JavaType;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysDataSet;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * 施設解約に関する設定値を取得するクラス。
 */
@Component
public class FacilityCancelConfig {

  /** システム設定 */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /** 設定内容のキャッシュ（スレッド別） */
  private static ThreadLocal<Map<String, Object>> cache = new ThreadLocal<>();

  /**
   * 一度にdeleteする上限件数の設定値を取得する。
   *
   * @return 上限件数
   */
  public Integer getMaxDeleteLimit() {
    Map<String, Object> m = readSetting();
    Object obj = m.get(CONF_KEY_MAX_DELETE_LIMIT);

    if (obj == null) {
      return DEFAULT_MAX_DELETE_LIMIT;
    }

    if (obj instanceof Integer) {
      return (Integer) obj;
    }

    if (obj instanceof Long) {
      return ((Long) obj).intValue();
    }

    throw new NtssException("レコード削除上限件数に不正な値が設定されています。");
  }

  /**
   * 実行時間上限の設定値を取得する。
   *
   * @return 実行時間上限
   */
  public Long getExpiration() {
    return DEFAULT_EXPIRATION;
  }

  /**
   * 削除対象外のテーブル名を取得する。
   *
   * @return 削除対象外テーブル名のリスト
   */
  public List<String> getExcludedTableList() {
    // 設定で削除対象外と指定されているテーブルを取得する。
    // ただし、以下の3テーブルは特例とする。

    // (1) mnt_facility_cancel_manage →必ず削除対象外
    // facility_cdカラムを持つため削除対象となるが、管理レコードであるので削除してはいけない。
    // 指定されていない場合であっても対象外とする。

    // (2) mst_user_authentication →必ず削除対象
    // 削除しないと、他のテーブルが削除されているのにログイン可能となり不整合が発生する。
    // そのため、削除対象外に指定されていても無視する。

    // (3) mst_facility_hash
    // (2)と同様。
    Map<String, Object> m = getControlFacilityCancelTable();
    Object obj = m.get(CONF_KEY_EXCLUDE_TABLE_LIST);
    List<String> l = ObjectMapperUtil.castToStringList(obj);

    // 施設解約管理テーブルは必ず対象外とする。
    if (!l.contains(TABLE_NAME_MNT_FACILITY_CANCEL_MANAGE)) {
      l.add(TABLE_NAME_MNT_FACILITY_CANCEL_MANAGE);
    }

    // 利用者マスタ、施設マスタハッシュは対象外に指定できない。（必ず削除対象）
    // 指定されていた場合は除く。
    l.remove(TABLE_NAME_MST_USER_AUTHENTICATION);
    l.remove(TABLE_NAME_MST_FACILITY_HASH);

    return l;
  }

  /**
   * 施設解約の施設コードの別名カラムを持つテーブルリスト
   * @return 施設解約の追加テーブルリスト
   */
  public List<Map<String, Object>> getIncludeTableList() {

    Map<String, Object> m = getControlFacilityCancelTable();
    Object obj = m.get(CONF_KEY_INCLUDE_TABLE_LIST);
    List<Map<String, Object>> list = ObjectMapperUtil.castToStringObjectMapList(obj);
    return list;
  }

  /**
   * 施設解約の削除優先順テーブルリスト
   * @return 削除優先順のテーブルリスト
   */
  public List<Map<String, Object>> getPriorityTableList() {
    Map<String, Object> m = getControlFacilityCancelTable();
    Object obj = m.get(CONF_KEY_PRIORITY_TABLE_LIST);
    List<Map<String, Object>> list = ObjectMapperUtil.castToStringObjectMapList(obj);

    // 念のため削除順位でソート
    List<Map<String, Object>> sortedList =  list.stream()
        .sorted((m1, m2) ->
          ((Integer)m1.get("order")).compareTo((Integer)m2.get("order")))
        .collect(Collectors.toList());

    return sortedList;
  }

  /**
   * ReMSのみ解約の削除対象テーブルリスト
   * @return ReMSのみ解約削除対象テーブルリスト
   */
  public List<String> getRemsCancelTargetTableList() {
    Map<String, Object> m = getControlFacilityCancelTable();
    Object obj = m.get(CONF_KEY_REMS_CANCEL_TARGET_TABLE_LIST);
    List<String> list = ObjectMapperUtil.castToStringList(obj);
    return list;
  }

  /**
   * FNSiのみ解約の削除対象外テーブルリスト
   * @return FNSiのみ解約削除対象外テーブルリスト
   */
  public List<String> getFnsiCancelExcludeTableList() {
    Map<String, Object> m = getControlFacilityCancelTable();
    Object obj = m.get(CONF_KEY_FNSI_CANCEL_EXCLUDE_TABLE_LIST);
    List<String> list = ObjectMapperUtil.castToStringList(obj);
    return list;
  }


  /**
   * バックアップファイルのパスのテンプレートを取得する。
   *
   * @param procClass 処理区分
   * @return バックアップファイルのパスのテンプレート
   */
  public String getBackupPathTemplate(String procClass) {
    Map<String, Object> m = readSetting();
    String filePathTemplate = null;
    if (PROC_CLASS_CANCEL.equals(procClass) || PROC_CLASS_REMS_CANCEL.equals(procClass) || PROC_CLASS_FNSI_CANCEL.equals(procClass)) {
      filePathTemplate = (String) m.get(CONF_KEY_FILE_PATH_TEMPLATE_CANCEL);
      // 必須設定
      if (!StringUtils.isEmpty(filePathTemplate)) {
        return filePathTemplate;
      }
      throw new NtssException("バックアップファイルのパスのテンプレートが設定されていません。");
    } else {
      // 任意設定
      filePathTemplate = (String) m.get(CONF_KEY_FILE_PATH_TEMPLATE_EXPIRE);
      return filePathTemplate;
    }
  }

  /**
   * バックアップ作成日時のフォーマットを取得する。
   *
   * @return バックアップ作成日時のフォーマット
   */
  public String getBackupPathDateFormat() {
    Map<String, Object> m = readSetting();
    String filePathTemplate = (String) m.get(CONF_KEY_FILE_PATH_DATE_FORMAT);
    if (!StringUtils.isEmpty(filePathTemplate)) {
      return filePathTemplate;
    }

    throw new NtssException("バックアップ作成日時のフォーマットが設定されていません。");
  }

  /**
   * バックアップ時のフェッチサイズを取得する。
   *
   * @return フェッチサイズ
   */
  public Integer getBackupFetchSize() {
    Map<String, Object> m = readSetting();
    Object obj = m.get(CONF_KEY_BACKUP_FETCH_SIZE);

    if (obj == null) {
      return DEFAULT_MAX_DELETE_LIMIT;
    }

    if (obj instanceof Integer) {
      return (Integer) obj;
    }

    if (obj instanceof Long) {
      return ((Long) obj).intValue();
    }

    throw new NtssException("レコード削除上限件数に不正な値が設定されています。");
  }

  /**
   * 施設解約の設定値を取得する。
   *
   * @return 設定値
   */
  private Map<String, Object> readSetting() {
    synchronized (FacilityCancelConfig.class) {
      Map<String, Object> m = cache.get();
      if (m != null) {
        return m;
      }

      String valueStr = null;
      try {
        SysSystemDefine ssd = sysSystemDefineDao.selectByCtlNo(FACILITY_CANSEL_SETTING_NO).get(0);
        valueStr = ssd.getValue();

        JavaType jt = ObjectMapperUtil.constructMapType(String.class, Object.class);
        m = ObjectMapperUtil.read(valueStr, jt);
        cache.set(m);
        return m;
      } catch (IOException e) {
        String errMsg = String.format("施設解約/期間外削除共通設定にJSON形式として不正な値が設定されています。 設定値:[%s]", valueStr);
        throw new NtssException(errMsg, e);
      }
    }
  }

  /**
   * 施設解約テーブル管理の設定を取得する
   *
   * @return 設定値
   */
  private Map<String, Object> getControlFacilityCancelTable() {

    String valueStr = null;
    try {
      SysSystemDefine ssd = sysSystemDefineDao.selectByCtlNo(FACILITY_CANCEL_TARGET_TABLE).get(0);
      valueStr = ssd.getValue();

      JavaType jt = ObjectMapperUtil.constructMapType(String.class, Object.class);
      Map<String, Object> m = ObjectMapperUtil.read(valueStr, jt);
      return m;
    } catch (IOException e) {
      String errMsg = String.format("施設解約テーブル管理にJSON形式として不正な値が設定されています。 設定値:[%s]", valueStr);
      throw new NtssException(errMsg, e);
    }
  }

  /**
   * 期間外削除の設定値を取得する
   * @return 設定値
   */
  public List<Map<String, Object>> getTargetTableExpire() {

    SysSystemDefine ssd = sysSystemDefineDao.selectByCtlNo(EXPIRE_TARGET_TABLE_REMS_ONLY).get(0);
    String valueStr = ssd.getValue();
    List<Map<String, Object>> targetList = null;
    try {
      targetList = ObjectMapperUtil.readListOfMap(valueStr);
    } catch (IOException e) {
      String errMsg = String.format("期間外削除の対象テーブルの値がJSON形式として不正です。 設定値:[%s]", valueStr);
      throw new NtssException(errMsg, e);
    }
    return targetList;
  }

  /**
   * データ種別からデータベース名に変換
   *
   * @return DB名
   */
  public String getDbName(Integer dbClass) {

    if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
      // 認証DB
      return DB_KIND_AUTH;
    }
    if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
      // 一般DB
      return DB_KIND_DEFAULT;
    }
    if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
      // 個人情報DB
      return DB_KIND_PERSONAL;
    }
    throw new NtssException(String.format("%sの設定値が不正です。db_class：[%s]", STAT_KEY_DB_CLASS, dbClass));
  }

}
