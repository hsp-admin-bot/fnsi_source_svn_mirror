# Doma SQL Mapper

DAO SQL は主に以下に配置される。

`ntss-src/ntss-core/src/main/resources/META-INF/jp/co/nikkiso/ntss/core/dao/{DaoName}/{methodName}.sql`

Java DAO 側は以下にある。

`ntss-src/ntss-core/src/main/java/jp/co/nikkiso/ntss/core/dao/{DaoName}.java`

`@Select` メソッド名と SQL ファイル名が対応する。

SQL 変更時は、以下の順で呼び出し元を追うと効率がよい。

1. SQL ファイル
2. DAO インターフェース
3. Service 実装
4. Resource または API
5. フロントまたは Windows ツール

AI が SQL 変更影響を調査する場合は、上記の順で参照し、呼び出し経路を説明すること。