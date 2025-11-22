-- Tables

BEGIN;

CREATE TABLE IF NOT EXISTS public."users"
(
    id serial,
    admin boolean,
    name text,
    PRIMARY KEY (id)
);

COMMENT ON TABLE public."users"
    IS 'The users of the service';

CREATE TABLE IF NOT EXISTS public.tasks
(
	task_id serial,
    user_id integer,
    completed boolean DEFAULT false,
    assigned boolean DEFAULT false,
    assignment text,
	PRIMARY KEY (task_id)
);

COMMENT ON TABLE public.tasks
    IS 'List of all tasks';

ALTER TABLE IF EXISTS public.tasks
    ADD FOREIGN KEY (user_id)
    REFERENCES public."users" (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

END;

