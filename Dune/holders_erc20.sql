-- https://dune.com/queries/4230552/7116791
WITH token_balances AS (
  SELECT
    -SUM(TRY_CAST(value AS DOUBLE) / POWER(10, b.decimals)) AS amount,
    "from" AS address
  FROM erc20_ethereum.evt_Transfer AS a
  JOIN tokens.erc20 AS b
    ON a.contract_address = b.contract_address
  WHERE
    1 = 1 AND a.contract_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
  GROUP BY
    2
  UNION ALL
  SELECT
    SUM(TRY_CAST(value AS DOUBLE) / POWER(10, b.decimals)) AS amount,
    a.to AS address
  FROM erc20_ethereum.evt_Transfer AS a
  JOIN tokens.erc20 AS b
    ON a.contract_address = b.contract_address
  WHERE
    1 = 1 AND a.contract_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
  GROUP BY
    2
), token_holders AS (
  SELECT
    address,
    SUM(amount) AS balance
  FROM token_balances
  GROUP BY
    1
)
SELECT
  COUNT(DISTINCT address) AS holder_cnt
FROM token_holders
WHERE
  1 = 1 AND balance > 0