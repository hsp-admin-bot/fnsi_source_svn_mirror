package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.util.Map;

import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.utils.CheckNecessaryParamUtil;
import jp.co.nikkiso.ntss.coop_api.utils.EntityCreatorUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Component
public class MstPersonalUserLogic implements EntityLogic {

  /**
   * MstPersonalUserDao.updateEncryptに対応するカラム.
   * ※暗号化対象に変更がある場合は、Columnsを対応させること
   * {@link MstPersonalUserDao}<br/>
   * */
  @Getter
  @AllArgsConstructor
  private enum Columns {
    /** 利用者名_姓 */
    USER_LAST_NAME("user_last_name"),
    /** 利用者名_名 */
    USER_FIRST_NAME("user_first_name"),
    /** 利用者カナ名_姓 */
    USER_LAST_NAME_KANA("user_last_name_kana"),
    /** 利用者カナ名_名 */
    USER_FIRST_NAME_KANA("user_first_name_kana"),
    /** 利用者英字名_姓 */
    USER_LAST_NAME_ALPHA("user_last_name_alpha"),
    /** 利用者英字名_名 */
    USER_FIRST_NAME_ALPHA("user_first_name_alpha"),
    /** メールアドレス1 */
    USER_EMAIL_ADDRESS_1("user_email_address_1"),
    /** メールアドレス2 */
    USER_EMAIL_ADDRESS_2("user_email_address_2"),
    /** 内線番号 */
    EXTENSION_NO("extension_no"),
    /** 自宅番号 */
    HOME_NO("home_no"),
    /** 携帯番号 */
    MOBILE_PHONE_NO("mobile_phone_no"),
    /** FAX番号 */
    FAX_NO("fax_no"),
    /** 郵便番号3 */
    ZIPCD_3("zipcd_3"),
    /** 郵便番号4 */
    ZIPCD_4("zipcd_4"),
    /** 自宅住所 */
    ADDRESS("address"),
    /** 自宅住所かな */
    ADDRESS_KANA("address_kana"),
    /** 職種コード */
    JOB_CD("job_cd"),
    /** 院内コード1 */
    IN_HOSPITAL_CD_1("in_hospital_cd_1"),
    /** 院内コード2 */
    IN_HOSPITAL_CD_2("in_hospital_cd_2"),
    /** 麻薬施用者免許証番号 */
    ANESTHESIOLOGIST_LICENSE_NO("anesthesiologist_license_no");
    // フィールド変数
    private final String key;
  }

  /**
   * マップからエンティティを作成
   *
   * @param paramMap カラム名とカラム値のマップ
   * @return エンティティ
   */
  @Override
  public Object createEntity(Map<String, Object> paramMap) {
    return EntityCreatorUtil.createEntity(MstPersonalUser.class, paramMap);
  }

