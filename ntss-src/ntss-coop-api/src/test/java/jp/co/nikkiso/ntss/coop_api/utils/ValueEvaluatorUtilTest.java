package jp.co.nikkiso.ntss.coop_api.utils;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.coop_api.service.BaseServiceTest;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.exception.NtssException;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class ValueEvaluatorUtilTest extends BaseServiceTest {

  @Autowired
  ValueEvaluatorUtil valueEvaluatorUtil;

  @Test
  public void 正常系_const変換_定数値で置換される() {
    String result = valueEvaluatorUtil.eval("A", "const:11", null, null);
    assertThat(result).isEqualTo("11");
  }

  @Test
  public void 正常系_json変換_jsonマップから取得した値で置換される() {
    LayoutExtSetting les = new LayoutExtSetting("{\"json-key\":{\"jsonKey\":{\"A\":\"22\"}}}");
    String result = valueEvaluatorUtil.eval("A", "json:jsonKey", null, les);
    assertThat(result).isEqualTo("22");
  }

  @Test
  public void 正常系_特殊値指定がnullの場合は切り出した値を返す() {
    // 特殊値指定なしの場合1
    String result = valueEvaluatorUtil.eval("ABC", null, null, null);
    assertThat(result).isEqualTo("ABC");
  }

  @Test
  public void 正常系_特殊値指定がブランクの場合は切り出した値を返す() {
    // 特殊値指定なしの場合2
    String result = valueEvaluatorUtil.eval("DEF", "", null, null);
    assertThat(result).isEqualTo("DEF");
  }

  @Test(expected = NtssException.class)
  public void 異常系_特殊値指定の形式のみ未指定の場合は例外を発生させる() {
    valueEvaluatorUtil.eval("GHI", ";100", null, null);
  }

  @Test(expected = NtssException.class)
  public void 異常系_特殊値指定にコロンがない場合は例外を発生させる() {
    valueEvaluatorUtil.eval("ghi", "const100", null, null);
  }

  @Test(expected = NtssException.class)
  public void 異常系_特殊値指定が未対応の形式の場合は例外を発生させる() {
    valueEvaluatorUtil.eval("JKL", "foobar;100", null, null);
  }

  @Test(expected = NtssException.class)
  public void 異常系_JSONが指定されたが構造が不正の場合は例外を発生させる() {
    valueEvaluatorUtil.eval("a", "json:{\"a\":\"1\"", null, null);
  }

}
