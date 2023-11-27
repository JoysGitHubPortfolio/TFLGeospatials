-- Identify the top 10 stations with the highest total rides
WITH TopStations AS (
  SELECT
    start_station_name,
    SUM(station_rides) AS overall_total_rides
  FROM (
    SELECT
      start_station_name,
      COUNT(*) AS station_rides
    FROM
      `bigquery-public-data.london_bicycles.cycle_hire`
    GROUP BY
      start_station_name
  )
  GROUP BY
    start_station_name
  ORDER BY
    overall_total_rides DESC
  LIMIT 10
),

MonthlyBreakdown AS (
  -- Get a monthly breakdown for the top 10 stations
  SELECT
    FORMAT_DATE('%Y-%m', start_date) AS ride_month,
    start_station_name,
    COUNT(*) AS monthly_rides
  FROM
    `bigquery-public-data.london_bicycles.cycle_hire`
  WHERE
    start_station_name IN (SELECT start_station_name FROM TopStations)
    AND start_date > '2021-01-01'
  GROUP BY
    ride_month, start_station_name
),

TotalRidesPerMonth AS (
  -- Calculate the total rides for each month for all stations
  SELECT
    FORMAT_DATE('%Y-%m', start_date) AS ride_month,
    COUNT(*) AS total_rides_for_month
  FROM
    `bigquery-public-data.london_bicycles.cycle_hire`
  GROUP BY
    ride_month
),

TotalRidesPerMonthTop10 AS (
  -- Calculate the total rides for each month for only the top 10 stations
  SELECT
    ride_month,
    SUM(monthly_rides) AS total_rides_for_month_top10
  FROM
    MonthlyBreakdown
  GROUP BY
    ride_month
)

SELECT
  m.ride_month,
  m.start_station_name,
  m.monthly_rides,
  t.total_rides_for_month,
  tt.total_rides_for_month_top10,
  ROUND(m.monthly_rides / tt.total_rides_for_month_top10 * 100, 3) AS popularity_relative_top10,
  ROUND(m.monthly_rides / t.total_rides_for_month * 100, 3) AS popularity_absolute
FROM
  MonthlyBreakdown m
JOIN
  TotalRidesPerMonth t ON m.ride_month = t.ride_month
JOIN
  TotalRidesPerMonthTop10 tt ON m.ride_month = tt.ride_month
ORDER BY
  m.start_station_name, m.ride_month;
