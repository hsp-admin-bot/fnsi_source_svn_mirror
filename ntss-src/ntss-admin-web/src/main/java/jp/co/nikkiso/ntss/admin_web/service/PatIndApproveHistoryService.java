package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.dto.PatIndApproveHistory.PatIndApproveHistoryDTO;
import jp.co.nikkiso.ntss.core.entity.PatIndApproveHistory;

public interface PatIndApproveHistoryService {
  /**
   * 指示受け・承認詳細作成
   * @param patIndApprove 指示受け・承認詳細
   * @return 挿入件数
   */
  int createHistory(PatIndApproveHistoryDTO patIndApproveHistoryDTO);

  /**
   * オーダ番号により指示受け・承認詳細取得
   * @param ordNo オーダ番号
   * @param page ページネーション
   * @param size ページネーション
   * @param kind 指示受け承認区分
   * @return 指示受け・承認詳細のリスト
   */
  //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx start
//  List<PatIndApproveHistory> findPatIndApproveHistoryByOrdNo(Long ordNo, Long page, Long size, String kind, String sort);
  List<PatIndApproveHistory> findPatIndApproveHistoryByOrdNo(Long ordNo, Long page, Long size, String kind);
  //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx end

  /**
   * 指示受け・承認詳細数取得
   * @param ordNo オーダ番号
   * @param kind 指示受け承認区分
   * @return 指示受け・承認詳細数
   */
  Long findTotalElements(Long ordNo, String kind);
}
