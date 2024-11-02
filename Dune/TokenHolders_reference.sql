/* 
Example of getting number of token holders over time
reference : original : https://dune.com/queries/3268167/5470567
my : https://dune.com/queries/4235366?token_address_t6c1ea=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48&chain_t6c1ea=ethereum
*/

WITH transfer_events AS (
    SELECT date_trunc('day',evt_block_time) as date,
           tr."from" AS address,
           -(tr.value/power(10, t.decimals)) AS amount
    FROM erc20_{{chain}}.evt_transfer tr
    LEFT JOIN tokens.erc20 t ON tr.contract_address = t.contract_address
    WHERE "from" != 0x0000000000000000000000000000000000000000
    AND tr.contract_address = {{token_address}}
    UNION ALL
    SELECT date_trunc('day',evt_block_time) as date,
           tr."to" AS address,
           (tr.value/power(10, t.decimals)) AS amount
    FROM erc20_{{chain}}.evt_transfer tr
    LEFT JOIN tokens.erc20 t ON tr.contract_address = t.contract_address
    WHERE "to" != 0x0000000000000000000000000000000000000000
    AND tr.contract_address = {{token_address}}
),

user_balance AS (
    SELECT date,
           address,
           SUM(SUM(amount)) OVER (PARTITION BY address ORDER BY date) as daily_cumulative_balance
    FROM transfer_events
    GROUP BY 1,2
),

setLeadData as (
    SELECT *,
           lead(date,1,NOW()) OVER (PARTITION BY address ORDER BY date) as latest_day 
    FROM user_balance
),

gs as (
    SELECT date 
    FROM UNNEST(sequence(date_trunc('day', CAST(NOW() - interval '1' year AS TIMESTAMP)),
                        CAST(NOW() AS TIMESTAMP),
                        interval '1' day)) as tbl(date)
),

getUserDailyBalance as (
    SELECT gs.date,
           address,
           daily_cumulative_balance
    FROM setLeadData g
    INNER JOIN gs ON g.date <= gs.date AND gs.date < g.latest_day
    WHERE daily_cumulative_balance > 0.000001
)

SELECT date,
       COUNT(address) as holders,
       COUNT(address) - LAG(COUNT(address)) OVER (ORDER BY date) as change 
FROM getUserDailyBalance
GROUP BY 1
ORDER BY 1 DESC