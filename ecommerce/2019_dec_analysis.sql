EDA
-- Null값 확인
SELECT COUNT(*) as total
       ,SUM(CASE WHEN event_time IS NULL THEN 1 ELSE 0 END) as event_time_null
       ,SUM(CASE WHEN event_type IS NULL THEN 1 ELSE 0 END) as event_type_null
       ,SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) as product_id_null
       ,SUM(CASE WHEN category_code IS NULL OR category_code = '' THEN 1 ELSE 0 END) as category_code_null
       ,SUM(CASE WHEN brand IS NULL OR brand = '' THEN 1 ELSE 0 END) as brand_null
       ,SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) as price_null
       ,SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) as user_id_null
FROM 2019_dec

-- 전체: 3,533,286건
-- category_code NULL : 3,474,821건 → 98.4%
-- brand NULL : 1,510,289건 → 42.7% 

-- 요일별 이벤트 발생 수
SELECT DATE_FORMAT(event_time, '%W') as day_of_the_week
      ,COUNT(*) as event_at
FROM 2019_dec
GROUP BY DATE_FORMAT(event_time, '%W'), WEEKDAY(event_time)
ORDER BY WEEKDAY(event_time)

-- 시간대 별 이벤트 발생수
SELECT HOUR(event_time) as time_area
      ,COUNT(*) as event_cnt
FROM 2019_dec
GROUP BY time_area
ORDER BY time_area  

-- 브랜드 별 통계 ( Null값 제외)
SELECT brand
        ,COUNT(DISTINCT product_id) as product_cnt
        ,COUNT(DISTINCT user_id) as customer_cnt
        ,SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) as view_cnt
        ,SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) as cart_cnt
        ,SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) as purchase_cnt
        ,AVG(price) as avg_price
        ,MIN(price) as min_price
        ,MAX(price) as max_price
FROM 2019_dec
WHERE brand IS NOT NULL
 AND brand != ''
 AND price > 0
GROUP BY brand
ORDER BY purchase_cnt DESC

-- 카테고리별 통계 ( Null값 제외)
SELECT category_code as category
      ,COUNT(DISTINCT product_id) as product_cnt
      ,COUNT(DISTINCT user_id) as customer_cnt
      ,SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) as view_cnt
      ,SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) as cart_cnt
      ,SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) as purchase_cnt
      ,AVG(price) as avg_price
FROM 2019_dec
WHERE category_code IS NOT NULL 
  AND category_code != ''
GROUP BY category_code
ORDER BY purchase_cnt DESC
LIMIT 20;

-- 단계별 발생 건수
SELECT event_type 
      ,COUNT(*) as total
      ,ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM 2019_dec), 2) as rate
FROM 2019_dec
GROUP BY event_type
ORDER BY total DESC

-- 일별 이벤트 발생 수
SELECT DATE(event_time) AS day_date
       ,COUNT(*) AS total
       ,SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS view_cnt
       ,SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS cart_cnt
       ,SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_cnt
       ,SUM(CASE WHEN event_type = 'remove_from_cart' THEN 1 ELSE 0 END) AS remove_cnt
FROM 2019_dec
GROUP BY day_date
ORDER BY day_date

--일별 구매 금액
SELECT DATE(event_time) as day_date
      ,COUNT(*) as purchase_cnt
      ,SUM(price) as daily_sales
FROM 2019_dec
WHERE event_type = 'purchase'
GROUP BY day_date
ORDER BY day_date

-- 브랜드 별 총 매출
SELECT brand 
      ,COUNT(*) as purchase_cnt
      ,SUM(price) as sales
FROM 2019_dec
WHERE event_type = 'purchase' 
  AND brand IS NOT NULL 
  AND brand != ''
GROUP BY brand
ORDER BY sales DESC
LIMIT 20

-------------퍼널

