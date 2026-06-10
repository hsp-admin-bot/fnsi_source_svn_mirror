<%@ LANGUAGE="VBScript" %>
<%
'///////////////////////////////////////////////////////////////////////////////
'//
'// システム名：FutureNetⅢ
'// 機能名    ：FNW版標準WEB-IF　透析レポート表示asp
'// ファイル名：GetDialysis.asp
'// 説明      ：内部で透析レポートPDFファイルへのURLに置き換えてリフレッシュする。
'//
'// Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
'//
'// 更新履歴
'// 日付        担当                理由
'// 2010/01/15  堀内英史            FN2版から流用（この時点で使用の予定はない）
'//
'// （使用方法）
'//     http://if-server/getdialysis.asp?file=ファイル名
'//     Ex.
'//     http://if-server/getdialysis.asp?file=dia_rep/000000102452/000000102452-20031204093915.PDF
'//     patidは、先頭に0を詰めてFN2内部12桁形式にあわせる。
'//     keyは、12桁＋12桁形式のみ有効。
'//
'///////////////////////////////////////////////////////////////////////////////

Option Explicit
%>
<!--#include file="include/CommonConst.asp"-->
<% Response.CacheControl = "no-cache" %>
<% Response.AddHeader "Pragma", "no-cache" %>
<% Response.Expires = -1 %>
<%
'
'----------------------------
'  変数の宣言
'----------------------------
public Req,Arguments

'----------------------------
'  POSTとGETの値の取り方を揃える
'（ex  Req("test") のように取得）
'----------------------------
sub GetArg
    dim Name
    set Req=CreateObject("Scripting.Dictionary")    ' 連想配列
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
%>

<%

dim param1
dim param2

param1 = "patid"
param2 = "key"

'-----------------
' 送信文字列の取得
'-----------------
call GetArg

Function ZeroPad(name)
    dim length
    length=len(name)
    ZeroPad = "000000000000" & name
    ZeroPad = right(ZeroPad, 12)
end Function

Function GetExistFileName(strFileName)
    dim strDirElements
    dim intCnt
    dim strRetFileName
    Dim objFSO
    dim strFilePath
    
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    
    strFilePath = pdfFolder & Mid(strFileName, Len(pdfPath) + 1)
    strFilePath = Replace(strFilePath, "/", "\\")
    If objFSO.FileExists(strFilePath) Then
        'ファイルが存在するため、このファイルパスを採用
        strRetFileName = strFileName
    Else
        '階層で分ける
        strDirElements = Split(strFileName, "/")
        
        If UBOUND(strDirElements) = 0 Then
            '階層がないのでそのままのファイルパスを返す
            strRetFileName = strFileName
        Else
            '2番目が患者IDフォルダ部分とみなし、0を除去する
            strDirElements(1) = FormatNumber(strDirElements(1), 0, 0, 0, 0)
            
            '結合
            strRetFileName = ""
            For intCnt = 0 to UBOUND(strDirElements)
                If intCnt <> 0 Then
                    strRetFileName = strRetFileName & "/"
                End If
                strRetFileName = strRetFileName & strDirElements(intCnt)
            Next
        End If
    End If
    
    '生成したファイル名を返す
    GetExistFileName = strRetFileName
End Function
%>


<script language="JavaScript">
    function fnCheckClick( click ) {
        if (document.layers || (document.getElementById && !document.all)) {
            if(click.which==2 || click.which==3) {
                return false;
            }
        }
    }
    function fnCheckContextMenu() {
        if (document.all) {
            return false;
        }
    }
    function fnInit() {
        document.title = "日機装株式会社";
    }
    if (document.layers){
        document.captureEvents(Event.MOUSEDOWN);
        document.onmousedown=fnCheckClick;
    }else{
        document.onmouseup=fnCheckClick;
        document.oncontextmenu=fnCheckContextMenu;
    }
</script>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=x-sjis">

<% if Req("file") = "" then %>
</head>
<body onLoad="fnInit()">
<h1>Paramerter Error</h1>
</body>
</html>
<% else %>
<!--
'''<meta http-equiv="refresh" content="0;URL=<%= pdfpath & "/" & ZeroPad(Req(param1)) & "/" & Req(param2) & ".pdf" %>">
''<meta http-equiv="refresh" content="0;URL=<%= pdfpath & "/" & Req(param1) & "/" & Req(param2) & ".pdf" %>">
-->
</head>
<body onLoad="fnInit()">
<iframe src="<%= GetExistFileName(Req("file")) %>" width="100%" height="100%" hspace="0" vspace="0" marginheight="0" marginwidth="0" allowtransparency=ture >
この部分は iframe 対応のブラウザで見てください。
</iframe>
</body>
</html>
<% end if %>
