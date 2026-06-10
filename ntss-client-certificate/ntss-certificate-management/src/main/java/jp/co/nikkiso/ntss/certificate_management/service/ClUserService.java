package jp.co.nikkiso.ntss.certificate_management.service;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.certificate_management.response.clUser.ResponseClUserSetting;
import jp.co.nikkiso.ntss.core.entity.ClUser;

public interface ClUserService {

  /**
   * すべてのユーザーを取得
   *  @param OrderKey 並べ替えキー.
   * @return すべてのユーザーのリスト
   * @throws Exception
   */

  //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
  //List<ClUser> getAllUser() throws Exception;
  List<ClUser> getAllUser(String OrderKey) throws Exception;
  //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
  /**
   * ユーザーを更新
   * @param id ID.
   * @param userName ユーザー名.
   * @param userRole ユーザー役割.
   * @param departmentCd 部門コード.
   * @param userPass ユーザーパスワード.
   * @param upDate 更新日.
   * @throws Exception
   */
  void updateUser(long id, String userName, String userRole, String departmentCd, String userPass, Timestamp upDate)
      throws Exception;

  /**
   * 更新パスなし
   * @param id ID
   * @param userName ユーザー名.
   * @param userRole ユーザー役割.
   * @param departmentCd 部門コード.
   * @param upDate 更新日.
   * @throws Exception
   */
  void updateUserNoPass(long id, String userName, String userRole, String departmentCd, Timestamp upDate)
      throws Exception;

  /**
   * ユーザーを削除
   * @param userId ユーザーID.
   * @throws Exception
   */
  void deleteUser(String userId) throws Exception;

  /**
   * ユーザーIDでユーザーを選択
   * @param userId ユーザーID.
   * @return ユーザー
   */
  ClUser selectById(String userId);

  /**
   * ユーザーを挿入
   * @param userName ユーザー名.
   * @param userRole ユーザー役割.
   * @param regDate 登録日.
   * @param upDate 更新日.
   * @param departmentCd 部門コード.
   * @param userPass ユーザーパスワード.
   * @param userId ユーザーID.
   * @param numLoginAttempt ログインに失敗した回数.
   * @throws Exception
   */
  void insertUser(String userName, String userRole, Timestamp regDate, Timestamp upDate, String departmentCd,
      String userPass, String userId, int numLoginAttempt) throws Exception;

  /**
   * ユーザー設定を取得
   * @return ユーザー設定.
   * @throws Exception
   */
  ResponseClUserSetting getUserSetting() throws Exception;

  /**
   * サインイン試行回数の更新に失敗しました
   * @param userId ユーザーID.
   * @param numLoginAttempt ログインに失敗した回数.
   * @throws Exception
   */
  void updateAttemptFail(String userId, int numLoginAttempt) throws Exception;
}
