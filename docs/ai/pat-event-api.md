# 連携イベント検索 API

API Resource は以下である。

`ntss-src\ntss-admin-web\src\main\java\jp\co\nikkiso\ntss\admin_web\web\rest\PatEventResource.java`

Service は以下である。

`ntss-src\ntss-admin-web\src\main\java\jp\co\nikkiso\ntss\admin_web\service\patEvent\PatEventServiceImpl.java`

`strkbn=C` の場合、`strSyubetu` により作成対象検索が分岐する。

`strkbn=D` の場合、中止対象検索に分岐する。

AI が検索条件や分岐を確認する場合は、まず Resource から Service をたどり、`strkbn` と `strSyubetu` の条件分岐を明示すること。