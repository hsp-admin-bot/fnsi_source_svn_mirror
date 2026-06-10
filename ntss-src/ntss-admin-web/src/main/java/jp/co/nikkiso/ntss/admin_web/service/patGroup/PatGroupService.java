package jp.co.nikkiso.ntss.admin_web.service.patGroup;

import java.util.Map;
import org.springframework.web.bind.annotation.RequestBody;
import jp.co.nikkiso.ntss.admin_web.response.patGroup.PatGroupResponse;
import jp.co.nikkiso.ntss.core.entity.PatGroup;

/**
 * 患者グループのServiceインタフェース.
 */
public interface PatGroupService {

	/**
	 * 患者グループの全リストの習得
	 *
	 * @param facilityCd
	 * @return
	 */
	PatGroupResponse getAllPatGroup(String facilityCd);

	/**
	 * 患者グループ情報の取得
	 *
	 * @param facilityCd
	 * @param patGroupCd
	 * @return
	 */
	PatGroup selectPatGroupByCd(String facilityCd, Long patGroupCd);

	/**
	 * 患者グループの作成
	 *
	 * @param payload
	 * @return
	 * @throws Exception
	 */
	long insert(@RequestBody Map<String, String> payload) throws Exception;

	/**
	 * IDで患者グループの更新
	 *
	 * @param patGroupCd
	 * @param payload
	 * @throws Exception
	 */
	void updateById(Long patGroupCd, @RequestBody Map<String, String> payload) throws Exception;

	/**
	 * 患者グループの更新
	 *
	 * @param facilityCd 施設コード
	 * @param patGroup 患者グループ
	 * @throws Exception
	 */
	void updatePatGroupById(String facilityCd, PatGroup patGroup) throws Exception;

	/**
	 * 患者グループの削除
	 *
	 * @param patGroupId
	 * @throws Exception
	 */
	// mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
//	void deleteById(Long patGroupId) throws Exception;
	void deleteById(Long patGroupId, String facilityCd) throws Exception;
	// mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end

  //add FutreNetWeb+SI課題管理 no.4266 劉全航 start
	void registerPatGroupNotification(Map<String, String> payload);
  //add FutreNetWeb+SI課題管理 no.4266 劉全航 end
}
