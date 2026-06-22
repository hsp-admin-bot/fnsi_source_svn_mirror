package jp.co.nikkiso.ntss.api.service;

import jp.co.nikkiso.ntss.core.entity.SysDailyNo;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * {@link SysDailyNoService}の実装クラス.
 */
@Service
public class SysDailyNoServiceImpl implements SysDailyNoService {
  //del #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
//  /**
//   * 受付番号採番情報のDaoインタフェース.
//   */
//  @Autowired
//  private SysDailyNoDao sysDailyNumberDao;
//
//  /** Clockラッパークラス */
//  @Autowired
//  private ApiClockWrapper clockWrapper;
//
//  /** 採番初期値 */
//  private static final Long INITIAL_CURRENT_NO = 0L;
//
//  /** 採番開始値 */
//  private static final Long START_CURRENT_NO = 1L;
//
//  // add 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 start
//  /** 採番の最大待ち時間(ミリ秒) （30分）*/
//  private static final int SLEEP_MAX_TIME = 1000*60*30;
//
//  /** 採番の待ち時間(ミリ秒) */
//  private static final int SLEEP_TIME = 500;
//  // add 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 end
  //del #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end

  //add #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
  @Autowired
  private JdbcTemplate jdbcTemplate;
  //add #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end

  //del #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
//  /**
//   * 引数の施設コード、採番種別で本日の受付番号を採番して返却する.
//   *
//   * @param facilityCd 施設コード
//   * @param numberingCd 採番種別
//   * @param baseDate 基準日
//   * @return 採番した受付番号
//   */
//  @Transactional(rollbackFor=Exception.class)
//  @Override
//  public Long numberingReception(String facilityCd, String numberingCd) {
//
//    Long retCurrentNo = 0l;
//
//    // add 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 start
//    int timeTotal = 0;
//    do {
//      // add 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 end
//      Timestamp now = new Timestamp(clockWrapper.getClockMillis());
//
//      Calendar nowCalendar = Calendar.getInstance();
//      nowCalendar.setTimeInMillis(now.getTime());
//      int nowDate = nowCalendar.get(Calendar.DATE);
//
//      // 指定の施設コード、採番種別で機能別日次採番マスタのデータリスト（1～31）を取得
//      SysDailyNo sysDailyNo = sysDailyNumberDao.selectDateList(facilityCd, numberingCd);
//
//      if (sysDailyNo == null) {
//        // 取得できなかった場合は、レコードを作成する。（当日分はCURRENT_NO:1、それ以外は0）
//        sysDailyNo = new SysDailyNo();
//        sysDailyNo.setFacilityCd(facilityCd);
//        sysDailyNo.setNumberingCd(numberingCd);
//        sysDailyNo.setIsDisp(ApiConstant.FlagType.FLAG_ON);
//        sysDailyNo.setIsDel(ApiConstant.FlagType.FLAG_OFF);
//        sysDailyNo.setUpDate(now);
//        sysDailyNo.setRegDate(now);
//        List<SysDailyNo.InnerCurrentNo> innerCurrentNoList = new ArrayList<SysDailyNo.InnerCurrentNo>();
//
//        for (int i = 1; i <= ApiConstant.MONTH_DAYS; i++) {
//          SysDailyNo.InnerCurrentNo innerCurrentNo = new SysDailyNo.InnerCurrentNo();
//          innerCurrentNo.setDate(String.valueOf(i));
//          innerCurrentNo.setCurrentNo(nowDate == i ? String.valueOf(START_CURRENT_NO) : String.valueOf(INITIAL_CURRENT_NO));
//          innerCurrentNo.setUpDate(now.toString());
//          innerCurrentNoList.add(innerCurrentNo);
//        }
//        SysDailyNo.CurrentNo currentNo = new SysDailyNo.CurrentNo();
//        currentNo.setCurrentNo(innerCurrentNoList);
//        sysDailyNo.setCurrentNo(currentNo);
//
//        // mod 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 start
////          sysDailyNumberDao.insert(sysDailyNo);
////          retCurrentNo = START_CURRENT_NO;
//        int insCnt = sysDailyNumberDao.insert(sysDailyNo);
//        if (insCnt != 0) {
//          retCurrentNo = START_CURRENT_NO;
//          // 採番正常の場合、ループを終了します。
//          break;
//        }
//        // mod 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 end
//      } else {
//
//        // add 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 start
//        // チェック更新日時
//        Timestamp checkUpDate = sysDailyNo.getUpDate();
//        // add 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 end
//
//        // 取得できた場合は当日分の採番値を更新
//        for (SysDailyNo.InnerCurrentNo innerCurrentNo : sysDailyNo.getCurrentNo().getCurrentNo()) {
//
//          if (!String.valueOf(nowDate).equals(innerCurrentNo.getDate())) {
//            // 当日分でない場合はパスする。
//            continue;
//          }
//
//          Timestamp innerUpDate = Timestamp.valueOf(innerCurrentNo.getUpDate());
//          // 現在日付とcurrent_no内のup_dateの日付が一致したらcurrent_noをインクリメント、一致しなかったら１に巻き戻し
//          if (DateUtils.truncatedCompareTo(now, innerUpDate, Calendar.DAY_OF_MONTH) == 0) {
//            int currentNo = Integer.parseInt(innerCurrentNo.getCurrentNo());
//            currentNo++;
//            innerCurrentNo.setCurrentNo(String.valueOf(currentNo));
//          } else {
//            innerCurrentNo.setCurrentNo(String.valueOf(START_CURRENT_NO));
//          }
//          innerCurrentNo.setUpDate(now.toString());
//          retCurrentNo = Long.valueOf(innerCurrentNo.getCurrentNo());
//        }
//
//        // mod 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 start
////        sysDailyNumberDao.updateByCtlNo(sysDailyNo);
//        sysDailyNo.setUpDate(now);
//        int updCnt = sysDailyNumberDao.updateByCtlNo(sysDailyNo, checkUpDate);
//        if (updCnt != 0) {
//          // 採番正常の場合、ループを終了します。
//          break;
//        }
//        // mod 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 end
//      }
//      // add 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 start
//      ThreadSleep(SLEEP_TIME);
//      timeTotal = timeTotal + SLEEP_TIME;
//      retCurrentNo = 0L;
//      sysDailyNo = null;
//    } while (timeTotal <= SLEEP_MAX_TIME);
//
//    if (0L == retCurrentNo) {
//      throw new NtssException("施設[" + facilityCd +"]採番種別[" + numberingCd + "]で受付番号を採番に失敗しました。[最大採番時間を超える。]");
//    }
//    // add 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 end
//    return retCurrentNo;
//  }
  //del #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end

