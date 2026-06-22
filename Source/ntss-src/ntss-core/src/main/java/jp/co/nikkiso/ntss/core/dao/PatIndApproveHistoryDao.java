package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.PatIndApproveHistory;


/**
 * 指示受け・承認詳細のDaoインタフェース
 */
@ConfigAutowireable
@Dao
public interface PatIndApproveHistoryDao {

  /**
   * 指示受け・承認詳細作成
   * @param patIndApprove 指示受け・承認詳細
   * @return 挿入件数
   */
  @Insert
  public int insertPatIndHistory(PatIndApproveHistory patIndApprove);

  /**
   * オーダ番号により指示受け・承認詳細取得
   * @param ordNo オーダ番号
   * @param kind 指示受け承認区分
   * @param orderBy でソート
   * @return 指示受け・承認詳細のリスト
   */
  @Select
  public List<PatIndApproveHistory> findByOrdNo(Long ordNo, String kind, String orderBy);

  /**
   * オーダ番号により変更後指示受け承認者取得
   * @param ordNo オーダ番号
   * @param approveKind 指示受け承認区分
   * @return 変更後指示受け承認者
   */
  @Select 
  Long findApproveAftIdByOrdNo(Long ordNo, String approveKind);

  /**
   * 指示受け・承認詳細数取得
   * @param ordNo オーダ番号
   * @param kind 指示受け承認区分
   * @return 指示受け・承認詳細数
   */
  @Select 
  Long findTotalElements(Long ordNo, String kind);
}
