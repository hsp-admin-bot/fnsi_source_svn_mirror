# ntss-m-notice (警報通知)
## application.yml整理
* `src/main/resources/application*.yml` は削除
* `environment` 配下に再配置

   |No|ファイル名|対象環境|
   |:--:|--|--|
   |1|application-local.yml|永和ローカル(個人)開発環境用|
   |2|application-st.yml|永和ST環境用|
   |3|application-dev.yml|AWS開発環境用|
   |4|application-stg.yml|AWS検証環境用|
   |5|application-prod.yml|AWS本番環境用|

   * No.1, 2
     既存`application-esm.yml`ベース
   * No.3, 4, 5
     AWS検証環境で現在(2019/03/01時点)使用されているものベース

## Build
* build方法
   ```bash
   # ./gradlew clean :ntss-m-notice:build -Penvironment=xxx
   ```
   * -Penvironment=xxx
     `xxx` で、使用する`application.yml`を特定する。(Default: `local`)

     |No|値(xxx)|対応するymlファイル|備考|
     |:--:|:--:|--|--|
     |1|`local`|application-local.yml|永和ローカル(個人)開発環境用|
     |2|`st`|application-st.yml|永和ST環境用|
     |3|`dev`|application-dev.yml|AWS開発環境用|
     |4|`stg`|application-stg.yml|AWS検証環境用|
     |5|`prod`|application-prod.yml|AWS本番環境用|

* 注意事項
   1. build時には、`environment`配下の、`application-xxx.yml`が
       `src/main/resources`配下にコピーされ、`application.yml`にリネームされる。
   1. 上記により、WARファイルに含まれるのは、`application.yml`１つだけとなる。
