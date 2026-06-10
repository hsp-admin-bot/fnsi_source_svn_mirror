package jp.co.nikkiso.ntss.admin_web.service.linkageDefinitionCreateion;

import java.util.List;
import java.util.Map;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import jp.co.nikkiso.ntss.core.entity.MstCoopDistribute;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.MstCoopFilename;
import jp.co.nikkiso.ntss.core.entity.SysDataSet;
import jp.co.nikkiso.ntss.core.entity.MstCoopApilink;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;

/**
 * リンケージ定義作成サービス
 *
 */
public interface LinkageDefinitionCreationService {

	/** mst_coop_layout */
	/* すべてのMstCoopLayoutを選択します */
	Page<MstCoopLayout> selectAllMstCoopLayout(Pageable pageable);

	/* MstCoopLayoutをCtlNoで選択します  */
	MstCoopLayout selectMstCoopLayoutByCtlNo(Long ctlNo);

	/* FacilityCd、CoopCd、CoopCdSubによってMstCoopLayoutを選択します */
	List<MstCoopLayout> selectMstCoopLayoutByFacilityCdOrCoopCdOrCoopCdSub(MstCoopLayout mstCoopLayout) throws Exception;

	/* MstCoopLayoutをCoopNameで選択します */
	Page<MstCoopLayout> selectMstCoopLayoutByCoopName(Pageable pageable, String coop_name);

	/* 最新のMstCoopLayoutのCtlNoを選択します */
	List<String> selectNewestMstCoopLayoutCtlNoByFacilityCd(String facilityCd);

	/* MstCoopLayoutを保存する */
	boolean submitMstCoopLayout(MstCoopLayout mstCoopLayout, final Long userId);

	/** mst_coop_layout_detail */
	/* すべて選択MstCoopLayoutDetail */
	Page<MstCoopLayoutDetail> selectAllMstCoopLayoutDetail(Pageable pageable);

	/* 最新のMstCoopLayoutDetailのCtlNoを選択します */
	List<String> selectNewestMstCoopLayoutDetailCtlNoByFacilityCd(String facilityCd);

	/* CtlNoによってMstCoopLayoutDetailを選択します */
	MstCoopLayoutDetail selectMstCoopLayoutDetailByCtlNo(Long ctlNo);

	/* MstCoopLayoutDetailを保存する */
	boolean submitMstCoopLayoutDetail(MstCoopLayoutDetail mstCoopLayoutDetail, final Long userId);

	/* 最新のMstCoopFilenameのCtlNoを選択します */
	List<String> selectNewestMstCoopFilenameCtlNoByFacilityCd(String facilityCd);

	/* CtlNoによってMstCoopFilenameを選択します */
	MstCoopFilename selectMstCoopFilenameByCtlNo(Long ctlNo);

	/* MstCoopFilenameを保存する */
	boolean submitMstCoopFilename(MstCoopFilename mstCoopFilename, final Long userId);

	/** mst_coop_distribute */
	/* すべてのMstCoopDistributeを選択します */
	Page<MstCoopDistribute> selectALlMstCoopDistribute(Pageable pageable);

	/* CtlNoによってMstCoopDistributeを選択します */
	MstCoopDistribute selectMstCoopDistributeByCtlNo(Long ctlNo);

	/* CtlNo、FacilityCd、coopCd、coopVersionによる選択 */
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  Page<MstCoopDistribute> selectByCtlNoORFacilityCdAndcoopCd(Pageable pageable, Long ctlNo, String facilityCd, String coopCd);
  Page<MstCoopDistribute> selectByCtlNoORFacilityCdAndcoopCd(Pageable pageable, Long ctlNo, String facilityCd,
                                                             String coopCd, String coopVersion);
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

	/* 最新のMstCoopDistributeのCtlNoを取得する */
	List<String> selectNewestMstCoopDistributeCtlNoByFacilityCd(String facilityCd);

	/* MstCoopDistributeを保存する */
	boolean submitMstCoopDistribute(MstCoopDistribute mstCoopDistribute, final Long userId);

	/** mst_coop_facility */

	/* 最新のMstCoopFacilityのCtlNoを取得する */
	List<String> selectNewestMstCoopFacilityCtlNo();

	/* CtlNo、FacilityCdで選択 */
	Page<MstCoopFacility> selectByCtlNoOrFacilityCd(Pageable pageable, Long ctlNo, String facilityCd);

	/* MstCoopFacilityを保存する */
	boolean submitMstCoopFacility(MstCoopFacility mstCoopFacility, Long userId);

	/** sys_data_set */
	/* すべてのSysDataSetを選択 */
	List<SysDataSet> selectAllSysDataSet();

	/* 連携電文設定マスタ詳細を取得する */
	MstCoopLayoutDetail selectMstCoopLayoutDetail(Map<String, String> payload) throws Exception;

	/* 保存 */
	Boolean submit(Map<String, String> payload, Long userId) throws Exception;

	/* Occを保存する */
	Boolean submitOcc(Map<String, String> payload, Long userId) throws Exception;

	/* 連携API関連付けマスタEntityを取得する */
	List<MstCoopApilink> selectMstCoopApilinksByFacility(String facilityCd) throws Exception;

	/* 連携API関連付けマスタEntityを保存する */
	Boolean submitMstCoopApilink(MstCoopApilink mstCoopApilink, Long userId) throws Exception;

	/* 連携施設マスタEntityを取得する */
	List<MstCoopIni> selectMstCoopIniByFacilityCd(String facilityCd);

	/* 連携施設マスタ情報保存 */
	boolean submitMstCoopIni(MstCoopIni mstCoopIni);

	/* 連携をアンインストールする */
	public Boolean UninstallCoop(String facilityCd) throws Exception;
}
