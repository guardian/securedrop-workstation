from sdw_util import Util
import subprocess

logger = Util.get_logger(module=__name__)


def launch_whistleflow():
    """Launch the Whistleflow view, encrypt and send services"""
    logger.info("Launching whistleflow-view")
    subprocess.Popen(["qvm-run", "whistleflow-view", "systemctl start whistleflow-view"])
    logger.info("Launching whistleflow-encrypt")
    subprocess.Popen(["qvm-run", "whistleflow-encrypt", "systemctl start whistleflow-encrypt"])
    logger.info("Launching whistleflow-send")
    subprocess.Popen(["qvm-run", "whistleflow-send", "systemctl start whistleflow-send"])
