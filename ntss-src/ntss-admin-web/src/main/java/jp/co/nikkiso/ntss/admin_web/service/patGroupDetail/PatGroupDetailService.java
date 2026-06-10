package jp.co.nikkiso.ntss.admin_web.service.patGroupDetail;

import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.RequestBody;

import jp.co.nikkiso.ntss.core.entity.PatGroupDetail;
import jp.co.nikkiso.ntss.core.entity.custom.PatGroupCustom;

/**
 * 患者グループ詳細のServiceインタフェース.
 */
public interface PatGroupDetailService {

	/**
	 * 患者IDで患者グループ詳細の習得
	 * 
	 * @param patId
	 * @return
	 */
	List<PatGroupDetail> selectByPatId(Long patId);

	/**
	 * 患者グループIDで詳細の習得
	 * 
	 * @param patGroupCd
	 * @param facilityCd
	 * @return
	 */
	List<PatGroupDetail> selectByPatGroupCd(Long patGroupCd, String facilityCd);

	/**
	 * 患者グループIDでグループの削除
	 * 
	 * @param patGroupId
	 */
	void deleteByPatGroupId(Long patGroupId);

	/**
	 * 患者IDでグループ詳細の更新
	 * 
	 * @param patId
	 * @param payload
	 * @throws Exception
	 */
	void updateByPatId(Long patId, @RequestBody Map<String, String> payload) throws Exception;

	/**
	 * グループ詳細の登録
	 * 
	 * @param patGroupDetail
	 */
	void insert(PatGroupDetail patGroupDetail);

	/**
	 * 患者IDでグループリストの習得
	 * 
	 * @param patId
	 * @return
	 */
	List<PatGroupCustom> selectPatGroupByPatId(Long patId);
}
