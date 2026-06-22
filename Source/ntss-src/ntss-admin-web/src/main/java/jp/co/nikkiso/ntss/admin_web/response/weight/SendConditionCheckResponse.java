package jp.co.nikkiso.ntss.admin_web.response.weight;

import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 条件送信checkのResponse.
 */
@NoArgsConstructor
public class SendConditionCheckResponse {

  /**
   * 治療条件分類不一致MsgList
   */
  public List<String> msgList;

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
   * Na注入プログラム使用Flg
   */
  public Boolean naInjectionProgramFlg;

  /**
   * シングルニードル使用Flg
   */
  public Boolean singleNeedleFlg;

  /**
   * TMP自動追従使用Flg
   */
  public Boolean tmpAutomaticTrackingFlg;

  /**
   * 装置オプション不整合MsgList
   */
  public List<String> deviceOptionsMsgList;

  /**
   * 特殊浄化MsgFlg
   */
  public Boolean isPurificationMsgFlg;

  /**
   * 補液量と補液速度についてMsgFlg
   */
  public Boolean replenishmentMsgFlg;

  /**
   * 補液量と補液比率についてMsgFlg
   */
  public Boolean replenishmentMsgFlg2;

  /**
   * 補液量と濾過率についてMsgFlg
   */
  public Boolean replenishmentMsgFlg3;

  // add FutreNetWeb+SI課題管理No7195 趙 start
  /**
   * HDF・HF 補液量と補液速度についてMsgFlg
   */
  public Boolean replenishmentMsgFlg4;
  // add FutreNetWeb+SI課題管理No7195 趙 end

  /**
   * 装置モード不一致チェックMsgFlg
   */
  public Boolean deviceModeMismatchMsgFlg;
  //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
  /**
   * 装置モード不一致チェック   -1
   */
  public Boolean deviceModeUnknownMsgFlg;

  /**
   * 特殊浄化MsgFlg   warn
   */
  public Boolean isPurificationWarnMsgFlg;
  //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end

  /**
   * VA方向不一致チェックMsgFlg
   */
  public Boolean vaDirectionInconsistentMsgFlg;

  /**
   * 感染症不一致チェックMsgFlg
   */
  public Boolean infectionNotConsistentMsgFlg;

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
  // add #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou start
  /**
   * BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告Flg
   */
  public Boolean diversionBvufcFlg;
  // add #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou end
}
