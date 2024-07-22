import unittest

from base import SD_VM_Local_Test


class SD_Log_Tests(SD_VM_Local_Test):
    def setUp(self):
        self.vm_name = "sd-log"
        super().setUp()

    def test_sd_log_package_installed(self):
        self.assertTrue(self._package_is_installed("securedrop-log"))

    def test_sd_log_redis_is_installed(self):
        self.assertTrue(self._package_is_installed("redis"))
        self.assertTrue(self._package_is_installed("redis-server"))

    def test_log_utility_installed(self):
        self.assertTrue(self._fileExists("/usr/sbin/securedrop-log-saver"))
        self.assertTrue(self._fileExists("/etc/qubes-rpc/securedrop.Log"))

    def test_sd_log_has_no_custom_rsyslog(self):
        self.assertFalse(self._fileExists("/etc/rsyslog.d/sdlog.conf"))

    def test_sd_log_service_running(self):
        self.assertTrue(self._service_is_active("securedrop-log-server"))

    def test_redis_service_running(self):
        self.assertTrue(self._service_is_active("redis"))

    def test_logs_are_flowing(self):
        cmd_output = self._run("ls -1 /home/user/QubesIncomingLogs")
        log_dirs = cmd_output.split("\n")
        # Confirm AppVMs are sending logs
        self.assertIn("sd-app", log_dirs)
        # The following will only have logs if the machine has booted,
        # which is not guaranteed given that we randomize test order.
        # self.assertIn("sd-devices", log_dirs)
        # self.assertIn("sd-proxy", log_dirs)
        # self.assertIn("sd-viewer", log_dirs)

    def test_log_dirs_properly_named(self):
        # Rerunning this command to keep test output readable
        cmd_output = self._run("ls -1 /home/user/QubesIncomingLogs")
        log_dirs = cmd_output.split("\n")
        # Confirm we don't have 'host' entries from Whonix VMs
        self.assertNotIn("host", log_dirs)


def load_tests(loader, tests, pattern):
    return unittest.TestLoader().loadTestsFromTestCase(SD_Log_Tests)
