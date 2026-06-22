'**************************************************
' Excelパスワード設定
'**************************************************
Option Explicit
On Error Resume Next

' 変数
Dim xls_edit_file
Dim objExcel
Dim objBook
Dim Password_1
Dim Password_2

' ファイルパスチェック（ドラッグ＆ドロップされたファイルのパスを取得）
If WScript.Arguments.Count > 0 Then
  xls_edit_file = WScript.Arguments(0)
Else
  WScript.Echo "対象のExcelファイルを当ファイル上にドラッグ＆ドロップしてください"
  WScript.Quit
End If

' 初期処理
Err.Clear
Set objExcel = WScript.CreateObject("Excel.Application")
If Err.Number <> 0 Then
  Wscript.Echo "Microsoft Excelがインストールされていません"
  WScript.Quit
End If
objExcel.Application.DisplayAlerts = False '警告が出ないように設定
objExcel.Visible = False

' パスワード入力（１回目）
Password_1 = InputBox ("パスワードを入力してください","パスワード入力")
If IsEmpty(Password_1) Then
  objExcel.Quit
'##オブジェクトの開放
  Set objExcel = Nothing
'##
  WScript.Quit
ElseIf Password_1 = "" Then
  WScript.Echo "パスワードが入力されていません"
  objExcel.Quit
'##オブジェクトの開放
  Set objExcel = Nothing
'##
  WScript.Quit
End If

' パスワード入力（２回目）
Password_2 = InputBox ("パスワードをもう一度入力してください","パスワード再入力")
If IsEmpty(Password_2) Then
  objExcel.Quit
'##オブジェクトの開放
  Set objExcel = Nothing
'##
  WScript.Quit
ElseIf Password_2 = "" Then
  WScript.Echo "パスワードが入力されていません"
  objExcel.Quit
'##オブジェクトの開放
  Set objExcel = Nothing
'##
  WScript.Quit
End If

' 入力パスワードチェック
If Password_1 <> Password_2 Then
  WScript.Echo "先に入力されたパスワードと一致しません"
  objExcel.Quit
'##オブジェクトの開放
  Set objExcel = Nothing
'##
  WScript.Quit
End If

' ファイルオープン処理
Err.Clear
Set objBook = objExcel.WorkBooks.Open(xls_edit_file,,,,Password_1) ' オープン時パスワードを指定する
If Err.Number = 1004 Then
  objBook.Close
  objExcel.Quit
  WScript.Echo "既に他のパスワードが設定されています"
'##オブジェクトの開放
  Set objExcel = Nothing
'##
  WScript.Quit
ElseIf Err.Number <> 0 Then
  objBook.Close
  objExcel.Quit
  Wscript.Echo "予期しないエラーが発生しました[ " & Err.Description & " ]"
'##オブジェクトの開放
  Set objExcel = Nothing
'##
  WScript.Quit
End If

'ワークブックを保護（パスワード付き）
Err.Clear
objExcel.Application.DisplayAlerts = False '警告が出ないように設定
objExcel.Visible = False
objBook.Protect "k3JYixDH"
If Err.Number = 1004 Then
  objBook.Close
  objExcel.Quit
  WScript.Echo "既に他のパスワードが設定されています"
'##オブジェクトの開放
  Set objBook = Nothing
  Set objExcel = Nothing
'##
  WScript.Quit
ElseIf Err.Number <> 0 Then
  objBook.Close
  objExcel.Quit
  Wscript.Echo "予期しないエラーが発生しました[ " & Err.Description & " ]"
'##オブジェクトの開放
  Set objBook = Nothing
  Set objExcel = Nothing
'##
  WScript.Quit
End If

' パスワード設定処理
objBook.SaveAs xls_edit_file,,Password_1 ' 書き込み時パスワード欄を空の文字列とする
objBook.Close
objExcel.Quit
'##オブジェクトの開放
Set objBook = Nothing
Set objExcel = Nothing
'##

' 処理終了メッセージ
WScript.Echo "正常に終了しました"
