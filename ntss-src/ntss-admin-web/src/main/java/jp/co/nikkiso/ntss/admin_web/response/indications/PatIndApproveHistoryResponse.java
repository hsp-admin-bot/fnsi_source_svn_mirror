package jp.co.nikkiso.ntss.admin_web.response.indications;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.PatIndApproveHistory;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class PatIndApproveHistoryResponse {
  /**
   * 指示受け・承認詳細のリスト
   */
  private List<PatIndApproveHistory> result;

  /**
   * ページ総数
   */
  private Long totalPages;

  /**
   * 全要素
   */
  private Long totalElements;
}
