import argparse
import csv
import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "scripts" / "benchmark-jichang-state.py"
SPEC = importlib.util.spec_from_file_location("benchmark_jichang_state", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
STATE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(STATE)


class PmSummaryTest(unittest.TestCase):
    def write_pm_log(
        self,
        output: Path,
        frequencies: list[float],
        busy: list[float],
    ) -> Path:
        log = output / "logs" / "abc123" / "maf-MXFP8.attempt-1_pm.csv"
        log.parent.mkdir(parents=True)
        frequency_columns = STATE.pm_freq_columns(0)
        busy_columns = STATE.pm_busy_columns(0)
        with log.open("w", newline="", encoding="utf-8") as stream:
            writer = csv.writer(stream)
            writer.writerow(["Time Stamp", *frequency_columns, *busy_columns])
            for index, (frequency, activity) in enumerate(zip(frequencies, busy)):
                writer.writerow([
                    str(index),
                    *([frequency] * len(frequency_columns)),
                    *([activity] * len(busy_columns)),
                ])
        return log

    def record_pm(self, output: Path, log: Path, keep_log: bool = True) -> None:
        STATE.record_pm(argparse.Namespace(
            output=output,
            log=log,
            gpu=0,
            keep_log=keep_log,
        ))

    def read_summary(self, output: Path) -> dict[str, str]:
        with (output / "pm-summary.csv").open(newline="", encoding="utf-8") as stream:
            return next(csv.DictReader(stream))

    def test_uses_longest_busy_interval_instead_of_idle_frequency_transition(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            log = self.write_pm_log(
                output,
                frequencies=[
                    250, 1500, 2250, 250,
                    1350, 1200, 1150, 1210,
                    2250, 1100, 1120,
                ],
                busy=[
                    0, 2, 0, 0,
                    70, 100, 100, 80,
                    0, 100, 100,
                ],
            )

            self.record_pm(output, log)

            summary = self.read_summary(output)
            self.assertEqual(summary["interval-sample-count"], "4")
            self.assertEqual(summary["used-sample-count"], "4")
            self.assertEqual(summary["all-xcd-min"], "1150")
            self.assertEqual(summary["warning"], "")

    def test_missing_active_interval_is_reported_and_raw_log_is_preserved(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            log = self.write_pm_log(output, [250, 2250, 250], [0, 4, 0])

            self.record_pm(output, log, keep_log=False)

            summary = self.read_summary(output)
            self.assertEqual(summary["interval-sample-count"], "0")
            self.assertEqual(summary["used-sample-count"], "0")
            self.assertEqual(summary["all-xcd-min"], "")
            self.assertIn("no active interval", summary["warning"])
            self.assertTrue(log.exists())


if __name__ == "__main__":
    unittest.main()
