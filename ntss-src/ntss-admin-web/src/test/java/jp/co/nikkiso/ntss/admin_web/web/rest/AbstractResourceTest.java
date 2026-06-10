package jp.co.nikkiso.ntss.admin_web.web.rest;

import org.junit.Before;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;


/**
 * Resourceテストの抽象基底クラス.
 */
public abstract class AbstractResourceTest {

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
    this.mockMvc = MockMvcBuilders.webAppContextSetup(this.context)
      .build();
  }

}
