using System;
using Microsoft.VisualBasic;

namespace jp.co.nikkiso.fn3.Cooperation.CSICoop
{
    /// <summary>
    /// ※※ 本クラスはシーエスアイ提供の「basCommon.bas」を移植したものである ※※
    /// </summary>
    public class CSICommon
    {
        #region メンバ定義

        #region その他定義
        // VBA.Collection ファクトリー
        public static CollectionFactory.clsVBACollectionClass objVBACollection = new CollectionFactory.clsVBACollectionClass();
        #endregion 

        #region 定数定義
        //******************************************************************************
        //*
        //*　他部門連携部品メソッドパラメータ定数定義
        //*
        //*　【概要】
        //*　　　・部品メソッドのパラメータ定義
        //*　　　　　　　コレクションオブジェクト
        //*　　　　　　　Variant配列・配列インデックス
        //******************************************************************************
        public const string CON_KINDOF_COME = "01";        //文書
        public const string CON_KINDOF_PRES = "20";        //処方
        public const string CON_KINDOF_INJ = "30";         //注射
        public const string CON_KINDOF_GEN = "41";         //汎用
        public const string CON_KINDOF_TEST = "60";        //検査
        public const string CON_KINDOF_XRAY = "70";        //画像
        #endregion

        #region 部品共通
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //>
        //> 部品共通パラメータ
        //>
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //******************************************************************************
        //*                                                                            *
        //* INパラメータ                                                               *
        //* 　患者属性検索（PARTSPATSCH）                                              *
        //* 　患者血液型検索（PARTSBLOODTYPE）                                         *
        //* 　患者感染症検索（PARTSINFECTION）                                         *
        //* 　患者保険情報検索（PARTSINSURANCE）                                       *
        //* 　患者透析情報出力（PARTSDIALYSIS）                                        *
        //*                                                                            *
        //******************************************************************************
        //***** Variant配列定義 *****
        public static object[] varINPARAM;  //患者番号・処理区分配列

        //******************************************************************************
        //*                                                                            *
        //* OUTパラメータ                                                              *
        //* 　患者オーダ登録／変更（PARTSORDER）                                       *
        //* 　診療フリー登録（PARTSEXAMFREE）                                          *
        //*                                                                            *
        //******************************************************************************
        //***** Variant配列定義 *****
        public static object[] varOUTPARAM; //登録データ管理番号配列

        //******************************************************************************
        //*                                                                            *
        //* ERRパラメータ                                                              *
        //*                                                                            *
        //******************************************************************************
        //***** Collection定義 *****
        public static VBA.Collection colERR = objVBACollection.CreateVBACollection();

        //***** Variant定義 *****
        public static object[] varERR;

        //***** IndexConst定義 *****
        public const int CON_ERR_FLG = 0;                                //ERRLEVEL
        public const int CON_ERR_CODE = 1;                               //ERRCODE
        public const int CON_ERR_TEXT = 2;                               //ERRTEXT
        #endregion 

        #region 患者属性検索
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //>
        //> 患者属性検索（PARTSPATSCH）パラメータ
        //>
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //******************************************************************************
        //*                                                                            *
        //* INパラメータ                                                               *
        //*                                                                            *
        //******************************************************************************
        //***** IndexConst定義 *****
        ////Public Const CON_PAT_PATIENTNO = 0;                         //患者番号
        //******************************************************************************

        //* OUTパラメータ                                                              *
        //*                                                                            *
        //******************************************************************************
        //***** Variant配列定義 *****
        public static object[] varPATSCH;                               //患者属性情報配列
        //***** IndexConst定義 *****
        public const int CON_PAT_PATIENTNO = 0;                         //患者番号
        public const int CON_PAT_PATIENTNM = 1;                         //患者氏名
        public const int CON_PAT_PATIENTNMKANA = 2;                     //患者カナ氏名
        public const int CON_PAT_BIRTHDAY = 3;                          //生年月日
        public const int CON_PAT_SEX = 4;                               //性別
        public const int CON_PAT_ADDRESS1 = 5;                          //住所１
        public const int CON_PAT_POSTALCODE1 = 6;                       //郵便番号１
        public const int CON_PAT_TEL1 = 7;                              //電話番号１
        public const int CON_PAT_ADDRESS2 = 8;                          //住所２
        public const int CON_PAT_POSTALCODE2 = 9;                       //郵便番号２
        public const int CON_PAT_TEL2 = 10;                             //電話番号２
        public const int CON_PAT_ADDRESS3 = 11;                         //住所３
        public const int CON_PAT_POSTALCODE3 = 12;                      //郵便番号３
        public const int CON_PAT_TEL3 = 13;                             //電話番号３
        #endregion

        #region 患者血液型検索
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //>
        //> 患者血液型検索（PARTSBLOODTYPE）パラメータ
        //>
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //******************************************************************************
        //*                                                                            *
        //* INパラメータ                                                               *
        //*                                                                            *
        //******************************************************************************
        //***** IndexConst定義 *****
        public const int CON_BLD_PATIENTNO = 0;                         //患者番号
        //******************************************************************************
        //*                                                                            *
        //* OUTパラメータ                                                              *
        //*                                                                            *
        //******************************************************************************
        //***** Variant配列定義 *****
        public static object[] varBLOODTYPE;                            //患者血液型情報配列
        //***** IndexConst定義 *****
        public const int CON_BLD_ABO = 0;                               //ABO式コード
        public const int CON_BLD_ABONAME = 1;                           //ABO式名称
        public const int CON_BLD_RH = 2;                                //RH式コード
        public const int CON_BLD_RHNAME = 3;                            //RH式名称
        public const int CON_BLD_DATE = 4;                              //血液型更新日
        #endregion

        #region 患者感染症検索
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //>
        //> 患者感染症検索（PARTSINFECTION）パラメータ
        //>
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //******************************************************************************
        //*                                                                            *
        //* INパラメータ                                                               *
        //*                                                                            *
        //******************************************************************************
        //***** IndexConst定義 *****
        public const int CON_INF_PATIENTNO = 0;                         //患者番号
        public const int CON_INF_MODE = 1;                              //区分
        //******************************************************************************
        //*                                                                            *
        //* OUTパラメータ                                                              *
        //*                                                                            *
        //******************************************************************************
        //***** Collection定義 *****
        public static VBA.Collection colINFECTION = objVBACollection.CreateVBACollection();
        //***** Variant配列定義 *****
        public static object[] varINFECTION;    //患者感染症情報配列        
        //***** IndexConst定義 *****
        public const int CON_INF_CODE = 0;                               //コード
        public const int CON_INF_NAME = 1;                               //名称
        public const int CON_INF_RESULT = 2;                             //結果
        public const int CON_INF_DATE = 3;                               //更新日
        #endregion

        #region 患者保険情報検索
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //>
        //> 患者保険情報検索（PARTSINSURANCE）パラメータ
        //>
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //******************************************************************************
        //*                                                                            *
        //* INパラメータ                                                               *
        //*                                                                            *
        //******************************************************************************
        //***** IndexConst定義 *****
        public const int CON_INS_PATIENTNO = 0;                          //患者番号
        public const int CON_INS_DEPARTMENT = 1;                         //科
        //******************************************************************************
        //*                                                                            *
        //* OUTパラメータ                                                              *
        //*                                                                            *
        //******************************************************************************
        //***** Collection定義 *****
        public static VBA.Collection colINSURANCE = objVBACollection.CreateVBACollection();
        //***** Variant配列定義 *****
        public static object[] varINSURANCE;    //患者保険情報配列
        //***** IndexConst定義 *****
        public const int CON_INS_CODE1 = 0;                              //法制コード１
        public const int CON_INS_KINDOFINS1 = 1;                         //保険種類１
        public const int CON_INS_CONTINUE1 = 2;                          //継続区分１
        public const int CON_INS_NAME1 = 3;                              //保険名称１
        public const int CON_INS_SHORTNAME1 = 4;                         //保険略称１
        public const int CON_INS_HKNP1 = 5;                              //保険者番号１
        public const int CON_INS_PFKBN1 = 6;                             //本人家族区分１
        public const int CON_INS_KIGO1 = 7;                              //記号１
        public const int CON_INS_BANGO1 = 8;                             //番号１
        public const int CON_INS_CODE2 = 9;                              //法制コード２
        public const int CON_INS_KINDOFINS2 = 10;                        //保険種類２
        public const int CON_INS_CONTINUE2 = 11;                         //継続区分２
        public const int CON_INS_NAME2 = 12;                             //保険名称２
        public const int CON_INS_SHORTNAME2 = 13;                        //保険略称２
        public const int CON_INS_HKNP2 = 14;                             //保険者番号２
        public const int CON_INS_PFKBN2 = 15;                            //本人家族区分２
        public const int CON_INS_KIGO2 = 16;                             //記号２
        public const int CON_INS_BANGO2 = 17;                            //番号２
        public const int CON_INS_CODE3 = 18;                             //法制コード３
        public const int CON_INS_KINDOFINS3 = 19;                        //保険種類３
        public const int CON_INS_CONTINUE3 = 20;                         //継続区分３
        public const int CON_INS_NAME3 = 21;                             //保険名称３
        public const int CON_INS_SHORTNAME3 = 22;                        //保険略称３
        public const int CON_INS_HKNP3 = 23;                             //保険者番号３
        public const int CON_INS_PFKBN3 = 24;                            //本人家族区分３
        public const int CON_INS_KIGO3 = 25;                             //記号３
        public const int CON_INS_BANGO3 = 26;                            //番号３
        #endregion

        #region 患者透析情報出力
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //>
        //> 患者透析情報出力（PARTSDIALYSIS）パラメータ
        //>
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //******************************************************************************
        //*                                                                            *
        //* INパラメータ                                                               *
        //*                                                                            *
        //******************************************************************************
        //***** IndexConst定義 *****
        public const int CON_DIA_PATIENTNO = 0;                         //患者番号
        public const int CON_DIA_MODE = 1;                              //処理区分（1:INSERT 3:DELETE）
        #endregion

