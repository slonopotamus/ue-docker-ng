package main

import (
	"errors"
	"fmt"
	"os"
)

func run() error {
	
	// Attempt to start the child process for MSBuild, ensuring it inherits its stdout and stderr streams from the parent
	command := append([]string{"cmd.exe", "/c", "C:\\Program Files\\Mono\\bin\\msbuild.bat"}, os.Args[1:]...)
	process, err := os.StartProcess("C:\\Windows\\System32\\cmd.exe", command, &os.ProcAttr{
		Files: []*os.File{nil, os.Stdout, os.Stderr},
	})
	
	// Verify that the child process started successfully
	if err != nil {
		return err
	}
	
	// Wait for the child process to complete
	status, err := process.Wait()
	if err != nil {
		return err
	}
	
	// Verify that the child process completed successfully
	if status.Success() == false {
		return errors.New(fmt.Sprint("command terminated with exit code ", status.ExitCode()))
	}
	
	return nil
}

func main() {
	if err := run(); err != nil {
		fmt.Printf("Error: %s", err.Error())
		os.Exit(1)
	}
}
