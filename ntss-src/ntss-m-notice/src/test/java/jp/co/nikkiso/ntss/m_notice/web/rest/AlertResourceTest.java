package jp.co.nikkiso.ntss.m_notice.web.rest;

import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;

import jp.co.nikkiso.ntss.m_notice.service.MNotice;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Ignore
public class AlertResourceTest {
  
  @Autowired
  private MockMvc mvc;

  @MockitoSpyBean
  private MNotice mNotice;

  @Test
  public void 緊急発報の登録で200が返されること() throws Exception {
    // モックの振る舞いを定義
    final byte[] content = new byte[] {0x61, 0x62, 0x63, 0x64};
    doNothing().when(mNotice).run(content);
    
    // 実行
    mvc.perform(post("/api/alerts")
        .contentType(MediaType.APPLICATION_JSON_VALUE)
        .content("{\"content\": \"YWJjZA==\"}"))
    .andExpect(status().isOk());
    
    verify(mNotice).run(content);
  }
}