        #region 患者オーダ登録／変更
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //>
        //> 患者オーダ登録／変更（PARTSORDER）パラメータ
        //>
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //******************************************************************************
        //*                                                                            *
        //* INパラメータ                                                               *
        //*                                                                            *
        //******************************************************************************
        //***** Collection定義 *****
        public static VBA.Collection colORDER = objVBACollection.CreateVBACollection();         //オーダコレクション
        public static VBA.Collection colHEADER = objVBACollection.CreateVBACollection();        //オーダヘッダコレクション
        public static VBA.Collection colGROUP = objVBACollection.CreateVBACollection();         //オーダグループコレクション
        public static VBA.Collection colDETAIL = objVBACollection.CreateVBACollection();        //オーダディテールコレクション
        public static VBA.Collection colDETAILINFO = objVBACollection.CreateVBACollection();    //オーダディテール情報コレクション
        //***** Variant配列定義 *****
        public static object[] varORDER;                                //オーダ配列
        public static object[] varHEADER;                               //オーダヘッダ配列
        public static object[] varGROUP;                                //オーダグループ配列
        public static object[] varDETAIL;                               //オーダディテール配列
        public static object[] varDETAILINFO;                           //オーダディテール情報配列
        //***** IndexConst定義 *****
        //varORDER()
        public const int CON_O_TRANSACTION = 0;                         //処理区分（1:INSERT 2:MODIFY 3:DELETE 6:MODSTATUS 9:RENEWINFO）
        public const int CON_O_ACTION = 1;                              //動作区分（1:監査のみ 2:正常のみ登録 3:警告でも登録 4:強制登録）
        public const int CON_O_MODSTATUS = 2;                           //進捗変更区分（IS:発行/受付 AIS:再発行 STP:中止 EXE:実施 BCK:未実施に戻す）
        public const int CON_O_ISSUE = 3;                               //帳票区分
        public const int CON_O_HEADERCOLLECTION = 4;                    //オーダヘッダコレクション
        public const int CON_O_COMSTATUS = 5;                           //進捗マスタ参照フラグ（0:参照しない 1:参照する）
        public const int CON_O_ORDERDATE = 6;                           //新オーダ日（N:変更なし T:当日に変更）
        public const int CON_O_ORDERSTATUS = 7;                         //新オーダ進捗（A:未実施 B:発行済 Y:実施 Z:中止）
        public const int CON_O_ACCOUNTSTATUS = 8;                       //新会計進捗（A:未会計 Y:会計済 X:会計後修正）
        public const int CON_O_PRINTOBJECT = 9;                         //帳票発行（N:出力しない Y:出力する）
        public const int CON_O_DRUG = 10;                               //薬袋Ⅰ／Ｆ（N:出力しない Y:出力する）
        public const int CON_O_LACS = 11;                               //検査Ⅰ／Ｆ（N:出力しない Y:出力する）
        public const int CON_O_IBARS = 12;                              //医事Ⅰ／Ｆ（N:出力しない Y:出力する）
        public const int CON_O_RIS = 13;                                //RISⅠ／Ｆ（N:出力しない Y:出力する）
        //varHEADER()
        //オーダ共通定数
        public const int CON_H_ORDERNO = 0;                             //オーダ番号
        public const int CON_H_ORDERSUBNO = 1;                          //オーダサブ番号
        public const int CON_H_PATIENTNO = 2;                           //患者番号
        public const int CON_H_KINDOFORDER = 3;                         //オーダ種
        public const int CON_H_DETAILOFORDER = 4;                       //オーダ詳細
        public const int CON_H_STARTDATE = 5;                           //オーダ開始日
        public const int CON_H_STARTTIME = 6;                           //オーダ開始時刻
        public const int CON_H_ENDDATE = 7;                             //オーダ終了日
        public const int CON_H_ENDTIME = 8;                             //オーダ終了時刻
        public const int CON_H_ORDERSTATUS1 = 9;                        //実施進捗
        public const int CON_H_ORDERDEPARTMENT = 10;                    //科
        public const int CON_H_ORDERWARD = 11;                          //病棟
        public const int CON_H_ORDERDOCTOR = 12;                        //指示医
        public const int CON_H_ORDERDATE = 13;                          //オーダ日
        public const int CON_H_ORDERTIME = 14;                          //オーダ時刻
        public const int CON_H_ORDERTERMINAL = 15;                      //オーダ入力端末
        public const int CON_H_ORDEROPERATOR = 16;                      //オーダ入力者
        public const int CON_H_EXECUTEWARD = 17;                        //実施病棟
        public const int CON_H_EXECUTEROOM = 18;                        //実施病室
        public const int CON_H_EXECUTEDATE = 19;                        //実施日
        public const int CON_H_EXECUTETIME = 20;                        //実施時刻
        public const int CON_H_EXECUTEOPERATOR = 21;                    //実施者
        public const int CON_H_EXECUTENO = 22;                          //実施番号
        public const int CON_H_ISSUEDATE = 23;                          //発行日
        public const int CON_H_ISSUEOPERATOR = 24;                      //発行者
        public const int CON_H_UPDATETERMINAL = 25;                     //更新端末
        public const int CON_H_UPDATEOPERATOR = 26;                     //更新者
        //文書オーダ        public const int CON_H_COMMENTINDEX = 27;   //フリーコメントオーダのタイトル
        public const int CON_H_APPLICATIONTYPE = 28;                    //フリーコメント種
        public const int CON_H_FILENAME = 29;                           //文書ファイル名
        //処方オーダ
        public const int CON_H_PRESSLIPNO = 27;                         //処方箋番号
        public const int CON_H_SLIPFREECOMMENT = 28;                    //汎用コメント
        public const int CON_H_SLIPSELECTIONCOMMENT = 29;               //処方箋選択コメント
        public const int CON_H_GATHER1ENVELOP = 30;                     //一包化
        public const int CON_H_PHARMACYLOCATION = 31;                   //院内／院外区分
        public const int CON_H_URGENTSTATUS = 32;                       //緊急区分
        public const int CON_H_BOOKMARK = 33;                           //服薬説明
        public const int CON_H_DRUGORDER = 34;                          //麻薬処方
        public const int CON_H_DRUGSLIPNO = 35;                         //麻薬処方箋番号
        public const int CON_H_PRESGROUPCOLLECTION = 36;                //オーダグループコレクション
        //注射オーダ
        public const int CON_H_INJSLIPNO = 27;                          //注射箋通番
        public const int CON_H_INJPLANMODE = 28;                        //事後／予定区分(0:事後／1:予定)
        public const int CON_H_OUTEXECUTEWARD = 29;                     //外来実施部署(0：診察室／1:中央処置室)
        public const int CON_H_INJGROUPCOLLECTION = 30;                 //オーダグループコレクション
        //汎用オーダ
        public const int CON_H_GENGROUPCOLLECTION = 27;                 //オーダグループコレクション
        //検査オーダ
        public const int CON_H_TESTGROUPCOLLECTION = 27;                //オーダグループコレクション
        //画像オーダ
        public const int CON_H_EMARGENCYLEVEL1 = 27;                    //緊急区分
        public const int CON_H_EMARGENCYLEVEL2 = 28;                    //至急区分
        public const int CON_H_EMARGENCYLEVEL3 = 29;                    //至急現像区分
        public const int CON_H_PORTAIT = 30;                            //読影依頼状況
        public const int CON_H_XRAYGROUPCOLLECTION = 31;                //オーダグループコレクション
        //varGROUP()
        //オーダ共通定数
        public const int CON_G_STARTDATE = 0;                           //開始日付
        public const int CON_G_STARTTIME = 1;                           //開始時刻
        public const int CON_G_GROUPSTATUS1 = 2;                        //実施進捗
        public const int CON_G_EXECUTEWARD = 3;                         //実施病棟
        public const int CON_G_EXECUTEROOM = 4;                         //実施病室
        public const int CON_G_EXECUTEDATE = 5;                         //実施日
        public const int CON_G_EXECUTETIME = 6;                         //実施時刻
        public const int CON_G_EXECUTEOPERATOR = 7;                     //実施者
        public const int CON_G_EXECUTENO = 8;                           //実施番号
        public const int CON_G_PERIOD = 9;                              //期間
        public const int CON_G_GROUPCATEGORY = 10;                      //グループ種
        //処方オーダ
        public const int CON_G_ANOTHERPACKSTATUS = 11;                  //別包
        public const int CON_G_MIXMEDICINESTATUS = 12;                  //混合
        public const int CON_G_DOSAGECODE = 13;                         //用法コード
        public const int CON_G_DOSAGEINPUTMETHOD = 14;                  //用法入力方法
        public const int CON_G_DOSAGENAME = 15;                         //用法名称
        public const int CON_G_DOSAGECOMMENTCODE = 16;                  //用法コメントコード
        public const int CON_G_DOSAGECOMMENTINPUTMETHOD = 17;           //用法コメント入力方法
        public const int CON_G_DOSAGECOMMENTNAME = 18;                  //用法コメント名称
        public const int CON_G_DOSAGECOMMENTCODE2 = 19;                 //用法コメントコード２
        public const int CON_G_DOSAGECOMMENTINPUTMETHOD2 = 20;          //用法コメント入力方法２
        public const int CON_G_DOSAGECOMMENTNAME2 = 21;                 //用法コメント名称２
        public const int CON_G_SPECIALMEDICINESTATUS = 22;              //臨時薬剤フラグ
        public const int CON_G_PRESDETAILCOLLECTION = 23;               //オーダディテールコレクション
        //注射オーダ
        public const int CON_G_ROUTECODE = 11;                          //ルート項目コード
        public const int CON_G_TIMES = 12;                              //回数
        public const int CON_G_METHODCODE = 13;                         //投与方法項目コード
        public const int CON_G_ROUTECOMMENTCODE = 14;                   //ルートコメントコード
        public const int CON_G_ROUTECOMMENTTYPE = 15;                   //ルートコメント入力区分
        public const int CON_G_ROUTECOMMENTNAME = 16;                   //ルートコメント名称
        public const int CON_G_ROUTECOMMENTCODE2 = 17;                  //ルートコメントコード２
        public const int CON_G_ROUTECOMMENTTYPE2 = 18;                  //ルートコメント入力区分２
        public const int CON_G_ROUTECOMMENTNAME2 = 19;                  //ルートコメント名称２
        public const int CON_G_ROUTECOMMENTCODE3 = 20;                  //ルートコメントコード３
        public const int CON_G_ROUTECOMMENTTYPE3 = 21;                  //ルートコメント入力区分３
        public const int CON_G_ROUTECOMMENTNAME3 = 22;                  //ルートコメント名称３
        public const int CON_G_RPCOMMENTCODE = 23;                      //Rpコメントコード
        public const int CON_G_RPCOMMENTTYPE = 24;                      //Rpコメント入力区分
        public const int CON_G_RPCOMMENTNAME = 25;                      //Rpコメント名称
        public const int CON_G_RPCOMMENTCODE2 = 26;                     //Rpコメントコード２
        public const int CON_G_RPCOMMENTTYPE2 = 27;                     //Rpコメント入力区分２
        public const int CON_G_RPCOMMENTNAME2 = 28;                     //Rpコメント名称２
        public const int CON_G_RPCOMMENTCODE3 = 29;                     //Rpコメントコード３
        public const int CON_G_RPCOMMENTTYPE3 = 30;                     //Rpコメント入力区分３
        public const int CON_G_RPCOMMENTNAME3 = 31;                     //Rpコメント名称３
        public const int CON_G_STARTTIME1 = 32;                         //開始時刻１回目
        public const int CON_G_STARTTIME2 = 33;                         //開始時刻２回目
        public const int CON_G_STARTTIME3 = 34;                         //開始時刻３回目
        public const int CON_G_STARTTIME4 = 35;                         //開始時刻４回目
        public const int CON_G_STARTTIME5 = 36;                         //開始時刻５回目
        public const int CON_G_STARTTIME6 = 37;                         //開始時刻６回目
        public const int CON_G_DRIPSPEED = 38;                          //指定速度
        public const int CON_G_INJDETAILCOLLECTION = 39;                //オーダディテールコレクション
        //汎用オーダ
        public const int CON_G_ACTIONCODE = 11;                         //行為コード
        public const int CON_G_GENDETAILCOLLECTION = 12;                //オーダディテールコレクション
        //検査オーダ
        public const int CON_G_TESTHEIGHT = 11;                         //身長
        public const int CON_G_TESTWEIGHT = 12;                         //体重
        public const int CON_G_TESTNOOFPREGNANCYMONTH = 13;             //妊娠週数
        public const int CON_G_TESTDETAILCOLLECTION = 14;               //オーダディテールコレクション
        //画像オーダ
        public const int CON_G_XRAYITEMCODE = 11;                       //画像項目
        public const int CON_G_XRAYPORTABLE = 12;                       //ポータブル
        public const int CON_G_XRAYHEIGHT = 13;                         //身長
        public const int CON_G_XRAYWEIGHT = 14;                         //体重
        public const int CON_G_XRAYDETAILCOLLECTION = 15;               //オーダディテールコレクション
        //varDETAIL()
        //処方オーダ
        public const int CON_D_PRESMEDICINECODE = 0;                    //薬剤コード
        public const int CON_D_PRESQUANTITY = 1;                        //使用量
        public const int CON_D_INGREDIENTQUANTITY = 2;                  //成分量
        public const int CON_D_INGREDIENTQUANTITYSIGN = 3;              //成分量入力
        public const int CON_D_SMASHSTATUS = 4;                         //粉砕
        public const int CON_D_ANOTHERPACKSTATUS = 5;                   //別包
        public const int CON_D_DIVIDESTATUS = 6;                        //分割
        public const int CON_D_PRESCOMMENTCODE = 7;                     //コメントコード
        public const int CON_D_PRESCOMMENTINPUTMETHOD = 8;              //コメント入力方法
        public const int CON_D_PRESCOMMENTNAME = 9;                     //コメント名称
        public const int CON_D_QUANTITY1 = 10;                          //不均等１
        public const int CON_D_QUANTITY2 = 11;                          //不均等２
        public const int CON_D_QUANTITY3 = 12;                          //不均等３
        public const int CON_D_QUANTITY4 = 13;                          //不均等４
        public const int CON_D_QUANTITY5 = 14;                          //不均等５
        public const int CON_D_QUANTITY6 = 15;                          //不均等６
        //注射オーダ
        public const int CON_D_INJMEDICINECODE = 0;                     //薬剤コード
        public const int CON_D_INJQUANTITY = 1;                         //入力数量
        public const int CON_D_SELECTEDUNIT = 2;                        //入力単位
        public const int CON_D_INJCOMMENTCODE = 3;                      //薬剤コメントコード
        public const int CON_D_INJCOMMENTINPUTMETHOD = 4;               //コメント入力方法
        public const int CON_D_INJCOMMENTNAME = 5;                      //コメント名称
        //汎用オーダ
        public const int CON_D_FUNCTIONID = 0;                          //機能コード（01：部位 02：コメント 03：会計コメント 04：処置薬剤 05：処置材料 06：時間）
        public const int CON_D_ITEMCODE = 1;                            //項目コード
        public const int CON_D_GENQUANTITY = 2;                         //使用量
        public const int CON_D_FREECOMMENT = 3;                         //フリーテキスト
        public const int CON_D_STARTTIME = 4;                           //開始時間
        public const int CON_D_ENDTIME = 5;                             //終了時間
        //検査オーダ
        public const int CON_D_TESTITEMCODE = 0;                        //検査項目コード
        public const int CON_D_EMARGENCYLEVEL = 1;                      //緊急区分（0:通常 1:至急 2:緊急）
        public const int CON_D_TESTMEDICINECOLLECTION = 2;              //検査薬剤コレクション
        public const int CON_D_TESTTIMECOLLECTION = 3;                  //負荷／日内時間コレクション
        public const int CON_D_TESTCOMMENTCOLLECTION = 4;               //検査コメントコレクション
        //画像オーダ
        public const int CON_D_DETAILCODE = 0;                          //レコード区分（20：薬剤（造影剤）
        public const int CON_D_XRAYSUBITEMCODE = 1;                     //画像項目
        public const int CON_D_USEQUANTITY = 2;                         //使用量
        public const int CON_D_UNIT = 3;                                //単位
        public const int CON_D_SCOUNT = 4;                              //スライス数
        public const int CON_D_FILMDIVISION = 5;                        //分割数
        public const int CON_D_PHOTOGRAPHTIMES = 6;                     //撮影回数
        public const int CON_D_MISTAKERASON = 7;                        //写損理由
        public const int CON_D_LOSSFILMCOUNT = 8;                       //写損数
        public const int CON_D_PIPEVOLTAGEUNIT = 9;                     //管電圧（量）
        public const int CON_D_PIPEVOLTAGEDFV = 10;                     //管電圧（単位）
        public const int CON_D_DISTANCEUNIT = 11;                       //距離（量）
        public const int CON_D_DISTANCEDFV = 12;                        //距離（単位）
        public const int CON_D_CURRENTUNIT = 13;                        //電圧（量）
        public const int CON_D_CURRENTDFV = 14;                         //電圧（単位）
        public const int CON_D_TIMEUNIT = 15;                           //時間（量）
        public const int CON_D_TIMEDFV = 16;                            //時間（単位）
        public const int CON_D_XRAYCOMMENTCODE = 17;                    //コメントコード
        public const int CON_D_XRAYCOMMENTNAME = 18;                    //コメント名称
        //varDETAILINFO()        //検査オーダディテール情報定数
        public const int CON_D_TESTMEDICINECODE = 0;                    //薬剤項目コード
        public const int CON_D_TESTQUANTITY = 1;                        //使用量
        public const int CON_D_TESTTIMECODE = 0;                        //時間コード
        public const int CON_D_TESTCOMMENTTYPE = 0;                     //コメント種
        public const int CON_D_TESTCOMMENTINPUTMETHOD = 1;              //入力区分
        public const int CON_D_TESTCOMMENTCODE = 2;                     //コメント項目コード
        public const int CON_D_TESTCOMMENTNAME = 3;                     //コメント名称
        //******************************************************************************
        //*                                                                            *
        //* OUTパラメータ                                                              *
        //*                                                                            *
        //******************************************************************************
        //***** IndexConst定義 *****
        public const int CON_ORDERNO = 0;                               //オーダ番号
        public const int CON_ORDERSUBNO = 1;                            //オーダサブ番号
        public const int CON_ORDERSTATUS = 2;                           //オーダ進捗
        public const int CON_ACCOUNTSTATUS = 3;                         //会計進捗
        public const int CON_GROUPSTATUS = 4;                           //グループ進捗
        public const int CON_GROUPACCOUNT = 5;                          //グループ会計進捗
        public const int CON_ISSUE = 6;                                 //帳票出力有無
        public const int CON_SLIPNO = 7;                                //処方箋番号
        public const int CON_DRUGSLIPNO = 8;                            //麻薬処方箋番号
        #endregion

