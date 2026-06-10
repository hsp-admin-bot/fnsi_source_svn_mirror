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
'//	日付        担当                理由
'// 2020/05/20  TEX-SOL             既存システムより流用
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

' add 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start
'----------------------------
'  指定された桁前ゼロ詰め処理
'----------------------------
Function ZeroPadByLen(name, maxLen)
	dim length
	length=len(name)
	if maxLen = "0" OR length >= maxLen then
		ZeroPadByLen = name
	else
		ZeroPadByLen = "00000000000000000000000000000000000000000000000000000000000000000000000000000000" & name
		ZeroPadByLen = right(ZeroPadByLen, maxLen)
	end if
end Function
' add 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end

' add 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 start
'----------------------------
'  前ゼロ削除処理
'----------------------------
Function ZeroTrim(name)
	dim tmpName
	tmpName = name
	For i = 1 to len(name)
		if left(tmpName, 1) = "0" then
			if Len(tmpName) = 1 then
				exit for
			end if
			tmpName = right(tmpName, Len(tmpName) - 1)
		else
			exit for
		end if
	Next
	ZeroTrim = tmpName
end Function
' add 2021-07-16 #5429:患者番号の前ゼロの扱いについて 孫 end

%>
