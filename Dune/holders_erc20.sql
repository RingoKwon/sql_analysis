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

WITH token_balances_usdc AS (
  SELECT
    -SUM(TRY_CAST(value AS DOUBLE) / POWER(10, b.decimals)) AS amount,
    "from" AS address,
    'USDC' AS symbol,
    'Stablecoin' AS token_type
  FROM erc20_ethereum.evt_Transfer AS a
  JOIN tokens.erc20 AS b
    ON a.contract_address = b.contract_address
  WHERE
    1 = 1 AND a.contract_address = FROM_HEX('A0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48')
  GROUP BY
    2
  UNION ALL
  SELECT
    SUM(TRY_CAST(value AS DOUBLE) / POWER(10, b.decimals)) AS amount,
    a.to AS address,
    'USDC' AS symbol,
    'Stablecoin' AS token_type
  FROM erc20_ethereum.evt_Transfer AS a
  JOIN tokens.erc20 AS b
    ON a.contract_address = b.contract_address
  WHERE
    1 = 1 AND a.contract_address = FROM_HEX('A0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48')
  GROUP BY
    2
), token_balances_usdt AS (
  SELECT
    -SUM(TRY_CAST(value AS DOUBLE) / POWER(10, b.decimals)) AS amount,
    "from" AS address,
    'USDT' AS symbol,
    'Stablecoin' AS token_type
  FROM erc20_ethereum.evt_Transfer AS a
  JOIN tokens.erc20 AS b
    ON a.contract_address = b.contract_address
  WHERE
    1 = 1 AND a.contract_address = FROM_HEX('dAC17F958D2ee523a2206206994597C13D831ec7')
  GROUP BY
    2
 UNION ALL
  SELECT
    SUM(TRY_CAST(value AS DOUBLE) / POWER(10, b.decimals)) AS amount,
    a.to AS address,
    'USDT' AS symbol,
    'Stablecoin' AS token_type
  FROM erc20_ethereum.evt_Transfer AS a
  JOIN tokens.erc20 AS b
    ON a.contract_address = b.contract_address
  WHERE
    1 = 1 AND a.contract_address = FROM_HEX('dAC17F958D2ee523a2206206994597C13D831ec7')
  GROUP BY
    2
), token_balances_dai AS (
  SELECT
    -SUM(TRY_CAST(value AS DOUBLE) / POWER(10, b.decimals)) AS amount,
    "from" AS address,
    'DAI' AS symbol,
    'Stablecoin' AS token_type
  FROM erc20_ethereum.evt_Transfer AS a
  JOIN tokens.erc20 AS b
    ON a.contract_address = b.contract_address
  WHERE
    1 = 1 AND a.contract_address = FROM_HEX('6B175474E89094C44Da98b954EedeAC495271d0F')
  GROUP BY
    2
UNION ALL
  SELECT
    SUM(TRY_CAST(value AS DOUBLE) / POWER(10, b.decimals)) AS amount,
    a.to AS address,
    'DAI' AS symbol,
    'Stablecoin' AS token_type
  FROM erc20_ethereum.evt_Transfer AS a
  JOIN tokens.erc20 AS b
    ON a.contract_address = b.contract_address
  WHERE
    1 = 1 AND a.contract_address = FROM_HEX('6B175474E89094C44Da98b954EedeAC495271d0F')
  GROUP BY
    2
), token_holders AS (
  SELECT
    address,
    symbol,
    token_type,
    SUM(amount) AS balance
  FROM (
    SELECT
      *
    FROM token_balances_usdc
    UNION ALL
    SELECT
      *
    FROM token_balances_usdt
    UNION ALL
    SELECT
      *
    FROM token_balances_dai
  ) AS token_balances
  GROUP BY
    1, 2, 3
)
SELECT
  symbol,
  token_type,
  COUNT(DISTINCT address) AS holder_cnt
FROM token_holders
WHERE
  1 = 1 AND balance > 0
GROUP BY
  1, 2
ORDER BY
  1, 2;