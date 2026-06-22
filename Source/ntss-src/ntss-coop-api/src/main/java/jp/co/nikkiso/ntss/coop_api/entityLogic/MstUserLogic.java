package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.utils.DateUtil;
import jp.co.nikkiso.ntss.coop_api.utils.EntityCreatorUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.exception.NtssException;

@Component
public class MstUserLogic implements EntityLogic {
  /** パラメータキー: 個人情報取扱い同意日時 */
  private static final String KEY_CONSENT_DATE = "consent_date";


  /**
   * マップからエンティティを作成
   *
   * @param paramMap カラム名とカラム値のマップ
   * @return エンティティ
   */
  @Override
  public Object createEntity(Map<String, Object> paramMap) {
    return EntityCreatorUtil.createEntity(MstUser.class, paramMap);
  }

  /**
   * 電文から抽出した項目をチェックおよび編集（新規登録時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap) {

    // 共通処理
    checkCommon(paramMap);

    // デフォルト値設定
    // 仮登録フラグ ※電文に設定されていない場合は仮登録とする
    paramMap.putIfAbsent("is_provisional", JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
    // 削除フラグ
    paramMap.putIfAbsent("is_del", JournalConvertConstants.LOGICAL_DELETE_FLAG_OFF);
    // 表示フラグ
    paramMap.putIfAbsent("is_disp", JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
    // 個人情報取扱い同意フラグ
    paramMap.putIfAbsent("is_consent", JournalConvertConstants.LOGICAL_DELETE_FLAG_OFF);

  }

  /**
   * 個人情報取扱い同意日時を正規化する。
   * ※値が設定されていない場合、TimeStamp変換対象にさせないようにnullとする
   *
   * @param dateStr 個人情報取扱い同意日時（文字列）
   * @return 正規化された文字列
   */
  private String normalizeConsentDate(String dateStr) {
    if (StringUtils.isEmpty(dateStr)) {
      return null;
    }

    if (dateStr.length() > 10) {
      return null;
    }

    return DateUtil.convertDateStr(DateUtil.convertDateToStringFormat(dateStr));
  }

  /**
   * 電文から抽出した項目をチェックおよび編集（更新時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @param entity 対象テーブルから取得したエンティティ（更新の場合に使用）
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap, Object entity) {
    // 共通処理
    checkCommon(paramMap);
  }

  /**
   * 共通チェック処理
   * @param paramMap 電文から抽出した項目のマップ
   */
  private void checkCommon(Map<String, Object> paramMap) {

    // 個人情報取扱い同意日時を正規化する。
    String consentDateStr = (String) paramMap.get(KEY_CONSENT_DATE);
    paramMap.put(KEY_CONSENT_DATE, normalizeConsentDate(consentDateStr));

    // マップのリストからマップ単体にする。
    Object userSettingsObj = paramMap.get("user_settings");
    if (userSettingsObj == null) {
      return;
    }

    List<Map<String, Object>> ul = ObjectMapperUtil.castToStringObjectMapList(userSettingsObj);
    Map<String, Object> m = ul.get(0);

    try {
      paramMap.put("user_settings", ObjectMapperUtil.write(m));
    } catch (IOException e) {
      String errMsg = String.format("mst_userテーブル、user_settingカラムの登録でエラーが発生しました。", userSettingsObj);
      throw new NtssException(errMsg, e);
    }
  }

}
