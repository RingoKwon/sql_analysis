with token_balances as (
    select -- tokens sold
        -sum(cast(value as double) / pow(10, b.decimals)) as amount
        , "from" as address
    from erc20_ethereum.evt_Transfer a
    join tokens.erc20 b on a.contract_address = b.contract_address
    group by 2
    
    union all
    
    select -- tokens bought
        sum(cast(value as double) / pow(10, b.decimals)) as amount
        , a.to as address
    from erc20_ethereum.evt_Transfer a
    join tokens.erc20 b on a.contract_address = b.contract_address
    
    group by 2
),


token_holders as (
    select
        address
        , sum(amount) as balance
    from token_balances
    group by 1
)
select 
count ( distinct address) as holder_cnt 
from token_holders
where 1=1 
    and balance >0 ; 
    