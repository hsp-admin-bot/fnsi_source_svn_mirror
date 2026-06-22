package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstSelectorToPatGroup;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstSelector;

/**
 * 並び順管理マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstSelectorDao {

  /**
   * 並び順定義取得.
   * 
   * @param facilityCd         施設コード
   * @param masterPhysicalName マスタ物理名
   * @return マスタセレクタエンティティ
   */
  @Select
  MstSelector selectByName(String facilityCd, String masterPhysicalName);

  /**
   * 並び順定義取得.(複数マスタ)
   * 
   * @param facilityCd         施設コード
   * @param masterPhysicalNameList マスタ物理名リスト
   * @return マスタセレクタエンティティリスト
   */
  @Select
  List<MstSelector> selectByNameList(String facilityCd, List<String> masterPhysicalNameList);

  //add #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx start
  @Select
  String selectItemCodesByNameList(String facilityCd);
  //add #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx end

  // add 10389 患者リストのソートが遅い gjn start
  /**
   * @param facilityCd         施設コード
   * @param masterPhysicalNameList マスタ物理名リスト
   * @return マスタセレクタエンティティリスト
   */
  @Select
  List<MstSelectorToPatGroup> selectByNameListToPatGroup(String facilityCd, List<String> masterPhysicalNameList);
  // add 10389 患者リストのソートが遅い gjn end

  /**
   * 並び順定義取得.施設CDは開示先施設
   * 
   * @param facilityCd         施設コード
   * @param masterPhysicalName マスタ物理名
   * @return マスタセレクタエンティティリスト
   */
  @Select
  List<MstSelector> selectListByName(String facilityCd, String masterPhysicalName);

  /**
   * レコードを追加.
   * 
   * @param MstSelector マスタセレクタエンティティ
   * @return 処理件数
   */
  @Insert
  int insert(MstSelector mstSelector);

  /**
   * レコードを更新.
   * 
   * @param MstSelector マスタセレクタエンティティ
   * @return 処理件数
   */
  @Update
  int update(MstSelector mstSelector);

  /**
   * レコード末尾に指定コードと指定名を追加
   * 
   * @param facilityCd 施設コード
   * @param masterPhysicalName マスタ物理名
   * @param setCode 登録コード
   * @param setName 登録名
   *   
  */
  @Update(sqlFile = true)
  int addByOrderSettings(long setCode, String setName,String facilityCd, String masterPhysicalName);

  /**
   * レコード末尾に指定コードと指定名を追加
   * 
   * @param setCode 登録コード
   * @param setName 登録名   
   * @param facilityCd 施設コード
   * @param masterPhysicalName マスタ物理名
   *   
  */
  @Insert(sqlFile = true)
  int insertSelector(long setCode, String setName,String facilityCd, String masterPhysicalName);
  /**
   * レコードを追加
   * 開示元施設のデータも表示するためにjlac10コードを補足
   */
  @Insert
  int insertMstExamItemSelector(MstSelector mstSelector);
  /**
   * レコードを変更
   * 開示元施設のデータも表示するためにjlac10コードを補足
   */
  @Update
  int updateMstExamItemSelector(MstSelector mstSelector);

}
