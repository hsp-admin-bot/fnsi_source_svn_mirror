package jp.co.nikkiso.ntss.admin_web.service;


import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.personalUser.NameWithHasEmailResponse;
import jp.co.nikkiso.ntss.admin_web.response.personalUser.UserIdAndUserFullName;
import jp.co.nikkiso.ntss.admin_web.response.personalUser.UserIdAndUserName;

/**
 * 利用者用のServiceインターフェース
 */
public interface PersonalUserService {

  /**
   * 指定された施設に属する利用者の名前と、メールアドレスの登録有無を取得する
   * @param facilityCd 施設コード
   * @return 名前とメールアドレスの登録有無のセット
   */
  NameWithHasEmailResponse getNameAndHasEmailByFacilityCd(String facilityCd);

  /**
   * 指定された施設と処方番号に属する医師の利用者IDと名前のリストを取得する
   * @param facilityCd 施設コード
   * @return 利用者IDと名前のセットのリスト
   */
  List<UserIdAndUserName> getDoctorsByFacilityCd(String facilityCd);

  // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
  List<UserIdAndUserName> getDoctorsByFacilityCdIncludeDel(String facilityCd);
  // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end

  /**
   * 処方箋機能で指定された施設に属する医師の利用者IDと名前のリストを取得する
   * @param facilityCd 施設コード
   * @param ordPrescriptionNo 処方番号 
   * @return 利用者IDと名前のセットのリスト
   */
  List<UserIdAndUserName> getDoctorsPrescriptionByFacilityCd(String facilityCd, Long ordPrescriptionNo);

  /**
   * 医師をチェック
   * @param facilityCd
   * @param user_id
   * @return
   */
  boolean checkDoctor(String facilityCd, Long user_id);

  /**
   * 指定された施設に属する医師の利用者IDと名前のリストを取得する
   * @param facilityCd 施設コード
   * @param viewDeletedUser 削除ユーザーの扱い 0: 含めない 1: 含める 2: 名称を(削除)として含める
   * @return 利用者IDと名前のセットのリスト
   */
  List<UserIdAndUserFullName> getAllUserWithDel(String facilityCd, short viewDeletedUser);
}
