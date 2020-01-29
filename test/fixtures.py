import pytest

import config
from harness import GdbSession, UartSession


@pytest.fixture
def addr_map():
    return config.addr_map

@pytest.fixture
def gdb_params():
    return config.gdb_params


@pytest.fixture
def gdb(scope='module', **kwargs):
    """Interface to a GDB/OpenOCD session connected to a RISC-V processor running on the VCU118."""

    # 'Setup' code run when fixture is instantiated:
    session = GdbSession(**kwargs)

    yield session

    # 'Teardown' code run when fixture goes out of scope:   
    # ...


