package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstDestinationGroup;

/**
 * 送信先グループマスタのDAOインターフェース
 */
@Dao
@ConfigAutowireable
public interface MstDestinationGroupDao {

  /**
   * 送信先グループマスタの情報を全件取得.
   *
   * @return 警報通知マスタのエンティティリスト
   */
  @Select
  List<MstDestinationGroup> selectAll();

  /**
   * 指定された施設コードに一致する送信先グループマスタを取得します.
   *
   * @param facilityCd 施設コード
   * @return 送信先グループ
   */
  @Select
  List<MstDestinationGroup> selectByFacilityCd(String facilityCd);

  /**
   * 指定された送信先グループコードに一致する送信先グループマスタを取得します.
   *
   * @param destinationGroupCd 送信先グループコード
   * @return 送信先グループ
   */
  @Select
  MstDestinationGroup selectByDestinationGroupCd(Long destinationGroupCd);

  /**
   * メーカー通知の対象となる送信先グループマスタを取得します.
   *
   * @return 送信先グループ
   */
  @Select
  List<MstDestinationGroup> selectByFacilityCdAndIsNotice(String facilityCd);

  /**
   * 送信対象を更新.
   * @param mstUser ユーザーEntity
   * @return 更新件数
   */
  @Update(include = {"destinationTarget", "upDate"})
  int updateDestinationTarget(MstDestinationGroup mstDestinationGroup);
}
