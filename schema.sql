CREATE TABLE accounts (
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL
);

CREATE TABLE categories (
  id serial PRIMARY KEY,
  assigned_amount decimal(10,2) NOT NULL DEFAULT 0,
  name text UNIQUE NOT NULL
);

CREATE TABLE transactions (
  id serial PRIMARY KEY,
  amount decimal(10,2) NOT NULL,
  memo text,
  inflow boolean NOT NULL DEFAULT false,
  date date NOT NULL DEFAULT CURRENT_DATE,
  category_id int NOT NULL REFERENCES categories (id),
  account_id int NOT NULL REFERENCES categories (id)
);

-- DEVELY DATA BELOW

INSERT INTO accounts (name)
VALUES ('Checking'), ('Savings');

INSERT INTO categories (name)
VALUES ('Ready to Assign'), ('Groceries'), ('Gas');

INSERT INTO transactions (amount, memo, inflow, category_id, account_id)
VALUES (3000.00, 'Starting Balance', true, 1, 1),
       (200.00, 'Costco Run', false, 1, 1),
       (75.00, 'Roadtrip', false, 1, 2)
       ;