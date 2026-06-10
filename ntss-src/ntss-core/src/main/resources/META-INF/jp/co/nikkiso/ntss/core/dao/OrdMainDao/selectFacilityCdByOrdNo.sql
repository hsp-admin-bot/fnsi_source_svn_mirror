-- #11827 2025.05.15 add 透析番号から施設コードを取得するためのSQL文を追加 TDC米沢 start
select
  facility_cd
from
  ord_main
where
  ord_no = /*ordNo*/1
-- #11827 2025.05.15 add 透析番号から施設コードを取得するためのSQL文を追加 TDC米沢 end
;
