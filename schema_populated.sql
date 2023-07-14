--
-- PostgreSQL database dump
--

-- Dumped from database version 14.8 (Homebrew)
-- Dumped by pg_dump version 14.8 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: alex
--

CREATE TABLE public.accounts (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.accounts OWNER TO alex;

--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: alex
--

CREATE SEQUENCE public.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_id_seq OWNER TO alex;

--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alex
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: alex
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name text NOT NULL,
    assigned_amount numeric(10,2) DEFAULT 0 NOT NULL
);


ALTER TABLE public.categories OWNER TO alex;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: alex
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_id_seq OWNER TO alex;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alex
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: alex
--

CREATE TABLE public.transactions (
    id integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    memo text,
    inflow boolean DEFAULT false NOT NULL,
    date date DEFAULT CURRENT_DATE NOT NULL,
    category_id integer NOT NULL,
    account_id integer NOT NULL
);


ALTER TABLE public.transactions OWNER TO alex;

--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: alex
--

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transactions_id_seq OWNER TO alex;

--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alex
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: alex
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: alex
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: alex
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: alex
--

INSERT INTO public.accounts VALUES (1, 'Checking');
INSERT INTO public.accounts VALUES (2, 'Savings');
INSERT INTO public.accounts VALUES (3, 'Money Market');


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: alex
--

INSERT INTO public.categories VALUES (1, 'Inflow', 0.00);
INSERT INTO public.categories VALUES (6, 'Emergency Fund', 5000.00);
INSERT INTO public.categories VALUES (3, 'Rent', 1000.00);
INSERT INTO public.categories VALUES (2, 'Groceries', 500.00);
INSERT INTO public.categories VALUES (5, 'Health and Fitness', 450.00);
INSERT INTO public.categories VALUES (4, 'Fun Money', 300.00);
INSERT INTO public.categories VALUES (7, 'Transportation', 200.00);
INSERT INTO public.categories VALUES (8, 'House Plants', 0.00);
INSERT INTO public.categories VALUES (9, 'Dining Out', 0.00);
INSERT INTO public.categories VALUES (10, 'Insurance', 0.00);
INSERT INTO public.categories VALUES (11, 'Garden Projects', 0.00);


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: alex
--

INSERT INTO public.transactions VALUES (2, 2000.00, 'Starting Balance', true, '2023-07-01', 1, 3);
INSERT INTO public.transactions VALUES (3, 1450.00, 'Starting Balance', true, '2023-07-13', 1, 2);
INSERT INTO public.transactions VALUES (4, 75.00, 'Meal Prep', false, '2023-07-13', 2, 1);
INSERT INTO public.transactions VALUES (5, 34.00, 'Snacks', false, '2023-07-05', 2, 1);
INSERT INTO public.transactions VALUES (6, 15.00, 'Coffee', false, '2023-07-04', 2, 1);
INSERT INTO public.transactions VALUES (7, 100.00, 'Costco run', false, '2023-07-07', 2, 1);
INSERT INTO public.transactions VALUES (8, 14.50, 'Milk and bread', false, '2023-07-13', 2, 1);
INSERT INTO public.transactions VALUES (9, 21.00, 'Burrito supplies', false, '2023-07-09', 2, 1);
INSERT INTO public.transactions VALUES (10, 50.00, 'Weekly food', false, '2023-07-11', 2, 1);
INSERT INTO public.transactions VALUES (11, 25.17, '', false, '2023-07-10', 2, 1);
INSERT INTO public.transactions VALUES (12, 55.49, '', false, '2023-07-02', 2, 1);
INSERT INTO public.transactions VALUES (13, 35.40, '', false, '2023-07-08', 2, 1);
INSERT INTO public.transactions VALUES (14, 35.00, 'potluck', false, '2023-06-28', 2, 1);
INSERT INTO public.transactions VALUES (1, 4000.00, 'Salary', true, '2023-07-01', 1, 1);
INSERT INTO public.transactions VALUES (15, 1000.00, 'Rent payment', false, '2023-07-01', 3, 2);
INSERT INTO public.transactions VALUES (16, 21.00, '', false, '2023-07-02', 2, 1);
INSERT INTO public.transactions VALUES (17, 80.00, 'Gym membership', false, '2023-07-01', 5, 1);
INSERT INTO public.transactions VALUES (18, 75.00, 'gas', false, '2023-07-02', 7, 1);
INSERT INTO public.transactions VALUES (19, 15.00, 'movie night', false, '2023-07-06', 4, 1);
INSERT INTO public.transactions VALUES (20, 100.00, 'Insurance', false, '2023-07-04', 7, 1);
INSERT INTO public.transactions VALUES (21, 20.00, 'headlight bulbs', false, '2023-07-12', 7, 1);
INSERT INTO public.transactions VALUES (23, 35.00, 'Bar tab', false, '2023-07-13', 4, 1);


--
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: alex
--

SELECT pg_catalog.setval('public.accounts_id_seq', 3, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: alex
--

SELECT pg_catalog.setval('public.categories_id_seq', 11, true);


--
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: alex
--

SELECT pg_catalog.setval('public.transactions_id_seq', 23, true);


--
-- Name: accounts accounts_name_key; Type: CONSTRAINT; Schema: public; Owner: alex
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_name_key UNIQUE (name);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: alex
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: alex
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: alex
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: alex
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alex
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alex
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

