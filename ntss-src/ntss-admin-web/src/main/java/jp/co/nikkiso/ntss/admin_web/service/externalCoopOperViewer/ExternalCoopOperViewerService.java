package jp.co.nikkiso.ntss.admin_web.service.externalCoopOperViewer;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.response.externalCoopOperViewer.SysCoopJournalDetail;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeClientConnect;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeHealthmon;
// add FNSI-連携情報を追加 李 start
import jp.co.nikkiso.ntss.core.entity.ConIntelligenceListmon;
// add FNSI-連携情報を追加 李 end
import jp.co.nikkiso.ntss.core.entity.custom.ExternalCoopPayload;

public interface ExternalCoopOperViewerService {

	/**
	 * 施設コードにより連携エッジヘルスモニタ取得
	 * @param facilityCd 施設コード
	 * @return 連携エッジヘルスモニタのリスト
	 */
	List<MntIfEdgeHealthmon> getMntIfEdgeHealthMonByFacilityCd(String facilityCd) throws Exception;

  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
  /**
   * 施設コードにより連携エッジクライアント接続状態取得
   * @param facilityCd
   * @return
   * @throws Exception
   */
  MntIfEdgeClientConnect getMntIfEdgeClientConn(String facilityCd) throws Exception;
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
  // add FNSI-連携情報を追加 李 start
  /**
   * 施設コードにより連携エッジヘルスモニタ取得
   * @param facilityCd 施設コード
   * @param coopVersion 連携版番号
   * @param selectedPatId 患者番号（システム）
   * @return 連携エッジヘルスモニタのリスト
   */
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  List<ConIntelligenceListmon> getConIntelligenceListByFacilityCd(String facilityCd, String selectedPatId) throws Exception;
  List<ConIntelligenceListmon> getConIntelligenceListByFacilityCd(String facilityCd, String coopVersion,
                                                                  String selectedPatId) throws Exception;
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  // add FNSI-連携情報を追加 李 end

	/**
	 * 外部連携用ジャーナル詳細取得
	 * @param facilityCd 施設コード
	 * @param payload 外部連携
	 * @return 外部連携用ジャーナル詳細のリスト
	 */
	List<SysCoopJournalDetail> getSysCoopJournalByCondition(String facilityCd, ExternalCoopPayload payload) throws Exception;

	/**
	 * 外部連携用ジャーナル詳細を更新
	 * @param sysList 外部連携用ジャーナル詳細のリスト
	 * @return
	 */
	void updateSys(List<SysCoopJournalDetail> sysList) throws Exception;

//  add 5615 IFエッジコマンド実行 関 start
  Map<String, Object> selectEdgeCommand() throws Exception;
//  add 5615 IFエッジコマンド実行 関 end

  // add 8229 外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230129 zhaoqi start
  public void callCreateJournal(String facilityCd,Long ordNo, Long userId, Long patId, String coopCd) throws Exception;
  // add 8229 外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230129 zhaoqi end

  //add #9490 電子カルテアイコンの連携先情報の制御について、2023.8.25 lmf start
  String getHealthmonFacilityConnByOn(String facilityCd);
  //add #9490 電子カルテアイコンの連携先情報の制御について、2023.8.25 lmf end
}
