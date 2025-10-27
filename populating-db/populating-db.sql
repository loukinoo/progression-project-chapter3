ROLLBACK;
DELETE FROM public.tasks;
DELETE FROM public.users;

BEGIN;
INSERT INTO public.users ("ID", is_admin, "name")
	VALUES 
	(1, true, 'admin'),
	(2, false, 'normal_user'),
	(3, false, 'other_user');
COMMIT;

BEGIN;
INSERT INTO public.tasks (user_id, completed, assigned, "assignment")
	VALUES
	(1, true, true, 'First assignment'),
	(1, true, true, 'Second assignment'),
	(1, false, true, 'Not yet completed'),
	(2, true, true, 'Already completed'),
	(2, false, true, 'TODO');
COMMIT;

SELECT * FROM public.users;
