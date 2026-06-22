package jp.co.nikkiso.ntss.admin_web.response.statusList;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.LargeDispListDTO;
import lombok.NoArgsConstructor;

/**
 * 治療状況リスト大画面表示のResponse.
 */
@NoArgsConstructor
public class LargeDispListResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public LargeDispListResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * 透析前患者一覧
   */
  public List<LargeDispListDTO> patList_mode0;
  /**
   * 透析中患者一覧
   */
  public List<LargeDispListDTO> patList_mode1;
  /**
   * 透析後患者一覧
   */
  public List<LargeDispListDTO> patList_mode2;
  /**
   * 透析前穿刺待ち件数
   */
  public int cntPuncWait;
  /**
   * 透析後回収待ち件数
   */
  public int cntReturnWait;
  /**
   * お知らせ
   */
  public List<LargeDisoInfo> info;

  public class LargeDisoInfo {
    /**
     * タイトル
     */
    public String title;
    /**
     * コンテンツ
     */
    public String content;
    /**
     * 記載開始日
     */
    public String startDate;
    /**
     * 記載終了日
     */
    public String endDate;
    /**
     * シーケンス
     */
    public Long bbsCtlNo;
  }

}
