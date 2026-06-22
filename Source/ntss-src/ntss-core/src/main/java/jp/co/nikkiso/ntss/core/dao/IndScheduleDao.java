package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.core.dto.indSchedule.OrdNoAndConnectedTableKeyData;
import jp.co.nikkiso.ntss.core.entity.BbsInfo;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

@ConfigAutowireable
@Dao
//add #10412 次患者更新関連全体見直し対応 朴 start
public interface IndScheduleDao {

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @param excludeOrdNoList
   * @return
   */
  @Select
  List<IndScheduleInfo> selectIndScheduleInfoByIndScheduleList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList, List<Long> excludeOrdNoList);
  /**
   *
   * @param facilityCd
   * @param ordNoList
   * @return
   */
  @Select
  List<IndScheduleInfo> selectIndScheduleInfoByOrdNoList(String facilityCd, List<Long> ordNoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @param excludeOrdNoList
   * @return
   */
  @Select
  List<IndScheduleInfo> selectSamePatDateKurTreatmentByIndScheduleList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList, List<Long> excludeOrdNoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @param excludeOrdNoList
   * @return
   */
  @Select
  List<IndScheduleInfo> selectDupulicateOrdScheduleByIndScheduleList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList, List<Long> excludeOrdNoList);

  /**
   *
   * @param facilityCd
   * @param ordNoList
   * @return
   */
  @Select
  List<OrdNoAndConnectedTableKeyData> selectConnectedPatEventByOrdNoList(String facilityCd, List<Long> ordNoList);

  /**
   *
   * @param facilityCd
   * @param ordNoList
   * @return
   */
  @Select
  List<OrdNoAndConnectedTableKeyData> selectConnectedExamMainCdByOrdNoList(String facilityCd, List<Long> ordNoList);

  /**
   *
   * @param facilityCd
   * @param ordNoList
   * @return
   */
  @Select
  List<OrdNoAndConnectedTableKeyData> selectConnectedRadResultCdByOrdNoList(String facilityCd, List<Long> ordNoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @param indUser
   * @param updUser
   * @param updateRst
   * @return
   */
  @Select
  List<OrdMain> updateOrdMainIndScheduleInfoByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList, MstPersonalUser indUser, MstPersonalUser updUser, String updateRst);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<OrdSchedule> selectForUpdateOrdScheduleMainDataByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<OrdSchedule> updateOrdScheduleMainDataByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);


  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Update(sqlFile = true)
  int insertOrdScheduleDummyByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList, List<IndScheduleInfo> indScheduleInfoList2);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatEvent> selectForUpdatePatEventByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatEvent> updatePatEventByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatEvent> selectForUpdatePatEventToDeleteByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatEvent> updatePatEventToDeleteByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<BbsInfo> selectForUpdateBbsInfoByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<BbsInfo> updateBbsInfoByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);


  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<BbsInfo> selectForUpdateBbsInfoToDeleteByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);


  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<BbsInfo> updateBbsInfoToDeleteByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);


  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatExamMain> selectForUpdatePatExamMainByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);


  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatExamMain> updatePatExamMainByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);


  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatExamMain> insertPatExamMainByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatExamMain> deletePatExamMainToHistoryByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);


  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatRadMain> insertPatRadMainByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatRadMain> selectForUpdatePatRadMainByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatRadMain> updatePatRadMainByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);


  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatRadMain> deletePatRadMainToHistoryByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatIndApprove> selectForUpdatePatIndApproveByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);

  /**
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @return
   */
  @Select
  List<PatIndApprove> updatePatIndApproveByIndSchdueInfoList(String facilityCd, List<IndScheduleInfo> indScheduleInfoList);

//  @Insert(sqlFile = true)
//  int insertOrderExamHstBatch(List<PatExamMainHst> patExamMainHstList);
//
//  @Select
//  List<PatExamMain> deleteByExamMainCdListAndGetDelData(List<Long> examMainCdList);

}
//add #10412 次患者更新関連全体見直し対応 朴 end
