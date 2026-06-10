package jp.co.nikkiso.ntss.coop_api.utils;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.fail;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.coop_api.service.BaseServiceTest;
import jp.co.nikkiso.ntss.core.exception.NtssException;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class DateUtilTest extends BaseServiceTest {

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の値がない場合
   * 結果 : nullが返却されること
   * */
  @Test
  public void convertDateToStringFormat_日付変換_引数なし() {

    String result = DateUtil.convertDateToStringFormat(null);

    // 検証結果
    assertThat(result, nullValue());
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数が想定外の場合
   * 結果 : nullが返却されること
   * */
  @Test
  public void convertDateToStringFormat_日付変換_引数不正() {

    final String date = "200518";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, nullValue());
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数が想定外の場合
   * 結果 : nullが返却されること
   * */
  @Test
  public void convertDateToStringFormat_日付変換_引数不正その２() {

    final String date = "2020/05/18 Mon";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, nullValue());
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列はYYYYMMDD
   * 結果 : YYYY-MM-DDに変換されること
   * */
  @Test
  public void convertDateToStringFormat_日付変換_西暦変換() {

    final String date = "20200518";
    final String expect = "2020-05-18";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, is(expect));

  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列はYYYY/MM/DD
   * 結果 : YYYY-MM-DDに変換されること
   * */
  @Test
  public void convertDateToStringFormat_日付変換_西暦変換_スラッシュあり() {

    final String date = "2020/05/18";
    final String expect = "2020-05-18";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, is(expect));
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列はYYYY-MM-DD
   * 結果 : YYYY-MM-DDに変換されること
   * */
  @Test
  public void convertDateToStringFormat_日付変換_西暦変換_ハイフンあり() {

    final String date = "2020-05-18";
    final String expect = "2020-05-18";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, is(expect));
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列は元号0YYMMDD
   * 結果 : YYYY-MM-DDに変換されること
   * */
  @Test
  public void convertDateToStringFormat_日付変換_和暦変換_大正() {

    // 大正11年→1922年
    final String date = "T0110518";
    final String expect = "1922-05-18";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, is(expect));
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列は元号0YYMMDD
   * 結果 : YYYY-MM-DDに変換されること
   * */
  @Test
  public void convertDateToStringFormat_日付変換_和暦変換_昭和() {

    // 昭和57年→1982年
    final String date = "S0570518";
    final String expect = "1982-05-18";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, is(expect));
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列は元号0YYMMDD
   * 結果 : YYYY-MM-DDに変換されること
   * */
  @Test
  public void convertDateToStringFormat_日付変換_和暦変換_平成() {

    // 平成30年→2018年
    final String date = "H0300518";
    final String expect = "2018-05-18";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, is(expect));
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列は元号0YYMMDD
   * 結果 : YYYY-MM-DDに変換されること
   * */
  @Test
  public void convertDateToStringFormat_日付変換_和暦変換_平成その２() {

    // 平成32年→2020年
    final String date = "H0320518";
    final String expect = "2020-05-18";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, is(expect));
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列は元号0YYMMDD
   * 結果 : YYYY-MM-DDに変換されること
   * */
  @Test
  public void convertDateToStringFormat_日付変換_和暦変換_令和() {

    // 令和1年→2019年
    final String date = "R0010501";
    final String expect = "2019-05-01";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, is(expect));
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列は元号0YYMMDD
   * 結果 : YYYY-MM-DDに変換されること
   * */
  @Test
  public void convertDateToStringFormat_日付変換_和暦変換_令和その２() {

    // 令和5年→2023年
    final String date = "R0050518";
    final String expect = "2023-05-18";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, is(expect));
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列が日付変換できない場合
   * 結果 : NtssExcetionがthrowされること
   * */
  @Test
  public void convertDateToStringFormat_日付変換失敗() {
    // 変換できない日付の場合
    final String date = "20200230";
    String expect = String.format("日付の変換に失敗しました。date:[%s]", date);

    try {
      DateUtil.convertDateToStringFormat(date);
      fail("例外テストのためここは実行されない");
    } catch(NtssException e) {
      assertThat(e.getMessage(), is(expect));
    }
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列が日付変換できない場合
   * 結果 : NtssExcetionがthrowされること
   * */
  @Test
  public void convertDateToStringFormat_日付変換失敗その２() {
    // 変換できない日付の場合
    final String date = "Q0010510";
    String expect = String.format("日付の変換に失敗しました。date:[%s]", date);

    try {
      DateUtil.convertDateToStringFormat(date);
      fail("例外テストのためここは実行されない");
    } catch(NtssException e) {
      assertThat(e.getMessage(), is(expect));
    }
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列が特殊日付の場合
   * 結果 : YYYY-MM-DDに変換されること
   * */
  @Test
  public void convertDateToStringFormat_特殊日付() {
    // 変換できない日付の場合
    final String date = "0000-00-00";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, is(result));
  }

  /**
   * convertDateToStringFormatのテスト
   *
   * 条件 : 引数の日付文字列が特殊日付の場合
   * 結果 : YYYY-MM-DDに変換されること
   * */
  @Test
  public void convertDateToStringFormat_特殊日付その２() {
    // 変換できない日付の場合
    final String date = "00000000";
    String expect = "0000-00-00";

    String result = DateUtil.convertDateToStringFormat(date);

    // 検証結果
    assertThat(result, is(expect));
  }
}
