/**
* @file ntss_mqueue_recv.c
* @brief メッセージキュー受信処理
* @author Y.Takamura
* @date 2019/01/07
* @details メッセージキューからメッセージを受信する
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mqueue.h>
#include <pthread.h>
#include "ntss_comsv.h"
#include "ntss_mqueue_recv.h"
#include "ntss_devicecap_conf.h"

// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 start
#include "ntss_logger_sync.h"
// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 etc

/**
* @fn int ntss_mqueue_recv(char *message)
* @brief メッセージキューからメッセージ受信
* @param[out] message メッセージ
* @return int 0:成功 -1:失敗
* @details メッセージキューからメッセージを受信する
*/
int ntss_mqueue_recv(char *message)
{
    int ret = -1;
    char *buff;
    struct mq_attr attr;
    mqd_t recv_que;
 
    recv_que = mq_open(QUE_NAME, O_RDONLY|O_CREAT, FILE_MODE, NULL);
    mq_getattr(recv_que, &attr);
    printf("mq_open [%ld]\n", attr.mq_msgsize);
    buff = malloc(attr.mq_msgsize);
    if ( buff == NULL ) {
        handle_error("malloc");
    }
    if ( recv_que == -1 ) {
        perror("mq_open error");
    }
    else {
        memset(buff, 0, attr.mq_msgsize);
        if( mq_receive(recv_que, buff, attr.mq_msgsize, NULL) == -1 ) {
            perror("mq_receive error");
        }
        else {
            strcpy(message, buff);
            ret = 0;
        }
    }

    free(buff);
    mq_close(recv_que);
    return ret;
}

