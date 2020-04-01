from datetime import timedelta
# The DAG object; we'll need this to instatiate a DAG
from airflow import DAG
# Operators; we need this to operate
from airflow.operators.bash_operator import BashOperator  
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago  

def test_function():
    print("TEST FUNCTION")

# These args will get passed on to each operator
# You can override them on a per-task basis during operator initialization
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': days_ago(2),
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
    # 'queue': 'bash_queue',
    # 'pool': 'backfill',
    # 'priority_weight': 10,
    # 'end_date': datetime(2016, 1, 1),
    # 'wait_for_downstream': False,
    # 'dag': dag,
    # 'sla': timedelta(hours=2),
    # 'execution_timeout': timedelta(seconds=300),
    # 'on_failure_callback': some_function,
    # 'on_success_callback': some_other_function,
    # 'on_retry_callback': another_function,
    # 'sla_miss_callback': yet_another_function,
    # 'trigger_rule': 'all_success'
}

# Instatiate a DAG
# We'll need a DAG object to nest our tasks into. Here we pass a string that defines the dag_id, which serves as a unique identifier for your DAG. 
# We also pass the default argument dictionary that we just defined and define a schedule_interval of 1 day for the DAG.

dag = DAG(
    'pierre-tutorial',
    default_args=default_args,
    description='A simple tutorial DAG',
    schedule_interval=timedelta(days=1)
)

# Tasks are generated when instantiating operator objects. An object instantiated from an operator is called a constructor.
# The first argument task_id acts as a unique identifier for the task.

# The precedence rules for a task are as follows:
#   1. Explicitly passed argument
#   2. Values that exist in the default_args dictionary
#   3. The operator's default value, if one exists

# A task must include or inherit the arguments task_id and owneer, otherwise Airflow will raise an exception.

t1 = BashOperator(
    task_id='print_date',
    bash_command='date',
    dag=dag
)

t2 = BashOperator(
    task_id='sleep',
    depends_on_past=False,
    bash_command='sleep 5',
    retries=3,
    dag=dag
)

t3 = BashOperator(
    task_id='echo',
    depends_on_past=False,
    bash_command='echo hello',
    retries=3,
    dag=dag
)

t4 = PythonOperator(
    task_id = 'python_test',
    provide_context = False,
    python_callable = test_function,
    dag=dag
)

# We can add documentation for DAG or each sing task. DAG documentation only supports markdown so far and task documentation supports plain text, markdown, reStructuredText, json, and yaml

dag.doc_md = __doc__

t1.doc_md = """\
    ### Task Documentation
    Test test test **TEST**
"""

# Setting up Dependencies
# We have tasks t1, t2, and t3 that do not depend on each other. Here's a few ways you can define dependencies between them:

# t1.set_downstream(t2)

# This means that t2 will depend on t1 running successfuly to run
# It is equivalent to 

# t2.set_upstream(t1)

# The bit shift operator can also be used to chain operations:

# t1 >> t2

# And the upstream dependency with the bit shift operator:
# t2 << t1

# Chaining multiple dependencies becomes concise with the bit shift operator:

t1 >> t2 >> t3 >> t4

# A list of tasks can also be set as dependencies. These operations all have the same effect:
# t1.set_downstream([t2, t3])
# t1 >> [t2, t3]
# [t2, t3] << t1