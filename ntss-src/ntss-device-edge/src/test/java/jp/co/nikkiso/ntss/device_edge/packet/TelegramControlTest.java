package jp.co.nikkiso.ntss.device_edge.packet;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import java.util.ArrayList;

import org.junit.Test;

public class TelegramControlTest {

  @Test
  public void getTelegramValueで一致する項目がある場合はそれを返すこと() {
    
    String[] telegramLines = {"AAA=hoge","BBB=fuga","CCC=hige"};

    assertThat(TelegramControl.getTelegramValue(telegramLines, "AAA"), is("hoge"));  
    assertThat(TelegramControl.getTelegramValue(telegramLines, "BBB"), is("fuga"));   
    assertThat(TelegramControl.getTelegramValue(telegramLines, "CCC"), is("hige"));   
  }
  
  @Test
  public void getTelegramValueで一致する項目がない場合はnullを返すこと() {
    
    String[] telegramLines = {"AAA=hoge","BBB=fuga","CCC=hige"};

    assertThat(TelegramControl.getTelegramValue(telegramLines, "ABC"), nullValue());  
    assertThat(TelegramControl.getTelegramValue(telegramLines, "hoge"), nullValue());   
    assertThat(TelegramControl.getTelegramValue(telegramLines, "hige"), nullValue());   
  }
  
  @Test
  public void convertTelegramToStringListはLF区切りとTAB区切りで配列のリストを作成すること() {
    String str = "AAA\tBBB\tCCC\tDDD\nABC\tDEF\tGHI\tJKL";
    ArrayList<String[]> returnTelegram = TelegramControl.convertTelegramToStringList(str);
    

    assertThat(returnTelegram.size(), is(2));
    assertThat(returnTelegram.get(0)[0], is("AAA"));
    assertThat(returnTelegram.get(0)[1], is("BBB"));
    assertThat(returnTelegram.get(0)[2], is("CCC"));
    assertThat(returnTelegram.get(0)[3], is("DDD"));
    assertThat(returnTelegram.get(1)[0], is("ABC"));
    assertThat(returnTelegram.get(1)[1], is("DEF"));
    assertThat(returnTelegram.get(1)[2], is("GHI"));
    assertThat(returnTelegram.get(1)[3], is("JKL"));    
  }
}
