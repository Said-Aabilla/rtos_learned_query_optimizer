

CREATE TABLE account
(
    id integer NOT NULL,
    display_name character varying COLLATE pg_catalog."default",
    location character varying COLLATE pg_catalog."default",
    about_me character varying COLLATE pg_catalog."default",
    website_url character varying COLLATE pg_catalog."default"
);


CREATE TABLE so_user
(
    id integer NOT NULL,
    site_id integer NOT NULL,
    reputation integer,
    creation_date timestamp without time zone,
    last_access_date timestamp without time zone,
    upvotes integer,
    downvotes integer,
    account_id integer
);

CREATE TABLE site
(
    site_id integer NOT NULL,
    site_name character varying COLLATE pg_catalog."default"
);




CREATE TABLE answer
(
    id integer NOT NULL,
    site_id integer NOT NULL,
    question_id integer,
    creation_date timestamp without time zone,
    deletion_date timestamp without time zone,
    score integer,
    view_count integer,
    body character varying COLLATE pg_catalog."default",
    owner_user_id integer,
    last_editor_id integer,
    last_edit_date timestamp without time zone,
    last_activity_date timestamp without time zone,
    title character varying COLLATE pg_catalog."default"
);

CREATE TABLE badge
(
    site_id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying COLLATE pg_catalog."default" NOT NULL,
    date timestamp without time zone NOT NULL
);

CREATE TABLE comment
(
    id integer NOT NULL,
    site_id integer NOT NULL,
    post_id integer,
    user_id integer,
    score integer,
    body character varying COLLATE pg_catalog."default",
    date timestamp without time zone
);

CREATE TABLE post_link
(
    site_id integer NOT NULL,
    post_id_from integer NOT NULL,
    post_id_to integer NOT NULL,
    link_type integer NOT NULL,
    date timestamp without time zone
);

CREATE TABLE tag
(
    id integer NOT NULL,
    site_id integer NOT NULL,
    name character varying COLLATE pg_catalog."default"
);

CREATE TABLE tag_question
(
    question_id integer NOT NULL,
    tag_id integer NOT NULL,
    site_id integer NOT NULL
);
CREATE TABLE question
(
    id integer NOT NULL,
    site_id integer NOT NULL,
    accepted_answer_id integer,
    creation_date timestamp without time zone,
    deletion_date timestamp without time zone,
    score integer,
    view_count integer,
    body character varying COLLATE pg_catalog."default",
    owner_user_id integer,
    last_editor_id integer,
    last_edit_date timestamp without time zone,
    last_activity_date timestamp without time zone,
    title character varying COLLATE pg_catalog."default",
    favorite_count integer,
    closed_date timestamp without time zone,
    tagstring character varying COLLATE pg_catalog."default"
);