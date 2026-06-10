/**
 * add FNSI-「幹対応残課題一覧.xlsx」№10対応 田
 */
package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.PatRadMainHst;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

@ConfigAutowireable
@Dao
public interface PatRadMainHstDao {

  /**
   * 放射線検査依頼を保存(追加).
   * @param patRadMain PatRadMainのEntity
   * @return 更新件数
   */
  @Insert
  int insertOrderRadSetInfo(PatRadMainHst patRadMainhst);


  // add 2022-01-18 課題No.37:オーダ番号につてい再対応 孫 start
  @Select
  PatRadMainHst selectByPatIdAndRegRadDateAndFacilityCdForNew(Long patId, String regRadDate, String facilityCd);
  // add 2022-01-18 課題No.37:オーダ番号につてい再対応 孫 end
}
