import { AppError } from "../../../utils/AppError.js";
import { AdminUserRepository } from "../repositories/AdminUserRepository.js";

const repository = new AdminUserRepository();
const allowedStatuses = new Set(["active", "inactive", "blocked"]);

export class AdminUserService {
  async listUsers() {
    const users = await repository.listUsers();
    return users.map((user) => this.toUserDto(user));
  }

  async updateStatus(input: { adminUserId: string; targetUserId: string; status: string }) {
    if (!allowedStatuses.has(input.status)) {
      throw new AppError(422, "invalid_user_status", "User status is invalid");
    }

    if (input.adminUserId === input.targetUserId && input.status !== "active") {
      throw new AppError(409, "cannot_disable_self", "You cannot disable your own admin account");
    }

    const user = await repository.findUser(BigInt(input.targetUserId));
    if (!user) {
      throw new AppError(404, "user_not_found", "User was not found");
    }

    const updated = await repository.updateStatus({
      userId: user.id,
      status: input.status
    });

    if (input.status !== "active") {
      await repository.revokeUserTokens(user.id);
    }

    return this.toUserDto(updated);
  }

  private toUserDto(user: {
    id: bigint;
    name: string;
    email: string;
    status: string;
    lastLoginAt: Date | null;
    createdAt: Date;
    role: { name: string };
  }) {
    return {
      id: user.id.toString(),
      name: user.name,
      email: user.email,
      role: user.role.name,
      status: user.status,
      lastLoginAt: user.lastLoginAt,
      createdAt: user.createdAt
    };
  }
}