/**
* @fn void *ntss_mqueue_receiver()
* @brief メッセージキューからメッセージ受信（スレッド用）
* @param[in,out] ptr 装置制御情報
* @details メッセージキューからメッセージを受信する
*/
void *ntss_mqueue_receiver(void *ptr){

    int i, j;
	int ret, ret2;
    int dno;
    int req_no;
    long dev_no;
    long ord_no;
    long ctl_no;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long l_time;
    time_t l_time;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    char *buff;
    char work[80];
    char fpath[64];
    char dev_type[4];
    char dev_sno[8];
    char dev_format;
    char dev_comm;
    char dt[20], tm[10];
    u_char clog[256];   
    struct mq_attr attr;
	struct connect_socket *conSock = (struct connect_socket *) ptr;
    mqd_t recv_que;
    extern bool check_is_mqueue_device(long dev_no, char *dev_type, char *dev_sno, char *dev_format, char *dev_comm, 
                                        short *dev_idx, char (*mstOption)[5], char * mstIpAddr);
    // add FNSI-バグ 通信サーバ 高 start
    pthread_attr_t thread_attr;
    short dev_idx;
    int dno_1;
    bool new_flag;
    char mstOption[5][5];
    char mstIpAddr[16] = {0};
    // add FNSI-バグ 通信サーバ 高 end
    // #11192 2025.04.02 add 治療終了指示に含まれたオーダー番号がDE側で治療中のものではないケースに対応 TDC片口 start
    pthread_t thr_end_treat;
    // #11192 2025.04.02 add 治療終了指示に含まれたオーダー番号がDE側で治療中のものではないケースに対応 TDC片口 end
 
    recv_que = mq_open(QUE_NAME, O_RDONLY|O_CREAT, FILE_MODE, NULL);
    mq_getattr(recv_que, &attr);
    printf("mq_open [%ld]\n", attr.mq_msgsize);
    buff = malloc(attr.mq_msgsize);
    if ( buff == NULL ) {
        handle_error("malloc");
    }
    if ( recv_que == -1 ) {
        perror("mq_open error");
    }
    else {
        while ( 1 ) {
            memset(buff, 0, attr.mq_msgsize);
            if( mq_receive(recv_que, buff, attr.mq_msgsize, NULL) == -1 ) {
                perror("mq_receive error");
                break;
            }
            //printf("received msg: %s [%d]\n", buff, (int)strlen(buff));
            if ( strcmp(buff, "CLOSE") == 0 ) {
                break;
            }
            else if ( memcmp(buff, "COMSV/", 6) == 0 ) {
                // COMSV/[機能番号]/[施設コード]/[デバイスエッジ番号][TAB[透析装置識別子]TAB[オーダー番号]]
                // [機能番号]取得
                req_no = 0;
                memset(work, 0, sizeof(work));
                get_text(1, buff, work);
                if ( strlen(work) > 0 ) {
                    for ( i = 6, j = 0; i < strlen(work); i++ ) {
                        if ( work[i] == '/' ) {
                            work[i] = 0;
                            j = i + 1;
                            break;
                        }
                    }
                    req_no = atoi(work + 6);
                }
                if ( j == 0 || req_no < 1 || (req_no > REQ_NO_MAX && req_no != REQ_SCNOUT) ) {
                    // メッセージ異常
                    continue;
                }
                if ( memcmp(work + j, facility_cd, 6) != 0 ) {
                    // 施設コード不一致
                    continue;
                }
                if ( device_edge_no != atoi(work + j + 7) ) {
                    // デバイスエッジ番号不一致
                    continue;
                }
                if ( req_no == 5 ) {
                    // 通信サーバ設定読み込み
                    comsv_work_fpath(-1, WORK_COMSV_SET, fpath);
                    ret = comsv_rest_get_mst(0, fpath);
                    printf("comsv_rest_get_mst = [%d]\n", ret);
                    ret = comsv_json_mst_comset(fpath, &_comsvCache._comsvSet);
                    printf("comsv_json_mst_comset = [%d]\n", ret);
                    // 仮想端末（処置者）読み込み
                    comsv_work_fpath(-1, WORK_COMSV_USER, fpath);
                    ret2 = comsv_rest_get_lcd(-1, "", "", 29, configParam.facilityCd, fpath);
                    // #10557 2024.05.17 mod 引数間違い TDC米沢 start
                    //printf("comsv_rest_get_lcd 29 = [%d]\n", ret);
                    printf("comsv_rest_get_lcd 29 = [%d]\n", ret2);
                    // #10557 2024.05.17 mod 引数間違い TDC米沢 end
                    ret2 = comsv_json_lcd_req29(fpath, &_comsvCache._lcdReq29);
                    // #10557 2024.05.17 mod 引数間違い TDC米沢 start
                    //printf("comsv_json_lcd_req29 = [%d]\n", ret);
                    printf("comsv_json_lcd_req29 = [%d]\n", ret2);
                    // #10557 2024.05.17 mod 引数間違い TDC米沢 end
                    // #12304 2025.10.21 add ログ強化（仮想端末処置者読み込み） TDC高村 start
                	if ( ret2 != 0 ) {
                		sprintf(clog, "仮想端末（処置者）の読み込みに失敗しました");
		                LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
                	}
                    // #12304 2025.10.21 add ログ強化（仮想端末処置者読み込み） TDC高村 end
                    if ( ret == 0 && ret2 == 0 ) {
                        if ( _comsvCache._comsvSet.treat_moni_interval > 0 ) {
                            // 治療中モニタ通知間隔（通信サーバ設定の値を使う）
                            devicecapConf.nSendDialysisMonitorInterval = _comsvCache._comsvSet.treat_moni_interval;
                        }
                        if ( _comsvCache._comsvSet.other_moni_interval > 0 ) {
                            // 治療外モニタ通知間隔（通信サーバ設定の値を使う）
                            devicecapConf.nSendUntreatMonitorInterval = _comsvCache._comsvSet.other_moni_interval;
                        }
                        // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
                        if ( _comsvCache._comsvSet.treat_realtime_monito_interval > 0 ) {
                			// 治療中リアルタイムモニタ通知間隔（通信サーバ設定の値を使う）
                			devicecapConf.nRealSendDialysisMonitorInterval = _comsvCache._comsvSet.treat_realtime_monito_interval;
                		}
                		if ( _comsvCache._comsvSet.other_realtime_monito_interval > 0 ) {
                			// 治療外リアルタイムモニタ通知間隔（通信サーバ設定の値を使う）
                			devicecapConf.nRealSendUntreatMonitorInterval = _comsvCache._comsvSet.other_realtime_monito_interval;
                		}
                        // add 治療記録用データと治療状況用データの登録先を振分けにする 高 end
                        sprintf(clog, "device_timeout : %d", _comsvCache._comsvSet.device_timeout);
                        LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
                        sprintf(clog, "treat_moni_interval : %d [%d]",
                            _comsvCache._comsvSet.treat_moni_interval, devicecapConf.nSendDialysisMonitorInterval);
                        LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
                        sprintf(clog, "other_moni_interval : %d [%d]",
                            _comsvCache._comsvSet.other_moni_interval, devicecapConf.nSendUntreatMonitorInterval);
                        LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
                        // 本体揮発領域の保存処理(非同期)
                        overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);

                        // #10557 2024.05.17 add ロガーに通信サーバー設定変更を通知 TDC米沢 start
                        SyncComSVConfigToLogger();
                        // #10557 2024.05.17 add ロガーに通信サーバー設定変更を通知 TDC米沢 end
                    }
                }
                else if ( req_no == 6 ) {
                    // 仮想端末（愁訴処置）読み込み
                    comsv_work_fpath(-1, WORK_COMSV_TREAT, fpath);
                    ret = comsv_rest_get_lcd(-1, "", "", 50, configParam.facilityCd, fpath);
                    printf("comsv_rest_get_lcd 50 = [%d]\n", ret);
                    ret = comsv_json_lcd_req50(fpath, &_comsvCache._lcdReq50);
                    printf("comsv_json_lcd_req50 = [%d]\n", ret);
                    if ( ret == 0 ) {
                        // 本体揮発領域の保存処理(非同期)
                        overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);
                    }
                }
                else if ( req_no == 7 ) {
                    // 仮想端末（処置者）読み込み
                    comsv_work_fpath(-1, WORK_COMSV_USER, fpath);
                    ret = comsv_rest_get_lcd(-1, "", "", 29, configParam.facilityCd, fpath);
                    printf("comsv_rest_get_lcd 29 = [%d]\n", ret);
                    ret = comsv_json_lcd_req29(fpath, &_comsvCache._lcdReq29);
                    printf("comsv_json_lcd_req29 = [%d]\n", ret);
                    // #12304 2025.10.21 add ログ強化（仮想端末処置者読み込み） TDC高村 start
                    //if ( ret == 0 ) {
                	if ( ret != 0 ) {
                		sprintf(clog, "仮想端末（処置者）の読み込みに失敗しました");
		                LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
                	}
                    else {
                    // #12304 2025.10.21 add ログ強化（仮想端末処置者読み込み） TDC高村 end
                        // 本体揮発領域の保存処理(非同期)
                        overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);
                    }
                }
                else if ( req_no == 13 ) {
                    // チェックリストマスタ読み込み
                    comsv_work_fpath(-1, WORK_COMSV_CHECK, fpath);
                    ret = comsv_rest_get_mst(2, fpath);
                    printf("comsv_rest_get_mst = [%d]\n", ret);
                    ret = comsv_json_mst_checklist(fpath, &_comsvCache._checkMst);
                    printf("comsv_json_mst_checklist = [%d]\n", ret);
                    if ( ret == 0 ) {
                        // 本体揮発領域の保存処理(非同期)
                        overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);
                    }
                }
                else if ( req_no == 15 ) {
                    // 検査項目マスタ読み込み
                    comsv_work_fpath(-1, WORK_COMSV_EXAM, fpath);
                    ret = comsv_rest_get_mst(3, fpath);
                    printf("comsv_rest_get_mst = [%d]\n", ret);
                    ret = comsv_json_mst_examitem(fpath, &_comsvCache._examMst);
                    printf("comsv_json_mst_examitem = [%d]\n", ret);
                    if ( ret == 0 ) {
                        // 本体揮発領域の保存処理(非同期)
                        overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);
                    }
                }
                else {
                    dev_no = 0;
                    ord_no = 0;
                    ctl_no = 0;
                    // [装置識別子]取得
                    memset(work, 0, sizeof(work));
                    get_text(2, buff, work);
                    if ( strlen(work) > 0 ) {
                        dev_no = atol(work);
                    }
                    if ( dev_no <= 0 ) {
    					sprintf(clog, "メッセージキュー受信[%d] : 対象装置指定値異常[装置番号%ld]", req_no, dev_no);
                        LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
                        continue;
                    };
                    for ( i = 0, dno = -1; i < DEV_MAX; i++ ) {
                        if ( conSock[i].scn.dev_no == dev_no ) {
                            // 対象装置あり
                            dno = i;
                            break;
                        }
                    }
                    // mod FNSI-バグ 通信サーバ 高 start
                    // if ( dno < 0 ) {
                    if ( dno < 0 || (req_no == 1 && conSock[dno].scn.conflg != 2) ) {
                    // mod FNSI-バグ 通信サーバ 高 start
                        if ( req_no == 11 || req_no == 12 ) {
                            // 後体重測定／治療状況確認の通知
                        }
                        else {
                            // add FNSI-バグ 通信サーバ 高 start
                            if(req_no == 1) {
                                new_flag = true;
                                // 条件送信
                                memset(dev_type, 0, sizeof(dev_type));
                                memset(dev_sno, 0, sizeof(dev_sno));
                                dev_format = 0;
                                dev_comm = 0;
                                dev_idx = 0;
                                memset(mstOption, 0, sizeof(mstOption));
                                if ( check_is_mqueue_device(dev_no, dev_type, dev_sno, &dev_format, &dev_comm, &dev_idx, mstOption, mstIpAddr) == false ) {
                                    sprintf(clog, "メッセージキュー受信[%d] : 対象装置なし0[装置番号%ld]", req_no, dev_no);
                                    LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
                                    continue;
                                }
                                
                                sprintf(clog, "[gs debug] : dev_type = [%s], dev_sno = [%s], dev_format = [%c], dev_comm = [%c], mstIpAddr = [%s]", 
                                                dev_type, dev_sno, dev_format, dev_comm, mstIpAddr);
                                LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
                                
                                if ( dev_comm != NTSS_COMM_TYPE_NEW ) {
                                    if(dno < 0) {
                                        sprintf(clog, "メッセージキュー受信[%d] : 対象装置なし1[装置番号%ld]", req_no, dev_no);
                                        LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
                                        continue;
                                    }
                                    new_flag = false;
                                }
                                
                                dno_1 = con_sock_search();
                                if ( dno_1 >= DEV_MAX ) {
                                    sprintf(clog, "メッセージキュー受信[%d] : 対象装置なし2[装置番号%ld]", req_no, dev_no);
                                    LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
                                    continue;
                                }
                                
                                if(new_flag == true) {
                                    con_sock[dno_1].scn.devsw = dev_format;
                                    memcpy(con_sock[dno_1].scn.devid, dev_sno, 8);
                                    con_sock[dno_1].scn.devid[7] = ' ';
                                    memcpy(con_sock[dno_1].scn.deviceType, dev_type, 3);
                                    
                                    // 作業データ用装置番号フォルダ作成
                                    comsv_work_mkdir_dev(dev_no);
                                    
                                    // 装置状態管理データを取得
                                    comsv_work_fpath(dev_no, WORK_DEV_STATE, fpath);
                                    i = comsv_rest_get_dev(dev_no, con_sock[dno_1].scn.deviceType, con_sock[dno_1].scn.devid, fpath);
                                    printf("comsv_rest_get_dev = [%d]\n", i);
                                    
                                    i = comsv_json_dev_state(fpath, 0, &(con_sock[dno_1].scn));
                                    printf("comsv_json_dev_state = [%d]\n", i);
                                    
                                    printf("treatment = [%d]\n", con_sock[dno_1].scn.treatment);
                                    
                                    if( con_sock[dno_1].scn.treatment != 9 ) {
                                        if(dno < 0) {
                                            con_sock[dno_1].using = false;
                                            memset(&con_sock[dno_1].scn, 0, sizeof(struct scn_data_fm));
                                            
                                            sprintf(clog, "メッセージキュー受信[%d] : 対象装置なし3[装置番号%ld]", req_no, dev_no);
                                            LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
                                            continue;
                                        }
                                        if(con_sock[dno].scn.force_flg == 1)
                                            con_sock[dno].scn.force_flg = 0;
                                    }
                                    else {
                                        if(!(dno >= 0 && con_sock[dno].scn.force_flg == 1)) {
                                            // 強制オフライン
                                            con_sock[dno_1].scn.force_flg = 1;
                                            con_sock[dno_1].scn.dev_no = dev_no;
                                            con_sock[dno_1].using = true;
                                            con_sock[dno_1].running = true;
                                            con_sock[dno_1].scn.conflg = 0;
                                            con_sock[dno_1].thread_no = dno_1;
                                            con_sock[dno_1].scn.dev_idx = dev_idx;
                                            strcpy(con_sock[dno_1].scn.ip_addr, mstIpAddr);
                                            con_sock[dno_1].scn.commType = NTSS_COMM_TYPE_NEW;
                                            // 装置オプション
                                            sscanf(mstOption[0], "%04hX", &con_sock[dno_1].scn.option[0]);
                                            sscanf(mstOption[1], "%04hX", &con_sock[dno_1].scn.option[1]);
                                            sscanf(mstOption[2], "%04hX", &con_sock[dno_1].scn.option[2]);
                                            sscanf(mstOption[3], "%04hX", &con_sock[dno_1].scn.option[3]);
                                            sscanf(mstOption[4], "%04hX", &con_sock[dno_1].scn.option[4]);
                                            
                                            sprintf(clog, "メッセージキュー受信[%d] : :装置がつながっていない場合,強制オフライン[装置番号%ld]", req_no, dev_no);
                                            LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
                                            
                                            // スレッド作成
                                            pthread_create(&(thr_sv[dno_1]), &thread_attr, comsv_stream, &(con_sock[dno_1]));
                                            dno = dno_1;
                                        }
                                    }
                                }
                            }
                            else {
                            // add FNSI-バグ 通信サーバ 高 end
                                sprintf(clog, "メッセージキュー受信[%d] : 対象装置なし4[装置番号%ld]", req_no, dev_no);
                                LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
                                continue;
                            }
                        }
                    }
                    if ( req_no == REQ_SCNOUT ) {
                        // 装置制御データ（各種状態）のログ出力
                        if ( conSock[dno].running == true ) {
                            // スレッド有りなら
                            comsv_scn_output(&conSock[dno].scn);
                        }
                        continue;
                    }
                    // #11192 2025.04.02 mod 治療終了指示にオーダー番号を含める TDC片口 start
                    // // mod 透析患者さんのレポート画面を差入れする 高 start
                    // // if ( dno >= 0 && req_no != 2 && req_no != 9 && req_no <= 10 ) {
                    // if (( dno >= 0 && req_no != 2 && req_no != 9 && req_no <= 10 ) || (req_no >= 19 && req_no <= 21) ){
                    // // mod 透析患者さんのレポート画面を差入れする 高 end
                    if ((dno >= 0 && req_no != 2 && req_no != 9 && req_no <= 10) || req_no == 17 || (req_no >= 19 && req_no <= 21))
                    {
                        // #11192 2025.04.02 mod 治療終了指示にオーダー番号を含める TDC片口 end

                        // 装置オプション読出＆未登録患者割付
                        // ＆後体重測定＆治療状況確認以外
                        // [オーダー番号]取得
                        memset(work, 0, sizeof(work));
                        get_text(3, buff, work);
                        if ( strlen(work) > 0 ) {
                            ord_no = atol(work);
                        }
                        if ( req_no != 4 && ord_no <= 0 ) {
                            // 次患者情報以外の場合、ord_noは必須
                            continue;
                        }
                    }
                    if ( dno >= 0 && req_no == 1 ) {
                        // 条件送信
                        // [条件送信管理番号]取得
                        memset(work, 0, sizeof(work));
                        get_text(4, buff, work);
                        if ( strlen(work) > 0 ) {
                            ctl_no = atol(work);
                            // mod FNSI-バグ 通信サーバ 高 start
                            // if ( conSock[dno].scn.conflg != 2) {
                            if ( conSock[dno].scn.conflg != 2 && con_sock[dno].scn.force_flg != 1) {
                            // mod FNSI-バグ 通信サーバ 高 end
                                // 体重計測定実績のステータス・メッセージデータを更新する
                                comsv_rest_put_scale_state(conSock[dno].scn.dev_no, conSock[dno].scn.deviceType, conSock[dno].scn.devid, ctl_no, 1);
                                continue;
                            }
                            else if ( (conSock[dno].scn.mon_sta & 1) ) {
                                // 体重計測定実績のステータス・メッセージデータを更新する
                                comsv_rest_put_scale_state(conSock[dno].scn.dev_no, conSock[dno].scn.deviceType, conSock[dno].scn.devid, ctl_no, 5);
                                continue;                                
                            }
                        }
                        // [ハッシュ値]取得
                        memset(work, 0, sizeof(work));
                        get_text(5, buff, work);
                    }
                    // #11192 2025.04.02 add 治療終了指示に含まれたオーダー番号がDE側で治療中のものではないケースに対応 TDC片口 start
                    if (dno >= 0 && req_no == 17)
                    {
                        // 対象オーダーがDE側が把握している治療オーダーではない、またはDE側で治療中ではない
                        if (ord_no > 0 && (ord_no != conSock[dno].scn.ord_no || !conSock[dno].scn.mon_sta & 1))
                        {
                            sprintf(clog, "メッセージキュー受信[%d] : 不一致ord_noの治療終了指示[受信番号%ld, 番号%ld]", req_no, ord_no, conSock[dno].scn.ord_no);
                            LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
                            
                            conSock[dno].scn.received_end_treat_ord_no = ord_no;
                            pthread_create(&thr_end_treat, &thread_attr, comsv_thread_other_ord_no_end_treat, &(con_sock[dno].scn));
                            // 下に続く通常の治療終了処理を行わない
                            ord_no = 0;
                            continue;
                        }
                    }
                    // #11192 2025.04.02 add 治療終了指示に含まれたオーダー番号がDE側で治療中のものではないケースに対応 TDC片口 end
                    
                    // mod FNSI-バグ 通信サーバ 高 start
                    // if ( dno >= 0 && conSock[dno].scn.conflg == 2 && (conSock[dno].running == true || con_sock[dno].scn.devsw == 'F') ) {
                    if ( dno >= 0 && (conSock[dno].scn.conflg == 2 || (conSock[dno].scn.conflg == 0 && con_sock[dno].scn.force_flg == 1)) 
                         && (conSock[dno].running == true || con_sock[dno].scn.devsw == 'F') ) {
                    // mod FNSI-バグ 通信サーバ 高 end
                        // mod 透析患者さんのレポート画面を差入れする 高 start
                        if( req_no == 19 ) {
                            conSock[dno].scn.ord_no_bmp = ord_no;
                        } 
                        else if( req_no >= 20 && req_no <= 21 ) {
                            if( ord_no == 0 || ord_no != conSock[dno].scn.ord_no) {
                                sprintf(clog, "メッセージキュー受信[%d] : オーダー番号なし[受信番号%ld, 番号%ld]", req_no, ord_no, conSock[dno].scn.ord_no);
                                LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
                                continue;
                            }
                        }
                        else {
                            if ( ord_no && req_no != 4 ) {
                                // オーダー番号有り＆次患者情報以外
                                conSock[dno].scn.ord_no = ord_no;
                            }
                        }
                        // mod 透析患者さんのレポート画面を差入れする 高 end
                        if ( ctl_no ) conSock[dno].scn.cond_send_ctrl = ctl_no;
                        if ( req_no == 1 ) {
                            memcpy(conSock[dno].scn.cond_send_hash, work, 64);
                        }
                        else if ( con_sock[dno].scn.devsw == 'F' && (req_no == 16 || req_no == 17) ) {
                            // オフライン運転開始／終了の通知
                            // [透析開始／終了日時]取得（存在すればこの日時"yyyyMMddHHmmss"を使用する）
                            memset(work, 0, sizeof(work));
                            get_text(3, buff, work);
                            if ( strlen(work) > 0 ) {
                                sprintf(dt, "%.4s/%.2s/%.2s", work, work + 4, work + 6);
                                sprintf(tm, "%.2s:%.2s:%.2s", work + 8, work + 10, work + 12);
                                if ( str_time(dt, tm, &l_time, 1) == 0 ) {
                                    if ( req_no == 16 && !con_sock[dno].scn.dial_start_date ) {
                                        con_sock[dno].scn.dial_start_date = l_time;
                                    }
                                    // #11192 2025.04.02 del 終了指示でdial_end_dateを0以外にセットするとDB側が終了しない問題の対処 TDC片口 start
                                    // else if ( req_no == 17 && !con_sock[dno].scn.dial_end_date ) {
                                    //     con_sock[dno].scn.dial_end_date = l_time;
                                    // }
                                    // #11192 2025.04.02 del 終了指示でdial_end_dateを0以外にセットするとDB側が終了しない問題の対処 TDC片口 end
                                }
                            }
                        }
                        if ( req_no >= 16 ) req_no -= 2;
                        else if ( req_no == 14 ) req_no--;
                        if ( req_no > 4 ) req_no -= 3;
                        conSock[dno].event[req_no -1] = 0x01;
                    }
    				else if ( req_no == 11 || req_no == 12 ) {
                        // 後体重測定／治療状況確認の通知
                        memset(dev_type, 0, sizeof(dev_type));
                        memset(dev_sno, 0, sizeof(dev_sno));
                        dev_format = 0;
                        dev_comm = 0;
                        // mod FNSI-バグ 通信サーバ 高 start
                        dev_idx = 0;
                        memset(mstOption, 0, sizeof(mstOption));
                        // if ( check_is_mqueue_device(dev_no, dev_type, dev_sno, &dev_format, &dev_comm) == true ) {
                        if ( check_is_mqueue_device(dev_no, dev_type, dev_sno, &dev_format, &dev_comm, &dev_idx, mstOption, mstIpAddr) == true ) {
                        // mod FNSI-バグ 通信サーバ 高 end
                            if ( req_no == 11 ) {
                                sprintf(clog, "装置未接続[%ld] : イベント（後体重測定）", dev_no);
                            }
                            else {
                                sprintf(clog, "装置未接続[%ld] : イベント（治療状況確認）", dev_no);
                            }
                            LogOutputs(NTSS_LOG_INFO, clog, 0, dev_type, dev_sno);
                            if ( (req_no == 11 && _comsvCache._comsvSet.pat_timing == '0') ||
                                (req_no == 12 && _comsvCache._comsvSet.pat_timing == '1') ) {
                                // #10457 2024.06.18 del デバイスエッジへの通知元で現患者クリアを実施 TDC高村 start
        					    // // 現患者クリアを行う
    					        // ret = comsv_rest_post_web_api(dev_no, dev_type, dev_sno, 0);
    					        // printf("comsv_rest_post_web_api = [%d]\n", ret);
                                // #10457 2024.06.18 del デバイスエッジへの通知元で現患者クリアを実施 TDC高村 end
           						if ( dev_comm == NTSS_COMM_TYPE_NEW && dev_format != 'I' && dev_format != 'J' ) {
        							// 画像転送ファイル削除
                                    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
                                    // comsv_bmp_remove(conSock->scn.dev_no);
                                    comsv_bmp_remove(conSock->scn.dev_no, conSock->scn.deviceType, conSock->scn.devid);
                                    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
                                }
                            }
                        }
                        else {
    					    sprintf(clog, "メッセージキュー受信[%d] : 対象装置なし[装置番号%ld]", req_no, dev_no);
                            LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
                        }            
                    }
                    else {
    					sprintf(clog, "メッセージキュー受信[%d] : 装置未接続[%ld]", req_no, conSock[dno].scn.dev_no);
    					LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");			
                    }
                }
            }
        }
    }

    free(buff);
    mq_unlink(QUE_NAME);
    mq_close(recv_que);
    
	// メッセージキュー受信スレッドの終了
	strcpy(clog, "メッセージキュースレッド : 終了");
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	pthread_exit((void *)0);
}

