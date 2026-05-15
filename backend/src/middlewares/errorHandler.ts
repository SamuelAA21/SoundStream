import type { FastifyError, FastifyReply, FastifyRequest } from "fastify";
import { AppError } from "../utils/AppError.js";

export function errorHandler(error: FastifyError, _request: FastifyRequest, reply: FastifyReply) {
  if (error instanceof AppError) {
    return reply.status(error.statusCode).send({
      error: {
        code: error.code,
        message: error.message
      }
    });
  }

  if (error.validation) {
    return reply.status(422).send({
      error: {
        code: "validation_error",
        message: "Invalid request payload"
      }
    });
  }

  _request.log.error(error);
  return reply.status(500).send({
    error: {
      code: "internal_error",
      message: "Unexpected server error"
    }
  });
}
