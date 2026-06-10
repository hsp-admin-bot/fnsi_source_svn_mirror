#include <cstdio>
#include <iostream>
#include <unistd.h>
#include "SystemAnalyzer.h"

using namespace std;

int preTick_ = 0;  // 前の/proc/statの値を保持
clock_t preTime_ = 0;  // 前の時刻を保持

int main_cpp()
{
    SystemAnalyzer analyzer;

    //CPUの使用率を取得
    int nCPU=1;//CPUの数
    //unsigned int cpuUsage=analyzer.GetCPUUsage(nCPU);
    unsigned int cpuUsage=analyzer.GetCPUUsage(nCPU, &preTick_, &preTime_);
    cout<<"CPU Usage is "<<cpuUsage<<"%"<<endl;

    //メモリの使用率を取得
    unsigned int memUsage=analyzer.GetMemoryUsage();
    cout<<"Memory Usage is "<<memUsage<<"%"<<endl;

    //ディスクの使用率を取得
    unsigned int diskUsage=analyzer.GetDiskUsage();
    //cout<<"Disk Usage is "<<diskUsage<<"%"<<endl;

    return 0;
}

extern "C" void GetSystemAnalyzer(char *buf)
{
    SystemAnalyzer analyzer;

    //CPUの使用率を取得

    int nCPU=1;//CPUの数
    //unsigned int cpuUsage=analyzer.GetCPUUsage(nCPU);
    unsigned int cpuUsage=analyzer.GetCPUUsage(nCPU, &preTick_, &preTime_);
 
    //メモリの使用率を取得
    // #12223 2025.10.01 mod DEログに出力しているメモリ使用率の計算修正 TDC高村 start
    //unsigned int memUsage=analyzer.GetMemoryUsage();
    unsigned int memUsage=analyzer.GetMemInfoUsage();
    // #12223 2025.10.01 mod DEログに出力しているメモリ使用率の計算修正 TDC高村 end
 
    //ディスクの使用率を取得
    unsigned int diskUsage=analyzer.GetDiskUsage();
 
    sprintf(buf, "CPU Usage is [%3d%%]  Memory Usage is [%3d%%]  Disk Usage is [%3d%%]", cpuUsage, memUsage, diskUsage);
}
