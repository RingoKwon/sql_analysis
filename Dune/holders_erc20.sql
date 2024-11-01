/* Error: Unable to fully debug query 
Stable coin
USDC : 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
USDT : 0xdAC17F958D2ee523a2206206994597C13D831ec7
DAI : 0x6B175474E89094C44Da98b954EedeAC495271d0F
USDE : 0x4c9EDD5852cd905f086C759E8383e09bff1E68B3
FDUSD : 0xc5f0f7b66764F6ec8C8Dff7BA683102295E16409
USDD : 0x0C10bF8FcB7Bf5412187A595ab97a3609160b5c6

Yield-Bearing Coin
USDM : 0x59D9356E565Ab3A36dD77763Fc0d87fEaf85508C
USDY : 0x96F6eF951840721AdBF46Ac996b59E0235CB985C
sUSDE : 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497
deUSD : 0x15700B564Ca08D9439C58cA5053166E8317aa138
*/
WITH token_balance_sUSDC AS (
  SELECT
    -SUM(TRY_CAST(value AS DOUBLE) / POWER(10, b.decimals)) AS amount,
    a.evt_block_time as ts, 
    a."from" AS address
  FROM erc20_ethereum.evt_Transfer AS a
  JOIN tokens.erc20 AS b
    ON a.contract_address = b.contract_address
  WHERE
    1 = 1 AND a.contract_address = FROM_HEX('A0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48')
  GROUP BY
    2,3
    
  UNION ALL
  SELECT
    SUM(TRY_CAST(value AS DOUBLE) / POWER(10, b.decimals)) AS amount,
    a.evt_block_time as ts ,
    a.to AS address
  FROM erc20_ethereum.evt_Transfer AS a
  JOIN tokens.erc20 AS b
    ON a.contract_address = b.contract_address
  WHERE
    1 = 1 AND a.contract_address = FROM_HEX('A0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48')
  GROUP BY
    2, 3
), token_union AS (
    SELECT
        address,
        'sUSDC' AS type,
        amount,
        CASE WHEN date(ts) < date('2023-11-01') THEN 1 ELSE 0 END AS cum_date_2310,
        CASE WHEN date(ts) < date('2023-12-01') THEN 1 ELSE 0 END AS cum_date_2311,
        CASE WHEN date(ts) < date('2024-01-01') THEN 1 ELSE 0 END AS cum_date_2312,
        CASE WHEN date(ts) < date('2024-02-01') THEN 1 ELSE 0 END AS cum_date_2401,
        CASE WHEN date(ts) < date('2024-03-01') THEN 1 ELSE 0 END AS cum_date_2402,
        CASE WHEN date(ts) < date('2024-04-01') THEN 1 ELSE 0 END AS cum_date_2403,
        CASE WHEN date(ts) < date('2024-05-01') THEN 1 ELSE 0 END AS cum_date_2404,
        CASE WHEN date(ts) < date('2024-06-01') THEN 1 ELSE 0 END AS cum_date_2405,
        CASE WHEN date(ts) < date('2024-07-01') THEN 1 ELSE 0 END AS cum_date_2406,
        CASE WHEN date(ts) < date('2024-08-01') THEN 1 ELSE 0 END AS cum_date_2407,
        CASE WHEN date(ts) < date('2024-09-01') THEN 1 ELSE 0 END AS cum_date_2408,
        CASE WHEN date(ts) < date('2024-10-01') THEN 1 ELSE 0 END AS cum_date_2409,
        CASE WHEN date(ts) < date('2024-11-01') THEN 1 ELSE 0 END AS cum_date_2410

    FROM token_balance_sUSDC
)
, token_holders AS (
  SELECT
    address,
    'sUSDC' AS type,
    SUM(cum_date_2310) AS cum_date_2310,
    SUM(cum_date_2311) AS cum_date_2311,
    SUM(cum_date_2312) AS cum_date_2312,
    SUM(cum_date_2401) AS cum_date_2401,
    SUM(cum_date_2402) AS cum_date_2402,
    SUM(cum_date_2403) AS cum_date_2403,
    SUM(cum_date_2404) AS cum_date_2404,
    SUM(cum_date_2405) AS cum_date_2405,
    SUM(cum_date_2406) AS cum_date_2406,
    SUM(cum_date_2407) AS cum_date_2407,
    SUM(cum_date_2408) AS cum_date_2408,
    SUM(cum_date_2409) AS cum_date_2409,
    SUM(cum_date_2410) AS cum_date_2410,
    SUM(amount) AS balance
  FROM token_union
  GROUP BY
    1,2 
)
SELECT
  type,
  count( distinct CASE WHEN cum_date_2310 = 1  THEN address END ) AS cum_date_2310,
  count( distinct CASE WHEN cum_date_2311 = 1 THEN address END ) AS cum_date_2311,
  count( distinct CASE WHEN cum_date_2312 = 1 THEN address END ) AS cum_date_2312,
  count( distinct CASE WHEN cum_date_2401 = 1 THEN address END ) AS cum_date_2401,
  count( distinct CASE WHEN cum_date_2402 = 1 THEN address END ) AS cum_date_2402,
  count( distinct CASE WHEN cum_date_2403 = 1 THEN address END ) AS cum_date_2403,
  count( distinct CASE WHEN cum_date_2404 = 1 THEN address END ) AS cum_date_2404,
  count( distinct CASE WHEN cum_date_2405 = 1 THEN address END ) AS cum_date_2405,
  count( distinct CASE WHEN cum_date_2406 = 1 THEN address END ) AS cum_date_2406,
  count( distinct CASE WHEN cum_date_2407 = 1 THEN address END ) AS cum_date_2407,
  count( distinct CASE WHEN cum_date_2408 = 1 THEN address END ) AS cum_date_2408,
  count( distinct CASE WHEN cum_date_2409 = 1 THEN address END ) AS cum_date_2409,
  count( distinct CASE WHEN cum_date_2410 = 1 THEN address END ) AS cum_date_2410

FROM token_holders
WHERE 1=1 
GROUP BY
  1


