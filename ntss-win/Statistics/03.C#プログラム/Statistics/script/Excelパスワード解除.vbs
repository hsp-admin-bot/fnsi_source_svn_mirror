'**************************************************
' Excelパスワード解除
'**************************************************
Option Explicit
On Error Resume Next

' 変数
Dim xls_edit_file
Dim objCmd
Dim objExcel
Dim objBook
Dim Password_1

'**************************************************
' ファイルパスチェック（ドラッグ＆ドロップされたファイルのパスを取得）
'**************************************************
If WScript.Arguments.Count > 0 Then
  xls_edit_file = WScript.Arguments(0)
Else
  WScript.Echo "対象のExcelファイルを当ファイル上にドラッグ＆ドロップしてください"
  WScript.Quit
End IF

'**************************************************
' Excel2010以降で「保護されたビュー」で開かないようにする
'**************************************************
Set objCmd = CreateObject("WScript.Shell")
objCmd.Run "cmd /c type nul > " + xls_edit_file + ":Zone.Identifier",0,true

'**************************************************
' Excelパスワード解除
'**************************************************
WScript.Echo "統計調査のパスワード解除を行います"

' 初期処理
Err.Clear
Set objExcel = WScript.CreateObject("Excel.Application")
If Err.Number <> 0 Then
  Wscript.Echo "Microsoft Excelがインストールされていません"
  WScript.Quit
End If
objExcel.Application.DisplayAlerts = False '警告が出ないように設定
objExcel.Visible = False

' パスワード入力
Password_1 = InputBox ("パスワードを入力してください","パスワード入力")
If IsEmpty(Password_1) Then
  Set objExcel = Nothing
  WScript.Quit
ElseIf Password_1 = "" Then
  WScript.Echo "パスワードが入力されていません"
  Set objExcel = Nothing
  WScript.Quit
End If

' ファイルオープン処理
Err.Clear
Set objBook = objExcel.WorkBooks.Open(xls_edit_file,,,,Password_1) ' オープン時パスワードを指定する
If Err.Number = 1004 Then
  WScript.Echo "入力されたパスワードが間違っています"
'##エクセル終了
  objExcel.Quit
'##
  Set objExcel = Nothing
  WScript.Quit
ElseIf Err.Number <> 0 Then
  Wscript.Echo "予期しないエラーが発生しました[ " & Err.Description & " ]"
'##エクセル終了
  objExcel.Quit
'##
  Set objExcel = Nothing
  WScript.Quit
End If

'ワークブックを保護解除
objBook.UnProtect "k3JYixDH"
If Err.Number = 1004 Then
   'ワークブックを保護解除
   Err.Clear
   objExcel.Application.DisplayAlerts = false '警告が出ないように設定
   objExcel.Visible = true
   objBook.UnProtect "A6qUsfS8"
   If Err.Number = 1004 Then
      WScript.Echo "ブック保護の解除が出来ませんでした"
'##ブックのクローズとエクセルの終了
      objBook.Close
      objExcel.Quit
'##
      Set objBook = Nothing
      Set objExcel = Nothing
      WScript.Quit
   End If
ElseIf Err.Number <> 0 Then
  Wscript.Echo "予期しないエラーが発生しました[ " & Err.Description & " ]"
'##ブックのクローズとエクセルの終了
  objBook.Close
  objExcel.Quit
'##
  Set objBook = Nothing
  Set objExcel = Nothing
  WScript.Quit
End If

' パスワード解除処理
objBook.SaveAs xls_edit_file,,"","" ' 書き込み時パスワード欄を空の文字列とする
objBook.Close
objExcel.Quit

'オブジェクトの開放
Set objBook = Nothing
Set objExcel = Nothing

'**************************************************
' 統計調査実名化
'**************************************************
WScript.Echo "パスワードが解除されましたので引続き、実名化を行います"

' 初期処理
Err.Clear
Set objExcel = WScript.CreateObject("Excel.Application")
If Err.Number <> 0 Then
  objExcel.Quit
  Wscript.Echo "Microsoft Excelがインストールされていません"
  WScript.Quit
End If
objExcel.Application.DisplayAlerts = false '警告が出ないように設定
objExcel.Visible = true

' ファイルオープン処理
Err.Clear
Set objBook = objExcel.WorkBooks.Open(xls_edit_file,,,,Password_1) ' オープン時パスワードを指定する
If Err.Number <> 0 Then
  Wscript.Echo "予期しないエラーが発生しました[ " & Err.Description & " ]"
  objExcel.Quit
  Set objExcel = Nothing
  WScript.Quit
End If

' 実名化ボタンの実行
objExcel.ActiveWorkbook.Worksheets("患者調査票").select
objExcel.Run("execJitsumei")

'ファイル保存処理
objBook.Close True
objExcel.Quit

'オブジェクトの開放
Set objBook = Nothing
Set objExcel = Nothing
Set objCmd = Nothing

' 処理終了メッセージ
WScript.Echo "正常に終了しました"
