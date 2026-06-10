package jp.co.nikkiso.ntss.admin_web.service.accessCard;

import jp.co.nikkiso.ntss.core.entity.MntCardappPort;

import java.util.List;

public interface AccessCardService {

  String selectPatInfoWriteCard(Long patId) throws Exception;

  Boolean setAccessCardIdm(String cardIdm, long idm) throws Exception;

  // add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 start
  Boolean setPatCardIdm(String cardIdm, long patId) throws Exception;
  // add 2020-08-13 FNSI-仕様追加 患者基本情報(pat_main)にアクセスカード番号(card_idm)の追加処理 夏 end

  // add 2020-09-25 FNSI-4200ポートを使用している 孫 start
  Boolean updateCarAppPortInfo(MntCardappPort cardAppPortInfo) throws Exception;

  List<Integer> selectByFacility(String facilityCd) throws Exception;
  // add 2020-09-25 FNSI-4200ポートを使用している 孫 end
}
