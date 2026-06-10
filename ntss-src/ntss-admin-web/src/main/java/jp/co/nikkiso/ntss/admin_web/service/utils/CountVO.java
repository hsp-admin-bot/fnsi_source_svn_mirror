package jp.co.nikkiso.ntss.admin_web.service.utils;

public class CountVO {

  public CountVO(int max){
    this.max = max;
  }

  private int max = 0;

  private int count = 0;

  public void addCount(){
    this.count++;
  }

  public boolean isReachedMax(){
    return this.count >= this.max ;
  }
}
