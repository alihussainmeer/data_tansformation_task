python3.11 -m venv .venv
source .venv/bin/activate
pip-compile
pip-compile requirements.in
pip-sync requirements.txt requirements.txt
cd dbt
dbt debug
dbt deps


# sudo -u postgres psql  # Log in as the postgres user
# ALTER ROLE postgres WITH PASSWORD 'your_strong_password';  # Change 'your_strong_password'
# \q  # Exit psql