  //add #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
  @Transactional(rollbackFor=Exception.class)
  @Override
  // #7304 mod 異なる連携の機能を組み合わせて使用する方法 荘 2024-07-19 start
  // public Long getAcceptNo(String facilityCd, String numberingCd, String baseDate) {
  public Long getAcceptNo(String facilityCd, String numberingCd, String baseDate, String coopVersion) {
    // #7304 mod 異なる連携の機能を組み合わせて使用する方法 荘 2024-07-19 start
    Integer res = 0;
    try {
      StringBuffer setSql = new StringBuffer();
      setSql.append("WITH updated_result AS (");
      setSql.append("    UPDATE sys_daily_no ");
      setSql.append("        SET up_date = CURRENT_TIMESTAMP, ");
      setSql.append("            current_no = current_no + 1 ");
      setSql.append("        WHERE facility_cd = ? ");
      setSql.append("            AND numbering_cd = ? ");
      setSql.append("            AND base_date = ? ");
      // #7304 add 異なる連携の機能を組み合わせて使用する方法 荘 2024-07-19 start
      setSql.append("            AND coop_version = ? ");
      // #7304 add 異なる連携の機能を組み合わせて使用する方法 荘 2024-07-19 end
      setSql.append("            AND is_del = '0' ");
      setSql.append("        RETURNING *), ");
      setSql.append("insert_result AS (");
      setSql.append("    INSERT INTO sys_daily_no (");
      // #7304 mod 異なる連携の機能を組み合わせて使用する方法 荘 2024-07-19 start
      // setSql.append("        facility_cd, numbering_cd, current_no, is_disp, is_del, up_date, reg_date, base_date");
      setSql.append("        facility_cd, numbering_cd, current_no, is_disp, is_del, up_date, reg_date, base_date, coop_version");
      setSql.append("    ) ");
      // setSql.append("    SELECT ?, ?, 1, '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, ? ");
      setSql.append("    SELECT ?, ?, 1, '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, ?, ? ");
      // #7304 mod 異なる連携の機能を組み合わせて使用する方法 荘 2024-07-19 end
      setSql.append("    WHERE NOT EXISTS (SELECT 1 FROM updated_result)");
      setSql.append("    RETURNING * ");
      setSql.append(") ");
      setSql.append("SELECT * FROM insert_result ");
      setSql.append("UNION ");
      setSql.append("SELECT * FROM updated_result");
      // #7304 mod 異なる連携の機能を組み合わせて使用する方法 荘 2024-07-19 start
      // Object[] params = {facilityCd, numberingCd, baseDate, facilityCd, numberingCd, baseDate};
      Object[] params = {facilityCd, numberingCd, baseDate, coopVersion, facilityCd, numberingCd, baseDate, coopVersion};
      // #7304 mod 異なる連携の機能を組み合わせて使用する方法 荘 2024-07-19 end
      SysDailyNo sysDailyNo = jdbcTemplate.queryForObject(setSql.toString(), params, new MyEntityRowMapper());
      if(sysDailyNo != null){
        res = sysDailyNo.getCurrentNo();
      }
    }catch (Exception e){
      throw new NtssException("施設[" + facilityCd +"]採番種別[" + numberingCd + "]で受付番号を採番に失敗しました。");
    }

    return (long) res;
  }

  static class MyEntityRowMapper implements RowMapper<SysDailyNo> {
    @Override
    public SysDailyNo mapRow(ResultSet rs, int rowNum) throws SQLException {
      SysDailyNo entity = new SysDailyNo();
      entity.setCurrentNo(rs.getInt("current_no"));
      return entity;
    }
  }
  //add #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end

  //del #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
  // add 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 start
//  /**
//   * Sleep
//   *
//   * @param millis
//   * @return void
//   */
//  private void ThreadSleep(int millis) {
//    try {
//      Thread.sleep(millis);
//    } catch (InterruptedException e) {
//      e.printStackTrace();
//    }
//  }
  // add 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 end
  //del #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end
}
