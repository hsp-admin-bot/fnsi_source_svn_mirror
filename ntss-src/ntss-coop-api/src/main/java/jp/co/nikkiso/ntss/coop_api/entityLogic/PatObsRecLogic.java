package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.utils.CheckNecessaryParamUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.EntityCreatorUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.core.dao.MstObsKindDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.PatObsRecDao;
import jp.co.nikkiso.ntss.core.entity.MstObsKind;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.PatObsRec;

/**
 * 電文から抽出した項目に基づき、{@link PatObsRec}エンティティを作成するクラス。
 */
@Component
public class PatObsRecLogic implements EntityLogic {

  @Autowired
  private PatObsRecDao patObsRecDao;

  @Autowired
  private MstObsKindDao mstObsKindDao;

  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  @Autowired
  private ClockWrapper clockWrapper;

  /**
   * マップからエンティティを作成する。
   *
   * @param paramMap カラム名とカラム値のマップ
   * @return エンティティ
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#createEntity(java.util.Map)
   */
  @Override
  public PatObsRec createEntity(Map<String, Object> paramMap) {
    return EntityCreatorUtil.createEntity(PatObsRec.class, paramMap);
  }

  /**
   * 電文から抽出した項目をチェックおよび編集する。（新規登録時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#check(java.lang.String, java.util.Map)
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap) {
    checkCommon(facilityCd, paramMap);

    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    paramMap.put("reg_date", now);
  }

  /**
   * 電文から抽出した項目をチェックおよび編集する。（更新時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @param entity 対象テーブルから取得したエンティティ（更新の場合に使用）
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#check(java.lang.String, java.util.Map, java.lang.Object)
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap, Object entity) {
    // pat_obs_recは上書きのみで、既存レコードを参照しない。
    // そのため、他のクラスとは異なり、更新用から新規登録用に移譲している。
    checkCommon(facilityCd, paramMap);
  }

  /**
   * insert/updateの共通チェック処理。
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   */
  private void checkCommon(String facilityCd, Map<String, Object> paramMap) {
    // ### pat_id
    // - 必須項目
    Long patId = (Long) paramMap.get("pat_id");
    CheckNecessaryParamUtil.checkRequired("pat_id", patId);

    // 管理番号
    // 新規の場合は自動採番であるので、obs_rec_noが未設定であることを担保する。
    // 更新の場合は既存レコードと同じobs_rec_noを設定する。
    // ただし、既存レコード内容を登録内容に反映する必要はない。
    PatObsRec patObsRec = patObsRecDao.selectById(patId, facilityCd);
    if (patObsRec != null) {
      paramMap.put("obs_rec_no", patObsRec.getObsRecNo());
    } else {
      paramMap.remove("obs_rec_no");
    }

    // ### facility_cd
    // - 必須項目
    CheckNecessaryParamUtil.checkRequired("facility_cd", facilityCd);

    // ### rec_date（起票日時）
    // - current_timestampを設定（現在のシステム日付でも良いがcurrentがbetter）
    // ⇒現在のシステム日付で良い。（他の処理と合わせる）
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    paramMap.put("rec_date", now);

    // ### kind_info(種別情報)
    // - `mst_obs_kind`(観察記録種別マスタ)と`kind_no`で突き合わせ
    //   付き合わなかった and `kind_info`.`kind_name`がない場合には空jsonを設定
    // マスタとマッチングしなかったが`kind_name`が存在した場合には`kind_name`をそのまま設定する
    checkKindInfo(facilityCd, "kind_info", paramMap);

    // ### reg_staff_info(起票者情報)
    // - `mst_user_authentication`と`facility_cd`,`reg_staff_cd`で突き合わせる
    //   マッチングしなかった場合 and `reg_staff_name`がない場合には空jsonを設定
    // マスタとマッチングしなかったが`reg_staff_name`が存在した場合には`reg_staff_name`のみ設定する
    checkRegStaffInfo(facilityCd, "reg_staff_info", paramMap);
    //

    // ### up_staff_info(編集者情報)
    // - `mst_user_authentication`と`facility_cd`,`up_staff_cd`で突き合わせる<br/>マッチングしなかった場合 and `up_staff_name`がない場合には空jsonを設定
    // マスタとマッチングしなかったが`up_staff_name`が存在した場合には`up_staff_name`のみ設定する
    checkUpStaffInfo(facilityCd, "up_staff_info", paramMap);

    // ### obs_rec_info(観察記録情報)
    // - そのまま登録
    // チェックなし。指定された場合は受信内容で上書きするため、処理不要。

    // ### 掲示板管理番号
    // - 対象外
    // 処理不要。

    // ### is_del, up_date, reg_date
    // 他に倣って登録
    // （pat_personal_main等、BaseEntityを継承していないエンティティのテーブルは独自に設定する必要がある。）
    paramMap.putIfAbsent("is_del", JournalConvertConstants.LOGICAL_DELETE_FLAG_OFF);
    paramMap.put("up_date", now);
  }

