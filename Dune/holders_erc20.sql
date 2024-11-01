/* Error: Unable to fully debug query */
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
), token_holders AS (
  SELECT
    address,
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
    1
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