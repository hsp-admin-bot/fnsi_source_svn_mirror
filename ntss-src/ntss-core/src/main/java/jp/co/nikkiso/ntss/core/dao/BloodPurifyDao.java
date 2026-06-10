package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstMachine;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.custom.BPOrdInfo;

@ConfigAutowireable
@Dao
public interface BloodPurifyDao {
  /**
   * 浄化装置,または日機装透析装置の透析情報を取得する.
   * @param facilityCd 施設コード.
   * @param treatDate YYYYMMDD形式の治療開始日.
   * @param isNkkDevice 対象が日機装装置ならばtrue
   * @return 浄化装置通信アプリ用の透析情報エンティティ.
   */
  @Select
  List<BPOrdInfo> selectOrdInfoForBloodPurifyDevice(String facilityCd, String treatDate, boolean isNkkDevice);

  // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 start
  /**
   * 装置マスタから必要な装置情報を取得する.
   * @param facilityCd 施設コード.
   * @return 浄化装置通信アプリ用の装置情報エンティティ.
   */
  @Select
  List<MstMachine> selectDialysisDevice(String facilityCd);
  // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 end
}
