## Education
- 데이터리안 SQL 입문반
- 데이터리안 SQL 실전반

## Certificate
- Google Analytics (GA)

## Project  

## 🔹 Sleep Quality Analysis  
### 📌 프로젝트 개요  
수면 데이터를 활용하여 수면의 질에 영향을 미치는 주요 요인을 알아봅니다. / 개인 프로젝트  

### 🎯 분석 목적  
수면 시간, 스트레스 수준, 수면 장애 유무 등이 수면의 질에 유의미한 영향을 미치는지 검증  
통계적 방법을 통해 단순 상관관계가 아닌 유의미한 차이를 확인  

### 🗂 데이터 설명  
출처: Kaggle / https://www.kaggle.com/datasets/uom190346a/sleep-health-and-lifestyle-dataset  
주요 변수: 수면 시간, 수면의 질, 스트레스 지수, 수면 장애 유무  
  
### 🛠 분석 방법  
Python (pandas, numpy, seaborn, matplotlib)  
T-test를 활용한 그룹 간 평균 차이 검정  
시각화를 통한 분포 및 패턴 확인  

### 📊 주요 결과  

가설 : 수면의 질이 낮은사람은 수면시간이 짧을 것이다  
검증 :  T-test , 상관계수 분석  
결과 : 수면 시간이 짧은 그룹과 긴 그룹 간 수면의 질에서 통계적으로 유의미한 차이 확인    
        스트레스 수준이 높을수록 수면의 질이 낮아지는 경향 관찰


## 🔹 Ecommerce Events Analysis  
### 📌 프로젝트 개요  
화장품 온라인 쇼핑몰의 사용자 행동 로그 데이터를 활용하여  
구매 전환 퍼널과 브랜드, 카테고리별 전환율을 분석한 프로젝트입니다. / 개인프로젝트    
  
### 🎯 분석 목적  
View → Cart → Purchase 퍼널 단계별 전환율 분석  
브랜드, 카테고리별 구매 전환 특성 파악 및 방안제시   

### 🗂 데이터 설명  
출처: Kaggle / https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-cosmetics-shop  

### 🛠 분석 방법  
MySQL을 활용한 데이터 추출 및 집계  
세션 단위 퍼널 분석  
결측치(Unknown) 비중 분석을 통한 데이터 품질 평가 
브랜드 , 카테고리별 전환율 분석  

### 📊 주요 결과    
전체 View → cart → Purchase의 최종 전환율은 약 2.36%     
View → Cart 단계에서 약 85%가 이탈함으로, 상세페이지를 개선해야 합니다.  
category , brand별 Unknow의 비율이 매우 높아 데이터 분류 및 수집 파이프라인을 개선해야합니다.  
카테고리 데이터의 결측률이 높아 해석에 주의 필요  





<img width="2492" height="1649" alt="my_funnel_chart" src="https://github.com/user-attachments/assets/2a1406b1-6924-4286-99b0-e890dff6ee25" />

