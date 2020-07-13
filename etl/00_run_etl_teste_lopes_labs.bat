echo Iniciando Job
c:
cd C:\pdi\pdi-ce-8.3.0.0-371\data-integration\
kitchen.bat /rep:teste_lopes_labs /job:00_mainjob_etl_apple_store /dir: /level:Basic /log:"C:\teste_lopes_lab\etl\logs\executa_job.log" > "C:\teste_lopes_lab\etl\logs\executa_job_console.log"
