<%
'///////////////////////////////////////////////////////////////////////////////
'//
'// システム名：FutureNetⅢ
'// 機能名    ：FNW版標準WEB-IF　共通定数
'// ファイル名：CommonConst.asp
'// 説明      ：設定値など共通の定数を定義
'//
'//	Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
'//
'// 更新履歴
'//	日付        担当                理由
'// 2020/05/20  TEX-SOL             既存システムより流用
'//
'///////////////////////////////////////////////////////////////////////////////

Dim pdfPath
Dim fileName_pdfServerInfo
Dim fileName_patientInfo

'PDF格納先トップURL（"hoge/"）
pdfPath					 = "dia_rep/"

'PDFサーバ情報XMLファイル名
fileName_pdfServerInfo	 = "pdfserverinfo.xml"

'患者情報XMLファイル名
fileName_patientInfo	 = "patientinfo.xml"


%>
