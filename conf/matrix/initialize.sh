#!/bin/bash -eu
# Demo Synapse entrypoint: renders the homeserver configuration from the
# jinja2 template (using environment variables), creates the database role,
# starts Synapse and ensures the admin user exists.

DATA_DIR="/data"
CONFIG_DIR="/config"
PLUGIN_NAME="synapse-auto-accept-invite"
PLUGIN_TARGET_DIR="${DATA_DIR}/matrix_plugins"

# 1. Install the auto-accept invite plugin (optional, non-fatal)
if [ "${ENABLE_PLUGIN_INSTALL:-true}" = "true" ]; then
  if python3 -c "import sys; sys.path.insert(0, '${PLUGIN_TARGET_DIR}'); import synapse_auto_accept_invite" 2>/dev/null; then
    echo "Plugin '${PLUGIN_NAME}' is already available. Skipping."
  elif pip install --target "${PLUGIN_TARGET_DIR}" "${PLUGIN_NAME}" >/dev/null 2>&1; then
    echo "Plugin '${PLUGIN_NAME}' installed."
  else
    echo "Plugin '${PLUGIN_NAME}' could not be installed, running without it."
    ENABLE_PLUGIN_INSTALL="false"
  fi
fi
export ENABLE_PLUGIN_INSTALL
export PYTHONPATH="${PLUGIN_TARGET_DIR}:${PYTHONPATH:-}"

# 2. Render the homeserver configuration from the template
python3 <<'PYEOF'
import jinja2
import os

env = {k: v for k, v in os.environ.items() if k.replace("_", "").isalnum()}
with open("/config/homeserver.yaml") as src:
    template = jinja2.Template(src.read())
with open("/data/homeserver.yaml", "w") as dst:
    dst.write(template.render(**env))
PYEOF

# 3. Copy the logging configuration
cp "${CONFIG_DIR}/matrix.log.config" "${DATA_DIR}/matrix.log.config"

# 4. Generate the signing key if missing
if [ ! -f "${DATA_DIR}/matrix.signing.key" ]; then
  echo "Generating the Matrix signing key..."
  python3 -m synapse.app.homeserver \
    --config-path "${DATA_DIR}/homeserver.yaml" \
    --keys-directory "${DATA_DIR}" \
    --generate-keys
fi

# Ensure Synapse (uid 991) can read the data and log directories
chown -R 991:991 "${DATA_DIR}" /var/log/matrix

# 5. Create the dedicated 'synapse' database role if missing
python3 <<'PYEOF'
import os
try:
    import psycopg2 as psycopg
except ImportError:
    import psycopg

conn = psycopg.connect(
    host="postgres",
    user="postgres",
    password=os.environ["MATRIX_POSTGRES_PASSWORD"],
    dbname="synapse",
)
conn.autocommit = True
cur = conn.cursor()
cur.execute("SELECT 1 FROM pg_roles WHERE rolname='synapse'")
if cur.fetchone() is None:
    cur.execute("CREATE ROLE synapse WITH LOGIN PASSWORD %s", (os.environ["MATRIX_DB_PASSWORD"],))
cur.execute("GRANT ALL ON SCHEMA public TO synapse")
cur.execute("ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO synapse")
cur.execute("ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO synapse")
cur.close()
conn.close()
PYEOF

# 6. Start Synapse in the background
exec /start.py &

# 7. Wait for the API, then ensure the admin user exists
echo "Waiting for Synapse API to be ready..."
until curl -sSf http://localhost:8008/_matrix/client/versions &>/dev/null; do
  sleep 5
done

if register_new_matrix_user -c "${DATA_DIR}/homeserver.yaml" -a \
    -u "${MATRIX_ADMIN_USERNAME}" -p "${MATRIX_ADMIN_PASSWORD}"; then
  echo "Matrix admin user '${MATRIX_ADMIN_USERNAME}' created."
else
  echo "Matrix admin user '${MATRIX_ADMIN_USERNAME}' already exists or could not be created."
fi

wait
