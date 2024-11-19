from alembic.config import Config
from alembic import command

from app.backend_pre_start import main as pre_start
from app.initial_data import main as initial_data

if __name__ == "__main__":
    """Implements the scripts/prestart.sh script, but using python as the interpreter instead of bash"""
    pre_start()
    command.upgrade(Config('alembic.ini'), 'head')
    initial_data()