/**
* @fn bool check_is_mqueue_device(long dev_no, char *dev_type, char *dev_sno, char *dev_format, char *dev_comm, short *dev_idx, char (*mstOption)[5], char * mstIpAddr) {
 * @brief マスタとの突き合わせ（装置未接続用）
 * @param[in] dev_no 装置番号 
 * @param[out] dev_type 型式コード
 * @param[out] dev_sno 製造番号
 * @param[out] dev_format 通信フォーマット
 * @param[out] dev_comm 通信方式
 * @param[out] dev_idx 装置マスタINDEX
 * @param[out] mstOption 装置オプション
 * @param[out] mstIpAddr IPアドレス
 * @return true 突き合わせ成功
 * @return false マスタに存在しない
 */
// mod FNSI-バグ 通信サーバ 高 start
// bool check_is_mqueue_device(long dev_no, char *dev_type, char *dev_sno, char *dev_format, char *dev_comm) {
bool check_is_mqueue_device(long dev_no, char *dev_type, char *dev_sno, char *dev_format, char *dev_comm, short *dev_idx, char (*mstOption)[5], char * mstIpAddr) {
// mod FNSI-バグ 通信サーバ 高 end
	bool matchMst = false;
	int idx;
    long dno;
	char mstDevNo[9] = {0};

	for( idx = 0; idx < COUNTOF(_machineInfoData); idx++ ) {
		if ( _machineInfoData[idx].machineFormatCd == '\0' ) {
			// これ以降マスタデータなし
			break;
		}
		strncpy(mstDevNo, _machineInfoData[idx].machineNo, 8);
		sscanf(mstDevNo, "%08lX", &dno);
        if ( dno == dev_no ) {
 			memcpy(dev_type, _machineInfoData[idx].machineTypeCd, 3);   // 型式コード
			memcpy(dev_sno, _machineInfoData[idx].machineSerial, 7);    // 製造番号
            *dev_format = _machineInfoData[idx].machineFormatCd;        // 通信フォーマット
            *dev_comm = _machineInfoData[idx].machineCommCd;            // 通信方式
            // add FNSI-バグ 通信サーバ 高 start
            strncpy(mstIpAddr, _machineInfoData[idx].ipAddress, 15);
            if(_machineInfoData[idx].machineCommCd == NTSS_COMM_TYPE_NEW) {
                strncpy(mstOption[0], _machineInfoData[idx].machineOptine1, 4);
                strncpy(mstOption[1], _machineInfoData[idx].machineOptine2, 4);
                strncpy(mstOption[2], _machineInfoData[idx].machineOptine3, 4);
                strncpy(mstOption[3], _machineInfoData[idx].machineOptine4, 4);
                strncpy(mstOption[4], _machineInfoData[idx].machineOptine5, 4);
            }
            *dev_idx = idx + 1;
            // add FNSI-バグ 通信サーバ 高 end
			// 突き合わせ成功
			matchMst = true;
            break;
        }
	}
	return matchMst;
}
