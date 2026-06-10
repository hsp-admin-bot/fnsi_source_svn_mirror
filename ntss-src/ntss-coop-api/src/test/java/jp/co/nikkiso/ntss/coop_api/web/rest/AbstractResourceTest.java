package jp.co.nikkiso.ntss.coop_api.web.rest;

import org.junit.Before;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import jp.co.nikkiso.ntss.coop_api.BaseTest;

public abstract class AbstractResourceTest extends BaseTest {

  /**
   * MockMVC.
   */
  @Autowired
  protected MockMvc mockMvc;

  /**
   * WebApplicationContext.
   */
  @Autowired
  private WebApplicationContext context;

  /**
   * テスト実行前処理.
   */
  @Before
  public void setUp() {
    // Rest Docs出力の準備
    this.mockMvc = MockMvcBuilders.webAppContextSetup(this.context).build();
  }
}