  /**
   * kind_info（種別情報）をチェック・
   * 編集する。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名（"kind_info" 固定）
   * @param paramMap 電文から抽出した項目のマップ
   */
  private void checkKindInfo(String facilityCd, String keyName, Map<String, Object> paramMap) {
    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    List<Map<String, Object>> kindInfoList = ObjectMapperUtil.castToStringObjectMapList(paramMap.get(keyName));
    if (CollectionUtils.isEmpty(kindInfoList)) {
      return;
    }

    // pat_obs_rec.kind_infoはマップ1つ分の情報を保持する。
    // 電文で複数件指定された場合は、先頭の値を使用する。
    Map<String, Object> kindInfo = kindInfoList.get(0);

    // - `mst_obs_kind`(観察記録種別マスタ)と`kind_no`で突き合わせる。
    // マッチングしなかった場合 and `kind_info`.`kind_name`がない場合には空jsonを設定
    // マッチングしなかったが`kind_name`が存在した場合には`kind_name`をそのまま設定する
    String kindNoStr = (String) kindInfo.get("kind_no");
    if (StringUtils.isEmpty(kindNoStr)) {
      return;
    }

    Long kindNo = Long.parseLong(kindNoStr);
    List<MstObsKind> mstObsKindList = mstObsKindDao.selectByKindNo(kindNo);

    String kindName = (String) kindInfo.get("kind_name");

    // mst_obs_kind（観察記録種別マスタ）との照合による編集処理
    if (CollectionUtils.isEmpty(mstObsKindList)) {
      if (StringUtils.isEmpty(kindName)) {
        // マスタ照合失敗、かつ、kind_nameが指定されていない場合
        // 空のjsonを設定する。
        kindInfo.clear();
      } else {
        // マスタ照合失敗、かつ、kind_nameが指定されている場合
        // kind_nameとkind_updateはそのまま設定、kind_noは未指定とする。
        kindInfo.remove("kind_no");
      }
    }
    // 照合成功の場合はそのまま登録するので処理不要。
    // （kind_noはmst_obs_kindのプライマリキーであり、条件検索後の置換対象ではない。）
    paramMap.put(keyName, kindInfo);
  }

  /**
   * reg_staff_info（起票者情報）をチェック・編集する。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名（"reg_staff_info" 固定）
   * @param paramMap 電文から抽出した項目のマップ
   */
  private void checkRegStaffInfo(String facilityCd, String keyName, Map<String, Object> paramMap) {
    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    List<Map<String, Object>> regStaffInfoList = ObjectMapperUtil.castToStringObjectMapList(paramMap.get(keyName));
    if (CollectionUtils.isEmpty(regStaffInfoList)) {
      return;
    }

    Map<String, Object> regStaffInfo = regStaffInfoList.get(0);

    // - `mst_user_authentication`と`facility_cd`,`reg_staff_cd`で突き合わせる。
    // マッチングしなかった場合 and `reg_staff_name`がない場合には空jsonを設定する。
    // マスタとマッチングしなかったが`reg_staff_name`が存在した場合には`reg_staff_name`のみ設定する。
    String regStaffCd = (String) regStaffInfo.get("reg_staff_cd");
    MstUserAuthentication mstUserAuthentication = mstUserAuthenticationDao.selectForLogin(regStaffCd, facilityCd);

    String regStaffName = (String) regStaffInfo.get("reg_staff_name");

    if (mstUserAuthentication == null) {
      if (StringUtils.isEmpty(regStaffName)) {
        // マスタ照合失敗、かつ、reg_staff_nameが指定されていない場合
        // 空のjsonを設定する。
        regStaffInfo.clear();
      } else {
        // マスタ照合失敗、かつ、reg_staff_nameが指定されている場合
        // reg_staff_nameとreg_staff_updateはそのまま設定、reg_staff_cdは未指定とする。
        regStaffInfo.remove("reg_staff_cd");
      }
    } else {
      // マスタ照合成功の場合
      // 内部用IDで置換する。
      regStaffInfo.put("reg_staff_cd", mstUserAuthentication.getUserId());
    }

    paramMap.put(keyName, regStaffInfo);
  }

  /**
   * up_staff_info（編集者情報）をチェック・編集する。
   *
   * @param facilityCd 施設コード
   * @param keyName キー名（"up_staff_info" 固定）
   * @param paramMap 電文から抽出した項目のマップ
   */
  private void checkUpStaffInfo(String facilityCd, String keyName, Map<String, Object> paramMap) {
    Object obj = paramMap.get(keyName);
    if (obj == null) {
      return;
    }

    List<Map<String, Object>> upStaffInfoList = ObjectMapperUtil.castToStringObjectMapList(obj);
    if (CollectionUtils.isEmpty(upStaffInfoList)) {
      return;
    }

    Map<String, Object> upStaffInfo = upStaffInfoList.get(0);

    // - `mst_user_authentication`と`facility_cd`,`up_staff_cd`で突き合わせる。
    // マッチングしなかった場合 and `up_staff_name`がない場合には空jsonを設定する。
    // マスタとマッチングしなかったが`up_staff_name`が存在した場合には`up_staff_name`のみ設定する。
    String upStaffCd = (String) upStaffInfo.get("up_staff_cd");
    MstUserAuthentication mstUserAuthentication = mstUserAuthenticationDao.selectForLogin(upStaffCd, facilityCd);

    String upStaffName = (String) upStaffInfo.get("up_staff_name");

    if (mstUserAuthentication == null) {
      if (StringUtils.isEmpty(upStaffName)) {
        // マスタ照合失敗、かつ、up_staff_nameが指定されていない場合
        // 空のjsonを設定する。
        upStaffInfo.clear();
      } else {
        // マスタ照合失敗、かつ、up_staff_nameが指定されている場合
        // up_staff_nameとup_staff_updateはそのまま設定、up_staff_cdは未指定とする。
        upStaffInfo.remove("up_staff_cd");
      }
    } else {
      // マスタ照合成功の場合
      // 内部用IDで置換する。
      upStaffInfo.put("up_staff_cd", mstUserAuthentication.getUserId());
    }

    paramMap.put(keyName, upStaffInfo);
  }

}
