select 
  "原価"."物件略称",
  D."作業LVL1" || D."作業LVL2" "作業",
  D."作業内容",
  D."作業時間"
from
  "R_日報ヘッダ" H
inner join
  "R_日報明細" D
on 
  H."日報NO" = D."日報NO"
inner join
  "R_原価ヘッダ承" "原価"
on
      D."原価NO" = "原価"."原価NO"
  and "原価"."最新枝番" = "原価"."枝番"
where
      H."担当者CD" = 89
  and H."作業日" = date'2020-05-27'