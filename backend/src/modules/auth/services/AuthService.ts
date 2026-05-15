import bcrypt from "bcryptjs";
import type { FastifyInstance } from "fastify";
import { env } from "../../../config/env.js";
import { AppError } from "../../../utils/AppError.js";
import { randomToken, sha256 } from "../../../utils/hash.js";
import { AuthRepository } from "../repositories/AuthRepository.js";

const repository = new AuthRepository();

export class AuthService {
  async register(app: FastifyInstance, input: { name: string; email: string; password: string; accountType?: "user" | "artist"; artistName?: string }) {
    const email = input.email.trim().toLowerCase();
    const existing = await repository.findUserByEmail(email);
    if (existing) {
      throw new AppError(409, "email_already_exists", "Email is already registered");
    }

    const accountType = input.accountType ?? "user";
    const role = await repository.findRoleByName(accountType);
    if (!role) {
      throw new AppError(500, "role_not_configured", "Requested role is not configured");
    }

    const artistName = accountType === "artist" ? (input.artistName?.trim() || input.name.trim()) : undefined;
    if (accountType === "artist" && !artistName) {
      throw new AppError(422, "artist_name_required", "Artist name is required");
    }

    const passwordHash = await bcrypt.hash(input.password, 12);
    const user = await repository.createUser({
      name: input.name.trim(),
      email,
      passwordHash,
      roleId: role.id,
      artistName
    });

    return this.issueSession(app, user);
  }

  async login(app: FastifyInstance, input: { email: string; password: string }) {
    const user = await repository.findUserByEmail(input.email.trim().toLowerCase());
    if (!user || !(await bcrypt.compare(input.password, user.passwordHash))) {
      throw new AppError(401, "invalid_credentials", "Email or password is invalid");
    }

    if (user.status !== "active") {
      throw new AppError(403, "user_not_active", "User is not active");
    }

    await repository.updateLastLogin(user.id);
    return this.issueSession(app, user);
  }

  async me(userId: string) {
    const user = await repository.findUserById(BigInt(userId));
    if (!user || user.status !== "active") {
      throw new AppError(401, "invalid_session", "Session is no longer valid");
    }

    return {
      id: user.id.toString(),
      name: user.name,
      email: user.email,
      role: user.role.name,
      artist: (user as any).artistProfile
        ? {
            id: (user as any).artistProfile.id.toString(),
            name: (user as any).artistProfile.name
          }
        : null
    };
  }

  async refresh(app: FastifyInstance, refreshToken: string) {
    const record = await repository.findRefreshToken(sha256(refreshToken));
    if (!record || record.revokedAt || record.expiresAt < new Date()) {
      throw new AppError(401, "invalid_refresh_token", "Refresh token is invalid");
    }

    if (record.user.status !== "active") {
      throw new AppError(403, "user_not_active", "User is not active");
    }

    await repository.revokeRefreshToken(record.tokenHash);
    return this.issueSession(app, record.user);
  }

  async logout(refreshToken: string) {
    await repository.revokeRefreshToken(sha256(refreshToken));
    return { ok: true };
  }

  private async issueSession(
    app: FastifyInstance,
    user: { id: bigint; email: string; name: string; role: { name: string }; artistProfile?: { id: bigint; name: string } | null }
  ) {
    const accessToken = app.jwt.sign({
      sub: user.id.toString(),
      email: user.email,
      role: user.role.name
    });

    const refreshToken = randomToken();
    const expiresAt = new Date(Date.now() + env.REFRESH_TOKEN_DAYS * 24 * 60 * 60 * 1000);
    await repository.saveRefreshToken({
      userId: user.id,
      tokenHash: sha256(refreshToken),
      expiresAt
    });

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id.toString(),
        name: user.name,
        email: user.email,
        role: user.role.name,
        artist: user.artistProfile
          ? {
              id: user.artistProfile.id.toString(),
              name: user.artistProfile.name
            }
          : null
      }
    };
  }
}
