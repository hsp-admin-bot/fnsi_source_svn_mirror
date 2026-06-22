/**
 * add FNSI-「幹対応残課題一覧.xlsx」№10対応 田
 */
package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.PatExamMainForAllOtherInfo;
import jp.co.nikkiso.ntss.core.entity.PatExamMainHst;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

@ConfigAutowireable
@Dao
public interface PatExamMainHstDao {

  /**
   * 検査依頼をバックアップ(追加).
   * @param patExamMainhst PatExamMainHstのEntity
   * @return 更新件数
   */
  @Insert
  int insertOrderExamHstSetInfo(PatExamMainHst patExamMainhst);

  // add 2022-01-18 課題No.37:オーダ番号につてい再対応 孫 start
  //add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 zhaoqi start
  @Select
  PatExamMainHst selectByPatIdAndRegRadDateAndFacilityCdForNew(Long patId, String regExamDate, String facilityCd, String regOrderClass);
  //add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 zhaoqi end
  // add 2022-01-18 課題No.37:オーダ番号につてい再対応 孫 end

  //mod 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 start
  //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 start
  //mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 start
  @Select
  List<PatExamMainForAllOtherInfo> selectForALlOtherInfo(Long patId, String facilityCd, String baseDate);
  //mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 end
  //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 end
  //mod 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 end

  @Select
  List<PatExamMainForAllOtherInfo> selectForALlOtherInfophy(Long patId, String facilityCd, String baseDate);

  @Select
  PatExamMainHst selectByPatIdAndRegRadDateAndFacilityCdForNewphy(Long patId, String regExamDate, String facilityCd, String regOrderClass);
}

