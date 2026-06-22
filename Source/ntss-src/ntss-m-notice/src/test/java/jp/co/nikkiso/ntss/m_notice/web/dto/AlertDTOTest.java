package jp.co.nikkiso.ntss.m_notice.web.dto;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import org.junit.Ignore;
import org.junit.Test;

/**
 * {@link AlertDTO}のテストケースです。
 */
@Ignore
public class AlertDTOTest {

  @Test
  public void getContentAsBytesはcontentがnullの場合にはnullを返すこと() {
    AlertDTO alertDTO = new AlertDTO();
    assertThat(alertDTO.getContentAsBytes(), nullValue());
  }

  @Test
  public void getContentAsBytesはcontentをBase64デコードした内容を返すこと() {
    final String content = "MDAwTjAwMDAwQTFUREMgFxAgFVlAMDIwMwAHAAgACQAKFw==";
    AlertDTO alertDTO = new AlertDTO();
    alertDTO.setContent(content);
    assertThat(alertDTO.getContentAsBytes(), is(new byte[] {
/* 0000000 */ 0x30, 0x30, 0x30, 0x4e, 0x30, 0x30, 0x30, 0x30, 0x30, 0x41, 0x31, 0x54, 0x44, 0x43, 0x20, 0x17,
/* 0000010 */ 0x10, 0x20, 0x15, 0x59, 0x40, 0x30, 0x32, 0x30, 0x33, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00,
/* 0000020 */ 0x0a, 0x17
    }));
  }
}
