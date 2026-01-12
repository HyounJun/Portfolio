--데이터확인
SELECT *
from 2019_dec
limit 10
      
--EDA
      
-- 일별 방문자(DAU)
-- 일별 방문자수를 구해본 결과 특정 날짜에 몰리는 이상치가 발견되지 않아 변동성이 낮았습니다. 
SELECT 
    DATE(event_time) AS event_date,
    COUNT(DISTINCT user_id) AS DAU 
FROM 2019_dec
GROUP BY event_date
ORDER BY event_date
      
--category_code별 값 확인 (공백은 Unknow처리)
SELECT category
       ,count(*) as cnt
FROM(
        SELECT *
               ,case WHEN category_code ='' then 'Unknown' else category_code end as category
        from 2019_dec
)as category_unknow
group by category
order by cnt desc

--brand 값 확인 (공백은 Unknow처리)
SELECT brand_srot
       ,cnt
       ,ROUND(cnt * 100.0 / SUM(cnt) OVER(), 2) as pct
FROM(
        SELECT case WHEN brand ='' then 'Unknown' else brand end as brand_srot
                ,count(*) as cnt
        from 2019_dec
        GROUP BY 1
)as brand_unknow
order by cnt desc

/*
brand별로 구분해본 결과 Unknown의 비중이 42.74%로 가장 높았으며, 브랜드가 있는 데이터중에서는 runail이 7.25%로 가장 높게 나타났습니다.
category별로 구분해본 결과 Unknown의 비중이 98.35%로 카테고리별 데이터가 많이 누락됐음을 알 수 있습니다.
*/ 

--funnel
-- 상품 페이지 - 장바구니 - 구매 퍼널별 전환 비율
WITH view_person as (  --상품을 본 사람
        SELECT event_time
        ,user_id
        ,user_session as view_at
        from 2019_dec
        where event_type = 'view'
),cart_person as ( -- 장바구니에 담은 사람
        SELECT event_time
        ,user_id
        ,user_session as cart_at
        from 2019_dec
        where event_type = 'cart'
),purchase_person as ( -- 구매한 사람
        SELECT event_time
        ,user_id
        ,user_session as purchase_at
        from 2019_dec
        where event_type = 'purchase'
)
SELECT count(DISTINCT vp.user_id , vp.view_at) as view_cnt
       ,count(DISTINCT cp.user_id , cp.cart_at) as cart_after
       ,count(DISTINCT pp.user_id , pp.purchase_at) as purchase_after

       ,round(count(DISTINCT cp.user_id , cp.cart_at) * 100 / count(DISTINCT vp.user_id , vp.view_at),2) as view_cart_rate --상품을 보고 장바구니에 담은 비율
       ,round(count(DISTINCT pp.user_id , pp.purchase_at) * 100 / count(DISTINCT cp.user_id , cp.cart_at),2)as cart_purchase_rate -- 장바구니에서 상품을 구매한 비율
       ,round(count(DISTINCT pp.user_id , pp.purchase_at) * 100 / count(DISTINCT vp.user_id , vp.view_at),2) as view_purchase_rate -- 상품을 보고 바로 구매한 비율
from view_person as vp
    left join cart_person as cp on vp.user_id = cp.user_id
                         AND vp.view_at = cp.cart_at
                         AND vp.event_time <= cp.event_time -- 제품을 본 세션과 장바구니에 담은세션이 같은것도 포함
    left JOIN purchase_person as pp on pp.user_id = cp.user_id
                             AND pp.purchase_at = cp.cart_at
                             AND pp.event_time >= cp.event_time -- 장바구니에 담은 세션과 구매한 세션이 같은것도 포함



--카테고리별 전환 비율
WITH base_data as(
        SELECT *
                ,case WHEN category_code = '' THEN 'Unknown' else category_code end as category
        FROM 2019_dec
), view_person as (  
        SELECT event_time
        ,user_id
        ,user_session as view_at
        ,category
        from base_data
        where event_type = 'view'
),cart_person as ( -- 장바구니에 담은 사람
        SELECT event_time
        ,user_id
        ,user_session as cart_at
        ,category
        from base_data
        where event_type = 'cart'
),purchase_person as ( -- 구매한 사람
        SELECT event_time
        ,user_id
        ,user_session as purchase_at
        ,category
        from base_data
        where event_type = 'purchase'
)
SELECT vp.category
        ,count(DISTINCT vp.user_id , vp.view_at) as view_cnt
       ,count(DISTINCT cp.user_id , cp.cart_at) as cart_after
       ,count(DISTINCT pp.user_id , pp.purchase_at) as purchase_after

       ,round(count(DISTINCT cp.user_id , cp.cart_at) * 100 / count(DISTINCT vp.user_id , vp.view_at),2) as view_cart_rate 
       ,round(count(DISTINCT pp.user_id , pp.purchase_at) * 100 / count(DISTINCT cp.user_id , cp.cart_at),2)as cart_purchase_rate -- 장바구니에서 상품을 구매한 비율
       ,round(count(DISTINCT pp.user_id , pp.purchase_at) * 100 / count(DISTINCT vp.user_id , vp.view_at),2) as view_purchase_rate -- 상품을 보고 바로 구매한 비율
from view_person as vp
    left join cart_person as cp on vp.user_id = cp.user_id
                         AND vp.view_at = cp.cart_at
                         AND vp.event_time <= cp.event_time --카테고리가 같은지 확인
                         AND vp.category = cp.category
    left JOIN purchase_person as pp on pp.user_id = cp.user_id
                             AND pp.purchase_at = cp.cart_at
                             AND pp.event_time >= cp.event_time
                             AND cp.category = pp.category --카테고리가 같은지 확인
group by category
order by view_cnt desc






















