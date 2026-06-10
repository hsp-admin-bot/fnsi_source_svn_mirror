package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.entity.custom.PatTreatmentPatternIndIndCommentInfo;

import java.util.HashMap;
import java.util.List;

public interface PatTreatmentPatternService {

  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start

  /**
   * pat_treatment_pattern更新
   * @param facilityCd 施設コード
   * @param userId ユーザID
   * @throws Exception
   */
  void updatePatTreatmentPatternOnceForAll(String facilityCd, Long userId, Long updUserId) throws Exception;
  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
  // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc start
  List<OrdMain> createOrdMainListByUpdateWeek(String facilityCd, PatPersonalMain patPersonalMain, PatMain patMain,
                                  List<PatTreatmentPattern> patTreatmentPatternList, HashMap<Short, List<Short>> changeWeekList,
                                  List<String> missingDateList) throws Exception;
  // add #10307 曜日パターン変更を行うと1年以降の治療予定が作成される 20240306 ztc end

  // add #11731_【因島：改良】指示コメント番号の指定方法 start
  // 指示コメント情報（指示コメント番号で集約）の取得
  List<PatTreatmentPatternIndIndCommentInfo> getIndIndCommentInfo(Long patId, String facilityCd, List<Integer> weeks, List<Integer> treats, List<Long> kurs);
  // add #11731_【因島：改良】指示コメント番号の指定方法 end
}
