# 変更履歴

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `変更履歴`
- Category: overview

## Content

| 変更履歴 | col2 | col3 | col4 | col5 | col6 | col7 | col8 | col9 | col10 | ↓反映済：「○ or 日付」、未確認／未反映：「×」、反映不要：「‐」を記入して下さい | col12 | col13 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  | No | テーブル名/ファンクション名/トリガー名 | 変更内容 | 区分 | 更新者 | 更新日 | DBバージョン | 備考 | ■ | 0 | 検証環境RDS反映日 | 本番環境RDS反映日 |
| =IF(OR(C3="",COUNTIF($C$3:C3,C3)<COUNTIF(C:C,C3)),"",C3) | 1 | mst_machine | - | 新規 | YSK橋口 | 43027 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C4="",COUNTIF($C$3:C4,C4)<COUNTIF(C:C,C4)),"",C4) | 2 | mst_machine_type | - | 新規 | YSK橋口 | 43027 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C5="",COUNTIF($C$3:C5,C5)<COUNTIF(C:C,C5)),"",C5) | 3 | mst_machine_record | - | 新規 | YSK橋口 | 43027 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C6="",COUNTIF($C$3:C6,C6)<COUNTIF(C:C,C6)),"",C6) | 4 | mst_facility | - | 新規 | YSK橋口 | 43027 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C7="",COUNTIF($C$3:C7,C7)<COUNTIF(C:C,C7)),"",C7) | 5 | mst_m_notice | - | 新規 | YSK橋口 | 43027 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C8="",COUNTIF($C$3:C8,C8)<COUNTIF(C:C,C8)),"",C8) | 6 | m_notice_manage | - | 新規 | YSK橋口 | 43027 | 1.0.0.0 |  | =IFERROR(IF(C8=VLOOKUP(C8,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C8&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C9="",COUNTIF($C$3:C9,C9)<COUNTIF(C:C,C9)),"",C9) | 7 | mst_device_edge | - | 新規 | YSK橋口 | 43028 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C10="",COUNTIF($C$3:C10,C10)<COUNTIF(C:C,C10)),"",C10) | 8 | mst_alive_moni | - | 新規 | YSK橋口 | 43028 | 1.0.0.0 |  | =IFERROR(IF(C10=VLOOKUP(C10,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C10&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C11="",COUNTIF($C$3:C11,C11)<COUNTIF(C:C,C11)),"",C11) | 9 | alive_moni_manage | - | 新規 | YSK橋口 | 43028 | 1.0.0.0 |  | =IFERROR(IF(C11=VLOOKUP(C11,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C11&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C12="",COUNTIF($C$3:C12,C12)<COUNTIF(C:C,C12)),"",C12) | 10 | mst_machine | カラムに以下を追加<br>・デバイスエッジ番号 | 変更 | YSK橋口 | 43028 | 1.0.0.0 | 各デバイスエッジと各装置の関連付け | ■ | ○ | ○ | - |
| =IF(OR(C13="",COUNTIF($C$3:C13,C13)<COUNTIF(C:C,C13)),"",C13) | 11 | mst_machine | 型変更 | 変更 | YSK櫨木 | 43031 | 1.0.0.0 | date型 ⇒ timestamp型に変更 | ■ | ○ | ○ | - |
| =IF(OR(C14="",COUNTIF($C$3:C14,C14)<COUNTIF(C:C,C14)),"",C14) | 12 | mst_machine_type | 型変更 | 変更 | YSK櫨木 | 43031 | 1.0.0.0 | date型 ⇒ timestamp型に変更 | ■ | ○ | ○ | - |
| =IF(OR(C15="",COUNTIF($C$3:C15,C15)<COUNTIF(C:C,C15)),"",C15) | 13 | mst_machine_record | 型変更 | 変更 | YSK櫨木 | 43031 | 1.0.0.0 | date型 ⇒ timestamp型に変更 | ■ | ○ | ○ | - |
| =IF(OR(C16="",COUNTIF($C$3:C16,C16)<COUNTIF(C:C,C16)),"",C16) | 14 | mst_facility | 型変更 | 変更 | YSK櫨木 | 43031 | 1.0.0.0 | date型 ⇒ timestamp型に変更 | ■ | ○ | ○ | - |
| =IF(OR(C17="",COUNTIF($C$3:C17,C17)<COUNTIF(C:C,C17)),"",C17) | 15 | mst_m_notice | 型変更 | 変更 | YSK櫨木 | 43031 | 1.0.0.0 | date型 ⇒ timestamp型に変更 | ■ | ○ | ○ | - |
| =IF(OR(C18="",COUNTIF($C$3:C18,C18)<COUNTIF(C:C,C18)),"",C18) | 16 | m_notice_manage | 型変更 | 変更 | YSK櫨木 | 43031 | 1.0.0.0 | date型 ⇒ timestamp型に変更 | =IFERROR(IF(C18=VLOOKUP(C18,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C18&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C19="",COUNTIF($C$3:C19,C19)<COUNTIF(C:C,C19)),"",C19) | 17 | mst_device_edge | 型変更 | 変更 | YSK櫨木 | 43031 | 1.0.0.0 | date型 ⇒ timestamp型に変更 | ■ | ○ | ○ | - |
| =IF(OR(C20="",COUNTIF($C$3:C20,C20)<COUNTIF(C:C,C20)),"",C20) | 18 | mst_alive_moni | 型変更 | 変更 | YSK櫨木 | 43031 | 1.0.0.0 | date型 ⇒ timestamp型に変更 | =IFERROR(IF(C20=VLOOKUP(C20,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C20&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C21="",COUNTIF($C$3:C21,C21)<COUNTIF(C:C,C21)),"",C21) | 19 | alive_moni_manage | 型変更 | 変更 | YSK櫨木 | 43031 | 1.0.0.0 | date型 ⇒ timestamp型に変更 | =IFERROR(IF(C21=VLOOKUP(C21,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C21&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C22="",COUNTIF($C$3:C22,C22)<COUNTIF(C:C,C22)),"",C22) | 20 | mst_alive_moni | カラムに以下を追加<br>・メールアドレス<br>・対象者名称 | 変更 | YSK橋口 | 43035 | 1.0.0.0 |  | =IFERROR(IF(C22=VLOOKUP(C22,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C22&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C23="",COUNTIF($C$3:C23,C23)<COUNTIF(C:C,C23)),"",C23) | 21 | alive_moni_manage | カラムに以下を追加<br>・メール送信日時<br>・メール本文<br>・メールアドレス<br>・対象者名称 | 変更 | YSK橋口 | 43035 | 1.0.0.0 |  | =IFERROR(IF(C23=VLOOKUP(C23,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C23&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C24="",COUNTIF($C$3:C24,C24)<COUNTIF(C:C,C24)),"",C24) | 22 | mst_facility | カラムに以下を追加<br>・死活監視メールテンプレート | 変更 | YSK橋口 | 43035 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C25="",COUNTIF($C$3:C25,C25)<COUNTIF(C:C,C25)),"",C25) | 23 | sys_system_define | - | 新規 | YSK橋口 | 43035 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C26="",COUNTIF($C$3:C26,C26)<COUNTIF(C:C,C26)),"",C26) | 24 | mst_device_edge | カラムに以下を追加<br>・デバイス名 | 変更 | YSK橋口 | 43038 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C27="",COUNTIF($C$3:C27,C27)<COUNTIF(C:C,C27)),"",C27) | 25 | mst_machine | カラムに以下を追加<br>・ポート番号 | 変更 | YSK橋口 | 43040 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C28="",COUNTIF($C$3:C28,C28)<COUNTIF(C:C,C28)),"",C28) | 26 | m_notice_manage | カラムに以下を追加<br>・装置記録補助メッセージ | 変更 | YSK橋口 | 43048 | 1.0.0.0 |  | =IFERROR(IF(C28=VLOOKUP(C28,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C28&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C29="",COUNTIF($C$3:C29,C29)<COUNTIF(C:C,C29)),"",C29) | 27 | mst_machine | カラムに以下を追加<br>・FTP収集 | 変更 | YSK橋口 | 43049 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C30="",COUNTIF($C$3:C30,C30)<COUNTIF(C:C,C30)),"",C30) | 28 | mst_machine | カラムに以下を追加<br>　・通信フォーマット(1) | 変更 | ESM高原 | 43053 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C31="",COUNTIF($C$3:C31,C31)<COUNTIF(C:C,C31)),"",C31) | 29 | mst_machine | 桁数変更 | 変更 | ESM高原 | 43053 | 1.0.0.0 | 施設コード : 20バイト ⇒ 6バイト<br>製造番号 : 8バイト ⇒ 7バイト | ■ | ○ | ○ | - |
| =IF(OR(C32="",COUNTIF($C$3:C32,C32)<COUNTIF(C:C,C32)),"",C32) | 30 | mst_facility | 桁数変更 | 変更 | ESM高原 | 43053 | 1.0.0.0 | 施設コード : 20バイト ⇒ 6バイト | ■ | ○ | ○ | - |
| =IF(OR(C33="",COUNTIF($C$3:C33,C33)<COUNTIF(C:C,C33)),"",C33) | 31 | mst_facility | カラムの削除<br>　・死活管理メールテンプレート | 変更 | ESM高原 | 43053 | 1.0.0.0 |  | ■ | ○ | ○ | - |
| =IF(OR(C34="",COUNTIF($C$3:C34,C34)<COUNTIF(C:C,C34)),"",C34) | 32 | mst_m_notice | 桁数変更 | 変更 | ESM高原 | 43053 | 1.0.0.0 | 施設コード : 20バイト ⇒ 6バイト | ■ | ○ | ○ | - |
| =IF(OR(C35="",COUNTIF($C$3:C35,C35)<COUNTIF(C:C,C35)),"",C35) | 33 | m_notice_manage | カラムに以下を追加<br>　・通信フォーマット(1バイト) | 変更 | ESM高原 | 43053 | 1.0.0.0 |  | =IFERROR(IF(C35=VLOOKUP(C35,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C35&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C36="",COUNTIF($C$3:C36,C36)<COUNTIF(C:C,C36)),"",C36) | 34 | m_notice_manage | 桁数変更 | 変更 | ESM高原 | 43053 | 1.0.0.0 | 施設コード : 20バイト ⇒ 6バイト<br>製造番号 : 8バイト ⇒ 7バイト | =IFERROR(IF(C36=VLOOKUP(C36,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C36&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C37="",COUNTIF($C$3:C37,C37)<COUNTIF(C:C,C37)),"",C37) | 35 | mst_device_edge | 桁数変更 | 変更 | ESM高原 | 43053 | 1.0.0.0 | 施設コード : 20バイト ⇒ 6バイト | ■ | ○ | ○ | - |
| =IF(OR(C38="",COUNTIF($C$3:C38,C38)<COUNTIF(C:C,C38)),"",C38) | 36 | sys_system_define | 桁数変更 | 変更 | ESM高原 | 43053 | 1.0.0.0 | 施設コード : 20バイト ⇒ 6バイト | ■ | ○ | ○ | - |
| mst_alive_moni | 37 | mst_alive_moni | テーブル削除 | 変更 | ESM高原 | 43053 | 1.0.0.0 |  | =IFERROR(IF(C39=VLOOKUP(C39,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C39&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C40="",COUNTIF($C$3:C40,C40)<COUNTIF(C:C,C40)),"",C40) | 38 | alive_moni_manage | テーブル削除 | 変更 | ESM高原 | 43053 | 1.0.0.0 |  | =IFERROR(IF(C40=VLOOKUP(C40,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C40&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C41="",COUNTIF($C$3:C41,C41)<COUNTIF(C:C,C41)),"",C41) | 39 | - | 「DB構成」シート追加 | 追加 | YSK橋口 | 43054 | 1.0.0.0 |  | =IFERROR(IF(C41=VLOOKUP(C41,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C41&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C42="",COUNTIF($C$3:C42,C42)<COUNTIF(C:C,C42)),"",C42) | 40 | gathering_manage | - | 新規 | YSK橋口 | 43056 | 1.0.0.0 |  | =IFERROR(IF(C42=VLOOKUP(C42,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C42&"!A1","■"),""),"") | 43070 | 43070 |  |
| =IF(OR(C43="",COUNTIF($C$3:C43,C43)<COUNTIF(C:C,C43)),"",C43) | 41 | m_notice_manage | 以下のカラムの「NOT NULL」制約を削除<br>・イベント発生日時 | 変更 | YSK橋口 | 43056 | 1.0.0.0 |  | =IFERROR(IF(C43=VLOOKUP(C43,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C43&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C44="",COUNTIF($C$3:C44,C44)<COUNTIF(C:C,C44)),"",C44) | 42 | m_notice_manage | カラムに以下を追加<br>・登録日時<br>・更新日時 | 変更 | YSK橋口 | 43059 | 1.0.0.0 | マスタ系テーブルだけではなく、管理系テーブルにも「登録日時」「更新日時」を保持する | =IFERROR(IF(C44=VLOOKUP(C44,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C44&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C45="",COUNTIF($C$3:C45,C45)<COUNTIF(C:C,C45)),"",C45) | 43 | gathering_manage | カラムに以下を追加<br>・登録日時<br>・操作情報<br>・親管理番号<br>「データ収集情報」カラムのJSON形式フォーマットを変更 | 変更 | YSK橋口 | 43059 | 1.0.0.0 | 「データ収集情報」カラムのJSON形式フォーマット<br>[通信フォーマット][製造番号][IPアドレス]<br>　↓<br>[型式コード][通信フォーマット][製造番号] | =IFERROR(IF(C45=VLOOKUP(C45,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C45&"!A1","■"),""),"") | 43070 | 43070 |  |
| =IF(OR(C46="",COUNTIF($C$3:C46,C46)<COUNTIF(C:C,C46)),"",C46) | 44 | m_notice_manage | 以下のカラムの取り扱いを変更<br>・緊急発報管理番号 | 変更 | YSK橋口 | 43060 | 1.0.0.0 | 「MAX+1」による手動でのインクリメントではなく、シーケンスを使用したインクリメントを行うように変更<br>※「新規追加時はMAX+1」の記載内容を削除 | =IFERROR(IF(C46=VLOOKUP(C46,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C46&"!A1","■"),""),"") | ○ | ○ |  |
| =IF(OR(C47="",COUNTIF($C$3:C47,C47)<COUNTIF(C:C,C47)),"",C47) | 45 | gathering_manage | 以下のカラムの取り扱いを変更<br>・データ収集情報 | 変更 | YSK橋口 | 43060 | 1.0.0.0 | JSON形式で保持する装置情報について、「装置ステータス」ではなく、「装置エラーコード」を保持するように変更 | =IFERROR(IF(C47=VLOOKUP(C47,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C47&"!A1","■"),""),"") | 43070 | 43070 |  |
| =IF(OR(C48="",COUNTIF($C$3:C48,C48)<COUNTIF(C:C,C48)),"",C48) | 46 | gathering_manage | 以下のカラムの型変更<br>・親管理番号 | 変更 | YSK橋口 | 43060 | 1.0.0.0 | bigserial型 ⇒ bigint型に変更 | =IFERROR(IF(C48=VLOOKUP(C48,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C48&"!A1","■"),""),"") | 43070 | 43070 |  |
| =IF(OR(C49="",COUNTIF($C$3:C49,C49)<COUNTIF(C:C,C49)),"",C49) | 47 | alive_moni_manage | テーブル再構築 | 変更 | YSK橋口 | 43060 | 1.0.0.0 | 死活監視対象の状態管理用テーブル | =IFERROR(IF(C49=VLOOKUP(C49,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C49&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C50="",COUNTIF($C$3:C50,C50)<COUNTIF(C:C,C50)),"",C50) | 48 | mst_facility | カラムに以下を追加<br>・自動データ収集開始時刻 | 変更 | YSK橋口 | 43061 | 1.0.0.0 |  | ■ | 43073 | 43073 | - |
| =IF(OR(C51="",COUNTIF($C$3:C51,C51)<COUNTIF(C:C,C51)),"",C51) | 49 | mst_machine | 桁数変更 | 変更 | YSK橋口 | 43061 | 1.0.0.0 | 製造番号 : 7バイト ⇒ 8バイト | ■ | 43073 | 43073 | - |
| =IF(OR(C52="",COUNTIF($C$3:C52,C52)<COUNTIF(C:C,C52)),"",C52) | 50 | m_notice_manage | 桁数変更 | 変更 | YSK橋口 | 43061 | 1.0.0.0 | 製造番号 : 7バイト ⇒ 8バイト | =IFERROR(IF(C52=VLOOKUP(C52,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C52&"!A1","■"),""),"") | 43070 | 43070 |  |
| =IF(OR(C53="",COUNTIF($C$3:C53,C53)<COUNTIF(C:C,C53)),"",C53) | 51 | gathering_manage | 桁数変更 | 変更 | YSK橋口 | 43061 | 1.0.0.0 | 製造番号 : 7バイト ⇒ 8バイト | =IFERROR(IF(C53=VLOOKUP(C53,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C53&"!A1","■"),""),"") | 43070 | 43070 |  |
| =IF(OR(C54="",COUNTIF($C$3:C54,C54)<COUNTIF(C:C,C54)),"",C54) | 52 | alive_moni_manage | 桁数変更 | 変更 | YSK橋口 | 43061 | 1.0.0.0 | 製造番号 : 7バイト ⇒ 8バイト | =IFERROR(IF(C54=VLOOKUP(C54,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C54&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C55="",COUNTIF($C$3:C55,C55)<COUNTIF(C:C,C55)),"",C55) | 53 | mst_m_notice | 以下のカラムの「NOT NULL」制約を削除<br>・装置記録メッセージ | 変更 | YSK橋口 | 43061 | 1.0.0.0 |  | ■ | 43073 | 43073 | - |
| =IF(OR(C56="",COUNTIF($C$3:C56,C56)<COUNTIF(C:C,C56)),"",C56) | 54 | mst_machine_type | カラムに以下を追加<br>・通信種別 | 変更 | YSK橋口 | 43066 | 1.0.0.0 |  | ■ | 43073 | 43073 | - |
| m_notice_manage | 55 | m_notice_manage | テーブル名に「mnt_」を付与する | 変更 | YSK橋口 | 43066 | 1.0.0.0 |  | =IFERROR(IF(C57=VLOOKUP(C57,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C57&"!A1","■"),""),"") | 43070 | 43070 |  |
| gathering_manage | 56 | gathering_manage | テーブル名に「mnt_」を付与する | 変更 | YSK橋口 | 43066 | 1.0.0.0 |  | =IFERROR(IF(C58=VLOOKUP(C58,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C58&"!A1","■"),""),"") | 43070 | 43070 |  |
| alive_moni_manage | 57 | alive_moni_manage | テーブル名に「mnt_」を付与する | 変更 | YSK橋口 | 43066 | 1.0.0.0 |  | =IFERROR(IF(C59=VLOOKUP(C59,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C59&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C60="",COUNTIF($C$3:C60,C60)<COUNTIF(C:C,C60)),"",C60) | 58 | mnt_m_notice_manage | カラムに以下を追加<br>・備考 | 変更 | YSK橋口 | 43066 | 1.0.0.0 |  | =IFERROR(IF(C60=VLOOKUP(C60,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C60&"!A1","■"),""),"") | 43070 | 43070 |  |
| =IF(OR(C61="",COUNTIF($C$3:C61,C61)<COUNTIF(C:C,C61)),"",C61) | 59 | mnt_m_notice_manage | 以下のカラムの名称変更<br>・装置記録補助メッセージ | 変更 | YSK橋口 | 43066 | 1.0.0.0 | 装置記録補助データ（machine_record_aux_data） | =IFERROR(IF(C61=VLOOKUP(C61,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C61&"!A1","■"),""),"") | 43070 | 43070 |  |
| =IF(OR(C62="",COUNTIF($C$3:C62,C62)<COUNTIF(C:C,C62)),"",C62) | 60 | mst_machine | カラムに以下を追加<br>・装置名 | 変更 | YSK橋口 | 43066 | 1.0.0.0 | 「ベッド名」のカラム追加については仕様確定時に追加とする | ■ | 43070 | 43070 | - |
| =IF(OR(C63="",COUNTIF($C$3:C63,C63)<COUNTIF(C:C,C63)),"",C63) | 61 | mnt_gathering_manage | カラムに以下を追加<br>・利用者ID | 変更 | YSK橋口 | 43066 | 1.0.0.0 |  | ■ | 43070 | 43070 | - |
| =IF(OR(C64="",COUNTIF($C$3:C64,C64)<COUNTIF(C:C,C64)),"",C64) | 62 | mst_user | - | 新規 | YSK橋口 | 43066 | 1.0.0.0 |  | ■ | 43070 | 43070 | - |
| =IF(OR(C65="",COUNTIF($C$3:C65,C65)<COUNTIF(C:C,C65)),"",C65) | 63 | mnt_m_notice_manage | 以下のカラムの「NOT NULL」制約を削除<br>・型式コード<br>・通信フォーマット<br>・製造番号<br>・施設コード<br>・装置記録コード | 変更 | YSK橋口 | 43069 | 1.0.0.0 |  | =IFERROR(IF(C65=VLOOKUP(C65,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C65&"!A1","■"),""),"") | 43070 | 43070 |  |
| =IF(OR(C66="",COUNTIF($C$3:C66,C66)<COUNTIF(C:C,C66)),"",C66) | 64 | mnt_m_notice_manage | 桁数変更 | 変更 | YSK橋口 | 43069 | 1.0.0.0 | 装置記録補助データ : 50バイト ⇒ 256バイト | =IFERROR(IF(C66=VLOOKUP(C66,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C66&"!A1","■"),""),"") | 43070 | 43070 |  |
| =IF(OR(C67="",COUNTIF($C$3:C67,C67)<COUNTIF(C:C,C67)),"",C67) | 65 | mst_machine_record | 以下のカラムの「NOT NULL」制約を削除<br>・装置記録メッセージ | 変更 | YSK橋口 | 43069 | 1.0.0.0 |  | ■ | 43069 | 43069 | 43441 |
| =IF(OR(C68="",COUNTIF($C$3:C68,C68)<COUNTIF(C:C,C68)),"",C68) | 66 | mst_machine_type | カラムに以下を追加<br>・メーカー | 変更 | YSK橋口 | 43069 | 1.0.0.0 |  | ■ | 43073 | 43073 | - |
| mst_m_notice | 67 | mst_m_notice | 以下のカラムの備考に入力上限を記載<br>・装置記録メッセージ | 変更 | YSK橋口 | 43074 | 1.0.0.0 | 「医器工V4等（新規登録時）：任意の文字列」に「50バイト上限」の内容を追記 | ■ | 43074 | 43074 | 43441 |
| =IF(OR(C70="",COUNTIF($C$3:C70,C70)<COUNTIF(C:C,C70)),"",C70) | 68 | mst_machine_type | 以下のカラムを削除<br>・通信種別 | 変更 | YSK橋口 | 43076 | 1.0.0.0 | mst_machine_typeからmst_machineへ移行 | ■ | 43082 | 43082 | - |
| =IF(OR(C71="",COUNTIF($C$3:C71,C71)<COUNTIF(C:C,C71)),"",C71) | 69 | mst_machine | カラムに以下を追加<br>・通信種別 | 変更 | YSK橋口 | 43076 | 1.0.0.0 | mst_machine_typeからmst_machineへ移行 | ■ | 43082 | 43082 | - |
| =IF(OR(C72="",COUNTIF($C$3:C72,C72)<COUNTIF(C:C,C72)),"",C72) | 70 | mnt_m_notice_manage | 桁数変更 | 変更 | YSK橋口 | 43081 | 1.0.0.0 | 備考 : 256バイト ⇒ 4000バイト | =IFERROR(IF(C72=VLOOKUP(C72,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C72&"!A1","■"),""),"") | 43082 | 43082 |  |
| =IF(OR(C73="",COUNTIF($C$3:C73,C73)<COUNTIF(C:C,C73)),"",C73) | 71 | mst_facility | カラムに以下を追加<br>・死活監視間隔 | 変更 | YSK橋口 | 43117 | 1.0.0.0 |  | ■ | 43130 | 43130 | - |
| =IF(OR(C74="",COUNTIF($C$3:C74,C74)<COUNTIF(C:C,C74)),"",C74) | 72 | mnt_device_edge_state | - | 新規 | YSK橋口 | 43117 | 1.0.0.0 |  | ■ | 43130 | 43130 | - |
| =IF(OR(C75="",COUNTIF($C$3:C75,C75)<COUNTIF(C:C,C75)),"",C75) | 73 | mnt_machine_state | - | 新規 | YSK橋口 | 43117 | 1.0.0.0 |  | ■ | 43130 | 43130 | - |
| mnt_alive_moni_manage | 74 | mnt_alive_moni_manage | テーブル削除<br>※死活監視では下記テーブル使用の為<br>mnt_device_edge_state<br>mnt_machine_state | 変更 | YSK橋口 | 43188 | 1.0.0.0 |  | =IFERROR(IF(C76=VLOOKUP(C76,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C76&"!A1","■"),""),"") | - | - |  |
| =IF(OR(C77="",COUNTIF($C$3:C77,C77)<COUNTIF(C:C,C77)),"",C77) | 75 | mnt_m_notice_manage | カラムに以下を追加<br>・デバイスエッジ番号 | 変更 | YSK橋口 | 43188 | 1.0.0.0 | 2018/3/22打合せ内容反映<br>※デバイスエッジ死活監視関連 | =IFERROR(IF(C77=VLOOKUP(C77,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C77&"!A1","■"),""),"") | 43188 | × |  |
| =IF(OR(C78="",COUNTIF($C$3:C78,C78)<COUNTIF(C:C,C78)),"",C78) | 76 | mnt_m_notice_manage | 誤記修正<br>・デバイスエッジ番号の「NOT NULL」制約を削除 | 変更 | YSK橋口 | 43189 | 1.0.0.0 |  | =IFERROR(IF(C78=VLOOKUP(C78,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C78&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C79="",COUNTIF($C$3:C79,C79)<COUNTIF(C:C,C79)),"",C79) | 77 | mst_user | 以下のカラムの備考内容を修正<br>・利用者ID（内部用ID） | 変更 | YSK橋口 | 2018/3/30<br>2018/4/5<br>⇒2018/12/10：変更履歴の誤記修正 | 1.0.0.0 | 2018/4/4打合せ内容反映<br>※稼働ビューア関連<br>⇒2018/12/10：変更履歴の誤記修正 | ■ | - | - | - |
| =IF(OR(C80="",COUNTIF($C$3:C80,C80)<COUNTIF(C:C,C80)),"",C80) | 78 | mst_machine | テーブルのカラム順を変更<br>①施設コード<br>②型式コード<br>③製造番号 | 変更 | YSK橋口 | 43189 | 1.0.0.0 | 2018/3/22打合せ内容反映 | ■ | - | - | - |
| mnt_m_notice_manage | 79 | mnt_m_notice_manage | テーブルのカラム順を変更<br>①施設コード<br>②デバイスエッジ番号<br>③型式コード<br>④製造番号<br>⑤通信フォーマット | 変更 | YSK橋口 | 43189 | 1.0.0.0 | 2018/3/22打合せ内容反映 | =IFERROR(IF(C81=VLOOKUP(C81,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C81&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C82="",COUNTIF($C$3:C82,C82)<COUNTIF(C:C,C82)),"",C82) | 80 | mst_device_edge | テーブルのカラム順を変更<br>①施設コード<br>②デバイスエッジ番号 | 変更 | YSK橋口 | 43189 | 1.0.0.0 | 2018/3/22打合せ内容反映 | ■ | - | - | - |
| =IF(OR(C83="",COUNTIF($C$3:C83,C83)<COUNTIF(C:C,C83)),"",C83) | 81 | sys_system_define | テーブルのカラム順を変更<br>①施設コード<br>②管理番号 | 変更 | YSK橋口 | 43189 | 1.0.0.0 | 2018/3/22打合せ内容反映 | ■ | - | - | - |
| =IF(OR(C84="",COUNTIF($C$3:C84,C84)<COUNTIF(C:C,C84)),"",C84) | 82 | mnt_gathering_manage | テーブルのカラム順を変更<br>①施設コード<br>②データ収集ステータス | 変更 | YSK橋口 | 43189 | 1.0.0.0 | 2018/3/22打合せ内容反映 | ■ | - | - | 43441 |
| =IF(OR(C85="",COUNTIF($C$3:C85,C85)<COUNTIF(C:C,C85)),"",C85) | 83 | mnt_device_edge_state | テーブルのカラム順を変更<br>①施設コード<br>②デバイスエッジ番号 | 変更 | YSK橋口 | 43189 | 1.0.0.0 | 2018/3/22打合せ内容反映 | ■ | - | - | - |
| =IF(OR(C86="",COUNTIF($C$3:C86,C86)<COUNTIF(C:C,C86)),"",C86) | 84 | mnt_machine_state | テーブルのカラム順を変更<br>①施設コード<br>②型式コード<br>③製造番号 | 変更 | YSK橋口 | 43189 | 1.0.0.0 | 2018/3/22打合せ内容反映 | ■ | - | - | - |
| =IF(OR(C87="",COUNTIF($C$3:C87,C87)<COUNTIF(C:C,C87)),"",C87) | 85 | mnt_device_edge_state | 以下のカラムの備考内容を修正<br>・死活監視ステータス | 変更 | YSK橋口 | 43189 | 1.0.0.0 | 2018/3/22打合せ内容反映 | ■ | - | - | - |
| =IF(OR(C88="",COUNTIF($C$3:C88,C88)<COUNTIF(C:C,C88)),"",C88) | 86 | mst_machine_type | カラムに以下を追加<br>・機種 | 変更 | YSK橋口 | 43195 | 1.0.0.0 | 2018/4/4打合せ内容反映<br>※稼働ビューア関連 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | 43441 |
| =IF(OR(C89="",COUNTIF($C$3:C89,C89)<COUNTIF(C:C,C89)),"",C89) | 87 | mnt_machine_state | 以下のカラムを削除<br>・死活監視ステータス<br>以下のカラムを追加<br>・機種<br>・装置名<br>・ベッドコード<br>・ベッド名<br>・工程状態<br>・緊急発報有無<br>・予防保守有無<br>・通信不良有無<br>・部品運転時間<br>補足情報として以下のシートを追加<br>@mnt_machine_state<br>@@mnt_machine_state | 変更 | YSK橋口 | 43195 | 1.0.0.0 | 2018/4/4打合せ内容反映<br>※稼働ビューア関連 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C90="",COUNTIF($C$3:C90,C90)<COUNTIF(C:C,C90)),"",C90) | 88 | mnt_motion_record | 以下のテーブル名から変更<br>・mnt_m_notice_manage<br>以下のカラム名を変更<br>・緊急発報管理番号<br>　→装置動作記録番号<br>以下のカラムから「NOT NULL」制約を削除<br>・緊急発報ステータス<br>以下のカラムを追加<br>・データ種別<br>・自己診断種別<br>・データ収集管理番号<br>・内容<br>・対処<br>・対処者<br>以下のカラムの備考内容を修正<br>・装置記録コード<br>・装置記録メッセージ<br>・装置記録補助データ<br>補足情報として以下のシートを追加<br>@mnt_motion_record<br>@@mnt_motion_record | 変更 | YSK橋口 | 43195 | 1.0.0.0 | 2018/3/29mnt_m_notice_manageの格上げ内容反映<br>2018/4/4打合せ内容反映<br>※稼働ビューア関連 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C91="",COUNTIF($C$3:C91,C91)<COUNTIF(C:C,C91)),"",C91) | 89 | mst_facility | 以下のカラムを追加<br>・都道府県コード<br>・部署符号 | 変更 | YSK橋口 | 43195 | 1.0.0.0 | 2018/4/4打合せ内容反映<br>※稼働ビューア関連 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C92="",COUNTIF($C$3:C92,C92)<COUNTIF(C:C,C92)),"",C92) | 90 | sys_system_define | 補足情報として以下のシートを追加<br>@sys_system_define | 変更 | YSK橋口 | 43195 | 1.0.0.0 | 2018/4/4打合せ内容反映<br>※稼働ビューア関連 | ■ | - | - | - |
| =IF(OR(C93="",COUNTIF($C$3:C93,C93)<COUNTIF(C:C,C93)),"",C93) | 91 | mst_staff_facility | - | 新規 | YSK橋口 | 43195 | 1.0.0.0 | 2018/3/27打合せ内容反映<br>※稼働ビューア関連 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C94="",COUNTIF($C$3:C94,C94)<COUNTIF(C:C,C94)),"",C94) | 92 | - | 以下のシート間のハイパーリンクを貼り付け<br>・一覧<br>・各テーブル | - | YSK橋口 | 43199 | - | 2018/04/09電話打合せ内容反映 | =IFERROR(IF(C94=VLOOKUP(C94,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C94&"!A1","■"),""),"") | - | - |  |
| =IF(OR(C95="",COUNTIF($C$3:C95,C95)<COUNTIF(C:C,C95)),"",C95) | 93 | mnt_machine_state | 以下のカラムを件数管理とする<br>※型は「数値」、論理名は「xx件数」、物理名は「is_」を削除し「_cnt」を付与する<br>※通信不良有無：is_preventive_mainteは型のみ「数値」に変更する<br>・緊急発報有無：is_m_notice<br>・緊急発報有無：is_preventive_mainte | 変更 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※稼働ビューア関連 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C96="",COUNTIF($C$3:C96,C96)<COUNTIF(C:C,C96)),"",C96) | 94 | mnt_motion_record | 「@@mnt_motion_record」に以下を追記<br>・各項目の下記情報は「イベント発生日時」カラムと同じ内容のため格納しない<br>※測定年、測定月日、測定時分 | 変更 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※稼働ビューア関連 | ■ | - | - | - |
| =IF(OR(C97="",COUNTIF($C$3:C97,C97)<COUNTIF(C:C,C97)),"",C97) | 95 | pat_main | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | ■ | 43258 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C98="",COUNTIF($C$3:C98,C98)<COUNTIF(C:C,C98)),"",C98) | 96 | pat_event | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | ■ | 43258 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C99="",COUNTIF($C$3:C99,C99)<COUNTIF(C:C,C99)),"",C99) | 97 | pat_obs_rec | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | ■ | 43258 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C100="",COUNTIF($C$3:C100,C100)<COUNTIF(C:C,C100)),"",C100) | 98 | pat_prescription | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | ■ | × | × |  |
| =IF(OR(C101="",COUNTIF($C$3:C101,C101)<COUNTIF(C:C,C101)),"",C101) | 99 | pat_prescription_detail | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | ■ | × | × |  |
| =IF(OR(C102="",COUNTIF($C$3:C102,C102)<COUNTIF(C:C,C102)),"",C102) | 100 | ord_main | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | ■ | 43258 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C103="",COUNTIF($C$3:C103,C103)<COUNTIF(C:C,C103)),"",C103) | 101 | ord_cond | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | =IFERROR(IF(C103=VLOOKUP(C103,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C103&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C104="",COUNTIF($C$3:C104,C104)<COUNTIF(C:C,C104)),"",C104) | 102 | ord_medi | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | =IFERROR(IF(C104=VLOOKUP(C104,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C104&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C105="",COUNTIF($C$3:C105,C105)<COUNTIF(C:C,C105)),"",C105) | 103 | ord_vital | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | ■ | 43258 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C106="",COUNTIF($C$3:C106,C106)<COUNTIF(C:C,C106)),"",C106) | 104 | mst_die | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | =IFERROR(IF(C106=VLOOKUP(C106,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C106&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C107="",COUNTIF($C$3:C107,C107)<COUNTIF(C:C,C107)),"",C107) | 105 | mst_ward | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | ■ | × | × |  |
| =IF(OR(C108="",COUNTIF($C$3:C108,C108)<COUNTIF(C:C,C108)),"",C108) | 106 | mst_set_medicine | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | =IFERROR(IF(C108=VLOOKUP(C108,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C108&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C109="",COUNTIF($C$3:C109,C109)<COUNTIF(C:C,C109)),"",C109) | 107 | sys_data_item | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※透析業務支援関連 | ■ | 43258 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C110="",COUNTIF($C$3:C110,C110)<COUNTIF(C:C,C110)),"",C110) | 108 | mni_monitor | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※生体モニタリング関連 | ■ | 43249 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C111="",COUNTIF($C$3:C111,C111)<COUNTIF(C:C,C111)),"",C111) | 109 | mst_bio_moni_frame_pattern | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※生体モニタリング関連 | ■ | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C112="",COUNTIF($C$3:C112,C112)<COUNTIF(C:C,C112)),"",C112) | 110 | mst_frame_define | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※生体モニタリング関連 | ■ | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C113="",COUNTIF($C$3:C113,C113)<COUNTIF(C:C,C113)),"",C113) | 111 | mst_moni_item | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※生体モニタリング関連 | ■ | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C114="",COUNTIF($C$3:C114,C114)<COUNTIF(C:C,C114)),"",C114) | 112 | mst_bed_group | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※生体モニタリング関連 | =IFERROR(IF(C114=VLOOKUP(C114,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C114&"!A1","■"),""),"") | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C115="",COUNTIF($C$3:C115,C115)<COUNTIF(C:C,C115)),"",C115) | 113 | mst_bed | - | 新規 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※生体モニタリング関連 | ■ | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C116="",COUNTIF($C$3:C116,C116)<COUNTIF(C:C,C116)),"",C116) | 114 | mnt_machine_state | 生体モニタリング検討内容反映 | 変更 | YSK橋口 | 43207 | 1.0.0.0 | 2018/4/17電話打合せ内容反映<br>※生体モニタリング関連 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C117="",COUNTIF($C$3:C117,C117)<COUNTIF(C:C,C117)),"",C117) | 115 | mni_monitor | カラムに以下を追加<br>・通信フォーマット<br>以下のカラムを変更<br>・「透析番号」→「オーダ番号」<br>以下のカラムの「型」を変更<br>・生体モニタリング管理番号<br>　※「bigint」→「bigserial」<br>「@mni_monitor」に最新の通信仕様書の内容を反映 | 変更 | YSK橋口 | 43209 | 1.0.0.0 | 2018/4/19メール内容反映<br>※稼働ビューア、生体モニタリング関連 | ■ | 43249 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C118="",COUNTIF($C$3:C118,C118)<COUNTIF(C:C,C118)),"",C118) | 116 | mnt_machine_state | 以下のカラムの「備考」内容を修正<br>・装置ステータス<br>以下のカラムを削除<br>・最終確認日時<br>・送信前患者ID<br>・透析記録確認日時<br>・生体モニタリング管理番号 | 変更 | YSK橋口 | 43209 | 1.0.0.0 | 2018/4/19メール内容反映<br>※稼働ビューア、生体モニタリング関連 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C119="",COUNTIF($C$3:C119,C119)<COUNTIF(C:C,C119)),"",C119) | 117 | ord_main | 以下のカラムを変更<br>・「ベッド番号」→「ベッドコード」<br>以下のカラムのキー情報を変更<br>・透析実績情報に「条件送信確認日時」追加 | 変更 | YSK橋口 | 43209 | 1.0.0.0 | 2018/4/19メール内容反映<br>※生体モニタリング関連 | ■ | 43258 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C120="",COUNTIF($C$3:C120,C120)<COUNTIF(C:C,C120)),"",C120) | 118 | mst_machine | カラムに以下を追加<br>・装置番号 | 変更 | YSK橋口 | 43209 | 1.0.0.0 | 2018/4/19メール内容反映<br>※生体モニタリング関連 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C121="",COUNTIF($C$3:C121,C121)<COUNTIF(C:C,C121)),"",C121) | 119 | mni_monitor | 以下のカラムを削除<br>・通信フォーマット<br>・版番号<br>以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | 43249 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C122="",COUNTIF($C$3:C122,C122)<COUNTIF(C:C,C122)),"",C122) | 120 | mnt_machine_state | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C123="",COUNTIF($C$3:C123,C123)<COUNTIF(C:C,C123)),"",C123) | 121 | pat_main | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | 43258 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C124="",COUNTIF($C$3:C124,C124)<COUNTIF(C:C,C124)),"",C124) | 122 | pat_event | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | 43258 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C125="",COUNTIF($C$3:C125,C125)<COUNTIF(C:C,C125)),"",C125) | 123 | pat_obs_rec | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | 43258 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C126="",COUNTIF($C$3:C126,C126)<COUNTIF(C:C,C126)),"",C126) | 124 | pat_prescription | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | × | × |  |
| =IF(OR(C127="",COUNTIF($C$3:C127,C127)<COUNTIF(C:C,C127)),"",C127) | 125 | ord_main | 以下の内容について、他テーブルに合わせる<br>・主キー(一意制約)<br>・NOT NULL制約<br>・デフォルト設定 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | 43258 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C128="",COUNTIF($C$3:C128,C128)<COUNTIF(C:C,C128)),"",C128) | 126 | ord_cond | 以下の内容について、他テーブルに合わせる<br>・主キー(一意制約)<br>・NOT NULL制約<br>・デフォルト設定 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | =IFERROR(IF(C128=VLOOKUP(C128,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C128&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C129="",COUNTIF($C$3:C129,C129)<COUNTIF(C:C,C129)),"",C129) | 127 | ord_medi | 以下の内容について、他テーブルに合わせる<br>・主キー(一意制約)<br>・NOT NULL制約<br>・デフォルト設定 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | =IFERROR(IF(C129=VLOOKUP(C129,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C129&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C130="",COUNTIF($C$3:C130,C130)<COUNTIF(C:C,C130)),"",C130) | 128 | ord_vital | 以下の内容について、他テーブルに合わせる<br>・主キー(一意制約)<br>・NOT NULL制約<br>・デフォルト設定<br>以下のカラム名を変更<br>・実績番号→管理番号 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | 43258 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C131="",COUNTIF($C$3:C131,C131)<COUNTIF(C:C,C131)),"",C131) | 129 | mst_user | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C132="",COUNTIF($C$3:C132,C132)<COUNTIF(C:C,C132)),"",C132) | 130 | mst_die | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | =IFERROR(IF(C132=VLOOKUP(C132,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C132&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C133="",COUNTIF($C$3:C133,C133)<COUNTIF(C:C,C133)),"",C133) | 131 | mst_ward | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | × | × |  |
| mst_set_medicine | 132 | mst_set_medicine | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | =IFERROR(IF(C134=VLOOKUP(C134,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C134&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C135="",COUNTIF($C$3:C135,C135)<COUNTIF(C:C,C135)),"",C135) | 133 | mst_bio_moni_frame_pattern | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定<br>以下のカラム名を変更<br>・発生日時→登録日時 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C136="",COUNTIF($C$3:C136,C136)<COUNTIF(C:C,C136)),"",C136) | 134 | mst_frame_define | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定<br>以下のカラム名を変更<br>・発生日時→登録日時 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C137="",COUNTIF($C$3:C137,C137)<COUNTIF(C:C,C137)),"",C137) | 135 | mst_moni_item | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定<br>以下のカラム名を変更<br>・発生日時→登録日時 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C138="",COUNTIF($C$3:C138,C138)<COUNTIF(C:C,C138)),"",C138) | 136 | mst_bed_group | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定<br>以下のカラム名を変更<br>・発生日時→登録日時<br>・ベッドコード→ベッド一覧 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | =IFERROR(IF(C138=VLOOKUP(C138,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C138&"!A1","■"),""),"") | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C139="",COUNTIF($C$3:C139,C139)<COUNTIF(C:C,C139)),"",C139) | 137 | mst_bed | 以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定<br>以下のカラム名を変更<br>・発生日時→登録日時 | 変更 | YSK橋口 | 43216 | 1.0.0.0 | 2018/4/25打合せ内容反映 | ■ | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C140="",COUNTIF($C$3:C140,C140)<COUNTIF(C:C,C140)),"",C140) | 138 | mst_frame_define | 以下のカラムの「型」を変更<br>・フレーム定義<br>　※「character varying」→「jsonb」 | 変更 | YSK橋口 | 43227 | 1.0.0.0 | 2018/4/26メール依頼内容反映 | ■ | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C141="",COUNTIF($C$3:C141,C141)<COUNTIF(C:C,C141)),"",C141) | 139 | mnt_client_connect | - | 新規 | YSK橋口 | 43227 | 1.0.0.0 | 2018/4/26メール依頼内容反映 | ■ | 43249 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C142="",COUNTIF($C$3:C142,C142)<COUNTIF(C:C,C142)),"",C142) | 140 | mnt_machine_state | 以下のシートの誤記を修正<br>「@mnt_machine_state」<br>「@@mnt_machine_state」 | 変更 | YSK橋口 | 43227 | 1.0.0.0 | 2018/4/27メール依頼内容反映 | ■ | - | - | - |
| mst_prefectures | 141 | mst_prefectures | - | 新規 | ESM高原 | 43243 | 1.0.0.0 | 稼働ビューア対応 | =IFERROR(IF(C143=VLOOKUP(C143,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C143&"!A1","■"),""),"") | 43245 | × |  |
| =IF(OR(C144="",COUNTIF($C$3:C144,C144)<COUNTIF(C:C,C144)),"",C144) | 142 | mst_user | 以下のカラムを削除<br>・利用者名<br>以下のカラムを追加<br>・パスワード<br>・利用者名_姓<br>・利用者名_名<br>・利用者カナ名_姓<br>・利用者カナ名_名<br>・利用者英字名_姓<br>・利用者英字名_名<br>・メールアドレス1<br>・メールアドレス2<br>・内線番号<br>・自宅番号<br>・携帯番号<br>・FAX番号<br>・郵便番号3<br>・郵便番号4<br>・自宅住所<br>・自宅住所かな<br>・仮登録フラグ<br>・職種コード<br>・メニュー表示フラグ | 変更 | ESM高原 | 43243 | 1.0.0.0 | 稼働ビューア対応 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C145="",COUNTIF($C$3:C145,C145)<COUNTIF(C:C,C145)),"",C145) | 143 | mst_facility | 以下のカラムを追加<br>・施設カナ名<br>・認証キー<br>・使用可能機能 | 変更 | ESM高原 | 43243 | 1.0.0.0 | 稼働ビューア対応 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C146="",COUNTIF($C$3:C146,C146)<COUNTIF(C:C,C146)),"",C146) | 144 | mnt_machine_state | 以下のカラムの型を定義<br>・次患者ID<br>・次患者クールCD<br>・透析開始予定日時<br>・透析終了予定日時<br>・前体重測定日時<br>・条件送信日時<br>・条件確認日時<br>・透析開始日時<br>・透析終了日時<br>・後体重測定日時 | 変更 | YSK橋口 | 43245 | 1.0.0.0 | 記載漏れ反映 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| sys_prefectures | 145 | sys_prefectures | 以下のテーブル名から変更<br>・mst_prefectures | 変更 | YSK橋口 | 43245 | 1.0.0.0 | 2018/5/25メール依頼内容反映 | ■ | 43245 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | 43441 |
| =IF(OR(C148="",COUNTIF($C$3:C148,C148)<COUNTIF(C:C,C148)),"",C148) | 146 | mni_monitor | 以下のカラムを追加<br>・患者ID | 変更 | YSK橋口 | 43248 | 1.0.0.0 | 2018/5/22打合せ内容反映<br>※生体モニタリング.pptx | ■ | 43249 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C149="",COUNTIF($C$3:C149,C149)<COUNTIF(C:C,C149)),"",C149) | 147 | mnt_machine_state | 以下のカラムを追加<br>・次回透析オーダ番号 | 変更 | YSK橋口 | 43248 | 1.0.0.0 | 2018/5/22打合せ内容反映<br>※生体モニタリング.pptx | ■ | 43249 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | - |
| =IF(OR(C150="",COUNTIF($C$3:C150,C150)<COUNTIF(C:C,C150)),"",C150) | 148 | - | 以下のシート名を変更<br>「一覧」→「テーブル一覧」<br>以下のシートを追加<br>「テーブル参照」 | 追加 | YSK橋口 | 43248 | 1.0.0.0 |  | =IFERROR(IF(C150=VLOOKUP(C150,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C150&"!A1","■"),""),"") | - | - | - |
| =IF(OR(C151="",COUNTIF($C$3:C151,C151)<COUNTIF(C:C,C151)),"",C151) | 149 | - | 以下のシートを追加<br>「ファンクション一覧」 | 追加 | YSK橋口 | 43249 | 1.0.0.0 |  | =IFERROR(IF(C151=VLOOKUP(C151,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C151&"!A1","■"),""),"") | - | - | - |
| ms_string_format() | 150 | ms_string_format() | - | 追加 | YSK橋口 | 43249 | 1.0.0.0 | 2018/5/29メール依頼内容反映 | =IFERROR(IF(C152=VLOOKUP(C152,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C152&"!A1","■"),""),"") | 43249 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | 43442 |
| build_machine_record_message() | 151 | build_machine_record_message() | - | 追加 | YSK橋口 | 43249 | 1.0.0.0 | 2018/5/29メール依頼内容反映 | =IFERROR(IF(C153=VLOOKUP(C153,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C153&"!A1","■"),""),"") | 43249 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | 43442 |
| =IF(OR(C154="",COUNTIF($C$3:C154,C154)<COUNTIF(C:C,C154)),"",C154) | 152 | mst_bio_moni_frame_pattern | 以下のカラムを追加<br>・フレーム種別 | 変更 | YSK橋口 | 43252 | 1.0.0.0 | 2018/5/31メール依頼内容反映 | ■ | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| tg_sync_mst_machine | 153 | tg_sync_mst_machine | - | 追加 | YSK橋口 | 43252 | 1.0.0.0 | 2018/5/31依頼内容反映 | =IFERROR(IF(C155=VLOOKUP(C155,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C155&"!A1","■"),""),"") | 43255 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | 43442 |
| tg_sync_mnt_motion_record | 154 | tg_sync_mnt_motion_record | - | 追加 | YSK橋口 | 43252 | 1.0.0.0 | 2018/5/31依頼内容反映 | =IFERROR(IF(C156=VLOOKUP(C156,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C156&"!A1","■"),""),"") | 43255 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | 43442 |
| =IF(OR(C157="",COUNTIF($C$3:C157,C157)<COUNTIF(C:C,C157)),"",C157) | 155 | - | 以下のシートを追加<br>「トリガー一覧」 | 追加 | YSK橋口 | 43252 | 1.0.0.0 |  | =IFERROR(IF(C157=VLOOKUP(C157,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C157&"!A1","■"),""),"") | - | - | - |
| =IF(OR(C158="",COUNTIF($C$3:C158,C158)<COUNTIF(C:C,C158)),"",C158) | 156 | - | 以下のシートを修正<br>「テーブル参照」 | 変更 | YSK橋口 | 43252 | 1.0.0.0 |  | =IFERROR(IF(C158=VLOOKUP(C158,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C158&"!A1","■"),""),"") | - | - |  |
| =IF(OR(C159="",COUNTIF($C$3:C159,C159)<COUNTIF(C:C,C159)),"",C159) | 157 | mst_moni_item | 以下のカラムの桁数を変更<br>・最小値 : 2,0 ⇒ 10,2<br>以下のカラムの誤記修正<br>・表示順　※不要なデフォルト値削除 | 変更 | YSK橋口 | 43256 | 1.0.0.0 | 2018/6/5メール依頼内容反映 | ■ | 43256 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C160="",COUNTIF($C$3:C160,C160)<COUNTIF(C:C,C160)),"",C160) | 158 | - | 以下のシートを修正<br>「テーブル参照」 | 変更 | YSK橋口 | 43258 | 1.0.0.0 | 2018/6/7メール依頼内容反映 | =IFERROR(IF(C160=VLOOKUP(C160,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C160&"!A1","■"),""),"") | - | - |  |
| =IF(OR(C161="",COUNTIF($C$3:C161,C161)<COUNTIF(C:C,C161)),"",C161) | 159 | - | 以下のシートを修正<br>「テーブル参照」 | 変更 | YSK橋口 | 43263 | 1.0.0.0 | 2018/6/12依頼内容反映 | =IFERROR(IF(C161=VLOOKUP(C161,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C161&"!A1","■"),""),"") | - | - |  |
| =IF(OR(C162="",COUNTIF($C$3:C162,C162)<COUNTIF(C:C,C162)),"",C162) | 160 | sys_data_item | 以下のカラムを追加<br>・施設コード<br>・テンプレート番号 | 変更 | YSK橋口 | 43269 | 1.0.0.0 | 2018/6/18メール依頼内容反映<br>※患者経過総合ビューア関連 | ■ | 43271 | 2018/6/24<br>※仮スキーマに適用<br>(ntss_provisional) |  |
| =IF(OR(C163="",COUNTIF($C$3:C163,C163)<COUNTIF(C:C,C163)),"",C163) | 161 | - | 以下のシートを修正<br>「テーブル参照」 | 変更 | YSK橋口 | 43276 | 1.0.0.0 | 2018/6/25依頼内容反映<br>※患者経過総合ビューア関連 | =IFERROR(IF(C163=VLOOKUP(C163,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C163&"!A1","■"),""),"") | - | - |  |
| =IF(OR(C164="",COUNTIF($C$3:C164,C164)<COUNTIF(C:C,C164)),"",C164) | 162 | mnt_motion_record | 以下のカラムの備考にデータ収集時のメッセージ内容を追加<br>・装置記録メッセージ | 追加 | YSK櫨木 | 43287 | 1.0.0.0 |  | ■ | - | - | - |
| =IF(OR(C165="",COUNTIF($C$3:C165,C165)<COUNTIF(C:C,C165)),"",C165) | 163 | mnt_motion_record | 以下のカラムの備考にデータ収集時の格納情報を追加<br>・内容 | 追加 | YSK櫨木 | 43287 | 1.0.0.0 |  | ■ | - | - | - |
| =IF(OR(C166="",COUNTIF($C$3:C166,C166)<COUNTIF(C:C,C166)),"",C166) | 164 | ord_main | 以下のカラムを削除<br>・同日複数回<br>・予定作成区分<br>・サイクル週数<br>・クール更新日時<br>・ダミーフラグ<br>・施設コード更新日時<br>・ベッド更新日時<br>・患者情報<br>・透析実績情報<br>・体重・血圧情報<br>以下のカラムを追加<br>・装置名<br>・治療状況<br>・透析実績バイタル情報<br>・透析実績愁訴情報<br>・透析実績愁訴処置情報<br>・透析実績愁訴処置者情報<br>・透析実績体重情報<br>・回診記録情報<br>・患者情報・実績情報内のJSONキーを<br>　カラムとして分離<br>以下の通り変更<br>・クールコード・クール名・ベッド番号・ベッド名・治療方法コードを指示と実績でそれぞれ別カラムとした<br>・版番号のPKを外した<br>・VAコード → VA方向<br>・マスタのUPDATEを全て削除 | 変更 | YSK伊藤(雅) | 43355 | 1.0.0.0 | 2018/09/05 ～ 2018/09/07 打ち合わせ検討内容反映 | ■ | × | × |  |
| =IF(OR(C167="",COUNTIF($C$3:C167,C167)<COUNTIF(C:C,C167)),"",C167) | 165 | pat_main | ■以下のカラムを追加<br>・重症度コード<br>・搬送区分コード<br>・業者連絡先情報<br>・身体情報<br>■以下のカラムを変更<br>・死因情報<br>・透析困難コメント情報<br>・フリーコメント情報<br>■以下のカラムのJSONキーを変更<br>・レセプトメモ<br>・診療科情報<br>・担当スタッフ情報<br>・患者グループ情報<br>・禁忌情報<br>・感染症情報<br>・禁忌情報<br>・病歴情報<br>■患者氏名カラムを姓と名に分割 | 変更 | YSK伊藤(雅) | 43379 | 1.0.0.0 | ・「TR-20180803-090183-XX-R0」の画面仕様を反映<br>・マスタ情報を含むJSONから更新日時と名称を削除<br>　(常に最新のマスタを参照するため)<br>・データがJSON配列で表示順の存在するカラムに"ctl_no"と"disp_order"を追加 | ■ | × | × |  |
| =IF(OR(C168="",COUNTIF($C$3:C168,C168)<COUNTIF(C:C,C168)),"",C168) | 166 | ord_main | ■指示・実績で保持している項目を明確にするたために、名称に「指示(ind)」「実績(rst)」と付ける<br>■治療記録の画面で子機能として分類されている項目ごとにjson化 | 変更 | YSK櫨木 | 43389 | 1.0.0.0 |  | ■ | × | × |  |
| =IF(OR(C169="",COUNTIF($C$3:C169,C169)<COUNTIF(C:C,C169)),"",C169) | 167 | pat_main | ■以下のカラムを変更<br>・透析困難コメント情報<br>・レセプトメモ情報<br>■以下のカラムのJSONキーを変更<br>・緊急連絡先情報<br>・業者連絡先情報 | 変更 | YSK伊藤(雅) | 43389 | 1.0.0.0 |  | ■ | × | × |  |
| =IF(OR(C170="",COUNTIF($C$3:C170,C170)<COUNTIF(C:C,C170)),"",C170) | 168 | mst_dialysis_difficulty | テーブル追加 | 新規 | YSK伊藤(雅) | 43390 | 1.0.0.0 | 患者情報関連機能で使用 | ■ | × | × |  |
| =IF(OR(C171="",COUNTIF($C$3:C171,C171)<COUNTIF(C:C,C171)),"",C171) | 169 | mst_injury | テーブル追加 | 新規 | YSK橋口 | 43392 | 1.0.0.0 | 患者情報関連機能で使用 | =IFERROR(IF(C171=VLOOKUP(C171,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C171&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C172="",COUNTIF($C$3:C172,C172)<COUNTIF(C:C,C172)),"",C172) | 170 | mst_transport | テーブル追加 | 新規 | YSK橋口 | 43392 | 1.0.0.0 | 患者情報関連機能で使用 | ■ | × | × |  |
| =IF(OR(C173="",COUNTIF($C$3:C173,C173)<COUNTIF(C:C,C173)),"",C173) | 171 | mst_ward | 以下のカラムの桁を削除<br>・病棟名<br>以下のカラムを削除<br>・表示順<br>・表示フラグ | 変更 | YSK橋口 | 43392 | 1.0.0.0 | 患者情報関連機能で使用 | ■ | × | × |  |
| =IF(OR(C174="",COUNTIF($C$3:C174,C174)<COUNTIF(C:C,C174)),"",C174) | 172 | mst_dialyzer | テーブル追加 | 新規 | YSK中村 | 43392 | 1.0.0.0 | 指示関連機能で使用 | ■ | × | × |  |
| =IF(OR(C175="",COUNTIF($C$3:C175,C175)<COUNTIF(C:C,C175)),"",C175) | 173 | mst_va | テーブル追加 | 新規 | YSK中村 | 43392 | 1.0.0.0 | 指示関連機能で使用 | ■ | × | × |  |
| =IF(OR(C176="",COUNTIF($C$3:C176,C176)<COUNTIF(C:C,C176)),"",C176) | 174 | mst_machine | カラムに以下を追加<br>・設置日<br>・廃棄日<br>・バージョン<br>・装置オプション<br>・メモ<br>・使用不可フラグ<br>・モード<br>・TMP初期補正中点<br>・配管自己診断測定日時<br>・漏血テスト測定日時<br>・濃度自己診断測定日時<br>・透析液流量自己診断測定日時<br>・通信共通 自己診断実施日時<br>・自己診断情報<br>・接続供給装置の装置番号<br>・接続溶解装置の装置番号<br>・接続水処理装置の装置番号 | 変更 | YSK中村 | 43392 | 1.0.0.0 | 指示関連機能で使用<br>※2018/12/7：赤文字部分をYSK橋口追記 | ■ | × | × |  |
| =IF(OR(C177="",COUNTIF($C$3:C177,C177)<COUNTIF(C:C,C177)),"",C177) | 175 | mst_bed | ■カラム名変更<br>・装置番号 | 変更 | YSK中村 | 43392 | 1.0.0.0 | 指示関連機能で使用 | ■ | × | × |  |
| =IF(OR(C178="",COUNTIF($C$3:C178,C178)<COUNTIF(C:C,C178)),"",C178) | 176 | mst_room | テーブル追加 | 新規 | YSK中村 | 43392 | 1.0.0.0 | 指示関連機能で使用 | =IFERROR(IF(C178=VLOOKUP(C178,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C178&"!A1","■"),""),"") | - | - |  |
| =IF(OR(C179="",COUNTIF($C$3:C179,C179)<COUNTIF(C:C,C179)),"",C179) | 177 | mst_medicine | テーブル追加 | 新規 | YSK中村 | 43392 | 1.0.0.0 | 指示関連機能で使用 | ■ | × | × |  |
| =IF(OR(C180="",COUNTIF($C$3:C180,C180)<COUNTIF(C:C,C180)),"",C180) | 178 | mst_medicine_class | テーブル追加 | 新規 | YSK中村 | 43392 | 1.0.0.0 | 指示関連機能で使用 | ■ | × | × |  |
| =IF(OR(C181="",COUNTIF($C$3:C181,C181)<COUNTIF(C:C,C181)),"",C181) | 179 | mst_equipment | テーブル追加 | 新規 | YSK中村 | 43392 | 1.0.0.0 | 指示関連機能で使用 | ■ | × | × |  |
| =IF(OR(C182="",COUNTIF($C$3:C182,C182)<COUNTIF(C:C,C182)),"",C182) | 180 | mst_equipment_class | テーブル追加 | 新規 | YSK中村 | 43392 | 1.0.0.0 | 指示関連機能で使用 | ■ | × | × |  |
| =IF(OR(C183="",COUNTIF($C$3:C183,C183)<COUNTIF(C:C,C183)),"",C183) | 181 | mst_procedure | テーブル追加 | 新規 | YSK中村 | 43392 | 1.0.0.0 | 指示関連機能で使用 | ■ | × | × |  |
| =IF(OR(C184="",COUNTIF($C$3:C184,C184)<COUNTIF(C:C,C184)),"",C184) | 182 | mst_medicate_timing | テーブル追加 | 新規 | YSK中村 | 43392 | 1.0.0.0 | 指示関連機能で使用 | ■ | × | × |  |
| =IF(OR(C185="",COUNTIF($C$3:C185,C185)<COUNTIF(C:C,C185)),"",C185) | 183 | mst_taboo_allergy | テーブル追加 | 新規 | YSK中村 | 43392 | 1.0.0.0 | 患者情報関連機能で使用 | ■ | × | × |  |
| =IF(OR(C186="",COUNTIF($C$3:C186,C186)<COUNTIF(C:C,C186)),"",C186) | 184 | mst_treatment_set | テーブル追加 | 新規 | YSK中村 | 43392 | 1.0.0.0 | 指示関連機能で使用 | ■ | × | × |  |
| =IF(OR(C187="",COUNTIF($C$3:C187,C187)<COUNTIF(C:C,C187)),"",C187) | 185 | mst_kur | テーブル追加 | 新規 | YSK橋口 | 43392 | 1.0.0.0 | 指示関連機能で使用 | ■ | × | × |  |
| =IF(OR(C188="",COUNTIF($C$3:C188,C188)<COUNTIF(C:C,C188)),"",C188) | 186 | mst_dialysis_difficulty | 各カラムの名称を変更<br>・透析困難症→透析困難<br>透析困難コードの型を変更<br>・character varying→serial<br>以下のカラムを追加<br>・FNW+の透析困難コード<br>・表示フラグ | 変更 | YSK橋口 | 43398 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| mst_injury | 187 | mst_injury | 重症度コードの型を変更<br>・character varying→serial<br>以下のカラムを追加<br>・FNW+の重症度コード<br>・表示フラグ | 変更 | YSK橋口 | 43398 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | =IFERROR(IF(C189=VLOOKUP(C189,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C189&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C190="",COUNTIF($C$3:C190,C190)<COUNTIF(C:C,C190)),"",C190) | 188 | mst_transport | 搬送区分コードの型を変更<br>・character varying→serial<br>以下のカラムを追加<br>・FNW+の搬送区分コード<br>・表示フラグ | 変更 | YSK橋口 | 43398 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C191="",COUNTIF($C$3:C191,C191)<COUNTIF(C:C,C191)),"",C191) | 189 | mst_ward | 病棟コードの型を変更<br>・character varying→serial<br>以下のカラムを追加<br>・FNW+の病棟コード<br>・表示フラグ | 変更 | YSK橋口 | 43398 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C192="",COUNTIF($C$3:C192,C192)<COUNTIF(C:C,C192)),"",C192) | 190 | mst_course | テーブル追加 | 新規 | YSK橋口 | 43398 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C193="",COUNTIF($C$3:C193,C193)<COUNTIF(C:C,C193)),"",C193) | 191 | mst_standard_course | テーブル追加 | 新規 | YSK橋口 | 43398 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C194="",COUNTIF($C$3:C194,C194)<COUNTIF(C:C,C194)),"",C194) | 192 | mst_disease | テーブル追加 | 新規 | YSK橋口 | 43398 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C195="",COUNTIF($C$3:C195,C195)<COUNTIF(C:C,C195)),"",C195) | 193 | mst_standard_disease | テーブル追加 | 新規 | YSK橋口 | 43398 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C196="",COUNTIF($C$3:C196,C196)<COUNTIF(C:C,C196)),"",C196) | 194 | mst_infection | テーブル追加 | 新規 | YSK橋口 | 43399 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C197="",COUNTIF($C$3:C197,C197)<COUNTIF(C:C,C197)),"",C197) | 195 | mst_implant | テーブル追加 | 新規 | YSK橋口 | 43399 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C198="",COUNTIF($C$3:C198,C198)<COUNTIF(C:C,C198)),"",C198) | 196 | mst_taboo_allergy | 禁忌・アレルギーコードの型を変更<br>・character varying→serial<br>以下のカラムの名称を変更<br>・禁忌コード→禁忌・アレルギーコード<br>・禁忌名称→内容<br>・禁忌詳細→詳細<br>以下のカラムを追加<br>・FNW+の禁忌・アレルギーコード<br>・表示フラグ | 変更 | YSK橋口 | 43399 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C199="",COUNTIF($C$3:C199,C199)<COUNTIF(C:C,C199)),"",C199) | 197 | sys_country | テーブル追加 | 新規 | YSK橋口 | 43402 | 1.0.0.0 | 2018/10/26打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C200="",COUNTIF($C$3:C200,C200)<COUNTIF(C:C,C200)),"",C200) | 198 | mst_relationship | テーブル追加 | 新規 | YSK橋口 | 43402 | 1.0.0.0 | 2018/10/26打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C201="",COUNTIF($C$3:C201,C201)<COUNTIF(C:C,C201)),"",C201) | 199 | mst_severity | 以下のテーブル名から変更<br>・mst_injury | 変更 | YSK橋口 | 43402 | 1.0.0.0 | 2018/10/26打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C202="",COUNTIF($C$3:C202,C202)<COUNTIF(C:C,C202)),"",C202) | 200 | mst_pat_memo | テーブル追加 | 新規 | YSK橋口 | 43402 | 1.0.0.0 | 2018/10/26打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C203="",COUNTIF($C$3:C203,C203)<COUNTIF(C:C,C203)),"",C203) | 201 | mst_com_fixed_phrase | テーブル追加<br>※「@mst_com_fixed_phrase」も追加 | 新規 | YSK橋口 | 43402 | 1.0.0.0 | 2018/10/26打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C204="",COUNTIF($C$3:C204,C204)<COUNTIF(C:C,C204)),"",C204) | 202 | mst_va | VAコードの型を変更<br>・character varying→serial<br>以下のカラムを追加<br>・FNW+のVAコード<br>・表示フラグ<br>以下のカラムから「NOT NULL」制約を削除<br>・表示フラグ<br>・削除フラグ | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/25打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C205="",COUNTIF($C$3:C205,C205)<COUNTIF(C:C,C205)),"",C205) | 203 | mst_procedure | 手技コードの型を変更<br>・character varying→serial<br>以下のカラムを追加<br>・FNW+の手技コード<br>・表示フラグ<br>以下のカラムから「NOT NULL」制約を削除<br>・表示フラグ<br>・削除フラグ | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/25打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C206="",COUNTIF($C$3:C206,C206)<COUNTIF(C:C,C206)),"",C206) | 204 | mst_medicate_timing | 投与タイミングコードの型を変更<br>・character varying→serial<br>以下のカラムを追加<br>・FNW+の投与タイミングコード<br>・表示フラグ<br>以下のカラムから「NOT NULL」制約を削除<br>・表示フラグ<br>・削除フラグ | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/25打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C207="",COUNTIF($C$3:C207,C207)<COUNTIF(C:C,C207)),"",C207) | 205 | mst_dialyzer | ダイアライザコードの型を変更<br>・character varying→serial<br>以下のカラムを削除<br>・写真<br>・バーコード<br>・メモ<br>以下のカラムを追加<br>・FNW+のダイアライザコード<br>・入り数<br>・使用開始日<br>・使用終了日<br>・院内コード3<br>・表示フラグ<br>以下のカラムから「NOT NULL」制約を削除<br>・ダイアライザ種別<br>・血流量<br>・透析液流量<br>・尿素クリアランス<br>・ガスパージ時間<br>・置換洗浄量（透析液）<br>・膜洗浄（中空糸）<br>・表示フラグ<br>・削除フラグ | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/25打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C208="",COUNTIF($C$3:C208,C208)<COUNTIF(C:C,C208)),"",C208) | 206 | mst_equipment | 医療材料コードの型を変更<br>・character varying→serial<br>以下のカラムを削除<br>・メーカー<br>・型番<br>・写真<br>・バーコード<br>医療材料分類コードカラムの型を変更<br>・character varying→integer<br>以下のカラムを追加<br>・FNW+の医療材料コード<br>・標準医療材料コード<br>　※JANコード、JMDNコードなど<br>・治験フラグ<br>・省略医療材料名<br>・使用開始日<br>・使用終了日<br>・院内コード3<br>・表示フラグ<br>以下のカラムから「NOT NULL」制約を削除<br>・表示フラグ<br>・削除フラグ | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C209="",COUNTIF($C$3:C209,C209)<COUNTIF(C:C,C209)),"",C209) | 207 | mst_equipment_class | 分類コードの型を変更<br>・character varying→serial<br>以下のカラムを追加<br>・FNW+の分類コード<br>・分類区分<br>・表示フラグ<br>以下のカラムから「NOT NULL」制約を削除<br>・表示フラグ<br>・編集可否フラグ<br>・削除フラグ | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| mst_die | 208 | mst_die | テーブル削除 | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | =IFERROR(IF(C210=VLOOKUP(C210,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C210&"!A1","■"),""),"") | × | × |  |
| ord_cond | 209 | ord_cond | テーブル削除 | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | =IFERROR(IF(C211=VLOOKUP(C211,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C211&"!A1","■"),""),"") | × | × |  |
| ord_medi | 210 | ord_medi | テーブル削除 | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | =IFERROR(IF(C212=VLOOKUP(C212,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C212&"!A1","■"),""),"") | × | × |  |
| =IF(OR(C213="",COUNTIF($C$3:C213,C213)<COUNTIF(C:C,C213)),"",C213) | 211 | mst_medicine | 薬剤コードの型を変更<br>・character varying→serial<br>以下のカラムを削除<br>・規格単位<br>・一般名<br>・効果効能<br>・用法用量<br>・規制区分<br>・剤形<br>・標準コード<br>・厚生省コード<br>・医薬品HOTコード<br>・写真<br>・アイコン1<br>・アイコン2<br>・アイコン3<br>・メモ<br>・1回当りの使用量<br>・1日当りの回数<br>・連続使用期間<br>・バーコード<br>・短縮名<br>薬剤分類コードカラムの型を変更<br>・character varying→integer<br>以下のカラム名を変更<br>・有効期間下限→使用開始日<br>・有効期間上限→使用終了日<br>・有効成分→抗凝固剤元数量<br>・容量→抗凝固剤後数量<br>以下のカラムを追加<br>・FNW+の薬剤コード<br>・個別医薬品コード(YJコード)<br>・治験フラグ<br>・省略薬剤名<br>・単位(第2)<br>・単位換算量<br>・単位(第2)換算量<br>・院内コード3<br>・表示フラグ<br>以下のカラムから「NOT NULL」制約を削除<br>・表示フラグ<br>・削除フラグ | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C214="",COUNTIF($C$3:C214,C214)<COUNTIF(C:C,C214)),"",C214) | 212 | mst_medicine_class | 分類コードの型を変更<br>・character varying→serial<br>以下のカラムを追加<br>・FNW+の分類コード<br>・分類区分<br>・表示フラグ<br>以下のカラムから「NOT NULL」制約を削除<br>・表示フラグ<br>・編集可否フラグ<br>・削除フラグ | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C215="",COUNTIF($C$3:C215,C215)<COUNTIF(C:C,C215)),"",C215) | 213 | mst_treatment | 治療方法コードの型を変更<br>・character varying→serial<br>以下のカラムを削除<br>・治療分類<br>以下のカラムを追加<br>・FNW+の治療方法コード<br>・治療経過表ID<br>・治療経過表ID（手書き）<br>・治療経過表ID（前体重）<br>・治療経過表ID（後体重）<br>・治療経過表ID（装置画像転送用）<br>・グラフ時間幅<br>・治療条件設定<br>・モニタデータ項目(帳票用)<br>・モニタデータ項目(画面用)<br>・表示フラグ<br>以下のカラムから「NOT NULL」制約を削除<br>・表示フラグ<br>・削除フラグ | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/25打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C216="",COUNTIF($C$3:C216,C216)<COUNTIF(C:C,C216)),"",C216) | 214 | mst_kur | クールコードの型を変更<br>・character varying→serial<br>以下のカラム名を変更<br>・クール開始→クール開始時刻<br>・クール終了→クール終了時刻<br>・クール内標準開始時刻→クール内標準治療開始時刻<br>以下のカラムを追加<br>・FNW+のクールコード<br>・院内コード1<br>・削除フラグ | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/25打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C217="",COUNTIF($C$3:C217,C217)<COUNTIF(C:C,C217)),"",C217) | 215 | mst_medicine_set | 以下のテーブル名から変更<br>・mst_set_medicine<br>薬剤セットコードの型を変更<br>・character varying→serial<br>以下のカラムを追加<br>・省略薬剤セット名<br>・表示フラグ<br>以下のカラムの備考を変更<br>・セット情報 | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C218="",COUNTIF($C$3:C218,C218)<COUNTIF(C:C,C218)),"",C218) | 216 | mst_equipment_set | テーブル追加 | 新規 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C219="",COUNTIF($C$3:C219,C219)<COUNTIF(C:C,C219)),"",C219) | 217 | mst_treatment_set | 治療方法セットコードの型を変更<br>・character varying→serial<br>以下のカラムを追加<br>・表示フラグ<br>治療方法コードカラムの型を変更<br>・character varying→integer<br>以下のカラムの備考を変更<br>・投与薬剤<br>・医療材料<br>・指示コメント | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/26打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C220="",COUNTIF($C$3:C220,C220)<COUNTIF(C:C,C220)),"",C220) | 218 | sys_address | テーブル追加 | 新規 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C221="",COUNTIF($C$3:C221,C221)<COUNTIF(C:C,C221)),"",C221) | 219 | mst_preparation_medicine | テーブル追加 | 新規 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/25打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C222="",COUNTIF($C$3:C222,C222)<COUNTIF(C:C,C222)),"",C222) | 220 | mst_standard_medicine | テーブル追加 | 新規 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/24打合せ内容を反映 | ■ | × | × |  |
| =IF(OR(C223="",COUNTIF($C$3:C223,C223)<COUNTIF(C:C,C223)),"",C223) | 221 | mst_machine | 「通信フォーマット」の「備考」を修正<br>※「@mst_machine」を追加 | 変更 | YSK橋口 | 43403 | 1.0.0.0 | 2018/10/03依頼内容反映 | ■ | - | - | - |
| =IF(OR(C224="",COUNTIF($C$3:C224,C224)<COUNTIF(C:C,C224)),"",C224) | 222 | ord_main | ・システムで管理する一意な患者ID(pat_id)の型(桁数)変更<br>　character varying(12) → bigint<br>・透析日のカラム名(論理、物理名)変更<br>　透析日 → 治療日<br>　dialysis_date → treat_date<br>・施設コードのカラム名(物理名)変更<br>　ind_facility_cd → facility_cd<br>・施設名のカラム名(物理名)変更<br>　ind_facility_name → facility_name<br>・指示：VA方向のカラム名(論理名)および型(桁数)変更<br>　指示：VA方向 → 指示：VAコード<br>　character varying → integer<br>・指示：治療方法コードのカラム名(物理名)および型(桁数)変更<br>　ind_treat_item_cd → ind_treatment_cd<br>　character varying → integer<br>・指示：治療方法名の復活(一度削除していた)およびカラム名(物理名)変更<br>　ind_treat_item_name → ind_treatment_name<br>・指示：クールコードの型(桁数)および備考変更<br>　character varying → integer<br>　クール未登録の場合、'NON'ではなく 0 を登録する<br>・指示：ベッド番号のカラム名(論理、物理名)変更<br>　指示：ベッド番号 → 指示：ベッドコード<br>　ind_bed_no → ind_bed_cd<br>・指示：スケジュール更新者ID、更新者名、指示者ID、指示者名を削除<br>・指示：治療予定指示者情報(Json)を追加<br>・指示：の備考変更<br>　Json構造の変更<br>・指示：投与薬剤情報の備考変更<br>　Json構造の変更<br>・指示：医療材料情報の備考変更<br>　Json構造の変更<br>・指示：医療材料情報の備考変更<br>　Json構造の変更<br>・指示：指示コメント情報<br>　Json構造の変更<br>・実績：関連透析番号の型および備考変更<br>　bigserial → bigint<br>・実績：治療方法コードのカラム名(物理名)および型(桁数)変更<br>　rst_treat_item_cd → rst_treatment_cd<br>　character varying → integer<br>・実績：治療方法名のカラム名(物理名)変更<br>　rst_treat_item_name → rst_treatment_name<br>・実績：クールコードの型(桁数)および備考変更<br>　character varying → integer<br>　クール未登録の場合、'NON'ではなく 0 を登録する<br>・実績：ベッド番号のカラム名(論理、物理名)変更<br>　実績：ベッド番号 → 実績：ベッドコード<br>　rst_bed_no → rst_bed_cd<br>・実績：装置番号の備考変更<br>　装置番号ではなく、型式コード、製造番号とするべきかどうか<br>・実績：入室日時のカラム名(論理、物理名)変更<br>　実績：入室日時 → 実績：受付日時<br>　rst_enter_date → rst_accept_date<br>・実績：退室日時のカラム名(論理、物理名)変更<br>　実績：退室日時 → 実績：帰宅日時<br>　rst_leave_date → rst_return_home_date<br>・実績：入外区分の型(桁数)変更<br>　character varying → smallint<br>・実績：透析回数の備考変更<br>　運転開始時に更新<br>・実績：病棟コードの型(桁数)変更<br>　character varying → integer<br>・実績：診療科コードの型(桁数)変更<br>　character varying → integer<br>・実績：穿刺者情報のカラム名(物理名)および備考変更<br>　rst_puncture_staff_info → rst_puncture_user_info<br>　Json構造の変更<br>・実績：返血者情報のカラム名(物理名)および備考変更<br>　rst_return_staff_info → rst_return_user_info<br>　Json構造の変更<br>・実績：担当者情報のカラム名(物理名)および備考変更<br>　rst_charge_staff_info → rst_charge_user_info<br>　Json構造の変更<br>・実績：治療条件情報の備考変更<br>　Json構造変更<br>・実績：投与薬剤情報の備考変更<br>　Json構造変更<br>・実績：医療材料情報の備考変更<br>　Json構造変更<br>・実績：指示コメント情報のカラム名(物理名)および備考変更<br>　rst_comment_info → rst_ind_comment_info<br>　Json構造変更<br>・実績：体重情報の備考変更<br>　Json構造要検討<br>・実績：バイタル情報の備考変更<br>　Json構造要検討<br>・実績：愁訴情報の備考変更<br>　Json構造要検討<br>・実績：愁訴処置情報の備考変更<br>　Json構造要検討<br>・実績：愁訴処置者情報の備考変更<br>　Json構造要検討<br>・実績：回診記録情報の備考変更<br>　Json構造要検討 | 変更 | YSK櫨木 | 43407 | 1.0.0.0 | シート「@治療条件項目」を追加 | ■ | × | × |  |
| =IF(OR(C225="",COUNTIF($C$3:C225,C225)<COUNTIF(C:C,C225)),"",C225) | 223 | ord_vital | ord_mainで管理 | 変更 | YSK櫨木 | 43407 | 1.0.0.0 |  | ■ | × | × |  |
| =IF(OR(C226="",COUNTIF($C$3:C226,C226)<COUNTIF(C:C,C226)),"",C226) | 224 | ord_schedule | テーブル追加 | 新規 | YSK橋口 | 43409 | 1.0.0.0 |  | ■ | × | × |  |
| mst_room | 225 | mst_room | テーブル変更<br>・ベッドグループマスタと透析室マスタを合併 | 変更 | YSK櫨木 | 43421 | 1.0.0.0 | 2018/11/7打合せ内容反映 | =IFERROR(IF(C227=VLOOKUP(C227,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C227&"!A1","■"),""),"") | × | × |  |
| @治療条件項目 | 226 | @治療条件項目 | 治療条件項目「穿刺針」を以下に分割<br>分割に伴い、項目番号も再採番<br>・穿刺針(A針)<br>・穿刺針(V針)<br>・穿刺針(SN) | 変更 | YSK櫨木 | 43424 | 1.0.0.0 |  | =IFERROR(IF(C228=VLOOKUP(C228,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C228&"!A1","■"),""),"") |  |  |  |
| =IF(OR(C229="",COUNTIF($C$3:C229,C229)<COUNTIF(C:C,C229)),"",C229) | 227 | mst_user | マスタ権限カラムを追加 | 変更 | ESM村上 | 43371 | 1.0.0.0 | 稼働ビューア対応 | ■ | × | × | × |
| mst_master_category | 228 | mst_master_category | - | 新規 | ESM石藏 | 43384 | 1.0.0.0 | マスタメンテ対応  → 廃止 | =IFERROR(IF(C230=VLOOKUP(C230,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C230&"!A1","■"),""),"") | - | - | - |
| mst_master_list | 229 | mst_master_list | - | 新規 | ESM石藏 | 43384 | 1.0.0.0 | マスタメンテ対応  → 廃止 | =IFERROR(IF(C231=VLOOKUP(C231,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C231&"!A1","■"),""),"") | - | - | - |
| mst_master_order | 230 | mst_master_order | - | 新規 | ESM石藏 | 43384 | 1.0.0.0 | マスタメンテ対応  → 廃止 | =IFERROR(IF(C232=VLOOKUP(C232,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C232&"!A1","■"),""),"") | - | - | - |
| =IF(OR(C233="",COUNTIF($C$3:C233,C233)<COUNTIF(C:C,C233)),"",C233) | 231 | sys_master_define | - | 新規 | ESM石藏 | 43398 | 1.0.0.0 | マスタメンテ対応 | ■ | × | × | × |
| =IF(OR(C234="",COUNTIF($C$3:C234,C234)<COUNTIF(C:C,C234)),"",C234) | 232 | mst_selector | - | 新規 | ESM石藏 | 43398 | 1.0.0.0 | マスタメンテ対応 | ■ | × | × | × |
| =IF(OR(C235="",COUNTIF($C$3:C235,C235)<COUNTIF(C:C,C235)),"",C235) | 233 | mst_facility_hash | - | 新規 | ESM村上 | 43420 | 1.0.0.0 | サインイン対応 | ■ | × | × | 43441 |
| =IF(OR(C236="",COUNTIF($C$3:C236,C236)<COUNTIF(C:C,C236)),"",C236) | 234 | sys_master_define | カラム名を以下に変更<br>・表示変更可否→新規レコード追加可否<br>カラム情報の保有イメージを修正 | 変更 | ESM堤 | 43423 | 1.0.0.0 | マスタメンテ対応 | ■ | × | × | × |
| =IF(OR(C237="",COUNTIF($C$3:C237,C237)<COUNTIF(C:C,C237)),"",C237) | 235 | mst_user | FK制約、一意制約をCREATE TABLEに追加 | 変更 | ESM中本 | 43423 | 1.0.0.0 | 稼働ビューア対応 | ■ | × | × | 43441 |
| =IF(OR(C238="",COUNTIF($C$3:C238,C238)<COUNTIF(C:C,C238)),"",C238) | 236 | mst_staff_facility | FK制約をCREATE TABLEに追加 | 変更 | ESM中本 | 43423 | 1.0.0.0 | 稼働ビューア対応 | ■ | × | × | 43441 |
| =IF(OR(C239="",COUNTIF($C$3:C239,C239)<COUNTIF(C:C,C239)),"",C239) | 237 | mnt_motion_record | FK制約をCREATE TABLEに追加 | 変更 | ESM中本 | 43423 | 1.0.0.0 | 稼働ビューア対応 | ■ | × | × | 43441 |
| =IF(OR(C240="",COUNTIF($C$3:C240,C240)<COUNTIF(C:C,C240)),"",C240) | 238 | mst_user | サインイン失敗回数カラムを追加 | 変更 | ESM村上 | 43425 | 1.0.0.0 | サインイン対応 | ■ | × | × | 43441 |
| =IF(OR(C241="",COUNTIF($C$3:C241,C241)<COUNTIF(C:C,C241)),"",C241) | 239 | mni_monitor | カラム追加<br>・データ種別 | 変更 | TDC米沢 | 43430 | 1.0.0.0 |  | ■ | × | × | 43441 |
| mnt_client_connect | 240 | mnt_client_connect | カラム追加<br>・サーバ種別 | 変更 | TDC米沢 | 43430 | 1.0.0.0 | 稼働サーバにより認証処理を行うため | ■ | × | × | 43441 |
| =IF(OR(C243="",COUNTIF($C$3:C243,C243)<COUNTIF(C:C,C243)),"",C243) | 241 | mnt_device_edge_state | カラム追加<br>・バージョン情報 | 変更 | TDC米沢 | 43430 | 1.0.0.0 |  | ■ | × | × | 43441 |
| =IF(OR(C244="",COUNTIF($C$3:C244,C244)<COUNTIF(C:C,C244)),"",C244) | 242 | mnt_machine_state | カラム追加<br>・警報、注意発生中リスト | 変更 | TDC米沢 | 43430 | 1.0.0.0 |  | ■ | × | × | 43442 |
| =IF(OR(C245="",COUNTIF($C$3:C245,C245)<COUNTIF(C:C,C245)),"",C245) | 243 | mnt_motion_record | カラム追加<br>・装置記録区分 | 変更 | TDC米沢 | 43430 | 1.0.0.0 |  | ■ | × | × | 43441 |
| =IF(OR(C246="",COUNTIF($C$3:C246,C246)<COUNTIF(C:C,C246)),"",C246) | 244 | mst_machine | カラム追加<br>・画像転送可否<br>コメント変更<br>・「FTP収集」→「データ収集可否」 | 変更 | TDC米沢 | 43430 | 1.0.0.0 | 2018/11/22打ち合わせ内容を反映 | ■ | × | × | 43441 |
| =IF(OR(C247="",COUNTIF($C$3:C247,C247)<COUNTIF(C:C,C247)),"",C247) | 245 | mst_device_edge | 主キー変更<br>・施設コード+デバイスエッジ番号 → 製造番号<br>カラム削除<br>・デバイス名<br>カラム追加<br>・表示フラグ<br>・削除フラグ<br>・設置日<br>・破棄日<br>・メモ | 変更 | TDC米沢 | 43430 | 1.0.0.0 | 2018/11/22打ち合わせ内容を反映 | ■ | × | × | 43441 |
| =IF(OR(C248="",COUNTIF($C$3:C248,C248)<COUNTIF(C:C,C248)),"",C248) | 246 | mnt_motion_record | カラム追加<br>・オーダ番号 | 変更 | TDC米沢 | 43432 | 1.0.0.0 | 2018/10/17打ち合わせ内容を反映 | ■ | × | × | 43441 |
| mst_device_edge | 247 | mst_device_edge | カラム追加<br>・デバイス名 | 変更 | TDC米沢 | 43432 | 1.0.0.0 |  | ■ | × | × | 43441 |
| =IF(OR(C250="",COUNTIF($C$3:C250,C250)<COUNTIF(C:C,C250)),"",C250) | 248 | sys_process_server | - | 新規 | YSK櫨木 | 43437 | 1.0.0.0 |  | =IFERROR(IF(C250=VLOOKUP(C250,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C250&"!A1","■"),""),"") | - | - | - |
| =IF(OR(C251="",COUNTIF($C$3:C251,C251)<COUNTIF(C:C,C251)),"",C251) | 249 | pat_main | 備考にJson構造の追記<br>・風袋補正、除水補正 | 変更 | YSK櫨木 | 43439 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C252="",COUNTIF($C$3:C252,C252)<COUNTIF(C:C,C252)),"",C252) | 250 | ord_main | カラム追加<br>・風袋補正(指示、実績)<br>・除水補正(指示、実績)<br>・治療曜日 | 変更 | YSK櫨木 | 43439 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C253="",COUNTIF($C$3:C253,C253)<COUNTIF(C:C,C253)),"",C253) | 251 | ord_schedule | カラム(物理名)追記<br>・治療曜日 | 変更 | YSK櫨木 | 43439 | 1.0.0.0 |  | ■ |  |  |  |
| DB構成 | 252 | DB構成 | データ管理方式の変更内容を反映<br>※以下の情報を個々のDBで管理する<br>・個人情報<br>・医療情報<br>・認証情報 | 変更 | YSK橋口 | 43441 | 1.0.0.0 | 以下の内容をを反映<br>TR-20181119-090183-01-R0_Nikkiso Total Solution Service：RDSパラメータ設定、データ管理方式の検討.docx | =IFERROR(IF(C254=VLOOKUP(C254,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C254&"!A1","■"),""),"") | - | - | - |
| テーブル一覧 | 253 | テーブル一覧 | 一覧の並び順を修正<br>・「テーブル名」の昇順で並べ替え | 変更 | YSK橋口 | 43441 | 1.0.0.0 |  | =IFERROR(IF(C255=VLOOKUP(C255,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C255&"!A1","■"),""),"") | - | - | - |
| テーブル参照 | 254 | テーブル参照 | 一覧の並び順を修正<br>・「テーブル名」の昇順で並べ替え | 変更 | YSK橋口 | 43441 | 1.0.0.0 |  | =IFERROR(IF(C256=VLOOKUP(C256,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C256&"!A1","■"),""),"") | - | - | - |
| 未反映テーブル | 255 | 未反映テーブル | 以下のテーブル構成が整理できていないシートの名称を変更<br>@【未反映】掲示板カテゴリマスタ<br>@【未反映】通知マスタ<br>@【未反映】マルチ患者一覧レイアウトマスタ | 変更 | YSK橋口 | 43441 | 1.0.0.0 |  | =IFERROR(IF(C257=VLOOKUP(C257,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C257&"!A1","■"),""),"") | - | - | - |
| =IF(OR(C258="",COUNTIF($C$3:C258,C258)<COUNTIF(C:C,C258)),"",C258) | 256 | tg_sync_mnt_machine_state | - | 新規 | YSK橋口 | 43441 | 1.0.0.0 | 2018/5/31依頼内容反映<br>※上記時点での変更履歴の記述漏れを追記 | =IFERROR(IF(C258=VLOOKUP(C258,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C258&"!A1","■"),""),"") | 43263 | 2018/6/12<br>※仮スキーマに適用<br>(ntss_provisional) | 43442 |
| sys_process_server | 257 | sys_process_server | テーブル削除<br>※以下のシートからも削除<br>・テーブル一覧<br>・テーブル参照 | 変更 | YSK橋口 | 43441 | 1.0.0.0 | 2018/12/5打ち合わせ内容を反映 | =IFERROR(IF(C259=VLOOKUP(C259,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C259&"!A1","■"),""),"") | - | - | - |
| =IF(OR(C260="",COUNTIF($C$3:C260,C260)<COUNTIF(C:C,C260)),"",C260) | 258 | sys_system_define | 以下のカラムを削除<br>・施設コード<br>「@sys_system_define」シートを修正 | 変更 | YSK橋口 | 43441 | 1.0.0.0 | 2018/12/5打ち合わせ内容を反映<br>※但し、2018/12/7時点での本番環境構築では本対応以前のテーブル構成で構築を行う | ■ | × | × | × |
| mst_bed_group | 259 | mst_bed_group | テーブル削除<br>※以下のシートからも削除<br>・テーブル一覧<br>・テーブル参照 | 変更 | YSK橋口 | 43441 | 1.0.0.0 | 2018/11/7打合せ内容反映 | =IFERROR(IF(C261=VLOOKUP(C261,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C261&"!A1","■"),""),"") | - | - | - |
| =IF(OR(C262="",COUNTIF($C$3:C262,C262)<COUNTIF(C:C,C262)),"",C262) | 260 | ord_main | 各カラムの取り消し線の内容を削除 | 変更 | YSK橋口 | 43441 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C263="",COUNTIF($C$3:C263,C263)<COUNTIF(C:C,C263)),"",C263) | 261 | pat_main | 各カラムの取り消し線の内容を削除 | 変更 | YSK橋口 | 43441 | 1.0.0.0 |  | ■ |  |  |  |
| 全テーブル | 262 | 全テーブル | 以下のテーブルを医療情報DBに登録するように修正<br>・mni_monitor<br>・mnt_client_connect<br>・mnt_device_edge_state<br>・mnt_gathering_manage<br>・mnt_machine_state<br>・mnt_motion_record<br>・mst_device_edge<br>・mst_facility<br>・mst_facility_hash<br>・mst_m_notice<br>・mst_machine<br>・mst_machine_record<br>・mst_machine_type<br>・mst_staff_facility<br>・mst_user<br>・sys_prefectures<br>・sys_system_define | 変更 | YSK橋口 | 43441 | 1.0.0.0 | 以下の内容をを反映<br>TR-20181119-090183-01-R0_Nikkiso Total Solution Service：RDSパラメータ設定、データ管理方式の検討.docx | =IFERROR(IF(C264=VLOOKUP(C264,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C264&"!A1","■"),""),"") | × | × | 43442 |
| =IF(OR(C265="",COUNTIF($C$3:C265,C265)<COUNTIF(C:C,C265)),"",C265) | 263 | mst_machine | 以下のカラムを削除<br>・設置日<br>・廃棄日<br>・バージョン<br>・装置オプション<br>・メモ<br>・使用不可フラグ<br>・モード<br>・TMP初期補正中点<br>・配管自己診断測定日時<br>・漏血テスト測定日時<br>・濃度自己診断測定日時<br>・透析液流量自己診断測定日時<br>・通信共通 自己診断実施日時<br>・自己診断情報<br>・接続供給装置の装置番号<br>・接続溶解装置の装置番号<br>・接続水処理装置の装置番号 | 変更 | YSK橋口 | 43441 | 1.0.0.0 | 以下のシートに検討中内容を転記し、本番環境適用の為、左記カラムを削除<br>「@mst_machine_20181207時点」シート | ■ | × | × | 43441 |
| =IF(OR(C266="",COUNTIF($C$3:C266,C266)<COUNTIF(C:C,C266)),"",C266) | 264 | mnt_machine_state | 以下のカラムを削除<br>・ベッド番号 | 変更 | YSK橋口 | 43442 | 1.0.0.0 | 以下のシートに検討中内容を転記し、本番環境適用の為、左記カラムを削除<br>「@mnt_machine_state_20181208時点」シート | ■ | × | × | 43442 |
| =IF(OR(C267="",COUNTIF($C$3:C267,C267)<COUNTIF(C:C,C267)),"",C267) | 265 | mst_user | FK制約をCREATE TABLEから削除 | 変更 | YSK橋口 | 43442 | 1.0.0.0 | DB分割により外部キー制約違反が発生するため削除 | ■ | × | × | 43442 |
| =IF(OR(C268="",COUNTIF($C$3:C268,C268)<COUNTIF(C:C,C268)),"",C268) | 266 | mst_user_authentication | - | 新規 | YSK橋口 | 43442 | 1.0.0.0 |  | ■ | × | × | 43442 |
| =IF(OR(C269="",COUNTIF($C$3:C269,C269)<COUNTIF(C:C,C269)),"",C269) | 267 | mst_personal_user | - | 新規 | YSK橋口 | 43442 | 1.0.0.0 |  | ■ | × | × | 43442 |
| =IF(OR(C270="",COUNTIF($C$3:C270,C270)<COUNTIF(C:C,C270)),"",C270) | 268 | mst_user | 暗号化対象カラムの備考に以下を追記<br>・暗号化対象<br>暗号化対象カラムの桁を設定なしに修正<br>「利用者種別」カラムの備考に以下を追加<br>・0:一般ユーザ、1:日機装ユーザ | 変更 | YSK橋口 | 43444 | 1.0.0.0 |  | ■ | × | × | 43444 |
| =IF(OR(C271="",COUNTIF($C$3:C271,C271)<COUNTIF(C:C,C271)),"",C271) | 269 | mst_user_authentication | 暗号化対象カラムの備考に以下を追記<br>・暗号化対象<br>暗号化対象カラムの桁を設定なしに修正<br>「利用者種別」カラムの備考に以下を追加<br>・0:一般ユーザ、1:日機装ユーザ | 変更 | YSK橋口 | 43444 | 1.0.0.0 |  | ■ | × | × | 43444 |
| =IF(OR(C272="",COUNTIF($C$3:C272,C272)<COUNTIF(C:C,C272)),"",C272) | 270 | mst_personal_user | 暗号化対象カラムの備考に以下を追記<br>・暗号化対象<br>暗号化対象カラムの桁を設定なしに修正<br>「利用者種別」カラムの備考に以下を追加<br>・0:一般ユーザ、1:日機装ユーザ | 変更 | YSK橋口 | 43444 | 1.0.0.0 |  | ■ | × | × | 43444 |
| =IF(OR(C273="",COUNTIF($C$3:C273,C273)<COUNTIF(C:C,C273)),"",C273) | 271 | DB設計規約 | 「current_timestamp」使用時の注意点を追記 | 変更 | YSK橋口 | 43447 | 1.0.0.0 | 2018/12/13打合せ内容反映 | =IFERROR(IF(C273=VLOOKUP(C273,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C273&"!A1","■"),""),"") | - | - | - |
| =IF(OR(C274="",COUNTIF($C$3:C274,C274)<COUNTIF(C:C,C274)),"",C274) | 272 | tg_sync_mnt_machine_state | 「current_timestamp」に「at time zone 'jst'」を付与 | 変更 | YSK橋口 | 43447 | 1.0.0.0 | 2018/12/13打合せ内容反映 | =IFERROR(IF(C274=VLOOKUP(C274,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C274&"!A1","■"),""),"") | - | - | - |
| DB設計規約 | 273 | DB設計規約 | 「current_timestamp」使用時の注意点を削除 | 変更 | YSK橋口 | 43448 | 1.0.0.0 | 2018/12/14打合せ内容反映 | =IFERROR(IF(C275=VLOOKUP(C275,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C275&"!A1","■"),""),"") | - | - | - |
| tg_sync_mnt_machine_state | 274 | tg_sync_mnt_machine_state | 「current_timestamp」から「at time zone 'jst'」を削除 | 変更 | YSK橋口 | 43448 | 1.0.0.0 | 2018/12/14打合せ内容反映 | =IFERROR(IF(C276=VLOOKUP(C276,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C276&"!A1","■"),""),"") | - | - | - |
| =IF(OR(C277="",COUNTIF($C$3:C277,C277)<COUNTIF(C:C,C277)),"",C277) | 275 | pat_main | ■以下のカラムを追加<br>・登録日時<br>・前体重許容割合（上限）<br>・前体重許容割合（下限）<br>■以下のカラムを変更<br>・患者受付状態<br>　論理名: ⇒ 治療進捗状態<br>■以下のカラムに備考を追記<br>・装置設定情報<br>・治療進捗状態<br>・患者グループ<br>・診療情報<br>・前体重許容割合（上限）<br>・前体重許容割合（下限） | 変更 | YSK伊藤(雅) | 43448 | 1.0.0.0 | 10/13 打ち合わせ内容(DocBase)反映 | ■ | × | × | × |
| =IF(OR(C278="",COUNTIF($C$3:C278,C278)<COUNTIF(C:C,C278)),"",C278) | 276 | pat_main | ■以下のカラムを変更<br>・透析困難コメント情報<br>　論理名: ⇒ 透析困難情報<br>・死因コード<br>　型: character varing ⇒ integer<br>・重症度コード<br>　物理名: injury_cd ⇒ severity_cd<br>　型: character varing ⇒ integer<br>・搬送区分コード<br>　型: character varing ⇒ integer<br>・受診歴情報<br>　論理名: ⇒ 入外・転入出<br>・緊急連絡先情報<br>　物理名: ⇒ other_contact_info<br>　論理名: 緊急連絡先情報 ⇒ 連絡先情報<br>・業者連絡先情報<br>　物理名: ⇒ vendor_contact_info<br>・患者メモ<br>　論理名: フリーコメント ⇒ 患者メモ<br>■以下のカラムに備考を追記<br>・死因コード<br>・重症度コード<br>・搬送区分コード<br>・国籍<br>・入外・転入出<br>・システムで管理する一意な患者ID<br>・院内表示用患者ID<br>・日機装内で管理する一意な患者ID<br>・透析困難情報<br>・連絡先情報<br>・業者連絡先情報 | 変更 | YSK伊藤(雅) | 43448 | 1.0.0.0 | 10/24-26 打ち合わせ内容(DocBase)反映 | ■ | × | × | × |
| =IF(OR(C279="",COUNTIF($C$3:C279,C279)<COUNTIF(C:C,C279)),"",C279) | 277 | pat_main | 以下のカラムを削除<br>・前体重許容割合（上限）<br>・前体重許容割合（下限）<br>※「身体情報」カラム内に移行 | 変更 | YSK橋口 | 43451 | 1.0.0.0 | 12/3-7 打ち合わせ内容(DocBase)反映 | ■ | × | × | × |
| =IF(OR(C280="",COUNTIF($C$3:C280,C280)<COUNTIF(C:C,C280)),"",C280) | 278 | mst_user | 以下のカラムを変更<br>・利用者ID（内部用ID）<br>　型：character varying ⇒ bigint<br>　備考：利用者マスタ（mst_personal_user）.利用者ID（内部用ID） | 変更 | YSK橋口 | 43452 | 1.0.0.0 | 2018/12/18打合せ内容反映 | ■ | × | × | × |
| =IF(OR(C281="",COUNTIF($C$3:C281,C281)<COUNTIF(C:C,C281)),"",C281) | 279 | mst_user_authentication | 以下のカラムを変更<br>・利用者ID（内部用ID）<br>　型：character varying ⇒ bigint<br>　備考：利用者マスタ（mst_personal_user）.利用者ID（内部用ID） | 変更 | YSK橋口 | 43452 | 1.0.0.0 | 2018/12/18打合せ内容反映 | ■ | × | × | × |
| =IF(OR(C282="",COUNTIF($C$3:C282,C282)<COUNTIF(C:C,C282)),"",C282) | 280 | mst_personal_user | 以下のカラムを変更<br>・利用者ID（内部用ID）<br>　型：character varying ⇒ bigserial | 変更 | YSK橋口 | 43452 | 1.0.0.0 | 2018/12/18打合せ内容反映 | ■ | × | × | × |
| =IF(OR(C283="",COUNTIF($C$3:C283,C283)<COUNTIF(C:C,C283)),"",C283) | 281 | mst_staff_facility | 以下のカラムを変更<br>・担当者ID<br>　物理名：user_cd ⇒ user_id<br>　型：character varying ⇒ bigint | 変更 | YSK橋口 | 43452 | 1.0.0.0 | 2018/12/17打合せ内容反映 | ■ | × | × | × |
| =IF(OR(C284="",COUNTIF($C$3:C284,C284)<COUNTIF(C:C,C284)),"",C284) | 282 | mnt_motion_record | 以下のカラムを変更<br>・対処者<br>　型：character varying ⇒ bigint | 変更 | YSK橋口 | 43452 | 1.0.0.0 | 2018/12/17打合せ内容反映 | ■ | × | × | × |
| mnt_gathering_manage | 283 | mnt_gathering_manage | 以下のカラムを変更<br>・利用者ID<br>　型：character varying ⇒ bigint | 変更 | YSK橋口 | 43452 | 1.0.0.0 | 2018/12/17打合せ内容反映 | ■ | × | × | × |
| =IF(OR(C286="",COUNTIF($C$3:C286,C286)<COUNTIF(C:C,C286)),"",C286) | 284 | mni_monitor | 以下のカラムを変更<br>・システムで管理する一意な患者ID<br>　型：character varying ⇒ bigint | 変更 | YSK橋口 | 43452 | 1.0.0.0 | 2018/12/17打合せ内容反映 | ■ | × | × | × |
| =IF(OR(C287="",COUNTIF($C$3:C287,C287)<COUNTIF(C:C,C287)),"",C287) | 285 | mnt_machine_state | 以下のカラムを変更<br>・ベッドコード<br>　型：character varying ⇒ bigint<br>・システムで管理する一意な患者ID<br>　型：character varying ⇒ bigint<br>・次患者ID<br>　型：character varying ⇒ bigint<br>・次患者クールCD<br>　型：character varying ⇒ bigint | 変更 | YSK橋口 | 43452 | 1.0.0.0 | 2018/12/18打合せ内容反映 | ■ | × | × | × |
| =IF(OR(C288="",COUNTIF($C$3:C288,C288)<COUNTIF(C:C,C288)),"",C288) | 286 | mst_bed | 以下のカラムを変更<br>・ベッドコード<br>　型：serial ⇒ bigserial | 変更 | YSK橋口 | 43452 | 1.0.0.0 | 2018/12/18打合せ内容反映 | ■ | × | × | × |
| =IF(OR(C289="",COUNTIF($C$3:C289,C289)<COUNTIF(C:C,C289)),"",C289) | 287 | mst_kur | 以下のカラムを変更<br>・クールコード<br>　型：serial ⇒ bigserial | 変更 | YSK橋口 | 43452 | 1.0.0.0 | 2018/12/18打合せ内容反映 | ■ | × | × | × |
| =IF(OR(C290="",COUNTIF($C$3:C290,C290)<COUNTIF(C:C,C290)),"",C290) | 288 | mst_machine | 以下のカラムを変更<br>・装置番号<br>　型：bigint ⇒ bigserial | 変更 | YSK中村 | 43452 | 1.0.0.0 | 2018/11/06-09 打ち合わせ内容(DocBase)反映 | ■ | × | × | × |
| - | 289 | - | 以下のシートを追加<br>「インデックス一覧」 | 新規 | YSK橋口 | 43452 | 1.0.0.0 |  | =IFERROR(IF(C291=VLOOKUP(C291,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C291&"!A1","■"),""),"") | - | - | - |
| idx_mni_monitor_01 | 290 | idx_mni_monitor_01 | - | 新規 | YSK橋口 | 43452 | 1.0.0.0 | 2018/12/17打合せ内容反映 | =IFERROR(IF(C292=VLOOKUP(C292,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C292&"!A1","■"),""),"") | 43453 | × | 43453 |
| personal_info_encrypt | 291 | personal_info_encrypt | - | 新規 | YSK中村 | 43453 | 1.0.0.0 | 2018/12/10打合せ内容反映 | =IFERROR(IF(C293=VLOOKUP(C293,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C293&"!A1","■"),""),"") | 43444 | × | 43444 |
| personal_info_decrypt | 292 | personal_info_decrypt | - | 新規 | YSK中村 | 43453 | 1.0.0.0 | 2018/12/10打合せ内容反映 | =IFERROR(IF(C294=VLOOKUP(C294,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C294&"!A1","■"),""),"") | 43444 | × | 43444 |
| idx_mnt_motion_record_01 | 293 | idx_mnt_motion_record_01 | - | 新規 | YSK橋口 | 43453 | 1.0.0.0 | 2018/12/19打合せ内容反映 | =IFERROR(IF(C295=VLOOKUP(C295,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C295&"!A1","■"),""),"") | 43453 | × | 43453 |
| =IF(OR(C296="",COUNTIF($C$3:C296,C296)<COUNTIF(C:C,C296)),"",C296) | 294 | sys_master_define | コンボデータカラムを追加 | 変更 | ESM | 43430 | 1.0.0.0 | マスタメンテ対応 | ■ | × | × | × |
| =IF(OR(C297="",COUNTIF($C$3:C297,C297)<COUNTIF(C:C,C297)),"",C297) | 295 | sys_master_define | PK変更(マスタコード→マスタ物理名) | 変更 | ESM | 43431 | 1.0.0.0 | マスタメンテ対応 | ■ | × | × | × |
| =IF(OR(C298="",COUNTIF($C$3:C298,C298)<COUNTIF(C:C,C298)),"",C298) | 296 | mst_selector | カラム名を以下に変更<br>・マスタコード→マスタ物理名 | 変更 | ESM | 43440 | 1.0.0.0 | マスタメンテ対応 | ■ | × | × | × |
| =IF(OR(C299="",COUNTIF($C$3:C299,C299)<COUNTIF(C:C,C299)),"",C299) | 297 | mst_selector | テーブル名（論理名）を変更<br>・並び順管理マスタ→選択肢マスタ | 変更 | ESM | 43440 | 1.0.0.0 | マスタメンテ対応 | ■ | × | × | × |
| =IF(OR(C300="",COUNTIF($C$3:C300,C300)<COUNTIF(C:C,C300)),"",C300) | 298 | sys_master_define | 表示区分カラムを追加 | 変更 | ESM | 43454 | 1.0.0.0 | マスタメンテ対応 | ■ | × | × | × |
| =IF(OR(C301="",COUNTIF($C$3:C301,C301)<COUNTIF(C:C,C301)),"",C301) | 299 | mst_user | 必要なカラムのみに修正 | 変更 | ESM | 43454 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C302="",COUNTIF($C$3:C302,C302)<COUNTIF(C:C,C302)),"",C302) | 300 | mst_user_authentication | 必要なカラムのみに修正 | 変更 | ESM | 43454 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C303="",COUNTIF($C$3:C303,C303)<COUNTIF(C:C,C303)),"",C303) | 301 | mst_personal_user | 必要なカラムのみに修正 | 変更 | ESM | 43454 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C304="",COUNTIF($C$3:C304,C304)<COUNTIF(C:C,C304)),"",C304) | 302 | mst_user | user_idに対するFK制約をCREATE TABLEに追加 | 変更 | ESM | 43454 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C305="",COUNTIF($C$3:C305,C305)<COUNTIF(C:C,C305)),"",C305) | 303 | mst_user_authentication | user_id、facility_cdに対するFK制約を<br>CREATE TABLEに追加 | 変更 | ESM | 43454 | 1.0.0.0 |  | ■ | × | × | × |
| mst_staff_facility | 304 | mst_staff_facility | facility_cdに対するFK制約をCREATE TABLEに追加 | 変更 | ESM | 43454 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C307="",COUNTIF($C$3:C307,C307)<COUNTIF(C:C,C307)),"",C307) | 305 | mst_user | 以下のカラムの外部キー制約を削除<br>・利用者ID（内部用ID）<br>以下のカラムの一意制約を削除<br>・施設コード＋表示用利用者ID | 変更 | ESM | 43455 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C308="",COUNTIF($C$3:C308,C308)<COUNTIF(C:C,C308)),"",C308) | 306 | mst_personal_user | 以下のカラムの一意制約を削除<br>・施設コード＋表示用利用者ID | 変更 | ESM | 43455 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C309="",COUNTIF($C$3:C309,C309)<COUNTIF(C:C,C309)),"",C309) | 307 | mst_user_authentication | 以下のカラムの外部キー制約を削除<br>・利用者ID（内部用ID）<br>・施設コード | 変更 | ESM | 43455 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C310="",COUNTIF($C$3:C310,C310)<COUNTIF(C:C,C310)),"",C310) | 308 | mst_facility_hash | 以下のカラムの外部キー制約を削除<br>・施設コード | 変更 | ESM | 43455 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C311="",COUNTIF($C$3:C311,C311)<COUNTIF(C:C,C311)),"",C311) | 309 | mst_personal_user | 以下のカラムの外部キー制約を削除<br>・施設コード | 変更 | ESM | 43459 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C312="",COUNTIF($C$3:C312,C312)<COUNTIF(C:C,C312)),"",C312) | 310 | mst_personal_user | 以下のカラムを削除<br>・ユーザー設定 | 変更 | ESM | 43460 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C313="",COUNTIF($C$3:C313,C313)<COUNTIF(C:C,C313)),"",C313) | 311 | mst_personal_user | 以下のカラムを削除<br>・サインイン失敗回数<br>・仮登録フラグ | 変更 | ESM | 43461 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C314="",COUNTIF($C$3:C314,C314)<COUNTIF(C:C,C314)),"",C314) | 312 | mst_user | 以下のカラムを追加<br>・仮登録フラグ | 変更 | ESM | 43461 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C315="",COUNTIF($C$3:C315,C315)<COUNTIF(C:C,C315)),"",C315) | 313 | mst_user_authentication | 以下のカラムを追加<br>・サインイン失敗回数 | 変更 | ESM | 43461 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C316="",COUNTIF($C$3:C316,C316)<COUNTIF(C:C,C316)),"",C316) | 314 | sys_master_define | カラム名（論理名および物理名）を以下に変更<br>・マスタ分類 → モード<br>・master_type → mode | 変更 | ESM | 43474 | 1.0.0.0 |  | ■ | × | × | × |
| mst_room_bed_group | 315 | mst_room_bed_group | テーブル名を変更<br>　mst_room ⇒ mst_room_bed_group<br>以下のカラムを変更<br>・透析室・ベッドグループコード<br>　bed_group_cd ⇒ room_bed_group_cd<br>・透析室・ベッドグループ名<br>　bed_group_name ⇒ room_bed_group_name<br>・FNW+の透析室・ベッドグループ番号<br>　fn_bed_group_no ⇒ fn_room_bed_group_no<br>　型：numeric ⇒ character varying<br>以下の内容について、他テーブルに合わせる<br>・NOT NULL制約 | 変更 | YSK中村 | 43486 | 1.0.0.0 | 2018/11/06-09 打ち合わせ内容(DocBase)反映 | ■ | × | × | × |
| =IF(OR(C318="",COUNTIF($C$3:C318,C318)<COUNTIF(C:C,C318)),"",C318) | 316 | mst_bed | 以下のカラムを追加<br>・表示フラグ<br>・削除フラグ<br>以下の内容について、他テーブルに合わせる<br>・NOT NULL制約 | 変更 | YSK中村 | 43486 | 1.0.0.0 | 2018/11/06-09 打ち合わせ内容(DocBase)反映 | ■ | × | × | × |
| =IF(OR(C319="",COUNTIF($C$3:C319,C319)<COUNTIF(C:C,C319)),"",C319) | 317 | pat_main | テーブル定義変更 | 変更 | YSK伊藤(雅) | 43486 | 1.0.0.0 | 「個人情報_患者情報_利用者情報.xlsx」の内容(2018/11/27 現在)に沿って元のpat_mainテーブルから派生 | ■ | × | × | × |
| =IF(OR(C320="",COUNTIF($C$3:C320,C320)<COUNTIF(C:C,C320)),"",C320) | 318 | pat_personal_main | テーブル追加 | 新規 | YSK伊藤(雅) | 43486 | 1.0.0.0 | 「個人情報_患者情報_利用者情報.xlsx」の内容(2018/11/27 現在)に沿って元のpat_mainテーブルから派生 | ■ | × | × | × |
| =IF(OR(C321="",COUNTIF($C$3:C321,C321)<COUNTIF(C:C,C321)),"",C321) | 319 | pat_unique | テーブル追加 | 新規 | YSK伊藤(雅) | 43486 | 1.0.0.0 | 「個人情報_患者情報_利用者情報.xlsx」の内容(2018/11/27 現在)に沿って元のpat_mainテーブルから派生 | ■ | × | × | × |
| =IF(OR(C322="",COUNTIF($C$3:C322,C322)<COUNTIF(C:C,C322)),"",C322) | 320 | ord_schedule | 以下のカラムを変更<br>・クールコード<br>　型：integer ⇒ bigint<br>・ベッドコード<br>　型：integer ⇒ bigint<br>以下の内容について、他テーブルに合わせる<br>・NOT NULL制約 | 変更 | YSK中村 | 43486 | 1.0.0.0 | 2018/11/06-09 打ち合わせ内容(DocBase)反映 | ■ | × | × | × |
| =IF(OR(C323="",COUNTIF($C$3:C323,C323)<COUNTIF(C:C,C323)),"",C323) | 321 | mst_treatment_set | 以下のカラムのJSON形式フォーマットを変更<br>・治療条件<br>・投与薬剤<br>・医療材料<br>・指示コメント | 変更 | YSK中村 | 43486 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C324="",COUNTIF($C$3:C324,C324)<COUNTIF(C:C,C324)),"",C324) | 322 | ord_main | 以下のカラムのJSON形式フォーマットを変更<br>・投与薬剤<br>・医療材料<br>・医療材料<br>・指示コメント<br>以下のカラムを追加<br>・指示：装置設定情報<br>・実績：装置設定情報<br>以下の内容について、他テーブルに合わせる<br>・NOT NULL制約<br>・デフォルト設定 | 変更 | YSK中村 | 43486 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C325="",COUNTIF($C$3:C325,C325)<COUNTIF(C:C,C325)),"",C325) | 323 | mst_machine | 以下のカラムを追加<br>・設置日<br>・廃棄日<br>・バージョン<br>・装置オプション<br>・メモ<br>・使用不可フラグ<br>・対応可否フラグ(HD)<br>・対応可否フラグ(ECUM)<br>・対応可否フラグ(HDF)<br>・対応可否フラグ(HF)<br>・対応可否フラグ(HD+補液)<br>・対応可否フラグ(ECUM+補液)<br>・対応可否フラグ(AFBF)<br>・対応可否フラグ(OHDF)<br>・対応可否フラグ(OHF)<br>・対応可否フラグ(I-HDF)<br>・TMP初期補正中点(HD)<br>・TMP初期補正中点(ECUM)<br>・TMP初期補正中点(HDF)<br>・TMP初期補正中点(HF)<br>・TMP初期補正中点(HD+補液)<br>・TMP初期補正中点(OHDF)<br>・TMP初期補正中点(OHF) | 変更 | YSK中村 | 43486 | 1.0.0.0 | 2018/11/06-09 打ち合わせ内容(DocBase)反映 | ■ | × | × | × |
| =IF(OR(C326="",COUNTIF($C$3:C326,C326)<COUNTIF(C:C,C326)),"",C326) | 324 | ord_main | 以下のカラムを変更<br>・指示：クールコード<br>　型：integer ⇒ bigint<br>・指示：ベッドコード<br>　型：integer ⇒ bigint<br>・実績：クールコード<br>　型：integer ⇒ bigint<br>・実績：ベッドコード<br>　型：integer ⇒ bigint | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_bio_moni_frame_pattern | 325 | mst_bio_moni_frame_pattern | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_com_fixed_phrase | 326 | mst_com_fixed_phrase | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C329="",COUNTIF($C$3:C329,C329)<COUNTIF(C:C,C329)),"",C329) | 327 | mst_course | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_dialysis_difficulty | 328 | mst_dialysis_difficulty | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C331="",COUNTIF($C$3:C331,C331)<COUNTIF(C:C,C331)),"",C331) | 329 | mst_dialyzer | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C332="",COUNTIF($C$3:C332,C332)<COUNTIF(C:C,C332)),"",C332) | 330 | mst_disease | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C333="",COUNTIF($C$3:C333,C333)<COUNTIF(C:C,C333)),"",C333) | 331 | mst_equipment | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_equipment_class | 332 | mst_equipment_class | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C335="",COUNTIF($C$3:C335,C335)<COUNTIF(C:C,C335)),"",C335) | 333 | mst_equipment_set | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_frame_define | 334 | mst_frame_define | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C337="",COUNTIF($C$3:C337,C337)<COUNTIF(C:C,C337)),"",C337) | 335 | mst_implant | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_infection | 336 | mst_infection | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C339="",COUNTIF($C$3:C339,C339)<COUNTIF(C:C,C339)),"",C339) | 337 | mst_kur | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_medicate_timing | 338 | mst_medicate_timing | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C341="",COUNTIF($C$3:C341,C341)<COUNTIF(C:C,C341)),"",C341) | 339 | mst_medicine | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_medicine_class | 340 | mst_medicine_class | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C343="",COUNTIF($C$3:C343,C343)<COUNTIF(C:C,C343)),"",C343) | 341 | mst_medicine_set | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_moni_item | 342 | mst_moni_item | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C345="",COUNTIF($C$3:C345,C345)<COUNTIF(C:C,C345)),"",C345) | 343 | mst_pat_memo | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C346="",COUNTIF($C$3:C346,C346)<COUNTIF(C:C,C346)),"",C346) | 344 | mst_procedure | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_relationship | 345 | mst_relationship | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_severity | 346 | mst_severity | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_standard_course | 347 | mst_standard_course | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_standard_disease | 348 | mst_standard_disease | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_standard_medicine | 349 | mst_standard_medicine | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C352="",COUNTIF($C$3:C352,C352)<COUNTIF(C:C,C352)),"",C352) | 350 | mst_taboo_allergy | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_transport | 351 | mst_transport | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C354="",COUNTIF($C$3:C354,C354)<COUNTIF(C:C,C354)),"",C354) | 352 | mst_treatment | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C355="",COUNTIF($C$3:C355,C355)<COUNTIF(C:C,C355)),"",C355) | 353 | mst_va | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| mst_ward | 354 | mst_ward | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C357="",COUNTIF($C$3:C357,C357)<COUNTIF(C:C,C357)),"",C357) | 355 | pat_event | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C358="",COUNTIF($C$3:C358,C358)<COUNTIF(C:C,C358)),"",C358) | 356 | pat_obs_rec | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| pat_prescription | 357 | pat_prescription | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| pat_prescription_detail | 358 | pat_prescription_detail | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| sys_address | 359 | sys_address | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| sys_country | 360 | sys_country | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| sys_data_item | 361 | sys_data_item | テーブルスペースの変更 | 変更 | YSK中村 | 43488 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C364="",COUNTIF($C$3:C364,C364)<COUNTIF(C:C,C364)),"",C364) | 362 | sys_master_define | 以下のカラムを追加<br>・参照型マスタの構造データ | 変更 | ESM | 43490 | 1.0.0.0 |  | ■ | × | × | × |
| mst_selector | 363 | mst_selector | テーブル名（論理名）を以下に変更<br>・並び順管理マスタ → 選択肢マスタ | 変更 | ESM | 43494 | 1.0.0.0 |  | ■ | × | × | × |
| pat_obs_rec | 364 | pat_obs_rec | 以下のカラムを追加<br>・ユニークな管理番号(obs_rec_no)<br>・起票日時(rec_date)<br>・オーダ番号(ord_no)<br>以下のカラムを変更<br>・主キーをpat_id+ctl_noからobs_rec_noに変更<br>・ctl_noを削除 | 変更 | TDC | 43493 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C367="",COUNTIF($C$3:C367,C367)<COUNTIF(C:C,C367)),"",C367) | 365 | mst_obs_kind | テーブル追加 | 新規 | TDC | 43495 | 1.0.0.0 |  | ■ | × | × | × |
| mst_obs_kind | 366 | mst_obs_kind | 以下のカラムを追加<br>・FNW+で管理する施設内の一意な種別ID(fn_kind_id)<br>以下のカラムのデフォルト値を追加<br>・期間(post_period)<br>・周知先(post_address_class) | 変更 | TDC | 43500 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C369="",COUNTIF($C$3:C369,C369)<COUNTIF(C:C,C369)),"",C369) | 367 | mst_weight | テーブル追加 | 新規 | TDC | 43501 | 1.0.0.0 |  | ■ | × | × | × |
| mst_weight_scale | 368 | mst_weight_scale | テーブル追加 | 新規 | TDC | 43501 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C371="",COUNTIF($C$3:C371,C371)<COUNTIF(C:C,C371)),"",C371) | 369 | mst_weight_print | テーブル追加 | 新規 | TDC | 43501 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C372="",COUNTIF($C$3:C372,C372)<COUNTIF(C:C,C372)),"",C372) | 370 | mst_wheel_chair | テーブル追加 | 新規 | TDC | 43501 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C373="",COUNTIF($C$3:C373,C373)<COUNTIF(C:C,C373)),"",C373) | 371 | mnt_weight_state | テーブル追加 | 新規 | TDC | 43501 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C374="",COUNTIF($C$3:C374,C374)<COUNTIF(C:C,C374)),"",C374) | 372 | ord_weight_scale | テーブル追加 | 新規 | TDC | 43501 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C375="",COUNTIF($C$3:C375,C375)<COUNTIF(C:C,C375)),"",C375) | 373 | ord_weight_scale | 以下のカラムを追加<br>・体重計名称 | 変更 | TDC | 43502 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C376="",COUNTIF($C$3:C376,C376)<COUNTIF(C:C,C376)),"",C376) | 374 | mnt_weight_state | 以下のカラムを削除<br>・施設コード<br>・体重計番号 | 変更 | TDC | 43502 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C377="",COUNTIF($C$3:C377,C377)<COUNTIF(C:C,C377)),"",C377) | 375 | mnt_weight_state | 以下のカラムを追加<br>・重量校正日時<br>・重量校正者<br>以下のカラムを変更<br>・車いす番号→FNW+で管理する施設内の一意な車いすコード<br>・車いすコード、名称、重量の物理名を変更 | 変更 | TDC | 43502 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C378="",COUNTIF($C$3:C378,C378)<COUNTIF(C:C,C378)),"",C378) | 376 | ord_main | 以下のカラムを追加<br>・登録日時 | 変更 | ESM | 43508 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C379="",COUNTIF($C$3:C379,C379)<COUNTIF(C:C,C379)),"",C379) | 377 | ord_schedule | 以下のカラムを追加<br>・登録日時 | 変更 | ESM | 43508 | 1.0.0.0 |  | ■ | × | × | × |
| mnt_websocket_certification | 378 | mnt_websocket_certification | テーブル追加 | 新規 | TDC | 43511 | 1.0.0.0 |  | ■ | × | × | × |
| jsonb_merge_recursive | 379 | jsonb_merge_recursive | ファンクション追加 | 新規 | YSK中村 | 43511 | 1.0.0.0 |  | =IFERROR(IF(C381=VLOOKUP(C381,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C381&"!A1","■"),""),"") | × | × | × |
| =IF(OR(C382="",COUNTIF($C$3:C382,C382)<COUNTIF(C:C,C382)),"",C382) | 380 | ord_main | 以下の備考を変更<br>・指示：投与薬剤情報<br>・指示：装置設定情報<br>　　※「@ind_device_set_info」シート参照<br>・実績：風袋補正 | 変更 | YSK中村 | 43521 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C383="",COUNTIF($C$3:C383,C383)<COUNTIF(C:C,C383)),"",C383) | 381 | mst_destination_group | テーブル追加 | 新規 | ESM | 43522 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C384="",COUNTIF($C$3:C384,C384)<COUNTIF(C:C,C384)),"",C384) | 382 | mst_alarm_notification | テーブル追加 | 新規 | ESM | 43522 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C385="",COUNTIF($C$3:C385,C385)<COUNTIF(C:C,C385)),"",C385) | 383 | mst_pat_viewer_layout | テーブル追加 | 新規 | YSK櫨木 | 43518 | 1.0.0.0 |  | ■ | × | × | × |
| ind_cond_info_value | 384 | ind_cond_info_value | ファンクション追加 | 新規 | YSK伊藤(雅) | 43524 | 1.0.0.0 |  | =IFERROR(IF(C386=VLOOKUP(C386,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C386&"!A1","■"),""),"") | × | × | × |
| json_array_contains_array_value | 385 | json_array_contains_array_value | ファンクション追加 | 新規 | YSK伊藤(雅) | 43524 | 1.0.0.0 |  | =IFERROR(IF(C387=VLOOKUP(C387,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C387&"!A1","■"),""),"") | × | × | × |
| json_array_contains_value | 386 | json_array_contains_value | ファンクション追加 | 新規 | YSK伊藤(雅) | 43524 | 1.0.0.0 |  | =IFERROR(IF(C388=VLOOKUP(C388,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C388&"!A1","■"),""),"") | × | × | × |
| json_array_contains_value_with_class | 387 | json_array_contains_value_with_class | ファンクション追加 | 新規 | YSK伊藤(雅) | 43524 | 1.0.0.0 |  | =IFERROR(IF(C389=VLOOKUP(C389,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C389&"!A1","■"),""),"") | × | × | × |
| =IF(OR(C390="",COUNTIF($C$3:C390,C390)<COUNTIF(C:C,C390)),"",C390) | 388 | pat_unique | 以下の備考を変更<br>・既往歴情報<br>・入外・転入出情報 | 変更 | YSK伊藤(雅) | 43524 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C391="",COUNTIF($C$3:C391,C391)<COUNTIF(C:C,C391)),"",C391) | 389 | mnt_machine_state | 以下のカラムを追加<br>・患者確認済みフラグ<br>以下のカラムを変更<br>・緊急発報件数<br>　デフォルト：0<br>・予防保守件数<br>　デフォルト：0<br>・通信不良有無<br>　デフォルト：0 | 変更 | YSK橋口 | 43524 | 1.0.0.0 | 2018/10/17打合せ内容(DocBase)反映<br>2019/1/21指摘内容(idobata)反映 | ■ | × | × | × |
| =IF(OR(C392="",COUNTIF($C$3:C392,C392)<COUNTIF(C:C,C392)),"",C392) | 390 | mnt_machine_state | 以下のカラムを追加<br>・装置設定一時データ | 変更 | YSK橋口 | 43524 | 1.0.0.0 |  | ■ | × | × | × |
| ord_main_ind_medi_info_no_seq | 391 | ord_main_ind_medi_info_no_seq | シーケンス追加 | 新規 | YSK中村 | 43524 | 1.0.0.0 |  | =IFERROR(IF(C393=VLOOKUP(C393,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C393&"!A1","■"),""),"") | × | × | × |
| =IF(OR(C394="",COUNTIF($C$3:C394,C394)<COUNTIF(C:C,C394)),"",C394) | 392 | mst_comsv_setting | テーブル追加 | 新規 | TDC | 43525 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C395="",COUNTIF($C$3:C395,C395)<COUNTIF(C:C,C395)),"",C395) | 393 | ord_treat_condition | テーブル追加 | 新規 | TDC | 43525 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C396="",COUNTIF($C$3:C396,C396)<COUNTIF(C:C,C396)),"",C396) | 394 | mst_treatment_status_layout | テーブル追加 | 新規 | TDC | 43525 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C397="",COUNTIF($C$3:C397,C397)<COUNTIF(C:C,C397)),"",C397) | 395 | mnt_machine_state | シート「@tmp_device_set_info」更新<br>・pat1のタグ名、データ種類名 | 変更 | TDC | 43525 | 1.0.0.0 |  | ■ | × | × | × |
| mst_treatment_status_layout | 396 | mst_treatment_status_layout | 以下のカラムの記述ミスを変更<br>・レイアウト名[layou_name]→[layout_name]に変更 | 変更 | TDC | 43527 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C399="",COUNTIF($C$3:C399,C399)<COUNTIF(C:C,C399)),"",C399) | 397 | mst_personal_user | 以下のカラムのNOT NULL属性を削除<br>・メールアドレス１<br>・職種コード | 変更 | ESM | 43528 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C400="",COUNTIF($C$3:C400,C400)<COUNTIF(C:C,C400)),"",C400) | 398 | ord_main | 以下のカラムを追加<br>・実績：DW | 変更 | ESM | 43530 | 1.0.0.0 | 2019/02/25 のidobataに投稿した内容を反映<br>https://idobata.io/archives/messages/30047779#message_30047779 | ■ | × | × | × |
| =IF(OR(C401="",COUNTIF($C$3:C401,C401)<COUNTIF(C:C,C401)),"",C401) | 399 | mst_bed | 以下の備考の記載ミスを訂正<br>・実績確定時の自動印刷有無 | 変更 | YSK中村 | 43531 | 1.0.0.0 |  | ■ | × | × | × |
| tg_sync_mst_bed | 400 | tg_sync_mst_bed | トリガー追加 | 新規 | YSK橋口 | 43531 | 1.0.0.0 | 2019/2/25依頼内容反映 | =IFERROR(IF(C402=VLOOKUP(C402,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C402&"!A1","■"),""),"") | × | × | × |
| =IF(OR(C403="",COUNTIF($C$3:C403,C403)<COUNTIF(C:C,C403)),"",C403) | 401 | ord_main | 以下のカラムの精度(numeric(3,2) -> numeric(5,2))を修正<br>・実績：DW | 変更 | ESM | 43531 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C404="",COUNTIF($C$3:C404,C404)<COUNTIF(C:C,C404)),"",C404) | 402 | mst_machine | 以下のカラムを追加<br>・削除フラグ<br>・表示フラグ | 変更 | TDC | 43531 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C405="",COUNTIF($C$3:C405,C405)<COUNTIF(C:C,C405)),"",C405) | 403 | mst_comsv_setting | テーブルスペース等が誤っていたので修正<br>・nkk → nkk5 | 変更 | TDC | 43531 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C406="",COUNTIF($C$3:C406,C406)<COUNTIF(C:C,C406)),"",C406) | 404 | ord_treat_condition | テーブルスペース等が誤っていたので修正<br>・nkk → nkk5 | 変更 | TDC | 43531 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C407="",COUNTIF($C$3:C407,C407)<COUNTIF(C:C,C407)),"",C407) | 405 | ord_main | 「@ind_device_set_info」シートの誤記修正<br>【誤】ufc→【正】ufr | 変更 | YSK橋口 | 43532 | 1.0.0.0 |  | ■ | × | × | × |
| tg_sync_ord_main | 406 | tg_sync_ord_main | トリガー追加 | 新規 | YSK中村 | 43532 | 1.0.0.0 |  | =IFERROR(IF(C408=VLOOKUP(C408,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C408&"!A1","■"),""),"") | × | × | × |
| =IF(OR(C409="",COUNTIF($C$3:C409,C409)<COUNTIF(C:C,C409)),"",C409) | 407 | mst_wheel_chair | 以下のカラム名を変更<br>・個人所有フラグ[is_parsonal]→[is_personal]に変更 | 変更 | TDC | 43538 | 1.0.0.0 |  | ■ | × | × | × |
| pat_unique_json_contains_value | 408 | pat_unique_json_contains_value | ファンクション追加 | 新規 | YSK | 43544 | 1.0.0.0 |  | =IFERROR(IF(C410=VLOOKUP(C410,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C410&"!A1","■"),""),"") | × | × | × |
| =IF(OR(C411="",COUNTIF($C$3:C411,C411)<COUNTIF(C:C,C411)),"",C411) | 409 | pat_unique | 以下の備考を変更<br>・既往歴情報<br>・入外・転入出情報 | 変更 | YSK | 43544 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C412="",COUNTIF($C$3:C412,C412)<COUNTIF(C:C,C412)),"",C412) | 410 | pat_treatment_pattern | テーブル追加 | 新規 | YSK | 43544 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C413="",COUNTIF($C$3:C413,C413)<COUNTIF(C:C,C413)),"",C413) | 411 | ord_main | 以下のカラムを変更<br>・weight_scale_noカラムを追加<br>・rst_tare_infoのJSON内容を追加<br>　（使用車いす情報を保存するように修正）<br>・rst_weight_infoのJSON内容を変更<br>　（water_removal_rst、weight_decreased、 re_loop_rate_main のキーを追加） | 変更 | TDC | 43545 | 1.0.0.0 |  | ■ | × | × | × |
| ord_treat_condition | 412 | ord_treat_condition | 以下のシートを追加<br>@ord_treat_condition | 追加 | TDC | 43546 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C415="",COUNTIF($C$3:C415,C415)<COUNTIF(C:C,C415)),"",C415) | 413 | mst_checklist | テーブル追加 | 追加 | TDC | 43546 | 1.0.0.0 |  | ■ | × | × | × |
| mst_dialysis_progress | 414 | mst_dialysis_progress | テーブル追加 | 追加 | TDC | 43546 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C417="",COUNTIF($C$3:C417,C417)<COUNTIF(C:C,C417)),"",C417) | 415 | ord_checklist | テーブル追加 | 追加 | TDC | 43546 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C418="",COUNTIF($C$3:C418,C418)<COUNTIF(C:C,C418)),"",C418) | 416 | mst_status_map_bed_layout | テーブル追加 | 追加 | TDC | 43546 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C419="",COUNTIF($C$3:C419,C419)<COUNTIF(C:C,C419)),"",C419) | 417 | mst_comsv_setting | 以下のカラムを追加<br>・lcd_staff_listカラムを追加 | 変更 | TDC | 43546 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C420="",COUNTIF($C$3:C420,C420)<COUNTIF(C:C,C420)),"",C420) | 418 | ord_checklist | 以下のカラムを変更<br>・rst_checklist_info<br>　セットされる項目の詳細を@ord_checklistシートに記述 | 変更 | TDC | 43546 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C421="",COUNTIF($C$3:C421,C421)<COUNTIF(C:C,C421)),"",C421) | 419 | mst_status_map_bed_layout | 以下のJSONキー名を修正<br>・campas_size → canvas_size<br>@mst_status_map_bed_layoutに記載 | 変更 | TDC | 43549 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C422="",COUNTIF($C$3:C422,C422)<COUNTIF(C:C,C422)),"",C422) | 420 | mst_pat_list_layout | テーブル追加 | 追加 | YSK | 43552 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C423="",COUNTIF($C$3:C423,C423)<COUNTIF(C:C,C423)),"",C423) | 421 | mst_device_set_info_default | テーブル追加 | 変更 | YSK | 43552 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C424="",COUNTIF($C$3:C424,C424)<COUNTIF(C:C,C424)),"",C424) | 422 | pat_personal_main | 以下のカラムを追加<br>・カラム追加（原疾患コード） | 変更 | YSK | 43552 | 1.0.0.0 |  | ■ | × | × | × |
| mst_va | 423 | mst_va | 以下の備考を変更<br>・VA方向 | 変更 | YSK | 43552 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C426="",COUNTIF($C$3:C426,C426)<COUNTIF(C:C,C426)),"",C426) | 424 | pat_treatment_pattern | 以下のカラムの外部キー制約を追加<br>・施設コード | 変更 | YSK | 43553 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C427="",COUNTIF($C$3:C427,C427)<COUNTIF(C:C,C427)),"",C427) | 425 | ord_main | インデックス(idx_ord_main_01)を追加 | 変更 | ESM | 43553 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C428="",COUNTIF($C$3:C428,C428)<COUNTIF(C:C,C428)),"",C428) | 426 | ord_checklist | 以下のカラムを変更<br>・rst_checklist_info<br>　JSONのキーを変更、@ord_checklistシートにも反映 | 変更 | TDC | 43557 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C429="",COUNTIF($C$3:C429,C429)<COUNTIF(C:C,C429)),"",C429) | 427 | mst_machine | 装置オプション（machine_option）カラムの内容を<br>@mst_machineシートに記載 | 変更 | TDC | 43557 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C430="",COUNTIF($C$3:C430,C430)<COUNTIF(C:C,C430)),"",C430) | 428 | ord_main | 以下のカラムを変更<br>・rst_weight_infoのJSON内容を変更<br>　weight_measure_beforeとweight_measure_afterを追加 | 変更 | TDC | 43558 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C431="",COUNTIF($C$3:C431,C431)<COUNTIF(C:C,C431)),"",C431) | 429 | mst_alarm_notification | 以下のカラムを追加<br>・is_notice_mon~sun<br>・start_time_mon~sun<br>・end_time_mon~sun<br>・is_next_day_mon~sun | 変更 | ESM | 43566 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C432="",COUNTIF($C$3:C432,C432)<COUNTIF(C:C,C432)),"",C432) | 430 | mst_machine_record | 以下のカラムを追加<br>・is_default<br>・log_class<br>・target_model | 変更 | ESM | 43566 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C433="",COUNTIF($C$3:C433,C433)<COUNTIF(C:C,C433)),"",C433) | 431 | ord_checklist | 以下のカラムを変更<br>・rst_checklist_info<br>　amountとunitを追加、@ord_checklistシートにも反映 | 変更 | TDC | 43566 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C434="",COUNTIF($C$3:C434,C434)<COUNTIF(C:C,C434)),"",C434) | 432 | ord_weight_scale | 以下のカラムを追加<br>・treatment_cd<br>・treatment_name | 変更 | TDC | 43567 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C435="",COUNTIF($C$3:C435,C435)<COUNTIF(C:C,C435)),"",C435) | 433 | mst_pat_viewer_layout | disp_item_infoのカラムを変更<br>・デフォルト値を定義<br>・表示項目の追加<br>　（@mst_pat_viewer_layoutシートに記載 | 変更 | YSK | 43567 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C436="",COUNTIF($C$3:C436,C436)<COUNTIF(C:C,C436)),"",C436) | 434 | mnt_motion_record | 以下のカラムを変更<br>・is_correctionの備考を変更<br>　候補値を追記 | 変更 | MOR | 43565 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C437="",COUNTIF($C$3:C437,C437)<COUNTIF(C:C,C437)),"",C437) | 435 | mnt_machine_state | 以下のカラムを変更<br>・m_notice_cntの備考を変更<br>　説明更新 | 変更 | MOR | 43565 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C438="",COUNTIF($C$3:C438,C438)<COUNTIF(C:C,C438)),"",C438) | 436 | mst_personal_user | 以下のカラムを追加<br>・administrator | 変更 | MOR | 43565 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C439="",COUNTIF($C$3:C439,C439)<COUNTIF(C:C,C439)),"",C439) | 437 | sys_master_define | 以下のカラムを追加<br>・edit_level | 変更 | MOR | 43565 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C440="",COUNTIF($C$3:C440,C440)<COUNTIF(C:C,C440)),"",C440) | 438 | mni_monitor | 以下のカラムを変更<br>・data_typeの備考を修正 | 変更 | TDC | 43571 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C441="",COUNTIF($C$3:C441,C441)<COUNTIF(C:C,C441)),"",C441) | 439 | ord_main | 以下のカラムを修正<br>・rst_weight_infoのJSON内容から再循環率1～5を削除 | 変更 | TDC | 43571 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C442="",COUNTIF($C$3:C442,C442)<COUNTIF(C:C,C442)),"",C442) | 440 | mnt_motion_record | 緊急発報ステータスに以下のコードを追加<br>  2：メール送信対象なし | 変更 | ESM | 43572 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C443="",COUNTIF($C$3:C443,C443)<COUNTIF(C:C,C443)),"",C443) | 441 | pat_main | 以下のカラムの備考を変更<br>・device_set_info<br>・acceptance_status_info | 変更 | YSK | 43574 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C444="",COUNTIF($C$3:C444,C444)<COUNTIF(C:C,C444)),"",C444) | 442 | ord_main | JSON内のデータ型を記載 | 変更 | YSK | 43574 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C445="",COUNTIF($C$3:C445,C445)<COUNTIF(C:C,C445)),"",C445) | 443 | mst_treatment | 以下のカラムを変更<br>・治療条件設定の備考を変更<br>　（「@mst_treatment」シート追加） | 変更 | YSK | 43574 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C446="",COUNTIF($C$3:C446,C446)<COUNTIF(C:C,C446)),"",C446) | 444 | mst_personal_user | 以下のカラムを追加<br>・is_disp<br>・is_del | 変更 | MOR | 43578 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C447="",COUNTIF($C$3:C447,C447)<COUNTIF(C:C,C447)),"",C447) | 445 | mst_user | 以下のカラムを追加<br>・is_disp<br>・is_del | 変更 | MOR | 43578 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C448="",COUNTIF($C$3:C448,C448)<COUNTIF(C:C,C448)),"",C448) | 446 | mst_alarm_notification | 以下のカラムにNOTNULL制約とデフォルト値を設定<br>・target_machine_record | 変更 | ESM | 43580 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C449="",COUNTIF($C$3:C449,C449)<COUNTIF(C:C,C449)),"",C449) | 447 | mst_destination_group | 以下のカラムにNOTNULL制約とデフォルト値を設定<br>・destination_target | 変更 | ESM | 43580 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C450="",COUNTIF($C$3:C450,C450)<COUNTIF(C:C,C450)),"",C450) | 448 | ord_main | 以下のカラムのJSON形式フォーマットの変更、および、データ型を記載<br>・rst_vital_info | 変更 | ESM | 43593 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C451="",COUNTIF($C$3:C451,C451)<COUNTIF(C:C,C451)),"",C451) | 449 | sys_system_define | マスタデータを1件追加<br>　（「@sys_system_define」シート参照） | 変更 | MOR | 43595 | 1.0.0.0 |  | ■ | × | × | × |
| ord_schedule | 450 | ord_schedule | 主キーにord_noを追加 | 変更 | YSK | 43601 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C453="",COUNTIF($C$3:C453,C453)<COUNTIF(C:C,C453)),"",C453) | 451 | pat_unique | 以下のカラムのJSON形式フォーマットの変更、および、データ型を記載<br>・medical_hst_info | 変更 | YSK | 43601 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C454="",COUNTIF($C$3:C454,C454)<COUNTIF(C:C,C454)),"",C454) | 452 | sys_facility_setting | テーブル追加 | 追加 | YSK | 43601 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C455="",COUNTIF($C$3:C455,C455)<COUNTIF(C:C,C455)),"",C455) | 453 | ord_weight_scale | 以下のカラムを追加<br>・device_mode<br>・print_content<br>・print_status<br>・print_error_message | 変更 | TDC | 43602 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C456="",COUNTIF($C$3:C456,C456)<COUNTIF(C:C,C456)),"",C456) | 454 | mst_weight | ＠mst_weightのJSONカラム記述を修正 | 変更 | TDC | 43602 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C457="",COUNTIF($C$3:C457,C457)<COUNTIF(C:C,C457)),"",C457) | 455 | mst_treatment_status_disp_item | テーブル追加 | 新規 | TDC | 43602 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C458="",COUNTIF($C$3:C458,C458)<COUNTIF(C:C,C458)),"",C458) | 456 | mst_facility_setting | ・テーブル名を変更<br>　sys_facility_setting ⇒ mst_facility_setting<br>・カラム名を変更<br>　service_cd ⇒ function_cd<br>・function_cdの備考修正<br>・シート追加<br>　機能コード一覧<br>・「@mst_facility_setting」シート修正<br>　機能コードを「機能コード一覧」に合わせる<br>　説明 変更 | 変更 | YSK | 43606 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C459="",COUNTIF($C$3:C459,C459)<COUNTIF(C:C,C459)),"",C459) | 457 | sys_system_define | ・サービスコードの備考に項目を追加<br>・マスタデータを1件追加<br>　（「@sys_system_define」シート参照） | 変更 | YSK | 43606 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C460="",COUNTIF($C$3:C460,C460)<COUNTIF(C:C,C460)),"",C460) | 458 | mst_facility_setting | @mst_facility_settingの管理番号3を追加 | 変更 | ESM | 43606 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C461="",COUNTIF($C$3:C461,C461)<COUNTIF(C:C,C461)),"",C461) | 459 | ord_monitor | テーブル追加 | 新規 | ESM | 43607 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C462="",COUNTIF($C$3:C462,C462)<COUNTIF(C:C,C462)),"",C462) | 460 | pat_personal_main | カラム名を変更<br>　primary disease_cd ⇒ primary_disease_cd<br>   ※「_(アンダーバー)」が抜けていた | 変更 | YSK | 43608 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C463="",COUNTIF($C$3:C463,C463)<COUNTIF(C:C,C463)),"",C463) | 461 | mst_facility_setting | 以下のカラムを追加<br>・is_disp<br>・is_del<br>・reg_date | 変更 | YSK | 43608 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C464="",COUNTIF($C$3:C464,C464)<COUNTIF(C:C,C464)),"",C464) | 462 | mst_comsv_setting | 以下のカラムを追加<br>・is_disp<br>・is_del | 変更 | TDC | 43608 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C465="",COUNTIF($C$3:C465,C465)<COUNTIF(C:C,C465)),"",C465) | 463 | mst_comsv_setting | 以下のカラムを削除<br>・is_leave (pat_timingと用途重複のため) | 変更 | TDC | 43608 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C466="",COUNTIF($C$3:C466,C466)<COUNTIF(C:C,C466)),"",C466) | 464 | mst_personal_tab_define | テーブル追加 | 新規 | ESM | 43613 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C467="",COUNTIF($C$3:C467,C467)<COUNTIF(C:C,C467)),"",C467) | 465 | mst_job | テーブル追加 | 追加 | MOR | 43614 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C468="",COUNTIF($C$3:C468,C468)<COUNTIF(C:C,C468)),"",C468) | 466 | mst_report | テーブル追加 | 追加 | TDC | 43622 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C469="",COUNTIF($C$3:C469,C469)<COUNTIF(C:C,C469)),"",C469) | 467 | mst_printer | テーブル追加 | 追加 | TDC | 43622 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C470="",COUNTIF($C$3:C470,C470)<COUNTIF(C:C,C470)),"",C470) | 468 | ord_main | 以下のカラムのJSON形式フォーマットを変更<br>・指示：投与薬剤情報 | 変更 | YSK | 43627 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C471="",COUNTIF($C$3:C471,C471)<COUNTIF(C:C,C471)),"",C471) | 469 | sys_function | テーブル追加 | 追加 | MOR | 43628 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C472="",COUNTIF($C$3:C472,C472)<COUNTIF(C:C,C472)),"",C472) | 470 | mst_user | user_settingsのカラムを変更<br>・使用可能機能コード(authorized_functions)を追加<br>　（@mst_userシートに記載） | 変更 | MOR | 43628 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C473="",COUNTIF($C$3:C473,C473)<COUNTIF(C:C,C473)),"",C473) | 471 | mst_user | user_settingsのカラムを変更<br>・予実リスト表示形式(ind_rst_pattern)を追加<br>　（@mst_userシートに記載） | 変更 | ESM | 43640 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C474="",COUNTIF($C$3:C474,C474)<COUNTIF(C:C,C474)),"",C474) | 472 | mst_round_type | テーブル追加 | 新規 | ESM | 43642 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C475="",COUNTIF($C$3:C475,C475)<COUNTIF(C:C,C475)),"",C475) | 473 | ord_main | rst_rounds_infoのJSONを記入 | 変更 | ESM | 43642 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C476="",COUNTIF($C$3:C476,C476)<COUNTIF(C:C,C476)),"",C476) | 474 | mst_user | user_settingsのカラムを変更<br>・許可権限コード(authorized_authorities)を追加<br>　（@mst_userシートに記載） | 変更 | ESM | 43650 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C477="",COUNTIF($C$3:C477,C477)<COUNTIF(C:C,C477)),"",C477) | 475 | mst_complaint | テーブル追加 | 新規 | ESM | 43651 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C478="",COUNTIF($C$3:C478,C478)<COUNTIF(C:C,C478)),"",C478) | 476 | mst_comp_treatment | テーブル追加 | 新規 | ESM | 43651 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C479="",COUNTIF($C$3:C479,C479)<COUNTIF(C:C,C479)),"",C479) | 477 | mst_device_set_info_default | 以下のカラムの備考を変更<br>・device_set_info<br>「@mst_device_set_info_default」シート追加 | 変更 | YSK | 43655 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C480="",COUNTIF($C$3:C480,C480)<COUNTIF(C:C,C480)),"",C480) | 478 | pat_main | ・device_set_infoのJSONキー追加<br>「@device_set_info」シート修正 | 変更 | YSK | 43655 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C481="",COUNTIF($C$3:C481,C481)<COUNTIF(C:C,C481)),"",C481) | 479 | mst_bbs_kind | テーブル追加 | 新規 | YSK | 43655 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C482="",COUNTIF($C$3:C482,C482)<COUNTIF(C:C,C482)),"",C482) | 480 | bbs_info | テーブル追加<br>※「機能コード一覧」シートに機能コード追加 | 新規 | YSK | 43655 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C483="",COUNTIF($C$3:C483,C483)<COUNTIF(C:C,C483)),"",C483) | 481 | pat_event | 以下のカラムを追加<br>・bbs_ctl_no<br>・fn_ctl_no | 変更 | YSK | 43657 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C484="",COUNTIF($C$3:C484,C484)<COUNTIF(C:C,C484)),"",C484) | 482 | mst_facility_setting | @mst_facility_settingシートに「透析困難リセット機能」の定義を追加 | 変更 | XCT | 43662 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C485="",COUNTIF($C$3:C485,C485)<COUNTIF(C:C,C485)),"",C485) | 483 | pat_personal_main | other_contact_infoのカラムを変更<br>・セイ（last_name_kana）を追加<br>・メイ（first_name_kana）を追加<br>以下のカラムを追加<br>・temporary_dialysis_cd | 変更 | XCT | 43656 | 1.0.0.0 |  | ■ | × | × | × |
| mst_temporary_dialysis | 484 | mst_temporary_dialysis | テーブル追加 | 新規 | XCT | 43656 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C487="",COUNTIF($C$3:C487,C487)<COUNTIF(C:C,C487)),"",C487) | 485 | mst_monitor_graph | テーブル追加 | 新規 | ESM | 43665 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C488="",COUNTIF($C$3:C488,C488)<COUNTIF(C:C,C488)),"",C488) | 486 | sys_personal_settings_define | テーブル追加 | 新規 | ESM | 43665 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C489="",COUNTIF($C$3:C489,C489)<COUNTIF(C:C,C489)),"",C489) | 487 | mst_personal_tab_define | 「モード」カラムの追加 | 変更 | ESM | 43665 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C490="",COUNTIF($C$3:C490,C490)<COUNTIF(C:C,C490)),"",C490) | 488 | mst_user | user_settingsのカラムを変更<br>・共通設定タブ個人設定値(personal_settings)を追加<br>　（@mst_userシートに記載） | 変更 | ESM | 43665 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C491="",COUNTIF($C$3:C491,C491)<COUNTIF(C:C,C491)),"",C491) | 489 | sys_personal_settings_define | UNIQUE制約追加 | 変更 | ESM | 43669 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C492="",COUNTIF($C$3:C492,C492)<COUNTIF(C:C,C492)),"",C492) | 490 | mst_user | user_settingsのカラムを変更<br>・権限の凡例を追加<br>　（@mst_userシートに記載）<br>　（@権限コードを追加） | 変更 | ESM | 43669 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C493="",COUNTIF($C$3:C493,C493)<COUNTIF(C:C,C493)),"",C493) | 491 | sys_master_define | edit_levelの備考を修正<br>・edit_level='5'を追加 | 変更 | MOR | 43670 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C494="",COUNTIF($C$3:C494,C494)<COUNTIF(C:C,C494)),"",C494) | 492 | sys_facility_setting | テーブル追加 | 新規 | MOR | 43670 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C495="",COUNTIF($C$3:C495,C495)<COUNTIF(C:C,C495)),"",C495) | 493 | mst_facility_setting | sys_facility_settingの追加による<br>カラム削除とsys_facility_settingへの参照用キーの追加<br>・管理番号(ctl_no)を削除<br>・機能コード(function_cd)を削除<br>・名称(name)を削除<br>・説明(description)を削除<br>・編集可否フラグ(is_editable)を削除<br>・表示フラグ(is_disp)を削除<br>・削除フラグ(is_del)を削除<br>・施設設定番号(facility_setting_no)を追加<br>旧@mst_facility_settingの情報をもとに@sys_facility_settingに設定情報を仮配置 | 変更 | MOR | 43670 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C496="",COUNTIF($C$3:C496,C496)<COUNTIF(C:C,C496)),"",C496) | 494 | ord_main | ind_equip_info（、rst_equip_info）カラムにキーequip_typeを追加 | 変更 | YSK | 43670 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C497="",COUNTIF($C$3:C497,C497)<COUNTIF(C:C,C497)),"",C497) | 495 | mst_report | 「帳票区分」カラムの追加 | 変更 | ESM | 43671 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C498="",COUNTIF($C$3:C498,C498)<COUNTIF(C:C,C498)),"",C498) | 496 | mst_weight | @mst_weightシートの音声ガイダンス設定JSON記載 | 変更 | TDC | 43672 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C499="",COUNTIF($C$3:C499,C499)<COUNTIF(C:C,C499)),"",C499) | 497 | mst_pat_list_layout | 以下のカラムを変更<br>・disp_item_info<br>・occupations<br>「@マルチ患者レイアウトマスタ」シート追加 | 変更 | YSK | 43678 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C500="",COUNTIF($C$3:C500,C500)<COUNTIF(C:C,C500)),"",C500) | 498 | mst_preparation_medicine | 以下のカラムを追加<br>・fn_set_medicine_cd | 変更 | YSK | 43678 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C501="",COUNTIF($C$3:C501,C501)<COUNTIF(C:C,C501)),"",C501) | 499 | mst_job | 以下のカラムを追加<br>・fn_job_class_cd | 変更 | YSK | 43678 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C502="",COUNTIF($C$3:C502,C502)<COUNTIF(C:C,C502)),"",C502) | 500 | mst_personal_user | 以下のカラムを追加<br>・fn_staff_cd | 変更 | YSK | 43678 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C503="",COUNTIF($C$3:C503,C503)<COUNTIF(C:C,C503)),"",C503) | 501 | ord_main | 以下のカラムを追加<br>・fn_plural | 変更 | YSK | 43678 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C504="",COUNTIF($C$3:C504,C504)<COUNTIF(C:C,C504)),"",C504) | 502 | mst_machine | 以下のカラムを追加<br>・fn_device_no | 変更 | YSK | 43678 | 1.0.0.0 |  | ■ | × | × | × |
| mst_disease | 503 | mst_disease | 以下のカラムを追加<br>・is_die | 変更 | YSK | 43678 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C506="",COUNTIF($C$3:C506,C506)<COUNTIF(C:C,C506)),"",C506) | 504 | pat_unique | 以下のカラムのJSON形式フォーマットの変更、および、データ型を記載<br>・physical_info | 変更 | YSK | 43678 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C507="",COUNTIF($C$3:C507,C507)<COUNTIF(C:C,C507)),"",C507) | 505 | mst_pat_viewer_layout | 以下のカラムを追加<br>・disp_period_class<br><br>以下のカラムを変更<br>・disp_item_info<br>「@mst_pat_viewer_layout」シート修正 | 変更 | YSK | 43678 | 1.0.0.0 |  | ■ | × | × | × |
| mst_notification_message | 506 | mst_notification_message | テーブル追加 | 新規 | ESM | 43679 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C509="",COUNTIF($C$3:C509,C509)<COUNTIF(C:C,C509)),"",C509) | 507 | mnt_notification_message | テーブル追加 | 新規 | ESM | 43679 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C510="",COUNTIF($C$3:C510,C510)<COUNTIF(C:C,C510)),"",C510) | 508 | mnt_notification_status | テーブル追加 | 新規 | ESM | 43679 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C511="",COUNTIF($C$3:C511,C511)<COUNTIF(C:C,C511)),"",C511) | 509 | sys_personal_settings_define | @sys_personal_settings_define に定義済の設定項目の記述を追加 | 変更 | ESM | 43679 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C512="",COUNTIF($C$3:C512,C512)<COUNTIF(C:C,C512)),"",C512) | 510 | sys_facility_setting | 施設設定番号(facility_setting_no)の値を<br>1001からの連番想定に変更し、対象データの一部を変更 | 変更 | MOR | 43685 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C513="",COUNTIF($C$3:C513,C513)<COUNTIF(C:C,C513)),"",C513) | 511 | mst_job | 以下のカラムを追加<br>・default_authorized_authorities | 変更 | MOR | 43685 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C514="",COUNTIF($C$3:C514,C514)<COUNTIF(C:C,C514)),"",C514) | 512 | mst_checklist | @mst_checklistに定義したJSON項目を修正 | 変更 | TDC | 43686 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C515="",COUNTIF($C$3:C515,C515)<COUNTIF(C:C,C515)),"",C515) | 513 | mst_weight_print | テーブル未使用のため削除<br>（体重計印刷項目は項目ごとの処理が大きく異なり、マスタでの管理が難しいため） | 変更 | TDC | 43686 | 1.0.0.0 |  | ■ | × | × | × |
| mst_alarm_notification | 514 | mst_alarm_notification | 以下のカラムを追加<br>・sms_tel | 変更 | TDC | 43686 | 1.0.0.0 |  | ■ | × | × | × |
| mst_function_report | 515 | mst_function_report | テーブル追加 | 新規 | ESM | 43697 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C518="",COUNTIF($C$3:C518,C518)<COUNTIF(C:C,C518)),"",C518) | 516 | mst_report | 「抽出条件」カラムの追加<br>「@mst_report」シートの追加 | 変更 | ESM | 43697 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C519="",COUNTIF($C$3:C519,C519)<COUNTIF(C:C,C519)),"",C519) | 517 | sys_facility_setting | @sys_facility_settingに定義（1005）を追加 | 変更 | ESM | 43700 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C520="",COUNTIF($C$3:C520,C520)<COUNTIF(C:C,C520)),"",C520) | 518 | sys_system_define | マスタデータを1件追加<br>　（「@sys_system_define」シート参照） | 変更 | XCT | 43703 | 1.0.0.0 |  | ■ | × | × | × |
| mst_destination_group | 519 | mst_destination_group | 以下のカラムを追加<br>・is_notice | 変更 | XCT | 43703 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C522="",COUNTIF($C$3:C522,C522)<COUNTIF(C:C,C522)),"",C522) | 520 | sys_facility_setting | @sys_facility_settingの1005定義の初期値を変更 | 変更 | ESM | 43705 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C523="",COUNTIF($C$3:C523,C523)<COUNTIF(C:C,C523)),"",C523) | 521 | bbs_info | 以下のカラムのJSON形式フォーマットの変更、および、データ型を記載<br>・pat_info<br>・staff_info | 変更 | YSK | 43705 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C524="",COUNTIF($C$3:C524,C524)<COUNTIF(C:C,C524)),"",C524) | 522 | mst_user | @mst_user にユーザ設定（画面フレーム分割）の定義を追加 | 変更 | ESM | 43706 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C525="",COUNTIF($C$3:C525,C525)<COUNTIF(C:C,C525)),"",C525) | 523 | sys_facility_setting | @sys_facility_settingに定義（1006）を追加 | 変更 | ESM | 43707 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C526="",COUNTIF($C$3:C526,C526)<COUNTIF(C:C,C526)),"",C526) | 524 | mst_pat_event_category | テーブル追加 | 新規 | TDC | 43711 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C527="",COUNTIF($C$3:C527,C527)<COUNTIF(C:C,C527)),"",C527) | 525 | mst_pat_event_sub_category | テーブル追加 | 新規 | TDC | 43711 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C528="",COUNTIF($C$3:C528,C528)<COUNTIF(C:C,C528)),"",C528) | 526 | mst_pat_event_data_template | テーブル追加 | 新規 | TDC | 43711 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C529="",COUNTIF($C$3:C529,C529)<COUNTIF(C:C,C529)),"",C529) | 527 | mst_trend_graph_template | テーブル追加 | 新規 | TDC | 43711 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C530="",COUNTIF($C$3:C530,C530)<COUNTIF(C:C,C530)),"",C530) | 528 | mst_trend_graph_monitor_set | テーブル追加 | 新規 | TDC | 43711 | 1.0.0.0 |  | ■ | × | × | × |
| mst_printer | 529 | mst_printer | 以下のカラムを追加<br>・disp_printer_name | 変更 | TDC | 43711 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C532="",COUNTIF($C$3:C532,C532)<COUNTIF(C:C,C532)),"",C532) | 530 | sys_facility_setting | @sys_facility_settingに定義（1007～1014）を追加 | 変更 | MOR | 43718 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C533="",COUNTIF($C$3:C533,C533)<COUNTIF(C:C,C533)),"",C533) | 531 | mst_pat_event_data_template | 以下のカラムを追加<br>・is_observe | 変更 | TDC | 43718 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C534="",COUNTIF($C$3:C534,C534)<COUNTIF(C:C,C534)),"",C534) | 532 | bbs_info | 以下のカラムのJSON形式フォーマットの変更<br>・file_info | 変更 | YSK | 43720 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C535="",COUNTIF($C$3:C535,C535)<COUNTIF(C:C,C535)),"",C535) | 533 | sys_facility_setting | @sys_facility_settingに定義（1015～1017）を追加<br>1010、1011、1013の記載ミスを修正 | 変更 | MOR | 43725 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C536="",COUNTIF($C$3:C536,C536)<COUNTIF(C:C,C536)),"",C536) | 534 | mst_spitz | テーブル追加 | 新規 | MOR | 43725 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C537="",COUNTIF($C$3:C537,C537)<COUNTIF(C:C,C537)),"",C537) | 535 | mst_exam_item | テーブル追加 | 新規 | MOR | 43725 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C538="",COUNTIF($C$3:C538,C538)<COUNTIF(C:C,C538)),"",C538) | 536 | mst_exam_set | テーブル追加 | 新規 | MOR | 43725 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C539="",COUNTIF($C$3:C539,C539)<COUNTIF(C:C,C539)),"",C539) | 537 | pat_exam_pattern | テーブル追加 | 新規 | MOR | 43725 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C540="",COUNTIF($C$3:C540,C540)<COUNTIF(C:C,C540)),"",C540) | 538 | pat_exam_main | テーブル追加 | 新規 | MOR | 43725 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C541="",COUNTIF($C$3:C541,C541)<COUNTIF(C:C,C541)),"",C541) | 539 | mst_rad_set | テーブル追加 | 新規 | MOR | 43725 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C542="",COUNTIF($C$3:C542,C542)<COUNTIF(C:C,C542)),"",C542) | 540 | pat_rad_pattern | テーブル追加 | 新規 | MOR | 43725 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C543="",COUNTIF($C$3:C543,C543)<COUNTIF(C:C,C543)),"",C543) | 541 | pat_rad_main | テーブル追加 | 新規 | MOR | 43725 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C544="",COUNTIF($C$3:C544,C544)<COUNTIF(C:C,C544)),"",C544) | 542 | mst_report | 「プリンター初期値」カラムの追加 | 変更 | ESM | 43727 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C545="",COUNTIF($C$3:C545,C545)<COUNTIF(C:C,C545)),"",C545) | 543 | sys_data_set | テーブル追加 | 新規 | ESM | 43727 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C546="",COUNTIF($C$3:C546,C546)<COUNTIF(C:C,C546)),"",C546) | 544 | mst_pat_event_data_template | @mst_pat_event_data_template<br>JSON定義を記載 | 変更 | TDC | 43728 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C547="",COUNTIF($C$3:C547,C547)<COUNTIF(C:C,C547)),"",C547) | 545 | pat_event | テーブル構成を全体的に変更 | 変更 | TDC | 43728 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C548="",COUNTIF($C$3:C548,C548)<COUNTIF(C:C,C548)),"",C548) | 546 | mst_taboo_allergy | 以下のカラムの備考内容を変更<br>・detail_info（JSON内容に禁忌対象名を追加） | 変更 | XCT | 43733 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C549="",COUNTIF($C$3:C549,C549)<COUNTIF(C:C,C549)),"",C549) | 547 | pat_main | 以下のカラムの備考内容を変更<br>・taboo_allergy_info（JSON内容の対象区分に「5:フリーワード」を追加） | 変更 | XCT | 43733 | 1.0.0.0 | 実装上未使用だが、禁忌・アレルギーマスタと記載レベルを合わせるため追加 | ■ | × | × | × |
| =IF(OR(C550="",COUNTIF($C$3:C550,C550)<COUNTIF(C:C,C550)),"",C550) | 548 | sys_master_define | カラム情報の保有イメージを追記 | 変更 | XCT | 43733 | 1.0.0.0 | マスタメンテナンス画面の固定列定義 | ■ | × | × | × |
| =IF(OR(C551="",COUNTIF($C$3:C551,C551)<COUNTIF(C:C,C551)),"",C551) | 549 | mst_exam_item | カラム追加<br>・default_calc_exam_item_cd<br>機能コード一覧に以下を追加<br>・検査依頼<br>・放射線検査依頼 | 変更 | MOR | 43734 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C552="",COUNTIF($C$3:C552,C552)<COUNTIF(C:C,C552)),"",C552) | 550 | pat_exam_main | JSON定義(@pat_exam_main)を更新 | 変更 | MOR | 43734 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C553="",COUNTIF($C$3:C553,C553)<COUNTIF(C:C,C553)),"",C553) | 551 | mst_exam_set | JSON定義(@mst_exam_set)を更新 | 変更 | MOR | 43734 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C554="",COUNTIF($C$3:C554,C554)<COUNTIF(C:C,C554)),"",C554) | 552 | pat_exam_pattern | JSON定義(@pat_exam_pattern)を更新<br>reg_exam_date の not ull 制約を外しました。 | 変更 | MOR | 43734 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C555="",COUNTIF($C$3:C555,C555)<COUNTIF(C:C,C555)),"",C555) | 553 | pat_rad_main | JSON定義(@pat_rad_main)を更新 | 変更 | MOR | 43734 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C556="",COUNTIF($C$3:C556,C556)<COUNTIF(C:C,C556)),"",C556) | 554 | pat_group | テーブル追加 | 新規 | FPT | 43735 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C557="",COUNTIF($C$3:C557,C557)<COUNTIF(C:C,C557)),"",C557) | 555 | pat_group_detail | テーブル追加 | 新規 | FPT | 43735 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C558="",COUNTIF($C$3:C558,C558)<COUNTIF(C:C,C558)),"",C558) | 556 | mst_pat_calendar_layout | テーブル追加<br>※「機能コード一覧」シートに機能コード追加<br>※「@mst_pat_calendar_layout」シート追加 | 新規 | YSK | 43740 | 1.0.0.0 |  | ■ | × | × | × |
| mst_pat_hash | 557 | mst_pat_hash | テーブル追加<br>※「機能コード一覧」シートに機能コード追加 | 新規 | MOR | 43742 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C560="",COUNTIF($C$3:C560,C560)<COUNTIF(C:C,C560)),"",C560) | 558 | mst_facility_hash | テーブルスペース名、ユーザー名の誤記を修正<br>DB5→DB4<br>nkk5→nkk4 | 変更 | MOR | 43742 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C561="",COUNTIF($C$3:C561,C561)<COUNTIF(C:C,C561)),"",C561) | 559 | mnt_device_edge_manage | テーブル追加<br>※「機能コード一覧」シートに機能コード追加 | 新規 | TDC | 43742 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C562="",COUNTIF($C$3:C562,C562)<COUNTIF(C:C,C562)),"",C562) | 560 | sys_facility_setting | @sys_facility_settingに定義（1018）を追加 | 変更 | TDC | 43742 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C563="",COUNTIF($C$3:C563,C563)<COUNTIF(C:C,C563)),"",C563) | 561 | pat_event | 以下のカラムを変更<br>・pat_idの型をbigintに修正 | 変更 | TDC | 43746 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C564="",COUNTIF($C$3:C564,C564)<COUNTIF(C:C,C564)),"",C564) | 562 | sys_system_define | @sys_system_defineにwindows用アプリケーション更新のための最新バージョン定義を追加<br>・7：帳票レイアウトデザイナアプリケーション<br>・8：体重計アプリケーション<br>・9：印刷サーバーアプリケーション | 新規 | TDC | 43746 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C565="",COUNTIF($C$3:C565,C565)<COUNTIF(C:C,C565)),"",C565) | 563 | mst_trend_graph_template | ＠mst_trend_graph_templateのJSON定義を修正 | 変更 | TDC | 43756 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C566="",COUNTIF($C$3:C566,C566)<COUNTIF(C:C,C566)),"",C566) | 564 | ord_main | 以下のカラムを追加<br>・treat_type(治療種別) | 変更 | YSK | 43767 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C567="",COUNTIF($C$3:C567,C567)<COUNTIF(C:C,C567)),"",C567) | 565 | sys_facility_setting | @sys_facility_settingに定義（1019、1020）を追加<br>並び順(disp_order)を変更 | 変更 | MOR | 43774 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C568="",COUNTIF($C$3:C568,C568)<COUNTIF(C:C,C568)),"",C568) | 566 | pat_ind_approve | 指示受け・承認機能のためのテーブル追加<br>※「機能コード一覧」シートに機能コード追加<br>028番の指示受け・承認 | 新規 | FPT | 43777 |  |  | ■ | × | × | × |
| =IF(OR(C569="",COUNTIF($C$3:C569,C569)<COUNTIF(C:C,C569)),"",C569) | 567 | mst_facility | 指示受け・承認機能のため、以下のカラムを追加<br>facility_type<br>bulk_approve | 変更 | FPT | 43777 |  |  | ■ | × | × | × |
| =IF(OR(C570="",COUNTIF($C$3:C570,C570)<COUNTIF(C:C,C570)),"",C570) | 568 | mst_bed | 以下のカラムを追加<br>・is_home_dialysis | 変更 | MOR | 43784 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C571="",COUNTIF($C$3:C571,C571)<COUNTIF(C:C,C571)),"",C571) | 569 | sys_system_define | @sys_system_defineシート更新<br>・管理番号4に在宅透析患者用のログインURLを追加<br>・管理番号10を追加 | 変更 | MOR | 43784 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C572="",COUNTIF($C$3:C572,C572)<COUNTIF(C:C,C572)),"",C572) | 570 | mst_user | 以下のカラムを追加<br>・pat_id | 変更 | MOR | 43784 | 1.0.0.0 |  | ■ | × | × | × |
| pat_hhd_pattern | 571 | pat_hhd_pattern | テーブル追加 | 新規 | MOR | 43784 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C574="",COUNTIF($C$3:C574,C574)<COUNTIF(C:C,C574)),"",C574) | 572 | sys_facility_setting | @sys_facility_settingに定義（1021）を追加 | 新規 | MOR | 43784 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C575="",COUNTIF($C$3:C575,C575)<COUNTIF(C:C,C575)),"",C575) | 573 | pat_personal_main | 以下のカラムを追加<br>・remote_monitor_service<br>・remote_monitor_user_id<br>・remote_monitor_user_pw | 新規 | MOR | 43784 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C576="",COUNTIF($C$3:C576,C576)<COUNTIF(C:C,C576)),"",C576) | 574 | pat_insurance | 患者情報の拡張（保険） | 新規 | FPT | 43784 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C577="",COUNTIF($C$3:C577,C577)<COUNTIF(C:C,C577)),"",C577) | 575 | mst_insurance | 保険マスタ | 新規 | FPT | 43784 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C578="",COUNTIF($C$3:C578,C578)<COUNTIF(C:C,C578)),"",C578) | 576 | mst_facility | 以下のカラムを削除しました。<br>facility_type<br>bulk_approve<br>以下のカラムを追加したました。<br>is_recesecon_disp<br>is_prescription_disp<br>advanced_settings | 変更 | FPT | 43784 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C579="",COUNTIF($C$3:C579,C579)<COUNTIF(C:C,C579)),"",C579) | 577 | sys_facility_setting | @sys_facility_settingに以下の定義を追加<br>定義（1022): ベッドコントロール<br>定義（1023): 受付・承認単位<br>定義（1024): 一括承認 | 新規 | FPT | 43788 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C580="",COUNTIF($C$3:C580,C580)<COUNTIF(C:C,C580)),"",C580) | 578 | mni_monitor | 以下のカラムを追加<br>　upd_staff_id | 変更 | ESM | 43789 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C581="",COUNTIF($C$3:C581,C581)<COUNTIF(C:C,C581)),"",C581) | 579 | sys_facility_setting | @sys_facility_settingに以下の定義を追加<br>定義（1025): デフォルト選択医師 | 新規 | MOR | 43791 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C582="",COUNTIF($C$3:C582,C582)<COUNTIF(C:C,C582)),"",C582) | 580 | pat_main | カラムに以下を追加<br>・車いす有無 | 新規 | MOR | 43791 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C583="",COUNTIF($C$3:C583,C583)<COUNTIF(C:C,C583)),"",C583) | 581 | sys_function | 機能コード一覧に以下を追加<br>・処方箋 | 新規 | MOR | 43791 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C584="",COUNTIF($C$3:C584,C584)<COUNTIF(C:C,C584)),"",C584) | 582 | pat_event | 以下のカラムを追加<br>letter_info<br>is_intro_letter | 変更 | FPT | 43802 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C585="",COUNTIF($C$3:C585,C585)<COUNTIF(C:C,C585)),"",C585) | 583 | mst_facility | @advanced_settings内容修正 | 変更 | FPT | 43802 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C586="",COUNTIF($C$3:C586,C586)<COUNTIF(C:C,C586)),"",C586) | 584 | ord_main | カラムに以下を追加<br>・実績：確定フラグ（is_confirm） | 変更 | ESM | 43802 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C587="",COUNTIF($C$3:C587,C587)<COUNTIF(C:C,C587)),"",C587) | 585 | mst_weight | @mst_weightシートの修正 | 変更 | TDC | 43803 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C588="",COUNTIF($C$3:C588,C588)<COUNTIF(C:C,C588)),"",C588) | 586 | sys_facility_setting | @sys_facility_settingに以下の定義を追加<br>定義（1026): 前体重時車いす測定順序<br>定義（1027): 後体重時車いす測定順序 | 新規 | TDC | 43803 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C589="",COUNTIF($C$3:C589,C589)<COUNTIF(C:C,C589)),"",C589) | 587 | sys_system_define | @sys_system_defineにwindows用アプリケーション更新のための最新バージョン定義を追加<br>・11：特殊浄化アプリケーション | 新規 | TDC | 43803 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C590="",COUNTIF($C$3:C590,C590)<COUNTIF(C:C,C590)),"",C590) | 588 | mst_comsv_setting | 以下のカラムを追加<br>offline_start_time<br>is_offline_auto_end<br>reload_next_pat_time<br>next_pat_mode<br>next_pat_mode_range | 変更 | TDC | 43803 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C591="",COUNTIF($C$3:C591,C591)<COUNTIF(C:C,C591)),"",C591) | 589 | mst_machine | オフラインに関する定義更新 | 変更 | NKK青田 | 43804 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C592="",COUNTIF($C$3:C592,C592)<COUNTIF(C:C,C592)),"",C592) | 590 | mst_treatment_set | 以下のカラムを追加<br>　ind_device_set_info | 変更 | MOR | 43796 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C593="",COUNTIF($C$3:C593,C593)<COUNTIF(C:C,C593)),"",C593) | 591 | sys_facility_setting | 以下のカラムの備考を変更<br>・input_type | 変更 | MOR | 43797 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C594="",COUNTIF($C$3:C594,C594)<COUNTIF(C:C,C594)),"",C594) | 592 | mst_medicine | 薬剤マスタに以下を追加<br>・換算フラグ<br>また、以下の項目の論理名を変更<br>・unit:指示単位<br>・unit_second:レセ単位<br>・unit_conberted_amount:指示単位換算量<br>・unit_converted_amount_second:レセ単位換算量<br>・anticoagulant_original_quantity:指示基準量<br>・after_anticoagulant_quanity:ML基準量 | 変更 | MOR | 43797 | 1.0.0.0 | 詳細の再修正あり | ■ | × | × | × |
| =IF(OR(C595="",COUNTIF($C$3:C595,C595)<COUNTIF(C:C,C595)),"",C595) | 593 | sys_facility_setting | 以下のカラムの備考を変更<br>・input_type<br>・option_value | 変更 | MOR | 43803 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C596="",COUNTIF($C$3:C596,C596)<COUNTIF(C:C,C596)),"",C596) | 594 | sys_facility_setting | @sys_facility_settingに以下の定義を追加<br>定義（1028): 薬剤・調整薬剤マスタ手技デフォルト<br>定義（1029): 薬剤・調整薬剤マスタ投与タイミングデフォルト | 変更 | MOR | 43803 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C597="",COUNTIF($C$3:C597,C597)<COUNTIF(C:C,C597)),"",C597) | 595 | mst_medicine_mix | テーブル追加 | 新規 | YSK | 43805 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C598="",COUNTIF($C$3:C598,C598)<COUNTIF(C:C,C598)),"",C598) | 596 | mst_medicine | 薬剤マスタに以下を追加<br>・投与タイミングコード(medicate_timing_cd)<br>・手技コード(procedure_cd) | 変更 | MOR | 43809 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C599="",COUNTIF($C$3:C599,C599)<COUNTIF(C:C,C599)),"",C599) | 597 | pat_main | 以下のカラムを追加<br>・共通診療情報(medical_care_info)<br>※pat_uniqueの同名カラムを移管 | 変更 | MOR | 43812 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C600="",COUNTIF($C$3:C600,C600)<COUNTIF(C:C,C600)),"",C600) | 598 | pat_unique | 以下のカラムを削除<br>・共通診療情報(medical_care_info)<br>※pat_mainに移管 | 変更 | MOR | 43812 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C601="",COUNTIF($C$3:C601,C601)<COUNTIF(C:C,C601)),"",C601) | 599 | mnt_if_edge_healthmon | テーブル追加 | 新規 | TEX | 43811 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C602="",COUNTIF($C$3:C602,C602)<COUNTIF(C:C,C602)),"",C602) | 600 | mst_coop_distribute | テーブル追加 | 新規 | TEX | 43815 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C603="",COUNTIF($C$3:C603,C603)<COUNTIF(C:C,C603)),"",C603) | 601 | mst_coop_facility | テーブル追加 | 新規 | TEX | 43811 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C604="",COUNTIF($C$3:C604,C604)<COUNTIF(C:C,C604)),"",C604) | 602 | mst_coop_layout | テーブル追加 | 新規 | TEX | 43811 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C605="",COUNTIF($C$3:C605,C605)<COUNTIF(C:C,C605)),"",C605) | 603 | mst_coop_layout_detail | テーブル追加 | 新規 | TEX | 43811 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C606="",COUNTIF($C$3:C606,C606)<COUNTIF(C:C,C606)),"",C606) | 604 | mst_if_edge | テーブル追加 | 新規 | TEX | 43811 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C607="",COUNTIF($C$3:C607,C607)<COUNTIF(C:C,C607)),"",C607) | 605 | sys_coop_journal | テーブル追加 | 新規 | TEX | 43811 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C608="",COUNTIF($C$3:C608,C608)<COUNTIF(C:C,C608)),"",C608) | 606 | mst_coop_distribute | typo修正<br>destribute -> distribute | 変更 | tex | 43819 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C609="",COUNTIF($C$3:C609,C609)<COUNTIF(C:C,C609)),"",C609) | 607 | mst_machine_type | 以下のカラムを追加<br>・通信種別(com_type)<br>・装置モード(treat_mode) | 変更 | MOR | 43819 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C610="",COUNTIF($C$3:C610,C610)<COUNTIF(C:C,C610)),"",C610) | 608 | mst_personal_user | 以下のカラムの備考を変更<br>・user_type | 変更 | MOR | 43819 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C611="",COUNTIF($C$3:C611,C611)<COUNTIF(C:C,C611)),"",C611) | 609 | mst_medicine_mix | 調整薬剤マスタに以下を追加<br>・投与タイミングコード(medicate_timing_cd)<br>・手技コード(procedure_cd) | 変更 | MOR | 43819 | 1.0.0.0 |  | ■ | × | × | × |
| mst_medicine_group | 610 | mst_medicine_group | テーブル追加 | 新規 | FPT | 43822 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C613="",COUNTIF($C$3:C613,C613)<COUNTIF(C:C,C613)),"",C613) | 611 | pat_event | 機能コード一覧シートに以下の追加<br>紹介状 | 新規 | FPT | 43822 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C614="",COUNTIF($C$3:C614,C614)<COUNTIF(C:C,C614)),"",C614) | 612 | mst_device_set_info_default | JSON定義(@mst_device_set_info_default)を更新<br>※静的静脈圧 | 変更 | YED | 43823 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C615="",COUNTIF($C$3:C615,C615)<COUNTIF(C:C,C615)),"",C615) | 613 | pat_main | JSON定義(@device_set_info)を更新<br>※静的静脈圧 | 変更 | YED | 43823 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C616="",COUNTIF($C$3:C616,C616)<COUNTIF(C:C,C616)),"",C616) | 614 | mnt_machine_state | JSON定義(@tmp_device_set_info)を更新<br>※静的静脈圧 | 変更 | YED | 43823 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C617="",COUNTIF($C$3:C617,C617)<COUNTIF(C:C,C617)),"",C617) | 615 | ord_main | JSON定義(@ind_device_set_info)を更新<br>※透析量プログラム | 変更 | YED | 43823 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C618="",COUNTIF($C$3:C618,C618)<COUNTIF(C:C,C618)),"",C618) | 616 | mst_add_monitor | テーブル追加 | 新規 | ESM | 43823 | 1.0.0.0 |  | ■ | × | × | × |
| sys_monitor_item | 617 | sys_monitor_item | テーブル追加<br>※mst_moni_itemが未使用だった為、テーブル名を変更 | 新規 | ESM | 43823 | 1.0.0.0 |  | ■ | × | × | × |
| ord_monitor | 618 | ord_monitor | 未使用となった為、テーブル削除<br>・「mni_monitorで管理」する旨を記載<br>・テーブル一覧に削除である旨を記載 | 変更 | ESM | 43823 | 1.0.0.0 |  | ■ | × | × | × |
| ord_vital | 619 | ord_vital | 未使用となった為、テーブル削除<br>・テーブル一覧に削除である旨を記載 | 変更 | ESM | 43823 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C622="",COUNTIF($C$3:C622,C622)<COUNTIF(C:C,C622)),"",C622) | 620 | ord_main | カラム追加<br>・指示ＤＷ ind_dw | 変更 | TDC | 43827 | 1.0.0.0 |  | ■ | × | × | × |
| mst_pat_viewer_layout | 621 | mst_pat_viewer_layout | `@mst_pat_viewer_layout修正<br>指示・実績DW表示用コード追加 | 変更 | TDC | 43829 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C624="",COUNTIF($C$3:C624,C624)<COUNTIF(C:C,C624)),"",C624) | 622 | mst_facility | 以下のカラムの削除<br>is_recesecon_disp<br>is_prescription_disp | 変更 | FPT | 43472 | 1.0.0.0 |  | ■ | × | × | × |
| personal_info_encrypt_jsonb | 623 | personal_info_encrypt_jsonb | ファンクション追加 | 新規 | YED | 43839 | 1.0.0.0 |  | =IFERROR(IF(C625=VLOOKUP(C625,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C625&"!A1","■"),""),"") | × | × | × |
| personal_info_decrypt_jsonb | 624 | personal_info_decrypt_jsonb | ファンクション追加 | 新規 | YED | 43839 | 1.0.0.0 |  | =IFERROR(IF(C626=VLOOKUP(C626,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C626&"!A1","■"),""),"") | × | × | × |
| mst_preparation_medicine | 625 | mst_preparation_medicine | 未使用となった為、テーブル削除 | 変更 | YED | 43839 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C628="",COUNTIF($C$3:C628,C628)<COUNTIF(C:C,C628)),"",C628) | 626 | pat_main | カラム追加<br>・スケジュール延長最終日(sch_ext_end_date)<br>・スケジュール延長処理ステータス(sch_ext_status) | 変更 | YED | 43839 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C629="",COUNTIF($C$3:C629,C629)<COUNTIF(C:C,C629)),"",C629) | 627 | sys_coop_journal | not Null属性の追加、default値の追加 | 変更 | TEX | 43840 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C630="",COUNTIF($C$3:C630,C630)<COUNTIF(C:C,C630)),"",C630) | 628 | ord_main | 以下のカラムを追加<br>・実績：特殊浄化回数(rst_purification_cnt) | 変更 | MOR | 43839 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C631="",COUNTIF($C$3:C631,C631)<COUNTIF(C:C,C631)),"",C631) | 629 | sys_facility | テーブル追加 | 新規 | MOR | 43839 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C632="",COUNTIF($C$3:C632,C632)<COUNTIF(C:C,C632)),"",C632) | 630 | mst_favorite_facility | テーブル追加 | 新規 | MOR | 43839 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C633="",COUNTIF($C$3:C633,C633)<COUNTIF(C:C,C633)),"",C633) | 631 | mnt_if_edge_healthmon | 機能コード一覧に追加<br>外部連携稼働ビューア | 変更 | FPT | 43482 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C634="",COUNTIF($C$3:C634,C634)<COUNTIF(C:C,C634)),"",C634) | 632 | sys_facility_setting | @sys_facility_settingに1030のカードログイン方式設定の追加 | 変更 | FPT | 43486 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C635="",COUNTIF($C$3:C635,C635)<COUNTIF(C:C,C635)),"",C635) | 633 | ord_main | addition_info列の追加<br>@ord_main.addition_infoシートの追加 | 変更 | FPT | 43486 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C636="",COUNTIF($C$3:C636,C636)<COUNTIF(C:C,C636)),"",C636) | 634 | mst_holiday | 新規追加 | 新規 | FPT | 43486 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C637="",COUNTIF($C$3:C637,C637)<COUNTIF(C:C,C637)),"",C637) | 635 | mst_addition | 新規追加 | 新規 | FPT | 43486 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C638="",COUNTIF($C$3:C638,C638)<COUNTIF(C:C,C638)),"",C638) | 636 | pat_main | addition_info列の内容の更新<br>@pat_main.addition_infoシートの追加 | 変更 | FPT | 43482 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C639="",COUNTIF($C$3:C639,C639)<COUNTIF(C:C,C639)),"",C639) | 637 | sys_facility_setting | @sys_facility_settingに以下の定義を追加<br>定義（1031): スケジュール延長処理開始時刻<br>定義（1032): スケジュール延長処理終了時刻 | 変更 | YED | 43859 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C640="",COUNTIF($C$3:C640,C640)<COUNTIF(C:C,C640)),"",C640) | 638 | mst_pat_event_sub_category | 以下のカラムを追加<br>・テンプレートコード（template_cd） | 変更 | TDC | 43859 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C641="",COUNTIF($C$3:C641,C641)<COUNTIF(C:C,C641)),"",C641) | 639 | mst_pat_event_data_template | 以下のカラムを削除<br>・カテゴリコード（category_cd）<br>過去に追加された以下のカラムが設計書に反映されていなかったので追加<br>・紹介状フラグ（is_intro_letter） | 変更 | TDC | 43859 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C642="",COUNTIF($C$3:C642,C642)<COUNTIF(C:C,C642)),"",C642) | 640 | pat_treatment_pattern | 以下のカラムの備考を変更（「隔週」の説明追加）<br>・治療種別<br>・適用開始日 | 変更 | YED | 43859 | 1.0.0.0 |  | ■ | × | × | × |
| mnt_if_edge_healthmon | 641 | mnt_if_edge_healthmon | 別文書への移動を記載 | 変更 | TEX | 43865 | 1.0.0.0 |  | ■ | × | × | × |
| mst_coop_distribute | 642 | mst_coop_distribute | 別文書への移動を記載 | 変更 | TEX | 43865 | 1.0.0.0 |  | ■ | × | × | × |
| mst_coop_facility | 643 | mst_coop_facility | 別文書への移動を記載 | 変更 | TEX | 43865 | 1.0.0.0 |  | ■ | × | × | × |
| mst_coop_layout | 644 | mst_coop_layout | 別文書への移動を記載 | 変更 | TEX | 43865 | 1.0.0.0 |  | ■ | × | × | × |
| mst_coop_layout_detail | 645 | mst_coop_layout_detail | 別文書への移動を記載 | 変更 | TEX | 43865 | 1.0.0.0 |  | ■ | × | × | × |
| mst_if_edge | 646 | mst_if_edge | 別文書への移動を記載 | 変更 | TEX | 43865 | 1.0.0.0 |  | ■ | × | × | × |
| sys_coop_journal | 647 | sys_coop_journal | 別文書への移動を記載 | 変更 | TEX | 43865 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C650="",COUNTIF($C$3:C650,C650)<COUNTIF(C:C,C650)),"",C650) | 648 | mst_pat_event_sub_category | 以下のカラムを追加<br>・利用種別（use_type） | 変更 | TDC | 43871 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C651="",COUNTIF($C$3:C651,C651)<COUNTIF(C:C,C651)),"",C651) | 649 | mst_pat_event_data_template | 以下のカラムを削除<br>・VAフラグ(is_va)<br>・観察記録フラグ(is_observe)<br>・紹介状フラグ(is_intro_letter)<br>@pat_event_data_template のJSON定義を修正 | 変更 | TDC | 43871 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C652="",COUNTIF($C$3:C652,C652)<COUNTIF(C:C,C652)),"",C652) | 650 | pat_event | 以下のカラムの論理名を変更<br>・イベント日時→イベント開始日時<br>以下のカラムを追加<br>・利用種別（use_type）<br>・イベント終了日時（event_end_date）<br>以下のカラムを削除<br>・VAフラグ(is_va)<br>・観察記録フラグ(is_observe)<br>・紹介状フラグ(is_intro_letter)<br>@pat_event のJSON定義を修正 | 変更 | TDC | 43871 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C653="",COUNTIF($C$3:C653,C653)<COUNTIF(C:C,C653)),"",C653) | 651 | sys_data_set | 以下のカラムのJSON構成を修正<br>・使用用途(use_application)<br>・帳票種別(report_class) | 変更 | TDC | 43871 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C654="",COUNTIF($C$3:C654,C654)<COUNTIF(C:C,C654)),"",C654) | 652 | mst_pat_event_data_template | @pat_event_data_template のJSON定義を修正 | 変更 | TDC | 43874 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C655="",COUNTIF($C$3:C655,C655)<COUNTIF(C:C,C655)),"",C655) | 653 | pat_event | @pat_event のJSON定義を修正 | 変更 | TDC | 43875 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C656="",COUNTIF($C$3:C656,C656)<COUNTIF(C:C,C656)),"",C656) | 654 | pat_main | 以下のjsonカラムにキーセットを追加<br>・インプラント情報（implant_info）に除去日(remove_date)を追加 | 変更 | MOR | 43875 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C657="",COUNTIF($C$3:C657,C657)<COUNTIF(C:C,C657)),"",C657) | 655 | pat_unique | 以下のカラムのJSON構成を修正<br>・既往歴情報(medical_hst_info)<br>・入外・転入出情報(in_out_visit_history_info) | 変更 | MOR | 43875 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C658="",COUNTIF($C$3:C658,C658)<COUNTIF(C:C,C658)),"",C658) | 656 | mst_facility | @advanced_settingsのJSON定義を修正<br>・isBvUfc(BV-UFC)<br>・isDialysisAmountProgram(透析量プログラム)<br>・enableHemoDialysis（在宅透析） | 変更 | MOR | 43875 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C659="",COUNTIF($C$3:C659,C659)<COUNTIF(C:C,C659)),"",C659) | 657 | pat_main | 以下のカラムの桁数を変更<br>・in_out_current_state(1→2)<br>・in_out_plan_state(1→2)<br>以下のカラムの備考を修正<br>・in_out_current_state<br>・in_out_plan_state<br>・in_out_plan_date | 変更 | MOR | 43882 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C660="",COUNTIF($C$3:C660,C660)<COUNTIF(C:C,C660)),"",C660) | 658 | pat_personal_main | 以下のカラムの備考を修正<br>・in_out_class | 変更 | MOR | 43882 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C661="",COUNTIF($C$3:C661,C661)<COUNTIF(C:C,C661)),"",C661) | 659 | sys_facility_setting | @sys_facility_settingの1021の以下の定義修正<br>・機能名<br>・入力方法<br>・オプション情報 | 変更 | MOR | 43882 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C662="",COUNTIF($C$3:C662,C662)<COUNTIF(C:C,C662)),"",C662) | 660 | mst_medicine | 以下のカラムの定義を変更<br>・unit_converted_amount<br>・unit_converted_amount_second<br>・anticoagulant_original_quantity<br>・after_anticoagulant_quantity<br>→Integer型からNumeric型へ<br><br>以下のカラムをInteger型で追加<br>・unit_decimal_point：指示単位小数部桁数<br>・unit_decimal_point_second：レセ単位小数部桁数 | 変更 | MOR | 43882 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C663="",COUNTIF($C$3:C663,C663)<COUNTIF(C:C,C663)),"",C663) | 661 | mst_medicine_mix | 以下のカラムの定義を変更<br>・amount_unit<br>・amount_ml<br>→Integer型からNumeric型へ<br><br>以下のカラムをInteger型で追加<br>・unit_decimal_point：指示単位小数部桁数<br><br>テーブルコメント変更：<br>　'調製薬剤マスタ' | 変更 | MOR | 43882 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C664="",COUNTIF($C$3:C664,C664)<COUNTIF(C:C,C664)),"",C664) | 662 | sys_facility_setting | @sys_facility_settingに以下の定義を追加<br>定義(1033): チェックリスト自動更新間隔 <br>定義(1034): 体重計選択有効化設定 | 変更 | TDC | 43887 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C665="",COUNTIF($C$3:C665,C665)<COUNTIF(C:C,C665)),"",C665) | 663 | mst_device_set_info_default | JSON定義(@mst_device_set_info_default)を更新<br>※TMP補液制御 | 変更 | TDC | 43887 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C666="",COUNTIF($C$3:C666,C666)<COUNTIF(C:C,C666)),"",C666) | 664 | pat_main | JSON定義(@device_set_info)を更新<br>※TMP補液制御 | 変更 | TDC | 43887 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C667="",COUNTIF($C$3:C667,C667)<COUNTIF(C:C,C667)),"",C667) | 665 | mnt_machine_state | JSON定義(@tmp_device_set_info)を更新<br>※TMP補液制御 | 変更 | TDC | 43887 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C668="",COUNTIF($C$3:C668,C668)<COUNTIF(C:C,C668)),"",C668) | 666 | sys_facility_setting | @sys_facility_settingの以下の定義を修正<br>定義(1034): 体重計選択有効化設定 | 変更 | TDC | 43887 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C669="",COUNTIF($C$3:C669,C669)<COUNTIF(C:C,C669)),"",C669) | 667 | pat_unique | @pat_uniqueの以下の定義を作成<br>・入外・転入出情報 | 変更 | MOR | 43887 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C670="",COUNTIF($C$3:C670,C670)<COUNTIF(C:C,C670)),"",C670) | 668 | sys_notification | テーブル追加 | 新規 | MOR | 43893 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C671="",COUNTIF($C$3:C671,C671)<COUNTIF(C:C,C671)),"",C671) | 669 | sys_system_define | @sys_system_defineに以下の設定を追加<br>・通知カテゴリ設定 | 変更 | MOR | 43893 | 1.0.0.0 |  | ■ | × | × | × |
| mst_personal_tab_define | 670 | mst_personal_tab_define | 以下のカラムの定義を変更<br>・facility_cd<br>→NOT NULL 制約の削除<br>→桁数を無制限に変更 | 変更 | MOR | 43893 | 1.0.0.0 |  | ■ | × | × | × |
| sys_personal_settings_define | 671 | sys_personal_settings_define | @sys_personal_settings_defineの定義済の設定項目を追加<br>・タブ定義コード：8 | 変更 | MOR | 43893 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C674="",COUNTIF($C$3:C674,C674)<COUNTIF(C:C,C674)),"",C674) | 672 | mst_comp_treatment | 以下のカラムの定義を変更<br>・amount<br>→numeric(12,2)からnumeric(指定なし)へ<br>※薬剤マスタの小数点桁数指定及びサイズに合わせて同一設定へ変更 | 変更 | MOR | 43893 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C675="",COUNTIF($C$3:C675,C675)<COUNTIF(C:C,C675)),"",C675) | 673 | sys_facility_setting | @sys_facility_settingの以下の定義を追加<br>定義(1035): 空きベッド検索除外予定数 | 変更 | MOR | 43893 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C676="",COUNTIF($C$3:C676,C676)<COUNTIF(C:C,C676)),"",C676) | 674 | ord_main | BVMS機能の対応<br>・ord_main.rst_weight_info.reloop_infoを追加する | 変更 | FPT | 43895 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C677="",COUNTIF($C$3:C677,C677)<COUNTIF(C:C,C677)),"",C677) | 675 | pat_insurance | JSON構内に暗号化されたカラムの追記 | 変更 | FPT | 43895 | 1.0.0.0 |  | ■ | × | × | × |
| mst_url_link_register | 676 | mst_url_link_register | 外部リンクメニューマスタの新規追加 | 新規 | FPT | 43895 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C679="",COUNTIF($C$3:C679,C679)<COUNTIF(C:C,C679)),"",C679) | 677 | mst_user | 2要素認証機能の対応のため、以下のカラムの追加<br>・secret_key<br>・is_set_qr_code | 変更 | FPT | 43895 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C680="",COUNTIF($C$3:C680,C680)<COUNTIF(C:C,C680)),"",C680) | 678 | sys_facility_setting | @sys_facility_settingに1036,1037番の追加 | 変更 | FPT | 43895 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C681="",COUNTIF($C$3:C681,C681)<COUNTIF(C:C,C681)),"",C681) | 679 | mst_facility_setting | 機能コード一覧に以下のコードの追加<br>・032：水質調査<br>・033：定期点検<br>・034：日常点検<br>・035：ログ参照 | 変更 | FPT | 43899 | 1.0.0.0 |  | ■ | × | × | × |
| mst_mente_detail | 680 | mst_mente_detail | mst_mente_detailの追加 | 新規 | FPT | 43899 | 1.0.0.0 |  | =IFERROR(IF(C682=VLOOKUP(C682,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C682&"!A1","■"),""),"") | × | × | × |
| mnt_mente_main | 681 | mnt_mente_main | mnt_mente_mainの追加 | 新規 | FPT | 43899 | 1.0.0.0 |  | =IFERROR(IF(C683=VLOOKUP(C683,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C683&"!A1","■"),""),"") | × | × | × |
| mst_mente_layout_group | 682 | mst_mente_layout_group | mst_mente_layout_groupの追加 | 新規 | FPT | 43899 | 1.0.0.0 |  | =IFERROR(IF(C684=VLOOKUP(C684,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C684&"!A1","■"),""),"") | × | × | × |
| mst_mente_category | 683 | mst_mente_category | mst_mente_categoryの追加 | 新規 | FPT | 43899 | 1.0.0.0 |  | =IFERROR(IF(C685=VLOOKUP(C685,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C685&"!A1","■"),""),"") | × | × | × |
| mst_mente_layout | 684 | mst_mente_layout | mst_mente_layoutの追加 | 新規 | FPT | 43899 | 1.0.0.0 |  | =IFERROR(IF(C686=VLOOKUP(C686,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C686&"!A1","■"),""),"") | × | × | × |
| =IF(OR(C687="",COUNTIF($C$3:C687,C687)<COUNTIF(C:C,C687)),"",C687) | 685 | mst_user | mst_userに以下のカラムの追加<br>tmp_log_search_condition | 変更 | FPT | 43899 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C688="",COUNTIF($C$3:C688,C688)<COUNTIF(C:C,C688)),"",C688) | 686 | mnt_water_survey | mnt_water_surveyの追加 | 新規 | FPT | 43899 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C689="",COUNTIF($C$3:C689,C689)<COUNTIF(C:C,C689)),"",C689) | 687 | mst_water_survey_point | mst_water_survey_pointの追加 | 新規 | FPT | 43899 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C690="",COUNTIF($C$3:C690,C690)<COUNTIF(C:C,C690)),"",C690) | 688 | mst_water_survey_type | mst_water_survey_typeの追加 | 新規 | FPT | 43899 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C691="",COUNTIF($C$3:C691,C691)<COUNTIF(C:C,C691)),"",C691) | 689 | sys_facility_setting | @sys_facility_settingに1038番の追加 | 変更 | FPT | 43899 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C692="",COUNTIF($C$3:C692,C692)<COUNTIF(C:C,C692)),"",C692) | 690 | mst_pat_event_sub_category | 院内コードの追加<br>・院内コードA1<br>・院内コードA2<br>・院内コードA3<br>・院内コードA4<br>・利用開始日B<br>・院内コードB1<br>・院内コードB2<br>・院内コードB3<br>・院内コードB4 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| mst_procedure | 691 | mst_procedure | 院内コードの追加<br>・利用開始日A<br>・院内コードA1<br>・院内コードA2<br>・利用開始日B<br>・院内コードB1<br>・院内コードB2 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| mst_equipment | 692 | mst_equipment | 院内コードの追加<br>・院内コード4 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C695="",COUNTIF($C$3:C695,C695)<COUNTIF(C:C,C695)),"",C695) | 693 | mst_insurance | 院内コードの追加<br>・院内コード1<br>・院内コード2 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C696="",COUNTIF($C$3:C696,C696)<COUNTIF(C:C,C696)),"",C696) | 694 | mst_bed | 院内コードの追加<br>・院内コード1<br>・院内コード2 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C697="",COUNTIF($C$3:C697,C697)<COUNTIF(C:C,C697)),"",C697) | 695 | mst_job | 院内コードの追加<br>・院内コード1 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C698="",COUNTIF($C$3:C698,C698)<COUNTIF(C:C,C698)),"",C698) | 696 | mst_equipment_set | 院内コードの追加<br>・院内コード1<br>・院内コード2 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| mst_medicine_set | 697 | mst_medicine_set | 院内コードの追加<br>・院内コード1<br>・院内コード2 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| mst_dialyzer | 698 | mst_dialyzer | 院内コードの追加<br>・院内コード4 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| mst_medicine | 699 | mst_medicine | 院内コードの追加<br>・院内コード4 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C702="",COUNTIF($C$3:C702,C702)<COUNTIF(C:C,C702)),"",C702) | 700 | mst_treatment | 院内コードの追加<br>・院内コードA1<br>・院内コードA2<br>・院内コードA3<br>・院内コードA4<br>・利用開始日B<br>・院内コードB1<br>・院内コードB2<br>・院内コードB3<br>・院内コードB4 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| mst_comp_treatment | 701 | mst_comp_treatment | 院内コードの追加<br>・院内コードA1<br>・院内コードA2<br>・院内コードA3<br>・院内コードA4<br>・利用開始日B<br>・院内コードB1<br>・院内コードB2<br>・院内コードB3<br>・院内コードB4 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C704="",COUNTIF($C$3:C704,C704)<COUNTIF(C:C,C704)),"",C704) | 702 | mst_personal_user | 院内コードの追加<br>・院内コード1<br>・院内コード2 | 変更 | FPT | 43908 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C705="",COUNTIF($C$3:C705,C705)<COUNTIF(C:C,C705)),"",C705) | 703 | sys_system_define | @sys_system_defineに以下の設定を追加<br>・日次バッチ処理設定 | 変更 | MOR | 43913 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C706="",COUNTIF($C$3:C706,C706)<COUNTIF(C:C,C706)),"",C706) | 704 | mnt_batch_manager | テーブル追加 | 変更 | MOR | 43913 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C707="",COUNTIF($C$3:C707,C707)<COUNTIF(C:C,C707)),"",C707) | 705 | sys_facility_setting | @sys_facility_settingに以下の定義を削除<br>定義（1031): スケジュール延長処理開始時刻<br>定義（1032): スケジュール延長処理終了時刻 | 変更 | MOR | 43913 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C708="",COUNTIF($C$3:C708,C708)<COUNTIF(C:C,C708)),"",C708) | 706 | mst_personal_user | 管理者への表示許可(info_disp_to_admin)を追加 | 変更 | MOR | 43917 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C709="",COUNTIF($C$3:C709,C709)<COUNTIF(C:C,C709)),"",C709) | 707 | sys_facility_setting | @sys_facility_settingの以下の定義を追加<br>定義(1039): 空きベッド検索除外予定数 | 変更 | MOR | 43917 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C710="",COUNTIF($C$3:C710,C710)<COUNTIF(C:C,C710)),"",C710) | 708 | pat_unique | @pat_uniqueに以下の定義を追加<br>period_start_date<br>period_start_year<br>period_start_month<br>period_start_day<br>period_start_input_free<br>period_end_date<br>period_end_year<br>period_end_month<br>period_end_day<br>period_end_input_free<br>facility_is_free<br>course_is_free<br>doctor_is_free | 変更 | MOR | 43917 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C711="",COUNTIF($C$3:C711,C711)<COUNTIF(C:C,C711)),"",C711) | 709 | mst_pat_event_data_template | @mst_pat_event_data_templateに記載のJSON構造を修正<br>・掲示板リンク設定を修正 | 変更 | TDC | 43920 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C712="",COUNTIF($C$3:C712,C712)<COUNTIF(C:C,C712)),"",C712) | 710 | pat_event | `@pat_eventに記載のJSON構造を修正<br>・スコア計算実績を修正<br>・掲示板リンク実績を修正 | 変更 | TDC | 43920 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C713="",COUNTIF($C$3:C713,C713)<COUNTIF(C:C,C713)),"",C713) | 711 | mst_checklist | @mst_checklistに記載のJSON構造を修正<br>・透析工程コードに3.未使用を追加 | 変更 | TDC | 43920 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C714="",COUNTIF($C$3:C714,C714)<COUNTIF(C:C,C714)),"",C714) | 712 | bbs_info | カラムを追加<br>・登録元機能 reg_func_class | 変更 | TDC | 43920 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C715="",COUNTIF($C$3:C715,C715)<COUNTIF(C:C,C715)),"",C715) | 713 | sys_data_set | @sys_data_setに記載のdetailカラムのJSON構造を修正<br>・conv_tableの詳細を記述<br>・label_classesキーを追加<br>・conv_sqlキーを追加<br>カラム追加<br>・事前取得データ情報 pre_data_set | 変更 | TDC | 43920 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C716="",COUNTIF($C$3:C716,C716)<COUNTIF(C:C,C716)),"",C716) | 714 | sys_data_set | @sys_data_setに記載のdetailカラムのJSONキー名を修正<br>・conv_sql.data_nameキー→conv_sql.field_name<br>・pre_sql_info.data_nameキー→pre_sql_info.field_name | 変更 | TDC | 43921 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C717="",COUNTIF($C$3:C717,C717)<COUNTIF(C:C,C717)),"",C717) | 715 | sys_system_define | @sys_system_defineに以下の設定を追加<br>・オンプレミス設定<br>・カードアプリケーション最新バージョン | 変更 | FPT | 43924 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C718="",COUNTIF($C$3:C718,C718)<COUNTIF(C:C,C718)),"",C718) | 716 | sys_function | 機能コード一覧に以下を追加<br>・患者情報共有 | 変更 | FPT | 43924 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C719="",COUNTIF($C$3:C719,C719)<COUNTIF(C:C,C719)),"",C719) | 717 | mst_user | 以下のカラムを追加<br>・アクセスカード番号 | 変更 | MOR | 43924 | 1.0.0.0 | FPT様修正分を代筆 | ■ | × | × | × |
| =IF(OR(C720="",COUNTIF($C$3:C720,C720)<COUNTIF(C:C,C720)),"",C720) | 718 | sys_facility_setting | @sys_facility_settingの定義（1030）を修正<br>（選択肢「無効」追加 / disp_order を 25 に変更 ) | 変更 | MOR | 43924 | 1.0.0.0 | FPT様修正分を代筆 | ■ | × | × | × |
| =IF(OR(C721="",COUNTIF($C$3:C721,C721)<COUNTIF(C:C,C721)),"",C721) | 719 | ord_main | @治療条件項目の補足を更新<br>・抗凝固剤<br>・抗凝固剤ワンショット量<br>・抗凝固剤持続速度<br>・抗凝固剤持続総量<br>・透析液<br>・透析液量<br>・補液<br>・補液使用数 | 変更 | MOR | 43924 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C722="",COUNTIF($C$3:C722,C722)<COUNTIF(C:C,C722)),"",C722) | 720 | sys_system_define | マスタデータ No16,17 を追加<br>　（「@sys_system_define」シート参照） | 変更 | MOR | 43924 | 1.0.0.0 |  | ■ | × | × | × |
| sys_notification_list | 721 | sys_notification_list | テーブル追加<br>@sys_notification_listシート追加 | 新規 | MOR | 43924 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C724="",COUNTIF($C$3:C724,C724)<COUNTIF(C:C,C724)),"",C724) | 722 | sys_daily_no | テーブル追加 | 新規 | TEX | 43926 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C725="",COUNTIF($C$3:C725,C725)<COUNTIF(C:C,C725)),"",C725) | 723 | mst_facility_calendar_layout | 機能コード一覧に以下のコードの追加<br>・施設カレンダー | 変更 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C726="",COUNTIF($C$3:C726,C726)<COUNTIF(C:C,C726)),"",C726) | 724 | pat_name_identification | 患者情報共有用のテープルの新規追加 | 新規 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| mst_bbs_kind | 725 | mst_bbs_kind | 施設カレンダーの対応のためカラムの変更<br>・default_contents<br>・default_title | 変更 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C728="",COUNTIF($C$3:C728,C728)<COUNTIF(C:C,C728)),"",C728) | 726 | bbs_info | 施設カレンダーの対応のためカラムの追加<br>・title<br>・notice_fac_cal_start_date<br>・notice_fac_cal_end_date<br>・is_disp_bbs<br>・color | 変更 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| mst_facility_calendar_layout | 727 | mst_facility_calendar_layout | 新規追加 | 新規 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C730="",COUNTIF($C$3:C730,C730)<COUNTIF(C:C,C730)),"",C730) | 728 | mnt_water_survey | Jsonbにデータを保管するため、カラム追加 | 変更 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C731="",COUNTIF($C$3:C731,C731)<COUNTIF(C:C,C731)),"",C731) | 729 | mst_mainte_layout | カラムの追加<br>・edition_no | 変更 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C732="",COUNTIF($C$3:C732,C732)<COUNTIF(C:C,C732)),"",C732) | 730 | mst_mainte_detail | カラムの追加<br>・edition_no | 変更 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C733="",COUNTIF($C$3:C733,C733)<COUNTIF(C:C,C733)),"",C733) | 731 | mst_mainte_category | カラムの追加<br>・edition_no | 変更 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C734="",COUNTIF($C$3:C734,C734)<COUNTIF(C:C,C734)),"",C734) | 732 | mst_mainte_layout_group | カラムの追加<br>・edition_no | 変更 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C735="",COUNTIF($C$3:C735,C735)<COUNTIF(C:C,C735)),"",C735) | 733 | mnt_mainte_main | カラムの追加<br>・mainte_layout_edition<br>・mainte_layout_group_edition<br>・mainte_category_edition | 変更 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C736="",COUNTIF($C$3:C736,C736)<COUNTIF(C:C,C736)),"",C736) | 734 | mst_mainte_detail_hst | 新規追加 | 新規 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C737="",COUNTIF($C$3:C737,C737)<COUNTIF(C:C,C737)),"",C737) | 735 | mst_mainte_layout_group_hst | 新規追加 | 新規 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C738="",COUNTIF($C$3:C738,C738)<COUNTIF(C:C,C738)),"",C738) | 736 | mst_mainte_category_hst | 新規追加 | 新規 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C739="",COUNTIF($C$3:C739,C739)<COUNTIF(C:C,C739)),"",C739) | 737 | mst_mainte_layout_hst | 新規追加 | 新規 | FPT | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C740="",COUNTIF($C$3:C740,C740)<COUNTIF(C:C,C740)),"",C740) | 738 | sys_medicine | テーブル追加<br>※シート：インデックス一覧に「idx_sys_medicine_01」も追加 | 新規 | ESM | 43929 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C741="",COUNTIF($C$3:C741,C741)<COUNTIF(C:C,C741)),"",C741) | 739 | mst_pat_event_data_template | @mst_pat_event_data_templateに記載のJSON構造を修正<br>・テキスト、テキストエリア、リストのsys_data_set連携用情報を修正 | 変更 | TDC | 43931 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C742="",COUNTIF($C$3:C742,C742)<COUNTIF(C:C,C742)),"",C742) | 740 | mst_comsv_setting | 以下のカラムを追加<br>・装置生存監視時間<br>・治療中モニタ通知間隔<br>・治療外モニタ通知間隔 | 変更 | TDC | 43931 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C743="",COUNTIF($C$3:C743,C743)<COUNTIF(C:C,C743)),"",C743) | 741 | sys_notification | 備考欄に記載を追加<br>@sys_notificationシート追加<br>通知定義番号1を追加 | 変更 | MOR | 43931 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C744="",COUNTIF($C$3:C744,C744)<COUNTIF(C:C,C744)),"",C744) | 742 | sys_data_set | @sys_data_setシート修正<br>use_applicationの使用用途を追加 | 変更 | TEX | 43931 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C745="",COUNTIF($C$3:C745,C745)<COUNTIF(C:C,C745)),"",C745) | 743 | sys_facility_setting | @sys_facility_settingに以下の定義を追加<br>定義（1040): スケジュール帳票表示<br>定義（1041): 水質管理帳票表示 | 変更 | TDC | 43931 | 1.0.0.0 |  | ■ | × | × | × |
| sys_medicine | 744 | sys_medicine | プライマリキーを変更<br>　変更前：jan_cd<br>　変更後：standard_no | 変更 | ESM | 43934 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C747="",COUNTIF($C$3:C747,C747)<COUNTIF(C:C,C747)),"",C747) | 745 | bbs_info | 以下のカラムを変更<br>・対象スタッフ staff_info のJSON形式を変更 | 変更 | TDC | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| ord_prescription | 746 | ord_prescription | 新規追加 | 新規 | FPT | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C749="",COUNTIF($C$3:C749,C749)<COUNTIF(C:C,C749)),"",C749) | 747 | ord_personal_prescription | 新規追加 | 新規 | FPT | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| sys_generic_medicine | 748 | sys_generic_medicine | 新規追加 | 新規 | FPT | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| mst_take_medicine | 749 | mst_take_medicine | 新規追加 | 新規 | FPT | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C752="",COUNTIF($C$3:C752,C752)<COUNTIF(C:C,C752)),"",C752) | 750 | mst_personal_user | 以下のカラムの追加<br>麻薬施用者免許証番号 | 変更 | FPT | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| sys_subscription_plan | 751 | sys_subscription_plan | 新規追加 | 新規 | FPT | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C754="",COUNTIF($C$3:C754,C754)<COUNTIF(C:C,C754)),"",C754) | 752 | sal_subscription_manage | 新規追加 | 新規 | FPT | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C755="",COUNTIF($C$3:C755,C755)<COUNTIF(C:C,C755)),"",C755) | 753 | sys_function | 以下のカラムの追加<br>disp_order<br>target_facility | 変更 | FPT | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C756="",COUNTIF($C$3:C756,C756)<COUNTIF(C:C,C756)),"",C756) | 754 | sys_function_advanced | 新規追加<br>「拡張機能コード一覧」シートの追加 | 新規 | FPT | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C757="",COUNTIF($C$3:C757,C757)<COUNTIF(C:C,C757)),"",C757) | 755 | mst_facility | 以下のカラムの追加<br>sales_email_address | 変更 | FPT | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C758="",COUNTIF($C$3:C758,C758)<COUNTIF(C:C,C758)),"",C758) | 756 | sys_system_define | 「@sys_system_define」シートの修正<br>以下のコードの追加<br>18,19,20,21,22,23 | 変更 | FPT | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| mst_pat_search_detail | 757 | mst_pat_search_detail | 新規追加 | 新規 | FPT | 43935 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C760="",COUNTIF($C$3:C760,C760)<COUNTIF(C:C,C760)),"",C760) | 758 | mst_monitor_graph | 以下のカラムのデータ型を変更<br>・left_data_index<br>・right_data_index | 変更 | TDC | 43937 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C761="",COUNTIF($C$3:C761,C761)<COUNTIF(C:C,C761)),"",C761) | 759 | pat_ind_approve_history | 新規追加 | 新規 | FPT | 43941 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C762="",COUNTIF($C$3:C762,C762)<COUNTIF(C:C,C762)),"",C762) | 760 | pat_ind_approve | ・コメント修正<br>・カラムの削除：is_content_change_since_created | 変更 | FPT | 43941 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C763="",COUNTIF($C$3:C763,C763)<COUNTIF(C:C,C763)),"",C763) | 761 | sys_facility_setting | 以下の設定の追加<br>1042, 1043, 1044, 1045 | 変更 | FPT | 43941 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C764="",COUNTIF($C$3:C764,C764)<COUNTIF(C:C,C764)),"",C764) | 762 | mst_water_survey_type | データ型がnumbericに変更<br>upper_threshold <br>lower_threshold <br>graph_upper_limit <br>graph_lower_limit | 変更 | FPT | 43941 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C765="",COUNTIF($C$3:C765,C765)<COUNTIF(C:C,C765)),"",C765) | 763 | mst_facility_setting | 機能コード一覧に以下のコードの追加<br>・038：申込一覧<br>機能名の修正：029：処方箋→処方 | 変更 | FPT | 43941 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C766="",COUNTIF($C$3:C766,C766)<COUNTIF(C:C,C766)),"",C766) | 764 | mst_comsv_setting | 以下の初期値を変更<br>・治療中モニタ通知間隔<br>・治療外モニタ通知間隔 | 変更 | TDC | 43942 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C767="",COUNTIF($C$3:C767,C767)<COUNTIF(C:C,C767)),"",C767) | 765 | sys_system_define | 「@sys_system_define」シートの修正<br>コード24を追加 | 変更 | TDC | 43942 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C768="",COUNTIF($C$3:C768,C768)<COUNTIF(C:C,C768)),"",C768) | 766 | pat_ind_approve | 以下のカラムを追加<br>・治療状況マップ指示変更ありフラグ<br>・治療状況マップ確認時指示内容<br>以下のカラムの型が誤った記載だったため実装に合わせて修正<br>・治療単位指示承認時指示内容 (character verying → jsonb) | 変更 | TDC | 43942 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C769="",COUNTIF($C$3:C769,C769)<COUNTIF(C:C,C769)),"",C769) | 767 | sys_facility_setting | @sys_facility_settingに以下の設定の追加<br>・1046 | 変更 | FPT | 43944 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C770="",COUNTIF($C$3:C770,C770)<COUNTIF(C:C,C770)),"",C770) | 768 | pat_exam_main | 以下のカラムを追加<br>・検査依頼登録フラグ | 変更 | MOR | 43951 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C771="",COUNTIF($C$3:C771,C771)<COUNTIF(C:C,C771)),"",C771) | 769 | sys_master_define | 以下のカラムを追加<br>・system_use_disp(システム利用表示区分）<br>上記項目の設定値詳細はシート参照 | 変更 | MOR | 43951 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C772="",COUNTIF($C$3:C772,C772)<COUNTIF(C:C,C772)),"",C772) | 770 | mst_user | 以下のカラムを追加<br>・is_consent（個人情報取扱い同意フラグ）<br>・consent_date(個人情報取扱い同意日時） | 変更 | MOR | 43951 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C773="",COUNTIF($C$3:C773,C773)<COUNTIF(C:C,C773)),"",C773) | 771 | sys_system_define | 「@sys_system_define」シートの修正<br>コード26(個人情報取扱い同意規約メッセージ)を追加 | 変更 | MOR | 43951 | 1.0.0.0 |  | ■ | × | × | × |
| sys_release_info | 772 | sys_release_info | 新規作成：システムリリース情報 | 新規 | MOR | 43951 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C775="",COUNTIF($C$3:C775,C775)<COUNTIF(C:C,C775)),"",C775) | 773 | sys_data_set | @sys_data_setに記載のdetailカラムのJSONキー名を追加<br>・filter_typeキーを追加 | 変更 | TDC | 43952 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C776="",COUNTIF($C$3:C776,C776)<COUNTIF(C:C,C776)),"",C776) | 774 | sys_facility_setting | @sys_facility_settingの以下項目を変更<br>・1017 | 変更 | MOR | 43959 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C777="",COUNTIF($C$3:C777,C777)<COUNTIF(C:C,C777)),"",C777) | 775 | mst_report | 以下のカラムを追加<br>・additional_info(追加情報) | 変更 | TDC | 43962 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C778="",COUNTIF($C$3:C778,C778)<COUNTIF(C:C,C778)),"",C778) | 776 | mst_spitz | 以下のカラムを削除<br>・emergency_flg(至急フラグ) | 変更 | MOR | 43965 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C779="",COUNTIF($C$3:C779,C779)<COUNTIF(C:C,C779)),"",C779) | 777 | mst_exam_set | @mst_exam_setに記載のlabel_infoカラムのJSONキー名を削除<br>・label_cntキーを削除 | 変更 | MOR | 43965 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C780="",COUNTIF($C$3:C780,C780)<COUNTIF(C:C,C780)),"",C780) | 778 | pat_exam_main | @pat_exam_mainに記載のorder_label_infoカラムのJSONキー名を削除<br>・label_cntキーを削除 | 変更 | MOR | 43965 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C781="",COUNTIF($C$3:C781,C781)<COUNTIF(C:C,C781)),"",C781) | 779 | sys_system_define | sys_system_defineに以下の設定の追加<br>・アプリケーションログ<br>・イベントログ | 変更 | FPT | 43969 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C782="",COUNTIF($C$3:C782,C782)<COUNTIF(C:C,C782)),"",C782) | 780 | sys_function_advanced | 以下の拡張設定の追加<br>・BVMS<br>・加算情報 | 変更 | FPT | 43969 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C783="",COUNTIF($C$3:C783,C783)<COUNTIF(C:C,C783)),"",C783) | 781 | sys_function_advanced | 以下の拡張設定の追加<br>・患者イベントスコア | 変更 | TDC | 43972 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C784="",COUNTIF($C$3:C784,C784)<COUNTIF(C:C,C784)),"",C784) | 782 | mst_facility | @advanced_settings<br>拡張設定のJSON構造の記載を実装に合わせて修正 | 変更 | TDC | 43972 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C785="",COUNTIF($C$3:C785,C785)<COUNTIF(C:C,C785)),"",C785) | 783 | sys_facility_setting | 入力方法input_typeに以下の定義を追加<br>・6: テキストエリア<br>'@sys_facility_settingに以下の項目を追加<br>・1047：シェーマ機能スタンプ定型文字 | 変更 | TDC | 43972 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C786="",COUNTIF($C$3:C786,C786)<COUNTIF(C:C,C786)),"",C786) | 784 | mst_machine | 以下のカラムを追加<br>対応可否フラグ(特殊浄化) is_blood_purify | 変更 | TDC | 43972 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C787="",COUNTIF($C$3:C787,C787)<COUNTIF(C:C,C787)),"",C787) | 785 | mst_machine | 以下のカラム名を修正(ほかの対応可否フラグと統一)<br>is_blood_purify → is_support_blood_purify | 変更 | TDC | 43976 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C788="",COUNTIF($C$3:C788,C788)<COUNTIF(C:C,C788)),"",C788) | 786 | sys_signin_manager | 新規追加 | 追加 | ESM | 43979 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C789="",COUNTIF($C$3:C789,C789)<COUNTIF(C:C,C789)),"",C789) | 787 | sys_facility_setting | @sys_facility_settingの1048の定義を追加 | 追加 | ESM | 43986 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C790="",COUNTIF($C$3:C790,C790)<COUNTIF(C:C,C790)),"",C790) | 788 | mst_addition | 以下の内容の修正<br>・addition_limit_typeの追加<br>・addition_cdの論理名の修正<br>・add_cnt_1の物理名の修正<br>・addition_condの追加 | 変更 | FPT | 43990 | 1.0.0.0 |  | ■ | × | × | × |
| mst_facility_setting | 789 | mst_facility_setting | 機能コード一覧に以下のコードの追加<br>039：P-Ca9分割グラフ | 変更 | FPT | 43990 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C792="",COUNTIF($C$3:C792,C792)<COUNTIF(C:C,C792)),"",C792) | 790 | sys_facility_setting | @sys_facility_settingの以下の定義を追加<br>・1049 | 変更 | FPT | 43990 | 1.0.0.0 |  | ■ | × | × | × |
| sys_data_list_detail | 791 | sys_data_list_detail | 新規追加 | 追加 | FPT | 43990 | 1.0.0.0 |  | ■ | × | × | × |
| sys_data_list_category | 792 | sys_data_list_category | 新規追加 | 追加 | FPT | 43990 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C795="",COUNTIF($C$3:C795,C795)<COUNTIF(C:C,C795)),"",C795) | 793 | mst_pat_list_layout | 以下のカラムを追加<br>・template_cd | 変更 | FPT | 43990 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C796="",COUNTIF($C$3:C796,C796)<COUNTIF(C:C,C796)),"",C796) | 794 | mnt_motion_record | 以下のカラムを追加<br>　・is_correction_up_date<br>　・service_support_type<br>　・service_support_user_id<br>　・service_support_up_date | 変更 | ESM | 43991 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C797="",COUNTIF($C$3:C797,C797)<COUNTIF(C:C,C797)),"",C797) | 795 | mnt_machine_state | 以下のカラムを追加<br>　・service_support_cnt | 変更 | ESM | 43991 | 1.0.0.0 |  | ■ | × | × | × |
| sys_signin_manager | 796 | sys_signin_manager | db6からdb4に変更 | 変更 | ESM | 43993 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C799="",COUNTIF($C$3:C799,C799)<COUNTIF(C:C,C799)),"",C799) | 797 | sys_facility_setting | ・sys_facility_settingにシステム利用表示区分カラムを追加<br>・@sys_facility_settingの既存施設設定にシステム利用表示区分の振り分けを実施<br>・sys_facility_settingで未使用の項目を削除<br> 1001,1002,1006 | 変更 | MOR | 43998 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C800="",COUNTIF($C$3:C800,C800)<COUNTIF(C:C,C800)),"",C800) | 798 | sys_facility_setting | @sys_facility_settingに以下の項目を追加<br>・1051：外部警報1メッセージ変更<br>・1052：外部警報2メッセージ変更<br>・1053：外部警報3メッセージ変更<br>・1054：外部警報4メッセージ変更 | 変更 | MOR | 43998 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C801="",COUNTIF($C$3:C801,C801)<COUNTIF(C:C,C801)),"",C801) | 799 | sys_facility_setting | @sys_facility_settingの以下の定義を追加<br>・1050 | 変更 | FPT | 43999 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C802="",COUNTIF($C$3:C802,C802)<COUNTIF(C:C,C802)),"",C802) | 800 | pat_event | 以下のカラムの追加<br>・event_start_time<br>・event_end_time<br>カラム名の変更<br>・event_date -> event_start_date | 変更 | FPT | 43999 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C803="",COUNTIF($C$3:C803,C803)<COUNTIF(C:C,C803)),"",C803) | 801 | mst_treatment | 以下のカラムを追加<br>　・report_graph_setting | 変更 | ESM | 44000 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C804="",COUNTIF($C$3:C804,C804)<COUNTIF(C:C,C804)),"",C804) | 802 | mnt_device_edge_state | 以下のカラムを追加<br>・send_mail_status(通信異常メール送信状況） | 変更 | TDC | 44008 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C805="",COUNTIF($C$3:C805,C805)<COUNTIF(C:C,C805)),"",C805) | 803 | mst_weight | 以下のカラムの備考に項目追加<br>・device_class(体重計機種)<br>・printer_class(使用プリンター) | 変更 | TDC | 44008 | 1.0.0.0 |  | ■ | × | × | × |
| mst_graph_setting | 804 | mst_graph_setting | Ca9分割グラフ設定マスタの追加 | 追加 | FPT | 44015 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C807="",COUNTIF($C$3:C807,C807)<COUNTIF(C:C,C807)),"",C807) | 805 | mnt_facility_cancel_manage | データ削除機能に伴い新規追加 | 追加 | TEX | 44021 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C808="",COUNTIF($C$3:C808,C808)<COUNTIF(C:C,C808)),"",C808) | 806 | sys_system_define | 施設解約処理で使用する設定を追加 | 変更 | TEX | 44021 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C809="",COUNTIF($C$3:C809,C809)<COUNTIF(C:C,C809)),"",C809) | 807 | mst_medicine_mix | ・不要なカラム use_start_date、use_end_date を削除 | 変更 | MOR | 44021 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C810="",COUNTIF($C$3:C810,C810)<COUNTIF(C:C,C810)),"",C810) | 808 | sys_notification | @sys_notificationに通知定義番号3～16を追加 | 変更 | MOR | 44021 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C811="",COUNTIF($C$3:C811,C811)<COUNTIF(C:C,C811)),"",C811) | 809 | pat_exam_main | pat_exam_mainに記載のJSONキー名称が変わっているのに未修正状態のままのため、最新で更新<br>（設計書作成に合わせて対応） | 変更 | MOR | 44021 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C812="",COUNTIF($C$3:C812,C812)<COUNTIF(C:C,C812)),"",C812) | 810 | mnt_device_edge_state | 以下のカラムを追加<br>・manage_no（予約更新指示番号）<br>・manage_plan_date（予約更新日時） | 変更 | TDC | 44046 | 1.0.0.0 |  | ■ | × | × | × |
| mnt_device_edge_manage | 811 | mnt_device_edge_manage | 以下のカラムの備考に定義を追加<br>・order_class（指示種別）<br>・response_status（応答ステータス） | 変更 | TDC | 44046 | 1.0.0.0 |  | ■ | × | × | × |
| mnt_find_machine | 812 | mnt_find_machine | 新規追加 | 新規 | TDC | 44050 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C815="",COUNTIF($C$3:C815,C815)<COUNTIF(C:C,C815)),"",C815) | 813 | sys_facility_setting | @sys_facility_settingに以下の項目を追加<br>・1059：体重計モード・スケジュール変更設定 | 変更 | 鄭博尹 | 44055 | 1.0.0.0 | 体重測定・条件送信<br>ボタン制御<br>「クール設定／ベッド設定」ボタンは条件により非活性 | ■ | × | × | × |
| =IF(OR(C816="",COUNTIF($C$3:C816,C816)<COUNTIF(C:C,C816)),"",C816) | 814 | mst_machine | 以下のカラム項目を追加<br>・is_blood_purify_use(特殊浄化通信アプリ使用選択)<br>・blood_purify_type(特殊浄化装置種別) | 変更 | 馮 | 44057 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C817="",COUNTIF($C$3:C817,C817)<COUNTIF(C:C,C817)),"",C817) | 815 | pat_main | 以下のカラム項目を追加<br>・card_idm(アクセスカード番号) | 変更 | 馮 | 44057 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C818="",COUNTIF($C$3:C818,C818)<COUNTIF(C:C,C818)),"",C818) | 816 | sys_system_define | @sys_system_defineに以下の設定を追加<br>・データセット最新バージョン | 追加 | 孫少凱 | 44057 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C819="",COUNTIF($C$3:C819,C819)<COUNTIF(C:C,C819)),"",C819) | 817 | sys_master_define | sys_master_defineにcolumn_infoのデータを更新<br>・体重計マスタデータに対して、体重計番号を更新 | 変更 | 李亮 | 44057 | 1.0.0.0 | {"type": "number", "alias": null, "title": "体重計番号", "format": "#####", "hidden": "false", "editable": "true", "validation": {"max": "32767", "min": 0, "required": "true", "maxlength": "5"}, "physical_name": "weight_no"} | ■ | × | × | × |
| =IF(OR(C820="",COUNTIF($C$3:C820,C820)<COUNTIF(C:C,C820)),"",C820) | 818 | mst_treatment_status_disp_item | mst_treatment_status_disp_itemのデータを追加<br>・110:装置自己診断 | 変更 | 何占峰 | 44062 | 1.0.0.0 | V20200819130001__add_mst_treatment_status_disp_item.sql | ■ | × | × | × |
| =IF(OR(C821="",COUNTIF($C$3:C821,C821)<COUNTIF(C:C,C821)),"",C821) | 819 | ord_main | 「rst_weight_info」にキーを追加：<br>  "sttc_vns_prssr": (Number)静的静脈圧<br>  "iap_rt": (Number)IAP　Rate<br>  "ihdf_pll": (Number)IHDF引き残し量<br>  "recrcl_rt": (Number)再循環率測定 | 変更 | 尚 | 44063 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C822="",COUNTIF($C$3:C822,C822)<COUNTIF(C:C,C822)),"",C822) | 820 | mst_weight | 以下のカラム項目を追加<br>・data_send_interval(測定値送信間隔)<br>・data_select_type(初期データ表示種別) | 変更 | 馮 | 44068 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C823="",COUNTIF($C$3:C823,C823)<COUNTIF(C:C,C823)),"",C823) | 821 | sys_system_define | 施設解約/期間外削除処理で使用する設定を追加 | 変更 | TEX | 44069 | 1.0.0.0 | @sys_system_defineを修正 | ■ |  |  |  |
| mnt_batch_manager | 822 | mnt_batch_manager | 施設解約/期間外削除処理で使用する設定を追加 | 変更 | TEX | 44069 | 1.0.0.0 | @mnt_batch_managerを修正 | ■ |  |  |  |
| =IF(OR(C825="",COUNTIF($C$3:C825,C825)<COUNTIF(C:C,C825)),"",C825) | 823 | mnt_facility_cancel_manage | 施設解約/期間外削除処理で使用する設定を追加 | 変更 | TEX | 44069 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C826="",COUNTIF($C$3:C826,C826)<COUNTIF(C:C,C826)),"",C826) | 824 | mst_facility | 施設解約/期間外削除処理で使用する設定を追加 | 変更 | TEX | 44069 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C827="",COUNTIF($C$3:C827,C827)<COUNTIF(C:C,C827)),"",C827) | 825 | ord_main | 「rst_complaint_info」にキーを追加：<br> 　　"checkFlag":帳票出力区分(*4)<br>　　　概要に説明を追加：<br>　　　(*4) 帳票出力区分【:帳票出力追加】<br>「rst_treatment_info」にキーを追加：<br> 　　"checkFlag":帳票出力区分(*5)<br>　　 概要に説明を追加：<br>       (*5) 帳票出力区分【:帳票出力追加】<br>「rst_treat_staff_info」にキーを追加：<br> 　　"checkFlag":帳票出力区分,(*4)<br>　　 概要に説明を追加：<br>       (*4) 帳票出力区分【:帳票出力追加】 | 変更 | 呉 | 44069 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C828="",COUNTIF($C$3:C828,C828)<COUNTIF(C:C,C828)),"",C828) | 826 | bbs_info | 以下のカラム項目を追加<br>・html_content(様式付きの内容) | 変更 | 任徳龍 | 44069 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C829="",COUNTIF($C$3:C829,C829)<COUNTIF(C:C,C829)),"",C829) | 827 | pat_event | 以下のカラム項目を追加<br>・report_url(テンプレートのアドレス) | 変更 | 任徳龍 | 44069 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C830="",COUNTIF($C$3:C830,C830)<COUNTIF(C:C,C830)),"",C830) | 828 | sys_facility_setting | @sys_facility_settingに以下の項目を変更<br>・1059：体重計モード・スケジュール変更設定<br>＝＞<br>・2000：体重計モード・スケジュール変更設定 | 変更 | 鄭博尹 | 44070 | 1.0.0.0 | 体重測定・条件送信<br>ボタン制御<br>「クール設定／ベッド設定」ボタンは条件により非活性 | ■ | × | × | × |
| =IF(OR(C831="",COUNTIF($C$3:C831,C831)<COUNTIF(C:C,C831)),"",C831) | 829 | sys_data_set | sqlのデータを更新<br>・sql_cd：128<br>・sql_cd：132 | 変更 | 夏威 | 44070 | 1.0.0.0 | V20200826105001__update_sys_data_set.sql<br>V20200826105002__update_sys_data_set.sql | ■ | × | × | × |
| =IF(OR(C832="",COUNTIF($C$3:C832,C832)<COUNTIF(C:C,C832)),"",C832) | 830 | pat_event | 以下のカラム項目を追加<br>・report_date(転入転出日付) | 変更 | 任徳龍 | 44070 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C833="",COUNTIF($C$3:C833,C833)<COUNTIF(C:C,C833)),"",C833) | 831 | sys_master_define | sys_master_defineにcolumn_infoのデータを更新<br>・体重計マスタデータに対して、データ初期種別、測定値送信間隔を追加 | 変更 | 何占峰 | 44076 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C834="",COUNTIF($C$3:C834,C834)<COUNTIF(C:C,C834)),"",C834) | 832 | pat_main | ・device_set_infoのJSONキー追加<br>「@device_set_info」シート修正 | 変更 | 趙慧敏 | 44078 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C835="",COUNTIF($C$3:C835,C835)<COUNTIF(C:C,C835)),"",C835) | 833 | mnt_weight_state | 以下のカラム項目を追加<br>scale_value_list(体重値候補リスト) | 変更 | 張 | 44081 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C836="",COUNTIF($C$3:C836,C836)<COUNTIF(C:C,C836)),"",C836) | 834 | mst_device_set_info_default | ・device_set_infoのJSONキー追加<br>「@mst_device_set_info_default」シート修正 | 変更 | 趙慧敏 | 44081 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C837="",COUNTIF($C$3:C837,C837)<COUNTIF(C:C,C837)),"",C837) | 835 | sys_data_set | スケジュール表のSQL文を更新<br>・sql_cdが6 | 変更 | 李龍 | 44083 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C838="",COUNTIF($C$3:C838,C838)<COUNTIF(C:C,C838)),"",C838) | 836 | mst_report | 以下のカラム項目を追加<br>・disp_order(表示順) | 変更 | 孫少凱 | 44090 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C839="",COUNTIF($C$3:C839,C839)<COUNTIF(C:C,C839)),"",C839) | 837 | mst_treatment | 以下のカラム項目を追加<br>・report_id_act(治療経過表ID（実績確定）) | 変更 | 孔帅 | 44091 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C840="",COUNTIF($C$3:C840,C840)<COUNTIF(C:C,C840)),"",C840) | 838 | mst_pat_event_sub_category | 以下のカラム項目を追加<br>・disp_item_info(レポート一覧) | 変更 | 孔帅 | 44092 | 1.0.0.0 |  | ■ |  |  |  |
| mst_personal_user | 839 | mst_personal_user | 以下のカラム追加<br>　・signin_date | 変更 | MOR | 44099 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C842="",COUNTIF($C$3:C842,C842)<COUNTIF(C:C,C842)),"",C842) | 840 | sys_facility_setting | @sys_facility_settingシート<br>機能名、設定名称、設定説明を適切な表現に修正<br>No1051～1052の設定名称、初期値の修正<br>No1055～1058（外部警報入力OFF時メッセージ変更）の追加<br>No1059～1060（パスワード関連設定）の追加<br>No1061～1063（サインイン失敗時関連設定）の追加 | 変更 | MOR | 44099 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C843="",COUNTIF($C$3:C843,C843)<COUNTIF(C:C,C843)),"",C843) | 841 | mst_user | 以下のカラム追加<br>　・reg_password_date | 変更 | MOR | 44099 | 1.0.0.0 |  | ■ | × | × | × |
| mst_user_authentication | 842 | mst_user_authentication | 以下のカラム追加<br>　・user_password_history<br>@mst_user_authenticationシート<br>　・user_password_historyのJSON構造を記載 | 変更 | MOR | 44099 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C845="",COUNTIF($C$3:C845,C845)<COUNTIF(C:C,C845)),"",C845) | 843 | mst_facility_hash | 以下のカラム追加<br>　・account_lock_setting<br>　・failure_cnt<br>　・otp_failure_cnt | 変更 | MOR | 44099 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C846="",COUNTIF($C$3:C846,C846)<COUNTIF(C:C,C846)),"",C846) | 844 | sys_facility_setting | @sys_facility_settingシート<br>No1064 権限変更時サインアウト の追加 | 変更 | MOR | 44099 | 1.0.0.0 |  | ■ | × | × | × |
| sys_function | 845 | sys_function | 以下のカラム追加<br>　・is_nkk<br>　・system_use_disp | 変更 | MOR | 44099 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C848="",COUNTIF($C$3:C848,C848)<COUNTIF(C:C,C848)),"",C848) | 846 | sys_function_advanced | 以下のカラム追加<br>　・is_nkk<br>　・system_use_disp | 変更 | MOR | 44099 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C849="",COUNTIF($C$3:C849,C849)<COUNTIF(C:C,C849)),"",C849) | 847 | mst_self_measure_result | 新規追加 | 新規 | MOR | 44099 | 1.0.0.0 |  | ■ | × | × | × |
| mnt_cardapp_port | 848 | mnt_cardapp_port | 新規追加 | 新規 | 孫少凱 | 44099 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C851="",COUNTIF($C$3:C851,C851)<COUNTIF(C:C,C851)),"",C851) | 849 | mst_pat_calendar_layout | 「disp_item_info」にキー「検査結果、検査予定、一般撮影検査予定、処方、バイタルモニタグラフ」を追加 | 変更 | 劉金玉 | 44106 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C852="",COUNTIF($C$3:C852,C852)<COUNTIF(C:C,C852)),"",C852) | 850 | mni_monitor | @mni_monitoシートにDRY装置の工程を追加 | 変更 | TDC | 44106 | 1.0.0.0. |  | ■ | × | × | × |
| =IF(OR(C853="",COUNTIF($C$3:C853,C853)<COUNTIF(C:C,C853)),"",C853) | 851 | mnt_machine_state | @mni_machine_stateシートにDRY装置の工程を追加 | 変更 | TDC | 44106 | 1.0.0.0. |  | ■ | × | × | × |
| =IF(OR(C854="",COUNTIF($C$3:C854,C854)<COUNTIF(C:C,C854)),"",C854) | 852 | mst_machine_type | 以下のカラムのデータ型の桁数を変更<br>　・treat_mode<br>@mst_machine_typeシート<br>　・装置モードに11桁目を記載 | 変更 | MOR | 44109 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C855="",COUNTIF($C$3:C855,C855)<COUNTIF(C:C,C855)),"",C855) | 853 | sys_facility_setting | @sys_facility_settingシート<br>No1065 大画面表示のお知らせ内容 の追加 | 変更 | TDC | 44112 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C856="",COUNTIF($C$3:C856,C856)<COUNTIF(C:C,C856)),"",C856) | 854 | pat_name_identification | 9:中止のステータスを追加 | 変更 | 毛懐虎 | 44112 | 1.0.0.0 |  | ■ |  |  |  |
| mnt_device_edge_state | 855 | mnt_device_edge_state | 以下のカラムの追加<br>・alive_moni_status_change_date | 変更 | TDC | 44113 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C858="",COUNTIF($C$3:C858,C858)<COUNTIF(C:C,C858)),"",C858) | 856 | mst_report | 以下のカラム項目を追加<br>・up_user(更新者) | 変更 | 李龍 | 44113 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C859="",COUNTIF($C$3:C859,C859)<COUNTIF(C:C,C859)),"",C859) | 857 | mst_vital_graph | 治療記録バイタルグラフマスタ 新規 | 新規 | 王辉 | 44116 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C860="",COUNTIF($C$3:C860,C860)<COUNTIF(C:C,C860)),"",C860) | 858 | mst_monitor_graph | 列追加 | 变更 | 王辉 | 44116 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C861="",COUNTIF($C$3:C861,C861)<COUNTIF(C:C,C861)),"",C861) | 859 | mni_monitor | @mni_monitoシートにDRY装置のモニタ項目を追加 | 変更 | TDC | 44117 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C862="",COUNTIF($C$3:C862,C862)<COUNTIF(C:C,C862)),"",C862) | 860 | mnt_machine_state | @mni_machine_state/@@mnt_machine_stateシートに<br>DRY装置以下情報を追加<br>・工程変換値<br>・動作時間 | 変更 | TDC | 44117 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C863="",COUNTIF($C$3:C863,C863)<COUNTIF(C:C,C863)),"",C863) | 861 | mnt_motion_record | @mnt_motion_record/@@mnt_motion_recordシートに<br>DRY装置の溶解記録を追加 | 変更 | TDC | 44117 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C864="",COUNTIF($C$3:C864,C864)<COUNTIF(C:C,C864)),"",C864) | 862 | mst_exam_item | 列追加(透析工程フラグ) | 新規 | 杜建利 | 44118 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C865="",COUNTIF($C$3:C865,C865)<COUNTIF(C:C,C865)),"",C865) | 863 | mst_mainte_category | 以下のカラム項目を追加<br>・detail(詳細) | 変更 | 杜建利 | 44118 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C866="",COUNTIF($C$3:C866,C866)<COUNTIF(C:C,C866)),"",C866) | 864 | mst_mainte_category_hst | 以下のカラム項目を追加<br>・detail(詳細) | 変更 | 杜建利 | 44118 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C867="",COUNTIF($C$3:C867,C867)<COUNTIF(C:C,C867)),"",C867) | 865 | mst_weight | @mst_weightのチェック項目jsonに有効／無効フラグのキーを追加 | 変更 | TDC | 44118 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C868="",COUNTIF($C$3:C868,C868)<COUNTIF(C:C,C868)),"",C868) | 866 | mst_weight | @mst_weightのチェック項目JSON有効／無効フラグの凡例変更 | 変更 | TDC | 44118 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C869="",COUNTIF($C$3:C869,C869)<COUNTIF(C:C,C869)),"",C869) | 867 | sys_facility_setting | @sys_facility_setting<br>テーブル追加 | 追加 | 孔帅 | 44119 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C870="",COUNTIF($C$3:C870,C870)<COUNTIF(C:C,C870)),"",C870) | 868 | sys_facility_setting | @sys_facility_setting<br>テーブル変更 | 変更 | 孔帅 | 44119 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C871="",COUNTIF($C$3:C871,C871)<COUNTIF(C:C,C871)),"",C871) | 869 | mnt_machine_state | @mni_machine_stateシートのDRY装置工程変換値を差し替え | 変更 | TDC | 44120 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C872="",COUNTIF($C$3:C872,C872)<COUNTIF(C:C,C872)),"",C872) | 870 | sys_system_define | @sys_system_defineシート<br>　・管理番号29～31の定義を変更<br>　・管理番号33を追加 | 変更 | MOR | 44123 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C873="",COUNTIF($C$3:C873,C873)<COUNTIF(C:C,C873)),"",C873) | 871 | mst_facility | 以下のカラムを削除<br>　・retention_period | 変更 | MOR | 44123 | 1.0.0.0 |  | ■ | × | × | × |
| sys_master_define | 872 | sys_master_define | 以下の内容の修正<br>・column_infoの修正<br>・combo_dataの修正 | 変更 | 徐天宇 | 44123 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C875="",COUNTIF($C$3:C875,C875)<COUNTIF(C:C,C875)),"",C875) | 873 | @mst_pat_viewer_layout | 構造変更 | 変更 | 王辉 | 44124 | 1.0.0.0 |  | =IFERROR(IF(C875=VLOOKUP(C875,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C875&"!A1","■"),""),"") |  |  |  |
| mst_implant | 874 | mst_implant | standard_implant_cd を数字型から文字列型にする | 変更 | 杨忠诚 | 44124 | 1.0.0.0 |  | ■ |  |  |  |
| mst_course | 875 | mst_course | 標準診療科コードを数字型から文字列型にする | 変更 | 王辉 | 44124 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C878="",COUNTIF($C$3:C878,C878)<COUNTIF(C:C,C878)),"",C878) | 876 | pat_main | 列追加 | 变更 | 韓国巳 | 44124 | 1.0.0.0 |  | ■ |  |  |  |
| pat_exam_pattern | 877 | pat_exam_pattern | 以下のカラムを追加<br>・ind_user_id | 変更 | MOR | 44126 | 1.0.0.0 |  | ■ | × | × | × |
| pat_rad_pattern | 878 | pat_rad_pattern | 以下のカラムを追加<br>・ind_user_id | 変更 | MOR | 44126 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C881="",COUNTIF($C$3:C881,C881)<COUNTIF(C:C,C881)),"",C881) | 879 | sys_system_define | @sys_system_defineシート<br>　・管理番号32の定義を変更 | 変更 | MOR | 44127 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C882="",COUNTIF($C$3:C882,C882)<COUNTIF(C:C,C882)),"",C882) | 880 | mnt_notification_message | 以下のカラムを追加<br>・facility_cd | 変更 | MOR | 44127 | 1.0.0.0 |  | ■ | × | × | × |
| mnt_notification_status | 881 | mnt_notification_status | 以下のカラムを追加<br>・facility_cd | 変更 | MOR | 44127 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C884="",COUNTIF($C$3:C884,C884)<COUNTIF(C:C,C884)),"",C884) | 882 | mnt_weight_state | 以下のカラムを追加<br>・facility_cd | 変更 | MOR | 44127 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C885="",COUNTIF($C$3:C885,C885)<COUNTIF(C:C,C885)),"",C885) | 883 | mst_user | 以下のカラムを追加<br>・facility_cd | 変更 | MOR | 44127 | 1.0.0.0 |  | ■ | × | × | × |
| mst_weight_print | 884 | mst_weight_print | 以下のカラムを追加<br>・facility_cd | 変更 | MOR | 44127 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C887="",COUNTIF($C$3:C887,C887)<COUNTIF(C:C,C887)),"",C887) | 885 | ord_checklist | 以下のカラムを追加<br>・facility_cd | 変更 | MOR | 44127 | 1.0.0.0 |  | ■ | × | × | × |
| pat_group_detail | 886 | pat_group_detail | 以下のカラムを追加<br>・facility_cd | 変更 | MOR | 44127 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C889="",COUNTIF($C$3:C889,C889)<COUNTIF(C:C,C889)),"",C889) | 887 | pat_ind_approve | 以下のカラムを追加<br>・facility_cd | 変更 | MOR | 44127 | 1.0.0.0 |  | ■ | × | × | × |
| pat_ind_approve_history | 888 | pat_ind_approve_history | 以下のカラムを追加<br>・facility_cd | 変更 | MOR | 44127 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C891="",COUNTIF($C$3:C891,C891)<COUNTIF(C:C,C891)),"",C891) | 889 | pat_unique | 以下のカラムを追加<br>・facility_cd | 変更 | MOR | 44127 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C892="",COUNTIF($C$3:C892,C892)<COUNTIF(C:C,C892)),"",C892) | 890 | sys_system_define | @sys_system_defineシート<br>　・管理番号34を追加 | 変更 | MOR | 44127 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C893="",COUNTIF($C$3:C893,C893)<COUNTIF(C:C,C893)),"",C893) | 891 | mst_machine_record_control | 新規追加 | 新規 | 孔帅 | 44131 | 1.0.0.0 |  | ■ |  |  |  |
| mni_monitor | 892 | mni_monitor | データタイプを追加：<br>　７：IAP Rate、８：IHDF引き残し量、９：静的静脈圧 | 変更 | 尚　利洪 | 44132 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C895="",COUNTIF($C$3:C895,C895)<COUNTIF(C:C,C895)),"",C895) | 893 | mst_facility | 以下のカラム項目を追加<br>・vpn_set(VPNセット) | 変更 | 孔帅 | 44134 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C896="",COUNTIF($C$3:C896,C896)<COUNTIF(C:C,C896)),"",C896) | 894 | sys_facility_setting | @sys_facility_setting<br>・facility_setting_no变更 | 変更 | 孔帅 | 44137 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C897="",COUNTIF($C$3:C897,C897)<COUNTIF(C:C,C897)),"",C897) | 895 | sys_facility_setting | @sys_facility_setting<br>・追加 患者イベント変更機能 | 変更 | 孔帅 | 44137 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C898="",COUNTIF($C$3:C898,C898)<COUNTIF(C:C,C898)),"",C898) | 896 | mst_self_measure_result | 新規追加 | 新規 | 尚　利洪 | 44139 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C899="",COUNTIF($C$3:C899,C899)<COUNTIF(C:C,C899)),"",C899) | 897 | mst_comsv_setting | 以下のカラム項目を追加<br>・is_notice_medi(投薬変更のお知らせ) | 変更 | 劉金玉 | 44140 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C900="",COUNTIF($C$3:C900,C900)<COUNTIF(C:C,C900)),"",C900) | 898 | pat_main | acceptance_status_infoのJSON構造を変更(備考を修正) | 変更 | TDC | 44145 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C901="",COUNTIF($C$3:C901,C901)<COUNTIF(C:C,C901)),"",C901) | 899 | mst_vital_graph | 以下の内容の修正<br>・vital_line_type_valueの論理名の修正<br>・vital_point_type_valueの論理名の修正 | 変更 | 孔帅 | 44145 | 1.0.0.0 |  | ■ |  |  |  |
| mst_vital_graph | 900 | mst_vital_graph | 以下の内容の修正<br>・vital_line_type_valueの桁の修正 | 変更 | 孔帅 | 44147 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C903="",COUNTIF($C$3:C903,C903)<COUNTIF(C:C,C903)),"",C903) | 901 | log_table_comment | table_commentテーブル追加 | 新規 | 解　宝喆 | 44151 | 1.0.0.0 |  | ■ |  |  |  |
| log_json_comment | 902 | log_json_comment | json_commentテーブル追加 | 新規 | 解　宝喆 | 44151 | 1.0.0.0 |  | ■ |  |  |  |
| mnt_facility_cancel_manage | 903 | mnt_facility_cancel_manage | 以下のカラムを追加<br>・stats_nosql<br><br>処理区分を追加 | 変更 | MOR | 44151 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C906="",COUNTIF($C$3:C906,C906)<COUNTIF(C:C,C906)),"",C906) | 904 | sys_system_define | @sys_system_defineシート<br>　・管理番号30の値、説明を変更 | 変更 | MOR | 44151 | 1.0.0.0 |  | ■ | × | × | × |
| mst_facility_hash | 905 | mst_facility_hash | 以下のカラムを追加<br>・url_signin<br>・url_signin_secretkey | 変更 | MOR | 44151 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C908="",COUNTIF($C$3:C908,C908)<COUNTIF(C:C,C908)),"",C908) | 906 | sys_facility_setting | @sys_facility_settingシート<br>　・施設管理番号2001、2002を追加 | 変更 | MOR | 44151 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C909="",COUNTIF($C$3:C909,C909)<COUNTIF(C:C,C909)),"",C909) | 907 | sys_system_define | @sys_system_defineシート<br>　・管理番号30の値、説明を変更 | 変更 | MOR | 44152 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C910="",COUNTIF($C$3:C910,C910)<COUNTIF(C:C,C910)),"",C910) | 908 | mnt_motion_record | 列：レポート表示フラグ（report_disp_flg）を追加 | 変更 | 尚　利洪 | 44152 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C911="",COUNTIF($C$3:C911,C911)<COUNTIF(C:C,C911)),"",C911) | 909 | mst_exam_set | 列：標準値（exam_item_info）を追加 | 変更 | 杜建利 | 44153 | 1.0.0.0 |  | ■ |  |  |  |
| mst_kur | 910 | mst_kur | 担当医情報(mst_user_authentication)を追加 | 変更 | 王辉 | 44153 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C913="",COUNTIF($C$3:C913,C913)<COUNTIF(C:C,C913)),"",C913) | 911 | sys_system_define | @sys_system_defineシート<br>　・管理番号27，28のデフォルト変更 | 変更 | NKK | 44154 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C914="",COUNTIF($C$3:C914,C914)<COUNTIF(C:C,C914)),"",C914) | 912 | sys_facility_setting | @sys_facility_setting<br>　・1036、1037：デフォルト変更<br>　・1051、1052、1053、1054：誤記修正 | 変更 | NKK | 44154 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C915="",COUNTIF($C$3:C915,C915)<COUNTIF(C:C,C915)),"",C915) | 913 | mst_treatment_status_disp_item | mst_treatment_status_disp_itemのデータを追加<br>・111:警報・報知 | 変更 | 付名 | 44154 | 1.0.0.0 | V20201028090000__add_mst_treatment_status_disp_item | ■ |  |  |  |
| =IF(OR(C916="",COUNTIF($C$3:C916,C916)<COUNTIF(C:C,C916)),"",C916) | 914 | sys_facility_setting | sys_facility_settingのデータを追加<br>・2001:治療状況自動更新間隔 | 変更 | 付名 | 44154 | 1.0.0.0 | V20201028090001__add_sys_facility_setting | ■ |  |  |  |
| =IF(OR(C917="",COUNTIF($C$3:C917,C917)<COUNTIF(C:C,C917)),"",C917) | 915 | sys_facility_setting | @sys_facility_setting<br>機能名変更<br>1003<br>名称変更<br>1003<br>説明変更<br>1003,1036,1037,1038,1048,1051,1052,1053,1054,1055,1056,1057,1058,1059,1060,1061,1062,1063,1064 | 変更 | NKK | 44161 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C918="",COUNTIF($C$3:C918,C918)<COUNTIF(C:C,C918)),"",C918) | 916 | sys_facility_setting | @sys_facility_settingシート<br>No1066（治療時間判定時間）の追加 | 変更 | TDC | 44162 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C919="",COUNTIF($C$3:C919,C919)<COUNTIF(C:C,C919)),"",C919) | 915 | mst_report | 項目「更新者」削除<br>項目「帳票更新履歴」追加 | 変更 | 孫少凱 | 44162 | 1.0.0.0 | V20201127103001__change_column_for_mst_report.sql | ■ |  |  |  |
| mst_machine_record | 916 | mst_machine_record | 項目「表示フラグ」追加 | 変更 | 孔帅 | 44162 | 1.0.0.0 | V20201127110002__add_columns_for_mst_machine_record.sql | ■ |  |  |  |
| =IF(OR(C921="",COUNTIF($C$3:C921,C921)<COUNTIF(C:C,C921)),"",C921) | 917 | mst_machine_record_control | 項目「装置フラグ」削除<br>項目「警報フラグ」削除 | 新規 | 孔帅 | 44162 | 1.0.0.0 | V20201127110003__create_table_for_mst_machine_record_control.sql | ■ |  |  |  |
| =IF(OR(C922="",COUNTIF($C$3:C922,C922)<COUNTIF(C:C,C922)),"",C922) | 918 | mst_comsv_setting | 治療中バイタル通知間隔，治療外バイタル通知間隔 追加 | 変更 | 杨忠诚 | 44165 | 1.0.0.0 | V20201130170004__add_columns_for_mst_comsv_setting.sql | ■ |  |  |  |
| =IF(OR(C923="",COUNTIF($C$3:C966,C923)<COUNTIF(C:C,C923)),"",C923) | 956 | sys_facility_setting | @sys_facility_settingシート<br>No1066 の番号を 2003 に変更 | 変更 | TDC | 44165 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C924="",COUNTIF($C$3:C924,C924)<COUNTIF(C:C,C924)),"",C924) | 919 | mst_mainte_layout | 新規カラム追加 | 変更 | 王辉 | 44166 | 1.0.0.0 | V20201201090001__add_columns_for_mst_mainte_layout.sql | ■ |  |  |  |
| mst_mainte_layout_hst | 920 | mst_mainte_layout_hst | 新規カラム追加 | 変更 | 王辉 | 44166 | 1.0.0.0 | V20201201090002__add_columns_for_mst_mainte_layout_hst.sql | ■ |  |  |  |
| =IF(OR(C926="",COUNTIF($C$3:C926,C926)<COUNTIF(C:C,C926)),"",C926) | 921 | mst_exam_set | 新規カラム追加(グラフセット graph_set) | 変更 | 杜建利 | 44166 | 1.0.0.0 | V20201201180001__add_columns_for_mst_exam_set.sql | ■ |  |  |  |
| =IF(OR(C927="",COUNTIF($C$3:C927,C927)<COUNTIF(C:C,C927)),"",C927) | 922 | log_table_comment(db4) | table_commentテーブル(DB4)追加 | 新規 | 解　宝喆 | 44166 | 1.0.0.0 |  | ■ |  |  |  |
| log_json_comment(db4) | 923 | log_json_comment(db4) | json_commentテーブル(DB4)追加 | 新規 | 解　宝喆 | 44166 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C929="",COUNTIF($C$3:C929,C929)<COUNTIF(C:C,C929)),"",C929) | 924 | log_table_comment(db6) | table_commentテーブル(DB6)追加 | 新規 | 解　宝喆 | 44166 | 1.0.0.0 |  | ■ |  |  |  |
| log_json_comment(db6) | 925 | log_json_comment(db6) | json_commentテーブル(DB6)追加 | 新規 | 解　宝喆 | 44166 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C931="",COUNTIF($C$3:C931,C931)<COUNTIF(C:C,C931)),"",C931) | 926 | sys_facility_setting | sys_facility_settingのデータを追加<br>・3006:医療材料表示順<br>・3007:投与薬剤表示順 | 変更 | 孔帅 | 44166 | 1.0.0.0 | V20201201183002__add_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C932="",COUNTIF($C$3:C932,C932)<COUNTIF(C:C,C932)),"",C932) | 927 | mst_comsv_setting | 治療中リアルタイムモニタ通知間隔，治療外リアルタイムモニタ通知間隔 追加 | 変更 | 杨忠诚 | 44173 | 1.0.0.0 | V20201208080001__add_columns_for_mst_comsv_setting.sql | ■ |  |  |  |
| mst_taboo_allergy | 928 | mst_taboo_allergy | 禁忌・アレルギーマスタのdetail_info「詳細」説明を変更 | 変更 | 孔帅 | 44173 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C934="",COUNTIF($C$3:C934,C934)<COUNTIF(C:C,C934)),"",C934) | 957 | mnt_motion_record | 緊急発報ステータス m_notice_status の凡例に <br>9：スキップ<br>を追加 | 変更 | TDC | 44173 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C935="",COUNTIF($C$3:C935,C935)<COUNTIF(C:C,C935)),"",C935) | 929 | sys_facility_setting | sys_facility_settingのデータを追加<br>・3009:分類不一致発生時条件送信設定 | 変更 | 孔帅 | 44176 | 1.0.0.0 | V20201211093001__add_sys_facility_setting.sql | ■ |  |  |  |
| mst_exam_matome | 930 | mst_exam_matome | 新しいテーブル臨床検査マスタ | 新規 | 杜建利 | 44176 | 1.0.0.0 | V20201211140003__add_mst_exam_matome.sql | ■ |  |  |  |
| =IF(OR(C937="",COUNTIF($C$3:C937,C937)<COUNTIF(C:C,C937)),"",C937) | 931 | mst_exam_item | 正常値(上限) 正常値(下限) 正常値(男性上限) 正常値(男性下限) 正常値(女性上限) 正常値(女性下限) 入力上限値 入力下限値 グラフ上限値 グラフ下限値  データタイプの変更 | 変更 | 杜建利 | 44176 | 1.0.0.0 | V20201211140002__update_mst_exam_item.sql | ■ |  |  |  |
| =IF(OR(C938="",COUNTIF($C$3:C938,C938)<COUNTIF(C:C,C938)),"",C938) | 932 | sys_report_setting | 機能帳票マスタ  再依賴 | 新規 | 王辉 | 44180 | 1.0.0.0 | V20201215130000__create_table_for_sys_report_setting.sql | ■ |  |  |  |
| =IF(OR(C939="",COUNTIF($C$3:C939,C939)<COUNTIF(C:C,C939)),"",C939) | 933 | mst_mainte_category | 定期点検項目グループマスタ   -  >  日常・定期点検項目グループマスタ | 変更 | 杜建利 | 44182 | 1.0.0.0 | V20201217132001__update_mst_mainte_category.sql | ■ |  |  |  |
| =IF(OR(C940="",COUNTIF($C$3:C940,C940)<COUNTIF(C:C,C940)),"",C940) | 934 | mst_facility | 以下の内容の修正<br>・vpn_setの備考の修正 | 変更 | 孔帅 | 44182 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C941="",COUNTIF($C$3:C941,C941)<COUNTIF(C:C,C941)),"",C941) | 935 | bbs_info | 以下のカラムを追加<br>notice_fac_cal_start_time<br>notice_fac_cal_end_time<br>is_time_start_flg<br>is_time_end_flg<br>以下のカラムを型変更（「timestamp」→「8桁文字列」）<br>notice_start_date<br>notice_end_date<br>notice_fac_cal_start_date<br>notice_fac_cal_end_date | 変更 | 趙立強 | 44179 | 1.0.0.0 | V20201214100104__alter_bbs_info.sql | ■ |  |  |  |
| =IF(OR(C942="",COUNTIF($C$3:C942,C942)<COUNTIF(C:C,C942)),"",C942) | 958 | mst_device_set_info_default | 以下のカラムを追加<br>・host_notification_info<br>@mst_device_set_info_defaultを更新 | 変更 | MOR | 44186 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C943="",COUNTIF($C$3:C943,C943)<COUNTIF(C:C,C943)),"",C943) | 959 | pat_main | 以下のカラムを追加<br>・host_notification_info<br>@device_set_infoシートにホスト報知定義を追加 | 変更 | MOR | 44186 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C944="",COUNTIF($C$3:C944,C944)<COUNTIF(C:C,C944)),"",C944) | 960 | sys_notification | @sys_notificationシート<br>　・通知定義番号17を追加 | 変更 | MOR | 44186 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C945="",COUNTIF($C$3:C966,C945)<COUNTIF(C:C,C945)),"",C945) | 961 | mnt_machine_state | 警報、注意発生中リスト alarm_list の凡例に<br>ホスト報知状態保持用の定義を記述 | 変更 | TDC | 44187 | 1.0.0.0 |  | ■ | × | × | × |
| =IF(OR(C946="",COUNTIF($C$3:C946,C946)<COUNTIF(C:C,C946)),"",C946) | 936 | sys_facility_setting | sys_facility_settingのデータを变更:3005 患者イベント変更機能 文言の変更 | 変更 | 孔帅 | 44187 | 1.0.0.0 | V20201222110001__update_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C947="",COUNTIF($C$3:C947,C947)<COUNTIF(C:C,C947)),"",C947) | 937 | sys_facility_setting | sys_facility_settingのデータを追加<br>・3010:DP=Qd+Qs(補液速度加算)表示切替え | 変更 | 孔帅 | 44187 | 1.0.0.0 | V20201222150001__add_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C948="",COUNTIF($C$3:C948,C948)<COUNTIF(C:C,C948)),"",C948) | 938 | ord_material_save | 計算材料保持テーブル | 新規 | 郭 | 44187 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C949="",COUNTIF($C$3:C949,C949)<COUNTIF(C:C,C949)),"",C949) | 939 | sys_notification | ’sys_notificationのデータを追加<br>通知定義番号が20~25のデータを追加する | 変更 | 孫少凱 | 44189 | 1.0.0.0 | V20201224130101__insert_sys_notification.sql | ■ |  |  |  |
| mst_weight | 940 | mst_weight | カラムを追加<br>telegram_format | 変更 | 商奎偉 | 44190 | 1.0.0.0 | V20201225080001__add_column_for_mst_weight.sql | ■ |  |  |  |
| =IF(OR(C951="",COUNTIF($C$3:C951,C951)<COUNTIF(C:C,C951)),"",C951) | 941 | mst_mainte_detail | 日常・定期点検項目マスタ  用途   回答パターン   補足コメント有無    初期展開テキスト | 新規 | 杜建利 | 44190 | 1.0.0.0 | V20201225093001__add_columns_for_mst_mainte_detail.sql | ■ |  |  |  |
| mst_mainte_detail_hst | 942 | mst_mainte_detail_hst | 日常・定期点検項目マスタ  用途   回答パターン   補足コメント有無    初期展開テキスト | 新規 | 杜建利 | 44190 | 1.0.0.0 | V20201225093002__add_columns_for_mst_mainte_detail_hst.sql | ■ |  |  |  |
| =IF(OR(C953="",COUNTIF($C$3:C953,C953)<COUNTIF(C:C,C953)),"",C953) | 943 | mst_mainte_category | 日常・定期点検項目グループマスタ 用途 | 新規 | 杜建利 | 44190 | 1.0.0.0 | V20201225110001__add_columns_for_mst_mainte_category.sql | ■ |  |  |  |
| mst_mainte_category_hst | 944 | mst_mainte_category_hst | 日常・定期点検項目グループマスタ  用途 | 新規 | 杜建利 | 44190 | 1.0.0.0 | V20201225110002__add_columns_for_mst_mainte_category_hst.sql | ■ |  |  |  |
| =IF(OR(C955="",COUNTIF($C$3:C955,C955)<COUNTIF(C:C,C955)),"",C955) | 945 | sys_notification | ’sys_notificationのデータを変更 | 変更 | 孫少凱 | 44190 | 1.0.0.0 | V20201225150105__update_sys_notification.sql | ■ |  |  |  |
| =IF(OR(C956="",COUNTIF($C$3:C956,C956)<COUNTIF(C:C,C956)),"",C956) | 946 | mst_exam_item | 検査項目マスタ   計算式領域free_calc   上限の削除 | 変更 | 杜建利 | 44193 | 1.0.0.0 | V20201228090001__update_columns_for_mst_exam_item.sql | ■ |  |  |  |
| =IF(OR(C957="",COUNTIF($C$3:C957,C957)<COUNTIF(C:C,C957)),"",C957) | 947 | sys_function_advanced | 拡張機能コード一覧に[A10投薬支援]を追加します | 変更 | 孔帅 | 44193 | 1.0.0.0 | V20201228113001__insert_sys_function_advanced.sql | ■ |  |  |  |
| =IF(OR(C958="",COUNTIF($C$3:C958,C958)<COUNTIF(C:C,C958)),"",C958) | 948 | sys_facility_setting | sys_facility_settingのデータを削除<br>・51-58遠隔監視を削除 | 変更 | 孔帅 | 44194 | 1.0.0.0 | V20201229100001__delete_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C959="",COUNTIF($C$3:C959,C959)<COUNTIF(C:C,C959)),"",C959) | 949 | sys_facility_setting | sys_facility_settingのデータを追加<br>・3011:前回検査日設定 | 変更 | 孔帅 | 44194 | 1.0.0.0 | V20201229100002__add_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C960="",COUNTIF($C$3:C960,C960)<COUNTIF(C:C,C960)),"",C960) | 950 | sys_facility_setting | sys_facility_settingのデータを追加<br>・3012:前回定義期間 | 変更 | 杜建利 | 44201 | 1.0.0.0 | V20210105143001__add_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C961="",COUNTIF($C$3:C961,C961)<COUNTIF(C:C,C961)),"",C961) | 951 | mst_medicine_support | 投薬支援マスタ新規追加 | 新規 | 孔帅 | 44202 | 1.0.0.0 | V20210106140001__create_table_mst_medication_support.sql | ■ |  |  |  |
| =IF(OR(C962="",COUNTIF($C$3:C962,C962)<COUNTIF(C:C,C962)),"",C962) | 952 | ord_main_restore | 治療情報復元新規追加 | 新規 | 呉 | 44202 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C963="",COUNTIF($C$3:C963,C963)<COUNTIF(C:C,C963)),"",C963) | 953 | ord_main | カラムを追加<br>up_ind_user_id<br>up_user_id | 新規 | 郭 | 44204 | 1.0.0.0 | V20201209100001__add_columns_for_ord_main.sql | ■ |  |  |  |
| =IF(OR(C964="",COUNTIF($C$3:C964,C964)<COUNTIF(C:C,C964)),"",C964) | 953 | ord_checklist | チェックリスト項目情報にJson構造の追記<br>・薬剤区分<br>チェックリスト項目情報詳細追記 | 変更 | 張洪勇 | 44204 | 1.0.0.0 |  | ■ |  |  |  |
| ord_checklist | 954 | ord_checklist | 実績区分:「9 リスト基準」追記 | 変更 | 張洪勇 | 44204 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C966="",COUNTIF($C$3:C966,C966)<COUNTIF(C:C,C966)),"",C966) | 955 | bbs_info | 以下のカラムを追加<br>font_color | 変更 | 趙立強 | 44204 | 1.0.0.0 | V20210108140104__alter_bbs_info.sql | ■ |  |  |  |
| =IF(OR(C967="",COUNTIF($C$3:C967,C967)<COUNTIF(C:C,C967)),"",C967) | 962 | mst_checklist | チェックリスト設定にJson構造の追記<br>・投与薬剤 | 変更 | 張洪勇 | 44208 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C968="",COUNTIF($C$3:C968,C968)<COUNTIF(C:C,C968)),"",C968) | 963 | mst_mainte_category | json構造変更 | 変更 | 杜建利 | 44208 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C969="",COUNTIF($C$3:C969,C969)<COUNTIF(C:C,C969)),"",C969) | 964 | sys_notification | ’sys_notificationのデータを変更 | 変更 | 孫少凱 | 44209 | 1.0.0.0 | V20201228100101__update_sys_notification.sql | ■ |  |  |  |
| =IF(OR(C970="",COUNTIF($C$3:C970,C970)<COUNTIF(C:C,C970)),"",C970) | 965 | sys_notification | ’sys_notificationのデータを変更 | 変更 | 孫少凱 | 44209 | 1.0.0.0 | V20201228161501__update_sys_notification.sql | ■ |  |  |  |
| =IF(OR(C971="",COUNTIF($C$3:C971,C971)<COUNTIF(C:C,C971)),"",C971) | 966 | mst_mainte_layout | json構造変更 | 変更 | 杜建利 | 44209 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C972="",COUNTIF($C$3:C972,C972)<COUNTIF(C:C,C972)),"",C972) | 967 | sys_facility_setting | @sys_facility_settingに定義（1007）を変更 | 変更 | 孔帅 | 44211 | 1.0.0.0 | V20210115160001__update_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C973="",COUNTIF($C$3:C973,C973)<COUNTIF(C:C,C973)),"",C973) | 968 | sys_facility_setting | @sys_facility_settingに定義（1008）を変更 | 変更 | 孔帅 | 44211 | 1.0.0.0 | V20210115160002__update_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C974="",COUNTIF($C$3:C974,C974)<COUNTIF(C:C,C974)),"",C974) | 969 | mnt_mainte_main | json構造変更（点検マスタ（新）r3.xlsxの内容を反映） | 変更 | 王穎 | 44215 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C975="",COUNTIF($C$3:C975,C975)<COUNTIF(C:C,C975)),"",C975) | 970 | log_table_comment(db4) | log_table_comment(db4)<br>コラムpk_flg、delete_flgを追加 | 変更 | 解　宝喆 | 44217 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C976="",COUNTIF($C$3:C976,C976)<COUNTIF(C:C,C976)),"",C976) | 971 | log_table_comment(db5) | log_table_comment(db5)<br>コラムpk_flg、delete_flgを追加 | 変更 | 解　宝喆 | 44217 | 1.0.0.0 |  | =IFERROR(IF(C976=VLOOKUP(C976,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C976&"!A1","■"),""),"") |  |  |  |
| =IF(OR(C977="",COUNTIF($C$3:C977,C977)<COUNTIF(C:C,C977)),"",C977) | 972 | log_table_comment(db6) | log_table_comment(db6)<br>コラムpk_flg、delete_flgを追加 | 変更 | 解　宝喆 | 44217 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C978="",COUNTIF($C$3:C978,C978)<COUNTIF(C:C,C978)),"",C978) | 973 | sys_function_advanced | B列PKを追加 | 変更 | 解　宝喆 | 44222 | 1.0.0.0 |  | ■ |  |  |  |
| pat_ind_approve | 974 | pat_ind_approve | B列PKを追加 | 変更 | 解　宝喆 | 44222 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C980="",COUNTIF($C$3:C980,C980)<COUNTIF(C:C,C980)),"",C980) | 975 | pat_insurance | B列PKを追加 | 変更 | 解　宝喆 | 44222 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C981="",COUNTIF($C$3:C981,C981)<COUNTIF(C:C,C981)),"",C981) | 976 | ord_personal_prescription | B列PKを追加 | 変更 | 解　宝喆 | 44222 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C982="",COUNTIF($C$3:C982,C982)<COUNTIF(C:C,C982)),"",C982) | 977 | sys_facility | 全施設マスタ表 改善対応 | 変更 | 孔帅 | 44225 | 1.0.0.0 | V20210129140001__create_tables_for_sys_facility.sql | ■ |  |  |  |
| log_table_comment(db4) | 978 | log_table_comment(db4) | log_table_comment(db4)<br>コラムord_main_hst_ins_flgを追加 | 変更 | 解　宝喆 | 44217 | 1.0.0.0 | V20210204210001__alter_log_table_comment.sql | ■ |  |  |  |
| log_table_comment(db5) | 979 | log_table_comment(db5) | log_table_comment(db5)<br>コラムord_main_hst_ins_flgを追加 | 変更 | 解　宝喆 | 44217 | 1.0.0.0 | V20210204210001__alter_log_table_comment.sql | =IFERROR(IF(C984=VLOOKUP(C984,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C984&"!A1","■"),""),"") |  |  |  |
| log_table_comment(db6) | 980 | log_table_comment(db6) | log_table_comment(db6)<br>コラムord_main_hst_ins_flgを追加 | 変更 | 解　宝喆 | 44217 | 1.0.0.0 | V20210204210001__alter_log_table_comment.sql | ■ |  |  |  |
| sys_function_advanced | 981 | sys_function_advanced | 新規追加<br>「拡張機能コード一覧」シートの追加 | 変更 | 王辉 | 44236 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C987="",COUNTIF($C$3:C987,C987)<COUNTIF(C:C,C987)),"",C987) | 982 | mnt_recalc_que | 新規追加 | 変更 | 杜建利 | 44236 | 1.0.0.0 | V20210209103000__create_table_for_mnt_recalc_que.sql | ■ |  |  |  |
| =IF(OR(C988="",COUNTIF($C$3:C988,C988)<COUNTIF(C:C,C988)),"",C988) | 983 | ord_material_save | 物品区分、17：抗凝固剤調製薬剤を追加 | 変更 | 郭 | 43880 | 1.0.0.1 |  | ■ |  |  |  |
| mnt_machine_state | 984 | mnt_machine_state | monitor_dataJSON項目追加 | 変更 | 張 | 44247 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C990="",COUNTIF($C$3:C990,C990)<COUNTIF(C:C,C990)),"",C990) | 985 | sys_facility_setting | @sys_facility_settingに定義（3004）を変更 | 変更 | 孔帅 | 44250 | 1.0.0.0 | V20210222113001__update_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C991="",COUNTIF($C$3:C991,C991)<COUNTIF(C:C,C991)),"",C991) | 986 | sys_system_define | レコード「帳票モデル最新バージョン」を追加する | 変更 | 夏威 | 44251 | 1.0.0.0 | V20210224150000__add_masterdata_for_sys_system_define.sql | ■ |  |  |  |
| =IF(OR(C992="",COUNTIF($C$3:C992,C992)<COUNTIF(C:C,C992)),"",C992) | 987 | mst_facility | 以下の内容の追加<br>・system_use_settingの追加 | 変更 | 杜建利 | 43893 | 1.0.0.0 | V20210303201501__add_column_mst_facility.sql | ■ |  |  |  |
| mst_mainte_detail | 988 | mst_mainte_detail | 以下の内容の追加<br>・smainte_category_cd廃棄 | 変更 | 劉金玉 | 44259 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C994="",COUNTIF($C$3:C994,C994)<COUNTIF(C:C,C994)),"",C994) | 989 | ord_main | 「rst_treatment_info」にキーを追加：<br> 　　"linkStartDate":酸素吸入関連番号(*6)<br>　　　概要に説明を追加：<br>　　　(*6) 酸素吸入終了の場合、対応の酸素吸入開始のctl_noを記入する。 | 変更 | 呉 | 44266 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C995="",COUNTIF($C$3:C995,C995)<COUNTIF(C:C,C995)),"",C995) | 990 | ord_main_restore | 「rst_treatment_info」にキーを追加：<br> 　　"linkStartDate":酸素吸入関連番号(*6)<br>　　　概要に説明を追加：<br>　　　(*6) 酸素吸入終了の場合、対応の酸素吸入開始のctl_noを記入する。 | 変更 | 呉 | 44266 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C996="",COUNTIF($C$3:C996,C996)<COUNTIF(C:C,C996)),"",C996) | 991 | @mst_pat_viewer_layout | JSON定義 | 新規 | 王辉 | 44270 | 1.0.0.0 |  | =IFERROR(IF(C996=VLOOKUP(C996,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C996&"!A1","■"),""),"") |  |  |  |
| =IF(OR(C997="",COUNTIF($C$3:C997,C997)<COUNTIF(C:C,C997)),"",C997) | 992 | mst_addition | 以下のカラムを追加<br>・addition_dialysis_time | 変更 | MOR | 44270 | 1.0.0.0 | V20210312170000__add_column_for_mst_addition.sql | ■ |  |  |  |
| =IF(OR(C998="",COUNTIF($C$3:C998,C998)<COUNTIF(C:C,C998)),"",C998) | 993 | mnt_motion_record | インデックス(idx_mnt_motion_record_02)を追加 | 変更 | MOR | 44270 | 1.0.0.0 | V20201208999999__add_index_for_mnt_motion_record.sql | ■ |  |  |  |
| medi_latest_no | 994 | medi_latest_no | 投薬最新識別番号新規追加 | 新規 | 李興強 | 44273 | 1.0.0.0 | V20210318000005__create_medicine_latest_no_table.sql | =IFERROR(IF(C999=VLOOKUP(C999,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C999&"!A1","■"),""),"") |  |  |  |
| =IF(OR(C1000="",COUNTIF($C$3:C1000,C1000)<COUNTIF(C:C,C1000)),"",C1000) | 995 | pat_personal_main | pat_personal_mainの論理名修正<br>・患者基本情報 => 患者個人情報 | 変更 | 孔帅 | 44279 | 1.0.0.0 | V20210324090001__update_pat_personal_main.sql | ■ |  |  |  |
| =IF(OR(C1001="",COUNTIF($C$3:C1001,C1001)<COUNTIF(C:C,C1001)),"",C1001) | 996 | pat_unique | pat_uniqueの論理名修正<br>・患者基本情報 => 患者固有情報 | 変更 | 孔帅 | 44279 | 1.0.0.0 | V20210324090001__update_pat_unique.sql | ■ |  |  |  |
| bbs_info | 997 | bbs_info | is_del，is_disp追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| mnt_notification_message | 998 | mnt_notification_message | notification_no追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| mst_favorite_facility | 999 | mst_favorite_facility | medical_institution_cd追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1005="",COUNTIF($C$3:C1005,C1005)<COUNTIF(C:C,C1005)),"",C1005) | 1000 | mst_holiday | class追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| mst_insurance | 1001 | mst_insurance | insu_name_short追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| mst_pat_memo | 1002 | mst_pat_memo | is_del,is_disp追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| mst_status_map_bed_layout | 1003 | mst_status_map_bed_layout | is_home_dialysis追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| ord_exception_period | 1004 | ord_exception_period | ord_exception_period追加 | 新規 | 解　宝喆 | 44280 | 1.0.0.0 |  | =IFERROR(IF(C1009=VLOOKUP(C1009,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C1009&"!A1","■"),""),"") |  |  |  |
| pat_exam_main | 1005 | pat_exam_main | exam_from,exam_pattern,exam_to,exam_week追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1011="",COUNTIF($C$3:C1011,C1011)<COUNTIF(C:C,C1011)),"",C1011) | 1006 | pat_insurance | old_up_date追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1012="",COUNTIF($C$3:C1012,C1012)<COUNTIF(C:C,C1012)),"",C1012) | 1007 | pat_main | old_up_date追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| pat_name_identification | 1008 | pat_name_identification | reg_date追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1014="",COUNTIF($C$3:C1014,C1014)<COUNTIF(C:C,C1014)),"",C1014) | 1009 | pat_personal_main | old_up_date_personal追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| pat_rad_main | 1010 | pat_rad_main | rad_from,rad_pattern,rad_to,rad_week追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1016="",COUNTIF($C$3:C1016,C1016)<COUNTIF(C:C,C1016)),"",C1016) | 1011 | pat_unique | old_up_date_unique追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| sal_subscription_manage | 1012 | sal_subscription_manage | cancel_date,canceller追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| sys_facility | 1013 | sys_facility | fax_no1,fax_no2,phone_no1,phone_no2追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1019="",COUNTIF($C$3:C1019,C1019)<COUNTIF(C:C,C1019)),"",C1019) | 1014 | sys_notification | help追加 | 変更 | 解　宝喆 | 44280 | 1.0.0.0 |  | ■ |  |  |  |
| log_table_comment | 1015 | log_table_comment | シート追加：<br>log_table_commentデータ(db4)<br>log_table_commentデータ(db4)<br>log_table_commentデータ(db4) | 変更 | 解　宝喆 | 44285 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1021="",COUNTIF($C$3:C1021,C1021)<COUNTIF(C:C,C1021)),"",C1021) | 1016 | mst_holiday | mst_holiday_pkey_03  追加mst_holiday_pkey_02削除 | 変更 | 杜建利 | 44288 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1022="",COUNTIF($C$3:C1022,C1022)<COUNTIF(C:C,C1022)),"",C1022) | 1017 | mst_round_type | 以下のカラムを追加<br>・is_notification | 変更 | MOR | 44293 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1023="",COUNTIF($C$3:C1023,C1023)<COUNTIF(C:C,C1023)),"",C1023) | 1018 | sys_notification | @sys_notificationシート<br>　・通知定義番号29～36を追加 | 変更 | MOR | 44293 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1024="",COUNTIF($C$3:C1024,C1024)<COUNTIF(C:C,C1024)),"",C1024) | 1019 | sys_system_define | @sys_system_defineシート<br>　・管理番号12の値を変更 | 変更 | MOR | 44293 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1025="",COUNTIF($C$3:C1025,C1025)<COUNTIF(C:C,C1025)),"",C1025) | 1020 | sys_daily_no | 一意のキー制約を作成 | 変更 | 孫少凱 | 44295 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1026="",COUNTIF($C$3:C1026,C1026)<COUNTIF(C:C,C1026)),"",C1026) | 1021 | mst_machine_type | over_nxseries追加 | 変更 | 孔帅 | 44295 | 1.0.0.0 | V20210409170001__add_columns_for_mst_machine_type.sql | ■ |  |  |  |
| mst_water_survey_type | 1022 | mst_water_survey_type | initial_stringの備考を変更 | 変更 | 孔帅 | 44307 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1028="",COUNTIF($C$3:C1028,C1028)<COUNTIF(C:C,C1028)),"",C1028) | 1023 | sys_facility_setting | sys_facility_settingのデータを追加<br>・3018:マスタ削除発生時条件送信設定<br>・3019:マスタ期限切れ発生時条件送信設定 | 変更 | 孔帅 | 44309 | 1.0.0.0 | V20210423100001__add_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C1029="",COUNTIF($C$3:C1029,C1029)<COUNTIF(C:C,C1029)),"",C1029) | 1024 | mst_monitor_graph | クラス型長度修改 | 変更 | 王辉 | 44311 | 1.0.0.0 | V20210425170001__alert_mst_monitor_graph.sql | ■ |  |  |  |
| =IF(OR(C1030="",COUNTIF($C$3:C1030,C1030)<COUNTIF(C:C,C1030)),"",C1030) | 1025 | sys_system_define | @sys_system_defineシート<br>　・#3642対応で記載漏れしていた管理番号1000～1006を追加<br>　・管理番号1007を追加 | 変更 | MOR | 44312 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1031="",COUNTIF($C$3:C1031,C1031)<COUNTIF(C:C,C1031)),"",C1031) | 1026 | sys_facility_setting | sys_facility_settingのデータを变更:<br>1018帳票デザイナー 既定のプリンター の初期値は-1に設定します | 変更 | 孔帅 | 44314 | 1.0.0.0 | V20210428153001__update_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C1032="",COUNTIF($C$3:C1032,C1032)<COUNTIF(C:C,C1032)),"",C1032) | 1027 | mst_medicine_support | 検査値単位 追加 | 変更 | 杨忠诚 | 44330 | 1.0.0.0 | V20210514140002__alert_mst_medicine_support.sql | ■ |  |  |  |
| =IF(OR(C1033="",COUNTIF($C$3:C1033,C1033)<COUNTIF(C:C,C1033)),"",C1033) | 1028 | sys_facility_setting | sys_facility_settingのデータを变更:<br>・3006:入力方法,初期値を変更<br>・3007:入力方法,初期値を変更 | 変更 | 孔帅 | 44337 | 1.0.0.0 | V20210521172001__update_sys_facility_setting.sql | ■ |  |  |  |
| sys_report_setting | 1029 | sys_report_setting | sys_report_settingのデータを变更:<br>・03001:紹介状 | 変更 | 杜建利 | 44343 | 1.0.0.0 | V20210527091000__update_sys_report_setting.sql | ■ |  |  |  |
| =IF(OR(C1035="",COUNTIF($C$3:C1035,C1035)<COUNTIF(C:C,C1035)),"",C1035) | 1030 | sys_facility_setting | sys_facility_settingのデータを变更:<br>・2003:設定説明の変更<br>・3010:設定説明の変更 | 変更 | 孔帅 | 44342 | 1.0.0.0 | V20210526171001__update_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C1036="",COUNTIF($C$3:C1036,C1036)<COUNTIF(C:C,C1036)),"",C1036) | 1031 | sys_system_define | @sys_system_defineシート<br>　・管理番号14に項目「ses」を追加、項目「path」の値を変更<br>　・管理番号29の項目「backup_path_template_cancel」の値を変更<br>　・管理番号1007を変更<br>　・管理番号1008を追加 | 変更 | MOR | 44357 | 1.0.0.0 | V20210531152101__add_masterdata_for_sys_system_define.sql<br>(↑IES様にて管理番号1007追加が行われたファイルです)<br>V20210610160002__add_sys_system_define.sql | ■ |  |  |  |
| =IF(OR(C1037="",COUNTIF($C$3:C1037,C1037)<COUNTIF(C:C,C1037)),"",C1037) | 1032 | mst_treatment_set | 投与薬剤のJSON構造変更 | 変更 | 孔帅 | 44363 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1038="",COUNTIF($C$3:C1038,C1038)<COUNTIF(C:C,C1038)),"",C1038) | 1033 | mst_monitor_graph | マスタデータの区分 | 変更 | 王辉 | 44370 | 1.0.0.0 | V20210623180002__add_columns_for_mst_monitor_graph.sql | ■ |  |  |  |
| =IF(OR(C1039="",COUNTIF($C$3:C1039,C1039)<COUNTIF(C:C,C1039)),"",C1039) | 1034 | mst_user | （login_method）登録方式を追加 | 変更 | 宋庆洋 | 44372 | 1.0.0.0 | V20210625114001__add_columns_for_mst_user.sql | ■ |  |  |  |
| =IF(OR(C1040="",COUNTIF($C$3:C1040,C1040)<COUNTIF(C:C,C1040)),"",C1040) | 1035 | mst_monitor_graph | グラフの上下限が不適切。 | 変更 | 王辉 | 44372 | 1.0.0.0 | V20210625117001__add_columns_for_mst_monitor_graph.sql | ■ |  |  |  |
| =IF(OR(C1041="",COUNTIF($C$3:C1041,C1041)<COUNTIF(C:C,C1041)),"",C1041) | 1036 | sys_facility_setting | sys_facility_settingのデータを追加:<br>・3020 | 変更 | 杜建利 | 44382 | 1.0.0.0 | V20210705115000__add_sys_facility_setting.sql | ■ |  |  |  |
| =IF(OR(C1042="",COUNTIF($C$3:C1042,C1042)<COUNTIF(C:C,C1042)),"",C1042) | 1037 | ord_main | カラム追加：<br>　初版確定日時（rst_edition_date）<br>　最新版確定日時（cur_edition_date） | 変更 | 呉 | 44370 | 1.0.0.0 | V20210623104701__add_columns_for_ord_main.sql | ■ |  |  |  |
| =IF(OR(C1043="",COUNTIF($C$3:C1043,C1043)<COUNTIF(C:C,C1043)),"",C1043) | 1038 | ord_main_restore | カラム追加：<br>　初版確定日時（rst_edition_date）<br>　最新版確定日時（cur_edition_date） | 変更 | 呉 | 44370 | 1.0.0.0 | V20210623105501__add_columns_for_ord_main_restore.sql | ■ |  |  |  |
| sys_data_set | 1039 | sys_data_set | MongoDB設定説明の追加 | 変更 | 孫少凱 | 44413 | 1.0.0.0 | 無し | ■ |  |  |  |
| mst_medicine_support | 1040 | mst_medicine_support | 投薬支援マスタの目標検査値に小数点以下の入力ができない | 変更 | 王辉 | 44452 | 1.0.0.0 | V20210913141001__alter_mst_medicine_support.sql | ■ |  |  |  |
| =IF(OR(C1046="",COUNTIF($C$3:C1046,C1046)<COUNTIF(C:C,C1046)),"",C1046) | 1041 | mst_trend_graph_template | （com_format_cd）通信フォーマットを追加 | 変更 | 宋庆洋 | 44454 | 1.0.0.0 | V20210915170001__add_columns_for_mst_trend_graph_template.sql | ■ |  |  |  |
| mst_trend_graph_monitor_set | 1042 | mst_trend_graph_monitor_set | （com_format_cd）通信フォーマットを追加 | 変更 | 宋庆洋 | 44454 | 1.0.0.0 | V20210915170002__add_columns_for_mst_trend_graph_monitor_set.sql | ■ |  |  |  |
| @mst_pat_viewer_layout | 1043 | @mst_pat_viewer_layout | 患者イベント、観察記録の設定項目不正 | 変更 | 王辉 | 44480 | 1.0.0.0 | 無し | =IFERROR(IF(C1048=VLOOKUP(C1048,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C1048&"!A1","■"),""),"") |  |  |  |
| sys_notification | 1044 | sys_notification | @sys_notificationシート<br>　・通知定義番号38を追加 | 変更 | MOR | 44544 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1050="",COUNTIF($C$3:C1050,C1050)<COUNTIF(C:C,C1050)),"",C1050) | 1045 | sys_system_define | @sys_system_defineシート<br>　・管理番号37を追加 | 変更 | MOR | 44575 | 1.0.0.0 | V20220114090001__add_sys_system_define.sql | ■ |  |  |  |
| =IF(OR(C1051="",COUNTIF($C$3:C1051,C1051)<COUNTIF(C:C,C1051)),"",C1051) | 1046 | sys_system_define | @sys_system_defineシート<br>　・管理番号4の値(初期値)を変更 | 変更 | MOR | 44624 | 1.0.0.0 | V20220304112502__update_sys_system_define.sql | ■ |  |  |  |
| sys_system_define | 1047 | sys_system_define | @sys_system_defineシート<br>　・管理番号1009～1011の記載を追加 | 変更 | MOR | 44726 | 1.0.0.0 | V20220614112001__add_sys_system_define.sql<br>※ MORが追加したのは管理番号1011のみとなります。<br>※ 管理番号1009、1010 は記載がなかった為、<br>　 合わせて追加いたしました。 | ■ |  |  |  |
| =IF(OR(C1053="",COUNTIF($C$3:C1053,C1053)<COUNTIF(C:C,C1053)),"",C1053) | 1048 | mst_user | カラム削除：<br>　登録方式（login_method） | 変更 | MOR | 44733 | 1.0.0.0 | V20220621132001__delete_columns_for_mst_user.sql | ■ |  |  |  |
| =IF(OR(C1054="",COUNTIF($C$3:C1054,C1054)<COUNTIF(C:C,C1054)),"",C1054) | 1049 | mst_addition | 加算の算定回数「期限」の追加に伴い、下記カラムの備考を修正。<br>・addition_span (算定間隔)<br>・addition_limit (算定回数上限) | 変更 | MOR | 44740 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1055="",COUNTIF($C$3:C1055,C1055)<COUNTIF(C:C,C1055)),"",C1055) | 1050 | mst_addition | 加算の「慢性維持透析患者外来医学管理料」の対応に伴い、下記カラムの備考を修正。<br>・addition_class (種別区分)<br>・addition_kind (登録区分) | 変更 | MOR | 44781 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1056="",COUNTIF($C$3:C1056,C1056)<COUNTIF(C:C,C1056)),"",C1056) | 1051 | mnt_recalc_que | 日次処理の時間経過による処理の中断の対応に伴い下記のカラムの追加と備考の修正。<br>追加カラム<br>・calc_pat_id（再計算済患者ID）<br>修正<br>ステータスに4:処理中断を追加 | 変更 | 小西 | 44901 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1057="",COUNTIF($C$3:C1057,C1057)<COUNTIF(C:C,C1057)),"",C1057) | 1052 | mst_treatment_set | カラムind_equip_infoのjson項目にequip_typeを追加 | 変更 | NKK青山 | 44965 | 1.0.0.0 |  | ■ |  |  |  |
| mst_equipment_set | 1053 | mst_equipment_set | カラムset_infoのjson項目にequip_typeを追加 | 変更 | NKK青山 | 44965 | 1.0.0.0 |  | ■ |  |  |  |
| =IF(OR(C1059="",COUNTIF($C$3:C1059,C1059)<COUNTIF(C:C,C1059)),"",C1059) | 1054 | pat_unique | medical_hst_info->>out_come | 変更 | IES 徐 | 45062 | 1.0.0.0 |  | ■ |  |  |  |
|  | 1055 | mst_treatment_set | 治療方法セットマスターの装置設定部分からbpの血圧関連を削除する | 変更 | IES 劉祥霖 | 45065 | 1.0.0.0 | @mst_treatment_setシート |  |  |  |  |
| =IF(OR(C1061="",COUNTIF($C$3:C1061,C1061)<COUNTIF(C:C,C1061)),"",C1061) | 1056 | pat_main | pat_main.infect_info->>infect修正 | 変更 | IES 徐 | 45069 | 1.0.0.0 | 感染症情報.結果コード | ■ |  |  |  |
| ind_device_set_info | 1057 | ind_device_set_info | @ind_device_set_info<br>各要素の型を追記 | 変更 | IES 関 | 45071 | 1.0.0.0 |  |  |  |  |  |
|  | 1058 | ord_main | ・ord_mainのrst_vital_infoに、ctl_noとinput_classを追加する<br>・ord_mainのrst_complaint_info、rst_treatment_info、rst_treat_staff_info、addition_infoに、型を追加する | 変更 | IES 関 | 45071 | 1.0.0.0 |  | ■ |  |  |  |
|  | 1059 | pat_main | pat_mainのpat_memo_info、charge_staff_info、taboo_allergy_info、infect_info、medical_care_infoに、型を追加する | 変更 | IES 関 | 45071 | 1.0.0.0 |  | ■ |  |  |  |
|  | 1060 | pat_unique | pat_unique.physical_info->>facility_cd, inspect_date追加 | 変更 | IES 徐 | 45085 | 1.0.0.0 |  | ■ |  |  |  |
|  | 1061 | pat_main | taboo_allergy_infoに、disp_orderの型は、String⇒Numberに修正 | 変更 | IES 関 | 45100 | 1.0.0.0 |  | ■ |  |  |  |
|  | 1062 | mst_add_monitor | fn_vital_monitor_item_cdカラム追加 | 変更 | IES 劉祥霖 | 45111 | 1.0.0.0 | コンバータのユニークキー不足のため | ■ |  |  |  |
|  | 1063 | mst_pat_event_data_template | fn_template_cdカラム追加 | 変更 | IES 劉祥霖 | 45111 | 1.0.0.0 | コンバータのユニークキー不足のため | ■ |  |  |  |
|  | 1064 | mst_monitor_graph | fn_monitor_graph_cdカラム追加 | 変更 | IES 劉祥霖 | 45111 | 1.0.0.0 | コンバータのユニークキー不足のため | ■ |  |  |  |
|  | 1065 | ord_main | カラムrst_treatment_infoに以下の情報を追加<br>    "medicine_type": (Number)薬剤区分(*7),<br>    "electrocardiogram_start": (String)心電図開始日時,<br>    "over_time": (Number)経過時間,※単位分 | 変更 | IES 朴 | 45201 | 1.0.0.0 | 処置薬剤について通常薬剤か調製薬剤かを判別する方法の調査結果を反映 | ■ |  |  |  |
|  | 1066 | mst_comsv_setting | next_pat_splitareaカラムを追加 | 変更 | TDC | 45229 | 1.0.0.0 |  | ■ |  |  |  |
|  | 1067 | pat_group | in_hospital_cd_1カラム追加 | 変更 | NKK笠原 | 45237 | 1.0.0.0 |  | ■ |  |  |  |
|  | 1068 | mnt_recalc_que | 日次処理の時間経過による処理の中断の対応に伴い下記のカラムの回復（取消線を消す）<br>回復カラム<br>・calc_pat_id（再計算済患者ID） | 変更 | IES 崔 | 45243 | 1.0.0.0 |  | ■ |  |  |  |
|  | 1069 | mst_exam_set | is_in_hospital定義変更＝＞<br>0:院外<br>1:院内 | 変更 | IES劉祥霖 | 45252 | 1.0.0.0 | redmine＃10028により変更 | ■ |  |  |  |
|  | 1070 | mst_machine_type | model(機種)に以下の情報を追加<br>006：溶解装置（A粉対応）<br>007：溶解装置（B粉対応） | 変更 | NKK笠原 | 45254 | 1.0.0.0 |  | ■ |  |  |  |
|  | 1071 | ord_material_save | カラムが以下の情報を追加<br>薬剤識別番号<br>手技コード<br>投与タイミングコード | 変更 | IES 李 | 45265 | 1.0.0.0 |  | ■ |  |  |  |
| mnt_water_survey | 1072 | mnt_water_survey | 水質データに、下記情報を追加<br>・memo(メモ) | 変更 | IES 関 | 45267 | 1.0.0.0 | 設計書記載漏れ対応 | ■ |  |  |  |
|  | 1073 | pat_main | 重複なカラムを削除<br>・旧更新日時<br>旧更新日時の物理名を修正<br>・up_date⇒old_up_date | 変更 | IES 関 | 45272 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
|  | 1074 | mnt_motion_record | contents(内容)に以下情報を追加<br>999：自己診断情報 | 変更 | IES張兆江 | 45274 | 1.0.0.0 | 設計書記載漏れ対応 | ■ |  |  |  |
|  | 1075 | mnt_weight_state | 「使用しない」という説明を削除 | 変更 | IES 関 | 45288 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
|  | 1076 | mst_spitz | 院内院外フラグの備考を下記のように修正<br>'0'：院外（デフォルト）、'1'：院内 | 変更 | IES 関 | 45288 | 1.0.0.0 | redmine＃10027により変更 | ■ |  |  |  |
|  | 1077 | mst_self_measure_result | @mst_self_measure_resultに、<br>judgeの型をboolean⇒Stringに修正 | 変更 | IES 関 | 45288 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
|  | 1078 | mst_addition | 種別区分の備考を修正 | 変更 | IES 関 | 45293 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
|  | 1079 | mnt_mainte_main | 点検カテゴリコード版数の取り消し線を削除 | 変更 | IES 関 | 45300 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
| mst_pat_event_sub_category | 1080 | mst_pat_event_sub_category | 以下のカラムを追加<br>・fn_event_category_class(FNW用サブカテゴリ区分)<br>・サブカテゴリ名称(sub_category_name)の長さを20⇒40に変更 | 変更 | IES 李 | 45314 | 1.0.0.0 | redmine＃10205により変更 | ■ |  |  |  |
|  | 1081 | ord_main | 以下のカラムを削除<br>・re_loop_rate_main<br>・reloop_info | 変更 | IES 李 | 45316 | 1.0.0.0 | redmine＃10196により変更 | ■ |  |  |  |
|  | 1082 | ord_main | @ind_device_set_infoに<br>・「"ord_no": 検査日オーダ番号」を削除する。<br>・下記のカラムを追加<br>"ind_user_id ": (Number)指示者コード(利用者マスタ.利用者ID),<br>"ind_user_last_name": (String)指示者名_姓(利用者マスタ.利用者名_姓),<br>"ind_user_first_name": (String)指示者名_名(利用者マスタ.利用者名_名),<br>"upd_user_id": (Number)更新者コード(利用者マスタ.利用者ID),<br>"upd_user_last_name": (String)更新者名_姓(利用者マスタ.利用者名_姓),<br>"upd_user_first_name": (String)更新者名_名(利用者マスタ.利用者名_名) | 変更 | IES 李 | 45322 | 1.0.0.0 | redmine＃10196により変更 | ■ |  |  |  |
|  | 1083 | mst_bed | 以下のカラムを削除<br>・ベッド番号(bed_no) | 変更 | IES 関 | 45324 | 1.0.0.0 | redmine＃10280により変更 | ■ |  |  |  |
|  | 1084 | ord_main | 以下のカラム項目を削除<br>・rst_device_set_info<br>・rst_vital_info<br>下記のカラムを追加<br>・ind_device_mode<br>・ind_dw_user_info | 変更 | IES 李 | 45326 | 1.0.0.0 | redmine＃10196により変更 | ■ |  |  |  |
| ord_main_restore | 1085 | ord_main_restore | 以下のカラム項目を削除<br>・re_loop_rate_main<br>・reloop_info<br>・rst_device_set_info<br>・rst_vital_info<br>下記のカラムを追加<br>・ind_device_mode<br>・ind_dw_user_info | 変更 | IES 李 | 45326 | 1.0.0.0 | redmine＃10196により変更 | ■ |  |  |  |
| ord_material_save | 1086 | ord_material_save | 下記のカラムを追加<br>・receipe_conversion | 変更 | IES 李 | 45326 | 1.0.0.0 | redmine＃10196により変更 | ■ |  |  |  |
| =IF(OR(C1092="",COUNTIF($C$3:C1092,C1092)<COUNTIF(C:C,C1092)),"",C1092) | 1087 | mst_machine | 下記のカラムを追加<br>・fn_class_cd | 変更 | IES 関 | 45326 | 1.0.0.0 | redmine＃10205により変更 | ■ |  |  |  |
|  | 1088 | mst_addition | @addition_tar_cdシートに、<br>設定内容を修正 | 変更 | IES 関 | 45328 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
|  | 1089 | mst_holiday | テーブルの論理名をモニタ項目⇒休日マスタに修正 | 変更 | IES 関 | 45328 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
|  | 1090 | pat_unique | 既往歴情報の備考欄に、<br>告知の注釈を下記のように修正<br>0:告知済、1:未告知　⇒　1:告知済、0:未告知 | 変更 | IES 関 | 45328 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
|  | 1091 | mst_exam_item | 下記項目の桁の値(8,2)を削除する<br>・正常値(上限)<br>・正常値(下限)<br>・正常値(男性上限)<br>・正常値(男性下限)<br>・正常値(女性上限)<br>・正常値(女性下限)<br>・入力上限値<br>・入力下限値<br>・グラフ上限値<br>・グラフ下限値 | 変更 | IES 関 | 45349 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
|  | 1092 | mst_pat_event_category | カテゴリ名称(category_name)の長さを20⇒40に変更 | 変更 | IES劉 | 45349 | 1.0.0.0 | redmine＃10205により変更 | ■ |  |  |  |
|  | 1093 | mst_pat_event_data_template | テンプレート名称(template_name)の長さを20⇒40に変更 | 変更 | IES劉 | 45349 | 1.0.0.0 | redmine＃10205により変更 | ■ |  |  |  |
|  | 1094 | pat_event | サブカテゴリ名称(sub_category_name)の長さを20⇒40に変更<br>カテゴリ名称(category_name)の長さを20⇒40に変更<br>テンプレート名称(template_name)の長さを20⇒40に変更 | 変更 | IES劉 | 45349 | 1.0.0.0 | redmine＃10205により変更 | ■ |  |  |  |
|  | 1095 | mst_machine_record_control | disp_flgの凡例を追記 | 変更 | IES劉 | 45350 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
|  | 1096 | mst_trend_graph_template | 下記カラムの記載を追加する<br>・FNW+で管理する施設内の一意なコード | 変更 | IES 関 | 45350 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
|  | 1097 | mst_water_survey_point | 連携コードの追加<br>・連携コード1<br>・連携コード2 | 変更 | NKK 正 | 45352 | 1.0.0.0 | redmine＃10347により変更 | ■ |  |  |  |
|  | 1098 | mst_wheel_chair | 連携コードの追加<br>・連携コード1<br>・連携コード2 | 変更 | NKK 正 | 45357 | 1.0.0.0 | redmine＃10346により変更 | ■ |  |  |  |
|  | 1099 | mst_exam_item | default値の追加<br>・データ形式 ⇒'1'：数値 を設定<br>default値の変更<br>・仮想端末表示対象区分 '1'：対象⇒'0'：対象外に変更 | 変更 | NKK 正 | 45359 | 1.0.0.0 | redmine＃10265により変更 | ■ |  |  |  |
|  | 1100 | sys_facility_setting | sys_facility_settingのデータを追加:<br>・1068 | 追加 | TDC米沢 | 45366 | 1.0.0.0 | redmine #10290により追加 | ■ |  |  |  |
|  | 1101 | mst_complaint | 連携コードの追加<br>・連携コード1<br>・連携コード2 | 変更 | NKK 正 | 45377 | 1.0.0.0 | redmine＃10428により変更 | ■ |  |  |  |
|  | 1102 | sys_daily_no | base_date追加<br>current_no：jsonb → integer変更<br>一意のキー制約：base_date追加 | 変更 | IES 徐 | 45379 | 1.0.0.0 | redmine＃10311により変更 | ■ |  |  |  |
|  | 1103 | mst_machine | 連携コードの追加<br>・連携コード1<br>・連携コード2 | 変更 | NKK 正 | 45392 | 1.0.0.0 | redmine＃10502により変更 | ■ |  |  |  |
|  | 1104 | pat_event | シート「@pat_event」<br>日付フォーマットを追記 | 変更 | IES劉 | 45421 | 1.0.0.0 | redmine#10228により変更 | ■ |  |  |  |
|  | 1105 | mst_facility | 下記カラムを追加<br>・スケジュール延長除外フラグ | 変更 | IES 関 | 45436 | 1.0.0.0 | redmine#10378-㉔により変更 | ■ |  |  |  |
|  | 1106 | mst_facility | 下記カラムを削除<br>・システム利用設定 | 変更 | IES 関 | 45436 | 1.0.0.0 | redmine#10438により変更 | ■ |  |  |  |
|  | 1107 | pat_insurance | 下記カラムの備考に補足説明を追記<br>・保険情報、公費情報、セット情報、自費情報<br>@insu_pub_infoに、下記項目を追記<br>・障碍者手帳番号 | 変更 | IES 関 | 45436 | 1.0.0.0 | redmine#10525により変更<br>設計書記載漏れ追記 | ■ |  |  |  |
|  | 1108 | pat_insurance | @insu_pub_info、@＠insu_infoに、下記項目の型（Number⇒String）を変更<br>・保険者番号、負担率、負担者番号、受給者番号 | 変更 | IES 関 | 45436 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
|  | 1109 | mst_user | @mst_userにuser_settings ->> default_settingの詳細を追記 | 変更 | HSP 西海 | 45449 | 1.0.0.0 | redmine#10004により変更 | ■ |  |  |  |
|  | 1110 | ord_main | カラム追加：<br>　実績装置モード（rst_device_mode） | 新規 | IES劉 | 45461 | 1.0.0.0 | カラム追加により変更 | ■ |  |  |  |
|  | 1111 | ord_main | カラムind_device_mode桁数を修正<br>　5,2=>2,0 | 変更 | IES劉 | 45461 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
| =IF(OR(C1117="",COUNTIF($C$3:C1117,C1117)<COUNTIF(C:C,C1117)),"",C1117) | 1112 | pat_treatment_pattern | ind_sch_infoに、下記項目を追記<br>・指示者名_姓<br>・指示者名_名<br>・更新者名_姓<br>・更新者名_名 | 変更 | IES張 | 45484 | 1.0.0.0 | redmine#10860により変更 | ■ |  |  |  |
|  | 1112 | ord_main | ind_schedule_user_infoに、下記項目を追記<br> ・ "ind_kur_cd_before": (Number)変更前クール(クールマスタ.クールコード、デフォルトが0)<br>  ・"ind_treat_start_time_before": (String)変更前治療開始予定時刻（HHMM形式、デフォルトがnull) | 変更 | IES劉 | 45497 | 1.0.0.0 | redmine#10860により変更 | ■ |  |  |  |
|  | 1113 | pat_treatment_pattern | ind_sch_infoに、下記項目を追記<br> ・ "ind_kur_cd_before": (Number)変更前クール(クールマスタ.クールコード、デフォルトが0)<br>  ・"ind_treat_start_time_before": (String)変更前治療開始予定時刻（HHMM形式、デフォルトがnull) | 変更 | IES劉 | 45497 | 1.0.0.0 | redmine#10860により変更 | ■ |  |  |  |
|  | 1114 | pat_treatment_pattern | ind_sch_infoに、下記項目の型を追記<br>・ind_bed_cdの型をnumberと追記 | 変更 | IES劉 | 45497 | 1.0.0.0 | redmine#10860により変更 | ■ |  |  |  |
|  | 1115 | pat_unique | 身体情報(physical_info)に、下記項目の型Number⇒Stringへ修正<br>・身長、検査時の体重、心横径、胸郭横径、CTR、DW、指示者、前体重許容割合<br>下記項目の桁を追記<br>・施設コード、検査日<br>下記項目を追加<br>・更新者<br>下記削除項目を復旧<br>・目標体重 | 変更 | IES 関 | 45497 | 1.0.0.0 | redmine#10860により変更 | ■ |  |  |  |
|  | 1116 | mnt_mainte_main | 下記カラムを削除<br>・結果入力パターン2<br>・定期交換部品記録コメント<br>下記カラムの備考に凡例を追記<br>・結果入力パターン1<br>mainte_comment_1の論理名修正<br>・定期検査記録コメント => 定期点検者コメント<br>'@mnt_mainte_mainシート<br>・judgeの定期交換部品記録簿の備考を変更 | 変更 | HSP 藤井 | 45504 | 1.0.0.0 | redmine#10819により変更 | ■ |  |  |  |
|  | 1117 | pat_main | 装置設定情報(device_set_info)に、下記項目の型Number⇒Stringへ修正<br>・検査日時(ヘマトクリット(Ht))  (ope:{"dev":{C:{"":)<br>・検査日時(総タンパク(TP))       (ope:{"dev":{C:{"":) | 変更 | IES 李 | 45506 | 1.0.0.0 | redmine#10735により変更 | ■ |  |  |  |
|  | 1118 | pat_main | 共通診療情報(medical_care_info)に、下記項目を追記<br>・自施設透析回数(pat_dialysis_count) | 変更 | IES 李 | 45506 | 1.0.0.0 | redmine#10735により変更 | ■ |  |  |  |
|  | 1119 | pat_personal_main | 透析困難情報(dial_diff_com_info)に、下記項目を削除<br>・管理番号(ctl_no) | 変更 | IES 李 | 45506 | 1.0.0.0 | redmine#10735により変更 | ■ |  |  |  |
|  | 1120 | pat_unique | 入外・転入出情報(in_out_visit_history_info)に、下記項目を追記<br>・(to_medicalInstitutionCd)<br>・(from_medicalInstitutionCd) | 変更 | IES 李 | 45506 | 1.0.0.0 | redmine#10735により変更 | ■ |  |  |  |
|  | 1121 | ord_main | ind_schedule_user_infoに、下記項目の説明文言を変更<br> ・ "ind_kur_cd_before": (Number)変更前クール(クールマスタ.クールコード、変更前がない状態：null、未登録：0)<br>  ・"ind_treat_start_time_before": (String)変更前治療開始予定時刻（HHMM形式、変更前がない状態：null、未登録：null) | 変更 | IES劉 | 45510 | 1.0.0.0 | redmine#10860により変更 | ■ |  |  |  |
|  | 1122 | pat_treatment_pattern | ind_sch_infoに、下記項目の説明文言を追記<br> ・ "ind_kur_cd_before": (Number)変更前クール(クールマスタ.クールコード、変更前がない状態：null、未登録：0)<br>  ・"ind_treat_start_time_before": (String)変更前治療開始予定時刻（HHMM形式、変更前がない状態：null、未登録：null) | 変更 | IES劉 | 45510 | 1.0.0.0 | redmine#10860により変更 | ■ |  |  |  |
|  | 1123 | ord_main | 医療材料情報(ind_equip_info)に、下記項目を削除<br>・穿刺針区分(needle_type) | 変更 | IES 関 | 45512 | 1.0.0.0 | redmine#10674により変更 | ■ |  |  |  |
|  | 1124 | ord_personal_prescription | ord_personal_prescriptionにカラムを追加<br>・名前<br>・略称<br>・保険情報<br>・公費情報<br>・セット情報<br>・自費情報<br>・保険メモ1<br>・保険メモ2<br>＠insu_info、@insu_pub_info、@insu_set_info、@insu_self_infoシート | 変更 | HSP 板本 | 45520 | 1.0.0.0 | redmine#10658により変更 | ■ |  |  |  |
|  | 1125 | ord_personal_prescription | 処方情報の備考列に「暗号化対象」という文言の追記<br>・公費負担者番号<br>・公費負担医療の受給者番号<br>・保険者番号<br>・被保険者証・被保険者手帳記号<br>・被保険者証・被保険者手帳番号 | 変更 | HSP 板本 | 45530 | 1.0.0.0 | redmine#10658により変更 | ■ |  |  |  |
|  | 1126 | ord_main | 実績：愁訴処置情報(rst_treatment_info)に、下記項目を削除<br>・"medicine_cd": (Number)薬剤コード<br>・"medicine_name": (String)薬剤名 | 変更 | IES 劉 | 45532 | 1.0.0.0 | redmine#11046により変更<br>使わないキーを削除 | ■ |  |  |  |
|  | 1127 | mst_rad_set | @mst_rad_setシートに、<br>item_classを追記、論理名追記 | 変更 | IES 関 | 45545 | 1.0.0.0 | 設計書記載不足追記 | ■ |  |  |  |
|  | 1128 | sys_facility_setting | sys_facility_settingの操作権限可否に「2：user_typeの設定内容に関わらず、非表示」を追記 | 変更 | NKK 本田 | 45552 | 1.0.0.0 | redmine #10984により変更 | ■ |  |  |  |
|  | 1129 | mst_report | 「@mst_report」シートにreport_setting のJSON構造を追加 | 変更 | NKK 本田 | 45552 | 1.0.0.0 | redmine #10984により変更 | ■ |  |  |  |
|  | 1130 | mst_treatment_status_disp_item | カラム追加<br>unit（単位） | 変更 | NKK 正 | 45572 | 1.0.0.0 | redmine #11126により変更 | ■ |  |  |  |
|  | 1131 | mst_mainte_layout_group | カラム削除<br>layout_default | 変更 | NKK 正 | 45611 | 1.0.0.0 | redmine #11224により変更 | ■ |  |  |  |
|  | 1132 | mst_mainte_layout_group_hst | カラム削除<br>layout_default | 変更 | NKK 正 | 45611 | 1.0.0.0 | redmine #11224により変更 | ■ |  |  |  |
|  | 1133 | mst_self_measure_result | ・シート「@self_measure_result」に、下記項目の型を変更<br>key：Number＝＞String<br>failure_low：Number＝＞String<br>caution_low：Number＝＞String<br>caution_up：Number＝＞String<br>failure_up：Number＝＞String<br>・下記項目の備考に参照シートを追加<br>対象機種情報（machine_info）<br>自己診断情報（self_measure_result） | 変更 | IES劉 | 45629 | 1.0.0.0 | 設計書記載ミス修正 | ■ |  |  |  |
|  | 1134 | sys_facility_setting | sys_facility_settingのデータを追加:<br>・1069 | 追加 | NKK 正 | 45645 | 1.0.0.0 | redmine #11337により追加 | ■ |  |  |  |
|  | 1135 | sys_application | シート追加：<br>・sys_application | 追加 | NKK 本田 | 45730 | 1.0.0.0 | redmine #11618により追加 | ■ |  |  |  |
|  | 1136 | mst_menu_group | テーブル追加<br>・mst_menu_group | 追加 | NKK 正 | 45737 | 1.0.0.0 | redmine #11247により追加 | ■ |  |  |  |
|  | 1137 | sys_facility_setting | sys_facility_settingのデータを追加:<br>・1071, 1072 | 追加 | NKK 正 | 45770 | 1.0.0.0 | redmine #11747により追加 | ■ |  |  |  |
|  | 1138 | mst_pat_list_layout | 職種の備考に、補足説明を追記 | 変更 | NKK 本田 | 45803 | 1.0.0.0 | redmine #11747により追加 | ■ |  |  |  |
|  | 1139 | mst_treatment | report_graph_settingのjson keyを追加<br>　　∟追加するJSONキー：show_check（boolean）<br>　　　true：表示、false：非表示<br>　　　※血圧情報のみ | 追加 | IES鄭 | 45848 | 1.0.0.0 | redmine #11847により追加 | ■ |  |  |  |
|  | 1140 | mst_report | カラム削除<br>multi_total_defaul | 変更 | IES孫 | 45891 | 1.0.0.0 | redmine #10983により変更 | ■ |  |  |  |
|  | 1141 | mst_device_set_info_default | device_set_infoのjson keyを追加<br>　　∟追加するJSONキー："476":(Number)	ΔSO2低下報知点 | 追加 | TDC 高村 | 45898 | 1.0.0.0 | redmine #11124により追加 | ■ |  |  |  |
|  | 1142 | pat_main | device_set_infoのjson keyを追加<br>　　∟追加するJSONキー："476":(Number)	ΔSO2低下報知点 | 追加 | TDC 高村 | 45898 | 1.0.0.0 | redmine #11124により追加 | ■ |  |  |  |
|  | 1143 | mst_checklist | @mst_checklist<br>説明：分類コード(class_cd)に「未分類：-1」の記載を追加 | 追加 | TDC米沢 | 45924 | 1.0.0.0 | redmine #11589により追加 | ■ |  |  |  |
| mst_mainte_layout | 1144 | mst_mainte_layout | カラムtype_infoの備考に日常点検では不使用のためNULLという説明を追加 | 変更 | NKK 古谷 | 45951 | 1.0.0.0 | redmine #9451により追加 | ■ |  |  |  |
| mst_mainte_category | 1145 | mst_mainte_category | カラムdetailの日常点検でのJSON構造を変更 | 変更 | NKK 古谷 | 45951 | 1.0.0.0 | redmine #9451により追加 | ■ |  |  |  |
|  | 1146 | mst_exam_set | カラム追加<br>　検査区分（order_class） | 変更 | NKK 本田 | 45954 | 1.0.0.0 | redmine #12091により追加 | ■ |  |  |  |
|  | 1147 | mst_job | カラム追加<br>　デフォルト表示設定（default_disp_settings）<br>　加えて@mst_jobシートに「デフォルト表示設定」の説明追記 | 変更 | NKK 都丸 | 45967 | 1.0.0.0 | redmine #12336により追加 | ■ |  |  |  |
|  | 1148 | mst_user | @'mst_userにて■user_settings ->> default_settingの詳細の箇所を追記・整備 | 変更 | NKK 都丸 | 45967 | 1.0.0.0 | redmine #12336により追加 | ■ |  |  |  |
|  | 1149 | mst_user | @'mst_userにて■user_settings ->> default_settingの詳細の箇所<br>　名称「検査結果」に対して、<br>　　・項目キー名：「viewDayType」<br>　　・項目名称：「表示条件」<br>　　・説明：「1:最新結果日、2:最新結果日」<br>を追加 | 変更 | NKK 本田 | 45968 | 1.0.0.0 | redmine #11198により追加 | ■ |  |  |  |
|  | 1150 | mst_user | @'mst_user ■user_settings ->> default_settingの詳細<br>　スケジュール表にisCheckedPlanMainteWaterを追加 | 変更 | NKK 正 | 45973 | 1.0.0.0 | redmine #12368により追加 | ■ |  |  |  |
| mnt_mainte_main | 1151 | mnt_mainte_main | @mnt_mainte_main にて<br>■detail ->> cate_no と ■detail ->> detail_no を削除 | 変更 | NKK 古谷 | 45973 | 1.0.0.0 | redmine #9451により追加 | ■ |  |  |  |
|  | 1152 | mst_job | カラム追加<br>　デフォルト通知設定（default_notification_settings）<br>　加えて@mst_jobシートに「デフォルト通知設定」の説明追記 | 変更 | NKK 都丸 | 45973 | 1.0.0.0 | redmine #12335により追加 | ■ |  |  |  |
|  | 1153 | mst_round_type | カラム追加<br>　強調表示（highlighting） | 変更 | NKK 都丸 | 46013 | 1.0.0.0 | redmine #12431により追加 | ■ |  |  |  |
|  | 1154 | sys_facility_setting | @sys_facility_settingの以下の定義を追加<br>定義(3139)：体重計モード測定記録ボタン表示切替 | 追加 | NKK 佐藤明 | 46041 | 1.0.0.0 | redmine #12398により追加 | ■ |  |  |  |
|  | 1155 | @ord_prescription | JSON構造に以下のキーを追加<br>　・患者希望（pat_req） | 変更 | NKK 本田 | 46055 | 1.0.0.0 | redmine #11063により追加 | =IFERROR(IF(C1161=VLOOKUP(C1161,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C1161&"!A1","■"),""),"") |  |  |  |
|  | 1156 | ord_personal_prescription | カラム追加<br>　・リフィル可（is_refill）<br>　・リフィル回数（refill_num） | 変更 | NKK 本田 | 46055 | 1.0.0.0 | redmine #11063により追加 | ■ |  |  |  |
|  | 1157 | mst_pat_calendar_layout | カラム追加<br>　・表示区分（disp_class）<br>@mst_pat_calendar_layout データ構造変更<br>　・disp_item_infoのJSON構造変更 | 変更 | NKK 正 | 46073 | 1.0.0.0 | redmine #10419により追加 | ■ |  |  |  |
|  | 1158 | @mst_pat_viewer_layout | 表示項目（disp_item_info）の中項目名、小項目名を変更<br>　透析運転時間→治療時間(実績) | 変更 | NKK 前田 | 46084 | 1.0.0.0 | redmine #12517により追加 | =IFERROR(IF(C1164=VLOOKUP(C1164,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C1164&"!A1","■"),""),"") |  |  |  |
|  | 1159 | mst_prescription_set | テーブル追加<br>・mst_prescription_set | 追加 | NKK 正 | 46090 | 1.0.0.0 | redmine #11318により追加 | ■ |  |  |  |
|  | 1160 | ord_weight_scale | インデックス一覧にidx_ord_weight_scale_03を追加 | 追加 | NKK 佐藤明 | 46091 | 1.0.0.0 | redmine #12544により追加 | ■ |  |  |  |
|  | 1161 | pat_main | カラム追加<br>　・車いすコード（wheel_chair_cd） | 変更 | NKK 都丸 | 46092 | 1.0.0.0 | redmine #12426により追加 | ■ |  |  |  |
|  | 1162 | sys_facility_setting | @sys_facility_settingの以下の定義を追加<br>・3143：レセプト情報のデータ種別出力順 | 追加 | IES_孫 | 46122 | 1.0.0.0 | redmine #12576により追加 | ■ |  |  |  |
|  | 1163 | @mst_user | 指示受け・指示承認の対象指示の説明を以下の通りに変更<br>・修正前：自動ワンショット量<br>・修正後：IPワンショットスタート<br>　　　　IPワンショット量 | 変更 | NKK 本田 | 46157 | 1.0.0.0 | redmine #12478により追加 | =IFERROR(IF(C1169=VLOOKUP(C1169,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C1169&"!A1","■"),""),"") |  |  |  |
|  | 1164 | mst_medicine_mix | カラム追加<br>　・薬剤セット数（medicine_set_num）<br>　・レセ単位（unit_second） | 追加 | IES_孫 | 46162 | 1.0.0.0 | redmine #11801により追加 | ■ |  |  |  |
|  |  |  |  |  |  |  |  |  | =IFERROR(IF(C1171=VLOOKUP(C1171,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C1171&"!A1","■"),""),"") |  |  |  |
|  |  |  |  |  |  |  |  |  | =IFERROR(IF(C1172=VLOOKUP(C1172,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C1172&"!A1","■"),""),"") |  |  |  |
|  |  |  |  |  |  |  |  |  | =IFERROR(IF(C1173=VLOOKUP(C1173,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C1173&"!A1","■"),""),"") |  |  |  |
|  |  |  |  |  |  |  |  |  | =IFERROR(IF(C1174=VLOOKUP(C1174,テーブル一覧!$E$3:$E$214,1,FALSE),HYPERLINK("["&テーブル一覧!$A$2&"]"&C1174&"!A1","■"),""),"") |  |  |  |
