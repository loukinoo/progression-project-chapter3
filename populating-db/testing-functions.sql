
SELECT create_task(1, 'Testing');
SELECT create_task(1, 'To delete');

SELECT assign_task_to(1, 6, 3);

SELECT mark_completed(3, 6);

SELECT remove_task(1, 8);

SELECT completion_rate_of(1, 2), own_completion_rate(3), see_own_tasks(2), total_completion_rate(1);
