package jp.co.nikkiso.ntss.core.dto.PatIndApproveHistory;

import java.util.ArrayList;
import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 指示受け・承認詳細
 */
@NoArgsConstructor
@Getter
@Setter
public class PatIndApproveHistoryDTO {
  /**
   * オーダ番号のリスト
   */
  private List<Long> ordNo = new ArrayList<Long>();

  /**
   * 操作者
   */
  private Long userId;

  /**
   * 指示受け承認区分のリスト
   */
  private List<Long> approveKind = new ArrayList<Long>();

  /**
   * 変更後指示受け承認者のリスト
   */
  private List<Long> approveAftId = new ArrayList<Long>();

  /**
   * 登録区分のリスト
   */
  private List<String> signType = new ArrayList<String>();

  //add #9507 一括指示受けに時間がかかる zrx start
  /**
   * 施設コー
   */
  private String facilityCd;
  /**
   * 指示受け1
   */
  private String unchecked1Indications;
  /**
   * 指示受け２
   */
  private String unchecked2Indications;
  /**
   * 指示承認1
   */
  private String unapproved1Indications;
  /**
   * 指示承認２
   */
  private String unapproved2Indications;
  //add #9507 一括指示受けに時間がかかる zrx end
}
