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


-- 상품 페이지 - 장바구니 - 구매 퍼널별 전환 수
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
SELECT count(DISTINCT view_person.user_id , view_person.view_at) as view_cnt
       ,count(DISTINCT cart_person.user_id , cart_person.cart_at) as cart_after
       ,count(DISTINCT purchase_person.user_id , purchase_person.purchase_at) as purchase_after
from view_person
    left join cart_person on view_person.user_id = cart_person.user_id
                         AND view_person.view_at = cart_person.cart_at
                         AND view_person.event_time <= cart_person.event_time -- 제품을 본 세션과 장바구니에 담은세션이 같은것도 포함
    left JOIN purchase_person on purchase_person.user_id = cart_person.user_id
                             AND purchase_person.purchase_at = cart_person.cart_at
                             AND purchase_person.event_time >= cart_person.event_time -- 장바구니에 담은 세션과 구매한 세션이 같은것도 포함

