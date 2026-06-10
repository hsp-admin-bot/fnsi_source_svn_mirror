package jp.co.nikkiso.ntss.api.response.scheduleList;

import jp.co.nikkiso.ntss.core.entity.custom.WeekChangeInfo;
import lombok.Getter;
import lombok.Setter;
import org.json.JSONArray;

import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Getter
@Setter
public class WeekPatternResponse {
  /**
   * 施設コード
   */
  String facilityCd;
  /**
   * 患者ID
   */
  Long patId;
  /**
   * 終了日指定なし
   */
  Boolean isEndDateUnset;
  /**
   * 治療方法
   */
  Integer treatmentCd;
  /**
   * 移動元 曜日
   */
  List<Integer> fromWeekList;
  /**
   * 曜日パターン変更 開始日
   */
  String weekChangeStartDate;
  /**
   * 曜日パターン変更 終了日
   */
  String weekChangeEndDate;
  /**
   * 上書き:1 既存:2
   */
  String footerFlg;
  /**
   * fromWeek → 移動先候補週の一覧
   */
  Map<Integer, List<Integer>> fromWeekCandidatesMap;
  /**
   * fromWeek → 実際に採用する移動先週（自分自身を除外し最小値を採用）
   */
  Map<Integer, Integer> changeWeekMap;

  List<Integer> delWeekList;
}