        #region 診察フリー登録録／変更
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //>
        //> 診察フリー登録録／変更（PARTSEXAMFREE）パラメータ
        //>
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //******************************************************************************
        //*                                                                            *
        //* INパラメータ                                                               *
        //*                                                                            *
        //******************************************************************************
        //***** Variant配列定義 *****
        public static object[] varEXAMFREE; //オーダ配列
        //***** IndexConst定義 *****
        public const int CON_EXM_MODE = 0;                               //処理区分（1:登録、2:変更、3:削除）
        public const int CON_EXM_EXAMNO = 1;                             //診察番号
        public const int CON_EXM_PATIENTNO = 2;                          //患者番号
        public const int CON_EXM_DAPARTMENT = 3;                         //診療科
        public const int CON_EXM_PRACTICEDATE = 4;                       //診察日
        public const int CON_EXM_PRACTICETIME = 5;                       //診察時刻
        public const int CON_EXM_DIRECTIONDOCTOR = 6;                    //指示医
        public const int CON_EXM_ENTRYSTAFF = 7;                         //登録者
        public const int CON_EXM_UPDATETERMINAL = 8;                     //更新端末
        public const int CON_EXM_UPDATEOPERATOR = 9;                     //更新者
        public const int CON_EXM_POSNO = 10;                             //POS番号
        public const int CON_EXM_TITLE = 11;                             //診療フリータイトル
        public const int CON_EXM_TEXT = 12;                              //診療フリー内容
        //public const int CON_EXM_SECTSEQ = 13;                           //管理番号←使用しない
        //public const int CON_EXM_SECTCLASS = 14;                         //部門区分←使用しない
        //******************************************************************************
        //*                                                                            *
        //* OUTパラメータ                                                              *
        //*                                                                            *
        //******************************************************************************
        //***** IndexConst定義 *****
        public const int CON_EXAMNO = 0;                                 //診察番号
        #endregion

        #region 予約検索
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //>
        //> 予約検索（PARTSAPPSCH）パラメータ
        //>
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //******************************************************************************
        //*                                                                            *
        //* INパラメータ                                                               *
        //*                                                                            *
        //******************************************************************************
        //***** IndexConst定義 *****
        public const int CON_APP_APPOINTMENTNO_IN = 0;                  //予約番号
        //******************************************************************************
        //*                                                                            *
        //* OUTパラメータ                                                              *
        //*                                                                            *
        //******************************************************************************
        //***** Variant配列定義 *****
        public static object[] varAPPSCH;                               //予約情報配列
        //***** IndexConst定義 *****
        public const int CON_APP_APPOINTMENTNO = 0;                     //予約番号
        public const int CON_APP_PATIENTNO = 1;                         //患者番号
        public const int CON_APP_APPDATE = 2;                           //予約日
        public const int CON_APP_APPTIME = 3;                           //予約時間
        public const int CON_APP_REQUESTDEPT = 4;                       //依頼科
        public const int CON_APP_REQUESTDEPTNAME = 5;                   //依頼科名称
        public const int CON_APP_REQUESTDR = 6;                         //依頼医
        public const int CON_APP_REQUESTDRNAME = 7;                     //依頼医名称
        public const int CON_APP_VISITSTATUS = 8;                       //来院区分
        public const int CON_APP_VISITTIME = 9;                         //来院時刻
        public const int CON_APP_FREECOMMENT = 10;                      //予約コメント
        #endregion

        #region 患者予約情報検索
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //>
        //> 患者予約情報検索（PARTSPATAPPSCH）パラメータ
        //>
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //******************************************************************************
        //*                                                                            *
        //* INパラメータ                                                               *
        //*                                                                            *
        //******************************************************************************
        //***** IndexConst定義 *****
        public const int CON_PAPP_PATIENTNO1 = 0;                       //患者番号
        public const int CON_PAPP_APPDATE1 = 1;                         //予約開始日
        public const int CON_PAPP_APPENDDATE = 2;                       //予約終了日
        //******************************************************************************
        //*                                                                            *
        //* OUTパラメータ                                                              *
        //*                                                                            *
        //******************************************************************************
        //***** Collection定義 *****
        public static VBA.Collection colPATAPPSCH = objVBACollection.CreateVBACollection();
        //***** Variant配列定義 *****
        public static object[] varPATAPPSCH;                            //患者予約情報配列            
        //***** IndexConst定義 *****
        public const int CON_PAPP_APPOINTMENTNO = 0;                    //予約番号
        public const int CON_PAPP_PATIENTNO = 1;                        //患者番号
        public const int CON_PAPP_APPDATE = 2;                          //予約日
        public const int CON_PAPP_APPTIME = 3;                          //予約時間
        public const int CON_PAPP_DEPARTMENT = 4;                       //予約科
        public const int CON_PAPP_DEPARTMENTNAME = 5;                   //予約科名称
        public const int CON_PAPP_APPCODE = 6;                          //予約科目
        public const int CON_PAPP_APPCODENAME = 7;                      //予約科目名称
        public const int CON_PAPP_APPSLOTTIME = 8;                      //分数
        public const int CON_PAPP_REQUESTDEPT = 9;                      //依頼科
        public const int CON_PAPP_REQUESTDEPTNAME = 10;                 //依頼科名称
        public const int CON_PAPP_REQUESTDR = 11;                       //依頼医
        public const int CON_PAPP_REQUESTDRNAME = 12;                   //依頼医名称
        public const int CON_PAPP_FREECOMMENT = 13;                     //予約コメント
        #endregion

        #region 入院情報検索
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //>
        //> 入院情報検索（PARTSADMSCH）パラメータ
        //>
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //******************************************************************************
        //*                                                                            *
        //* INパラメータ                                                               *
        //*                                                                            *
        //******************************************************************************
        //***** IndexConst定義 *****
        //////public const int CON_ADM_PATIENTNO               = 0;     //患者番号
        public const int CON_ADM_TARGETDATE = 1;                        //対象日
        public const int CON_ADM_TARGETTIME = 2;                        //対象時刻
        //******************************************************************************
        //*                                                                            *
        //* OUTパラメータ                                                              *
        //*                                                                            *
        //******************************************************************************
        //***** Variant配列定義 *****
        public static object[] varADMSCH;   //入院情報配列
        //***** IndexConst定義 *****
        public const int CON_ADM_PATIENTNO = 0;                         //患者番号
        public const int CON_ADM_PATIENTTYPE = 1;                       //入外区分
        public const int CON_ADM_CURRENTDEPT = 2;                       //カレント科
        public const int CON_ADM_CURRENTWARD = 3;                       //カレント病棟
        public const int CON_ADM_CURRENTROOM = 4;                       //カレント病室
        public const int CON_ADM_CURRENTBED = 5;                        //カレントベッド
        public const int CON_ADM_OUTSTARTDATE = 6;                      //外出・外泊開始日付
        public const int CON_ADM_OUTSTARTTIME = 7;                      //外出・外泊開始時間
        public const int CON_ADM_OUTENDDATE = 8;                        //外出・外泊終了日付
        public const int CON_ADM_OUTENDTIME = 9;                        //外出・外泊終了時間
        public const int CON_ADM_DEATHDATE = 10;                        //死亡日
        #endregion

        #region 予約情報　登録／変更／削除
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //>
        //> 予約情報　登録／変更／削除（PARTSAPPPATIENT）パラメータ
        //>
        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //******************************************************************************
        //*                                                                            *
        //* INパラメータ                                                               *
        //*                                                                            *
        //******************************************************************************
        //***** IndexConst定義 *****
        public const int CON_APPP_MODE = 0;                             //処理区分（1:新規、2:変更、3:削除）
        public const int CON_APPP_PATIENTNO = 1;                        //患者番号
        public const int CON_APPP_REQUESTDEPT = 2;                      //依頼科
        public const int CON_APPP_REQUESTDR = 3;                        //依頼医
        public const int CON_APPP_APPOINTMENTNO = 4;                    //予約番号
        public const int CON_APPP_APPDATE = 5;                          //予約日
        public const int CON_APPP_APPTIME = 6;                          //予約時間
        public const int CON_APPP_APPSLOTTIME = 7;                      //分数
        public const int CON_APPP_DEPARTMENT = 8;                       //予約科コード
        public const int CON_APPP_APPCODE = 9;                          //予約科目コード
        public const int CON_APPP_APPACTIONCODE = 10;                   //予約行為コード
        public const int CON_APPP_FREECOMMENT = 11;                     //予約コメント
        public const int CON_APPP_VISITSTATUS = 12;                     //来院区分
        public const int CON_APPP_UPDATETERMINAL = 13;                  //更新端末
        public const int CON_APPP_UPDATEOPERATOR = 14;                  //更新者
        public const int CON_APPP_PREPARATIONCOLLECTION = 15;           //準備品コレクション
        public const int CON_APPP_COMMENTCOLLECTION = 16;               //コメントコレクション
        //******************************************************************************
        //*                                                                            *
        //* OUTパラメータ                                                              *
        //*                                                                            *
        //******************************************************************************
        //***** IndexConst定義 *****
        public const int CON_APPP_APPOINTMENTNO1 = 0;                   //予約番号
        #endregion

