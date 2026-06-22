package jp.co.nikkiso.ntss.admin_web.service.webSocketNotify;

import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertThat;

import org.junit.Test;

import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.PayloadBuilder;

public class PayloadBuilderTest {

  @Test
  public void BuildTopicは引数をスラッシュ区切りで連結すること() {

    String topic = PayloadBuilder.BuildTopic("NTSS/TEST", "000000", 1);
    assertThat(topic, is("NTSS/TEST/000000/1"));
  }

  @Test
  public void BuildTopicは第一引数がスラッシュで終わっていてもスラッシュ区切りで連結すること() {

    String topic = PayloadBuilder.BuildTopic("NTSS/TEST/", "000000", 1);
    assertThat(topic, is("NTSS/TEST/000000/1"));
  }
  @Test
  public void  BuildTopicは引数がNULLの場合には空文字列として連結すること() {

    String payload = PayloadBuilder.BuildTopic(null, null, null);
    assertThat(payload, is("//"));
  }

  @Test
  public void BuildWeightTopicは引数をスラッシュ区切りで連結すること() {

    String topic = PayloadBuilder.BuildWeightTopic("NTSS/TEST", "000000", 1);
    assertThat(topic, is("NTSS/TEST/000000/1"));
  }

  @Test
  public void BuildWeightTopicは第一引数がスラッシュで終わっていてもスラッシュ区切りで連結すること() {

    String topic = PayloadBuilder.BuildWeightTopic("NTSS/TEST/", "000000", 1);
    assertThat(topic, is("NTSS/TEST/000000/1"));
  }
  @Test
  public void  BuildWeightTopicは引数がNULLの場合には空文字列として連結すること() {

    String payload = PayloadBuilder.BuildWeightTopic(null, null, null);
    assertThat(payload, is("//"));
  }

  @Test
  public void BuildAppUpdatePayloadは引数が予定なしで正しい場合は正常にペイロードを作成すること() {

    String payload = PayloadBuilder.BuildAppUpdatePayload((long) 9999, (short)0, "s3://test", "hoge.zip", null);
    assertThat(payload, is("9999\t0\ts3://test\thoge.zip"));
  }

  @Test
  public void BuildAppUpdatePayloadは引数が予定ありで正しい場合は正常にペイロードを作成すること() {

    String payload = PayloadBuilder.BuildAppUpdatePayload((long) 9999, (short)0, "s3://test", "hoge.zip", "20200801000000");
    assertThat(payload, is("9999\t0\ts3://test\thoge.zip\t20200801000000"));
  }

  @Test
  public void BuildAppUpdatePayloadは引数がNULLの場合は空文字に変換して作成すること() {

    String payload = PayloadBuilder.BuildAppUpdatePayload(null, null, null, null, null);
    assertThat(payload, is("\t\t\t"));
  }

  @Test
  public void BuildConfUpdatePayloadは引数が正しい場合は正常にペイロードを作成すること() {

    String payload = PayloadBuilder.BuildConfUpdatePayload((long) 9999, "s3://test", "hoge.zip");
    assertThat(payload, is("9999\ts3://test\thoge.zip"));
  }

  @Test
  public void BuildConfUpdatePayloadは引数がNULLの場合は空文字に変換して作成すること() {

    String payload = PayloadBuilder.BuildConfUpdatePayload(null, null, null);
    assertThat(payload, is("\t\t"));
  }

  @Test
  public void BuildAppRestorePayloadは引数が正しい場合は正常にペイロードを作成すること() {

    String payload = PayloadBuilder.BuildAppRestorePayload((long) 9999);
    assertThat(payload, is("9999"));
  }

  @Test
  public void BuildAppRestorePayloadは引数がNULLの場合は空文字に変換して作成すること() {

    String payload = PayloadBuilder.BuildAppRestorePayload(null);
    assertThat(payload, is(""));
  }

  @Test
  public void BuildGatherPayloadは引数が正しい場合は正常にペイロードを作成すること() {

    String payload = PayloadBuilder.BuildGatherPayload((long) 9999);
    assertThat(payload, is("9999"));
  }

  @Test
  public void BuildGatherPayloadは引数がNULLの場合は空文字に変換して作成すること() {

    String payload = PayloadBuilder.BuildGatherPayload(null);
    assertThat(payload, is(""));
  }

  @Test
  public void BuildSendConditionPayloadは引数が正しい場合に正常にペイロードを作成すること() {

    String payload = PayloadBuilder.BuildSendConditionPayload("999T1234567 ", (long) 9999, (long) 9999, "test");
    assertThat(payload, is("999T1234567 \t9999\t9999\ttest"));
  }

}
