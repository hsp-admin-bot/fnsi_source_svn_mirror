package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MntIfEdgeHealthmon;

/**
 * {@link MntIfEdgeHealthmonDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MntIfEdgeHealthmonDaoTest.before.sql")
public class MntIfEdgeHealthmonDaoTest {
  /**
   * テスト対象Dao.
   */
  @Autowired
  private MntIfEdgeHealthmonDao dao;

  /**
   * {@link MntIfEdgeHealthmonDao#selectByFacilityAndIfEdgeNo(String, Integer)} の確認テスト
   * <p>
   * &lt確認内容&gt<br>
   * 　facilityCd、ifEdgeNo の組み合わせが、存在するレコードと同じ場合<br>
   *
   * <p>
   * &lt想定結果&gt<br>
   * 　指定した facilityCd、ifEdgeNo と同じ組み合わせの レコードデータが取得できる<br>
   */
  @Test
  public void 正常系_selectByFacilityAndIfEdgeNo_データあり() {
    String facilityCd = "000001";
    Integer ifEdgeNo = 12;
//    List<MntIfEdgeHealthmon> healthmon = dao.selectByFacilityAndIfEdgeNo(facilityCd,  ifEdgeNo);
    MntIfEdgeHealthmon healthmon = dao.selectByFacilityAndIfEdgeNo(facilityCd,  ifEdgeNo);

    assertThat(healthmon, is(notNullValue()));
  }

  /**
   * {@link MntIfEdgeHealthmonDao#selectByFacilityAndIfEdgeNo(String, Integer)} の確認テスト
   * <p>
   * &lt確認内容&gt<br>
   * 　facilityCd、ifEdgeNo の組み合わせが、登録しているレコードに存在しない場合<br>
   * （facilityCd のみ等しい、ifEdgeNo のみ等しい、どちらも等しくない、どちらも等しいが削除フラグON）
   * <p>
   * &lt想定結果&gt<br>
   * 　レコードデータ が取得できない
   */
  @Test
  public void 正常系_selectByFacilityAndIfEdgeNo_データなし() {
    String facilityCd = "000001";
    Integer ifEdgeNo = 99;
//    List<MntIfEdgeHealthmon> healthmon = dao.selectByFacilityAndIfEdgeNo(facilityCd,  ifEdgeNo);
    MntIfEdgeHealthmon healthmon = dao.selectByFacilityAndIfEdgeNo(facilityCd,  ifEdgeNo);

    assertThat(healthmon, is(nullValue()));
  }

  /**
   * {@link MntIfEdgeHealthmonDao#updateServerAndFacilityConn(MntIfEdgeHealthmon)} の確認テスト
   * <p>
   * &lt確認内容&gt
   * <ul>
   *   <li>テストデータ
   *   <ul>
   *     <li>更新するレコードが存在する
   *     <li>healthmon_facility_conn に 複数の項目値が存在する<br>
   *     （'{ "項目1" : { AA: XX, BB: XX }, "項目2" : { AA: XX, BB: XX } .. }'）
   *     <li>healthmon_server_conn に値が存在する
   *   </ul>
   *   <li>更新内容
   *   <ul>
   *     <li>healthmon_facility_conn に存在する項目1つ のみ指定する<br>
   *     （'{ "項目1" : { AA: XX, BB: XX } }'）
   *     <li>healthmon_server_conn を指定する
   *   </ul>
   * </ul>
   * <p>
   * &lt想定結果&gt
   * <ul>
   *   <li>healthmon_facility_conn 内の "ini_dial" 部分のみ更新されること（他の項目は更新されていないこと）
   *   <li>healthmon_server_conn が指定した値で更新されていること
   *   <li>up_date が更新されていること
   * </ul>
   */
  @Test
  public void 正常系_updateServerAndFacilityConn_エッジ_サーバステータスと更新日時が更新される() {
    MntIfEdgeHealthmon updateData = 上書き更新用テストデータ作成();

    dao.updateServerAndFacilityConn(updateData);
    List<MntIfEdgeHealthmon> actual = new ArrayList<>((Collection) dao.selectByFacilityAndIfEdgeNo(updateData.getFacilityCd(), updateData.getIfEdgeNo()));


    assertThat(actual, is(notNullValue()));
    // 更新日時
    assertThat(actual.get(0).getUpDate().toString(), not(Timestamp.valueOf("2019-12-10 13:00:03").toString()));
    // エッジステータス
    assertThat(actual.get(0).getHealthmonFacilityConn(), is("{"
        + "\"profile\": {\"type\": \"request\", \"status\": \"01\", \"moni_time\": \"2020-01-01 00:00:01\"}"
        + ", "
        + "\"exam_rst\": {\"type\": \"send\", \"status\": \"01\", \"moni_time\": \"2020-01-01 00:00:01\"}"
        + ", "
        // 以下の項目のみ上書き更新
        + "\"ini_dial\": {\"type\": \"receive\", \"status\": \"F1\", \"moni_time\": \"2019-12-15 20:15:32\"}"
        + "}"));
    // サーバステータス
    assertThat(actual.get(0).getHealthmonServerConn(), is(updateData.getHealthmonServerConn()));
    // 更新対象外
    assertThat(actual.get(0).getCtlNo(), is(1L));
    assertThat(actual.get(0).getFacilityCd(), is("000001"));
    assertThat(actual.get(0).getIfEdgeNo(), is(12));
    assertThat(actual.get(0).getRegDate().toString(), is(Timestamp.valueOf("2019-12-10 12:50:00").toString()));
  }

  /**
   * {@link MntIfEdgeHealthmonDao#updateServerAndFacilityConn(MntIfEdgeHealthmon)} の確認テスト
   * <p>
   * &lt確認内容&gt
   * <ul>
   *   <li>テストデータ
   *   <ul>
   *     <li>更新するレコードが存在する
   *     <li>healthmon_facility_conn に 3つ以上の項目値が存在する<br>
   *     （'{ "項目1" : { AA: XX, BB: XX }, "項目2" : { AA: XX, BB: XX }, "項目3" : { AA: XX, BB: XX } .. }'）
   *     <li>healthmon_server_conn に値が存在する
   *   </ul>
   *   <li>更新内容
   *   <ul>
   *     <li>healthmon_facility_conn に存在する項目2つ を指定する<br>
   *     （'{ "項目1" : { AA: XX, BB: XX }, "項目3" : { AA: XX, BB: XX } }'）
   *     <li>healthmon_server_conn を指定する
   *   </ul>
   * </ul>
   * <p>
   * &lt想定結果&gt
   * <ul>
   *   <li>healthmon_facility_conn 内の "ini_dial"、"profile" 部分が更新されること（他の項目は更新されていないこと）
   *   <li>healthmon_server_conn が指定した値で更新されていること
   *   <li>up_date が更新されていること
   * </ul>
   */
  @Test
  public void 正常系_updateServerAndFacilityConn_エッジ_サーバステータスと更新日時が更新される_複数項目() {
    MntIfEdgeHealthmon updateData = 複数項目上書き更新用テストデータ作成();

    dao.updateServerAndFacilityConn(updateData);
    List<MntIfEdgeHealthmon> actual = new ArrayList<>((Collection) dao.selectByFacilityAndIfEdgeNo(updateData.getFacilityCd(), updateData.getIfEdgeNo()));


    assertThat(actual, is(notNullValue()));
    // 更新日時
    assertThat(actual.get(0).getUpDate().toString(), not(Timestamp.valueOf("2019-12-10 13:00:03").toString()));
    // エッジステータス
    assertThat(actual.get(0).getHealthmonFacilityConn(), is("{"
        // 更新される
        + "\"profile\": {\"type\": \"send\", \"status\": \"F1\", \"moni_time\": \"2019-12-18 21:18:43\"}"
        + ", "
        // 更新されない
        + "\"exam_rst\": {\"type\": \"send\", \"status\": \"01\", \"moni_time\": \"2020-01-01 00:00:01\"}"
        + ", "
        // 更新される
        + "\"ini_dial\": {\"type\": \"receive\", \"status\": \"F1\", \"moni_time\": \"2019-12-15 20:15:32\"}"
        + "}"));
    // サーバステータス
    assertThat(actual.get(0).getHealthmonServerConn(), is(updateData.getHealthmonServerConn()));
    // 更新対象外
    assertThat(actual.get(0).getCtlNo(), is(1L));
    assertThat(actual.get(0).getFacilityCd(), is("000001"));
    assertThat(actual.get(0).getIfEdgeNo(), is(12));
    assertThat(actual.get(0).getRegDate().toString(), is(Timestamp.valueOf("2019-12-10 12:50:00").toString()));
  }

  /**
   * {@link MntIfEdgeHealthmonDao#updateServerAndFacilityConn(MntIfEdgeHealthmon)} の確認テスト
   * <p>
   * &lt確認内容&gt
   * <ul>
   *   <li>テストデータ
   *   <ul>
   *     <li>更新するレコードが存在する
   *     <li>healthmon_facility_conn に値が存在する
   *     <li>healthmon_server_conn に値が存在する
   *   </ul>
   *   <li>更新内容
   *   <ul>
   *     <li>healthmon_server_conn を指定する
   *   </ul>
   * </ul>
   *
   * &lt想定結果&gt
   * <ul>
   *  <li>healthmon_facility_conn が更新されていないこと
   *  <li>healthmon_server_conn が指定した値で更新されていること
   *  <li>up_date が更新されていること
   * </ul>
   */
  @Test
  public void 正常系_updateServerAndFacilityConn_サーバステータスと更新日時が更新される() {
    MntIfEdgeHealthmon updateData = 上書き更新用テストデータ作成();
    // 更新しない
    updateData.setHealthmonFacilityConn(null);

    dao.updateServerAndFacilityConn(updateData);

    List<MntIfEdgeHealthmon> actual = new ArrayList<>((Collection) dao.selectByFacilityAndIfEdgeNo(updateData.getFacilityCd(), updateData.getIfEdgeNo()));


    assertThat(actual, is(notNullValue()));
    // 更新日時
    assertThat(actual.get(0).getUpDate().toString(), not(Timestamp.valueOf("2019-12-10 13:00:03").toString()));
    // サーバステータス
    assertThat(actual.get(0).getHealthmonServerConn(), is(updateData.getHealthmonServerConn()));

    // 更新対象外
    // エッジステータス
    assertThat(actual.get(0).getHealthmonFacilityConn(), is("{"
        + "\"profile\": {\"type\": \"request\", \"status\": \"01\", \"moni_time\": \"2020-01-01 00:00:01\"}"
        + ", "
        + "\"exam_rst\": {\"type\": \"send\", \"status\": \"01\", \"moni_time\": \"2020-01-01 00:00:01\"}"
        + ", "
        + "\"ini_dial\": {\"type\": \"receive\", \"status\": \"01\", \"moni_time\": \"2020-01-01 00:00:01\"}"
        + "}"));
    assertThat(actual.get(0).getCtlNo(), is(1L));
    assertThat(actual.get(0).getFacilityCd(), is("000001"));
    assertThat(actual.get(0).getIfEdgeNo(), is(12));
    assertThat(actual.get(0).getRegDate().toString(), is(Timestamp.valueOf("2019-12-10 12:50:00").toString()));
  }

  /**
   * {@link MntIfEdgeHealthmonDao#updateServerAndFacilityConn(MntIfEdgeHealthmon)} の確認テスト
   * <p>
   * &lt確認内容&gt
   * <ul>
   *   <li>テストデータ
   *   <ul>
   *     <li>更新するレコードが存在する
   *     <li>healthmon_facility_conn に値が存在する
   *     <li>healthmon_server_conn に値が存在する
   *   </ul>
   *   <li>更新内容
   *   <ul>
   *     <li>healthmon_facility_conn を指定する
   *   </ul>
   * </ul>
   * <p>
   * &lt想定結果&gt
   * <ul>
   *   <li>healthmon_facility_conn が更新されていること
   *   <li>healthmon_server_conn が更新されていないこと
   *   <li>up_date が更新されていること
   * </ul>
   */
  @Test
  public void 正常系_updateServerAndFacilityConn_エッジテータスと更新日時が更新される() {
    MntIfEdgeHealthmon updateData = 上書き更新用テストデータ作成();
    // 更新しない
    updateData.setHealthmonServerConn(null);

    dao.updateServerAndFacilityConn(updateData);

    List<MntIfEdgeHealthmon> actual = new ArrayList<>((Collection) dao.selectByFacilityAndIfEdgeNo(updateData.getFacilityCd(), updateData.getIfEdgeNo()));


    assertThat(actual, is(notNullValue()));
    // 更新日時
    assertThat(actual.get(0).getUpDate().toString(), not(Timestamp.valueOf("2019-12-10 13:00:03").toString()));
    // エッジステータス
    assertThat(actual.get(0).getHealthmonFacilityConn(), is("{"
        + "\"profile\": {\"type\": \"request\", \"status\": \"01\", \"moni_time\": \"2020-01-01 00:00:01\"}"
        + ", "
        + "\"exam_rst\": {\"type\": \"send\", \"status\": \"01\", \"moni_time\": \"2020-01-01 00:00:01\"}"
        + ", "
        // 以下の項目のみ上書き更新
        + "\"ini_dial\": {\"type\": \"receive\", \"status\": \"F1\", \"moni_time\": \"2019-12-15 20:15:32\"}"
        + "}"));
    // 更新対象外
    // サーバステータス
    assertThat(actual.get(0).getHealthmonServerConn(), is("{\"status\": \"01\", \"moni_time\": \"2020-01-01 00:00:01\"}"));
    assertThat(actual.get(0).getCtlNo(), is(1L));
    assertThat(actual.get(0).getFacilityCd(), is("000001"));
    assertThat(actual.get(0).getIfEdgeNo(), is(12));
    assertThat(actual.get(0).getRegDate().toString(), is(Timestamp.valueOf("2019-12-10 12:50:00").toString()));
  }

  /**
   * {@link MntIfEdgeHealthmonDao#updateServerAndFacilityConn(MntIfEdgeHealthmon)} の確認テスト
   * <p>
   * &lt確認内容&gt
   * <ul>
   *   <li>テストデータ
   *   <ul>
   *     <li>更新するレコードが存在する
   *     <li>healthmon_facility_conn に 1つの項目値が存在する（'{ "項目1" : { AA: XX, BB: XX} }'）
   *     <li>healthmon_server_conn に項目値が存在しない（'{  }'）
   *   </ul>
   *   <li>更新内容
   *   <ul>
   *     <li>healthmon_facility_conn に存在しない項目1つ のみ指定する<br>
   *     （'{ "項目X" : { AA: XX, BB: XX } }'）
   *     <li>healthmon_server_conn を指定する
   *   </ul>
   * </ul>
   * <p>
   * &lt想定結果&gt
   * <ul>
   *   <li>healthmon_facility_conn 内に 新しく項目が増えること（既存の項目は更新されていないこと）
   *   <li>healthmon_server_conn が指定した値で更新されていること
   *   <li>up_date が更新されていること
   * </ul>
   */
  @Test
  public void 正常系_updateServerAndFacilityConn_エッジ_サーバステータスと更新日時が追加更新される() {
    MntIfEdgeHealthmon updateData = 追加更新用テストデータ作成();

    dao.updateServerAndFacilityConn(updateData);

    List<MntIfEdgeHealthmon> actual = new ArrayList<>((Collection) dao.selectByFacilityAndIfEdgeNo(updateData.getFacilityCd(), updateData.getIfEdgeNo()));


    assertThat(actual, is(notNullValue()));
    // 更新日時
    assertThat(actual.get(0).getUpDate().toString(), not(Timestamp.valueOf("2019-12-10 15:00:03").toString()));
    // エッジステータス
    assertThat(actual.get(0).getHealthmonFacilityConn(), is("{"
        + "\"profile\": {\"type\": \"request\", \"status\": \"01\", \"moni_time\": \"2020-01-01 00:00:01\"}"
        + ", "
        + "\"ini_dial\": {\"type\": \"receive\", \"status\": \"F1\", \"moni_time\": \"2019-12-15 20:15:32\"}"
        + "}"));
    // サーバステータス
    assertThat(actual.get(0).getHealthmonServerConn(), is(updateData.getHealthmonServerConn()));
    // 更新対象外
    assertThat(actual.get(0).getCtlNo(), is(2L));
    assertThat(actual.get(0).getFacilityCd(), is("000011"));
    assertThat(actual.get(0).getIfEdgeNo(), is(3));
    assertThat(actual.get(0).getRegDate().toString(), is(Timestamp.valueOf("2019-12-10 11:50:00").toString()));
  }

  /**
   * {@link MntIfEdgeHealthmonDao#updateServerAndFacilityConn(MntIfEdgeHealthmon)} の確認テスト
   * <p>
   * &lt確認内容&gt
   * <ul>
   *   <li>テストデータ
   *   <ul>
   *     <li>更新するレコードが存在しない
   *   </ul>
   *   <li>更新内容
   *   <ul>
   *     <li>healthmon_facility_conn を指定する
   *     <li>healthmon_server_conn を指定する
   *   </ul>
   * </ul>
   * <p>
   * &lt想定結果&gt<br>
   * 　更新されていないこと
   */
  @Test
  public void 異常系_updateServerAndFacilityConn_データなし() {
    MntIfEdgeHealthmon updateData = 上書き更新用テストデータ作成();
    // 存在しない値に変更
    updateData.setCtlNo(99L);

    int count = dao.updateServerAndFacilityConn(updateData);

    // 更新件数
    assertThat(count, is(0));
  }

  private MntIfEdgeHealthmon 上書き更新用テストデータ作成() {
    MntIfEdgeHealthmon healthmon = new MntIfEdgeHealthmon();
    healthmon.setCtlNo(1L);
    healthmon.setFacilityCd("000001");
    healthmon.setIfEdgeNo(12);
    healthmon.setHealthmonFacilityConn(
        "{\"ini_dial\": {\"status\": \"F1\", \"type\": \"receive\", \"moni_time\": \"2019-12-15 20:15:32\"}}");
    healthmon.setHealthmonServerConn(
        "{\"status\": \"F0\", \"moni_time\": \"2019-12-15 20:18:32\"}");

    return healthmon;
  }

  private MntIfEdgeHealthmon 複数項目上書き更新用テストデータ作成() {
    MntIfEdgeHealthmon healthmon = new MntIfEdgeHealthmon();
    healthmon.setCtlNo(1L);
    healthmon.setFacilityCd("000001");
    healthmon.setIfEdgeNo(12);
    healthmon.setHealthmonFacilityConn(
        "{\"ini_dial\": {\"status\": \"F1\", \"type\": \"receive\", \"moni_time\": \"2019-12-15 20:15:32\"},"
        + "\"profile\": { \"status\": \"F1\", \"type\" : \"send\", \"moni_time\": \"2019-12-18 21:18:43\" }}");
    healthmon.setHealthmonServerConn(
        "{\"status\": \"F0\", \"moni_time\": \"2019-12-15 20:18:32\"}");

    return healthmon;
  }

  private MntIfEdgeHealthmon 追加更新用テストデータ作成() {
    MntIfEdgeHealthmon healthmon = new MntIfEdgeHealthmon();
    healthmon.setCtlNo(2L);
    healthmon.setFacilityCd("000011");
    healthmon.setIfEdgeNo(3);
    healthmon.setHealthmonFacilityConn(
        "{\"ini_dial\": {\"status\": \"F1\", \"type\": \"receive\", \"moni_time\": \"2019-12-15 20:15:32\"}}");
    healthmon.setHealthmonServerConn(
        "{\"status\": \"F0\", \"moni_time\": \"2019-12-15 20:18:32\"}");

    return healthmon;
  }
}
