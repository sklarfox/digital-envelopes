SELECT accounts.*, 
       COALESCE(sum(CASE WHEN t.inflow THEN amount ELSE -(amount) END), 0) AS balance
FROM accounts 
  LEFT JOIN transactions AS t
    ON accounts.id = t.account_id
    GROUP BY accounts.id
    ORDER BY accounts.name;
