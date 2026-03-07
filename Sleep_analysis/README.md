# 수면 품질 결정 요인 분석

수면 데이터를 활용하여 수면의 질에 영향을 미치는 주요 요인을 분석한 개인 프로젝트입니다.

---

## 📌 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 분석 목적 | 수면 시간, 스트레스, 수면장애가 수면의 질에 미치는 영향 검증 |
| 데이터 출처 | Kaggle - Sleep Health and Lifestyle Dataset |
| 데이터 규모 | 374행 × 13컬럼 |
| 분석 도구 | Python (pandas, numpy, seaborn, matplotlib, scipy) |

---

## 🔑 핵심 결과 요약

| 분석 항목 | 주요 발견 |
|-----------|-----------|
| 수면의 질 vs 수면시간 | High_Quality 평균 7.74h, Low_Quality 평균 6.57h — T-test p=1.09e-63 |
| 수면시간 vs 스트레스 | 상관계수 -0.81 / Short_Sleeper 평균 스트레스 6.63 vs Long_Sleeper 4.30 |
| 수면장애 유무 | Disorder 그룹 수면질 평균 6.87 vs No Disorder 7.63 |
| 직업군별 수면질 | Engineer 최고 / Doctor 최저 |

---

## 🔍 분석 구조
```
Q1. 수면의 질이 낮은 사람은 수면시간이 짧은가?
 └─ 수면질 평균(7.31) 기준 High/Low 그룹 분류 → T-test 검증
    ↓
Q2. 수면시간이 짧은 사람은 스트레스가 많은가?
 └─ 수면시간 평균(7.13h) 기준 Long/Short 그룹 분류 → 스트레스 비교
    ↓
Q3. 수면장애 유무·유형이 수면에 영향을 주는가?
 └─ NaN 219건 → No Disorder 처리 / 수면질·수면시간·스트레스 비교
 └─ 추가: IQR 이상치 탐지 (하한 6.05h) → 의사 직업군 집중 확인
    ↓
Q4. 직업군별 수면의 질 차이가 있는가?
 └─ High_Quality TOP: Engineer / Low_Quality TOP: Doctor
```

---

## 📊 사용 시각화

- Heatmap (상관행렬)
- Boxplot (그룹 간 분포 비교)
- Violinplot (수면시간 분포)
- Countplot / Barplot (빈도 및 직업군 비교)

---

## 💡 분석 시 주요 판단

- `Sleep Disorder` 컬럼 NaN 219건 → 수면장애 없음(No Disorder)으로 가정 처리
- 그룹 분류 기준: 전체 평균값 사용 (수면질 평균 7.31, 수면시간 평균 7.13h)
- 통계 검증: T-test (`equal_var=True`, 두 그룹 분산 동일 가정)
- 이상치 탐지: IQR 방식 적용 (No Disorder 그룹 내 하한 6.05h)