-- 단계별 퍼널분석
WITH view_person as (  -- 상품을 본 사람
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
       ,round(count(DISTINCT cp.user_id , cp.cart_at) * 100 / count(DISTINCT vp.user_id , vp.view_at),2) as view_cart_rate -- 조회→장바구니 전환율
       ,round(count(DISTINCT pp.user_id , pp.purchase_at) * 100 / count(DISTINCT cp.user_id , cp.cart_at),2)as cart_purchase_rate -- 장바구니→구매 전환율
       ,round(count(DISTINCT pp.user_id , pp.purchase_at) * 100 / count(DISTINCT vp.user_id , vp.view_at),2) as view_purchase_rate -- 조회→구매 전환율
from view_person as vp
    left join cart_person as cp on vp.user_id = cp.user_id
                         AND vp.view_at = cp.cart_at
                         AND vp.event_time <= cp.event_time -- 제품을 본 세션과 장바구니에 담은세션이 같은것도 포함
    left JOIN purchase_person as pp on pp.user_id = cp.user_id
                             AND pp.purchase_at = cp.cart_at
                             AND pp.event_time >= cp.event_time -- 장바구니에 담은 세션과 구매한 세션이 같은것도 포함

-- 조회 세션의 85.07%가 장바구니 단계에서 이탈 (view→cart 14.93%)
-- 장바구니 담은 세션의 84.18%가 결제 없이 이탈 (cart→purchase 15.82%)
--  view - > cart 전환율 14.93% , cart- > purchase 전환율 15.82% , 최종 전환율 2.36%

-- 왜 이탈하는가?

가설 1 :가격이 높을수록 구매 전환율이 낮다
WITH quartiled AS (
    SELECT price, NTILE(4) OVER (ORDER BY price) AS quartile
    FROM 2019_dec
    WHERE price > 0
)
SELECT
    quartile,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM quartiled
GROUP BY quartile
ORDER BY quartile;

-- Q1: $0.05 ~ $2.06  (하위 25%)
-- Q2: $2.06 ~ $4.22  (25~50%)
-- Q3: $4.22 ~ $7.14  (50~75%)  ← 75%가 $7.14 이하
-- Q4: $7.14 ~ $327.78 (상위 25%)
-- : 사분위를 확인해보니 전체 이벤트의 75%가 $7.14 이하 저가 상품

WITH view_events AS (
    SELECT user_id
           ,user_session
           ,product_id 
           ,MIN(price) AS price
           ,MIN(event_time) AS view_time
    FROM 2019_dec
    WHERE event_type = 'view' 
      AND price > 0
    GROUP BY user_id, user_session, product_id
),
cart_events AS (
    SELECT user_id
           ,user_session
           ,product_id
           ,MIN(event_time) AS cart_time
    FROM 2019_dec
    WHERE event_type = 'cart' 
      AND price > 0
    GROUP BY user_id, user_session, product_id
),
purchase_events AS (
    SELECT user_id
          ,user_session
          ,product_id
          ,MIN(event_time) AS purchase_time
    FROM 2019_dec
    WHERE event_type = 'purchase' 
      AND price > 0
    GROUP BY user_id, user_session, product_id
)
SELECT
    CASE
        WHEN v.price < 5 THEN '0-5'
        WHEN v.price < 10 THEN '5-10'
        WHEN v.price < 20 THEN '10-20'
        WHEN v.price < 50 THEN '20-50'
        WHEN v.price < 100 THEN '50-100'
        ELSE '100+'
    END AS price_range
    ,COUNT(DISTINCT v.user_id, v.user_session, v.product_id) AS view_cnt
    ,COUNT(DISTINCT c.user_id, c.user_session, c.product_id) AS cart_cnt
    ,COUNT(DISTINCT p.user_id, p.user_session, p.product_id) AS purchase_cnt
    ,ROUND(COUNT(DISTINCT c.user_id, c.user_session, c.product_id) * 100.0 /
          NULLIF(COUNT(DISTINCT v.user_id, v.user_session, v.product_id), 0), 2) AS view_to_cart
    ,ROUND(COUNT(DISTINCT p.user_id, p.user_session, p.product_id) * 100.0 /
          NULLIF(COUNT(DISTINCT v.user_id, v.user_session, v.product_id), 0), 2) AS view_to_purchase
    ,ROUND(COUNT(DISTINCT p.user_id, p.user_session, p.product_id) * 100.0 /
          NULLIF(COUNT(DISTINCT c.user_id, c.user_session, c.product_id), 0), 2) AS cart_purchase
FROM view_events v
LEFT JOIN cart_events c
    ON v.user_id = c.user_id
    AND v.user_session = c.user_session
    AND v.product_id = c.product_id
    AND v.view_time <= c.cart_time
LEFT JOIN purchase_events p
    ON v.user_id = p.user_id
    AND v.user_session = p.user_session
    AND v.product_id = p.product_id
    AND v.view_time <= p.purchase_time
GROUP BY price_range
ORDER BY price_range
--결론 : 가격이 높을수록 구매 전환율이 낮아지는것으로 보였습니다. 최저가($0-5) 대비 최고가($100+) 구간의 view→purchase 전환율이 3.42% → 0.61%로 5.6배 낮게 나타났으며, view→cart 비율 역시 11.43% → 2.62%로 4.4배 낮아 고가품은 조회에서 구매까지 모든 단계에서 이탈이 높았습니다.

--가설 2: 시간대에 따라 구매 전환율이 다르다
WITH view_events AS (
    SELECT user_id
           ,user_session
           ,product_id
           ,HOUR(min(event_time)) AS view_hour
           ,MIN(event_time) AS view_time
    FROM 2019_dec
    WHERE event_type = 'view' 
      AND price > 0
    GROUP BY user_id, user_session, product_id
),
cart_events AS (
    SELECT user_id
           ,user_session
           ,product_id
           ,MIN(event_time) AS cart_time
    FROM 2019_dec
    WHERE event_type = 'cart' 
      AND price > 0
    GROUP BY user_id, user_session, product_id
),
purchase_events AS (
    SELECT user_id
           ,user_session
           ,product_id
           ,MIN(event_time) AS purchase_time
    FROM 2019_dec
    WHERE event_type = 'purchase' 
      AND price > 0
    GROUP BY user_id, user_session, product_id
)
SELECT view_hour AS time_section
       ,COUNT(DISTINCT v.user_id, v.user_session, v.product_id) AS view_cnt
       ,COUNT(DISTINCT c.user_id, c.user_session, c.product_id) AS cart_cnt
       ,COUNT(DISTINCT p.user_id, p.user_session, p.product_id) AS purchase_cnt
       ,ROUND(COUNT(DISTINCT c.user_id, c.user_session, c.product_id) * 100.0 /
          NULLIF(COUNT(DISTINCT v.user_id, v.user_session, v.product_id), 0), 2) AS view_to_cart
       ,ROUND(COUNT(DISTINCT p.user_id, p.user_session, p.product_id) * 100.0 /
          NULLIF(COUNT(DISTINCT v.user_id, v.user_session, v.product_id), 0), 2) AS view_to_purchase
FROM view_events v
LEFT JOIN cart_events c
    ON v.user_id = c.user_id
    AND v.user_session = c.user_session
    AND v.product_id = c.product_id
    AND v.view_time <= c.cart_time
LEFT JOIN purchase_events p
    ON v.user_id = p.user_id
    AND v.user_session = p.user_session
    AND v.product_id = p.product_id
    AND v.view_time <= p.purchase_time
GROUP BY time_section
ORDER BY time_section

-- 결과 : 시간대별 view→purchase 전환율은 최저 1.92%(0시) ~ 최고 3.25%(10시)로 1.33%p 차이가 났습니다. 오전 8~11시에 전환율이 높았고, 새벽 0~2시에 낮게 나타났습니다.
