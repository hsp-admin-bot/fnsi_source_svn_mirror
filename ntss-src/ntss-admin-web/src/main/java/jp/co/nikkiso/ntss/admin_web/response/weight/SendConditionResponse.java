package jp.co.nikkiso.ntss.admin_web.response.weight;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 条件送信時のResponse.
 */
@NoArgsConstructor
public class SendConditionResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public SendConditionResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * 応答情報.
   */
  public Long weightScaleNo;

  /**
   * 応答情報(レシート印刷用).
   */
  public Long printWeightScaleNo;

  /**
   * 自動印刷が必要ならばTrue
   */
  public boolean isAutoPrint;
  /**
   * 自動印刷が成功していればTrue
   */
  public boolean isSuccessAutoPrint;
  /**
   * 自動印刷エラーメッセージ
   */
  public String autoPrintErrorMessage;
  // add FNSI-分類不一致判断の追加 徐 start
  /**
   * 治療条件未登録MsgList
   */
  public List<String> indCondInfoNoLoginMsgList;

  /**
   * 治療条件上限MsgList
   */
  public List<String> indCondInfoTopLimitMsgList;

  /**
   * 治療条件下限MsgList
   */
  public List<String> indCondInfoLowerLimitMsgList;

  /**
   * IHDF治療条件不整合MsgList
   */
  public List<String> indCondInfoUseIHDFMsgList;

  /**
   * AFBF治療条件不整合MsgList
   */
  public List<String> indCondInfoUseAFBFMsgList;

  /**
   * SN治療条件不整合MsgList
   */
  public List<String> indCondInfoUseSNMsgList;

  /**
   * マスタ削除MsgList
   */
  public List<String> mstDelFlgMsgList;

  /**
   * マスタ削除特殊MsgList
   */
  public List<String> mstDelSpecialMsgList;

  /**
   * マスタ期限切れMsgList
   */
  public List<String> mstOverdueMsgList;
  // add FNSI-分類不一致判断の追加 徐 end
}