  /**
   * 電文から抽出した項目をチェックおよび編集（新規登録時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap) {
    //-------------------------
    // 必須チェック
    //-------------------------
    // 一意キー扱いなので、必ず設定されていることをチェック
    // 施設コード
    CheckNecessaryParamUtil.checkRequired("facility_cd", paramMap);
    // 院内コード1
    CheckNecessaryParamUtil.checkRequired("in_hospital_cd_1", paramMap);

    // デフォルト値設定
    // 削除フラグ
    paramMap.putIfAbsent("is_del", JournalConvertConstants.LOGICAL_DELETE_FLAG_OFF);
    // 表示フラグ
    paramMap.putIfAbsent("is_disp", JournalConvertConstants.LOGICAL_DELETE_FLAG_ON);
    // 管理者への表示許可
    paramMap.putIfAbsent("info_disp_to_admin", JournalConvertConstants.LOGICAL_DELETE_FLAG_OFF);
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

    // 更新対象のカラムで値が連携されていない場合
    // 既存レコードの値を設定する
    copyUpdateColumns(paramMap, entity);
  }

  /**
   * 暗号化対象の更新カラムをコピーする
   * ※entityの値は復号化されていることを前提としている.
   *   復号化されていない値を設定するとその状態で暗号化されるので注意.
   *   Columns定義のカラムは必ず値を設定すること.
   * @param paramMap mst_personal_userに対応するマップ
   * @param entity mst_personal_userの既存レコード
   * */
  private void copyUpdateColumns(Map<String, Object> mpuMap, Object entity) {

    if (entity == null) {
      // 既存レコードがない場合は何もしない
      return;
    }

    MstPersonalUser mpu = (MstPersonalUser) entity;

    // 利用者名_姓
    if (StringUtils.isEmpty(mpuMap.get(Columns.USER_LAST_NAME.getKey()))) {
      mpuMap.put(Columns.USER_LAST_NAME.getKey(), mpu.getUserLastName());
    }
    // 利用者名_名
    if (StringUtils.isEmpty(mpuMap.get(Columns.USER_FIRST_NAME.getKey()))) {
      mpuMap.put(Columns.USER_FIRST_NAME.getKey(), mpu.getUserFirstName());
    }
    // 利用者カナ名_姓
    if (StringUtils.isEmpty(mpuMap.get(Columns.USER_LAST_NAME_KANA.getKey()))) {
      mpuMap.put(Columns.USER_LAST_NAME_KANA.getKey(), mpu.getUserLastNameKana());
    }
    // 利用者カナ名_名
    if (StringUtils.isEmpty(mpuMap.get(Columns.USER_FIRST_NAME_KANA.getKey()))) {
      mpuMap.put(Columns.USER_FIRST_NAME_KANA.getKey(), mpu.getUserFirstNameKana());
    }
    // 利用者カナ名_姓
    if (StringUtils.isEmpty(mpuMap.get(Columns.USER_LAST_NAME_ALPHA.getKey()))) {
      mpuMap.put(Columns.USER_LAST_NAME_ALPHA.getKey(), mpu.getUserLastNameAlpha());
    }
    // 利用者カナ名_名
    if (StringUtils.isEmpty(mpuMap.get(Columns.USER_FIRST_NAME_ALPHA.getKey()))) {
      mpuMap.put(Columns.USER_FIRST_NAME_ALPHA.getKey(), mpu.getUserFirstNameAlpha());
    }
    // メールアドレス1
    if (StringUtils.isEmpty(mpuMap.get(Columns.USER_EMAIL_ADDRESS_1.getKey()))) {
      mpuMap.put(Columns.USER_EMAIL_ADDRESS_1.getKey(), mpu.getUserEmailAddress1());
    }
    // メールアドレス2
    if (StringUtils.isEmpty(mpuMap.get(Columns.USER_EMAIL_ADDRESS_2.getKey()))) {
      mpuMap.put(Columns.USER_EMAIL_ADDRESS_2.getKey(), mpu.getUserEmailAddress2());
    }
    // 内線番号
    if (StringUtils.isEmpty(mpuMap.get(Columns.EXTENSION_NO.getKey()))) {
      mpuMap.put(Columns.EXTENSION_NO.getKey(), mpu.getExtensionNo());
    }
    // 自宅番号
    if (StringUtils.isEmpty(mpuMap.get(Columns.HOME_NO.getKey()))) {
      mpuMap.put(Columns.HOME_NO.getKey(), mpu.getHomeNo());
    }
    // 携帯番号
    if (StringUtils.isEmpty(mpuMap.get(Columns.MOBILE_PHONE_NO.getKey()))) {
      mpuMap.put(Columns.MOBILE_PHONE_NO.getKey(), mpu.getMobilePhoneNo());
    }
    // FAX
    if (StringUtils.isEmpty(mpuMap.get(Columns.FAX_NO.getKey()))) {
      mpuMap.put(Columns.FAX_NO.getKey(), mpu.getFaxNo());
    }
    // 郵便番号3
    if (StringUtils.isEmpty(mpuMap.get(Columns.ZIPCD_3.getKey()))) {
      mpuMap.put(Columns.ZIPCD_3.getKey(), mpu.getZipcd3());
    }
    // 郵便番号4
    if (StringUtils.isEmpty(mpuMap.get(Columns.ZIPCD_4.getKey()))) {
      mpuMap.put(Columns.ZIPCD_4.getKey(), mpu.getZipcd4());
    }
    // 自宅住所
    if (StringUtils.isEmpty(mpuMap.get(Columns.ADDRESS.getKey()))) {
      mpuMap.put(Columns.ADDRESS.getKey(), mpu.getAddress());
    }
    // 自宅住所かな
    if (StringUtils.isEmpty(mpuMap.get(Columns.ADDRESS_KANA.getKey()))) {
      mpuMap.put(Columns.ADDRESS_KANA.getKey(), mpu.getAddressKana());
    }
    // 職種コード
    if (StringUtils.isEmpty(mpuMap.get(Columns.JOB_CD.getKey()))) {
      mpuMap.put(Columns.JOB_CD.getKey(), mpu.getJobCd());
    }
    // 院内コード1
    if (StringUtils.isEmpty(mpuMap.get(Columns.IN_HOSPITAL_CD_1.getKey()))) {
      mpuMap.put(Columns.IN_HOSPITAL_CD_1.getKey(), mpu.getInHospitalCd_1());
    }
    // 院内コード2
    if (StringUtils.isEmpty(mpuMap.get(Columns.IN_HOSPITAL_CD_2.getKey()))) {
      mpuMap.put(Columns.IN_HOSPITAL_CD_2.getKey(), mpu.getInHospitalCd_2());
    }
    // 麻薬施用者免許証番号
    if (StringUtils.isEmpty(mpuMap.get(Columns.ANESTHESIOLOGIST_LICENSE_NO.getKey()))) {
      mpuMap.put(Columns.ANESTHESIOLOGIST_LICENSE_NO.getKey(), mpu.getAnesthesiologistLicenseNo());
    }
  }
}
