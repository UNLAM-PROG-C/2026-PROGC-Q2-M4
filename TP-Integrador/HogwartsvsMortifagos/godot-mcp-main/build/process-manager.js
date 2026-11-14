import { spawn } from "node:child_process";
export class ProcessManager {
    active = null;
    async launchEditor(godotPath, projectPath) {
        // Fire-and-forget: launch the editor, don't track the process
        const child = spawn(godotPath, ["-e", "--path", projectPath], {
            detached: true,
            stdio: "ignore",
        });
        child.unref();
    }
    async runProject(godotPath, projectPath, scene) {
        // Kill any existing process first
        if (this.active) {
            await this.stopProject();
        }
        const args = ["-d", "--path", projectPath];
        if (scene) {
            args.push(scene);
        }
        const child = spawn(godotPath, args, {
            stdio: ["ignore", "pipe", "pipe"],
        });
        const godotProcess = {
            process: child,
            output: [],
            errors: [],
        };
        child.stdout?.on("data", (data) => {
            const lines = data.toString().split("\n").filter(Boolean);
            godotProcess.output.push(...lines);
        });
        child.stderr?.on("data", (data) => {
            const lines = data.toString().split("\n").filter(Boolean);
            godotProcess.errors.push(...lines);
        });
        child.on("exit", () => {
            if (this.active?.process === child) {
                this.active = null;
            }
        });
        this.active = godotProcess;
    }
    async stopProject() {
        if (!this.active) {
            return { output: [], errors: [] };
        }
        const { process: child, output, errors } = this.active;
        this.active = null;
        if (!child.killed) {
            child.kill("SIGTERM");
            // Give it a moment to exit gracefully, then force kill
            await new Promise((resolve) => {
                const timeout = setTimeout(() => {
                    if (!child.killed) {
                        child.kill("SIGKILL");
                    }
                    resolve();
                }, 3000);
                child.on("exit", () => {
                    clearTimeout(timeout);
                    resolve();
                });
            });
        }
        return { output, errors };
    }
    getDebugOutput() {
        if (!this.active) {
            return { output: [], errors: [] };
        }
        return {
            output: [...this.active.output],
            errors: [...this.active.errors],
        };
    }
    isRunning() {
        return this.active !== null && !this.active.process.killed;
    }
}
