SELECT
  HIRES.rental_id, HIRES.duration, HIRES.start_date, HIRES.start_station_name, HIRES.end_station_name,
  START.latitude AS starting_latitude, START.longitude AS starting_longitude, START.docks_count,
  ENDING.latitude AS ending_latitude, ENDING.longitude AS ending_longitude
FROM
  `bigquery-public-data.london_bicycles.cycle_hire` AS HIRES

JOIN
  `bigquery-public-data.london_bicycles.cycle_stations` AS START
ON
  HIRES.start_station_name = START.name

JOIN
  `bigquery-public-data.london_bicycles.cycle_stations` AS ENDING
ON
  HIRES.end_station_name = ENDING.name

WHERE
  start_station_name != end_station_name
  AND start_date > '2021-01-01'
  AND EXTRACT(DAYOFWEEK FROM start_date) IN (1,7)
  AND EXTRACT(HOUR FROM start_date) BETWEEN 10 AND 18
  ORDER BY RAND()
LIMIT 1000
