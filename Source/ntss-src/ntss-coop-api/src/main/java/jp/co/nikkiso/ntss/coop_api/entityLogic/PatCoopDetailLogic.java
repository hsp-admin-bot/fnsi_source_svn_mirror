package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.util.Map;

import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.utils.CheckNecessaryParamUtil;
import jp.co.nikkiso.ntss.coop_api.utils.EntityCreatorUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.core.entity.PatCoopDetail;

/**
 * 電文から抽出した項目に基づき、{@link PatCoopDetail}エンティティを作成するクラス。
 */
@Component
public class PatCoopDetailLogic implements EntityLogic {

  /**
   * マップからエンティティを作成する。
   *
   * @param paramMap カラム名とカラム値のマップ
   * @return エンティティ
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#createEntity(java.util.Map)
   */
  @Override
  public Object createEntity(Map<String, Object> paramMap) {
    return EntityCreatorUtil.createEntity(PatCoopDetail.class, paramMap);
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
    // ### pat_id
    // - 必須項目
    Long patId = (Long) paramMap.get("pat_id");
    CheckNecessaryParamUtil.checkRequired("pat_id", patId);

    // ### facility_cd
    // - 必須項目
    CheckNecessaryParamUtil.checkRequired("facility_cd", facilityCd);

    // ### 連携情報カラム１-１０
    // - 定義されたまま登録
    // ⇒チェック・編集処理不要

    paramMap.putIfAbsent("is_del", JournalConvertConstants.LOGICAL_DELETE_FLAG_OFF);
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
    // pat_coop_detailは上書きのみで、既存レコードを参照しない。
    // そのため、更新用から新規登録用に移譲している。
    check(facilityCd, paramMap);

    PatCoopDetail pcd = (PatCoopDetail) entity;
    paramMap.put("coop_save_no", pcd.getCoopSaveNo());
  }

}
