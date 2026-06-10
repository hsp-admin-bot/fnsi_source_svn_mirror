package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.PatCourseInfo;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstCourse;

@ConfigAutowireable
@Dao
public interface MstCourseDao {
  @Select
  List<MstCourse> selectAll(SelectOptions options, MstCourse params);

  /**
   * 診療科マスタ取得する,包含已经删除数据
   * @param options
   * @param params
   * @return
   */
  @Select
  List<MstCourse> selectAllIncludeDelete(SelectOptions options, MstCourse params);

  /**
   * 診療科コードを指定してすべてのカラムを取得する
   * @param courseCd 診療科コード
   * @return
   */
  @Select
  MstCourse selectByCd(int courseCd);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  @Select
  List<MstCourse> selectAllCourse();
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
//No.7167 upd Paging Optimization runtime by ztc start
  @Select
  List<MstCourse> getMstCourseInfoByFacilityCd(String facilityCd);
  //No.7167 upd Paging Optimization runtime by ztc end
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Select
  List<MstCourse> selectAllName(List<Integer> courseCds);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
  //add 課情報の取得 #12462 患者情報共有 zrx start
  @Select
  List<PatCourseInfo> getCourseByFacilityCdList(List<String> facilityCdList);
  //add 課情報の取得#12462 患者情報共有 zrx end
}
