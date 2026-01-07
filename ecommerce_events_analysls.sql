--데이터확인
SELECT *
from 2019_dec
limit 10
      
--EDA
--category_code별 값 확인 (공백은 Unknow처리)
SELECT category
       ,count(*) as cnt
FROM(
        SELECT *
               ,case WHEN category_code ='' then 'Unknow' else category_code end as category
        from 2019_dec
)as category_unknow
group by category
order by cnt desc

--category_code별 값 확인 (공백은 Unknow처리)
SELECT brand_srot
       ,count(*) as cnt
FROM(
        SELECT *
               ,case WHEN brand ='' then 'Unknow' else brand end as brand_srot
        from 2019_dec
)as brand_unknow
group by brand_srot
order by cnt desc

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



-- 요일 별 구매비율

--카테고리별 전환 비율
WITH base_data as(
        SELECT *
                ,case WHEN category_code = '' THEN 'Unknow' else category_code end as category
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






