        #endregion


        #region メソッド定義

        //******************************************************************************
        //*
        //*  関数名：    pSetINPARAMData
        //*
        //*  概要  ：    INパラメータ配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetINPARAMData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varINPARAM[iIndex] = vValue;
                    break;
                case VariantType.Empty:
                case VariantType.Null:
                    varINPARAM[iIndex] = "";
                    break;
                default:
                    varINPARAM[iIndex] = vValue;
                    break;
            }
        }
        //Public Sub pSetINPARAMData(ByVal iIndex As Integer, ByVal vValue As Variant)
        //    Select Case VarType(vValue)
        //        Case vbObject
        //            Set varINPARAM(iIndex) = vValue
        //        Case vbEmpty, vbNull
        //            varINPARAM(iIndex) = ""
        //        Case Else
        //            varINPARAM(iIndex) = vValue
        //    End Select
        //End Sub

        //******************************************************************************
        //*
        //*  関数名：    pGetINPARAMData
        //*
        //*  概要  ：    INパラメータ配列から値を取得
        //*
        //*  引数  ：    ①配列のIndex番号
        //*
        //*  戻り値：    配列要素
        //*
        //******************************************************************************
        public static object pGetINPARAMData(int iIndex)
        {

            switch (Information.VarType(varINPARAM[iIndex]))
            {
                case VariantType.Object:
                    return varINPARAM[iIndex];
                default:
                    return varINPARAM[iIndex];
            }
        }
        //Public Function pGetINPARAMData(ByVal iIndex As Integer) As Variant
        //    Select Case VarType(varINPARAM(iIndex))
        //        Case vbObject
        //            Set pGetINPARAMData = varINPARAM(iIndex)
        //        Case Else
        //            pGetINPARAMData = varINPARAM(iIndex)
        //    End Select
        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pSetOUTPARAMData
        //*
        //*  概要  ：    OUTパラメータ配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetOUTPARAMData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varOUTPARAM[iIndex] = vValue;
                    break;
                case VariantType.Empty:
                case VariantType.Null:
                    varOUTPARAM[iIndex] = "";
                    break;
                default:
                    varOUTPARAM[iIndex] = vValue;
                    break;
            }
        }
        //Public Sub pSetOUTPARAMData(ByVal iIndex As Integer, ByVal vValue As Variant)
        //    Select Case VarType(vValue)
        //        Case vbObject
        //            Set varOUTPARAM(iIndex) = vValue
        //        Case vbEmpty, vbNull
        //            varOUTPARAM(iIndex) = ""
        //        Case Else
        //            varOUTPARAM(iIndex) = vValue
        //    End Select
        //End Sub

        //******************************************************************************
        //*
        //*  関数名：    pGetOUTPARAMData
        //*
        //*  概要  ：    OUTパラメータ配列から値を取得
        //*
        //*  引数  ：    ①配列のIndex番号
        //*
        //*  戻り値：    配列要素
        //*
        //******************************************************************************
        public static object pGetOUTPARAMData(int iIndex)
        {
            switch (Information.VarType(varOUTPARAM[iIndex]))
            {
                case VariantType.Object:
                    return varOUTPARAM[iIndex];
                default:
                    return varOUTPARAM[iIndex];
            }
        }
        //Public Function pGetOUTPARAMData(ByVal iIndex As Integer) As Variant
        //    Select Case VarType(varOUTPARAM(iIndex))
        //        Case vbObject
        //            Set pGetOUTPARAMData = varOUTPARAM(iIndex)
        //        Case Else
        //            pGetOUTPARAMData = varOUTPARAM(iIndex)
        //    End Select
        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pSetPATSCHData
        //*
        //*  概要  ：    患者属性情報配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetPATSCHData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varPATSCH[iIndex] = vValue;
                    break;
                case VariantType.Empty:
                case VariantType.Null:
                    varPATSCH[iIndex] = "";
                    break;
                default:
                    varPATSCH[iIndex] = vValue;
                    break;
            }
        }
        //Public Sub pSetPATSCHData(ByVal iIndex As Integer, ByVal vValue As Variant)
        //    Select Case VarType(vValue)
        //        Case vbObject
        //            Set varPATSCH(iIndex) = vValue
        //        Case vbEmpty, vbNull
        //            varPATSCH(iIndex) = ""
        //        Case Else
        //            varPATSCH(iIndex) = vValue
        //    End Select
        //End Sub

        //>>>>> [ADD] START by kawashima 2007.08.30 [E_PKG-PARTS-0018] >>>>>>>>>>>>>>>>>>>>>>>>
        //>>>>> リハスタ対応
        //******************************************************************************
        //*
        //*  関数名：    pGetADMSCHData
        //*
        //*  概要  ：    患者在院情報配列から値を取得
        //*
        //*  引数  ：    ①配列のIndex番号
        //*
        //*  戻り値：    配列要素
        //*
        //******************************************************************************
        public static String pGetADMSCHData(int iIndex)
        {
            if (varADMSCH[iIndex] == null)
            {
                return "";
            }
            else
            {
                return varADMSCH[iIndex].ToString();
            }
        }

// 戻り値をString型にしてNullチェックを不要とするよう変更
        //public static object pGetADMSCHData(int iIndex)
        //{
        //    switch (Information.VarType(varADMSCH[iIndex]))
        //    {
        //        case VariantType.Object:
        //            return varADMSCH[iIndex];
        //        default:
        //            return varADMSCH[iIndex];
        //    }
        //}
        //Public Function pGetADMSCHData(ByVal iIndex As Integer) As Variant
        //    Select Case VarType(varADMSCH(iIndex))
        //        Case vbObject
        //            Set pGetADMSCHData = varADMSCH(iIndex)
        //        Case Else
        //            pGetADMSCHData = varADMSCH(iIndex)
        //    End Select
        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pGetAPPSCHData
        //*
        //*  概要  ：    受付情報検索配列から値を取得
        //*
        //*  引数  ：    ①配列のIndex番号
        //*
        //*  戻り値：    配列要素
        //*
        //******************************************************************************
        public static String pGetAPPSCHData(int iIndex)
        {
            if (varAPPSCH[iIndex] == null)
            {
                return "";
            }
            else
            {
                return varAPPSCH[iIndex].ToString();
            }
        }

// 戻り値をString型にしてNullチェックを不要とするよう変更
        //Public Function pGetAPPSCHData(ByVal iIndex As Integer) As Variant
        //    Select Case VarType(varAPPSCH(iIndex))
        //        Case vbObject
        //            Set pGetAPPSCHData = varAPPSCH(iIndex)
        //        Case Else
        //            pGetAPPSCHData = varAPPSCH(iIndex)
        //    End Select
        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pGetPATAPPSCHCollectionItem
        //*
        //*  概要  ：    患者予約情報コレクションメンバの取得
        //*
        //*  引数  ：    ①コレクションの要素番号
        //*              ②配列のIndex番号（省略可）
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static object pGetPATAPPSCHCollectionItem(int viIndex1, ref object viIndex2)
        {
            try
            {
                if (pGetPATAPPSCHCollectionCount() == 0)
                {
                    return null;
                }

                object oIndex1 = (object)viIndex1;

                //配列要素が設定されている場合
                if (viIndex2 != null)
                {
                    //【課題】移植に不安あり
                    object[] obj = (object[])colPATAPPSCH.Item(ref oIndex1);
                    return obj[(int)viIndex2];
                }
                //配列要素が省略された場合
                else
                {
                    return colPATAPPSCH.Item(ref oIndex1);
                }
            }
            catch
            {
                // なにもしない
                return null;
            }
        }
        //Public Function pGetPATAPPSCHCollectionItem(ByVal viIndex1 As Integer, Optional viIndex2 As Integer) As Variant
        //    On Error GoTo Err_Handler
        //    If pGetPATAPPSCHCollectionCount = 0 Then Exit Function
        //    //配列要素が設定されている場合
        //    If IsMissing(viIndex2) = False Then
        //        pGetPATAPPSCHCollectionItem = colPATAPPSCH.Item(viIndex1)(viIndex2)
        //    Else
        //    //配列要素が省略された場合
        //        pGetPATAPPSCHCollectionItem = colPATAPPSCH.Item(viIndex1)        //    End If
        //Err_Handler:
        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pGetPATAPPSCHCollectionCount
        //*
        //*  概要  ：    患者予約情報コレクションの件数を取得
        //*
        //*  引数  ：    なし
        //*
        //*  戻り値：    患者予約情報コレクション件数
        //*
        //******************************************************************************
        public static int pGetPATAPPSCHCollectionCount()
        {
            return colPATAPPSCH.Count();
        }
        //Public Function pGetPATAPPSCHCollectionCount() As Integer

        //    pGetPATAPPSCHCollectionCount = colPATAPPSCH.Count

        //End Function
        //<<<<< [ADD] END   by kawashima 2007.08.30 [E_PKG-PARTS-0018] <<<<<<<<<<<<<<<<<<<<<<<<

        //******************************************************************************
        //*
        //*  関数名：    pGetPATSCHData
        //*
        //*  概要  ：    患者属性情報配列から値を取得
        //*
        //*  引数  ：    ①配列のIndex番号
        //*
        //*  戻り値：    配列要素
        //*
        //******************************************************************************
        public static String pGetPATSCHData(int iIndex)
        {
            if (varPATSCH[iIndex] == null)
            {
                return "";
            }
            else
            {
                return varPATSCH[iIndex].ToString();
            }
        }

// 戻り値をString型にしてNullチェックを不要とするよう変更
        //public static object pGetPATSCHData(int iIndex)
        //{
        //    switch (Information.VarType(varPATSCH[iIndex]))
        //    {
        //        case VariantType.Object:
        //            return varPATSCH[iIndex];
        //        default:
        //            return varPATSCH[iIndex];
        //    }
        //}
        //Public Function pGetPATSCHData(ByVal iIndex As Integer) As Variant

        //    Select Case VarType(varPATSCH(iIndex))
        //        Case vbObject
        //            Set pGetPATSCHData = varPATSCH(iIndex)
        //        Case Else
        //            pGetPATSCHData = varPATSCH(iIndex)
        //    End Select

        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pSetBLOODTYPEData
        //*
        //*  概要  ：    患者血液型情報配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetBLOODTYPEData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varBLOODTYPE[iIndex] = vValue;
                    break;
                case VariantType.Empty:
                case VariantType.Null:
                    varBLOODTYPE[iIndex] = "";
                    break;
                default:
                    varBLOODTYPE[iIndex] = vValue;
                    break;
            }
        }
        //Public Sub pSetBLOODTYPEData(ByVal iIndex As Integer, ByVal vValue As Variant)

        //    Select Case VarType(vValue)
        //        Case vbObject
        //            Set varBLOODTYPE(iIndex) = vValue
        //        Case vbEmpty, vbNull
        //            varBLOODTYPE(iIndex) = ""
        //        Case Else
        //            varBLOODTYPE(iIndex) = vValue
        //    End Select

        //End Sub

        //******************************************************************************
        //*
        //*  関数名：    pGetBLOODTYPEData
        //*
        //*  概要  ：    患者血液型情報配列から値を取得
        //*
        //*  引数  ：    ①配列のIndex番号
        //*
        //*  戻り値：    配列要素
        //*
        //******************************************************************************
        public static String pGetBLOODTYPEData(int iIndex)
        {
            if (varBLOODTYPE[iIndex] == null)
            {
                return "";
            }
            else
            {
                return varBLOODTYPE[iIndex].ToString();
            }
        }

