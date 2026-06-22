package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.util.Map;

import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.utils.EntityCreatorUtil;
import jp.co.nikkiso.ntss.core.entity.OrdCoopNo;

/**
 * 電文から抽出した項目に基づき、{@link OrdCoopNo}エンティティを作成するクラス。
 */
@Component
public class OrdCoopNoLogic implements EntityLogic {

  /**
   * マップからエンティティを作成する。
   *
   * @param paramMap カラム名とカラム値のマップ
   * @return エンティティ
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#createEntity(java.util.Map)
   */
  @Override
  public Object createEntity(Map<String, Object> paramMap) {
    return EntityCreatorUtil.createEntity(OrdCoopNo.class, paramMap);
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
    // 未使用
  }

  /**
   * 電文から抽出した項目をチェックおよび編集する。（更新時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @param entity OrdMainエンティティ
   * @see jp.co.nikkiso.ntss.coop_api.entityLogic.EntityLogic#check(java.lang.String, java.util.Map, Object)
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap, Object entity) {
    // 未使用
  }
}
