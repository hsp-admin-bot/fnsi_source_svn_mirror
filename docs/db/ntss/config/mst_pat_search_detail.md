# mst_pat_search_detail

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_pat_search_detail`
- Category: config/reference

## Content

| col1 | 型 | 説明 |
| --- | --- | --- |
| { |  |  |
| hospPatId | Text |  |
| patName | Text |  |
| nameInitialList | List | [ (Number), ...]<br>0: ァ-オ\|ヴ<br>1: カ-ゴ<br>2: サ-ゾ<br>3: タ-ド<br>4: ナ-ノ<br>5: ハ-ポ<br>6: マ-モ<br>7: ャ-ヨ<br>8: ラ-ロ<br>9: ヮ-ン |
| patSex | List | [ (Number), ...]<br>0:不明, 1:男性, 2:女性 |
| ageLower | Number |  |
| ageUpper | Number |  |
| bloodTypeAboList | List | [ (Number), ...]<br>0:不明, 1:A, 2:B, 3:O, 4:AB |
| bloodTypeRhList | List | [ (Number), ...]<br>0:不明, 1:Rh+, 2:Rh- |
| bloodTypeSerovarList | List | [ (Number), ...]<br>0:不明, 11:A1, 12:Aint, 13:A2, 14:A３, 15:Ax, 16:Am, 17:Ael, 18:Aend, 21:B1, 22:Bint, 23:B2, 24:B3, 25:Bx, 26:Bm, 27:Bel, 28:Bend |
| isBloodSugerExam | Number | null:指定しない, 1:あり, 0:なし |
| isImplant | Number | null:指定しない, 1:あり, 0:なし |
| inOutClassList | List | [ (Number), ...]<br>0:外来, 1:入院, 2:死亡, 3:- |
| inOutStateList | List | [ (Number), ...]<br>0:在院, 1:導入予定, 2:転入予定, 103:転出予定, 3:転出, 7:離脱, 8:移植, 9:一時転出, 10:不明, 11:死亡 |
| dialHstLower： |  |  |
| { |  |  |
| year | Text |  |
| month | Text |  |
| } |  |  |
| dialHstUpper |  |  |
| { |  |  |
| year | Text |  |
| month | Text |  |
| } |  |  |
| staffCdDoctor | Number |  |
| staffNameDoctor | Text |  |
| staffCdCharge | Number |  |
| staffNameCharge | Text |  |
| staffCdPucture | Number |  |
| staffNamePuncture | Text |  |
| tabooCd | Number |  |
| tabooContent | Text |  |
| allergyCd | Number |  |
| allergyContent | Text |  |
| isInfect | Number | null:指定しない, 1:あり, 0:なし |
| isDiabetes | Number | null:指定しない, 1:あり, 0:なし |
| outComeList | List | [ (Number), ...]<br>1:治療中, 2:診断のみ, 3:治癒, 4:軽快< 5:寛解, 6:不変, 7:増悪, 8:中止, 9:転医, 10:死亡 |
| diseaseCd | Number |  |
| diseaseName | Text |  |
| dialysisStartDate | Text |  |
| dialysisEndDate | Text |  |
| kurCdList | List | [ cd (Number), ...] |
| bedCdList | List | [ cd (Number), ...] |
| bedGroupCdList | List | [ cd (Number), ...] |
| treatDayOfWeekList | List | [ (Number),.. ]<br>0:全, 1:月, 2:火, 3:水, 4:木, 5:金, 6:土, 7:日 |
| indCommentList |  |  |
| { |  |  |
| 0 | Text | 3:前方一致, 2:部分一致 |
| 1 | Text | コメント１ |
| 2 | Text | コメント２ |
| 3 | Text | コメント３ |
| } |  |  |
| dialysisConditionList |  |  |
| { |  |  |
| 1 | Text |  |
| 2 | Text |  |
| 3 | Text |  |
| 4 | Text |  |
| 5 | Text |  |
| } |  |  |
| selectingDialCondId |  |  |
| { |  |  |
| 1 | Number |  |
| 2 | Number |  |
| 3 | Number |  |
| 4 | Number |  |
| 5 | Number |  |
| } |  |  |
| medicationList |  |  |
| { |  |  |
| 1 | Number |  |
| 2 | Number |  |
| 3 | Number |  |
| 4 | Number |  |
| 5 | Number |  |
| } |  |  |
| medicationSelectorClass |  |  |
| { |  |  |
| 1 | Number |  |
| 2 | Number |  |
| 3 | Number |  |
| 4 | Number |  |
| 5 | Number |  |
| } |  |  |
| equipmentList |  |  |
| { |  |  |
| 1 | Number |  |
| 2 | Number |  |
| 3 | Number |  |
| 4 | Number |  |
| 5 | Number |  |
| } |  |  |
| equipmentSelectorClass |  |  |
| { |  |  |
| 1 | Number |  |
| 2 | Number |  |
| 3 | Number |  |
| 4 | Number |  |
| 5 | Number |  |
| } |  |  |
| patGroups | List | [ cd (Number), ...] |
| patGroupsMethod | Number | 1:含む, 2:一致する |
