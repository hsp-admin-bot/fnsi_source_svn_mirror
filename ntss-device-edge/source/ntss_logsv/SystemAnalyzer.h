/** 
 * @file SystemAnalyzer.h
 *
 * @brief Linuxにおいてシステム情報を取得するためのクラスライブラリ
 *
 * @note 使い方のサンプルコード
 *
 * SystemAnalyzer analyzer;
 * while(1){
 *    //CPUの使用率を取得
 *    int nCPU=4;//CPUの数
 *    unsigned int cpuUsage=analyzer.GetCPUUsage(nCPU);
 *    cout<<"CPU Usage is "<<cpuUsage<<"%"<<endl;
 *
 *    //メモリの使用率を取得
 *    unsigned int memUsage=analyzer.GetMemoryUsage();
 *    cout<<"Memory Usage is "<<memUsage<<"%"<<endl;
 *
 *    //ディスクの使用率を取得
 *    unsigned int diskUsage=analyzer.GetDiskUsage();
 *    cout<<"Disk Usage is "<<diskUsage<<"%"<<endl;
 *
 *    sleep(1);
 *  }
 */
#ifndef SYSTEM_ANALYZER_H
#define SYSTEM_ANALYZER_H

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

  extern void GetSystemAnalyzer(char *buf);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#include <iostream>
#include <cstdio>
#include <stdio.h>
// #12223 2025.10.01 add DEログに出力しているメモリ使用率の計算修正 TDC高村 start
#include <stdlib.h>
#include <string.h>
// #12223 2025.10.01 add DEログに出力しているメモリ使用率の計算修正 TDC高村 end
#include <sys/times.h>
#include <sys/sysinfo.h>
#include <sys/statvfs.h>

using namespace std;

/** 
 * @brief Linuxにおいてシステム情報を取得するためのクラス
 */
class SystemAnalyzer{
  public:
    SystemAnalyzer(){
      //preTick_=0;
      //preTime_=times(NULL);
    }

    //~~~~~~functions~~~~~~~

    /**
     * @brief CPUの使用率を返す関数
     * @param nCPU CPUの数
     * @return システム全体のCPUの使用率[%]
     */
    unsigned int GetCPUUsage(int nCPU, int *preTick_, clock_t *preTime_){
    //unsigned int GetCPUUsage(int nCPU){
      unsigned int cpuUsage=0;

      // 演算に使用されたTick値を取得
      FILE *infile = fopen( "/proc/stat", "r" );
      if ( NULL == infile ){
        cout<<"[GetCPUUsage]<<Cannot open /proc/stat"<<endl;
        return 0;
      }

      int usr, nice, sys;
      char buf[1024]; // 文字列"cpu"の部分の入力用
      int result=fscanf( infile, "%s %d %d %d", buf, &usr, &nice, &sys );
      if(result==-1){
        cout<<"[GetCPUUsage]<<Cannot read fscanf"<<endl;
        return 0;
      }
      fclose( infile );

      // 現在の時刻を取得
      clock_t now = times(NULL);

      if(*preTick_==0){//一回目の呼び出しの場合
        // 取得したTick値、時刻を保存
        *preTick_ = usr + nice + sys;
        *preTime_ = now;
        return 0;//0%を返す
      }

      // CPU利用率を算出
      // この計算式では、100% x CPUを最大値としたCPU使用率が計算されてしまうので、nCPUで割る
      cpuUsage = ( (double)( usr + nice + sys - *preTick_ ) / ( now - *preTime_ ) )*100.0/nCPU;

      // 取得したTick値、時刻を保存
      *preTick_ = usr + nice + sys;
      *preTime_ = now;

      return cpuUsage;
    }

    /**
     * @brief 使用されているメモリの割合を取得する関数
     *
     * @return 使用されているメモリの割合[%] 0-100 
     */
    unsigned int GetMemoryUsage(void){
      struct sysinfo info;
      sysinfo(&info);

      //メモリの枚数で正規化
      unsigned long totalram = (info.totalram * info.mem_unit) / 1024;
      unsigned long freeram = (info.freeram * info.mem_unit ) / 1024;
     
      //メモリ使用量を計算
      unsigned int memoryUsage=(double)(totalram-freeram)/(double)totalram*100;

      return memoryUsage;
    }

    // #12223 2025.10.01 add DEログに出力しているメモリ使用率の計算修正 TDC高村 start
    /**
     * @brief meminfoから指定した値を返す関数
     * @param 指定するキー
     * @return 指定した値
     */
    long GetMeminfoValue(const char *key) {
        FILE *fp = fopen("/proc/meminfo", "r");
        if (!fp) {
            perror("fopen");
            return -1;
        }

        char line[256];
        long value = -1;

        while (fgets(line, sizeof(line), fp)) {
            if (strncmp(line, key, strlen(key)) == 0) {
                sscanf(line + strlen(key), "%ld", &value);
                break;
            }
        }

        fclose(fp);
        return value; // 単位は kB
    }

    /**
     * @brief 使用されているメモリの割合を取得する関数
     *
     * @return 使用されているメモリの割合[%] 0-100 
     */
    unsigned int GetMemInfoUsage(void){
      struct sysinfo info;
      sysinfo(&info);

      //メモリの枚数で正規化
      unsigned long totalram = GetMeminfoValue("MemTotal:") / 1024;
      unsigned long freeram = GetMeminfoValue("MemAvailable:") / 1024;
     
      //メモリ使用量を計算
      unsigned int memoryUsage=(double)(totalram-freeram)/(double)totalram*100;

      return memoryUsage;
    }
    // #12223 2025.10.01 add DEログに出力しているメモリ使用率の計算修正 TDC高村 end

    /**
     * @brief 使用されているディスクの割合を取得する関数
     *
     * @return 使用されているディスクの割合[%] 0-100 
     */
    unsigned int GetDiskUsage(void){
      unsigned int diskUsage=0;

      //システムデータの読み込み
      struct statvfs buf;
      statvfs("/",&buf);

      float availableDisk=((float)buf.f_frsize*(float)buf.f_bavail/1024.0);
      float allDisk=((float)buf.f_frsize*(float)buf.f_blocks/1024.0);
      
      //使用ディスク容量の計算
      diskUsage=100.0-availableDisk/allDisk*100.0;

      return diskUsage;
    }

 

  private:
    //GetCPUUsage用
    //int preTick_;  // 前の/proc/statの値を保持
    //clock_t preTime_;  // 前の時刻を保持

    //~~~~~~Struct/Enum~~~~~~

    //~~~~~~Members~~~~~

    //~~~~~~functions~~~~~~~
};
#endif  //SYSTEM_ANALYZER_H
