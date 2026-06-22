package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.custom.MstPrinter;

@ConfigAutowireable
@Dao
public interface MstPrinterDao {

  /**
   * 指定された施設コードに一致するプリンターマスタを取得します.
   *
   * @param facilityCd 施設コード
   * @return プリンタ
   */
  @Select
  List<jp.co.nikkiso.ntss.core.entity.MstPrinter> selectByFacilityCd(String facilityCd);

  /**
   * 指定されたプリンターコードに一致するプリンターマスタを取得します.
   *
   * @param printerCd プリンターコード
   * @return プリンタ
   */
  @Select
  jp.co.nikkiso.ntss.core.entity.MstPrinter selectByPrinterCd(Long printerCd);

  /**
   * 指定された施設コード, クライアント識別子の全てのレコードの削除フラグをONにする.
   * @param entity プリンターマスタエンティティ
   * @return
   */
  @Update(sqlFile = true)
  int updateIsDelOn(MstPrinter entity);

  /**
   * プリンターを追加する.
   * @param entity プリンターマスタエンティティ
   * @param printerNames プリンター名
   * @return
   */
  @Insert(sqlFile = true)
  int insert(MstPrinter entity, List<MstPrinter> printerNames);

  /**
   * 指定されたプリンター以外の削除フラグをONにする.
   * @param entity
   * @param printerNames 削除フラグをONにしないプリンター
   * @return
   */
  @Update(sqlFile = true)
  // mod 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
  //int updateIsDelOnOnlyDeleted(MstPrinter entity, List<String> printerNames);
  int updateIsDelOnOnlyDeleted(MstPrinter entity, String printerNames);
  // mod 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 end

  /**
   * 指定された[施設コード + クライアントキー]に一致するプリンターマスタを取得します.
   * @param facilityCd 施設コード
   * @param clientKey クライアント識別子
   * @return プリンタ
   */
  @Select
  List<jp.co.nikkiso.ntss.core.entity.MstPrinter> selectByClientKey(String facilityCd, String clientKey);

  // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
  /**
   * 指定されたプリンターCD, クライアント識別子を更新します.
   * @param printerCd プリンターCD
   * @param clientKey クライアント識別子
   * @return
   */
  @Update(sqlFile = true)
  int updateclientKey(String printerCd, String clientKey);

  /**
   *指定された[施設コード]に一致するプリンターマスタを取得します.
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  List<jp.co.nikkiso.ntss.core.entity.MstPrinter> getPrinters(String facilityCd);

  /**
   * 指定されたプリンタ名に一致するクライアント識別子を取得します.
   * @param entity
   * @param printerNames プリンタ名
   * @return
   */
  @Select
  List<jp.co.nikkiso.ntss.core.entity.MstPrinter> selectByPrinterNames(MstPrinter entity, List<String> printerNames);

  /**
   *指定された[施設コード]に一致するプリンターを取得します.
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  List<jp.co.nikkiso.ntss.core.entity.MstPrinter> selectByFacilityCdALL(String facilityCd);

  /**
   * 指定された施設コード, クライアント識別子の全てのレコードの削除フラグをOFFにする.
   * @param entity プリンターマスタエンティティ
   * @return
   */
  @Update(sqlFile = true)
  int updateIsDelOff(MstPrinter entity);

  /**
   * 指定されたプリンターCD, クライアント識別子のレコードの削除フラグをOnにする.
   * @param printerCd プリンターCD
   * @return
   */
  @Update(sqlFile = true)
  // mod FNSI-4749 不要プリンターの削除機能対応 夏 start
//  int updateIsDelOnByPrinterCd(String printerCd);
  int updateIsDelOnByPrinterCd(String printerCd, String clientKey);
  // mod FNSI-4749 不要プリンターの削除機能対応 夏 end
  // add 2020-09-23 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
}
