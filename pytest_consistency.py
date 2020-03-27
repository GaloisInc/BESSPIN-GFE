import sys
import subprocess

def run_test (command):
    test = subprocess.Popen(command, stdout=subprocess.PIPE)
    return test.returncode

if __name__ == "__main__":
    pytest = "./pytest_processor.py"
    subprocess_command = [pytest]
    [subprocess_command.append(x) for x in sysargv[2:]]
    iterations = sys.argv[1]

    failures = 0

    print ("Running", ' '.join(subrocess_command), iterations, "times. . .")

    for x in range(0, iterations):
        result = run_test(subprocess_command)
        if result != 0:
            # Exited failure
            print ("Run", x, "failed with code", result)
            failures += 1

    print("Completed", iterations, "runs")
    print("Consistency:", failures, "/", iterations, "\n", 
            " ==> [", failures/iterations, "% Fail]", "\n",
            " ==> [", 100-(failures/iterations), "% Success]")
