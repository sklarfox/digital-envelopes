CREATE TABLE accounts (
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL
);

CREATE TABLE categories (
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL,
  assigned_amount decimal(10,2) NOT NULL DEFAULT 0
);

INSERT INTO categories (name)
VALUES ('Inflow');

CREATE TABLE transactions (
  id serial PRIMARY KEY,
  amount decimal(10,2) NOT NULL,
  memo text,
  inflow boolean NOT NULL DEFAULT false,
  date date NOT NULL DEFAULT CURRENT_DATE,
  category_id int NOT NULL REFERENCES categories (id) ON DELETE CASCADE,
  account_id int NOT NULL REFERENCES accounts (id) ON DELETE CASCADE
);

-- Development Data Below

INSERT INTO accounts (name)
VALUES ('Checking'), ('Savings'), ('Money Market');

INSERT INTO categories (name)
VALUES ('Groceries'), ('Rent'), ('Fun Money'), ('Health and Fitness'),
       ('Emergency Fund'), ('Transportation');
