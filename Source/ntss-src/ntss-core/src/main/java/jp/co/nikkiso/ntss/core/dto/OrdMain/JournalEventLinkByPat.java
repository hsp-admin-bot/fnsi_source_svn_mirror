package jp.co.nikkiso.ntss.core.dto.OrdMain;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class JournalEventLinkByPat {
  /**
   * Map用Key(施設コード+患者ID)
   */
  private String uniqueKey;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * 患者番号(電子カルテ連携システム用)
   */
  private String hospPatId;

  /**
   * 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント治療日のリスト
   */
  List<String> toBeDEventTreatDateList = new ArrayList<>();
  /**
   * 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベントクールのリスト
   */
  List<Integer> toBeDEventTreatDateKurList = new ArrayList<>();
  /**
   * 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント除外キーのリスト(patExamMain)
   */
  List<Long> toBeDEventExcludeExamKeyList = new ArrayList<>();
  /**
   * 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント除外キーのリスト(patRadMain)
   */
  List<Long> toBeDEventExcludeRadKeyList = new ArrayList<>();

  /**
   * 治療予定が登録　または　クールが未登録→指定へ　変更した場合、発行すべきCイベント治療日のリスト
   */
  List<String> toBeCEventTreatDateList = new ArrayList<>();

  /**
   * 治療予定が登録　または　クールが未登録→指定へ　変更した場合、発行すべきCイベントクールのリスト
   */
  List<Integer> toBeCEventTreatDateKurList = new ArrayList<>();
  /**
   * 治療予定が登録　または　クールが未登録→指定へ　変更した場合、発行すべきCイベント除外キーのリスト(patExamMain)
   */
  List<Long> toBeCEventExcludeExamKeyList = new ArrayList<>();
  /**
   * 治療予定が登録　または　クールが未登録→指定へ　変更した場合、発行すべきCイベント除外キーのリスト(patRadMain)
   */
  List<Long> toBeCEventExcludeRadKeyList = new ArrayList<>();

  /**
   * 治療予定が　変更した場合、発行すべきUイベント治療日のリスト
   */
  List<String> toBeUEventTreatDateList = new ArrayList<>();
  /**
   * 治療予定が　変更した場合、発行すべきUイベントクールのリスト
   */
  List<Integer> toBeUEventTreatDateKurList = new ArrayList<>();
  /**
   * 治療予定が　変更した場合、発行すべきUイベント除外キーのリスト(patExamMain)
   */
  List<Long> toBeUEventExcludeExamKeyList = new ArrayList<>();
  /**
   * 治療予定が　変更した場合、発行すべきUイベント除外キーのリスト(patRadMain)
   */
  List<Long> toBeUEventExcludeRadKeyList = new ArrayList<>();
}
