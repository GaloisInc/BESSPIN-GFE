import testlib
import re
import gfeparameters


class gfetester(object):
    """Collection of functions and state used to interact with the GFE fpga.
    This code can be used to coordinate and control actions over the
    physical interfaces to the GFE"""
    def __init__(
        self,
        gdb_port=gfeparameters.gdb_port,
        gdb_path=gfeparameters.gdb_path,
        openocd_command=gfeparameters.openocd_command,
        openocd_cfg_path=gfeparameters.openocd_cfg_path,
    ):
        super(gfetester, self).__init__()
        self.gdb_port = gdb_port
        self.openocd_command = openocd_command
        self.openocd_cfg_path = openocd_cfg_path
        self.gdb_path = gdb_path

    def startGdb(
        self,
        port=gfeparameters.gdb_port,
        server_cmd=gfeparameters.openocd_command,
        config=gfeparameters.openocd_cfg_path,
        riscv_gdb_cmd=gfeparameters.gdb_path
    ):
        """Start a gdb session with the riscv core on the GFE

        Args:
            port (int, optional): TCP port for GDB connection over openocd
            server_cmd (string, optional): The base openocd command to run
            config (string, optional): Path to the openocd debugger
            configuration riscv_gdb_cmd (string, optional): Base gdb
            command for the riscv gdb program
        """
        self.openocd_session = testlib.Openocd(
            server_cmd=server_cmd,
            config=config,
            port=port,
            debug=True,
            verbose=True)
        self.gdb_session = testlib.Gdb(
            cmd=riscv_gdb_cmd,
            verbose=True)
        print("Connecting to the riscv core")
        print(
            self.gdb_session.command(
                "target remote localhost:{}".format(
                    port)))

    def riscvRead32(self, address):
        """Read 32 bits from memory using the riscv core

        Args:
            address (int): Memory address

        Returns:
            int: Value at the address
        """
        if not self.gdb_session:
            self.startGdb()

        return self.gdb_session.x(address=address, size="1w")

    def riscvWrite(self, address, value, size):
        """Use GDB to perform a write with the synchronous riscv core

        Args:
            address (int): Write address
            value (int): Write value
            size (int): Write data size in bits (8, 32, or 64 bits)

        Raises:
            Exception: Invalid write size
        """

        size_options = {8: "char", 32: "int"}

        # Validate input
        if size not in size_options:
            raise Exception(
                "Write size {} must be one of {}".format(
                    size, size_options.keys()))

        if not self.gdb_session:
            self.startGdb()

        # Perform the write command using the gdb set command
        output = self.gdb_session.command(
            "set *(({} *) 0x{:x}) = 0x{:x}".format(
                size_options[size], address, value))

        # Check for an error message from gdb
        m = re.search("Cannot access memory", output)
        if m:
            raise testlib.CannotAccess(address)

    def riscvWrite32(self, address, value):
        self.riscvWrite(address, value, 32)