// 戻り値をString型にしてNullチェックを不要とするよう変更
        //public static object pGetBLOODTYPEData(int iIndex)
        //{
        //    switch (Information.VarType(varBLOODTYPE[iIndex]))
        //    {
        //        case VariantType.Object:
        //            return varBLOODTYPE[iIndex];
        //        default:
        //            return varBLOODTYPE[iIndex];
        //    }
        //}
        //Public Function pGetBLOODTYPEData(ByVal iIndex As Integer) As Variant

        //    Select Case VarType(varBLOODTYPE(iIndex))
        //        Case vbObject
        //            Set pGetBLOODTYPEData = varBLOODTYPE(iIndex)
        //        Case Else
        //            pGetBLOODTYPEData = varBLOODTYPE(iIndex)
        //    End Select

        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pSetCollection
        //*
        //*  概要  ：    コレクションへのオブジェクトの追加
        //*
        //*  引数  ：    ①コレクション指定モード
        //*                1:オーダコレクション
        //*                2:オーダヘッダコレクション
        //*                3:オーダグループコレクション
        //*                4:オーダディテールコレクション
        //*                5:オーダディテール情報コレクション
        //*              ②コレクションへメンバ追加するオブジェクト
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetCollection(int iMode, object vValue)
        {

            Array aValue = (Array)vValue;

            switch (iMode)
            {
                case 1:
                    objVBACollection.AddObjectArray(ref colORDER, ref aValue);
                    break;
                case 2:
                    objVBACollection.AddObjectArray(ref colHEADER, ref aValue);
                    break;
                case 3:
                    objVBACollection.AddObjectArray(ref colGROUP, ref aValue);
                    break;
                case 4:
                    objVBACollection.AddObjectArray(ref colDETAIL, ref aValue);
                    break;
                case 5:
                    objVBACollection.AddObjectArray(ref colDETAILINFO, ref aValue);
                    break;
            }
            //switch (iMode)
            //{
            //    case 1:
            //        objVBACollection.AddObject(ref colORDER, ref vValue);
            //        break;
            //    case 2:
            //        objVBACollection.AddObject(ref colHEADER, ref vValue);
            //        break;
            //    case 3:
            //        objVBACollection.AddObject(ref colGROUP, ref vValue);
            //        break;
            //    case 4:
            //        objVBACollection.AddObject(ref colDETAIL, ref vValue);
            //        break;
            //    case 5:
            //        objVBACollection.AddObject(ref colDETAILINFO, ref vValue);
            //        break;
            //}
        }

        //******************************************************************************
        //*
        //*  関数名：    pSetORDERData
        //*
        //*  概要  ：    オーダ配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetORDERData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varORDER[iIndex] = vValue;
                    break;
                case VariantType.Null:
                case VariantType.Empty:
                    varORDER[iIndex] = string.Empty;
                    break;
                default:
                    varORDER[iIndex] = vValue;
                    break;
            }
        }

        //******************************************************************************
        //*
        //*  関数名：    pGetORDERData
        //*
        //*  概要  ：    オーダ配列から値を取得
        //*
        //*  引数  ：    ①配列のIndex番号
        //*
        //*  戻り値：    配列要素
        //*
        //******************************************************************************
        public static object pGetORDERData(int iIndex)
        {
            switch (Information.VarType(varORDER[iIndex]))
            {
                case VariantType.Object:
                    return varORDER[iIndex];
                default:
                    return varORDER[iIndex];
            }
        }
        //Public Function pGetORDERData(ByVal iIndex As Integer) As Variant

        //    Select Case VarType(varORDER(iIndex))
        //        Case vbObject
        //            Set pGetORDERData = varORDER(iIndex)
        //        Case Else
        //            pGetORDERData = varORDER(iIndex)
        //    End Select

        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pSetHEADERData
        //*
        //*  概要  ：    オーダヘッダ配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetHEADERData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varHEADER[iIndex] = vValue;
                    break;
                case VariantType.Null:
                case VariantType.Empty:
                    varHEADER[iIndex] = "";
                    break;
                default:
                    varHEADER[iIndex] = vValue;
                    break;
            }
        }
        //Public Sub pSetHEADERData(ByVal iIndex As Integer, ByVal vValue As Variant)

        //    Select Case VarType(vValue)
        //        Case vbObject
        //            Set varHEADER(iIndex) = vValue
        //        Case vbEmpty, vbNull
        //            varHEADER(iIndex) = ""
        //        Case Else
        //            varHEADER(iIndex) = vValue
        //    End Select

        //End Sub

        //******************************************************************************
        //*
        //*  関数名：    pGetHEADERData
        //*
        //*  概要  ：    オーダヘッダ配列から値を取得
        //*
        //*  引数  ：    ①配列のIndex番号
        //*
        //*  戻り値：    配列要素
        //*
        //******************************************************************************
        public static object pGetHEADERData(int iIndex)
        {
            switch (Information.VarType(varHEADER[iIndex]))
            {
                case VariantType.Object:
                    return varHEADER[iIndex];
                default:
                    return varHEADER[iIndex];
            }
        }
        //Public Function pGetHEADERData(ByVal iIndex As Integer) As Variant

        //    Select Case VarType(varHEADER(iIndex))
        //        Case vbObject
        //            Set pGetHEADERData = varHEADER(iIndex)
        //        Case Else
        //            pGetHEADERData = varHEADER(iIndex)
        //    End Select

        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pSetGROUPData
        //*
        //*  概要  ：    オーダグループ配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetGROUPData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varGROUP[iIndex] = vValue;
                    break;
                case VariantType.Null:
                case VariantType.Empty:
                    varGROUP[iIndex] = "";
                    break;
                default:
                    varGROUP[iIndex] = vValue;
                    break;
            }
        }
        //Public Sub pSetGROUPData(ByVal iIndex As Integer, ByVal vValue As Variant)

        //    Select Case VarType(vValue)
        //        Case vbObject
        //            Set varGROUP(iIndex) = vValue
        //        Case vbEmpty, vbNull
        //            varGROUP(iIndex) = ""
        //        Case Else
        //            varGROUP(iIndex) = vValue
        //    End Select

        //End Sub

        //******************************************************************************
        //*
        //*  関数名：    pGetGROUPData
        //*
        //*  概要  ：    オーダグループ配列から値を取得
        //*
        //*  引数  ：    ①配列のIndex番号
        //*
        //*  戻り値：    配列要素
        //*
        //******************************************************************************
        public static object pGetGROUPData(int iIndex)
        {
            switch (Information.VarType(varGROUP[iIndex]))
            {
                case VariantType.Object:
                    return varGROUP[iIndex];
                default:
                    return varGROUP[iIndex];
            }
        }
        //Public Function pGetGROUPData(ByVal iIndex As Integer) As Variant

        //    Select Case VarType(varGROUP(iIndex))
        //        Case vbObject
        //            Set pGetGROUPData = varGROUP(iIndex)
        //        Case Else
        //            pGetGROUPData = varGROUP(iIndex)
        //    End Select

        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pSetDETAILData
        //*
        //*  概要  ：    オーダディテール配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetDETAILData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varDETAIL[iIndex] = vValue;
                    break;
                case VariantType.Null:
                case VariantType.Empty:
                    varDETAIL[iIndex] = "";
                    break;
                default:
                    varDETAIL[iIndex] = vValue;
                    break;
            }
        }
        //Public Sub pSetDETAILData(ByVal iIndex As Integer, ByVal vValue As Variant)

        //    Select Case VarType(vValue)
        //        Case vbObject
        //            Set varDETAIL(iIndex) = vValue
        //        Case vbEmpty, vbNull
        //            varDETAIL(iIndex) = ""
        //        Case Else
        //            varDETAIL(iIndex) = vValue
        //    End Select

        //End Sub

        //******************************************************************************
        //*
        //*  関数名：    pGetDETAILData
        //*
        //*  概要  ：    オーダディテール配列から値を取得
        //*
        //*  引数  ：    ①配列のIndex番号
        //*
        //*  戻り値：    配列要素
        //*
        //******************************************************************************
        public static object pGetDETAILData(int iIndex)
        {
            switch (Information.VarType(varDETAIL[iIndex]))
            {
                case VariantType.Object:
                    return varDETAIL[iIndex];
                default:
                    return varDETAIL[iIndex];
            }
        }
        //Public Function pGetDETAILData(ByVal iIndex As Integer) As Variant

        //    Select Case VarType(varDETAIL(iIndex))
        //        Case vbObject
        //            Set pGetDETAILData = varDETAIL(iIndex)
        //        Case Else
        //            pGetDETAILData = varDETAIL(iIndex)
        //    End Select

        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pSetDETAILINFOData
        //*
        //*  概要  ：    オーダディテール情報配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetDETAILINFOData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varDETAILINFO[iIndex] = vValue;
                    break;
                case VariantType.Null:
                case VariantType.Empty:
                    varDETAILINFO[iIndex] = "";
                    break;
                default:
                    varDETAILINFO[iIndex] = vValue;
                    break;
            }
        }
        //Public Sub pSetDETAILINFOData(ByVal iIndex As Integer, ByVal vValue As Variant)

        //    Select Case VarType(vValue)
        //        Case vbObject
        //            Set varDETAILINFO(iIndex) = vValue
        //        Case vbEmpty, vbNull
        //            varDETAILINFO(iIndex) = ""
        //        Case Else
        //            varDETAILINFO(iIndex) = vValue
        //    End Select

        //End Sub

        //******************************************************************************
        //*
        //*  関数名：    pGetDETAILINFOData
        //*
        //*  概要  ：    オーダディテール情報配列から値を取得
        //*
        //*  引数  ：    ①配列のIndex番号
        //*
        //*  戻り値：    配列要素
        //*
        //******************************************************************************
        public static object pGetDETAILINFOData(int iIndex)
        {
            switch (Information.VarType(varDETAILINFO[iIndex]))
            {
                case VariantType.Object:
                    return varDETAILINFO[iIndex];
                default:
                    return varDETAILINFO[iIndex];
            }
        }
        //Public Function pGetDETAILINFOData(ByVal iIndex As Integer) As Variant

        //    Select Case VarType(varDETAILINFO(iIndex))
        //        Case vbObject
        //            Set pGetDETAILINFOData = varDETAILINFO(iIndex)
        //        Case Else
        //            pGetDETAILINFOData = varDETAILINFO(iIndex)
        //    End Select

        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pSetERRData
        //*
        //*  概要  ：    ERRパラメータ配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetERRData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varERR[iIndex] = vValue;
                    break;
                case VariantType.Null:
                case VariantType.Empty:
                    varERR[iIndex] = "";
                    break;
                default:
                    varERR[iIndex] = vValue;
                    break;
            }
        }
        //Public Sub pSetERRData(ByVal iIndex As Integer, ByVal vValue As Variant)

        //    Select Case VarType(vValue)
        //        Case vbObject
        //            Set varERR(iIndex) = vValue
        //        Case vbEmpty, vbNull
        //            varERR(iIndex) = ""
        //        Case Else
        //            varERR(iIndex) = vValue
        //    End Select

        //End Sub

        //******************************************************************************
        //*
        //*  関数名：    pSetERRCollection
        //*
        //*  概要  ：    ERRコレクションへのオブジェクトの追加
        //*
        //*  引数  ：    ①ERRコレクションへメンバ追加するオブジェクト
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetERRCollection(object vValue)
        {
            object oColKey;

            if (colERR.Count() == 0)
            {
                //【課題】移植に不安あり
                oColKey = "1";
            }
            else
            {
                oColKey = (object)Convert.ToString(colERR.Count() + 1);
            }
            objVBACollection.AddObject2(ref colERR, ref vValue, ref oColKey);

        }
        //Public Sub pSetERRCollection(ByVal vValue As Variant)

        //    Dim sColKey         As String

        //    If colERR Is Nothing Then
        //        sColKey = "1"
        //    Else
        //        sColKey = CStr(colERR.Count + 1)
        //    End If

        //    colERR.Add vValue, sColKey

        //End Sub

        //******************************************************************************
        //*
        //*  関数名：    pGetERRCollectionCount
        //*
        //*  概要  ：    ERRコレクションの件数を取得
        //*
        //*  引数  ：    なし
        //*
        //*  戻り値：    ERRコレクション件数
        //*
        //******************************************************************************
        public static int pGetERRCollectionCount()
        {
            return colERR.Count();
        }

        //******************************************************************************
        //*
        //*  関数名：    pGetERRCollectionItem
        //*
        //*  概要  ：    ERRコレクションメンバの取得
        //*
        //*  引数  ：    ①コレクションKey or コレクションインデックス
        //*              ②エラーレベル
        //*              ③エラーコード
        //*              ④エラーテキスト
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pGetERRCollectionItem(object vColKey, ref string sErrLevel, ref string sErrCode, ref string sErrText)
        {
            string sColKey;
            int iItemIndex;
            object oColKey;

            try
            {
                sErrLevel = string.Empty;
                sErrCode = string.Empty;
                sErrText = string.Empty;

                if (pGetERRCollectionCount() == 0)
                {
                    return;
                }

                sColKey = vColKey.ToString();
                oColKey = (object)sColKey;

                object[] retObjs = (object[])colERR.Item(ref oColKey);
                sErrLevel = retObjs[CON_ERR_FLG].ToString();
                sErrCode = retObjs[CON_ERR_CODE].ToString();
                sErrText = retObjs[CON_ERR_TEXT].ToString();
            }
            catch
            {
                iItemIndex = Convert.ToInt32(vColKey);
                oColKey = (object)iItemIndex;

                object[] retObjs = (object[])colERR.Item(ref oColKey);
                sErrLevel = retObjs[CON_ERR_FLG].ToString();
                sErrCode = retObjs[CON_ERR_CODE].ToString();
                sErrText = retObjs[CON_ERR_TEXT].ToString();
            }
        }

        //******************************************************************************
        //*
        //*  関数名：    pSetINFECTIONData
        //*
        //*  概要  ：    患者感染症情報配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetINFECTIONData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varINFECTION[iIndex] = vValue;
                    break;
                case VariantType.Empty:
                case VariantType.Null:
                    varINFECTION[iIndex] = "";
                    break;
                default:
                    varINFECTION[iIndex] = vValue;
                    break;
            }
        }
        //Public Sub pSetINFECTIONData(ByVal iIndex As Integer, ByVal vValue As Variant)

        //    Select Case VarType(vValue)
        //        Case vbObject
        //            Set varINFECTION(iIndex) = vValue
        //        Case vbEmpty, vbNull
        //            varINFECTION(iIndex) = ""
        //        Case Else
        //            varINFECTION(iIndex) = vValue
        //    End Select

        //End Sub

        //******************************************************************************
        //*
        //*  関数名：    pSetINFECTIONCollection
        //*
        //*  概要  ：    患者感染症情報コレクションへのオブジェクトの追加
        //*
        //*  引数  ：    ①患者感染症情報コレクションへメンバ追加するオブジェクト
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetINFECTIONCollection(object vValue)
        {
            object oColKey;

            if (colINFECTION.Count() == 0)
            {
                //【課題】移植に不安あり
                oColKey = "1";
            }
            else
            {
                oColKey = Convert.ToString(colINFECTION.Count() + 1);
            }
            objVBACollection.AddObject2(ref colINFECTION, ref vValue, ref oColKey);
        }
        //Public Sub pSetINFECTIONCollection(ByVal vValue As Variant)

        //    Dim sColKey         As String

        //    If colINFECTION Is Nothing Then
        //        sColKey = "1"
        //    Else
        //        sColKey = CStr(colINFECTION.Count + 1)
        //    End If

        //    colINFECTION.Add vValue, sColKey

        //End Sub

        //******************************************************************************
        //*
        //*  関数名：    pGetINFECTIONCollectionCount
        //*
        //*  概要  ：    患者感染症情報コレクションの件数を取得
        //*
        //*  引数  ：    なし
        //*
        //*  戻り値：    患者感染症情報コレクション件数
        //*
        //******************************************************************************
        public static int pGetINFECTIONCollectionCount()
        {
            return colINFECTION.Count();
        }
        //Public Function pGetINFECTIONCollectionCount() As Integer

        //    pGetINFECTIONCollectionCount = colINFECTION.Count

        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pGetINFECTIONCollectionItem
        //*
        //*  概要  ：    患者感染症情報コレクションメンバの取得
        //*
        //*  引数  ：    ①コレクションKey or コレクションインデックス
        //*              ②感染症コード
        //*              ③感染症名称
        //*              ④結果区分
        //*              ⑤感染情報更新日
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pGetINFECTIONCollectionItem(string vColKey,
                                                        ref string sCode,
                                                        ref string sName,
                                                        ref string sResult,
                                                        ref string sDate)
        {

            string sColKey;       //コレクションKey
            int iItemIndex;       //コレクションインデックス

            try
            {
                sCode = "";              //感染症コード
                sName = "";              //感染症名称
                sResult = "";            //結果区分
                sDate = "";              //感染情報更新日

                if (pGetINFECTIONCollectionCount() == 0)
                {
                    return;
                }

                sColKey = vColKey;
                object oColKey = (object)sColKey;

                object[] obj = (object[])colINFECTION.Item(ref oColKey);
                sCode = obj[CON_INF_CODE].ToString();
                sName = obj[CON_INF_NAME].ToString();
                sResult = obj[CON_INF_RESULT].ToString();
                sDate = obj[CON_INF_DATE].ToString();
            }
            catch
            {
                iItemIndex = Convert.ToInt32(vColKey);
                object oItemIndex = (object)iItemIndex;

                if (pGetINFECTIONCollectionCount() >= iItemIndex)
                {
                    object[] obj = (object[])colINFECTION.Item(ref oItemIndex);
                    sCode = obj[CON_INF_CODE].ToString();
                    sName = obj[CON_INF_NAME].ToString();
                    sResult = obj[CON_INF_RESULT].ToString();
                    sDate = obj[CON_INF_DATE].ToString();
                }
            }
        }
        //Public Sub pGetINFECTIONCollectionItem(ByVal vColKey As String, _
        //                                        ByRef sCode As String, _
        //                                        ByRef sName As String, _
        //                                        ByRef sResult As String, _
        //                                        ByRef sDate As String)

        //    Dim sColKey         As String       //コレクションKey
        //    Dim iItemIndex      As Integer      //コレクションインデックス

        //On Error GoTo pGetINFECTIONCollectionItem_ERR

        //    sCode = ""              //感染症コード
        //    sName = ""              //感染症名称
        //    sResult = ""            //結果区分
        //    sDate = ""              //感染情報更新日

        //    If pGetINFECTIONCollectionCount = 0 Then Exit Sub

        //    sColKey = CStr(vColKey)

        //    With colINFECTION
        //        sCode = .Item(sColKey)(CON_INF_CODE)
        //        sName = .Item(sColKey)(CON_INF_NAME)
        //        sResult = .Item(sColKey)(CON_INF_RESULT)
        //        sDate = .Item(sColKey)(CON_INF_DATE)
        //    End With

        //pGetINFECTIONCollectionItem_ERR:

        //    iItemIndex = CInt(vColKey)

        //    If pGetINFECTIONCollectionCount >= iItemIndex Then

        //        With colINFECTION
        //            sCode = .Item(iItemIndex)(CON_INF_CODE)
        //            sName = .Item(iItemIndex)(CON_INF_NAME)
        //            sResult = .Item(iItemIndex)(CON_INF_RESULT)
        //            sDate = .Item(iItemIndex)(CON_INF_DATE)
        //        End With

        //    End If

        //End Sub


        //******************************************************************************
        //*
        //*  関数名：    pSetINSURANCEData
        //*
        //*  概要  ：    患者保険情報配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetINSURANCEData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varINSURANCE[iIndex] = vValue;
                    break;
                case VariantType.Empty:
                case VariantType.Null:
                    varINSURANCE[iIndex] = "";
                    break;
                default:
                    varINSURANCE[iIndex] = vValue;
                    break;
            }
        }
        //Public Sub pSetINSURANCEData(ByVal iIndex As Integer, ByVal vValue As Variant)

        //    Select Case VarType(vValue)
        //        Case vbObject
        //            Set varINSURANCE(iIndex) = vValue
        //        Case vbEmpty, vbNull
        //            varINSURANCE(iIndex) = ""
        //        Case Else
        //            varINSURANCE(iIndex) = vValue
        //    End Select

        //End Sub

        //******************************************************************************
        //*
        //*  関数名：    pSetINSURANCECollection
        //*
        //*  概要  ：    患者保険情報コレクションへのオブジェクトの追加
        //*
        //*  引数  ：    ①患者保険情報コレクションへメンバ追加するオブジェクト
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetINSURANCECollection(object vValue)
        {
            object oColKey;

            if (colINSURANCE.Count() == 0)
            {
                //【課題】移植に不安あり
                oColKey = "1";
            }
            else
            {
                oColKey = Convert.ToString(colINSURANCE.Count() + 1);
            }
            objVBACollection.AddObject2(ref colINSURANCE, ref vValue, ref oColKey);
        }

        //******************************************************************************
        //*
        //*  関数名：    pGetINSURANCECollectionCount
        //*
        //*  概要  ：    患者保険情報コレクションの件数を取得
        //*
        //*  引数  ：    なし
        //*
        //*  戻り値：    患者保険情報コレクション件数
        //*
        //******************************************************************************
        public static int pGetINSURANCECollectionCount()
        {
            return colINSURANCE.Count();
        }
        //Public Function pGetINSURANCECollectionCount() As Integer

        //    pGetINSURANCECollectionCount = colINSURANCE.Count

        //End Function

        //******************************************************************************
        //*
        //*  関数名：    pGetINSURANCECollectionItem
        //*
        //*  概要  ：    患者保険情報コレクションメンバの取得
        //*
        //*  引数  ：    ①コレクションKey or コレクションインデックス
        //*              ②法制コード１
        //*              ③保険種類１
        //*              ④継続区分１
        //*              ⑤保険名勝１
        //*              ⑥保険略称１
        //*              ⑦保険者番号１
        //*              ⑧本人家族区分１
        //*              ⑨記号１
        //*              ⑩番号１
        //*              ⑪法制コード２
        //*              ⑫保険種類２
        //*              ⑬継続区分２
        //*              ⑭保険名勝２
        //*              ⑮保険略称２
        //*              ⑯保険者番号２
        //*              ⑰本人家族区分２
        //*              ⑱記号２
        //*              ⑲番号２
        //*              ⑳法制コード３
        //*              21保険種類３
        //*              22継続区分３
        //*              23保険名勝３
        //*              24保険略称３
        //*              25保険者番号３
        //*              26本人家族区分３
        //*              27記号３
        //*              28番号３
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pGetINSURANCECollectionItem(string vColKey,
                                                        ref string vsCODE1,
                                                        ref string vsKINDOFINS1,
                                                        ref string vsCONTINUE1,
                                                        ref string vsNAME1,
                                                        ref string vsSHORTNAME1,
                                                        ref string vsHKNP1,
                                                        ref string vsPFKBN1,
                                                        ref string vsKIGO1,
                                                        ref string vsBANGO1,
                                                        ref string vsCODE2,
                                                        ref string vsKINDOFINS2,
                                                        ref string vsCONTINUE2,
                                                        ref string vsNAME2,
                                                        ref string vsSHORTNAME2,
                                                        ref string vsHKNP2,
                                                        ref string vsPFKBN2,
                                                        ref string vsKIGO2,
                                                        ref string vsBANGO2,
                                                        ref string vsCODE3,
                                                        ref string vsKINDOFINS3,
                                                        ref string vsCONTINUE3,
                                                        ref string vsNAME3,
                                                        ref string vsSHORTNAME3,
                                                        ref string vsHKNP3,
                                                        ref string vsPFKBN3,
                                                        ref string vsKIGO3,
                                                        ref string vsBANGO3)
        {

            string sColKey;      //コレクションKey
            int iItemIndex;      //コレクションインデックス

            try
            {

                vsCODE1 = "";                    //法制コード１
                vsKINDOFINS1 = "";               //保険種類１
                vsCONTINUE1 = "";                //継続区分１
                vsNAME1 = "";                    //保険名称１
                vsSHORTNAME1 = "";               //保険略称１
                vsHKNP1 = "";                    //保険者番号１
                vsPFKBN1 = "";                   //本人家族区分１
                vsKIGO1 = "";                    //記号１
                vsBANGO1 = "";                   //番号１
                vsCODE2 = "";                    //法制コード２
                vsKINDOFINS2 = "";               //保険種類２
                vsCONTINUE2 = "";                //継続区分２
                vsNAME2 = "";                    //保険名称２
                vsSHORTNAME2 = "";               //保険略称２
                vsHKNP2 = "";                    //保険者番号２
                vsPFKBN2 = "";                   //本人家族区分２
                vsKIGO2 = "";                    //記号２
                vsBANGO2 = "";                   //番号２
                vsCODE3 = "";                    //法制コード３
                vsKINDOFINS3 = "";               //保険種類３
                vsCONTINUE3 = "";                //継続区分３
                vsNAME3 = "";                    //保険名称３
                vsSHORTNAME3 = "";               //保険略称３
                vsHKNP3 = "";                    //保険者番号３
                vsPFKBN3 = "";                   //本人家族区分３
                vsKIGO3 = "";                    //記号３
                vsBANGO3 = "";                   //番号３

                if (pGetINSURANCECollectionCount() == 0)
                {
                    return;
                }

                sColKey = vColKey;
                object oColKey = (object)sColKey;

                object[] obj = (object[])colINSURANCE.Item(ref oColKey);

                vsCODE1 = obj[CON_INS_CODE1].ToString();                     //法制コード１
                vsKINDOFINS1 = obj[CON_INS_KINDOFINS1].ToString();           //保険種類１
                vsCONTINUE1 = obj[CON_INS_CONTINUE1].ToString();             //継続区分１
                vsNAME1 = obj[CON_INS_NAME1].ToString();                     //保険名称１
                vsSHORTNAME1 = obj[CON_INS_SHORTNAME1].ToString();           //保険略称１
                vsHKNP1 = obj[CON_INS_HKNP1].ToString();                     //保険者番号１
                vsPFKBN1 = obj[CON_INS_PFKBN1].ToString();                   //本人家族区分１
                vsKIGO1 = obj[CON_INS_KIGO1].ToString();                     //記号１
                vsBANGO1 = obj[CON_INS_BANGO1].ToString();                   //番号１
                vsCODE2 = obj[CON_INS_CODE2].ToString();                     //法制コード２
                vsKINDOFINS2 = obj[CON_INS_KINDOFINS2].ToString();           //保険種類２
                vsCONTINUE2 = obj[CON_INS_CONTINUE2].ToString();             //継続区分２
                vsNAME2 = obj[CON_INS_NAME2].ToString();                     //保険名称２
                vsSHORTNAME2 = obj[CON_INS_SHORTNAME2].ToString();           //保険略称２
                vsHKNP2 = obj[CON_INS_HKNP2].ToString();                     //保険者番号２
                vsPFKBN2 = obj[CON_INS_PFKBN2].ToString();                   //本人家族区分２
                vsKIGO2 = obj[CON_INS_KIGO2].ToString();                     //記号２
                vsBANGO2 = obj[CON_INS_BANGO2].ToString();                   //番号２
                vsCODE3 = obj[CON_INS_CODE3].ToString();                     //法制コード３
                vsKINDOFINS3 = obj[CON_INS_KINDOFINS3].ToString();           //保険種類３
                vsCONTINUE3 = obj[CON_INS_CONTINUE3].ToString();             //継続区分３
                vsNAME3 = obj[CON_INS_NAME3].ToString();                     //保険名称３
                vsSHORTNAME3 = obj[CON_INS_SHORTNAME3].ToString();           //保険略称３
                vsHKNP3 = obj[CON_INS_HKNP3].ToString();                     //保険者番号３
                vsPFKBN3 = obj[CON_INS_PFKBN3].ToString();                   //本人家族区分３
                vsKIGO3 = obj[CON_INS_KIGO3].ToString();                     //記号３
                vsBANGO3 = obj[CON_INS_BANGO3].ToString();                   //番号３
            }
            catch
            {

                iItemIndex = Convert.ToInt32(vColKey);
                object oItemIndex = (object)iItemIndex;

                if (pGetINSURANCECollectionCount() >= iItemIndex)
                {
                    object[] obj = (object[])colINSURANCE.Item(ref oItemIndex);

                    vsCODE1 = obj[CON_INS_CODE1].ToString();                     //法制コード１
                    vsKINDOFINS1 = obj[CON_INS_KINDOFINS1].ToString();           //保険種類１
                    vsCONTINUE1 = obj[CON_INS_CONTINUE1].ToString();             //継続区分１
                    vsNAME1 = obj[CON_INS_NAME1].ToString();                     //保険名称１
                    vsSHORTNAME1 = obj[CON_INS_SHORTNAME1].ToString();           //保険略称１
                    vsHKNP1 = obj[CON_INS_HKNP1].ToString();                     //保険者番号１
                    vsPFKBN1 = obj[CON_INS_PFKBN1].ToString();                   //本人家族区分１
                    vsKIGO1 = obj[CON_INS_KIGO1].ToString();                     //記号１
                    vsBANGO1 = obj[CON_INS_BANGO1].ToString();                   //番号１
                    vsCODE2 = obj[CON_INS_CODE2].ToString();                     //法制コード２
                    vsKINDOFINS2 = obj[CON_INS_KINDOFINS2].ToString();           //保険種類２
                    vsCONTINUE2 = obj[CON_INS_CONTINUE2].ToString();             //継続区分２
                    vsNAME2 = obj[CON_INS_NAME2].ToString();                     //保険名称２
                    vsSHORTNAME2 = obj[CON_INS_SHORTNAME2].ToString();           //保険略称２
                    vsHKNP2 = obj[CON_INS_HKNP2].ToString();                     //保険者番号２
                    vsPFKBN2 = obj[CON_INS_PFKBN2].ToString();                   //本人家族区分２
                    vsKIGO2 = obj[CON_INS_KIGO2].ToString();                     //記号２
                    vsBANGO2 = obj[CON_INS_BANGO2].ToString();                   //番号２
                    vsCODE3 = obj[CON_INS_CODE3].ToString();                     //法制コード３
                    vsKINDOFINS3 = obj[CON_INS_KINDOFINS3].ToString();           //保険種類３
                    vsCONTINUE3 = obj[CON_INS_CONTINUE3].ToString();             //継続区分３
                    vsNAME3 = obj[CON_INS_NAME3].ToString();                     //保険名称３
                    vsSHORTNAME3 = obj[CON_INS_SHORTNAME3].ToString();           //保険略称３
                    vsHKNP3 = obj[CON_INS_HKNP3].ToString();                     //保険者番号３
                    vsPFKBN3 = obj[CON_INS_PFKBN3].ToString();                   //本人家族区分３
                    vsKIGO3 = obj[CON_INS_KIGO3].ToString();                     //記号３
                    vsBANGO3 = obj[CON_INS_BANGO3].ToString();                   //番号３
                }
            }
        }

        //******************************************************************************
        //*
        //*  関数名：    pSetEXAMFREEData
        //*
        //*  概要  ：    患者診療フリー情報配列へ値を代入
        //*
        //*  引数  ：    ①配列のIndex番号
        //*              ②代入する要素
        //*
        //*  戻り値：    なし
        //*
        //******************************************************************************
        public static void pSetEXAMFREEData(int iIndex, object vValue)
        {
            switch (Information.VarType(vValue))
            {
                case VariantType.Object:
                    varEXAMFREE[iIndex] = vValue;
                    break;
                case VariantType.Empty:
                case VariantType.Null:
                    varEXAMFREE[iIndex] = "";
                    break;
                default:
                    varEXAMFREE[iIndex] = vValue;
                    break;
            }
        }

        //Public Sub pGetINSURANCECollectionItem(ByVal vColKey As String, _
        //                                    ByRef vsCODE1 As String, ByRef vsKINDOFINS1 As String, ByRef vsCONTINUE1 As String, _
        //                                    ByRef vsNAME1 As String, ByRef vsSHORTNAME1 As String, ByRef vsHKNP1 As String, _
        //                                    ByRef vsPFKBN1 As String, ByRef vsKIGO1 As String, ByRef vsBANGO1 As String, _
        //                                    ByRef vsCODE2 As String, ByRef vsKINDOFINS2 As String, ByRef vsCONTINUE2 As String, _
        //                                    ByRef vsNAME2 As String, ByRef vsSHORTNAME2 As String, ByRef vsHKNP2 As String, _
        //                                    ByRef vsPFKBN2 As String, ByRef vsKIGO2 As String, ByRef vsBANGO2 As String, _
        //                                    ByRef vsCODE3 As String, ByRef vsKINDOFINS3 As String, ByRef vsCONTINUE3 As String, _
        //                                    ByRef vsNAME3 As String, ByRef vsSHORTNAME3 As String, ByRef vsHKNP3 As String, _
        //                                    ByRef vsPFKBN3 As String, ByRef vsKIGO3 As String, ByRef vsBANGO3 As String)

        //    Dim sColKey         As String       //コレクションKey
        //    Dim iItemIndex      As Integer      //コレクションインデックス

        //On Error GoTo pGetINSURANCECollectionItem_ERR

        //    vsCODE1 = ""                    //法制コード１
        //    vsKINDOFINS1 = ""               //保険種類１
        //    vsCONTINUE1 = ""                //継続区分１
        //    vsNAME1 = ""                    //保険名称１
        //    vsSHORTNAME1 = ""               //保険略称１
        //    vsHKNP1 = ""                    //保険者番号１
        //    vsPFKBN1 = ""                   //本人家族区分１
        //    vsKIGO1 = ""                    //記号１
        //    vsBANGO1 = ""                   //番号１
        //    vsCODE2 = ""                    //法制コード２
        //    vsKINDOFINS2 = ""               //保険種類２
        //    vsCONTINUE2 = ""                //継続区分２
        //    vsNAME2 = ""                    //保険名称２
        //    vsSHORTNAME2 = ""               //保険略称２
        //    vsHKNP2 = ""                    //保険者番号２
        //    vsPFKBN2 = ""                   //本人家族区分２
        //    vsKIGO2 = ""                    //記号２
        //    vsBANGO2 = ""                   //番号２
        //    vsCODE3 = ""                    //法制コード３
        //    vsKINDOFINS3 = ""               //保険種類３
        //    vsCONTINUE3 = ""                //継続区分３
        //    vsNAME3 = ""                    //保険名称３
        //    vsSHORTNAME3 = ""               //保険略称３
        //    vsHKNP3 = ""                    //保険者番号３
        //    vsPFKBN3 = ""                   //本人家族区分３
        //    vsKIGO3 = ""                    //記号３
        //    vsBANGO3 = ""                   //番号３

        //    If pGetINSURANCECollectionCount = 0 Then Exit Sub

        //    sColKey = CStr(vColKey)

        //    With colINSURANCE
        //        vsCODE1 = .Item(sColKey)(CON_INS_CODE1)                     //法制コード１
        //        vsKINDOFINS1 = .Item(sColKey)(CON_INS_KINDOFINS1)           //保険種類１
        //        vsCONTINUE1 = .Item(sColKey)(CON_INS_CONTINUE1)             //継続区分１
        //        vsNAME1 = .Item(sColKey)(CON_INS_NAME1)                     //保険名称１
        //        vsSHORTNAME1 = .Item(sColKey)(CON_INS_SHORTNAME1)           //保険略称１
        //        vsHKNP1 = .Item(sColKey)(CON_INS_HKNP1)                     //保険者番号１
        //        vsPFKBN1 = .Item(sColKey)(CON_INS_PFKBN1)                   //本人家族区分１
        //        vsKIGO1 = .Item(sColKey)(CON_INS_KIGO1)                     //記号１
        //        vsBANGO1 = .Item(sColKey)(CON_INS_BANGO1)                   //番号１
        //        vsCODE2 = .Item(sColKey)(CON_INS_CODE2)                     //法制コード２
        //        vsKINDOFINS2 = .Item(sColKey)(CON_INS_KINDOFINS2)           //保険種類２
        //        vsCONTINUE2 = .Item(sColKey)(CON_INS_CONTINUE2)             //継続区分２
        //        vsNAME2 = .Item(sColKey)(CON_INS_NAME2)                     //保険名称２
        //        vsSHORTNAME2 = .Item(sColKey)(CON_INS_SHORTNAME2)           //保険略称２
        //        vsHKNP2 = .Item(sColKey)(CON_INS_HKNP2)                     //保険者番号２
        //        vsPFKBN2 = .Item(sColKey)(CON_INS_PFKBN2)                   //本人家族区分２
        //        vsKIGO2 = .Item(sColKey)(CON_INS_KIGO2)                     //記号２
        //        vsBANGO2 = .Item(sColKey)(CON_INS_BANGO2)                   //番号２
        //        vsCODE3 = .Item(sColKey)(CON_INS_CODE3)                     //法制コード３
        //        vsKINDOFINS3 = .Item(sColKey)(CON_INS_KINDOFINS3)           //保険種類３
        //        vsCONTINUE3 = .Item(sColKey)(CON_INS_CONTINUE3)             //継続区分３
        //        vsNAME3 = .Item(sColKey)(CON_INS_NAME3)                     //保険名称３
        //        vsSHORTNAME3 = .Item(sColKey)(CON_INS_SHORTNAME3)           //保険略称３
        //        vsHKNP3 = .Item(sColKey)(CON_INS_HKNP3)                     //保険者番号３
        //        vsPFKBN3 = .Item(sColKey)(CON_INS_PFKBN3)                   //本人家族区分３
        //        vsKIGO3 = .Item(sColKey)(CON_INS_KIGO3)                     //記号３
        //        vsBANGO3 = .Item(sColKey)(CON_INS_BANGO3)                   //番号３
        //    End With

        //pGetINSURANCECollectionItem_ERR:

        //    iItemIndex = CInt(vColKey)

        //    If pGetINSURANCECollectionCount >= iItemIndex Then

        //        With colINSURANCE
        //            vsCODE1 = .Item(iItemIndex)(CON_INS_CODE1)                     //法制コード１
        //            vsKINDOFINS1 = .Item(iItemIndex)(CON_INS_KINDOFINS1)           //保険種類１
        //            vsCONTINUE1 = .Item(iItemIndex)(CON_INS_CONTINUE1)             //継続区分１
        //            vsNAME1 = .Item(iItemIndex)(CON_INS_NAME1)                     //保険名称１
        //            vsSHORTNAME1 = .Item(iItemIndex)(CON_INS_SHORTNAME1)           //保険略称１
        //            vsHKNP1 = .Item(iItemIndex)(CON_INS_HKNP1)                     //保険者番号１
        //            vsPFKBN1 = .Item(iItemIndex)(CON_INS_PFKBN1)                   //本人家族区分１
        //            vsKIGO1 = .Item(iItemIndex)(CON_INS_KIGO1)                     //記号１
        //            vsBANGO1 = .Item(iItemIndex)(CON_INS_BANGO1)                   //番号１
        //            vsCODE2 = .Item(iItemIndex)(CON_INS_CODE2)                     //法制コード２
        //            vsKINDOFINS2 = .Item(iItemIndex)(CON_INS_KINDOFINS2)           //保険種類２
        //            vsCONTINUE2 = .Item(iItemIndex)(CON_INS_CONTINUE2)             //継続区分２
        //            vsNAME2 = .Item(iItemIndex)(CON_INS_NAME2)                     //保険名称２
        //            vsSHORTNAME2 = .Item(iItemIndex)(CON_INS_SHORTNAME2)           //保険略称２
        //            vsHKNP2 = .Item(iItemIndex)(CON_INS_HKNP2)                     //保険者番号２
        //            vsPFKBN2 = .Item(iItemIndex)(CON_INS_PFKBN2)                   //本人家族区分２
        //            vsKIGO2 = .Item(iItemIndex)(CON_INS_KIGO2)                     //記号２
        //            vsBANGO2 = .Item(iItemIndex)(CON_INS_BANGO2)                   //番号２
        //            vsCODE3 = .Item(iItemIndex)(CON_INS_CODE3)                     //法制コード３
        //            vsKINDOFINS3 = .Item(iItemIndex)(CON_INS_KINDOFINS3)           //保険種類３
        //            vsCONTINUE3 = .Item(iItemIndex)(CON_INS_CONTINUE3)             //継続区分３
        //            vsNAME3 = .Item(iItemIndex)(CON_INS_NAME3)                     //保険名称３
        //            vsSHORTNAME3 = .Item(iItemIndex)(CON_INS_SHORTNAME3)           //保険略称３
        //            vsHKNP3 = .Item(iItemIndex)(CON_INS_HKNP3)                     //保険者番号３
        //            vsPFKBN3 = .Item(iItemIndex)(CON_INS_PFKBN3)                   //本人家族区分３
        //            vsKIGO3 = .Item(iItemIndex)(CON_INS_KIGO3)                     //記号３
        //            vsBANGO3 = .Item(iItemIndex)(CON_INS_BANGO3)                   //番号３
        //        End With

        //    End If

        //End Sub

        //注）以下のコードは透析I/F部品内部にて使用している関数です。部品外部では使用できませんので削除してください。
        //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        ////******************************************************************************
        ////*
        ////*  関数名：    pbAddError
        ////*
        ////*  概要  ：    各部品からのエラーコレクションの追加
        ////*
        ////*  引数  ：　　(i)   エラーコード(String)
        ////*              (i/o) エラーコレクション(Collection)
        ////*              (i)   エラーレベル(String)
        ////*                    ※省略時または""：パラメータのDBOBJクラスを設定時は未使用の為省略可
        ////*                    　設定時        ：パラメータのDBOBJクラスを省略時に使用
        ////*              (i)   エラーメッセージ(String)
        ////*                    ※省略時または""：マスタから取得したエラーメッセージをそのままコレクションに格納
        ////*                    　設定時        ：パラメータのエラーメッセージ表示位置の内容によりエラーメッセージをコレクションに格納
        ////*              (i)   エラーメッセージ表示位置(Integer)
        ////*                    ※省略時または0 ：パラメータのエラーメッセージをそのままコレクションに格納
        ////*                    　1             ：マスタから取得したエラーメッセージの前にパラメータのエラーメッセージを結合してコレクションに格納
        ////*                    　2             ：マスタから取得したエラーメッセージの後にパラメータのエラーメッセージを結合してコレクションに格納
        ////*              (i)   DBOBJクラス(Object)
        ////*                    ※省略時        ：パラメータのエラーコード／エラーレベル／エラーメッセージをそのままコレクションに格納
        ////*                    　設定時        ：エラー管理テーブルを使用
        ////*
        ////*  戻り値：    True:正常、False:異常
        ////*
        ////******************************************************************************
        //Public Function pbAddError(ByVal vsErrCode As String, ByRef rcError As Collection, _
        //                           Optional ByVal vsErrLevel As String, Optional ByVal vsErrMsg As String, _
        //                           Optional ByVal viErrMsgPos As Integer, Optional ByVal voDbObject As Object) As Boolean

        //    Dim lvErrLibData()  As Variant
        //    Dim lsErrCode       As String
        //    Dim lsErrLevel      As String
        //    Dim lsErrText1      As String

        //On Error Resume Next

        //    ReDim varERR(2)
        //    pbAddError = True

        //    If (voDbObject Is Nothing) Then
        //        //
        //        //DBOBJが未設定の場合
        //        lsErrCode = vsErrCode
        //        lsErrLevel = vsErrLevel
        //        lsErrText1 = vsErrMsg

        //    Else
        //        //
        //        //DBOBJが設定された場合
        //        //
        //        //エラー管理テーブル取得
        //        If pbGetErrLib(vsErrCode, lvErrLibData, voDbObject) = True Then
        //            //
        //            //エラー管理テーブル取得時、エラーコードが存在するか判定
        //            If IsEmpty(lvErrLibData(0)) = False Then
        //                //
        //                //エラーコード／エラーレベル設定
        //                lsErrCode = lvErrLibData(0)
        //                lsErrLevel = lvErrLibData(1)
        //                //
        //                //エラー管理テーブルのエラーメッセージを使用するか判定
        //                If lvErrLibData(2) = 0 Then
        //                    //
        //                    //エラー管理テーブルのエラーメッセージを使用する場合
        //                    Select Case viErrMsgPos
        //                        Case 0
        //                            //
        //                            //エラー管理テーブルのエラーメッセージを設定
        //                            lsErrText1 = lvErrLibData(3)

        //                        Case 1
        //                            //
        //                            //エラー管理テーブルのエラーメッセージの前にパラメータのエラーメッセージを結合
        //                            lsErrText1 = vsErrMsg & lvErrLibData(3)

        //                        Case 2
        //                            //
        //                            //エラー管理テーブルのエラーメッセージの後にパラメータのエラーメッセージを結合
        //                            lsErrText1 = lvErrLibData(3) & vsErrMsg

        //                        Case Else
        //                            //
        //                            //エラー管理テーブルのエラーメッセージを設定
        //                            lsErrText1 = lvErrLibData(3)

        //                    End Select

        //                Else
        //                    //
        //                    //エラー管理テーブルのエラーメッセージを使用しない場合はパラメータのエラーメッセージを設定
        //                    lsErrText1 = vsErrMsg

        //                End If

        //            Else
        //                //
        //                //エラー管理テーブルに取得失敗
        //                lsErrCode = "D0018"
        //                lsErrLevel = "D"
        //                lsErrText1 = "エラー管理テーブルにコードが存在しません。エラーコード = " & vsErrCode
        //            End If

        //        Else
        //            //
        //            //エラー管理テーブル取得失敗
        //            lsErrCode = "P0013"
        //            lsErrLevel = "P"
        //            lsErrText1 = "エラー管理テーブル取得プロセスエラー"

        //        End If
        //    End If
        //    //
        //    //エラー情報をvarERRに設定
        //    Call pSetERRData(CON_ERR_FLG, lsErrLevel)
        //    Call pSetERRData(CON_ERR_CODE, lsErrCode)
        //    Call pSetERRData(CON_ERR_TEXT, lsErrText1)
        //    //
        //    //エラー情報を返却コレクションに格納
        //    rcError.Add varERR

        //End Function

        ////******************************************************************************
        ////*
        ////*  関数名：    pbGetErrLib
        ////*
        ////*  概要  ：    エラー管理テーブル取得
        ////*
        ////*  引数  ：　　(i) エラーコード(String)
        ////*              (o) エラーテーブル情報(Variant)
        ////*              (i) DBOBJクラス(Object)
        ////*
        ////*  戻り値：    True:正常、False:異常
        ////*
        ////******************************************************************************
        //Public Function pbGetErrLib(ByVal vsErrCode As String, ByRef rvErrLibData As Variant, ByVal voDbObject As Object) As Boolean

        //    Dim loDsoErrLib     As New DataStoreObject
        //    Dim lsSQL           As String
        //    Dim lvParam(0)      As Variant

        //    On Error GoTo Error_Handler

        //    pbGetErrLib = False
        //    //
        //    //返却エラー情報初期化
        //    Erase rvErrLibData
        //    ReDim rvErrLibData(5)

        //    With loDsoErrLib

        //        lsSQL = ""
        //        lsSQL = lsSQL & " SELECT"
        //        lsSQL = lsSQL & "   ERRCODE,"
        //        lsSQL = lsSQL & "   ERRLEVEL,"
        //        lsSQL = lsSQL & "   FLG, "
        //        lsSQL = lsSQL & "   TEXT1, "
        //        lsSQL = lsSQL & "   TEXT2, "
        //        lsSQL = lsSQL & "   TEXT3 "
        //        lsSQL = lsSQL & " FROM"
        //        lsSQL = lsSQL & "   ERRLIB"
        //        lsSQL = lsSQL & " WHERE"
        //        lsSQL = lsSQL & "   ERRCODE = ^"

        //        lvParam(0) = TILDE & vsErrCode

        //        .SetSQLId lsSQL, voDbObject

        //        If .PrepareDataSet(lvParam, True) > 0 Then
        //            //
        //            //返却エラー情報に設定
        //            .GetCurrentRow rvErrLibData

        //        End If

        //    End With

        //    Set loDsoErrLib = Nothing

        //    pbGetErrLib = True

        //    Exit Function

        //Error_Handler:
        //    Set loDsoErrLib = Nothing

        //End Function
        //↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑


        // 以上
        // basCommon.basからの移植
        //##########################################################################################################################    

        /// <summary>
        /// CSICommon入力、出力パラメタクリアメソッド
        /// </summary>
        public static void ClearAllParameter()
        {
            // object配列の入力パラメタクリア
            CSICommon.varINPARAM = null;

            // object配列の出力パラメタクリア
            CSICommon.varADMSCH = null;
            CSICommon.varAPPSCH = null;
            CSICommon.varBLOODTYPE = null;
            CSICommon.varDETAIL = null;
            CSICommon.varDETAILINFO = null;
            CSICommon.varERR = null;
            CSICommon.varEXAMFREE = null;
            CSICommon.varGROUP = null;
            CSICommon.varHEADER = null;
            CSICommon.varINFECTION = null;
            CSICommon.varINPARAM = null;
            CSICommon.varINSURANCE = null;
            CSICommon.varORDER = null;
            CSICommon.varOUTPARAM = null;
            CSICommon.varPATAPPSCH = null;
            CSICommon.varPATSCH = null;

            // VBA.Collectionの出力パラメタクリア
            objVBACollection.ClearVBACollection(ref CSICommon.colERR);
            objVBACollection.ClearVBACollection(ref CSICommon.colDETAIL);
            objVBACollection.ClearVBACollection(ref CSICommon.colDETAILINFO);
            objVBACollection.ClearVBACollection(ref CSICommon.colGROUP);
            objVBACollection.ClearVBACollection(ref CSICommon.colHEADER);
            objVBACollection.ClearVBACollection(ref CSICommon.colINFECTION);
            objVBACollection.ClearVBACollection(ref CSICommon.colINSURANCE);
            objVBACollection.ClearVBACollection(ref CSICommon.colORDER);
            objVBACollection.ClearVBACollection(ref CSICommon.colPATAPPSCH);
        }

        /// <summary>
        /// CSICommon入力、出力コレクションパラメータをクリアする
        /// </summary>
        /// <param name="collection">クリアしたいコレクションパラメータ</param>
        public static void ClearColParameter(ref VBA.Collection collection)
        {
            // クリアする
            objVBACollection.ClearVBACollection(ref collection);
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public CSICommon()
        {
        }

        #endregion 
    }
}