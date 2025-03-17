--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Ubuntu 17.4-1.pgdg22.04+2)
-- Dumped by pg_dump version 17.4 (Ubuntu 17.4-1.pgdg22.04+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: java_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO java_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: java_user
--

CREATE TABLE public.posts (
    id bigint NOT NULL,
    author character varying(255),
    content character varying(255),
    title character varying(255)
);


ALTER TABLE public.posts OWNER TO java_user;

--
-- Name: posts_seq; Type: SEQUENCE; Schema: public; Owner: java_user
--

CREATE SEQUENCE public.posts_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.posts_seq OWNER TO java_user;

--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: java_user
--

COPY public.posts (id, author, content, title) FROM stdin;
3	Наталья Морозова	Виртуальная и дополненная реальность находят применение в играх, образовании и медицине. Что нас ждет в будущем?	VR и AR: новые горизонты
2	Анна Смирнова	Облачные технологии продолжают развиваться, предлагая новые решения для хранения и обработки данных. В будущем они станут еще более безопасными и доступными.	Будущее облачных технологий
4	Дмитрий Иванов	ИИ помогает врачам ставить точные диагнозы и разрабатывать персонализированные методы лечения. Это революция в здравоохранении!	Искусственный интеллект в медицине
5	Иван Петров	С ростом числа кибератак важно использовать современные методы защиты данных. Узнайте, как обезопасить свой бизнес.	Кибербезопасность в 2023 год
21	Мария Иванова	Технология 5G обещает высокую скорость и низкую задержку. Как она изменит нашу жизнь?	5G: новая эра связи
34	Сергей Соколов	Блокчейн используется не только для криптовалют. Узнайте, как он применяется в логистике, юриспруденции и других сферах.	Блокчейн за пределами криптовалют
56	Алексей Петров	Квантовые компьютеры обещают решать задачи, недоступные классическим. Но когда они станут доступны?	Квантовые компьютеры: миф или реальность?
64	Ольга Кузнецова	Big Data меняет подход к анализу информации. Как компании используют большие данные для принятия решений?	Big Data: данные как ресурс
86	Екатерина Сидорова	Умные дома, фитнес-трекеры и другие устройства IoT делают нашу жизнь удобнее. Но как защитить свои данные?	Интернет вещей (IoT) в быту
98	Андрей Волков	DevOps объединяет разработку и эксплуатацию, ускоряя выпуск продуктов. Почему это важно для IT-команд?	DevOps: путь к эффективной разработке
\.


--
-- Name: posts_seq; Type: SEQUENCE SET; Schema: public; Owner: java_user
--

SELECT pg_catalog.setval('public.posts_seq', 201, true);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: java_user
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

