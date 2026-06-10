# tmp_log_search_condition

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@tmp_log_search_condition`
- Category: config/reference

## Content

| col1 |
| --- |
| [ |
| { |
| "idFilter": , |
| "condition": { |
| "patId": [ |
| { |
| "cd": Number, |
| "name": String, |
| "cdType": Number |
| } |
| ], |
| "userId": [ |
| { |
| "cd": Number, |
| "name": String, |
| "cdType": Number |
| } |
| ], |
| "logType": [ |
| "error", |
| "warning" |
| ], |
| "duration": Number, |
| "logClass": [ |
| "service", |
| "event" |
| ], |
| "keySearch": String, |
| "facilityCd": [ |
| String |
| ], |
| "typeSearch": number, |
| "serviceName": [ |
| { |
| "cd": Number, |
| "name": String, |
| "cdType": Number |
| } |
| ], |
| "noticeEndDate": date, |
| "noticeEndTime": time, |
| "noticeStartDate": date, |
| "noticeStartTime": time |
| }, |
| "nameFilter": String |
| }, |
