package jp.co.nikkiso.ntss.device_edge.web.rest;

import static org.hamcrest.CoreMatchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class UploadApiResourceTest {

  @Autowired
  private MockMvc mockMvc;

  @Test
  public void test_sample_疎通確認用APIでsample文字列が返ってくること() throws Exception {

    mockMvc.perform(get("/api/sample").header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK"))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", is("sample")));

  }

  @Test
  public void test_sample_疎通確認用APIでセキュリティキーが不一致だとエラーになること() throws Exception {

    mockMvc.perform(get("/api/sample").header("SSECCAYEK", "nkk"))
      .andExpect(status().isNotFound());

  }
}
