# mnt_notification_message

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mnt_notification_message`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| additional_infoのJSON構造 |  |  |
|  | { |  |
|  | "FUNC": 遷移先機能コード, | ※必須 |
|  | "PATID": 患者ID, | ※任意 |
|  | "FACILITYCD":施設コード, | ※任意 |
|  | … |  |
|  | } |  |
|  | FUNC は遷移先画面の機能コードを指定する。 |  |
|  | それ以外の項目は、遷移先画面で必要とするパラメータを指定し、以下のように取得する。 |  |
|  | ...mapGetters("app", ["getQueryParameters"]), |  |
|  | const queryParameters = this.getQueryParameters(); |  |
|  | const condition = { |  |
|  | facilityCd: queryParameters.FACILITYCD, |  |
|  | machineTypeCd: queryParameters.MACHINETYPECD, |  |
|  | machineSerial: queryParameters.MACHINESERIAL |  |
|  | } |  |
|  | await this.getMachine(condition); |  |
|  | await this.setHeaderInfo(this.getSelectMachine()) |  |
