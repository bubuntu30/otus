# OTUS. Feature Store

# 1. Создайте 2 новые Feature View

Были созданы два новых Feature View, основанных на  данных о водителях.


1. FeatureView (driver_quality_stats) - как хорошо водитель выполняет работу. Использует признаки conv_rate,acc_rate

2. FeatureView  - активность водителя. Использует признак avg_daily_trips


# 2. Создайте 1 on-demand Feature View

Оба Feature View используются в on-demand Feature View (realtime_driver_metrics)
Вычисляет метрики в реальном времени:

quality_index — комбинированная оценка качества водителя
efficiency_score — итоговая эффективность с учётом активности

# 3 Приложите ноутбу

Ноутбук - otus-feature-store/example.ipynb