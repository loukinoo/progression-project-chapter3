-- Functions
-- Logic

BEGIN;
	
	CREATE OR REPLACE FUNCTION completion_rate_of (id_calling_user int, id_user int)
	RETURNS double precision AS $$
	DECLARE 
		percentage double precision;
		completed int;
		total int;
		admin_calling boolean;
	BEGIN
		SELECT u.is_admin
			INTO admin_calling
			FROM public.users u
			WHERE u.id=id_calling_user;
		IF admin_calling OR id_calling_user=id_user THEN
			SELECT COUNT(*)
				INTO completed
				FROM public.tasks t
				WHERE t.user_id = id_user AND t.completed=true;
			SELECT COUNT(*)
				INTO total
				FROM public.tasks t
				WHERE t.user_id = id_user;
			SELECT (100.0 * completed / total)
				INTO percentage;
			RETURN percentage;
		ELSE
			RAISE 'User without admin capabilities trying to access tasks assigned to another user';
		END IF;
	END;
	$$ LANGUAGE plpgsql;

END;

-- For all users
BEGIN;
	
	CREATE OR REPLACE FUNCTION see_own_tasks (id_calling_user int)
	RETURNS TABLE(assignment text, completed boolean) AS $$
	BEGIN
		RETURN QUERY
		SELECT t.assignment, t.completed
			FROM public.tasks t
			WHERE t.user_id = id_calling_user;
	END;
	$$ LANGUAGE plpgsql;
	
	CREATE OR REPLACE FUNCTION mark_completed (id_calling_user int, id_task int)
	RETURNS void AS $$
	DECLARE 
		id_task_user int;
	BEGIN
		SELECT t.user_id
			INTO id_task_user
			FROM public.tasks t
			WHERE t.task_id=id_task;
		IF id_task_user=id_calling_user THEN
			UPDATE public.tasks t
				SET completed=true
				WHERE t.task_id=id_task;
		ELSE
			RAISE 'The task called is assigned to a different user';
		END IF;
	END;
	$$ LANGUAGE plpgsql;
	
	CREATE OR REPLACE FUNCTION own_completion_rate (id_calling_user int)
	RETURNS double precision AS $$
	BEGIN
		RETURN completion_rate_of(id_calling_user, id_calling_user);
	END;
	$$ LANGUAGE plpgsql;
	
END;

-- Only for admin users
-- Add tasks, remove not assigned, assign, check total completion
BEGIN;

	CREATE OR REPLACE FUNCTION create_task (id_calling_user int, task_assignment text)
	RETURNS int as $$
	DECLARE
		admin_calling boolean;
		current_id int;
	BEGIN
		SELECT u.is_admin
			INTO admin_calling
			FROM public.users u
			WHERE u.id=id_calling_user;
		IF admin_calling THEN
			SELECT nextval(pg_get_serial_sequence('tasks', 'task_id'))
				INTO current_id;
			INSERT INTO public.tasks (task_id, assignment)
				VALUES (current_id, task_assignment);
		ELSE
			RAISE 'User without admin capabilities trying to create new task';
		END IF;
		RETURN current_id;
	END;
	$$ LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION remove_task (id_calling_user int, id_task int)
	RETURNS void AS $$
	DECLARE
		is_assigned boolean;
		admin_calling boolean;
	BEGIN
		SELECT u.is_admin
			INTO admin_calling
			FROM public.users u
			WHERE u.id=id_calling_user;
		IF admin_calling THEN
			SELECT t.assigned
				INTO is_assigned
				FROM public.tasks t
				WHERE t.task_id=id_task;
			IF NOT is_assigned THEN
				DELETE FROM public.tasks t
					WHERE t.task_id=id_task;
			ELSE
				RAISE 'Cannot remove a task that has already been assigned';
			END IF;
		ELSE 
			RAISE 'User without admin capabilities trying to remove a task';
		END IF;
	END;
	$$ LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION assign_task_to (id_calling_user int, id_task int, id_user int)
	RETURNS void AS $$
	DECLARE
		admin_calling boolean;
		already_assigned boolean;
	BEGIN
		SELECT u.is_admin
			INTO admin_calling
			FROM public.users u
			WHERE u.id=id_calling_user;
		IF admin_calling THEN
			SELECT t.assigned
				INTO already_assigned
				FROM public.tasks t
				WHERE t.task_id=id_task;
			IF NOT already_assigned THEN
				UPDATE public.tasks t
					SET assigned=true, user_id=id_user
					WHERE t.task_id=id_task;
			ELSE 
				RAISE 'Cannot assign a task already assigned';
			END IF;
		ELSE
			RAISE 'User without admin capabilities trying to assign a task';
		END IF;
	END;
	$$ LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION total_completion_rate (id_calling_user int)
	RETURNS double precision AS $$
	DECLARE
		admin_calling boolean;
		completed int;
		assigned int;
		percentage double precision;
	BEGIN
		SELECT u.is_admin
			INTO admin_calling
			FROM public.users u
			WHERE u.id=id_calling_user;
		IF admin_calling THEN
			SELECT COUNT(*)
				INTO completed
				FROM public.tasks t
				WHERE t.completed = true;
			SELECT COUNT(*)
				INTO assigned
				FROM public.tasks t
				WHERE t.assigned = true;
			SELECT (100.0 * completed / assigned)
				INTO percentage;
			RETURN percentage;
		ELSE
			RAISE 'User without admin capabilities trying to access total completion rate';
		END IF;
	END;
	$$ LANGUAGE plpgsql;

END;