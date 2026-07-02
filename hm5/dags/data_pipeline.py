"""
DAG: data_pipeline
Description: Processing data with Dataproc and PySpark (submission-ready version)
"""

import uuid
from datetime import datetime, timedelta

from airflow import DAG
from airflow.models import Variable
from airflow.utils.trigger_rule import TriggerRule
from airflow.operators.bash import BashOperator

from airflow.providers.yandex.operators.dataproc import (
    DataprocCreateClusterOperator,
    DataprocCreatePysparkJobOperator,
    DataprocDeleteClusterOperator,
)


YC_ZONE = Variable.get("YC_ZONE")
YC_FOLDER_ID = Variable.get("YC_FOLDER_ID")
YC_SUBNET_ID = Variable.get("YC_SUBNET_ID")
YC_SSH_PUBLIC_KEY = Variable.get("YC_SSH_PUBLIC_KEY")

S3_BUCKET_NAME = Variable.get("S3_BUCKET_NAME")


with DAG(
    dag_id="data_pipeline",
    start_date=datetime(2025, 6, 10),
    schedule_interval=timedelta(hours=1),
    catchup=False,
    tags=["dataproc", "pyspark"],
) as dag:

    upload_script = BashOperator(
        task_id="upload_pyspark_script",
        bash_command="""
        aws s3 cp /opt/airflow/dags/scripts/pyspark_script.py \
        s3://{{ var.value.S3_BUCKET_NAME }}/src/pyspark_script.py
        """
    )

    create_spark_cluster = DataprocCreateClusterOperator(
        task_id="create_dataproc_cluster",
        folder_id=YC_FOLDER_ID,
        cluster_name=f"tmp-dp-{uuid.uuid4()}",
        cluster_description="Yandex Dataproc cluster for ETL",
        subnet_id=YC_SUBNET_ID,
        s3_bucket=S3_BUCKET_NAME,
        service_account_id=Variable.get("DP_SA_ID"),
        ssh_public_keys=YC_SSH_PUBLIC_KEY,
        zone=YC_ZONE,
        cluster_image_version="2.1",

        masternode_resource_preset="s3-c2-m8",
        masternode_disk_type="network-ssd",
        masternode_disk_size=20,

        datanode_resource_preset="s3-c4-m16",
        datanode_disk_type="network-ssd",
        datanode_disk_size=50,
        datanode_count=2,

        computenode_count=0,

        services=["YARN", "SPARK", "HDFS", "MAPREDUCE"],

        connection_id="yandexcloud_default",

        do_xcom_push=True,
    )

    run_pyspark_job = DataprocCreatePysparkJobOperator(
        task_id="run_pyspark_job",
        main_python_file_uri=f"s3a://{S3_BUCKET_NAME}/src/pyspark_script.py",
        args=["--bucket", S3_BUCKET_NAME],
        connection_id="yandexcloud_default",
    )

    delete_cluster = DataprocDeleteClusterOperator(
        task_id="delete_dataproc_cluster",
        cluster_id="{{ task_instance.xcom_pull(task_ids='create_dataproc_cluster')['id'] }}",
        trigger_rule=TriggerRule.ALL_DONE,
        connection_id="yandexcloud_default",
    )

    upload_script >> create_spark_cluster >> run_pyspark_job >> delete_cluster