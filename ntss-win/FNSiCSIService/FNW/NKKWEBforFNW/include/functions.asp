<%
'///////////////////////////////////////////////////////////////////////////////
'//
'// システム名：FutureNetⅢ
'// 機能名    ：FNW版標準WEB-IF　共通ライブラリ
'// ファイル名：functions.asp
'// 説明      ：共通ライブラリ
'//
'//	Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
'//
'// 更新履歴
'//	日付		担当				理由
'//	2010/01/15	堀内英史			FN2版から流用（※DB系など不要なメソッドは除去）
'//
'///////////////////////////////////////////////////////////////////////////////


'----------------------------
'  変数の宣言
'----------------------------
Public Req,Arguments

'----------------------------
'  POSTとGETの値の取り方を揃える
'（ex  Req("test") のように取得）
'----------------------------
sub GetArg
	dim Name
	set Req=CreateObject("Scripting.Dictionary")	' 連想配列
	Arguments=""

	with Request
		if .ServerVariables("REQUEST_METHOD")="GET" then
			For Each Name In .QueryString
				Req.add Name,.Querystring(Name)
				Arguments=Arguments&Name&"="&Server.URLEncode(.Querystring(Name))&"&"
			next
		else
			For Each Name In .Form
				Req.add Name,.Form(Name)
				Arguments=Arguments&Name&"="&Server.URLEncode(.Form(Name))&"&"
			next
		end if
	end with
end sub


'----------------------------
'  12桁前ゼロ詰め処理
'----------------------------
Function ZeroPad(name)
	dim length
	length=len(name)
	ZeroPad = "000000000000" & name
	ZeroPad = right(ZeroPad, 12)
end Function

%>
