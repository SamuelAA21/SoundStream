import { spawn } from "child_process";
import { randomUUID } from "crypto";
import { resolve } from "path";
import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { requireAdmin } from "../../../middlewares/auth.js";

interface DeployJob {
  status: "running" | "done" | "error";
  branch: string;
  lines: string[];
  startedAt: Date;
}

const jobs = new Map<string, DeployJob>();

const SCRIPT_PATH = resolve(process.cwd(), "..", "deploy", "scripts", "update_server.sh");

const deploySchema = z.object({
  branch: z.string().min(1).max(100).regex(/^[a-zA-Z0-9\-_.\/]+$/, "Invalid branch name")
});

export async function registerAdminDeployRoutes(app: FastifyInstance) {
  app.post("/deploy", { preHandler: requireAdmin }, async (request, reply) => {
    const { branch } = deploySchema.parse(request.body);
    const jobId = randomUUID();

    const job: DeployJob = { status: "running", branch, lines: [], startedAt: new Date() };
    jobs.set(jobId, job);

    const proc = spawn("bash", [SCRIPT_PATH, branch], { cwd: resolve(process.cwd(), "..") });

    proc.stdout.on("data", (chunk: Buffer) => {
      const lines = chunk.toString().split("\n").filter(Boolean);
      job.lines.push(...lines);
    });

    proc.stderr.on("data", (chunk: Buffer) => {
      const lines = chunk.toString().split("\n").filter(Boolean);
      job.lines.push(...lines.map(l => `[err] ${l}`));
    });

    proc.on("close", (code) => {
      job.status = code === 0 ? "done" : "error";
      setTimeout(() => jobs.delete(jobId), 30 * 60 * 1000);
    });

    return reply.status(202).send({ jobId });
  });

  app.get("/deploy/:jobId", { preHandler: requireAdmin }, async (request, reply) => {
    const { jobId } = request.params as { jobId: string };
    const job = jobs.get(jobId);
    if (!job) return reply.status(404).send({ error: { code: "job_not_found", message: "Deploy job not found" } });

    return {
      jobId,
      branch: job.branch,
      status: job.status,
      lines: job.lines,
      startedAt: job.startedAt.toISOString()
    };
  });
}
